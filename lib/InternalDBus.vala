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
   * The application id of a dock. Without a name, Plank runs every dock in
   * enabled-docks under the plain id. A dock run with -n gets one of its own,
   * and since its name can be anything, the id comes from the name's
   * checksum, which always makes a valid bus name and the same one for the
   * same name.
   *
   * @param app_dbus the plain application id
   * @param dock_name the name given with -n, or an empty string for none
   * @return the application id
   */
  public static string dock_application_id (string app_dbus, string dock_name) {
    if (dock_name == "")
      return app_dbus;

    return "%s.h%s".printf (app_dbus, Checksum.compute_for_string (ChecksumType.SHA256, dock_name));
  }

  /**
   * The object path of a dock's items, under its application's path. Docks
   * sharing a process each need a path of their own, since a connection
   * holds only one object per interface at a path. A dock's name can be
   * anything, so it's escaped, which always makes a valid element and never
   * the same one for two names.
   *
   * @param application_path the application's object path
   * @param dock_name the dock's name
   * @return the object path of the dock's items
   */
  public static string dock_dbus_object_path (string application_path, string dock_name) {
    return "%s/%s".printf (application_path, DBus.escape_object_path (dock_name));
  }
}
