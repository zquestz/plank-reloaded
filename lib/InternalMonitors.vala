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
   * A monitor's identity from its EDID: manufacturer, product code and
   * serial number, such as SAM-0F35-HNMT500123, the serial from its serial
   * string when it has one, else its serial number. A monitor reporting no
   * serial is identified by its model alone. Pure, testable in isolation.
   *
   * @param edid the EDID as the monitor reports it
   * @return the identity, or null when the EDID isn't valid
   */
  public static string? edid_identity (uint8[] edid) {
    const uint8[] HEADER = { 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00 };

    if (edid.length < 128)
      return null;

    for (var i = 0; i < HEADER.length; i++)
      if (edid[i] != HEADER[i])
        return null;

    // Three letters of five bits each, 1 for A
    var packed = (edid[8] << 8) | edid[9];
    var manufacturer = new StringBuilder ();
    for (var shift = 10; shift >= 0; shift -= 5) {
      var letter = (packed >> shift) & 0x1f;
      if (letter < 1 || letter > 26)
        return null;
      manufacturer.append_c ((char) ('A' + letter - 1));
    }

    var identity = "%s-%04X".printf (manufacturer.str, edid[10] | (edid[11] << 8));

    // A display descriptor tagged 0xFF holds the serial as text, ended by a
    // line feed
    for (var offset = 54; offset <= 108; offset += 18) {
      if (edid[offset] != 0 || edid[offset + 1] != 0 || edid[offset + 3] != 0xff)
        continue;

      var serial = new StringBuilder ();
      for (var i = offset + 5; i < offset + 18 && edid[i] != 0x0a; i++)
        if (((char) edid[i]).isalnum ())
          serial.append_c ((char) edid[i]);

      if (serial.len > 0)
        return "%s-%s".printf (identity, serial.str);
    }

    uint32 number = edid[12] | (edid[13] << 8) | (edid[14] << 16) | ((uint32) edid[15] << 24);
    if (number != 0)
      return "%s-%08X".printf (identity, number);

    return identity;
  }

  /**
   * Whether a monitor is a laptop's own screen, by its connector name.
   *
   * @param connector the monitor's connector, such as eDP-1
   * @return whether the monitor is built in
   */
  public static bool monitor_is_builtin (string connector) {
    return (connector.has_prefix ("eDP") || connector.has_prefix ("LVDS") || connector.has_prefix ("DSI"));
  }

  /**
   * Where each monitor sits in the layout: "builtin" for a laptop's own
   * screen, else its place among the external monitors from left to right,
   * top to bottom on ties, with how many there are, so a layout of three
   * monitors never takes the places of one of two. Pure, testable in
   * isolation.
   *
   * @param monitors the monitors' geometries
   * @param builtin whether each monitor is built in
   * @return each monitor's position
   */
  public static string[] monitor_positions (Gdk.Rectangle[] monitors, bool[] builtin) {
    var positions = new string[monitors.length];
    var externals = new Gee.ArrayList<int> ();

    for (var i = 0; i < monitors.length; i++) {
      if (builtin[i])
        positions[i] = "builtin";
      else
        externals.add (i);
    }

    externals.sort ((a, b) => {
      if (monitors[a].x != monitors[b].x)
        return (monitors[a].x < monitors[b].x ? -1 : 1);
      if (monitors[a].y != monitors[b].y)
        return (monitors[a].y < monitors[b].y ? -1 : 1);
      return 0;
    });

    for (var rank = 0; rank < externals.size; rank++)
      positions[externals[rank]] = "external-%d-%d".printf (externals.size, rank);

    return positions;
  }

  /**
   * The dock an earlier monitor manager kept for a connector, named by the
   * connector alone or followed by the monitor's manufacturer and size in
   * millimeters, such as DP-2-1 or DP-2-1-SAM-797x333mm. Pure, testable in
   * isolation.
   *
   * @param connector the monitor's connector
   * @param names the names of the docks that have settings
   * @return the dock's name, or null
   */
  public static string? earlier_monitor_dock (string connector, string[] names) {
    string? bare = null;

    foreach (unowned string name in names) {
      if (name == connector) {
        bare = name;
        continue;
      }

      if (!name.has_prefix (connector + "-"))
        continue;

      // The rest is the manufacturer, then the size, such as SAM-797x333mm;
      // a manufacturer starts with a letter, which tells DP-2's dock from
      // DP-2-1's
      var rest = name.substring (connector.length + 1);
      var size_start = rest.last_index_of_char ('-');
      if (size_start <= 0 || !rest[0].isalpha ())
        continue;

      if (Regex.match_simple ("^[0-9]+x[0-9]+mm$", rest.substring (size_start + 1)))
        return name;
    }

    return bare;
  }

  /**
   * Chooses the dock, and so the settings and launchers, each monitor gets.
   * A monitor seen before gets its dock back by its EDID identity; one an
   * earlier monitor manager kept a dock for gets that dock; any other takes
   * the dock of the monitor that was last in its position; failing all
   * that, a new dock. No two monitors share a dock. The choices are
   * recorded in known, by identity and by position, for next time. Pure,
   * testable in isolation.
   *
   * @param identities each monitor's EDID identity, or null
   * @param positions each monitor's position, from monitor_positions ()
   * @param earlier each monitor's dock from an earlier monitor manager, or null
   * @param known the docks chosen before, by "edid:" identity and "position:" position
   * @param taken the names of every dock that has settings
   * @return each monitor's dock
   */
  public static string[] choose_monitor_docks (string?[] identities, string[] positions, string?[] earlier,
                                               Gee.Map<string, string> known, string[] taken) {
    var docks = new string?[identities.length];
    var used = new Gee.HashSet<string> ();

    // Identities first, so a monitor moved within the layout keeps its dock
    // before another monitor can take it by position
    for (var i = 0; i < identities.length; i++) {
      if (identities[i] == null)
        continue;

      var dock = known["edid:" + identities[i]];
      if (dock != null && !used.contains (dock)) {
        docks[i] = dock;
        used.add (dock);
      }
    }

    for (var i = 0; i < identities.length; i++) {
      if (docks[i] == null && earlier[i] != null && !used.contains (earlier[i])) {
        docks[i] = earlier[i];
        used.add (earlier[i]);
      }
    }

    for (var i = 0; i < identities.length; i++) {
      if (docks[i] != null)
        continue;

      var dock = known["position:" + positions[i]];
      if (dock != null && !used.contains (dock)) {
        docks[i] = dock;
        used.add (dock);
      }
    }

    var names = new Gee.HashSet<string> ();
    foreach (unowned string name in taken)
      names.add (name);
    names.add_all (known.values);

    var next = 1;
    for (var i = 0; i < identities.length; i++) {
      if (docks[i] != null)
        continue;

      while (names.contains ("monitor%d".printf (next)) || used.contains ("monitor%d".printf (next)))
        next++;

      docks[i] = "monitor%d".printf (next);
      used.add (docks[i]);
    }

    var result = new string[identities.length];
    for (var i = 0; i < identities.length; i++) {
      result[i] = docks[i];

      if (identities[i] != null)
        known["edid:" + identities[i]] = docks[i];
      known["position:" + positions[i]] = docks[i];
    }

    return result;
  }
}
