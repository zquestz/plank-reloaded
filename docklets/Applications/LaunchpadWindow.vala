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

namespace Docky {
  /**
   * One application in the launchpad grid.
   */
  class LaunchpadTile : Gtk.FlowBoxChild {
    public GLib.AppInfo info;
    public string key;

    public LaunchpadTile (GLib.AppInfo info, int icon_size) {
      this.info = info;
      key = info.get_display_name ().down ();

      var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);
      var image = new Gtk.Image ();
      image.pixel_size = icon_size;
      var icon = info.get_icon ();
      if (icon != null)
        image.set_from_gicon (icon, Gtk.IconSize.DIALOG);
      else
        image.set_from_icon_name ("application-x-executable", Gtk.IconSize.DIALOG);
      image.pixel_size = icon_size;

      var label = new Gtk.Label (info.get_display_name ());
      label.ellipsize = Pango.EllipsizeMode.END;
      label.max_width_chars = 14;
      label.width_chars = 14;
      label.justify = Gtk.Justification.CENTER;

      box.pack_start (image, false, false, 0);
      box.pack_start (label, false, false, 0);
      box.margin = 10;
      add (box);
      can_focus = true;
    }
  }

  /**
   * A full-screen grid of the installed applications with a search entry,
   * shown on the monitor the pointer is on.
   */
  public class LaunchpadWindow : Gtk.Window {
    const int ICON_SIZE = 72;
    const string CSS = """
      .plank-launchpad flowboxchild { border-radius: 14px; color: white; padding: 0; }
      .plank-launchpad flowboxchild:hover, .plank-launchpad flowboxchild:selected,
      .plank-launchpad flowboxchild:focus { background-color: alpha(white, 0.16); }
      .plank-launchpad flowboxchild label { color: white; text-shadow: 0 1px 2px alpha(black, 0.6); }
      .plank-launchpad scrolledwindow, .plank-launchpad viewport, .plank-launchpad flowbox { background: transparent; }
      .plank-launchpad entry { border-radius: 10px; min-height: 34px;
        background-color: alpha(white, 0.14); color: white; border: 1px solid alpha(white, 0.25); }
    """;

    Gtk.SearchEntry entry;
    Gtk.FlowBox flow;
    string filter = "";

    public LaunchpadWindow () {
      GLib.Object (type: Gtk.WindowType.TOPLEVEL);
    }

    construct {
      decorated = false;
      skip_taskbar_hint = true;
      skip_pager_hint = true;
      app_paintable = true;
      set_keep_above (true);

      unowned Gdk.Screen screen = get_screen ();
      set_visual (screen.get_rgba_visual () ?? screen.get_system_visual ());
      get_style_context ().add_class ("plank-launchpad");

      var provider = new Gtk.CssProvider ();
      try {
        provider.load_from_data (CSS, -1);
        Gtk.StyleContext.add_provider_for_screen (screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
      } catch (Error e) {
        warning ("Launchpad style: %s", e.message);
      }

      entry = new Gtk.SearchEntry ();
      entry.halign = Gtk.Align.CENTER;
      entry.width_request = 340;
      entry.search_changed.connect (() => {
        filter = entry.text.down ().strip ();
        flow.invalidate_filter ();
      });
      entry.activate.connect (launch_first_match);

      flow = new Gtk.FlowBox ();
      flow.homogeneous = true;
      flow.valign = Gtk.Align.START;
      flow.halign = Gtk.Align.CENTER;
      flow.min_children_per_line = 4;
      flow.max_children_per_line = 8;
      flow.row_spacing = 14;
      flow.column_spacing = 14;
      flow.selection_mode = Gtk.SelectionMode.NONE;
      flow.activate_on_single_click = true;
      flow.set_filter_func ((child) => {
        return filter == "" || ((LaunchpadTile) child).key.contains (filter);
      });
      flow.child_activated.connect ((child) => launch (((LaunchpadTile) child).info));

      var scrolled = new Gtk.ScrolledWindow (null, null);
      scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
      scrolled.add (flow);

      var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 28);
      box.margin_top = 60;
      box.margin_bottom = 110;
      box.margin_start = 80;
      box.margin_end = 80;
      box.pack_start (entry, false, false, 0);
      box.pack_start (scrolled, true, true, 0);
      add (box);

      add_events (Gdk.EventMask.BUTTON_PRESS_MASK | Gdk.EventMask.KEY_PRESS_MASK);
      focus_out_event.connect (() => { hide (); return false; });
      delete_event.connect (hide_on_delete);
    }

    void reload () {
      foreach (var child in flow.get_children ())
        flow.remove (child);

      var infos = GLib.AppInfo.get_all ();
      infos.sort ((a, b) => a.get_display_name ().collate (b.get_display_name ()));
      foreach (var info in infos) {
        if (!info.should_show ())
          continue;
        flow.add (new LaunchpadTile (info, ICON_SIZE));
      }
    }

    void launch (GLib.AppInfo info) {
      hide ();
      try {
        info.launch (null, get_display ().get_app_launch_context ());
      } catch (Error e) {
        warning ("Launchpad: could not launch '%s': %s", info.get_display_name (), e.message);
      }
    }

    void launch_first_match () {
      foreach (var child in flow.get_children ()) {
        unowned LaunchpadTile tile = (LaunchpadTile) child;
        if (filter == "" || tile.key.contains (filter)) {
          launch (tile.info);
          return;
        }
      }
    }

    /**
     * Shows the launchpad on the monitor the pointer is on, or hides it if
     * it is showing.
     */
    public void toggle () {
      if (visible) {
        hide ();
        return;
      }

      reload ();
      entry.text = "";
      filter = "";

      unowned Gdk.Display display = get_display ();
      int x, y;
      display.get_default_seat ().get_pointer ().get_position (null, out x, out y);
      var monitor = display.get_monitor_at_point (x, y);
      var n = 0;
      for (var i = 0; i < display.get_n_monitors (); i++) {
        if (display.get_monitor (i) == monitor) {
          n = i;
          break;
        }
      }

      show_all ();
      fullscreen_on_monitor (get_screen (), n);
      present ();
      entry.grab_focus ();
    }

    public override bool key_press_event (Gdk.EventKey event) {
      if (event.keyval == Gdk.Key.Escape) {
        hide ();
        return true;
      }
      return base.key_press_event (event);
    }

    public override bool button_press_event (Gdk.EventButton event) {
      // a press that reaches the window missed every tile
      hide ();
      return true;
    }

    public override bool draw (Cairo.Context cr) {
      cr.save ();
      cr.set_operator (Cairo.Operator.SOURCE);
      cr.set_source_rgba (0.07, 0.07, 0.10, get_screen ().is_composited () ? 0.80 : 1.0);
      cr.paint ();
      cr.restore ();
      return base.draw (cr);
    }
  }
}
