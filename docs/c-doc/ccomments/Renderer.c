/**
 * SECTION:Renderer
 * @short_description: Handles animated rendering. Uses a timer and continues requesting redraws for a widget until no more animation is needed.
 */
/**
 * PLANK_TYPE_RENDERER:
 * 
 * The type for <link linkend="PlankRenderer"><type>PlankRenderer</type></link>.
 */
/**
 * plank_renderer_animation_needed:
 * @self: the <link linkend="PlankRenderer"><type>PlankRenderer</type></link> instance
 * @frame_time: (in): &nbsp;.  <para>the current time for this frame&apos;s render </para>
 * 
 * Determines if animation should continue.
 * 
 * Returns: <para>if another animation frame is needed </para>
 */
/**
 * plank_renderer_initialize_frame:
 * @self: the <link linkend="PlankRenderer"><type>PlankRenderer</type></link> instance
 * @frame_time: (in): &nbsp;.  <para>the current time for this frame&apos;s render </para>
 * 
 * Preparations which are not requiring a drawing context yet.
 */
/**
 * plank_renderer_draw:
 * @self: the <link linkend="PlankRenderer"><type>PlankRenderer</type></link> instance
 * @cr: (in): &nbsp;.  <para>the context to use for drawing </para>
 * @frame_time: &nbsp;
 * 
 * Draws onto a context.
 */
/**
 * plank_renderer_force_frame_time_update:
 * @self: the <link linkend="PlankRenderer"><type>PlankRenderer</type></link> instance
 * 
 * Force an immediate update of the frame_time property.
 */
/**
 * plank_renderer_animated_draw:
 * @self: the <link linkend="PlankRenderer"><type>PlankRenderer</type></link> instance
 * 
 * Request re-drawing.
 */
/**
 * PlankRenderer:widget:
 */
/**
 * plank_renderer_get_widget:
 * @self: the <link linkend="PlankRenderer"><type>PlankRenderer</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankRenderer--widget"><type>"widget"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankRenderer--widget"><type>"widget"</type></link> property
 */
/**
 * PlankRenderer:frame-time:
 */
/**
 * plank_renderer_get_frame_time:
 * @self: the <link linkend="PlankRenderer"><type>PlankRenderer</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankRenderer--frame-time"><type>"frame-time"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankRenderer--frame-time"><type>"frame-time"</type></link> property
 */
/**
 * PlankRenderer:
 * 
 * Handles animated rendering. Uses a timer and continues requesting redraws for a widget until no more animation is needed.
 */
/**
 * PlankRendererClass:
 * @animation_needed: virtual method used internally
 * @initialize_frame: virtual method used internally
 * @draw: virtual method called by <link linkend="plank-renderer-draw"><function>plank_renderer_draw()</function></link>
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-RENDERER:CAPS"><literal>PLANK_TYPE_RENDERER</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
