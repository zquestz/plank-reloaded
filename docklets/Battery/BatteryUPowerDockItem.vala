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

    public abstract async GLib.ObjectPath get_display_device() throws DBusError, IOError;
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
    private const uint UPDATE_INTERVAL = 20; // seconds

    private IUPower? upower;
    private IUPowerDevice? power_device;
    private Cancellable? dbus_cancellable = null;
    private uint timer_id = 0;
    private uint fallback_idle_id = 0;
    private bool fallback_pending = false;
    private bool removed = false;

    public BatteryUPowerDockItem.with_dockitem_file(GLib.File file)
    {
      GLib.Object(Prefs : new DockItemPreferences.with_file(file));
    }

    construct
    {
      Icon = ICON_MISSING;
      Text = NO_BATTERY_TEXT;

      notify["Container"].connect(handle_container_changed);

      initialize_upower.begin();
    }

    ~BatteryUPowerDockItem() {
      cleanup();
    }

    private void handle_container_changed() {
      if (Container == null) {
        removed_from_dock();
      } else if (fallback_pending) {
        schedule_sysfs_fallback();
      }
    }

    // Teardown must not rely solely on the destructor: the repeating timer
    // holds a reference to this item, so it must be removed when the item
    // leaves its dock or the item can never finalize
    private void removed_from_dock() {
      removed = true;
      cleanup();
    }

    private async void initialize_upower() {
      var cancellable = new Cancellable();
      dbus_cancellable = cancellable;

      try {
        var upower_proxy = yield Bus.get_proxy<IUPower> (
                                                        BusType.SYSTEM,
                                                        UPOWER_NAME,
                                                        UPOWER_PATH,
                                                        DBusProxyFlags.NONE,
                                                        cancellable
        );
        var device = yield get_display_device(upower_proxy, cancellable);

        if (removed || cancellable.is_cancelled()) {
          return;
        }

        upower = upower_proxy;
        power_device = device;

        upower.device_added.connect(on_device_changed);
        upower.device_removed.connect(on_device_changed);

        update();
        timer_id = Timeout.add_seconds(UPDATE_INTERVAL, update);
      } catch (Error e) {
        if (!removed && !(e is IOError.CANCELLED)) {
          debug("UPower not available, falling back to sysfs: %s", e.message);
          schedule_sysfs_fallback();
        }
      } finally {
        if (dbus_cancellable == cancellable) {
          dbus_cancellable = null;
        }
      }
    }

    private void cleanup() {
      dbus_cancellable?.cancel();
      dbus_cancellable = null;

      if (timer_id > 0U) {
        GLib.Source.remove(timer_id);
        timer_id = 0U;
      }

      if (fallback_idle_id > 0U) {
        GLib.Source.remove(fallback_idle_id);
        fallback_idle_id = 0U;
      }

      if (upower != null) {
        upower.device_added.disconnect(on_device_changed);
        upower.device_removed.disconnect(on_device_changed);
        upower = null;
      }

      power_device = null;
    }

    private void on_device_changed(GLib.ObjectPath obj) {
      refresh_display_device.begin();
    }

    private async void refresh_display_device() {
      if (removed || upower == null) {
        return;
      }

      dbus_cancellable?.cancel();
      var cancellable = new Cancellable();
      dbus_cancellable = cancellable;
      IUPower upower_proxy = upower;

      try {
        var device = yield get_display_device(upower_proxy, cancellable);

        if (removed || cancellable.is_cancelled()) {
          return;
        }

        power_device = device;
        update();
      } catch (Error e) {
        if (!removed && !(e is IOError.CANCELLED)) {
          warning("Error getting display device: %s", e.message);
          power_device = null;
          update();
        }
      } finally {
        if (dbus_cancellable == cancellable) {
          dbus_cancellable = null;
        }
      }
    }

    private async IUPowerDevice? get_display_device(IUPower upower_proxy,
                                                     Cancellable cancellable) throws Error {
      var path = yield upower_proxy.get_display_device();
      if (cancellable.is_cancelled()) {
        return null;
      }

      return yield Bus.get_proxy<IUPowerDevice> (
                                                  BusType.SYSTEM,
                                                  UPOWER_NAME,
                                                  path,
                                                  DBusProxyFlags.NONE,
                                                  cancellable
      );
    }

    private void schedule_sysfs_fallback() {
      if (removed) {
        return;
      }

      fallback_pending = true;
      if (fallback_idle_id > 0U) {
        return;
      }

      // Replacement must wait until the item has fully joined its provider
      fallback_idle_id = Idle.add(() => {
        fallback_idle_id = 0U;

        if (removed) {
          return false;
        }

        var container = Container;
        var backing_file = Prefs.get_backing_file();
        if (container == null || backing_file == null) {
          return false;
        }

        var replacement = new BatteryDockItem.with_dockitem_file(backing_file);
        if (container.replace(replacement, this)) {
          fallback_pending = false;
        }

        return false;
      });
    }

    private bool update() {
      if (removed) {
        return false;
      }

      // Keep the poll alive while the device is gone (e.g. upowerd restart);
      // on_device_changed re-resolves it when it comes back
      if (power_device == null) {
        Icon = ICON_MISSING;
        Text = NO_BATTERY_TEXT;
        return true;
      }

      Icon = power_device.icon_name;
      Text = "%i%%".printf((int) power_device.percentage);
      return true;
    }
  }
}
