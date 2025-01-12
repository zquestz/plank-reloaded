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
  public class ClockDockItem : DockletItem {
    private const string THEME_BASE_URI = "resource://" + Docky.G_RESOURCE_PATH + "/themes/";
    private const string DEFAULT_THEME = "Default";
    private const string DEFAULT_24H_THEME = "Default24";
    private const int UPDATE_INTERVAL = 1000;

    private const double DATE_SIZE_RATIO = 0.75;
    private const double FONT_SIZE_RATIO = 1.0 / 3.0;
    private const double SHADOW_OPACITY = 0.4;
    private const double SCALE_FACTOR = 0.9;

    // SVG resources
    private const string SVG_DROP_SHADOW = "/clock-drop-shadow.svg";
    private const string SVG_FACE_SHADOW = "/clock-face-shadow.svg";
    private const string SVG_FACE = "/clock-face.svg";
    private const string SVG_MARKS = "/clock-marks.svg";
    private const string SVG_GLASS = "/clock-glass.svg";
    private const string SVG_FRAME = "/clock-frame.svg";

    private Pango.Layout layout;
    private uint timer_id;
    private int minute;
    private string current_theme;
    ClockDockCalendar calendar;

    public ClockDockItem.with_dockitem_file(GLib.File file) {
      GLib.Object(Prefs: new ClockPreferences.with_file(file));
    }

    construct {
      setup_layout();
      setup_icon();
      connect_preferences();
      start_timer();
    }

    ~ClockDockItem() {
      cleanup();
    }

    private void setup_layout() {
      layout = new Pango.Layout(Gdk.pango_context_get());
      var style_context = new Gtk.StyleContext();
      var font_description = new Pango.FontDescription();

      style_context.get(style_context.get_state(), Gtk.STYLE_PROPERTY_FONT, &font_description);
      font_description.set_weight(Pango.Weight.BOLD);
      layout.set_font_description(font_description);
      layout.set_ellipsize(Pango.EllipsizeMode.NONE);
      layout.set_alignment(Pango.Alignment.CENTER);
    }

    private void setup_icon() {
      Icon = "clock";
      Text = "time";

      unowned ClockPreferences prefs = (ClockPreferences) Prefs;
      update_theme(prefs.ShowMilitary);
    }

    private void connect_preferences() {
      unowned ClockPreferences prefs = (ClockPreferences) Prefs;
      prefs.notify["ShowMilitary"].connect(handle_prefs_changed);
      prefs.notify["ShowDate"].connect(handle_prefs_changed);
      prefs.notify["ShowDigital"].connect(handle_prefs_changed);
    }

    private void start_timer() {
      timer_id = Gdk.threads_add_timeout(UPDATE_INTERVAL, update_timer);
    }

    private void cleanup() {
      if (timer_id > 0U) {
        GLib.Source.remove(timer_id);
        timer_id = 0U;
      }

      unowned ClockPreferences prefs = (ClockPreferences) Prefs;
      prefs.notify["ShowMilitary"].disconnect(handle_prefs_changed);
      prefs.notify["ShowDate"].disconnect(handle_prefs_changed);
      prefs.notify["ShowDigital"].disconnect(handle_prefs_changed);
    }

    private void update_theme(bool military) {
      current_theme = THEME_BASE_URI + (military ? DEFAULT_24H_THEME : DEFAULT_THEME);
    }

    private bool update_timer() {
      var now = new DateTime.now_local();
      if (minute != now.get_minute()) {
        reset_icon_buffer();
        minute = now.get_minute();
      }
      return true;
    }

    private void handle_prefs_changed() {
      unowned ClockPreferences prefs = (ClockPreferences) Prefs;
      update_theme(prefs.ShowMilitary);
      reset_icon_buffer();
    }

    protected override AnimationType on_clicked(PopupButton button, Gdk.ModifierType mod, uint32 event_time) {
      int x, y;
      if (calendar == null) {
        calendar = new ClockDockCalendar();
        calendar.get_position(out x, out y);

        var controller = get_dock();
        if (controller != null) {
          var position = controller.prefs.Position;
          var adjustment = controller.prefs.IconSize * 2;

          switch (position) {
          default:
          case Gtk.PositionType.BOTTOM:
            calendar.move(x, y - adjustment);
            break;
          case Gtk.PositionType.TOP:
            calendar.move(x, y + adjustment);
            break;
          case Gtk.PositionType.LEFT:
            calendar.move(x + adjustment, y);
            break;
          case Gtk.PositionType.RIGHT:
            calendar.move(x - adjustment, y);
            break;
          }
        } else {
          // Fallback to default position and adjustment if no controller
          calendar.move(x, y - 150);
        }

        calendar.destroy.connect(() => {
          calendar = null;
          Gtk.main_quit();
        });
        calendar.show_all();
      } else {
        calendar.present_with_time(event_time);
      }
      return AnimationType.NONE;
    }

    protected override void draw_icon(Surface surface) {
      unowned ClockPreferences prefs = (ClockPreferences) Prefs;
      var now = new DateTime.now_local();

      Text = now.format(prefs.ShowMilitary ? "%a, %b %d %H:%M" : "%a, %b %d %I:%M %p");

      var size = int.max(surface.Width, surface.Height);
      if (prefs.ShowDigital) {
        render_digital_clock(surface, now, size);
      } else {
        render_analog_clock(surface.Context, now, size);
      }
    }

    private void render_file_onto_context(Cairo.Context cr, string uri, int size) {
      var pbuf = DrawingService.load_icon(uri, size, size);
      if (pbuf != null) {
        Gdk.cairo_set_source_pixbuf(cr, pbuf, 0, 0);
        cr.paint();
      }
    }

    private Pango.Layout setup_text_layout(Pango.Context context) {
      var new_layout = new Pango.Layout(context);
      new_layout.set_font_description(layout.get_font_description());
      new_layout.set_alignment(layout.get_alignment());
      return new_layout;
    }

    private string format_time_text(DateTime now, bool military) {
      if (military) {
        return now.format("%H:%M");
      }

      int hour = now.get_hour() % 12;
      if (hour == 0)hour = 12;
      return "%d:%s %s".printf(
                               hour,
                               now.format("%M"),
                               now.get_hour() >= 12 ? "ᴘᴍ" : "ᴀᴍ"
      );
    }

    private void render_digital_clock(Surface surface, DateTime now, int size) {
      unowned ClockPreferences prefs = (ClockPreferences) Prefs;
      unowned Cairo.Context cr = surface.Context;

      int text_size = (int) (surface.Width * FONT_SIZE_RATIO);

      // Setup layouts
      var time_layout = setup_text_layout(layout.get_context());
      var date_layout = setup_text_layout(layout.get_context());

      // Format time text
      string time_text = format_time_text(now, prefs.ShowMilitary);

      // Find the right size that fits
      int current_size = text_size;
      bool fits = false;

      while (!fits && current_size > 0) {
        var font_description = layout.get_font_description();
        font_description.set_absolute_size((int) (current_size * Pango.SCALE));

        time_layout.set_font_description(font_description);
        time_layout.set_text(time_text, -1);

        if (prefs.ShowDate) {
          var date_font = font_description.copy();
          date_font.set_absolute_size((int) (current_size * DATE_SIZE_RATIO * Pango.SCALE));
          date_layout.set_font_description(date_font);
          date_layout.set_text(now.format("%b %d"), -1);
        }

        Pango.Rectangle time_ink, time_logical;
        Pango.Rectangle date_ink, date_logical;

        time_layout.get_pixel_extents(out time_ink, out time_logical);
        date_layout.get_pixel_extents(out date_ink, out date_logical);

        int max_width = time_logical.width;
        if (prefs.ShowDate) {
          max_width = int.max(max_width, date_logical.width);
        }

        if (max_width <= surface.Width) {
          fits = true;

          time_layout.set_width(surface.Width * Pango.SCALE);
          date_layout.set_width(surface.Width * Pango.SCALE);

          time_layout.get_pixel_extents(out time_ink, out time_logical);
          date_layout.get_pixel_extents(out date_ink, out date_logical);

          int total_height = time_logical.height;
          if (prefs.ShowDate) {
            total_height += date_logical.height;
          }

          int start_y = (surface.Height - total_height) / 2;

          // Draw time
          cr.move_to(0, start_y);
          draw_outlined_text(cr, time_layout, 1.0);

          // Draw date if enabled
          if (prefs.ShowDate) {
            cr.move_to(0, start_y + time_logical.height);
            draw_outlined_text(cr, date_layout, 1.0);
          }
        } else {
          current_size = (int) (current_size * SCALE_FACTOR);
        }
      }
    }

    private void draw_outlined_text(Cairo.Context cr, Pango.Layout layout, double offset = 1.0) {
      // Draw drop shadow
      cr.set_source_rgba(0, 0, 0, SHADOW_OPACITY);
      Pango.cairo_show_layout(cr, layout);

      // Draw main text
      cr.translate(-offset, -offset);
      cr.set_source_rgba(1, 1, 1, 1);
      Pango.cairo_show_layout(cr, layout);
      cr.translate(offset, offset);
    }

    private void render_analog_clock(Cairo.Context cr, DateTime now, int size) {
      int center = size / 2;
      var radius = center;

      // Render clock background elements
      render_file_onto_context(cr, current_theme + SVG_DROP_SHADOW, radius * 2);
      render_file_onto_context(cr, current_theme + SVG_FACE_SHADOW, radius * 2);
      render_file_onto_context(cr, current_theme + SVG_FACE, radius * 2);
      render_file_onto_context(cr, current_theme + SVG_MARKS, radius * 2);

      cr.translate(center, center);

      // Draw clock hands
      render_clock_hands(cr, now, size, radius);

      cr.translate(-center, -center);

      // Render clock overlay elements
      render_file_onto_context(cr, current_theme + SVG_GLASS, radius * 2);
      render_file_onto_context(cr, current_theme + SVG_FRAME, radius * 2);
    }

    private void render_clock_hands(Cairo.Context cr, DateTime now, int size, int radius) {
      // Draw minute hand
      cr.set_source_rgba(0.15, 0.15, 0.15, 1);
      cr.set_line_width(double.max(1.0, size / 48.0));
      cr.set_line_cap(Cairo.LineCap.ROUND);

      double minute_rotation = Math.PI * (now.get_minute() / 30.0 + 1.0);
      draw_clock_hand(cr, minute_rotation, radius, 0.35, 0.15);

      // Draw hour hand
      cr.set_source_rgba(0, 0, 0, 1);
      var total_hours = current_theme.has_suffix("24") ? 24.0 : 12.0;
      double hour_rotation = Math.PI * (
                                        (now.get_hour() % (int) total_hours) / (total_hours / 2.0)
                                        + now.get_minute() / (30.0 * total_hours) + 1.0
      );
      draw_clock_hand(cr, hour_rotation, radius, 0.5, 0.15);
    }

    private void draw_clock_hand(Cairo.Context cr, double rotation,
                                 int radius, double length_factor, double offset_factor) {
      cr.rotate(rotation);
      cr.move_to(0, radius - radius * length_factor);
      cr.line_to(0, 0 - radius * offset_factor);
      cr.stroke();
      cr.rotate(-rotation);
    }

    public override Gee.ArrayList<Gtk.MenuItem> get_menu_items() {
      unowned ClockPreferences prefs = (ClockPreferences) Prefs;
      var items = new Gee.ArrayList<Gtk.MenuItem> ();

      add_menu_item(items, _("Di_gital Clock"), prefs.ShowDigital, () => {
        prefs.ShowDigital = !prefs.ShowDigital;
        return true;
      });

      add_menu_item(items, _("24-Hour _Clock"), prefs.ShowMilitary, () => {
        prefs.ShowMilitary = !prefs.ShowMilitary;
        return true;
      });

      add_menu_item(items, _("Show _Date"), prefs.ShowDate, () => {
        prefs.ShowDate = !prefs.ShowDate;
        return true;
      }, prefs.ShowDigital);

      return items;
    }

    private void add_menu_item(Gee.ArrayList<Gtk.MenuItem> items, string label,
                               bool active, owned GLib.SourceFunc callback,
                               bool sensitive = true) {
      var item = new Gtk.CheckMenuItem.with_mnemonic(label);
      item.active = active;
      item.sensitive = sensitive;
      item.activate.connect(() => {
        callback();
      });
      items.add(item);
    }
  }
}
