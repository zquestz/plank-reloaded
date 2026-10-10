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
   * The element a dock's name takes in a DBus object path, which holds only
   * ASCII letters, digits and underscores: any other byte becomes an
   * underscore, as GApplication turns an application id's hyphens into
   * underscores in its own path, so a dock named in the application id
   * still matches the end of that path. Pure, testable in isolation.
   *
   * @param name the dock's name
   * @return the path element
   */
  public static string dbus_path_element (string name) {
    var element = new StringBuilder.sized (name.length);

    for (var i = 0; i < name.length; i++) {
      var c = name[i];
      element.append_c (c.isalnum () || c == '_' ? c : '_');
    }

    return element.str;
  }
}
