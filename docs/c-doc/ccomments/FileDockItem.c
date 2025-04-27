/**
 * SECTION:FileDockItem
 * @short_description: A dock item for files or folders on the dock.
 * 
 * <para>Folders act like stacks and display the contents of the folder in the popup menu. Files just open the associated file.</para>
 */
/**
 * PLANK_TYPE_FILE_DOCK_ITEM:
 * 
 * The type for <link linkend="PlankFileDockItem"><type>PlankFileDockItem</type></link>.
 */
/**
 * PLANK_FILE_DOCK_ITEM_TYPE_FILE_SORT_DATA:
 * 
 * The type for <link linkend="PlankFileDockItemFileSortData"><type>PlankFileDockItemFileSortData</type></link>.
 */
/**
 * plank_file_dock_item_file_sort_data_new:
 * @creation_date: &nbsp;
 * @modified_date: &nbsp;
 * @display_name: &nbsp;
 * @content_type: &nbsp;
 * @size: &nbsp;
 * @menu_item: &nbsp;
 */
/**
 * PlankFileDockItemFileSortData:creation-date:
 */
/**
 * plank_file_dock_item_file_sort_data_get_creation_date:
 * @self: the <link linkend="PlankFileDockItemFileSortData"><type>PlankFileDockItemFileSortData</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankFileDockItemFileSortData--creation-date"><type>"creation-date"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankFileDockItemFileSortData--creation-date"><type>"creation-date"</type></link> property
 */
/**
 * PlankFileDockItemFileSortData:modified-date:
 */
/**
 * plank_file_dock_item_file_sort_data_get_modified_date:
 * @self: the <link linkend="PlankFileDockItemFileSortData"><type>PlankFileDockItemFileSortData</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankFileDockItemFileSortData--modified-date"><type>"modified-date"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankFileDockItemFileSortData--modified-date"><type>"modified-date"</type></link> property
 */
/**
 * PlankFileDockItemFileSortData:display-name:
 */
/**
 * plank_file_dock_item_file_sort_data_get_display_name:
 * @self: the <link linkend="PlankFileDockItemFileSortData"><type>PlankFileDockItemFileSortData</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankFileDockItemFileSortData--display-name"><type>"display-name"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankFileDockItemFileSortData--display-name"><type>"display-name"</type></link> property
 */
/**
 * PlankFileDockItemFileSortData:content-type:
 */
/**
 * plank_file_dock_item_file_sort_data_get_content_type:
 * @self: the <link linkend="PlankFileDockItemFileSortData"><type>PlankFileDockItemFileSortData</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankFileDockItemFileSortData--content-type"><type>"content-type"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankFileDockItemFileSortData--content-type"><type>"content-type"</type></link> property
 */
/**
 * PlankFileDockItemFileSortData:size:
 */
/**
 * plank_file_dock_item_file_sort_data_get_size:
 * @self: the <link linkend="PlankFileDockItemFileSortData"><type>PlankFileDockItemFileSortData</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankFileDockItemFileSortData--size"><type>"size"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankFileDockItemFileSortData--size"><type>"size"</type></link> property
 */
/**
 * PlankFileDockItemFileSortData:menu-item:
 */
/**
 * plank_file_dock_item_file_sort_data_get_menu_item:
 * @self: the <link linkend="PlankFileDockItemFileSortData"><type>PlankFileDockItemFileSortData</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankFileDockItemFileSortData--menu-item"><type>"menu-item"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankFileDockItemFileSortData--menu-item"><type>"menu-item"</type></link> property
 */
/**
 * PlankFileDockItemFileSortData:
 */
/**
 * plank_file_dock_item_file_sort_data_ref:
 * @instance: a <link linkend="PlankFileDockItemFileSortData"><type>PlankFileDockItemFileSortData</type></link>.
 * 
 * Increases the reference count of @object.
 * 
 * Returns: the same @object
 */
/**
 * plank_file_dock_item_file_sort_data_unref:
 * @instance: a <link linkend="PlankFileDockItemFileSortData"><type>PlankFileDockItemFileSortData</type></link>.
 * 
 * Decreases the reference count of @object. When its reference count drops to 0, the object is finalized (i.e. its memory is freed).
 */
/**
 * plank_file_dock_item_param_spec_file_sort_data:
 * @name: canonical name of the property specified
 * @nick: nick name for the property specified
 * @blurb: description of the property specified
 * @object_type: <link linkend="PLANK-FILE-DOCK-ITEM-TYPE-FILE-SORT-DATA:CAPS"><literal>PLANK_FILE_DOCK_ITEM_TYPE_FILE_SORT_DATA</literal></link> derived type of this property
 * @flags: flags for the property specified
 * 
 * Creates a new <link linkend="GParamSpecBoxed"><type>GParamSpecBoxed</type></link> instance specifying a <link linkend="PLANK-FILE-DOCK-ITEM-TYPE-FILE-SORT-DATA:CAPS"><literal>PLANK_FILE_DOCK_ITEM_TYPE_FILE_SORT_DATA</literal></link> derived property.
 * 
 * See <link linkend="g-param-spec-internal"><function>g_param_spec_internal()</function></link> for details on property names.
 */
/**
 * plank_file_dock_item_value_set_file_sort_data:
 * @value: a valid <link linkend="GValue"><type>GValue</type></link> of <link linkend="PLANK-FILE-DOCK-ITEM-TYPE-FILE-SORT-DATA:CAPS"><literal>PLANK_FILE_DOCK_ITEM_TYPE_FILE_SORT_DATA</literal></link> derived type
 * @v_object: object value to be set
 * 
 * Set the contents of a <link linkend="PLANK-FILE-DOCK-ITEM-TYPE-FILE-SORT-DATA:CAPS"><literal>PLANK_FILE_DOCK_ITEM_TYPE_FILE_SORT_DATA</literal></link> derived <link linkend="GValue"><type>GValue</type></link> to @v_object.
 * 
 * <link linkend="plank-file-dock-item-value-set-file-sort-data"><function>plank_file_dock_item_value_set_file_sort_data()</function></link> increases the reference count of @v_object (the <link linkend="GValue"><type>GValue</type></link> holds a reference to @v_object). If you do not wish to increase the reference count of the object (i.e. you wish to pass your current reference to the <link linkend="GValue"><type>GValue</type></link> because you no longer need it), use <link linkend="plank-file-dock-item-value-take-file-sort-data"><function>plank_file_dock_item_value_take_file_sort_data()</function></link> instead.
 * 
 * It is important that your <link linkend="GValue"><type>GValue</type></link> holds a reference to @v_object (either its own, or one it has taken) to ensure that the object won't be destroyed while the <link linkend="GValue"><type>GValue</type></link> still exists).
 */
/**
 * plank_file_dock_item_value_get_file_sort_data:
 * @value: a valid <link linkend="GValue"><type>GValue</type></link> of <link linkend="PLANK-FILE-DOCK-ITEM-TYPE-FILE-SORT-DATA:CAPS"><literal>PLANK_FILE_DOCK_ITEM_TYPE_FILE_SORT_DATA</literal></link> derived type
 * 
 * Get the contents of a <link linkend="PLANK-FILE-DOCK-ITEM-TYPE-FILE-SORT-DATA:CAPS"><literal>PLANK_FILE_DOCK_ITEM_TYPE_FILE_SORT_DATA</literal></link> derived <link linkend="GValue"><type>GValue</type></link>.
 * 
 * Returns: object contents of @value
 */
/**
 * plank_file_dock_item_value_take_file_sort_data:
 * @value: a valid <link linkend="GValue"><type>GValue</type></link> of <link linkend="PLANK-FILE-DOCK-ITEM-TYPE-FILE-SORT-DATA:CAPS"><literal>PLANK_FILE_DOCK_ITEM_TYPE_FILE_SORT_DATA</literal></link> derived type
 * @v_object: object value to be set
 * 
 * Sets the contents of a <link linkend="PLANK-FILE-DOCK-ITEM-TYPE-FILE-SORT-DATA:CAPS"><literal>PLANK_FILE_DOCK_ITEM_TYPE_FILE_SORT_DATA</literal></link> derived <link linkend="GValue"><type>GValue</type></link> to @v_object and takes over the ownership of the callers reference to @v_object; the caller doesn't have to unref it any more (i.e. the reference count of the object is not increased).
 * 
 * If you want the GValue to hold its own reference to @v_object, use <link linkend="plank-file-dock-item-value-set-file-sort-data"><function>plank_file_dock_item_value_set_file_sort_data()</function></link> instead.
 */
/**
 * PlankFileDockItemFileSortDataClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-FILE-DOCK-ITEM-TYPE-FILE-SORT-DATA:CAPS"><literal>PLANK_FILE_DOCK_ITEM_TYPE_FILE_SORT_DATA</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
/**
 * plank_file_dock_item_new_with_file:
 * @file: &nbsp;
 */
/**
 * plank_file_dock_item_new_with_dockitem_file:
 * @file: &nbsp;
 */
/**
 * plank_file_dock_item_new_with_dockitem_filename:
 * @filename: &nbsp;
 */
/**
 * plank_file_dock_item_new:
 */
/**
 * PlankFileDockItem:OwnedFile:
 */
/**
 * plank_file_dock_item_get_OwnedFile:
 * @self: the <link linkend="PlankFileDockItem"><type>PlankFileDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankFileDockItem--OwnedFile"><type>"OwnedFile"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankFileDockItem--OwnedFile"><type>"OwnedFile"</type></link> property
 */
/**
 * plank_file_dock_item_set_OwnedFile:
 * @self: the <link linkend="PlankFileDockItem"><type>PlankFileDockItem</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankFileDockItem--OwnedFile"><type>"OwnedFile"</type></link> property
 * 
 * Set the value of the <link linkend="PlankFileDockItem--OwnedFile"><type>"OwnedFile"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankFileDockItem:
 * 
 * A dock item for files or folders on the dock.
 * 
 * <para>Folders act like stacks and display the contents of the folder in the popup menu. Files just open the associated file.</para>
 */
/**
 * PlankFileDockItemClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-FILE-DOCK-ITEM:CAPS"><literal>PLANK_TYPE_FILE_DOCK_ITEM</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
