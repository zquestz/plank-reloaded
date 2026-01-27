//
// Copyright (C) 2025 Plank Reloaded Developers
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

#if HAVE_CLUTTER
namespace Plank {
  /**
   * Manages a Clutter actor for a single dock icon.
   *
   * This class wraps a Clutter.Actor with a Clutter.Canvas content,
   * allowing Cairo to draw the icon while the GPU handles transforms
   * (position, scale, opacity) without requiring redraws.
   *
   * The icon texture is only redrawn when content actually changes,
   * not every frame during zoom/position animations.
   *
   * Includes support for:
   * - Icon rendering with GPU-accelerated transforms
   * - Shadow rendering (separate actor below icon)
   * - Indicator rendering (separate actor for running/urgent indicators)
   * - Lighten/darken effects via texture redraw with effects applied
   */
  public class ClutterIconActor : GLib.Object {
    /**
     * The main container actor that holds icon, shadow, and indicator.
     */
    public Clutter.Actor container { get; private set; }

    /**
     * The Clutter actor for the icon itself.
     */
    public Clutter.Actor icon_actor { get; private set; }

    /**
     * The canvas for Cairo drawing of the icon.
     */
    private Clutter.Canvas icon_canvas;

    /**
     * The Clutter actor for the shadow (rendered below icon).
     */
    private Clutter.Actor? shadow_actor = null;

    /**
     * The canvas for Cairo drawing of the shadow.
     */
    private Clutter.Canvas? shadow_canvas = null;

    /**
     * The Clutter actor for indicators.
     */
    private Clutter.Actor? indicator_actor = null;

    /**
     * The canvas for Cairo drawing of indicators.
     */
    private Clutter.Canvas? indicator_canvas = null;

    /**
     * The Clutter actor for active glow (rendered behind icon, in front of shadow).
     */
    private Clutter.Actor? glow_actor = null;

    /**
     * The canvas for Cairo drawing of active glow.
     */
    private Clutter.Canvas? glow_canvas = null;

    /**
     * The dock item this actor represents.
     */
    public unowned DockItem? item { get; private set; }

    /**
     * Current texture size (base icon size, not scaled).
     */
    private int texture_size = 0;

    /**
     * Current scale factor for HiDPI.
     */
    private int scale_factor = 1;

    /**
     * Whether the icon texture needs to be redrawn.
     */
    private bool icon_texture_dirty = true;

    /**
     * Whether the shadow texture needs to be redrawn.
     */
    private bool shadow_texture_dirty = true;

    /**
     * Whether the indicator texture needs to be redrawn.
     */
    private bool indicator_texture_dirty = true;

    /**
     * Cached surface for drawing.
     */
    private Surface? cached_surface = null;

    /**
     * Last drawn icon revision (to detect changes).
     */
    private uint last_icon_revision = 0;

    /**
     * Signal handler ID for item icon changes.
     */
    private ulong icon_changed_handler_id = 0;

    /**
     * Signal handler ID for item state changes.
     */
    private ulong state_changed_handler_id = 0;

    /**
     * Signal handler ID for item indicator changes.
     */
    private ulong indicator_changed_handler_id = 0;

    /**
     * Current lighten amount (0.0 to 1.0).
     */
    private double current_lighten = 0.0;

    /**
     * Current darken amount (0.0 to 1.0).
     */
    private double current_darken = 0.0;

    /**
     * Previous lighten amount (to detect changes).
     */
    private double last_lighten = 0.0;

    /**
     * Previous darken amount (to detect changes).
     */
    private double last_darken = 0.0;

    /**
     * Current shadow size from theme.
     */
    private double current_shadow_size = 0.0;

    /**
     * Current indicator state.
     */
    private IndicatorState current_indicator_state = IndicatorState.NONE;

    /**
     * Current item state (for urgent indicator).
     */
    private ItemState current_item_state = ItemState.NORMAL;

    /**
     * Reference to the dock theme for drawing.
     */
    private unowned DockTheme? theme = null;

    /**
     * Reference to the position manager.
     */
    private unowned PositionManager? position_manager = null;

    /**
     * Reference to the render backend for buffer access.
     */
    private unowned RenderBackend? render_backend = null;

    /**
     * Dock buffer width for indicator positioning.
     */
    private int dock_buffer_width = 0;

    /**
     * Dock buffer height for indicator positioning.
     */
    private int dock_buffer_height = 0;

    /**
     * Container X position in dock coordinates (for indicator positioning).
     */
    private float container_x = 0.0f;

    /**
     * Container Y position in dock coordinates (for indicator positioning).
     */
    private float container_y = 0.0f;

    /**
     * Container scale factor (for indicator positioning during zoom).
     */
    private float container_scale = 1.0f;

    /**
     * Current glow opacity (0.0 to 1.0).
     */
    private double current_glow_opacity = 0.0;

    /**
     * Current glow color.
     */
    private Color current_glow_color;

    /**
     * Background region for glow positioning (in dock coordinates).
     */
    private Gdk.Rectangle current_background_region;

    /**
     * Background rect for glow clipping (in dock coordinates).
     */
    private Gdk.Rectangle current_background_rect;

    /**
     * Delegate for shadow drawing callback.
     */
    public delegate Surface? ShadowDrawFunc (int width, int height, Surface model, DockItem item);

    /**
     * The shadow draw callback function.
     */
    private unowned ShadowDrawFunc? shadow_draw_func = null;

    /**
     * Creates a new icon actor.
     */
    public ClutterIconActor () {
      // Create container actor to hold all sub-actors
      container = new Clutter.Actor ();

      // Create shadow actor (rendered first/below)
      shadow_actor = new Clutter.Actor ();
      shadow_canvas = new Clutter.Canvas ();
      shadow_actor.set_content (shadow_canvas);
      shadow_actor.set_content_scaling_filters (
        Clutter.ScalingFilter.TRILINEAR,
        Clutter.ScalingFilter.LINEAR
      );
      shadow_canvas.draw.connect (on_shadow_canvas_draw);
      container.add_child (shadow_actor);

      // Create glow actor (rendered after shadow, before icon)
      glow_actor = new Clutter.Actor ();
      glow_canvas = new Clutter.Canvas ();
      glow_actor.set_content (glow_canvas);
      glow_actor.set_content_scaling_filters (
        Clutter.ScalingFilter.TRILINEAR,
        Clutter.ScalingFilter.LINEAR
      );
      glow_canvas.draw.connect (on_glow_canvas_draw);
      container.add_child (glow_actor);
      glow_actor.hide ();

      // Create icon actor
      icon_actor = new Clutter.Actor ();
      icon_canvas = new Clutter.Canvas ();
      icon_actor.set_content (icon_canvas);
      icon_actor.set_content_scaling_filters (
        Clutter.ScalingFilter.TRILINEAR,
        Clutter.ScalingFilter.LINEAR
      );
      icon_canvas.draw.connect (on_icon_canvas_draw);
      container.add_child (icon_actor);

      // Create indicator actor (rendered last/on top)
      indicator_actor = new Clutter.Actor ();
      indicator_canvas = new Clutter.Canvas ();
      indicator_actor.set_content (indicator_canvas);
      indicator_actor.set_content_scaling_filters (
        Clutter.ScalingFilter.TRILINEAR,
        Clutter.ScalingFilter.LINEAR
      );
      indicator_canvas.draw.connect (on_indicator_canvas_draw);
      container.add_child (indicator_actor);

      // Pivot from top-left for simpler position calculation
      container.set_pivot_point (0.0f, 0.0f);
      icon_actor.set_pivot_point (0.0f, 0.0f);
    }

    ~ClutterIconActor () {
      disconnect_item ();

      if (icon_canvas != null) {
        icon_canvas.draw.disconnect (on_icon_canvas_draw);
      }
      if (shadow_canvas != null) {
        shadow_canvas.draw.disconnect (on_shadow_canvas_draw);
      }
      if (indicator_canvas != null) {
        indicator_canvas.draw.disconnect (on_indicator_canvas_draw);
      }
      if (glow_canvas != null) {
        glow_canvas.draw.disconnect (on_glow_canvas_draw);
      }
    }

    /**
     * Sets references needed for drawing.
     *
     * @param dock_theme the dock theme
     * @param pos_manager the position manager
     * @param backend the render backend
     * @param shadow_func the shadow draw callback function
     */
    public void set_draw_references (DockTheme dock_theme, PositionManager pos_manager,
                                      RenderBackend backend, ShadowDrawFunc? shadow_func = null) {
      theme = dock_theme;
      position_manager = pos_manager;
      render_backend = backend;
      shadow_draw_func = shadow_func;
    }

    /**
     * Binds this actor to a dock item.
     *
     * @param dock_item the item to bind to
     */
    public void bind_item (DockItem dock_item) {
      if (item == dock_item)
        return;

      disconnect_item ();

      item = dock_item;
      icon_texture_dirty = true;
      shadow_texture_dirty = true;
      indicator_texture_dirty = true;
      last_icon_revision = 0;

      // Listen for icon/state changes to mark texture dirty
      icon_changed_handler_id = item.notify["Icon"].connect (() => {
        icon_texture_dirty = true;
        shadow_texture_dirty = true;
        last_icon_revision = 0;
      });

      state_changed_handler_id = item.notify["State"].connect (() => {
        // State changes may affect indicator
        indicator_texture_dirty = true;
      });

      indicator_changed_handler_id = item.notify["Indicator"].connect (() => {
        indicator_texture_dirty = true;
      });
    }

    /**
     * Unbinds the current item.
     */
    public void unbind_item () {
      disconnect_item ();
      item = null;
      container.hide ();
    }

    /**
     * Disconnects signal handlers from the current item.
     */
    private void disconnect_item () {
      if (item != null) {
        if (icon_changed_handler_id > 0) {
          item.disconnect (icon_changed_handler_id);
          icon_changed_handler_id = 0;
        }
        if (state_changed_handler_id > 0) {
          item.disconnect (state_changed_handler_id);
          state_changed_handler_id = 0;
        }
        if (indicator_changed_handler_id > 0) {
          item.disconnect (indicator_changed_handler_id);
          indicator_changed_handler_id = 0;
        }
      }
    }

    /**
     * Ensures the texture is the correct size.
     *
     * @param size the base icon size (logical pixels)
     * @param scale the device scale factor
     * @param shadow_size the shadow size from theme
     * @return true if the texture was resized
     */
    public bool ensure_size (int size, int scale, double shadow_size = 0.0) {
      bool resized = false;

      if (texture_size != size || scale_factor != scale) {
        texture_size = size;
        scale_factor = scale;

        // Set canvas size in physical pixels
        var physical_size = size * scale;
        icon_canvas.set_size (physical_size, physical_size);

        // Set actor size in logical pixels
        icon_actor.set_size (size, size);

        icon_texture_dirty = true;
        resized = true;
      }

      // Update shadow size if changed
      if (current_shadow_size != shadow_size || resized) {
        current_shadow_size = shadow_size;

        if (shadow_size > 0 && shadow_actor != null && shadow_canvas != null) {
          // Shadow is larger than icon to accommodate blur
          var shadow_physical_size = (int) ((size + 2 * shadow_size) * scale);
          shadow_canvas.set_size (shadow_physical_size, shadow_physical_size);
          shadow_actor.set_size ((float) (size + 2 * shadow_size), (float) (size + 2 * shadow_size));
          shadow_actor.show ();
          shadow_texture_dirty = true;
        } else if (shadow_actor != null) {
          shadow_actor.hide ();
        }
      }

      return resized;
    }

    /**
     * Updates the container's position on screen.
     *
     * @param x the x position (logical pixels)
     * @param y the y position (logical pixels)
     */
    public void set_position (float x, float y) {
      container.set_position (x, y);

      // Position shadow offset (shadow is larger, needs to be offset)
      if (shadow_actor != null && current_shadow_size > 0) {
        shadow_actor.set_position ((float) (-current_shadow_size), (float) (-current_shadow_size));
      }
    }

    /**
     * Updates the container's scale (for zoom effect).
     *
     * @param scale_x horizontal scale factor
     * @param scale_y vertical scale factor
     */
    public void set_scale (double scale_x, double scale_y) {
      container.set_scale (scale_x, scale_y);
    }

    /**
     * Updates the container's opacity.
     *
     * @param opacity opacity value (0-255)
     */
    public void set_opacity (uint8 opacity) {
      container.set_opacity (opacity);
    }

    /**
     * Shows the container actor.
     */
    public void show () {
      container.show ();
    }

    /**
     * Hides the container actor.
     */
    public void hide () {
      container.hide ();
    }

    /**
     * Marks all textures as needing redraw.
     */
    public void invalidate () {
      icon_texture_dirty = true;
      shadow_texture_dirty = true;
      indicator_texture_dirty = true;
    }

    /**
     * Sets the lighten effect amount.
     *
     * @param amount lighten amount (0.0 to 1.0)
     */
    public void set_lighten (double amount) {
      current_lighten = amount;
    }

    /**
     * Sets the darken effect amount.
     *
     * @param amount darken amount (0.0 to 1.0)
     */
    public void set_darken (double amount) {
      current_darken = amount;
    }

    /**
     * Sets the indicator state for the icon.
     *
     * @param indicator_state the indicator state
     * @param item_state the item state (for urgent)
     */
    public void set_indicator_state (IndicatorState indicator_state, ItemState item_state) {
      if (current_indicator_state != indicator_state || current_item_state != item_state) {
        current_indicator_state = indicator_state;
        current_item_state = item_state;
        indicator_texture_dirty = true;
      }
    }

    /**
     * Sets the active glow state for the icon.
     *
     * @param opacity the glow opacity (0.0 to 1.0)
     * @param color the glow color
     * @param background_region the item's background region in dock coordinates
     * @param background_rect the dock's background rect for clipping
     */
    public void set_glow_state (double opacity, Color color, Gdk.Rectangle background_region, Gdk.Rectangle background_rect) {
      current_glow_opacity = opacity;
      current_glow_color = color;
      current_background_region = background_region;
      current_background_rect = background_rect;
    }

    /**
     * Updates and positions the glow actor.
     * Should be called after set_glow_state and set_position_context.
     */
    public void update_glow () {
      if (glow_actor == null || glow_canvas == null || theme == null)
        return;

      if (current_glow_opacity <= 0.0) {
        glow_actor.hide ();
        return;
      }

      // Glow is drawn in the background_region area
      var region = current_background_region;
      if (region.width <= 0 || region.height <= 0) {
        glow_actor.hide ();
        return;
      }

      // Set canvas size in physical pixels, actor size in logical pixels
      var physical_width = region.width * scale_factor;
      var physical_height = region.height * scale_factor;
      glow_canvas.set_size (physical_width, physical_height);
      glow_actor.set_size (region.width, region.height);

      // Position glow relative to container (convert from dock coords to container-local)
      // The glow should be positioned at background_region in dock coordinates
      float glow_x = (region.x - container_x) / container_scale;
      float glow_y = (region.y - container_y) / container_scale;
      glow_actor.set_position (glow_x, glow_y);

      // Counter-scale so glow doesn't zoom with icon
      var inverse_scale = 1.0f / container_scale;
      glow_actor.set_scale (inverse_scale, inverse_scale);

      // Set opacity on the actor
      glow_actor.set_opacity ((uint8) (current_glow_opacity * 255));

      // Invalidate to redraw
      glow_canvas.invalidate ();
      glow_actor.show ();
    }

    /**
     * Redraws textures if needed.
     *
     * @param model_surface surface to use as model for creating buffers
     * @param force force redraw even if not dirty
     * @return true if any texture was redrawn
     */
    public bool update_textures (Surface model_surface, bool force = false) {
      if (item == null)
        return false;

      bool any_redrawn = false;

      // Check if icon has changed via its revision counter
      var current_revision = item.get_data<uint> ("icon-revision");
      if (current_revision != last_icon_revision) {
        icon_texture_dirty = true;
        shadow_texture_dirty = true;
        last_icon_revision = current_revision;
      }

      // Check if lighten/darken changed (requires icon redraw)
      const double EFFECT_THRESHOLD = 0.01;
      bool lighten_changed = (current_lighten > EFFECT_THRESHOLD) != (last_lighten > EFFECT_THRESHOLD) ||
                              (current_lighten > EFFECT_THRESHOLD && Math.fabs (current_lighten - last_lighten) > EFFECT_THRESHOLD);
      bool darken_changed = (current_darken > EFFECT_THRESHOLD) != (last_darken > EFFECT_THRESHOLD) ||
                             (current_darken > EFFECT_THRESHOLD && Math.fabs (current_darken - last_darken) > EFFECT_THRESHOLD);

      if (lighten_changed || darken_changed) {
        icon_texture_dirty = true;
        last_lighten = current_lighten;
        last_darken = current_darken;
      }

      // Update icon texture
      if (icon_texture_dirty || force) {
        icon_texture_dirty = false;
        icon_canvas.invalidate ();
        any_redrawn = true;
      }

      // Update shadow texture
      if ((shadow_texture_dirty || force) && current_shadow_size > 0) {
        shadow_texture_dirty = false;
        if (shadow_canvas != null) {
          shadow_canvas.invalidate ();
        }
        any_redrawn = true;
      }

      // Update indicator texture
      if (indicator_texture_dirty || force) {
        indicator_texture_dirty = false;
        if (indicator_canvas != null && current_indicator_state != IndicatorState.NONE) {
          indicator_canvas.invalidate ();
          if (indicator_actor != null) {
            indicator_actor.show ();
          }
        } else if (indicator_actor != null) {
          indicator_actor.hide ();
        }
        any_redrawn = true;
      }

      return any_redrawn;
    }

    /**
     * Sets the positioning context needed for indicator placement.
     * This must be called before position_indicator() to provide dock buffer
     * dimensions, container position, and scale factor.
     *
     * @param buffer_width the dock buffer width
     * @param buffer_height the dock buffer height
     * @param cont_x the container's X position in dock coordinates
     * @param cont_y the container's Y position in dock coordinates
     * @param scale the container's scale factor (for zoom)
     */
    public void set_position_context (int buffer_width, int buffer_height, float cont_x, float cont_y, float scale) {
      this.dock_buffer_width = buffer_width;
      this.dock_buffer_height = buffer_height;
      this.container_x = cont_x;
      this.container_y = cont_y;
      this.container_scale = scale;
    }

    /**
     * Positions the indicator actor relative to the icon container.
     * The indicator is positioned at the dock edge (matching Cairo path behavior).
     */
    public void position_indicator () {
      if (indicator_actor == null || theme == null || position_manager == null || render_backend == null)
        return;

      if (current_indicator_state == IndicatorState.NONE || theme.IndicatorSize <= 0) {
        indicator_actor.hide ();
        return;
      }

      // Get the cached indicator surface from backend - use its actual dimensions
      // This ensures we match the Cairo path exactly
      unowned Surface? indicator_surface = render_backend.get_indicator_buffer (
        current_indicator_state, current_item_state,
        position_manager.IconSize, position_manager.Position,
        theme, render_backend.get_item_buffer ());

      if (indicator_surface == null) {
        indicator_actor.hide ();
        return;
      }

      // Use the actual surface dimensions (already accounts for rotation)
      // Surface is in LOGICAL pixels (created with icon_size which is logical)
      var ind_width = indicator_surface.Width;
      var ind_height = indicator_surface.Height;

      // Set indicator canvas size in physical pixels, actor size in logical pixels
      // Canvas needs physical pixels for HiDPI, actor uses logical for positioning
      indicator_canvas.set_size (ind_width * scale_factor, ind_height * scale_factor);
      indicator_actor.set_size (ind_width, ind_height);

      // Invalidate the canvas to trigger a redraw
      indicator_canvas.invalidate ();

      // Calculate position relative to the container (icon is at 0,0 in container)
      // We position in base icon coordinates - the container scale will handle zoom
      // The indicator actor is NOT counter-scaled, so it zooms with the icon
      //
      // IMPORTANT: Unlike simple icon-relative positioning, we match the Cairo path
      // behavior where indicators are at a fixed position relative to the DOCK EDGE,
      // not relative to the icon. This requires knowing the dock buffer dimensions
      // and the container's position in dock coordinates.
      float x = 0.0f, y = 0.0f;
      var icon_size = (float) texture_size;

      // Get the bottom offset from theme (padding from dock edge)
      var bottom_offset = (float) theme.get_bottom_offset ();

      // Indicator dimensions in logical pixels (surface is already logical)
      var indicator_width = (float) ind_width;
      var indicator_height = (float) ind_height;

      // To match Cairo path behavior exactly:
      // 1. Indicator should be at a FIXED dock edge position (doesn't move with zoom)
      // 2. Indicator should be centered on the zoomed icon's center
      // 3. Indicator should NOT zoom in size (Cairo draws it at fixed size)
      //
      // Since indicator is a child of the scaled container:
      // - We counter-scale the indicator actor (1/scale) so it doesn't grow
      // - We calculate position in dock coords, then convert to local coords
      //
      // For position: final_dock_pos = container_pos + local_pos * container_scale
      // We want specific dock positions, so: local_pos = (target_dock_pos - container_pos) / container_scale
      //
      // For the centering axis (y for LEFT/RIGHT, x for TOP/BOTTOM):
      // Cairo uses item_rect (hover_region) center. The container is already at the
      // zoomed icon position, so we center on the scaled icon size / 2.

      // Calculate the zoomed icon size (what the icon visually appears as)
      var zoomed_icon_size = icon_size * container_scale;

      switch (position_manager.Position) {
      default:
      case Gtk.PositionType.BOTTOM:
        // Cairo: x = item_rect.x + item_rect.width / 2.0 - indicator_width / 2.0
        // Center horizontally on zoomed icon center
        x = (zoomed_icon_size / 2.0f - indicator_width / 2.0f) / container_scale;
        // Cairo: y = item_buffer.Height - bottom_offset - indicator_height (fixed dock edge)
        var absolute_y_bottom = (float) dock_buffer_height - bottom_offset - indicator_height;
        y = (absolute_y_bottom - container_y) / container_scale;
        break;
      case Gtk.PositionType.TOP:
        // Center horizontally on zoomed icon center
        x = (zoomed_icon_size / 2.0f - indicator_width / 2.0f) / container_scale;
        // Cairo: y = bottom_offset (fixed dock edge)
        y = (bottom_offset - container_y) / container_scale;
        break;
      case Gtk.PositionType.LEFT:
        // Cairo: x = bottom_offset (fixed dock edge)
        x = (bottom_offset - container_x) / container_scale;
        // Center vertically on zoomed icon center
        y = (zoomed_icon_size / 2.0f - indicator_height / 2.0f) / container_scale;
        break;
      case Gtk.PositionType.RIGHT:
        // Cairo: x = item_buffer.Width - bottom_offset - indicator_width (fixed dock edge)
        var absolute_x_right = (float) dock_buffer_width - bottom_offset - indicator_width;
        x = (absolute_x_right - container_x) / container_scale;
        // Center vertically on zoomed icon center
        y = (zoomed_icon_size / 2.0f - indicator_height / 2.0f) / container_scale;
        break;
      }

      indicator_actor.set_position (x, y);

      // Counter-scale the indicator so it maintains fixed size regardless of zoom
      // This matches Cairo behavior where indicator is drawn at a fixed size
      var inverse_scale = 1.0f / container_scale;
      indicator_actor.set_scale (inverse_scale, inverse_scale);

      indicator_actor.show ();

      // Calculate final dock coordinates for debugging
      var final_dock_x = container_x + x * container_scale;
      var final_dock_y = container_y + y * container_scale;

      Logger.verbose ("position_indicator: pos=%d, local=(%.1f, %.1f), dock=(%.1f, %.1f), container=(%.1f, %.1f), scale=%.2f, buffer=%dx%d, icon_size=%.0f, indicator=%dx%d, bottom_offset=%.0f",
                      position_manager.Position, x, y, final_dock_x, final_dock_y,
                      container_x, container_y, container_scale,
                      dock_buffer_width, dock_buffer_height,
                      icon_size, (int) indicator_width, (int) indicator_height, bottom_offset);
    }

    /**
     * Icon canvas draw callback.
     */
    private bool on_icon_canvas_draw (Cairo.Context cr, int width, int height) {
      // Clear the canvas
      cr.set_operator (Cairo.Operator.CLEAR);
      cr.paint ();
      cr.set_operator (Cairo.Operator.OVER);

      if (item == null || texture_size <= 0)
        return true;

      // Canvas is sized in physical pixels (texture_size * scale_factor)
      var physical_size = texture_size * scale_factor;

      // Create a temporary model surface if we don't have a cached one
      if (cached_surface == null || cached_surface.Width != physical_size) {
        var image = new Cairo.ImageSurface (Cairo.Format.ARGB32, physical_size, physical_size);
        cached_surface = new Surface.with_internal (image);
      }

      // Get icon surface at physical pixel size from the item's cache
      var icon_surface = item.get_surface (physical_size, physical_size, cached_surface);

      // Apply lighten/darken effects if needed
      const double EFFECT_THRESHOLD = 0.01;
      bool has_lighten = current_lighten > EFFECT_THRESHOLD;
      bool has_darken = current_darken > EFFECT_THRESHOLD;

      if (has_lighten || has_darken) {
        // Need to draw to a temporary surface to apply effects
        cr.set_source_surface (icon_surface.Internal, 0, 0);
        cr.paint ();

        // Apply lighten effect
        if (has_lighten) {
          cr.set_source_surface (icon_surface.Internal, 0, 0);
          cr.set_operator (Cairo.Operator.ADD);
          cr.paint_with_alpha (current_lighten);
          cr.set_operator (Cairo.Operator.OVER);
        }

        // Apply darken effect
        if (has_darken) {
          cr.rectangle (0, 0, width, height);
          cr.set_source_rgba (0, 0, 0, current_darken);
          cr.set_operator (Cairo.Operator.ATOP);
          cr.fill ();
          cr.set_operator (Cairo.Operator.OVER);
        }
      } else {
        // No effects - draw icon directly
        cr.set_source_surface (icon_surface.Internal, 0, 0);
        cr.paint ();
      }

      // Draw foreground overlay (count badge, progress) if visible
      if (item.CountVisible || item.ProgressVisible) {
        var overlay_surface = item.get_foreground_surface (physical_size, physical_size, cached_surface, null);
        if (overlay_surface != null) {
          cr.set_source_surface (overlay_surface.Internal, 0, 0);
          cr.paint ();
        }
      }

      return true;
    }

    /**
     * Shadow canvas draw callback.
     */
    private bool on_shadow_canvas_draw (Cairo.Context cr, int width, int height) {
      // Clear the canvas
      cr.set_operator (Cairo.Operator.CLEAR);
      cr.paint ();
      cr.set_operator (Cairo.Operator.OVER);

      if (item == null || texture_size <= 0 || current_shadow_size <= 0)
        return true;

      if (theme == null || render_backend == null)
        return true;

      // Shadow size in physical pixels
      var shadow_physical_size = (int) ((texture_size + 2 * current_shadow_size) * scale_factor);

      // Create model surface for shadow
      if (cached_surface == null || cached_surface.Width < shadow_physical_size) {
        var image = new Cairo.ImageSurface (Cairo.Format.ARGB32, shadow_physical_size, shadow_physical_size);
        cached_surface = new Surface.with_internal (image);
      }

      // Get shadow surface from item's background cache
      // Uses the shadow draw callback if provided
      Surface? icon_shadow_surface = null;
      if (shadow_draw_func != null) {
        icon_shadow_surface = shadow_draw_func (shadow_physical_size, shadow_physical_size, cached_surface, item);
      } else {
        icon_shadow_surface = item.get_background_surface (
          shadow_physical_size, shadow_physical_size,
          cached_surface, null);
      }

      if (icon_shadow_surface != null) {
        cr.set_source_surface (icon_shadow_surface.Internal, 0, 0);
        cr.paint ();
      }

      return true;
    }

    /**
     * Indicator canvas draw callback.
     * Uses the backend's cached indicator surface for pixel-perfect match with Cairo path.
     */
    private bool on_indicator_canvas_draw (Cairo.Context cr, int width, int height) {
      // Clear the canvas
      cr.set_operator (Cairo.Operator.CLEAR);
      cr.paint ();
      cr.set_operator (Cairo.Operator.OVER);

      if (current_indicator_state == IndicatorState.NONE)
        return true;

      if (theme == null || position_manager == null || render_backend == null)
        return true;

      // Get the cached indicator surface from backend - this is the same surface
      // used by the Cairo path, ensuring pixel-perfect match
      unowned Surface? indicator_surface = render_backend.get_indicator_buffer (
        current_indicator_state, current_item_state,
        position_manager.IconSize, position_manager.Position,
        theme, render_backend.get_item_buffer ());

      if (indicator_surface == null)
        return true;

      // The canvas is in physical pixels, but the surface is in logical pixels.
      // Scale the context to match HiDPI.
      cr.scale (scale_factor, scale_factor);

      // Paint the cached surface directly to our canvas
      cr.set_source_surface (indicator_surface.Internal, 0, 0);
      cr.paint ();

      return true;
    }

    /**
     * Glow canvas draw callback.
     * Draws the active glow effect behind the icon.
     */
    private bool on_glow_canvas_draw (Cairo.Context cr, int width, int height) {
      // Clear the canvas
      cr.set_operator (Cairo.Operator.CLEAR);
      cr.paint ();
      cr.set_operator (Cairo.Operator.OVER);

      if (current_glow_opacity <= 0.0)
        return true;

      if (theme == null || position_manager == null)
        return true;

      var region = current_background_region;
      if (region.width <= 0 || region.height <= 0)
        return true;

      // The canvas is sized to the background_region, so draw at 0,0
      // We need to draw the glow pattern that would normally be drawn by theme.draw_active_glow

      var color = current_glow_color;
      Cairo.Pattern gradient = null;

      // Create gradient based on active item style and dock position
      if (theme.ActiveItemStyle == ActiveItemStyleType.CENTER_GRADIENT ||
          theme.ActiveItemStyle == ActiveItemStyleType.COLOR_CENTER_GRADIENT) {
        // Radial gradient from center
        var center_x = width / 2.0;
        var center_y = height / 2.0;
        var radius = double.max (width, height) / 2.0;

        gradient = new Cairo.Pattern.radial (center_x, center_y, 0, center_x, center_y, radius);
        gradient.add_color_stop_rgba (0, color.red, color.green, color.blue, 0.6);
        gradient.add_color_stop_rgba (1, color.red, color.green, color.blue, 0);
      } else {
        // Linear gradient based on dock position
        switch (position_manager.Position) {
        default:
        case Gtk.PositionType.BOTTOM:
          gradient = new Cairo.Pattern.linear (0, 0, 0, height);
          break;
        case Gtk.PositionType.TOP:
          gradient = new Cairo.Pattern.linear (0, height, 0, 0);
          break;
        case Gtk.PositionType.LEFT:
          gradient = new Cairo.Pattern.linear (width, 0, 0, 0);
          break;
        case Gtk.PositionType.RIGHT:
          gradient = new Cairo.Pattern.linear (0, 0, width, 0);
          break;
        }
        gradient.add_color_stop_rgba (0, color.red, color.green, color.blue, 0);
        gradient.add_color_stop_rgba (0.5, color.red, color.green, color.blue, 0.4);
        gradient.add_color_stop_rgba (1, color.red, color.green, color.blue, 0);
      }

      cr.rectangle (0, 0, width, height);
      cr.set_source (gradient);
      cr.fill ();

      return true;
    }
  }
}
#endif
