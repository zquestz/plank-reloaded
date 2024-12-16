//
//  Copyright (C) 2024 Plank Reloaded Developers
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

using Plank;

namespace Docky
{
    public class DesktopDockItem : DockletItem
    {
        private const string ICON_NAME = "show-desktop";
        private const string ICON_RESOURCE = "resource://" + G_RESOURCE_PATH + "/icons/show-desktop.svg";
        private const string ICON_PATH = ICON_NAME + ";;" + ICON_RESOURCE;

        private unowned Wnck.Screen? screen;

        public DesktopDockItem.with_dockitem_file (GLib.File file)
        {
            GLib.Object (Prefs: new DockItemPreferences.with_file (file));
        }

        construct
        {
            initialize_item();
            initialize_wnck();
        }

        ~DesktopDockItem()
        {
            screen = null;
        }

        private void initialize_item()
        {
            Icon = ICON_PATH;
            Text = _("Show Desktop");
        }

        private void initialize_wnck()
        {
            screen = Wnck.Screen.get_default();
        }

        protected override AnimationType on_clicked (PopupButton button,
                                                   Gdk.ModifierType mod,
                                                   uint32 event_time)
        {
            if (button != PopupButton.LEFT)
                return AnimationType.NONE;

            toggle_desktop();
            return AnimationType.BOUNCE;
        }

        private void toggle_desktop()
        {
            if (screen != null) {
                screen.toggle_showing_desktop(!screen.get_showing_desktop());
            }
        }
    }
}
