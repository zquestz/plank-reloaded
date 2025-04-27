/**
 * SECTION:PositionManager
 * @short_description: Handles computing any size/position information for the dock.
 */
/**
 * PLANK_TYPE_POSITION_MANAGER:
 * 
 * The type for <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link>.
 */
/**
 * plank_position_manager_initialize:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * 
 * Initializes the position manager.
 */
/**
 * plank_position_manager_update:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * @theme: (in): &nbsp;.  <para>the current dock theme </para>
 * 
 * Updates all internal caches.
 */
/**
 * plank_position_manager_is_horizontal_dock:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * 
 * Return whether or not a dock is a horizontal dock.
 * 
 * Returns: <para>true if the dock&apos;s position indicates it is horizontal </para>
 */
/**
 * plank_position_manager_get_cursor_region:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * 
 * Returns the cursor region for the dock. This is the region that the cursor can interact with the dock.
 * 
 * Returns: <para>the cursor region for the dock </para>
 */
/**
 * plank_position_manager_get_static_dock_region:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * 
 * Returns the static dock region for the dock. This is the region that the dock occupies when not hidden.
 * 
 * Returns: <para>the static dock region for the dock </para>
 */
/**
 * plank_position_manager_update_regions:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * 
 * Call when any cached region needs updating.
 */
/**
 * plank_position_manager_get_draw_value_for_item:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * @item: (in): &nbsp;.  <para>the dock item to find the drawvalue for </para>
 * 
 * The draw-value for a dock item.
 * 
 * Returns: <para>the region for the dock item </para>
 */
/**
 * plank_position_manager_update_draw_values:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * @items: (in): &nbsp;.  <para>the ordered list of all current item which are suppose to be shown on the dock </para>
 * @func: (in) (allow-none): &nbsp;.  <para>a function which adjusts the draw-value per item </para>
 * @func_target: (allow-none) (closure): user data to pass to @func
 * @post_func: (in) (allow-none): &nbsp;.  <para>a function which post-processes all draw-values </para>
 * @post_func_target: (allow-none) (closure): user data to pass to @post_func
 * 
 * Update and recalculated all internal draw-values using the given methodes for custom manipulations.
 */
/**
 * plank_position_manager_get_hover_region_for_element:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * @element: (in): &nbsp;.  <para>the dock element to find a region for </para>
 * 
 * The cursor region for interacting with a dock element.
 * 
 * Returns: <para>the region for the dock item </para>
 */
/**
 * plank_position_manager_get_nearest_item_at:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * @x: (in): &nbsp;.  <para>the x position </para>
 * @y: (in): &nbsp;.  <para>the y position </para>
 * @container: (in) (allow-none): &nbsp;.  <para>a container or NULL </para>
 * 
 * Get the item which is the nearest at the given coordinates. If a container is given the result will be restricted to its children.
 * 
 * Returns: (transfer none): 
 */
/**
 * plank_position_manager_get_current_target_item:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * @container: (in) (allow-none): &nbsp;.  <para>a container or NULL </para>
 * 
 * Get the item which is the appropriate target for a drag&apos;n&apos;drop action. The returned item may not hovered and is meant to be used as target for e.g. DockContainer.add/move_to functions. If a container is given the result will be restricted to its children.
 * 
 * Returns: (transfer none): 
 */
/**
 * plank_position_manager_get_menu_position:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * @hovered: (in): &nbsp;.  <para>the item that is hovered </para>
 * @requisition: (in): &nbsp;.  <para>the menu&apos;s requisition </para>
 * @x: (out): &nbsp;.  <para>the resulting x position </para>
 * @y: (out): &nbsp;.  <para>the resulting y position </para>
 * 
 * Get&apos;s the x and y position to display a menu for a dock item.
 */
/**
 * plank_position_manager_get_hover_position:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * @hovered: (in): &nbsp;.  <para>the item that is hovered </para>
 * @x: (out): &nbsp;.  <para>the resulting x position </para>
 * @y: (out): &nbsp;.  <para>the resulting y position </para>
 * 
 * Get&apos;s the x and y position to display a hover window for a dock item.
 */
/**
 * plank_position_manager_get_hover_position_at:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * @x: (inout): &nbsp;.  <para>the resulting x position </para>
 * @y: (inout): &nbsp;.  <para>the resulting y position </para>
 * 
 * Get&apos;s the x and y position to display a hover window for the given coordinates.
 */
/**
 * plank_position_manager_get_urgent_glow_position:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * @item: (in): &nbsp;.  <para>the item to show urgent-glow for </para>
 * @x: (out): &nbsp;.  <para>the resulting x position </para>
 * @y: (out): &nbsp;.  <para>the resulting y position </para>
 * 
 * Get&apos;s the x and y position to display the urgent-glow for a dock item.
 */
/**
 * plank_position_manager_update_dock_position:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * 
 * Caches the x and y position of the dock window.
 */
/**
 * plank_position_manager_get_dock_draw_position:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * @x: (out): &nbsp;.  <para>the resulting x position </para>
 * @y: (out): &nbsp;.  <para>the resulting y position </para>
 * 
 * Get&apos;s the x and y position to display the main dock buffer.
 */
/**
 * plank_position_manager_get_dock_window_region:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * 
 * Get&apos;s the region to display the dock window at.
 * 
 * Returns: <para>the region for the dock window </para>
 */
/**
 * plank_position_manager_get_background_padding:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * @x: (out): &nbsp;.  <para>the horizontal padding </para>
 * @y: (out): &nbsp;.  <para>the vertical padding </para>
 * 
 * Get&apos;s the padding between background and icons of the dock.
 */
/**
 * plank_position_manager_get_background_region:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * 
 * Get&apos;s the region for background of the dock.
 * 
 * Returns: <para>the region for the dock background </para>
 */
/**
 * plank_position_manager_get_icon_geometry:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * @item: (in): &nbsp;.  <para>an application-dockitem of the dock </para>
 * @for_hidden: (in): &nbsp;.  <para>whether the geometry should apply for a hidden dock </para>
 * 
 * Get the item&apos;s icon geometry for the dock.
 * 
 * Returns: <para>icon geometry for the given application-dockitem </para>
 */
/**
 * plank_position_manager_get_struts:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 * @struts: (inout) (array length=struts_length1): &nbsp;.  <para>the array to contain the struts </para>
 * @struts_length1: length of the @struts array
 * 
 * Computes the struts for the dock.
 */
/**
 * plank_position_manager_get_barrier:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance
 */
/**
 * plank_position_manager_new:
 * @controller: (in): &nbsp;.  <para>the dock controller to manage positions for </para>
 * 
 * Creates a new position manager.
 */
/**
 * PlankPositionManager:controller:
 */
/**
 * PlankPositionManager:screen-is-composited:
 */
/**
 * plank_position_manager_get_screen_is_composited:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--screen-is-composited"><type>"screen-is-composited"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--screen-is-composited"><type>"screen-is-composited"</type></link> property
 */
/**
 * PlankPositionManager:LineWidth:
 * 
 * Theme-based line-width.
 */
/**
 * plank_position_manager_get_LineWidth:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--LineWidth"><type>"LineWidth"</type></link> property.
 * 
 * Theme-based line-width.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--LineWidth"><type>"LineWidth"</type></link> property
 */
/**
 * PlankPositionManager:IconSize:
 * 
 * Cached current icon size for the dock.
 */
/**
 * plank_position_manager_get_IconSize:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--IconSize"><type>"IconSize"</type></link> property.
 * 
 * Cached current icon size for the dock.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--IconSize"><type>"IconSize"</type></link> property
 */
/**
 * PlankPositionManager:GapSize:
 * 
 * Cached current gap size for the dock.
 */
/**
 * plank_position_manager_get_GapSize:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--GapSize"><type>"GapSize"</type></link> property.
 * 
 * Cached current gap size for the dock.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--GapSize"><type>"GapSize"</type></link> property
 */
/**
 * PlankPositionManager:ZoomIconSize:
 * 
 * Cached current icon size for the dock.
 */
/**
 * plank_position_manager_get_ZoomIconSize:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--ZoomIconSize"><type>"ZoomIconSize"</type></link> property.
 * 
 * Cached current icon size for the dock.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--ZoomIconSize"><type>"ZoomIconSize"</type></link> property
 */
/**
 * PlankPositionManager:Position:
 * 
 * Cached position of the dock.
 */
/**
 * plank_position_manager_get_Position:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--Position"><type>"Position"</type></link> property.
 * 
 * Cached position of the dock.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--Position"><type>"Position"</type></link> property
 */
/**
 * PlankPositionManager:Alignment:
 * 
 * Cached alignment of the dock.
 */
/**
 * plank_position_manager_get_Alignment:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--Alignment"><type>"Alignment"</type></link> property.
 * 
 * Cached alignment of the dock.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--Alignment"><type>"Alignment"</type></link> property
 */
/**
 * PlankPositionManager:ItemsAlignment:
 * 
 * Cached alignment of the items.
 */
/**
 * plank_position_manager_get_ItemsAlignment:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--ItemsAlignment"><type>"ItemsAlignment"</type></link> property.
 * 
 * Cached alignment of the items.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--ItemsAlignment"><type>"ItemsAlignment"</type></link> property
 */
/**
 * PlankPositionManager:Offset:
 * 
 * Cached offset of the dock.
 */
/**
 * plank_position_manager_get_Offset:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--Offset"><type>"Offset"</type></link> property.
 * 
 * Cached offset of the dock.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--Offset"><type>"Offset"</type></link> property
 */
/**
 * PlankPositionManager:IndicatorSize:
 * 
 * Theme-based indicator size, scaled by icon size.
 */
/**
 * plank_position_manager_get_IndicatorSize:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--IndicatorSize"><type>"IndicatorSize"</type></link> property.
 * 
 * Theme-based indicator size, scaled by icon size.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--IndicatorSize"><type>"IndicatorSize"</type></link> property
 */
/**
 * PlankPositionManager:IconShadowSize:
 * 
 * Theme-based icon-shadow size, scaled by icon size.
 */
/**
 * plank_position_manager_get_IconShadowSize:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--IconShadowSize"><type>"IconShadowSize"</type></link> property.
 * 
 * Theme-based icon-shadow size, scaled by icon size.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--IconShadowSize"><type>"IconShadowSize"</type></link> property
 */
/**
 * PlankPositionManager:GlowSize:
 * 
 * Theme-based urgent glow size, scaled by icon size.
 */
/**
 * plank_position_manager_get_GlowSize:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--GlowSize"><type>"GlowSize"</type></link> property.
 * 
 * Theme-based urgent glow size, scaled by icon size.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--GlowSize"><type>"GlowSize"</type></link> property
 */
/**
 * PlankPositionManager:HorizPadding:
 * 
 * Theme-based horizontal padding, scaled by icon size.
 */
/**
 * plank_position_manager_get_HorizPadding:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--HorizPadding"><type>"HorizPadding"</type></link> property.
 * 
 * Theme-based horizontal padding, scaled by icon size.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--HorizPadding"><type>"HorizPadding"</type></link> property
 */
/**
 * PlankPositionManager:TopPadding:
 * 
 * Theme-based top padding, scaled by icon size.
 */
/**
 * plank_position_manager_get_TopPadding:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--TopPadding"><type>"TopPadding"</type></link> property.
 * 
 * Theme-based top padding, scaled by icon size.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--TopPadding"><type>"TopPadding"</type></link> property
 */
/**
 * PlankPositionManager:BottomPadding:
 * 
 * Theme-based bottom padding, scaled by icon size.
 */
/**
 * plank_position_manager_get_BottomPadding:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--BottomPadding"><type>"BottomPadding"</type></link> property.
 * 
 * Theme-based bottom padding, scaled by icon size.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--BottomPadding"><type>"BottomPadding"</type></link> property
 */
/**
 * PlankPositionManager:ItemPadding:
 * 
 * Theme-based item padding, scaled by icon size.
 */
/**
 * plank_position_manager_get_ItemPadding:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--ItemPadding"><type>"ItemPadding"</type></link> property.
 * 
 * Theme-based item padding, scaled by icon size.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--ItemPadding"><type>"ItemPadding"</type></link> property
 */
/**
 * PlankPositionManager:UrgentBounceHeight:
 * 
 * Theme-based urgent-bounce height, scaled by icon size.
 */
/**
 * plank_position_manager_get_UrgentBounceHeight:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--UrgentBounceHeight"><type>"UrgentBounceHeight"</type></link> property.
 * 
 * Theme-based urgent-bounce height, scaled by icon size.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--UrgentBounceHeight"><type>"UrgentBounceHeight"</type></link> property
 */
/**
 * PlankPositionManager:LaunchBounceHeight:
 * 
 * Theme-based launch-bounce height, scaled by icon size.
 */
/**
 * plank_position_manager_get_LaunchBounceHeight:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--LaunchBounceHeight"><type>"LaunchBounceHeight"</type></link> property.
 * 
 * Theme-based launch-bounce height, scaled by icon size.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--LaunchBounceHeight"><type>"LaunchBounceHeight"</type></link> property
 */
/**
 * PlankPositionManager:MaxItemCount:
 * 
 * The maximum item count which fit the dock in its maximum size with the current theme and icon-size.
 */
/**
 * plank_position_manager_get_MaxItemCount:
 * @self: the <link linkend="PlankPositionManager"><type>PlankPositionManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPositionManager--MaxItemCount"><type>"MaxItemCount"</type></link> property.
 * 
 * The maximum item count which fit the dock in its maximum size with the current theme and icon-size.
 * 
 * Returns: the value of the <link linkend="PlankPositionManager--MaxItemCount"><type>"MaxItemCount"</type></link> property
 */
/**
 * plank_position_manager_get_monitor_plug_names:
 * @screen: &nbsp;
 * 
 * Returns: (array length=result_length1): 
 */
/**
 * PlankPositionManager:
 * 
 * Handles computing any size/position information for the dock.
 */
/**
 * PlankPositionManagerClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-POSITION-MANAGER:CAPS"><literal>PLANK_TYPE_POSITION_MANAGER</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
