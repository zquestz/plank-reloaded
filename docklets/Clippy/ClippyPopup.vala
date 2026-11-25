//
// Copyright (C) 2026 Plank Reloaded Developers
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
  /**
   * Where the history window opens.
   */
  public enum ClippyPlacement {
    /** Centred on the active window. */
    ACTIVE_WINDOW,
    /** Next to the pointer. */
    POINTER,
    /** Centre of the monitor with the pointer. */
    SCREEN_CENTER,
    /** At the dock icon that was clicked. */
    DOCK_ICON
  }

  /**
   * Clipboard history with previews of text, images and hex colors. Driven
   * by the keyboard; closes when it loses the focus.
   */
  public class ClippyPopup : Gtk.Window {
    private const int POINTER_GAP = 12;

    // Small, medium, large: window width, text lines, characters per line,
    // image height, list height cap
    private const int[] SIZE_WIDTH = { 340, 400, 560 };
    private const int[] SIZE_LINES = { 2, 4, 8 };
    private const int[] SIZE_CHARS = { 34, 42, 60 };
    private const int[] SIZE_IMAGE_HEIGHT = { 80, 150, 280 };
    private const int[] SIZE_MAX_HEIGHT = { 420, 520, 760 };

    private int WIDTH;
    private int MAX_HEIGHT;
    private int PREVIEW_LINES;
    private int IMAGE_MAX_WIDTH;
    private int IMAGE_MAX_HEIGHT;
    private int TEXT_WIDTH_CHARS;

    /**
     * The window that was active when the history opened, to paste into;
     * 0 if none.
     */
    public ulong target_xid { get; private set; default = 0; }

    private const string CSS = """
      .clippy-popup { background-color: @theme_bg_color; border: 1px solid @borders; }
      .clippy-popup list { background: transparent; }
      .clippy-popup row { padding: 8px 10px; border-radius: 6px; }
      .clippy-popup .clippy-number { opacity: 0.5; font-size: 90%; }
      .clippy-popup .clippy-meta { opacity: 0.6; font-size: 85%; }
      .clippy-popup .clippy-title { font-weight: bold; }
    """;

    // Header, hint and margins
    private const int CHROME_HEIGHT = 110;
    private const uint FOCUS_CHECK_DELAY = 400;

    // Added to the screen once per process
    private static Gtk.CssProvider? css_provider = null;

    public signal void item_chosen (ClippyClipboardItem item);
    public signal void clear_requested ();

    private Gtk.ListBox list;
    private Gtk.ScrolledWindow scroller;
    private bool paste_mode;
    private uint focus_check_id = 0U;
    private Gee.ArrayList<ClippyClipboardItem> items;
    private bool closing = false;

    // Set when the window closed on focus loss (for the reopen guard)
    public bool closed_by_focus_loss { get; private set; default = false; }

    // Enter and 1-9 act on key release, so the key's auto-repeat cannot reach
    // the window the entry is pasted into
    private uint pending_key = 0U;
    private int pending_index = -1;

    /**
     * @param clips the history, newest first
     * @param preview_size 0 small, 1 medium, 2 large
     * @param paste_mode whether choosing an entry also pastes it
     */
    public ClippyPopup (Gee.List<ClippyClipboardItem> clips, uint preview_size, bool paste_mode) {
      GLib.Object (type: Gtk.WindowType.TOPLEVEL);
      this.paste_mode = paste_mode;

      int size = (int) uint.min (preview_size, 2);
      WIDTH = SIZE_WIDTH[size];
      MAX_HEIGHT = SIZE_MAX_HEIGHT[size];
      PREVIEW_LINES = SIZE_LINES[size];
      IMAGE_MAX_WIDTH = WIDTH - 48;
      IMAGE_MAX_HEIGHT = SIZE_IMAGE_HEIGHT[size];
      TEXT_WIDTH_CHARS = SIZE_CHARS[size];

      items = new Gee.ArrayList<ClippyClipboardItem> ();
      items.add_all (clips);

      decorated = false;
      resizable = false;
      skip_taskbar_hint = true;
      skip_pager_hint = true;
      type_hint = Gdk.WindowTypeHint.DIALOG;
      set_keep_above (true);
      title = _("Clipboard");

      get_style_context ().add_class ("clippy-popup");
      install_css (get_screen ());

      build_ui ();

      key_press_event.connect (on_key_press);
      key_release_event.connect (on_key_release);
      focus_out_event.connect (() => {
        closed_by_focus_loss = true;
        close_popup ();
        return false;
      });
      destroy.connect (() => {
        if (focus_check_id > 0U) {
          GLib.Source.remove (focus_check_id);
          focus_check_id = 0U;
        }
      });
    }

    private static void install_css (Gdk.Screen screen) {
      if (css_provider != null) {
        return;
      }

      css_provider = new Gtk.CssProvider ();
      try {
        css_provider.load_from_data (CSS);
        Gtk.StyleContext.add_provider_for_screen (screen, css_provider,
                                                  Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
      } catch (Error e) {
        warning ("Clippy CSS: %s", e.message);
      }
    }

    private void build_ui () {
      var outer = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
      outer.margin = 8;

      var header = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
      var title_label = new Gtk.Label (_("Clipboard"));
      title_label.get_style_context ().add_class ("clippy-title");
      title_label.halign = Gtk.Align.START;
      header.pack_start (title_label, true, true, 0);

      var clear_button = new Gtk.Button.with_label (_("Clear All"));
      clear_button.relief = Gtk.ReliefStyle.NONE;
      clear_button.can_focus = false;
      clear_button.sensitive = items.size > 0;
      clear_button.clicked.connect (() => {
        clear_requested ();
        close_popup ();
      });
      header.pack_end (clear_button, false, false, 0);
      outer.pack_start (header, false, false, 0);

      list = new Gtk.ListBox ();
      list.selection_mode = Gtk.SelectionMode.BROWSE;
      list.activate_on_single_click = true;
      list.row_activated.connect ((row) => choose (row.get_index ()));

      if (items.size == 0) {
        var empty = new Gtk.Label (_("Clipboard is currently empty."));
        empty.margin = 16;
        empty.get_style_context ().add_class ("clippy-meta");
        list.set_placeholder (empty);
        empty.show ();
      }

      for (int i = 0; i < items.size; i++) {
        list.add (create_row (items[i], i));
      }

      scroller = new Gtk.ScrolledWindow (null, null);
      scroller.hscrollbar_policy = Gtk.PolicyType.NEVER;
      scroller.vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
      scroller.propagate_natural_height = true;
      scroller.max_content_height = MAX_HEIGHT;
      scroller.add (list);
      outer.pack_start (scroller, true, true, 0);

      var hint = new Gtk.Label (paste_mode
        ? _("Enter or click: paste  ·  1–9: quick pick  ·  Esc: close")
        : _("Enter or click: copy  ·  1–9: quick pick  ·  Esc: close"));
      hint.get_style_context ().add_class ("clippy-meta");
      outer.pack_start (hint, false, false, 0);

      add (outer);
      set_size_request (WIDTH, -1);
    }

    private Gtk.ListBoxRow create_row (ClippyClipboardItem item, int index) {
      var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);

      var number = new Gtk.Label (index < 9 ? (index + 1).to_string () : "");
      number.get_style_context ().add_class ("clippy-number");
      number.valign = Gtk.Align.START;
      number.width_chars = 1;
      box.pack_start (number, false, false, 0);

      var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 4);

      if (item.item_type == ClippyClipboardItem.Type.IMAGE && item.image != null) {
        var preview = new Gtk.Image.from_pixbuf (item.get_preview (IMAGE_MAX_WIDTH, IMAGE_MAX_HEIGHT));
        preview.halign = Gtk.Align.START;
        content.pack_start (preview, false, false, 0);

        var meta = new Gtk.Label (_("Image %d×%d").printf (item.image.get_width (), item.image.get_height ()));
        meta.halign = Gtk.Align.START;
        meta.get_style_context ().add_class ("clippy-meta");
        content.pack_start (meta, false, false, 0);
      } else {
        var line = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);

        var color = item.parse_hex_color ();
        if (color != null) {
          var swatch = new Gtk.DrawingArea ();
          swatch.set_size_request (18, 18);
          swatch.valign = Gtk.Align.START;
          swatch.draw.connect ((cr) => {
            cr.set_source_rgba (color.red, color.green, color.blue, color.alpha);
            cr.rectangle (0, 0, 18, 18);
            cr.fill ();
            return false;
          });
          line.pack_start (swatch, false, false, 0);
        }

        // A wrapped label must fill the row, or GTK shrinks it to width_chars
        var label = new Gtk.Label (item.get_preview_text (PREVIEW_LINES, PREVIEW_LINES * TEXT_WIDTH_CHARS * 2));
        label.halign = Gtk.Align.FILL;
        label.xalign = 0;
        label.wrap = true;
        label.wrap_mode = Pango.WrapMode.WORD_CHAR;
        label.lines = PREVIEW_LINES;
        label.ellipsize = Pango.EllipsizeMode.END;
        label.width_chars = TEXT_WIDTH_CHARS;
        label.max_width_chars = TEXT_WIDTH_CHARS;
        label.hexpand = true;
        line.pack_start (label, true, true, 0);
        content.pack_start (line, false, false, 0);

        var line_count = item.get_line_count ();
        if (line_count > PREVIEW_LINES) {
          var meta = new Gtk.Label (_("%d lines").printf (line_count));
          meta.halign = Gtk.Align.START;
          meta.get_style_context ().add_class ("clippy-meta");
          content.pack_start (meta, false, false, 0);
        }
      }

      box.pack_start (content, true, true, 0);

      var row = new Gtk.ListBoxRow ();
      row.add (box);
      return row;
    }

    private void choose (int index) {
      if (index < 0 || index >= items.size) {
        return;
      }

      item_chosen (items[index]);
      close_popup ();
    }

    private bool on_key_press (Gdk.EventKey event) {
      switch (event.keyval) {
      case Gdk.Key.Escape:
        close_popup ();
        return true;
      case Gdk.Key.Return:
      case Gdk.Key.KP_Enter:
        var row = list.get_selected_row ();
        if (row != null) {
          pending_key = event.hardware_keycode;
          pending_index = row.get_index ();
        }
        return true;
      default:
        break;
      }

      // 1-9 quick pick; Ctrl/Alt/Super combinations are left alone
      var modifiers = Gtk.accelerator_get_default_mod_mask () & ~Gdk.ModifierType.SHIFT_MASK;
      if ((event.state & modifiers) != 0) {
        return false;
      }

      uint digit = 0;
      if (event.keyval >= Gdk.Key.@1 && event.keyval <= Gdk.Key.@9) {
        digit = event.keyval - Gdk.Key.@1 + 1;
      } else if (event.keyval >= Gdk.Key.KP_1 && event.keyval <= Gdk.Key.KP_9) {
        digit = event.keyval - Gdk.Key.KP_1 + 1;
      }

      if (digit > 0) {
        pending_key = event.hardware_keycode;
        pending_index = (int) digit - 1;
        return true;
      }

      return false;
    }

    private bool on_key_release (Gdk.EventKey event) {
      if (pending_key != 0U && event.hardware_keycode == pending_key) {
        var index = pending_index;
        pending_key = 0U;
        pending_index = -1;
        choose (index);
        return true;
      }

      return false;
    }

    /**
     * Shows the window at the given place within the monitor's work area and
     * gives it the keyboard. The position is set before mapping, so the window
     * manager does not place the window itself.
     */
    public void popup (uint32 event_time, ClippyPlacement placement) {
      var display = get_display ();
      int px, py;
      display.get_default_seat ().get_pointer ().get_position (null, out px, out py);

      // Remember the paste target before taking the focus; the desktop and
      // docks do not count
      Gdk.Rectangle? active_frame = null;
      unowned Wnck.Screen wnck_screen = Plank.get_wnck_screen ();
      wnck_screen.force_update ();
      unowned Wnck.Window? active = wnck_screen.get_active_window ();
      if (active != null) {
        var type = active.get_window_type ();
        if (type != Wnck.WindowType.DESKTOP && type != Wnck.WindowType.DOCK) {
          target_xid = active.get_xid ();
          Gdk.Rectangle frame = Gdk.Rectangle ();
          active.get_geometry (out frame.x, out frame.y, out frame.width, out frame.height);
          // Wnck reports device pixels; GTK places windows in logical ones
          int scale = int.max (1, get_scale_factor ());
          frame.x /= scale;
          frame.y /= scale;
          frame.width /= scale;
          frame.height /= scale;
          if (frame.width > 1 && frame.height > 1) {
            active_frame = frame;
          }
        }
      }

      if (placement == ClippyPlacement.ACTIVE_WINDOW && active_frame == null) {
        placement = ClippyPlacement.SCREEN_CENTER;
      }

      var monitor = (placement == ClippyPlacement.ACTIVE_WINDOW)
        ? display.get_monitor_at_point (active_frame.x + active_frame.width / 2,
                                        active_frame.y + active_frame.height / 2)
        : display.get_monitor_at_point (px, py);
      var area = monitor.get_workarea ();

      scroller.max_content_height = int.max (120, int.min (MAX_HEIGHT, area.height - CHROME_HEIGHT));
      get_child ().show_all ();

      Gtk.Requisition natural;
      get_preferred_size (null, out natural);
      int width = int.max (natural.width, WIDTH);
      int height = natural.height;

      int x, y;
      switch (placement) {
      case ClippyPlacement.ACTIVE_WINDOW:
        x = active_frame.x + (active_frame.width - width) / 2;
        y = active_frame.y + (active_frame.height - height) / 2;
        break;
      case ClippyPlacement.SCREEN_CENTER:
        x = area.x + (area.width - width) / 2;
        y = area.y + (area.height - height) / 2;
        break;
      default:
        x = px - width / 2;
        y = py + POINTER_GAP;
        if (y + height > area.y + area.height) {
          y = py - height - POINTER_GAP;
        }
        break;
      }

      x = x.clamp (area.x, int.max (area.x, area.x + area.width - width));
      y = y.clamp (area.y, int.max (area.y, area.y + area.height - height));

      set_position (Gtk.WindowPosition.NONE);
      move (x, y);

      // A hotkey launch has no event time; without a fresh user time the window
      // manager refuses the focus
      realize ();
      if (get_window () is Gdk.X11.Window) {
        var x11_window = (Gdk.X11.Window) get_window ();
        if (event_time == 0U) {
          event_time = Gdk.X11.get_server_time (x11_window);
        }
        x11_window.set_user_time (event_time);
      }

      show ();

      var first = list.get_row_at_index (0);
      if (first != null) {
        list.select_row (first);
        first.grab_focus ();
      }

      present_with_time (event_time);

      // Without the focus the window would never close: retry once, then close
      focus_check_id = GLib.Timeout.add (FOCUS_CHECK_DELAY, () => {
        if (is_active) {
          focus_check_id = 0U;
          return false;
        }

        if (get_window () is Gdk.X11.Window) {
          present_with_time (Gdk.X11.get_server_time ((Gdk.X11.Window) get_window ()));
        }

        focus_check_id = GLib.Timeout.add (FOCUS_CHECK_DELAY, () => {
          focus_check_id = 0U;
          if (!is_active) {
            close_popup ();
          }
          return false;
        });
        return false;
      });
    }

    private void close_popup () {
      if (closing) {
        return;
      }

      closing = true;
      destroy ();
    }
  }
}
