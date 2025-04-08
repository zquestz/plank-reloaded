/**
 * SECTION:DrawingService
 * @short_description: Utility service for loading icons and working with pixbufs.
 */
/**
 * PLANK_TYPE_DRAWING_SERVICE:
 * 
 * The type for <link linkend="PlankDrawingService"><type>PlankDrawingService</type></link>.
 */
/**
 * plank_drawing_service_get_icon_theme:
 * 
 * Returns: (transfer none): 
 */
/**
 * plank_drawing_service_get_icon_from_file:
 * @file: (in): &nbsp;.  <para>the file to get the icon name for </para>
 * 
 * Gets the icon name from a <link linkend="GFile"><type>GFile</type></link>.
 * 
 * Returns: <para>the icon name for the file, or null if none exists </para>
 */
/**
 * plank_drawing_service_get_icon_from_gicon:
 * @icon: (in) (allow-none): &nbsp;.  <para>the icon to get the name for </para>
 * 
 * Gets an icon from a <link linkend="GIcon"><type>GIcon</type></link>.
 * 
 * Returns: <para>the icon name, or null if none exists </para>
 */
/**
 * plank_drawing_service_load_icon:
 * @names: (in): &nbsp;.  <para>a delimited (with &quot;;;&quot;) list of icon names, first one found is used </para>
 * @width: (in): &nbsp;.  <para>the requested width of the icon </para>
 * @height: (in): &nbsp;.  <para>the requested height of the icon </para>
 * 
 * Loads an icon based on names and the given width/height
 * 
 * Returns: <para>the pixbuf representing the requested icon </para>
 */
/**
 * plank_drawing_service_try_get_icon_file:
 * @name: (in): &nbsp;.  <para>a string which might represent an existing file </para>
 * 
 * Try to get a <link linkend="GFile"><type>GFile</type></link> for the given icon name
 * 
 * Returns: <para>a <link linkend="GFile"><type>GFile</type></link>, or null if it failed </para>
 */
/**
 * plank_drawing_service_load_icon_for_scale:
 * @names: (in): &nbsp;.  <para>a delimited (with &quot;;;&quot;) list of icon names, first one found is used </para>
 * @width: (in): &nbsp;.  <para>the requested width of the icon </para>
 * @height: (in): &nbsp;.  <para>the requested height of the icon </para>
 * @scale: (in): &nbsp;.  <para>the implicit requested scale of the icon </para>
 * 
 * Loads an icon based on names and the given width/height
 * 
 * Returns: <para>the {link Cairo.Surface} containing the requested icon, do not alter this surface </para>
 */
/**
 * plank_drawing_service_ar_scale:
 * @source: (in): &nbsp;.  <para>the pixbuf to scale </para>
 * @width: (in): &nbsp;.  <para>the width of the scaled pixbuf </para>
 * @height: (in): &nbsp;.  <para>the height of the scaled pixbuf </para>
 * 
 * Scales a <link linkend="GdkPixbuf"><type>GdkPixbuf</type></link>, maintaining the original aspect ratio.
 * 
 * Returns: <para>the scaled pixbuf </para>
 */
/**
 * plank_drawing_service_average_color:
 * @source: (in): &nbsp;.  <para>the pixbuf to use </para>
 * 
 * Computes and returns the average color of a <link linkend="GdkPixbuf"><type>GdkPixbuf</type></link>. The resulting color is the average of all pixels which aren&apos;t nearly transparent while saturated pixels are weighted more than &quot;grey&quot; ones.
 * 
 * Returns: <para>the average color of the pixbuf </para>
 */
/**
 * PlankDrawingService:
 * 
 * Utility service for loading icons and working with pixbufs.
 */
/**
 * PlankDrawingServiceClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-DRAWING-SERVICE:CAPS"><literal>PLANK_TYPE_DRAWING_SERVICE</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
