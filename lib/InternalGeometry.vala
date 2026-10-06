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
   * Whether a point is at or past the edge of the dock's area, within the
   * stretch of that edge the dock covers, on the dock's monitor. Past the
   * edge counts only on the dock's own monitor, such as a panel beside the
   * dock's area; beyond that lies a neighbouring monitor. Pure math,
   * testable in isolation.
   *
   * @param position the dock position
   * @param x the x coordinate of the point
   * @param y the y coordinate of the point
   * @param area the dock's area, the monitor or its work area
   * @param raw_monitor the whole monitor the dock is on
   * @param dock_rect the visible dock
   * @return whether the point is at the dock's edge
   */
  public static bool point_at_dock_edge (Gtk.PositionType position, int x, int y,
                                         Gdk.Rectangle area, Gdk.Rectangle raw_monitor,
                                         Gdk.Rectangle dock_rect) {
    if (x < raw_monitor.x || x >= raw_monitor.x + raw_monitor.width
        || y < raw_monitor.y || y >= raw_monitor.y + raw_monitor.height)
      return false;

    bool at_edge = false;
    bool within_dock_span = false;

    switch (position) {
    default:
    case Gtk.PositionType.BOTTOM:
      at_edge = y >= area.y + area.height - 1;
      within_dock_span = x >= dock_rect.x && x < dock_rect.x + dock_rect.width;
      break;
    case Gtk.PositionType.TOP:
      at_edge = y <= area.y;
      within_dock_span = x >= dock_rect.x && x < dock_rect.x + dock_rect.width;
      break;
    case Gtk.PositionType.LEFT:
      at_edge = x <= area.x;
      within_dock_span = y >= dock_rect.y && y < dock_rect.y + dock_rect.height;
      break;
    case Gtk.PositionType.RIGHT:
      at_edge = x >= area.x + area.width - 1;
      within_dock_span = y >= dock_rect.y && y < dock_rect.y + dock_rect.height;
      break;
    }

    return at_edge && within_dock_span;
  }

  /**
   * The height of a window preview's thumbnail, which takes the shape of
   * the dock's monitor: the shape of a fullscreen window, and close to that
   * of a maximized one. Pure math, testable in isolation.
   *
   * @param width the thumbnail's width
   * @param monitor the dock's monitor
   * @return the thumbnail's height
   */
  public static int preview_thumbnail_height (int width, Gdk.Rectangle monitor) {
    // Square until the monitor is known, rather than dividing by zero
    if (monitor.width <= 0 || monitor.height <= 0)
      return width;

    // The product of two screen sizes can pass int's range
    return (int) ((int64) width * monitor.height / monitor.width);
  }

  /**
   * The widest window preview thumbnail whose height fits, the inverse of
   * preview_thumbnail_height (), or 0 when nothing fits. Heights round
   * down, so that is the largest width with
   * width * monitor.height < (height + 1) * monitor.width. Pure math,
   * testable in isolation.
   *
   * @param height the height to fit
   * @param monitor the dock's monitor
   * @return the thumbnail's width
   */
  public static int preview_width_for_thumbnail_height (int height, Gdk.Rectangle monitor) {
    if (height < 0)
      return 0;

    // Square until the monitor is known, like preview_thumbnail_height ()
    if (monitor.width <= 0 || monitor.height <= 0)
      return height;

    // The product of two screen sizes can pass int's range
    return (int) ((((int64) height + 1) * monitor.width - 1) / monitor.height);
  }

  /**
   * The room a window preview popup has next to a dock item. Along the
   * dock's edge that is the whole area. Across it, the room runs from the
   * anchor, past the gap, to the area's far edge, so the popup never covers
   * the dock. Pure math, testable in isolation.
   *
   * @param width the resulting width
   * @param height the resulting height
   * @param position the dock position
   * @param anchor_x the x coordinate the popup is anchored to
   * @param anchor_y the y coordinate the popup is anchored to
   * @param gap the space between the anchor and the popup
   * @param area the dock's area, the monitor or its work area
   */
  public static void compute_preview_space (out int width, out int height,
                                            Gtk.PositionType position, int anchor_x, int anchor_y,
                                            int gap, Gdk.Rectangle area) {
    switch (position) {
    default:
    case Gtk.PositionType.BOTTOM:
      width = area.width;
      height = anchor_y - gap - area.y;
      break;
    case Gtk.PositionType.TOP:
      width = area.width;
      height = area.y + area.height - anchor_y - gap;
      break;
    case Gtk.PositionType.LEFT:
      width = area.x + area.width - anchor_x - gap;
      height = area.height;
      break;
    case Gtk.PositionType.RIGHT:
      width = anchor_x - gap - area.x;
      height = area.height;
      break;
    }

    width = int.max (0, width);
    height = int.max (0, height);
  }

  /**
   * Lays out window previews in a single line along the dock's edge: a row
   * on top and bottom docks, a column on side docks. Tiles take the
   * preferred size when they all fit and otherwise shrink evenly, but never
   * below the minimum. When even the smallest tiles don't all fit, only as
   * many windows as fit are shown, and the line's last slot is kept for a
   * count of the rest. At least one window is always shown, as long as
   * there are any. Across the line, tiles also shrink to the room there,
   * down to the same minimum. Pure math, testable in isolation.
   *
   * @param tile_size the resulting thumbnail width
   * @param shown the resulting number of windows shown
   * @param position the dock position
   * @param monitor the dock's monitor, whose shape the thumbnails take
   * @param count the number of windows
   * @param size the preferred thumbnail width
   * @param min_size the smallest thumbnail width
   * @param width the width the tiles have room for
   * @param height the height the tiles have room for
   * @param tile_width_extra the width a tile adds around its thumbnail
   * @param tile_height_extra the height a tile adds around its thumbnail, its title included
   * @param spacing the space between tiles
   */
  public static void compute_preview_layout (out int tile_size, out int shown,
                                             Gtk.PositionType position, Gdk.Rectangle monitor,
                                             int count, int size, int min_size, int width, int height,
                                             int tile_width_extra, int tile_height_extra,
                                             int spacing) {
    var horizontal = (position == Gtk.PositionType.TOP || position == Gtk.PositionType.BOTTOM);

    // Each tile has to fit the room across the line by itself
    if (horizontal)
      size = int.min (size, preview_width_for_thumbnail_height (height - tile_height_extra, monitor));
    else
      size = int.min (size, width - tile_width_extra);
    size = int.max (min_size, size);

    tile_size = size;
    shown = 0;

    if (count <= 0)
      return;

    // The largest size at which every tile fits along the line
    var length = (horizontal ? width : height);
    var extent = (length - (count - 1) * spacing) / count;
    var fit = horizontal
      ? extent - tile_width_extra
      : preview_width_for_thumbnail_height (extent - tile_height_extra, monitor);

    if (fit >= min_size) {
      tile_size = int.min (size, fit);
      shown = count;
      return;
    }

    // Even the smallest tiles don't all fit, so fill the line with them and
    // keep its last slot for the count of the rest
    tile_size = min_size;

    var slot = horizontal
      ? min_size + tile_width_extra
      : preview_thumbnail_height (min_size, monitor) + tile_height_extra;

    // A slot and its spacing only take no space together when the line has
    // no room at all, which leaves just the one window that always shows
    var slots = (length + spacing) / int.max (1, slot + spacing);
    shown = int.max (1, slots - 1);
  }

  /**
   * Where to put a window preview popup: past the gap from the anchor,
   * centered on it along the dock's edge, and kept within the dock's area,
   * pinned to the area's start when it is too big. Without enough room
   * across, staying within the area wins over keeping the gap. Pure math,
   * testable in isolation.
   *
   * @param x the resulting x coordinate
   * @param y the resulting y coordinate
   * @param position the dock position
   * @param anchor_x the x coordinate the popup is anchored to
   * @param anchor_y the y coordinate the popup is anchored to
   * @param width the popup's width
   * @param height the popup's height
   * @param gap the space between the anchor and the popup
   * @param area the dock's area, the monitor or its work area
   */
  public static void compute_preview_position (out int x, out int y,
                                               Gtk.PositionType position, int anchor_x, int anchor_y,
                                               int width, int height, int gap, Gdk.Rectangle area) {
    switch (position) {
    default:
    case Gtk.PositionType.BOTTOM:
      x = anchor_x - width / 2;
      y = anchor_y - gap - height;
      break;
    case Gtk.PositionType.TOP:
      x = anchor_x - width / 2;
      y = anchor_y + gap;
      break;
    case Gtk.PositionType.LEFT:
      x = anchor_x + gap;
      y = anchor_y - height / 2;
      break;
    case Gtk.PositionType.RIGHT:
      x = anchor_x - gap - width;
      y = anchor_y - height / 2;
      break;
    }

    x = int.max (area.x, int.min (x, area.x + area.width - width));
    y = int.max (area.y, int.min (y, area.y + area.height - height));
  }

  /**
   * Whether a point is where the pointer may be while a window preview
   * popup is open: on the dock, or anywhere in the span from the hovered
   * item to the popup, which covers the gap between them and diagonal paths
   * toward the popup's far ends. The popup and item must not be empty, as
   * GDK's union still stretches the span to an empty rectangle's position.
   * Pure math, testable in isolation.
   *
   * @param x the x coordinate of the point
   * @param y the y coordinate of the point
   * @param popup the popup
   * @param item the hovered item
   * @param dock the dock's cursor region
   * @return whether the point is in the zone
   */
  public static bool point_in_preview_zone (int x, int y, Gdk.Rectangle popup,
                                            Gdk.Rectangle item, Gdk.Rectangle dock) {
    Gdk.Rectangle span;
    popup.union (item, out span);

    return ((x >= span.x && x < span.x + span.width && y >= span.y && y < span.y + span.height)
            || (x >= dock.x && x < dock.x + dock.width && y >= dock.y && y < dock.y + dock.height));
  }
}
