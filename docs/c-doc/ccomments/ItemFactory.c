/**
 * SECTION:ItemFactory
 * @short_description: An item factory. Creates <link linkend="PlankDockItem"><type>PlankDockItem</type></link>s based on .dockitem files.
 * @launchers_dir: The directory containing .dockitem files.
 */
/**
 * PLANK_TYPE_ITEM_FACTORY:
 * 
 * The type for <link linkend="PlankItemFactory"><type>PlankItemFactory</type></link>.
 */
/**
 * plank_item_factory_make_element:
 * @self: the <link linkend="PlankItemFactory"><type>PlankItemFactory</type></link> instance
 * @file: (in): &nbsp;.  <para>the <link linkend="GFile"><type>GFile</type></link> of .dockitem file to parse </para>
 * 
 * Creates a new <link linkend="PlankDockElement"><type>PlankDockElement</type></link> from a .dockitem.
 * 
 * Returns: <para>the new <link linkend="PlankDockElement"><type>PlankDockElement</type></link> created </para>
 */
/**
 * plank_item_factory_get_item_for_dock:
 * @self: the <link linkend="PlankItemFactory"><type>PlankItemFactory</type></link> instance
 * 
 * Creates a new <link linkend="PlankPlankDockItem"><type>PlankPlankDockItem</type></link> for the dock itself.
 * 
 * Returns: <para>the new <link linkend="PlankPlankDockItem"><type>PlankPlankDockItem</type></link> created </para>
 */
/**
 * plank_item_factory_default_make_element:
 * @self: the <link linkend="PlankItemFactory"><type>PlankItemFactory</type></link> instance
 * @file: (in): &nbsp;.  <para>the <link linkend="GFile"><type>GFile</type></link> of .dockitem file that was parsed </para>
 * @launcher: (in): &nbsp;.  <para>the launcher name from the .dockitem </para>
 * 
 * Creates a new <link linkend="PlankDockElement"><type>PlankDockElement</type></link> for a launcher parsed from a .dockitem.
 * 
 * Returns: <para>the new <link linkend="PlankDockElement"><type>PlankDockElement</type></link> created </para>
 */
/**
 * plank_item_factory_get_launcher_from_dockitem:
 * @self: the <link linkend="PlankItemFactory"><type>PlankItemFactory</type></link> instance
 * @file: (in): &nbsp;.  <para>the <link linkend="GFile"><type>GFile</type></link> of .dockitem to parse </para>
 * 
 * Parses a .dockitem to get the launcher from it.
 * 
 * Returns: <para>the launcher from the .dockitem </para>
 */
/**
 * plank_item_factory_load_elements:
 * @self: the <link linkend="PlankItemFactory"><type>PlankItemFactory</type></link> instance
 * @source_dir: (in): &nbsp;.  <para>the folder where to load .dockitem from </para>
 * @ordering: (in) (allow-none) (array length=ordering_length1): &nbsp;.  <para>a &quot;;;&quot;-separated string to be used to order the loaded DockItems </para>
 * @ordering_length1: length of the @ordering array
 * 
 * Creates a list of Dockitems based on .dockitem files found in the given source_dir.
 * 
 * Returns: <para>the new List of DockItems </para>
 */
/**
 * plank_item_factory_make_default_items:
 * @self: the <link linkend="PlankItemFactory"><type>PlankItemFactory</type></link> instance
 * 
 * Creates a bunch of default .dockitem&apos;s.
 */
/**
 * plank_item_factory_make_dock_item:
 * @self: the <link linkend="PlankItemFactory"><type>PlankItemFactory</type></link> instance
 * @uri: (in): &nbsp;.  <para>the uri or path to create a .dockitem for </para>
 * @target_dir: (in) (allow-none): &nbsp;.  <para>the folder where to put the newly created .dockitem (defaults to launchers_dir) </para>
 * 
 * Creates a new .dockitem for a uri.
 * 
 * Returns: <para>the new <link linkend="GFile"><type>GFile</type></link> of the new .dockitem created </para>
 */
/**
 * plank_item_factory_new:
 */
/**
 * PlankItemFactory:
 * @launchers_dir: The directory containing .dockitem files.
 * 
 * An item factory. Creates <link linkend="PlankDockItem"><type>PlankDockItem</type></link>s based on .dockitem files.
 */
/**
 * PlankItemFactoryClass:
 * @make_element: virtual method called by <link linkend="plank-item-factory-make-element"><function>plank_item_factory_make_element()</function></link>
 * @get_item_for_dock: virtual method called by <link linkend="plank-item-factory-get-item-for-dock"><function>plank_item_factory_get_item_for_dock()</function></link>
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-ITEM-FACTORY:CAPS"><literal>PLANK_TYPE_ITEM_FACTORY</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
