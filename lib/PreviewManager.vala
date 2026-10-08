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
   * Shows previews of a hovered application's windows in place of its
   * tooltip. The open popup is handled like the dock's menu: the dock stays
   * hovered and keeps its hovered item, so the pointer can cross over to the
   * popup, which closes once the pointer has been away from it, the item and
   * the dock for a moment.
   */
  internal class PreviewManager : GLib.Object {
    // How often the pointer is checked while the popup is open
    const uint POLL_INTERVAL = 100U;
    // How long the pointer may be away before the popup closes
    const uint CLOSE_DELAY = 250U;
    // How long an open popup waits before following the pointer to another
    // item, so sweeping across the dock doesn't open every application
    const uint RETARGET_DELAY = 100U;

    public DockController controller { private get; construct; }

    PreviewWindow popup;

    /**
     * The item whose windows the popup shows, while it is open.
     */
    internal ApplicationDockItem? shown_item { get; private set; default = null; }

    // Where the popup was anchored, and the dock it was anchored to
    int anchor_x;
    int anchor_y;
    Gtk.PositionType shown_position;
    Gdk.Rectangle shown_dock_region;
    Gdk.Rectangle shown_area;

    uint open_timer_id = 0U;
    uint poll_timer_id = 0U;
    int64 away_since = 0;

    // Each window's last thumbnail, at the largest thumbnail's size in
    // device pixels, so windows that can't be captured now still have one
    Gee.HashMap<ulong, Gdk.Pixbuf> thumbnails = new Gee.HashMap<ulong, Gdk.Pixbuf> ();
    int thumbnails_width = 0;
    int thumbnails_height = 0;

    // The windows with tiles still to capture, one per pass of the main loop
    Gee.ArrayList<Bamf.Window> pending_captures = new Gee.ArrayList<Bamf.Window> ();
    uint capture_idle_id = 0U;

    public PreviewManager (DockController controller) {
      GLib.Object (controller : controller);
    }

    construct
    {
      popup = new PreviewWindow ();
      popup.activated.connect (window_activated);
      popup.close_requested.connect (window_close_requested);

      controller.prefs.notify["PreviewsEnabled"].connect (previews_enabled_changed);
      controller.hide_manager.notify["Hidden"].connect (hidden_changed);
      controller.drag_manager.notify["InternalDragActive"].connect (drag_changed);
      controller.drag_manager.notify["ExternalDragActive"].connect (drag_changed);
      unowned Wnck.Screen screen = WindowControl.get_wnck_screen ();
      screen.active_workspace_changed.connect (workspace_changed);
      // Window managers like Compiz switch viewports instead of workspaces
      screen.viewports_changed.connect (workspace_changed);
      screen.window_closed.connect (window_closed);
    }

    ~PreviewManager () {
      popup.activated.disconnect (window_activated);
      popup.close_requested.disconnect (window_close_requested);

      controller.prefs.notify["PreviewsEnabled"].disconnect (previews_enabled_changed);
      controller.hide_manager.notify["Hidden"].disconnect (hidden_changed);
      controller.drag_manager.notify["InternalDragActive"].disconnect (drag_changed);
      controller.drag_manager.notify["ExternalDragActive"].disconnect (drag_changed);
      unowned Wnck.Screen screen = WindowControl.get_wnck_screen ();
      screen.active_workspace_changed.disconnect (workspace_changed);
      screen.viewports_changed.disconnect (workspace_changed);
      screen.window_closed.disconnect (window_closed);

      dismiss ();
      popup.destroy ();
    }

    /**
     * Whether the popup is showing.
     */
    internal bool is_open () {
      return popup.visible;
    }

    /**
     * Follows the dock's hovered item. An item with window previews gets
     * them after the preview delay. While the popup is open, the pointer may
     * just be crossing the dock on its way to the popup, so empty dock space
     * changes nothing, and another item only takes over the popup, or closes
     * it when it has no previews, once the pointer rests on it.
     *
     * @param item the hovered item, if any
     * @return whether the item shows window previews instead of a tooltip
     */
    internal bool hovered_item_changed (DockItem? item) {
      stop_open_timer ();

      // While open, empty dock space and the popup's own item change nothing
      var open = is_open ();
      if (open && (item == null || item == shown_item))
        return (item != null);

      var app_item = (item as ApplicationDockItem);
      var has_previews = (app_item != null && can_show () && !app_item.get_window_list ().is_empty);

      // The _full variants own their closures, which hold the item, rather
      // than letting them be freed when this returns
      if (open) {
        open_timer_id = Gdk.threads_add_timeout_full (GLib.Priority.DEFAULT, RETARGET_DELAY, () => {
          open_timer_id = 0U;

          if (has_previews)
            show (app_item);
          else
            dismiss ();

          return false;
        });

        return has_previews;
      }

      if (!has_previews)
        return false;

      open_timer_id = Gdk.threads_add_timeout_full (GLib.Priority.DEFAULT, controller.prefs.PreviewDelay, () => {
        open_timer_id = 0U;
        show_when_unhidden (app_item);
        return false;
      });

      return true;
    }

    // Shows the popup once the dock has completely unhidden, checking again
    // at the poll interval rather than the preview delay, which may be 0: a
    // timer that is always due would starve the unhiding animation
    void show_when_unhidden (ApplicationDockItem item) {
      if (!controller.hide_manager.Hidden && controller.renderer.hide_progress > 0.0) {
        open_timer_id = Gdk.threads_add_timeout_full (GLib.Priority.DEFAULT, POLL_INTERVAL, () => {
          open_timer_id = 0U;
          show_when_unhidden (item);
          return false;
        });
        return;
      }

      show (item);
    }

    /**
     * Hides the popup and cancels a pending one, leaving the dock's hover to
     * the caller: a click, scroll, menu or drag on the dock, the dock hiding,
     * or a change of its hovered item.
     */
    internal void dismiss () {
      stop_open_timer ();
      stop_captures ();

      if (poll_timer_id > 0U) {
        GLib.Source.remove (poll_timer_id);
        poll_timer_id = 0U;
      }

      shown_item = null;
      popup.clear ();
    }

    // Like dismiss (), but then the dock rechecks whether the pointer still
    // hovers it, as after its menu hides, since the pointer may have left
    // while the popup kept the dock hovered
    void close () {
      var was_open = is_open ();

      dismiss ();

      if (was_open)
        controller.window.recheck_hovered ();
    }

    bool can_show () {
      unowned DragManager drag_manager = controller.drag_manager;

      return (controller.prefs.PreviewsEnabled
              && !drag_manager.InternalDragActive && !drag_manager.ExternalDragActive
              && !controller.window.menu_is_visible ());
    }

    void stop_open_timer () {
      if (open_timer_id > 0U) {
        GLib.Source.remove (open_timer_id);
        open_timer_id = 0U;
      }
    }

    void show (ApplicationDockItem item) {
      // The item may have left the dock while the popup waited
      if (!controller.VisibleItems.contains (item)) {
        close ();
        return;
      }

      // Windows may have closed while the popup waited
      var windows = item.get_window_list ();
      if (windows.is_empty) {
        dismiss ();
        return;
      }

      // A popup moving to another item leaves its captures behind
      stop_captures ();

      unowned PositionManager position_manager = controller.position_manager;
      var monitor = position_manager.get_raw_monitor_geometry ();
      var size = controller.prefs.PreviewSize;
      var scale = popup.get_scale_factor ();

      // Thumbnails are kept at the largest thumbnail's size, so a new size,
      // scale or monitor shape makes the kept ones the wrong size
      var max_width = size * scale;
      var max_height = preview_thumbnail_height (size, monitor) * scale;
      if (max_width != thumbnails_width || max_height != thumbnails_height) {
        thumbnails.clear ();
        thumbnails_width = max_width;
        thumbnails_height = max_height;
      }

      var entries = create_entries (item, windows, scale);

      position_manager.get_hover_position (item, out anchor_x, out anchor_y);
      shown_position = position_manager.Position;
      shown_dock_region = position_manager.get_dock_window_region ();
      shown_area = position_manager.get_monitor_geometry ();

      var shown = popup.show_entries (entries, shown_position, anchor_x, anchor_y, shown_area, monitor, size);

      shown_item = item;
      away_since = 0;

      // Only the windows with tiles are captured, once the popup has shown,
      // and never without compositing
      if (popup.get_screen ().is_composited ()) {
        for (var i = 0; i < shown; i++)
          pending_captures.add (windows[i]);

        capture_idle_id = Gdk.threads_add_idle_full (GLib.Priority.DEFAULT_IDLE, capture_next);
      }

      if (poll_timer_id == 0U)
        poll_timer_id = Gdk.threads_add_timeout (POLL_INTERVAL, poll);
    }

    Gee.ArrayList<PreviewEntry> create_entries (ApplicationDockItem item, Gee.List<Bamf.Window> windows, int scale) {
      var entries = new Gee.ArrayList<PreviewEntry> ();

      // Without compositing, the covered parts of windows hold nothing to
      // show, so every tile gets the icon
      var composited = popup.get_screen ().is_composited ();

      Gdk.Pixbuf? icon = null;

      foreach (var window in windows) {
        var xid = window.get_xid ();

        // A window's last thumbnail shows until it is captured again, if it
        // is on screen
        var thumbnail = (composited ? thumbnails[xid] : null);

        // The item's themed icon, loaded once, is sharper than the windows'
        // own, which Wnck keeps at 32 pixels. An item without a launcher has
        // none, so it gets its application's window icon, as the dock does,
        // at its own size
        if (thumbnail == null && icon == null) {
          unowned Gdk.Pixbuf? app_icon = (item.Icon == "" && item.App != null ? WindowControl.get_app_icon (item.App) : null);
          if (app_icon != null) {
            icon = app_icon;
          } else {
            var icon_size = PreviewWindow.ICON_SIZE * scale;
            icon = DrawingService.load_icon (item.Icon, icon_size, icon_size);
          }
        }

        entries.add (new PreviewEntry (xid, item.shorten_window_name (window.get_name ()),
                                       thumbnail, icon, window.is_active ()));
      }

      return entries;
    }

    // Captures the next window with a tile that is on screen, keeps its
    // thumbnail and puts it on the tile, one window per pass of the main
    // loop so the popup stays responsive
    bool capture_next () {
      unowned Wnck.Workspace? workspace = WindowControl.get_wnck_screen ().get_active_workspace ();

      while (!pending_captures.is_empty) {
        var window = pending_captures.remove_at (0);

        // A window that closed meanwhile is gone from Wnck, which
        // is_on_screen () checks first
        if (!is_on_screen (window, workspace))
          continue;

        var thumbnail = capture (window, thumbnails_width, thumbnails_height);
        if (thumbnail == null)
          continue;

        var xid = window.get_xid ();
        thumbnails[xid] = thumbnail;
        popup.set_thumbnail (xid, thumbnail);
        return true;
      }

      capture_idle_id = 0U;
      return false;
    }

    void stop_captures () {
      if (capture_idle_id > 0U) {
        GLib.Source.remove (capture_idle_id);
        capture_idle_id = 0U;
      }

      pending_captures.clear ();
    }

    // Whether a window is on screen, where its contents can be captured:
    // neither minimized nor shaded, and on the current workspace. Window
    // managers with their own hidden state set it only for minimized
    // windows, so Wnck's HIDDEN doesn't cover shaded ones there
    static bool is_on_screen (Bamf.Window window, Wnck.Workspace? workspace) {
      unowned Wnck.Window? wnck_window = WindowControl.get_wnck_window (window.get_xid ());

      return (wnck_window != null && workspace != null
              && (wnck_window.get_state () & Wnck.WindowState.HIDDEN) == 0
              && !wnck_window.is_shaded ()
              && WindowControl.window_is_on_workspace (wnck_window, workspace));
    }

    static Gdk.Pixbuf? capture (Bamf.Window window, int max_width, int max_height) {
      var thumbnail = WindowControl.get_window_thumbnail (window);

      if (thumbnail != null && (thumbnail.width > max_width || thumbnail.height > max_height))
        thumbnail = DrawingService.ar_scale (thumbnail, max_width, max_height);

      return thumbnail;
    }

    // A window of the shown item as it is listed now, in case it closed
    // meanwhile
    Bamf.Window? find_window (ulong xid) {
      if (shown_item == null)
        return null;

      foreach (var window in shown_item.get_window_list ()) {
        if (window.get_xid () == xid)
          return window;
      }

      return null;
    }

    void window_activated (ulong xid, uint32 event_time) {
      var item = shown_item;
      var target = find_window (xid);

      close ();

      if (item == null || target == null)
        return;

      unowned DefaultApplicationDockItemProvider? provider = (item.Container as DefaultApplicationDockItemProvider);
      WindowControl.focus_window (target, event_time, Helpers.bring_to_current_workspace (provider));
    }

    // Like a click that focuses a window, closing one closes the popup,
    // which doesn't follow changes to the windows while it is open
    void window_close_requested (ulong xid, uint32 event_time) {
      var target = find_window (xid);

      close ();

      if (target != null)
        WindowControl.close_window (target, event_time);
    }

    bool poll () {
      if (!controller.VisibleItems.contains (shown_item) || item_moved ()) {
        poll_timer_id = 0U;
        close ();
        return false;
      }

      if (pointer_in_zone ()) {
        away_since = 0;
        return true;
      }

      var now = GLib.get_monotonic_time ();
      if (away_since == 0) {
        away_since = now;
      } else if (now - away_since >= (int64) CLOSE_DELAY * 1000) {
        poll_timer_id = 0U;
        close ();
        return false;
      }

      return true;
    }

    // Whether the item moved since the popup opened: the dock changed edge,
    // window or area, or the item moved along the dock with its neighbors.
    // Bounces only move items across the dock for a moment, so the item's
    // own position across it doesn't count
    bool item_moved () {
      unowned PositionManager position_manager = controller.position_manager;

      if (position_manager.Position != shown_position
          || position_manager.get_dock_window_region () != shown_dock_region
          || position_manager.get_monitor_geometry () != shown_area)
        return true;

      int x, y;
      position_manager.get_hover_position (shown_item, out x, out y);

      return (position_manager.is_horizontal_dock () ? x != anchor_x : y != anchor_y);
    }

    bool pointer_in_zone () {
      unowned PositionManager position_manager = controller.position_manager;

      int x, y;
      popup.get_display ().get_default_seat ().get_pointer ().get_position (null, out x, out y);

      // The popup's area as it was placed, which needs no query of the
      // window; the item's and the dock's regions are relative to the
      // dock's window
      var window_region = position_manager.get_dock_window_region ();

      var item_region = position_manager.get_hover_region_for_element (shown_item);
      item_region.x += window_region.x;
      item_region.y += window_region.y;

      var dock_region = position_manager.get_cursor_region ();
      dock_region.x += window_region.x;
      dock_region.y += window_region.y;

      return point_in_preview_zone (x, y, popup.shown_region, item_region, dock_region);
    }

    void previews_enabled_changed () {
      if (controller.prefs.PreviewsEnabled)
        return;

      close ();

      // Turning previews off frees the memory their thumbnails took
      thumbnails.clear ();
    }

    void hidden_changed () {
      if (controller.hide_manager.Hidden)
        dismiss ();
    }

    void drag_changed () {
      unowned DragManager drag_manager = controller.drag_manager;

      if (drag_manager.InternalDragActive || drag_manager.ExternalDragActive)
        dismiss ();
    }

    void workspace_changed () {
      close ();
    }

    void window_closed (Wnck.Screen screen, Wnck.Window window) {
      thumbnails.unset (window.get_xid ());
    }
  }
}
