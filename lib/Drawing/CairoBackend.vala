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
   * Cairo-based CPU rendering backend for the dock.
   *
   * This backend uses Cairo for all rendering operations, compositing
   * layers on the CPU. It works on all systems, including those without
   * compositing window managers.
   *
   * All buffer management is inherited from the base RenderBackend class.
   */
  public class CairoBackend : RenderBackend {
    /**
     * Creates a new Cairo rendering backend.
     *
     * @param controller the dock controller to render for
     */
    public CairoBackend (DockController controller) {
      base (controller);
    }

    /**
     * {@inheritDoc}
     */
    public override void ensure_buffers (int width, int height, Cairo.Surface target) {
      base.ensure_buffers (width, height, target);

      // CairoBackend needs fade_buffer for opacity transitions
      if (current_opacity < 1.0) {
        if (fade_buffer == null || fade_buffer.Width != width || fade_buffer.Height != height) {
          fade_buffer = new Surface.with_cairo_surface (width, height, target);
          fade_buffer.Internal.set_device_scale (window_scale_factor, window_scale_factor);
        }
      }
    }

    /**
     * {@inheritDoc}
     */
    public override void reset_buffers () {
      Logger.verbose ("CairoBackend.reset_buffers ()");
      base.reset_buffers ();
    }
  }
}
