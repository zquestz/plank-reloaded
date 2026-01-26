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
  public class NotificationData {
    public uint32 id { get; set; }
    public string app_name { get; set; }
    public string app_icon { get; set; }
    public string image_path { get; set; default = ""; }
    public ImageData? image_data { get; set; default = null; }
    public ImageData? icon_data { get; set; default = null; }
    public string desktop_entry { get; set; default = ""; }
    public string summary { get; set; }
    public string body { get; set; }
    public string[] actions { get; set; }
    public GLib.HashTable<string, GLib.Variant> hints { get; set; }
    public int expire_timeout { get; set; }
    public DateTime timestamp { get; set; }
    public uint8 urgency { get; set; default = 1; }
    public string category { get; set; default = ""; }
    public bool transient { get; set; default = false; }
    public bool resident { get; set; default = false; }
    public uint32 serial { get; set; }
    public bool id_assigned { get; set; default = false; }
    public string sender { get; set; default = ""; }
    private uint expiry_timer_id = 0;
    private weak NotificationsDockItem? parent_dock_item = null;

    public NotificationData(uint32 id, string app_name, string app_icon, string summary, string body, string[] actions, GLib.HashTable<string, GLib.Variant> hints, int expire_timeout, uint32 serial, string sender) {
      this.id = id;
      this.app_name = app_name;
      this.app_icon = app_icon;
      this.summary = summary;
      this.body = body;
      this.actions = actions;
      this.hints = hints;
      this.expire_timeout = expire_timeout;
      this.serial = serial;
      this.timestamp = new DateTime.now_local();
      this.sender = sender;

      parse_hints();
    }

    public void setup_expiry_timer(NotificationsDockItem dock_item) {
      if (expire_timeout <= 0) {
        return;
      }

      if (expiry_timer_id > 0) {
        return;
      }

      parent_dock_item = dock_item;

      var age = new DateTime.now_local().difference(timestamp);
      var total_timeout = expire_timeout * TimeSpan.MILLISECOND;
      var remaining = total_timeout - age;

      if (remaining <= 0) {
        parent_dock_item?.notification_expired(this);

        return;
      }

      var safe_timeout = (uint) ((remaining / TimeSpan.MILLISECOND) + 50);
      if (safe_timeout > uint.MAX - 1000) {
        safe_timeout = uint.MAX - 1000;
      }

      expiry_timer_id = GLib.Timeout.add(safe_timeout, () => {
        expiry_timer_id = 0;

        parent_dock_item?.notification_expired(this);

        return false;
      });
    }

    public void cancel_expiry_timer() {
      if (expiry_timer_id > 0) {
        Source.remove(expiry_timer_id);
        expiry_timer_id = 0;
      }
    }

    ~NotificationData() {
      cancel_expiry_timer();

      if (image_data != null) {
        image_data.data = null;
        image_data = null;
      }
      if (icon_data != null) {
        icon_data.data = null;
        icon_data = null;
      }
    }

    public bool is_expired() {
      if (expire_timeout <= 0) {
        return false;
      }

      var age = new DateTime.now_local().difference(timestamp);
      return age > (expire_timeout * TimeSpan.MILLISECOND);
    }

    private void parse_hints() {
      if (hints == null) {
        return;
      }

      var urgency_variant = hints.lookup("urgency");
      if (urgency_variant != null) {
        urgency = urgency_variant.get_byte();
      }

      var category_variant = hints.lookup("category");
      if (category_variant != null) {
        category = category_variant.get_string();
      }

      var transient_variant = hints.lookup("transient");
      if (transient_variant != null) {
        transient = transient_variant.get_boolean();
      }

      var resident_variant = hints.lookup("resident");
      if (resident_variant != null) {
        resident = resident_variant.get_boolean();
      }

      var image_data_variant = hints.lookup("image-data");
      if (image_data_variant != null) {
        image_data = parse_image_data(image_data_variant);
      }

      var image_path_variant = hints.lookup("image-path");
      if (image_path_variant != null) {
        image_path = image_path_variant.get_string();
      }

      var icon_data_variant = hints.lookup("icon_data");
      if (icon_data_variant != null) {
        icon_data = parse_image_data(icon_data_variant);
      }

      var desktop_entry_variant = hints.lookup("desktop-entry");
      if (desktop_entry_variant != null) {
        desktop_entry = desktop_entry_variant.get_string();
      }
    }

    private ImageData ? parse_image_data(Variant variant) {
      if (!variant.is_of_type(new VariantType("(iiibiiay)"))) {
        warning("Invalid image data format");
        return null;
      }

      int width = variant.get_child_value(0).get_int32();
      int height = variant.get_child_value(1).get_int32();
      int rowstride = variant.get_child_value(2).get_int32();
      bool has_alpha = variant.get_child_value(3).get_boolean();
      int bits_per_sample = variant.get_child_value(4).get_int32();
      int channels = variant.get_child_value(5).get_int32();

      var data_variant = variant.get_child_value(6);

      size_t array_size = data_variant.n_children();
      uint8[] data = new uint8[array_size];

      for (size_t i = 0; i < array_size; i++) {
        data[i] = data_variant.get_child_value(i).get_byte();
      }

      if (bits_per_sample != 8) {
        warning("Unsupported bits_per_sample: %d", bits_per_sample);
        return null;
      }

      if (has_alpha && channels != 4) {
        warning("Invalid channels for alpha image: %d", channels);
        return null;
      }

      if (!has_alpha && channels != 3) {
        warning("Invalid channels for RGB image: %d", channels);
        return null;
      }

      if (data.length < height * rowstride) {
        warning("Image data too small: %d bytes, expected %d",
                data.length, height * rowstride);
        return null;
      }

      return new ImageData(width, height, rowstride, has_alpha,
                           bits_per_sample, channels, data);
    }
  }

  public class ImageData {
    public int width { get; set; }
    public int height { get; set; }
    public int rowstride { get; set; }
    public bool has_alpha { get; set; }
    public int bits_per_sample { get; set; }
    public int channels { get; set; }
    public uint8[] data { get; set; }

    public ImageData(int width, int height, int rowstride, bool has_alpha,
      int bits_per_sample, int channels, uint8[] data) {
      this.width = width;
      this.height = height;
      this.rowstride = rowstride;
      this.has_alpha = has_alpha;
      this.bits_per_sample = bits_per_sample;
      this.channels = channels;
      this.data = data;
    }
  }

  public class NotificationsDockItem : DockletItem {
    private NotificationsPreferences prefs {
      get { return (NotificationsPreferences) Prefs; }
    }

    private GLib.List<NotificationData> notifications;
    private DBusConnection? monitor_connection;
    private DBusConnection? send_connection;
    private uint message_filter_id = 0;
    private uint update_timer_id = 0;
    private bool close_notification_supported = true;
    private static Object notification_lock = new Object();
    private static string base_icon = NotificationsDocklet.ICON;
    private Bamf.Matcher bamf_matcher = Bamf.Matcher.get_default();

    private const int ICON_SIZE = 32;
    private const int IMAGE_SIZE = 128;

    public NotificationsDockItem.with_dockitem_file(GLib.File file) {
      GLib.Object(Prefs : new NotificationsPreferences.with_file(file));
    }

    construct {
      Icon = base_icon;
      Text = _("Notifications");
      notifications = new GLib.List<NotificationData> ();

      setup_dbus_monitoring();
      update_display();
    }

    ~NotificationsDockItem() {
      cleanup_dbus_monitoring();

      if (update_timer_id > 0) {
        Source.remove(update_timer_id);
        update_timer_id = 0;
      }
    }

    private void setup_dbus_monitoring() {
      try {
        var address = Environment.get_variable("DBUS_SESSION_BUS_ADDRESS");
        if (address == null) {
          warning("DBUS_SESSION_BUS_ADDRESS not set");
          return;
        }

        monitor_connection = new DBusConnection.for_address_sync(
                                                                 address,
                                                                 DBusConnectionFlags.AUTHENTICATION_CLIENT | DBusConnectionFlags.MESSAGE_BUS_CONNECTION,
                                                                 null,
                                                                 null
        );

        send_connection = new DBusConnection.for_address_sync(
                                                              address,
                                                              DBusConnectionFlags.AUTHENTICATION_CLIENT | DBusConnectionFlags.MESSAGE_BUS_CONNECTION,
                                                              null,
                                                              null
        );

        monitor_connection.on_closed.connect((closed) => {
          warning("D-Bus monitor connection closed: %s", closed.to_string());
        });

        send_connection.on_closed.connect((closed) => {
          warning("D-Bus send connection closed: %s", closed.to_string());
        });

        string[] match_rules = {
          "type=method_call,interface=org.freedesktop.Notifications,member=Notify",
          "type=method_return,sender=org.freedesktop.Notifications",
          "type=signal,interface=org.freedesktop.Notifications,member=NotificationClosed"
        };

        var rules_variant = new Variant.strv(match_rules);
        var flags_variant = new Variant.uint32(0);
        var parameters = new Variant.tuple({ rules_variant, flags_variant });

        monitor_connection.call_sync(
                                     "org.freedesktop.DBus",
                                     "/org/freedesktop/DBus",
                                     "org.freedesktop.DBus.Monitoring",
                                     "BecomeMonitor",
                                     parameters,
                                     null,
                                     DBusCallFlags.NONE,
                                     -1,
                                     null
        );

        message_filter_id = monitor_connection.add_filter(dbus_message_filter);
      } catch (Error e) {
        warning("Failed to setup D-Bus monitoring: %s", e.message);
      }
    }

    private void cleanup_dbus_monitoring() {
      if (monitor_connection != null && message_filter_id > 0) {
        monitor_connection.remove_filter(message_filter_id);
        message_filter_id = 0;
      }
      if (send_connection != null) {
        try {
          send_connection.close_sync();
        } catch (Error e) {}
        send_connection = null;
      }
      if (monitor_connection != null) {
        try {
          monitor_connection.close_sync();
        } catch (Error e) {}
        monitor_connection = null;
      }
    }

    private DBusMessage ? dbus_message_filter(DBusConnection conn, owned DBusMessage message, bool incoming) {
      if (incoming) {
        if (message.get_message_type() == DBusMessageType.METHOD_CALL &&
            message.get_member() == "Notify") {
          parse_notification_message(message);
        } else if (message.get_message_type() == DBusMessageType.SIGNAL &&
                   message.get_member() == "NotificationClosed") {
          parse_notification_closed_signal(message);
        } else if (message.get_message_type() == DBusMessageType.METHOD_RETURN) {
          parse_notification_response(message);
        }
      }

      return null;
    }

    private void parse_notification_closed_signal(owned GLib.DBusMessage message) {
      var body = message.get_body();
      if (body == null) {
        return;
      }

      var id = body.get_child_value(0).get_uint32();
      remove_notification(id);
    }

    private void parse_notification_response(owned GLib.DBusMessage message) {
      var body = message.get_body();
      if (body == null || body.n_children() != 1) {
        return;
      }

      var first_child = body.get_child_value(0);
      if (!first_child.is_of_type(VariantType.UINT32)) {
        return;
      }

      var notification_id = first_child.get_uint32();
      var reply_serial = message.get_reply_serial();
      var destination = message.get_destination();

      lock (notification_lock) {
        notifications.foreach((notification) => {
          if (notification == null || notification.id_assigned) { return; }

          if (notification.sender == destination && notification.serial == reply_serial) {
            notification.id = notification_id;
            notification.id_assigned = true;
          }
        });

        update_display();
      }
    }

    private void parse_notification_message(owned GLib.DBusMessage message) {
      var body = message.get_body();
      if (body == null) {
        return;
      }

      var app_name = body.get_child_value(0).get_string();
      var replaces_id = body.get_child_value(1).get_uint32();
      var app_icon = body.get_child_value(2).get_string();
      var summary = body.get_child_value(3).get_string();
      var notification_body = body.get_child_value(4).get_string();
      var actions = body.get_child_value(5).get_strv();
      var hints = new GLib.HashTable<string,GLib.Variant> (str_hash,str_equal);
      var serial = message.get_serial();
      var sender = message.get_sender();

      var hints_variant = body.get_child_value(6);
      if (hints_variant.get_type_string() == "a{sv}") {
        for (size_t i = 0; i < hints_variant.n_children(); i++) {
          var child = hints_variant.get_child_value(i);
          if (child.get_type_string() == "{sv}") {
            var key = child.get_child_value(0).get_string();
            var value = child.get_child_value(1).get_variant();
            hints.insert(key,value);
          }
        }
      } else {
        warning("Unexpected hints type: %s",hints_variant.get_type_string());
      }

      var expire_timeout = body.get_child_value(7).get_int32();

      var id = replaces_id > 0 ? replaces_id : 0;

      add_notification(
                       id,
                       app_name,
                       app_icon,
                       summary,
                       notification_body,
                       actions,
                       hints,
                       expire_timeout,
                       serial,
                       sender);
    }

    public void notification_expired(NotificationData notification) {
      if (!prefs.EnableExpiry) {
        return;
      }

      lock (notification_lock) {
        notifications.remove(notification);
        update_display();
      }
    }

    private void add_notification(uint32 id,string app_name,string app_icon,string summary,string body,string[] actions,GLib.HashTable<string,GLib.Variant> hints,int expire_timeout,uint32 serial,string sender) {
      lock (notification_lock) {
        remove_notification(id);

        var notification = new NotificationData(id,app_name,app_icon,summary,body,actions,hints,expire_timeout,serial,sender);

        if (notification.transient && !prefs.ShowTransient) {
          return;
        }

        notifications.append(notification);

        if (prefs.EnableExpiry) {
          notification.setup_expiry_timer(this);
        }

        update_display();
      }
    }

    private void remove_notification(uint32 id,bool send_close = false) {
      lock (notification_lock) {
        if (id == 0) {
          return;
        }

        NotificationData? to_remove = null;

        notifications.foreach((notification) => {
          if (notification == null) { return; }

          if (notification.id == id) {
            to_remove = notification;
          }
        });

        if (to_remove != null) {
          to_remove.cancel_expiry_timer();
          notifications.remove(to_remove);
          update_display();

          if (send_close) {
            close_notification(to_remove.id,2);
          }
        }
      }
    }

    private void close_notification(uint32 notification_id,uint32 reason) {
      if (!close_notification_supported) {
        return;
      }

      if (notification_id == 0) {
        return;
      }

      if (send_connection == null || send_connection.is_closed()) {
        warning("No D-Bus connection for closing notification");
        return;
      }

      send_connection.call.begin(
                                 "org.freedesktop.Notifications",
                                 "/org/freedesktop/Notifications",
                                 "org.freedesktop.Notifications",
                                 "CloseNotification",
                                 new Variant.tuple({
        new Variant.uint32(notification_id)
      }),
                                 null,
                                 DBusCallFlags.NONE,
                                 5000,
                                 null,
                                 (obj,res) => {
        try {
          send_connection.call.end(res);
        } catch (Error e) {
          if (e is DBusError.UNKNOWN_METHOD) {
            close_notification_supported = false;
            debug("Daemon doesn't support CloseNotification: %s",e.message);
          } else if (e is DBusError.TIMEOUT) {
            debug("Timeout closing notification %u",notification_id);
          } else {
            warning("Failed to close notification %u: %s",notification_id,e.message);
          }
        }
      });
    }

    private void clear_all_notifications() {
      var snapshot = new GLib.List<NotificationData> ();

      lock (notification_lock) {
        notifications.foreach((n) => {
          n.cancel_expiry_timer();
          snapshot.append(n);
        });

        notifications = new GLib.List<NotificationData> ();
        update_display();
      }

      snapshot.foreach((notification) => {
        if (notification.id_assigned) {
          close_notification(notification.id,2);
        }
      });
    }

    private void update_display() {
      if (update_timer_id > 0) {
        Source.remove(update_timer_id);
        update_timer_id = 0;
      }

      update_timer_id = GLib.Timeout.add(100,() => {
        update_timer_id = 0;

        do_update_display();

        return false;
      });
    }

    private void do_update_display() {
      uint count;
      lock (notification_lock) {
        count = notifications.length();
      }

      if (Count != count) {
        Count = (int) count;
      }

      bool count_visible = prefs.ShowCount && count > 0;
      if (CountVisible != count_visible) {
        CountVisible = count_visible;
      }

      string icon;
      if (count == 0) {
        icon = "notification-inactive;;notification-symbolic;;indicator-notification-read;;ayatana-indicator-notification-read;;" + base_icon;
      } else {
        icon = "notification-active;;notification-new-symbolic;;indicator-notification-unread;;ayatana-indicator-notification-unread;;" + base_icon;
      }

      if (Icon != icon) {
        Icon = icon;
      }
    }

    private void update_transient_items() {
      if (prefs.ShowTransient) {
        update_display();
      } else {
        lock (notification_lock) {
          var to_remove = new GLib.List<NotificationData> ();

          notifications.foreach((notification) => {
            if (notification == null || !notification.transient) { return; }

            to_remove.append(notification);
          });

          to_remove.foreach((notification) => {
            notifications.remove(notification);
          });
        }
      }
    }

    protected override AnimationType on_clicked(PopupButton button,Gdk.ModifierType mod,uint32 event_time) {
      if (button == PopupButton.LEFT) {
        bool has_notifications;
        lock (notification_lock) {
          has_notifications = notifications.length() > 0;
        }

        if (has_notifications) {
          show_notifications_menu(event_time);
          return AnimationType.NONE;
        } else {
          return AnimationType.BOUNCE;
        }
      }
      return AnimationType.NONE;
    }

    private void on_menu_show() {
      DockController? controller = get_dock();
      if (controller == null) {
        return;
      }

      controller.window.update_hovered(0,0);
      controller.renderer.animated_draw();
    }

    private void on_menu_hide() {
      DockController? controller = get_dock();
      if (controller == null) {
        return;
      }

      controller.renderer.animated_draw();

      controller.hide_manager.update_hovered();
      if (!controller.hide_manager.Hovered) {
        controller.window.update_hovered(0,0);
      }
    }

    private void show_notifications_menu(uint32 event_time) {
      DockController? controller = get_dock();
      if (controller == null) {
        return;
      }

      var menu = new Gtk.Menu();
      menu.show.connect(on_menu_show);
      menu.hide.connect(on_menu_hide);

      menu.reserve_toggle_size = false;

      var snapshot = new GLib.List<NotificationData> ();
      lock (notification_lock) {
        notifications.foreach((n) => snapshot.append(n));
      }

      snapshot.foreach((notification) => {
        var item = create_notification_menu_item(notification);
        menu.append(item);
      });

      menu.show_all();

      Gtk.Requisition requisition;
      menu.get_preferred_size(null,out requisition);

      int x,y;
      controller.position_manager.get_menu_position(this,requisition,out x,out y);

      Gdk.Gravity gravity;
      Gdk.Gravity flipped_gravity;

      switch (controller.position_manager.Position) {
      case Gtk.PositionType.BOTTOM :
        gravity = Gdk.Gravity.NORTH;
        flipped_gravity = Gdk.Gravity.SOUTH;
        break;
      case Gtk.PositionType.TOP :
        gravity = Gdk.Gravity.SOUTH;
        flipped_gravity = Gdk.Gravity.NORTH;
        break;
      case Gtk.PositionType.LEFT :
        gravity = Gdk.Gravity.EAST;
        flipped_gravity = Gdk.Gravity.WEST;
        break;
      case Gtk.PositionType.RIGHT :
        gravity = Gdk.Gravity.WEST;
        flipped_gravity = Gdk.Gravity.EAST;
        break;
        default :
        gravity = Gdk.Gravity.NORTH;
        flipped_gravity = Gdk.Gravity.SOUTH;
        break;
      }

      menu.popup_at_rect(
                         controller.window.get_screen().get_root_window(),
                         Gdk.Rectangle() {
        x = x,
        y = y,
        width = 1,
        height = 1,
      },
                         gravity,
                         flipped_gravity,
                         null
      );
    }

    private Gtk.MenuItem create_notification_menu_item(NotificationData notification) {
      var item = new Gtk.MenuItem();

      var hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL,8);
      hbox.margin = 6;
      hbox.width_request = 200;

      var icon = create_notification_icon(notification);
      icon.halign = Gtk.Align.START;
      icon.valign = Gtk.Align.START;
      icon.margin_end = 6;

      hbox.pack_start(icon,false,false,0);

      var vbox = new Gtk.Box(Gtk.Orientation.VERTICAL,2);
      var header_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,0);

      var stripped_name = notification.app_name.strip();
      if (stripped_name.length > 0) {
        var app_label = new Gtk.Label(stripped_name);
        app_label.get_style_context().add_class("app-name");
        app_label.set_markup("<small><b>%s</b></small>".printf(GLib.Markup.escape_text(stripped_name)));
        app_label.margin_bottom = 10;
        app_label.margin_end = 6;
        header_box.pack_start(app_label, false, false, 0);
      }

      var time_label = new Gtk.Label(format_timestamp(notification.timestamp));
      time_label.get_style_context().add_class("timestamp");
      var markup_text = GLib.Markup.escape_text(format_timestamp(notification.timestamp));
      time_label.set_markup("<small>%s</small>".printf(markup_text));
      time_label.margin_bottom = 10;
      if (stripped_name.length > 0) {
        time_label.margin_start = 10;
        header_box.pack_end(time_label, false, false, 0);
      } else {
        header_box.pack_start(time_label, false, false, 0);
      }

      vbox.pack_start(header_box, false, false, 0);

      var stripped_summary = notification.summary.strip();
      var summary_label = new Gtk.Label(stripped_summary);
      summary_label.set_markup("<b>%s</b>".printf(GLib.Markup.escape_text(stripped_summary)));
      summary_label.set_line_wrap(true);
      summary_label.set_max_width_chars(50);
      summary_label.set_alignment(0, 0);
      vbox.pack_start(summary_label, false, false, 0);

      var stripped_body = notification.body.strip();
      if (stripped_body.length > 0) {
        var body_label = new Gtk.Label(stripped_body);
        body_label.set_markup(stripped_body);
        body_label.set_line_wrap(true);
        body_label.set_max_width_chars(50);
        body_label.set_alignment(0, 0);
        body_label.get_style_context().add_class("body-text");
        body_label.margin_top = 10;
        vbox.pack_start(body_label, false, false, 0);
      }

      hbox.pack_start(vbox, true, true, 0);

      item.add(hbox);

      item.activate.connect((event) => {
        remove_notification(notification.id, true);
      });

      return item;
    }

    private Gdk.Pixbuf? load_image_from_path(string path, int size) {
      if (!Path.is_absolute(path) || !FileUtils.test(path, FileTest.EXISTS)) {
        return null;
      }

      try {
        var file = File.new_for_path(path);
        var info = file.query_info("standard::content-type", FileQueryInfoFlags.NONE);
        var mime_type = info.get_content_type();

        if (mime_type.has_prefix("image/")) {
          return new Gdk.Pixbuf.from_file_at_scale(path, size, size, true);
        }
      } catch (Error e) {
        warning("Failed to load image from '%s': %s", path, e.message);
      }

      return null;
    }

    private Gdk.Pixbuf? create_pixbuf_from_image_data(ImageData image_data, int target_size) {
      if (image_data == null) {
        return null;
      }

      var pixbuf = new Gdk.Pixbuf.from_data(
                                            image_data.data,
                                            Gdk.Colorspace.RGB,
                                            image_data.has_alpha,
                                            image_data.bits_per_sample,
                                            image_data.width,
                                            image_data.height,
                                            image_data.rowstride,
                                            null
      );

      if (image_data.width != target_size || image_data.height != target_size) {
        var scaled_pixbuf = pixbuf.scale_simple(
                                                target_size,
                                                target_size,
                                                Gdk.InterpType.BILINEAR
        );
        return scaled_pixbuf;
      }

      return pixbuf;
    }

    private string ? get_desktop_entry_icon(NotificationData notification) {
      if (notification.desktop_entry.length > 0) {
        var app = bamf_matcher.get_application_for_desktop_file(notification.desktop_entry + ".desktop", false);
        if (app != null) {
          return app.get_icon();
        }
      }

      return null;
    }

    private Gtk.Widget create_notification_icon(NotificationData notification) {
      Gdk.Pixbuf? pixbuf = null;
      int image_size = notification.app_icon.length > 0 ? IMAGE_SIZE : ICON_SIZE;

      if (notification.image_data != null) {
        pixbuf = create_pixbuf_from_image_data(notification.image_data, image_size);
        if (pixbuf != null) {
          return new Gtk.Image.from_pixbuf(pixbuf);
        }
      }

      if (notification.image_path.length > 0) {
        pixbuf = load_image_from_path(notification.image_path, image_size);
        if (pixbuf != null) {
          return new Gtk.Image.from_pixbuf(pixbuf);
        }
      }

      if (notification.app_icon.length > 0) {
        pixbuf = load_image_from_path(notification.app_icon, ICON_SIZE);
        if (pixbuf != null) {
          return new Gtk.Image.from_pixbuf(pixbuf);
        }

        try {
          var icon_theme = Gtk.IconTheme.get_default();
          if (icon_theme.has_icon(notification.app_icon)) {
            pixbuf = icon_theme.load_icon(notification.app_icon, ICON_SIZE, Gtk.IconLookupFlags.FORCE_SYMBOLIC);
            return new Gtk.Image.from_pixbuf(pixbuf);
          }
        } catch (Error e) {
          warning("Failed to load theme icon '%s': %s", notification.app_icon, e.message);
        }
      }

      if (notification.icon_data != null) {
        pixbuf = create_pixbuf_from_image_data(notification.icon_data, ICON_SIZE);
        if (pixbuf != null) {
          return new Gtk.Image.from_pixbuf(pixbuf);
        }
      }

      var desktop_icon = get_desktop_entry_icon(notification);
      if (desktop_icon != null) {
        pixbuf = load_image_from_path(desktop_icon, ICON_SIZE);
        if (pixbuf != null) {
          return new Gtk.Image.from_pixbuf(pixbuf);
        }

        try {
          var icon_theme = Gtk.IconTheme.get_default();
          if (icon_theme.has_icon(desktop_icon)) {
            pixbuf = icon_theme.load_icon(desktop_icon, ICON_SIZE, 0);
            return new Gtk.Image.from_pixbuf(pixbuf);
          }
        } catch (Error e) {
          debug("Failed to load BAMF icon '%s': %s", desktop_icon, e.message);
        }
      }

      return create_placeholder_icon(notification, ICON_SIZE);
    }

    private Gtk.Image create_placeholder_icon(NotificationData notification, int size) {
      var icon_theme = Gtk.IconTheme.get_default();

      string[] fallback_icons;

      if (notification.urgency == 2) {
        fallback_icons = {
          "dialog-error-symbolic",
          "application-default-symbolic",
          "application-default-icon"
        };
      } else {
        fallback_icons = {
          "dialog-information-symbolic",
          "application-default-symbolic",
          "application-default-icon"
        };
      };

      foreach (var icon_name in fallback_icons) {
        if (icon_theme.has_icon(icon_name)) {
          try {
            var pixbuf = icon_theme.load_icon(icon_name, size, 0);
            return new Gtk.Image.from_pixbuf(pixbuf);
          } catch (Error e) {
            continue;
          }
        }
      }

      // If all else fails, create a simple colored square
      var surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, size, size);
      var ctx = new Cairo.Context(surface);

      ctx.set_source_rgba(0.7, 0.7, 0.7, 1.0);
      ctx.rectangle(2, 2, size - 4, size - 4);
      ctx.fill();

      ctx.set_source_rgba(0.5, 0.5, 0.5, 1.0);
      ctx.rectangle(2, 2, size - 4, size - 4);
      ctx.stroke();

      var pixbuf = Gdk.pixbuf_get_from_surface(surface, 0, 0, size, size);
      return new Gtk.Image.from_pixbuf(pixbuf);
    }

    private string format_timestamp(DateTime timestamp) {
      var now = new DateTime.now_local();
      var diff = now.difference(timestamp);

      if (diff < TimeSpan.MINUTE) {
        return _("just now");
      } else if (diff < TimeSpan.HOUR) {
        var minutes = diff / TimeSpan.MINUTE;
        return ngettext("%d minute ago", "%d minutes ago", (ulong) minutes).printf((int) minutes);
      } else if (diff < TimeSpan.DAY) {
        var hours = diff / TimeSpan.HOUR;
        return ngettext("%d hour ago", "%d hours ago", (ulong) hours).printf((int) hours);
      } else {
        return timestamp.format("%b %d, %H:%M");
      }
    }

    private void handle_expiry_changed() {
      if (prefs.EnableExpiry) {
        cleanup_expired_notifications();
      } else {
        cancel_all_expiry_timers();
      }
    }

    private void cleanup_expired_notifications() {
      lock (notification_lock) {
        var active_notifications = new GLib.List<NotificationData> ();
        bool changed = false;

        notifications.foreach((n) => {
          if (n.is_expired()) {
            changed = true;
          } else {
            active_notifications.append(n);
            n.setup_expiry_timer(this);
          }
        });

        if (changed) {
          notifications = (owned) active_notifications;
          update_display();
        }
      }
    }

    private void cancel_all_expiry_timers() {
      lock (notification_lock) {
        notifications.foreach((n) => {
          n.cancel_expiry_timer();
        });
      }
    }

    public override Gee.ArrayList<Gtk.MenuItem> get_menu_items() {
      var items = new Gee.ArrayList<Gtk.MenuItem> ();

      var expiry_item = new Gtk.CheckMenuItem.with_mnemonic(_("Enable _Expiry"));
      expiry_item.active = prefs.EnableExpiry;
      expiry_item.activate.connect(() => {
        prefs.EnableExpiry = !prefs.EnableExpiry;
        handle_expiry_changed();
      });
      items.add(expiry_item);

      var count_item = new Gtk.CheckMenuItem.with_mnemonic(_("Show _Count"));
      count_item.active = prefs.ShowCount;
      count_item.activate.connect(() => {
        prefs.ShowCount = !prefs.ShowCount;
        update_display();
      });
      items.add(count_item);

      var transient_item = new Gtk.CheckMenuItem.with_mnemonic(_("Show _Transient"));
      transient_item.active = prefs.ShowTransient;
      transient_item.activate.connect(() => {
        prefs.ShowTransient = !prefs.ShowTransient;
        update_transient_items();
        update_display();
      });
      items.add(transient_item);

      bool has_notifications;
      lock (notification_lock) {
        has_notifications = notifications.length() > 0;
      }

      items.add(new Gtk.SeparatorMenuItem());

      var clear_item = new Gtk.MenuItem.with_label(_("Clear Notifications"));
      clear_item.activate.connect(() => {
        clear_all_notifications();
      });
      if (!has_notifications) {
        clear_item.sensitive = false;
      }
      items.add(clear_item);

      return items;
    }
  }
}
