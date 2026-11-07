/*
 * Copyright (C) 2026 Plank Reloaded Developers
 *
 * This file is part of Plank.
 *
 * Plank is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Plank is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "monitor-edid.h"

#include <string.h>
#include <gdk/gdkx.h>
#include <X11/Xatom.h>
#include <X11/extensions/Xrandr.h>

/*
 * The EDID a monitor reports, read from the EDID property of the RandR
 * output GDK names it by, or NULL when the display isn't X11 or the output
 * has none.
 */
GBytes *
plank_monitor_get_edid (GdkDisplay *display, const gchar *output_name)
{
  Display *xdisplay;
  XRRScreenResources *resources;
  Atom edid_atom;
  GBytes *edid = NULL;
  int i;

  if (!GDK_IS_X11_DISPLAY (display) || output_name == NULL)
    return NULL;

  xdisplay = GDK_DISPLAY_XDISPLAY (display);

  edid_atom = XInternAtom (xdisplay, RR_PROPERTY_RANDR_EDID, True);
  if (edid_atom == None)
    return NULL;

  /* An output can go away while it is read */
  gdk_x11_display_error_trap_push (display);

  resources = XRRGetScreenResourcesCurrent (xdisplay, DefaultRootWindow (xdisplay));
  for (i = 0; resources != NULL && i < resources->noutput && edid == NULL; i++) {
    XRROutputInfo *info = XRRGetOutputInfo (xdisplay, resources, resources->outputs[i]);
    unsigned char *data = NULL;
    unsigned long n_items, bytes_after;
    Atom type;
    int format;

    if (info == NULL)
      continue;

    /* An EDID is 128 bytes per block, up to 4 blocks: 128 longs */
    if (strcmp (info->name, output_name) == 0
        && XRRGetOutputProperty (xdisplay, resources->outputs[i], edid_atom, 0, 128, False, False,
                                 AnyPropertyType, &type, &format, &n_items, &bytes_after, &data) == Success
        && data != NULL && type == XA_INTEGER && format == 8 && n_items >= 128)
      edid = g_bytes_new (data, n_items);

    if (data != NULL)
      XFree (data);
    XRRFreeOutputInfo (info);
  }

  if (resources != NULL)
    XRRFreeScreenResources (resources);

  gdk_x11_display_error_trap_pop_ignored (display);

  return edid;
}
