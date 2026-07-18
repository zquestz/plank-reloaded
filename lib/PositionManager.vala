//
// Copyright (C) 2012 Robert Dyer, Rico Tzschichholz
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
   * What screen area the dock is positioned within.
   * If AUTO, the area is chosen based on the desktop environment.
   * If MONITOR, the full monitor geometry is used.
   * If WORK_AREA, space reserved by other panels is avoided.
   */
  public enum AreaType {
    AUTO,
    MONITOR,
    WORK_AREA
  }

  /**
   * Handles computing any size/position information for the dock.
   */
  public class PositionManager : GLib.Object {
    public DockController controller { private get; construct; }

    public bool screen_is_composited { get; private set; }

    Gdk.Rectangle static_dock_region;

    // Runaway backstop: total samples per episode before giving up on a
    // measurement that never stabilizes
    const uint SCREEN_UPDATE_MAX_SAMPLES = 20;

    // Debounce for screen updates. Doubles as the settle window
    // after a strut withdrawal: accepted work-area events keep re-arming
    // it, so the evaluation only runs once the work area has gone quiet.
    const uint SCREEN_UPDATE_DEBOUNCE_TIME = 1000U;

    // Interval between measurement samples once an evaluation has begun
    const uint SCREEN_UPDATE_SAMPLE_TIME = 500U;

    // Consecutive agreeing samples required before an episode ends; in
    // monitor mode this only bounds the wait for geometry that lags its
    // trigger, since a changed sample completes the episode immediately
    const uint SCREEN_UPDATE_STABLE_SAMPLES = 5;

    uint active_display_timeout_id;
    uint screen_update_timeout_id;
    uint screen_sample_timeout_id;

    Gdk.Rectangle monitor_geo;
    int monitor_num;
    int last_update_monitor_num;

    // Work-area mode state: external panel margins around the raw monitor
    // geometry, measured from the per-monitor work area. The three edges we
    // reserve nothing on always measure clean; the dock's own edge can only
    // be measured while our strut is not asserted (same-edge struts combine
    // by max), so it holds its last clean value in between. Strut-free
    // docks track work-area changes live; asserted docks re-measure through
    // the withdraw-and-settle path on screen or preference changes only.
    int area_margin_top = 0;
    int area_margin_bottom = 0;
    int area_margin_left = 0;
    int area_margin_right = 0;
    bool workarea_filter_installed = false;
    X.Atom workarea_atom = X.None;
    X.Atom gtk_workareas_atom = X.None;
    X.Atom current_desktop_atom = X.None;

    // Raw monitor geometry from the last measurement, and whether the
    // current update episode has seen it move: during geometry
    // transitions margin decreases are held (see held_margin)
    Gdk.Rectangle last_raw_geo;
    bool geometry_change_in_flight = false;

    int max_hover_height_cache = 0;
    int max_hover_width_cache = 0;
    int window_scale_factor = 1;

    /**
     * Creates a new position manager.
     *
     * @param controller the dock controller to manage positions for
     */
    public PositionManager (DockController controller) {
      GLib.Object (controller: controller);
    }

    construct
    {
      static_dock_region = {};
    }

    /**
     * Initializes the position manager.
     */
    public void initialize ()
    requires (controller.window != null)
    {
      unowned Gdk.Screen screen = controller.window.get_screen ();

      controller.prefs.notify.connect (prefs_changed);
      screen.monitors_changed.connect (schedule_screen_update);
      screen.size_changed.connect (schedule_screen_update);
      screen.composited_changed.connect (screen_composited_changed);
      controller.window.notify["scale-factor"].connect (window_scale_factor_changed);

      var display = screen.get_display ();
      monitor_num = find_monitor_number (screen, controller.prefs.Monitor);
      var monitor = display.get_monitor (monitor_num);

      update_monitor_geo (monitor);
      watch_workarea ();

      screen_is_composited = screen.is_composited ();

      if (controller.prefs.ActiveDisplay) {
        start_active_display_polling ();
      }
    }

    ~PositionManager () {
      stop_active_display_polling ();
      stop_screen_update_timeout ();
      unwatch_workarea ();

      unowned Gdk.Screen screen = controller.window.get_screen ();

      screen.monitors_changed.disconnect (schedule_screen_update);
      screen.size_changed.disconnect (schedule_screen_update);
      screen.composited_changed.disconnect (screen_composited_changed);
      controller.window.notify["scale-factor"].disconnect (window_scale_factor_changed);
      controller.prefs.notify.disconnect (prefs_changed);
    }

    bool use_monitor_geometry () {
      switch (controller.prefs.AreaMode) {
      case AreaType.MONITOR:
        return true;
      case AreaType.WORK_AREA:
        return false;
      default:
      case AreaType.AUTO:
        return environment_is_session_desktop (XdgSessionDesktop.GNOME | XdgSessionDesktop.UBUNTU | XdgSessionDesktop.MATE | XdgSessionDesktop.CINNAMON | XdgSessionDesktop.XFCE | XdgSessionDesktop.KDE);
      }
    }

    void reset_area_margins () {
      area_margin_top = 0;
      area_margin_bottom = 0;
      area_margin_left = 0;
      area_margin_right = 0;
    }

    bool update_monitor_geo (Gdk.Monitor monitor) {
      var geo = monitor.get_geometry ();

      // Hotplug transients can report empty geometry; keep the previous
      // state and report the measurement unusable, so sampling neither
      // trusts nor stabilizes on it
      if (geo.width <= 0 || geo.height <= 0)
        return false;

      // The first measurement only seeds the reference: it runs outside
      // any update episode, so a flag set here would never be cleared
      if (last_raw_geo.width != 0
          && (geo.x != last_raw_geo.x || geo.y != last_raw_geo.y
              || geo.width != last_raw_geo.width || geo.height != last_raw_geo.height))
        geometry_change_in_flight = true;

      last_raw_geo = geo;

      if (use_monitor_geometry ()) {
        reset_area_margins ();
        monitor_geo = geo;
        return true;
      }

      update_area_margins (monitor, geo);

      Gdk.Rectangle available = geo;
      available.x += area_margin_left;
      available.y += area_margin_top;
      available.width -= area_margin_left + area_margin_right;
      available.height -= area_margin_top + area_margin_bottom;

      // Never let a bogus work area collapse the dock's space. The margin
      // fields keep their measured values: transient absurd readings
      // correct themselves at the next sample, and a held own edge must
      // survive the turbulence.
      if (available.width < geo.width / 2 || available.height < geo.height / 2) {
        warning ("Work area margins look bogus (%i,%i,%i,%i), using monitor geometry",
                 area_margin_top, area_margin_bottom, area_margin_left, area_margin_right);
        monitor_geo = geo;
        return true;
      }

      monitor_geo = available;
      return true;
    }

    static int sane_margin (int margin, int dimension) {
      // A margin claiming more than half the monitor is never a real
      // panel, only a transiently stale reading; treat it as empty rather
      // than storing it (where a held own edge could keep it alive)
      return (margin > dimension / 2 ? 0 : margin);
    }

    void update_area_margins (Gdk.Monitor monitor, Gdk.Rectangle geo) {
      var workarea = monitor.get_workarea ();

      // Stored margins may predate a dimension change: drop any that are
      // impossible under the current geometry, so a held value that was
      // legal on the old size cannot trip the bogus-geometry fallback
      area_margin_top = sane_margin (area_margin_top, geo.height);
      area_margin_bottom = sane_margin (area_margin_bottom, geo.height);
      area_margin_left = sane_margin (area_margin_left, geo.width);
      area_margin_right = sane_margin (area_margin_right, geo.width);

      var top = sane_margin ((workarea.y - geo.y).clamp (0, geo.height), geo.height);
      var left = sane_margin ((workarea.x - geo.x).clamp (0, geo.width), geo.width);
      var bottom = sane_margin (((geo.y + geo.height) - (workarea.y + workarea.height)).clamp (0, geo.height), geo.height);
      var right = sane_margin (((geo.x + geo.width) - (workarea.x + workarea.width)).clamp (0, geo.width), geo.width);

      // The dock's own edge folds our strut into the work area whenever it
      // is asserted (same-edge struts combine by max), so it only refreshes
      // while measurable and holds its last clean value otherwise
      var own_edge_measurable = !controller.window.struts_asserted;

      switch (Position) {
      default:
      case Gtk.PositionType.BOTTOM:
        area_margin_top = held_margin (top, area_margin_top);
        area_margin_left = held_margin (left, area_margin_left);
        area_margin_right = held_margin (right, area_margin_right);
        if (own_edge_measurable)
          area_margin_bottom = held_margin (bottom, area_margin_bottom);
        break;
      case Gtk.PositionType.TOP:
        area_margin_bottom = held_margin (bottom, area_margin_bottom);
        area_margin_left = held_margin (left, area_margin_left);
        area_margin_right = held_margin (right, area_margin_right);
        if (own_edge_measurable)
          area_margin_top = held_margin (top, area_margin_top);
        break;
      case Gtk.PositionType.LEFT:
        area_margin_top = held_margin (top, area_margin_top);
        area_margin_bottom = held_margin (bottom, area_margin_bottom);
        area_margin_right = held_margin (right, area_margin_right);
        if (own_edge_measurable)
          area_margin_left = held_margin (left, area_margin_left);
        break;
      case Gtk.PositionType.RIGHT:
        area_margin_top = held_margin (top, area_margin_top);
        area_margin_bottom = held_margin (bottom, area_margin_bottom);
        area_margin_left = held_margin (left, area_margin_left);
        if (own_edge_measurable)
          area_margin_right = held_margin (right, area_margin_right);
        break;
      }
    }

    int held_margin (int measured, int held) {
      // Outside geometry transitions the work area is trustworthy in both
      // directions: a real panel removal arrives as a work-area change
      // with unchanged geometry and must be tracked live
      if (!geometry_change_in_flight)
        return measured;

      // While the monitor geometry is moving, the WM can publish a work
      // area missing a panel's reservation for the entire measurement
      // window (the panel is placed visually, but its strut only lands
      // once something re-runs the WM's region update), and a withdrawn
      // sibling dock's reservation is equally absent. The last measured
      // values are the only surviving copy of the truth, so decreases are
      // held for the rest of the episode; monitor switches and
      // AreaMode/Position changes reset them.
      if (measured < held) {
        debug ("PositionManager.held_margin () holding %i over measured %i", held, measured);
        return held;
      }

      return measured;
    }

    void watch_workarea () {
      if (workarea_filter_installed)
        return;

      // GTK3 never emits notify for Gdk.Monitor.workarea (it is computed
      // on demand from root window properties), so listen for
      // _NET_WORKAREA changes ourselves
      workarea_atom = Gdk.X11.get_xatom_by_name ("_NET_WORKAREA");

      // Mutter-family WMs also publish per-monitor work areas, which can
      // change without the global value moving (e.g. a panel switching
      // monitors on the same edge). Measurements read the current
      // workspace's property, so that is the one to watch, following the
      // user across workspace switches.
      current_desktop_atom = Gdk.X11.get_xatom_by_name ("_NET_CURRENT_DESKTOP");
      update_gtk_workareas_atom ();

      unowned Gdk.Window root = controller.window.get_screen ().get_root_window ();
      root.set_events (root.get_events () | Gdk.EventMask.PROPERTY_CHANGE_MASK);
      gdk_window_add_filter (root, (Gdk.FilterFunc) workarea_xevent_filter);
      workarea_filter_installed = true;
    }

    void unwatch_workarea () {
      if (!workarea_filter_installed)
        return;

      unowned Gdk.Window root = controller.window.get_screen ().get_root_window ();
      gdk_window_remove_filter (root, (Gdk.FilterFunc) workarea_xevent_filter);
      workarea_filter_installed = false;
    }

    void update_gtk_workareas_atom () {
      unowned Gdk.X11.Screen? screen = controller.window.get_screen () as Gdk.X11.Screen;
      var desktop = (screen != null ? screen.get_current_desktop () : 0);
      gtk_workareas_atom = Gdk.X11.get_xatom_by_name ("_GTK_WORKAREAS_D%u".printf (desktop));
    }

    [CCode (instance_pos = -1)]
    Gdk.FilterReturn workarea_xevent_filter (Gdk.XEvent gdk_xevent, Gdk.Event gdk_event) {
      X.Event* xevent = (X.Event*) gdk_xevent;

      // Keep the watched per-desktop atom following the user's workspace
      if (xevent.type == X.EventType.PropertyNotify && xevent.xproperty.atom == current_desktop_atom)
        update_gtk_workareas_atom ();

      if (xevent.type == X.EventType.PropertyNotify
          && (xevent.xproperty.atom == workarea_atom || xevent.xproperty.atom == gtk_workareas_atom)
          && !use_monitor_geometry ()) {
        // Only strut-free docks track the work area live. While our strut
        // is asserted, events cannot be attributed safely: the own edge
        // only echoes our own reservation, and other docks (possibly in
        // other processes) produce transitions indistinguishable from
        // panels, so reacting could make two docks churn each other
        // without ever settling. Screen and preference triggers
        // re-measure instead.
        var accepted = !controller.window.struts_asserted;
        debug ("PositionManager.workarea_changed (accepted = %s)", accepted.to_string ());

        if (accepted)
          schedule_screen_update (controller.window.get_screen ());
      }

      return Gdk.FilterReturn.CONTINUE;
    }

    void prefs_changed (Object prefs, ParamSpec prop) {
      switch (prop.name) {
      case "Monitor":
        prefs_monitor_changed ();
        break;
      case "ActiveDisplay":
        prefs_active_display_changed ();
        break;
      case "ActiveDisplayPollingInterval":
        prefs_active_display_polling_interval_changed ();
        break;
      case "GapSize":
        prefs_gap_size_changed ();
        break;
      case "AreaMode":
      case "Position":
        // Both change where the dock's area comes from: drop any held
        // margins so everything is re-measured from scratch (this makes
        // flipping the mode the manual refresh for a stale hold), then
        // re-measure through the withdraw-and-settle path so an asserted
        // strut cannot pollute the fresh measurement
        reset_area_margins ();

        // Entering monitor mode needs no clean measurement: end any
        // inherited episode right away instead of waiting out sampling
        if (use_monitor_geometry ())
          end_screen_update_episode ();

        schedule_screen_update (controller.window.get_screen ());
        break;
      case "ZoomPercent":
      case "ZoomEnabled":
        prefs_zoom_changed ();
        break;
      default:
        // Nothing important for us changed
        break;
      }
    }

    public string active_monitor () {
      var screen = controller.window.get_screen ();
      var display = screen.get_display ();

      int x, y;
      display.get_default_seat ()
       .get_pointer ()
       .get_position (null, out x, out y);

      var monitor = display.get_monitor_at_point (x, y);
      int active_monitor_num = 0;

      int n_monitors = display.get_n_monitors ();
      for (int i = 0; i < n_monitors; i++) {
        if (display.get_monitor (i) == monitor)
          active_monitor_num = i;
      }

      return get_monitor_name (monitor, active_monitor_num);
    }

    public void move_to_active_monitor () {
      string monitor_name = active_monitor ();

      if (controller.prefs.Monitor != monitor_name) {
        debug ("Moving dock to current monitor (%s)", monitor_name);
        controller.prefs.Monitor = monitor_name;
      }
    }

    void start_active_display_polling () {
      active_display_timeout_id = GLib.Timeout.add_seconds (controller.prefs.ActiveDisplayPollingInterval, () => {
        if (controller.prefs.ActiveDisplay) {
          move_to_active_monitor ();
          return GLib.Source.CONTINUE;
        } else {
          active_display_timeout_id = 0;
          return GLib.Source.REMOVE;
        }
      });
    }

    void stop_active_display_polling () {
      if (active_display_timeout_id > 0) {
        GLib.Source.remove (active_display_timeout_id);
        active_display_timeout_id = 0;
      }
    }

    void stop_screen_update_timeout () {
      if (screen_update_timeout_id > 0) {
        GLib.Source.remove (screen_update_timeout_id);
        screen_update_timeout_id = 0;
      }
      if (screen_sample_timeout_id > 0) {
        GLib.Source.remove (screen_sample_timeout_id);
        screen_sample_timeout_id = 0;
      }
    }

    static string get_monitor_name (Gdk.Monitor monitor, int index) {
      return monitor.get_model () ?? "PLUG_MONITOR_%i".printf (index);
    }

    public static string[] get_monitor_plug_names (Gdk.Screen screen) {
      var display = screen.get_display ();
      int n_monitors = display.get_n_monitors ();
      var result = new string[n_monitors];

      for (int i = 0; i < n_monitors; i++) {
        result[i] = get_monitor_name (display.get_monitor (i), i);
      }

      return result;
    }

    static int find_monitor_number (Gdk.Screen screen, string plug_name) {
      var display = screen.get_display ();
      var primary_monitor = display.get_primary_monitor ();

      if (plug_name == "") {
        // Find the index of the primary monitor
        int n_monitors = display.get_n_monitors ();
        for (int i = 0; i < n_monitors; i++) {
          if (display.get_monitor (i) == primary_monitor)
            return i;
        }
        return 0; // Fallback to first monitor
      }

      int n_monitors = display.get_n_monitors ();
      for (int i = 0; i < n_monitors; i++) {
        if (plug_name == get_monitor_name (display.get_monitor (i), i))
          return i;
      }

      // If we didn't find a match, find primary monitor index
      for (int i = 0; i < n_monitors; i++) {
        if (display.get_monitor (i) == primary_monitor)
          return i;
      }
      return 0; // Fallback to first monitor
    }

    void prefs_monitor_changed () {
      schedule_screen_update (controller.window.get_screen ());
    }

    void prefs_active_display_changed () {
      if (controller.prefs.ActiveDisplay) {
        start_active_display_polling ();
      } else {
        stop_active_display_polling ();
      }
    }

    void prefs_active_display_polling_interval_changed () {
      if (controller.prefs.ActiveDisplay) {
        stop_active_display_polling ();
        start_active_display_polling ();
      }
    }

    void window_scale_factor_changed () {
      Logger.verbose ("PositionManager.window_scale_factor_changed ()");
      schedule_screen_update (controller.window.get_screen ());
    }

    void schedule_screen_update (Gdk.Screen screen) {
      // Withhold struts for the whole episode, so the measurement stays
      // free of our own reservation even if HideMode flips to NONE
      // mid-episode; the evaluation exits re-apply whatever the state
      // then calls for
      if (!use_monitor_geometry ())
        controller.window.clear_struts ();

      // Every trigger resets the whole episode: the quiet period starts
      // over and any sampling in progress is abandoned
      stop_screen_update_timeout ();

      screen_update_timeout_id = GLib.Timeout.add (SCREEN_UPDATE_DEBOUNCE_TIME, () => {
        screen_update_timeout_id = 0;
        do_screen_update (screen, 0, 0);
        return GLib.Source.REMOVE;
      });
    }

    void schedule_screen_sample (Gdk.Screen screen, uint sample, uint stable) {
      screen_sample_timeout_id = GLib.Timeout.add (SCREEN_UPDATE_SAMPLE_TIME, () => {
        screen_sample_timeout_id = 0;
        do_screen_update (screen, sample, stable);
        return GLib.Source.REMOVE;
      });
    }

    void end_screen_update_episode () {
      geometry_change_in_flight = false;
      controller.window.release_struts ();
    }

    void do_screen_update (Gdk.Screen screen, uint sample, uint stable) {
      var old_monitor_geo = monitor_geo;
      var old_monitor_num = monitor_num;

      var display = screen.get_display ();
      monitor_num = find_monitor_number (screen, controller.prefs.Monitor);
      var monitor = display.get_monitor (monitor_num);

      // A different monitor starts from scratch: margins are per-monitor
      // facts, and a held own-edge value must not carry across
      if (old_monitor_num != monitor_num)
        reset_area_margins ();

      if (!update_monitor_geo (monitor)) {
        // Nothing usable was measured: the retained state must neither be
        // applied as a change nor counted towards stability
        if (sample + 1 < SCREEN_UPDATE_MAX_SAMPLES) {
          schedule_screen_sample (screen, sample + 1, 0);
          return;
        }

        debug ("PositionManager.do_screen_update () gave up, no valid geometry");

        // Monitor mode never withdrew, so an asserted strut could keep
        // reserving a removed monitor's edge indefinitely: clear it here.
        // Elsewhere this is a no-op (work-area episodes already withdrew,
        // strut-free docks have nothing to clear), and the release below
        // cannot re-assert while the geometry stays invalid.
        controller.window.clear_struts ();

        end_screen_update_episode ();
        return;
      }

      if (old_monitor_num == monitor_num
          && old_monitor_geo.x == monitor_geo.x
          && old_monitor_geo.y == monitor_geo.y
          && old_monitor_geo.width == monitor_geo.width
          && old_monitor_geo.height == monitor_geo.height) {
        stable++;

        // Enough consecutive agreeing samples: the transition is over
        // (or the trigger was spurious and nothing ever arrived)
        if (stable >= SCREEN_UPDATE_STABLE_SAMPLES) {
          debug ("PositionManager.do_screen_update () settled after %u samples", sample + 1);
          end_screen_update_episode ();
          return;
        }

        if (sample + 1 < SCREEN_UPDATE_MAX_SAMPLES) {
          schedule_screen_sample (screen, sample + 1, stable);
          return;
        }

        debug ("PositionManager.do_screen_update () gave up waiting for a change");
        end_screen_update_episode ();
        return;
      }

      Logger.verbose ("PositionManager.monitor_geo_changed (%i,%i-%ix%i)",
                      monitor_geo.x, monitor_geo.y, monitor_geo.width, monitor_geo.height);

      freeze_notify ();

      update_dimensions ();
      update_regions ();

      // A margin change can shift the monitor area without changing the
      // window-relative dock region, which update_regions' guard skips;
      // reposition explicitly (a no-op when already in place)
      controller.window.update_size_and_position ();

#if HAVE_BARRIERS
      controller.hide_manager.update_barrier ();
#endif

      thaw_notify ();

      // Monitor geometry needs no stability verification: invalid readings
      // never get this far, and only work-area margins can look plausible
      // yet wrong mid-transition, so the update is complete as soon as a
      // change lands
      if (use_monitor_geometry ()) {
        end_screen_update_episode ();
        return;
      }

      // The measurement moved: keep the strut withheld and restart the
      // stability count, so late changes (like a panel re-anchoring after
      // a screen shrink) are caught instead of locked out
      if (sample + 1 < SCREEN_UPDATE_MAX_SAMPLES) {
        schedule_screen_sample (screen, sample + 1, 0);
        return;
      }

      debug ("PositionManager.do_screen_update () gave up, measurements still changing");
      end_screen_update_episode ();
    }

    void screen_composited_changed (Gdk.Screen screen) {
      freeze_notify ();

      screen_is_composited = screen.is_composited ();

      update (controller.renderer.theme);

      thaw_notify ();
    }

    //
    // used to cache various sizes calculated from the theme and preferences
    //

    /**
     * Theme-based line-width.
     */
    public int LineWidth { get; private set; }

    /**
     * Cached current icon size for the dock.
     */
    public int IconSize { get; private set; }

    /**
     * Cached current gap size for the dock.
     */
    public int GapSize { get; private set; }

    /**
     * Cached current icon size for the dock.
     */
    public int ZoomIconSize { get; private set; }

    /**
     * Cached position of the dock.
     */
    public Gtk.PositionType Position { get; private set; }

    /**
     * Cached alignment of the dock.
     */
    public Gtk.Align Alignment { get; private set; }

    /**
     * Cached alignment of the items.
     */
    public Gtk.Align ItemsAlignment { get; private set; }

    /**
     * Cached offset of the dock.
     */
    public int Offset { get; private set; }

    /**
     * Theme-based indicator size, scaled by icon size.
     */
    public int IndicatorSize { get; private set; }
    /**
     * Theme-based icon-shadow size, scaled by icon size.
     */
    public int IconShadowSize { get; private set; }
    /**
     * Theme-based urgent glow size, scaled by icon size.
     */
    public int GlowSize { get; private set; }
    /**
     * Theme-based horizontal padding, scaled by icon size.
     */
    public int HorizPadding  { get; private set; }
    /**
     * Theme-based top padding, scaled by icon size.
     */
    public int TopPadding    { get; private set; }
    /**
     * Theme-based bottom padding, scaled by icon size.
     */
    public int BottomPadding { get; private set; }
    /**
     * Theme-based item padding, scaled by icon size.
     */
    public int ItemPadding   { get; private set; }
    /**
     * Theme-based urgent-bounce height, scaled by icon size.
     */
    public int UrgentBounceHeight { get; private set; }
    /**
     * Theme-based launch-bounce height, scaled by icon size.
     */
    public int LaunchBounceHeight { get; private set; }
    /**
     * Theme-based separator padding, scaled by icon size.
     */
    public int SeparatorPadding { get; private set; }

    int items_width;
    int items_offset;
    int top_offset;
    int bottom_offset;
    int extra_hide_offset;

    /**
     * x position of the dock window.
     */
    int win_x;
    /**
     * y position of the dock window.
     */
    int win_y;

    /**
     * The currently visible height of the dock.
     */
    int VisibleDockHeight;
    /**
     * The static height of the dock.
     */
    int DockHeight;
    /**
     * The height of the dock's background image.
     */
    int DockBackgroundHeight;

    /**
     * The currently visible width of the dock.
     */
    int VisibleDockWidth;
    /**
     * The static width of the dock.
     */
    int DockWidth;
    /**
     * The width of the dock's background image.
     */
    int DockBackgroundWidth;

    double ZoomPercent;

    Gdk.Rectangle background_rect;

    /**
     * The maximum item count which fit the dock in its maximum
     * size with the current theme and icon-size.
     */
    public int MaxItemCount { get; private set; }

    /**
     * The maximum icon-size which results in a dock which fits on
     * the target screen edge.
     */
    int MaxIconSize { get; private set; default = DockPreferences.MAX_ICON_SIZE; }

    /**
     * Updates all internal caches.
     *
     * @param theme the current dock theme
     */
    public void update (DockTheme theme) {
      Logger.verbose ("PositionManager.update ()");

      screen_is_composited = controller.window.get_screen ().is_composited ();

      freeze_notify ();

      update_caches (theme);
      update_max_icon_size (theme);
      update_dimensions ();
      update_regions ();

      thaw_notify ();
    }

    void update_caches (DockTheme theme) {
      unowned DockPreferences prefs = controller.prefs;

      Position = prefs.Position;
      Alignment = prefs.Alignment;
      ItemsAlignment = prefs.ItemsAlignment;
      Offset = prefs.Offset;

      // Mirror position/alignments/offset for RTL environments if needed
      if (Gtk.Widget.get_default_direction () == Gtk.TextDirection.RTL) {
        if (is_horizontal_dock ()) {
          if (Alignment == Gtk.Align.START)
            Alignment = Gtk.Align.END;
          else if (Alignment == Gtk.Align.END)
            Alignment = Gtk.Align.START;

          if (ItemsAlignment == Gtk.Align.START)
            ItemsAlignment = Gtk.Align.END;
          else if (ItemsAlignment == Gtk.Align.END)
            ItemsAlignment = Gtk.Align.START;

          Offset = -Offset;
        } else {
          if (Position == Gtk.PositionType.RIGHT)
            Position = Gtk.PositionType.LEFT;
          else
            Position = Gtk.PositionType.RIGHT;
        }
      }

      IconSize = int.min (MaxIconSize, prefs.IconSize);
      GapSize = prefs.GapSize;
      ZoomPercent = (screen_is_composited ? prefs.ZoomPercent / 100.0 : 1.0);
      ZoomIconSize = (screen_is_composited && prefs.ZoomEnabled ? (int) Math.round (IconSize * ZoomPercent) : IconSize);

      var scaled_icon_size = IconSize / 10.0;

      IconShadowSize = (int) Math.ceil (theme.IconShadowSize * scaled_icon_size);
      IndicatorSize = (int) (theme.IndicatorSize * scaled_icon_size);
      GlowSize = (int) (theme.GlowSize * scaled_icon_size);
      HorizPadding = (int) (theme.HorizPadding * scaled_icon_size);
      TopPadding = (int) (theme.TopPadding * scaled_icon_size);
      BottomPadding = (int) (theme.BottomPadding * scaled_icon_size);
      ItemPadding = (int) (theme.ItemPadding * scaled_icon_size);
      SeparatorPadding = (int) (theme.SeparatorPadding * scaled_icon_size);
      UrgentBounceHeight = (int) (theme.UrgentBounceHeight * IconSize);
      LaunchBounceHeight = (int) (theme.LaunchBounceHeight * IconSize);
      LineWidth = theme.LineWidth;

      if (!screen_is_composited) {
        if (HorizPadding < 0)
          HorizPadding = (int) scaled_icon_size;
        if (TopPadding < 0)
          TopPadding = (int) scaled_icon_size;
      }

      items_offset = (int) (2 * LineWidth + (HorizPadding > 0 ? HorizPadding : 0));

      top_offset = theme.get_top_offset () + TopPadding;
      bottom_offset = theme.get_bottom_offset () + BottomPadding;

      if (top_offset < 0)
        extra_hide_offset = IconShadowSize;
      else if (top_offset < IconShadowSize)
        extra_hide_offset = (IconShadowSize - top_offset);
      else
        extra_hide_offset = 0;
    }

    void prefs_zoom_changed () {
      unowned DockPreferences prefs = controller.prefs;

      ZoomPercent = (screen_is_composited ? prefs.ZoomPercent / 100.0 : 1.0);
      ZoomIconSize = (screen_is_composited && prefs.ZoomEnabled ? (int) Math.round (IconSize * ZoomPercent) : IconSize);

      freeze_notify ();

      update_dimensions ();
      update_regions ();

      thaw_notify ();
    }

    void prefs_gap_size_changed () {
      unowned DockPreferences prefs = controller.prefs;

      GapSize = prefs.GapSize;

      freeze_notify ();

      update_dock_position ();
      controller.window.update_size_and_position ();

      thaw_notify ();
    }

    int get_items_width (Gee.ArrayList<unowned DockItem> items) {
      int width = items.size * IconSize;

      // Add padding between items - separator affects padding on both sides
      for (int idx = 0; idx < items.size - 1; idx++) {
        var item = items[idx];
        var next = items[idx + 1];

        // If either current item or next item is a separator, use SeparatorPadding
        if (item.is_separator () || next.is_separator ()) {
          width += SeparatorPadding;
        } else {
          width += ItemPadding;
        }
      }

      return width;
    }

    /**
     * Find an appropriate MaxIconSize
     */
    void update_max_icon_size (DockTheme theme) {
      unowned DockPreferences prefs = controller.prefs;

      // Check if the dock is oversized and doesn't fit the targeted screen-edge
      var width = get_items_width (controller.VisibleItems) + 2 * HorizPadding + 4 * LineWidth;
      var max_width = (is_horizontal_dock () ? monitor_geo.width : monitor_geo.height);
      var step_size = int.max (1, (int) (Math.fabs (width - max_width) / controller.VisibleItems.size));

      if (width > max_width && MaxIconSize > DockPreferences.MIN_ICON_SIZE) {
        MaxIconSize -= step_size;
      } else if (width < max_width && MaxIconSize < prefs.IconSize && step_size > 1) {
        MaxIconSize += step_size;
      } else {
        // Make sure the MaxIconSize is even and restricted properly
        MaxIconSize = int.max (DockPreferences.MIN_ICON_SIZE,
                               int.min (DockPreferences.MAX_ICON_SIZE, (int) (MaxIconSize / 2.0) * 2));
        Logger.verbose ("PositionManager.MaxIconSize = %i", MaxIconSize);
        update_caches (theme);
        return;
      }

      update_caches (theme);
      update_max_icon_size (theme);
    }

    void update_dimensions () {
      Logger.verbose ("PositionManager.update_dimensions ()");

      // height of the visible (cursor) rect of the dock
      var height = IconSize + top_offset + bottom_offset;

      // height of the dock background image, as drawn
      var background_height = int.max (0, height);

      if (top_offset < 0)
        height -= top_offset;

      // height of the dock window
      var dock_height = height + (screen_is_composited ? UrgentBounceHeight : 0) * (int) (Math.ceil (ZoomPercent));

      var width = 0;
      switch (Alignment) {
      default:
      case Gtk.Align.START:
      case Gtk.Align.END:
      case Gtk.Align.CENTER:
        width = get_items_width (controller.VisibleItems) + 2 * HorizPadding + 4 * LineWidth;
        break;
      case Gtk.Align.FILL:
        if (is_horizontal_dock ())
          width = monitor_geo.width;
        else
          width = monitor_geo.height;
        break;
      }

      // width of the dock background image, as drawn
      var background_width = int.max (0, width);

      // width of the visible (cursor) rect of the dock
      if (HorizPadding < 0)
        width -= 2 * HorizPadding;

      if (is_horizontal_dock ()) {
        width = int.min (monitor_geo.width, width);
        VisibleDockHeight = height;
        VisibleDockWidth = width;
        DockHeight = dock_height;
        DockWidth = (screen_is_composited ? monitor_geo.width : width);
        DockBackgroundHeight = background_height;
        DockBackgroundWidth = background_width;
        MaxItemCount = (int) Math.floor ((double) (monitor_geo.width - 2 * HorizPadding + 4 * LineWidth) / (ItemPadding + IconSize));
      } else {
        width = int.min (monitor_geo.height, width);
        VisibleDockHeight = width;
        VisibleDockWidth = height;
        DockHeight = (screen_is_composited ? monitor_geo.height : width);
        DockWidth = dock_height;
        DockBackgroundHeight = background_width;
        DockBackgroundWidth = background_height;
        MaxItemCount = (int) Math.floor ((double) (monitor_geo.height - 2 * HorizPadding + 4 * LineWidth) / (ItemPadding + IconSize));
      }
    }

    /**
     * Return whether or not a dock is a horizontal dock.
     *
     * @return true if the dock's position indicates it is horizontal
     */
    public bool is_horizontal_dock () {
      return (Position == Gtk.PositionType.TOP || Position == Gtk.PositionType.BOTTOM);
    }

    /**
     * Returns the cursor region for the dock.
     * This is the region that the cursor can interact with the dock.
     *
     * @return the cursor region for the dock
     */
    public Gdk.Rectangle get_cursor_region () {
      var cursor_region = static_dock_region;

      switch (Position) {
      case Gtk.PositionType.BOTTOM:
      case Gtk.PositionType.TOP:
        cursor_region.height = int.max (cursor_region.height, max_hover_height_cache);
        break;
      case Gtk.PositionType.LEFT:
      case Gtk.PositionType.RIGHT:
        cursor_region.width = int.max (cursor_region.width, max_hover_width_cache);
        break;
      }

      var progress = 1.0 - controller.renderer.hide_progress;
      window_scale_factor = controller.window.get_window ().get_scale_factor ();

      unowned DockItem? hovered_item = controller.window.HoveredItem;
      if (hovered_item != null) {
        var hover_region = get_hover_region_for_element (hovered_item);
        cursor_region.union (hover_region, out cursor_region);
      }

      // When GapSize is set, then we use polling for HideManager
      var min_hover_region = GapSize > 0 ? 0 : 1;

      switch (Position) {
      default :
      case Gtk.PositionType.BOTTOM:
        cursor_region.height = int.max (min_hover_region * window_scale_factor, (int) (progress * cursor_region.height));
        cursor_region.y = DockHeight - cursor_region.height + (window_scale_factor - 1);
        break;
      case Gtk.PositionType.TOP:
        cursor_region.height = int.max (min_hover_region * window_scale_factor, (int) (progress * cursor_region.height));
        cursor_region.y = 0;
        break;
      case Gtk.PositionType.LEFT:
        cursor_region.width = int.max (min_hover_region * window_scale_factor, (int) (progress * cursor_region.width));
        cursor_region.x = 0;
        break;
      case Gtk.PositionType.RIGHT:
        cursor_region.width = int.max (min_hover_region * window_scale_factor, (int) (progress * cursor_region.width));
        cursor_region.x = DockWidth - cursor_region.width + (window_scale_factor - 1);
        break;
      }

      return cursor_region;
    }

    /**
     * Returns the static dock region for the dock.
     * This is the region that the dock occupies when not hidden.
     *
     * @return the static dock region for the dock
     */
    public Gdk.Rectangle get_static_dock_region () {
      var dock_region = static_dock_region;
      dock_region.x += win_x;
      dock_region.y += win_y;

      // Revert adjustments made by update_dock_position () for non-compositing mode
      if (!screen_is_composited && controller.hide_manager.Hidden) {
        switch (Position) {
        default:
        case Gtk.PositionType.BOTTOM:
          dock_region.y -= DockHeight - 1;
          break;
        case Gtk.PositionType.TOP:
          dock_region.y += DockHeight - 1;
          break;
        case Gtk.PositionType.LEFT:
          dock_region.x += DockWidth - 1;
          break;
        case Gtk.PositionType.RIGHT:
          dock_region.x -= DockWidth - 1;
          break;
        }
      }

      return dock_region;
    }

    /**
     * Call when any cached region needs updating.
     */
    public void update_regions () {
      Logger.verbose ("PositionManager.update_regions ()");

      var old_region = static_dock_region;

      // width of the items-area of the dock
      items_width = get_items_width (controller.VisibleItems);

      static_dock_region.width = VisibleDockWidth;
      static_dock_region.height = VisibleDockHeight;

      var xoffset = (DockWidth - static_dock_region.width) / 2;
      var yoffset = (DockHeight - static_dock_region.height) / 2;

      if (screen_is_composited) {
        var offset = Offset;
        xoffset = xoffset + (offset * xoffset) / 100;
        yoffset = yoffset + (offset * yoffset) / 100;

        switch (Alignment) {
        default:
        case Gtk.Align.CENTER:
        case Gtk.Align.FILL:
          break;
        case Gtk.Align.START:
          if (is_horizontal_dock ()) {
            xoffset = 0;
            yoffset = (monitor_geo.height - static_dock_region.height);
          } else {
            xoffset = (monitor_geo.width - static_dock_region.width);
            yoffset = 0;
          }
          break;
        case Gtk.Align.END:
          if (is_horizontal_dock ()) {
            xoffset = (monitor_geo.width - static_dock_region.width);
            yoffset = 0;
          } else {
            xoffset = 0;
            yoffset = (monitor_geo.height - static_dock_region.height);
          }
          break;
        }
      }

      switch (Position) {
      default:
      case Gtk.PositionType.BOTTOM:
        static_dock_region.x = xoffset;
        static_dock_region.y = DockHeight - static_dock_region.height;
        break;
      case Gtk.PositionType.TOP:
        static_dock_region.x = xoffset;
        static_dock_region.y = 0;
        break;
      case Gtk.PositionType.LEFT:
        static_dock_region.y = yoffset;
        static_dock_region.x = 0;
        break;
      case Gtk.PositionType.RIGHT:
        static_dock_region.y = yoffset;
        static_dock_region.x = DockWidth - static_dock_region.width;
        break;
      }

      update_dock_position ();

      if (!screen_is_composited
          || old_region.x != static_dock_region.x
          || old_region.y != static_dock_region.y
          || old_region.width != static_dock_region.width
          || old_region.height != static_dock_region.height
          || last_update_monitor_num != monitor_num) {
        last_update_monitor_num = monitor_num;
        controller.window.update_size_and_position ();

#if HAVE_BARRIERS
        controller.hide_manager.update_barrier ();
#endif

        // With active compositing support update_size_and_position () won't trigger a redraw
        // (a changed static_dock_region doesn't implicate the window-size changed)
        if (screen_is_composited)
          controller.renderer.animated_draw ();
      } else {
        controller.renderer.animated_draw ();
      }
    }

    /**
     * The draw-value for a dock item.
     *
     * @param item the dock item to find the drawvalue for
     * @return the region for the dock item
     */
    public unowned DockItemDrawValue get_draw_value_for_item (DockItem item) {
      return item.draw_value;
    }

    /**
     * Update and recalculated all internal draw-values using the given methodes for custom manipulations.
     *
     * @param items the ordered list of all current item which are suppose to be shown on the dock
     * @param func a function which adjusts the draw-value per item
     * @param post_func a function which post-processes all draw-values
     */
    public void update_draw_values (Gee.ArrayList<unowned DockItem> items, DrawValueFunc? func = null,
                                    DrawValuesFunc? post_func = null) {
      unowned DockPreferences prefs = controller.prefs;
      unowned DockRenderer renderer = controller.renderer;

      // first we do the math as if this is a top dock, to do this we need to set
      // up some "pretend" variables. we pretend we are a top dock because 0,0 is
      // at the top.
      int width = DockWidth;
      int height = DockHeight;
      int icon_size = IconSize;

      Gdk.Point cursor = renderer.local_cursor;

      // "relocate" our cursor to be on the top
      switch (Position) {
      case Gtk.PositionType.RIGHT :
        cursor.x = width - cursor.x;
        break;
      case Gtk.PositionType.BOTTOM :
        cursor.y = height - cursor.y;
        break;
      default:
        break;
      }

      // our width and height switch around if we have a vertical dock
      if (!is_horizontal_dock ()) {
        int tmp = cursor.y;
        cursor.y = cursor.x;
        cursor.x = tmp;

        tmp = width;
        width = height;
        height = tmp;
      }

      // the line along the dock width about which the center of unzoomed icons sit
      double center_y = (is_horizontal_dock () ? static_dock_region.height / 2.0 : static_dock_region.width / 2.0);
      double center_x = (icon_size) / 2.0 + items_offset;

      if (Alignment == Gtk.Align.FILL) {
        switch (ItemsAlignment) {
        default:
        case Gtk.Align.FILL:
        case Gtk.Align.CENTER:
          if (is_horizontal_dock ())
            center_x += static_dock_region.x + (static_dock_region.width - 2 * items_offset - items_width) / 2;
          else
            center_x += static_dock_region.y + (static_dock_region.height - 2 * items_offset - items_width) / 2;
          break;
        case Gtk.Align.START:
          break;
        case Gtk.Align.END:
          if (is_horizontal_dock ())
            center_x += static_dock_region.x + (static_dock_region.width - 2 * items_offset - items_width);
          else
            center_x += static_dock_region.y + (static_dock_region.height - 2 * items_offset - items_width);
          break;
        }
      } else {
        if (is_horizontal_dock ())
          center_x += static_dock_region.x;
        else
          center_x += static_dock_region.y;
      }

      PointD center = { Math.floor (center_x), Math.floor (center_y) };

      // ZoomPercent is a number greater than 1.  It should never be less than one.

      // zoom_in_percent is a range of 1 to ZoomPercent.
      // We need a number that is 1 when ZoomIn is 0, and ZoomPercent when ZoomIn is 1.
      // Then we treat this as if it were the ZoomPercent for the rest of the calculation.
      bool expand_for_drop = (controller.drag_manager.ExternalDragActive && !prefs.LockItems);
      bool zoom_enabled = prefs.ZoomEnabled;

      double zoom_in_progress = (zoom_enabled || expand_for_drop ? renderer.zoom_in_progress : 0.0);
      double zoom_in_percent = (zoom_enabled ? 1.0 + (ZoomPercent - 1.0) * zoom_in_progress : 1.0);
      double zoom_icon_size = ZoomIconSize;

      // With FILL alignment the dock spans the whole screen edge, so the
      // cursor can hover empty space far away from the items. Fade the zoom
      // out with the distance to the items area and anchor it to the nearest
      // end of the items area, so approaching icons magnify progressively
      // instead of being pushed away by a bump over empty space.
      if (Alignment == Gtk.Align.FILL && zoom_in_percent > 1.0 && !expand_for_drop) {
        double items_begin = center.x - icon_size / 2.0;
        double items_end = items_begin + items_width;
        double outside = double.max (items_begin - cursor.x, cursor.x - items_end);
        if (outside > 0.0) {
          zoom_in_percent = 1.0 + (zoom_in_percent - 1.0) * double.max (0.0, 1.0 - outside / zoom_icon_size);
          cursor.x = (int) (cursor.x < items_begin ? items_begin : items_end);
        }
      }

      // Fast path: when no zoom is active (idle state), skip expensive zoom calculations
      bool no_zoom_active = (zoom_in_percent == 1.0 && !expand_for_drop);
      double static_center_height = icon_size / 2.0;
      bool is_horizontal = is_horizontal_dock ();

      for (int idx = 0; idx < items.size; idx++) {
        unowned DockItem item = items[idx];
        unowned DockItemDrawValue val = item.draw_value;
        // Reset values for this frame (reusing existing object)
        val.opacity = 1.0;
        val.darken = 0.0;
        val.lighten = 0.0;
        val.show_indicator = true;
        val.zoom = 1.0;

        val.static_center = center;

        double center_position;
        double zoomed_center_height;

        if (no_zoom_active) {
          // Fast path: no zoom calculations needed
          center_position = Math.round (center.x);
          zoomed_center_height = static_center_height;
          val.icon_size = icon_size;
        } else {
          // Full zoom calculation path
          // get us some handy doubles with fancy names
          double cursor_position = cursor.x;
          center_position = center.x;

          // offset from the center of the true position, ranged between 0 and the zoom size
          double offset = double.min (Math.fabs (cursor_position - center_position), zoom_icon_size);

          double offset_percent;
          if (expand_for_drop) {
            double orig_offset = offset;
            offset += offset * zoom_icon_size / icon_size;
            offset_percent = double.min (orig_offset / zoom_icon_size, offset / (2.0 * zoom_icon_size));
          } else {
            offset_percent = offset / zoom_icon_size;
          }

          if (offset_percent > 0.99)
            offset_percent = 1.0;

          // pull in our offset to make things less spaced out
          // explaination since this is a bit tricky...
          // we have three terms, basically offset = f(x) * h(x) * g(x)
          // f(x) == offset identity
          // h(x) == a number from 0 to DockPreference.ZoomPercent - 1.  This is used to get the smooth "zoom in" effect.
          // additionally serves to "curve" the offset based on the max zoom
          // g(x) == a term used to move the ends of the zoom inward.  Precalculated that the edges should be 66% of the current
          // value. The center is 100%. (1 - offset_percent) == 0,1 distance from center
          // The .66 value comes from the area under the curve.  Dont ask me to explain it too much because it's too clever for me.

          if (expand_for_drop) {
            double zoom_adjust = 1.0;
            if (zoom_enabled) {
              zoom_adjust = 1 + (icon_size / zoom_icon_size);
            }
            offset *= zoom_in_progress / zoom_adjust;
          } else {
            offset *= zoom_in_percent - 1.0;
          }
          offset *= 1.0 - offset_percent / 3.0;

          if (cursor_position > center_position)
            center_position -= offset;
          else
            center_position += offset;

          // zoom is calculated as 1 through target_zoom (default 2).
          // The larger your offset, the smaller your zoom

          // First we get the point on our curve that defines our current zoom
          // offset is always going to fall on a point on the curve >= 0
          var zoom = 1.0 - Math.pow (offset_percent, 2);

          // scale this to match our zoom_in_percent
          if (item.AllowZoom) {
            zoom = 1.0 + zoom * (zoom_in_percent - 1.0);
          } else {
            zoom = 1.0;
          }
          zoomed_center_height = (icon_size * zoom / 2.0);

          if (zoom == 1.0)
            center_position = Math.round (center_position);

          val.zoom = zoom;
          val.icon_size = Math.round (zoom * icon_size);
        }

        val.center = { center_position, zoomed_center_height };

        // now we undo our transforms to the point
        if (!is_horizontal) {
          double tmp = val.center.y;
          val.center.y = val.center.x;
          val.center.x = tmp;

          tmp = val.static_center.y;
          val.static_center.y = val.static_center.x;
          val.static_center.x = tmp;
        }

        switch (Position) {
        case Gtk.PositionType.RIGHT:
          val.center.x = height - val.center.x;
          val.static_center.x = height - val.static_center.x;
          break;
        case Gtk.PositionType.BOTTOM:
          val.center.y = height - val.center.y;
          val.static_center.y = height - val.static_center.y;
          break;
        default:
          break;
        }

        val.move_in (Position, bottom_offset);

        // let the draw-value be modified by the given function
        if (func != null)
          func (item, val);

        if (item.RemoveTime == 0 && idx < (items.size - 1)) {
          double padding = ItemPadding;
          if (item.is_separator ()) {
            padding = SeparatorPadding;
          } else if (items[idx + 1].is_separator ()) {
            padding = SeparatorPadding;
          }
          center.x += icon_size + padding;
        }
      }

      if (post_func != null)
        post_func (items);

      update_background_region (items.first ().draw_value, items.last ().draw_value);

      int max_hover_height = 0;
      int max_hover_width = 0;

      foreach (unowned DockItem item in items) {
        unowned DockItemDrawValue val = item.draw_value;
        val.draw_region = get_item_draw_region (val);
        val.hover_region = get_item_hover_region (val);
        val.background_region = get_item_background_region (val);

        max_hover_height = int.max (max_hover_height, val.hover_region.height);
        max_hover_width = int.max (max_hover_width, val.hover_region.width);
      }

      max_hover_height_cache = max_hover_height;
      max_hover_width_cache = max_hover_width;

      controller.window.update_icon_regions ();
    }

    /**
     * The region for drawing a dock item.
     *
     * @param val the item's DockItemDrawValue
     * @return the region for the dock item
     */
    Gdk.Rectangle get_item_draw_region (DockItemDrawValue val) {
      var width = val.icon_size, height = val.icon_size;

      return { (int) Math.round (val.center.x - width / 2.0),
               (int) Math.round (val.center.y - height / 2.0),
               (int) width,
               (int) height };
    }

    /**
     * The intersecting region of a dock item's hover region and the background.
     *
     * @param val the item's DockItemDrawValue
     * @return the region for the dock item
     */
    Gdk.Rectangle get_item_background_region (DockItemDrawValue val) {
      Gdk.Rectangle rect;
      var hover_region = val.hover_region;

      switch (Position) {
      default:
      case Gtk.PositionType.BOTTOM:
        hover_region.height = (background_rect.y + background_rect.height - hover_region.y).abs ();
        break;
      case Gtk.PositionType.TOP:
        hover_region.y = background_rect.y;
        hover_region.height = (hover_region.y - background_rect.y + background_rect.height).abs ();
        break;
      case Gtk.PositionType.LEFT:
        hover_region.x = background_rect.x;
        hover_region.width = (hover_region.x - background_rect.x + background_rect.width).abs ();
        break;
      case Gtk.PositionType.RIGHT:
        hover_region.width = (background_rect.x + background_rect.width - hover_region.x).abs ();
        break;
      }

      if (!hover_region.intersect (background_rect, out rect))
        return {};

      return rect;
    }

    /**
     * The cursor region for interacting with a dock element.
     *
     * @param val the item's DockItemDrawValue
     * @return the region for the dock item
     */
    Gdk.Rectangle get_item_hover_region (DockItemDrawValue val) {
      Gdk.Rectangle rect;

      var item_padding = ItemPadding;
      var top_padding = (top_offset < 0 ? 0 : top_offset);
      var bottom_padding = bottom_offset;
      var width = val.icon_size, height = val.icon_size;

      // Apply scalable padding
      switch (Position) {
      default:
      case Gtk.PositionType.BOTTOM:
        width += item_padding;
        break;
      case Gtk.PositionType.TOP:
        width += item_padding;
        break;
      case Gtk.PositionType.LEFT:
        height += item_padding;
        break;
      case Gtk.PositionType.RIGHT:
        height += item_padding;
        break;
      }

      rect = { (int) Math.round (val.center.x - width / 2.0),
               (int) Math.round (val.center.y - height / 2.0),
               (int) width,
               (int) height };

      // Apply static padding
      switch (Position) {
      default:
      case Gtk.PositionType.BOTTOM:
        rect.y -= top_padding;
        rect.height += bottom_padding + top_padding;
        break;
      case Gtk.PositionType.TOP:
        rect.y -= bottom_padding;
        rect.height += bottom_padding + top_padding;
        break;
      case Gtk.PositionType.LEFT:
        rect.x -= bottom_padding;
        rect.width += bottom_padding + top_padding;
        break;
      case Gtk.PositionType.RIGHT:
        rect.x -= top_padding;
        rect.width += bottom_padding + top_padding;
        break;
      }

      Gdk.Rectangle background_region;

      if (rect.intersect (get_background_region (), out background_region))
        background_region.union (get_item_draw_region (val), out rect);

      return rect;
    }

    /**
     * The cursor region for interacting with a dock element.
     *
     * @param element the dock element to find a region for
     * @return the region for the dock item
     */
    public Gdk.Rectangle get_hover_region_for_element (DockElement element) {
      unowned DockItem? item = (element as DockItem);
      if (item != null)
        return get_draw_value_for_item (item).hover_region;

      unowned DockContainer? container = (element as DockContainer);
      if (container == null)
        return {};

      unowned Gee.ArrayList<DockElement> items = container.VisibleElements;

      if (items.size == 0)
        return {};

      var first_rect = get_hover_region_for_element (items.first ());
      if (items.size == 1)
        return first_rect;

      var last_rect = get_hover_region_for_element (items.last ());

      Gdk.Rectangle result;
      first_rect.union (last_rect, out result);

      switch (Position) {
      case Gtk.PositionType.BOTTOM :
        result.y = int.min (result.y, static_dock_region.y - (max_hover_height_cache - static_dock_region.height));
        result.height = int.max (result.height, max_hover_height_cache);
        break;
      case Gtk.PositionType.TOP :
        result.height = int.max (result.height, max_hover_height_cache);
        break;
      case Gtk.PositionType.LEFT:
        result.width = int.max (result.width, max_hover_width_cache);
        break;
      case Gtk.PositionType.RIGHT:
        result.x = int.min (result.x, static_dock_region.x - (max_hover_width_cache - static_dock_region.width));
        result.width = int.max (result.width, max_hover_width_cache);
        break;
      }

      return result;
    }

    /**
     * Get the item which is the nearest at the given coordinates. If a container is given
     * the result will be restricted to its children.
     *
     * @param x the x position
     * @param y the y position
     * @param container a container or NULL
     */
    public unowned DockItem ? get_nearest_item_at (int x, int y, DockContainer? container = null) {
      unowned DockItem? result = null;
      double min_squared_distance = double.MAX;

      foreach (unowned DockItem item in controller.VisibleItems) {
        if (container != null && item.Container != container) {
          continue;
        }

        var center = item.draw_value.static_center;
        double squared_distance = (x - center.x) * (x - center.x) + (y - center.y) * (y - center.y);

        if (squared_distance < min_squared_distance) {
          min_squared_distance = squared_distance;
          result = item;
        }
      }

      return result;
    }

    /**
     * Get the item which is the appropriate target for a drag'n'drop action.
     * The returned item may not hovered and is meant to be used as target
     * for e.g. DockContainer.add/move_to functions.
     * If a container is given the result will be restricted to its children.
     *
     * @param container a container or NULL
     */
    public unowned DockItem ? get_current_target_item (DockContainer? container = null) {
      unowned DockRenderer renderer = controller.renderer;
      var cursor = renderer.local_cursor;

      unowned var nearest = get_nearest_item_at (cursor.x, cursor.y, container);

      if (nearest == null) {
        return null;
      }

      var val = get_draw_value_for_item (nearest);
      var center = val.static_center;

      bool on_second_half;
      if (is_horizontal_dock ()) {
        on_second_half = cursor.x > center.x;
      } else {
        on_second_half = cursor.y > center.y;
      }

      if (!on_second_half) {
        return nearest;
      }

      Gee.ArrayList<DockElement> items;
      if (container != null) {
        items = container.VisibleElements;
      } else {
        return null;
      }

      int item_index = -1;
      for (int i = 0; i < items.size; i++) {
        if (items[i] == nearest) {
          item_index = i;
          break;
        }
      }

      if (item_index == -1 || item_index >= items.size - 1)
        return null;

      DockElement next_element = items[item_index + 1];
      return next_element as DockItem;
    }

    /**
     * Get's the x and y position to display a menu for a dock item.
     *
     * @param hovered the item that is hovered
     * @param requisition the menu's requisition
     * @param x the resulting x position
     * @param y the resulting y position
     */
    public void get_menu_position (DockItem hovered, Gtk.Requisition requisition, out int x, out int y) {
      var rect = get_hover_region_for_element (hovered);

      var offset = 10;
      switch (Position) {
      default :
      case Gtk.PositionType.BOTTOM :
        x = win_x + rect.x + (rect.width - requisition.width) / 2;
        y = win_y + rect.y - requisition.height - offset;
        break;
      case Gtk.PositionType.TOP :
        x = win_x + rect.x + (rect.width - requisition.width) / 2;
        y = win_y + rect.height + offset;
        break;
      case Gtk.PositionType.LEFT :
        y = win_y + rect.y + (rect.height - requisition.height) / 2;
        x = win_x + rect.x + rect.width + offset;
        break;
      case Gtk.PositionType.RIGHT :
        y = win_y + rect.y + (rect.height - requisition.height) / 2;
        x = win_x + rect.x - requisition.width - offset;
        break;
      }
    }

    /**
     * Get's the x and y position to display a hover window for a dock item.
     *
     * @param hovered the item that is hovered
     * @param x the resulting x position
     * @param y the resulting y position
     */
    public void get_hover_position (DockItem hovered, out int x, out int y) {
      var center = get_draw_value_for_item (hovered).static_center;
      var offset = (ZoomIconSize - IconSize / 2.0);

      switch (Position) {
      default :
      case Gtk.PositionType.BOTTOM :
        x = (int) Math.round (center.x + win_x);
        y = (int) Math.round (center.y + win_y - offset);
        break;
      case Gtk.PositionType.TOP:
        x = (int) Math.round (center.x + win_x);
        y = (int) Math.round (center.y + win_y + offset);
        break;
      case Gtk.PositionType.LEFT:
        x = (int) Math.round (center.x + win_x + offset);
        y = (int) Math.round (center.y + win_y);
        break;
      case Gtk.PositionType.RIGHT:
        x = (int) Math.round (center.x + win_x - offset);
        y = (int) Math.round (center.y + win_y);
        break;
      }
    }

    /**
     * Get's the x and y position to display a hover window for the given coordinates.
     *
     * @param x the resulting x position
     * @param y the resulting y position
     */
    public void get_hover_position_at (ref int x, ref int y) {
      // Any element will suffice since only the constant coordinate of center is used
      var center = get_draw_value_for_item (controller.VisibleItems.first ()).static_center;
      var offset = (ZoomIconSize - IconSize / 2.0);

      switch (Position) {
      default:
      case Gtk.PositionType.BOTTOM:
        y = (int) Math.round (center.y + win_y - offset);
        break;
      case Gtk.PositionType.TOP:
        y = (int) Math.round (center.y + win_y + offset);
        break;
      case Gtk.PositionType.LEFT:
        x = (int) Math.round (center.x + win_x + offset);
        break;
      case Gtk.PositionType.RIGHT:
        x = (int) Math.round (center.x + win_x - offset);
        break;
      }
    }

    /**
     * Get's the x and y position to display the urgent-glow for a dock item.
     *
     * @param item the item to show urgent-glow for
     * @param x the resulting x position
     * @param y the resulting y position
     */
    public void get_urgent_glow_position (DockItem item, out int x, out int y) {
      var rect = get_hover_region_for_element (item);
      var glow_size = GlowSize;

      switch (Position) {
      default:
      case Gtk.PositionType.BOTTOM:
        x = rect.x + (rect.width - glow_size) / 2;
        y = DockHeight + GapSize - glow_size / 2;
        break;
      case Gtk.PositionType.TOP:
        x = rect.x + (rect.width - glow_size) / 2;
        y = -GapSize - glow_size / 2;
        break;
      case Gtk.PositionType.LEFT:
        y = rect.y + (rect.height - glow_size) / 2;
        x = -GapSize - glow_size / 2;
        break;
      case Gtk.PositionType.RIGHT:
        y = rect.y + (rect.height - glow_size) / 2;
        x = DockWidth + GapSize - glow_size / 2;
        break;
      }
    }

    /**
     * Caches the x and y position of the dock window.
     */
    public void update_dock_position () {
      bool hidden = !screen_is_composited && controller.hide_manager.Hidden;

      compute_dock_window_position (out win_x, out win_y, Position, Alignment,
                                    monitor_geo, DockWidth, DockHeight, GapSize, Offset,
                                    screen_is_composited, is_horizontal_dock (),
                                    static_dock_region.width, static_dock_region.height,
                                    hidden);
    }

    /**
     * Pure math for dock window position — no X11 dependencies, testable in isolation.
     *
     * @param x the resulting x position
     * @param y the resulting y position
     * @param position the dock position (top/bottom/left/right)
     * @param alignment the dock alignment
     * @param monitor the monitor geometry
     * @param dock_width the dock window width
     * @param dock_height the dock window height
     * @param gap_size gap between dock and screen edge
     * @param offset position offset from center (percent)
     * @param composited whether compositing is active
     * @param horizontal whether the dock is horizontal
     * @param static_width the static dock region width
     * @param static_height the static dock region height
     * @param hidden whether the dock is hidden (non-composited mode)
     */
    public static void compute_dock_window_position (out int x, out int y,
                                                      Gtk.PositionType position, Gtk.Align alignment,
                                                      Gdk.Rectangle monitor,
                                                      int dock_width, int dock_height,
                                                      int gap_size, int offset,
                                                      bool composited, bool horizontal,
                                                      int static_width, int static_height,
                                                      bool hidden) {
      var xoffset = 0;
      var yoffset = 0;

      if (!composited) {
        xoffset = (monitor.width - dock_width) / 2 + (offset * (monitor.width - dock_width)) / 200;
        yoffset = (monitor.height - dock_height) / 2 + (offset * (monitor.height - dock_height)) / 200;

        switch (alignment) {
        default:
        case Gtk.Align.CENTER:
        case Gtk.Align.FILL:
          break;
        case Gtk.Align.START:
          if (horizontal) {
            xoffset = 0;
            yoffset = (monitor.height - static_height);
          } else {
            xoffset = (monitor.width - static_width);
            yoffset = 0;
          }
          break;
        case Gtk.Align.END:
          if (horizontal) {
            xoffset = (monitor.width - static_width);
            yoffset = 0;
          } else {
            xoffset = 0;
            yoffset = (monitor.height - static_height);
          }
          break;
        }
      }

      switch (position) {
      default:
      case Gtk.PositionType.BOTTOM:
        x = monitor.x + xoffset;
        y = monitor.y + monitor.height - dock_height - gap_size;
        break;
      case Gtk.PositionType.TOP:
        x = monitor.x + xoffset;
        y = monitor.y + gap_size;
        break;
      case Gtk.PositionType.LEFT:
        y = monitor.y + yoffset;
        x = monitor.x + gap_size;
        break;
      case Gtk.PositionType.RIGHT:
        y = monitor.y + yoffset;
        x = monitor.x + monitor.width - dock_width - gap_size;
        break;
      }

      // Actually change the window position while hidden for non-compositing mode
      if (hidden) {
        switch (position) {
        default:
        case Gtk.PositionType.BOTTOM:
          y += dock_height - 1;
          break;
        case Gtk.PositionType.TOP:
          y -= dock_height - 1;
          break;
        case Gtk.PositionType.LEFT:
          x -= dock_width - 1;
          break;
        case Gtk.PositionType.RIGHT:
          x += dock_width - 1;
          break;
        }
      }
    }

    /**
     * Get's the x and y position to display the main dock buffer.
     *
     * @param x the resulting x position
     * @param y the resulting y position
     */
    public void get_dock_draw_position (out int x, out int y) {
      if (!screen_is_composited) {
        x = 0;
        y = 0;
        return;
      }

      var progress = controller.renderer.hide_progress;

      compute_dock_draw_position (out x, out y, Position, progress,
                                  VisibleDockWidth, VisibleDockHeight, extra_hide_offset);
    }

    /**
     * Pure math for dock draw position — no X11 dependencies, testable in isolation.
     *
     * @param x the resulting x offset
     * @param y the resulting y offset
     * @param position the dock position (top/bottom/left/right)
     * @param progress hide progress (0.0 = visible, 1.0 = hidden)
     * @param dock_width visible dock width
     * @param dock_height visible dock height
     * @param hide_offset extra offset for hiding
     */
    public static void compute_dock_draw_position (out int x, out int y,
                                                    Gtk.PositionType position, double progress,
                                                    int dock_width, int dock_height, int hide_offset) {
      switch (position) {
      default:
      case Gtk.PositionType.BOTTOM:
        x = 0;
        y = (int) ((dock_height + hide_offset) * progress);
        break;
      case Gtk.PositionType.TOP:
        x = 0;
        y = (int) (-(dock_height + hide_offset) * progress);
        break;
      case Gtk.PositionType.LEFT:
        x = (int) (-(dock_width + hide_offset) * progress);
        y = 0;
        break;
      case Gtk.PositionType.RIGHT:
        x = (int) ((dock_width + hide_offset) * progress);
        y = 0;
        break;
      }
    }

    /**
     * Get's the region to display the dock window at.
     *
     * @return the region for the dock window
     */
    public Gdk.Rectangle get_dock_window_region () {
      return { win_x, win_y, DockWidth, DockHeight };
    }

    public Gdk.Rectangle get_monitor_geometry () {
      return monitor_geo;
    }

    /**
     * Get's the padding between background and icons of the dock.
     *
     * @param x the horizontal padding
     * @param y the vertical padding
     */
    public void get_background_padding (out int x, out int y) {
      compute_background_padding (out x, out y, Position,
                                  VisibleDockWidth, VisibleDockHeight,
                                  DockBackgroundWidth, DockBackgroundHeight,
                                  extra_hide_offset);
    }

    /**
     * Pure math for background padding — no X11 dependencies, testable in isolation.
     *
     * @param x the resulting x padding
     * @param y the resulting y padding
     * @param position the dock position
     * @param dock_width visible dock width
     * @param dock_height visible dock height
     * @param bg_width dock background width
     * @param bg_height dock background height
     * @param hide_offset extra offset for hiding
     */
    public static void compute_background_padding (out int x, out int y,
                                                    Gtk.PositionType position,
                                                    int dock_width, int dock_height,
                                                    int bg_width, int bg_height,
                                                    int hide_offset) {
      switch (position) {
      default:
      case Gtk.PositionType.BOTTOM:
        x = 0;
        y = dock_height - bg_height + hide_offset;
        break;
      case Gtk.PositionType.TOP:
        x = 0;
        y = -(dock_height - bg_height + hide_offset);
        break;
      case Gtk.PositionType.LEFT:
        x = -(dock_width - bg_width + hide_offset);
        y = 0;
        break;
      case Gtk.PositionType.RIGHT:
        x = dock_width - bg_width + hide_offset;
        y = 0;
        break;
      }
    }

    /**
     * Get's the region for background of the dock.
     *
     * @return the region for the dock background
     */
    public Gdk.Rectangle get_background_region () {
      return background_rect;
    }

    void update_background_region (DockItemDrawValue val_first, DockItemDrawValue val_last) {
      var x = 0, y = 0, width = 0, height = 0;

      if (screen_is_composited) {
        x = static_dock_region.x;
        y = static_dock_region.y;
        width = VisibleDockWidth;
        height = VisibleDockHeight;
      } else {
        width = DockWidth;
        height = DockHeight;
      }

      if (Alignment == Gtk.Align.FILL) {
        switch (Position) {
        default:
        case Gtk.PositionType.BOTTOM:
          x += (width - DockBackgroundWidth) / 2;
          y += height - DockBackgroundHeight;
          break;
        case Gtk.PositionType.TOP:
          x += (width - DockBackgroundWidth) / 2;
          y = 0;
          break;
        case Gtk.PositionType.LEFT:
          x = 0;
          y += (height - DockBackgroundHeight) / 2;
          break;
        case Gtk.PositionType.RIGHT:
          x += width - DockBackgroundWidth;
          y += (height - DockBackgroundHeight) / 2;
          break;
        }

        background_rect = { x, y, DockBackgroundWidth, DockBackgroundHeight };
        return;
      }

      var center_first = val_first.center;
      var center_last = val_last.center;
      var padding = ItemPadding + 2 * HorizPadding + 4 * LineWidth;
      var padding_first = (val_first.icon_size + padding) / 2.0;
      var padding_last = (val_last.icon_size + padding) / 2.0;

      switch (Position) {
      default:
      case Gtk.PositionType.BOTTOM:
        x = (int) Math.round (center_first.x - padding_first);
        y += height - DockBackgroundHeight;
        width = (int) Math.round (center_last.x - center_first.x + padding_first + padding_last);
        height = DockBackgroundHeight;
        break;
      case Gtk.PositionType.TOP:
        x = (int) Math.round (center_first.x - padding_first);
        y = 0;
        width = (int) Math.round (center_last.x - center_first.x + padding_first + padding_last);
        height = DockBackgroundHeight;
        break;
      case Gtk.PositionType.LEFT:
        x = 0;
        y = (int) Math.round (center_first.y - padding_first);
        width = DockBackgroundWidth;
        height = (int) Math.round (center_last.y - center_first.y + padding_first + padding_last);
        break;
      case Gtk.PositionType.RIGHT:
        x += width - DockBackgroundWidth;
        y = (int) Math.round (center_first.y - padding_first);
        width = DockBackgroundWidth;
        height = (int) Math.round (center_last.y - center_first.y + padding_first + padding_last);
        break;
      }

      background_rect = { x, y, width, height };
    }

    /**
     * Returns the icon geometry for the given application-dockitem
     *
     * @param item an application-dockitem of the dock
     * @param for_hidden whether the geometry should apply for a hidden dock
     * @return icon geometry for the given application-dockitem
     */
    public Gdk.Rectangle get_icon_geometry (ApplicationDockItem item, bool for_hidden) {
      var draw_value = get_draw_value_for_item (item);

      window_scale_factor = controller.window.get_window ().get_scale_factor ();

      if (!for_hidden) {
        var region = Gdk.Rectangle ();
        int hit_box_size = (int) Math.round (draw_value.icon_size / 4.0);

        region.width = hit_box_size * 2;
        region.height = hit_box_size * 2;

        switch (Position) {
        default:
        case Gtk.PositionType.BOTTOM:
          region.x = (int) Math.round (draw_value.static_center.x - hit_box_size) + win_x;
          region.y = win_y + DockHeight + GapSize - hit_box_size;
          break;
        case Gtk.PositionType.TOP:
          region.x = (int) Math.round (draw_value.static_center.x - hit_box_size) + win_x;
          region.y = win_y - GapSize;
          break;
        case Gtk.PositionType.LEFT:
          region.y = (int) Math.round (draw_value.static_center.y - hit_box_size) + win_y;
          region.x = win_x - GapSize;
          break;
        case Gtk.PositionType.RIGHT:
          region.y = (int) Math.round (draw_value.static_center.y - hit_box_size) + win_y;
          region.x = win_x + DockWidth + GapSize - hit_box_size;
          break;
        }

        region.x *= window_scale_factor;
        region.y *= window_scale_factor;
        region.width *= window_scale_factor;
        region.height *= window_scale_factor;

        return region;
      }

      // For hidden dock, return point geometry at screen edge
      var x = win_x, y = win_y;

      switch (Position) {
      default:
      case Gtk.PositionType.BOTTOM:
        x += (int) Math.round (draw_value.static_center.x);
        y += DockHeight + GapSize;
        break;
      case Gtk.PositionType.TOP:
        x += (int) Math.round (draw_value.static_center.x);
        y -= GapSize;
        break;
      case Gtk.PositionType.LEFT:
        x -= GapSize;
        y += (int) Math.round (draw_value.static_center.y);
        break;
      case Gtk.PositionType.RIGHT:
        x += DockWidth + GapSize;
        y += (int) Math.round (draw_value.static_center.y);
        break;
      }

      return { x, y, 0, 0 };
    }

    /**
     * Computes the struts for the dock.
     *
     * @param struts the array to contain the struts
     */
    public void get_struts (ref ulong[] struts) {
      // Reservations must describe current reality: re-resolve the
      // selected monitor and require its raw geometry to match the last
      // valid measurement, so hotplug windows and mid-transition mode
      // flips can never reassert retained geometry (a removed monitor's
      // rectangle could even wrap the depth arithmetic once the root
      // shrinks)
      unowned Gdk.Screen screen = controller.window.get_screen ();
      if (find_monitor_number (screen, controller.prefs.Monitor) != monitor_num)
        return;

      var raw_geo = screen.get_display ().get_monitor (monitor_num).get_geometry ();

      // A positive live reading is required first: without it, a transient
      // zero geometry at startup would compare equal to the zero-seeded
      // reference despite no valid measurement ever having occurred
      if (raw_geo.width <= 0 || raw_geo.height <= 0)
        return;

      if (raw_geo.x != last_raw_geo.x || raw_geo.y != last_raw_geo.y
          || raw_geo.width != last_raw_geo.width || raw_geo.height != last_raw_geo.height)
        return;

      // In monitor mode the applied rectangle must be the raw geometry
      // itself; right after a flip away from the work area it can still
      // be margin-shrunk until the scheduled episode measures
      if (use_monitor_geometry ()
          && (monitor_geo.x != raw_geo.x || monitor_geo.y != raw_geo.y
              || monitor_geo.width != raw_geo.width || monitor_geo.height != raw_geo.height))
        return;

      // Before the window is realized there is no Gdk.Window to read the
      // scale factor from; keep the last-known value
      unowned Gdk.Window? window = controller.window.get_window ();
      if (window != null)
        window_scale_factor = window.get_scale_factor ();

      // Per the _NET_WM_STRUT_PARTIAL spec, all coordinates are root window
      // coordinates and struts are relative to the screen edge, not the
      // monitor edge. Compute screen bounds from monitor geometries so
      // everything is in GDK logical pixels — screen.get_width/get_height()
      // behavior varies across GTK3 versions and distro patches.
      var display = controller.window.get_display ();
      int screen_width = 0;
      int screen_height = 0;
      for (var i = 0; i < display.get_n_monitors (); i++) {
        var geo = display.get_monitor (i).get_geometry ();
        screen_width = int.max (screen_width, geo.x + geo.width);
        screen_height = int.max (screen_height, geo.y + geo.height);
      }

      compute_struts (ref struts, Position, monitor_geo,
                      screen_width, screen_height,
                      VisibleDockWidth, VisibleDockHeight,
                      GapSize, window_scale_factor);
    }

    /**
     * Pure math for strut calculation — no X11 dependencies, testable in isolation.
     *
     * All spatial inputs (monitor, screen_width, screen_height, dock_width,
     * dock_height, gap_size) must be in GDK logical (application) pixels.
     * The scale factor converts the result to X11 device pixels for struts.
     *
     * @param struts the array to contain the struts
     * @param position the dock position (top/bottom/left/right)
     * @param monitor the monitor geometry (GDK logical pixels)
     * @param screen_width total screen width (GDK logical pixels)
     * @param screen_height total screen height (GDK logical pixels)
     * @param dock_width visible dock width (GDK logical pixels)
     * @param dock_height visible dock height (GDK logical pixels)
     * @param gap_size gap between dock and screen edge (GDK logical pixels)
     * @param scale window scale factor (logical to device pixel ratio)
     */
    public static void compute_struts (ref ulong[] struts, Gtk.PositionType position,
                                       Gdk.Rectangle monitor, int screen_width, int screen_height,
                                       int dock_width, int dock_height,
                                       int gap_size, int scale) {
      switch (position) {
      default:
      case Gtk.PositionType.BOTTOM:
        struts[Struts.BOTTOM] = (dock_height + gap_size + screen_height - monitor.y - monitor.height) * scale;
        struts[Struts.BOTTOM_START] = monitor.x * scale;
        struts[Struts.BOTTOM_END] = (monitor.x + monitor.width) * scale - 1;
        break;
      case Gtk.PositionType.TOP:
        struts[Struts.TOP] = (monitor.y + dock_height + gap_size) * scale;
        struts[Struts.TOP_START] = monitor.x * scale;
        struts[Struts.TOP_END] = (monitor.x + monitor.width) * scale - 1;
        break;
      case Gtk.PositionType.LEFT:
        struts[Struts.LEFT] = (monitor.x + dock_width + gap_size) * scale;
        struts[Struts.LEFT_START] = monitor.y * scale;
        struts[Struts.LEFT_END] = (monitor.y + monitor.height) * scale - 1;
        break;
      case Gtk.PositionType.RIGHT:
        struts[Struts.RIGHT] = (dock_width + gap_size + screen_width - monitor.x - monitor.width) * scale;
        struts[Struts.RIGHT_START] = monitor.y * scale;
        struts[Struts.RIGHT_END] = (monitor.y + monitor.height) * scale - 1;
        break;
      }
    }

#if HAVE_BARRIERS
    public Gdk.Rectangle get_barrier () {
      Gdk.Rectangle barrier = {};

      // Before the window is realized there is no Gdk.Window to read the
      // scale factor from; keep the last-known value
      unowned Gdk.Window? window = controller.window.get_window ();
      if (window != null)
        window_scale_factor = window.get_scale_factor ();

      switch (Position) {
      default:
      case Gtk.PositionType.BOTTOM:
        barrier.x = (monitor_geo.x + (monitor_geo.width - VisibleDockWidth) / 2) * window_scale_factor;
        barrier.y = (monitor_geo.y + monitor_geo.height) * window_scale_factor;
        barrier.width = VisibleDockWidth * window_scale_factor;
        barrier.height = 0;
        break;
      case Gtk.PositionType.TOP:
        barrier.x = (monitor_geo.x + (monitor_geo.width - VisibleDockWidth) / 2) * window_scale_factor;
        barrier.y = monitor_geo.y * window_scale_factor;
        barrier.width = VisibleDockWidth * window_scale_factor;
        barrier.height = 0;
        break;
      case Gtk.PositionType.LEFT:
        barrier.x = monitor_geo.x * window_scale_factor;
        barrier.y = (monitor_geo.y + (monitor_geo.height - VisibleDockHeight) / 2) * window_scale_factor;
        barrier.width = 0;
        barrier.height = VisibleDockHeight * window_scale_factor;
        break;
      case Gtk.PositionType.RIGHT:
        barrier.x = (monitor_geo.x + monitor_geo.width) * window_scale_factor;
        barrier.y = (monitor_geo.y + (monitor_geo.height - VisibleDockHeight) / 2) * window_scale_factor;
        barrier.width = 0;
        barrier.height = VisibleDockHeight * window_scale_factor;
        break;
      }

      warn_if_fail (barrier.width > 0 || barrier.height > 0);

      return barrier;
    }

#endif
  }
}
