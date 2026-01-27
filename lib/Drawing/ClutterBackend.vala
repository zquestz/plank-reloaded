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
   * This is a hybrid approach: Cairo draws to surfaces, which are then
   * uploaded to GPU textures via Clutter.Canvas for final compositing.
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

    private int clutter_surface_width = 0;
    private int clutter_surface_height = 0;

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
    }

    ~ClutterBackend () {
      // Clear cached Clutter surfaces and contexts
      clutter_main_cr = null;
      clutter_item_cr = null;
      clutter_shadow_cr = null;
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
      clutter_main_surface = null;
      clutter_item_surface = null;
      clutter_shadow_surface = null;
      clutter_fade_surface = null;
      clutter_model_surface = null;
      clutter_model = null;
      clutter_surface_width = 0;
      clutter_surface_height = 0;
    }
  }
}
#endif
