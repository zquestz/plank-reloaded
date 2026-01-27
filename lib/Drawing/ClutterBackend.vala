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

#if HAVE_CLUTTER
namespace Plank {
  /**
   * Clutter-based GPU rendering backend for the dock.
   *
   * This backend uses Clutter for hardware-accelerated rendering,
   * offloading compositing operations to the GPU. Cairo is used for
   * drawing content to a Clutter.Canvas, which is then composited
   * by the GPU.
   *
   * Architecture notes:
   * - DockWindow owns the GtkClutter.Embed widget and Clutter stage/canvas
   * - ClutterBackend manages Cairo buffer caching for the Clutter draw path
   * - DockRenderer coordinates drawing between the two
   *
   * Rendering modes:
   * 1. Canvas mode (default): Cairo draws all icons to a single canvas,
   *    GPU uploads and displays. Simple but redraws everything each frame.
   * 2. Actor mode: Each icon has its own Clutter.Actor with a texture.
   *    GPU handles position/scale/opacity transforms without redrawing.
   *    Only redraws when icon content actually changes.
   *
   * Common buffer management is inherited from the base RenderBackend class.
   * This class adds Clutter-specific ImageSurface caching for the canvas
   * draw path, since Clutter canvas surfaces don't work well with
   * Cairo.Surface.similar().
   */
  public class ClutterBackend : RenderBackend {
    /**
     * Whether Clutter has been successfully initialized.
     */
    private static bool clutter_initialized = false;

    /**
     * Whether Clutter initialization has been attempted.
     */
    private static bool init_attempted = false;

    // Cached ImageSurfaces for Clutter canvas drawing (to avoid per-frame allocation)
    // These are separate from the inherited Surface buffers because Clutter canvas
    // surfaces don't work well with Cairo.Surface.similar()
    private Cairo.ImageSurface? clutter_main_surface = null;
    private Cairo.ImageSurface? clutter_item_surface = null;
    private Cairo.ImageSurface? clutter_shadow_surface = null;
    private Cairo.ImageSurface? clutter_fade_surface = null;
    private Cairo.ImageSurface? clutter_model_surface = null;
    private Surface? clutter_model = null;

    // Cached Cairo.Context objects for clearing surfaces (to avoid per-frame allocation)
    private Cairo.Context? clutter_main_cr = null;
    private Cairo.Context? clutter_item_cr = null;
    private Cairo.Context? clutter_shadow_cr = null;

    // Cached Cairo.Context objects for drawing (separate from clearing contexts)
    // These are provided to draw_to_context to avoid per-frame allocation
    private Cairo.Context? draw_main_cr = null;
    private Cairo.Context? draw_item_cr = null;
    private Cairo.Context? draw_shadow_cr = null;

    private int clutter_surface_width = 0;
    private int clutter_surface_height = 0;

    // Per-icon actor management
    private Gee.HashMap<DockItem, ClutterIconActor>? icon_actors = null;
    private Gee.ArrayList<ClutterIconActor>? actor_pool = null;

    /**
     * Whether per-icon actor mode is enabled.
     * When true, each icon gets its own Clutter.Actor for GPU transforms.
     */
    public bool actor_mode_enabled { get; private set; default = false; }

    /**
     * The container actor that holds all icon actors.
     */
    public Clutter.Actor? icon_container { get; private set; default = null; }

    /**
     * The background actor for the dock background.
     */
    public Clutter.Actor? background_actor { get; private set; default = null; }

    /**
     * Canvas for drawing the dock background.
     */
    private Clutter.Canvas? background_canvas = null;

    /**
     * The shadow actor for icon shadows.
     */
    public Clutter.Actor? shadow_actor { get; private set; default = null; }

    /**
     * Canvas for drawing shadows.
     */
    private Clutter.Canvas? shadow_canvas = null;

    /**
     * Actor for urgent glow (shown even when dock is hidden).
     */
    public Clutter.Actor? urgent_glow_actor { get; private set; default = null; }

    /**
     * Canvas for drawing urgent glow.
     */
    private Clutter.Canvas? urgent_glow_canvas = null;

    /**
     * Delegate for urgent glow drawing.
     */
    public delegate void UrgentGlowDrawFunc (Cairo.Context cr, int width, int height);

    /**
     * The urgent glow draw callback function.
     */
    private unowned UrgentGlowDrawFunc? urgent_glow_draw_func = null;

    /**
     * Whether urgent glow draw callback is connected.
     */
    private bool urgent_glow_draw_connected = false;

    /**
     * Creates a new Clutter rendering backend.
     *
     * @param controller the dock controller to render for
     */
    public ClutterBackend (DockController controller) {
      base (controller);
    }

    construct {
      Logger.verbose ("ClutterBackend.construct ()");
      icon_actors = new Gee.HashMap<DockItem, ClutterIconActor> ();
      actor_pool = new Gee.ArrayList<ClutterIconActor> ();
    }

    ~ClutterBackend () {
      // Clean up actor mode resources
      cleanup_actor_mode ();

      // Clear cached Clutter surfaces and contexts
      clutter_main_cr = null;
      clutter_item_cr = null;
      clutter_shadow_cr = null;
      draw_main_cr = null;
      draw_item_cr = null;
      draw_shadow_cr = null;
      clutter_main_surface = null;
      clutter_item_surface = null;
      clutter_shadow_surface = null;
      clutter_fade_surface = null;
      clutter_model_surface = null;
      clutter_model = null;
      clutter_surface_width = 0;
      clutter_surface_height = 0;
    }

    /**
     * Attempts to initialize Clutter.
     *
     * @return true if Clutter is available and initialized
     */
    public static bool initialize () {
      if (init_attempted) {
        return clutter_initialized;
      }

      init_attempted = true;

      // Initialize Clutter-GTK
      unowned string[]? args = null;
      var result = GtkClutter.init (ref args);

      clutter_initialized = (result == Clutter.InitError.SUCCESS);

      return clutter_initialized;
    }

    /**
     * Checks if Clutter GPU rendering is available.
     *
     * @return true if Clutter can be used for rendering
     */
    public static bool is_available () {
      return initialize ();
    }

    /**
     * Gets or creates cached ImageSurfaces for Clutter canvas drawing.
     * This avoids allocating new surfaces every frame, significantly reducing
     * memory churn and GC pressure.
     *
     * @param width the required surface width (logical pixels)
     * @param height the required surface height (logical pixels)
     * @param scale_factor the device scale factor for HiDPI support
     * @param main_surface output parameter for main compositing surface
     * @param item_surface output parameter for item drawing surface
     * @param shadow_surface output parameter for shadow drawing surface
     */
    public void get_clutter_surfaces (int width, int height, int scale_factor,
                                       out unowned Cairo.ImageSurface main_surface,
                                       out unowned Cairo.ImageSurface item_surface,
                                       out unowned Cairo.ImageSurface shadow_surface) {
      // Calculate physical pixel dimensions for HiDPI support
      var physical_width = width * scale_factor;
      var physical_height = height * scale_factor;

      // Reallocate if size or scale changed
      if (clutter_surface_width != physical_width || clutter_surface_height != physical_height) {
        // Create surfaces at physical pixel dimensions for full HiDPI resolution
        clutter_main_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, physical_width, physical_height);
        clutter_item_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, physical_width, physical_height);
        clutter_shadow_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, physical_width, physical_height);
        clutter_fade_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, physical_width, physical_height);
        clutter_model_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, physical_width, physical_height);
        clutter_model = new Surface.with_internal (clutter_model_surface);

        // Set device scale so Cairo interprets coordinates in logical pixels
        clutter_main_surface.set_device_scale (scale_factor, scale_factor);
        clutter_item_surface.set_device_scale (scale_factor, scale_factor);
        clutter_shadow_surface.set_device_scale (scale_factor, scale_factor);
        clutter_fade_surface.set_device_scale (scale_factor, scale_factor);
        clutter_model_surface.set_device_scale (scale_factor, scale_factor);

        // Create cached contexts for clearing surfaces
        clutter_main_cr = new Cairo.Context (clutter_main_surface);
        clutter_item_cr = new Cairo.Context (clutter_item_surface);
        clutter_shadow_cr = new Cairo.Context (clutter_shadow_surface);

        // Create cached contexts for drawing (separate from clearing)
        draw_main_cr = new Cairo.Context (clutter_main_surface);
        draw_item_cr = new Cairo.Context (clutter_item_surface);
        draw_shadow_cr = new Cairo.Context (clutter_shadow_surface);

        clutter_surface_width = physical_width;
        clutter_surface_height = physical_height;

        Logger.verbose ("ClutterBackend: Allocated cached surfaces %dx%d (physical), scale=%d",
                        physical_width, physical_height, scale_factor);
      }

      main_surface = clutter_main_surface;
      item_surface = clutter_item_surface;
      shadow_surface = clutter_shadow_surface;
    }

    /**
     * Gets cached Cairo.Context objects for drawing to the Clutter surfaces.
     * This avoids allocating new contexts every frame, reducing GC pressure.
     *
     * @param main_cr output parameter for main surface context
     * @param item_cr output parameter for item surface context
     * @param shadow_cr output parameter for shadow surface context
     */
    public void get_draw_contexts (out unowned Cairo.Context? main_cr,
                                    out unowned Cairo.Context? item_cr,
                                    out unowned Cairo.Context? shadow_cr) {
      main_cr = draw_main_cr;
      item_cr = draw_item_cr;
      shadow_cr = draw_shadow_cr;
    }

    /**
     * Gets the cached fade surface for opacity transitions.
     *
     * @return the fade surface, or null if surfaces haven't been allocated
     */
    public unowned Cairo.ImageSurface? get_clutter_fade_surface () {
      return clutter_fade_surface;
    }

    /**
     * Gets the cached model surface for buffer creation.
     * This avoids creating a new Surface object every frame.
     *
     * @return the model Surface, or null if surfaces haven't been allocated
     */
    public unowned Surface? get_model_surface () {
      return clutter_model;
    }

    /**
     * Clears all cached Clutter surfaces (fills with transparent).
     * Call this at the start of each frame before drawing.
     * Uses cached Cairo.Context objects to avoid per-frame allocation.
     */
    public void clear_clutter_surfaces () {
      if (clutter_main_cr != null) {
        clutter_main_cr.set_operator (Cairo.Operator.CLEAR);
        clutter_main_cr.paint ();
      }
      if (clutter_item_cr != null) {
        clutter_item_cr.set_operator (Cairo.Operator.CLEAR);
        clutter_item_cr.paint ();
      }
      if (clutter_shadow_cr != null) {
        clutter_shadow_cr.set_operator (Cairo.Operator.CLEAR);
        clutter_shadow_cr.paint ();
      }
    }

    /**
     * {@inheritDoc}
     */
    public override void reset_buffers () {
      Logger.verbose ("ClutterBackend.reset_buffers ()");

      // Reset inherited Surface buffers
      base.reset_buffers ();

      // Also clear Clutter-specific surfaces and contexts to force recreation
      clutter_main_cr = null;
      clutter_item_cr = null;
      clutter_shadow_cr = null;
      draw_main_cr = null;
      draw_item_cr = null;
      draw_shadow_cr = null;
      clutter_main_surface = null;
      clutter_item_surface = null;
      clutter_shadow_surface = null;
      clutter_fade_surface = null;
      clutter_model_surface = null;
      clutter_model = null;
      clutter_surface_width = 0;
      clutter_surface_height = 0;

      // Invalidate all icon actor textures
      if (icon_actors != null) {
        foreach (var actor in icon_actors.values) {
          actor.invalidate ();
        }
      }
    }

    /**
     * Enables per-icon actor mode for GPU-accelerated transforms.
     *
     * @param stage the Clutter stage to add actors to
     */
    public void enable_actor_mode (Clutter.Actor stage) {
      if (actor_mode_enabled)
        return;

      Logger.verbose ("ClutterBackend: Enabling per-icon actor mode");

      // Create background actor
      background_actor = new Clutter.Actor ();
      background_canvas = new Clutter.Canvas ();
      background_actor.set_content (background_canvas);
      background_actor.set_content_scaling_filters (
        Clutter.ScalingFilter.TRILINEAR,
        Clutter.ScalingFilter.LINEAR
      );
      stage.add_child (background_actor);

      // Create shadow actor (renders below icons)
      shadow_actor = new Clutter.Actor ();
      shadow_canvas = new Clutter.Canvas ();
      shadow_actor.set_content (shadow_canvas);
      shadow_actor.set_content_scaling_filters (
        Clutter.ScalingFilter.TRILINEAR,
        Clutter.ScalingFilter.LINEAR
      );
      stage.add_child (shadow_actor);

      // Create container for icon actors
      icon_container = new Clutter.Actor ();
      stage.add_child (icon_container);

      // Create urgent glow actor (rendered on top, visible when dock hidden)
      urgent_glow_actor = new Clutter.Actor ();
      urgent_glow_canvas = new Clutter.Canvas ();
      urgent_glow_actor.set_content (urgent_glow_canvas);
      urgent_glow_actor.set_content_scaling_filters (
        Clutter.ScalingFilter.TRILINEAR,
        Clutter.ScalingFilter.LINEAR
      );
      stage.add_child (urgent_glow_actor);
      urgent_glow_actor.hide ();

      actor_mode_enabled = true;
    }

    /**
     * Disables per-icon actor mode and cleans up resources.
     */
    public void disable_actor_mode () {
      if (!actor_mode_enabled)
        return;

      Logger.verbose ("ClutterBackend: Disabling per-icon actor mode");
      cleanup_actor_mode ();
      actor_mode_enabled = false;
    }

    /**
     * Cleans up actor mode resources.
     */
    private void cleanup_actor_mode () {
      // Return all actors to the pool and unbind items
      if (icon_actors != null) {
        foreach (var actor in icon_actors.values) {
          actor.unbind_item ();
          if (icon_container != null) {
            icon_container.remove_child (actor.container);
          }
        }
        icon_actors.clear ();
      }

      // Clear the pool
      if (actor_pool != null) {
        actor_pool.clear ();
      }

      // Destroy container actors
      if (icon_container != null) {
        icon_container.destroy ();
        icon_container = null;
      }

      if (shadow_actor != null) {
        shadow_canvas = null;
        shadow_actor.destroy ();
        shadow_actor = null;
      }

      if (urgent_glow_actor != null) {
        if (urgent_glow_draw_connected && urgent_glow_canvas != null) {
          urgent_glow_canvas.draw.disconnect (on_urgent_glow_canvas_draw);
          urgent_glow_draw_connected = false;
        }
        urgent_glow_canvas = null;
        urgent_glow_actor.destroy ();
        urgent_glow_actor = null;
      }

      if (background_actor != null) {
        if (background_draw_connected && background_canvas != null) {
          background_canvas.draw.disconnect (on_background_canvas_draw);
          background_draw_connected = false;
        }
        background_canvas = null;
        background_actor.destroy ();
        background_actor = null;
      }
    }

    /**
     * Gets or creates an icon actor for a dock item.
     *
     * @param item the dock item
     * @return the icon actor for this item
     */
    public ClutterIconActor get_icon_actor (DockItem item) {
      if (icon_actors.has_key (item)) {
        return icon_actors[item];
      }

      // Try to get an actor from the pool
      ClutterIconActor actor;
      if (actor_pool.size > 0) {
        actor = actor_pool.remove_at (actor_pool.size - 1);
      } else {
        actor = new ClutterIconActor ();
      }

      actor.bind_item (item);
      icon_actors[item] = actor;

      // Add to container (use container, not icon_actor)
      if (icon_container != null) {
        icon_container.add_child (actor.container);
      }

      return actor;
    }

    /**
     * Releases an icon actor back to the pool.
     *
     * @param item the dock item to release
     */
    public void release_icon_actor (DockItem item) {
      if (!icon_actors.has_key (item))
        return;

      var actor = icon_actors[item];
      icon_actors.unset (item);

      // Remove from container (use container, not icon_actor)
      if (icon_container != null) {
        icon_container.remove_child (actor.container);
      }

      actor.unbind_item ();
      actor_pool.add (actor);
    }

    /**
     * Synchronizes icon actors with the current visible items.
     * Releases actors for items no longer visible, creates actors for new items.
     *
     * @param visible_items the currently visible dock items
     */
    public void sync_icon_actors (Gee.ArrayList<unowned DockItem> visible_items) {
      if (!actor_mode_enabled)
        return;

      // Build set of visible items for fast lookup
      var visible_set = new Gee.HashSet<DockItem> ();
      foreach (unowned DockItem item in visible_items) {
        visible_set.add (item);
      }

      // Release actors for items no longer visible
      var to_release = new Gee.ArrayList<DockItem> ();
      foreach (var item in icon_actors.keys) {
        if (!visible_set.contains (item)) {
          to_release.add (item);
        }
      }
      foreach (var item in to_release) {
        release_icon_actor (item);
      }

      // Ensure actors exist for all visible items
      foreach (unowned DockItem item in visible_items) {
        get_icon_actor (item);
      }
    }

    /**
     * Updates the background canvas size and triggers redraw.
     *
     * The canvas is set to logical pixel size - Clutter handles HiDPI scaling
     * via the content scaling filters set on the actor.
     *
     * @param width the width in logical pixels
     * @param height the height in logical pixels
     * @param scale_factor the device scale factor (unused, kept for API compatibility)
     */
    public void update_background_size (int width, int height, int scale_factor) {
      if (background_canvas == null || background_actor == null)
        return;

      // Use logical pixels for both canvas and actor
      // Clutter handles scaling to physical pixels via content scaling filters
      background_canvas.set_size (width, height);
      background_actor.set_size (width, height);
    }

    /**
     * Sets the urgent glow draw callback function.
     *
     * @param func the draw function to call when rendering urgent glow
     */
    public void set_urgent_glow_draw_func (UrgentGlowDrawFunc? func) {
      urgent_glow_draw_func = func;

      if (urgent_glow_canvas != null && !urgent_glow_draw_connected) {
        urgent_glow_canvas.draw.connect (on_urgent_glow_canvas_draw);
        urgent_glow_draw_connected = true;
      }
    }

    /**
     * Updates the urgent glow actor size and position.
     *
     * @param width the width in logical pixels
     * @param height the height in logical pixels
     * @param x the x position
     * @param y the y position
     */
    public void update_urgent_glow (int width, int height, int x, int y) {
      if (urgent_glow_canvas == null || urgent_glow_actor == null)
        return;

      urgent_glow_canvas.set_size (width, height);
      urgent_glow_actor.set_size (width, height);
      urgent_glow_actor.set_position (x, y);
    }

    /**
     * Invalidates the urgent glow canvas to trigger a redraw.
     */
    public void invalidate_urgent_glow () {
      if (urgent_glow_canvas != null) {
        urgent_glow_canvas.invalidate ();
      }
    }

    /**
     * Urgent glow canvas draw callback.
     */
    private bool on_urgent_glow_canvas_draw (Cairo.Context cr, int width, int height) {
      // Clear the canvas
      cr.set_operator (Cairo.Operator.CLEAR);
      cr.paint ();
      cr.set_operator (Cairo.Operator.OVER);

      if (urgent_glow_draw_func != null) {
        urgent_glow_draw_func (cr, width, height);
      }

      return true;
    }

    /**
     * Updates the shadow canvas size.
     *
     * The canvas is set to logical pixel size - Clutter handles HiDPI scaling
     * via the content scaling filters set on the actor.
     *
     * @param width the width in logical pixels
     * @param height the height in logical pixels
     * @param scale_factor the device scale factor (unused, kept for API compatibility)
     */
    public void update_shadow_size (int width, int height, int scale_factor) {
      if (shadow_canvas == null || shadow_actor == null)
        return;

      // Use logical pixels for both canvas and actor
      // Clutter handles scaling to physical pixels via content scaling filters
      shadow_canvas.set_size (width, height);
      shadow_actor.set_size (width, height);
    }

    /**
     * Invalidates the background canvas to trigger redraw.
     */
    public void invalidate_background () {
      if (background_canvas != null) {
        background_canvas.invalidate ();
      }
    }

    /**
     * Invalidates the shadow canvas to trigger redraw.
     */
    public void invalidate_shadow () {
      if (shadow_canvas != null) {
        shadow_canvas.invalidate ();
      }
    }

    /**
     * Gets the background canvas for drawing.
     *
     * @return the background canvas, or null if actor mode is not enabled
     */
    public unowned Clutter.Canvas? get_background_canvas () {
      return background_canvas;
    }

    /**
     * Gets the shadow canvas for drawing.
     *
     * @return the shadow canvas, or null if actor mode is not enabled
     */
    public unowned Clutter.Canvas? get_shadow_canvas () {
      return shadow_canvas;
    }

    /**
     * Delegate for background drawing.
     */
    public delegate void BackgroundDrawFunc (Cairo.Context cr, int width, int height);

    /**
     * The background draw callback function.
     */
    private unowned BackgroundDrawFunc? background_draw_func = null;

    /**
     * Whether the background canvas draw signal is connected.
     */
    private bool background_draw_connected = false;

    /**
     * Sets the background draw function.
     *
     * @param func the function to call when drawing background
     */
    public void set_background_draw_func (BackgroundDrawFunc? func) {
      background_draw_func = func;

      if (background_canvas != null && !background_draw_connected) {
        // Connect the draw signal (only once)
        background_canvas.draw.connect (on_background_canvas_draw);
        background_draw_connected = true;
      }
    }

    /**
     * Background canvas draw callback.
     */
    private bool on_background_canvas_draw (Cairo.Context cr, int width, int height) {
      // Clear the canvas
      cr.set_operator (Cairo.Operator.CLEAR);
      cr.paint ();
      cr.set_operator (Cairo.Operator.OVER);

      if (background_draw_func != null) {
        background_draw_func (cr, width, height);
      }

      return true;
    }
  }
}
#endif
