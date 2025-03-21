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
  [DBus(name = "org.freedesktop.UPower")]
  private interface IUPower : GLib.DBusProxy {
    public abstract signal void device_added(GLib.ObjectPath obj);
    public abstract signal void device_removed(GLib.ObjectPath obj);

    public abstract GLib.ObjectPath get_display_device() throws DBusError, IOError;
  }

  [DBus(name = "org.freedesktop.UPower.Device")]
  private interface IUPowerDevice : GLib.DBusProxy {
    [DBus(name = "Percentage")]
    public abstract double percentage { owned get; }

    [DBus(name = "IconName")]
    public abstract string icon_name { owned get; }
  }

  public class BatteryUPowerDockItem : DockletItem {
    private const string UPOWER_NAME = "org.freedesktop.UPower";
    private const string UPOWER_PATH = "/org/freedesktop/UPower";
    private const string ICON_MISSING = "battery-missing";
    private const string NO_BATTERY_TEXT = _("No battery");
    private const uint UPDATE_INTERVAL = 20 * 1000; // 20 seconds

    private IUPower? upower;
    private IUPowerDevice? power_device;
    private uint timer_id;

    public static bool is_supported {
      get {
        return DBus.is_interface_name(UPOWER_NAME);
      }
    }

    public BatteryUPowerDockItem.with_dockitem_file(GLib.File file)
    {
      GLib.Object(Prefs : new DockItemPreferences.with_file(file));
    }

    construct
    {
      Icon = ICON_MISSING;
      Text = NO_BATTERY_TEXT;

      initialize_upower();
    }

    ~BatteryUPowerDockItem() {
      cleanup();
    }

    private void initialize_upower() {
      try {
        upower = Bus.get_proxy_sync(BusType.SYSTEM, UPOWER_NAME, UPOWER_PATH);

        upower.device_added.connect(on_device_changed);
        upower.device_removed.connect(on_device_changed);

        power_device = get_display_device();

        if (power_device != null) {
          update();
          timer_id = Gdk.threads_add_timeout(UPDATE_INTERVAL, update);
        }
      } catch (Error e) {
        warning("Cannot initialize battery docklet: %s", e.message);
        cleanup();
      }
    }

    private void cleanup() {
      if (timer_id > 0U) {
        GLib.Source.remove(timer_id);
        timer_id = 0U;
      }

      if (upower != null) {
        upower.device_added.disconnect(on_device_changed);
        upower.device_removed.disconnect(on_device_changed);
        upower = null;
      }

      power_device = null;
    }

    private void on_device_changed(GLib.ObjectPath obj) {
      power_device = get_display_device();
      update();
    }

    private IUPowerDevice ? get_display_device() {
      try {
        var path = upower.get_display_device();
        return Bus.get_proxy_sync(BusType.SYSTEM, UPOWER_NAME, path);
      } catch (Error e) {
        warning("Error getting display device: %s", e.message);
        return null;
      }
    }

    private bool update() {
      if (power_device == null) {
        warning("Battery docklet not initialized");
        Icon = ICON_MISSING;
        Text = NO_BATTERY_TEXT;
        return false;
      }

      Icon = power_device.icon_name;
      Text = "%i%%".printf((int) power_device.percentage);
      return true;
    }
  }
}
