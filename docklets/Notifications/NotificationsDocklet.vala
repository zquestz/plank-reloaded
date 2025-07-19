//
// Copyright (C) 2025 Plank Reloaded Developers
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

public static void docklet_init (Plank.DockletManager manager) {
  manager.register_docklet (typeof (Docky.NotificationsDocklet));
}

namespace Docky {
  public class NotificationsDocklet : Object, Plank.Docklet {
    private const string ID = "notifications";
    public const string ICON = "notifications;;cs-notifications;;org.kde.plasma.notifications;;indicator-notification-read;;ayatana-indicator-notification-read";

    public unowned string get_id () { return ID; }
    public unowned string get_name () { return _("Notifications"); }
    public unowned string get_description () { return _("Simple notifications docklet."); }
    public unowned string get_icon () { return ICON; }

    public bool is_supported () { return true; }

    public Plank.DockElement make_element (string launcher, GLib.File file) {
      return new NotificationsDockItem.with_dockitem_file (file);
    }
  }
}
