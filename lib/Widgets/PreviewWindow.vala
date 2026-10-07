//
// Copyright (C) 2026 Plank Reloaded Developers
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
  /**
   * A window shown in a {@link PreviewWindow}.
   */
  internal class PreviewEntry : GLib.Object {
    public ulong xid;
    public string title;
    public Gdk.Pixbuf? thumbnail;
    public Gdk.Pixbuf? icon;
    public bool active;

    /**
     * Creates the entry for a window. Its pixbufs hold device pixels, like
     * those Gdk.pixbuf_get_from_window () returns.
     *
     * @param xid the window's X id
     * @param title the window's title
     * @param thumbnail a picture of the window, or null to show its icon
     * @param icon the window's icon, shown when there is no thumbnail
     * @param active whether this is the active window
     */
    public PreviewEntry (ulong xid, string title, Gdk.Pixbuf? thumbnail, Gdk.Pixbuf? icon, bool active) {
      this.xid = xid;
      this.title = title;
      this.thumbnail = thumbnail;
      this.icon = icon;
      this.active = active;
    }
  }

  /**
   * A window's tile in a {@link PreviewWindow}, highlighted while hovered.
   */
  class PreviewTile : Gtk.EventBox {
    const double HIGHLIGHT_ALPHA = 0.15;
    const double HIGHLIGHT_RADIUS = 4.0;

    public PreviewEntry entry { get; construct; }

    bool hovered = false;

    public PreviewTile (PreviewEntry entry) {
      GLib.Object (entry: entry);
    }

    construct
    {
      visible_window = false;
    }

    /**
     * {@inheritDoc}
     */
    public override bool enter_notify_event (Gdk.EventCrossing event) {
      hovered = true;
      queue_draw ();

      return Gdk.EVENT_PROPAGATE;
    }

    /**
     * {@inheritDoc}
     */
    public override bool leave_notify_event (Gdk.EventCrossing event) {
      hovered = false;
      queue_draw ();

      return Gdk.EVENT_PROPAGATE;
    }

    /**
     * {@inheritDoc}
     */
    public override bool draw (Cairo.Context cr) {
      // A tint of the text color stands out on light and dark themes alike
      if (hovered) {
        unowned Gtk.StyleContext context = get_style_context ();
        var color = context.get_color (context.get_state ());

        cr.set_source_rgba (color.red, color.green, color.blue, color.alpha * HIGHLIGHT_ALPHA);
        Theme.draw_rounded_rect (cr, 0, 0, get_allocated_width (), get_allocated_height (),
                                 HIGHLIGHT_RADIUS, HIGHLIGHT_RADIUS, 0);
        cr.fill ();
      }

      return base.draw (cr);
    }
  }

  /**
   * A popup that shows an application's windows next to its dock item, in a
   * single line along the dock's edge. It looks like the item's tooltip,
   * which it replaces.
   */
  internal class PreviewWindow : Gtk.Window {
    // The space between the dock item and the popup, as for tooltips
    const int GAP = 10;
    const int PADDING = 6;
    const int TILE_MARGIN = 4;
    const int TILE_SPACING = 6;
    const int TITLE_SPACING = 4;
    const int ICON_SIZE = 48;

    static construct
    {
      set_accessible_role (Atk.Role.TOOL_TIP);
      set_css_name ("tooltip");
    }

    /**
     * Emitted when a window's tile is clicked, unless it is the active
     * window's.
     *
     * @param xid the window's X id
     * @param event_time the time of the click
     */
    public signal void activated (ulong xid, uint32 event_time);

    Gtk.Box line;

    public PreviewWindow () {
      GLib.Object (type: Gtk.WindowType.POPUP, type_hint: Gdk.WindowTypeHint.TOOLTIP);
    }

    construct
    {
      app_paintable = true;
      resizable = false;

      unowned Gdk.Screen screen = get_screen ();
      set_visual (screen.get_rgba_visual () ?? screen.get_system_visual ());

      get_style_context ().add_class (Gtk.STYLE_CLASS_TOOLTIP);

      line = new Gtk.Box (Gtk.Orientation.HORIZONTAL, TILE_SPACING);
      line.margin = PADDING;
      add (line);
      line.show ();
    }

    /**
     * Shows windows next to a dock item, in their order, in place of those
     * shown before. When they don't all fit, the first ones that do are
     * shown and the last slot counts the rest. With no windows, the popup
     * hides. All geometry is in logical pixels.
     *
     * @param entries the windows
     * @param position the dock's position
     * @param anchor_x the x coordinate of the item's tooltip anchor
     * @param anchor_y the y coordinate of the item's tooltip anchor
     * @param area the dock's area, the monitor or its work area
     * @param monitor the dock's monitor, whose shape the thumbnails take
     * @param size the preferred thumbnail width
     */
    public void show_entries (Gee.List<PreviewEntry> entries, Gtk.PositionType position,
                              int anchor_x, int anchor_y, Gdk.Rectangle area,
                              Gdk.Rectangle monitor, int size) {
      line.foreach ((child) => child.destroy ());

      if (entries.is_empty) {
        hide ();
        return;
      }

      var horizontal = (position == Gtk.PositionType.TOP || position == Gtk.PositionType.BOTTOM);
      line.orientation = (horizontal ? Gtk.Orientation.HORIZONTAL : Gtk.Orientation.VERTICAL);

      int width, height;
      compute_preview_space (out width, out height, position, anchor_x, anchor_y, GAP, area);

      // Without tiles, the popup's size is what it adds around them: the
      // padding and the theme's frame
      Gtk.Requisition empty;
      get_preferred_size (null, out empty);

      // The tallest title, measured on a title label inside the popup so the
      // theme's styling and fallback fonts count. All the windows' titles
      // are measured, since which of them are shown depends on the result
      var probe = create_title (null);
      line.add (probe);
      // GTK measures hidden widgets as empty
      probe.show ();

      var title_height = 0;
      foreach (var entry in entries) {
        probe.set_text (entry.title);

        int label_height;
        probe.get_preferred_height (null, out label_height);
        title_height = int.max (title_height, label_height);
      }

      probe.destroy ();

      int thumbnail_width, shown;
      compute_preview_layout (out thumbnail_width, out shown, position, monitor, entries.size, size,
                              DockPreferences.MIN_PREVIEW_SIZE, width - empty.width, height - empty.height,
                              2 * TILE_MARGIN, 2 * TILE_MARGIN + TITLE_SPACING + title_height, TILE_SPACING);

      var thumbnail_height = preview_thumbnail_height (thumbnail_width, monitor);

      for (var i = 0; i < shown; i++)
        line.add (create_tile (entries[i], thumbnail_width, thumbnail_height));

      if (shown < entries.size)
        line.add (create_count (entries.size - shown, thumbnail_width, thumbnail_height, title_height));

      line.show_all ();

      // realize and show the window early to be able to move it, as
      // HoverWindow does; the natural size is the new one even while a
      // showing window still has its old allocation
      show ();

      Gtk.Requisition natural;
      get_preferred_size (null, out natural);

      int x, y;
      compute_preview_position (out x, out y, position, anchor_x, anchor_y,
                                natural.width, natural.height, GAP, area);
      move (x, y);
    }

    PreviewTile create_tile (PreviewEntry entry, int thumbnail_width, int thumbnail_height) {
      var image = create_image (entry, thumbnail_width, thumbnail_height);

      var title = create_title (entry.title);
      title.set_size_request (thumbnail_width, -1);

      // The active window is greyed out, as in the window list's menu. GTK
      // dims insensitive pixbuf images but draws surfaces as they are, so
      // the image is faded by hand, to the opacity GTK's dim effect leaves
      if (entry.active) {
        title.set_sensitive (false);
        image.set_opacity (0.5);
      }

      var box = new Gtk.Box (Gtk.Orientation.VERTICAL, TITLE_SPACING);
      box.margin = TILE_MARGIN;
      box.add (image);
      box.add (title);

      var tile = new PreviewTile (entry);
      tile.add (box);
      tile.button_release_event.connect (tile_button_released);

      return tile;
    }

    Gtk.Label create_title (string? text) {
      var title = new Gtk.Label (text);
      title.ellipsize = Pango.EllipsizeMode.MIDDLE;
      // One line, with any line breaks shown as glyphs
      title.single_line_mode = true;
      // The tile decides the width, however long the title is
      title.max_width_chars = 1;

      return title;
    }

    Gtk.Image create_image (PreviewEntry entry, int thumbnail_width, int thumbnail_height) {
      var image = new Gtk.Image ();
      image.set_size_request (thumbnail_width, thumbnail_height);

      // A thumbnail may take the whole frame, an icon only its icon size
      Gdk.Pixbuf? pixbuf = entry.thumbnail;
      var width = thumbnail_width;
      var height = thumbnail_height;

      if (pixbuf == null) {
        pixbuf = entry.icon;
        width = height = int.min (ICON_SIZE, thumbnail_height);
      }

      if (pixbuf == null)
        return image;

      // Pixbufs hold device pixels, which a surface with the scale factor
      // draws sharp on HiDPI screens; they only ever shrink to fit
      var scale = get_scale_factor ();
      if (pixbuf.width > width * scale || pixbuf.height > height * scale)
        pixbuf = DrawingService.ar_scale (pixbuf, width * scale, height * scale);

      image.set_from_surface (Gdk.cairo_surface_create_from_pixbuf (pixbuf, scale, null));

      return image;
    }

    Gtk.Widget create_count (int count, int thumbnail_width, int thumbnail_height, int title_height) {
      // Exactly a tile's size, since the count's one line always fits the
      // whole tile, with the count centered and nothing to hover or click
      var label = new Gtk.Label ("+%d".printf (count));
      // Never wider than a tile, even in a very large font
      label.ellipsize = Pango.EllipsizeMode.END;
      label.max_width_chars = 1;
      label.set_size_request (thumbnail_width, thumbnail_height + TITLE_SPACING + title_height);
      label.margin = TILE_MARGIN;

      return label;
    }

    bool tile_button_released (Gtk.Widget widget, Gdk.EventButton event) {
      unowned PreviewTile tile = (PreviewTile) widget;

      if (event.button != Gdk.BUTTON_PRIMARY)
        return Gdk.EVENT_PROPAGATE;

      // Releasing away from the tile takes the click back
      if (event.x < 0 || event.y < 0
          || event.x >= tile.get_allocated_width () || event.y >= tile.get_allocated_height ())
        return Gdk.EVENT_STOP;

      // Clicking the active window does nothing, as in the menu
      if (!tile.entry.active)
        activated (tile.entry.xid, event.time);

      return Gdk.EVENT_STOP;
    }

    /**
     * {@inheritDoc}
     */
    public override bool draw (Cairo.Context cr) {
      var width = get_allocated_width ();
      var height = get_allocated_height ();
      unowned Gtk.StyleContext context = get_style_context ();
      var screen = get_screen ();

      if (screen.is_composited ()) {
        cr.save ();
        cr.set_operator (Cairo.Operator.CLEAR);
        cr.paint ();
        cr.restore ();

        shape_combine_region (null);

        context.render_background (cr, 0, 0, width, height);
        context.render_frame (cr, 0, 0, width, height);
      } else {
        var surface = get_window ().create_similar_surface (Cairo.Content.COLOR_ALPHA, width, height);
        var compat_cr = new Cairo.Context (surface);

        context.render_background (compat_cr, 0, 0, width, height);
        context.render_frame (compat_cr, 0, 0, width, height);

        var region = Gdk.cairo_region_create_from_surface (surface);
        shape_combine_region (region);
      }

      return base.draw (cr);
    }
  }
}
