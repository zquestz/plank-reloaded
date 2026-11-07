namespace Plank {
  [CCode (cheader_filename = "monitor-edid.h", cname = "plank_monitor_get_edid")]
  public GLib.Bytes? monitor_get_edid (Gdk.Display display, string output_name);
}
