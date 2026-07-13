//
// Copyright (C) 2025 Plank Reloaded Developers
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
  namespace Helpers {
    /**
     * Truncates a string at the middle to ensure it is no longer than max_length.
     * If the string is truncated, an ellipsis will be inserted in the middle.
     *
     * @param str The string to truncate
     * @param max_length Maximum length for the returned string
     * @return A string not longer than max_length
     */
    public string truncate_middle (string str, int max_length) {
      var char_count = str.char_count ();

      if (char_count <= max_length) {
        return str;
      }

      if (max_length < 5) {
        return str.substring (0, str.index_of_nth_char (max_length));
      }

      int half = (max_length - 1) / 2;
      int left_chars = half;
      int right_chars = max_length - left_chars - 1;

      var left_end = str.index_of_nth_char (left_chars);
      var right_start = str.index_of_nth_char (char_count - right_chars);

      return str.substring (0, left_end) + "…" + str.substring (right_start);
    }

    public static bool current_workspace_only (DefaultApplicationDockItemProvider? provider) {
      bool current_workspace_only = false;

      if (provider != null) {
        current_workspace_only = provider.Prefs.CurrentWorkspaceOnly;
      }

      return current_workspace_only;
    }

    public static bool bring_to_current_workspace (DefaultApplicationDockItemProvider? provider) {
      bool bring_to_current_workspace = false;

      if (provider != null) {
        bring_to_current_workspace = provider.Prefs.BringToCurrentWorkspace;
      }

      return bring_to_current_workspace;
    }

    /**
     * Positions and pops up a docklet-built menu next to its dock item.
     *
     * @param controller The dock the item lives on
     * @param item The dock item to position the menu against
     * @param menu The menu to show
     */
    public static void popup_docklet_menu (DockController controller, DockItem item, Gtk.Menu menu) {
      menu.show_all ();

      Gtk.Requisition requisition;
      menu.get_preferred_size (null, out requisition);

      int x, y;
      controller.position_manager.get_menu_position (item, requisition, out x, out y);

      Gdk.Gravity gravity;
      Gdk.Gravity flipped_gravity;

      switch (controller.position_manager.Position) {
      case Gtk.PositionType.BOTTOM:
        gravity = Gdk.Gravity.NORTH;
        flipped_gravity = Gdk.Gravity.SOUTH;
        break;
      case Gtk.PositionType.TOP:
        gravity = Gdk.Gravity.SOUTH;
        flipped_gravity = Gdk.Gravity.NORTH;
        break;
      case Gtk.PositionType.LEFT:
        gravity = Gdk.Gravity.EAST;
        flipped_gravity = Gdk.Gravity.WEST;
        break;
      case Gtk.PositionType.RIGHT:
        gravity = Gdk.Gravity.WEST;
        flipped_gravity = Gdk.Gravity.EAST;
        break;
      default:
        gravity = Gdk.Gravity.NORTH;
        flipped_gravity = Gdk.Gravity.SOUTH;
        break;
      }

      menu.popup_at_rect (
                          controller.window.get_screen ().get_root_window (),
                          Gdk.Rectangle () {
        x = x,
        y = y,
        width = 1,
        height = 1,
      },
                          gravity,
                          flipped_gravity,
                          null
      );
    }

    public static int window_count (Bamf.Application? app, DefaultApplicationDockItemProvider? provider) {
      int window_count = 0;

      if (app == null) {
        return window_count;
      }

      if (current_workspace_only (provider)) {
        unowned Wnck.Workspace? active_workspace = Wnck.Screen.get_default ().get_active_workspace ();
        if (active_workspace != null)
          window_count = WindowControl.window_on_workspace_count (app, active_workspace);
      } else {
        window_count = WindowControl.window_count (app);
      }

      return window_count;
    }
  }
}
