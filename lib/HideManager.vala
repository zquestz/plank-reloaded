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
  /**
   * If/How the dock should hide itself.
   */
  public enum HideType {
    /**
     * The dock does not hide.  It should set struts to reserve space for it.
     */
    NONE,
    /**
     * The dock hides if a window in the active window group overlaps it.
     */
    INTELLIGENT,
    /**
     * The dock hides if the mouse is not over it.
     */
    AUTO,
    /**
     * The dock hides if there is an active maximized window.
     */
    DODGE_MAXIMIZED,
    /**
     * The dock hides if there is any window overlapping it.
     */
    WINDOW_DODGE,
    /**
     * The dock hides if there is the active window overlapping it.
     */
    DODGE_ACTIVE,
  }

  /**
   * Handles checking if a dock should hide or not.
   */
  public class HideManager : GLib.Object {
    // a delay between window changes and updating our data
    // this allows window animations to occur, which might change
    // the results of our update
    const uint UPDATE_TIMEOUT = 200U;

#if HAVE_BARRIERS
    // As GNOME Shell's edge pressure: 250 pixels of pushing within a second
    const double PRESSURE_THRESHOLD = 250.0;
    const uint PRESSURE_TIMEOUT = 1000U;
#endif

    static int plank_pid;

    static construct
    {
      plank_pid = getpid ();
    }

    public DockController controller { private get; construct; }

    /**
     * If the dock is currently hidden.
     */
    public bool Hidden { get; private set; default = true; }

    /**
     * If hiding the dock is currently disabled
     */
    public bool Disabled { get; private set; default = false; }

    /**
     * If the dock is currently hovered by the mouse cursor.
     */
    public bool Hovered { get; private set; default = false; }

    const uint EDGE_POLL_INTERVAL = 100U;
    const uint EDGE_REVEAL_TIMEOUT = 2000U;

    uint hide_timer_id = 0U;
    uint unhide_timer_id = 0U;
    uint prefs_changed_timer_id = 0U;
    uint geometry_timer_id = 0U;
    uint window_changed_timer_id = 0U;
    uint edge_poll_timer_id = 0U;
    uint pending_reveal_timer_id = 0U;

    bool pending_reveal = false;
    int64 pending_reveal_deadline = 0;
    // The dock's monitor setting changed, and the move hasn't landed yet
    bool monitor_change_pending = false;
    // A screen update is running, and the dock's own monitor may still be
    // measured as it was before
    bool screen_update_pending = false;
    bool window_intersect = false;
    bool active_window_intersect = false;
    bool active_application_intersect = false;
    bool active_maximized_window_intersect = false;
    bool dialog_windows_intersect = false;
    Gdk.Rectangle last_window_rect;

    string? last_window_name = null;
    ulong last_window_xid = 0;
    int last_window_workspace_id = -1;

#if HAVE_BARRIERS
    XFixes.PointerBarrier barrier = 0;
    int opcode = 0;
    PressureCounter pressure_counter = new PressureCounter (PRESSURE_THRESHOLD, PRESSURE_TIMEOUT);
    bool barriers_supported = false;
    Gtk.Clipboard? xdnd_selection = null;
    // A drag-and-drop is running, in any app. A window move or a text
    // selection grabs the pointer too, but isn't one
    bool drag_live = false;
#endif

    /**
     * Creates a new instance of a HideManager, which handles
     * checking if a dock should hide or not.
     *
     * @param controller the {@link DockController} to manage hiding for
     */
    public HideManager (DockController controller) {
      GLib.Object (controller: controller);
    }

    construct
    {
      controller.prefs.notify.connect (prefs_changed);
      notify["Hidden"].connect (hidden_changed);
    }

    /**
     * Initializes the hide manager.  Call after the DockWindow is constructed.
     */
    public void initialize ()
    requires (controller.window != null)
    {
      unowned DockWindow window = controller.window;
      unowned Wnck.Screen wnck_screen = WindowControl.get_wnck_screen ();

#if HAVE_BARRIERS
      initialize_barriers_support ();
#endif

      window.enter_notify_event.connect (handle_enter_notify_event);
      window.leave_notify_event.connect (handle_leave_notify_event);

      wnck_screen.window_opened.connect_after (schedule_update);
      wnck_screen.window_closed.connect_after (schedule_update);
      wnck_screen.active_window_changed.connect_after (handle_active_window_changed);
      wnck_screen.active_workspace_changed.connect_after (handle_workspace_changed);

      setup_active_window (wnck_screen);
      update_edge_polling ();
    }

    ~HideManager () {
      unowned DockWindow window = controller.window;
      unowned DragManager drag_manager = controller.drag_manager;
      unowned Wnck.Screen wnck_screen = WindowControl.get_wnck_screen ();

      controller.prefs.notify.disconnect (prefs_changed);

      window.enter_notify_event.disconnect (handle_enter_notify_event);
      window.leave_notify_event.disconnect (handle_leave_notify_event);

      wnck_screen.window_opened.disconnect (schedule_update);
      wnck_screen.window_closed.disconnect (schedule_update);
      wnck_screen.active_window_changed.disconnect (handle_active_window_changed);
      wnck_screen.active_workspace_changed.disconnect (handle_workspace_changed);

      stop_timers ();

#if HAVE_BARRIERS
      gdk_window_remove_filter (null, (Gdk.FilterFunc) xevent_filter);

      if (xdnd_selection != null)
        xdnd_selection.owner_change.disconnect (xdnd_owner_changed);

      if (barrier != 0) {
        unowned Gdk.X11.Display? gdk_display = (controller.window.get_display () as Gdk.X11.Display);
        if (gdk_display != null) {
          unowned X.Display display = gdk_display.get_xdisplay ();
          gdk_display.error_trap_push ();
          XFixes.destroy_pointer_barrier (display, barrier);
          gdk_display.error_trap_pop_ignored ();
        }
        barrier = 0;
      }
#endif
    }

    /**
     * Checks to see if the dock is being hovered by the mouse cursor.
     */
    public void update_hovered () {
      unowned PositionManager position_manager = controller.position_manager;

      // get current mouse pointer location
      int x, y;
      get_pointer_position (out x, out y);

      // get window location
      var win_rect = position_manager.get_dock_window_region ();
      x -= win_rect.x;
      y -= win_rect.y;

      // X only reports the pointer inside the dock's window, so a pointer
      // outside it can't count as hovering, or no leave would ever clear it
      update_hovered_with_coords (x, y, x < 0 || y < 0 || x >= win_rect.width || y >= win_rect.height);
    }

    /**
     * The pointer's position in logical pixels. GTK rounds the device
     * position divided by the scale to the nearest pixel, which at a scale
     * of 2 or more puts a monitor's last device row or column on the pixel
     * past the monitor; rounding down keeps it on the pixel that holds it.
     */
    internal void get_pointer_position (out int x, out int y) {
      double pointer_x, pointer_y;
      controller.window.get_display ()
       .get_default_seat ()
       .get_pointer ()
       .get_position_double (null, out pointer_x, out pointer_y);

      x = (int) Math.floor (pointer_x);
      y = (int) Math.floor (pointer_y);
    }

    /**
     * Checks to see if the dock is being hovered by the mouse cursor.
     *
     * @param x the x coordinate of the pointer relative to the dock window
     * @param y the y coordinate of the pointer relative to the dock window
     */
    public void update_hovered_with_coords (int x, int y, bool force_unhovered = false) {
      unowned PositionManager position_manager = controller.position_manager;
      unowned DockWindow window = controller.window;
      unowned DragManager drag_manager = controller.drag_manager;

      freeze_notify ();

      bool update_needed = false;

      // compute rect of the window
      var dock_rect = position_manager.get_cursor_region ();

      // use the dock rect and cursor location to determine if dock is hovered
      var hovered = false;

      if (!force_unhovered) {
        hovered = (x >= dock_rect.x && x < dock_rect.x + dock_rect.width
                   && y >= dock_rect.y && y < dock_rect.y + dock_rect.height);
      }

      // Open window previews keep the dock hovered, so it neither hides nor
      // drops its zoom while the pointer crosses over to them
      if (controller.preview_manager.is_open ())
        hovered = true;

      if (Hovered != hovered) {
        Hovered = hovered;
        update_needed = true;
      }

      // disable hiding if menu is visible or drags are active
      var disabled = (window.menu_is_visible () || drag_manager.InternalDragActive || drag_manager.ExternalDragActive);
      if (Disabled != disabled) {
        Disabled = disabled;
        update_needed = true;
      }

      if (update_needed)
        update_hidden ();

      thaw_notify ();
    }

    void prefs_changed (Object prefs, ParamSpec prop) {
      switch (prop.name) {
      case "HideMode":
      case "Position":
        if (prefs_changed_timer_id > 0U) {
          GLib.Source.remove (prefs_changed_timer_id);
          prefs_changed_timer_id = 0U;
        }

        prefs_changed_timer_id = Gdk.threads_add_timeout (UPDATE_TIMEOUT, () => {
          update_window_intersect ();
#if HAVE_BARRIERS
          update_barrier ();
#endif
          update_edge_polling ();
          prefs_changed_timer_id = 0U;
          return false;
        });
        break;
      case "PressureReveal":
#if HAVE_BARRIERS
        update_barrier ();
#endif
        update_edge_polling ();
        break;
      case "GapSize":
        update_edge_polling ();
        break;
      case "Monitor":
        // The dock moves to another monitor once the screen update lands,
        // with the setting changed by hand or by following the active
        // display. Until then, monitors past its old edge mustn't hold it,
        // so a reveal from one ends and the dock hides where it is rather
        // than arriving shown, without waiting out a hide delay that could
        // outlast the move
        monitor_change_pending = true;
        cancel_pending_reveal ();
        update_hovered ();
        update_hidden ();
        if (hide_timer_id > 0U) {
          GLib.Source.remove (hide_timer_id);
          hide_timer_id = 0U;
          Hidden = true;
        }
        update_edge_polling ();
        break;
      default:
        // Nothing important for us changed
        break;
      }
    }

    void update_hidden () {
      // Showing also drops a hide timer that was counting down, so it can't
      // hide the dock under a menu or a drag
      if (Disabled) {
        show (false);
        return;
      }

      // The pointer shows the dock while it hovers it or a reveal from the
      // edge is pending; each hide mode's own reason to show comes first
      var pointer = (Hovered || pending_reveal);

      switch (controller.prefs.HideMode) {
      default:
      case HideType.NONE:
        show (false);
        break;

      case HideType.INTELLIGENT:
        if (!active_application_intersect)
          show (false);
        else if (pointer)
          show (true);
        else
          hide ();
        break;

      case HideType.AUTO:
        if (pointer)
          show (true);
        else
          hide ();
        break;

      case HideType.DODGE_MAXIMIZED:
        if (!(active_maximized_window_intersect || dialog_windows_intersect))
          show (false);
        else if (pointer)
          show (true);
        else
          hide ();
        break;

      case HideType.WINDOW_DODGE:
        if (!window_intersect)
          show (false);
        else if (pointer)
          show (true);
        else
          hide ();
        break;

      case HideType.DODGE_ACTIVE:
        if (!active_window_intersect)
          show (false);
        else if (pointer)
          show (true);
        else
          hide ();
        break;
      }
    }

    void hide () {
      if (unhide_timer_id > 0U) {
        GLib.Source.remove (unhide_timer_id);
        unhide_timer_id = 0U;

#if HAVE_BARRIERS
        // The reveal was cancelled before the dock showed, and the pointer
        // may still be within the barrier's reach, where no leave arrives,
        // so let the next push reveal again
        pressure_counter.leave ();
#endif
      }

      if (Hidden)
        return;

      // A dock the edge poll would reveal again at once, with the pointer at
      // its edge or on a monitor past it, holds there instead of hiding and
      // bouncing straight back
      if (edge_poll_applies () && pointer_at_dock_edge ()) {
        start_pending_reveal ();
        return;
      }

      if (controller.prefs.HideDelay == 0U) {
        if (!Hidden)
          Hidden = true;
        return;
      }

      if (hide_timer_id > 0U)
        return;

      hide_timer_id = Gdk.threads_add_timeout (controller.prefs.HideDelay, () => {
        hide_timer_id = 0U;

        if (Hidden)
          return false;

        // The pointer may have reached the edge while the delay ran
        if (edge_poll_applies () && pointer_at_dock_edge ())
          start_pending_reveal ();
        else
          Hidden = true;

        return false;
      });
    }

    // Only showing for the pointer waits for the unhide delay, whatever event
    // asked; once the dock no longer needs to hide, it shows at once
    void show (bool pointer_update) {
      if (hide_timer_id > 0U) {
        GLib.Source.remove (hide_timer_id);
        hide_timer_id = 0U;
      }

      if (!Hidden)
        return;

      if (!pointer_update || controller.prefs.UnhideDelay == 0U) {
        if (Hidden)
          Hidden = false;
        return;
      }

      if (unhide_timer_id > 0U)
        return;

      unhide_timer_id = Gdk.threads_add_timeout (controller.prefs.UnhideDelay, () => {
        unhide_timer_id = 0U;

        // A dock shown meanwhile for another reason leaves nothing to decide
        if (!Hidden)
          return false;

        // The reveal checks the pointer only every 100 ms, so make sure it
        // still waits near the edge as the delay ends
        if (pending_reveal && !pointer_in_keep_area ()) {
          cancel_pending_reveal ();
          update_hovered ();
          update_hidden ();
          return false;
        }

        if (Hidden)
          Hidden = false;
        return false;
      });
    }

    /**
     * How long a dock revealed from its edge stays shown once the pointer has
     * left that edge, and how long a dock following the active display waits
     * before moving to a monitor past its edge.
     */
    internal uint compute_reveal_timeout () {
      unowned DockTheme theme = controller.renderer.theme;
      var anim_time = theme.FadeOpacity == 1.0 ? theme.HideTime : theme.FadeTime;
      return (uint) anim_time + EDGE_REVEAL_TIMEOUT;
    }

    void start_pending_reveal () {
      // A push against a gapless dock holds the pointer on the dock's own
      // edge, so the dock simply counts as hovered until the pointer leaves
      // it. The edge poll may find the pointer off the dock, on a panel or
      // another monitor, where the dock would never see it leave, so that
      // reveal takes the hold below
      if (controller.prefs.GapSize == 0 && pressure_reveals ()) {
        freeze_notify ();

        if (!Hovered) {
          Hovered = true;
          update_hidden ();
        }

        thaw_notify ();
        return;
      }

      if (pending_reveal)
        return;

      pending_reveal = true;
      pending_reveal_deadline = 0;
      pending_reveal_timer_id = Gdk.threads_add_timeout (EDGE_POLL_INTERVAL, () => {
        if (Hidden) {
          // While the unhide delay runs, the pointer has to wait near the
          // edge, as it has to stay on a dock without a gap; leaving gives
          // the reveal up
          if (pointer_in_keep_area ())
            return true;
        } else {
          // A gap, a panel or a monitor past the edge leaves the pointer
          // outside the dock's hover region, so the reveal lasts until the
          // pointer has been away from the edge for the whole timeout, counted
          // from the first poll that finds it gone once the dock shows,
          // leaving it that long to cross over to the dock
          if (pointer_at_dock_edge ()) {
            pending_reveal_deadline = 0;
            return true;
          }

          var now = GLib.get_monotonic_time ();
          if (pending_reveal_deadline == 0)
            pending_reveal_deadline = now + (int64) compute_reveal_timeout () * 1000;

          if (now < pending_reveal_deadline)
            return true;
        }

        pending_reveal = false;
        pending_reveal_timer_id = 0U;
        update_hovered ();
        update_hidden ();
        return false;
      });

      // Showing can find the pointer already on the dock and end the reveal
      // there, which has to take the timer with it
      show (true);
    }

    void cancel_pending_reveal () {
      if (!pending_reveal)
        return;

      pending_reveal = false;
      if (pending_reveal_timer_id > 0U) {
        GLib.Source.remove (pending_reveal_timer_id);
        pending_reveal_timer_id = 0U;
      }
    }

    void hidden_changed () {
      update_edge_polling ();

      // With pressure reveal on, a hidden gapless dock ignores the pointer
      // entering its edge strip, so a pointer parked there isn't hovering it.
      // When the dock then shows for another reason, the pointer is already
      // inside its window and no further enter arrives, so check now, while
      // the input region is still the strip. A dock with a gap has no strip,
      // and without a compositor its window is still where it hid, so the
      // pointer that revealed it on the edge row would count as on the dock
      if (!Hidden && !Hovered && controller.prefs.GapSize == 0)
        update_hovered ();

      // A dock that shows with the pointer on it no longer needs the reveal
      // that brought it out: leaving the dock decides from here
      if (!Hidden && Hovered)
        cancel_pending_reveal ();

#if HAVE_BARRIERS
      // A dock that has just hidden starts every push afresh. The pointer may
      // still be within the barrier's reach, where no leave arrives to end
      // the push that revealed it
      if (Hidden)
        pressure_counter.leave ();
#endif
    }

    // Pressure reveal, when the barriers it needs work, reveals a dock by
    // pushing against its edge instead of touching it
    bool pressure_reveals () {
#if HAVE_BARRIERS
      return (barriers_supported && controller.prefs.PressureReveal);
#else
      return false;
#endif
    }

    // Whether the dock polls its edge for the pointer while hidden. A gapless
    // dock already sees the pointer at its edge through its own input
    // region, so it only needs the poll for a panel between that edge and
    // the monitor's, or for a monitor past it
    bool edge_poll_applies () {
      unowned PositionManager position_manager = controller.position_manager;

      return controller.prefs.HideMode != HideType.NONE
             && !pressure_reveals ()
             && (controller.prefs.GapSize > 0
                 || band_past_dock_area (position_manager.Position, position_manager.get_monitor_geometry (),
                                         position_manager.get_raw_monitor_geometry ())
                 || any_monitor_past_dock_edge ());
    }

    /**
     * Notes that a screen update has begun, and the dock's own monitor may
     * still be measured as it was before.
     */
    internal void screen_update_started () {
      screen_update_pending = true;
    }

    /**
     * Picks up after a screen update: the dock may have landed on another
     * monitor, and monitors may have come or gone past its edge.
     */
    internal void screen_update_ended () {
      monitor_change_pending = false;
      screen_update_pending = false;
      update_edge_polling ();
    }

    /**
     * Starts or stops polling the pointer for a hidden dock's edge, after a
     * change to the dock or to the monitors around it.
     */
    internal void update_edge_polling () {
      bool need_polling = Hidden && edge_poll_applies ();

      if (need_polling && edge_poll_timer_id == 0U) {
        edge_poll_timer_id = Gdk.threads_add_timeout (EDGE_POLL_INTERVAL, edge_poll_tick);
      } else if (!need_polling && edge_poll_timer_id > 0U) {
        GLib.Source.remove (edge_poll_timer_id);
        edge_poll_timer_id = 0U;
      }
    }

    bool edge_poll_tick () {
      // A hovered dock is already showing for the pointer on its own edge
      // strip, and a hold started here would outlast the hover
      if (Hidden && !Hovered && pointer_at_dock_edge ())
        start_pending_reveal ();

      return true;
    }

    // Whether a monitor past the dock's edge counts at all. Pressure reveal
    // shows the dock only for a push against its own monitor's edge, and a
    // dock about to move to another monitor no longer belongs to the old
    // monitor's edge. While a screen update runs, the dock's own monitor
    // can look like one past its edge, so a hidden dock waits for it to land
    // rather than flash up; a dock already shown keeps counting, so it
    // doesn't hide and come back
    bool monitors_past_count () {
      return !pressure_reveals () && !monitor_change_pending
             && !(screen_update_pending && Hidden);
    }

    // Whether a point is on another monitor past the dock's edge, as
    // monitor_past_dock_edge () defines it
    bool on_monitor_past_dock_edge (int x, int y) {
      if (!monitors_past_count ())
        return false;

      unowned PositionManager position_manager = controller.position_manager;
      var monitor = controller.window.get_display ().get_monitor_at_point (x, y).get_geometry ();

      return monitor_past_dock_edge (position_manager.Position, monitor,
                                     position_manager.get_raw_monitor_geometry ());
    }

    // Whether any monitor lies past the dock's edge, as
    // monitor_past_dock_edge () defines it
    bool any_monitor_past_dock_edge () {
      if (!monitors_past_count ())
        return false;

      unowned PositionManager position_manager = controller.position_manager;
      unowned Gdk.Display display = controller.window.get_display ();
      var raw_monitor = position_manager.get_raw_monitor_geometry ();

      for (var i = 0; i < display.get_n_monitors (); i++)
        if (monitor_past_dock_edge (position_manager.Position, display.get_monitor (i).get_geometry (), raw_monitor))
          return true;

      return false;
    }

    // Whether the pointer is in the dock's keep area, as
    // point_in_dock_keep_area () defines it, or on a monitor past its edge
    bool pointer_in_keep_area () {
      unowned PositionManager position_manager = controller.position_manager;

      int x, y;
      get_pointer_position (out x, out y);

      return point_in_dock_keep_area (position_manager.Position, x, y,
                                      position_manager.get_raw_monitor_geometry (),
                                      position_manager.get_static_dock_region ())
             || on_monitor_past_dock_edge (x, y);
    }

    // Whether the pointer is at the dock's edge, as point_at_dock_edge () defines it,
    // or anywhere on a monitor past it
    bool pointer_at_dock_edge () {
      unowned PositionManager position_manager = controller.position_manager;

      int pointer_x, pointer_y;
      get_pointer_position (out pointer_x, out pointer_y);

      return point_at_dock_edge (position_manager.Position, pointer_x, pointer_y,
                                 position_manager.get_monitor_geometry (),
                                 position_manager.get_raw_monitor_geometry (),
                                 position_manager.get_static_dock_region ())
             || on_monitor_past_dock_edge (pointer_x, pointer_y);
    }

    [CCode (instance_pos = -1)]
    bool handle_enter_notify_event (Gtk.Widget widget, Gdk.EventCrossing event) {
      if (event.detail == Gdk.NotifyType.INFERIOR)
        return Hidden;

      // A reveal from the edge still waiting out its unhide delay carries on
      // across a gapless dock's strip, as long as the pointer stays near the
      // dock; once the dock shows, the pointer on it takes over
      if (!Hidden)
        cancel_pending_reveal ();

#if HAVE_BARRIERS
      if (Hidden && barriers_supported
          && controller.prefs.PressureReveal
          && device_supports_pressure (event.get_source_device ()))
        return Hidden;
#endif

      if (!Hovered)
        update_hovered_with_coords ((int) event.x, (int) event.y);

      return Hidden;
    }

    [CCode (instance_pos = -1)]
    bool handle_leave_notify_event (Gtk.Widget widget, Gdk.EventCrossing event) {
      if (event.detail == Gdk.NotifyType.INFERIOR)
        return Gdk.EVENT_PROPAGATE;

      // ignore this event if it was sent explicitly
      if ((bool) event.send_event)
        return Gdk.EVENT_PROPAGATE;

      if (Hovered) {
        unowned PositionManager position_manager = controller.position_manager;
        var dock_rect = position_manager.get_static_dock_region ();
        var x = (int) event.x_root;
        var y = (int) event.y_root;

        // Leaving a dock for its edge, across its gap, onto a panel along the
        // edge or onto a monitor past it, is reaching for the edge rather
        // than leaving, so the dock stays shown as for a reveal from the
        // edge. A gapless dock still hidden, hovered through its strip during
        // its unhide delay, keeps revealing the same way rather than starting
        // the delay over. A gapless dock does this only where its edge poll
        // runs. With a compositor at a scale of 2, the input region of a
        // bottom or right dock leaves out the dock's far row or column, so a
        // pointer leaving the other way can still be on the dock, which
        // doesn't count
        var on_dock = (x >= dock_rect.x && x < dock_rect.x + dock_rect.width
                       && y >= dock_rect.y && y < dock_rect.y + dock_rect.height);
        if (controller.prefs.HideMode != HideType.NONE && !on_dock
            && (controller.prefs.GapSize > 0 || edge_poll_applies ())
            && (point_in_dock_keep_area (position_manager.Position, x, y,
                                         position_manager.get_raw_monitor_geometry (), dock_rect)
                || on_monitor_past_dock_edge (x, y)))
          start_pending_reveal ();

        update_hovered_with_coords ((int) event.x, (int) event.y, true);
      }

      return Gdk.EVENT_PROPAGATE;
    }

    inline bool device_supports_pressure (Gdk.Device device) {
      return (device.input_source == Gdk.InputSource.MOUSE
              || device.input_source == Gdk.InputSource.TOUCHPAD
              || device.input_source == Gdk.InputSource.TRACKPOINT);
    }

    //
    // intelligent hiding code
    //

    void update_window_intersect () {
      var dock_rect = controller.position_manager.get_static_dock_region ();
      var window_scale_factor = controller.window.get_window ().get_scale_factor ();
      if (window_scale_factor > 1) {
        dock_rect.x *= window_scale_factor;
        dock_rect.y *= window_scale_factor;
        dock_rect.width *= window_scale_factor;
        dock_rect.height *= window_scale_factor;
      }

      var intersect = false;
      var dialog_intersect = false;
      var active_intersect = false;
      var new_active_window_intersect = false;
      var active_maximized_intersect = false;
      var ignore_update = false;
      unowned Wnck.Screen screen = WindowControl.get_wnck_screen ();
      unowned Wnck.Window? active_window = screen.get_active_window ();
      unowned Wnck.Workspace? active_workspace = screen.get_active_workspace ();

      if (active_window != null && active_workspace != null) {
        var active_pid = active_window.get_pid ();
        foreach (var w in screen.get_windows ()) {
          if (w.is_minimized ())
            continue;
          var type = w.get_window_type ();
          if (type == Wnck.WindowType.DESKTOP || type == Wnck.WindowType.DOCK
              || type == Wnck.WindowType.MENU || type == Wnck.WindowType.SPLASHSCREEN)
            continue;
          // The dock's own test, so sticky windows shown on every workspace
          // count here too
          if (!WindowControl.window_is_visible_on_workspace (w, active_workspace))
            continue;
          var pid = w.get_pid ();
          if (pid == plank_pid)
            continue;

          if (window_geometry (w).intersect (dock_rect, null)) {
            intersect = true;

            if (pid != active_pid)
              continue;

            active_intersect = true;

            new_active_window_intersect = new_active_window_intersect || (active_window == w);

            active_maximized_intersect = active_maximized_intersect || (active_window == w
                                                                        && (w.is_maximized () || w.is_maximized_vertically () || w.is_maximized_horizontally ()));

            dialog_intersect = dialog_intersect || type == Wnck.WindowType.DIALOG;

            if (active_maximized_intersect && dialog_intersect)
              break;
          }
        }

        last_window_name = active_window.get_name ();
        last_window_xid = active_window.get_xid ();
        last_window_workspace_id = active_workspace.get_number ();
      } else {
        // Workaround to prevent dock from showing up on Steam menu clicks.
        // See InternalConsts.STEAM_WINDOW_NAME for details.
        if (last_window_name == STEAM_WINDOW_NAME) {
          unowned Wnck.Window? existing_window = WindowControl.get_wnck_window (last_window_xid);

          if (existing_window != null && active_workspace != null
              && last_window_workspace_id == active_workspace.get_number ()) {
            ignore_update = true;
          } else {
            last_window_name = null;
            last_window_xid = 0;
            last_window_workspace_id = -1;
          }
        }
      }

      if (ignore_update) {
        return;
      }

      window_intersect = intersect;
      dialog_windows_intersect = dialog_intersect;
      active_application_intersect = active_intersect;
      active_window_intersect = new_active_window_intersect;
      active_maximized_window_intersect = active_maximized_intersect;

      update_hidden ();
    }

    void schedule_update () {
      if (window_changed_timer_id > 0U)
        return;

      window_changed_timer_id = Gdk.threads_add_timeout (UPDATE_TIMEOUT, () => {
        update_window_intersect ();
        window_changed_timer_id = 0U;
        return false;
      });
    }

    [CCode (instance_pos = -1)]
    void handle_workspace_changed (Wnck.Screen screen, Wnck.Workspace? previous) {
      schedule_update ();
    }

    [CCode (instance_pos = -1)]
    void handle_active_window_changed (Wnck.Screen screen, Wnck.Window? previous) {
      if (previous != null) {
        previous.geometry_changed.disconnect (handle_geometry_changed);
        previous.state_changed.disconnect (handle_state_changed);
      }

      setup_active_window (screen);
    }

    void setup_active_window (Wnck.Screen screen) {
      var active_window = screen.get_active_window ();

      if (active_window != null) {
        last_window_rect = window_geometry (active_window);
        active_window.geometry_changed.connect_after (handle_geometry_changed);
        active_window.state_changed.connect_after (handle_state_changed);
      }

      schedule_update ();
    }

    [CCode (instance_pos = -1)]
    void handle_state_changed (Wnck.Window window, Wnck.WindowState changed_mask, Wnck.WindowState new_state) {
      if ((changed_mask & Wnck.WindowState.MINIMIZED) == 0)
        return;

      schedule_update ();
    }

    [CCode (instance_pos = -1)]
    void handle_geometry_changed (Wnck.Window window) {
      var geo = window_geometry (window);
      if (geo == last_window_rect)
        return;

      last_window_rect = geo;

      if (geometry_timer_id > 0U)
        return;

      geometry_timer_id = Gdk.threads_add_timeout (UPDATE_TIMEOUT, () => {
        update_window_intersect ();
        geometry_timer_id = 0U;
        return false;
      });
    }

    static Gdk.Rectangle window_geometry (Wnck.Window window) {
      Gdk.Rectangle win_rect = {};
      window.get_geometry (out win_rect.x, out win_rect.y, out win_rect.width, out win_rect.height);
      return win_rect;
    }

    void stop_timers () {
      if (geometry_timer_id > 0U) {
        GLib.Source.remove (geometry_timer_id);
        geometry_timer_id = 0U;
      }

      if (window_changed_timer_id > 0U) {
        GLib.Source.remove (window_changed_timer_id);
        window_changed_timer_id = 0U;
      }

      if (prefs_changed_timer_id > 0U) {
        GLib.Source.remove (prefs_changed_timer_id);
        prefs_changed_timer_id = 0U;
      }

      if (hide_timer_id > 0U) {
        GLib.Source.remove (hide_timer_id);
        hide_timer_id = 0U;
      }

      if (unhide_timer_id > 0U) {
        GLib.Source.remove (unhide_timer_id);
        unhide_timer_id = 0U;
      }

      if (edge_poll_timer_id > 0U) {
        GLib.Source.remove (edge_poll_timer_id);
        edge_poll_timer_id = 0U;
      }

      cancel_pending_reveal ();
    }

#if HAVE_BARRIERS
    void initialize_barriers_support () {
      unowned Gdk.X11.Display? gdk_display = (controller.window.get_display () as Gdk.X11.Display);
      if (gdk_display == null) {
        debug ("Barriers disabled (not an X11 display)");
        barriers_supported = false;
        return;
      }
      unowned X.Display display = gdk_display.get_xdisplay ();
      int error_base, first_event_return;

      gdk_window_remove_filter (null, (Gdk.FilterFunc) xevent_filter);

      if (!display.query_extension ("XInputExtension", out opcode, out first_event_return, out error_base)) {
        debug ("Barriers disabled (XInput needed)");
        barriers_supported = false;
      } else {
        int major = 2, minor = 3;
        var has_xinput = (XInput.query_version (display, ref major, ref minor) == X.Success);
        if (has_xinput && major >= 2 && minor >= 3) {
          message ("Barriers enabled (XInput %i.%i support)\n", major, minor);
          barriers_supported = true;
          gdk_window_add_filter (null, (Gdk.FilterFunc) xevent_filter);

          // A drag-and-drop starts by taking the XdndSelection. GTK lets it
          // go as the drag ends, but an app may keep it once its drag is
          // over, so a button release ends a drag too
          xdnd_selection = Gtk.Clipboard.get_for_display (gdk_display, Gdk.Atom.intern_static_string ("XdndSelection"));
          xdnd_selection.owner_change.connect (xdnd_owner_changed);
        } else {
          debug ("Barriers disabled (XInput %i.%i not sufficient)", major, minor);
          barriers_supported = false;
        }
      }
    }

    [CCode (instance_pos = -1)]
    void xdnd_owner_changed (Gtk.Clipboard clipboard, Gdk.EventOwnerChange event) {
      var live = (event.owner != null);
      if (drag_live == live)
        return;

      drag_live = live;
      if (live)
        Logger.verbose ("HideManager (drag started)");
      else
        Logger.verbose ("HideManager (drag ended)");
    }

    /**
     * Event filter method needed to fetch X.Events
     */
    [CCode (instance_pos = -1)]
    Gdk.FilterReturn xevent_filter (Gdk.XEvent gdk_xevent, Gdk.Event gdk_event) {
      X.Event* xevent = (X.Event*) gdk_xevent;
      X.GenericEventCookie* xcookie = &xevent.xcookie;
      unowned X.Display display = xcookie.display;

      // A drag ends as its button is released, which X reports even while
      // the drag holds the pointer grabbed. Every dock's filter needs to see
      // it, and a wheel's buttons, 4 to 7, can release mid-drag
      if (xcookie.extension == opcode && xcookie.evtype == XInput.EventType.RAW_BUTTON_RELEASE) {
        XInput.RawEvent* raw_event = (XInput.RawEvent*) (xcookie.data);
        if (drag_live && raw_event != null && (raw_event.detail < 4 || raw_event.detail > 7)) {
          drag_live = false;
          Logger.verbose ("HideManager (drag ended)");
        }

        return Gdk.FilterReturn.CONTINUE;
      }

      // Did we got a barrier-event?
      if (barrier == 0
          || (xcookie.extension != opcode)
          || (xcookie.evtype != XInput.EventType.BARRIER_HIT && xcookie.evtype != XInput.EventType.BARRIER_LEAVE))
        return Gdk.FilterReturn.CONTINUE;

      // GDK fetches the event's data before running any filter and frees it
      // afterwards, so it must be left alone here: freeing it would leave
      // the next dock's filter reading nothing
      XInput.BarrierEvent* barrier_event = (XInput.BarrierEvent*) (xcookie.data);
      if (barrier_event == null || barrier_event.barrier != barrier)
        return Gdk.FilterReturn.CONTINUE;

      bool release = false;

      switch (xcookie.evtype) {
      case XInput.EventType.BARRIER_HIT :
        // A grabbed pointer, as when the window manager moves a window or
        // another app drags something, goes straight through uncounted, as
        // GNOME Shell's pressure barriers ignore it: a drag is never held by
        // the dock, and never reveals it, which it would do without the dock
        // ever seeing the drag leave. A drag-and-drop against a hidden dock
        // with a gap counts, though: the dock's window sits off the edge, out
        // of the drag's reach, so nothing else can reveal it, and the edge
        // hold it reveals through ends by itself. The push that reveals it
        // stays held until it leaves the barrier, as any other does, rather
        // than carrying the drag on into a monitor beyond
        if ((barrier_event.flags & XInput.BARRIER_DEVICE_IS_GRABBED) != 0
            && !(drag_live && controller.prefs.GapSize > 0 && (Hidden || pressure_counter.triggered))) {
          release = true;
          break;
        }

        double slide = 0.0, distance = 0.0;
        switch (controller.position_manager.Position) {
        default :
        case Gtk.PositionType.BOTTOM :
        case Gtk.PositionType.TOP :
          distance = Math.fabs (barrier_event.dy);
          slide = Math.fabs (barrier_event.dx);
          break;
        case Gtk.PositionType.LEFT :
        case Gtk.PositionType.RIGHT:
          distance = Math.fabs (barrier_event.dx);
          slide = Math.fabs (barrier_event.dy);
          break;
        }

        if (!pressure_counter.push ((uint32) barrier_event.time, distance, slide)) {
          Logger.verbose ("HideManager (pressure = %f)", pressure_counter.pressure);
          break;
        }

        // Every push needs the full threshold, and a push triggers only once
        // until the pointer leaves the edge. Against a hidden dock it reveals
        // the dock and stays held, so it can't carry the pointer on into a
        // monitor beyond; against a shown dock it goes through. Releasing the
        // pointer ends the barrier's hold on this push, and X reports no more
        // of it
        if (Hidden) {
          Logger.verbose ("HideManager (pressure-threshold reached > unhide (%f))", PRESSURE_THRESHOLD);
          start_pending_reveal ();
        } else {
          Logger.verbose ("HideManager (pressure-threshold reached > release (%f))", PRESSURE_THRESHOLD);
          release = true;
        }
        break;
      case XInput.EventType.BARRIER_LEAVE:
        pressure_counter.leave ();
        break;
      default:
        break;
      }

      if (release) {
        unowned Gdk.X11.Display? gdk_display = Gdk.Display.get_default () as Gdk.X11.Display;
        if (gdk_display != null)
          gdk_display.error_trap_push ();

        XInput.barrier_release_pointer (display, barrier_event.deviceid,
                                        barrier, barrier_event.eventid);

        display.flush ();

        if (gdk_display != null)
          gdk_display.error_trap_pop_ignored ();
      }

      return Gdk.FilterReturn.REMOVE;
    }

    public void update_barrier () {
      if (!barriers_supported || !controller.window.get_realized ())
        return;

      unowned Gdk.X11.Display? gdk_display = (controller.window.get_display () as Gdk.X11.Display);
      if (gdk_display == null)
        return;
      unowned X.Display display = gdk_display.get_xdisplay ();

      if (barrier > 0) {
        gdk_display.error_trap_push ();
        XFixes.destroy_pointer_barrier (display, barrier);
        gdk_display.error_trap_pop_ignored ();
        barrier = 0;

        // The old barrier's leave is filtered out by its id, so start the
        // next barrier with a clean count, never stuck on a trigger
        pressure_counter.leave ();
      }

      if (!controller.prefs.PressureReveal)
        return;

      if (controller.prefs.HideMode == HideType.NONE)
        return;

      var root_xwindow = display.default_root_window ();
      var barrier_area = controller.position_manager.get_barrier ();

      // A dock without items can have no width at all, and the X server
      // rejects a barrier without length
      if (barrier_area.width <= 0 && barrier_area.height <= 0)
        return;

      // Enable barrier events, and the button releases that end a drag
      uchar[] mask_bits = new uchar[XInput.mask_length (XInput.EventType.LASTEVENT)];
      XInput.EventMask mask = { XInput.ALL_MASTER_DEVICES, (int) (sizeof (uchar) * mask_bits.length), (owned) mask_bits };
      XInput.set_mask (mask.mask, XInput.EventType.BARRIER_HIT);
      XInput.set_mask (mask.mask, XInput.EventType.BARRIER_LEAVE);
      XInput.set_mask (mask.mask, XInput.EventType.RAW_BUTTON_RELEASE);
      XInput.select_events (display, root_xwindow, &mask, 1);

      debug ("Barrier: %i,%i - %i,%i\n", barrier_area.x, barrier_area.y, barrier_area.x + barrier_area.width, barrier_area.y + barrier_area.height);

      // The barrier holds only pushes out of the dock's area: into a monitor
      // beyond the edge or, when the dock keeps to the work area, a panel
      // along it. Inward motion passes straight through, so a push from
      // beyond can't reveal the dock while the pointer is outside it
      int directions;
      switch (controller.position_manager.Position) {
      default:
      case Gtk.PositionType.BOTTOM:
        directions = XFixes.BARRIER_NEGATIVE_Y;
        break;
      case Gtk.PositionType.TOP:
        directions = XFixes.BARRIER_POSITIVE_Y;
        break;
      case Gtk.PositionType.LEFT:
        directions = XFixes.BARRIER_POSITIVE_X;
        break;
      case Gtk.PositionType.RIGHT:
        directions = XFixes.BARRIER_NEGATIVE_X;
        break;
      }

      // A barrier the X server rejects must not take the dock down with it
      gdk_display.error_trap_push ();
      barrier = XFixes.create_pointer_barrier (
                                               display, root_xwindow,
                                               barrier_area.x, barrier_area.y, barrier_area.x + barrier_area.width,
                                               barrier_area.y + barrier_area.height,
                                               directions,
                                               0, null);
      gdk_display.error_trap_pop_ignored ();

      warn_if_fail (barrier > 0);
    }

#endif
  }
}
