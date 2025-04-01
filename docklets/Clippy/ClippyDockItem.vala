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
  public class ClippyDockItem : DockletItem {
    private const string EMPTY_CLIPBOARD_TEXT = _("Clipboard is currently empty.");
    private const string CLEAR_MENU_LABEL = _("_Clear");
    private const int MAX_CLIP_MENU_ITEM_LENGTH = 80;

    private const string TRACK_SELECTION_LABEL = _("Track Mouse Selections");
    private const string TRACK_IMAGES_LABEL = _("Track Images");
    private const string TRACK_CLIPBOARD_LABEL = _("Enable Clipboard Tracking");
    private const string MAX_ENTRIES_LABEL = _("Maximum Entries");

    private Gtk.Clipboard clipboard;
    private Gee.ArrayList<ClippyClipboardItem> clips;
    private ulong handler_id = 0U;
    private uint debounce_timeout_id = 0;
    private const uint DEBOUNCE_DELAY = 500;

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
      initialize_clipboard();
      update_display();
    }

    ~ClippyDockItem() {
      disconnect_clipboard();

      if (debounce_timeout_id > 0) {
        GLib.Source.remove(debounce_timeout_id);
        debounce_timeout_id = 0;
      }
    }

    private void initialize_clipboard() {
      var atom_name = prefs.TrackMouseSelections ? "PRIMARY" : "CLIPBOARD";
      clipboard = Gtk.Clipboard.get(Gdk.Atom.intern(atom_name, true));
      connect_clipboard();
    }

    private void connect_clipboard() {
      if (!prefs.DisableTracking) {
        handler_id = clipboard.owner_change.connect((clipboard, ev) => {
          request_clipboard_content();
        });
      }
    }

    private void disconnect_clipboard() {
      if (handler_id > 0U) {
        clipboard.disconnect(handler_id);
        handler_id = 0U;
      }
    }

    private void toggle_clipboard_tracking() {
      prefs.DisableTracking = !prefs.DisableTracking;

      disconnect_clipboard();
      connect_clipboard();
    }

    private void toggle_selection_tracking() {
      prefs.TrackMouseSelections = !prefs.TrackMouseSelections;

      disconnect_clipboard();
      initialize_clipboard();
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

    private void request_clipboard_content() {
      if (debounce_timeout_id > 0) {
        GLib.Source.remove(debounce_timeout_id);
        debounce_timeout_id = 0;
      }

      debounce_timeout_id = GLib.Timeout.add(DEBOUNCE_DELAY, () => {
        debounce_timeout_id = 0;

        if (prefs.TrackImages) {
          clipboard.request_image(handle_image_result);
        } else {
          request_clipboard_text();
        }

        return false;
      });
    }

    private void handle_image_result(Gtk.Clipboard cb, Gdk.Pixbuf? pixbuf) {
      if (pixbuf != null && pixbuf.get_width() > 0 && pixbuf.get_height() > 0) {
        var item = new ClippyClipboardItem.with_image(pixbuf);
        process_clipboard_item(item);
      } else {
        request_clipboard_text();
      }
    }

    private void request_clipboard_text() {
      clipboard.request_text((cb, text) => {
        if (text != null && text != "") {
          var item = new ClippyClipboardItem.with_text(text);
          process_clipboard_item(item);
        }
      });
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
      item.copy_to_clipboard(clipboard);

      clips.remove_at(index);
      clips.add(item);

      update_display();
    }

    private void clear_clipboard() {
      clipboard.set_text("", 0);
      clipboard.clear();
      clips.clear();
      update_display();
    }

    private void on_menu_show() {
      DockController? controller = get_dock();
      if (controller == null) {
        return;
      }

      controller.window.update_icon_regions();
      controller.hover.hide();
      controller.renderer.animated_draw();
    }

    private void on_menu_hide() {
      DockController? controller = get_dock();
      if (controller == null) {
        return;
      }

      controller.window.update_icon_regions();
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
        default:
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

      return items;
    }
  }
}
