/**
 * SECTION:ApplicationDockItem
 * @short_description: A dock item for applications (with .desktop launchers).
 */
/**
 * PLANK_TYPE_APPLICATION_DOCK_ITEM:
 * 
 * The type for <link linkend="PlankApplicationDockItem"><type>PlankApplicationDockItem</type></link>.
 */
/**
 * plank_application_dock_item_is_running:
 * @self: the <link linkend="PlankApplicationDockItem"><type>PlankApplicationDockItem</type></link> instance
 */
/**
 * plank_application_dock_item_is_window:
 * @self: the <link linkend="PlankApplicationDockItem"><type>PlankApplicationDockItem</type></link> instance
 */
/**
 * plank_application_dock_item_set_urgent:
 * @self: the <link linkend="PlankApplicationDockItem"><type>PlankApplicationDockItem</type></link> instance
 * @is_urgent: &nbsp;
 */
/**
 * plank_application_dock_item_get_unity_application_uri:
 * @self: the <link linkend="PlankApplicationDockItem"><type>PlankApplicationDockItem</type></link> instance
 * 
 * Get libunity application URI
 * 
 * Returns: (transfer none): <para>the libunity application uri of this item, or NULL </para>
 */
/**
 * plank_application_dock_item_get_unity_dbusname:
 * @self: the <link linkend="PlankApplicationDockItem"><type>PlankApplicationDockItem</type></link> instance
 * 
 * Get current libunity dbusname
 * 
 * Returns: (transfer none): <para>the dbusname which provides the LauncherEntry interface, or NULL </para>
 */
/**
 * plank_application_dock_item_has_unity_info:
 * @self: the <link linkend="PlankApplicationDockItem"><type>PlankApplicationDockItem</type></link> instance
 * 
 * Whether this item provides information worth showing
 */
/**
 * plank_application_dock_item_unity_update:
 * @self: the <link linkend="PlankApplicationDockItem"><type>PlankApplicationDockItem</type></link> instance
 * @sender_name: (in): &nbsp;.  <para>the corressponding dbusname </para>
 * @prop_iter: (in): &nbsp;.  <para>the data in a standardize format from libunity </para>
 * 
 * Update this item&apos;s remote libunity value based on the given data
 */
/**
 * plank_application_dock_item_unity_reset:
 * @self: the <link linkend="PlankApplicationDockItem"><type>PlankApplicationDockItem</type></link> instance
 * 
 * Reset this item&apos;s remote libunity values
 */
/**
 * plank_application_dock_item_new_with_dockitem_file:
 * @file: &nbsp;
 * 
 * 
 */
/**
 * plank_application_dock_item_new_with_dockitem_filename:
 * @filename: &nbsp;
 * 
 * 
 */
/**
 * plank_application_dock_item_new:
 */
/**
 * PlankApplicationDockItem:App:
 */
/**
 * plank_application_dock_item_get_App:
 * @self: the <link linkend="PlankApplicationDockItem"><type>PlankApplicationDockItem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankApplicationDockItem--App"><type>"App"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankApplicationDockItem--App"><type>"App"</type></link> property
 */
/**
 * plank_application_dock_item_set_App:
 * @self: the <link linkend="PlankApplicationDockItem"><type>PlankApplicationDockItem</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankApplicationDockItem--App"><type>"App"</type></link> property
 * 
 * Set the value of the <link linkend="PlankApplicationDockItem--App"><type>"App"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankApplicationDockItem::pin-launcher:
 * @application_dock_item: the <link linkend="PlankApplicationDockItem"><type>PlankApplicationDockItem</type></link> instance that received the signal
 * 
 * Signal fired when the item&apos;s &apos;keep in dock&apos; menu item is pressed.
 */
/**
 * PlankApplicationDockItem::app-closed:
 * @application_dock_item: the <link linkend="PlankApplicationDockItem"><type>PlankApplicationDockItem</type></link> instance that received the signal
 * 
 * Signal fired when the application associated with this item closes.
 */
/**
 * PlankApplicationDockItem::app-window-added:
 * @application_dock_item: the <link linkend="PlankApplicationDockItem"><type>PlankApplicationDockItem</type></link> instance that received the signal
 * 
 * Signal fired when the application associated with this item opened a new window.
 */
/**
 * PlankApplicationDockItem::app-window-removed:
 * @application_dock_item: the <link linkend="PlankApplicationDockItem"><type>PlankApplicationDockItem</type></link> instance that received the signal
 * 
 * Signal fired when the application associated with this item closed a window.
 */
/**
 * plank_application_dock_item_parse_launcher:
 * @launcher: (in): &nbsp;.  <para>the launcher file (.desktop file) to parse </para>
 * @icon: (out): &nbsp;.  <para>the icon key from the launcher </para>
 * @text: (out): &nbsp;.  <para>the text key from the launcher </para>
 * @actions: (in) (allow-none): &nbsp;.  <para>a list of all actions by name </para>
 * @actions_map: (in) (allow-none): &nbsp;.  <para>a map of actions from name to exec;;icon </para>
 * @mimes: (in) (allow-none): &nbsp;.  <para>a list of all supported mime types </para>
 * 
 * Parses a launcher to get the text, icon and actions.
 */
/**
 * PlankApplicationDockItem:
 * 
 * A dock item for applications (with .desktop launchers).
 */
/**
 * PlankApplicationDockItemClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-APPLICATION-DOCK-ITEM:CAPS"><literal>PLANK_TYPE_APPLICATION_DOCK_ITEM</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
