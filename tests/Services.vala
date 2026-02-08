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

namespace PlankTests
{
	public static void register_services_tests ()
	{
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
	}

	//
	// Environment detection tests
	//

	void environment_desktop_from_string ()
	{
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

	void environment_desktop_from_string_unknown ()
	{
		// Unknown strings should return UNKNOWN
		assert (XdgSessionDesktop.from_string ("lightdm-xsession") == XdgSessionDesktop.UNKNOWN);
		assert (XdgSessionDesktop.from_string ("something-random") == XdgSessionDesktop.UNKNOWN);
		assert (XdgSessionDesktop.from_string ("") == XdgSessionDesktop.UNKNOWN);
	}

	void environment_desktop_from_string_case ()
	{
		// Detection should be case-insensitive
		assert (XdgSessionDesktop.from_string ("XFCE") == XdgSessionDesktop.XFCE);
		assert (XdgSessionDesktop.from_string ("Xfce") == XdgSessionDesktop.XFCE);
		assert (XdgSessionDesktop.from_string ("CINNAMON") == XdgSessionDesktop.CINNAMON);
		assert (XdgSessionDesktop.from_string ("KDE") == XdgSessionDesktop.KDE);
		assert (XdgSessionDesktop.from_string ("GNOME") == XdgSessionDesktop.GNOME);
		assert (XdgSessionDesktop.from_string ("MATE") == XdgSessionDesktop.MATE);
		assert (XdgSessionDesktop.from_string ("Xubuntu") == XdgSessionDesktop.XFCE);
	}

	void environment_desktop_from_string_multi ()
	{
		// Semicolon-separated values should OR together
		var result = XdgSessionDesktop.from_string ("ubuntu;xfce");
		assert ((result & XdgSessionDesktop.UBUNTU) != 0);
		assert ((result & XdgSessionDesktop.XFCE) != 0);
		assert ((result & XdgSessionDesktop.KDE) == 0);

		// Single unknown in a list shouldn't break the known ones
		var result2 = XdgSessionDesktop.from_string ("lightdm-xsession;XFCE");
		assert ((result2 & XdgSessionDesktop.XFCE) != 0);
	}

	void environment_desktop_bitmask ()
	{
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

	void helpers_truncate_middle_short ()
	{
		// String shorter than limit should be returned as-is
		var result = Helpers.truncate_middle ("hello", 10);
		assert (result == "hello");
	}

	void helpers_truncate_middle_exact ()
	{
		// String exactly at limit should be returned as-is
		var result = Helpers.truncate_middle ("hello", 5);
		assert (result == "hello");
	}

	void helpers_truncate_middle_long ()
	{
		// String longer than limit should be truncated with ellipsis in middle
		var result = Helpers.truncate_middle ("hello world test", 11);
		assert (result.char_count () == 11);
		assert (result.contains ("…"));
		// Should start with beginning of original
		assert (result.has_prefix ("hello"));
		// Should end with end of original
		assert (result.has_suffix ("test"));
	}

	void helpers_truncate_middle_very_short_limit ()
	{
		// Very short limit (< 5) should just truncate from start
		var result = Helpers.truncate_middle ("hello world", 3);
		assert (result.char_count () == 3);
		assert (result == "hel");
	}

	void helpers_truncate_middle_utf8 ()
	{
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

	void helpers_truncate_middle_cjk ()
	{
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

	//
	// Session type detection tests
	//

	void session_type_known ()
	{
		assert (XdgSessionType.from_string ("x11") == XdgSessionType.X11);
		assert (XdgSessionType.from_string ("wayland") == XdgSessionType.WAYLAND);
		assert (XdgSessionType.from_string ("tty") == XdgSessionType.TTY);
		assert (XdgSessionType.from_string ("mir") == XdgSessionType.MIR);
		assert (XdgSessionType.from_string ("unspecified") == XdgSessionType.UNSPECIFIED);
	}

	void session_type_case ()
	{
		assert (XdgSessionType.from_string ("X11") == XdgSessionType.X11);
		assert (XdgSessionType.from_string ("Wayland") == XdgSessionType.WAYLAND);
		assert (XdgSessionType.from_string ("WAYLAND") == XdgSessionType.WAYLAND);
	}

	void session_type_unknown ()
	{
		// Unknown strings should default to UNSPECIFIED
		assert (XdgSessionType.from_string ("something") == XdgSessionType.UNSPECIFIED);
		assert (XdgSessionType.from_string ("") == XdgSessionType.UNSPECIFIED);
	}

	//
	// Color prefs round-trip tests
	//

	void color_prefs_round_trip ()
	{
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

	void color_prefs_clamping ()
	{
		// Values outside 0-255 should be clamped
		var color = Color.from_prefs_string ("300;;-10;;128;;255");
		assert (color.red == 1.0);   // 300 clamped to 255 → 1.0
		assert (color.green == 0.0); // -10 clamped to 0 → 0.0
		assert (color.blue > 0.49 && color.blue < 0.51); // 128/255 ≈ 0.502
		assert (color.alpha == 1.0); // 255 → 1.0
	}

	void color_prefs_format ()
	{
		// Verify the string format uses ;; separators
		Color color = { 1.0, 0.0, 0.5, 1.0 };
		var str = color.to_prefs_string ();
		var parts = str.split (";;");
		assert (parts.length == 4);
		assert (int.parse (parts[0]) == 255);  // red
		assert (int.parse (parts[1]) == 0);    // green
		assert (int.parse (parts[3]) == 255);  // alpha
	}

	//
	// Dock window position tests
	//

	void dock_win_pos_bottom_composited ()
	{
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

	void dock_win_pos_top_composited ()
	{
		int x, y;
		Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
		PositionManager.compute_dock_window_position (out x, out y,
			Gtk.PositionType.TOP, Gtk.Align.CENTER,
			monitor, 1920, 48, 0, 0,
			true, true, 1920, 48, false);

		assert (x == 0);
		assert (y == 0);
	}

	void dock_win_pos_left_composited ()
	{
		int x, y;
		Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
		PositionManager.compute_dock_window_position (out x, out y,
			Gtk.PositionType.LEFT, Gtk.Align.CENTER,
			monitor, 48, 1080, 0, 0,
			true, false, 48, 1080, false);

		assert (x == 0);
		assert (y == 0);
	}

	void dock_win_pos_right_composited ()
	{
		int x, y;
		Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
		PositionManager.compute_dock_window_position (out x, out y,
			Gtk.PositionType.RIGHT, Gtk.Align.CENTER,
			monitor, 48, 1080, 0, 0,
			true, false, 48, 1080, false);

		assert (x == 1920 - 48);
		assert (y == 0);
	}

	void dock_win_pos_bottom_with_gap ()
	{
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

	void dock_win_pos_offset_monitor ()
	{
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

	void bg_padding_bottom ()
	{
		int x, y;
		// dock_height=48, bg_height=40, no hide offset
		// padding = 48 - 40 + 0 = 8
		PositionManager.compute_background_padding (out x, out y,
			Gtk.PositionType.BOTTOM, 200, 48, 200, 40, 0);

		assert (x == 0);
		assert (y == 8);
	}

	void bg_padding_top ()
	{
		int x, y;
		PositionManager.compute_background_padding (out x, out y,
			Gtk.PositionType.TOP, 200, 48, 200, 40, 0);

		assert (x == 0);
		assert (y == -8);
	}

	void bg_padding_left ()
	{
		int x, y;
		// dock_width=48, bg_width=40
		PositionManager.compute_background_padding (out x, out y,
			Gtk.PositionType.LEFT, 48, 200, 40, 200, 0);

		assert (x == -8);
		assert (y == 0);
	}

	void bg_padding_right ()
	{
		int x, y;
		PositionManager.compute_background_padding (out x, out y,
			Gtk.PositionType.RIGHT, 48, 200, 40, 200, 0);

		assert (x == 8);
		assert (y == 0);
	}

	void bg_padding_with_hide_offset ()
	{
		int x, y;
		// hide_offset adds to the padding
		PositionManager.compute_background_padding (out x, out y,
			Gtk.PositionType.BOTTOM, 200, 48, 200, 40, 5);

		assert (x == 0);
		assert (y == 13);  // 48 - 40 + 5
	}

	//
	// Easing bounce tests
	//

	void easing_bounce_start_zero ()
	{
		// Bounce should start at 0
		var val = DockRenderer.easing_bounce (0.0, 1000.0, 2.0);
		assert (val == 0.0);
	}

	void easing_bounce_end_zero ()
	{
		// Bounce should end at 0 (dampened to nothing)
		var val = DockRenderer.easing_bounce (1000.0, 1000.0, 2.0);
		assert (val == 0.0);
	}

	void easing_bounce_midpoint_positive ()
	{
		// Bounce should be positive at midpoint
		var val = DockRenderer.easing_bounce (250.0, 1000.0, 2.0);
		assert (val > 0.0);
	}

	void easing_bounce_always_non_negative ()
	{
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

	void draw_position_bottom_visible ()
	{
		int x, y;
		// Fully visible (progress = 0) — no offset
		PositionManager.compute_dock_draw_position (out x, out y,
			Gtk.PositionType.BOTTOM, 0.0, 200, 48, 0);
		assert (x == 0);
		assert (y == 0);
	}

	void draw_position_bottom_hidden ()
	{
		int x, y;
		// Fully hidden (progress = 1) — offset equals dock height
		PositionManager.compute_dock_draw_position (out x, out y,
			Gtk.PositionType.BOTTOM, 1.0, 200, 48, 0);
		assert (x == 0);
		assert (y == 48);
	}

	void draw_position_bottom_half ()
	{
		int x, y;
		// Half hidden
		PositionManager.compute_dock_draw_position (out x, out y,
			Gtk.PositionType.BOTTOM, 0.5, 200, 48, 0);
		assert (x == 0);
		assert (y == 24);
	}

	void draw_position_top_hidden ()
	{
		int x, y;
		// Top dock hides upward (negative y)
		PositionManager.compute_dock_draw_position (out x, out y,
			Gtk.PositionType.TOP, 1.0, 200, 48, 0);
		assert (x == 0);
		assert (y == -48);
	}

	void draw_position_left_hidden ()
	{
		int x, y;
		// Left dock hides leftward (negative x)
		PositionManager.compute_dock_draw_position (out x, out y,
			Gtk.PositionType.LEFT, 1.0, 48, 200, 0);
		assert (x == -48);
		assert (y == 0);
	}

	void draw_position_right_hidden ()
	{
		int x, y;
		// Right dock hides rightward (positive x)
		PositionManager.compute_dock_draw_position (out x, out y,
			Gtk.PositionType.RIGHT, 1.0, 48, 200, 0);
		assert (x == 48);
		assert (y == 0);
	}

	void draw_position_with_hide_offset ()
	{
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

	void easing_linear_bounds ()
	{
		// Linear easing: t=0 → 0, t=d → 1
		assert (easing_for_mode (AnimationMode.LINEAR, 0.0, 1000.0) == 0.0);
		assert (easing_for_mode (AnimationMode.LINEAR, 1000.0, 1000.0) == 1.0);
	}

	void easing_linear_midpoint ()
	{
		// Linear easing: midpoint should be exactly 0.5
		assert (easing_for_mode (AnimationMode.LINEAR, 500.0, 1000.0) == 0.5);
	}

	void easing_all_modes_bounds ()
	{
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

	void draw_value_move_in_bottom ()
	{
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

	void draw_value_move_in_top ()
	{
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

	void draw_value_move_right_bottom ()
	{
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

	void draw_value_move_right_left ()
	{
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

	void struts_single_monitor_bottom ()
	{
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

	void struts_single_monitor_top ()
	{
		var struts = new ulong[Struts.N_VALUES];
		Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
		PositionManager.compute_struts (ref struts, Gtk.PositionType.TOP,
		                                monitor, 1920, 1080, 1920, 48, 0, 1);

		assert (struts[Struts.TOP] == 48);
		assert (struts[Struts.TOP_START] == 0);
		assert (struts[Struts.TOP_END] == 1919);
		assert (struts[Struts.BOTTOM] == 0);
	}

	void struts_single_monitor_left ()
	{
		var struts = new ulong[Struts.N_VALUES];
		Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
		PositionManager.compute_struts (ref struts, Gtk.PositionType.LEFT,
		                                monitor, 1920, 1080, 48, 1080, 0, 1);

		assert (struts[Struts.LEFT] == 48);
		assert (struts[Struts.LEFT_START] == 0);
		assert (struts[Struts.LEFT_END] == 1079);
		assert (struts[Struts.RIGHT] == 0);
	}

	void struts_single_monitor_right ()
	{
		var struts = new ulong[Struts.N_VALUES];
		Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
		PositionManager.compute_struts (ref struts, Gtk.PositionType.RIGHT,
		                                monitor, 1920, 1080, 48, 1080, 0, 1);

		assert (struts[Struts.RIGHT] == 48);
		assert (struts[Struts.RIGHT_START] == 0);
		assert (struts[Struts.RIGHT_END] == 1079);
		assert (struts[Struts.LEFT] == 0);
	}

	void struts_multi_monitor_bottom ()
	{
		var struts = new ulong[Struts.N_VALUES];
		// Two 1920x1080 monitors side by side, dock on the right monitor
		// Full X screen is 3840x1080, right monitor at x=1920
		Gdk.Rectangle monitor = { 1920, 0, 1920, 1080 };
		PositionManager.compute_struts (ref struts, Gtk.PositionType.BOTTOM,
		                                monitor, 3840, 1080, 1920, 48, 0, 1);

		// BOTTOM strut = dock_height + screen_height - monitor_bottom
		// = 48 + 1080 - 0 - 1080 = 48
		assert (struts[Struts.BOTTOM] == 48);
		// Strut range should cover only the right monitor
		assert (struts[Struts.BOTTOM_START] == 1920);
		assert (struts[Struts.BOTTOM_END] == 3839);
	}

	void struts_scaling_2x ()
	{
		var struts = new ulong[Struts.N_VALUES];
		// Single monitor with 2x scaling
		Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
		PositionManager.compute_struts (ref struts, Gtk.PositionType.BOTTOM,
		                                monitor, 1920, 1080, 1920, 48, 0, 2);

		// All values should be doubled
		assert (struts[Struts.BOTTOM] == 96);
		assert (struts[Struts.BOTTOM_START] == 0);
		assert (struts[Struts.BOTTOM_END] == 3839);
	}

	void struts_with_gap ()
	{
		var struts = new ulong[Struts.N_VALUES];
		// Single monitor with 10px gap
		Gdk.Rectangle monitor = { 0, 0, 1920, 1080 };
		PositionManager.compute_struts (ref struts, Gtk.PositionType.BOTTOM,
		                                monitor, 1920, 1080, 1920, 48, 10, 1);

		// BOTTOM strut should include gap
		assert (struts[Struts.BOTTOM] == 58);
	}
}