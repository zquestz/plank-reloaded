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
  public class WorkspacesDockItem : DockletItem {
    private ulong invert_color_handler_id = 0;
    private ulong live_previews_handler_id = 0;
    private ulong prefs_handler_id = 0;
    private ulong theme_handler_id = 0UL;
    private uint setup_timer_id = 0;
    private uint redraw_timeout_id = 0;
    private Gee.HashMap<Wnck.Window, Gee.ArrayList<ulong>> window_signals =
      new Gee.HashMap<Wnck.Window, Gee.ArrayList<ulong>> ();
    private int workspace_count = 0;
    private int current_workspace = 0;
    private int rows;
    private int cols;
    private bool is_light_theme;
    private bool needs_update = true;

    private WorkspacesPreferences workspaces_prefs {
      get { return (WorkspacesPreferences) Prefs; }
    }

    public WorkspacesDockItem.with_dockitem_file (GLib.File file)
    {
      GLib.Object (Prefs: new WorkspacesPreferences.with_file (file));
    }

    construct
    {
      Icon = WorkspacesDocklet.ICON;
      Text = _("Workspaces");

      is_light_theme = false;

      setup_workspace_info ();

      invert_color_handler_id = workspaces_prefs.notify["InvertColor"].connect (() => {
        update_cache ();
      });

      connect_screen_signals ();

      live_previews_handler_id = workspaces_prefs.notify["LivePreviews"].connect (() => {
        if (workspaces_prefs.LivePreviews) {
          register_window_tracking (null);
        } else {
          unregister_all_window_tracking ();
        }
        queue_redraw ();
      });

      register_window_tracking (null);

      // Setup theme detection with a slight delay to ensure dock is ready
      setup_timer_id = Timeout.add (2000, () => {
        setup_theme_signals ();
        setup_timer_id = 0;
        return false;
      });
    }

    private void connect_screen_signals () {
      unowned Wnck.Screen screen = Wnck.Screen.get_default ();
      screen.active_workspace_changed.connect_after (handle_workspace_changed);
      screen.workspace_created.connect_after (handle_workspace_count_changed);
      screen.workspace_destroyed.connect_after (handle_workspace_count_changed);
      screen.window_opened.connect_after (handle_window_event);
      screen.window_closed.connect_after (handle_window_closed);
      screen.window_stacking_changed.connect_after (handle_stacking_changed);
    }

    private void setup_theme_signals () {
      var dock = get_dock ();
      if (dock != null) {
        prefs_handler_id = dock.prefs.notify.connect ((s, p) => {
          if (p.name == "Theme") {
            update_cache ();
          }
        });

        theme_handler_id = Gtk.Settings.get_default ().notify["gtk-theme-name"].connect (
        (s, p) => {
          update_cache ();
        });

        update_cache ();
      } else {
        warning ("WorkspacesDockItem: dock controller still null after timer");
      }
    }

    ~WorkspacesDockItem () {
      if (setup_timer_id > 0) {
        Source.remove (setup_timer_id);
        setup_timer_id = 0;
      }

      if (invert_color_handler_id > 0) {
        workspaces_prefs.disconnect (invert_color_handler_id);
        invert_color_handler_id = 0;
      }

      if (live_previews_handler_id > 0) {
        workspaces_prefs.disconnect (live_previews_handler_id);
        live_previews_handler_id = 0;
      }

      disconnect_screen_signals ();
      disconnect_theme_signals ();
      unregister_all_window_tracking ();

      if (redraw_timeout_id > 0) {
        Source.remove (redraw_timeout_id);
        redraw_timeout_id = 0;
      }
    }

    private void disconnect_screen_signals () {
      unowned Wnck.Screen screen = Wnck.Screen.get_default ();
      screen.active_workspace_changed.disconnect (handle_workspace_changed);
      screen.workspace_created.disconnect (handle_workspace_count_changed);
      screen.workspace_destroyed.disconnect (handle_workspace_count_changed);
      screen.window_opened.disconnect (handle_window_event);
      screen.window_closed.disconnect (handle_window_closed);
      screen.window_stacking_changed.disconnect (handle_stacking_changed);
    }

    private void disconnect_theme_signals () {
      var dock = get_dock ();
      if (dock != null) {
        if (prefs_handler_id > 0) {
          dock.prefs.disconnect (prefs_handler_id);
          prefs_handler_id = 0;
        }

        if (theme_handler_id > 0UL) {
          SignalHandler.disconnect (Gtk.Settings.get_default (), theme_handler_id);
          theme_handler_id = 0UL;
        }
      }
    }

    private bool update_cache () {
      var dock = get_dock ();
      if (dock == null)
        return false;

      var theme = dock.renderer.theme;
      Gdk.RGBA fill_color = theme.FillStartColor;

      double brightness = calculate_brightness (fill_color);
      is_light_theme = brightness > 0.5;

      needs_update = false;
      queue_redraw ();

      return true;
    }

    private double calculate_brightness (Gdk.RGBA color) {
      return 0.299 * color.red + 0.587 * color.green + 0.114 * color.blue;
    }

    private void setup_workspace_info () {
      unowned Wnck.Screen screen = Wnck.Screen.get_default ();

      current_workspace = screen.get_active_workspace () ? .get_number () ?? 0;
      workspace_count = screen.get_workspace_count ();

      Text = _("Workspace %d of %d").printf (current_workspace + 1, workspace_count);
    }

    [CCode (instance_pos = -1)]
    private void handle_workspace_changed (Wnck.Screen screen, Wnck.Workspace? previous) {
      bool changed = false;

      unowned Wnck.Workspace? active_workspace = screen.get_active_workspace ();
      if (active_workspace != null) {
        int new_workspace = active_workspace.get_number ();

        if (new_workspace != current_workspace) {
          current_workspace = new_workspace;
          debug ("Current workspace changed to %d\n", current_workspace);
          changed = true;
        }
      }

      int new_count = screen.get_workspace_count ();
      if (new_count != workspace_count) {
        workspace_count = new_count;
        debug ("Workspace count changed to %d\n", workspace_count);
        changed = true;
      }

      if (changed) {
        Text = _("Workspace %d of %d").printf (current_workspace + 1, workspace_count);
        queue_redraw ();
      }
    }

    [CCode (instance_pos = -1)]
    private void handle_workspace_count_changed (Wnck.Screen screen, Wnck.Workspace? workspace) {
      int new_count = screen.get_workspace_count ();

      if (new_count != workspace_count) {
        workspace_count = new_count;
        debug ("Workspace count changed to %d\n", workspace_count);
        Text = _("Workspace %d of %d").printf (current_workspace + 1, workspace_count);
        queue_redraw ();
      }
    }

    [CCode (instance_pos = -1)]
    private void handle_window_event (Wnck.Screen screen, Wnck.Window window) {
      register_window_tracking (window);
      queue_redraw ();
    }

    [CCode (instance_pos = -1)]
    private void handle_stacking_changed (Wnck.Screen screen) {
      queue_redraw ();
    }

    [CCode (instance_pos = -1)]
    private void handle_window_closed (Wnck.Screen screen, Wnck.Window window) {
      unregister_window_tracking (window);
      queue_redraw ();
    }

    private void register_window_tracking (Wnck.Window? new_window) {
      unowned Wnck.Screen screen = Wnck.Screen.get_default ();
      if (!workspaces_prefs.LivePreviews) {
        return;
      }

      // If a specific window was provided, just track that one
      if (new_window != null) {
        if (!window_signals.has_key (new_window)) {
          // Create a map to store multiple signal IDs per window
          if (window_signals[new_window] == null) {
            window_signals[new_window] = new Gee.ArrayList<ulong> ();
          }

          // Connect to geometry changes
          ulong geom_handler_id = new_window.geometry_changed.connect (() => {
            queue_redraw ();
          });
          window_signals[new_window].add (geom_handler_id);

          // Connect to state changes
          ulong state_handler_id = new_window.state_changed.connect ((changed_mask, new_state) => {
            Wnck.WindowState interesting_states = Wnck.WindowState.MINIMIZED
              | Wnck.WindowState.MAXIMIZED_HORIZONTALLY
              | Wnck.WindowState.MAXIMIZED_VERTICALLY;
            if ((changed_mask & interesting_states) != 0) {
              queue_redraw ();
            }
          });
          window_signals[new_window].add (state_handler_id);
        }
        return;
      }

      // Otherwise, track all existing windows
      foreach (unowned Wnck.Window window in screen.get_windows ()) {
        register_window_tracking (window);
      }
    }

    private void unregister_window_tracking (Wnck.Window window) {
      if (window_signals.has_key (window)) {
        var handler_ids = window_signals[window];
        foreach (ulong id in handler_ids) {
          window.disconnect (id);
        }
        window_signals.unset (window);
      }
    }

    private void unregister_all_window_tracking () {
      foreach (var entry in window_signals.entries) {
        Wnck.Window window = entry.key;
        var handler_ids = entry.value;
        foreach (ulong id in handler_ids) {
          window.disconnect (id);
        }
      }
      window_signals.clear ();
    }

    protected override AnimationType on_clicked (PopupButton button, Gdk.ModifierType mod, uint32 event_time) {
      if (button == PopupButton.LEFT) {
        int next_workspace = (current_workspace + 1) % workspace_count;
        switch_to_workspace (next_workspace);
      }

      return AnimationType.NONE;
    }

    protected override AnimationType on_scrolled (Gdk.ScrollDirection direction, Gdk.ModifierType mod, uint32 event_time) {
      int new_workspace = current_workspace;

      if (direction == Gdk.ScrollDirection.UP || direction == Gdk.ScrollDirection.LEFT) {
        new_workspace = (current_workspace - 1 + workspace_count) % workspace_count;
      } else if (direction == Gdk.ScrollDirection.DOWN || direction == Gdk.ScrollDirection.RIGHT) {
        new_workspace = (current_workspace + 1) % workspace_count;
      }

      switch_to_workspace (new_workspace);

      return AnimationType.NONE;
    }

    private void switch_to_workspace (int workspace_num) {
      if (workspace_num == current_workspace) {
        return;
      }

      unowned Wnck.Screen screen = Wnck.Screen.get_default ();
      unowned Wnck.Workspace? workspace = screen.get_workspace (workspace_num);

      if (workspace != null) {
        workspace.activate (Gtk.get_current_event_time ());
      }
    }

    private void queue_redraw () {
      if (redraw_timeout_id > 0) {
        Source.remove (redraw_timeout_id);
      }

      redraw_timeout_id = Timeout.add (100, () => {
        redraw_timeout_id = 0;
        reset_icon_buffer ();
        return false;
      });
    }

    protected override void draw_icon (Surface surface) {
      if (needs_update) {
        bool updated = update_cache ();
        if (!updated) {
          is_light_theme = false;
        }
      }

      int width = surface.Width;
      int height = surface.Height;
      unowned Cairo.Context cr = surface.Context;

      cr.save ();
      cr.set_source_rgba (0, 0, 0, 0);
      cr.set_operator (Cairo.Operator.CLEAR);
      cr.paint ();
      cr.restore ();

      if (workspace_count <= 0) {
        return;
      }

      rows = cols = 1;

      if (workspace_count == 1) {
        rows = cols = 1;
      } else if (workspace_count == 2) {
        rows = 1;
        cols = 2;
      } else if (workspace_count == 3) {
        rows = 2;
        cols = 2;
      } else {
        cols = (int) Math.ceil (Math.sqrt (workspace_count));
        rows = (int) Math.ceil ((double) workspace_count / cols);
      }

      unowned Wnck.Screen screen = Wnck.Screen.get_default ();
      int screen_width = screen.get_width ();
      int screen_height = screen.get_height ();
      bool is_horizontal = screen_width >= screen_height;

      double aspect_ratio = is_horizontal ? 4.0 / 3.0 : 3.0 / 4.0;
      double scale = 1.0;

      int max_cell_width = (int) Math.floor ((width * scale) / cols);
      int max_cell_height = (int) Math.floor ((height * scale) / rows);

      int cell_width, cell_height;

      if (max_cell_width < max_cell_height * aspect_ratio) {
        cell_width = max_cell_width;
        cell_height = (int) (cell_width / aspect_ratio);
      } else {
        cell_height = max_cell_height;
        cell_width = (int) (cell_height * aspect_ratio);
      }

      if (cell_width * cols > width * scale) {
        cell_width = (int) (width * scale / cols);
        cell_height = (int) (cell_width / aspect_ratio);
      }

      if (cell_height * rows > height * scale) {
        cell_height = (int) (height * scale / rows);
        cell_width = (int) (cell_height * aspect_ratio);
      }

      int grid_width = cell_width * cols;
      int grid_height = cell_height * rows;

      int offset_x = (width - grid_width) / 2;
      int offset_y = (height - grid_height) / 2;

      for (int i = 0; i < workspace_count; i++) {
        int row = i / cols;
        int col = i % cols;

        int x = offset_x + col * cell_width;
        int y = offset_y + row * cell_height;

        draw_workspace (cr, x, y, cell_width, cell_height, i);
      }
    }

    private void draw_workspace (Cairo.Context cr, int x, int y, int width, int height, int workspace_num) {
      int padding = 1;
      int border = 1;

      int x_padded = x + padding;
      int y_padded = y + padding;
      int width_padded = width - (padding * 2);
      int height_padded = height - (padding * 2);

      if (width_padded <= 0 || height_padded <= 0)
        return;

      cr.save ();
      cr.set_operator (Cairo.Operator.OVER);

      bool use_dark = !is_light_theme;
      if (workspaces_prefs.InvertColor) {
        use_dark = !use_dark;
      }

      cr.rectangle (x_padded, y_padded, width_padded, height_padded);
      if (use_dark) {
        cr.set_source_rgba (0.13, 0.13, 0.15, 0.95);
      } else {
        cr.set_source_rgba (0.92, 0.92, 0.94, 0.95);
      }
      cr.fill ();

      int x_inner = x_padded + border;
      int y_inner = y_padded + border;
      int width_inner = width_padded - (border * 2);
      int height_inner = height_padded - (border * 2);

      cr.rectangle (x_inner, y_inner, width_inner, height_inner);

      if (use_dark) {
        if (workspace_num == current_workspace) {
          cr.set_source_rgba (0.15, 0.25, 0.40, 1.0);
        } else {
          cr.set_source_rgba (0.22, 0.22, 0.25, 1.0);
        }
      } else {
        if (workspace_num == current_workspace) {
          cr.set_source_rgba (0.90, 0.95, 1.0, 1.0);
        } else {
          cr.set_source_rgba (0.82, 0.82, 0.85, 1.0);
        }
      }
      cr.fill ();

      if (workspaces_prefs.LivePreviews) {
        unowned Wnck.Screen screen = Wnck.Screen.get_default ();
        unowned Wnck.Workspace workspace = screen.get_workspace (workspace_num);

        if (workspace != null) {
          foreach (unowned Wnck.Window window in screen.get_windows ()) {
            if (window.is_on_workspace (workspace) &&
                !window.is_minimized () &&
                window.get_window_type () == Wnck.WindowType.NORMAL) {

              int win_x, win_y, win_width, win_height;
              window.get_geometry (out win_x, out win_y, out win_width, out win_height);

              int screen_width = screen.get_width ();
              int screen_height = screen.get_height ();

              int preview_x = x_inner + (win_x * width_inner / screen_width);
              int preview_y = y_inner + (win_y * height_inner / screen_height);
              int preview_width = win_width * width_inner / screen_width;
              int preview_height = win_height * height_inner / screen_height;

              preview_width = int.max (preview_width, 3);
              preview_height = int.max (preview_height, 3);

              cr.rectangle (preview_x, preview_y, preview_width, preview_height);

              Gdk.RGBA window_color;
              if (use_dark) {
                if (workspace_num == current_workspace) {
                  window_color = { 0.35, 0.55, 0.85, 0.7 };
                } else {
                  window_color = { 0.75, 0.75, 0.78, 0.7 };
                }
              } else {
                if (workspace_num == current_workspace) {
                  window_color = { 0.0, 0.4, 0.8, 0.7 };
                } else {
                  window_color = { 0.3, 0.3, 0.33, 0.7 };
                }
              }

              cr.set_source_rgba (window_color.red, window_color.green, window_color.blue, window_color.alpha);
              cr.fill ();
            }
          }
        }
      }

      cr.restore ();
    }

    public override Gee.ArrayList<Gtk.MenuItem> get_menu_items () {
      var items = new Gee.ArrayList<Gtk.MenuItem> ();
      unowned Wnck.Screen screen = Wnck.Screen.get_default ();

      for (int i = 0; i < workspace_count; i++) {
        unowned Wnck.Workspace? workspace = screen.get_workspace (i);
        string name = workspace != null? workspace.get_name () : _("Workspace %d").printf (i + 1);

        var item = new Gtk.MenuItem.with_label (name);

        if (i == current_workspace) {
          var label = item.get_child () as Gtk.Label;
          if (label != null) {
            label.set_markup ("<b>" + label.get_text () + "</b>");
          }
        }

        int workspace_num = i;
        item.activate.connect (() => {
          switch_to_workspace (workspace_num);
        });

        items.add (item);
      }

      var separator_item = new Gtk.SeparatorMenuItem ();
      items.add (separator_item);

      var invert_item = new Gtk.CheckMenuItem.with_mnemonic (_("_Invert Color"));
      invert_item.active = workspaces_prefs.InvertColor;
      invert_item.activate.connect (() => {
        workspaces_prefs.InvertColor = !workspaces_prefs.InvertColor;
      });
      items.add (invert_item);

      var live_previews_item = new Gtk.CheckMenuItem.with_mnemonic (_("_Live Previews"));
      live_previews_item.active = workspaces_prefs.LivePreviews;
      live_previews_item.activate.connect (() => {
        workspaces_prefs.LivePreviews = !workspaces_prefs.LivePreviews;
      });
      items.add (live_previews_item);

      return items;
    }
  }
}
