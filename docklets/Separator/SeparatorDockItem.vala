//
// Copyright (C) 2025 Plank Reloaded Developers
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

using Plank;

namespace Docky {
  public class SeparatorDockItem : DockletItem {
    private ulong position_handler_id = 0;
    private ulong prefs_handler_id = 0;
    private ulong separator_prefs_handler_id = 0;
    private uint setup_timer_id = 0;

    private Gtk.PositionType cached_position;
    private bool is_light_theme;
    private Gdk.RGBA cached_color;
    private bool needs_update = true;

    private SeparatorPreferences separator_prefs {
      get { return (SeparatorPreferences) Prefs; }
    }

    public SeparatorDockItem.with_dockitem_file (GLib.File file)
    {
      GLib.Object (Prefs: new SeparatorPreferences.with_file (file));
    }

    construct
    {
      Icon = "";
      Text = null;

      // Initialize defaults for cached values
      // Default color is white with 40% opacity
      cached_position = Gtk.PositionType.BOTTOM;
      is_light_theme = false;
      cached_color = { 1.0, 1.0, 1.0, 0.4 };

      separator_prefs_handler_id = separator_prefs.notify["InvertColor"].connect (() => {
        update_cache (false, true);
      });

      setup_timer_id = Timeout.add (2000, () => {
        setup_signals ();
        setup_timer_id = 0;
        return false;
      });
    }

    ~SeparatorDockItem () {
      if (setup_timer_id > 0) {
        Source.remove (setup_timer_id);
        setup_timer_id = 0;
      }

      if (separator_prefs_handler_id > 0) {
        separator_prefs.disconnect (separator_prefs_handler_id);
        separator_prefs_handler_id = 0;
      }

      disconnect_signals ();
    }

    private void setup_signals () {
      var dock = get_dock ();
      if (dock != null) {
        position_handler_id = dock.position_manager.notify["Position"].connect (() => {
          update_cache (true, false);
        });

        prefs_handler_id = dock.prefs.notify.connect ((s, p) => {
          if (p.name == "Theme") {
            update_cache (false, true);
          }
        });

        update_cache (true, true);
      } else {
        warning ("SeparatorDockItem: dock controller still null after timer");
      }
    }

    private void disconnect_signals () {
      var dock = get_dock ();
      if (dock != null) {
        if (position_handler_id > 0) {
          dock.position_manager.disconnect (position_handler_id);
          position_handler_id = 0;
        }

        if (prefs_handler_id > 0) {
          dock.prefs.disconnect (prefs_handler_id);
          prefs_handler_id = 0;
        }
      }
    }

    // Update cached values - can selectively update position or theme
    private bool update_cache (bool update_position, bool update_theme) {
      var dock = get_dock ();
      if (dock == null)
        return false;

      if (update_position) {
        cached_position = dock.position_manager.Position;
      }

      if (update_theme) {
        var theme = dock.renderer.theme;
        Gdk.RGBA fill_color = theme.FillStartColor;

        double brightness = calculate_brightness (fill_color);
        is_light_theme = brightness > 0.5;

        bool use_dark = is_light_theme;
        if (separator_prefs.InvertColor) {
          use_dark = !use_dark;
        }

        if (use_dark) {
          cached_color = { 0.0, 0.0, 0.0, 0.4 };
        } else {
          cached_color = { 1.0, 1.0, 1.0, 0.4 };
        }
      }

      needs_update = false;

      if (update_position || update_theme) {
        Idle.add (() => {
          reset_icon_buffer ();
          return false;
        });
      }

      return true;
    }

    protected override void draw_icon (Surface surface) {
      int size = int.max (surface.Width, surface.Height);
      unowned Cairo.Context cr = surface.Context;

      cr.save ();
      cr.set_operator (Cairo.Operator.CLEAR);
      cr.paint ();
      cr.restore ();

      if (needs_update) {
        bool updated = update_cache (true, true);
        if (!updated) {
          return;
        }
      }

      draw_separator (cr, size);
    }

    private double calculate_brightness (Gdk.RGBA color) {
      return 0.299 * color.red + 0.587 * color.green + 0.114 * color.blue;
    }

    private void draw_separator (Cairo.Context cr, int size) {
      cr.set_source_rgba (cached_color.red, cached_color.green, cached_color.blue, cached_color.alpha);
      cr.set_line_width (2.0);

      bool horizontal = (cached_position == Gtk.PositionType.LEFT ||
                         cached_position == Gtk.PositionType.RIGHT);

      if (horizontal) {
        double y = size / 2.0;
        cr.move_to (size * 0.1, y);
        cr.line_to (size * 0.9, y);
      } else {
        double x = size / 2.0;
        cr.move_to (x, size * 0.1);
        cr.line_to (x, size * 0.9);
      }

      cr.stroke ();
    }

    // Override to provide menu items
    public override Gee.ArrayList<Gtk.MenuItem> get_menu_items () {
      var items = new Gee.ArrayList<Gtk.MenuItem> ();

      var invert_item = new Gtk.CheckMenuItem.with_mnemonic (_("_Invert Color"));
      invert_item.active = separator_prefs.InvertColor;
      invert_item.activate.connect (() => {
        separator_prefs.InvertColor = !separator_prefs.InvertColor;
      });
      items.add (invert_item);

      return items;
    }
  }
}
