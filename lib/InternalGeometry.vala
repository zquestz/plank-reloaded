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
}
