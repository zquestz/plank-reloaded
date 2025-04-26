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
     * Cached thumbnail for menus.
     */
    private Gdk.Pixbuf? _thumbnail = null;

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

    /**
     * Get the thumbnail for this clipboard item.
     *
     * @return A GDK.Pixbuf thumbnail of the image
     */
    public Gdk.Pixbuf? get_thumbnail() {
      if (item_type != Type.IMAGE || image == null)
        return null;

      if (_thumbnail == null) {
        int thumb_size = 24;
        int width = image.get_width();
        int height = image.get_height();
        double scale = (double) thumb_size / double.max(width, height);
        int thumb_width = (int) (width * scale);
        int thumb_height = (int) (height * scale);

        _thumbnail = image.scale_simple(thumb_width, thumb_height, Gdk.InterpType.BILINEAR);
      }

      return _thumbnail;
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
        unowned uint8[] pixels = image.get_pixels();
        checksum.update(pixels, pixels.length);
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
        var stripped_text = text.strip();
        var lines = stripped_text.split("\n");

        if (lines.length > 1) {
          stripped_text = lines[0] + "... [" + lines.length.to_string() + "]";
        }

        stripped_text = Helpers.truncate_middle(stripped_text, max_length);

        return stripped_text;
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

      string trimmed = text.strip();

      try {
        var regex = new Regex("^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{4}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$");
        return regex.match(trimmed);
      } catch (RegexError e) {
        return false;
      }
    }

    /**
     * Parses the text content as a hex color.
     *
     * @return A Gdk.RGBA color representation or null if not a valid color.
     */
    public Gdk.RGBA? parse_hex_color() {
      if (is_hex_color()) {
        var color = Gdk.RGBA();
        if (color.parse(text.strip())) {
          return color;
        }
      }

      return null;
    }

    /**
     * Creates a color swatch widget for hex colors.
     *
     * @return A DrawingArea widget showing the color.
     */
    private Gtk.DrawingArea? create_color_swatch() {
      var color = parse_hex_color();
      if (color == null) {
        return null;
      }

      int icon_size;
      Gtk.icon_size_lookup(Gtk.IconSize.MENU, out icon_size, null);

      var swatch = new Gtk.DrawingArea();
      swatch.set_size_request(icon_size, icon_size);

      swatch.draw.connect((cr) => {
        cr.set_source_rgba(color.red, color.green, color.blue, color.alpha);
        cr.rectangle(0, 0, icon_size, icon_size);
        cr.fill();
        return false;
      });

      return swatch;
    }

    /**
     * Create a menu item for this clipboard item.
     *
     * @return A menu item for this clipboard item
     */
    public Gtk.MenuItem create_menu_item() {
      var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 6);

      if (item_type == Type.IMAGE && image != null) {
        var thumbnail = get_thumbnail();
        var img = new Gtk.Image.from_pixbuf(thumbnail);
        box.pack_start(img, false, false, 0);

        int width = image.get_width();
        int height = image.get_height();
        var size_str = "%dx%d".printf(width, height);
        var label = new Gtk.Label(_("Image") + " (" + size_str + ")");
        label.halign = Gtk.Align.START;
        box.pack_start(label, true, true, 0);
      } else {
        var swatch = create_color_swatch();
        if (swatch != null) {
          box.pack_start(swatch, false, false, 0);
        }

        var label = new Gtk.Label(get_display_text());
        label.halign = Gtk.Align.START;
        box.pack_start(label, true, true, 0);
      }

      var item = new Gtk.MenuItem();
      item.add(box);
      return item;
    }
  }
}
