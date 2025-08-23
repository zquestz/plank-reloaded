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

using Plank;

namespace Docky {
  public class TimerDockItem : DockletItem {
    public TimerDockItem.with_dockitem_file(GLib.File file)
    {
      GLib.Object(Prefs: new DockItemPreferences.with_file(file));
    }

    construct
    {
      Icon = "timer-symbolic";
      Text = _("Timer");
    }

    ~TimerDockItem() {
    }

    protected override AnimationType on_clicked(PopupButton button,
                                                Gdk.ModifierType mod,
                                                uint32 event_time) {
      if (button != PopupButton.LEFT)
        return AnimationType.NONE;

      return AnimationType.BOUNCE;
    }
  }
}
