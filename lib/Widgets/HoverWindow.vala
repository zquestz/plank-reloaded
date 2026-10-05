//
// Copyright (C) 2011-2012 Robert Dyer, Rico Tzschichholz
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
   * A captured preview of an application's window, as shown in the {@link HoverWindow}.
   */
  public class WindowPreview : GLib.Object {
    public Bamf.Window Window { get; construct; }
    public Gdk.Pixbuf Pixbuf { get; construct; }
    public string Title { get; construct; }

    public WindowPreview (Bamf.Window window, Gdk.Pixbuf pixbuf, string title) {
      GLib.Object (Window: window, Pixbuf: pixbuf, Title: title);
    }
  }

  /**
   * A clickable tile showing a single window preview,
   * highlighted while the pointer is over it.
   */
  class WindowPreviewTile : Gtk.EventBox {
    const double HIGHLIGHT_ALPHA = 0.15;
    const double HIGHLIGHT_RADIUS = 4.0;

    public WindowPreview Preview { get; construct; }

    bool highlighted = false;

    public WindowPreviewTile (WindowPreview preview, int size) {
      GLib.Object (Preview: preview);

      var scaled = preview.Pixbuf;
      if (scaled.width > size || scaled.height > size)
        scaled = DrawingService.ar_scale (scaled, size, size);

      var vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 4);
      vbox.margin = 4;

      var image = new Gtk.Image.from_pixbuf (scaled);
      image.set_size_request (size, -1);
      image.valign = Gtk.Align.CENTER;
      image.vexpand = true;
      vbox.pack_start (image, true, true, 0);

      var title = new Gtk.Label (preview.Title);
      title.ellipsize = Pango.EllipsizeMode.MIDDLE;
      title.max_width_chars = 1;
      title.set_size_request (size, -1);
      vbox.pack_start (title, false, false, 0);

      add (vbox);
      vbox.show_all ();
    }

    construct
    {
      visible_window = false;
      add_events (Gdk.EventMask.ENTER_NOTIFY_MASK
                  | Gdk.EventMask.LEAVE_NOTIFY_MASK
                  | Gdk.EventMask.BUTTON_RELEASE_MASK);
    }

    public override bool enter_notify_event (Gdk.EventCrossing event) {
      highlighted = true;
      queue_draw ();
      return Gdk.EVENT_PROPAGATE;
    }

    public override bool leave_notify_event (Gdk.EventCrossing event) {
      if (event.detail == Gdk.NotifyType.INFERIOR)
        return Gdk.EVENT_PROPAGATE;

      highlighted = false;
      queue_draw ();
      return Gdk.EVENT_PROPAGATE;
    }

    public override bool draw (Cairo.Context cr) {
      if (highlighted) {
        // Derive the highlight from the tooltip's text color so it
        // stays visible on both light and dark themes
        var color = get_style_context ().get_color (get_state_flags ());
        var width = get_allocated_width ();
        var height = get_allocated_height ();

        cr.save ();
        cr.new_sub_path ();
        cr.arc (width - HIGHLIGHT_RADIUS, HIGHLIGHT_RADIUS, HIGHLIGHT_RADIUS, -Math.PI_2, 0);
        cr.arc (width - HIGHLIGHT_RADIUS, height - HIGHLIGHT_RADIUS, HIGHLIGHT_RADIUS, 0, Math.PI_2);
        cr.arc (HIGHLIGHT_RADIUS, height - HIGHLIGHT_RADIUS, HIGHLIGHT_RADIUS, Math.PI_2, Math.PI);
        cr.arc (HIGHLIGHT_RADIUS, HIGHLIGHT_RADIUS, HIGHLIGHT_RADIUS, Math.PI, 3 * Math.PI_2);
        cr.close_path ();
        cr.set_source_rgba (color.red, color.green, color.blue, HIGHLIGHT_ALPHA);
        cr.fill ();
        cr.restore ();
      }

      return base.draw (cr);
    }
  }

  /**
   * A hover window that shows labels for dock items.
   * This window floats outside (but near) the dock.
   */
  public class HoverWindow : Gtk.Window {
    const int PADDING = 10;
    const int THUMBNAIL_SPACING = 6;
    const int MIN_THUMBNAIL_SIZE = 48;

    static construct
    {
      set_accessible_role (Atk.Role.TOOL_TIP);
      set_css_name ("tooltip");
    }

    Gtk.Box box;
    Gtk.Label label;
    Gtk.Box thumbnails;

    /**
     * Whether the pointer is currently inside this window.
     */
    public bool PointerInside { get; private set; default = false; }

    /**
     * Whether window previews are currently shown.
     */
    public bool ShowsPreviews { get; private set; default = false; }

    /**
     * Emitted when the user clicks one of the shown window previews.
     *
     * @param window the window whose preview was clicked
     * @param event_time the time of the click
     */
    public signal void window_activated (Bamf.Window window, uint32 event_time);

    public HoverWindow () {
      GLib.Object (type: Gtk.WindowType.POPUP, type_hint: Gdk.WindowTypeHint.TOOLTIP);
    }

    construct
    {
      app_paintable = true;
      resizable = false;

      unowned Gdk.Screen screen = get_screen ();
      set_visual (screen.get_rgba_visual () ?? screen.get_system_visual ());

      get_style_context ().add_class (Gtk.STYLE_CLASS_TOOLTIP);

      add_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);

      box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
      box.set_margin_start (6);
      box.set_margin_end (6);
      box.set_margin_top (6);
      box.set_margin_bottom (6);
      add (box);
      box.show ();

      label = new Gtk.Label (null);
      label.set_line_wrap (true);
      box.pack_start (label, false, false, 0);

      thumbnails = new Gtk.Box (Gtk.Orientation.HORIZONTAL, THUMBNAIL_SPACING);
      box.pack_start (thumbnails, false, false, 0);
    }

    /**
     * Shows and centers the window according to the x/y location specified
     * while accounting the dock's position.
     *
     * @param x the x location
     * @param y the y location
     * @param position the dock's position
     */
    public void show_at (int x, int y, Gtk.PositionType position) {
      unowned Gdk.Display display = get_display ();
      Gdk.Rectangle monitor;
      var monitor_at_point = display.get_monitor_at_point (x, y);

      if (environment_is_session_desktop (XdgSessionDesktop.GNOME | XdgSessionDesktop.UBUNTU | XdgSessionDesktop.MATE | XdgSessionDesktop.CINNAMON | XdgSessionDesktop.XFCE | XdgSessionDesktop.KDE)) {
        monitor = monitor_at_point.get_geometry ();
      } else {
        monitor = monitor_at_point.get_workarea ();
      }

      // realize and show the window early to have current allocation-dimensions
      // this is also needed for being able to move override-redirect windows
      // on mutter-derived window-managers
      show ();

      var width = get_allocated_width ();
      var height = get_allocated_height ();

      switch (position) {
      case Gtk.PositionType.BOTTOM:
        x = x - width / 2;
        y = y - height - PADDING;
        break;
      case Gtk.PositionType.TOP:
        x = x - width / 2;
        y = y + PADDING;
        break;
      case Gtk.PositionType.LEFT:
        x = x + PADDING;
        y = y - height / 2;
        break;
      case Gtk.PositionType.RIGHT:
        x = x - width - PADDING;
        y = y - height / 2;
        break;
      }

      x = x.clamp (monitor.x, monitor.x + monitor.width - width);
      y = y.clamp (monitor.y, monitor.y + monitor.height - height);

      move (x, y);
    }

    /**
     * Set the tooltip-text to show
     *
     * @param text the text to show
     */
    public void set_text (string text) {
      // Every caller showing a label starts from a plain tooltip,
      // so stale previews from a previous item never linger
      clear_thumbnails ();

      label.set_text (text);
      if (text != null && text.length > 0)
        label.show ();
      else
        label.hide ();
    }

    /**
     * Set the window previews to show below the tooltip-text,
     * an empty list removes all previews
     *
     * @param previews the previews to show
     * @param position the dock's position, used to lay out the previews
     * @param size the maximum width and height of a single preview
     */
    public void set_thumbnails (Gee.List<WindowPreview> previews, Gtk.PositionType position, int size) {
      clear_thumbnails ();

      if (previews.size == 0)
        return;

      var vertical = (position == Gtk.PositionType.LEFT || position == Gtk.PositionType.RIGHT);
      thumbnails.orientation = (vertical ? Gtk.Orientation.VERTICAL : Gtk.Orientation.HORIZONTAL);

      // Shrink the previews if they would not fit next to each other on the monitor
      int x, y;
      unowned Gdk.Display display = get_display ();
      display.get_default_seat ().get_pointer ().get_position (null, out x, out y);
      var monitor = display.get_monitor_at_point (x, y).get_workarea ();
      var available = (vertical ? monitor.height : monitor.width) - 2 * PADDING;
      var fitting = available / previews.size - THUMBNAIL_SPACING - 8 /* tile margins */;
      size = int.max (MIN_THUMBNAIL_SIZE, int.min (size, fitting));

      foreach (var preview in previews) {
        var tile = new WindowPreviewTile (preview, size);
        tile.button_release_event.connect (handle_tile_released);
        thumbnails.pack_start (tile, false, false, 0);
        tile.show ();
      }

      thumbnails.show ();
      ShowsPreviews = true;
    }

    [CCode (instance_pos = -1)]
    bool handle_tile_released (Gtk.Widget widget, Gdk.EventButton event) {
      if (event.button != Gdk.BUTTON_PRIMARY)
        return Gdk.EVENT_PROPAGATE;

      window_activated (((WindowPreviewTile) widget).Preview.Window, event.time);
      return Gdk.EVENT_STOP;
    }

    void clear_thumbnails () {
      thumbnails.foreach ((child) => child.destroy ());
      thumbnails.hide ();
      ShowsPreviews = false;

      // Shrink back to the label-only size, a resizable=false window
      // otherwise keeps the size it had while showing previews
      resize (1, 1);
    }

    /**
     * {@inheritDoc}
     */
    public override bool enter_notify_event (Gdk.EventCrossing event) {
      if (!PointerInside)
        PointerInside = true;

      return Gdk.EVENT_PROPAGATE;
    }

    /**
     * {@inheritDoc}
     */
    public override bool leave_notify_event (Gdk.EventCrossing event) {
      if (event.detail != Gdk.NotifyType.INFERIOR && PointerInside)
        PointerInside = false;

      return Gdk.EVENT_PROPAGATE;
    }

    /**
     * {@inheritDoc}
     */
    public override void unmap () {
      // An unmapped window gets no leave-notify, so reset the state here
      if (PointerInside)
        PointerInside = false;

      base.unmap ();
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
