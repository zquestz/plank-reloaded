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
    private const string NEMO_SCHEMA = "org.nemo.preferences";
    private const string NEMO_PATH = "/org/nemo/preferences/";
    private const string NAUTILUS_SCHEMA = "org.gnome.nautilus.preferences";
    private const string NAUTILUS_PATH = "/org/gnome/nautilus/preferences/";

    private const string STANDARD_ATTRIBUTES =
      FileAttribute.STANDARD_TYPE + ","
      + FileAttribute.STANDARD_NAME + ","
      + FileAttribute.ACCESS_CAN_DELETE;

    private const string TRASH_ATTRIBUTES =
      FileAttribute.STANDARD_TYPE + ","
      + FileAttribute.STANDARD_NAME;

    private FileMonitor? trash_monitor;
    private File owned_file;
    private bool confirm_trash_delete = true;

    public TrashDockItem.with_dockitem_file(GLib.File file)
    {
      GLib.Object(Prefs : new DockItemPreferences.with_file(file));
    }

    construct
    {
      initialize_trash();
      initialize_settings();
    }

    ~TrashDockItem() {
      cleanup_monitor();
    }

    private static GLib.Settings? create_settings(string schema_id, string? path = null)
    {
      var schema_source = GLib.SettingsSchemaSource.get_default();
      var schema = schema_source.lookup(schema_id, true);
      if (schema == null) {
        warning("GSettingsSchema '%s' not found", schema_id);
        return null;
      }
      return new GLib.Settings.full(schema, null, path);
    }

    private void initialize_trash() {
      owned_file = File.new_for_uri(TRASH_URI);
      setup_monitor();
      update();
    }

    private void initialize_settings() {
      if (environment_is_session_desktop(XdgSessionDesktop.CINNAMON)) {
        load_settings(NEMO_SCHEMA, NEMO_PATH);
      }
    }

    private void load_settings(string schema, string path) {
      var settings = create_settings(schema, path);
      if (settings != null) {
        confirm_trash_delete = settings.get_boolean("confirm-trash");
      } else {
        confirm_trash_delete = true;
      }
    }

    private void setup_monitor() {
      try {
        trash_monitor = owned_file.monitor(0);
        trash_monitor.changed.connect(trash_changed);
      } catch (Error e) {
        warning("Could not start file monitor for trash: %s", e.message);
      }
    }

    private void cleanup_monitor() {
      if (trash_monitor != null) {
        trash_monitor.changed.disconnect(trash_changed);
        trash_monitor.cancel();
        trash_monitor = null;
      }
    }

    private void trash_changed(File f, File? other, FileMonitorEvent event) {
      update();
    }

    private void update() {
      uint32 item_count = get_trash_item_count();
      update_text(item_count);
      update_icon();
    }

    private void update_text(uint32 item_count) {
      Text = (item_count == 0) ?
        _("No items in Trash") :
        ngettext("%u item in Trash", "%u items in Trash", item_count).printf(item_count);
    }

    private void update_icon() {
      Icon = DrawingService.get_icon_from_file(owned_file);
    }

    private uint32 get_trash_item_count() {
      try {
        return owned_file.query_info(
                                     FileAttribute.TRASH_ITEM_COUNT,
                                     0,
                                     null
        ).get_attribute_uint32(FileAttribute.TRASH_ITEM_COUNT);
      } catch (Error e) {
        warning("Could not get item count from trash::item-count: %s", e.message);
      }
      return 0U;
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

    private bool move_to_trash(string uri) {
      try {
        return File.new_for_uri(uri).trash(null);
      } catch (Error e) {
        warning("Could not move '%s' to trash: %s", uri, e.message);
        return false;
      }
    }

    public override Gee.ArrayList<Gtk.MenuItem> get_menu_items() {
      var items = new Gee.ArrayList<Gtk.MenuItem> ();

      if (!environment_is_session_desktop(XdgSessionDesktop.CINNAMON)) {
        add_restore_items(items);
      }

      add_trash_operations(items);

      return items;
    }

    private void add_restore_items(Gee.ArrayList<Gtk.MenuItem> items) {
      var files = get_trash_files();
      if (files.size > 0) {
        items.add(new TitledSeparatorMenuItem.no_line(_("Restore Files")));
        add_restore_menu_items(items, files);
        items.add(new Gtk.SeparatorMenuItem());
      }
    }

    private Gee.ArrayList<File> get_trash_files() {
      var files = new Gee.ArrayList<File> ();
      try {
        var enumerator = owned_file.enumerate_children(
                                                       TRASH_ATTRIBUTES,
                                                       FileQueryInfoFlags.NOFOLLOW_SYMLINKS,
                                                       null
        );

        if (enumerator != null) {
          FileInfo? info = null;
          while ((info = enumerator.next_file()) != null) {
            files.add(owned_file.get_child(info.get_name()));
          }
          enumerator.close(null);
        }
      } catch (Error e) {
        warning("Could not enumerate items in the trash: %s", e.message);
      }
      return files;
    }

    private void add_restore_menu_items(Gee.ArrayList<Gtk.MenuItem> items,
                                        Gee.ArrayList<File> files) {
      files.sort((CompareDataFunc) compare_files);

      int count = 0;
      foreach (File file in files) {
        var menu_item = create_restore_menu_item(file);
        if (menu_item != null) {
          items.add(menu_item);
          if (++count == 5)break;
        }
      }
    }

    private Gtk.MenuItem? create_restore_menu_item(File file)
    {
      var item = create_literal_menu_item(
                                          file.get_basename(),
                                          DrawingService.get_icon_from_file(file),
                                          false
      );
      item.activate.connect(() => restore_file(file));
      return item;
    }

    private void add_trash_operations(Gee.ArrayList<Gtk.MenuItem> items) {
      var open_item = create_menu_item(_("_Open Trash"), Icon);
      open_item.activate.connect(open_trash);
      items.add(open_item);

      var empty_item = create_menu_item(_("Empty _Trash"), "gtk-clear");
      empty_item.activate.connect(empty_trash);
      empty_item.sensitive = (get_trash_item_count() > 0);
      items.add(empty_item);
    }

    private static int compare_files(File left, File right) {
      try {
        string? left_date = left.query_info(
                                            FileAttribute.TRASH_DELETION_DATE,
                                            0,
                                            null
        ).get_attribute_string(FileAttribute.TRASH_DELETION_DATE);

        string? right_date = right.query_info(
                                              FileAttribute.TRASH_DELETION_DATE,
                                              0,
                                              null
        ).get_attribute_string(FileAttribute.TRASH_DELETION_DATE);

        return strcmp(right_date ?? "", left_date ?? "");
      } catch (Error e) {
        warning("Could not compare trash items: %s", e.message);
        return 0;
      }
    }

    private void restore_file(File file) {
      try {
        var info = file.query_info(
                                   FileAttribute.TRASH_ORIG_PATH,
                                   0,
                                   null
        );

        string? orig_path = info.get_attribute_string(FileAttribute.TRASH_ORIG_PATH);
        if (orig_path != null) {
          var dest_file = File.new_for_path(orig_path);
          file.move(
                    dest_file,
                    FileCopyFlags.NOFOLLOW_SYMLINKS
                    | FileCopyFlags.ALL_METADATA
                    | FileCopyFlags.NO_FALLBACK_FOR_MOVE,
                    null,
                    null
          );
        }
      } catch (Error e) {
        warning("Could not restore file from trash: %s", e.message);
      }
    }

    private void open_trash() {
      System.get_default().open(owned_file);
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
      if (!confirm_trash_delete) {
        perform_empty_trash();
        return;
      }

      show_empty_trash_dialog();
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
      if (trash_monitor != null) {
        trash_monitor.changed.disconnect(trash_changed);
      }

      Worker.get_default().add_task_with_result.begin<void*> (() => {
        delete_children_recursive(owned_file);
        return null;
      }, TaskPriority.HIGH, () => {
        if (trash_monitor != null) {
          trash_monitor.changed.connect(trash_changed);
        }
        update();
      });
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
  }
}
