/**
 * SECTION:ApplicationDockItemProvider
 * @short_description: A container and controller class for managing application dock items on a dock.
 */
/**
 * PLANK_TYPE_APPLICATION_DOCK_ITEM_PROVIDER:
 * 
 * The type for <link linkend="PlankApplicationDockItemProvider"><type>PlankApplicationDockItemProvider</type></link>.
 */
/**
 * plank_application_dock_item_provider_item_for_application:
 * @self: the <link linkend="PlankApplicationDockItemProvider"><type>PlankApplicationDockItemProvider</type></link> instance
 * @app: &nbsp;
 * 
 * Returns: (transfer none): 
 */
/**
 * plank_application_dock_item_provider_app_opened:
 * @self: the <link linkend="PlankApplicationDockItemProvider"><type>PlankApplicationDockItemProvider</type></link> instance
 * @app: &nbsp;
 */
/**
 * plank_application_dock_item_provider_delay_items_monitor:
 * @self: the <link linkend="PlankApplicationDockItemProvider"><type>PlankApplicationDockItemProvider</type></link> instance
 */
/**
 * plank_application_dock_item_provider_resume_items_monitor:
 * @self: the <link linkend="PlankApplicationDockItemProvider"><type>PlankApplicationDockItemProvider</type></link> instance
 */
/**
 * plank_application_dock_item_provider_new:
 * @launchers_dir: (in): &nbsp;.  <para>the directory where to load/save .dockitems files from/to </para>
 * 
 * Creates a new container for dock items.
 */
/**
 * PlankApplicationDockItemProvider:LaunchersDir:
 */
/**
 * plank_application_dock_item_provider_get_LaunchersDir:
 * @self: the <link linkend="PlankApplicationDockItemProvider"><type>PlankApplicationDockItemProvider</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankApplicationDockItemProvider--LaunchersDir"><type>"LaunchersDir"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankApplicationDockItemProvider--LaunchersDir"><type>"LaunchersDir"</type></link> property
 */
/**
 * PlankApplicationDockItemProvider::item-window-added:
 * @application_dock_item_provider: the <link linkend="PlankApplicationDockItemProvider"><type>PlankApplicationDockItemProvider</type></link> instance that received the signal
 * @item: &nbsp;
 */
/**
 * PlankApplicationDockItemProvider:
 * 
 * A container and controller class for managing application dock items on a dock.
 */
/**
 * PlankApplicationDockItemProviderClass:
 * @app_opened: virtual method used internally
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-APPLICATION-DOCK-ITEM-PROVIDER:CAPS"><literal>PLANK_TYPE_APPLICATION_DOCK_ITEM_PROVIDER</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
