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
  private static bool keybinder_initialized = false;

  public class ClippyDockItem : DockletItem {
    private const string EMPTY_CLIPBOARD_TEXT = _("Clipboard is currently empty.");
    private const string CLEAR_MENU_LABEL = _("_Clear");
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
    private uint debounce_timeout_id = 0;
    private const uint DEBOUNCE_DELAY = 500;
    private string? current_hotkey = null;

    private ClippyPreferences prefs {
      get { return (ClippyPreferences) Prefs; }
    }

    public ClippyDockItem.with_dockitem_file(GLib.File file)
    {
      GLib.Object(Prefs: new ClippyPreferences.with_file(file));
    }

    construct
    {
      Icon = ClippyDocklet.ICON;
      clips = new Gee.ArrayList<ClippyClipboardItem> ();
      initialize_clipboards();
      // Defer hotkey initialization to ensure GTK main loop is running
      GLib.Idle.add(() => {
        initialize_hotkey();
        return false;
      });
      update_display();
    }

    ~ClippyDockItem() {
      disconnect_clipboards();
      unbind_hotkey();

      if (debounce_timeout_id > 0) {
        GLib.Source.remove(debounce_timeout_id);
        debounce_timeout_id = 0;
      }

      if (popup_window != null) {
        popup_window.destroy();
        popup_window = null;
        popup_button = null;
      }
    }

    private void initialize_clipboards() {
      primary_clipboard = Gtk.Clipboard.get(Gdk.Atom.intern("PRIMARY", true));
      regular_clipboard = Gtk.Clipboard.get(Gdk.Atom.intern("CLIPBOARD", true));
      connect_clipboards();
    }

    private void initialize_hotkey() {
      if (!keybinder_initialized) {
        Keybinder.init();
        keybinder_initialized = true;

        if (!Keybinder.supported()) {
          warning("Keybinder is not supported on this system");
          return;
        }
      }

      prefs.notify["Hotkey"].connect(() => {
        update_hotkey_binding();
      });

      update_hotkey_binding();
    }

    private void update_hotkey_binding() {
      unbind_hotkey();

      if (prefs.Hotkey != null && prefs.Hotkey.strip() != "") {
        bind_hotkey(prefs.Hotkey);
      }
    }

    private void bind_hotkey(string keystring) {
      bool success = Keybinder.bind(keystring, on_hotkey_pressed, this);
      if (success) {
        current_hotkey = keystring;
      } else {
        warning("Failed to bind hotkey: %s", keystring);
      }
    }

    private void unbind_hotkey() {
      if (current_hotkey != null) {
        Keybinder.unbind_all(current_hotkey);
        current_hotkey = null;
      }
    }

    private static void on_hotkey_pressed(string keystring, void* user_data) {
      unowned ClippyDockItem? self = (ClippyDockItem?) user_data;
      if (self != null) {
        self.show_clipboard_menu_at_pointer();
      }
    }

    private int pos_x;
    private int pos_y;
    private Gtk.Window? popup_window = null;
    private Gtk.Button? popup_button = null;
    private Gee.ArrayList<Gtk.Button>? menu_buttons = null;
    private int current_button_index = 0;

    private void show_clipboard_menu_at_pointer() {
      if (clips.size == 0) {
        return;
      }

      // Create a toplevel window to act as our menu
      var menu_window = new Gtk.Window(Gtk.WindowType.POPUP);
      menu_window.set_type_hint(Gdk.WindowTypeHint.POPUP_MENU);
      menu_window.set_decorated(false);
      menu_window.set_skip_taskbar_hint(true);
      menu_window.set_skip_pager_hint(true);
      menu_window.set_resizable(false);
      menu_window.set_keep_above(true);

      // Create a vertical box to hold menu items
      var vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
      vbox.get_style_context().add_class("menu");
      menu_window.add(vbox);

      // List to track buttons for keyboard navigation
      menu_buttons = new Gee.ArrayList<Gtk.Button>();

      // Build clipboard items list (in reverse order - newest first)
      for (int i = clips.size - 1; i >= 0; i--) {
        var index = i;
        var clip = clips.get(index);

        var button = new Gtk.Button();
        button.set_relief(Gtk.ReliefStyle.NONE);
        button.set_can_focus(true);
        button.set_alignment(0.0f, 0.5f);

        // Get display text from clip
        if (clip.item_type == ClippyClipboardItem.Type.IMAGE) {
          button.set_label("Image");
        } else {
          button.set_label(clip.get_display_text(MAX_CLIP_MENU_ITEM_LENGTH));
        }

        button.clicked.connect(() => {
          copy_item_at(index);
          Gdk.pointer_ungrab(Gdk.CURRENT_TIME);
          Gdk.keyboard_ungrab(Gdk.CURRENT_TIME);
          menu_window.hide();
          menu_window.destroy();
        });

        menu_buttons.add(button);
        vbox.pack_start(button, false, false, 0);
      }

      // Add separator and clear button if we have items
      if (clips.size > 0) {
        var separator = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
        vbox.pack_start(separator, false, false, 2);

        var clear_button = new Gtk.Button.with_label("Clear");
        clear_button.set_relief(Gtk.ReliefStyle.NONE);
        clear_button.set_can_focus(true);
        clear_button.set_alignment(0.0f, 0.5f);
        clear_button.clicked.connect(() => {
          clear_clipboard();
          Gdk.pointer_ungrab(Gdk.CURRENT_TIME);
          Gdk.keyboard_ungrab(Gdk.CURRENT_TIME);
          menu_window.hide();
          menu_window.destroy();
        });
        menu_buttons.add(clear_button);
        vbox.pack_start(clear_button, false, false, 0);
      }

      // Get pointer position
      var display = Gdk.Display.get_default();
      var seat = display.get_default_seat();
      var pointer = seat.get_pointer();

      Gdk.Screen screen;
      pointer.get_position(out screen, out pos_x, out pos_y);

      // Get event time
      uint32 event_time = Keybinder.get_current_event_time();
      if (event_time == 0) {
        event_time = Gtk.get_current_event_time();
      }

      // Release any existing grabs
      Gdk.pointer_ungrab(event_time);
      Gdk.keyboard_ungrab(event_time);

      // Wait a bit for grabs to release
      Thread.usleep(50000); // 50ms

      // Position and show the menu window
      menu_window.move(pos_x, pos_y);
      menu_window.show_all();

      // Set up event mask to receive all events
      menu_window.add_events(
        Gdk.EventMask.KEY_PRESS_MASK |
        Gdk.EventMask.FOCUS_CHANGE_MASK |
        Gdk.EventMask.BUTTON_PRESS_MASK
      );

      // Grab keyboard and pointer for the menu window
      var menu_gdk_window = menu_window.get_window();
      if (menu_gdk_window != null) {
        var grab_status = Gdk.pointer_grab(
          menu_gdk_window,
          true,
          Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.BUTTON_RELEASE_MASK,
          null,
          null,
          event_time
        );

        // Retry keyboard grab multiple times
        var kbd_grab = Gdk.GrabStatus.FAILED;
        for (int retry = 0; retry < 5; retry++) {
          kbd_grab = Gdk.keyboard_grab(menu_gdk_window, true, Gdk.CURRENT_TIME);
          if (kbd_grab == Gdk.GrabStatus.SUCCESS) {
            break;
          }
          Thread.usleep(10000); // 10ms between retries
        }
      }

      // Make window modal and grab focus
      menu_window.set_modal(true);
      menu_window.set_accept_focus(true);
      menu_window.present();
      menu_window.grab_focus();

      // Focus first button
      if (menu_buttons != null && menu_buttons.size > 0) {
        current_button_index = 0;
        menu_buttons.get(0).grab_focus();
      }

      // Process events to ensure window is visible
      while (Gtk.events_pending()) {
        Gtk.main_iteration();
      }

      // Close menu when focus is lost
      menu_window.focus_out_event.connect(() => {
        Gdk.pointer_ungrab(Gdk.CURRENT_TIME);
        Gdk.keyboard_ungrab(Gdk.CURRENT_TIME);
        menu_window.hide();
        menu_window.destroy();
        return false;
      });

      // Handle keyboard navigation and close
      menu_window.key_press_event.connect((event) => {
        if (event.keyval == Gdk.Key.Escape) {
          Gdk.pointer_ungrab(Gdk.CURRENT_TIME);
          Gdk.keyboard_ungrab(Gdk.CURRENT_TIME);
          menu_window.hide();
          menu_window.destroy();
          return true;
        }

        // Arrow key navigation
        if (menu_buttons != null && menu_buttons.size > 0) {
          if (event.keyval == Gdk.Key.Down || event.keyval == Gdk.Key.Tab) {
            current_button_index = (current_button_index + 1) % menu_buttons.size;
            menu_buttons.get(current_button_index).grab_focus();
            return true;
          } else if (event.keyval == Gdk.Key.Up || event.keyval == Gdk.Key.ISO_Left_Tab) {
            current_button_index = (current_button_index - 1 + menu_buttons.size) % menu_buttons.size;
            menu_buttons.get(current_button_index).grab_focus();
            return true;
          } else if (event.keyval == Gdk.Key.Return || event.keyval == Gdk.Key.KP_Enter) {
            // Activate the currently focused button
            menu_buttons.get(current_button_index).clicked();
            return true;
          }
        }

        return false;
      });

      // Close menu when clicking outside - use global button press
      menu_window.button_press_event.connect((event) => {
        // Get window size
        int width, height;
        menu_window.get_size(out width, out height);

        // Check if click is outside the window bounds
        if (event.x < 0 || event.x >= width || event.y < 0 || event.y >= height) {
          Gdk.pointer_ungrab(Gdk.CURRENT_TIME);
          Gdk.keyboard_ungrab(Gdk.CURRENT_TIME);
          menu_window.hide();
          menu_window.destroy();
          return true;
        }
        return false;
      });

      // Also monitor root window for clicks
      var root_window = menu_window.get_screen().get_root_window();
      root_window.add_filter((xevent, event) => {
        if (event.type == Gdk.EventType.BUTTON_PRESS) {
          // Check if the event is outside our menu window
          int menu_x, menu_y, menu_width, menu_height;
          menu_window.get_position(out menu_x, out menu_y);
          menu_window.get_size(out menu_width, out menu_height);

          var button_event = (Gdk.EventButton) event;
          if (button_event.x_root < menu_x || button_event.x_root >= menu_x + menu_width ||
              button_event.y_root < menu_y || button_event.y_root >= menu_y + menu_height) {
            Gdk.pointer_ungrab(Gdk.CURRENT_TIME);
            Gdk.keyboard_ungrab(Gdk.CURRENT_TIME);
            menu_window.hide();
            menu_window.destroy();
          }
        }
        return Gdk.FilterReturn.CONTINUE;
      });
    }

    private void connect_clipboards() {
      if (!prefs.DisableTracking) {
        regular_handler_id = regular_clipboard.owner_change.connect((clipboard, ev) => {
          request_clipboard_content(regular_clipboard);
        });

        primary_handler_id = primary_clipboard.owner_change.connect((clipboard, ev) => {
          if (prefs.TrackMouseSelections) {
            request_clipboard_content(primary_clipboard);
          }
        });
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

    private void set_hotkey(string hotkey) {
      prefs.Hotkey = hotkey;
    }

    private void request_clipboard_content(Gtk.Clipboard source_clipboard) {
      if (debounce_timeout_id > 0) {
        GLib.Source.remove(debounce_timeout_id);
        debounce_timeout_id = 0;
      }

      debounce_timeout_id = GLib.Timeout.add(DEBOUNCE_DELAY, () => {
        debounce_timeout_id = 0;

        if (prefs.TrackImages) {
          source_clipboard.request_image(handle_image_result);
        } else {
          request_clipboard_text(source_clipboard);
        }

        return false;
      });
    }

    private void request_clipboard_text(Gtk.Clipboard source_clipboard) {
      source_clipboard.request_text(handle_text_result);
    }

    private void handle_text_result(Gtk.Clipboard cb, string? text) {
      if (text != null && text != "") {
        var item = new ClippyClipboardItem.with_text(text);
        process_clipboard_item(item);
      }
    }

    private void handle_image_result(Gtk.Clipboard cb, Gdk.Pixbuf? pixbuf) {
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

      update_display();
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
    }

    private void copy_item_at(int index) {
      if (index < 0 || index >= clips.size) {
        return;
      }

      var item = clips.get(index);
      item.copy_to_clipboard(regular_clipboard);

      clips.remove_at(index);
      clips.add(item);

      update_display();
    }

    private void clear_clipboard() {
      regular_clipboard.set_text("", 0);
      regular_clipboard.clear();
      primary_clipboard.set_text("", 0);
      primary_clipboard.clear();

      clips.clear();
      update_display();
    }

    private void on_menu_show() {
      DockController? controller = get_dock();
      if (controller == null) {
        return;
      }

      controller.window.update_hovered(0, 0);
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
        controller.window.update_hovered(0, 0);
      }
    }

    protected override AnimationType on_clicked(PopupButton button,
                                                Gdk.ModifierType mod,
                                                uint32 event_time) {
      if (button == PopupButton.LEFT) {
        if (clips.size == 0) {
          return AnimationType.BOUNCE;
        }

        DockController? controller = get_dock();
        if (controller == null) {
          return AnimationType.NONE;
        }

        var menu = new Gtk.Menu();
        menu.show.connect(on_menu_show);
        menu.hide.connect(on_menu_hide);
        menu.attach_to_widget(controller.window, null);

        foreach (var item in get_clipboard_menu_items()) {
          menu.append(item);
        }

        menu.show_all();

        Gtk.Requisition requisition;
        menu.get_preferred_size(null, out requisition);

        int x, y;
        controller.position_manager.get_menu_position(this, requisition, out x, out y);

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

        return AnimationType.NONE;
      }

      return AnimationType.NONE;
    }

    private Gee.ArrayList<Gtk.MenuItem> get_clipboard_menu_items() {
      var items = new Gee.ArrayList<Gtk.MenuItem> ();

      for (int i = clips.size - 1; i >= 0; i--) {
        var index = i;
        var clip = clips.get(index);

        var item = clip.create_menu_item();

        item.activate.connect(() => {
          copy_item_at(index);
        });
        items.add(item);
      }

      if (clips.size > 0) {
        var separator = new Gtk.SeparatorMenuItem();
        items.add(separator);

        var clear_item = create_menu_item(CLEAR_MENU_LABEL);
        clear_item.activate.connect(clear_clipboard);
        items.add(clear_item);
      }

      return items;
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

      int[] entry_counts = { 5, 10, 15, 20, 25 };
      unowned GLib.SList<Gtk.RadioMenuItem> group = null;

      foreach (var count in entry_counts) {
        var item = new Gtk.RadioMenuItem.with_label(group, count.to_string());

        if (group == null)
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

      items.add(new Gtk.SeparatorMenuItem());

      var hotkey_item = new Gtk.MenuItem.with_label(_("Set Hotkey..."));
      hotkey_item.activate.connect(() => {
        show_hotkey_dialog();
      });
      items.add(hotkey_item);

      return items;
    }

    private void show_hotkey_dialog() {
      DockController? controller = get_dock();
      if (controller == null) {
        return;
      }

      var dialog = new Gtk.Dialog.with_buttons(
        _("Set Clipboard Hotkey"),
        null,
        Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT,
        _("_Clear"), Gtk.ResponseType.REJECT,
        _("_Cancel"), Gtk.ResponseType.CANCEL,
        _("_OK"), Gtk.ResponseType.OK
      );

      dialog.set_default_response(Gtk.ResponseType.OK);
      dialog.set_border_width(12);

      var content = dialog.get_content_area();
      var label = new Gtk.Label(_("Press the key combination you want to use:"));
      label.xalign = 0;
      content.pack_start(label, false, false, 6);

      var entry = new Gtk.Entry();
      entry.set_placeholder_text(_("e.g., <Super>v or <Ctrl><Alt>c"));
      entry.text = prefs.Hotkey;
      entry.editable = false;
      entry.can_focus = true;
      content.pack_start(entry, false, false, 6);

      var info_label = new Gtk.Label(_("Examples: <Super>v, <Ctrl><Alt>c, <Shift><Super>Insert"));
      info_label.xalign = 0;
      info_label.get_style_context().add_class("dim-label");
      info_label.wrap = true;
      content.pack_start(info_label, false, false, 6);

      string captured_key = prefs.Hotkey;

      entry.key_press_event.connect((event) => {
        var keyval = event.keyval;
        var modifiers = event.state & Gtk.accelerator_get_default_mod_mask();

        // Skip modifier-only presses
        if (keyval == Gdk.Key.Shift_L || keyval == Gdk.Key.Shift_R ||
            keyval == Gdk.Key.Control_L || keyval == Gdk.Key.Control_R ||
            keyval == Gdk.Key.Alt_L || keyval == Gdk.Key.Alt_R ||
            keyval == Gdk.Key.Super_L || keyval == Gdk.Key.Super_R ||
            keyval == Gdk.Key.Meta_L || keyval == Gdk.Key.Meta_R) {
          return true;
        }

        // Build the accelerator string
        var key_name = Gtk.accelerator_name(keyval, modifiers);
        if (key_name != null && key_name != "") {
          captured_key = key_name;
          entry.text = key_name;
        }

        return true;
      });

      content.show_all();

      int response = dialog.run();

      if (response == Gtk.ResponseType.OK) {
        if (captured_key != null && captured_key.strip() != "") {
          set_hotkey(captured_key);
        }
      } else if (response == Gtk.ResponseType.REJECT) {
        set_hotkey("");
      }

      dialog.destroy();
    }
  }
}
