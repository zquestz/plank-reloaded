//
// Copyright (C) 2011-2012 Robert Dyer, Rico Tzschichholz
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
   * Handles all of the drawing for a dock.
   */
  public class DockRenderer : Renderer {
    public DockController controller { private get; construct; }

    public DockTheme theme { get; private set; }

    /**
     * The current progress [0.0..1.0] of the hide-animation of the dock.
     */
    [CCode (notify = false)]
    public double hide_progress { get; private set; }

    /**
     * The current opacity of the dock.
     */
    [CCode (notify = false)]
    double opacity { get; private set; }

    /**
     * The current progress [0.0..1.0] of the zoom-in-animation of the dock.
     */
    [CCode (notify = false)]
    public double zoom_in_progress { get; private set; }

    /**
     * The current local cursor-position on the dock if hovered.
     */
    public Gdk.Point local_cursor;

    /**
     * The rendering backend for buffer management.
     */
    RenderBackend backend;

    // Reusable scratch surface for icon modifications (lighten/darken/overlay)
    // Avoids per-frame allocations when drawing modified icons
    Surface? scratch_surface = null;
    int scratch_surface_size = 0;

    Surface? background_buffer = null;
    Gdk.Rectangle background_rect;

    int64 last_hide = 0LL;
    int64 last_hovered_changed = 0LL;

    bool screen_is_composited = false;
    bool show_notifications = true;
    uint reset_position_manager_timer_id = 0U;
    int window_scale_factor = 1;
    bool is_first_frame = true;
    bool zoom_changed = false;

    ulong gtk_theme_name_changed_handler_id = 0UL;

    double dynamic_animation_offset = 0.0;

    Gee.ArrayList<unowned DockItem> current_items;
    Gee.HashSet<DockItem> transient_items;
#if BENCHMARK
    Gee.ArrayList<string> benchmark;
#endif

    /**
     * Create a new dock renderer for a dock.
     *
     * @param controller the dock controller to manage drawing for
     * @param window the dock window to be animated
     */
    public DockRenderer (DockController controller, Gtk.Window window) {
      GLib.Object (controller : controller, widget : window);
    }

    construct
    {
      transient_items = new Gee.HashSet<DockItem> ();
      current_items = new Gee.ArrayList<unowned DockItem> ();
#if BENCHMARK
      benchmark = new Gee.ArrayList<string> ();
#endif
      backend = RenderBackend.create (controller);
      controller.prefs.notify.connect (prefs_changed);

      load_theme ();
    }

    /**
     * Initializes the renderer.  Call after the DockWindow is constructed.
     */
    public void initialize ()
    requires (controller.window != null)
    {
      controller.position_manager.update (theme);

      controller.window.notify["HoveredItem"].connect (animated_draw);
      controller.hide_manager.notify["Hidden"].connect (hidden_changed);
      controller.hide_manager.notify["Hovered"].connect (hovered_changed);

#if HAVE_CLUTTER
      initialize_clutter ();
#endif
    }

    ~DockRenderer () {
      controller.prefs.notify.disconnect (prefs_changed);
      theme.notify.disconnect (theme_changed);

      controller.hide_manager.notify["Hidden"].disconnect (hidden_changed);
      controller.hide_manager.notify["Hovered"].disconnect (hovered_changed);
      controller.window.notify["HoveredItem"].disconnect (animated_draw);

#if HAVE_CLUTTER
      cleanup_clutter ();
#endif
    }

    void prefs_changed (Object prefs, ParamSpec prop) {
      switch (prop.name) {
      case "Alignment" :
      case "IconSize" :
      case "ItemsAlignment" :
      case "Offset" :
      case "Position":
        reset_position_manager ();
        break;
      case "Theme":
        load_theme ();
        break;
      default:
        // Nothing important for us changed
        break;
      }
    }

    void theme_changed () {
      reset_position_manager ();
    }

    void reset_position_manager () {
      // Don't perform an update immediately and summon further
      // update-requests, wait at least 50ms after the last request

      if (reset_position_manager_timer_id > 0U)
        Source.remove (reset_position_manager_timer_id);

      reset_position_manager_timer_id = Gdk.threads_add_timeout (50, () => {
        reset_position_manager_timer_id = 0U;

        reset_buffers ();
        reset_item_buffers ();
        controller.position_manager.update (theme);

        return false;
      });
    }

    void load_theme () {
      var is_reload = (theme != null);

      if (is_reload)
        theme.notify.disconnect (theme_changed);

      unowned string name = controller.prefs.Theme;
      if (name == Theme.GTK_THEME_NAME) {
        if (gtk_theme_name_changed_handler_id == 0UL)
          gtk_theme_name_changed_handler_id = Gtk.Settings.get_default ().notify["gtk-theme-name"].connect (load_theme);
      } else if (gtk_theme_name_changed_handler_id > 0UL) {
        SignalHandler.disconnect (Gtk.Settings.get_default (), gtk_theme_name_changed_handler_id);
        gtk_theme_name_changed_handler_id = 0UL;
      }

      theme = new DockTheme (name);
      theme.load ("dock");
      theme.notify.connect (theme_changed);

      if (is_reload)
        theme_changed ();
    }

    /**
     * Resets all internal buffers and forces a redraw.
     */
    public void reset_buffers () {
      Logger.verbose ("DockRenderer.reset_buffers ()");

      backend.reset_buffers ();

      animated_draw ();
    }

    /**
     * Resets all internal item buffers and forces a redraw.
     */
    void reset_item_buffers () {
      Logger.verbose ("DockRenderer.reset_item_buffers ()");

      controller.reset_buffers ();

      animated_draw ();
    }

    /**
     * {@inheritDoc}
     */
    protected override void initialize_frame (int64 frame_time) {
      return_if_fail (theme != null);

      unowned Gee.ArrayList<unowned DockItem> new_items = controller.VisibleItems;

      // Bail out if there are no visible items to render
      if (new_items.size <= 0) {
        critical ("No items available to initialize frame");
        return;
      }

      unowned PositionManager position_manager = controller.position_manager;

      screen_is_composited = position_manager.screen_is_composited;
      show_notifications = EnvironmentSettings.get_instance ().ShowNotifications;
      dynamic_animation_offset = 0.0;

      var fade_opacity = theme.FadeOpacity;

      if (screen_is_composited) {
        var hide_duration = (fade_opacity == 1.0 ? theme.HideTime : theme.FadeTime) * 1000;
        var hide_time = int64.max (0LL, frame_time - last_hide);
        if (hide_time < hide_duration) {
          if (controller.hide_manager.Hidden)
            hide_progress = easing_for_mode (AnimationMode.EASE_IN_CUBIC, hide_time, hide_duration);
          else
            hide_progress = 1.0 - easing_for_mode (AnimationMode.EASE_OUT_CUBIC, hide_time, hide_duration);
        } else {
          hide_progress = (controller.hide_manager.Hidden ? 1.0 : 0.0);
        }

        var zoom_duration = DOCK_ZOOM_DURATION * 1000;
        var zoom_time = int64.max (0LL, frame_time - last_hovered_changed);
        double zoom_progress;
        if (zoom_time < zoom_duration) {
          if (controller.hide_manager.Hovered) {
            zoom_progress = easing_for_mode (AnimationMode.EASE_OUT_CUBIC, zoom_time, zoom_duration);
          } else {
            zoom_progress = 1.0 - easing_for_mode (AnimationMode.EASE_IN_CUBIC, zoom_time, zoom_duration);
          }
        } else {
          zoom_progress = (controller.hide_manager.Hovered ? 1.0 : 0.0);
        }
        zoom_in_progress = zoom_progress * (1.0 - hide_progress);
      } else {
        hide_progress = 0.0;
        zoom_in_progress = 0.0;
      }

      if (fade_opacity < 1.0)
        opacity = 1.0 - (1.0 - fade_opacity) * hide_progress;
      else
        opacity = 1.0;

      // Update *ordered* list of items
      current_items.clear ();
      current_items.add_all (new_items);

      if (screen_is_composited) {
        var add_time = 0LL;
        var remove_time = 0LL;
        var move_time = 0LL;
        var move_duration = theme.ItemMoveTime * 1000;

        var transient_items_it = transient_items.iterator ();
        while (transient_items_it.next ()) {
          var item = transient_items_it.get ();
          add_time = item.AddTime;
          remove_time = item.RemoveTime;

          if (add_time > remove_time) {
            // Item is being added - check if already in list (from new_items)
            move_time = frame_time - add_time;
            if (move_time < move_duration) {
              if (!current_items.contains (item))
                current_items.add (item);
            } else {
              transient_items_it.remove ();
            }
          } else if (remove_time > 0) {
            // Item is being removed - not in new_items, so skip contains() check
            move_time = frame_time - remove_time;
            if (move_time < move_duration) {
              current_items.add (item);
            } else {
              transient_items_it.remove ();
            }
          }
        }
      } else {
        transient_items.clear ();
      }

      // Only sort if transient items were added - new_items is already in position order
      if (transient_items.size > 0)
        current_items.sort ((CompareDataFunc) compare_dock_item_position);

      // Calculate positions for given ordered list of items
      position_manager.update_draw_values (current_items,
                                           (DrawValueFunc) animate_draw_value_for_item,
                                           (DrawValuesFunc) post_process_draw_values);

      background_rect = position_manager.get_background_region ();
    }

#if HAVE_CLUTTER
    /**
     * Initializes Clutter draw callback if GPU rendering is active.
     */
    void initialize_clutter () {
      if (controller.window.gpu_rendering_active) {
        controller.window.set_clutter_draw_func (on_clutter_draw);
      }
    }

    /**
     * Cleans up Clutter draw callback to prevent dangling reference.
     */
    void cleanup_clutter () {
      if (controller.window.gpu_rendering_active) {
        controller.window.set_clutter_draw_func (null);
      }
    }

    /**
     * Triggers a Clutter canvas redraw if GPU rendering is active.
     *
     * @return true if GPU rendering handled the draw, false to fall back to CPU
     */
    bool queue_clutter_draw () {
      if (!controller.window.gpu_rendering_active)
        return false;

      unowned PositionManager position_manager = controller.position_manager;
      var win_rect = position_manager.get_dock_window_region ();
      controller.window.update_clutter_size (win_rect.width, win_rect.height);
      controller.window.invalidate_clutter_canvas ();
      return true;
    }

    /**
     * Clutter canvas draw callback for GPU rendering.
     *
     * Note: This is called asynchronously by Clutter's frame loop, not by GTK's
     * draw cycle. We must update frame_time here to get accurate animation timing.
     */
    void on_clutter_draw (Cairo.Context cr, int width, int height) {
      // Update frame time - critical fix: Clutter calls this asynchronously,
      // so the inherited frame_time property may be stale
      int64 local_frame_time = force_frame_time_update ();

      // Initialize frame state with fresh timing
      initialize_frame (local_frame_time);

      // Draw directly to the canvas context
      draw_to_context (cr, local_frame_time);
    }

    /**
     * Draws the dock directly to a Cairo context (used by Clutter canvas).
     *
     * Uses cached ImageSurface buffers from ClutterBackend to avoid allocating
     * new surfaces every frame. Clutter canvas surfaces don't work well with
     * Cairo.Surface.similar(), so we use ImageSurfaces instead.
     */
    void draw_to_context (Cairo.Context cr, int64 local_frame_time) {
      if (current_items.is_empty) {
        critical ("No items available to draw frame");
        return;
      }

      unowned PositionManager position_manager = controller.position_manager;
      unowned DockItem dragged_item = controller.drag_manager.DragItem;
      unowned ClutterBackend clutter_backend = (ClutterBackend) backend;

      // Update backend state
      backend.update_scale_factor (controller.window);
      window_scale_factor = backend.window_scale_factor;
      backend.begin_frame (local_frame_time, hide_progress, opacity, zoom_in_progress);

      var win_rect = position_manager.get_dock_window_region ();
      var width = win_rect.width;
      var height = win_rect.height;

      // Get cached ImageSurface buffers from ClutterBackend - avoids per-frame allocation
      unowned Cairo.ImageSurface main_surface;
      unowned Cairo.ImageSurface item_surface;
      unowned Cairo.ImageSurface shadow_surface;
      clutter_backend.get_clutter_surfaces (width, height, window_scale_factor, out main_surface, out item_surface, out shadow_surface);

      // Get cached model surface for buffer creation (avoids per-frame allocation)
      unowned Surface? model = clutter_backend.get_model_surface ();

      // Ensure standard Surface buffers are allocated - needed for icon loading APIs
      // and for urgent glow drawing when dock is hidden
      if (model != null) {
        backend.ensure_buffers (width, height, model.Internal);
      } else {
        // Fallback: create a temporary model surface
        var temp_model = new Cairo.ImageSurface (Cairo.Format.ARGB32, width, height);
        backend.ensure_buffers (width, height, temp_model);
      }

      // Check if we can skip full drawing (dock completely hidden)
      var no_full_draw_needed = (!is_first_frame && hide_progress == 1.0 && opacity == 1.0);

      // If dock is completely hidden, only draw urgent glow indicators
      if (no_full_draw_needed) {
        // we still need to clear out the previous output
        cr.save ();
        cr.set_operator (Cairo.Operator.CLEAR);
        cr.paint ();
        cr.restore ();

        if (show_notifications) {
          foreach (unowned DockItem item in current_items)
            draw_urgent_glow (item, cr, local_frame_time);
        }

        backend.end_frame ();
        return;
      }

      // Calculate drawing offset for slide animation (when FadeOpacity == 1.0)
      var x_offset = 0, y_offset = 0;
      if (opacity == 1.0)
        position_manager.get_dock_draw_position (out x_offset, out y_offset);

      // Clear the cached surfaces before drawing
      clutter_backend.clear_clutter_surfaces ();

      var main_cr = new Cairo.Context (main_surface);
      var item_cr = new Cairo.Context (item_surface);
      var shadow_cr = new Cairo.Context (shadow_surface);

      // composite dock layers and make sure to draw onto the canvas with one operation
      main_cr.set_operator (Cairo.Operator.OVER);

      // draw background-layer (model should never be null after get_clutter_surfaces, but check anyway)
      unowned Surface? bg_buffer = (model != null) ? backend.get_background_buffer (
        background_rect.width, background_rect.height,
        theme, position_manager.Position, model) : null;

      if (bg_buffer != null) {
        main_cr.set_source_surface (bg_buffer.Internal,
          background_rect.x + x_offset, background_rect.y + y_offset);
        main_cr.paint ();
      }

      // draw each item
      foreach (unowned DockItem item in current_items) {
        if (item.IsVisible && dragged_item != item) {
          var draw_value = position_manager.get_draw_value_for_item (item);
          draw_item (item_cr, item, draw_value, local_frame_time);
          draw_item_shadow (shadow_cr, item, draw_value);
        }
      }

      // composite layers onto main surface
      main_cr.set_source_surface (shadow_surface, x_offset, y_offset);
      main_cr.paint ();
      main_cr.set_source_surface (item_surface, x_offset, y_offset);
      main_cr.paint ();

      // paint final result to the Clutter canvas context
      cr.set_operator (Cairo.Operator.SOURCE);
      if (opacity < 1.0) {
        unowned Cairo.ImageSurface? fade_surface = clutter_backend.get_clutter_fade_surface ();
        if (fade_surface != null) {
          var fade_cr = new Cairo.Context (fade_surface);
          fade_cr.set_operator (Cairo.Operator.CLEAR);
          fade_cr.paint ();
          fade_cr.set_operator (Cairo.Operator.OVER);
          fade_cr.set_source_surface (main_surface, 0, 0);
          fade_cr.paint_with_alpha (opacity);
          cr.set_source_surface (fade_surface, 0, 0);
        } else {
          cr.set_source_surface (main_surface, 0, 0);
        }
      } else {
        cr.set_source_surface (main_surface, 0, 0);
      }
      cr.paint ();

      // Draw urgent-glow during fade-out (when opacity < 1.0 but hide_progress == 1.0)
      // Note: When fully hidden with opacity == 1.0, we return early above
      if (show_notifications && hide_progress == 1.0) {
        foreach (unowned DockItem item in current_items)
          draw_urgent_glow (item, cr, local_frame_time);
      }

      if (is_first_frame) {
        message ("Rendering: GPU (Clutter)");

        // Workaround for bug #1256626 - plank not appearing after login
        // Use idle callback to ensure dock appears after initialization completes
        Gdk.threads_add_idle_full (GLib.Priority.LOW, () => {
          unowned HideManager hide_manager = controller.hide_manager;

          // HideManager.initialize() already updates Hidden state,
          // but only if there is an active window
          if (hide_manager.Hidden)
            return false;

          // Slide the dock in if it shouldn't start hidden
          hide_manager.update_hovered ();

          last_hide = force_frame_time_update ();

          hidden_changed ();
          return false;
        });

        is_first_frame = false;
      }

      backend.end_frame ();
    }
#endif

    /**
     * {@inheritDoc}
     */
    public override void draw (Cairo.Context cr, int64 frame_time) {
#if HAVE_CLUTTER
      if (queue_clutter_draw ())
        return;
#endif
      draw_internal (cr, frame_time);
    }

    /**
     * Internal drawing method for the Cairo/CPU rendering path.
     */
    void draw_internal (Cairo.Context cr, int64 frame_time) {
      // Bail out if there are no items to draw
      if (current_items.is_empty) {
        critical ("No items available to draw frame");
        return;
      }

      // Update backend state
      backend.update_scale_factor (controller.window);
      window_scale_factor = backend.window_scale_factor;

      // Begin frame with current animation state
      backend.begin_frame (frame_time, hide_progress, opacity, zoom_in_progress);

      // Check if we can skip full drawing (dock completely hidden)
      var no_full_draw_needed = (!is_first_frame && hide_progress == 1.0 && opacity == 1.0);

      unowned PositionManager position_manager = controller.position_manager;
      unowned DockItem dragged_item = controller.drag_manager.DragItem;
      var win_rect = position_manager.get_dock_window_region ();

      // Ensure all buffers are properly allocated
      backend.ensure_buffers (win_rect.width, win_rect.height, cr.get_target ());

      // If dock is completely hidden, only draw urgent glow indicators
      if (no_full_draw_needed) {
        // we still need to clear out the previous output
        cr.save ();
        cr.set_operator (Cairo.Operator.CLEAR);
        cr.paint ();
        cr.restore ();

        if (show_notifications) {
          foreach (unowned DockItem item in current_items)
            draw_urgent_glow (item, cr, frame_time);
        }

        backend.end_frame ();
        return;
      }

#if BENCHMARK
      DateTime start, start2, end, end2;
      benchmark.clear ();
      start = new DateTime.now_local ();
#endif

      unowned Surface main_buffer = backend.get_main_buffer ();
      unowned Surface item_buffer = backend.get_item_buffer ();
      unowned Surface shadow_buffer = backend.get_shadow_buffer ();

      main_buffer.clear ();
      item_buffer.clear ();
      shadow_buffer.clear ();
      unowned Cairo.Context item_cr = item_buffer.Context;
      unowned Cairo.Context shadow_cr = shadow_buffer.Context;

      // calculate drawing offset
      var x_offset = 0, y_offset = 0;
      if (opacity == 1.0)
        position_manager.get_dock_draw_position (out x_offset, out y_offset);

      // composite dock layers and make sure to draw onto the window's context with one operation
      unowned Cairo.Context main_cr = main_buffer.Context;
      main_cr.set_operator (Cairo.Operator.OVER);

#if BENCHMARK
      start2 = new DateTime.now_local ();
#endif
      // draw background-layer
      draw_dock_background (main_cr, background_rect, x_offset, y_offset);
#if BENCHMARK
      end2 = new DateTime.now_local ();
      benchmark.add ("background render time - %f ms".printf (end2.difference (start2) / 1000.0));
#endif

      // Cache shadow size check to avoid repeated method calls in loop
      bool has_shadows = (theme.IconShadowSize > 0);

      // draw each item onto the dock buffer
      foreach (unowned DockItem item in current_items) {
#if BENCHMARK
        start2 = new DateTime.now_local ();
#endif
        // Do not draw the currently dragged item
        if (item.IsVisible && dragged_item != item) {
          var draw_value = position_manager.get_draw_value_for_item (item);
          draw_item (item_cr, item, draw_value, frame_time);
          if (has_shadows)
            draw_item_shadow (shadow_cr, item, draw_value);
        }
#if BENCHMARK
        end2 = new DateTime.now_local ();
        benchmark.add ("item render time - %f ms".printf (end2.difference (start2) / 1000.0));
#endif
      }

      // draw items-shadow-layer
      main_cr.set_source_surface (shadow_buffer.Internal, x_offset, y_offset);
      main_cr.paint ();

      // draw items-layer
      main_cr.set_source_surface (item_buffer.Internal, x_offset, y_offset);
      main_cr.paint ();

      // draw the dock on the window and fade it if need be
      cr.set_operator (Cairo.Operator.SOURCE);
      if (opacity < 1.0) {
        unowned Surface fade_buffer = backend.get_fade_buffer ();
        fade_buffer.clear ();
        unowned Cairo.Context fade_cr = fade_buffer.Context;
        fade_cr.set_operator (Cairo.Operator.OVER);
        fade_cr.set_source_surface (main_buffer.Internal, 0, 0);
        fade_cr.paint_with_alpha (opacity);

        cr.set_source_surface (fade_buffer.Internal, 0, 0);
      } else {
        cr.set_source_surface (main_buffer.Internal, 0, 0);
      }
      cr.paint ();

      // draw urgent-glow if dock is completely hidden
      if (show_notifications && hide_progress == 1.0) {
        foreach (unowned DockItem item in current_items)
          draw_urgent_glow (item, cr, frame_time);
      }

#if BENCHMARK
      end = new DateTime.now_local ();
      var diff = end.difference (start) / 1000.0;
      if (diff > 5.0)
        foreach (var s in benchmark)
          message ("	"+ s);
      message ("render time - %f ms", diff);
#endif

      if (is_first_frame) {
        // Note: GPU (Clutter) path handles its own first-frame in draw_to_context()
        message ("Rendering: CPU (Cairo), SurfaceType: %s", cairo_surface_type_to_string (cr.get_target ().get_type ()));

        // Workaround for bug #1256626 - plank not appearing after login
        // Use idle callback to ensure dock appears after initialization completes
        Gdk.threads_add_idle_full (GLib.Priority.LOW, () => {
          unowned HideManager hide_manager = controller.hide_manager;

          // HideManager.initialize() already updates Hidden state,
          // but only if there is an active window
          if (hide_manager.Hidden)
            return false;

          // Slide the dock in if it shouldn't start hidden
          hide_manager.update_hovered ();

          last_hide = force_frame_time_update ();

          hidden_changed ();
          return false;
        });

        is_first_frame = false;
      }

      backend.end_frame ();
    }

    void draw_dock_background (Cairo.Context cr, Gdk.Rectangle background_rect, int x_offset, int y_offset) {
      unowned PositionManager position_manager = controller.position_manager;

      unowned Surface? background_buffer = backend.get_background_buffer (
        background_rect.width, background_rect.height,
        theme, position_manager.Position, backend.get_main_buffer ());

      if (background_buffer == null)
        return;

      if (hide_progress > 0.0 && theme.CascadeHide) {
        int x, y;
        position_manager.get_background_padding (out x, out y);
        x_offset -= (int) (x * hide_progress);
        y_offset -= (int) (y * hide_progress);
      }

      cr.set_source_surface (background_buffer.Internal, background_rect.x + x_offset, background_rect.y + y_offset);
      cr.paint ();
    }

    [CCode (instance_pos = -1)]
    void animate_draw_value_for_item (DockItem item, DockItemDrawValue draw_value) {
      unowned PositionManager position_manager = controller.position_manager;
      unowned DockItem hovered_item = controller.window.HoveredItem;
      unowned DragManager drag_manager = controller.drag_manager;

      var icon_size = (int) draw_value.icon_size;
      var position = position_manager.Position;
      var x_offset = 0.0, y_offset = 0.0;

      // Cache commonly used duration values (avoid repeated multiplications)
      var item_move_duration = theme.ItemMoveTime * 1000;

      // check for and calculate click-animation
      // Only calculate if animation type is not NONE to avoid unnecessary work
      if (item.ClickedAnimation != AnimationType.NONE) {
        var max_click_time = item.ClickedAnimation == AnimationType.BOUNCE ? theme.LaunchBounceTime * 1000 : theme.ClickTime * 1000;
        var click_time = int64.max (0LL, frame_time - item.LastClicked);
        if (click_time < max_click_time) {
          var click_animation_progress = click_time / (double) max_click_time;

          switch (item.ClickedAnimation) {
          case AnimationType.BOUNCE:
            if (screen_is_composited)
              y_offset += position_manager.LaunchBounceHeight * easing_bounce (click_time, max_click_time, 2);
            break;
          case AnimationType.DARKEN:
            draw_value.darken = Math.sin (Math.PI * click_animation_progress) * 0.5;
            break;
          case AnimationType.LIGHTEN:
            draw_value.lighten = Math.sin (Math.PI * click_animation_progress) * 0.5;
            break;
          default:
            break;
          }
        }
      }

      // check for and calculate scroll-animation
      if (item.ScrolledAnimation != AnimationType.NONE) {
        var max_scroll_time = ITEM_SCROLL_DURATION * 1000;
        var scroll_time = int64.max (0LL, frame_time - item.LastScrolled);
        if (scroll_time < max_scroll_time) {
          var scroll_animation_progress = scroll_time / (double) max_scroll_time;

          switch (item.ScrolledAnimation) {
          case AnimationType.DARKEN:
            draw_value.darken = Math.sin (Math.PI * scroll_animation_progress) * 0.5;
            break;
          case AnimationType.LIGHTEN:
            draw_value.lighten = Math.sin (Math.PI * scroll_animation_progress) * 0.5;
            break;
          default:
            break;
          }
        }
      }

      // check for and calculate hover-animation
      var max_hover_time = ITEM_HOVER_DURATION * 1000;
      var hover_time = int64.max (0LL, frame_time - item.LastHovered);
      bool is_hovered = (hovered_item == item);

      if (hover_time < max_hover_time) {
        if (item.HoveredAnimation == AnimationType.LIGHTEN) {
          var hover_animation_progress = is_hovered
            ? easing_for_mode (AnimationMode.LINEAR, hover_time, max_hover_time)
            : 1.0 - easing_for_mode (AnimationMode.LINEAR, hover_time, max_hover_time);
          draw_value.lighten = hover_animation_progress * 0.2;
        }
      } else if (is_hovered && !item.is_separator ()) {
        // Steady-state hover: constant lighten value
        draw_value.lighten = 0.2;
      }

      // Handle menu and drag states (quick checks)
      if (is_hovered && controller.window.menu_is_visible ())
        draw_value.darken += 0.4;
      else if (drag_manager.ExternalDragActive
               && drag_manager.DragNeedsCheck
               && !drag_manager.drop_is_accepted_by (item))
        draw_value.darken += 0.6;

      // bounce icon on urgent state - only check if state flag is set
      if ((item.State & ItemState.URGENT) != 0 && screen_is_composited && show_notifications) {
        var urgent_duration = theme.UrgentBounceTime * 1000;
        var urgent_time = int64.max (0LL, frame_time - item.LastUrgent);
        if (urgent_time < urgent_duration)
          y_offset += position_manager.UrgentBounceHeight * easing_bounce (urgent_time, urgent_duration, 1.0);
      }

      // animate addition/removal
      unowned DockContainer? container = item.Container;
      var allow_animation = (screen_is_composited && (container == null || container.AddTime < item.AddTime));
      if (allow_animation && item.AddTime > item.RemoveTime) {
        var move_time = int64.max (0LL, frame_time - item.AddTime);
        if (move_time < item_move_duration) {
          var move_animation_progress = 1.0 - easing_for_mode (AnimationMode.LINEAR, move_time, item_move_duration);
          draw_value.opacity = easing_for_mode (AnimationMode.EASE_IN_EXPO, move_time, item_move_duration);
          y_offset -= move_animation_progress * (icon_size + position_manager.BottomPadding);
          draw_value.show_indicator = false;

          // calculate the resulting incremental dynamic-animation-offset used to animate the background-resize and icon-offset
          move_animation_progress = 1.0 - easing_for_mode (AnimationMode.EASE_OUT_QUINT, move_time, item_move_duration);
          dynamic_animation_offset -= move_animation_progress * (icon_size + position_manager.ItemPadding);
          x_offset += dynamic_animation_offset;
        }
      } else if (allow_animation && item.RemoveTime > 0) {
        var move_time = int64.max (0LL, frame_time - item.RemoveTime);
        if (move_time < item_move_duration) {
          var move_animation_progress = easing_for_mode (AnimationMode.LINEAR, move_time, item_move_duration);
          draw_value.opacity = 1.0 - easing_for_mode (AnimationMode.EASE_OUT_EXPO, move_time, item_move_duration);
          y_offset -= move_animation_progress * (icon_size + position_manager.BottomPadding);
          draw_value.show_indicator = false;

          // calculate the resulting incremental dynamic-animation-offset used to animate the background-resize and icon-offset
          move_animation_progress = 1.0 - easing_for_mode (AnimationMode.EASE_IN_QUINT, move_time, item_move_duration);
          dynamic_animation_offset += move_animation_progress * (icon_size + position_manager.ItemPadding);
          x_offset += dynamic_animation_offset - (icon_size + position_manager.ItemPadding);
        }
      }

      // animate icon movement on move state - only check if state flag is set
      if ((item.State & ItemState.MOVE) != 0) {
        var move_time = int64.max (0LL, frame_time - item.LastMove);
        if (move_time < item_move_duration) {
          var move_animation_progress = 0.0;
          if (transient_items.size > 0) {
            if (dynamic_animation_offset > 0)
              move_animation_progress = 1.0 - easing_for_mode (AnimationMode.EASE_IN_QUINT, move_time, item_move_duration);
            else
              move_animation_progress = 1.0 - easing_for_mode (AnimationMode.EASE_OUT_QUINT, move_time, item_move_duration);
          } else {
            move_animation_progress = 1.0 - easing_for_mode (AnimationMode.EASE_OUT_CIRC, move_time, item_move_duration);
          }
          var change = move_animation_progress * (icon_size + position_manager.ItemPadding);
          x_offset += (item.Position < item.LastPosition ? change : -change);
        } else {
          item.unset_move_state ();
        }
      }

      // animate icon on invalid state - only check if state flag is set
      if ((item.State & ItemState.INVALID) != 0) {
        var invalid_duration = ITEM_INVALID_DURATION * 1000;
        var invalid_time = int64.max (0LL, frame_time - item.LastValid);
        if (invalid_time < invalid_duration) {
          draw_value.opacity = 0.10 + (0.90 * (Math.cos (invalid_time / (double) invalid_duration * 4.5 * Math.PI) + 1) / 2);
        } else {
          draw_value.opacity = 0.10;
        }
      }

      if (x_offset != 0.0)
        draw_value.move_right (position, x_offset);

      if (y_offset != 0.0)
        draw_value.move_in (position, y_offset);
    }

    [CCode (instance_pos = -1)]
    void post_process_draw_values (Gee.ArrayList<unowned DockItem> items) {
      if (dynamic_animation_offset == 0.0)
        return;

      unowned PositionManager position_manager = controller.position_manager;
      var position = position_manager.Position;

      var x_offset = 0.0;

      switch (position_manager.Alignment) {
      default :
      case Gtk.Align.CENTER:
        x_offset -= Math.round (dynamic_animation_offset / 2.0);
        break;
      case Gtk.Align.START:
        break;
      case Gtk.Align.END:
        x_offset -= Math.round (dynamic_animation_offset);
        break;
      case Gtk.Align.FILL:
        switch (position_manager.ItemsAlignment) {
        default:
        case Gtk.Align.FILL:
        case Gtk.Align.CENTER:
          x_offset -= Math.round (dynamic_animation_offset / 2.0);
          break;
        case Gtk.Align.START:
          break;
        case Gtk.Align.END:
          x_offset -= Math.round (dynamic_animation_offset);
          break;
        }
        break;
      }

      if (x_offset == 0.0)
        return;

      foreach (unowned DockItem item in items) {
        item.draw_value.move_right (position, x_offset);
      }
    }

    inline Surface get_item_surface (DockItem item, int icon_size) {
      unowned Surface item_buffer = backend.get_item_buffer ();
      var private_icon_surface = item.get_surface (icon_size, icon_size, item_buffer);
      if (!screen_is_composited)
        return private_icon_surface;

      // Check if the underlying cache returned a marked surface and if needed
      // request another draw with the currently assumed largest required size
      string? drawing_status;
      unowned PositionManager position_manager = controller.position_manager;
      var max_icon_size = position_manager.ZoomIconSize * window_scale_factor;
      if (icon_size < max_icon_size
          && ((drawing_status = private_icon_surface.steal_qdata<string> (quark_surface_stats)) != null
              && drawing_status == SURFACE_STATS_DRAWING_TIME_EXCEEDED))
        item.get_surface (max_icon_size, max_icon_size, item_buffer);

      return private_icon_surface;
    }

    void draw_item (Cairo.Context cr, DockItem item, DockItemDrawValue draw_value, int64 frame_time) {
      unowned PositionManager position_manager = controller.position_manager;
      unowned Surface item_buffer = backend.get_item_buffer ();
      var icon_size = (int) draw_value.icon_size * window_scale_factor;
      var position = position_manager.Position;

      // load the icon
#if BENCHMARK
      var start = new DateTime.now_local ();
#endif
      // Check if we need to modify the surface (overlay, lighten, or darken)
      // Only copy if modifications are needed to avoid allocation overhead
      Surface? icon_overlay_surface = null;
      if (item.CountVisible || item.ProgressVisible)
        icon_overlay_surface = item.get_foreground_surface (icon_size, icon_size, item_buffer, (DrawDataFunc<DockItem>) draw_item_foreground);

      // Apply threshold to skip tiny lighten/darken values that are imperceptible
      // This avoids surface operations during animation tails
      const double EFFECT_THRESHOLD = 0.01;
      bool has_lighten = draw_value.lighten > EFFECT_THRESHOLD;
      bool has_darken = draw_value.darken > EFFECT_THRESHOLD;
      bool needs_surface_modification = (icon_overlay_surface != null || has_lighten || has_darken);

      Surface icon_surface;
      if (needs_surface_modification) {
        // Get the base icon surface
        var base_surface = get_item_surface (item, icon_size);

        // Reuse scratch surface if possible, otherwise create/resize it
        if (scratch_surface == null || scratch_surface_size < icon_size) {
          scratch_surface = new Surface.with_surface (icon_size, icon_size, base_surface);
          scratch_surface_size = icon_size;
        }

        // Clear and copy base surface to scratch
        scratch_surface.clear ();
        unowned Cairo.Context scratch_cr = scratch_surface.Context;
        scratch_cr.set_source_surface (base_surface.Internal, 0, 0);
        scratch_cr.paint ();

        if (icon_overlay_surface != null) {
          scratch_cr.set_source_surface (icon_overlay_surface.Internal, 0, 0);
          scratch_cr.paint ();
        }

        // lighten the icon
        // Note: source is already set to base_surface from the copy above,
        // or to icon_overlay_surface if overlay was applied (matching original behavior)
        if (has_lighten) {
          scratch_cr.set_operator (Cairo.Operator.ADD);
          scratch_cr.paint_with_alpha (draw_value.lighten);
          scratch_cr.set_operator (Cairo.Operator.OVER);
        }

        // darken the icon
        if (has_darken) {
          scratch_cr.rectangle (0, 0, icon_size, icon_size);
          scratch_cr.set_source_rgba (0, 0, 0, draw_value.darken);
          scratch_cr.set_operator (Cairo.Operator.ATOP);
          scratch_cr.fill ();
          scratch_cr.set_operator (Cairo.Operator.OVER);
        }

        icon_surface = scratch_surface;
      } else {
        // No modifications needed - use cached surface directly
        icon_surface = get_item_surface (item, icon_size);
      }

#if BENCHMARK
      var end = new DateTime.now_local ();
      benchmark.add ("	item.get_surface time - %f ms".printf (end.difference (start) / 1000.0));
#endif

      // draw active glow
      var active_time = int64.max (0LL, frame_time - item.LastActive);
      var opacity = double.min (1, active_time / (double) (theme.ActiveTime * 1000));
      if ((item.State & ItemState.ACTIVE) == 0) {
        opacity = 1 - opacity;
      }

      if (opacity > 0) {
        var color = (theme.use_average_icon_color () ? item.AverageIconColor : theme.ActiveItemColor);
        theme.draw_active_glow (item_buffer, background_rect, draw_value.background_region, color, opacity, position);
      }

      if (window_scale_factor > 1) {
        cr.save ();
        cr.scale (1.0 / window_scale_factor, 1.0 / window_scale_factor);
      }

      var draw_region = draw_value.draw_region;
      cr.set_source_surface (icon_surface.Internal, draw_region.x * window_scale_factor, draw_region.y * window_scale_factor);
      if (draw_value.opacity < 1.0)
        cr.paint_with_alpha (draw_value.opacity);
      else
        cr.paint ();
      if (window_scale_factor > 1)
        cr.restore ();

      // draw indicators
      if (draw_value.show_indicator)
        draw_indicator_state (cr, draw_value.hover_region, item.Indicator, item.State);
    }

    void draw_item_shadow (Cairo.Context cr, DockItem item, DockItemDrawValue draw_value) {
      var scaled_icon_size = draw_value.icon_size / 10.0;
      var shadow_size = theme.IconShadowSize * scaled_icon_size;

      // Inflate size to fit shadow
      var icon_size = (int) (draw_value.icon_size + 2 * shadow_size) * window_scale_factor;

      // load and draw the icon shadow
      Surface? icon_shadow_surface = null;
      if (shadow_size > 0)
        icon_shadow_surface = item.get_background_surface (icon_size, icon_size, backend.get_item_buffer (), (DrawDataFunc<DockItem>) draw_item_background);

      if (icon_shadow_surface != null) {
        if (window_scale_factor > 1) {
          cr.save ();
          cr.scale (1.0 / window_scale_factor, 1.0 / window_scale_factor);
        }
        var draw_region = draw_value.draw_region;
        cr.set_operator (Cairo.Operator.OVER);
        cr.set_source_surface (icon_shadow_surface.Internal, (draw_region.x - shadow_size) * window_scale_factor, (draw_region.y - shadow_size) * window_scale_factor);
        if (draw_value.opacity < 1.0)
          cr.paint_with_alpha (draw_value.opacity);
        else
          cr.paint ();
        if (window_scale_factor > 1)
          cr.restore ();
      }
    }

    [CCode (instance_pos = -1)]
    Surface draw_item_foreground (int width, int height, Surface model, DockItem item) {
      Logger.verbose ("DockItem.draw_item_overlay (width = %i, height = %i)", width, height);
      var surface = new Surface.with_surface (width, height, model);

      var icon_size = int.min (width, height);
      var urgent_color = theme.BadgeColor;
      if (urgent_color.equal ({ 0.0, 0.0, 0.0, 0.0 })) {
        urgent_color = (theme.IndicatorStyle == IndicatorStyleType.LEGACY ? theme.get_styled_color () : theme.IndicatorColor);
        urgent_color.add_hue (theme.UrgentHueShift);
      }

      // draw item's count
      if (item.CountVisible)
        theme.draw_item_count (surface, icon_size, urgent_color, item.Count);

      // draw item's progress
      if (item.ProgressVisible)
        theme.draw_item_progress (surface, icon_size, urgent_color, item.Progress);

      return surface;
    }

    [CCode (instance_pos = -1)]
    Surface draw_item_background (int width, int height, Surface model, DockItem item) {
      unowned PositionManager position_manager = controller.position_manager;

      var draw_value = position_manager.get_draw_value_for_item (item);
      var scaled_icon_size = draw_value.icon_size / 10.0;
      var shadow_size = theme.IconShadowSize * scaled_icon_size * window_scale_factor;

      var icon_size = (int) draw_value.icon_size * window_scale_factor;
      var icon_surface = item.get_surface (icon_size, icon_size, model);

      Logger.verbose ("DockItem.draw_icon_with_shadow (width = %i, height = %i, shadow_size = %i)", width, height, shadow_size);
      var surface = new Surface.with_surface (width, height, model);
      unowned Cairo.Context cr = surface.Context;
      var shadow_surface = icon_surface.create_mask (0.4, null);

      double xoffset = 0, yoffset = 0;
      switch (position_manager.Position) {
      default :
      case Gtk.PositionType.BOTTOM :
        yoffset = -shadow_size / 4;
        break;
      case Gtk.PositionType.TOP:
        yoffset = shadow_size / 4;
        break;
      case Gtk.PositionType.LEFT:
        xoffset = shadow_size / 4;
        break;
      case Gtk.PositionType.RIGHT:
        xoffset = -shadow_size / 4;
        break;
      }

      cr.set_source_surface (shadow_surface.Internal, shadow_size + xoffset, shadow_size + yoffset);
      cr.paint_with_alpha (0.44);
      surface.gaussian_blur ((int) Math.round (shadow_size));

      return surface;
    }

    void draw_indicator_state (Cairo.Context cr, Gdk.Rectangle item_rect, IndicatorState indicator_state, ItemState item_state) {
      if (indicator_state == IndicatorState.NONE || theme.IndicatorSize <= 0)
        return;

      unowned PositionManager position_manager = controller.position_manager;
      unowned Surface item_buffer = backend.get_item_buffer ();

      unowned Surface? indicator_surface = backend.get_indicator_buffer (
        indicator_state, item_state,
        position_manager.IconSize, position_manager.Position,
        theme, item_buffer);

      if (indicator_surface == null)
        return;

      var x = 0.0, y = 0.0;
      switch (position_manager.Position) {
      default:
      case Gtk.PositionType.BOTTOM:
        x = item_rect.x + item_rect.width / 2.0 - indicator_surface.Width / 2.0;
        y = item_buffer.Height - theme.get_bottom_offset () - indicator_surface.Height;
        break;
      case Gtk.PositionType.TOP:
        x = item_rect.x + item_rect.width / 2.0 - indicator_surface.Width / 2.0;
        y = theme.get_bottom_offset ();
        break;
      case Gtk.PositionType.LEFT:
        x = theme.get_bottom_offset ();
        y = item_rect.y + item_rect.height / 2.0 - indicator_surface.Height / 2.0;
        break;
      case Gtk.PositionType.RIGHT:
        x = item_buffer.Width - theme.get_bottom_offset () - indicator_surface.Width;
        y = item_rect.y + item_rect.height / 2.0 - indicator_surface.Height / 2.0;
        break;
      }

      cr.set_source_surface (indicator_surface.Internal, x, y);
      cr.paint ();
    }

    void draw_urgent_glow (DockItem item, Cairo.Context cr, int64 frame_time) {
      if ((item.State & ItemState.URGENT) == 0)
        return;

      var diff = int64.max (0LL, frame_time - item.LastUrgent);
      if (diff >= theme.GlowTime * 1000)
        return;

      unowned PositionManager position_manager = controller.position_manager;
      var x_offset = 0, y_offset = 0;

      unowned Surface? urgent_glow_buffer = backend.get_urgent_glow_buffer (
        position_manager.GlowSize, theme, backend.get_main_buffer ());

      if (urgent_glow_buffer == null)
        return;

      position_manager.get_urgent_glow_position (item, out x_offset, out y_offset);

      cr.set_source_surface (urgent_glow_buffer.Internal, x_offset, y_offset);
      var glow_opacity = 0.2 + (0.75 * (Math.sin (diff / (double) (theme.GlowPulseTime * 1000) * 2 * Math.PI) + 1) / 2);
      cr.paint_with_alpha (glow_opacity);
    }

    void hidden_changed () {
      var now = force_frame_time_update ();
      var diff = now - last_hide;
      var time = (theme.FadeOpacity == 1.0 ? theme.HideTime : theme.FadeTime) * 1000;

      if (diff < time)
        last_hide = now + (diff - time);
      else
        last_hide = now;

      if (!screen_is_composited) {
        controller.position_manager.update_dock_position ();
        controller.window.update_size_and_position ();
        return;
      }

      controller.window.update_icon_regions ();

      animated_draw ();
    }

    void hovered_changed () {
      var now = force_frame_time_update ();
      var diff = now - last_hovered_changed;
      var time = DOCK_ZOOM_DURATION * 1000;

      if (diff < time)
        last_hovered_changed = now + (diff - time);
      else
        last_hovered_changed = now;

      animated_draw ();
    }

    public void update_local_cursor (int x, int y) {
      Gdk.Point new_cursor = { x, y };
      if (local_cursor == new_cursor)
        return;

      local_cursor = new_cursor;

      if (screen_is_composited) {
        zoom_changed = true;
        animated_draw ();
      }
    }

    public void animate_items (Gee.List<DockElement> elements) {
      if (!screen_is_composited)
        return;

      foreach (var element in elements) {
        DockItem? item = (element as DockItem);
        if (item != null)
          transient_items.add (item);
      }

      if (transient_items.size > 0)
        animated_draw ();
    }

    /**
     * {@inheritDoc}
     */
    protected override bool animation_needed (int64 frame_time) {
      if (zoom_changed) {
        zoom_changed = false;
        return true;
      }

      if (frame_time - last_hovered_changed <= DOCK_ZOOM_DURATION * 1000)
        return true;

      if (theme.FadeOpacity == 1.0) {
        if (frame_time - last_hide <= theme.HideTime * 1000)
          return true;
      } else {
        if (frame_time - last_hide <= theme.FadeTime * 1000)
          return true;
      }

      if (transient_items.size > 0)
        return true;

      foreach (var item in current_items)
        if (item_animation_needed (item, frame_time))
          return true;

      return false;
    }

    inline bool item_animation_needed (DockItem item, int64 render_time) {
      if (item.ClickedAnimation != AnimationType.NONE
          && render_time - item.LastClicked <= (item.ClickedAnimation == AnimationType.BOUNCE ? theme.LaunchBounceTime : theme.ClickTime) * 1000)
        return true;
      if (item.HoveredAnimation != AnimationType.NONE
          && render_time - item.LastHovered <= ITEM_HOVER_DURATION * 1000)
        return true;
      if (item.ScrolledAnimation != AnimationType.NONE
          && render_time - item.LastScrolled <= ITEM_SCROLL_DURATION * 1000)
        return true;
      if (render_time - item.LastActive <= theme.ActiveTime * 1000)
        return true;
      if (show_notifications
          && render_time - item.LastUrgent <= (hide_progress == 1.0 ? theme.GlowTime : theme.UrgentBounceTime) * 1000)
        return true;
      if (render_time - item.LastMove <= theme.ItemMoveTime * 1000)
        return true;
      if (render_time - item.AddTime <= theme.ItemMoveTime * 1000)
        return true;
      if (render_time - item.RemoveTime <= theme.ItemMoveTime * 1000)
        return true;
      if (render_time - item.LastValid <= ITEM_INVALID_DURATION * 1000)
        return true;

      return false;
    }

    static int compare_dock_item_position (DockItem i1, DockItem i2) {
      var p_i1 = i1.Position;
      var p_i2 = i2.Position;

      if (p_i1 > p_i2)
        return 1;

      if (p_i1 < p_i2)
        return -1;

      if (i1.RemoveTime > i2.RemoveTime)
        return -1;

      return 1;
    }

    static double easing_bounce (double t, double d, double n)
    requires (t >= 0.0 && d > 0.0 && n >= 1.0)
    requires (t <= d)
    {
      var p = t / d;
      return Math.fabs (Math.sin (n * Math.PI * p) * double.min (1.0, (1.0 - p) * (2.0 * n) / (2.0 * n - 1.0)));
    }

    static unowned string cairo_surface_type_to_string (Cairo.SurfaceType type) {
      unowned string result;

      switch (type) {
      case Cairo.SurfaceType.IMAGE : result = "IMAGE"; break;
      case Cairo.SurfaceType.PDF: result = "PDF"; break;
      case Cairo.SurfaceType.PS: result = "PS"; break;
      case Cairo.SurfaceType.XLIB: result = "XLIB"; break;
      case Cairo.SurfaceType.XCB: result = "XCB"; break;
      case Cairo.SurfaceType.GLITZ: result = "GLITZ"; break;
      case Cairo.SurfaceType.QUARTZ: result = "QUARTZ"; break;
      case Cairo.SurfaceType.WIN32: result = "WIN32"; break;
      case Cairo.SurfaceType.BEOS: result = "BEOS"; break;
      case Cairo.SurfaceType.DIRECTFB: result = "DIRECTFB"; break;
      case Cairo.SurfaceType.SVG: result = "SVG"; break;
      case Cairo.SurfaceType.OS2: result = "OS2"; break;
      case Cairo.SurfaceType.WIN32_PRINTING: result = "WIN32_PRINTING"; break;
      case Cairo.SurfaceType.QUARTZ_IMAGE: result = "QUARTZ_IMAGE"; break;
      case Cairo.SurfaceType.SCRIPT: result = "SCRIPT"; break;
      case Cairo.SurfaceType.QT: result = "QT"; break;
      case Cairo.SurfaceType.RECORDING: result = "RECORDING"; break;
      case Cairo.SurfaceType.VG: result = "VG"; break;
      case Cairo.SurfaceType.GL: result = "GL"; break;
      case Cairo.SurfaceType.DRM: result = "DRM"; break;
      case Cairo.SurfaceType.TEE: result = "TEE"; break;
      case Cairo.SurfaceType.XML: result = "XML"; break;
      case Cairo.SurfaceType.SKIA: result = "SKIA"; break;
      case Cairo.SurfaceType.SUBSURFACE: result = "SUBSURFACE"; break;
      case Cairo.SurfaceType.COGL: result = "COGL"; break;
      default: result = "???"; break;
      }

      return result;
    }
  }
}
