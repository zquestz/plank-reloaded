/**
 * SECTION:HideManager
 * @short_description: Handles checking if a dock should hide or not.
 */
/**
 * PLANK_TYPE_HIDE_MANAGER:
 * 
 * The type for <link linkend="PlankHideManager"><type>PlankHideManager</type></link>.
 */
/**
 * plank_hide_manager_initialize:
 * @self: the <link linkend="PlankHideManager"><type>PlankHideManager</type></link> instance
 * 
 * Initializes the hide manager. Call after the DockWindow is constructed.
 */
/**
 * plank_hide_manager_update_hovered:
 * @self: the <link linkend="PlankHideManager"><type>PlankHideManager</type></link> instance
 * 
 * Checks to see if the dock is being hovered by the mouse cursor.
 */
/**
 * plank_hide_manager_update_hovered_with_coords:
 * @self: the <link linkend="PlankHideManager"><type>PlankHideManager</type></link> instance
 * @x: (in): &nbsp;.  <para>the x coordinate of the pointer relative to the dock window </para>
 * @y: (in): &nbsp;.  <para>the y coordinate of the pointer relative to the dock window </para>
 * @force_unhovered: &nbsp;
 * 
 * Checks to see if the dock is being hovered by the mouse cursor.
 */
/**
 * plank_hide_manager_update_barrier:
 * @self: the <link linkend="PlankHideManager"><type>PlankHideManager</type></link> instance
 */
/**
 * plank_hide_manager_new:
 * @controller: (in): &nbsp;.  <para>the <link linkend="PlankDockController"><type>PlankDockController</type></link> to manage hiding for </para>
 * 
 * Creates a new instance of a HideManager, which handles checking if a dock should hide or not.
 */
/**
 * PlankHideManager:controller:
 */
/**
 * PlankHideManager:Hidden:
 * 
 * If the dock is currently hidden.
 */
/**
 * plank_hide_manager_get_Hidden:
 * @self: the <link linkend="PlankHideManager"><type>PlankHideManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankHideManager--Hidden"><type>"Hidden"</type></link> property.
 * 
 * If the dock is currently hidden.
 * 
 * Returns: the value of the <link linkend="PlankHideManager--Hidden"><type>"Hidden"</type></link> property
 */
/**
 * PlankHideManager:Disabled:
 * 
 * If hiding the dock is currently disabled
 */
/**
 * plank_hide_manager_get_Disabled:
 * @self: the <link linkend="PlankHideManager"><type>PlankHideManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankHideManager--Disabled"><type>"Disabled"</type></link> property.
 * 
 * If hiding the dock is currently disabled
 * 
 * Returns: the value of the <link linkend="PlankHideManager--Disabled"><type>"Disabled"</type></link> property
 */
/**
 * PlankHideManager:Hovered:
 * 
 * If the dock is currently hovered by the mouse cursor.
 */
/**
 * plank_hide_manager_get_Hovered:
 * @self: the <link linkend="PlankHideManager"><type>PlankHideManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankHideManager--Hovered"><type>"Hovered"</type></link> property.
 * 
 * If the dock is currently hovered by the mouse cursor.
 * 
 * Returns: the value of the <link linkend="PlankHideManager--Hovered"><type>"Hovered"</type></link> property
 */
/**
 * PlankHideManager:
 * 
 * Handles checking if a dock should hide or not.
 */
/**
 * PlankHideManagerClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-HIDE-MANAGER:CAPS"><literal>PLANK_TYPE_HIDE_MANAGER</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
/**
 * PlankHideType:
 * @PLANK_HIDE_TYPE_NONE: The dock does not hide. It should set struts to reserve space for it.
 * @PLANK_HIDE_TYPE_INTELLIGENT: The dock hides if a window in the active window group overlaps it.
 * @PLANK_HIDE_TYPE_AUTO: The dock hides if the mouse is not over it.
 * @PLANK_HIDE_TYPE_DODGE_MAXIMIZED: The dock hides if there is an active maximized window.
 * @PLANK_HIDE_TYPE_WINDOW_DODGE: The dock hides if there is any window overlapping it.
 * @PLANK_HIDE_TYPE_DODGE_ACTIVE: The dock hides if there is the active window overlapping it.
 * 
 * If/How the dock should hide itself.
 */
