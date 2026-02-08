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
}