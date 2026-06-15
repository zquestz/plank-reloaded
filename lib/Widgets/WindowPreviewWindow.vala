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
  /**
   * A floating popup that shows thumbnail previews of an application's windows,
   * grouped under a dock item.  Hovering a card outlines the matching desktop
   * window; clicking it focuses that window.
   */
  public class WindowPreviewWindow : Gtk.Window {

    // Visual constants
    const int   CARD_THUMB_WIDTH  = 200;
    const int   CARD_THUMB_HEIGHT = 120;
    const int   CARD_PADDING      = 8;
    const int   CARD_SPACING      = 8;
    // The gap between the visible card area and the dock edge is achieved by
    // adding this margin on the dock-facing side of the card container inside
    // the window.  The window itself extends flush to the dock so there is no
    // pointer-event dead zone between the dock and the popup.
    const int   DOCK_SIDE_MARGIN  = 12;
    const int   TITLE_MAX_CHARS   = 30;

    // Highlight colour for the outline drawn on the live desktop window
    const double HIGHLIGHT_R = 0.25;
    const double HIGHLIGHT_G = 0.55;
    const double HIGHLIGHT_B = 1.0;
    const double HIGHLIGHT_A = 0.85;
    const int    HIGHLIGHT_WIDTH  = 4;

    /**
     * Fired when the user clicks on a window card.
     * The consumer (DockWindow) should call WindowControl.focus_window().
     */
    public signal void window_activated (Bamf.Window window);

    /**
     * Fired when the user middle-clicks a window card to close it.
     */
    public signal void window_close_requested (Bamf.Window window);

    /**
     * Fired when the pointer enters the visible card area of the preview popup.
     * DockWindow uses this to cancel any pending hide timer.
     */
    public signal void pointer_entered ();

    /**
     * Fired when the pointer leaves the preview popup entirely.
     * DockWindow uses this to start a grace-period hide timer.
     */
    public signal void pointer_left ();

    // The Bamf windows currently displayed, in card order
    Gee.ArrayList<Bamf.Window> shown_windows = new Gee.ArrayList<Bamf.Window> ();

    // The card widget for each Bamf window (parallel to shown_windows)
    Gee.ArrayList<Gtk.EventBox> cards = new Gee.ArrayList<Gtk.EventBox> ();

    // Index of the currently hovered card (-1 = none)
    int hovered_index = -1;

    // Which dock edge we are attached to — drives transparent-gap side
    Gtk.PositionType dock_position = Gtk.PositionType.BOTTOM;

    // The sub-rectangle (within our window coordinates) that actually renders
    // the visible card content.  Updated in reposition().
    Gdk.Rectangle visible_area = Gdk.Rectangle ();

    // GDK window used to draw the highlight on the real desktop window
    Gdk.Window? highlight_overlay = null;

    Gtk.Box card_box;

    static construct {
      // Register this widget class as "tooltip" so GTK loads the correct
      // tooltip background/foreground colours from the user's current theme,
      // exactly as HoverWindow does.
      PlankCompat.gtk_widget_class_set_css_name (
          (GLib.ObjectClass) typeof (WindowPreviewWindow).class_ref (), "tooltip");
    }

    public WindowPreviewWindow () {
      GLib.Object (type: Gtk.WindowType.POPUP,
                   type_hint: Gdk.WindowTypeHint.TOOLTIP);
    }

    construct {
      app_paintable = true;
      resizable     = false;
      decorated     = false;

      unowned Gdk.Screen screen = get_screen ();
      set_visual (screen.get_rgba_visual () ?? screen.get_system_visual ());

      get_style_context ().add_class (Gtk.STYLE_CLASS_TOOLTIP);

      card_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, CARD_SPACING);
      card_box.margin = CARD_PADDING;
      // Make the box transparent so the window-level tooltip background
      // renders through — prevents grey child-widget backgrounds in dark themes.
      card_box.app_paintable = true;
      card_box.draw.connect ((cr) => { return false; });
      add (card_box);

      add_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
    }

    public override bool enter_notify_event (Gdk.EventCrossing event) {
      if (event.detail != Gdk.NotifyType.INFERIOR)
        pointer_entered ();
      return Gdk.EVENT_PROPAGATE;
    }

    public override bool leave_notify_event (Gdk.EventCrossing event) {
      if (event.detail != Gdk.NotifyType.INFERIOR)
        pointer_left ();
      return Gdk.EVENT_PROPAGATE;
    }

    // ── Public API ─────────────────────────────────────────────────────────

    /**
     * Rebuild card list from the given windows and reposition near the dock item.
     *
     * @param windows        Bamf windows to display (already filtered for monitor/workspace)
     * @param dock_item_x    screen-x of the hovered dock icon centre
     * @param dock_item_y    screen-y of the hovered dock icon centre
     * @param position       which edge the dock sits on (drives popup placement)
     */
    public void present_for (Gee.ArrayList<Bamf.Window> windows,
                             int                         dock_item_x,
                             int                         dock_item_y,
                             Gtk.PositionType            position,
                             int                         zoom_clearance = 0) {
      clear_highlight ();
      hovered_index = -1;
      dock_position = position;

      // Rebuild card list
      shown_windows.clear ();
      shown_windows.add_all (windows);

      // Remove old cards
      foreach (var old in cards)
        card_box.remove (old);
      cards.clear ();

      // The transparent dock-side strip must be wide enough to span the
      // zoomed icon so the icon always appears in front.  Use whichever is
      // larger: our aesthetic gap constant or the zoom clearance supplied
      // by the caller.
      int dock_margin = int.max (DOCK_SIDE_MARGIN, zoom_clearance);

      // Apply the dock-side margin so the visible area appears to float with
      // a gap while the window itself reaches flush to the dock edge.
      card_box.margin_top    = CARD_PADDING;
      card_box.margin_bottom = CARD_PADDING;
      card_box.margin_start  = CARD_PADDING;
      card_box.margin_end    = CARD_PADDING;
      switch (position) {
      case Gtk.PositionType.BOTTOM:
        card_box.margin_bottom = CARD_PADDING + dock_margin;
        break;
      case Gtk.PositionType.TOP:
        card_box.margin_top    = CARD_PADDING + dock_margin;
        break;
      case Gtk.PositionType.LEFT:
        card_box.margin_start  = CARD_PADDING + dock_margin;
        break;
      default:
      case Gtk.PositionType.RIGHT:
        card_box.margin_end    = CARD_PADDING + dock_margin;
        break;
      }

      // Build new cards
      int idx = 0;
      foreach (var w in shown_windows) {
        var card = build_card (w, idx);
        cards.add (card);
        card_box.pack_start (card, false, false, 0);
        idx++;
      }

      card_box.show_all ();
      show_all ();

      // Position the popup relative to the dock edge, storing dock_margin for draw()
      reposition (dock_item_x, dock_item_y, position, dock_margin);
    }

    /**
     * Hide the popup and remove any desktop highlight.
     */
    public new void hide () {
      clear_highlight ();
      hovered_index = -1;
      base.hide ();
    }

    // ── Card building ──────────────────────────────────────────────────────

    Gtk.EventBox build_card (Bamf.Window bamf_window, int idx) {
      var event_box = new Gtk.EventBox ();
      event_box.above_child = true;
      // Don't let the EventBox draw its own background — the window-level
      // tooltip background should show through for correct theme colours.
      event_box.visible_window = false;

      var vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 4);
      vbox.margin = 4;
      event_box.add (vbox);

      // Thumbnail or fallback icon
      Gdk.Pixbuf? thumb = WindowControl.get_window_thumbnail (bamf_window);
      Gtk.Widget thumb_widget;

      if (thumb != null) {
        thumb = DrawingService.ar_scale (thumb, CARD_THUMB_WIDTH, CARD_THUMB_HEIGHT);
        thumb_widget = new Gtk.Image.from_pixbuf (thumb);
      } else {
        Gdk.Pixbuf? icon_pbuf = WindowControl.get_window_icon (bamf_window);
        if (icon_pbuf != null) {
          // Scale icon to fill the thumb area, centred
          icon_pbuf = DrawingService.ar_scale (icon_pbuf, 64, 64);
          var icon_img = new Gtk.Image.from_pixbuf (icon_pbuf);

          var centering = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
          centering.set_size_request (CARD_THUMB_WIDTH, CARD_THUMB_HEIGHT);
          centering.halign = Gtk.Align.CENTER;
          centering.valign = Gtk.Align.CENTER;
          centering.pack_start (icon_img, true, false, 0);
          centering.halign = Gtk.Align.FILL;
          thumb_widget = centering;
        } else {
          // No image at all – grey placeholder
          var placeholder = new Gtk.DrawingArea ();
          placeholder.set_size_request (CARD_THUMB_WIDTH, CARD_THUMB_HEIGHT);
          placeholder.draw.connect ((cr) => {
            cr.set_source_rgb (0.35, 0.35, 0.35);
            cr.paint ();
            return false;
          });
          thumb_widget = placeholder;
        }
      }

      // Fix thumbnail size so all cards are the same height
      thumb_widget.set_size_request (CARD_THUMB_WIDTH, CARD_THUMB_HEIGHT);
      thumb_widget.halign = Gtk.Align.FILL;
      thumb_widget.valign = Gtk.Align.FILL;
      vbox.pack_start (thumb_widget, false, false, 0);

      // Window title
      var raw_name = bamf_window.get_name () ?? "";
      if (raw_name.char_count () > TITLE_MAX_CHARS)
        raw_name = Helpers.truncate_middle (raw_name, TITLE_MAX_CHARS);

      var label = new Gtk.Label (raw_name);
      label.ellipsize = Pango.EllipsizeMode.END;
      label.max_width_chars = TITLE_MAX_CHARS;
      label.halign = Gtk.Align.CENTER;
      // Inherit the tooltip foreground colour from the window's style context
      label.get_style_context ().add_class (Gtk.STYLE_CLASS_TOOLTIP);
      vbox.pack_start (label, false, false, 0);

      // Wire hover and click events
      event_box.enter_notify_event.connect ((ev) => {
        on_card_enter (idx);
        return false;
      });
      event_box.leave_notify_event.connect ((ev) => {
        on_card_leave (idx);
        return false;
      });
      event_box.button_release_event.connect ((ev) => {
        if (ev.button == 1) {
          window_activated (bamf_window);
          return true;
        }
        if (ev.button == 2) {
          window_close_requested (bamf_window);
          return true;
        }
        return false;
      });

      return event_box;
    }

    // ── Hover highlight ────────────────────────────────────────────────────

    void on_card_enter (int idx) {
      if (hovered_index == idx)
        return;

      clear_highlight ();
      hovered_index = idx;

      if (idx < 0 || idx >= shown_windows.size)
        return;

      highlight_desktop_window (shown_windows.get (idx));
      queue_draw_card (idx);
    }

    void on_card_leave (int idx) {
      if (hovered_index != idx)
        return;

      clear_highlight ();
      hovered_index = -1;
      queue_draw_card (idx);
    }

    void queue_draw_card (int idx) {
      if (idx >= 0 && idx < cards.size)
        cards.get (idx).queue_draw ();
    }

    /**
     * Draw a coloured rectangle outline on top of the live desktop window.
     * We create a tiny input-transparent override-redirect window the same
     * size as the target and paint just its border.
     */
    void highlight_desktop_window (Bamf.Window bamf_window) {
      clear_highlight ();

      unowned Wnck.Window? wnck = Wnck.Window.@get (bamf_window.get_xid ());
      if (wnck == null)
        return;

      // Skip minimised windows – there is nothing to outline
      if (wnck.is_minimized ())
        return;

      int wx, wy, ww, wh;
      wnck.get_geometry (out wx, out wy, out ww, out wh);
      if (ww < 4 || wh < 4)
        return;

      var attr = Gdk.WindowAttr () {
        window_type  = Gdk.WindowType.TEMP,
        wclass       = Gdk.WindowWindowClass.INPUT_OUTPUT,
        x            = wx,
        y            = wy,
        width        = ww,
        height       = wh,
        event_mask   = 0,
      };

      unowned Gdk.Screen screen = get_screen ();
      attr.visual = screen.get_rgba_visual () ?? screen.get_system_visual ();

      var mask = Gdk.WindowAttributesType.X
               | Gdk.WindowAttributesType.Y
               | Gdk.WindowAttributesType.VISUAL;

      highlight_overlay = new Gdk.Window (screen.get_root_window (), attr, mask);

      // Make this overlay click-through via input-shape
      var empty_region = new Cairo.Region ();
      highlight_overlay.input_shape_combine_region (empty_region, 0, 0);

      // Paint the border
      highlight_overlay.show ();

      // Ensure the preview popup stays above the highlight overlay so the
      // cards are not obscured by the border drawn on the desktop window.
      if (get_window () != null)
        get_window ().raise ();

      var cr = Gdk.cairo_create (highlight_overlay);
      cr.set_operator (Cairo.Operator.SOURCE);

      // Transparent interior
      cr.set_source_rgba (0, 0, 0, 0);
      cr.paint ();

      // Coloured border
      cr.set_source_rgba (HIGHLIGHT_R, HIGHLIGHT_G, HIGHLIGHT_B, HIGHLIGHT_A);
      cr.set_line_width (HIGHLIGHT_WIDTH);
      double half = HIGHLIGHT_WIDTH / 2.0;
      cr.rectangle (half, half, ww - HIGHLIGHT_WIDTH, wh - HIGHLIGHT_WIDTH);
      cr.stroke ();
    }

    void clear_highlight () {
      if (highlight_overlay != null) {
        highlight_overlay.hide ();
        highlight_overlay.destroy ();
        highlight_overlay = null;
      }
    }

    // ── Positioning ────────────────────────────────────────────────────────

    void reposition (int icon_x, int icon_y, Gtk.PositionType position, int dock_margin) {
      show_all ();
      Gtk.Requisition req;
      get_preferred_size (null, out req);
      int pw = req.width;
      int ph = req.height;

      int px, py;

      // The preview window's dock-facing edge is placed flush with the dock
      // face coordinate (icon_x / icon_y).  The internal dock_margin strip is
      // transparent and covers the zoomed icon area so the icon appears in front.
      switch (position) {
      default:
      case Gtk.PositionType.BOTTOM:
        px = icon_x - pw / 2;
        py = icon_y - ph;
        break;
      case Gtk.PositionType.TOP:
        px = icon_x - pw / 2;
        py = icon_y;
        break;
      case Gtk.PositionType.LEFT:
        px = icon_x;
        py = icon_y - ph / 2;
        break;
      case Gtk.PositionType.RIGHT:
        px = icon_x - pw;
        py = icon_y - ph / 2;
        break;
      }

      unowned Gdk.Display display = get_display ();
      unowned Gdk.Monitor monitor = display.get_monitor_at_point (icon_x, icon_y);
      Gdk.Rectangle mon_geo = monitor.get_geometry ();

      px = px.clamp (mon_geo.x, mon_geo.x + mon_geo.width  - pw);
      py = py.clamp (mon_geo.y, mon_geo.y + mon_geo.height - ph);

      // Store visible_area: only this sub-rect gets the tooltip background.
      // The dock-side strip (dock_margin wide) stays transparent.
      switch (position) {
      default:
      case Gtk.PositionType.BOTTOM:
        visible_area = { 0, 0, pw, ph - dock_margin };
        break;
      case Gtk.PositionType.TOP:
        visible_area = { 0, dock_margin, pw, ph - dock_margin };
        break;
      case Gtk.PositionType.LEFT:
        visible_area = { dock_margin, 0, pw - dock_margin, ph };
        break;
      case Gtk.PositionType.RIGHT:
        visible_area = { 0, 0, pw - dock_margin, ph };
        break;
      }

      move (px, py);
    }

    // ── Drawing ────────────────────────────────────────────────────────────

    /**
     * {@inheritDoc}
     * Renders the tooltip-style background, then the card highlight frame for
     * the hovered card.
     */
    public override bool draw (Cairo.Context cr) {
      var width  = get_allocated_width ();
      var height = get_allocated_height ();
      unowned Gtk.StyleContext ctx = get_style_context ();
      var screen = get_screen ();

      int vx = visible_area.x;
      int vy = visible_area.y;
      int vw = visible_area.width;
      int vh = visible_area.height;

      // Clear the whole window to transparent first
      cr.save ();
      cr.set_operator (Cairo.Operator.CLEAR);
      cr.paint ();
      cr.restore ();

      if (screen.is_composited ()) {
        // Allow the full window to receive pointer events — the dock-side
        // transparent strip must pass enter/leave events to the preview window
        // so the grace-period timer works at any mouse speed.
        shape_combine_region (null);
      } else {
        // Non-composited: paint a solid background over visible_area only
        var surface = get_window ().create_similar_surface (
            Cairo.Content.COLOR_ALPHA, width, height);
        var compat_cr = new Cairo.Context (surface);
        ctx.render_background (compat_cr, vx, vy, vw, vh);
        ctx.render_frame (compat_cr, vx, vy, vw, vh);
        var region = Gdk.cairo_region_create_from_surface (surface);
        shape_combine_region (region);
      }

      // Paint the tooltip look over the visible card area only
      ctx.render_background (cr, vx, vy, vw, vh);
      ctx.render_frame (cr, vx, vy, vw, vh);

      // Let child widgets draw themselves
      bool result = base.draw (cr);

      // Draw the hover outline on the hovered card widget
      if (hovered_index >= 0 && hovered_index < cards.size) {
        Gtk.EventBox card = cards.get (hovered_index);
        Gtk.Allocation alloc;
        card.get_allocation (out alloc);

        cr.save ();
        cr.set_operator (Cairo.Operator.OVER);
        cr.set_source_rgba (HIGHLIGHT_R, HIGHLIGHT_G, HIGHLIGHT_B, 0.6);
        cr.set_line_width (2.0);
        cr.rectangle (alloc.x + 1, alloc.y + 1, alloc.width - 2, alloc.height - 2);
        cr.stroke ();
        cr.restore ();
      }

      return result;
    }
  }
}
