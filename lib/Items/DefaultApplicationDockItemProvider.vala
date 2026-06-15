//
// Copyright (C) 2013 Rico Tzschichholz
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
   * The default container and controller class for managing application dock items on a dock.
   */
  public class DefaultApplicationDockItemProvider : ApplicationDockItemProvider {
    public DockPreferences Prefs { get; construct; }
    public PositionManager? PositionMgr { get; construct; }

    bool current_workspace_only;

    /**
     * Fills geo with the screen-coordinate geometry of the monitor this dock
     * instance is running on. Returns false (no filtering) when OnlyActiveMonitor
     * is disabled or no PositionManager is available.
     *
     * @param geo output rectangle
     * @return true if monitor filtering is active and a valid geometry is available
     */
    public bool try_get_dock_monitor_geometry (out Gdk.Rectangle geo) {
      if (PositionMgr == null || !Prefs.OnlyActiveMonitor) {
        geo = Gdk.Rectangle ();
        return false;
      }
      return PositionMgr.try_get_dock_monitor_geometry (out geo);
    }

    /**
     * Creates the default container for dock items.
     *
     * @param prefs the preferences of the dock which owns this provider
     * @param position_mgr the PositionManager of the dock (used for per-monitor filtering)
     */
    public DefaultApplicationDockItemProvider (DockPreferences prefs, File launchers_dir, PositionManager? position_mgr = null) {
      Object (Prefs: prefs, LaunchersDir: launchers_dir, PositionMgr: position_mgr);
      Text = "DefaultApplicationDockItemProvider";
    }

    construct
    {
      Prefs.notify["CurrentWorkspaceOnly"].connect (handle_setting_changed);
      Prefs.notify["PinnedOnly"].connect (handle_pinned_only_changed);
      Prefs.notify["OnlyActiveMonitor"].connect (handle_only_active_monitor_changed);

      current_workspace_only = Prefs.CurrentWorkspaceOnly;

      if (current_workspace_only)
        connect_wnck ();

      if (PositionMgr != null) {
        PositionMgr.dock_monitor_changed.connect (handle_dock_monitor_changed);
        if (Prefs.OnlyActiveMonitor)
          connect_geometry_tracking ();
      }
    }

    ~DefaultApplicationDockItemProvider () {
      Prefs.notify["CurrentWorkspaceOnly"].disconnect (handle_setting_changed);
      Prefs.notify["PinnedOnly"].disconnect (handle_pinned_only_changed);
      Prefs.notify["OnlyActiveMonitor"].disconnect (handle_only_active_monitor_changed);

      if (current_workspace_only)
        disconnect_wnck ();

      if (PositionMgr != null) {
        PositionMgr.dock_monitor_changed.disconnect (handle_dock_monitor_changed);
        if (Prefs.OnlyActiveMonitor)
          disconnect_geometry_tracking ();
      }
    }

    void handle_dock_monitor_changed () {
      // Re-evaluate which items are visible and update indicators now that
      // the dock has moved to (or its geometry changed on) a monitor.
      if (Prefs.OnlyActiveMonitor)
        update_visible_elements ();
    }

    void handle_only_active_monitor_changed () {
      if (PositionMgr != null) {
        if (Prefs.OnlyActiveMonitor)
          connect_geometry_tracking ();
        else
          disconnect_geometry_tracking ();
      }
      update_visible_elements ();
    }

    public void trigger_update_visible_elements (bool update_indicator) {
      internal_update_visible_elements (update_indicator);
    }

    protected void internal_update_visible_elements (bool update_indicator) {
      Logger.verbose ("DefaultDockItemProvider.update_visible_items ()");

      Gdk.Rectangle monitor_geo = Gdk.Rectangle ();
      bool has_monitor_filter = try_get_dock_monitor_geometry (out monitor_geo);

      if (Prefs.CurrentWorkspaceOnly) {
        unowned Wnck.Workspace? active_workspace = Wnck.Screen.get_default ().get_active_workspace ();
        foreach (var item in internal_elements) {
          unowned TransientDockItem? transient = (item as TransientDockItem);

          if (transient == null || transient.App == null) {
            // Pinned item (not transient) — always shown
            item.IsAttached = true;
          } else if (active_workspace == null) {
            item.IsAttached = true;
          } else if (has_monitor_filter) {
            // With monitor filtering: only attach if the app has a window on this
            // monitor AND the current workspace
            item.IsAttached = WindowControl.window_on_workspace_and_monitor_count (
              transient.App, active_workspace, monitor_geo) > 0;
          } else {
            item.IsAttached = WindowControl.has_window_on_workspace (transient.App, active_workspace);
          }

          if (update_indicator && item.IsAttached) {
            unowned ApplicationDockItem? app_item = (item as ApplicationDockItem);
            if (app_item != null) {
              app_item.external_update_indicator ();
            }
          }
        }
      } else {
        foreach (var item in internal_elements) {
          unowned TransientDockItem? transient = (item as TransientDockItem);

          if (transient == null || transient.App == null) {
            // Pinned item — always shown
            item.IsAttached = true;
          } else if (has_monitor_filter) {
            // With monitor filtering: only show unpinned (transient) apps that
            // have at least one window on this monitor
            item.IsAttached = WindowControl.has_window_on_monitor (transient.App, monitor_geo);
          } else {
            item.IsAttached = WindowControl.has_window (transient.App);
          }

          if (update_indicator && item.IsAttached) {
            unowned ApplicationDockItem? app_item = (item as ApplicationDockItem);
            if (app_item != null) {
              app_item.external_update_indicator ();
            }
          }
        }
      }

      base.update_visible_elements ();
    }

    protected override void update_visible_elements () {
      internal_update_visible_elements (true);
    }

    /**
     * {@inheritDoc}
     */
    public override void prepare () {
      if (!Prefs.PinnedOnly)
        add_transient_items ();

      var favs = new Gee.ArrayList<string> ();

      foreach (var element in internal_elements) {
        unowned ApplicationDockItem? item = (element as ApplicationDockItem);
        if (item != null && !(item is TransientDockItem))
          favs.add (item.Launcher);
      }

      Matcher.get_default ().set_favorites (favs);
    }

    protected override void app_opened (Bamf.Application app) {
      unowned ApplicationDockItem? found = item_for_application (app);
      if (found != null) {
        found.App = app;
        return;
      }

      if (Prefs.PinnedOnly)
        return;

      // Make sure plank never shows up if we don't want the dock item.
      if (!Prefs.ShowDockItem) {
        string? desktop_file = app.get_desktop_file ();
        if (desktop_file != null && desktop_file.has_suffix ("net.launchpad.plank.desktop")) {
          return;
        }
      }

      var new_item = new TransientDockItem.with_application (app);

      add (new_item);
    }

    void app_closed (DockItem item) {
      if (item is TransientDockItem
          && !(((TransientDockItem) item).has_unity_info ()))
        remove (item);
    }

    void connect_wnck () {
      unowned Wnck.Screen screen = Wnck.Screen.get_default ();

      screen.active_window_changed.connect_after (handle_window_changed);
      screen.active_workspace_changed.connect_after (handle_workspace_changed);
      screen.viewports_changed.connect_after (handle_viewports_changed);
      screen.window_closed.connect_after (handle_window_closed);
    }

    void disconnect_wnck () {
      unowned Wnck.Screen screen = Wnck.Screen.get_default ();

      screen.active_window_changed.disconnect (handle_window_changed);
      screen.active_workspace_changed.disconnect (handle_workspace_changed);
      screen.viewports_changed.disconnect (handle_viewports_changed);
      screen.window_closed.disconnect (handle_window_closed);
    }

    // Window geometry tracking — needed so we react when a window is dragged
    // from one monitor to another, changing whether it should be counted for
    // this dock instance.

    void connect_geometry_tracking () {
      unowned Wnck.Screen screen = Wnck.Screen.get_default ();
      screen.window_opened.connect_after (handle_window_opened_for_geometry);
      screen.window_closed.connect_after (handle_window_closed_for_geometry);
      // Also subscribe to windows already open at startup
      foreach (unowned Wnck.Window w in screen.get_windows ())
        w.geometry_changed.connect_after (handle_window_geometry_changed);
    }

    void disconnect_geometry_tracking () {
      unowned Wnck.Screen screen = Wnck.Screen.get_default ();
      screen.window_opened.disconnect (handle_window_opened_for_geometry);
      screen.window_closed.disconnect (handle_window_closed_for_geometry);
      foreach (unowned Wnck.Window w in screen.get_windows ())
        w.geometry_changed.disconnect (handle_window_geometry_changed);
    }

    [CCode (instance_pos = -1)]
    void handle_window_opened_for_geometry (Wnck.Screen screen, Wnck.Window window) {
      window.geometry_changed.connect_after (handle_window_geometry_changed);
    }

    [CCode (instance_pos = -1)]
    void handle_window_closed_for_geometry (Wnck.Screen screen, Wnck.Window window) {
      window.geometry_changed.disconnect (handle_window_geometry_changed);
    }

    void handle_window_geometry_changed (Wnck.Window window) {
      // A window moved or resized — it may have crossed a monitor boundary.
      update_visible_elements ();
    }

    [CCode (instance_pos = -1)]
    void handle_window_changed (Wnck.Screen screen, Wnck.Window? previous) {
      update_visible_elements ();
    }

    [CCode (instance_pos = -1)]
    void handle_window_closed (Wnck.Screen screen, Wnck.Window? window) {
      update_visible_elements ();
    }

    [CCode (instance_pos = -1)]
    void handle_workspace_changed (Wnck.Screen screen, Wnck.Workspace? previous) {
      unowned Wnck.Workspace? active_workspace = screen.get_active_workspace ();
      if (active_workspace != null && active_workspace.is_virtual ())
        return;

      update_visible_elements ();
    }

    [CCode (instance_pos = -1)]
    void handle_viewports_changed (Wnck.Screen screen) {
      unowned Wnck.Workspace? active_workspace = screen.get_active_workspace ();
      if (active_workspace != null && !active_workspace.is_virtual ())
        return;

      update_visible_elements ();
    }

    void handle_setting_changed () {
      if (current_workspace_only == Prefs.CurrentWorkspaceOnly)
        return;

      current_workspace_only = Prefs.CurrentWorkspaceOnly;

      if (current_workspace_only)
        connect_wnck ();
      else
        disconnect_wnck ();

      update_visible_elements ();
    }

    void handle_pinned_only_changed () {
      if (Prefs.PinnedOnly)
        remove_transient_items ();
      else
        add_transient_items ();
    }

    void add_transient_items () {
      var transient_items = new Gee.ArrayList<DockElement> ();

      // Match running applications to their available dock-items
      foreach (var app in Matcher.get_default ().active_launchers ()) {
        unowned ApplicationDockItem? found = item_for_application (app);
        if (found != null) {
          found.App = app;
          continue;
        }

        transient_items.add (new TransientDockItem.with_application (app));
      }

      add_all (transient_items);
    }

    void remove_transient_items () {
      var transient_items = new Gee.ArrayList<DockElement> ();

      foreach (var element in internal_elements) {
        if (element is TransientDockItem)
          transient_items.add (element);
      }

      remove_all (transient_items);
    }

    protected override void connect_element (DockElement element) {
      base.connect_element (element);

      unowned ApplicationDockItem? appitem = (element as ApplicationDockItem);
      if (appitem != null) {
        appitem.app_closed.connect (app_closed);
        appitem.pin_launcher.connect (pin_item);
      }
    }

    protected override void disconnect_element (DockElement element) {
      base.disconnect_element (element);

      unowned ApplicationDockItem? appitem = (element as ApplicationDockItem);
      if (appitem != null) {
        appitem.app_closed.disconnect (app_closed);
        appitem.pin_launcher.disconnect (pin_item);
      }
    }

    protected override void handle_item_deleted (DockItem item) {
      unowned Bamf.Application? app = null;
      if (item is ApplicationDockItem)
        app = ((ApplicationDockItem) item).App;

      if (app == null || !app.is_running () || Prefs.PinnedOnly) {
        remove (item);
        return;
      }

      var new_item = new TransientDockItem.with_application (app);
      item.copy_values_to (new_item);

      replace (new_item, item);
    }

    public void pin_item (DockItem item) {
      if (!internal_elements.contains (item)) {
        critical ("Item '%s' does not exist in this DockItemProvider.", item.Text);
        return;
      }

      Logger.verbose ("DefaultDockItemProvider.pin_item ('%s[%s]')", item.Text, item.DockItemFilename);

      unowned ApplicationDockItem? app_item = (item as ApplicationDockItem);
      if (app_item == null)
        return;

      // delay automatic add of new dockitems while creating this new one
      delay_items_monitor ();

      if (item is TransientDockItem) {
        var dockitem_file = Factory.item_factory.make_dock_item (item.Launcher, LaunchersDir);
        if (dockitem_file == null)
          return;

        var new_item = new ApplicationDockItem.with_dockitem_file (dockitem_file);
        item.copy_values_to (new_item);

        replace (new_item, item);
      } else {
        if (!(app_item.is_running () || app_item.has_unity_info ()))
          remove (item);
        item.delete ();
      }

      resume_items_monitor ();
    }
  }
}
