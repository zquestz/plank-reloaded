//
// Copyright (C) 2011 Robert Dyer
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
   * Handles animated rendering.  Uses a timer and continues requesting
   * redraws for a widget until no more animation is needed.
   */
  public abstract class Renderer : GLib.Object {
    public Gtk.Widget widget { get; construct; }

    [CCode (notify = false)]
    public int64 frame_time { get; private set; }

    uint timer_id = 0U;
    ulong widget_realize_handler_id = 0UL;
    ulong widget_draw_handler_id = 0UL;

    /**
     * Creates a new animation renderer.
     */
    protected Renderer (Gtk.Widget widget) {
      Object (widget: widget);
    }

    construct
    {
      timer_id = widget.add_tick_callback ((Gtk.TickCallback) draw_timeout);
      widget_realize_handler_id = widget.realize.connect (on_widget_realize);
      widget_draw_handler_id = widget.draw.connect (on_widget_draw);
    }

    ~Renderer () {
      if (timer_id > 0U) {
        widget.remove_tick_callback (timer_id);
        timer_id = 0U;
      }

      if (widget_realize_handler_id > 0UL) {
        widget.disconnect (widget_realize_handler_id);
        widget_realize_handler_id = 0UL;
      }

      if (widget_draw_handler_id > 0UL) {
        widget.disconnect (widget_draw_handler_id);
        widget_draw_handler_id = 0UL;
      }
    }

    /**
     * Determines if animation should continue.
     *
     * @param frame_time the current time for this frame's render
     * @return if another animation frame is needed
     */
    protected abstract bool animation_needed (int64 frame_time);

    /**
     * Preparations which are not requiring a drawing context yet.
     *
     * @param frame_time the current time for this frame's render
     */
    protected abstract void initialize_frame (int64 frame_time);

    /**
     * Draws onto a context.
     *
     * @param cr the context to use for drawing
     */
    public abstract void draw (Cairo.Context cr, int64 frame_time);

    /**
     * Force an immediate update of the frame_time property.
     */
    protected int64 force_frame_time_update () {
      frame_time = GLib.get_monotonic_time ();
      return frame_time;
    }

    /**
     * Request re-drawing.
     */
    public void animated_draw () {
      if (!widget.get_realized ())
        return;

      int64 local_frame_time = force_frame_time_update ();
      initialize_frame (local_frame_time);

      widget.queue_draw ();

      if (animation_needed (local_frame_time)) {
        unowned Gdk.FrameClock? frame_clock = widget.get_frame_clock ();
        frame_clock.begin_updating ();
      }
    }

    [CCode (instance_pos = -1)]
    bool draw_timeout (Gtk.Widget widget, Gdk.FrameClock frame_clock) {
      int64 local_frame_time = force_frame_time_update ();
      initialize_frame (local_frame_time);

      widget.queue_draw ();

      if (animation_needed (local_frame_time))
        return true;

      frame_clock.end_updating ();
      return true;
    }

    [CCode (instance_pos = -1)]
    bool on_widget_draw (Gtk.Widget widget, Cairo.Context cr) {
      draw (cr, frame_time);

      return Gdk.EVENT_PROPAGATE;
    }

    [CCode (instance_pos = -1)]
    void on_widget_realize (Gtk.Widget widget) {
      initialize_frame (force_frame_time_update ());

      if (widget_realize_handler_id > 0UL) {
        widget.disconnect (widget_realize_handler_id);
        widget_realize_handler_id = 0UL;
      }
    }
  }
}
