//
// Copyright (C) 2024 Plank Reloaded Developers
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
  public class CPUMonitorDockItem : DockletItem {
    private const ulong UPDATE_DELAY = 1000000UL;
    private const double RADIUS_PERCENT = 0.9;
    private const double CPU_THRESHOLD = 0.03;
    private const double MEM_THRESHOLD = 0.01;

    private const string PROC_STAT_PATH = "/proc/stat";
    private const string PROC_MEMINFO_PATH = "/proc/meminfo";

    private bool disposed;
    private ulong last_usage;
    private ulong last_idle;

    private double cpu_utilization;
    private double memory_utilization;
    private double last_cpu_utilization;
    private double last_memory_utilization;

    public CPUMonitorDockItem.with_dockitem_file(GLib.File file)
    {
      GLib.Object(Prefs: new DockItemPreferences.with_file(file));
    }

    construct
    {
      start_monitor();
    }

    ~CPUMonitorDockItem() {
      disposed = true;
    }

    private void start_monitor() {
      new Thread<void*> ("cpu-monitor", () => {
        while (!disposed) {
          update_stats();
          Thread.usleep(UPDATE_DELAY);
        }
        return null;
      });
    }

    private void update_stats() {
      update_cpu_stats();
      update_memory_stats();
      update_display();
    }

    private void update_cpu_stats() {
      var stream = FileStream.open(PROC_STAT_PATH, "r");
      if (stream == null)
        return;

      ulong user, nice, system, idle, iowait, irq, softirq;
      if (stream.scanf("%*s %lu %lu %lu %lu %lu %lu %lu",
                       out user, out nice, out system, out idle,
                       out iowait, out irq, out softirq) < 7)
        return;

      var usage_final = user + nice + system + idle + iowait + irq + softirq;
      var idle_final = idle + iowait;

      var usage_diff = usage_final - last_usage;
      var idle_diff = idle_final - last_idle;

      last_idle = idle_final;
      last_usage = usage_final;

      if (usage_diff > 0UL) {
        cpu_utilization = double.max(0.01,
                                     (1.0 - (idle_diff / (double) usage_diff) + cpu_utilization) / 2.0);
      }
    }

    private void update_memory_stats() {
      var stream = FileStream.open(PROC_MEMINFO_PATH, "r");
      if (stream == null)
        return;

      ulong mem_total, mem_free, mem_avail;
      if (stream.scanf("%*s %lu %*s", out mem_total) < 1)
        return;
      if (stream.scanf("%*s %lu %*s", out mem_free) < 1)
        return;
      if (stream.scanf("%*s %lu %*s", out mem_avail) < 1)
        return;

      memory_utilization = 1.0 - (mem_avail / (double) mem_total);
    }

    private void update_display() {
      var cpu = cpu_utilization;
      var mem = memory_utilization;
      var needs_icon_update = should_update_icon();

      // Update UI on main thread
      Idle.add(() => {
        if (disposed) {
          return false;
        }

        Text = ("CPU: %.1f%% | Mem: %.1f%%").printf(cpu * 100, mem * 100);

        if (needs_icon_update) {
          reset_icon_buffer();
        }

        return false;
      });

      if (needs_icon_update) {
        last_cpu_utilization = cpu_utilization;
        last_memory_utilization = memory_utilization;
      }
    }

    private bool should_update_icon() {
      return Math.fabs(last_cpu_utilization - cpu_utilization) >= CPU_THRESHOLD
             || Math.fabs(last_memory_utilization - memory_utilization) >= MEM_THRESHOLD;
    }

    protected override void draw_icon(Surface surface) {
      var size = int.max(surface.Width, surface.Height);
      unowned Cairo.Context cr = surface.Context;

      double center = size / 2.0;
      Plank.Color base_color = { 1.0, 0.3, 0.3, 0.5 };
      base_color.set_hue(120.0 * (1.0 - cpu_utilization));

      draw_background(cr, center, base_color);
      draw_cpu_indicator(cr, center, base_color);
      draw_highlight(cr, center, size);
      draw_outer_circles(cr, center);
      draw_memory_indicator(cr, center, size);
    }

    private void draw_background(Cairo.Context cr, double center, Plank.Color base_color) {
      cr.arc(center, center, center * RADIUS_PERCENT, 0.0, 2.0 * Math.PI);
      cr.set_source_rgba(0.0, 0.0, 0.0, 0.5);
      cr.fill_preserve();

      var pattern = new Cairo.Pattern.radial(
                                             center, center, 0.0,
                                             center, center, center * RADIUS_PERCENT
      );
      pattern.add_color_stop_rgba(0.0, base_color.red, base_color.green, base_color.blue, base_color.alpha);
      pattern.add_color_stop_rgba(0.2, base_color.red, base_color.green, base_color.blue, base_color.alpha);
      pattern.add_color_stop_rgba(1.0, base_color.red, base_color.green, base_color.blue, 0.15);
      cr.set_source(pattern);
      cr.fill_preserve();
    }

    private void draw_cpu_indicator(Cairo.Context cr, double center, Plank.Color base_color) {
      double radius = double.max(double.min(cpu_utilization * 1.3, 1.0), 0.001);
      var pattern = new Cairo.Pattern.radial(
                                             center, center, 0,
                                             center, center, center * RADIUS_PERCENT * radius
      );
      pattern.add_color_stop_rgba(0.0, base_color.red, base_color.green, base_color.blue, 1.0);
      pattern.add_color_stop_rgba(0.2, base_color.red, base_color.green, base_color.blue, 1.0);
      pattern.add_color_stop_rgba(1.0, base_color.red, base_color.green, base_color.blue,
                                  double.max(0.0, cpu_utilization * 1.3 - 1.0));
      cr.set_source(pattern);
      cr.fill();
    }

    private void draw_highlight(Cairo.Context cr, double center, int size) {
      cr.arc(center, center * 0.8, center * 0.6, 0.0, 2.0 * Math.PI);
      var pattern = new Cairo.Pattern.linear(0.0, 0.0, 0.0, center);
      pattern.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.35);
      pattern.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 0.0);
      cr.set_source(pattern);
      cr.fill();
    }

    private void draw_outer_circles(Cairo.Context cr, double center) {
      cr.set_line_width(1.0);
      cr.arc(center, center, center * RADIUS_PERCENT, 0.0, 2.0 * Math.PI);
      cr.set_source_rgba(1.0, 1.0, 1.0, 0.75);
      cr.stroke();

      cr.set_line_width(1.0);
      cr.arc(center, center, center * RADIUS_PERCENT - 1.0, 0.0, 2.0 * Math.PI);
      cr.set_source_rgba(0.8, 0.8, 0.8, 0.75);
      cr.stroke();
    }

    private void draw_memory_indicator(Cairo.Context cr, double center, int size) {
      cr.set_line_width(size / 32.0);
      cr.arc_negative(center, center,
                      center * RADIUS_PERCENT - 1.0,
                      Math.PI,
                      Math.PI - Math.PI * (2.0 * memory_utilization));
      cr.set_source_rgba(1.0, 1.0, 1.0, 0.85);
      cr.stroke();
    }
  }
}
