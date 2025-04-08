/**
 * SECTION:DockItemDrawValue
 * @short_description: Contains all positions and modifications to draw a dock-item on the dock
 */
/**
 * PLANK_TYPE_DOCK_ITEM_DRAW_VALUE:
 * 
 * The type for <link linkend="PlankDockItemDrawValue"><type>PlankDockItemDrawValue</type></link>.
 */
/**
 * plank_dock_item_draw_value_move_in:
 * @self: the <link linkend="PlankDockItemDrawValue"><type>PlankDockItemDrawValue</type></link> instance
 * @position: &nbsp;
 * @damount: &nbsp;
 */
/**
 * plank_dock_item_draw_value_move_right:
 * @self: the <link linkend="PlankDockItemDrawValue"><type>PlankDockItemDrawValue</type></link> instance
 * @position: &nbsp;
 * @damount: &nbsp;
 */
/**
 * plank_dock_item_draw_value_new:
 */
/**
 * PlankDockItemDrawValue:
 * 
 * Contains all positions and modifications to draw a dock-item on the dock
 */
/**
 * plank_dock_item_draw_value_ref:
 * @instance: a <link linkend="PlankDockItemDrawValue"><type>PlankDockItemDrawValue</type></link>.
 * 
 * Increases the reference count of @object.
 * 
 * Returns: the same @object
 */
/**
 * plank_dock_item_draw_value_unref:
 * @instance: a <link linkend="PlankDockItemDrawValue"><type>PlankDockItemDrawValue</type></link>.
 * 
 * Decreases the reference count of @object. When its reference count drops to 0, the object is finalized (i.e. its memory is freed).
 */
/**
 * plank_param_spec_dock_item_draw_value:
 * @name: canonical name of the property specified
 * @nick: nick name for the property specified
 * @blurb: description of the property specified
 * @object_type: <link linkend="PLANK-TYPE-DOCK-ITEM-DRAW-VALUE:CAPS"><literal>PLANK_TYPE_DOCK_ITEM_DRAW_VALUE</literal></link> derived type of this property
 * @flags: flags for the property specified
 * 
 * Creates a new <link linkend="GParamSpecBoxed"><type>GParamSpecBoxed</type></link> instance specifying a <link linkend="PLANK-TYPE-DOCK-ITEM-DRAW-VALUE:CAPS"><literal>PLANK_TYPE_DOCK_ITEM_DRAW_VALUE</literal></link> derived property.
 * 
 * See <link linkend="g-param-spec-internal"><function>g_param_spec_internal()</function></link> for details on property names.
 */
/**
 * plank_value_set_dock_item_draw_value:
 * @value: a valid <link linkend="GValue"><type>GValue</type></link> of <link linkend="PLANK-TYPE-DOCK-ITEM-DRAW-VALUE:CAPS"><literal>PLANK_TYPE_DOCK_ITEM_DRAW_VALUE</literal></link> derived type
 * @v_object: object value to be set
 * 
 * Set the contents of a <link linkend="PLANK-TYPE-DOCK-ITEM-DRAW-VALUE:CAPS"><literal>PLANK_TYPE_DOCK_ITEM_DRAW_VALUE</literal></link> derived <link linkend="GValue"><type>GValue</type></link> to @v_object.
 * 
 * <link linkend="plank-value-set-dock-item-draw-value"><function>plank_value_set_dock_item_draw_value()</function></link> increases the reference count of @v_object (the <link linkend="GValue"><type>GValue</type></link> holds a reference to @v_object). If you do not wish to increase the reference count of the object (i.e. you wish to pass your current reference to the <link linkend="GValue"><type>GValue</type></link> because you no longer need it), use <link linkend="plank-value-take-dock-item-draw-value"><function>plank_value_take_dock_item_draw_value()</function></link> instead.
 * 
 * It is important that your <link linkend="GValue"><type>GValue</type></link> holds a reference to @v_object (either its own, or one it has taken) to ensure that the object won't be destroyed while the <link linkend="GValue"><type>GValue</type></link> still exists).
 */
/**
 * plank_value_get_dock_item_draw_value:
 * @value: a valid <link linkend="GValue"><type>GValue</type></link> of <link linkend="PLANK-TYPE-DOCK-ITEM-DRAW-VALUE:CAPS"><literal>PLANK_TYPE_DOCK_ITEM_DRAW_VALUE</literal></link> derived type
 * 
 * Get the contents of a <link linkend="PLANK-TYPE-DOCK-ITEM-DRAW-VALUE:CAPS"><literal>PLANK_TYPE_DOCK_ITEM_DRAW_VALUE</literal></link> derived <link linkend="GValue"><type>GValue</type></link>.
 * 
 * Returns: object contents of @value
 */
/**
 * plank_value_take_dock_item_draw_value:
 * @value: a valid <link linkend="GValue"><type>GValue</type></link> of <link linkend="PLANK-TYPE-DOCK-ITEM-DRAW-VALUE:CAPS"><literal>PLANK_TYPE_DOCK_ITEM_DRAW_VALUE</literal></link> derived type
 * @v_object: object value to be set
 * 
 * Sets the contents of a <link linkend="PLANK-TYPE-DOCK-ITEM-DRAW-VALUE:CAPS"><literal>PLANK_TYPE_DOCK_ITEM_DRAW_VALUE</literal></link> derived <link linkend="GValue"><type>GValue</type></link> to @v_object and takes over the ownership of the callers reference to @v_object; the caller doesn't have to unref it any more (i.e. the reference count of the object is not increased).
 * 
 * If you want the GValue to hold its own reference to @v_object, use <link linkend="plank-value-set-dock-item-draw-value"><function>plank_value_set_dock_item_draw_value()</function></link> instead.
 */
/**
 * PlankDockItemDrawValueClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-DOCK-ITEM-DRAW-VALUE:CAPS"><literal>PLANK_TYPE_DOCK_ITEM_DRAW_VALUE</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
/**
 * PlankDrawValueFunc:
 * @item: (in): &nbsp;.  <para>the dock-item </para>
 * @draw_value: (in): &nbsp;.  <para>the dock-item&apos;s drawvalue </para>
 * @user_data: (closure): data to pass to the delegate function
 * 
 * Modify the given DrawItemValue
 */
/**
 * PlankDrawValuesFunc:
 * @draw_values: (in): &nbsp;.  <para>the map of dock-items with their draw-values </para>
 * @user_data: (closure): data to pass to the delegate function
 * 
 * Modify all given DrawItemValues
 */
/**
 * PlankPointD:
 */
/**
 * plank_point_d_dup:
 * @self: the instance to duplicate
 * 
 * Creates a copy of self.
 * 
 * <emphasis>See also</emphasis>: plank_point_d_copy(), plank_point_d_destroy(), plank_point_d_free()
 * 
 * Returns: a copy of @self, free with plank_point_d_free()
 */
/**
 * plank_point_d_free:
 * @self: the struct to free
 * 
 * Frees the heap-allocated struct.
 * 
 * <emphasis>See also</emphasis>: plank_point_d_dup(), plank_point_d_copy(), plank_point_d_destroy()
 */
/**
 * plank_point_d_copy:
 * @self: the struct to copy
 * @dest: a unused struct. Use plank_point_d_destroy() to free the content.
 * 
 * Creates a copy of self.
 * 
 * <emphasis>See also</emphasis>: plank_point_d_dup(), plank_point_d_destroy(), plank_point_d_free()
 */
/**
 * plank_point_d_destroy:
 * @self: the struct to destroy
 * 
 * Frees the content of the struct pointed by @self.
 * 
 * <emphasis>See also</emphasis>: plank_point_d_dup(), plank_point_d_copy(), plank_point_d_free()
 */
