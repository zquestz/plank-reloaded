/**
 * SECTION:DockItemProvider
 * @short_description: A container and controller class for managing dock items.
 */
/**
 * PLANK_TYPE_DOCK_ITEM_PROVIDER:
 * 
 * The type for <link linkend="PlankDockItemProvider"><type>PlankDockItemProvider</type></link>.
 */
/**
 * plank_dock_item_provider_item_exists_for_uri:
 * @self: the <link linkend="PlankDockItemProvider"><type>PlankDockItemProvider</type></link> instance
 * @uri: (in): &nbsp;.  <para>the URI to look for </para>
 * 
 * Whether a dock item with the given URI exists in this provider.
 */
/**
 * plank_dock_item_provider_item_for_uri:
 * @self: the <link linkend="PlankDockItemProvider"><type>PlankDockItemProvider</type></link> instance
 * @uri: (in): &nbsp;.  <para>the URI to look for </para>
 * 
 * Get the dock item for the given URI if it exists or null.
 * 
 * Returns: (transfer none): 
 */
/**
 * plank_dock_item_provider_add_item_with_uri:
 * @self: the <link linkend="PlankDockItemProvider"><type>PlankDockItemProvider</type></link> instance
 * @uri: (in): &nbsp;.  <para>the URI to add a dock item for </para>
 * @target: (in) (allow-none): &nbsp;.  <para>an existing item where to put this new one at </para>
 * 
 * Adds a dock item with the given URI to the collection.
 * 
 * Returns: <para>whether adding the URI was successful </para>
 */
/**
 * plank_dock_item_provider_allow_duplicate_item:
 * @self: the <link linkend="PlankDockItemProvider"><type>PlankDockItemProvider</type></link> instance
 * @uri: &nbsp;
 */
/**
 * plank_dock_item_provider_handle_item_deleted:
 * @self: the <link linkend="PlankDockItemProvider"><type>PlankDockItemProvider</type></link> instance
 * @item: &nbsp;
 */
/**
 * plank_dock_item_provider_get_dockitem_filenames:
 * @self: the <link linkend="PlankDockItemProvider"><type>PlankDockItemProvider</type></link> instance
 * 
 * Get ordered array of dockitem-filenames handled by this provider
 * 
 * Returns: (array length=result_length1): <para>an ordered array of strings containing all basenames </para>
 */
/**
 * plank_dock_item_provider_new:
 * 
 * Creates a new container for dock items.
 */
/**
 * PlankDockItemProvider:
 * 
 * A container and controller class for managing dock items.
 */
/**
 * PlankDockItemProviderClass:
 * @item_exists_for_uri: virtual method called by <link linkend="plank-dock-item-provider-item-exists-for-uri"><function>plank_dock_item_provider_item_exists_for_uri()</function></link>
 * @item_for_uri: virtual method called by <link linkend="plank-dock-item-provider-item-for-uri"><function>plank_dock_item_provider_item_for_uri()</function></link>
 * @add_item_with_uri: virtual method called by <link linkend="plank-dock-item-provider-add-item-with-uri"><function>plank_dock_item_provider_add_item_with_uri()</function></link>
 * @handle_item_deleted: virtual method used internally
 * @get_dockitem_filenames: virtual method called by <link linkend="plank-dock-item-provider-get-dockitem-filenames"><function>plank_dock_item_provider_get_dockitem_filenames()</function></link>
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-DOCK-ITEM-PROVIDER:CAPS"><literal>PLANK_TYPE_DOCK_ITEM_PROVIDER</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
