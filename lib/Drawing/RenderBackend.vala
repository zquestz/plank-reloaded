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

namespace Plank {
  /**
   * Abstract base class for dock rendering backends.
   *
   * This class defines the interface for rendering the dock, allowing
   * different implementations for CPU (Cairo) and GPU (Clutter) rendering.
   * The backend primarily manages buffers and compositing, while the actual
   * drawing logic remains in DockRenderer.
   *
   * Architecture overview:
   * - DockRenderer HAS-A RenderBackend (composition pattern)
   * - RenderBackend.create() is a factory method for runtime backend selection
   * - CairoBackend: CPU rendering, works everywhere
   * - ClutterBackend: GPU rendering via Clutter.Canvas (hybrid Cairo+GPU approach)
   *
   * The Clutter backend uses Cairo for drawing (reusing existing code) but
   * uploads the result to GPU textures for hardware-accelerated compositing.
   *
   * Common buffer management is implemented in this base class to avoid
   * code duplication between backends. Subclasses can override methods
   * to add backend-specific behavior.
   */
  public abstract class RenderBackend : GLib.Object {
    /**
     * The dock controller this backend renders for.
     */
    public unowned DockController controller { get; construct; }

    /**
     * Whether this backend supports blur effects.
     */
    public virtual bool supports_blur { get { return false; } }

    /**
     * The current window scale factor.
     */
    public int window_scale_factor { get; protected set; default = 1; }

    // Common Surface buffers for compositing
    protected Surface? main_buffer = null;
    protected Surface? fade_buffer = null;
    protected Surface? item_buffer = null;
    protected Surface? shadow_buffer = null;
    protected Surface? background_buffer = null;

    // Indicator buffers
    protected Surface[] indicator_buffer = new Surface[2];
    protected Surface[] urgent_indicator_buffer = new Surface[2];
    protected Surface? urgent_glow_buffer = null;

    // Frame state (used internally for buffer management)
    protected double current_opacity = 1.0;

    /**
     * Creates a new render backend.
     *
     * @param controller the dock controller to render for
     */
    protected RenderBackend (DockController controller) {
      Object (controller: controller);
    }

    /**
     * Resets all internal buffers and caches.
     * Subclasses should override and call base to add their own cleanup.
     */
    public virtual void reset_buffers () {
      main_buffer = null;
      fade_buffer = null;
      item_buffer = null;
      shadow_buffer = null;
      background_buffer = null;

      indicator_buffer[0] = null;
      indicator_buffer[1] = null;
      urgent_indicator_buffer[0] = null;
      urgent_indicator_buffer[1] = null;
      urgent_glow_buffer = null;
    }

    /**
     * Called at the start of each frame to prepare for drawing.
     *
     * @param frame_time the current frame timestamp
     * @param hide_progress the current hide animation progress (0.0 to 1.0)
     * @param opacity the current dock opacity
     * @param zoom_in_progress the current zoom animation progress
     */
    public virtual void begin_frame (int64 frame_time, double hide_progress,
                                      double opacity, double zoom_in_progress) {
      current_opacity = opacity;
    }

    /**
     * Called at the end of each frame to finalize drawing.
     */
    public virtual void end_frame () {
      // Nothing to do by default - subclasses can override
    }

    /**
     * Ensures all buffers are allocated and sized correctly.
     *
     * @param width the buffer width
     * @param height the buffer height
     * @param target the Cairo surface to base buffers on
     */
    public virtual void ensure_buffers (int width, int height, Cairo.Surface target) {
      if (main_buffer == null || main_buffer.Width != width || main_buffer.Height != height) {
        main_buffer = new Surface.with_cairo_surface (width, height, target);
        main_buffer.Internal.set_device_scale (window_scale_factor, window_scale_factor);
      }

      if (item_buffer == null || item_buffer.Width != width || item_buffer.Height != height) {
        item_buffer = new Surface.with_cairo_surface (width, height, target);
        item_buffer.Internal.set_device_scale (window_scale_factor, window_scale_factor);
      }

      if (shadow_buffer == null || shadow_buffer.Width != width || shadow_buffer.Height != height) {
        shadow_buffer = new Surface.with_cairo_surface (width, height, target);
        shadow_buffer.Internal.set_device_scale (window_scale_factor, window_scale_factor);
      }
    }

    /**
     * Gets the main buffer for compositing.
     *
     * @return the main surface buffer
     */
    public virtual unowned Surface? get_main_buffer () {
      return main_buffer;
    }

    /**
     * Gets the item buffer for drawing dock items.
     *
     * @return the item surface buffer
     */
    public virtual unowned Surface? get_item_buffer () {
      return item_buffer;
    }

    /**
     * Gets the shadow buffer for drawing item shadows.
     *
     * @return the shadow surface buffer
     */
    public virtual unowned Surface? get_shadow_buffer () {
      return shadow_buffer;
    }

    /**
     * Gets the fade buffer for opacity transitions.
     *
     * @return the fade surface buffer
     */
    public virtual unowned Surface? get_fade_buffer () {
      return fade_buffer;
    }

    /**
     * Gets or creates the background buffer.
     *
     * @param width the required width
     * @param height the required height
     * @param theme the dock theme
     * @param position the dock position
     * @param model the surface to base the buffer on
     * @return the background surface buffer
     */
    public virtual unowned Surface? get_background_buffer (int width, int height, DockTheme theme,
                                                            Gtk.PositionType position, Surface model) {
      if (width <= 0 || height <= 0) {
        background_buffer = null;
        return null;
      }

      if (background_buffer == null || background_buffer.Width != width
          || background_buffer.Height != height) {
        background_buffer = theme.create_background (width, height, position, model);
      }

      return background_buffer;
    }

    /**
     * Gets or creates an indicator buffer.
     *
     * @param indicator_state the indicator state
     * @param item_state the item state
     * @param icon_size the icon size
     * @param position the dock position
     * @param theme the dock theme
     * @param model the surface to base the buffer on
     * @return the indicator surface
     */
    public virtual unowned Surface? get_indicator_buffer (IndicatorState indicator_state, ItemState item_state,
                                                           int icon_size, Gtk.PositionType position,
                                                           DockTheme theme, Surface model) {
      var index = indicator_state - 1;

      // Bounds check for safety
      if (index < 0 || index >= indicator_buffer.length) {
        return null;
      }

      if ((item_state & ItemState.URGENT) == 0) {
        if (indicator_buffer[index] == null) {
          indicator_buffer[index] = theme.create_indicator_for_state (indicator_state, ItemState.NORMAL,
                                                                       icon_size, position, model);
        }
        return indicator_buffer[index];
      } else {
        if (urgent_indicator_buffer[index] == null) {
          urgent_indicator_buffer[index] = theme.create_indicator_for_state (indicator_state, ItemState.URGENT,
                                                                              icon_size, position, model);
        }
        return urgent_indicator_buffer[index];
      }
    }

    /**
     * Gets or creates the urgent glow buffer.
     *
     * @param glow_size the glow size
     * @param theme the dock theme
     * @param model the surface to base the buffer on
     * @return the urgent glow surface
     */
    public virtual unowned Surface? get_urgent_glow_buffer (int glow_size, DockTheme theme, Surface model) {
      if (urgent_glow_buffer == null) {
        var urgent_color = (theme.IndicatorStyle == IndicatorStyleType.LEGACY
                            ? theme.get_styled_color () : theme.IndicatorColor);
        urgent_color.add_hue (theme.UrgentHueShift);
        urgent_color.set_sat (1.0);
        urgent_glow_buffer = theme.create_urgent_glow (glow_size, urgent_color, model);
      }
      return urgent_glow_buffer;
    }

    /**
     * Updates the window scale factor.
     *
     * @param widget the widget to get scale factor from
     */
    public virtual void update_scale_factor (Gtk.Widget widget) {
      if (widget.get_realized ()) {
        window_scale_factor = widget.get_window ().get_scale_factor ();
      }
    }

    /**
     * Factory method to create the appropriate backend.
     *
     * Selection logic:
     * 1. If Clutter is compiled in and prefer_gpu is true, try ClutterBackend
     * 2. If Clutter initialization fails or is unavailable, fall back to CairoBackend
     * 3. CairoBackend always works as the reliable fallback
     *
     * @param controller the dock controller
     * @param prefer_gpu whether to prefer GPU rendering if available
     * @return a new render backend instance
     */
    public static RenderBackend create (DockController controller, bool prefer_gpu = true) {
#if HAVE_CLUTTER
      if (prefer_gpu && ClutterBackend.is_available ()) {
        return new ClutterBackend (controller);
      }
#endif
      return new CairoBackend (controller);
    }
  }
}
