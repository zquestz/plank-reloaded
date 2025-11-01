/* keybinder-3.0.vapi
 *
 * Copyright (C) 2024 Plank Reloaded Developers
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 */

[CCode (cprefix = "Keybinder", lower_case_cprefix = "keybinder_", cheader_filename = "keybinder.h")]
namespace Keybinder {
	[CCode (cname = "KeybinderHandler", has_target = false)]
	public delegate void Handler (string keystring, void* user_data);

	[CCode (cname = "keybinder_init")]
	public void init ();

	[CCode (cname = "keybinder_bind")]
	public bool bind (string keystring, Handler handler, void* user_data = null);

	[CCode (cname = "keybinder_bind_full")]
	public bool bind_full (string keystring, Handler handler, void* user_data, GLib.DestroyNotify? notify);

	[CCode (cname = "keybinder_unbind")]
	public void unbind (string keystring, Handler handler);

	[CCode (cname = "keybinder_unbind_all")]
	public void unbind_all (string keystring);

	[CCode (cname = "keybinder_get_current_event_time")]
	public uint32 get_current_event_time ();

	[CCode (cname = "keybinder_supported")]
	public bool supported ();
}