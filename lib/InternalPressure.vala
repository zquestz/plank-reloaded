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
   * Measures how hard the pointer pushes against a barrier, the way GNOME
   * Shell's pressure barriers do. Pushes within the timeout of the latest
   * one add up, each capped at 15 pixels; a single push of the whole
   * threshold counts on its own; and a move that slides along the barrier
   * more than it pushes into it doesn't count. Reaching the threshold
   * triggers once, and further pushes are ignored until the pointer leaves
   * the barrier. Pure logic, testable in isolation.
   */
  public class PressureCounter {
    // The most a single push adds
    const double MAX_PUSH = 15.0;

    struct Push {
      uint32 time;
      double distance;
    }

    double threshold;
    uint32 timeout;

    Push[] pushes = {};

    /**
     * The pressure the counted pushes add up to.
     */
    public double pressure { get; private set; }

    /**
     * Whether a push has triggered since the pointer last left the barrier.
     */
    public bool triggered { get; private set; }

    /**
     * Creates a pressure counter.
     *
     * @param threshold the pressure that triggers, in pixels
     * @param timeout how long a push counts, in milliseconds
     */
    public PressureCounter (double threshold, uint timeout) {
      this.threshold = threshold;
      this.timeout = timeout;
    }

    /**
     * Counts a push against the barrier.
     *
     * @param time when the push happened, as an X server time in milliseconds
     * @param distance how far the push went into the barrier
     * @param slide how far it moved along the barrier
     * @return whether this push triggered
     */
    public bool push (uint32 time, double distance, double slide) {
      if (triggered)
        return false;

      if (distance >= threshold)
        return trigger ();

      if (slide > distance)
        return false;

      // Pushes more than the timeout before this one no longer count; the
      // unsigned difference stays right when the X server time wraps
      var expired = 0;
      while (expired < pushes.length && (uint32) (time - pushes[expired].time) > timeout) {
        pressure -= pushes[expired].distance;
        expired++;
      }
      if (expired > 0)
        pushes = pushes[expired:pushes.length];

      Push counted = { time, double.min (MAX_PUSH, distance) };
      pushes += counted;
      pressure += counted.distance;

      if (pressure < threshold)
        return false;

      return trigger ();
    }

    /**
     * Forgets every push once the pointer leaves the barrier, so the next
     * push can trigger again.
     */
    public void leave () {
      triggered = false;
      reset ();
    }

    bool trigger () {
      triggered = true;
      reset ();
      return true;
    }

    void reset () {
      pushes = {};
      pressure = 0.0;
    }
  }
}
