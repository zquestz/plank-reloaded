/**
 * SECTION:DockletManager
 * @short_description: A controller class for managing all available docklets.
 */
/**
 * PLANK_TYPE_DOCKLET_MANAGER:
 * 
 * The type for <link linkend="PlankDockletManager"><type>PlankDockletManager</type></link>.
 */
/**
 * plank_docklet_manager_load_docklets:
 * @self: the <link linkend="PlankDockletManager"><type>PlankDockletManager</type></link> instance
 * 
 * Load docklet modules from known directories
 */
/**
 * plank_docklet_manager_register_docklet:
 * @self: the <link linkend="PlankDockletManager"><type>PlankDockletManager</type></link> instance
 * @type: (in): &nbsp;.  <para>a type </para>
 * 
 * Register docklet with given name and type
 */
/**
 * plank_docklet_manager_get_docklet_by_id:
 * @self: the <link linkend="PlankDockletManager"><type>PlankDockletManager</type></link> instance
 * @id: (in): &nbsp;.  <para>a unique id </para>
 * 
 * Find docklet for given id
 * 
 * Returns: <para>a docklet or null </para>
 */
/**
 * plank_docklet_manager_get_docklet_by_uri:
 * @self: the <link linkend="PlankDockletManager"><type>PlankDockletManager</type></link> instance
 * @uri: (in): &nbsp;.  <para>an URI </para>
 * 
 * Find docklet wich supports given uri
 * 
 * Returns: <para>a docklet or null </para>
 */
/**
 * plank_docklet_manager_list_docklets:
 * @self: the <link linkend="PlankDockletManager"><type>PlankDockletManager</type></link> instance
 * 
 * Get list of all registered docklets
 * 
 * Returns: <para>a list of all registered docklets </para>
 */
/**
 * PlankDockletManager::docklet-added:
 * @docklet_manager: the <link linkend="PlankDockletManager"><type>PlankDockletManager</type></link> instance that received the signal
 * @docklet: &nbsp;
 */
/**
 * plank_docklet_manager_get_default:
 * 
 * Returns: (transfer none): 
 */
/**
 * PlankDockletManager:
 * 
 * A controller class for managing all available docklets.
 */
/**
 * PlankDockletManagerClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-DOCKLET-MANAGER:CAPS"><literal>PLANK_TYPE_DOCKLET_MANAGER</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
/**
 * PLANK_DOCKLET_ENTRY_POINT:
 */
/**
 * PlankDockletInitFunc:
 * @manager: &nbsp;
 * @user_data: (closure): data to pass to the delegate function
 */
