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
  /**
   * A class representing an item stored in the Clippy clipboard history.
   * Can hold either text or image data.
   */
  public class ClippyClipboardItem : GLib.Object {
    /**
     * The type of content stored in this clipboard item.
     */
    public enum Type {
      TEXT,
      IMAGE
    }

    /**
     * The type of content stored in this clipboard item.
     */
    public Type item_type { get; private set; }

    /**
     * The text content if this is a text item.
     */
    public string? text { get; private set; }

    /**
     * The image content if this is an image item.
     */
    public Gdk.Pixbuf? image { get; private set; }

    /**
     * Cached hash value for efficient comparison.
     */
    private string _hash;


    /**
     * Create a new clipboard item containing text.
     *
     * @param text The text content to store
     */
    public ClippyClipboardItem.with_text(string text) {
      item_type = Type.TEXT;
      this.text = text;
      this.image = null;
      _hash = compute_hash();
    }

    /**
     * Create a new clipboard item containing an image.
     *
     * @param image The image content to store
     */
    public ClippyClipboardItem.with_image(Gdk.Pixbuf image) {
      item_type = Type.IMAGE;
      this.text = null;
      this.image = image;
      _hash = compute_hash();
    }

    /**
     * Get the hash value for this clipboard item.
     * Used for efficient comparison and deduplication.
     *
     * @return A string hash uniquely identifying this content
     */
    public string get_hash() {
      return _hash;
    }

    private Gdk.Pixbuf? _preview = null;
    private int _line_count = -1;

    private static GLib.Regex hex_color_regex =
      /^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{4}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$/;
    private int _preview_width = 0;
    private int _preview_height = 0;

    /**
     * Get a preview of this image that fits in the given box; small images
     * are never scaled up.
     *
     * @return the preview, or null for a text item
     */
    public Gdk.Pixbuf? get_preview(int max_width, int max_height) {
      if (item_type != Type.IMAGE || image == null)
        return null;

      if (_preview == null || _preview_width != max_width || _preview_height != max_height) {
        int width = image.get_width();
        int height = image.get_height();
        double scale = double.min(1.0, double.min((double) max_width / width,
                                                  (double) max_height / height));
        int preview_width = int.max(1, (int) (width * scale));
        int preview_height = int.max(1, (int) (height * scale));

        _preview = (scale >= 1.0)
          ? image
          : image.scale_simple(preview_width, preview_height, Gdk.InterpType.BILINEAR);
        _preview_width = max_width;
        _preview_height = max_height;
      }

      return _preview;
    }

    /**
     * Get the first lines of a text item for the history window, with
     * surrounding blank lines and indentation of the block trimmed.
     *
     * @param max_lines how many lines to keep
     * @param max_chars how many characters to keep in all
     */
    public string get_preview_text(int max_lines, int max_chars) {
      if (item_type != Type.TEXT || text == null)
        return "";

      // Bounded prefix, so huge entries stay cheap
      var prefix = get_text_prefix(max_chars * 4 + max_lines);
      var lines = prefix.split("\n", max_lines + 1);
      var builder = new StringBuilder();
      int count = int.min(lines.length, max_lines);

      for (int i = 0; i < count; i++) {
        if (i > 0)
          builder.append_c('\n');
        builder.append(lines[i].replace("\t", "    ").chomp());
      }

      var preview = builder.str.chomp();
      if (preview.char_count() > max_chars) {
        preview = preview.substring(0, preview.index_of_nth_char(max_chars)) + "…";
      }

      return preview;
    }

    /**
     * Number of lines of a text item (leading and trailing blank space
     * ignored), counted once and cached.
     */
    public int get_line_count() {
      if (item_type != Type.TEXT || text == null)
        return 0;

      if (_line_count < 0) {
        int start = 0;
        int end = text.length;
        while (start < end && text[start].isspace())
          start++;
        while (end > start && text[end - 1].isspace())
          end--;

        int count = (end > start) ? 1 : 0;
        for (int i = start; i < end; i++) {
          if (text[i] == '\n')
            count++;
        }
        _line_count = count;
      }

      return _line_count;
    }

    /**
     * At most max_bytes of the text after its leading blank space, cut on a
     * character boundary.
     */
    private string get_text_prefix(int max_bytes) {
      int start = 0;
      while (start < text.length && text[start].isspace())
        start++;

      int length = int.min(text.length - start, max_bytes);
      return text.substring(start, length).make_valid();
    }

    /**
     * Compute a hash based on the content.
     *
     * @return A string hash
     */
    private string compute_hash() {
      var checksum = new GLib.Checksum(GLib.ChecksumType.SHA256);

      if (item_type == Type.TEXT && text != null) {
        checksum.update(text.data, text.data.length);
      } else if (item_type == Type.IMAGE && image != null) {
        // Skip the rowstride padding: it is uninitialised, and hashing it would
        // give the same image a different hash each time
        unowned uint8[] pixels = image.get_pixels_with_length();
        int width = image.get_width();
        int height = image.get_height();
        int rowstride = image.get_rowstride();
        int row_bytes = (width * image.get_n_channels() * image.get_bits_per_sample() + 7) / 8;
        var header = "%dx%dx%d".printf(width, height, image.get_n_channels());
        checksum.update(header.data, header.data.length);
        for (int row = 0; row < height; row++) {
          int offset = row * rowstride;
          int length = int.min(row_bytes, pixels.length - offset);
          if (length <= 0)
            break;
          checksum.update(pixels[offset:offset + length], length);
        }
      }

      return checksum.get_string();
    }

    /**
     * Get a display-friendly version of this item's content.
     *
     * @param max_length Maximum length for text content
     * @return A formatted string representation for display
     */
    public string get_display_text(int max_length = 80) {
      if (item_type == Type.TEXT && text != null) {
        var first = get_text_prefix(max_length * 4).split("\n", 2)[0].strip();
        int lines = get_line_count();

        if (lines > 1) {
          first = first + "... [" + lines.to_string() + "]";
        }

        return Helpers.truncate_middle(first, max_length);
      } else {
        return _("Image");
      }
    }

    /**
     * Copy this item's content to the clipboard.
     *
     * @param clipboard The clipboard to copy to
     */
    public void copy_to_clipboard(Gtk.Clipboard clipboard) {
      if (item_type == Type.TEXT && text != null) {
        clipboard.set_text(text, text.length);
      } else if (item_type == Type.IMAGE && image != null) {
        clipboard.set_image(image);
      }
    }

    /**
     * Checks if the text content represents a valid hex color.
     *
     * @return True if the content is a valid hex color.
     */
    public bool is_hex_color() {
      if (item_type != Type.TEXT || text == null) {
        return false;
      }

      // Reject long text before copying it
      int start = 0;
      int end = text.length;
      while (start < end && text[start].isspace())
        start++;
      while (end > start && text[end - 1].isspace())
        end--;
      if (end - start < 4 || end - start > 9 || text[start] != '#') {
        return false;
      }

      return hex_color_regex.match(text.substring(start, end - start));
    }

    /**
     * Parses the text content as a hex color.
     *
     * @return A Gdk.RGBA color representation or null if not a valid color.
     */
    public Gdk.RGBA? parse_hex_color() {
      if (!is_hex_color()) {
        return null;
      }

      // Parsed by hand: GTK 3 rejects the #RGBA and #RRGGBBAA forms
      var hex = text.strip().substring(1);
      bool short_form = hex.length <= 4;
      int digits = short_form ? 1 : 2;
      double[] channels = { 0.0, 0.0, 0.0, 1.0 };

      for (int i = 0; i < hex.length / digits; i++) {
        int value = 0;
        for (int d = 0; d < digits; d++) {
          value = value * 16 + hex[i * digits + d].xdigit_value();
        }
        channels[i] = short_form ? value / 15.0 : value / 255.0;
      }

      var color = Gdk.RGBA();
      color.red = channels[0];
      color.green = channels[1];
      color.blue = channels[2];
      color.alpha = channels[3];
      return color;
    }

  }
}
