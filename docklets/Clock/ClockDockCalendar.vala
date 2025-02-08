using Plank;

namespace Docky {
  public class ClockDockCalendar : Gtk.Window {
    private Gtk.Calendar calendar;
    private int natural_height = 0;

    public ClockDockCalendar() {
      this.title = "Plank Clock Calendar";
      this.border_width = 5;
      this.set_default_size(300, 200);
      this.set_position(Gtk.WindowPosition.MOUSE);
      this.set_skip_taskbar_hint(true);
      Gtk.Window.set_default_icon_name("calendar");

      calendar = new Gtk.Calendar();
      this.add(calendar);

      // Get the natural height before setting min width
      Gtk.Requisition min_size, nat_size;
      calendar.get_preferred_size(out min_size, out nat_size);
      natural_height = nat_size.height;

      // Now set the minimum width
      calendar.set_size_request(300, -1);
    }

    public int get_natural_height() {
      return natural_height + ((int) border_width * 2);
    }
  }
}
