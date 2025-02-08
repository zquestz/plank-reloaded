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

using Plank;

namespace Docky {
  public class ClockPreferences : DockItemPreferences {
    [Description (nick = "show-military",
                  blurb = "If the clock shows 24hr time (when showing digital and in the hover).")]
    public bool ShowMilitary { get; set; default = false; }

    [Description (nick = "show-digital",
                  blurb = "If the clock shows a digital clock (true) or an analog clock (false).")]
    public bool ShowDigital { get; set; default = false; }

    [Description (nick = "show-date",
                  blurb = "If the clock shows the date in digital mode.")]
    public bool ShowDate { get; set; default = false; }

    public ClockPreferences.with_file (GLib.File file)
    {
      base.with_file (file);
    }

    protected override void reset_properties () {
      ShowMilitary = false;
      ShowDigital = false;
      ShowDate = false;
    }
  }
}
