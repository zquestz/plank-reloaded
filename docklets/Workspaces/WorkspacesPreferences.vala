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
  public class WorkspacesPreferences : DockItemPreferences {
    [Description (nick = "invert-color",
                  blurb = "Inverts the color of the workspace switcher")]
    public bool InvertColor { get; set; default = false; }

    [Description (nick = "live-previews",
                  blurb = "Enable live workspace previews")]
    public bool LivePreviews { get; set; default = true; }

    public WorkspacesPreferences.with_file (GLib.File file)
    {
      base.with_file (file);
    }

    protected override void reset_properties () {
      InvertColor = false;
    }
  }
}
