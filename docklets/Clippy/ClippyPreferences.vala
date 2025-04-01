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
  public class ClippyPreferences : DockItemPreferences {
    [Description (nick = "max-entries", blurb = "How many recent clipboard entries to keep.")]
    public uint MaxEntries { get; set; default = 15; }

    [Description (nick = "track-mouse-selections",
                  blurb = "If it should track the primary (mouse selection) clipboard.")]
    public bool TrackMouseSelections { get; set; default = false; }

    [Description (nick = "track-images",
                  blurb = "Track images in the clipboard.")]
    public bool TrackImages { get; set; default = true; }

    [Description (nick = "disable-tracking",
                  blurb = "Disable clipboard tracking.")]
    public bool DisableTracking { get; set; default = false; }

    public ClippyPreferences.with_file (GLib.File file)
    {
      base.with_file (file);
    }

    protected override void reset_properties () {
      MaxEntries = 15;
      TrackMouseSelections = false;
      TrackImages = true;
      DisableTracking = false;
    }
  }
}
