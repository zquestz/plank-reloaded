/**
 * SECTION:Surface
 * @short_description: A surface is a wrapper class for a <link linkend="cairo-surface-t"><type>cairo_surface_t</type></link>. It encapsulates a surface/context and provides utility methods.
 */
/**
 * PLANK_TYPE_SURFACE:
 * 
 * The type for <link linkend="PlankSurface"><type>PlankSurface</type></link>.
 */
/**
 * plank_surface_clear:
 * @self: the <link linkend="PlankSurface"><type>PlankSurface</type></link> instance
 * 
 * Clears the entire surface.
 */
/**
 * plank_surface_copy:
 * @self: the <link linkend="PlankSurface"><type>PlankSurface</type></link> instance
 * 
 * Create a copy of the surface
 * 
 * Returns: <para>copy of this surface </para>
 */
/**
 * plank_surface_scaled_copy:
 * @self: the <link linkend="PlankSurface"><type>PlankSurface</type></link> instance
 * @width: (in): &nbsp;.  <para>the resulting width </para>
 * @height: (in): &nbsp;.  <para>the resulting height </para>
 * 
 * Create a scaled copy of the surface
 * 
 * Returns: <para>scaled copy of this surface </para>
 */
/**
 * plank_surface_to_pixbuf:
 * @self: the <link linkend="PlankSurface"><type>PlankSurface</type></link> instance
 * 
 * Saves the current surface to a <link linkend="GdkPixbuf"><type>GdkPixbuf</type></link>.
 * 
 * Returns: <para>the <link linkend="GdkPixbuf"><type>GdkPixbuf</type></link> </para>
 */
/**
 * plank_surface_create_mask:
 * @self: the <link linkend="PlankSurface"><type>PlankSurface</type></link> instance
 * @threshold: (in): &nbsp;.  <para>value defining the minimum opacity [0.0 .. 1.0] </para>
 * @extent: (out): &nbsp;.  <para>bounding box of the found mask </para>
 * 
 * Computes the mask of the surface.
 * 
 * Returns: <para>a new surface containing the mask </para>
 */
/**
 * plank_surface_average_color:
 * @self: the <link linkend="PlankSurface"><type>PlankSurface</type></link> instance
 * 
 * Computes and returns the average color of the surface.
 * 
 * Returns: <para>the average color of the surface </para>
 */
/**
 * plank_surface_fast_blur:
 * @self: the <link linkend="PlankSurface"><type>PlankSurface</type></link> instance
 * @radius: (in): &nbsp;.  <para>the radius of the blur </para>
 * @process_count: (in): &nbsp;.  <para>how many iterations to blur </para>
 * 
 * Performs a fast blur on the surface.
 */
/**
 * plank_surface_exponential_blur:
 * @self: the <link linkend="PlankSurface"><type>PlankSurface</type></link> instance
 * @radius: (in): &nbsp;.  <para>the radius of the blur </para>
 * 
 * Performs an exponential blur on the surface.
 */
/**
 * plank_surface_gaussian_blur:
 * @self: the <link linkend="PlankSurface"><type>PlankSurface</type></link> instance
 * @radius: (in): &nbsp;.  <para>the radius of the blur </para>
 * 
 * Performs a gaussian blur on the surface. <emphasis role="bold">Note: This method is wickedly slow</emphasis>
 */
/**
 * plank_surface_new:
 * @width: (in): &nbsp;.  <para>width of the new surface </para>
 * @height: (in): &nbsp;.  <para>height of the new surface </para>
 * 
 * Creates a new surface.
 */
/**
 * plank_surface_new_with_cairo_surface:
 * @width: (in): &nbsp;.  <para>width of the new surface </para>
 * @height: (in): &nbsp;.  <para>height of the new surface </para>
 * @model: (in): &nbsp;.  <para>existing <link linkend="cairo-surface-t"><type>cairo_surface_t</type></link> to be similar to </para>
 * 
 * Creates a new surface compatible with an existing <link linkend="cairo-surface-t"><type>cairo_surface_t</type></link>.
 */
/**
 * plank_surface_new_with_surface:
 * @width: (in): &nbsp;.  <para>width of the new surface </para>
 * @height: (in): &nbsp;.  <para>height of the new surface </para>
 * @model: (in): &nbsp;.  <para>existing <link linkend="plank-surface-new"><function>plank_surface_new()</function></link> to be similar to </para>
 * 
 * Creates a new surface compatible with an existing <link linkend="plank-surface-new"><function>plank_surface_new()</function></link>.
 */
/**
 * plank_surface_new_with_internal:
 * @image: (in): &nbsp;.  <para>existing <link linkend="cairo-surface-t"><type>cairo_surface_t</type></link> as Internal </para>
 * 
 * Creates a new surface with the given <link linkend="cairo-surface-t"><type>cairo_surface_t</type></link> as Internal.
 */
/**
 * PlankSurface:Internal:
 * 
 * The internal <link linkend="cairo-surface-t"><type>cairo_surface_t</type></link> backing the surface.
 */
/**
 * plank_surface_get_Internal:
 * @self: the <link linkend="PlankSurface"><type>PlankSurface</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankSurface--Internal"><type>"Internal"</type></link> property.
 * 
 * The internal <link linkend="cairo-surface-t"><type>cairo_surface_t</type></link> backing the surface.
 * 
 * Returns: the value of the <link linkend="PlankSurface--Internal"><type>"Internal"</type></link> property
 */
/**
 * PlankSurface:Width:
 * 
 * The width of the surface.
 */
/**
 * plank_surface_get_Width:
 * @self: the <link linkend="PlankSurface"><type>PlankSurface</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankSurface--Width"><type>"Width"</type></link> property.
 * 
 * The width of the surface.
 * 
 * Returns: the value of the <link linkend="PlankSurface--Width"><type>"Width"</type></link> property
 */
/**
 * PlankSurface:Height:
 * 
 * The height of the surface.
 */
/**
 * plank_surface_get_Height:
 * @self: the <link linkend="PlankSurface"><type>PlankSurface</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankSurface--Height"><type>"Height"</type></link> property.
 * 
 * The height of the surface.
 * 
 * Returns: the value of the <link linkend="PlankSurface--Height"><type>"Height"</type></link> property
 */
/**
 * PlankSurface:Context:
 * 
 * A <link linkend="cairo-t"><type>cairo_t</type></link> for the surface.
 */
/**
 * plank_surface_get_Context:
 * @self: the <link linkend="PlankSurface"><type>PlankSurface</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankSurface--Context"><type>"Context"</type></link> property.
 * 
 * A <link linkend="cairo-t"><type>cairo_t</type></link> for the surface.
 * 
 * Returns: the value of the <link linkend="PlankSurface--Context"><type>"Context"</type></link> property
 */
/**
 * PlankSurface:
 * 
 * A surface is a wrapper class for a <link linkend="cairo-surface-t"><type>cairo_surface_t</type></link>. It encapsulates a surface/context and provides utility methods.
 */
/**
 * PlankSurfaceClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-SURFACE:CAPS"><literal>PLANK_TYPE_SURFACE</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
