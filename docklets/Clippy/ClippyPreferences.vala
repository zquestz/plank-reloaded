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

    [Description (nick = "preview-size",
                  blurb = "Size of the previews in the history window: 0 small, 1 medium, 2 large.")]
    public uint PreviewSize { get; set; default = 1; }

    [Description (nick = "persist-history",
                  blurb = "Keep the history in a file so it survives a restart.")]
    public bool PersistHistory { get; set; default = false; }

    [Description (nick = "paste-on-select",
                  blurb = "Paste the chosen entry into the active window right away.")]
    public bool PasteOnSelect { get; set; default = false; }

    [Description (nick = "hotkey-position",
                  blurb = "Where the hotkey opens the history window: 0 at the active window, 1 at the pointer, 2 at the screen centre.")]
    public uint HotkeyPosition { get; set; default = 0; }

    public ClippyPreferences.with_file (GLib.File file)
    {
      base.with_file (file);
    }

    protected override void reset_properties () {
      base.reset_properties ();
      MaxEntries = 15;
      TrackMouseSelections = false;
      TrackImages = true;
      DisableTracking = false;
      PreviewSize = 1;
      PersistHistory = false;
      PasteOnSelect = false;
      HotkeyPosition = 0;
    }
  }
}
