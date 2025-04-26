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
    /**
     * Truncates a string at the middle to ensure it is no longer than max_length.
     * If the string is truncated, an ellipsis will be inserted in the middle.
     *
     * @param str The string to truncate
     * @param max_length Maximum length for the returned string
     * @return A string not longer than max_length
     */
    public string truncate_middle(string str, int max_length) {
      if (str.length <= max_length) {
        return str;
      }

      if (max_length < 5) {
        return str.substring(0, max_length);
      }

      int half = (max_length - 1) / 2;
      int left_size = half;
      int right_size = max_length - left_size - 1;

      return str.substring(0, left_size) + "…" + str.substring(str.length - right_size);
    }
  }
}
