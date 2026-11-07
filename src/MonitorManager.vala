//
// Copyright (C) 2026 Plank Reloaded Developers
//
// This file is part of Plank.
//
// Plank is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Plank is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

namespace Plank {
  /**
   * Runs one dock on each connected monitor, as `plank --monitor-manager`.
   *
   * Each dock is a plank process of its own, started as
   * `plank -n DOCK --assigned-monitor CONNECTOR`, since a dock can't be
   * freed while plank runs, while a process that ends frees everything.
   * Which dock, and so which settings and launchers, a monitor gets is
   * chosen by choose_monitor_docks (): by the monitor's EDID when it was
   * seen before, else by its position in the layout. Docks are added and
   * removed once a change of monitors has settled, so a monitor that
   * briefly drops out keeps its dock, and a dock that crashes is started
   * again. A dock closed by the user stays closed, and the manager ends
   * once the user has closed every dock.
   */
  public class MonitorManager : GLib.Object {
    // How long monitors have to stay unchanged before docks follow them
    const uint SETTLE_TIME = 2000;
    // How long to wait before starting a crashed dock again
    const uint RESTART_DELAY = 2000;
    // A dock crashing this many times within the window is left stopped
    const int MAX_CRASHES = 3;
    const int64 CRASH_WINDOW = 60 * 1000000;
    // How long docks get to end before the manager quits anyway
    const uint QUIT_TIMEOUT = 5000;

    class Dock {
      public string name;
      public string connector;
      public Pid pid;
      // Stopped by the manager, rather than closed or crashed
      public bool stopping;
    }

    GLib.MainLoop loop;
    GLib.Settings settings;
    string self_exe;
    string[] dock_args = {};

    // The running docks, and the monitor each should be on, by dock name
    Gee.HashMap<string, Dock> docks = new Gee.HashMap<string, Dock> ();
    Gee.HashMap<string, string> wanted = new Gee.HashMap<string, string> ();
    // Docks the user closed, which stay closed
    Gee.HashSet<string> closed = new Gee.HashSet<string> ();
    // Recent crash times of each dock
    Gee.HashMap<string, Gee.ArrayList<int64?>> crashes = new Gee.HashMap<string, Gee.ArrayList<int64?>> ();
    // Docks waiting to be started again after a crash
    Gee.HashSet<string> restarting = new Gee.HashSet<string> ();

    uint settle_timeout_id = 0U;
    bool quitting = false;

    /**
     * Runs the manager until it is told to quit or every dock is closed.
     *
     * @param args the command line
     * @return the exit status
     */
    public int run (string[] args) {
      Gtk.init (ref args);

      Logger.initialize ("plank");
      Logger.DisplayLevel = LogLevel.INFO;
      foreach (unowned string arg in args) {
        if (arg == "-d" || arg == "--debug") {
          Logger.DisplayLevel = LogLevel.DEBUG;
          dock_args += arg;
        } else if (arg == "-v" || arg == "--verbose") {
          Logger.DisplayLevel = LogLevel.VERBOSE;
          dock_args += arg;
        }
      }

      unowned Gdk.Display? display = Gdk.Display.get_default ();
      if (display == null || !(display is Gdk.X11.Display)) {
        critical ("The monitor manager needs an X11 display.");
        return 1;
      }

      Paths.initialize ("plank", Build.PKGDATADIR);
      settings = create_settings ("net.launchpad.plank");
      self_exe = find_self_exe ();
      loop = new GLib.MainLoop ();

      message ("Monitor manager starting");

      display.monitor_added.connect (schedule_reconcile);
      display.monitor_removed.connect (schedule_reconcile);
      Gdk.Screen.get_default ().monitors_changed.connect (schedule_reconcile);

      GLib.Unix.signal_add (Posix.Signal.TERM, handle_quit_signal);
      GLib.Unix.signal_add (Posix.Signal.INT, handle_quit_signal);

      // The monitors at start are as settled as they get
      reconcile ();

      loop.run ();

      message ("Monitor manager stopped");
      return 0;
    }

    [CCode (instance_pos = -1)]
    void schedule_reconcile () {
      if (quitting)
        return;

      // Every change starts the wait over
      if (settle_timeout_id > 0U)
        GLib.Source.remove (settle_timeout_id);

      settle_timeout_id = GLib.Timeout.add (SETTLE_TIME, () => {
        settle_timeout_id = 0U;
        reconcile ();
        return GLib.Source.REMOVE;
      });
    }

    // Works out the dock each monitor should have, then starts, stops and
    // moves docks to match
    void reconcile () {
      unowned Gdk.Display display = Gdk.Display.get_default ();
      var count = display.get_n_monitors ();

      var connectors = new string[count];
      var geometries = new Gdk.Rectangle[count];
      var builtin = new bool[count];
      var identities = new string?[count];

      for (var i = 0; i < count; i++) {
        var monitor = display.get_monitor (i);
        var geometry = monitor.get_geometry ();

        // Mid-change monitors can report no size; wait for them to settle
        if (geometry.width <= 0 || geometry.height <= 0) {
          schedule_reconcile ();
          return;
        }

        connectors[i] = monitor.get_model () ?? "PLUG_MONITOR_%i".printf (i);
        geometries[i] = geometry;
        builtin[i] = monitor_is_builtin (connectors[i]);

        var edid = monitor_get_edid (display, connectors[i]);
        identities[i] = (edid != null ? edid_identity (edid.get_data ()) : null);
      }

      var known = load_known ();
      var taken = dock_names ();

      // Docks an earlier monitor manager kept, by connector, are only taken
      // over on the first run, so they never outrank positions later
      var earlier = new string?[count];
      if (known.is_empty)
        for (var i = 0; i < count; i++)
          earlier[i] = earlier_monitor_dock (connectors[i], taken);

      var positions = monitor_positions (geometries, builtin);
      var chosen = choose_monitor_docks (identities, positions, earlier, known, taken);
      save_known (known);

      wanted.clear ();
      for (var i = 0; i < count; i++) {
        wanted[chosen[i]] = connectors[i];
        debug ("Monitor %s (%s, %s) gets dock '%s'", connectors[i], identities[i] ?? "no EDID", positions[i], chosen[i]);
      }

      foreach (var dock in docks.values.to_array ()) {
        // Gone, or on another monitor now, which a dock only learns as it
        // starts; on its exit the dock starts again if still wanted
        if (!wanted.has_key (dock.name) || wanted[dock.name] != dock.connector)
          stop (dock);
      }

      foreach (var entry in wanted.entries)
        if (!docks.has_key (entry.key) && !closed.contains (entry.key) && !restarting.contains (entry.key))
          start (entry.key, entry.value);
    }

    void start (string name, string connector) {
      string[] argv = { self_exe, "-n", name, "--assigned-monitor", connector };
      foreach (unowned string arg in dock_args)
        argv += arg;

      Pid pid;
      try {
        Process.spawn_async (null, argv, null, SpawnFlags.DO_NOT_REAP_CHILD, null, out pid);
      } catch (SpawnError e) {
        warning ("Could not start dock '%s' for monitor %s: %s", name, connector, e.message);
        return;
      }

      message ("Started dock '%s' on monitor %s (PID %i)", name, connector, (int) pid);

      var dock = new Dock ();
      dock.name = name;
      dock.connector = connector;
      dock.pid = pid;
      docks[name] = dock;

      ChildWatch.add (pid, (pid, status) => handle_dock_exited (dock, status));
    }

    // Asks a dock to end, which it does cleanly on SIGTERM
    void stop (Dock dock) {
      if (dock.stopping)
        return;

      dock.stopping = true;
      message ("Stopping dock '%s' (PID %i)", dock.name, (int) dock.pid);
      Posix.kill ((Posix.pid_t) dock.pid, Posix.Signal.TERM);
    }

    void handle_dock_exited (Dock dock, int status) {
      Process.close_pid (dock.pid);

      if (docks[dock.name] == dock)
        docks.unset (dock.name);

      if (quitting) {
        if (docks.is_empty)
          loop.quit ();
        return;
      }

      if (dock.stopping) {
        // Moved to another monitor while it ran
        if (wanted.has_key (dock.name) && !docks.has_key (dock.name))
          start (dock.name, wanted[dock.name]);
      } else if (Process.if_exited (status) && Process.exit_status (status) == 0) {
        message ("Dock '%s' was closed, it stays closed", dock.name);
        closed.add (dock.name);

        // Only the user closing the last dock ends the manager; docks
        // stopped because their monitors went are back when they return
        if (docks.is_empty && restarting.is_empty) {
          message ("Every dock is closed, the monitor manager quits");
          loop.quit ();
        }
      } else {
        restart_crashed (dock.name);
      }
    }

    void restart_crashed (string name) {
      var now = GLib.get_monotonic_time ();

      // Only crashes within the window count
      var times = new Gee.ArrayList<int64?> ();
      if (crashes.has_key (name))
        foreach (var time in crashes[name])
          if (now - time <= CRASH_WINDOW)
            times.add (time);
      times.add (now);
      crashes[name] = times;

      if (times.size >= MAX_CRASHES) {
        warning ("Dock '%s' crashed %i times within a minute, leaving it stopped", name, times.size);
        return;
      }

      warning ("Dock '%s' crashed, starting it again", name);
      restarting.add (name);
      GLib.Timeout.add (RESTART_DELAY, () => {
        restarting.remove (name);
        if (!quitting && wanted.has_key (name) && !docks.has_key (name))
          start (name, wanted[name]);
        return GLib.Source.REMOVE;
      });
    }

    bool handle_quit_signal () {
      message ("Monitor manager received a termination signal, stopping its docks");
      quitting = true;

      if (settle_timeout_id > 0U) {
        GLib.Source.remove (settle_timeout_id);
        settle_timeout_id = 0U;
      }

      if (docks.is_empty) {
        loop.quit ();
        return GLib.Source.REMOVE;
      }

      foreach (var dock in docks.values.to_array ())
        stop (dock);

      // Quit even if a dock hangs on its way out
      GLib.Timeout.add (QUIT_TIMEOUT, () => {
        loop.quit ();
        return GLib.Source.REMOVE;
      });

      return GLib.Source.REMOVE;
    }

    Gee.HashMap<string, string> load_known () {
      var known = new Gee.HashMap<string, string> ();

      var iter = settings.get_value ("monitor-docks").iterator ();
      string key, name;
      while (iter.next ("{ss}", out key, out name))
        known[key] = name;

      return known;
    }

    void save_known (Gee.Map<string, string> known) {
      var builder = new VariantBuilder (new VariantType ("a{ss}"));
      foreach (var entry in known.entries)
        builder.add ("{ss}", entry.key, entry.value);

      settings.set_value ("monitor-docks", builder.end ());
    }

    // The names of the docks with settings, by their folders
    string[] dock_names () {
      string[] names = {};

      try {
        var children = Paths.AppConfigFolder.enumerate_children (FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE, 0);
        FileInfo? info;
        while ((info = children.next_file ()) != null)
          if (info.get_file_type () == FileType.DIRECTORY)
            names += info.get_name ();
      } catch (Error e) {
        warning ("Could not list the docks' settings: %s", e.message);
      }

      return names;
    }

    static string find_self_exe () {
      try {
        return GLib.FileUtils.read_link ("/proc/self/exe");
      } catch (FileError e) {
        warning ("Could not find this executable (%s), starting docks as 'plank'", e.message);
        return "plank";
      }
    }
  }
}
