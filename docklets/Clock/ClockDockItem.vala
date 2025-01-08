//
//  Copyright (C) 2024 Plank Reloaded Developers
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

using Plank;

namespace Docky
{
    public class ClockDockItem : DockletItem
    {
        private const string THEME_BASE_URI = "resource://" + Docky.G_RESOURCE_PATH + "/themes/";
        private const string DEFAULT_THEME = "Default";
        private const string DEFAULT_24H_THEME = "Default24";
        private const int UPDATE_INTERVAL = 1000; // 1 second

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

        public ClockDockItem.with_dockitem_file (GLib.File file)
        {
            GLib.Object (Prefs: new ClockPreferences.with_file (file));
        }

        construct
        {
            setup_layout();
            setup_icon();
            connect_preferences();
            start_timer();
        }

        ~ClockDockItem ()
        {
            cleanup();
        }

        private void setup_layout()
        {
            layout = new Pango.Layout (Gdk.pango_context_get ());
            var style_context = new Gtk.StyleContext ();
            var font_description = new Pango.FontDescription ();

            style_context.get (style_context.get_state (), Gtk.STYLE_PROPERTY_FONT, &font_description);
            font_description.set_weight (Pango.Weight.BOLD);
            layout.set_font_description (font_description);
            layout.set_ellipsize (Pango.EllipsizeMode.NONE);
        }

        private void setup_icon()
        {
            Icon = "clock";
            Text = "time";

            unowned ClockPreferences prefs = (ClockPreferences) Prefs;
            update_theme(prefs.ShowMilitary);
        }

        private void connect_preferences()
        {
            unowned ClockPreferences prefs = (ClockPreferences) Prefs;
            prefs.notify["ShowMilitary"].connect (handle_prefs_changed);
            prefs.notify["ShowDate"].connect (handle_prefs_changed);
            prefs.notify["ShowDigital"].connect (handle_prefs_changed);
        }

        private void start_timer()
        {
            timer_id = Gdk.threads_add_timeout (UPDATE_INTERVAL, update_timer);
        }

        private void cleanup()
        {
            if (timer_id > 0U) {
                GLib.Source.remove (timer_id);
                timer_id = 0U;
            }

            unowned ClockPreferences prefs = (ClockPreferences) Prefs;
            prefs.notify["ShowMilitary"].disconnect (handle_prefs_changed);
            prefs.notify["ShowDate"].disconnect (handle_prefs_changed);
            prefs.notify["ShowDigital"].disconnect (handle_prefs_changed);
        }

        private void update_theme(bool military)
        {
            current_theme = THEME_BASE_URI + (military ? DEFAULT_24H_THEME : DEFAULT_THEME);
        }

        private bool update_timer ()
        {
            var now = new DateTime.now_local ();
            if (minute != now.get_minute ()) {
                reset_icon_buffer ();
                minute = now.get_minute ();
            }
            return true;
        }

        private void handle_prefs_changed ()
        {
            unowned ClockPreferences prefs = (ClockPreferences) Prefs;
            update_theme(prefs.ShowMilitary);
            reset_icon_buffer ();
        }

        protected override void draw_icon (Surface surface)
        {
            unowned ClockPreferences prefs = (ClockPreferences) Prefs;
            var now = new DateTime.now_local ();

            Text = now.format (prefs.ShowMilitary ? "%a, %b %d %H:%M" : "%a, %b %d %I:%M %p");

            var size = int.max (surface.Width, surface.Height);
            if (prefs.ShowDigital) {
                render_digital_clock (surface, now, size);
            } else {
                render_analog_clock (surface.Context, now, size);
            }
        }

        private void render_file_onto_context (Cairo.Context cr, string uri, int size)
        {
            var pbuf = DrawingService.load_icon (uri, size, size);
            if (pbuf != null) {
                Gdk.cairo_set_source_pixbuf (cr, pbuf, 0, 0);
                cr.paint ();
            }
        }

        private void render_digital_clock (Surface surface, DateTime now, int size)
        {
            unowned ClockPreferences prefs = (ClockPreferences) Prefs;
            unowned Cairo.Context cr = surface.Context;

            // Calculate dimensions
            int time_size = surface.Height / 4;
            int date_size = surface.Height / 5;
            int ampm_size = surface.Height / 5;
            int spacing = time_size / 2;
            int center = surface.Height / 2;

            layout.set_width ((int) (surface.Width * Pango.SCALE));

            // Draw time
            render_time(cr, now, prefs, time_size, spacing, center, surface);

            // Draw date if enabled
            if (prefs.ShowDate) {
                render_date(cr, now, date_size, spacing, surface);
            }

            // Draw AM/PM indicators for 12-hour clock
            if (!prefs.ShowMilitary) {
                render_ampm_indicators(cr, now, ampm_size, spacing, center, surface, prefs.ShowDate);
            }
        }

        private void render_time(Cairo.Context cr, DateTime now, ClockPreferences prefs,
                                int time_size, int spacing, int center, Surface surface)
        {
            var font_description = layout.get_font_description ();
            font_description.set_absolute_size ((int) (time_size * Pango.SCALE));

            string time_text = prefs.ShowMilitary ?
                now.format ("%H:%M") :
                now.format ("%l:%M").chug ();

            layout.set_text (time_text, -1);

            Pango.Rectangle ink_rect, logical_rect;
            layout.get_pixel_extents (out ink_rect, out logical_rect);

            int time_y_offset = prefs.ShowMilitary ? time_size : time_size / 2;
            int time_x_offset = (surface.Width - ink_rect.width) / 2;

            cr.move_to (time_x_offset,
                        prefs.ShowDate ? time_y_offset : time_y_offset + time_size / 2);

            draw_outlined_text(cr, 3.0);
        }

        private void render_date(Cairo.Context cr, DateTime now,
                                int date_size, int spacing, Surface surface)
        {
            var font_description = layout.get_font_description ();
            font_description.set_absolute_size ((int) (date_size * Pango.SCALE));

            layout.set_text (now.format ("%b %d"), -1);

            Pango.Rectangle ink_rect, logical_rect;
            layout.get_pixel_extents (out ink_rect, out logical_rect);

            cr.move_to ((surface.Width - ink_rect.width) / 2,
                        surface.Height - spacing - date_size);

            draw_outlined_text(cr, 2.5);
        }

        private void draw_outlined_text(Cairo.Context cr, double line_width)
        {
            Pango.cairo_layout_path (cr, layout);
            cr.set_line_width (line_width);
            cr.set_source_rgba (0, 0, 0, 0.5);
            cr.stroke_preserve ();
            cr.set_source_rgba (1, 1, 1, 0.8);
            cr.fill ();
        }

        private void render_ampm_indicators(Cairo.Context cr, DateTime now,
                                          int ampm_size, int spacing, int center,
                                          Surface surface, bool show_date)
        {
            var font_description = layout.get_font_description ();
            font_description.set_absolute_size ((int) (ampm_size * Pango.SCALE));

            int y_offset = show_date ?
                center - spacing :
                surface.Height - spacing - ampm_size;

            // Draw AM indicator
            render_ampm_indicator(cr, "am", now.get_hour () < 12,
                                y_offset, center, true);

            // Draw PM indicator
            render_ampm_indicator(cr, "pm", now.get_hour () >= 12,
                                y_offset, center, false);
        }

        private void render_ampm_indicator(Cairo.Context cr, string text, bool active,
                                         int y_offset, int center, bool is_am)
        {
            layout.set_text (text, -1);

            Pango.Rectangle ink_rect, logical_rect;
            layout.get_pixel_extents (out ink_rect, out logical_rect);

            int x_offset = is_am ?
                (center - ink_rect.width) / 2 :
                center + (center - ink_rect.width) / 2;

            cr.move_to (x_offset, y_offset);

            Pango.cairo_layout_path (cr, layout);
            cr.set_line_width (2);

            if (active) {
                cr.set_source_rgba (0, 0, 0, 0.5);
                cr.stroke_preserve ();
                cr.set_source_rgba (1, 1, 1, 0.8);
            } else {
                cr.set_source_rgba (1, 1, 1, 0.4);
                cr.stroke_preserve ();
                cr.set_source_rgba (0, 0, 0, 0.5);
            }

            cr.fill ();
        }

        private void render_analog_clock (Cairo.Context cr, DateTime now, int size)
        {
            int center = size / 2;
            var radius = center;

            // Render clock background elements
            render_file_onto_context (cr, current_theme + SVG_DROP_SHADOW, radius * 2);
            render_file_onto_context (cr, current_theme + SVG_FACE_SHADOW, radius * 2);
            render_file_onto_context (cr, current_theme + SVG_FACE, radius * 2);
            render_file_onto_context (cr, current_theme + SVG_MARKS, radius * 2);

            cr.translate (center, center);

            // Draw clock hands
            render_clock_hands(cr, now, size, radius);

            cr.translate (-center, -center);

            // Render clock overlay elements
            render_file_onto_context (cr, current_theme + SVG_GLASS, radius * 2);
            render_file_onto_context (cr, current_theme + SVG_FRAME, radius * 2);
        }

        private void render_clock_hands(Cairo.Context cr, DateTime now, int size, int radius)
        {
            // Draw minute hand
            cr.set_source_rgba (0.15, 0.15, 0.15, 1);
            cr.set_line_width (double.max (1.0, size / 48.0));
            cr.set_line_cap (Cairo.LineCap.ROUND);

            double minute_rotation = Math.PI * (now.get_minute () / 30.0 + 1.0);
            draw_clock_hand(cr, minute_rotation, radius, 0.35, 0.15);

            // Draw hour hand
            cr.set_source_rgba (0, 0, 0, 1);
            var total_hours = current_theme.has_suffix ("24") ? 24.0 : 12.0;
            double hour_rotation = Math.PI * (
                (now.get_hour () % (int)total_hours) / (total_hours / 2.0) +
                now.get_minute () / (30.0 * total_hours) + 1.0
            );
            draw_clock_hand(cr, hour_rotation, radius, 0.5, 0.15);
        }

        private void draw_clock_hand(Cairo.Context cr, double rotation,
                                   int radius, double length_factor, double offset_factor)
        {
            cr.rotate (rotation);
            cr.move_to (0, radius - radius * length_factor);
            cr.line_to (0, 0 - radius * offset_factor);
            cr.stroke ();
            cr.rotate (-rotation);
        }

        public override Gee.ArrayList<Gtk.MenuItem> get_menu_items ()
        {
            unowned ClockPreferences prefs = (ClockPreferences) Prefs;
            var items = new Gee.ArrayList<Gtk.MenuItem> ();

            add_menu_item (items, _("Di_gital Clock"), prefs.ShowDigital, () => {
                prefs.ShowDigital = !prefs.ShowDigital;
                return true;
            });

            add_menu_item (items, _("24-Hour _Clock"), prefs.ShowMilitary, () => {
                prefs.ShowMilitary = !prefs.ShowMilitary;
                return true;
            });

            add_menu_item (items, _("Show _Date"), prefs.ShowDate, () => {
                prefs.ShowDate = !prefs.ShowDate;
                return true;
            }, prefs.ShowDigital);

            return items;
        }

        private void add_menu_item (Gee.ArrayList<Gtk.MenuItem> items, string label,
                                  bool active, owned GLib.SourceFunc callback,
                                  bool sensitive = true)
        {
            var item = new Gtk.CheckMenuItem.with_mnemonic (label);
            item.active = active;
            item.sensitive = sensitive;
            item.activate.connect (() => {
                callback ();
            });
            items.add (item);
        }
    }
}
