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
  public class BatteryDockItem : DockletItem {
    private const string BAT_BASE_PATH = "/sys/class/power_supply";
    private const string BAT_CAPACITY = BAT_BASE_PATH + "/%s/capacity";
    private const string BAT_CAPACITY_LEVEL = BAT_BASE_PATH + "/%s/capacity_level";
    private const string BAT_STATUS = BAT_BASE_PATH + "/%s/status";

    private const string ICON_MISSING = "battery-missing";
    private const string NO_BATTERY_TEXT = N_ ("No battery");
    private const uint UPDATE_INTERVAL = 60 * 1000;     // 60 seconds

    private string current_battery = "BAT0";
    private uint timer_id = 0U;

    public BatteryDockItem.with_dockitem_file (GLib.File file)
    {
      GLib.Object (Prefs: new DockItemPreferences.with_file (file));
    }

    construct
    {
      Icon = ICON_MISSING;
      Text = _(NO_BATTERY_TEXT);

      update ();
      timer_id = Gdk.threads_add_timeout (UPDATE_INTERVAL, update);
    }

    ~BatteryDockItem () {
      if (timer_id > 0U) {
        GLib.Source.remove (timer_id);
        timer_id = 0U;
      }
    }

    private int get_capacity () throws GLib.FileError {
      string contents;
      FileUtils.get_contents (BAT_CAPACITY.printf (current_battery), out contents);
      return int.parse (contents);
    }

    private string get_capacity_level () throws GLib.FileError {
      string contents;
      FileUtils.get_contents (BAT_CAPACITY_LEVEL.printf (current_battery), out contents);
      return contents.strip ();
    }

    private string get_status () throws GLib.FileError {
      string contents;
      FileUtils.get_contents (BAT_STATUS.printf (current_battery), out contents);
      return contents.strip ();
    }

    private string get_battery_icon (string capacity_level, string status) {
      string icon = "";

      switch (capacity_level.down ()) {
      case "full":
        icon = "battery-full";
        break;
      case "high":
      case "normal":
        icon = "battery-good";
        break;
      case "low":
        icon = "battery-low";
        break;
      case "critical":
        icon = "battery-caution";
        break;
      case "unknown":
        icon = "battery-empty";
        break;
      default:
        icon = ICON_MISSING;
        break;
      }

      switch (status.down ()) {
      case "charging":
      case "full":
        icon += "-charging";
        break;
      default:
        break;
      }

      return icon;
    }

    private bool update () {
      try {
        var status = get_status ();
        var capacity = get_capacity ();
        var capacity_level = get_capacity_level ();

        Icon = get_battery_icon (capacity_level, status);
        Text = "%i%%".printf (capacity);
      } catch (Error e) {
        warning ("Failed to update battery status: %s", e.message);
        Icon = ICON_MISSING;
        Text = _(NO_BATTERY_TEXT);
      }

      return true;
    }
  }
}
