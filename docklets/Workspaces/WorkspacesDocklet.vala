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

/**
 * Initializes the docklet plugin.
 *
 * @param manager The docklet manager
 */
public static void docklet_init (Plank.DockletManager manager) {
  manager.register_docklet (typeof (Docky.WorkspacesDocklet));
}

namespace Docky {
  /**
   * A docklet that provides a graphical workspace switcher.
   */
  public class WorkspacesDocklet : Object, Plank.Docklet {
    private const string ID = "workspaces";
    public const string ICON = "workspace-switcher;;preferences-desktop-workspaces;;xfce4-workspaces;;workspaces";

    /**
     * Returns the unique identifier for this docklet.
     *
     * @return the docklet's ID
     */
    public unowned string get_id () { return ID; }

    /**
     * Returns the display name for this docklet.
     *
     * @return the docklet's name
     */
    public unowned string get_name () { return _("Workspaces"); }

    /**
     * Returns the description of this docklet.
     *
     * @return the docklet's description
     */
    public unowned string get_description () { return _("A graphical workspace switcher."); }

    /**
     * Returns the icon name(s) for this docklet.
     *
     * @return the docklet's icon name(s)
     */
    public unowned string get_icon () { return ICON; }

    /**
     * Checks if workspaces are supported in the current environment.
     *
     * @return true if workspaces are supported, false otherwise
     */
    public bool is_supported () {
      unowned Wnck.Screen screen = Wnck.Screen.get_default ();
      int workspace_count = screen.get_workspace_count ();

      return workspace_count > 0;
    }

    /**
     * Creates a new workspace dock item for this docklet.
     *
     * @param launcher the URI to the launcher file (unused for this docklet)
     * @param file the backing dock item preferences file
     * @return a new workspace dock item instance
     */
    public Plank.DockElement make_element (string launcher, GLib.File file) {
      return new WorkspacesDockItem.with_dockitem_file (file);
    }
  }
}
