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
    private ulong theme_handler_id = 0UL;
    private PositionManager? connected_position_manager = null;
    private DockPreferences? connected_dock_prefs = null;

    private Gtk.PositionType cached_position;
    private bool is_light_theme;
    private Gdk.RGBA cached_color;
    private bool needs_update = true;

    private SeparatorPreferences prefs {
      get { return (SeparatorPreferences) Prefs; }
    }

    public SeparatorDockItem.with_dockitem_file (GLib.File file)
    {
      GLib.Object (Prefs: new SeparatorPreferences.with_file (file));
    }

    construct
    {
      update_icon ();
      Text = null;
      AllowZoom = false;

      cached_position = Gtk.PositionType.BOTTOM;
      is_light_theme = false;
      cached_color = { 1.0, 1.0, 1.0, 0.4 };

      separator_prefs_handler_id = prefs.notify.connect (handle_separator_prefs_changed);

      theme_handler_id = Gtk.Settings.get_default ().notify["gtk-theme-name"].connect (handle_gtk_theme_changed);

      // Dock signals connect once the item is attached to its container
      notify["Container"].connect (handle_container_changed);
    }

    private void handle_container_changed () {
      if (Container == null) {
        removed_from_dock ();
      } else if (position_handler_id == 0) {
        setup_signals ();
      }
    }

    // Teardown must not rely solely on the destructor: handlers on external
    // objects keep this item alive and unreachable for finalization
    private void removed_from_dock () {
      if (separator_prefs_handler_id > 0) {
        prefs.disconnect (separator_prefs_handler_id);
        separator_prefs_handler_id = 0;
      }

      if (theme_handler_id > 0UL) {
        SignalHandler.disconnect (Gtk.Settings.get_default (), theme_handler_id);
        theme_handler_id = 0UL;
      }

      disconnect_signals ();
    }

    [CCode (instance_pos = -1)]
    private void handle_separator_prefs_changed (GLib.Object o, ParamSpec p) {
      if (p.name == "InvertColor" || p.name == "Style") {
        update_cache (false, true);
      } else if (p.name == "CustomIcon") {
        update_icon ();
      }
    }

    [CCode (instance_pos = -1)]
    private void handle_gtk_theme_changed (GLib.Object o, ParamSpec p) {
      update_cache (false, true);
    }

    [CCode (instance_pos = -1)]
    private void handle_position_changed (GLib.Object o, ParamSpec p) {
      update_cache (true, false);
    }

    [CCode (instance_pos = -1)]
    private void handle_dock_prefs_changed (GLib.Object o, ParamSpec p) {
      if (p.name == "Theme") {
        update_cache (false, true);
      }
    }

    private void update_icon () {
      if (has_custom_icon ()) {
        Icon = prefs.CustomIcon;
      } else {
        Icon = "";
      }

      Idle.add (() => {
        reset_icon_buffer ();
        return false;
      });
    }

    private bool has_custom_icon () {
      string custom_icon = prefs.CustomIcon;
      return custom_icon != null && custom_icon != "";
    }

    private void setup_signals () {
      var dock = get_dock ();
      if (dock == null) {
        return;
      }

      connected_position_manager = dock.position_manager;
      position_handler_id = connected_position_manager.notify["Position"].connect (handle_position_changed);

      connected_dock_prefs = dock.prefs;
      prefs_handler_id = connected_dock_prefs.notify.connect (handle_dock_prefs_changed);

      update_cache (true, true);
    }

    private void disconnect_signals () {
      if (connected_position_manager != null && position_handler_id > 0) {
        connected_position_manager.disconnect (position_handler_id);
      }
      position_handler_id = 0;
      connected_position_manager = null;

      if (connected_dock_prefs != null && prefs_handler_id > 0) {
        connected_dock_prefs.disconnect (prefs_handler_id);
      }
      prefs_handler_id = 0;
      connected_dock_prefs = null;
    }

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
        if (prefs.InvertColor) {
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
      if (has_custom_icon ()) {
        base.draw_icon (surface);
        return;
      }

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
      switch (prefs.Style) {
      case SeparatorStyle.LINE:
        draw_line_separator (cr, size);
        break;
      case SeparatorStyle.DOT:
        draw_dot_separator (cr, size);
        break;
      case SeparatorStyle.SPACE:
        break;
      }
    }

    private void draw_line_separator (Cairo.Context cr, int size) {
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

    private void draw_dot_separator (Cairo.Context cr, int size) {
      cr.set_source_rgba (cached_color.red, cached_color.green, cached_color.blue, cached_color.alpha);

      double center_x = size / 2.0;
      double center_y = size / 2.0;
      double radius = size * 0.08;

      cr.arc (center_x, center_y, radius, 0, 2 * Math.PI);
      cr.fill ();
    }

    private void show_icon_picker () {
      var file_chooser = new Gtk.FileChooserDialog (
                                                    _("Select Custom Icon"),
                                                    null,
                                                    Gtk.FileChooserAction.OPEN,
                                                    _("Cancel"), Gtk.ResponseType.CANCEL,
                                                    _("Select"), Gtk.ResponseType.ACCEPT
      );

      string[] icon_paths = {
        "/usr/share/icons",
        "/usr/share/pixmaps",
        GLib.Environment.get_home_dir () + "/.local/share/icons"
      };

      foreach (var path in icon_paths) {
        var dir = File.new_for_path (path);
        if (dir.query_exists ()) {
          file_chooser.set_current_folder (path);
          break;
        }
      }

      var filter = new Gtk.FileFilter ();
      filter.set_name (_("Image Files"));
      filter.add_mime_type ("image/png");
      filter.add_mime_type ("image/jpeg");
      filter.add_mime_type ("image/svg+xml");
      filter.add_mime_type ("image/webp");
      filter.add_pattern ("*.png");
      filter.add_pattern ("*.jpg");
      filter.add_pattern ("*.jpeg");
      filter.add_pattern ("*.svg");
      filter.add_pattern ("*.xpm");
      filter.add_pattern ("*.webp");
      file_chooser.add_filter (filter);

      var preview = new Gtk.Image ();
      preview.set_size_request (128, 128);
      file_chooser.set_preview_widget (preview);
      file_chooser.set_use_preview_label (false);

      file_chooser.update_preview.connect (() => {
        string? filename = file_chooser.get_preview_filename ();
        if (filename == null) {
          file_chooser.set_preview_widget_active (false);
          return;
        }

        try {
          var pixbuf = new Gdk.Pixbuf.from_file_at_scale (filename, 128, 128, true);
          preview.set_from_pixbuf (pixbuf);
          file_chooser.set_preview_widget_active (true);
        } catch (Error e) {
          file_chooser.set_preview_widget_active (false);
        }
      });

      if (file_chooser.run () == Gtk.ResponseType.ACCEPT) {
        string uri = file_chooser.get_uri ();
        prefs.CustomIcon = uri;
      }

      file_chooser.destroy ();
    }

    public override Gee.ArrayList<Gtk.MenuItem> get_menu_items () {
      var items = new Gee.ArrayList<Gtk.MenuItem> ();

      var custom_icon_item = new Gtk.MenuItem.with_mnemonic (_("Choose Custom Icon"));
      custom_icon_item.activate.connect (() => {
        show_icon_picker ();
      });
      items.add (custom_icon_item);

      if (has_custom_icon ()) {
        var reset_icon_item = new Gtk.MenuItem.with_mnemonic (_("Reset to Default Icon"));
        reset_icon_item.activate.connect (() => {
          prefs.CustomIcon = "";
        });
        items.add (reset_icon_item);
      }

      items.add (new Gtk.SeparatorMenuItem ());

      var style_item = new Gtk.MenuItem.with_mnemonic (_("_Style"));
      var style_menu = new Gtk.Menu ();
      style_item.set_submenu (style_menu);
      style_item.sensitive = !has_custom_icon ();

      var line_item = new Gtk.RadioMenuItem.with_mnemonic (null, _("_Line"));
      line_item.active = (prefs.Style == SeparatorStyle.LINE);
      line_item.sensitive = !has_custom_icon ();
      line_item.activate.connect (() => {
        if (line_item.active && !has_custom_icon ()) {
          prefs.Style = SeparatorStyle.LINE;
        }
      });
      style_menu.add (line_item);

      var dot_item = new Gtk.RadioMenuItem.with_mnemonic_from_widget (line_item, _("_Dot"));
      dot_item.active = (prefs.Style == SeparatorStyle.DOT);
      dot_item.sensitive = !has_custom_icon ();
      dot_item.activate.connect (() => {
        if (dot_item.active && !has_custom_icon ()) {
          prefs.Style = SeparatorStyle.DOT;
        }
      });
      style_menu.add (dot_item);

      var space_item = new Gtk.RadioMenuItem.with_mnemonic_from_widget (line_item, _("_Space"));
      space_item.active = (prefs.Style == SeparatorStyle.SPACE);
      space_item.sensitive = !has_custom_icon ();
      space_item.activate.connect (() => {
        if (space_item.active && !has_custom_icon ()) {
          prefs.Style = SeparatorStyle.SPACE;
        }
      });
      style_menu.add (space_item);

      items.add (style_item);
      style_item.show_all ();

      var invert_item = new Gtk.CheckMenuItem.with_mnemonic (_("_Invert Color"));
      invert_item.active = prefs.InvertColor;
      invert_item.sensitive = !has_custom_icon ();
      invert_item.activate.connect (() => {
        if (!has_custom_icon ()) {
          prefs.InvertColor = !prefs.InvertColor;
        }
      });
      items.add (invert_item);

      return items;
    }
  }
}
