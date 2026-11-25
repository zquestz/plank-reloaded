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

// XKB calls missing from x11.vapi
[CCode (cheader_filename = "X11/XKBlib.h")]
namespace ClippyXkb {
  // XkbUseCoreKbd from X11/extensions/XKB.h
  internal const uint USE_CORE_KBD = 0x0100;

  // Fills an XkbStateRec: byte 0 is the effective group, byte 1 the locked one
  internal const int STATE_SIZE = 64;

  [CCode (cname = "XkbGetState")]
  internal extern int get_state (X.Display display, uint device_spec, void* state);

  [CCode (cname = "XkbLockGroup")]
  internal extern bool lock_group (X.Display display, uint device_spec, uint group);

  [CCode (cname = "XkbKeycodeToKeysym")]
  internal extern ulong keycode_to_keysym (X.Display display, uchar keycode, int group, int level);
}

namespace Docky {
  /**
   * Lets a global hotkey open the history window:
   * gdbus call --session --dest net.launchpad.plank.Clippy
   *   --object-path /net/launchpad/plank/Clippy
   *   --method net.launchpad.plank.Clippy.ShowHistory
   */
  [DBus (name = "net.launchpad.plank.Clippy")]
  public class ClippyService : GLib.Object {
    public const string BUS_NAME = "net.launchpad.plank.Clippy";
    public const string OBJECT_PATH = "/net/launchpad/plank/Clippy";

    [DBus (visible = false)]
    public signal void show_requested ();

    public void show_history () throws GLib.DBusError, GLib.IOError {
      show_requested ();
    }
  }

  public delegate void ClippyChoiceSetter (uint choice);

  public class ClippyEncodeJob : GLib.Object {
    public bool written = false;
  }

  // Moves the callback into an idle source, so it runs and is freed on the
  // main thread, not in the worker
  public class ClippyEncodeDone : GLib.Object {
    private GLib.SourceFunc? callback;

    public ClippyEncodeDone (owned GLib.SourceFunc callback) {
      this.callback = (owned) callback;
    }

    public void schedule () {
      lock (callback) {
        if (callback != null) {
          GLib.Idle.add ((owned) callback);
          callback = null;
        }
      }
    }
  }

  public class ClippyDockItem : DockletItem {
    private const string EMPTY_CLIPBOARD_TEXT = _("Clipboard is currently empty.");
    private const int MAX_CLIP_MENU_ITEM_LENGTH = 80;

    private const string TRACK_SELECTION_LABEL = _("Track Mouse Selections");
    private const string TRACK_IMAGES_LABEL = _("Track Images");
    private const string TRACK_CLIPBOARD_LABEL = _("Enable Clipboard Tracking");
    private const string MAX_ENTRIES_LABEL = _("Maximum Entries");

    private Gtk.Clipboard primary_clipboard;
    private Gtk.Clipboard regular_clipboard;
    private Gee.ArrayList<ClippyClipboardItem> clips;
    private ulong primary_handler_id = 0U;
    private ulong regular_handler_id = 0U;
    private uint regular_debounce_id = 0;
    private uint primary_debounce_id = 0;
    private bool removed = false;
    private const uint DEBOUNCE_DELAY = 500;
    private const string PASSWORD_MANAGER_HINT = "x-kde-passwordManagerHint";

    private ClippyPreferences prefs {
      get { return (ClippyPreferences) Prefs; }
    }

    private ClippyPopup? popup = null;
    private int64 popup_closed_at = 0;
    private uint paste_timer_id = 0U;
    private uint save_timer_id = 0U;
    private bool loading_history = false;
    // Set once the item is in a dock. A dropped duplicate launcher never loads
    // the history or joins the hotkey service
    private bool attached = false;
    // The .dockitem was deleted: never write the history again
    private bool history_discarded = false;
    private Gee.HashSet<string> encoding = new Gee.HashSet<string> ();

    // The paste waits for the target window and for released modifiers
    private const uint PASTE_RETRY_DELAY = 60;
    private const int PASTE_ATTEMPTS = 20;
    private const uint SAVE_DELAY = 1000;
    // Ignore the click or hotkey that closed the popup by taking its focus
    private const int64 REOPEN_GUARD_USEC = 300000;
    private const string HISTORY_INDEX = "index";
    // Path of the owning .dockitem, for the orphan sweep
    private const string HISTORY_OWNER = "owner";
    private const uint DELETION_CHECK_DELAY = 1500;
    // Images are kept at full size in memory; cap their number
    private const int MAX_IMAGE_ENTRIES = 10;
    private const int MAX_LOADED_TEXT = 16 * 1024 * 1024;
    private const uint EVDEV_KEYCODE_V = 55;

    // Terminals paste with Ctrl+Shift+V. Matched by whole word of the window
    // class, or by the whole class
    private static string[] TERMINAL_WORDS = {
      "kitty", "terminal", "xterm", "alacritty", "konsole", "tilix", "terminator",
      "wezterm", "urxvt", "rxvt", "sakura", "guake", "tilda", "yakuake", "ghostty", "kgx",
      "qterminal", "lxterminal", "terminology", "ptyxis", "blackbox"
    };
    private static string[] TERMINAL_CLASSES = {
      "st-256color", "foot", "footclient", "org.gnome.console"
    };

    // One D-Bus service per process; the hotkey goes to the first attached Clippy
    private static GLib.List<unowned ClippyDockItem> instances = null;
    private static ClippyService? shared_service = null;
    private static uint bus_owner_id = 0U;
    private static uint service_registration_id = 0U;
    private static GLib.DBusConnection? service_connection = null;

    public ClippyDockItem.with_dockitem_file(GLib.File file)
    {
      GLib.Object(Prefs: new ClippyPreferences.with_file(file));
    }

    construct
    {
      notify["Container"].connect(handle_container_changed);

      Icon = ClippyDocklet.ICON;
      clips = new Gee.ArrayList<ClippyClipboardItem> ();
      deleted.connect(handle_dockitem_deleted);
      initialize_clipboards();
      update_display();
    }

    private void register_instance() {
      instances.append(this);
      if (shared_service == null) {
        start_service();
      }
    }

    private void unregister_instance() {
      instances.remove(this);
      if (instances.length() == 0) {
        stop_service();
      }
    }

    private static void start_service() {
      shared_service = new ClippyService();
      shared_service.show_requested.connect(on_hotkey);

      bus_owner_id = GLib.Bus.own_name(GLib.BusType.SESSION, ClippyService.BUS_NAME,
        GLib.BusNameOwnerFlags.NONE,
        (connection) => {
          if (shared_service == null) {
            return;
          }
          try {
            service_registration_id = connection.register_object(ClippyService.OBJECT_PATH,
                                                                 shared_service);
            service_connection = connection;
          } catch (GLib.IOError e) {
            warning("Clippy: could not export the D-Bus service: %s", e.message);
            // Release the name so another process can serve the hotkey
            if (bus_owner_id > 0U) {
              GLib.Bus.unown_name(bus_owner_id);
              bus_owner_id = 0U;
            }
          }
        },
        null,
        () => {
          debug("Clippy: %s is owned elsewhere, hotkey goes to that one", ClippyService.BUS_NAME);
        });
    }

    private static void stop_service() {
      if (service_connection != null && service_registration_id > 0U) {
        service_connection.unregister_object(service_registration_id);
      }
      service_registration_id = 0U;
      service_connection = null;

      if (bus_owner_id > 0U) {
        GLib.Bus.unown_name(bus_owner_id);
        bus_owner_id = 0U;
      }

      if (shared_service != null) {
        shared_service.show_requested.disconnect(on_hotkey);
        shared_service = null;
      }
    }

    private static void on_hotkey() {
      foreach (unowned ClippyDockItem item in instances) {
        if (!item.removed) {
          item.show_popup(0U, (ClippyPlacement) uint.min(item.prefs.HotkeyPosition, 2));
          return;
        }
      }
    }

    /**
     * Opens the history window, or closes it if it is open.
     */
    public void show_popup(uint32 event_time,
                           ClippyPlacement placement = ClippyPlacement.DOCK_ICON) {
      if (removed) {
        return;
      }

      if (popup != null) {
        popup.destroy();
        return;
      }

      if (GLib.get_monotonic_time() - popup_closed_at < REOPEN_GUARD_USEC) {
        return;
      }

      var newest_first = new Gee.ArrayList<ClippyClipboardItem> ();
      for (int i = clips.size - 1; i >= 0; i--) {
        newest_first.add(clips.get(i));
      }

      popup = new ClippyPopup(newest_first, prefs.PreviewSize, prefs.PasteOnSelect);
      popup.item_chosen.connect((clip) => {
        var target = popup.target_xid;
        copy_item(clip);
        if (prefs.PasteOnSelect) {
          paste_into(target);
        }
      });
      popup.clear_requested.connect(clear_clipboard);
      popup.destroy.connect((window) => {
        if (((ClippyPopup) window).closed_by_focus_loss) {
          popup_closed_at = GLib.get_monotonic_time();
        }
        popup = null;
      });
      popup.popup(event_time, placement);
    }

    ~ClippyDockItem() {
      remove_debounce_timers();
      // Keep finalized items out of the static instance list
      if (attached && !removed) {
        unregister_instance();
      }
    }

    private void handle_container_changed() {
      if (Container == null) {
        removed_from_dock();
      } else if (!attached && !removed) {
        attached = true;
        sweep_orphan_histories();
        load_history();
        // Do not write back what was just loaded
        loading_history = true;
        update_display();
        loading_history = false;
        register_instance();
      }
    }

    // The .dockitem was deleted: remove the history. Container == null cannot
    // be used for this, it is also set when a dock is torn down
    private void handle_dockitem_deleted() {
      history_discarded = true;
      if (save_timer_id > 0) {
        GLib.Source.remove(save_timer_id);
        save_timer_id = 0;
      }
      delete_history_files(history_dir(), null, true);
    }

    // Dragging the icon off removes the item before deleting its .dockitem, so
    // the deleted signal may not reach it; check again after a delay
    private void check_dockitem_deleted_later() {
      unowned GLib.File? file = prefs.get_backing_file();
      if (file == null || !prefs.PersistHistory) {
        return;
      }

      var dockitem_path = file.get_path();
      var dir = history_dir();
      GLib.Timeout.add(DELETION_CHECK_DELAY, () => {
        if (!GLib.FileUtils.test(dockitem_path, GLib.FileTest.EXISTS)) {
          delete_history_files(dir, null, true);
        }
        return false;
      });
    }

    // Tear down when the item leaves its dock: the destructor may run much later
    private void removed_from_dock() {
      if (removed) {
        return;
      }

      removed = true;
      disconnect_clipboards();
      remove_debounce_timers();
      if (attached) {
        unregister_instance();
        check_dockitem_deleted_later();
      }
      if (popup != null) {
        popup.destroy();
      }
    }

    private void remove_debounce_timers() {
      if (regular_debounce_id > 0) {
        GLib.Source.remove(regular_debounce_id);
        regular_debounce_id = 0;
      }

      if (primary_debounce_id > 0) {
        GLib.Source.remove(primary_debounce_id);
        primary_debounce_id = 0;
      }

      if (paste_timer_id > 0) {
        GLib.Source.remove(paste_timer_id);
        paste_timer_id = 0;
      }

      if (save_timer_id > 0) {
        GLib.Source.remove(save_timer_id);
        save_timer_id = 0;
        save_history();
      }
    }

    private void initialize_clipboards() {
      primary_clipboard = Gtk.Clipboard.get(Gdk.Atom.intern("PRIMARY", true));
      regular_clipboard = Gtk.Clipboard.get(Gdk.Atom.intern("CLIPBOARD", true));
      connect_clipboards();
    }

    private void connect_clipboards() {
      if (!prefs.DisableTracking) {
        regular_handler_id = regular_clipboard.owner_change.connect(handle_regular_owner_change);
        primary_handler_id = primary_clipboard.owner_change.connect(handle_primary_owner_change);
      }
    }

    [CCode (instance_pos = -1)]
    private void handle_regular_owner_change(Gtk.Clipboard clipboard, Gdk.EventOwnerChange event) {
      request_clipboard_content(regular_clipboard);
    }

    [CCode (instance_pos = -1)]
    private void handle_primary_owner_change(Gtk.Clipboard clipboard, Gdk.EventOwnerChange event) {
      if (prefs.TrackMouseSelections) {
        request_clipboard_content(primary_clipboard);
      }
    }

    private void disconnect_clipboards() {
      if (regular_handler_id > 0U) {
        regular_clipboard.disconnect(regular_handler_id);
        regular_handler_id = 0U;
      }

      if (primary_handler_id > 0U) {
        primary_clipboard.disconnect(primary_handler_id);
        primary_handler_id = 0U;
      }
    }

    private void toggle_clipboard_tracking() {
      prefs.DisableTracking = !prefs.DisableTracking;

      disconnect_clipboards();
      connect_clipboards();
    }

    private void toggle_selection_tracking() {
      prefs.TrackMouseSelections = !prefs.TrackMouseSelections;
    }

    private void toggle_image_tracking() {
      prefs.TrackImages = !prefs.TrackImages;
    }

    private void set_max_entries(int count) {
      prefs.MaxEntries = count;

      while (clips.size > prefs.MaxEntries) {
        clips.remove_at(0);
      }

      update_display();
    }

    private void request_clipboard_content(Gtk.Clipboard source_clipboard) {
      if (removed) {
        return;
      }

      // One debounce per clipboard: activity on one selection must not
      // cancel a pending capture from the other
      if (source_clipboard == regular_clipboard) {
        if (regular_debounce_id > 0) {
          GLib.Source.remove(regular_debounce_id);
        }

        regular_debounce_id = GLib.Timeout.add(DEBOUNCE_DELAY, () => {
          regular_debounce_id = 0;
          if (removed) {
            return false;
          }

          source_clipboard.request_targets(handle_targets_result);
          return false;
        });
      } else {
        if (primary_debounce_id > 0) {
          GLib.Source.remove(primary_debounce_id);
        }

        primary_debounce_id = GLib.Timeout.add(DEBOUNCE_DELAY, () => {
          primary_debounce_id = 0;
          if (removed) {
            return false;
          }

          source_clipboard.request_targets(handle_targets_result);
          return false;
        });
      }
    }

    private void handle_targets_result(Gtk.Clipboard cb, Gdk.Atom[]? atoms) {
      if (removed) {
        return;
      }

      // Respect the password-manager convention: managers mark sensitive
      // selections with this target so clipboard tools skip them
      if (atoms != null) {
        foreach (var atom in atoms) {
          if (atom.name() == PASSWORD_MANAGER_HINT) {
            return;
          }
        }
      }

      if (prefs.TrackImages) {
        cb.request_image(handle_image_result);
      } else {
        request_clipboard_text(cb);
      }
    }

    private void request_clipboard_text(Gtk.Clipboard source_clipboard) {
      if (removed) {
        return;
      }

      source_clipboard.request_text(handle_text_result);
    }

    private void handle_text_result(Gtk.Clipboard cb, string? text) {
      if (removed) {
        return;
      }

      if (text != null && text != "") {
        var item = new ClippyClipboardItem.with_text(text);
        process_clipboard_item(item);
      }
    }

    private void handle_image_result(Gtk.Clipboard cb, Gdk.Pixbuf? pixbuf) {
      if (removed) {
        return;
      }

      if (pixbuf != null && pixbuf.get_width() > 0 && pixbuf.get_height() > 0) {
        var item = new ClippyClipboardItem.with_image(pixbuf);
        process_clipboard_item(item);
      } else {
        request_clipboard_text(cb);
      }
    }

    private void process_clipboard_item(ClippyClipboardItem new_item) {
      string new_hash = new_item.get_hash();
      ClippyClipboardItem? duplicate_item = null;

      foreach (var item in clips) {
        if (item.get_hash() == new_hash) {
          duplicate_item = item;
          break;
        }
      }

      if (duplicate_item != null) {
        clips.remove(duplicate_item);
      }

      clips.add(new_item);

      while (clips.size > prefs.MaxEntries) {
        clips.remove_at(0);
      }
      trim_images();

      update_display();
    }

    private void trim_images() {
      int images = 0;
      foreach (var clip in clips) {
        if (clip.item_type == ClippyClipboardItem.Type.IMAGE) {
          images++;
        }
      }

      for (int i = 0; i < clips.size && images > MAX_IMAGE_ENTRIES; ) {
        if (clips.get(i).item_type == ClippyClipboardItem.Type.IMAGE) {
          clips.remove_at(i);
          images--;
        } else {
          i++;
        }
      }
    }

    private void update_display() {
      if (clips.size == 0) {
        Text = EMPTY_CLIPBOARD_TEXT;
      } else {
        var latest = clips.get(clips.size - 1);

        if (latest.item_type == ClippyClipboardItem.Type.IMAGE) {
          Text = _("Image");
        } else {
          Text = latest.get_display_text(MAX_CLIP_MENU_ITEM_LENGTH);
        }
      }

      schedule_save();
    }


    // Paste only into the window the history was opened over, once it is
    // active and no modifier is held; otherwise leave the entry copied
    private void paste_into(ulong xid) {
      if (paste_timer_id > 0) {
        GLib.Source.remove(paste_timer_id);
        paste_timer_id = 0;
      }

      if (xid == 0) {
        return;
      }

      int attempts = 0;
      bool activation_asked = false;
      paste_timer_id = GLib.Timeout.add(PASTE_RETRY_DELAY, () => {
        if (removed) {
          paste_timer_id = 0;
          return false;
        }

        unowned Wnck.Window? target = find_wnck_window(xid);
        if (target == null) {
          paste_timer_id = 0;
          return false;
        }

        if (target.is_active() && !modifiers_held()) {
          paste_timer_id = 0;
          send_paste_keys(is_terminal(target));
          return false;
        }

        if (!target.is_active() && !activation_asked) {
          target.activate(server_time());
          activation_asked = true;
        }

        if (++attempts >= PASTE_ATTEMPTS) {
          paste_timer_id = 0;
          return false;
        }

        return true;
      });
    }

    private static bool modifiers_held() {
      var keymap = Gdk.Keymap.get_for_display(Gdk.Display.get_default());
      var held = (Gdk.ModifierType) keymap.get_modifier_state();
      var modifiers = Gdk.ModifierType.SHIFT_MASK | Gdk.ModifierType.CONTROL_MASK
                      | Gdk.ModifierType.MOD1_MASK | Gdk.ModifierType.SUPER_MASK
                      | Gdk.ModifierType.MOD4_MASK | Gdk.ModifierType.META_MASK
                      | Gdk.ModifierType.HYPER_MASK;
      return (held & modifiers) != 0;
    }

    private static unowned Wnck.Window? find_wnck_window(ulong xid) {
      unowned Wnck.Screen screen = Plank.get_wnck_screen();
      screen.force_update();
      foreach (unowned Wnck.Window window in screen.get_windows()) {
        if (window.get_xid() == xid) {
          return window;
        }
      }
      return null;
    }

    private uint32 server_time() {
      DockController? controller = get_dock();
      if (controller != null && controller.window.get_window() is Gdk.X11.Window) {
        return Gdk.X11.get_server_time((Gdk.X11.Window) controller.window.get_window());
      }
      return Gtk.get_current_event_time();
    }

    private static bool is_terminal(Wnck.Window window) {
      string[] classes = {
        (window.get_class_group_name() ?? "").down(),
        (window.get_class_instance_name() ?? "").down()
      };

      foreach (var window_class in classes) {
        if (window_class in TERMINAL_CLASSES) {
          return true;
        }

        foreach (var word in GLib.Regex.split_simple("[ ._-]+", window_class)) {
          if (word in TERMINAL_WORDS) {
            return true;
          }
        }
      }

      return false;
    }

    private static void send_paste_keys(bool terminal) {
      var display = Gdk.Display.get_default() as Gdk.X11.Display;
      if (display == null) {
        return;
      }

      unowned X.Display xdisplay = display.get_xdisplay();
      uint ctrl = xdisplay.keysym_to_keycode(X.string_to_keysym("Control_L"));
      uint shift = xdisplay.keysym_to_keycode(X.string_to_keysym("Shift_L"));
      ulong v_keysym = X.string_to_keysym("v");
      uint v = xdisplay.keysym_to_keycode(v_keysym);
      if (v == 0) {
        // No Latin "v" in the keymap: use the evdev keycode of the V key
        v = EVDEV_KEYCODE_V;
      }
      if (ctrl == 0 || (terminal && shift == 0)) {
        return;
      }

      // Under a non-Latin layout the V key gives another letter and many
      // programs miss Ctrl+V: lock the group that has a Latin "v" for the
      // keystroke, then restore the user's group
      var state = new uint8[ClippyXkb.STATE_SIZE];
      int current_group = -1;
      int locked_group = -1;
      int latin_group = -1;
      if (ClippyXkb.get_state(xdisplay, ClippyXkb.USE_CORE_KBD, (void*) state) == 0) {
        current_group = state[0];
        locked_group = state[1];
        if (ClippyXkb.keycode_to_keysym(xdisplay, (uchar) v, current_group, 0) != v_keysym) {
          for (int group = 0; group < 4; group++) {
            if (ClippyXkb.keycode_to_keysym(xdisplay, (uchar) v, group, 0) == v_keysym) {
              latin_group = group;
              break;
            }
          }
        }
      }

      // GDK aborts on untrapped X errors
      display.error_trap_push();

      if (latin_group >= 0) {
        ClippyXkb.lock_group(xdisplay, ClippyXkb.USE_CORE_KBD, latin_group);
      }

      XTest.fake_key_event(xdisplay, ctrl, true, 0);
      if (terminal) {
        XTest.fake_key_event(xdisplay, shift, true, 0);
      }
      XTest.fake_key_event(xdisplay, v, true, 0);
      XTest.fake_key_event(xdisplay, v, false, 0);
      if (terminal) {
        XTest.fake_key_event(xdisplay, shift, false, 0);
      }
      XTest.fake_key_event(xdisplay, ctrl, false, 0);

      if (latin_group >= 0) {
        ClippyXkb.lock_group(xdisplay, ClippyXkb.USE_CORE_KBD, locked_group);
      }
      xdisplay.flush();
      display.error_trap_pop_ignored();
    }


    private static string history_root() {
      return GLib.Path.build_filename(GLib.Environment.get_user_data_dir(),
                                      "plank-reloaded", "clippy");
    }

    // Per-Clippy directory: a readable name plus a checksum of the .dockitem
    // path, so similar names cannot collide
    private string history_dir() {
      unowned GLib.File? file = prefs.get_backing_file();
      var path = (file != null) ? (file.get_path() ?? "") : "";
      var checksum = GLib.Checksum.compute_for_string(GLib.ChecksumType.SHA256, path);
      return "%s-%s".printf(readable_history_dir(), checksum.substring(0, 12));
    }

    private string readable_history_dir() {
      string id = "default";
      unowned GLib.File? file = prefs.get_backing_file();
      if (file != null) {
        var dock = file.get_parent()?.get_parent()?.get_basename() ?? "dock";
        var item = file.get_basename() ?? "clippy";
        if (item.has_suffix(".dockitem")) {
          item = item.substring(0, item.length - ".dockitem".length);
        }
        try {
          id = /[^A-Za-z0-9._-]/.replace("%s-%s".printf(dock, item), -1, 0, "_");
        } catch (GLib.RegexError e) {
          id = "default";
        }
      }

      return GLib.Path.build_filename(history_root(), id);
    }

    private void schedule_save() {
      if (!attached || loading_history || removed || !prefs.PersistHistory) {
        return;
      }

      if (save_timer_id > 0) {
        GLib.Source.remove(save_timer_id);
      }

      save_timer_id = GLib.Timeout.add(SAVE_DELAY, () => {
        save_timer_id = 0;
        save_history();
        return false;
      });
    }

    private void flush_history() {
      if (save_timer_id > 0) {
        GLib.Source.remove(save_timer_id);
        save_timer_id = 0;
      }
      save_history();
    }

    private static string entry_file_name(ClippyClipboardItem clip) {
      return clip.get_hash()
        + (clip.item_type == ClippyClipboardItem.Type.IMAGE ? ".png" : ".txt");
    }

    // One file per entry, named by content hash and written once; the index
    // is replaced atomically, then unlisted files are removed. Files are 0600,
    // the directory 0700
    private bool save_history() {
      if (!attached || !prefs.PersistHistory || history_discarded) {
        return false;
      }

      var dir = history_dir();
      if (GLib.DirUtils.create_with_parents(dir, 0700) != 0) {
        warning("Clippy: cannot create %s", dir);
        return false;
      }
      GLib.FileUtils.chmod(history_root(), 0700);
      GLib.FileUtils.chmod(dir, 0700);

      var index = new StringBuilder();
      var keep = new Gee.HashSet<string> ();
      // Keep the files of images still being encoded
      keep.add_all(encoding);

      try {
        var owner_path = GLib.Path.build_filename(dir, HISTORY_OWNER);
        unowned GLib.File? file = prefs.get_backing_file();
        if (file != null && file.get_path() != null) {
          GLib.FileUtils.set_contents_full(owner_path, file.get_path(), -1,
                                           GLib.FileSetContentsFlags.CONSISTENT, 0600);
        }
      } catch (Error e) {
        warning("Clippy: cannot save the history owner: %s", e.message);
      }

      foreach (var clip in clips) {
        var name = entry_file_name(clip);
        var path = GLib.Path.build_filename(dir, name);

        try {
          if (!GLib.FileUtils.test(path, GLib.FileTest.EXISTS)) {
            if (clip.item_type == ClippyClipboardItem.Type.TEXT && clip.text != null) {
              GLib.FileUtils.set_contents_full(path, clip.text, clip.text.length,
                                               GLib.FileSetContentsFlags.CONSISTENT, 0600);
            } else if (clip.item_type == ClippyClipboardItem.Type.IMAGE && clip.image != null) {
              encode_image_later(clip.image, dir, name);
              continue;
            } else {
              continue;
            }
          }

          index.append("%c %s\n".printf(
            clip.item_type == ClippyClipboardItem.Type.IMAGE ? 'I' : 'T', name));
          keep.add(name);
        } catch (Error e) {
          warning("Clippy: cannot save an entry: %s", e.message);
        }
      }

      try {
        GLib.FileUtils.set_contents_full(GLib.Path.build_filename(dir, HISTORY_INDEX),
                                         index.str, -1,
                                         GLib.FileSetContentsFlags.CONSISTENT, 0600);
      } catch (Error e) {
        warning("Clippy: cannot save the history index: %s", e.message);
        return false;
      }

      delete_history_files(dir, keep, false);
      return true;
    }

    // PNGs are encoded in a worker thread: a large screenshot would block the dock
    private void encode_image_later(Gdk.Pixbuf image, string dir, string name) {
      if (encoding.contains(name)) {
        return;
      }

      encoding.add(name);
      var path = GLib.Path.build_filename(dir, name);
      var job = new ClippyEncodeJob();

      // Created and freed on the main thread, so the worker never drops the
      // last reference to this item
      GLib.SourceFunc done = () => {
        encoding.remove(name);
        if (history_discarded || !prefs.PersistHistory) {
          GLib.FileUtils.unlink(path);
          GLib.DirUtils.remove(dir);
        } else if (job.written) {
          schedule_save();
        }
        return false;
      };

      encode_png(image, path, job, (owned) done);
    }

    // Static, so the worker thread does not capture the item
    private static void encode_png(Gdk.Pixbuf image, string path, ClippyEncodeJob job,
                                   owned GLib.SourceFunc done) {
      var finish = new ClippyEncodeDone((owned) done);
      new GLib.Thread<bool> ("clippy-png", () => {
        try {
          uint8[] png;
          image.save_to_bufferv(out png, "png", null, null);
          GLib.FileUtils.set_contents_full(path, (string) png, png.length,
                                           GLib.FileSetContentsFlags.CONSISTENT, 0600);
          job.written = true;
        } catch (Error e) {
          warning("Clippy: cannot save an image: %s", e.message);
        }

        finish.schedule();
        return job.written;
      });
    }

    // Removes histories whose .dockitem no longer exists
    private static void sweep_orphan_histories() {
      var root = history_root();
      try {
        var handle = GLib.Dir.open(root);
        unowned string? name;
        while ((name = handle.read_name()) != null) {
          var dir = GLib.Path.build_filename(root, name);
          string owner;
          try {
            if (!GLib.FileUtils.get_contents(GLib.Path.build_filename(dir, HISTORY_OWNER), out owner)) {
              continue;
            }
          } catch (Error e) {
            continue;
          }

          owner = owner.strip();
          if (owner != "" && !GLib.FileUtils.test(owner, GLib.FileTest.EXISTS)) {
            delete_history_files(dir, null, true);
          }
        }
      } catch (GLib.FileError e) {
        return;
      }
    }

    private void load_history() {
      if (!prefs.PersistHistory) {
        return;
      }

      read_history(history_dir());

      while (clips.size > prefs.MaxEntries) {
        clips.remove_at(0);
      }
      trim_images();
    }

    // Returns false when dir has no index
    private bool read_history(string dir) {
      string contents;
      try {
        if (!GLib.FileUtils.get_contents(GLib.Path.build_filename(dir, HISTORY_INDEX), out contents)) {
          return false;
        }
      } catch (Error e) {
        return false;
      }

      loading_history = true;
      foreach (var line in contents.split("\n")) {
        if (line.length < 3 || line[1] != ' ') {
          continue;
        }

        var name = line.substring(2);
        if ("/" in name || name.has_prefix(".")) {
          continue;
        }

        var path = GLib.Path.build_filename(dir, name);
        try {
          if (line[0] == 'T') {
            string text;
            GLib.FileUtils.get_contents(path, out text);
            // Skip damaged files
            if (text != "" && text.length <= MAX_LOADED_TEXT && text.validate()) {
              clips.add(new ClippyClipboardItem.with_text(text));
            }
          } else if (line[0] == 'I') {
            clips.add(new ClippyClipboardItem.with_image(new Gdk.Pixbuf.from_file(path)));
          }
        } catch (Error e) {
          warning("Clippy: skipping a saved entry: %s", e.message);
        }
      }
      loading_history = false;

      return true;
    }

    // Removes only files this code writes that are not in keep; with keep
    // null, also the index and the owner file
    private static void delete_history_files(string dir, Gee.Set<string>? keep, bool remove_dir) {
      try {
        var handle = GLib.Dir.open(dir);
        unowned string? name;
        var entry = /^[0-9a-f]{64}\.(txt|png)$/;
        // Leftovers of an interrupted atomic write
        var leftover = /^([0-9a-f]{64}\.(txt|png)|index|owner)\.[A-Za-z0-9]{6}$/;
        while ((name = handle.read_name()) != null) {
          bool remove;
          if (leftover.match(name)) {
            var target = name.substring(0, name.last_index_of_char('.'));
            remove = keep == null || !keep.contains(target);
          } else {
            remove = (keep == null && (name == HISTORY_INDEX || name == HISTORY_OWNER))
              || (entry.match(name) && (keep == null || !keep.contains(name)));
          }
          if (remove) {
            GLib.FileUtils.unlink(GLib.Path.build_filename(dir, name));
          }
        }
      } catch (GLib.FileError e) {
        return;
      }

      if (remove_dir) {
        GLib.DirUtils.remove(dir);
      }
    }

    private void toggle_persist_history() {
      prefs.PersistHistory = !prefs.PersistHistory;

      if (prefs.PersistHistory) {
        flush_history();
      } else {
        if (save_timer_id > 0) {
          GLib.Source.remove(save_timer_id);
          save_timer_id = 0;
        }
        delete_history_files(history_dir(), null, true);
      }
    }

    // An entry evicted while the window was open is still copied and becomes
    // the newest again
    private void copy_item(ClippyClipboardItem clip) {
      clip.copy_to_clipboard(regular_clipboard);

      if (clips.contains(clip)) {
        clips.remove(clip);
        clips.add(clip);
        update_display();
      } else {
        process_clipboard_item(clip);
      }
    }

    private void clear_clipboard() {
      regular_clipboard.set_text("", 0);
      regular_clipboard.clear();
      primary_clipboard.set_text("", 0);
      primary_clipboard.clear();

      clips.clear();
      update_display();

      // Write at once, so cleared entries do not survive a crash or a logout
      if (prefs.PersistHistory) {
        flush_history();
      }
    }

    protected override AnimationType on_clicked(PopupButton button,
                                                Gdk.ModifierType mod,
                                                uint32 event_time) {
      if (button == PopupButton.LEFT) {
        // With an empty history only bounce, unless the window is open
        if (clips.size == 0 && popup == null) {
          return AnimationType.BOUNCE;
        }

        show_popup(event_time);

        return AnimationType.NONE;
      }

      return AnimationType.NONE;
    }

    private static Gtk.MenuItem create_choice_item(string label, string[] choices,
                                                   uint current, owned ClippyChoiceSetter setter) {
      var item = new Gtk.MenuItem.with_label(label);
      var submenu = new Gtk.Menu();
      unowned GLib.SList<Gtk.RadioMenuItem> group = null;

      for (uint i = 0; i < choices.length; i++) {
        var choice = new Gtk.RadioMenuItem.with_label(group, choices[i]);
        // GTK prepends to the group list: take its new head every time
        group = choice.get_group();
        choice.active = (i == current);
        choice.set_data<uint>("clippy-choice", i);
        choice.toggled.connect((radio) => {
          if (radio.active) {
            setter(radio.get_data<uint>("clippy-choice"));
          }
        });
        submenu.append(choice);
      }

      submenu.show_all();
      item.set_submenu(submenu);
      return item;
    }

    public override Gee.ArrayList<Gtk.MenuItem> get_menu_items() {
      var items = new Gee.ArrayList<Gtk.MenuItem> ();

      var track_clipboard = new Gtk.CheckMenuItem.with_label(TRACK_CLIPBOARD_LABEL);
      track_clipboard.active = !prefs.DisableTracking;
      track_clipboard.toggled.connect(() => {
        toggle_clipboard_tracking();
      });
      items.add(track_clipboard);

      var track_selections = new Gtk.CheckMenuItem.with_label(TRACK_SELECTION_LABEL);
      track_selections.active = prefs.TrackMouseSelections;
      track_selections.sensitive = !prefs.DisableTracking;
      track_selections.toggled.connect(() => {
        toggle_selection_tracking();
      });
      items.add(track_selections);

      var track_images = new Gtk.CheckMenuItem.with_label(TRACK_IMAGES_LABEL);
      track_images.active = prefs.TrackImages;
      track_images.sensitive = !prefs.DisableTracking;
      track_images.toggled.connect(() => {
        toggle_image_tracking();
      });
      items.add(track_images);

      items.add(new Gtk.SeparatorMenuItem());

      var max_entries_item = new Gtk.MenuItem.with_label(MAX_ENTRIES_LABEL);
      var max_entries_menu = new Gtk.Menu();

      int[] entry_counts = { 5, 10, 15, 20, 25, 50, 100 };
      unowned GLib.SList<Gtk.RadioMenuItem> group = null;

      foreach (var count in entry_counts) {
        var item = new Gtk.RadioMenuItem.with_label(group, count.to_string());
        group = item.get_group();

        if (prefs.MaxEntries == count) {
          item.active = true;
        }

        item.toggled.connect(() => {
          if (item.active) {
            set_max_entries(count);
          }
        });

        max_entries_menu.append(item);
      }

      max_entries_menu.show_all();
      max_entries_item.set_submenu(max_entries_menu);
      items.add(max_entries_item);

      items.add(create_choice_item(_("Preview Size"),
        { _("Small"), _("Medium"), _("Large") },
        prefs.PreviewSize, (choice) => prefs.PreviewSize = choice));

      items.add(create_choice_item(_("Hotkey Opens It"),
        { _("At the Active Window"), _("At the Pointer"), _("At the Screen Centre") },
        prefs.HotkeyPosition, (choice) => prefs.HotkeyPosition = choice));

      items.add(new Gtk.SeparatorMenuItem());

      var paste_now = new Gtk.CheckMenuItem.with_label(_("Paste Right Away"));
      paste_now.active = prefs.PasteOnSelect;
      paste_now.toggled.connect(() => {
        prefs.PasteOnSelect = !prefs.PasteOnSelect;
      });
      items.add(paste_now);

      var persist = new Gtk.CheckMenuItem.with_label(_("Keep History After Restart"));
      persist.active = prefs.PersistHistory;
      persist.toggled.connect(() => {
        toggle_persist_history();
      });
      items.add(persist);

      return items;
    }
  }
}
