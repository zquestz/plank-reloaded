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
   * Whether a file's first bytes are an AppImage's: an ELF header with "AI"
   * and the AppImage type, 1 or 2, at byte 8. Pure, testable in isolation.
   *
   * @param header the file's first bytes
   * @return whether they start an AppImage
   */
  public static bool is_appimage_header (uint8[] header) {
    if (header.length < 11)
      return false;

    // "\x7fELF"
    if (header[0] != 0x7f || header[1] != 0x45 || header[2] != 0x4c || header[3] != 0x46)
      return false;

    // "AI", then the type
    return (header[8] == 0x41 && header[9] == 0x49 && (header[10] == 1 || header[10] == 2));
  }

  /**
   * Whether a file is an AppImage, judged by its first bytes, so its name
   * doesn't matter.
   *
   * @param file the file in question
   * @return whether it is an AppImage
   */
  public static bool is_appimage (File file) {
    // Only a regular file can be one, and checking first keeps a FIFO or a
    // device from blocking the open below. Symlinks are followed
    if (file.query_file_type (FileQueryInfoFlags.NONE) != FileType.REGULAR)
      return false;

    try {
      var stream = file.read ();
      var header = new uint8[11];
      size_t length;
      stream.read_all (header, out length);
      stream.close ();

      return (length == header.length && is_appimage_header (header));
    } catch (Error e) {
      // Directories, missing and unreadable files are no AppImages
      return false;
    }
  }

  /**
   * Makes an AppImage executable if it isn't yet, but only one the user
   * owns: system files are never changed. It becomes executable wherever it
   * is readable, as file managers do.
   *
   * @param file the AppImage
   * @return whether it is executable now
   */
  public static bool ensure_appimage_executable (File file) {
    try {
      var info = file.query_info ("%s,%s,%s".printf (FileAttribute.ACCESS_CAN_EXECUTE, FileAttribute.UNIX_MODE, FileAttribute.UNIX_UID),
                                  FileQueryInfoFlags.NONE);
      if (info.get_attribute_boolean (FileAttribute.ACCESS_CAN_EXECUTE))
        return true;

      if (info.get_attribute_uint32 (FileAttribute.UNIX_UID) != (uint32) Posix.getuid ()) {
        warning ("Unable to run '%s': it isn't executable, and it belongs to another user", file.get_path ());
        return false;
      }

      var mode = info.get_attribute_uint32 (FileAttribute.UNIX_MODE);
      file.set_attribute_uint32 (FileAttribute.UNIX_MODE, mode | ((mode & 0444) >> 2), FileQueryInfoFlags.NONE);
      message ("Made '%s' executable to run it", file.get_path ());

      return true;
    } catch (Error e) {
      warning ("Unable to make '%s' executable: %s", file.get_path (), e.message);
      return false;
    }
  }
}
