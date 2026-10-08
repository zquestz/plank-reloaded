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

using Plank;

namespace PlankTests {
  public static void register_services_tests () {
    Test.add_func ("/Services/Environment/desktop_from_string", environment_desktop_from_string);
    Test.add_func ("/Services/Environment/desktop_from_string_unknown_fallthrough", environment_desktop_from_string_unknown);
    Test.add_func ("/Services/Environment/desktop_from_string_case_insensitive", environment_desktop_from_string_case);
    Test.add_func ("/Services/Environment/desktop_from_string_multi", environment_desktop_from_string_multi);
    Test.add_func ("/Services/Environment/desktop_bitmask", environment_desktop_bitmask);
    Test.add_func ("/Services/Helpers/truncate_middle_short", helpers_truncate_middle_short);
    Test.add_func ("/Services/Helpers/truncate_middle_exact", helpers_truncate_middle_exact);
    Test.add_func ("/Services/Helpers/truncate_middle_long", helpers_truncate_middle_long);
    Test.add_func ("/Services/Helpers/truncate_middle_very_short_limit", helpers_truncate_middle_very_short_limit);
    Test.add_func ("/Services/Helpers/truncate_middle_utf8", helpers_truncate_middle_utf8);
    Test.add_func ("/Services/Helpers/truncate_middle_cjk", helpers_truncate_middle_cjk);
    Test.add_func ("/Services/Helpers/truncate_middle_combining", helpers_truncate_middle_combining);
    Test.add_func ("/Services/Helpers/truncate_middle_emoji", helpers_truncate_middle_emoji);
    Test.add_func ("/Services/Helpers/truncate_middle_very_short_limit_combining", helpers_truncate_middle_very_short_limit_combining);
    Test.add_func ("/Services/Helpers/truncate_middle_edge_cases", helpers_truncate_middle_edge_cases);
    Test.add_func ("/Services/Helpers/truncate_middle_no_room", helpers_truncate_middle_no_room);
    Test.add_func ("/Services/Helpers/truncate_middle_huge", helpers_truncate_middle_huge);
    Test.add_func ("/Services/DockWindowPosition/bottom_composited", dock_win_pos_bottom_composited);
    Test.add_func ("/Services/DockWindowPosition/top_composited", dock_win_pos_top_composited);
    Test.add_func ("/Services/DockWindowPosition/left_composited", dock_win_pos_left_composited);
    Test.add_func ("/Services/DockWindowPosition/right_composited", dock_win_pos_right_composited);
    Test.add_func ("/Services/DockWindowPosition/bottom_with_gap", dock_win_pos_bottom_with_gap);
    Test.add_func ("/Services/DockWindowPosition/offset_monitor", dock_win_pos_offset_monitor);
    Test.add_func ("/Services/BackgroundPadding/bottom", bg_padding_bottom);
    Test.add_func ("/Services/BackgroundPadding/top", bg_padding_top);
    Test.add_func ("/Services/BackgroundPadding/left", bg_padding_left);
    Test.add_func ("/Services/BackgroundPadding/right", bg_padding_right);
    Test.add_func ("/Services/BackgroundPadding/with_hide_offset", bg_padding_with_hide_offset);
    Test.add_func ("/Services/EasingBounce/start_zero", easing_bounce_start_zero);
    Test.add_func ("/Services/EasingBounce/end_zero", easing_bounce_end_zero);
    Test.add_func ("/Services/EasingBounce/midpoint_positive", easing_bounce_midpoint_positive);
    Test.add_func ("/Services/EasingBounce/always_non_negative", easing_bounce_always_non_negative);
    Test.add_func ("/Services/SessionType/known_types", session_type_known);
    Test.add_func ("/Services/SessionType/case_insensitive", session_type_case);
    Test.add_func ("/Services/SessionType/unknown_defaults", session_type_unknown);
    Test.add_func ("/Services/ColorPrefs/round_trip", color_prefs_round_trip);
    Test.add_func ("/Services/ColorPrefs/clamping", color_prefs_clamping);
    Test.add_func ("/Services/ColorPrefs/format", color_prefs_format);
    Test.add_func ("/Services/DockDrawPosition/bottom_visible", draw_position_bottom_visible);
    Test.add_func ("/Services/DockDrawPosition/bottom_hidden", draw_position_bottom_hidden);
    Test.add_func ("/Services/DockDrawPosition/bottom_half", draw_position_bottom_half);
    Test.add_func ("/Services/DockDrawPosition/top_hidden", draw_position_top_hidden);
    Test.add_func ("/Services/DockDrawPosition/left_hidden", draw_position_left_hidden);
    Test.add_func ("/Services/DockDrawPosition/right_hidden", draw_position_right_hidden);
    Test.add_func ("/Services/DockDrawPosition/with_hide_offset", draw_position_with_hide_offset);
    Test.add_func ("/Services/Easing/linear_bounds", easing_linear_bounds);
    Test.add_func ("/Services/Easing/linear_midpoint", easing_linear_midpoint);
    Test.add_func ("/Services/Easing/all_modes_bounds", easing_all_modes_bounds);
    Test.add_func ("/Services/DrawValue/move_in_bottom", draw_value_move_in_bottom);
    Test.add_func ("/Services/DrawValue/move_in_top", draw_value_move_in_top);
    Test.add_func ("/Services/DrawValue/move_right_bottom", draw_value_move_right_bottom);
    Test.add_func ("/Services/DrawValue/move_right_left", draw_value_move_right_left);
    Test.add_func ("/Services/Struts/single_monitor_bottom", struts_single_monitor_bottom);
    Test.add_func ("/Services/Struts/single_monitor_top", struts_single_monitor_top);
    Test.add_func ("/Services/Struts/single_monitor_left", struts_single_monitor_left);
    Test.add_func ("/Services/Struts/single_monitor_right", struts_single_monitor_right);
    Test.add_func ("/Services/Struts/multi_monitor_bottom", struts_multi_monitor_bottom);
    Test.add_func ("/Services/Struts/scaling_2x", struts_scaling_2x);
    Test.add_func ("/Services/Struts/with_gap", struts_with_gap);
    Test.add_func ("/Services/Struts/multi_monitor_scaling_2x_bottom", struts_multi_monitor_scaling_2x_bottom);
    Test.add_func ("/Services/Struts/multi_monitor_scaling_2x_right", struts_multi_monitor_scaling_2x_right);
    Test.add_func ("/Services/Struts/gap_with_scaling_2x", struts_gap_with_scaling_2x);
    Test.add_func ("/Services/Struts/top_scaling_2x", struts_top_scaling_2x);
    Test.add_func ("/Services/Struts/left_scaling_2x", struts_left_scaling_2x);
    Test.add_func ("/Services/Struts/right_scaling_2x", struts_right_scaling_2x);
    Test.add_func ("/Services/Struts/non_primary_monitor_bottom", struts_non_primary_monitor_bottom);
    Test.add_func ("/Services/Struts/non_primary_monitor_scaling_2x", struts_non_primary_monitor_scaling_2x);
    Test.add_func ("/Services/Struts/ewmh_xinerama_example", struts_ewmh_xinerama_example);
    Test.add_func ("/Services/Struts/different_height_monitors_scaling_2x", struts_different_height_monitors_scaling_2x);
    Test.add_func ("/Services/Matcher/desktop_file_for_window_class", matcher_desktop_file_for_window_class);
    Test.add_func ("/Services/DockEdge/monitor_mode_edges", dock_edge_monitor_mode_edges);
    Test.add_func ("/Services/DockEdge/outside_span", dock_edge_outside_span);
    Test.add_func ("/Services/DockEdge/work_area_band", dock_edge_work_area_band);
    Test.add_func ("/Services/DockEdge/neighbouring_monitor", dock_edge_neighbouring_monitor);
    Test.add_func ("/Services/DockEdge/offset_monitor", dock_edge_offset_monitor);
    Test.add_func ("/Services/DockEdge/empty_monitor", dock_edge_empty_monitor);
    Test.add_func ("/Services/PreviewThumbnail/shape", preview_thumbnail_shape);
    Test.add_func ("/Services/PreviewThumbnail/inverse", preview_thumbnail_inverse);
    Test.add_func ("/Services/PreviewSpace/edges", preview_space_edges);
    Test.add_func ("/Services/PreviewSpace/offset_monitor", preview_space_offset_monitor);
    Test.add_func ("/Services/PreviewLayout/all_fit", preview_layout_all_fit);
    Test.add_func ("/Services/PreviewLayout/shrink", preview_layout_shrink);
    Test.add_func ("/Services/PreviewLayout/overflow", preview_layout_overflow);
    Test.add_func ("/Services/PreviewLayout/across_limit", preview_layout_across_limit);
    Test.add_func ("/Services/PreviewLayout/tight_space", preview_layout_tight_space);
    Test.add_func ("/Services/PreviewPosition/edges", preview_position_edges);
    Test.add_func ("/Services/PreviewPosition/clamped", preview_position_clamped);
    Test.add_func ("/Services/PreviewZone/bottom", preview_zone_bottom);
    Test.add_func ("/Services/PreviewZone/side", preview_zone_side);
  }

  void matcher_desktop_file_for_window_class () {
    // The fixtures from tests/data/applications, copied into the test home's
    // XDG_DATA_HOME before any test runs, since GLib only picks up files added
    // after its first desktop ID lookup through an asynchronous monitor
    var applications = File.new_for_path (Environment.get_user_data_dir ()).get_child ("applications");
    var exact = applications.get_child ("org.example.TestWindow.desktop");
    var lower = applications.get_child ("testwindowlower.desktop");

    // The instance name matches as written, like dev.zed.Zed
    assert (Matcher.desktop_file_for_window_class ("org.example.TestWindow", "Other") == exact.get_path ());
    // The class name matches once lowercased
    assert (Matcher.desktop_file_for_window_class (null, "TestWindowLower") == lower.get_path ());
    // Entries hidden from menus are skipped
    assert (Matcher.desktop_file_for_window_class ("testwindowhidden", null) == null);
    assert (Matcher.desktop_file_for_window_class ("no-such-app", "NoSuchApp") == null);
  }

  //
  // Environment detection tests
  //

  void environment_desktop_from_string () {
    assert (XdgSessionDesktop.from_string ("xfce") == XdgSessionDesktop.XFCE);
    assert (XdgSessionDesktop.from_string ("cinnamon") == XdgSessionDesktop.CINNAMON);
    assert (XdgSessionDesktop.from_string ("x-cinnamon") == XdgSessionDesktop.CINNAMON);
    assert (XdgSessionDesktop.from_string ("gnome") == XdgSessionDesktop.GNOME);
    assert (XdgSessionDesktop.from_string ("gnome-xorg") == XdgSessionDesktop.GNOME);
    assert (XdgSessionDesktop.from_string ("gnome-classic") == XdgSessionDesktop.GNOME);
    assert (XdgSessionDesktop.from_string ("gnome-flashback") == XdgSessionDesktop.GNOME);
    assert (XdgSessionDesktop.from_string ("kde") == XdgSessionDesktop.KDE);
    assert (XdgSessionDesktop.from_string ("mate") == XdgSessionDesktop.MATE);
    assert (XdgSessionDesktop.from_string ("unity") == XdgSessionDesktop.UNITY);
    assert (XdgSessionDesktop.from_string ("ubuntu") == XdgSessionDesktop.UBUNTU);
    assert (XdgSessionDesktop.from_string ("ubuntu-xorg") == XdgSessionDesktop.UBUNTU);
    assert (XdgSessionDesktop.from_string ("pantheon") == XdgSessionDesktop.PANTHEON);
    assert (XdgSessionDesktop.from_string ("lxde") == XdgSessionDesktop.LXDE);
    assert (XdgSessionDesktop.from_string ("lxqt") == XdgSessionDesktop.LXDE);
  }

  void environment_desktop_from_string_unknown () {
    // Unknown strings should return UNKNOWN
    assert (XdgSessionDesktop.from_string ("lightdm-xsession") == XdgSessionDesktop.UNKNOWN);
    assert (XdgSessionDesktop.from_string ("something-random") == XdgSessionDesktop.UNKNOWN);
    assert (XdgSessionDesktop.from_string ("") == XdgSessionDesktop.UNKNOWN);
  }

  void environment_desktop_from_string_case () {
    // Detection should be case-insensitive
    assert (XdgSessionDesktop.from_string ("XFCE") == XdgSessionDesktop.XFCE);
    assert (XdgSessionDesktop.from_string ("Xfce") == XdgSessionDesktop.XFCE);
    assert (XdgSessionDesktop.from_string ("CINNAMON") == XdgSessionDesktop.CINNAMON);
    assert (XdgSessionDesktop.from_string ("KDE") == XdgSessionDesktop.KDE);
    assert (XdgSessionDesktop.from_string ("GNOME") == XdgSessionDesktop.GNOME);
    assert (XdgSessionDesktop.from_string ("MATE") == XdgSessionDesktop.MATE);
    assert (XdgSessionDesktop.from_string ("Xubuntu") == XdgSessionDesktop.XFCE);
  }

  void environment_desktop_from_string_multi () {
    // Semicolon-separated values should OR together
    var result = XdgSessionDesktop.from_string ("ubuntu;xfce");
    assert ((result & XdgSessionDesktop.UBUNTU) != 0);
    assert ((result & XdgSessionDesktop.XFCE) != 0);
    assert ((result & XdgSessionDesktop.KDE) == 0);

    // Single unknown in a list shouldn't break the known ones
    var result2 = XdgSessionDesktop.from_string ("lightdm-xsession;XFCE");
    assert ((result2 & XdgSessionDesktop.XFCE) != 0);
  }

  void environment_desktop_bitmask () {
    // Verify bitmask matching works correctly
    var xfce = XdgSessionDesktop.from_string ("xfce");
    var kde = XdgSessionDesktop.from_string ("kde");
    var gnome = XdgSessionDesktop.from_string ("gnome");

    var mask = XdgSessionDesktop.GNOME | XdgSessionDesktop.XFCE | XdgSessionDesktop.KDE;

    assert ((mask & xfce) > 0);
    assert ((mask & kde) > 0);
    assert ((mask & gnome) > 0);

    var cinnamon = XdgSessionDesktop.from_string ("cinnamon");
    assert ((mask & cinnamon) == 0);
  }

  //
  // Helpers tests
  //

  void helpers_truncate_middle_short () {
    // String shorter than limit should be returned as-is
    var result = Helpers.truncate_middle ("hello", 10);
    assert (result == "hello");
  }

  void helpers_truncate_middle_exact () {
    // String exactly at limit should be returned as-is
    var result = Helpers.truncate_middle ("hello", 5);
    assert (result == "hello");
  }

  void helpers_truncate_middle_long () {
    // String longer than limit should be truncated with ellipsis in middle
    var result = Helpers.truncate_middle ("hello world test", 11);
    assert (result.char_count () == 11);
    assert (result.contains ("…"));
    // Should start with beginning of original
    assert (result.has_prefix ("hello"));
    // Should end with end of original
    assert (result.has_suffix ("test"));
  }

  void helpers_truncate_middle_very_short_limit () {
    // Very short limit (< 5) should just truncate from start
    var result = Helpers.truncate_middle ("hello world", 3);
    assert (result.char_count () == 3);
    assert (result == "hel");
  }

  void helpers_truncate_middle_utf8 () {
    // UTF-8 multi-byte characters should be handled by character count, not byte count
    // Each é is 2 bytes in UTF-8
    var input = "éléphant résumé";
    var char_count = input.char_count ();
    assert (char_count == 15);

    var result = Helpers.truncate_middle (input, 9);
    assert (result.char_count () == 9);
    assert (result.contains ("…"));
    // Should preserve valid UTF-8
    assert (result.validate ());
  }

  void helpers_truncate_middle_cjk () {
    // CJK characters are 3 bytes each in UTF-8
    // If we used byte length instead of char_count, this would truncate too aggressively
    var input = "日本語テスト文字列";
    var char_count = input.char_count ();
    assert (char_count == 9);

    // At limit — should not truncate
    var result = Helpers.truncate_middle (input, 9);
    assert (result == input);

    // Below limit — should truncate by character count
    var result2 = Helpers.truncate_middle (input, 7);
    assert (result2.char_count () == 7);
    assert (result2.contains ("…"));
    assert (result2.validate ());
    // Should start with first characters
    assert (result2.has_prefix ("日本語"));
    // Should end with last characters
    assert (result2.has_suffix ("字列"));
  }

  void helpers_truncate_middle_combining () {
    // A letter with a combining accent is one character of two code points,
    // and a cut never separates them
    var e = "e\u0301";
    var input = e + e + e + e + e + e + e + e + e + e;
    assert (input.char_count () == 20);

    var result = Helpers.truncate_middle (input, 7);
    assert (result == e + e + e + "…" + e + e + e);

    // Six characters fit a limit of 6 or 9, though they are 12 code points
    var six = e + e + e + e + e + e;
    assert (Helpers.truncate_middle (six, 6) == six);
    assert (Helpers.truncate_middle (six, 9) == six);
  }

  void helpers_truncate_middle_emoji () {
    // A family joined by zero-width joiners is one character of 7 code
    // points, and stays whole on both sides of the ellipsis
    var family = "👩\u200D👩\u200D👧\u200D👦";
    var families = family + family + family + family + family + family;
    assert (families.char_count () == 42);

    var result = Helpers.truncate_middle (families, 5);
    assert (result == family + family + "…" + family + family);

    // A flag is one character of two regional indicators
    var flags = "🇯🇵🇺🇸🇫🇷🇩🇪🇮🇹🇬🇧🇨🇦";
    assert (flags.char_count () == 14);

    var result2 = Helpers.truncate_middle (flags, 6);
    assert (result2 == "🇯🇵🇺🇸…🇮🇹🇬🇧🇨🇦");
  }

  void helpers_truncate_middle_very_short_limit_combining () {
    // A very short limit cuts from the start by whole characters too
    var e = "e\u0301";
    var six = e + e + e + e + e + e;
    assert (Helpers.truncate_middle (six, 1) == e);
    assert (Helpers.truncate_middle (six, 2) == e + e);
    assert (Helpers.truncate_middle (six, 3) == e + e + e);
    assert (Helpers.truncate_middle (six, 4) == e + e + e + e);
  }

  void helpers_truncate_middle_edge_cases () {
    // An empty string stays empty
    assert (Helpers.truncate_middle ("", 5) == "");

    // CR LF is one character, which stays whole on either side of the
    // ellipsis
    assert (Helpers.truncate_middle ("\r\nX", 1) == "\r\n");
    assert (Helpers.truncate_middle ("a\r\nbcdefg", 5) == "a\r\n…fg");
    assert (Helpers.truncate_middle ("abcdef\r\ng", 5) == "ab…\r\ng");

    // Combining marks with no letter before them are one character
    var marks = "\u0301\u0301\u0301";
    assert (Helpers.truncate_middle (marks, 1) == marks);
  }

  void helpers_truncate_middle_no_room () {
    // A limit with no room leaves nothing
    assert (Helpers.truncate_middle ("hello", 0) == "");
    assert (Helpers.truncate_middle ("hello", -1) == "");
  }

  void helpers_truncate_middle_huge () {
    // Text too long to analyze whole has only its ends analyzed, with the
    // same result as for short text
    var x = string.nfill (5000, 'x');
    assert (Helpers.truncate_middle ("é" + x + "z", 9) == "éxxx…xxxz");

    // Accents at the start, and flags and a family at the end, stay whole
    var e = "e" + ((unichar) 0x301).to_string ();
    var zwj = ((unichar) 0x200D).to_string ();
    var family = "👩" + zwj + "👩" + zwj + "👧" + zwj + "👦";
    var input = e + e + e + x + "🇯🇵🇺🇸" + family;
    assert (Helpers.truncate_middle (input, 7) == e + e + e + "…🇯🇵🇺🇸" + family);

    // A very short limit keeps only the start
    assert (Helpers.truncate_middle (input, 2) == e + e);

    // Flags pair up from the start of their run, even where the end's
    // analysis would begin inside it, here at the run's second code point
    var run = new StringBuilder ();
    for (var i = 0; i < 512; i++) {
      run.append ("🇯🇵");
    }
    run.append ("🇯");
    assert (Helpers.truncate_middle ("a" + x + run.str, 7) == "axx…🇯🇵🇯🇵🇯");

    // and where it would begin at the run's third code point
    var even_run = new StringBuilder ();
    for (var i = 0; i < 513; i++) {
      even_run.append ("🇯🇵");
    }
    assert (Helpers.truncate_middle ("a" + x + even_run.str, 7) == "axx…🇯🇵🇯🇵🇯🇵");

    // Text exactly at the limit stays whole, even where the end's analysis
    // begins inside a character whose start it can't see: here two women
    // joined across thousands of accents make one character
    var joined = new StringBuilder ("ab👩");
    for (var i = 0; i < 3000; i++) {
      joined.append_unichar (0x301);
    }
    joined.append (zwj + "👩cd");
    assert (Helpers.truncate_middle (joined.str, 5) == joined.str);

    // Absurd text, whose ends hold too few characters for the cuts, is
    // analyzed whole: here a letter carrying thousands of accents
    var accented = new StringBuilder ("e");
    for (var i = 0; i < 3000; i++) {
      accented.append_unichar (0x301);
    }
    assert (Helpers.truncate_middle (accented.str + "abcdefgh", 5) == accented.str + "a…gh");
    assert (Helpers.truncate_middle ("abcdefgh" + accented.str, 5) == "ab…h" + accented.str);
  }

  //
  // Session type detection tests
  //

  void session_type_known () {
    assert (XdgSessionType.from_string ("x11") == XdgSessionType.X11);
    assert (XdgSessionType.from_string ("wayland") == XdgSessionType.WAYLAND);
    assert (XdgSessionType.from_string ("tty") == XdgSessionType.TTY);
    assert (XdgSessionType.from_string ("mir") == XdgSessionType.MIR);
    assert (XdgSessionType.from_string ("unspecified") == XdgSessionType.UNSPECIFIED);
  }

  void session_type_case () {
    assert (XdgSessionType.from_string ("X11") == XdgSessionType.X11);
    assert (XdgSessionType.from_string ("Wayland") == XdgSessionType.WAYLAND);
    assert (XdgSessionType.from_string ("WAYLAND") == XdgSessionType.WAYLAND);
  }

  void session_type_unknown () {
    // Unknown strings should default to UNSPECIFIED
    assert (XdgSessionType.from_string ("something") == XdgSessionType.UNSPECIFIED);
    assert (XdgSessionType.from_string ("") == XdgSessionType.UNSPECIFIED);
  }

  //
  // Color prefs round-trip tests
  //

  void color_prefs_round_trip () {
    // A color should survive to_prefs_string → from_prefs_string
    Color original = { 0.5, 0.25, 0.75, 1.0 };
    var str = original.to_prefs_string ();
    var restored = Color.from_prefs_string (str);

    // Allow 1/255 precision loss from int conversion
    const double EPSILON = 1.0 / 255.0 + 0.001;
    assert (Math.fabs (original.red - restored.red) < EPSILON);
    assert (Math.fabs (original.green - restored.green) < EPSILON);
    assert (Math.fabs (original.blue - restored.blue) < EPSILON);
    assert (Math.fabs (original.alpha - restored.alpha) < EPSILON);
  }

  void color_prefs_clamping () {
    // Values outside 0-255 should be clamped
    var color = Color.from_prefs_string ("300;;-10;;128;;255");
    assert (color.red == 1.0);               // 300 clamped to 255 → 1.0
    assert (color.green == 0.0);             // -10 clamped to 0 → 0.0
    assert (color.blue > 0.49 && color.blue < 0.51);             // 128/255 ≈ 0.502
    assert (color.alpha == 1.0);             // 255 → 1.0
  }

  void color_prefs_format () {
    // Verify the string format uses ;; separators
    Color color = { 1.0, 0.0, 0.5, 1.0 };
    var str = color.to_prefs_string ();
    var parts = str.split (";;");
    assert (parts.length == 4);
    assert (int.parse (parts[0]) == 255);              // red
    assert (int.parse (parts[1]) == 0);                // green
    assert (int.parse (parts[3]) == 255);              // alpha
  }

  //
  // Dock window position tests
  //

  void dock_win_pos_bottom_composited () {
    int x, y;
    // 1920x1080 monitor at origin, 48px dock at bottom, composited
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    PositionManager.compute_dock_window_position (out x, out y,
                                                  Gtk.PositionType.BOTTOM, Gtk.Align.CENTER,
                                                  monitor, 1920, 48, 0, 0,
                                                  true, true, 1920, 48, false);

    assert (x == 0);
    assert (y == 1080 - 48);
  }

  void dock_win_pos_top_composited () {
    int x, y;
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    PositionManager.compute_dock_window_position (out x, out y,
                                                  Gtk.PositionType.TOP, Gtk.Align.CENTER,
                                                  monitor, 1920, 48, 0, 0,
                                                  true, true, 1920, 48, false);

    assert (x == 0);
    assert (y == 0);
  }

  void dock_win_pos_left_composited () {
    int x, y;
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    PositionManager.compute_dock_window_position (out x, out y,
                                                  Gtk.PositionType.LEFT, Gtk.Align.CENTER,
                                                  monitor, 48, 1080, 0, 0,
                                                  true, false, 48, 1080, false);

    assert (x == 0);
    assert (y == 0);
  }

  void dock_win_pos_right_composited () {
    int x, y;
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    PositionManager.compute_dock_window_position (out x, out y,
                                                  Gtk.PositionType.RIGHT, Gtk.Align.CENTER,
                                                  monitor, 48, 1080, 0, 0,
                                                  true, false, 48, 1080, false);

    assert (x == 1920 - 48);
    assert (y == 0);
  }

  void dock_win_pos_bottom_with_gap () {
    int x, y;
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    PositionManager.compute_dock_window_position (out x, out y,
                                                  Gtk.PositionType.BOTTOM, Gtk.Align.CENTER,
                                                  monitor, 1920, 48, 20, 0,
                                                  true, true, 1920, 48, false);

    assert (x == 0);
    // Gap pushes dock up from edge
    assert (y == 1080 - 48 - 20);
  }

  void dock_win_pos_offset_monitor () {
    int x, y;
    // Monitor not at origin (second monitor at x=1920)
    Gdk.Rectangle monitor = { 1920, 0, 1920, 1080 };
    PositionManager.compute_dock_window_position (out x, out y,
                                                  Gtk.PositionType.BOTTOM, Gtk.Align.CENTER,
                                                  monitor, 1920, 48, 0, 0,
                                                  true, true, 1920, 48, false);

    assert (x == 1920);
    assert (y == 1080 - 48);
  }

  //
  // Background padding tests
  //

  void bg_padding_bottom () {
    int x, y;
    // dock_height=48, bg_height=40, no hide offset
    // padding = 48 - 40 + 0 = 8
    PositionManager.compute_background_padding (out x, out y,
                                                Gtk.PositionType.BOTTOM, 200, 48, 200, 40, 0);

    assert (x == 0);
    assert (y == 8);
  }

  void bg_padding_top () {
    int x, y;
    PositionManager.compute_background_padding (out x, out y,
                                                Gtk.PositionType.TOP, 200, 48, 200, 40, 0);

    assert (x == 0);
    assert (y == -8);
  }

  void bg_padding_left () {
    int x, y;
    // dock_width=48, bg_width=40
    PositionManager.compute_background_padding (out x, out y,
                                                Gtk.PositionType.LEFT, 48, 200, 40, 200, 0);

    assert (x == -8);
    assert (y == 0);
  }

  void bg_padding_right () {
    int x, y;
    PositionManager.compute_background_padding (out x, out y,
                                                Gtk.PositionType.RIGHT, 48, 200, 40, 200, 0);

    assert (x == 8);
    assert (y == 0);
  }

  void bg_padding_with_hide_offset () {
    int x, y;
    // hide_offset adds to the padding
    PositionManager.compute_background_padding (out x, out y,
                                                Gtk.PositionType.BOTTOM, 200, 48, 200, 40, 5);

    assert (x == 0);
    assert (y == 13);              // 48 - 40 + 5
  }

  //
  // Easing bounce tests
  //

  void easing_bounce_start_zero () {
    // Bounce should start at 0
    var val = DockRenderer.easing_bounce (0.0, 1000.0, 2.0);
    assert (val == 0.0);
  }

  void easing_bounce_end_zero () {
    // Bounce should end at 0 (dampened to nothing)
    var val = DockRenderer.easing_bounce (1000.0, 1000.0, 2.0);
    assert (val == 0.0);
  }

  void easing_bounce_midpoint_positive () {
    // Bounce should be positive at midpoint
    var val = DockRenderer.easing_bounce (250.0, 1000.0, 2.0);
    assert (val > 0.0);
  }

  void easing_bounce_always_non_negative () {
    // Bounce uses fabs so should always be >= 0
    for (int i = 0; i <= 100; i++) {
      var val = DockRenderer.easing_bounce (i * 10.0, 1000.0, 2.0);
      assert (val >= 0.0);
      assert (val <= 1.0);
    }
  }

  //
  // Dock draw position tests
  //

  void draw_position_bottom_visible () {
    int x, y;
    // Fully visible (progress = 0) — no offset
    PositionManager.compute_dock_draw_position (out x, out y,
                                                Gtk.PositionType.BOTTOM, 0.0, 200, 48, 0);
    assert (x == 0);
    assert (y == 0);
  }

  void draw_position_bottom_hidden () {
    int x, y;
    // Fully hidden (progress = 1) — offset equals dock height
    PositionManager.compute_dock_draw_position (out x, out y,
                                                Gtk.PositionType.BOTTOM, 1.0, 200, 48, 0);
    assert (x == 0);
    assert (y == 48);
  }

  void draw_position_bottom_half () {
    int x, y;
    // Half hidden
    PositionManager.compute_dock_draw_position (out x, out y,
                                                Gtk.PositionType.BOTTOM, 0.5, 200, 48, 0);
    assert (x == 0);
    assert (y == 24);
  }

  void draw_position_top_hidden () {
    int x, y;
    // Top dock hides upward (negative y)
    PositionManager.compute_dock_draw_position (out x, out y,
                                                Gtk.PositionType.TOP, 1.0, 200, 48, 0);
    assert (x == 0);
    assert (y == -48);
  }

  void draw_position_left_hidden () {
    int x, y;
    // Left dock hides leftward (negative x)
    PositionManager.compute_dock_draw_position (out x, out y,
                                                Gtk.PositionType.LEFT, 1.0, 48, 200, 0);
    assert (x == -48);
    assert (y == 0);
  }

  void draw_position_right_hidden () {
    int x, y;
    // Right dock hides rightward (positive x)
    PositionManager.compute_dock_draw_position (out x, out y,
                                                Gtk.PositionType.RIGHT, 1.0, 48, 200, 0);
    assert (x == 48);
    assert (y == 0);
  }

  void draw_position_with_hide_offset () {
    int x, y;
    // Hide offset adds to the distance
    PositionManager.compute_dock_draw_position (out x, out y,
                                                Gtk.PositionType.BOTTOM, 1.0, 200, 48, 10);
    assert (x == 0);
    assert (y == 58);
  }

  //
  // Easing function tests
  //

  void easing_linear_bounds () {
    // Linear easing: t=0 → 0, t=d → 1
    assert (easing_for_mode (AnimationMode.LINEAR, 0.0, 1000.0) == 0.0);
    assert (easing_for_mode (AnimationMode.LINEAR, 1000.0, 1000.0) == 1.0);
  }

  void easing_linear_midpoint () {
    // Linear easing: midpoint should be exactly 0.5
    assert (easing_for_mode (AnimationMode.LINEAR, 500.0, 1000.0) == 0.5);
  }

  void easing_all_modes_bounds () {
    // All easing modes should return 0 at t=0 and 1 at t=d
    // and stay within the documented range of -1.0 to 2.0
    AnimationMode[] modes = {
      AnimationMode.LINEAR,
      AnimationMode.EASE_IN_QUAD,
      AnimationMode.EASE_OUT_QUAD,
      AnimationMode.EASE_IN_OUT_QUAD,
      AnimationMode.EASE_IN_CUBIC,
      AnimationMode.EASE_OUT_CUBIC,
      AnimationMode.EASE_IN_OUT_CUBIC,
      AnimationMode.EASE_IN_QUART,
      AnimationMode.EASE_OUT_QUART,
      AnimationMode.EASE_IN_OUT_QUART,
      AnimationMode.EASE_IN_QUINT,
      AnimationMode.EASE_OUT_QUINT,
      AnimationMode.EASE_IN_OUT_QUINT,
      AnimationMode.EASE_IN_SINE,
      AnimationMode.EASE_OUT_SINE,
      AnimationMode.EASE_IN_OUT_SINE,
      AnimationMode.EASE_IN_EXPO,
      AnimationMode.EASE_OUT_EXPO,
      AnimationMode.EASE_IN_OUT_EXPO,
      AnimationMode.EASE_IN_CIRC,
      AnimationMode.EASE_OUT_CIRC,
      AnimationMode.EASE_IN_OUT_CIRC,
      AnimationMode.EASE_IN_BACK,
      AnimationMode.EASE_OUT_BACK,
      AnimationMode.EASE_IN_OUT_BACK,
      AnimationMode.EASE_IN_BOUNCE,
      AnimationMode.EASE_OUT_BOUNCE,
      AnimationMode.EASE_IN_OUT_BOUNCE,
    };

    const double EPSILON = 0.0001;

    foreach (var mode in modes) {
      var start = easing_for_mode (mode, 0.0, 1000.0);
      var end = easing_for_mode (mode, 1000.0, 1000.0);

      // All modes start at ~0 and end at ~1
      assert (Math.fabs (start) < EPSILON);
      assert (Math.fabs (end - 1.0) < EPSILON);

      // Check 10 intermediate points stay in range
      for (int i = 1; i < 10; i++) {
        var val = easing_for_mode (mode, i * 100.0, 1000.0);
        assert (val >= -1.0 && val <= 2.0);
      }
    }
  }

  //
  // DockItemDrawValue movement tests
  //

  void draw_value_move_in_bottom () {
    var val = new DockItemDrawValue ();
    val.center = { 100.0, 200.0 };
    val.static_center = { 100.0, 200.0 };
    val.hover_region = { 80, 180, 40, 40 };
    val.draw_region = { 80, 180, 40, 40 };

    val.move_in (Gtk.PositionType.BOTTOM, 10.0);

    // Bottom dock: move_in decreases y (moves up toward screen)
    assert (val.center.y == 190.0);
    assert (val.static_center.y == 190.0);
    assert (val.hover_region.y == 170);
    assert (val.draw_region.y == 170);
    // x should not change
    assert (val.center.x == 100.0);
  }

  void draw_value_move_in_top () {
    var val = new DockItemDrawValue ();
    val.center = { 100.0, 200.0 };
    val.static_center = { 100.0, 200.0 };
    val.hover_region = { 80, 180, 40, 40 };
    val.draw_region = { 80, 180, 40, 40 };

    val.move_in (Gtk.PositionType.TOP, 10.0);

    // Top dock: move_in increases y (moves down toward screen)
    assert (val.center.y == 210.0);
    assert (val.static_center.y == 210.0);
    assert (val.hover_region.y == 190);
    assert (val.draw_region.y == 190);
  }

  void draw_value_move_right_bottom () {
    var val = new DockItemDrawValue ();
    val.center = { 100.0, 200.0 };
    val.static_center = { 100.0, 200.0 };
    val.hover_region = { 80, 180, 40, 40 };
    val.draw_region = { 80, 180, 40, 40 };
    val.background_region = { 80, 180, 40, 40 };

    val.move_right (Gtk.PositionType.BOTTOM, 15.0);

    // Bottom/Top dock: move_right increases x
    assert (val.center.x == 115.0);
    assert (val.static_center.x == 115.0);
    assert (val.hover_region.x == 95);
    assert (val.draw_region.x == 95);
    assert (val.background_region.x == 95);
    // y should not change
    assert (val.center.y == 200.0);
  }

  void draw_value_move_right_left () {
    var val = new DockItemDrawValue ();
    val.center = { 100.0, 200.0 };
    val.static_center = { 100.0, 200.0 };
    val.hover_region = { 80, 180, 40, 40 };
    val.draw_region = { 80, 180, 40, 40 };
    val.background_region = { 80, 180, 40, 40 };

    val.move_right (Gtk.PositionType.LEFT, 15.0);

    // Left/Right dock: move_right increases y (perpendicular axis)
    assert (val.center.y == 215.0);
    assert (val.static_center.y == 215.0);
    assert (val.hover_region.y == 195);
    assert (val.draw_region.y == 195);
    assert (val.background_region.y == 195);
    // x should not change
    assert (val.center.x == 100.0);
  }

  //
  // Struts computation tests
  //

  void struts_single_monitor_bottom () {
    var struts = new ulong[Struts.N_VALUES];
    // Single 1920x1080 monitor, 48px dock at bottom, no gap, 1x scale
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.BOTTOM,
                                    monitor, 1920, 1080, 1920, 48, 0, 1);

    assert (struts[Struts.BOTTOM] == 48);
    assert (struts[Struts.BOTTOM_START] == 0);
    assert (struts[Struts.BOTTOM_END] == 1919);
    assert (struts[Struts.TOP] == 0);
    assert (struts[Struts.LEFT] == 0);
    assert (struts[Struts.RIGHT] == 0);
  }

  void struts_single_monitor_top () {
    var struts = new ulong[Struts.N_VALUES];
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.TOP,
                                    monitor, 1920, 1080, 1920, 48, 0, 1);

    assert (struts[Struts.TOP] == 48);
    assert (struts[Struts.TOP_START] == 0);
    assert (struts[Struts.TOP_END] == 1919);
    assert (struts[Struts.BOTTOM] == 0);
  }

  void struts_single_monitor_left () {
    var struts = new ulong[Struts.N_VALUES];
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.LEFT,
                                    monitor, 1920, 1080, 48, 1080, 0, 1);

    assert (struts[Struts.LEFT] == 48);
    assert (struts[Struts.LEFT_START] == 0);
    assert (struts[Struts.LEFT_END] == 1079);
    assert (struts[Struts.RIGHT] == 0);
  }

  void struts_single_monitor_right () {
    var struts = new ulong[Struts.N_VALUES];
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.RIGHT,
                                    monitor, 1920, 1080, 48, 1080, 0, 1);

    assert (struts[Struts.RIGHT] == 48);
    assert (struts[Struts.RIGHT_START] == 0);
    assert (struts[Struts.RIGHT_END] == 1079);
    assert (struts[Struts.LEFT] == 0);
  }

  void struts_multi_monitor_bottom () {
    var struts = new ulong[Struts.N_VALUES];
    // Two 1920x1080 monitors side by side, dock on the right monitor
    // GDK logical bounding box = (3840, 1080)
    Gdk.Rectangle monitor = { 1920, 0, 1920, 1080 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.BOTTOM,
                                    monitor, 3840, 1080, 1920, 48, 0, 1);

    // BOTTOM = (48 + 0 + 1080 - 0 - 1080) * 1 = 48
    assert (struts[Struts.BOTTOM] == 48);
    // Strut range should cover only the right monitor
    assert (struts[Struts.BOTTOM_START] == 1920);
    assert (struts[Struts.BOTTOM_END] == 3839);
  }

  void struts_scaling_2x () {
    var struts = new ulong[Struts.N_VALUES];
    // Single 4K monitor with 2x scaling
    // GDK logical monitor = {0, 0, 1920, 1080}
    // screen dims = monitor bounds = (1920, 1080)
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.BOTTOM,
                                    monitor, 1920, 1080, 1920, 48, 0, 2);

    // BOTTOM = (48 + 0 + 1080 - 0 - 1080) * 2 = 96
    assert (struts[Struts.BOTTOM] == 96);
    assert (struts[Struts.BOTTOM_START] == 0);
    assert (struts[Struts.BOTTOM_END] == 3839);
  }

  void struts_with_gap () {
    var struts = new ulong[Struts.N_VALUES];
    // Single monitor with 10px gap
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.BOTTOM,
                                    monitor, 1920, 1080, 1920, 48, 10, 1);

    // BOTTOM strut should include gap
    assert (struts[Struts.BOTTOM] == 58);
  }

  void struts_multi_monitor_scaling_2x_bottom () {
    var struts = new ulong[Struts.N_VALUES];
    // Two 4K monitors side by side with 2x scaling
    // Right monitor GDK = {1920, 0, 1920, 1080}
    // GDK logical bounding box = (3840, 1080)
    Gdk.Rectangle monitor = { 1920, 0, 1920, 1080 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.BOTTOM,
                                    monitor, 3840, 1080, 1920, 48, 0, 2);

    // BOTTOM = (48 + 0 + 1080 - 0 - 1080) * 2 = 96
    assert (struts[Struts.BOTTOM] == 96);
    assert (struts[Struts.BOTTOM_START] == 3840);
    assert (struts[Struts.BOTTOM_END] == 7679);
  }

  void struts_multi_monitor_scaling_2x_right () {
    var struts = new ulong[Struts.N_VALUES];
    // Two 4K monitors stacked vertically with 2x scaling
    // Top monitor GDK = {0, 0, 1920, 1080}, bottom = {0, 1080, 1920, 1080}
    // GDK logical bounding box = (1920, 2160)
    // Dock on top monitor, RIGHT position
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.RIGHT,
                                    monitor, 1920, 2160, 48, 1080, 0, 2);

    // RIGHT = (48 + 0 + 1920 - 0 - 1920) * 2 = 96 (monitor right = screen right)
    assert (struts[Struts.RIGHT] == 96);
    assert (struts[Struts.RIGHT_START] == 0);
    assert (struts[Struts.RIGHT_END] == 2159);
  }

  void struts_gap_with_scaling_2x () {
    var struts = new ulong[Struts.N_VALUES];
    // Single 4K monitor, 2x scaling, 10px GDK gap, BOTTOM dock
    // GDK logical = {0, 0, 1920, 1080}
    // GDK logical bounding box = (1920, 1080)
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.BOTTOM,
                                    monitor, 1920, 1080, 1920, 48, 10, 2);

    // BOTTOM = (48 + 10 + 1080 - 0 - 1080) * 2 = 116
    assert (struts[Struts.BOTTOM] == 116);
    assert (struts[Struts.BOTTOM_START] == 0);
    assert (struts[Struts.BOTTOM_END] == 3839);

    // Also test RIGHT with gap + scaling
    var struts2 = new ulong[Struts.N_VALUES];
    PositionManager.compute_struts (ref struts2, Gtk.PositionType.RIGHT,
                                    monitor, 1920, 1080, 48, 1080, 10, 2);

    // RIGHT = (48 + 10 + 1920 - 0 - 1920) * 2 = 116
    assert (struts2[Struts.RIGHT] == 116);

    // And TOP with gap + scaling
    var struts3 = new ulong[Struts.N_VALUES];
    PositionManager.compute_struts (ref struts3, Gtk.PositionType.TOP,
                                    monitor, 1920, 1080, 1920, 48, 10, 2);

    // TOP = (0 + 48 + 10) * 2 = 116
    assert (struts3[Struts.TOP] == 116);

    // And LEFT with gap + scaling
    var struts4 = new ulong[Struts.N_VALUES];
    PositionManager.compute_struts (ref struts4, Gtk.PositionType.LEFT,
                                    monitor, 1920, 1080, 48, 1080, 10, 2);

    // LEFT = (0 + 48 + 10) * 2 = 116
    assert (struts4[Struts.LEFT] == 116);
  }

  void struts_top_scaling_2x () {
    var struts = new ulong[Struts.N_VALUES];
    // Single 4K monitor, 2x scaling, TOP dock
    // GDK logical = {0, 0, 1920, 1080}
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.TOP,
                                    monitor, 1920, 1080, 1920, 48, 0, 2);

    // TOP = (0 + 48 + 0) * 2 = 96
    assert (struts[Struts.TOP] == 96);
    assert (struts[Struts.TOP_START] == 0);
    assert (struts[Struts.TOP_END] == 3839);
  }

  void struts_left_scaling_2x () {
    var struts = new ulong[Struts.N_VALUES];
    // Single 4K monitor, 2x scaling, LEFT dock
    // GDK logical = {0, 0, 1920, 1080}
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.LEFT,
                                    monitor, 1920, 1080, 48, 1080, 0, 2);

    // LEFT = (0 + 48 + 0) * 2 = 96
    assert (struts[Struts.LEFT] == 96);
    assert (struts[Struts.LEFT_START] == 0);
    assert (struts[Struts.LEFT_END] == 2159);
  }

  void struts_right_scaling_2x () {
    var struts = new ulong[Struts.N_VALUES];
    // Single 4K monitor, 2x scaling, RIGHT dock
    // GDK logical = {0, 0, 1920, 1080}
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.RIGHT,
                                    monitor, 1920, 1080, 48, 1080, 0, 2);

    // RIGHT = (48 + 0 + 1920 - 0 - 1920) * 2 = 96
    assert (struts[Struts.RIGHT] == 96);
    assert (struts[Struts.RIGHT_START] == 0);
    assert (struts[Struts.RIGHT_END] == 2159);
  }

  void struts_non_primary_monitor_bottom () {
    var struts = new ulong[Struts.N_VALUES];
    // Dock on non-primary monitor, scale=1
    // Monitor A (primary): 1920x1080 at (0,0)
    // Monitor B: 1920x1080 at (1920,0) — dock is here
    // GDK logical bounding box = (3840, 1080)
    Gdk.Rectangle monitor = { 1920, 0, 1920, 1080 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.BOTTOM,
                                    monitor, 3840, 1080, 1920, 48, 0, 1);

    // BOTTOM = (48 + 0 + 1080 - 0 - 1080) * 1 = 48
    assert (struts[Struts.BOTTOM] == 48);
    assert (struts[Struts.BOTTOM_START] == 1920);
    assert (struts[Struts.BOTTOM_END] == 3839);
  }

  void struts_non_primary_monitor_scaling_2x () {
    var struts = new ulong[Struts.N_VALUES];
    // Dock on non-primary monitor, scale=2
    // Monitor A (primary): 3840x2160 at (0,0), GDK {0, 0, 1920, 1080}
    // Monitor B: 3840x2160 at (3840,0), GDK {1920, 0, 1920, 1080} — dock is here
    // GDK logical bounding box = (3840, 1080)
    Gdk.Rectangle monitor = { 1920, 0, 1920, 1080 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.BOTTOM,
                                    monitor, 3840, 1080, 1920, 48, 0, 2);

    // BOTTOM = (48 + 0 + 1080 - 0 - 1080) * 2 = 96
    assert (struts[Struts.BOTTOM] == 96);
    assert (struts[Struts.BOTTOM_START] == 3840);
    assert (struts[Struts.BOTTOM_END] == 7679);
  }

  void struts_ewmh_xinerama_example () {
    var struts = new ulong[Struts.N_VALUES];
    // Exact example from EWMH spec section 5.10:
    // Two monitors: 1280x1024 (left) + 1024x768 (right), top-aligned
    // GDK logical (scale=1): left={0,0,1280,1024}, right={1280,0,1024,768}
    // GDK logical bounding box = (2304, 1024)
    // Panel: 50px tall at bottom of right (shorter) monitor
    // Spec says: bottom strut = 306, bottom_start_x = 1280, bottom_end_x = 2303
    Gdk.Rectangle monitor = { 1280, 0, 1024, 768 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.BOTTOM,
                                    monitor, 2304, 1024, 1024, 50, 0, 1);

    // BOTTOM = (50 + 0 + 1024 - 0 - 768) * 1 = 306
    assert (struts[Struts.BOTTOM] == 306);
    assert (struts[Struts.BOTTOM_START] == 1280);
    assert (struts[Struts.BOTTOM_END] == 2303);
  }

  void struts_different_height_monitors_scaling_2x () {
    var struts = new ulong[Struts.N_VALUES];
    // 4K (left) + 1440p (right) side by side, top-aligned, scale=2
    // Left: 3840x2160, GDK {0, 0, 1920, 1080}
    // Right: 2560x1440, GDK {1920, 0, 1280, 720}
    // GDK logical bounding box = (3200, 1080)
    // Dock on right (shorter) monitor, BOTTOM
    Gdk.Rectangle monitor = { 1920, 0, 1280, 720 };
    PositionManager.compute_struts (ref struts, Gtk.PositionType.BOTTOM,
                                    monitor, 3200, 1080, 1280, 48, 0, 2);

    // BOTTOM = (48 + 0 + 1080 - 0 - 720) * 2 = 408 * 2 = 816
    // = dock(96) + offset from monitor bottom to screen bottom (720 logical = 360 X11 pixels)
    assert (struts[Struts.BOTTOM] == 816);
    assert (struts[Struts.BOTTOM_START] == 3840);
    assert (struts[Struts.BOTTOM_END] == 6399);
  }

  //
  // Dock edge tests
  //

  void dock_edge_monitor_mode_edges () {
    // In monitor mode the dock's area is the whole monitor, so only the
    // monitor's edge row or column counts
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };

    Gdk.Rectangle bottom = { 760, 1032, 400, 48 };
    assert (point_at_dock_edge (Gtk.PositionType.BOTTOM, 960, 1079, monitor, monitor, bottom));
    assert (!point_at_dock_edge (Gtk.PositionType.BOTTOM, 960, 1078, monitor, monitor, bottom));

    Gdk.Rectangle top = { 760, 0, 400, 48 };
    assert (point_at_dock_edge (Gtk.PositionType.TOP, 960, 0, monitor, monitor, top));
    assert (!point_at_dock_edge (Gtk.PositionType.TOP, 960, 1, monitor, monitor, top));

    Gdk.Rectangle left = { 0, 340, 48, 400 };
    assert (point_at_dock_edge (Gtk.PositionType.LEFT, 0, 540, monitor, monitor, left));
    assert (!point_at_dock_edge (Gtk.PositionType.LEFT, 1, 540, monitor, monitor, left));

    Gdk.Rectangle right = { 1872, 340, 48, 400 };
    assert (point_at_dock_edge (Gtk.PositionType.RIGHT, 1919, 540, monitor, monitor, right));
    assert (!point_at_dock_edge (Gtk.PositionType.RIGHT, 1918, 540, monitor, monitor, right));
  }

  void dock_edge_outside_span () {
    // On the edge but beside the dock does not count, and the span is
    // half-open like the rectangle it comes from
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };

    Gdk.Rectangle bottom = { 760, 1032, 400, 48 };
    assert (point_at_dock_edge (Gtk.PositionType.BOTTOM, 760, 1079, monitor, monitor, bottom));
    assert (point_at_dock_edge (Gtk.PositionType.BOTTOM, 1159, 1079, monitor, monitor, bottom));
    assert (!point_at_dock_edge (Gtk.PositionType.BOTTOM, 759, 1079, monitor, monitor, bottom));
    assert (!point_at_dock_edge (Gtk.PositionType.BOTTOM, 1160, 1079, monitor, monitor, bottom));

    Gdk.Rectangle top = { 760, 0, 400, 48 };
    assert (point_at_dock_edge (Gtk.PositionType.TOP, 760, 0, monitor, monitor, top));
    assert (point_at_dock_edge (Gtk.PositionType.TOP, 1159, 0, monitor, monitor, top));
    assert (!point_at_dock_edge (Gtk.PositionType.TOP, 759, 0, monitor, monitor, top));
    assert (!point_at_dock_edge (Gtk.PositionType.TOP, 1160, 0, monitor, monitor, top));

    Gdk.Rectangle left = { 0, 340, 48, 400 };
    assert (point_at_dock_edge (Gtk.PositionType.LEFT, 0, 340, monitor, monitor, left));
    assert (point_at_dock_edge (Gtk.PositionType.LEFT, 0, 739, monitor, monitor, left));
    assert (!point_at_dock_edge (Gtk.PositionType.LEFT, 0, 339, monitor, monitor, left));
    assert (!point_at_dock_edge (Gtk.PositionType.LEFT, 0, 740, monitor, monitor, left));

    Gdk.Rectangle right = { 1872, 340, 48, 400 };
    assert (point_at_dock_edge (Gtk.PositionType.RIGHT, 1919, 340, monitor, monitor, right));
    assert (point_at_dock_edge (Gtk.PositionType.RIGHT, 1919, 739, monitor, monitor, right));
    assert (!point_at_dock_edge (Gtk.PositionType.RIGHT, 1919, 339, monitor, monitor, right));
    assert (!point_at_dock_edge (Gtk.PositionType.RIGHT, 1919, 740, monitor, monitor, right));
  }

  void dock_edge_work_area_band () {
    // In work area mode a 40px panel sits between the dock's area and the
    // monitor's edge, and anywhere from the area's edge to the monitor's
    // edge counts
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };

    Gdk.Rectangle bottom_area = { 0, 0, 1920, 1040 };
    Gdk.Rectangle bottom = { 760, 992, 400, 48 };
    assert (point_at_dock_edge (Gtk.PositionType.BOTTOM, 960, 1039, bottom_area, monitor, bottom));
    assert (point_at_dock_edge (Gtk.PositionType.BOTTOM, 960, 1060, bottom_area, monitor, bottom));
    assert (point_at_dock_edge (Gtk.PositionType.BOTTOM, 960, 1079, bottom_area, monitor, bottom));
    assert (!point_at_dock_edge (Gtk.PositionType.BOTTOM, 960, 1038, bottom_area, monitor, bottom));

    Gdk.Rectangle top_area = { 0, 40, 1920, 1040 };
    Gdk.Rectangle top = { 760, 40, 400, 48 };
    assert (point_at_dock_edge (Gtk.PositionType.TOP, 960, 40, top_area, monitor, top));
    assert (point_at_dock_edge (Gtk.PositionType.TOP, 960, 20, top_area, monitor, top));
    assert (point_at_dock_edge (Gtk.PositionType.TOP, 960, 0, top_area, monitor, top));
    assert (!point_at_dock_edge (Gtk.PositionType.TOP, 960, 41, top_area, monitor, top));

    Gdk.Rectangle left_area = { 40, 0, 1880, 1080 };
    Gdk.Rectangle left = { 40, 340, 48, 400 };
    assert (point_at_dock_edge (Gtk.PositionType.LEFT, 40, 540, left_area, monitor, left));
    assert (point_at_dock_edge (Gtk.PositionType.LEFT, 20, 540, left_area, monitor, left));
    assert (point_at_dock_edge (Gtk.PositionType.LEFT, 0, 540, left_area, monitor, left));
    assert (!point_at_dock_edge (Gtk.PositionType.LEFT, 41, 540, left_area, monitor, left));

    Gdk.Rectangle right_area = { 0, 0, 1880, 1080 };
    Gdk.Rectangle right = { 1832, 340, 48, 400 };
    assert (point_at_dock_edge (Gtk.PositionType.RIGHT, 1879, 540, right_area, monitor, right));
    assert (point_at_dock_edge (Gtk.PositionType.RIGHT, 1900, 540, right_area, monitor, right));
    assert (point_at_dock_edge (Gtk.PositionType.RIGHT, 1919, 540, right_area, monitor, right));
    assert (!point_at_dock_edge (Gtk.PositionType.RIGHT, 1878, 540, right_area, monitor, right));
  }

  void dock_edge_neighbouring_monitor () {
    // A monitor across the dock's edge is not past the edge: the dock
    // monitor's own edge counts, the neighbour does not

    // A bottom dock on the upper of two stacked monitors
    Gdk.Rectangle upper_monitor = { 0, 0, 1920, 1080 };
    Gdk.Rectangle bottom = { 760, 1032, 400, 48 };
    assert (point_at_dock_edge (Gtk.PositionType.BOTTOM, 960, 1079, upper_monitor, upper_monitor, bottom));
    assert (!point_at_dock_edge (Gtk.PositionType.BOTTOM, 960, 1080, upper_monitor, upper_monitor, bottom));
    assert (!point_at_dock_edge (Gtk.PositionType.BOTTOM, 960, 1500, upper_monitor, upper_monitor, bottom));

    // A top dock on the lower of two stacked monitors
    Gdk.Rectangle lower_monitor = { 0, 1080, 1920, 1080 };
    Gdk.Rectangle top = { 760, 1080, 400, 48 };
    assert (point_at_dock_edge (Gtk.PositionType.TOP, 960, 1080, lower_monitor, lower_monitor, top));
    assert (!point_at_dock_edge (Gtk.PositionType.TOP, 960, 1079, lower_monitor, lower_monitor, top));
    assert (!point_at_dock_edge (Gtk.PositionType.TOP, 960, 500, lower_monitor, lower_monitor, top));

    // A left dock on the right of two side-by-side monitors
    Gdk.Rectangle right_monitor = { 1920, 0, 1920, 1080 };
    Gdk.Rectangle left = { 1920, 340, 48, 400 };
    assert (point_at_dock_edge (Gtk.PositionType.LEFT, 1920, 540, right_monitor, right_monitor, left));
    assert (!point_at_dock_edge (Gtk.PositionType.LEFT, 1919, 540, right_monitor, right_monitor, left));
    assert (!point_at_dock_edge (Gtk.PositionType.LEFT, 500, 540, right_monitor, right_monitor, left));

    // A right dock on the left of two side-by-side monitors
    Gdk.Rectangle left_monitor = { 0, 0, 1920, 1080 };
    Gdk.Rectangle right = { 1872, 340, 48, 400 };
    assert (point_at_dock_edge (Gtk.PositionType.RIGHT, 1919, 540, left_monitor, left_monitor, right));
    assert (!point_at_dock_edge (Gtk.PositionType.RIGHT, 1920, 540, left_monitor, left_monitor, right));
    assert (!point_at_dock_edge (Gtk.PositionType.RIGHT, 2500, 540, left_monitor, left_monitor, right));
  }

  void dock_edge_offset_monitor () {
    // On a monitor away from the origin, the lower right of a 2x2 grid,
    // each edge sits at the monitor's offset
    Gdk.Rectangle monitor = { 1920, 1080, 1920, 1080 };

    Gdk.Rectangle bottom = { 2680, 2112, 400, 48 };
    assert (point_at_dock_edge (Gtk.PositionType.BOTTOM, 2880, 2159, monitor, monitor, bottom));
    assert (!point_at_dock_edge (Gtk.PositionType.BOTTOM, 2880, 2158, monitor, monitor, bottom));

    Gdk.Rectangle top = { 2680, 1080, 400, 48 };
    assert (point_at_dock_edge (Gtk.PositionType.TOP, 2880, 1080, monitor, monitor, top));
    assert (!point_at_dock_edge (Gtk.PositionType.TOP, 2880, 1081, monitor, monitor, top));

    Gdk.Rectangle left = { 1920, 1420, 48, 400 };
    assert (point_at_dock_edge (Gtk.PositionType.LEFT, 1920, 1620, monitor, monitor, left));
    assert (!point_at_dock_edge (Gtk.PositionType.LEFT, 1921, 1620, monitor, monitor, left));

    Gdk.Rectangle right = { 3792, 1420, 48, 400 };
    assert (point_at_dock_edge (Gtk.PositionType.RIGHT, 3839, 1620, monitor, monitor, right));
    assert (!point_at_dock_edge (Gtk.PositionType.RIGHT, 3838, 1620, monitor, monitor, right));
  }

  void dock_edge_empty_monitor () {
    // Before the first valid measurement the area and monitor are both
    // empty. An empty area alone would put the bottom and right edges
    // everywhere, so each point below would count without the monitor check
    Gdk.Rectangle empty = { 0, 0, 0, 0 };
    Gdk.Rectangle dock = { 0, 0, 400, 400 };
    assert (!point_at_dock_edge (Gtk.PositionType.BOTTOM, 10, 10, empty, empty, dock));
    assert (!point_at_dock_edge (Gtk.PositionType.TOP, 10, 0, empty, empty, dock));
    assert (!point_at_dock_edge (Gtk.PositionType.LEFT, 0, 10, empty, empty, dock));
    assert (!point_at_dock_edge (Gtk.PositionType.RIGHT, 10, 10, empty, empty, dock));
  }

  //
  // Window preview geometry tests
  //

  void preview_thumbnail_shape () {
    // Thumbnails take the monitor's shape, rounding down
    Gdk.Rectangle sixteen_nine = { 0, 0, 1920, 1080 };
    assert (preview_thumbnail_height (240, sixteen_nine) == 135);
    assert (preview_thumbnail_height (64, sixteen_nine) == 36);
    assert (preview_thumbnail_height (65, sixteen_nine) == 36);

    Gdk.Rectangle sixteen_ten = { 0, 0, 1920, 1200 };
    assert (preview_thumbnail_height (240, sixteen_ten) == 150);

    Gdk.Rectangle ultrawide = { 1920, 0, 3440, 1440 };
    assert (preview_thumbnail_height (240, ultrawide) == 100);

    Gdk.Rectangle portrait = { 0, 0, 1080, 1920 };
    assert (preview_thumbnail_height (240, portrait) == 426);

    // Until the monitor is fully known they are square, rather than
    // dividing by zero
    Gdk.Rectangle empty = { 0, 0, 0, 0 };
    assert (preview_thumbnail_height (240, empty) == 240);

    Gdk.Rectangle no_width = { 0, 0, 0, 1080 };
    assert (preview_thumbnail_height (240, no_width) == 240);

    Gdk.Rectangle no_height = { 0, 0, 1920, 0 };
    assert (preview_thumbnail_height (240, no_height) == 240);

    // Sizes whose product passes int's range still come out exact
    Gdk.Rectangle huge = { 0, 0, 50000, 50000 };
    assert (preview_thumbnail_height (50000, huge) == 50000);
  }

  void preview_thumbnail_inverse () {
    // For every height and monitor shape, the width found is the widest
    // whose thumbnail fits: its own fits and one pixel more would not
    Gdk.Rectangle sixteen_nine = { 0, 0, 1920, 1080 };
    Gdk.Rectangle sixteen_ten = { 0, 0, 1920, 1200 };
    Gdk.Rectangle ultrawide = { 1920, 0, 3440, 1440 };
    Gdk.Rectangle portrait = { 0, 0, 1080, 1920 };
    Gdk.Rectangle no_width = { 0, 0, 0, 1080 };
    Gdk.Rectangle no_height = { 0, 0, 1920, 0 };
    Gdk.Rectangle empty = { 0, 0, 0, 0 };
    Gdk.Rectangle[] monitors = { sixteen_nine, sixteen_ten, ultrawide, portrait, no_width, no_height, empty };

    foreach (var monitor in monitors) {
      for (var height = 0; height <= 500; height++) {
        var width = preview_width_for_thumbnail_height (height, monitor);
        assert (preview_thumbnail_height (width, monitor) <= height);
        assert (preview_thumbnail_height (width + 1, monitor) > height);
      }

      // Below zero nothing fits
      assert (preview_width_for_thumbnail_height (-1, monitor) == 0);
      assert (preview_width_for_thumbnail_height (-5, monitor) == 0);
    }

    // Sizes whose product passes int's range still come out exact
    Gdk.Rectangle huge = { 0, 0, 50000, 50000 };
    assert (preview_width_for_thumbnail_height (50000, huge) == 50000);
  }

  void preview_space_edges () {
    // Along the dock's edge the popup may use the whole area, and across it
    // the room from the anchor, past a 10px gap, to the area's far edge
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    int width, height;

    compute_preview_space (out width, out height, Gtk.PositionType.BOTTOM, 960, 1000, 10, monitor);
    assert (width == 1920);
    assert (height == 990);

    compute_preview_space (out width, out height, Gtk.PositionType.TOP, 960, 80, 10, monitor);
    assert (width == 1920);
    assert (height == 990);

    compute_preview_space (out width, out height, Gtk.PositionType.LEFT, 80, 540, 10, monitor);
    assert (width == 1830);
    assert (height == 1080);

    compute_preview_space (out width, out height, Gtk.PositionType.RIGHT, 1840, 540, 10, monitor);
    assert (width == 1830);
    assert (height == 1080);

    // An anchor closer to the area's edge than the gap leaves no room
    compute_preview_space (out width, out height, Gtk.PositionType.BOTTOM, 960, 5, 10, monitor);
    assert (height == 0);

    compute_preview_space (out width, out height, Gtk.PositionType.RIGHT, 5, 540, 10, monitor);
    assert (width == 0);
  }

  void preview_space_offset_monitor () {
    // On the lower right monitor of a 2x2 grid the room is measured from
    // that monitor's own edges
    Gdk.Rectangle monitor = { 1920, 1080, 1920, 1080 };
    int width, height;

    compute_preview_space (out width, out height, Gtk.PositionType.BOTTOM, 2880, 2080, 10, monitor);
    assert (width == 1920);
    assert (height == 990);

    compute_preview_space (out width, out height, Gtk.PositionType.TOP, 2880, 1160, 10, monitor);
    assert (width == 1920);
    assert (height == 990);

    compute_preview_space (out width, out height, Gtk.PositionType.LEFT, 2000, 1620, 10, monitor);
    assert (width == 1830);
    assert (height == 1080);

    compute_preview_space (out width, out height, Gtk.PositionType.RIGHT, 3760, 1620, 10, monitor);
    assert (width == 1830);
    assert (height == 1080);
  }

  // The layout tests use tiles that add 8px of margins to a thumbnail's
  // width and 32px of margins and title to its height, with 6px between
  // tiles and a 64px minimum, on a 1920x1080 monitor unless noted

  void preview_layout_all_fit () {
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    int size, shown;

    // Three windows easily fit a 1896px row at the preferred 240px
    compute_preview_layout (out size, out shown, Gtk.PositionType.BOTTOM, monitor, 3, 240, 64, 1896, 900, 8, 32, 6);
    assert (size == 240);
    assert (shown == 3);

    // Five fit a 1056px column, each tile a 135px tall thumbnail plus 32px
    compute_preview_layout (out size, out shown, Gtk.PositionType.LEFT, monitor, 5, 240, 64, 1800, 1056, 8, 32, 6);
    assert (size == 240);
    assert (shown == 5);
  }

  void preview_layout_shrink () {
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    int size, shown;

    // Ten 240px tiles would need 2534px, so all ten shrink to 176px, the
    // largest that fits: 10 * (176 + 8) + 9 * 6 = 1894
    compute_preview_layout (out size, out shown, Gtk.PositionType.BOTTOM, monitor, 10, 240, 64, 1896, 900, 8, 32, 6);
    assert (size == 176);
    assert (shown == 10);

    // In a column the thumbnails' height decides: 168px wide is 94px tall
    // and 8 * (94 + 32) + 7 * 6 = 1050 fits, where 169px (95px tall) would not
    compute_preview_layout (out size, out shown, Gtk.PositionType.LEFT, monitor, 8, 240, 64, 1800, 1056, 8, 32, 6);
    assert (size == 168);
    assert (shown == 8);

    // A top dock lays out like a bottom one, and a right dock like a left one
    compute_preview_layout (out size, out shown, Gtk.PositionType.TOP, monitor, 10, 240, 64, 1896, 900, 8, 32, 6);
    assert (size == 176);
    assert (shown == 10);

    compute_preview_layout (out size, out shown, Gtk.PositionType.RIGHT, monitor, 8, 240, 64, 1800, 1056, 8, 32, 6);
    assert (size == 168);
    assert (shown == 8);

    // A 16:10 monitor makes thumbnails taller, so the same column shrinks
    // them further, to 151px wide for the same 94px
    Gdk.Rectangle sixteen_ten = { 0, 0, 1920, 1200 };
    compute_preview_layout (out size, out shown, Gtk.PositionType.LEFT, sixteen_ten, 8, 240, 64, 1800, 1056, 8, 32, 6);
    assert (size == 151);
    assert (shown == 8);
  }

  void preview_layout_overflow () {
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    int size, shown;

    // 40 windows don't fit even at 64px, but 24 slots of 72px do,
    // 24 * 72 + 23 * 6 = 1866, so 23 windows show and the last slot holds
    // the count of the other 17
    compute_preview_layout (out size, out shown, Gtk.PositionType.BOTTOM, monitor, 40, 240, 64, 1896, 900, 8, 32, 6);
    assert (size == 64);
    assert (shown == 23);

    // 25 windows exactly fill a 1944px row at the minimum, so all show
    compute_preview_layout (out size, out shown, Gtk.PositionType.BOTTOM, monitor, 25, 240, 64, 1944, 900, 8, 32, 6);
    assert (size == 64);
    assert (shown == 25);

    // A pixel less and only 24 slots fit, so 23 windows show
    compute_preview_layout (out size, out shown, Gtk.PositionType.BOTTOM, monitor, 25, 240, 64, 1943, 900, 8, 32, 6);
    assert (size == 64);
    assert (shown == 23);

    // One more, and the last slot goes to the count
    compute_preview_layout (out size, out shown, Gtk.PositionType.BOTTOM, monitor, 26, 240, 64, 1944, 900, 8, 32, 6);
    assert (size == 64);
    assert (shown == 24);

    // A 1056px column holds 14 slots of 36 + 32 = 68px, so 13 of 20 show
    compute_preview_layout (out size, out shown, Gtk.PositionType.LEFT, monitor, 20, 240, 64, 1800, 1056, 8, 32, 6);
    assert (size == 64);
    assert (shown == 13);

    // 14 windows exactly fill a 1030px column at 65px, whose thumbnail is
    // 36px tall like 64px's, and a pixel less leaves 13 slots, so 12 show
    compute_preview_layout (out size, out shown, Gtk.PositionType.LEFT, monitor, 14, 240, 64, 1800, 1030, 8, 32, 6);
    assert (size == 65);
    assert (shown == 14);

    compute_preview_layout (out size, out shown, Gtk.PositionType.LEFT, monitor, 14, 240, 64, 1800, 1029, 8, 32, 6);
    assert (size == 64);
    assert (shown == 12);
  }

  void preview_layout_across_limit () {
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    int size, shown;

    // Above a bottom dock with 300px of room, a 478px thumbnail (268px
    // tall) plus 32px is the most that fits, so 640px is capped there
    compute_preview_layout (out size, out shown, Gtk.PositionType.BOTTOM, monitor, 1, 640, 64, 1896, 300, 8, 32, 6);
    assert (size == 478);
    assert (shown == 1);

    // Beside a side dock with 500px of room, 492px plus 8px fits
    compute_preview_layout (out size, out shown, Gtk.PositionType.LEFT, monitor, 1, 640, 64, 500, 1056, 8, 32, 6);
    assert (size == 492);
    assert (shown == 1);

    // Windows that all fit along the line are each still limited by the
    // room across it: beside a side dock with 200px of room, five fit at
    // 192px plus 8px
    compute_preview_layout (out size, out shown, Gtk.PositionType.LEFT, monitor, 5, 240, 64, 200, 1056, 8, 32, 6);
    assert (size == 192);
    assert (shown == 5);

    // Above a bottom dock with 150px of room, five fit at 211px, whose
    // thumbnail is 118px tall, plus 32px
    compute_preview_layout (out size, out shown, Gtk.PositionType.BOTTOM, monitor, 5, 240, 64, 1896, 150, 8, 32, 6);
    assert (size == 211);
    assert (shown == 5);

    // With less room than the minimum needs, the minimum still holds
    compute_preview_layout (out size, out shown, Gtk.PositionType.BOTTOM, monitor, 1, 240, 64, 1896, 50, 8, 32, 6);
    assert (size == 64);
    assert (shown == 1);
  }

  void preview_layout_tight_space () {
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    int size, shown;

    // A line too short for even one tile still shows one window, with the
    // count of the others
    compute_preview_layout (out size, out shown, Gtk.PositionType.BOTTOM, monitor, 3, 240, 64, 50, 900, 8, 32, 6);
    assert (size == 64);
    assert (shown == 1);

    // A lone window shows with no count
    compute_preview_layout (out size, out shown, Gtk.PositionType.BOTTOM, monitor, 1, 240, 64, 50, 900, 8, 32, 6);
    assert (size == 64);
    assert (shown == 1);

    // No windows, nothing to show
    compute_preview_layout (out size, out shown, Gtk.PositionType.BOTTOM, monitor, 0, 240, 64, 1896, 900, 8, 32, 6);
    assert (shown == 0);

    // With no room along the line, or less than none, one window still shows
    compute_preview_layout (out size, out shown, Gtk.PositionType.BOTTOM, monitor, 3, 240, 64, 0, 900, 8, 32, 6);
    assert (size == 64);
    assert (shown == 1);

    compute_preview_layout (out size, out shown, Gtk.PositionType.BOTTOM, monitor, 3, 240, 64, -10, 900, 8, 32, 6);
    assert (size == 64);
    assert (shown == 1);

    compute_preview_layout (out size, out shown, Gtk.PositionType.LEFT, monitor, 3, 240, 64, 1800, 0, 8, 32, 6);
    assert (size == 64);
    assert (shown == 1);

    compute_preview_layout (out size, out shown, Gtk.PositionType.LEFT, monitor, 3, 240, 64, 1800, -10, 8, 32, 6);
    assert (size == 64);
    assert (shown == 1);

    // Even slots that take no space don't divide by zero: on a 128x1
    // monitor a 64px thumbnail is 0px tall, here with no margins, title or
    // spacing either
    Gdk.Rectangle sliver = { 0, 0, 128, 1 };
    compute_preview_layout (out size, out shown, Gtk.PositionType.LEFT, sliver, 1, 240, 64, 1000, -1, 0, 0, 0);
    assert (size == 64);
    assert (shown == 1);
  }

  void preview_position_edges () {
    // Past a 10px gap from the anchor, centered on it along the dock's edge
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    int x, y;

    compute_preview_position (out x, out y, Gtk.PositionType.BOTTOM, 960, 1000, 400, 200, 10, monitor);
    assert (x == 760);
    assert (y == 790);

    compute_preview_position (out x, out y, Gtk.PositionType.TOP, 960, 80, 400, 200, 10, monitor);
    assert (x == 760);
    assert (y == 90);

    compute_preview_position (out x, out y, Gtk.PositionType.LEFT, 80, 540, 300, 600, 10, monitor);
    assert (x == 90);
    assert (y == 240);

    compute_preview_position (out x, out y, Gtk.PositionType.RIGHT, 1840, 540, 300, 600, 10, monitor);
    assert (x == 1530);
    assert (y == 240);
  }

  void preview_position_clamped () {
    // Near the area's ends the popup slides back inside
    Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
    int x, y;

    compute_preview_position (out x, out y, Gtk.PositionType.BOTTOM, 50, 1000, 400, 200, 10, monitor);
    assert (x == 0);
    assert (y == 790);

    compute_preview_position (out x, out y, Gtk.PositionType.BOTTOM, 1900, 1000, 400, 200, 10, monitor);
    assert (x == 1520);

    compute_preview_position (out x, out y, Gtk.PositionType.LEFT, 80, 100, 300, 600, 10, monitor);
    assert (y == 0);

    compute_preview_position (out x, out y, Gtk.PositionType.RIGHT, 1840, 1000, 300, 600, 10, monitor);
    assert (y == 480);

    // On a monitor away from the origin it stays on that monitor
    Gdk.Rectangle offset_monitor = { 1920, 0, 1920, 1080 };
    compute_preview_position (out x, out y, Gtk.PositionType.BOTTOM, 1950, 1000, 400, 200, 10, offset_monitor);
    assert (x == 1920);

    // A popup wider than the area is pinned to the area's start, and one
    // taller than it to the area's top
    compute_preview_position (out x, out y, Gtk.PositionType.BOTTOM, 960, 1000, 2000, 200, 10, monitor);
    assert (x == 0);

    compute_preview_position (out x, out y, Gtk.PositionType.LEFT, 80, 540, 300, 1200, 10, monitor);
    assert (y == 0);

    // On a monitor above the primary one, with a negative origin, it is
    // placed and kept within that monitor all the same
    Gdk.Rectangle upper_monitor = { 0, -1080, 1920, 1080 };
    compute_preview_position (out x, out y, Gtk.PositionType.BOTTOM, 960, -80, 400, 200, 10, upper_monitor);
    assert (y == -290);

    compute_preview_position (out x, out y, Gtk.PositionType.LEFT, 80, -1000, 300, 600, 10, upper_monitor);
    assert (y == -1080);
  }

  void preview_zone_bottom () {
    // A bottom dock and one of its items, with the item's popup 42px above it
    Gdk.Rectangle dock = { 500, 1032, 900, 48 };
    Gdk.Rectangle item = { 936, 1032, 48, 48 };
    Gdk.Rectangle popup = { 760, 790, 400, 200 };

    // On the popup, and in the gap straight up or toward the popup's ends
    assert (point_in_preview_zone (960, 800, popup, item, dock));
    assert (point_in_preview_zone (960, 1010, popup, item, dock));
    assert (point_in_preview_zone (780, 1000, popup, item, dock));
    assert (point_in_preview_zone (1150, 1000, popup, item, dock));

    // Anywhere on the dock, even beyond the popup's ends
    assert (point_in_preview_zone (520, 1050, popup, item, dock));

    // Beside the gap, above the popup, and past the dock's end
    assert (!point_in_preview_zone (700, 1000, popup, item, dock));
    assert (!point_in_preview_zone (960, 780, popup, item, dock));
    assert (!point_in_preview_zone (480, 1050, popup, item, dock));

    // The span is half-open like the rectangles it comes from
    assert (point_in_preview_zone (760, 900, popup, item, dock));
    assert (!point_in_preview_zone (759, 900, popup, item, dock));
    assert (!point_in_preview_zone (1160, 900, popup, item, dock));
    assert (point_in_preview_zone (960, 790, popup, item, dock));
    assert (!point_in_preview_zone (960, 789, popup, item, dock));

    // So is the dock, beyond the span's ends
    assert (point_in_preview_zone (500, 1050, popup, item, dock));
    assert (!point_in_preview_zone (499, 1050, popup, item, dock));
    assert (point_in_preview_zone (1399, 1050, popup, item, dock));
    assert (!point_in_preview_zone (1400, 1050, popup, item, dock));
    assert (point_in_preview_zone (520, 1079, popup, item, dock));
    assert (!point_in_preview_zone (520, 1080, popup, item, dock));
  }

  void preview_zone_side () {
    // A left dock and one of its items, with the item's popup 42px to the right
    Gdk.Rectangle dock = { 0, 340, 48, 400 };
    Gdk.Rectangle item = { 0, 516, 48, 48 };
    Gdk.Rectangle popup = { 90, 400, 300, 280 };

    // On the popup, and in the gap straight across or toward the popup's ends
    assert (point_in_preview_zone (200, 540, popup, item, dock));
    assert (point_in_preview_zone (70, 540, popup, item, dock));
    assert (point_in_preview_zone (70, 410, popup, item, dock));

    // Past the popup, and beside the gap beyond the popup's ends
    assert (!point_in_preview_zone (400, 540, popup, item, dock));
    assert (!point_in_preview_zone (70, 380, popup, item, dock));
    assert (!point_in_preview_zone (70, 700, popup, item, dock));

    // The span's bottom edge is excluded, as in the rectangles it comes from
    assert (point_in_preview_zone (70, 679, popup, item, dock));
    assert (!point_in_preview_zone (70, 680, popup, item, dock));
  }
}
