/**
 * SECTION:SurfaceCache
 * @short_description: Cache multiple sizes of the assumed same image
 */
/**
 * PLANK_TYPE_SURFACE_CACHE:
 * 
 * The type for <link linkend="PlankSurfaceCache"><type>PlankSurfaceCache</type></link>.
 */
/**
 * plank_surface_cache_get_surface:
 * @self: the <link linkend="PlankSurfaceCache"><type>PlankSurfaceCache</type></link> instance
 * @g_type: The #GType for @g
 * @g_dup_func: A dup function for @g_type
 * @g_destroy_func: A destroy function for @g_type
 * @draw_func_target: (allow-none) (closure): user data to pass to @draw_func
 * @draw_data_func_target: (allow-none) (closure): user data to pass to @draw_data_func
 * @width: &nbsp;
 * @height: &nbsp;
 * @model: &nbsp;
 * @draw_func: &nbsp;
 * @draw_data_func: &nbsp;
 */
/**
 * plank_surface_cache_clear:
 * @self: the <link linkend="PlankSurfaceCache"><type>PlankSurfaceCache</type></link> instance
 */
/**
 * plank_surface_cache_new:
 * @g_type: A #GType
 * @g_dup_func: A dup function for @g_type
 * @g_destroy_func: A destroy function for @g_type
 * @flags: &nbsp;
 */
/**
 * PlankSurfaceCache:flags:
 */
/**
 * plank_surface_cache_get_flags:
 * @self: the <link linkend="PlankSurfaceCache"><type>PlankSurfaceCache</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankSurfaceCache--flags"><type>"flags"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankSurfaceCache--flags"><type>"flags"</type></link> property
 */
/**
 * plank_surface_cache_set_flags:
 * @self: the <link linkend="PlankSurfaceCache"><type>PlankSurfaceCache</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankSurfaceCache--flags"><type>"flags"</type></link> property
 * 
 * Set the value of the <link linkend="PlankSurfaceCache--flags"><type>"flags"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankSurfaceCache:
 * 
 * Cache multiple sizes of the assumed same image
 */
/**
 * PlankSurfaceCacheClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-SURFACE-CACHE:CAPS"><literal>PLANK_TYPE_SURFACE_CACHE</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
/**
 * PlankDrawFunc:
 * @width: (in): &nbsp;.  <para>the width </para>
 * @height: (in): &nbsp;.  <para>the height </para>
 * @model: (in): &nbsp;.  <para>existing surface to use as basis of new surface </para>
 * @draw_data_func: (in) (allow-none): &nbsp;.  <para>function which changes the surface </para>
 * @draw_data_func_target: (allow-none) (closure): user data to pass to @draw_data_func
 * @user_data: (closure): data to pass to the delegate function
 * 
 * Creates a new surface based on the given information
 * 
 * Returns: <para>the newly created surface or NULL </para>
 */
/**
 * PlankDrawDataFunc:
 * @width: (in): &nbsp;.  <para>the width </para>
 * @height: (in): &nbsp;.  <para>the height </para>
 * @model: (in): &nbsp;.  <para>existing surface to use as basis of new surface </para>
 * @data: (in): &nbsp;.  <para>the data object used for drawing </para>
 * @user_data: (closure): data to pass to the delegate function
 * 
 * Creates a new surface using the given element and information
 * 
 * Returns: <para>the newly created surface or NULL </para>
 */
/**
 * PlankSurfaceCacheFlags:
 * @PLANK_SURFACE_CACHE_FLAGS_ALLOW_DOWNSCALE: Allow down-scaling of an existing cached surface for better performance
 * @PLANK_SURFACE_CACHE_FLAGS_ALLOW_UPSCALE: Allow up-scaling of an existing cached surface for better performance
 * @PLANK_SURFACE_CACHE_FLAGS_ALLOW_SCALE: Allow scaling of an existing cached surface for better performance (This basically means the cache will only contain one entry which will be scaled accordingly on request)
 * @PLANK_SURFACE_CACHE_FLAGS_ADAPTIVE_SCALE: Allow scaling if the drawing-time is significatly high
 * 
 * Controls some internal behaviors of a <link linkend="PlankSurfaceCache"><type>PlankSurfaceCache</type></link>
 */
