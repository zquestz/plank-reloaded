/**
 * SECTION:Docklet
 * @short_description: The common interface for all docklets.
 */
/**
 * plank_docklet_get_id:
 * @self: the <link linkend="PlankDocklet"><type>PlankDocklet</type></link> instance
 * 
 * Returns: (transfer none): 
 */
/**
 * plank_docklet_get_name:
 * @self: the <link linkend="PlankDocklet"><type>PlankDocklet</type></link> instance
 * 
 * Returns: (transfer none): 
 */
/**
 * plank_docklet_get_description:
 * @self: the <link linkend="PlankDocklet"><type>PlankDocklet</type></link> instance
 * 
 * Returns: (transfer none): 
 */
/**
 * plank_docklet_get_icon:
 * @self: the <link linkend="PlankDocklet"><type>PlankDocklet</type></link> instance
 * 
 * Returns: (transfer none): 
 */
/**
 * plank_docklet_is_supported:
 * @self: the <link linkend="PlankDocklet"><type>PlankDocklet</type></link> instance
 */
/**
 * plank_docklet_make_element:
 * @self: the <link linkend="PlankDocklet"><type>PlankDocklet</type></link> instance
 * @launcher: &nbsp;
 * @file: &nbsp;
 */
/**
 * PlankDocklet:
 * 
 * The common interface for all docklets.
 */
/**
 * PlankDockletIface:
 * @get_id: virtual method called by <link linkend="plank-docklet-get-id"><function>plank_docklet_get_id()</function></link>
 * @get_name: virtual method called by <link linkend="plank-docklet-get-name"><function>plank_docklet_get_name()</function></link>
 * @get_description: virtual method called by <link linkend="plank-docklet-get-description"><function>plank_docklet_get_description()</function></link>
 * @get_icon: virtual method called by <link linkend="plank-docklet-get-icon"><function>plank_docklet_get_icon()</function></link>
 * @is_supported: virtual method called by <link linkend="plank-docklet-is-supported"><function>plank_docklet_is_supported()</function></link>
 * @make_element: virtual method called by <link linkend="plank-docklet-make-element"><function>plank_docklet_make_element()</function></link>
 * @parent_iface: the parent interface structure
 * 
 * Interface for creating <link linkend="PlankDocklet"><type>PlankDocklet</type></link> implementations.
 */
