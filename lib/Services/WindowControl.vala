//
// Copyright (C) 2011-2012 Robert Dyer, Rico Tzschichholz
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
  public enum Struts {
    LEFT,
    RIGHT,
    TOP,
    BOTTOM,
    LEFT_START,
    LEFT_END,
    RIGHT_START,
    RIGHT_END,
    TOP_START,
    TOP_END,
    BOTTOM_START,
    BOTTOM_END,
    N_VALUES
  }

  public class WindowControl : GLib.Object {
    // when working on a group of windows, wait this amount (in ms) between each action
    public const uint WINDOW_GROUP_DELAY = 10U;
    // when changing a viewport, wait this time (for viewport change animations) before continuing
    public const uint VIEWPORT_CHANGE_DELAY = 200U;

    static uint delayed_focus_timer_id = 0U;
    static ulong delayed_focus_xid = 0UL;

    // Action type for pending operations
    enum PendingActionType {
      MINIMIZE,
      UNMINIMIZE,
      CENTER_AND_FOCUS,
      SCHEDULE_DELAYED_FOCUS
    }

    // A single pending operation with its own XIDs and event time
    class PendingOperation {
      public PendingActionType action_type;
      public Gee.ArrayList<ulong> xids;
      public uint32 event_time;
      public int index;
      public uint window_count;  // Used by SCHEDULE_DELAYED_FOCUS

      public PendingOperation (PendingActionType action_type, Gee.ArrayList<ulong> xids, uint32 event_time, uint window_count = 0) {
        this.action_type = action_type;
        this.xids = xids;
        this.event_time = event_time;
        this.index = 0;
        this.window_count = window_count;
      }
    }

    // Queue of pending operations
    static Gee.ArrayQueue<PendingOperation>? pending_queue = null;
    static uint pending_timer_id = 0U;

    /**
     * Process a list of windows with a delayed action between each.
     * Operations are queued and processed in order with 10ms delays.
     * Uses XIDs to avoid use-after-free in timeouts.
     *
     * @param windows the list of windows to process
     * @param action_type the type of action to perform
     * @param event_time the event time for window operations
     */
    static void process_windows (Gee.ArrayList<unowned Wnck.Window> windows, PendingActionType action_type, uint32 event_time) {
      if (windows.size == 0)
        return;

      // Convert to XIDs
      var xids = new Gee.ArrayList<ulong> ();
      foreach (unowned Wnck.Window window in windows) {
        if (window != null)
          xids.add (window.get_xid ());
      }

      if (xids.size == 0)
        return;

      queue_operation (new PendingOperation (action_type, xids, event_time));
    }

    static void queue_operation (PendingOperation op) {
      // Initialize queue if needed
      if (pending_queue == null)
        pending_queue = new Gee.ArrayQueue<PendingOperation> ();

      // Add operation to queue
      pending_queue.offer (op);

      // Start processing if not already running
      if (pending_timer_id == 0U)
        process_pending_operations ();
    }

    static void process_pending_operations () {
      while (true) {
        // Get current operation from front of queue
        // When empty, set pending_queue to null to free memory - a new queue
        // will be allocated on demand when the next operation is queued
        if (pending_queue == null || pending_queue.is_empty) {
          pending_queue = null;
          pending_timer_id = 0U;
          return;
        }

        PendingOperation? op = pending_queue.peek ();
        if (op == null) {
          pending_queue = null;
          pending_timer_id = 0U;
          return;
        }

        // Check if current operation is complete
        if (op.index >= op.xids.size) {
          // Remove completed operation and move to next
          pending_queue.poll ();
          continue;
        }

        // Handle SCHEDULE_DELAYED_FOCUS specially - single XID, calls schedule_delayed_focus
        // No delay after this operation to match original timing
        if (op.action_type == PendingActionType.SCHEDULE_DELAYED_FOCUS) {
          if (op.xids.size > 0) {
            unowned Wnck.Window? window = Wnck.Window.@get (op.xids[0]);
            if (window != null) {
              schedule_delayed_focus (window, op.window_count, op.event_time);
            }
          }
          pending_queue.poll ();
          // Continue immediately without delay
          continue;
        }

        // Look up window by XID - returns null if window was closed
        unowned Wnck.Window? window = Wnck.Window.@get (op.xids[op.index]);
        if (window != null) {
          switch (op.action_type) {
          case PendingActionType.MINIMIZE:
            window.minimize ();
            break;
          case PendingActionType.UNMINIMIZE:
            window.unminimize (op.event_time);
            break;
          case PendingActionType.CENTER_AND_FOCUS:
            center_and_focus_window (window, op.event_time);
            break;
          default:
            // SCHEDULE_DELAYED_FOCUS handled above
            break;
          }
        }

        op.index++;

        // Schedule next window with delay
        pending_timer_id = Gdk.threads_add_timeout (WINDOW_GROUP_DELAY, () => {
          pending_timer_id = 0U;
          process_pending_operations ();
          return false;
        });
        return;
      }
    }

    WindowControl () {
    }

    public static void initialize () {
      Wnck.set_client_type (Wnck.ClientType.PAGER);

      unowned Wnck.Screen screen = Wnck.Screen.get_default ();

      // Make sure internal window-list of Wnck is most up to date
      Gdk.error_trap_push ();

      screen.force_update ();

      if (Gdk.error_trap_pop () != 0)
        critical ("Wnck.Screen.force_update() caused a XError");

      screen.window_manager_changed.connect_after (window_manager_changed);
      screen.window_closed.connect_after (handle_window_closed);

      message ("Window-manager: %s", screen.get_window_manager_name ());
    }

    static void window_manager_changed (Wnck.Screen screen) {
      Gdk.error_trap_push ();

      screen.force_update ();

      if (Gdk.error_trap_pop () != 0)
        critical ("Wnck.Screen.force_update() caused a XError");

      warning ("Window-manager changed: %s", screen.get_window_manager_name ());
    }

    static void handle_window_closed (Wnck.Window window) {
      if (delayed_focus_timer_id > 0U && delayed_focus_xid == window.get_xid ()) {
        GLib.Source.remove (delayed_focus_timer_id);
        delayed_focus_timer_id = 0U;
        delayed_focus_xid = 0UL;
      }
    }

    public static unowned Gdk.Pixbuf? get_app_icon (Bamf.Application app)
    {
      unowned Gdk.Pixbuf? pbuf = null;

      Array<uint32>? xids = app.get_xids ();

      warn_if_fail (xids != null);

      Gdk.error_trap_push ();

      for (var i = 0; xids != null && i < xids.length && pbuf == null; i++) {
        unowned Wnck.Window window = Wnck.Window.@get (xids.index (i));
        if (window == null)
          continue;

        pbuf = window.get_icon ();
        if (window.get_icon_is_fallback ())
          pbuf = null;

        break;
      }

      if (Gdk.error_trap_pop () != 0)
        critical ("get_app_icon() for '%s' caused a XError", app.get_name ());

      return pbuf;
    }

    public static unowned Gdk.Pixbuf? get_window_icon (Bamf.Window window)
    {
      unowned Wnck.Window w = Wnck.Window.@get (window.get_xid ());
      unowned Gdk.Pixbuf? pbuf = null;

      warn_if_fail (w != null);

      if (w == null)
        return null;

      Gdk.error_trap_push ();

      pbuf = w.get_icon ();
      if (w.get_icon_is_fallback ())
        pbuf = null;

      if (Gdk.error_trap_pop () != 0)
        critical ("get_window_icon() for '%s' caused a XError", window.get_name ());

      return pbuf;
    }

    public static Gdk.Pixbuf? get_window_thumbnail (Bamf.Window window)
    {
      unowned Wnck.Window w = Wnck.Window.@get (window.get_xid ());

      warn_if_fail (w != null);

      if (w == null)
        return null;

      Gdk.error_trap_push ();

      Gdk.Pixbuf? thumbnail = null;

      var xwindow = w.get_xid ();
      var x11_display = Gdk.Display.get_default () as Gdk.X11.Display;
      if (x11_display == null) {
        return null;
      }

      var gdk_window = new Gdk.X11.Window.foreign_for_display (x11_display, xwindow);

      if (gdk_window != null) {
        int win_width = gdk_window.get_width ();
        int win_height = gdk_window.get_height ();

        if (win_width < 48 || win_height < 48)
          return null;

        thumbnail = Gdk.pixbuf_get_from_window (gdk_window, 0, 0, win_width, win_height);
      }

      if (Gdk.error_trap_pop () != 0)
        warning ("get_window_thumbnail() for '%s' caused a XError", window.get_name ());

      return thumbnail;
    }


    public static unowned Wnck.Workspace? get_window_workspace (Bamf.Window window)
    {
      unowned Wnck.Window w = Wnck.Window.@get (window.get_xid ());
      unowned Wnck.Workspace? workspace = null;

      warn_if_fail (w != null);

      if (w == null)
        return null;

      Gdk.error_trap_push ();

      workspace = w.get_workspace ();

      if (Gdk.error_trap_pop () != 0)
        critical ("get_window_workspace() for '%s' caused a XError", window.get_name ());

      return workspace;
    }

    public static bool has_maximized_window (Bamf.Application app) {
      Array<uint32>? xids = app.get_xids ();

      warn_if_fail (xids != null);

      for (var i = 0; xids != null && i < xids.length; i++) {
        unowned Wnck.Window window = Wnck.Window.@get (xids.index (i));
        if (window != null && window.is_maximized ())
          return true;
      }

      return false;
    }

    public static bool has_minimized_window (Bamf.Application app) {
      Array<uint32>? xids = app.get_xids ();

      warn_if_fail (xids != null);

      for (var i = 0; xids != null && i < xids.length; i++) {
        unowned Wnck.Window window = Wnck.Window.@get (xids.index (i));
        if (window != null && window.is_minimized ())
          return true;
      }

      return false;
    }

    public static bool has_window_on_workspace (Bamf.Application app, Wnck.Workspace workspace) {
      var is_virtual = workspace.is_virtual ();

      foreach (unowned Wnck.Window window in get_ordered_window_stack (app)) {
        if (window == null || window.is_skip_tasklist ())
          continue;

        if (!is_virtual) {
          if (window.is_on_workspace (workspace)) {
            return true;
          }
        } else {
          if (window.is_in_viewport (workspace)) {
            return true;
          }
        }
      }

      return false;
    }

    public static int window_on_workspace_count (Bamf.Application app, Wnck.Workspace workspace) {
      int window_count = 0;
      var is_virtual = workspace.is_virtual ();

      foreach (unowned Wnck.Window window in get_ordered_window_stack (app)) {
        if (window == null || window.is_skip_tasklist ())
          continue;

        if (!is_virtual) {
          if (window.is_on_workspace (workspace)) {
            window_count += 1;
          }
        } else {
          if (window.is_in_viewport (workspace)) {
            window_count += 1;
          }
        }
      }

      return window_count;
    }

    public static bool has_window (Bamf.Application app) {
      foreach (unowned Wnck.Window window in get_ordered_window_stack (app)) {
        if (window != null && !window.is_skip_tasklist ()) {
          return true;
        }
      }

      return false;
    }

    public static int window_count (Bamf.Application app) {
      int window_count = 0;

      foreach (unowned Wnck.Window window in get_ordered_window_stack (app)) {
        if (window != null && !window.is_skip_tasklist ()) {
          window_count += 1;
        }
      }

      return window_count;
    }

    public static Array<uint32> get_app_xids_on_workspace (Bamf.Application? app) {
      Array<uint32> xids = new Array<uint32> ();

      unowned Wnck.Workspace? active_workspace = Wnck.Screen.get_default ().get_active_workspace ();
      Array<uint32> app_xids = app.get_xids ();

      if (active_workspace == null) {
        return app_xids;
      }

      var is_virtual = active_workspace.is_virtual ();

      foreach (uint32 xid in app_xids) {
        unowned Wnck.Window window = Wnck.Window.@get (xid);

        if (!is_virtual) {
          if (window.is_on_workspace (active_workspace)) {
            xids.append_val (xid);
          }
        } else {
          if (window.is_in_viewport (active_workspace)) {
            xids.append_val (xid);
          }
        }
      }

      return xids;
    }

    public static void update_icon_regions (Bamf.Application app, Gdk.Rectangle rect) {
      Array<uint32>? xids = app.get_xids ();

      warn_if_fail (xids != null);

      for (var i = 0; xids != null && i < xids.length; i++) {
        unowned Wnck.Window window = Wnck.Window.@get (xids.index (i));
        if (window != null)
          window.set_icon_geometry (rect.x, rect.y, rect.width, rect.height);
      }
    }

    public static void close_window (Bamf.Window window, uint32 event_time) {
      unowned Wnck.Window wnck_window = Wnck.Window.@get (window.get_xid ());
      wnck_window.close (event_time);
    }

    public static void close_all (Bamf.Application app, uint32 event_time) {
      Array<uint32>? xids = app.get_xids ();

      warn_if_fail (xids != null);

      for (var i = 0; xids != null && i < xids.length; i++) {
        unowned Wnck.Window window = Wnck.Window.@get (xids.index (i));
        if (window != null && !window.is_skip_tasklist ())
          window.close (event_time);
      }
    }

    public static void close_all_in_workspace (Bamf.Application app, uint32 event_time) {
      Array<uint32>? xids = app.get_xids ();

      warn_if_fail (xids != null);

      unowned Wnck.Workspace? active_workspace = Wnck.Screen.get_default ().get_active_workspace ();
      var is_virtual = active_workspace.is_virtual ();

      for (var i = 0; xids != null && i < xids.length; i++) {
        unowned Wnck.Window window = Wnck.Window.@get (xids.index (i));
        if (window != null && !window.is_skip_tasklist () && active_workspace != null) {
          if (!is_virtual) {
            if (window.is_on_workspace (active_workspace)) {
              window.close (event_time);
            }
          } else {
            if (window.is_in_viewport (active_workspace)) {
              window.close (event_time);
            }
          }
        }
      }
    }

    public static void focus_window (Bamf.Window window, uint32 event_time) {
      unowned Wnck.Window w = Wnck.Window.@get (window.get_xid ());

      warn_if_fail (w != null);

      if (w == null)
        return;

      center_and_focus_window (w, event_time);
    }

    static void focus_window_by_xid (uint32 xid, uint32 event_time) {
      unowned Wnck.Window w = Wnck.Window.@get (xid);

      warn_if_fail (w != null);

      if (w == null)
        return;

      center_and_focus_window (w, event_time);
    }

    static int find_active_xid_index (Array<uint32>? xids) {
      var i = 0;
      for ( ; xids != null && i < xids.length; i++) {
        unowned Wnck.Window? window = Wnck.Window.@get (xids.index (i));
        if (window != null && window.is_active ())
          break;
      }
      return i;
    }

    public static void focus_previous (Bamf.Application app, uint32 event_time, bool focus_workspace) {
      Array<uint32>? xids = focus_workspace ? get_app_xids_on_workspace (app) : app.get_xids ();

      warn_if_fail (xids != null);

      if (xids == null)
        return;

      var i = find_active_xid_index (xids);
      i = i < xids.length ? i - 1 : 0;

      if (i < 0)
        i = (int) xids.length - 1;

      focus_window_by_xid (xids.index (i), event_time);
    }

    public static void focus_next (Bamf.Application app, uint32 event_time, bool focus_workspace) {
      Array<uint32>? xids = focus_workspace ? get_app_xids_on_workspace (app) : app.get_xids ();

      warn_if_fail (xids != null);

      if (xids == null)
        return;

      var i = find_active_xid_index (xids);
      i = i < xids.length ? i + 1 : 0;

      if (i == xids.length)
        i = 0;

      focus_window_by_xid (xids.index (i), event_time);
    }

    public static void minimize (Bamf.Application app) {
      var windows_to_minimize = new Gee.ArrayList<unowned Wnck.Window> ();

      foreach (unowned Wnck.Window window in get_ordered_window_stack (app)) {
        unowned Wnck.Workspace? active_workspace = window.get_screen ().get_active_workspace ();
        if (!window.is_minimized () && active_workspace != null && window.is_in_viewport (active_workspace)) {
          windows_to_minimize.add (window);
        }
      }

      process_windows (windows_to_minimize, PendingActionType.MINIMIZE, 0);
    }

    public static void restore (Bamf.Application app, uint32 event_time) {
      var stack = get_ordered_window_stack (app);
      stack.reverse ();

      var windows_to_restore = new Gee.ArrayList<unowned Wnck.Window> ();

      foreach (unowned Wnck.Window window in stack) {
        unowned Wnck.Workspace? active_workspace = window.get_screen ().get_active_workspace ();
        if (window.is_minimized () && active_workspace != null && window.is_in_viewport (active_workspace)) {
          windows_to_restore.add (window);
        }
      }

      process_windows (windows_to_restore, PendingActionType.UNMINIMIZE, event_time);
    }

    public static void maximize (Bamf.Application app) {
      foreach (unowned Wnck.Window window in get_ordered_window_stack (app))
        if (!window.is_maximized ())
          window.maximize ();
    }

    public static void unmaximize (Bamf.Application app) {
      foreach (unowned Wnck.Window window in get_ordered_window_stack (app))
        if (window.is_maximized ())
          window.unmaximize ();
    }

    public static GLib.List<unowned Wnck.Window> get_ordered_window_stack (Bamf.Application app) {
      var windows = new GLib.List<unowned Wnck.Window> ();

      Array<uint32>? xids = app.get_xids ();

      if (xids == null) {
        debug ("Failed to get xids for %s", app.get_name ());
        return windows;
      }

      unowned GLib.List<Wnck.Window> stack = Wnck.Screen.get_default ().get_windows_stacked ();

      foreach (unowned Wnck.Window window in stack)
        for (var j = 0; j < xids.length; j++)
          if (xids.index (j) == window.get_xid ())
            windows.append (window);

      return windows;
    }

    public static void smart_focus (Bamf.Application app, uint32 event_time) {
      var windows = get_ordered_window_stack (app);

      var not_in_viewport = true;
      var urgent = false;

      foreach (unowned Wnck.Window window in windows) {
        unowned Wnck.Workspace? active_workspace = window.get_screen ().get_active_workspace ();
        if (!window.is_skip_tasklist () && active_workspace != null && window.is_in_viewport (active_workspace))
          not_in_viewport = false;
        if (window.needs_attention ())
          urgent = true;
      }

      // Focus off-viewport window if it needs attention
      if (not_in_viewport || urgent) {
        foreach (unowned Wnck.Window window in windows) {
          if (urgent && !window.needs_attention ())
            continue;

          if (!window.is_skip_tasklist ()) {
            intelligent_focus_off_viewport_window (window, windows, event_time);
            return;
          }
        }
      }

      // Unminimize minimized windows if there is one or more
      foreach (unowned Wnck.Window window in windows) {
        unowned Wnck.Workspace? active_workspace = window.get_screen ().get_active_workspace ();
        if (window.is_minimized () && active_workspace != null && window.is_in_viewport (active_workspace)) {
          var windows_to_unminimize = new Gee.ArrayList<unowned Wnck.Window> ();
          foreach (unowned Wnck.Window w in windows)
            if (w.is_minimized () && w.is_in_viewport (active_workspace))
              windows_to_unminimize.add (w);
          process_windows (windows_to_unminimize, PendingActionType.UNMINIMIZE, event_time);
          return;
        }
      }

      // Minimize all windows if this application owns the active window
      foreach (unowned Wnck.Window window in windows) {
        unowned Wnck.Workspace? active_workspace = window.get_screen ().get_active_workspace ();
        if ((window.is_active () && active_workspace != null && window.is_in_viewport (active_workspace))
            || window == window.get_screen ().get_active_window ()) {
          var windows_to_minimize = new Gee.ArrayList<unowned Wnck.Window> ();
          foreach (unowned Wnck.Window w in windows)
            if (!w.is_minimized () && w.is_in_viewport (active_workspace) && w.get_window_type () != Wnck.WindowType.DOCK)
              windows_to_minimize.add (w);
          process_windows (windows_to_minimize, PendingActionType.MINIMIZE, 0);
          return;
        }
      }

      // Get all windows on the current workspace in the foreground
      foreach (unowned Wnck.Window window in windows) {
        unowned Wnck.Workspace? active_workspace = window.get_screen ().get_active_workspace ();
        if (active_workspace != null && window.is_in_viewport (active_workspace)) {
          var windows_to_focus = new Gee.ArrayList<unowned Wnck.Window> ();
          foreach (unowned Wnck.Window w in windows)
            if (w.is_in_viewport (active_workspace))
              windows_to_focus.add (w);
          process_windows (windows_to_focus, PendingActionType.CENTER_AND_FOCUS, event_time);
          return;
        }
      }

      // Focus most-top window and all others on its workspace
      intelligent_focus_off_viewport_window (windows.nth_data (0), windows, event_time);
    }

    static void intelligent_focus_off_viewport_window (Wnck.Window? targetWindow,
                                                       GLib.List<unowned Wnck.Window> additional_windows, uint32 event_time) {
      if (targetWindow == null) {
        return;
      }

      additional_windows.reverse ();

      var windows_to_focus = new Gee.ArrayList<unowned Wnck.Window> ();
      foreach (unowned Wnck.Window window in additional_windows) {
        if (window == targetWindow)
          continue;
        if (!window.is_minimized () && windows_share_viewport (targetWindow, window)) {
          windows_to_focus.add (window);
        }
      }

      // Focus the additional windows first, then the target window
      uint window_count = additional_windows.length ();

      if (windows_to_focus.size > 0) {
        process_windows (windows_to_focus, PendingActionType.CENTER_AND_FOCUS, event_time);

        // Queue target window focus after the other windows
        var target_list = new Gee.ArrayList<unowned Wnck.Window> ();
        target_list.add (targetWindow);
        process_windows (target_list, PendingActionType.CENTER_AND_FOCUS, event_time);

        // Queue schedule_delayed_focus to run after focus operations
        var delayed_list = new Gee.ArrayList<ulong> ();
        delayed_list.add (targetWindow.get_xid ());
        queue_operation (new PendingOperation (PendingActionType.SCHEDULE_DELAYED_FOCUS, delayed_list, event_time, window_count));
      } else {
        center_and_focus_window (targetWindow, event_time);
        schedule_delayed_focus (targetWindow, window_count, event_time);
      }
    }

    /**
     * Schedule a delayed focus activation for the target window.
     *
     * This is a workaround for Compiz and other compositing window managers
     * that may not properly bring the target window to front when multiple
     * windows are focused in quick succession. By delaying the final focus
     * activation, we give the window manager time to process the previous
     * focus changes before activating the target window again.
     *
     * Uses XID instead of window reference to avoid use-after-free in timeout.
     */
    static void schedule_delayed_focus (Wnck.Window targetWindow, uint window_count, uint32 event_time) {
      if (window_count <= 1)
        return;

      // Cancel any pending delayed focus
      if (delayed_focus_timer_id > 0U) {
        GLib.Source.remove (delayed_focus_timer_id);
        delayed_focus_timer_id = 0U;
      }

      // Store XID instead of window reference - safe to use in timeout
      delayed_focus_xid = targetWindow.get_xid ();
      delayed_focus_timer_id = Gdk.threads_add_timeout (VIEWPORT_CHANGE_DELAY, () => {
        delayed_focus_timer_id = 0U;
        // Look up window by XID - returns null if window was closed
        unowned Wnck.Window? w = Wnck.Window.@get (delayed_focus_xid);
        if (w != null) {
          w.activate (event_time);
        }
        delayed_focus_xid = 0UL;
        return false;
      });
    }

    static bool windows_share_viewport (Wnck.Window? first, Wnck.Window? second) {
      if (first == null || second == null)
        return false;

      unowned Wnck.Workspace wksp = first.get_workspace ();
      if (wksp == null)
        wksp = second.get_workspace ();

      if (wksp == null)
        return false;

      Gdk.Rectangle firstGeo = {};
      Gdk.Rectangle secondGeo = {};

      first.get_geometry (out firstGeo.x, out firstGeo.y, out firstGeo.width, out firstGeo.height);
      second.get_geometry (out secondGeo.x, out secondGeo.y, out secondGeo.width, out secondGeo.height);

      firstGeo.x += wksp.get_viewport_x ();
      firstGeo.y += wksp.get_viewport_y ();

      secondGeo.x += wksp.get_viewport_x ();
      secondGeo.y += wksp.get_viewport_y ();

      var viewportWidth = first.get_screen ().get_width ();
      var viewportHeight = first.get_screen ().get_height ();

      var firstViewportX = ((firstGeo.x + firstGeo.width / 2) / viewportWidth) * viewportWidth;
      var firstViewportY = ((firstGeo.y + firstGeo.height / 2) / viewportHeight) * viewportHeight;

      Gdk.Rectangle viewpRect = { firstViewportX, firstViewportY, viewportWidth, viewportHeight };
      return viewpRect.intersect (secondGeo, null);
    }

    static void center_and_focus_window (Wnck.Window w, uint32 event_time) {
      unowned Wnck.Workspace? workspace = w.get_workspace ();

      if (!w.is_pinned () && workspace != null && workspace != w.get_screen ().get_active_workspace ())
        workspace.activate (event_time);

      if (w.is_minimized ())
        w.unminimize (event_time);

      w.activate_transient (event_time);
    }

    public static Gdk.Rectangle get_easy_geometry (Wnck.Window w) {
      Gdk.Rectangle geo = {};

      w.get_geometry (out geo.x, out geo.y, out geo.width, out geo.height);

      return geo;
    }
  }
}
