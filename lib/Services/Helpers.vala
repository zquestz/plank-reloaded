//
// Copyright (C) 2025 Plank Reloaded Developers
//
// This file is part of Plank.
//
// Plank is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Plank is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

namespace Plank {
  namespace Helpers {
    // Text with more than twice this many code points, like a huge
    // clipboard entry, only has this much of each end analyzed
    const int TRUNCATE_WINDOW = 1024;

    /**
     * Truncates a string to at most max_length characters, counting them as
     * displayed: a letter with its accents, or an emoji made of several code
     * points, is one character and is never split. A longer string keeps its
     * start and end around an ellipsis, or only its start when max_length is
     * under 5. A max_length of 0 or less leaves an empty string.
     *
     * @param str The string to truncate, in valid UTF-8
     * @param max_length Maximum length for the returned string
     * @return A string not longer than max_length
     */
    public string truncate_middle (string str, int max_length) {
      if (max_length <= 0) {
        return "";
      }

      // Plain ASCII has a character per byte
      if (is_plain_ascii (str)) {
        return truncate_characters (str, null, str.length, max_length);
      }

      // A displayed character is one or more code points, so text with no
      // more code points than that fits as it is
      var code_points = str.char_count ();
      if (code_points <= max_length) {
        return str;
      }

      // Anything else goes through Pango, which finds characters by
      // Unicode's grapheme cluster rules but needs four bytes per code point
      // to do it, so long text only has its ends analyzed, which is all its
      // cuts need
      var window = int.max (TRUNCATE_WINDOW, 2 * max_length);
      if (code_points > 2 * window) {
        var truncated = truncate_ends (str, code_points, window, max_length);
        if (truncated != null) {
          return truncated;
        }
      }

      var attrs = analyze_characters (str, code_points);
      return truncate_characters (str, attrs, count_characters (attrs), max_length);
    }

    /**
     * Truncates a string whose characters are known, from its analysis or
     * as one per byte.
     *
     * @param str the string
     * @param attrs the string's analysis, or null for plain ASCII
     * @param char_count the string's character count
     * @param max_length the most characters the result may have
     * @return the truncated string
     */
    string truncate_characters (string str, Pango.LogAttr[]? attrs, int char_count, int max_length) {
      if (char_count <= max_length) {
        return str;
      }

      if (max_length < 5) {
        return str.substring (0, character_start (str, attrs, max_length));
      }

      int half = (max_length - 1) / 2;
      int left_chars = half;
      int right_chars = max_length - left_chars - 1;

      var left_end = character_start (str, attrs, left_chars);
      var right_start = character_start (str, attrs, char_count - right_chars);

      return str.substring (0, left_end) + "…" + str.substring (right_start);
    }

    /**
     * Truncates long text by analyzing only a window at each end. Whether a
     * character starts somewhere depends only on the text just before it,
     * so the end window, which may begin inside a character, can misread
     * only its first two characters. Flags are the exception, as they pair
     * up from the start of their run, so that window begins on the start of
     * a pair.
     *
     * @param str the string, of more than twice window code points
     * @param code_points the string's code point count
     * @param window how many code points of each end to analyze
     * @param max_length the most characters the result may have
     * @return the truncated string, or null when a window holds too few
     * characters for its cut, as only absurd text does
     */
    string? truncate_ends (string str, int code_points, int window, int max_length) {
      // The cut comes where the first character left out starts, which has
      // to be inside the start window
      var head = str.substring (0, str.index_of_nth_char (window));
      var head_attrs = analyze_characters (head, window);
      var left_chars = (max_length < 5 ? max_length : (max_length - 1) / 2);
      if (count_characters (head_attrs) <= left_chars) {
        return null;
      }

      var left_end = character_start (head, head_attrs, left_chars);
      if (max_length < 5) {
        return head.substring (0, left_end);
      }

      // A window that would begin after an odd number of a run's indicators
      // begins one earlier, which takes counting them but no copying
      var tail_start = (int) str.index_of_nth_char (code_points - window);
      if (is_regional_indicator (str.get_char (tail_start))) {
        var index = tail_start;
        var preceding = 0;
        unichar previous;
        while (str.get_prev_char (ref index, out previous) && is_regional_indicator (previous)) {
          preceding++;
        }

        if (preceding % 2 == 1) {
          str.get_prev_char (ref tail_start, out previous);
        }
      }

      // The cut has to come after the two characters the end window may
      // misread and at least one more, which proves the text holds more than
      // max_length characters
      var tail = str.substring (tail_start);
      var tail_attrs = analyze_characters (tail, tail.char_count ());
      var tail_chars = count_characters (tail_attrs);
      var right_chars = max_length - left_chars - 1;
      if (tail_chars - right_chars <= 2) {
        return null;
      }

      var right_start = character_start (tail, tail_attrs, tail_chars - right_chars);

      return head.substring (0, left_end) + "…" + tail.substring (right_start);
    }

    /**
     * Finds where a string's displayed characters start, which Pango marks
     * as cursor positions.
     *
     * @param str the string
     * @param code_points the string's code point count
     * @return the string's Pango.get_log_attrs () analysis
     */
    Pango.LogAttr[] analyze_characters (string str, int code_points) {
      var attrs = new Pango.LogAttr[code_points + 1];
      Pango.get_log_attrs (str, -1, -1, Pango.Language.get_default (), attrs);

      return attrs;
    }

    /**
     * Counts the displayed characters a string's analysis finds.
     *
     * @param attrs the string's Pango.get_log_attrs () analysis
     * @return the character count
     */
    int count_characters (Pango.LogAttr[] attrs) {
      var count = 0;
      for (var i = 0; i < attrs.length - 1; i++) {
        if (attrs[i].is_cursor_position != 0) {
          count++;
        }
      }

      return count;
    }

    /**
     * Whether a string has a displayed character per byte: ASCII without
     * carriage returns, as CR LF is the only ASCII pair that Unicode's
     * grapheme cluster rules join into one character.
     *
     * @param str the string
     * @return whether each byte is a character
     */
    bool is_plain_ascii (string str) {
      foreach (var b in str.data) {
        if (b >= 0x80 || b == '\r') {
          return false;
        }
      }

      return true;
    }

    /**
     * Whether a code point is a regional indicator, two of which make a
     * flag.
     *
     * @param c the code point
     * @return whether it is a regional indicator
     */
    bool is_regional_indicator (unichar c) {
      return (c >= 0x1F1E6 && c <= 0x1F1FF);
    }

    /**
     * Where a displayed character starts in a string.
     *
     * @param str the string
     * @param attrs the string's Pango.get_log_attrs () analysis, or null for plain ASCII
     * @param n the character's index, below the string's character count
     * @return the byte offset of the character's start
     */
    int character_start (string str, Pango.LogAttr[]? attrs, int n) {
      if (attrs == null) {
        return n;
      }

      var start = 0;
      var index = 0;
      var i = 0;
      var count = 0;
      unichar c;

      while (str.get_next_char (ref index, out c)) {
        if (attrs[i++].is_cursor_position != 0) {
          if (count == n) {
            return start;
          }

          count++;
        }

        start = index;
      }

      return start;
    }

    /**
     * Whether a point falls on a widget, given in the coordinates of a
     * widget that contains it, like a close icon in a window's menu item or
     * preview tile. The widget's right and bottom edges are outside it.
     *
     * @param container the widget the point's coordinates are relative to
     * @param widget the widget inside it
     * @param x the point's x coordinate
     * @param y the point's y coordinate
     * @return whether the point is on the widget
     */
    internal bool is_point_on_widget (Gtk.Widget container, Gtk.Widget widget, double x, double y) {
      int widget_x, widget_y;
      if (!widget.translate_coordinates (container, 0, 0, out widget_x, out widget_y))
        return false;

      return (x >= widget_x && x < widget_x + widget.get_allocated_width ()
              && y >= widget_y && y < widget_y + widget.get_allocated_height ());
    }

    /**
     * Attributes that make a label bold, like the active window's title in
     * a window's menu item or preview tile.
     *
     * @return the attributes
     */
    internal Pango.AttrList bold_attributes () {
      var attributes = new Pango.AttrList ();
      attributes.insert (Pango.attr_weight_new (Pango.Weight.BOLD));

      return attributes;
    }

    public static bool current_workspace_only (DefaultApplicationDockItemProvider? provider) {
      bool current_workspace_only = false;

      if (provider != null) {
        current_workspace_only = provider.Prefs.CurrentWorkspaceOnly;
      }

      return current_workspace_only;
    }

    public static bool bring_to_current_workspace (DefaultApplicationDockItemProvider? provider) {
      bool bring_to_current_workspace = false;

      if (provider != null) {
        bring_to_current_workspace = provider.Prefs.BringToCurrentWorkspace;
      }

      return bring_to_current_workspace;
    }

    /**
     * Positions and pops up a docklet-built menu next to its dock item.
     *
     * @param controller The dock the item lives on
     * @param item The dock item to position the menu against
     * @param menu The menu to show
     */
    public static void popup_docklet_menu (DockController controller, DockItem item, Gtk.Menu menu) {
      menu.show_all ();

      Gtk.Requisition requisition;
      menu.get_preferred_size (null, out requisition);

      int x, y;
      controller.position_manager.get_menu_position (item, requisition, out x, out y);

      Gdk.Gravity gravity;
      Gdk.Gravity flipped_gravity;

      switch (controller.position_manager.Position) {
      case Gtk.PositionType.BOTTOM:
        gravity = Gdk.Gravity.NORTH;
        flipped_gravity = Gdk.Gravity.SOUTH;
        break;
      case Gtk.PositionType.TOP:
        gravity = Gdk.Gravity.SOUTH;
        flipped_gravity = Gdk.Gravity.NORTH;
        break;
      case Gtk.PositionType.LEFT:
        gravity = Gdk.Gravity.EAST;
        flipped_gravity = Gdk.Gravity.WEST;
        break;
      case Gtk.PositionType.RIGHT:
        gravity = Gdk.Gravity.WEST;
        flipped_gravity = Gdk.Gravity.EAST;
        break;
      default:
        gravity = Gdk.Gravity.NORTH;
        flipped_gravity = Gdk.Gravity.SOUTH;
        break;
      }

      menu.popup_at_rect (
                          controller.window.get_screen ().get_root_window (),
                          Gdk.Rectangle () {
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

    public static int window_count (Bamf.Application? app, DefaultApplicationDockItemProvider? provider) {
      int window_count = 0;

      if (app == null) {
        return window_count;
      }

      if (current_workspace_only (provider)) {
        unowned Wnck.Workspace? active_workspace = WindowControl.get_wnck_screen ().get_active_workspace ();
        if (active_workspace != null)
          window_count = WindowControl.window_on_workspace_count (app, active_workspace);
      } else {
        window_count = WindowControl.window_count (app);
      }

      return window_count;
    }
  }
}
