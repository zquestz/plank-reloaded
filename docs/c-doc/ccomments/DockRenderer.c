/**
 * SECTION:DockRenderer
 * @short_description: Handles all of the drawing for a dock.
 */
/**
 * PLANK_TYPE_DOCK_RENDERER:
 * 
 * The type for <link linkend="PlankDockRenderer"><type>PlankDockRenderer</type></link>.
 */
/**
 * plank_dock_renderer_initialize:
 * @self: the <link linkend="PlankDockRenderer"><type>PlankDockRenderer</type></link> instance
 * 
 * Initializes the renderer. Call after the DockWindow is constructed.
 */
/**
 * plank_dock_renderer_reset_buffers:
 * @self: the <link linkend="PlankDockRenderer"><type>PlankDockRenderer</type></link> instance
 * 
 * Resets all internal buffers and forces a redraw.
 */
/**
 * plank_dock_renderer_update_local_cursor:
 * @self: the <link linkend="PlankDockRenderer"><type>PlankDockRenderer</type></link> instance
 * @x: &nbsp;
 * @y: &nbsp;
 */
/**
 * plank_dock_renderer_animate_items:
 * @self: the <link linkend="PlankDockRenderer"><type>PlankDockRenderer</type></link> instance
 * @elements: &nbsp;
 */
/**
 * plank_dock_renderer_new:
 * @controller: (in): &nbsp;.  <para>the dock controller to manage drawing for </para>
 * @window: (in): &nbsp;.  <para>the dock window to be animated </para>
 * 
 * Create a new dock renderer for a dock.
 */
/**
 * PlankDockRenderer:controller:
 */
/**
 * PlankDockRenderer:theme:
 */
/**
 * plank_dock_renderer_get_theme:
 * @self: the <link linkend="PlankDockRenderer"><type>PlankDockRenderer</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockRenderer--theme"><type>"theme"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockRenderer--theme"><type>"theme"</type></link> property
 */
/**
 * PlankDockRenderer:hide-progress:
 * 
 * The current progress [0.0..1.0] of the hide-animation of the dock.
 */
/**
 * plank_dock_renderer_get_hide_progress:
 * @self: the <link linkend="PlankDockRenderer"><type>PlankDockRenderer</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockRenderer--hide-progress"><type>"hide-progress"</type></link> property.
 * 
 * The current progress [0.0..1.0] of the hide-animation of the dock.
 * 
 * Returns: the value of the <link linkend="PlankDockRenderer--hide-progress"><type>"hide-progress"</type></link> property
 */
/**
 * PlankDockRenderer:zoom-in-progress:
 * 
 * The current progress [0.0..1.0] of the zoom-in-animation of the dock.
 */
/**
 * plank_dock_renderer_get_zoom_in_progress:
 * @self: the <link linkend="PlankDockRenderer"><type>PlankDockRenderer</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockRenderer--zoom-in-progress"><type>"zoom-in-progress"</type></link> property.
 * 
 * The current progress [0.0..1.0] of the zoom-in-animation of the dock.
 * 
 * Returns: the value of the <link linkend="PlankDockRenderer--zoom-in-progress"><type>"zoom-in-progress"</type></link> property
 */
/**
 * PlankDockRenderer:local-cursor:
 * 
 * The current local cursor-position on the dock if hovered.
 */
/**
 * plank_dock_renderer_get_local_cursor:
 * @self: the <link linkend="PlankDockRenderer"><type>PlankDockRenderer</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockRenderer--local-cursor"><type>"local-cursor"</type></link> property.
 * 
 * The current local cursor-position on the dock if hovered.
 * 
 * Returns: the value of the <link linkend="PlankDockRenderer--local-cursor"><type>"local-cursor"</type></link> property
 */
/**
 * PlankDockRenderer:
 * 
 * Handles all of the drawing for a dock.
 */
/**
 * PlankDockRendererClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-DOCK-RENDERER:CAPS"><literal>PLANK_TYPE_DOCK_RENDERER</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
