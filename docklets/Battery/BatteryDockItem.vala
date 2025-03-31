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
    private const string NO_BATTERY_TEXT = _("No battery");
    private const uint UPDATE_INTERVAL = 60 * 1000; // 60 seconds

    private uint timer_id = 0U;

    public BatteryDockItem.with_dockitem_file (GLib.File file)
    {
      GLib.Object (Prefs: new BatteryPreferences.with_file (file));
    }

    construct
    {
      Icon = ICON_MISSING;
      Text = NO_BATTERY_TEXT;

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
      unowned BatteryPreferences prefs = (BatteryPreferences) Prefs;
      FileUtils.get_contents (BAT_CAPACITY.printf (prefs.BatteryDeviceName), out contents);
      return int.parse (contents);
    }

    private string get_capacity_level () throws GLib.FileError {
      string contents;
      unowned BatteryPreferences prefs = (BatteryPreferences) Prefs;
      FileUtils.get_contents (BAT_CAPACITY_LEVEL.printf (prefs.BatteryDeviceName), out contents);
      return contents.strip ();
    }

    private string get_status () throws GLib.FileError {
      string contents;
      unowned BatteryPreferences prefs = (BatteryPreferences) Prefs;
      FileUtils.get_contents (BAT_STATUS.printf (prefs.BatteryDeviceName), out contents);
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
        Text = NO_BATTERY_TEXT;
      }

      return true;
    }

    public override Gee.ArrayList<Gtk.MenuItem> get_menu_items () {
      var items = new Gee.ArrayList<Gtk.MenuItem> ();

      var batteries_menu_item = new Gtk.MenuItem.with_label (_("Batteries"));
      var batteries_submenu = new Gtk.Menu ();
      batteries_menu_item.set_submenu (batteries_submenu);

      try {
        var dir = File.new_for_path (BAT_BASE_PATH);
        var enumerator = dir.enumerate_children ("standard::*", FileQueryInfoFlags.NONE);

        FileInfo info;
        bool batteries_found = false;

        while ((info = enumerator.next_file ()) != null) {
          string battery_name = info.get_name ();

          if (info.get_file_type () != FileType.DIRECTORY) {
            continue;
          }

          if (FileUtils.test (BAT_CAPACITY.printf (battery_name), FileTest.EXISTS) &&
              FileUtils.test (BAT_CAPACITY_LEVEL.printf (battery_name), FileTest.EXISTS) &&
              FileUtils.test (BAT_STATUS.printf (battery_name), FileTest.EXISTS)) {

            batteries_found = true;

            var battery_item = new Gtk.MenuItem.with_label (battery_name);

            battery_item.activate.connect (() => {
              ((BatteryPreferences) Prefs).BatteryDeviceName = battery_name;
              update ();
            });

            if (((BatteryPreferences) Prefs).BatteryDeviceName == battery_name) {
              var label = battery_item.get_child () as Gtk.Label;
              if (label != null) {
                label.set_markup ("<b>" + label.get_text () + "</b>");
              }
            }

            batteries_submenu.append (battery_item);
          }
        }

        if (!batteries_found) {
          var no_batteries_item = new Gtk.MenuItem.with_label (_("No batteries found"));
          no_batteries_item.sensitive = false;
          batteries_submenu.append (no_batteries_item);
        }
      } catch (Error e) {
        warning ("Failed to enumerate batteries: %s", e.message);

        var error_item = new Gtk.MenuItem.with_label (_("Error finding batteries"));
        error_item.sensitive = false;
        batteries_submenu.append (error_item);
      }

      batteries_submenu.show_all ();
      items.add (batteries_menu_item);

      return items;
    }
  }
}
