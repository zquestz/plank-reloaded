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
using Canberra;

namespace Docky {
  [DBus(name = "org.gnome.Nautilus.FileOperations")]
  private interface NautilusFileOperations : Object {
    public abstract async void empty_trash() throws DBusError, IOError;
  }

  public class TrashDockItem : DockletItem {
    private const string TRASH_URI = "trash://";
    private const string KDE_TRASH_URI = "trash:/";
    private const string NEMO_SCHEMA = "org.nemo.preferences";
    private const string NEMO_PATH = "/org/nemo/preferences/";
    private const string CAJA_SCHEMA = "org.mate.caja.preferences";
    private const string CAJA_PATH = "/org/mate/caja/preferences/";
    private const string DEFAULT_SOUND_THEME = "freedesktop";

    private const string STANDARD_ATTRIBUTES =
      FileAttribute.STANDARD_TYPE + ","
      + FileAttribute.STANDARD_NAME + ","
      + FileAttribute.ACCESS_CAN_DELETE;

    private const uint UPDATE_DEBOUNCE_DELAY = 200U;

    private Gee.ArrayList<FileMonitor> trash_monitors;
    private File trash;
    private Canberra.Context? sound_context;
    private uint update_timer_id = 0;
    private bool update_in_progress = false;
    private bool update_pending = false;
    private uint32 last_item_count = 0;

    public TrashDockItem.with_dockitem_file(GLib.File file)
    {
      GLib.Object(Prefs : new DockItemPreferences.with_file(file));
    }

    construct
    {
      trash = environment_is_session_desktop(XdgSessionDesktop.KDE) ? File.new_for_uri(KDE_TRASH_URI) : File.new_for_uri(TRASH_URI);
      trash_monitors = new Gee.ArrayList<FileMonitor> ();

      notify["Container"].connect(handle_container_changed);

      Icon = "user-trash";
      setup_monitor();
      update();
    }

    ~TrashDockItem() {
      cleanup_monitor();
      remove_update_timer();
    }

    private void handle_container_changed() {
      if (Container == null) {
        removed_from_dock();
      }
    }

    // Stop watching and pending updates as soon as the item leaves its dock
    private void removed_from_dock() {
      cleanup_monitor();
      remove_update_timer();
    }

    private void remove_update_timer() {
      if (update_timer_id > 0) {
        GLib.Source.remove(update_timer_id);
        update_timer_id = 0;
      }
    }

    private void setup_monitor() {
      try {
        if (environment_is_session_desktop(XdgSessionDesktop.KDE)) {
          var trash_dirs = get_trash_directories();
          foreach (var trash_dir in trash_dirs) {
            // Monitor even when files/ does not exist yet (GIO watches for
            // creation), so the first trashed file on a fresh profile counts
            var files_dir = trash_dir.get_child("files");
            var monitor = files_dir.monitor(0);
            monitor.changed.connect(trash_changed);
            trash_monitors.add(monitor);
          }
        } else {
          var monitor = trash.monitor(0);
          monitor.changed.connect(trash_changed);
          trash_monitors.add(monitor);
        }
      } catch (GLib.Error e) {
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
      schedule_update();
    }

    // Coalesce monitor-event bursts (a mass delete emits hundreds) into a
    // single update shortly after the last event
    private void schedule_update() {
      if (update_timer_id > 0) {
        GLib.Source.remove(update_timer_id);
      }

      update_timer_id = GLib.Timeout.add(UPDATE_DEBOUNCE_DELAY, () => {
        update_timer_id = 0;
        update();
        return false;
      });
    }

    private void update() {
      do_update.begin();
    }

    private async void do_update() {
      if (update_in_progress) {
        update_pending = true;
        return;
      }
      update_in_progress = true;

      uint32 item_count = 0;
      string? icon_name = null;

      if (environment_is_session_desktop(XdgSessionDesktop.KDE)) {
        item_count = yield get_trash_item_count_manual();
        icon_name = item_count > 0 ? "user-trash-full" : "user-trash";
      } else {
        try {
          var info = yield trash.query_info_async(
                                                  FileAttribute.TRASH_ITEM_COUNT + "," + FileAttribute.STANDARD_ICON,
                                                  0,
                                                  Priority.DEFAULT,
                                                  null
          );
          item_count = info.get_attribute_uint32(FileAttribute.TRASH_ITEM_COUNT);
          icon_name = DrawingService.get_icon_from_gicon(info.get_icon());
        } catch (GLib.Error e) {
          warning("Could not get item count from trash::item-count: %s", e.message);
          item_count = yield get_trash_item_count_manual();
          icon_name = item_count > 0 ? "user-trash-full" : "user-trash";
        }
      }

      last_item_count = item_count;
      update_text(item_count);
      update_icon(icon_name);

      update_in_progress = false;
      if (update_pending) {
        update_pending = false;
        schedule_update();
      }
    }

    private void update_text(uint32 item_count) {
      var new_text = (item_count == 0) ?
        _("No items in Trash") :
        ngettext("%u item in Trash", "%u items in Trash", item_count).printf(item_count);

      if (Text != new_text) {
        Text = new_text;
      }
    }

    // Only assign on change: the Icon setter resets the icon buffer even for
    // identical values
    private void update_icon(string? icon_name) {
      if (icon_name != null && icon_name != "" && Icon != icon_name) {
        Icon = icon_name;
      }
    }

    private void play_event_sound(string sound_name) {
      unowned Gtk.Settings settings = Gtk.Settings.get_default();
      if (!settings.gtk_enable_event_sounds) {
        return;
      }

      if (sound_context == null) {
        Canberra.Context.create(out sound_context);
        sound_context.open();
      }

      sound_context.play(
                         0,
                         Canberra.PROP_CANBERRA_XDG_THEME_NAME, settings.gtk_sound_theme_name ?? DEFAULT_SOUND_THEME,
                         Canberra.PROP_EVENT_ID, sound_name,
                         null
      );
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

    private async uint32 get_trash_item_count_manual() {
      uint32 count = 0;

      var trash_dirs = get_trash_directories();

      foreach (var trash_dir in trash_dirs) {
        try {
          var files_dir = trash_dir.get_child("files");
          if (!files_dir.query_exists()) {
            continue;
          }

          var enumerator = yield files_dir.enumerate_children_async(
                                                                    FileAttribute.STANDARD_NAME,
                                                                    FileQueryInfoFlags.NOFOLLOW_SYMLINKS,
                                                                    Priority.DEFAULT,
                                                                    null
          );

          while (true) {
            var infos = yield enumerator.next_files_async(100, Priority.DEFAULT, null);
            if (infos == null || infos.length() == 0) {
              break;
            }
            count += infos.length();
          }

          yield enumerator.close_async(Priority.DEFAULT, null);
        } catch (GLib.Error e) {
          warning("Could not enumerate trash directory %s: %s", trash_dir.get_path(), e.message);
        }
      }

      return count;
    }

    private bool move_to_trash(string uri) {
      try {
        return File.new_for_uri(uri).trash(null);
      } catch (GLib.Error e) {
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
        empty_trash_via_nautilus.begin();
        return;
      }

      empty_trash_internal();
    }

    private async void empty_trash_via_nautilus() {
      try {
        var nautilus = yield Bus.get_proxy<NautilusFileOperations> (
                                                                    BusType.SESSION,
                                                                    "org.gnome.Nautilus",
                                                                    "/org/gnome/Nautilus"
        );
        yield nautilus.empty_trash();
        play_event_sound("trash-empty");
      } catch (GLib.Error e) {
        warning("Could not empty trash via Nautilus: %s", e.message);
        empty_trash_internal();
      }
    }

    private void empty_trash_internal() {
      if (!confirm_trash_delete()) {
        perform_empty_trash();
        return;
      }

      show_empty_trash_dialog();
    }

    private bool confirm_trash_delete() {
      if (environment_is_session_desktop(XdgSessionDesktop.CINNAMON)) {
        var settings = try_create_settings(NEMO_SCHEMA, NEMO_PATH);
        if (settings != null) {
          return settings.get_boolean("confirm-trash");
        }
      }

      if (environment_is_session_desktop(XdgSessionDesktop.MATE)) {
        var settings = try_create_settings(CAJA_SCHEMA, CAJA_PATH);
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
        play_event_sound("trash-empty");
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
          } catch (GLib.Error e) {
            warning("Could not delete trash item: %s", e.message);
          }
        }

        enumerator.close();
      } catch (GLib.Error e) {
        warning("Could not enumerate trash for deletion: %s", e.message);
      }
    }

    public override string get_drop_text() {
      return _("Drop to move to Trash");
    }

    protected override bool can_accept_drop(Gee.ArrayList<string> uris) {
      // No IO here: this runs on every pointer motion during an external
      // drag, and query_exists on a remote uri is a round trip per event;
      // the drop itself reports failures
      foreach (string uri in uris) {
        if (uri != "") {
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
        play_event_sound("file-trash");
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
      empty_item.sensitive = (last_item_count > 0);
      items.add(empty_item);

      return items;
    }
  }
}
