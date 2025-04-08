/**
 * SECTION:DockItem
 * @short_description: The base class for all dock items.
 */
/**
 * PLANK_TYPE_DOCK_ITEM:
 * 
 * The type for <link linkend="PlankDockItem"><type>PlankDockItem</type></link>.
 */
/**
 * plank_dock_item_load_from_launcher:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance
 * 
 * Parses the associated launcher and e.g. sets the icon and text from it.
 */
/**
 * plank_dock_item_delete:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance
 * 
 * Deletes the underlying preferences file.
 */
/**
 * plank_dock_item_is_separator:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance
 * 
 * The item is a separator.
 */
/**
 * plank_dock_item_reset_icon_buffer:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance
 * 
 * Resets the buffer for this item&apos;s icon and requests a redraw.
 */
/**
 * plank_dock_item_unset_move_state:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance
 */
/**
 * plank_dock_item_get_surface:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance
 * @width: (in): &nbsp;.  <para>width of the icon surface </para>
 * @height: (in): &nbsp;.  <para>height of the icon surface </para>
 * @model: (in): &nbsp;.  <para>existing surface to use as basis of new surface </para>
 * 
 * Returns the surface for this item.
 * 
 * <para>It might trigger an internal redraw if the requested size isn&apos;t cached yet.</para>
 * 
 * Returns: <para>the surface for this item which may not be changed </para>
 */
/**
 * plank_dock_item_get_background_surface:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance
 * @draw_data_func: (in) (allow-none): &nbsp;.  <para>function which creates/changes the background surface </para>
 * @draw_data_func_target: (allow-none) (closure): user data to pass to @draw_data_func
 * @width: &nbsp;
 * @height: &nbsp;
 * @model: &nbsp;
 * 
 * Returns the background surface for this item.
 * 
 * <para>The draw_func may pass through the given previously computed surface or change it as needed. This surface will be buffered internally.</para><para>Passing null as draw_func will destroy the internal background buffer.</para>
 * 
 * Returns: <para>the background surface of this item which may not be changed </para>
 */
/**
 * plank_dock_item_get_foreground_surface:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance
 * @draw_data_func: (in) (allow-none): &nbsp;.  <para>function which creates/changes the foreground surface </para>
 * @draw_data_func_target: (allow-none) (closure): user data to pass to @draw_data_func
 * @width: &nbsp;
 * @height: &nbsp;
 * @model: &nbsp;
 * 
 * Returns the foreground surface for this item.
 * 
 * <para>The draw_func may pass through the given previously computed surface or change it as needed. This surface will be buffered internally.</para><para>Passing null as draw_func will destroy the internal foreground buffer.</para>
 * 
 * Returns: <para>the background surface of this item which may not be changed </para>
 */
/**
 * plank_dock_item_get_surface_copy:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance
 * @width: (in): &nbsp;.  <para>width of the icon surface </para>
 * @height: (in): &nbsp;.  <para>height of the icon surface </para>
 * @model: (in): &nbsp;.  <para>existing surface to use as basis of new surface </para>
 * 
 * Returns a copy of the surface for this item.
 * 
 * <para>It will trigger an internal redraw if the requested size isn&apos;t matching the cache.</para>
 * 
 * Returns: <para>the copied surface for this item </para>
 */
/**
 * plank_dock_item_draw_icon:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance
 * @surface: (in): &nbsp;.  <para>the surface to draw on </para>
 * 
 * Draws the item&apos;s icon onto a surface.
 */
/**
 * plank_dock_item_draw_icon_fast:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance
 * @surface: (in): &nbsp;.  <para>the surface to draw on </para>
 * 
 * Draws a placeholder icon onto a surface. This method should be considered time-critical! Make sure to only use simple drawing routines, and do not rely on external resources!
 */
/**
 * plank_dock_item_is_valid:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance
 * 
 * Check the validity of this item.
 * 
 * Returns: <para>Whether or not this item is valid for the .dockitem given </para>
 */
/**
 * plank_dock_item_copy_values_to:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance
 * @target: (in): &nbsp;.  <para>the dockitem to copy the values to </para>
 * 
 * Copy all property value of this dockitem instance to target instance.
 */
/**
 * PlankDockItem:Icon:
 * 
 * The dock item&apos;s icon.
 */
/**
 * plank_dock_item_get_Icon:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockItem--Icon"><type>"Icon"</type></link> property.
 * 
 * The dock item&apos;s icon.
 * 
 * Returns: the value of the <link linkend="PlankDockItem--Icon"><type>"Icon"</type></link> property
 */
/**
 * plank_dock_item_set_Icon:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockItem--Icon"><type>"Icon"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockItem--Icon"><type>"Icon"</type></link> property to @value.
 * 
 * The dock item&apos;s icon.
 */
/**
 * PlankDockItem:ForcePixbuf:
 */
/**
 * plank_dock_item_get_ForcePixbuf:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockItem--ForcePixbuf"><type>"ForcePixbuf"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockItem--ForcePixbuf"><type>"ForcePixbuf"</type></link> property
 */
/**
 * plank_dock_item_set_ForcePixbuf:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockItem--ForcePixbuf"><type>"ForcePixbuf"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockItem--ForcePixbuf"><type>"ForcePixbuf"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockItem:Count:
 * 
 * The count for the dock item.
 */
/**
 * plank_dock_item_get_Count:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockItem--Count"><type>"Count"</type></link> property.
 * 
 * The count for the dock item.
 * 
 * Returns: the value of the <link linkend="PlankDockItem--Count"><type>"Count"</type></link> property
 */
/**
 * plank_dock_item_set_Count:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockItem--Count"><type>"Count"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockItem--Count"><type>"Count"</type></link> property to @value.
 * 
 * The count for the dock item.
 */
/**
 * PlankDockItem:CountVisible:
 * 
 * Show the item&apos;s count or not.
 */
/**
 * plank_dock_item_get_CountVisible:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockItem--CountVisible"><type>"CountVisible"</type></link> property.
 * 
 * Show the item&apos;s count or not.
 * 
 * Returns: the value of the <link linkend="PlankDockItem--CountVisible"><type>"CountVisible"</type></link> property
 */
/**
 * plank_dock_item_set_CountVisible:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockItem--CountVisible"><type>"CountVisible"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockItem--CountVisible"><type>"CountVisible"</type></link> property to @value.
 * 
 * Show the item&apos;s count or not.
 */
/**
 * PlankDockItem:Progress:
 * 
 * The progress for this dock item.
 */
/**
 * plank_dock_item_get_Progress:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockItem--Progress"><type>"Progress"</type></link> property.
 * 
 * The progress for this dock item.
 * 
 * Returns: the value of the <link linkend="PlankDockItem--Progress"><type>"Progress"</type></link> property
 */
/**
 * plank_dock_item_set_Progress:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockItem--Progress"><type>"Progress"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockItem--Progress"><type>"Progress"</type></link> property to @value.
 * 
 * The progress for this dock item.
 */
/**
 * PlankDockItem:ProgressVisible:
 * 
 * Show the item&apos;s progress or not.
 */
/**
 * plank_dock_item_get_ProgressVisible:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockItem--ProgressVisible"><type>"ProgressVisible"</type></link> property.
 * 
 * Show the item&apos;s progress or not.
 * 
 * Returns: the value of the <link linkend="PlankDockItem--ProgressVisible"><type>"ProgressVisible"</type></link> property
 */
/**
 * plank_dock_item_set_ProgressVisible:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockItem--ProgressVisible"><type>"ProgressVisible"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockItem--ProgressVisible"><type>"ProgressVisible"</type></link> property to @value.
 * 
 * Show the item&apos;s progress or not.
 */
/**
 * PlankDockItem:AllowZoom:
 * 
 * Should this item allow Zooming.
 */
/**
 * plank_dock_item_get_AllowZoom:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockItem--AllowZoom"><type>"AllowZoom"</type></link> property.
 * 
 * Should this item allow Zooming.
 * 
 * Returns: the value of the <link linkend="PlankDockItem--AllowZoom"><type>"AllowZoom"</type></link> property
 */
/**
 * plank_dock_item_set_AllowZoom:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockItem--AllowZoom"><type>"AllowZoom"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockItem--AllowZoom"><type>"AllowZoom"</type></link> property to @value.
 * 
 * Should this item allow Zooming.
 */
/**
 * PlankDockItem:Position:
 * 
 * The dock item&apos;s position on the dock.
 */
/**
 * plank_dock_item_get_Position:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockItem--Position"><type>"Position"</type></link> property.
 * 
 * The dock item&apos;s position on the dock.
 * 
 * Returns: the value of the <link linkend="PlankDockItem--Position"><type>"Position"</type></link> property
 */
/**
 * plank_dock_item_set_Position:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockItem--Position"><type>"Position"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockItem--Position"><type>"Position"</type></link> property to @value.
 * 
 * The dock item&apos;s position on the dock.
 */
/**
 * PlankDockItem:LastPosition:
 * 
 * The dock item&apos;s last position on the dock.
 */
/**
 * plank_dock_item_get_LastPosition:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockItem--LastPosition"><type>"LastPosition"</type></link> property.
 * 
 * The dock item&apos;s last position on the dock.
 * 
 * Returns: the value of the <link linkend="PlankDockItem--LastPosition"><type>"LastPosition"</type></link> property
 */
/**
 * plank_dock_item_set_LastPosition:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockItem--LastPosition"><type>"LastPosition"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockItem--LastPosition"><type>"LastPosition"</type></link> property to @value.
 * 
 * The dock item&apos;s last position on the dock.
 */
/**
 * PlankDockItem:State:
 * 
 * The item&apos;s current state.
 */
/**
 * plank_dock_item_get_State:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockItem--State"><type>"State"</type></link> property.
 * 
 * The item&apos;s current state.
 * 
 * Returns: the value of the <link linkend="PlankDockItem--State"><type>"State"</type></link> property
 */
/**
 * plank_dock_item_set_State:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockItem--State"><type>"State"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockItem--State"><type>"State"</type></link> property to @value.
 * 
 * The item&apos;s current state.
 */
/**
 * PlankDockItem:Indicator:
 * 
 * The indicator shown for the item.
 */
/**
 * plank_dock_item_get_Indicator:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockItem--Indicator"><type>"Indicator"</type></link> property.
 * 
 * The indicator shown for the item.
 * 
 * Returns: the value of the <link linkend="PlankDockItem--Indicator"><type>"Indicator"</type></link> property
 */
/**
 * plank_dock_item_set_Indicator:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockItem--Indicator"><type>"Indicator"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockItem--Indicator"><type>"Indicator"</type></link> property to @value.
 * 
 * The indicator shown for the item.
 */
/**
 * PlankDockItem:AverageIconColor:
 * 
 * The average color of this item&apos;s icon.
 */
/**
 * plank_dock_item_get_AverageIconColor:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockItem--AverageIconColor"><type>"AverageIconColor"</type></link> property.
 * 
 * The average color of this item&apos;s icon.
 * 
 * Returns: the value of the <link linkend="PlankDockItem--AverageIconColor"><type>"AverageIconColor"</type></link> property
 */
/**
 * plank_dock_item_set_AverageIconColor:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockItem--AverageIconColor"><type>"AverageIconColor"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockItem--AverageIconColor"><type>"AverageIconColor"</type></link> property to @value.
 * 
 * The average color of this item&apos;s icon.
 */
/**
 * PlankDockItem:DockItemFilename:
 * 
 * The filename of the preferences backing file.
 */
/**
 * plank_dock_item_get_DockItemFilename:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockItem--DockItemFilename"><type>"DockItemFilename"</type></link> property.
 * 
 * The filename of the preferences backing file.
 * 
 * Returns: the value of the <link linkend="PlankDockItem--DockItemFilename"><type>"DockItemFilename"</type></link> property
 */
/**
 * PlankDockItem:Launcher:
 * 
 * The launcher associated with this item.
 */
/**
 * plank_dock_item_get_Launcher:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockItem--Launcher"><type>"Launcher"</type></link> property.
 * 
 * The launcher associated with this item.
 * 
 * Returns: the value of the <link linkend="PlankDockItem--Launcher"><type>"Launcher"</type></link> property
 */
/**
 * PlankDockItem:Prefs:
 * 
 * The underlying preferences for this item.
 */
/**
 * plank_dock_item_get_Prefs:
 * @self: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockItem--Prefs"><type>"Prefs"</type></link> property.
 * 
 * The underlying preferences for this item.
 * 
 * Returns: the value of the <link linkend="PlankDockItem--Prefs"><type>"Prefs"</type></link> property
 */
/**
 * PlankDockItem::deleted:
 * @dock_item: the <link linkend="PlankDockItem"><type>PlankDockItem</type></link> instance that received the signal
 * 
 * Signal fired when the .dockitem for this item was deleted.
 */
/**
 * PlankDockItem:
 * 
 * The base class for all dock items.
 */
/**
 * PlankDockItemClass:
 * @load_from_launcher: virtual method used internally
 * @draw_icon: virtual method used internally
 * @draw_icon_fast: virtual method used internally
 * @is_valid: virtual method called by <link linkend="plank-dock-item-is-valid"><function>plank_dock_item_is_valid()</function></link>
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-DOCK-ITEM:CAPS"><literal>PLANK_TYPE_DOCK_ITEM</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
