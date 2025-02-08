//
// Copyright (C) 2024 Plank Reloaded Developers
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
  manager.register_docklet (typeof (Docky.DesktopDocklet));
}

namespace Docky {
  public const string G_RESOURCE_PATH = "/net/launchpad/plank/docklets/desktop";

  public class DesktopDocklet : Object, Plank.Docklet {
    private const string ID = "desktop";
    private const string ICON_NAME = "show-desktop";
    private const string ICON_RESOURCE = "resource://" + G_RESOURCE_PATH + "/icons/show-desktop.svg";
    private const string ICON_PATH = ICON_NAME + ";;" + ICON_RESOURCE;

    public unowned string get_id () { return ID; }

    public unowned string get_name () { return _("Desktop"); }

    public unowned string get_description () { return _("Show your Desktop."); }

    public unowned string get_icon () { return ICON_PATH; }

    public bool is_supported () { return true; }

    public Plank.DockElement make_element (string launcher, GLib.File file) {
      return new DesktopDockItem.with_dockitem_file (file);
    }
  }
}
