/**
 * SECTION:DockController
 * @short_description: A controller class for managing a single dock.
 * 
 * <para>All needed controlling parts will be created and initialized.</para>
 */
/**
 * PLANK_TYPE_DOCK_CONTROLLER:
 * 
 * The type for <link linkend="PlankDockController"><type>PlankDockController</type></link>.
 */
/**
 * plank_dock_controller_initialize:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance
 * 
 * Initialize this controller. Call this when added at least one DockItemProvider otherwise the <link linkend="PlankDefaultApplicationDockItemProvider"><type>PlankDefaultApplicationDockItemProvider</type></link> will be added by default.
 */
/**
 * plank_dock_controller_add_default_provider:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance
 * 
 * Add the default provider which is an instance of <link linkend="PlankDefaultApplicationDockItemProvider"><type>PlankDefaultApplicationDockItemProvider</type></link>
 */
/**
 * plank_dock_controller_new:
 * @config_folder: (in): &nbsp;.  <para>the base-folder to load settings from and save them to </para>
 * @dock_name: &nbsp;
 * 
 * Create a new DockController which manages a single dock
 */
/**
 * PlankDockController:name:
 */
/**
 * plank_dock_controller_get_name:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockController--name"><type>"name"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockController--name"><type>"name"</type></link> property
 */
/**
 * PlankDockController:config-folder:
 */
/**
 * plank_dock_controller_get_config_folder:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockController--config-folder"><type>"config-folder"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockController--config-folder"><type>"config-folder"</type></link> property
 */
/**
 * PlankDockController:launchers-folder:
 */
/**
 * plank_dock_controller_get_launchers_folder:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockController--launchers-folder"><type>"launchers-folder"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockController--launchers-folder"><type>"launchers-folder"</type></link> property
 */
/**
 * PlankDockController:prefs:
 */
/**
 * plank_dock_controller_get_prefs:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockController--prefs"><type>"prefs"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockController--prefs"><type>"prefs"</type></link> property
 */
/**
 * PlankDockController:drag-manager:
 */
/**
 * plank_dock_controller_get_drag_manager:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockController--drag-manager"><type>"drag-manager"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockController--drag-manager"><type>"drag-manager"</type></link> property
 */
/**
 * plank_dock_controller_set_drag_manager:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockController--drag-manager"><type>"drag-manager"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockController--drag-manager"><type>"drag-manager"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockController:hide-manager:
 */
/**
 * plank_dock_controller_get_hide_manager:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockController--hide-manager"><type>"hide-manager"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockController--hide-manager"><type>"hide-manager"</type></link> property
 */
/**
 * plank_dock_controller_set_hide_manager:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockController--hide-manager"><type>"hide-manager"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockController--hide-manager"><type>"hide-manager"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockController:position-manager:
 */
/**
 * plank_dock_controller_get_position_manager:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockController--position-manager"><type>"position-manager"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockController--position-manager"><type>"position-manager"</type></link> property
 */
/**
 * plank_dock_controller_set_position_manager:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockController--position-manager"><type>"position-manager"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockController--position-manager"><type>"position-manager"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockController:renderer:
 */
/**
 * plank_dock_controller_get_renderer:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockController--renderer"><type>"renderer"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockController--renderer"><type>"renderer"</type></link> property
 */
/**
 * plank_dock_controller_set_renderer:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockController--renderer"><type>"renderer"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockController--renderer"><type>"renderer"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockController:window:
 */
/**
 * plank_dock_controller_get_window:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockController--window"><type>"window"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockController--window"><type>"window"</type></link> property
 */
/**
 * plank_dock_controller_set_window:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockController--window"><type>"window"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockController--window"><type>"window"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockController:hover:
 */
/**
 * plank_dock_controller_get_hover:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockController--hover"><type>"hover"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockController--hover"><type>"hover"</type></link> property
 */
/**
 * plank_dock_controller_set_hover:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockController--hover"><type>"hover"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockController--hover"><type>"hover"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockController:default-provider:
 */
/**
 * plank_dock_controller_get_default_provider:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockController--default-provider"><type>"default-provider"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockController--default-provider"><type>"default-provider"</type></link> property
 */
/**
 * PlankDockController:Items:
 * 
 * List of all items on this dock
 */
/**
 * plank_dock_controller_get_Items:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockController--Items"><type>"Items"</type></link> property.
 * 
 * List of all items on this dock
 * 
 * Returns: the value of the <link linkend="PlankDockController--Items"><type>"Items"</type></link> property
 */
/**
 * PlankDockController:VisibleItems:
 * 
 * Ordered list of all visible items on this dock
 */
/**
 * plank_dock_controller_get_VisibleItems:
 * @self: the <link linkend="PlankDockController"><type>PlankDockController</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockController--VisibleItems"><type>"VisibleItems"</type></link> property.
 * 
 * Ordered list of all visible items on this dock
 * 
 * Returns: the value of the <link linkend="PlankDockController--VisibleItems"><type>"VisibleItems"</type></link> property
 */
/**
 * PlankDockController:
 * 
 * A controller class for managing a single dock.
 * 
 * <para>All needed controlling parts will be created and initialized.</para>
 */
/**
 * PlankDockControllerClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-DOCK-CONTROLLER:CAPS"><literal>PLANK_TYPE_DOCK_CONTROLLER</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
/**
 * PLANK_G_RESOURCE_PATH:
 */
