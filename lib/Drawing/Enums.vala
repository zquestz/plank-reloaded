//
// Copyright (C) 2025 Plank Reloaded Developers
// Copyright (C) 2016 Rico Tzschichholz
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
   * The style of the item indicator.
   */
  public enum IndicatorStyleType {
    /**
     * A glowing dot which is gtk-theme-colored.
     */
    LEGACY,
    /**
     * A glowing dot using a color defined by the theme
     */
    GLOW,
    /**
     * A solid circle using a color defined by the theme
     */
    CIRCLE,
    /**
     * A solid line using a color defined by the theme
     */
    LINE
  }

  /**
   * The style of the active item.
   */
  public enum ActiveItemStyleType {
    /**
     * A vertical gradient which is colored based of the item's icon.
     */
    LEGACY,
    /**
     * A vertical gradient using a color defined by the theme
     */
    COLOR_GRADIENT,
    /**
     * A solid color based of the item's icon.
     */
    SOLID,
    /**
     * A solid color defined by the theme
     */
    COLOR_SOLID,
    /**
     * A centered gradient which is colored based of the item's icon.
     */
    CENTER_GRADIENT,
    /**
     * A centered gradient using a color defined by the theme
     */
    COLOR_CENTER_GRADIENT
  }

  /**
   * The style of the badge.
   */
  public enum BadgeStyleType {
    /**
     * A vertical gradient which is colored based on the indicator color
     */
    LEGACY,
    /**
     * A solid color defined by the theme
     */
    SOLID
  }
}
