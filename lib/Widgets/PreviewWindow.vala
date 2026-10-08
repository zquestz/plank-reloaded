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
     * @param thumbnail a picture of the window, or null to show the icon
     * @param icon the icon shown when there is no thumbnail
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
   * A window's tile in a {@link PreviewWindow}: a row with the window's
   * title and a close icon, above the window's thumbnail or icon. It is
   * highlighted while hovered, when the close icon also shows.
   */
  class PreviewTile : Gtk.EventBox {
    // The space around the tile's content, and between the title's row and
    // the image
    internal const int MARGIN = 4;
    internal const int TITLE_SPACING = 4;
    // The space between the title and the close icon
    const int CLOSE_SPACING = 4;

    const double HIGHLIGHT_ALPHA = 0.15;
    const double HIGHLIGHT_RADIUS = 4.0;
    // The close icon's strength until the pointer is on it
    const double CLOSE_ICON_DIMMED = 0.8;

    /**
     * The window's X id. Only that is kept, so the entry and its pixbufs
     * are freed once the tile's image has been made from them.
     */
    public ulong xid { get; construct; }

    /**
     * The window's thumbnail or icon, which a newer thumbnail can replace.
     */
    public Gtk.Image image { get; private set; }

    Gtk.Image close_icon;
    bool hovered = false;

    /**
     * Creates the tile for a window.
     *
     * @param entry the window
     * @param image the window's thumbnail or icon, sized for the tile
     */
    public PreviewTile (PreviewEntry entry, Gtk.Image image) {
      GLib.Object (xid: entry.xid);

      this.image = image;

      var title = create_title (entry.title, entry.active);
      title.hexpand = true;

      // The close icon keeps its space while hidden, so the title never
      // moves when it shows
      close_icon = create_close_icon ();
      close_icon.opacity = 0.0;

      var row = new Gtk.Box (Gtk.Orientation.HORIZONTAL, CLOSE_SPACING);
      row.add (title);
      row.add (close_icon);

      // The title's row takes the image's width
      var box = new Gtk.Box (Gtk.Orientation.VERTICAL, TITLE_SPACING);
      box.margin = MARGIN;
      box.add (row);
      box.add (image);
      add (box);
    }

    construct
    {
      visible_window = false;
      // The close icon follows the pointer within the tile
      add_events (Gdk.EventMask.POINTER_MOTION_MASK);
    }

    /**
     * Creates a title as tiles show it, which the popup also measures.
     *
     * @param text the title's text
     * @param active whether it is the active window's title
     * @return the title
     */
    public static Gtk.Label create_title (string? text, bool active) {
      var title = new Gtk.Label (text);
      title.xalign = 0.0f;
      title.ellipsize = Pango.EllipsizeMode.MIDDLE;
      // One line, with any line breaks shown as glyphs
      title.single_line_mode = true;
      // The tile decides the width, however long the title is
      title.max_width_chars = 1;
      title.set_attributes (title_attributes (active));

      return title;
    }

    /**
     * A title's attributes: the active window's title is bold, as in the
     * window list's menu.
     *
     * @param active whether it is the active window's title
     * @return the attributes, if any
     */
    public static Pango.AttrList? title_attributes (bool active) {
      if (!active)
        return null;

      var attributes = new Pango.AttrList ();
      attributes.insert (Pango.attr_weight_new (Pango.Weight.BOLD));

      return attributes;
    }

    /**
     * Creates the close icon of the window list's menu, which the popup
     * also measures.
     *
     * @return the close icon
     */
    public static Gtk.Image create_close_icon () {
      return new Gtk.Image.from_icon_name ("window-close-symbolic", Gtk.IconSize.MENU);
    }

    /**
     * {@inheritDoc}
     */
    public override bool enter_notify_event (Gdk.EventCrossing event) {
      hovered = true;
      update_close_icon (event.x, event.y);
      queue_draw ();

      return Gdk.EVENT_PROPAGATE;
    }

    /**
     * {@inheritDoc}
     */
    public override bool motion_notify_event (Gdk.EventMotion event) {
      update_close_icon (event.x, event.y);

      return Gdk.EVENT_PROPAGATE;
    }

    /**
     * {@inheritDoc}
     */
    public override bool leave_notify_event (Gdk.EventCrossing event) {
      hovered = false;
      close_icon.opacity = 0.0;
      queue_draw ();

      return Gdk.EVENT_PROPAGATE;
    }

    // While the tile is hovered, the close icon shows dimmed, at full
    // strength with the pointer on it
    void update_close_icon (double x, double y) {
      close_icon.opacity = (on_close_icon (x, y) ? 1.0 : CLOSE_ICON_DIMMED);
    }

    /**
     * Whether a point in the tile is on its close icon.
     *
     * @param x the x coordinate in the tile
     * @param y the y coordinate in the tile
     * @return whether the point is on the close icon
     */
    public bool on_close_icon (double x, double y) {
      return Helpers.is_point_on_widget (this, close_icon, x, y);
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
    const int TILE_SPACING = 6;

    /**
     * The largest an icon is shown, in a tile without a thumbnail.
     */
    internal const int ICON_SIZE = 48;

    static construct
    {
      set_accessible_role (Atk.Role.TOOL_TIP);
      set_css_name ("tooltip");
    }

    /**
     * Emitted when a window's tile is clicked, the active window's too,
     * which the window manager simply keeps in front.
     *
     * @param xid the window's X id
     * @param event_time the time of the click
     */
    public signal void activated (ulong xid, uint32 event_time);

    /**
     * Emitted when a window's close icon is clicked, or its tile is
     * middle-clicked.
     *
     * @param xid the window's X id
     * @param event_time the time of the click
     */
    public signal void close_requested (ulong xid, uint32 event_time);

    /**
     * The area the popup was last placed in, in logical pixels, as it was
     * computed rather than read back from the window.
     */
    internal Gdk.Rectangle shown_region { get; private set; }

    Gtk.Box line;

    // The size of the tiles' thumbnails, which newer thumbnails fit into
    int frame_width;
    int frame_height;

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
     * @return how many windows got tiles, the first ones of the entries
     */
    public int show_entries (Gee.List<PreviewEntry> entries, Gtk.PositionType position,
                             int anchor_x, int anchor_y, Gdk.Rectangle area,
                             Gdk.Rectangle monitor, int size) {
      clear_tiles ();

      if (entries.is_empty) {
        hide ();
        return 0;
      }

      var horizontal = (position == Gtk.PositionType.TOP || position == Gtk.PositionType.BOTTOM);
      line.orientation = (horizontal ? Gtk.Orientation.HORIZONTAL : Gtk.Orientation.VERTICAL);

      int width, height;
      compute_preview_space (out width, out height, position, anchor_x, anchor_y, GAP, area);

      // Without tiles, the popup's size is what it adds around them: the
      // padding and the theme's frame
      Gtk.Requisition empty;
      get_preferred_size (null, out empty);

      // The title row's height: the tallest title or the close icon beside
      // it, measured on a title label and an icon inside the popup so the
      // theme's styling and fallback fonts count. All the windows' titles
      // are measured, since which of them are shown depends on the result
      var probe = PreviewTile.create_title (null, false);
      var probe_icon = PreviewTile.create_close_icon ();
      line.add (probe);
      line.add (probe_icon);
      // GTK measures hidden widgets as empty
      probe.show ();
      probe_icon.show ();

      int title_height;
      probe_icon.get_preferred_height (null, out title_height);

      foreach (var entry in entries) {
        probe.set_text (entry.title);
        probe.set_attributes (PreviewTile.title_attributes (entry.active));

        int label_height;
        probe.get_preferred_height (null, out label_height);
        title_height = int.max (title_height, label_height);
      }

      probe.destroy ();
      probe_icon.destroy ();

      int thumbnail_width, shown;
      compute_preview_layout (out thumbnail_width, out shown, position, monitor, entries.size, size,
                              DockPreferences.MIN_PREVIEW_SIZE, width - empty.width, height - empty.height,
                              2 * PreviewTile.MARGIN, 2 * PreviewTile.MARGIN + PreviewTile.TITLE_SPACING + title_height,
                              TILE_SPACING);

      var thumbnail_height = preview_thumbnail_height (thumbnail_width, monitor);
      frame_width = thumbnail_width;
      frame_height = thumbnail_height;

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

      shown_region = { x, y, natural.width, natural.height };

      return shown;
    }

    /**
     * Puts a newer thumbnail on a window's tile, in place, as the tile keeps
     * its size.
     *
     * @param xid the window's X id
     * @param thumbnail the window's picture, in device pixels
     */
    internal void set_thumbnail (ulong xid, Gdk.Pixbuf thumbnail) {
      foreach (unowned Gtk.Widget child in line.get_children ()) {
        unowned PreviewTile? tile = (child as PreviewTile);
        if (tile == null || tile.xid != xid)
          continue;

        tile.image.set_from_surface (create_surface (thumbnail, frame_width, frame_height));
        return;
      }
    }

    /**
     * Hides the popup and drops its tiles, with their images, rather than
     * keeping them until it shows again.
     */
    internal void clear () {
      hide ();
      clear_tiles ();
    }

    void clear_tiles () {
      line.foreach ((child) => child.destroy ());
    }

    PreviewTile create_tile (PreviewEntry entry, int thumbnail_width, int thumbnail_height) {
      var tile = new PreviewTile (entry, create_image (entry, thumbnail_width, thumbnail_height));
      tile.button_release_event.connect (tile_button_released);

      return tile;
    }

    Gtk.Image create_image (PreviewEntry entry, int thumbnail_width, int thumbnail_height) {
      var image = new Gtk.Image ();
      image.set_size_request (thumbnail_width, thumbnail_height);

      // A thumbnail may take the whole frame, an icon only its icon size
      if (entry.thumbnail != null) {
        image.set_from_surface (create_surface (entry.thumbnail, thumbnail_width, thumbnail_height));
      } else if (entry.icon != null) {
        var icon_size = int.min (ICON_SIZE, thumbnail_height);
        image.set_from_surface (create_surface (entry.icon, icon_size, icon_size));
      }

      return image;
    }

    // Pixbufs hold device pixels, which a surface with the scale factor
    // draws sharp on HiDPI screens; they only ever shrink to fit
    Cairo.Surface create_surface (Gdk.Pixbuf pixbuf, int width, int height) {
      var scale = get_scale_factor ();
      var fitted = pixbuf;
      if (pixbuf.width > width * scale || pixbuf.height > height * scale)
        fitted = DrawingService.ar_scale (pixbuf, width * scale, height * scale);

      return Gdk.cairo_surface_create_from_pixbuf (fitted, scale, null);
    }

    Gtk.Widget create_count (int count, int thumbnail_width, int thumbnail_height, int title_height) {
      // Exactly a tile's size, since the count's one line always fits the
      // whole tile, with the count centered and nothing to hover or click
      var label = new Gtk.Label ("+%d".printf (count));
      // Never wider than a tile, even in a very large font
      label.ellipsize = Pango.EllipsizeMode.END;
      label.max_width_chars = 1;
      label.set_size_request (thumbnail_width, thumbnail_height + PreviewTile.TITLE_SPACING + title_height);
      label.margin = PreviewTile.MARGIN;

      return label;
    }

    bool tile_button_released (Gtk.Widget widget, Gdk.EventButton event) {
      unowned PreviewTile tile = (PreviewTile) widget;

      if (event.button != Gdk.BUTTON_PRIMARY && event.button != Gdk.BUTTON_MIDDLE)
        return Gdk.EVENT_PROPAGATE;

      // Releasing away from the tile takes the click back
      if (event.x < 0 || event.y < 0
          || event.x >= tile.get_allocated_width () || event.y >= tile.get_allocated_height ())
        return Gdk.EVENT_STOP;

      // A middle-click anywhere on the tile closes the window, like a click
      // on its close icon
      if (event.button == Gdk.BUTTON_MIDDLE || tile.on_close_icon (event.x, event.y))
        close_requested (tile.xid, event.time);
      else
        activated (tile.xid, event.time);

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
