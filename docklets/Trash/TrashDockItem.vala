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
  [DBus(name = "org.gnome.Nautilus.FileOperations")]
  private interface NautilusFileOperations : Object {
    public abstract void empty_trash() throws DBusError, IOError;
  }

  public class TrashDockItem : DockletItem {
    private const string TRASH_URI = "trash://";
    private const string KDE_TRASH_URI = "trash:/";
    private const string NEMO_SCHEMA = "org.nemo.preferences";
    private const string NEMO_PATH = "/org/nemo/preferences/";
    private const string CAJA_SCHEMA = "org.mate.caja.preferences";
    private const string CAJA_PATH = "/org/mate/caja/preferences/";

    private const string STANDARD_ATTRIBUTES =
      FileAttribute.STANDARD_TYPE + ","
      + FileAttribute.STANDARD_NAME + ","
      + FileAttribute.ACCESS_CAN_DELETE;

    private Gee.ArrayList<FileMonitor> trash_monitors;
    private File trash;

    public TrashDockItem.with_dockitem_file(GLib.File file)
    {
      GLib.Object(Prefs: new DockItemPreferences.with_file(file));
    }

    construct
    {
      trash = environment_is_session_desktop(XdgSessionDesktop.KDE) ? File.new_for_uri(KDE_TRASH_URI) : File.new_for_uri(TRASH_URI);
      trash_monitors = new Gee.ArrayList<FileMonitor> ();

      setup_monitor();
      update();
    }

    ~TrashDockItem() {
      cleanup_monitor();
    }

    private void setup_monitor() {
      try {
        if (environment_is_session_desktop(XdgSessionDesktop.KDE)) {
          var trash_dirs = get_trash_directories();
          foreach (var trash_dir in trash_dirs) {
            var files_dir = trash_dir.get_child("files");
            if (files_dir.query_exists()) {
              var monitor = files_dir.monitor(0);
              monitor.changed.connect(trash_changed);
              trash_monitors.add(monitor);
            }
          }
        } else {
          var monitor = trash.monitor(0);
          monitor.changed.connect(trash_changed);
          trash_monitors.add(monitor);
        }
      } catch (Error e) {
        warning("Could not start file monitor for trash: %s", e.message);
      }
    }

    private void cleanup_monitor() {
      foreach (var monitor in trash_monitors) {
        monitor.changed.disconnect(trash_changed);
        monitor.cancel();
      }
      trash_monitors.clear();
    }

    private void trash_changed(File f, File? other, FileMonitorEvent event) {
      update();
    }

    private void update() {
      uint32 item_count = get_trash_item_count();
      update_text(item_count);
      update_icon(item_count);
    }

    private void update_text(uint32 item_count) {
      Text = (item_count == 0) ?
        _("No items in Trash") :
        ngettext("%u item in Trash", "%u items in Trash", item_count).printf(item_count);
    }

    private void update_icon(uint32 item_count) {
      string? icon_name = null;

      if (environment_is_session_desktop(XdgSessionDesktop.KDE)) {
        icon_name = item_count > 0 ? "user-trash-full" : "user-trash";
      } else {
        icon_name = DrawingService.get_icon_from_file(trash);
      }

      if (icon_name != null && icon_name != "") {
        Icon = icon_name;
      }
    }

    private Gee.ArrayList<File> get_trash_directories() {
      var trash_dirs = new Gee.ArrayList<File> ();

      var primary_trash = File.new_for_path(Environment.get_user_data_dir()).get_child("Trash");
      if (!primary_trash.query_exists()) {
        primary_trash = File.new_for_path(Environment.get_home_dir()).get_child(".local/share/Trash");
      }
      trash_dirs.add(primary_trash);

      return trash_dirs;
    }

    private uint32 get_trash_item_count() {
      if (environment_is_session_desktop(XdgSessionDesktop.KDE)) {
        return get_trash_item_count_manual();
      } else {
        try {
          return trash.query_info(
                                  FileAttribute.TRASH_ITEM_COUNT,
                                  0,
                                  null
          ).get_attribute_uint32(FileAttribute.TRASH_ITEM_COUNT);
        } catch (Error e) {
          warning("Could not get item count from trash::item-count: %s", e.message);
        }
      }

      return get_trash_item_count_manual();
    }

    private uint32 get_trash_item_count_manual() {
      uint32 count = 0;

      var trash_dirs = get_trash_directories();

      foreach (var trash_dir in trash_dirs) {
        try {
          var files_dir = trash_dir.get_child("files");
          if (!files_dir.query_exists()) {
            continue;
          }

          var enumerator = files_dir.enumerate_children(
                                                        FileAttribute.STANDARD_NAME,
                                                        FileQueryInfoFlags.NOFOLLOW_SYMLINKS,
                                                        null
          );

          if (enumerator != null) {
            FileInfo? info = null;
            while ((info = enumerator.next_file()) != null) {
              count++;
            }
            enumerator.close(null);
          }
        } catch (Error e) {
          warning("Could not enumerate trash directory %s: %s", trash_dir.get_path(), e.message);
        }
      }

      return count;
    }

    private bool move_to_trash(string uri) {
      try {
        return File.new_for_uri(uri).trash(null);
      } catch (Error e) {
        warning("Could not move '%s' to trash: %s", uri, e.message);
        return false;
      }
    }

    private void open_trash() {
      if (environment_is_session_desktop(XdgSessionDesktop.KDE)) {
        try {
          Process.spawn_command_line_async("kioclient exec %s".printf(KDE_TRASH_URI));
        } catch (SpawnError e) {
          try {
            Process.spawn_command_line_async("dolphin %s".printf(KDE_TRASH_URI));
          } catch (SpawnError e2) {
            try {
              Process.spawn_command_line_async("kde-open %s".printf(KDE_TRASH_URI));
            } catch (SpawnError e3) {
              warning("Could not open trash in KDE: %s, %s, %s", e.message, e2.message, e3.message);
            }
          }
        }
      } else {
        System.get_default().open(trash);
      }
    }

    private void empty_trash() {
      if (environment_is_session_desktop(
                                         XdgSessionDesktop.GNOME
                                         | XdgSessionDesktop.UNITY
                                         | XdgSessionDesktop.UBUNTU
          )) {
        try {
          var nautilus = Bus.get_proxy_sync<NautilusFileOperations> (
                                                                     BusType.SESSION,
                                                                     "org.gnome.Nautilus",
                                                                     "/org/gnome/Nautilus"
          );
          nautilus.empty_trash();
          return;
        } catch (Error e) {
          warning("Could not empty trash via Nautilus: %s", e.message);
        }
      }

      empty_trash_internal();
    }

    private void empty_trash_internal() {
      if (!confirm_trash_delete()) {
        perform_empty_trash();
        return;
      }

      show_empty_trash_dialog();
    }

    private static GLib.Settings? create_settings(string schema_id, string? path = null) {
      var schema_source = GLib.SettingsSchemaSource.get_default();
      var schema = schema_source.lookup(schema_id, true);
      if (schema == null) {
        warning("GSettingsSchema '%s' not found", schema_id);
        return null;
      }
      return new GLib.Settings.full(schema, null, path);
    }

    private bool confirm_trash_delete() {
      if (environment_is_session_desktop(XdgSessionDesktop.CINNAMON)) {
        var settings = create_settings(NEMO_SCHEMA, NEMO_PATH);
        if (settings != null) {
          return settings.get_boolean("confirm-trash");
        }
      }

      if (environment_is_session_desktop(XdgSessionDesktop.MATE)) {
        var settings = create_settings(CAJA_SCHEMA, CAJA_PATH);
        if (settings != null) {
          return settings.get_boolean("confirm-trash");
        }
      }

      return true;
    }

    private void show_empty_trash_dialog() {
      var dialog = new Gtk.MessageDialog(
                                         null,
                                         0,
                                         Gtk.MessageType.WARNING,
                                         Gtk.ButtonsType.NONE,
                                         "%s",
                                         _("Empty all items from Trash?")
      );

      dialog.secondary_text = _("All items in the Trash will be permanently deleted.");
      dialog.add_button(_("_Cancel"), Gtk.ResponseType.CANCEL);
      dialog.add_button(_("Empty _Trash"), Gtk.ResponseType.OK);
      dialog.set_default_response(Gtk.ResponseType.OK);

      dialog.window_position = Gtk.WindowPosition.CENTER;
      dialog.gravity = Gdk.Gravity.CENTER;
      dialog.set_transient_for(
                               ((Gtk.Application) Application.get_default()).get_active_window()
      );

      dialog.response.connect((response_id) => {
        if (response_id == Gtk.ResponseType.OK) {
          perform_empty_trash();
        }
        dialog.destroy();
      });

      dialog.show();
    }

    private void perform_empty_trash() {
      foreach (var monitor in trash_monitors) {
        monitor.changed.disconnect(trash_changed);
      }

      Worker.get_default().add_task_with_result.begin<void*> (() => {
        if (environment_is_session_desktop(XdgSessionDesktop.KDE)) {
          delete_kde_trash_files();
        } else {
          delete_children_recursive(trash);
        }
        return null;
      }, TaskPriority.HIGH, () => {
        foreach (var monitor in trash_monitors) {
          monitor.changed.connect(trash_changed);
        }
        update();
      });
    }

    private void delete_kde_trash_files() {
      var trash_dirs = get_trash_directories();

      foreach (var trash_dir in trash_dirs) {
        var files_dir = trash_dir.get_child("files");
        var info_dir = trash_dir.get_child("info");

        if (files_dir.query_exists()) {
          delete_children_recursive(files_dir);
        }

        if (info_dir.query_exists()) {
          delete_children_recursive(info_dir);
        }
      }
    }

    private static void delete_children_recursive(File file) {
      try {
        var enumerator = file.enumerate_children(
                                                 STANDARD_ATTRIBUTES,
                                                 FileQueryInfoFlags.NOFOLLOW_SYMLINKS
        );

        if (enumerator == null)return;

        FileInfo? info = null;
        while ((info = enumerator.next_file()) != null) {
          var child = file.get_child(info.get_name());

          if (info.get_file_type() == FileType.DIRECTORY) {
            delete_children_recursive(child);
          }

          try {
            if (info.get_attribute_boolean(FileAttribute.ACCESS_CAN_DELETE)) {
              child.delete();
            }
          } catch (Error e) {
            warning("Could not delete trash item: %s", e.message);
          }
        }

        enumerator.close();
      } catch (Error e) {
        warning("Could not enumerate trash for deletion: %s", e.message);
      }
    }

    public override string get_drop_text() {
      return _("Drop to move to Trash");
    }

    protected override bool can_accept_drop(Gee.ArrayList<string> uris) {
      foreach (string uri in uris) {
        if (File.new_for_uri(uri).query_exists()) {
          return true;
        }
      }
      return false;
    }

    protected override bool accept_drop(Gee.ArrayList<string> uris) {
      bool accepted = false;
      foreach (string uri in uris) {
        accepted |= move_to_trash(uri);
      }

      if (accepted) {
        update();
      }
      return accepted;
    }

    protected override AnimationType on_clicked(PopupButton button,
                                                Gdk.ModifierType mod,
                                                uint32 event_time) {
      if (button == PopupButton.LEFT) {
        open_trash();
        return AnimationType.BOUNCE;
      }
      return AnimationType.NONE;
    }

    public override Gee.ArrayList<Gtk.MenuItem> get_menu_items() {
      var items = new Gee.ArrayList<Gtk.MenuItem> ();

      var open_item = create_menu_item(_("_Open Trash"), Icon);
      open_item.activate.connect(open_trash);
      items.add(open_item);

      var empty_item = create_menu_item(_("Empty _Trash"), "gtk-clear");
      empty_item.activate.connect(empty_trash);
      empty_item.sensitive = (get_trash_item_count() > 0);
      items.add(empty_item);

      return items;
    }
  }
}
