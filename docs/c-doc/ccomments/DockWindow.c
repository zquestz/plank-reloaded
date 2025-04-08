/**
 * SECTION:DockWindow
 * @short_description: The main window for all docks.
 */
/**
 * PLANK_TYPE_DOCK_WINDOW:
 * 
 * The type for <link linkend="PlankDockWindow"><type>PlankDockWindow</type></link>.
 */
/**
 * plank_dock_window_update_hovered:
 * @self: the <link linkend="PlankDockWindow"><type>PlankDockWindow</type></link> instance
 * @x: (in): &nbsp;.  <para>the cursor x position </para>
 * @y: (in): &nbsp;.  <para>the cursor x position </para>
 * 
 * Determines if an item is hovered by the cursor at the x/y position.
 * 
 * Returns: <para>if a dock item is hovered </para>
 */
/**
 * plank_dock_window_update_size_and_position:
 * @self: the <link linkend="PlankDockWindow"><type>PlankDockWindow</type></link> instance
 * 
 * Sets the size of the dock window and repositions it if needed.
 */
/**
 * plank_dock_window_update_icon_regions:
 * @self: the <link linkend="PlankDockWindow"><type>PlankDockWindow</type></link> instance
 * 
 * Updates the icon regions for all items on the dock.
 */
/**
 * plank_dock_window_update_icon_region:
 * @self: the <link linkend="PlankDockWindow"><type>PlankDockWindow</type></link> instance
 * @appitem: &nbsp;
 * 
 * Updates the icon region for the given item.
 */
/**
 * plank_dock_window_menu_is_visible:
 * @self: the <link linkend="PlankDockWindow"><type>PlankDockWindow</type></link> instance
 * 
 * If the popup menu is currently visible.
 */
/**
 * plank_dock_window_new:
 * @controller: &nbsp;
 * 
 * Creates a new dock window.
 */
/**
 * PlankDockWindow:controller:
 * 
 * The controller for this dock.
 */
/**
 * PlankDockWindow:HoveredItem:
 * 
 * The currently hovered item (if any).
 */
/**
 * plank_dock_window_get_HoveredItem:
 * @self: the <link linkend="PlankDockWindow"><type>PlankDockWindow</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockWindow--HoveredItem"><type>"HoveredItem"</type></link> property.
 * 
 * The currently hovered item (if any).
 * 
 * Returns: the value of the <link linkend="PlankDockWindow--HoveredItem"><type>"HoveredItem"</type></link> property
 */
/**
 * PlankDockWindow:HoveredItemProvider:
 * 
 * The currently hovered item-provider (if any).
 */
/**
 * plank_dock_window_get_HoveredItemProvider:
 * @self: the <link linkend="PlankDockWindow"><type>PlankDockWindow</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockWindow--HoveredItemProvider"><type>"HoveredItemProvider"</type></link> property.
 * 
 * The currently hovered item-provider (if any).
 * 
 * Returns: the value of the <link linkend="PlankDockWindow--HoveredItemProvider"><type>"HoveredItemProvider"</type></link> property
 */
/**
 * PlankDockWindow:
 * 
 * The main window for all docks.
 */
/**
 * PlankDockWindowClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-DOCK-WINDOW:CAPS"><literal>PLANK_TYPE_DOCK_WINDOW</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
