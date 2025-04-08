/**
 * SECTION:DockContainer
 * @short_description: A container and controller class for managing dock elements on a dock.
 */
/**
 * PLANK_TYPE_DOCK_CONTAINER:
 * 
 * The type for <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link>.
 */
/**
 * plank_dock_container_prepare:
 * @self: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance
 * 
 * Do some special implementation specific preparation
 * 
 * <para>This is meant to called after the initial batch of items was added and the provider is about to be added to the dock.</para>
 */
/**
 * plank_dock_container_add:
 * @self: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance
 * @element: (in): &nbsp;.  <para>the dock-element to add </para>
 * @target: (in) (allow-none): &nbsp;.  <para>an existing item where to put this new one at </para>
 * 
 * Adds a dock-element to the collection.
 * 
 * Returns: <para>whether adding the item was successful </para>
 */
/**
 * plank_dock_container_prepend:
 * @self: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance
 * @element: (in): &nbsp;.  <para>the dock-element to add </para>
 * 
 * Prepends a dock-element to the collection. So the dock-element will appear at the first position.
 */
/**
 * plank_dock_container_add_all:
 * @self: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance
 * @elements: (in): &nbsp;.  <para>the dock-elements to add </para>
 * 
 * Adds a ordered list of dock-elements to the collection.
 * 
 * Returns: <para>whether all elements were added successfully </para>
 */
/**
 * plank_dock_container_remove:
 * @self: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance
 * @element: (in): &nbsp;.  <para>the dock-element to remove </para>
 * 
 * Removes a dock-element from the collection.
 * 
 * Returns: <para>whether removing the element was successful </para>
 */
/**
 * plank_dock_container_remove_all:
 * @self: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance
 * @elements: (in): &nbsp;.  <para>the dock-elements to remove </para>
 * 
 * Removes all given dock-elements from the collection.
 * 
 * Returns: <para>whether removing the elements was successful </para>
 */
/**
 * plank_dock_container_clear:
 * @self: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance
 * 
 * Clears and therefore removes all dock-elements from the collection.
 * 
 * Returns: <para>whether removing the elements was successful </para>
 */
/**
 * plank_dock_container_update_visible_elements:
 * @self: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance
 */
/**
 * plank_dock_container_move_to:
 * @self: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance
 * @move: (in): &nbsp;.  <para>the element to move </para>
 * @target: (in): &nbsp;.  <para>the element of the new position </para>
 * 
 * Move an element to the position of another element. This shifts all elements which are placed between these two elements.
 * 
 * Returns: <para>whether moving the element was successful </para>
 */
/**
 * plank_dock_container_replace:
 * @self: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance
 * @new_element: (in): &nbsp;.  <para>the new element </para>
 * @old_element: (in): &nbsp;.  <para>the element to be replaced </para>
 * 
 * Replace an element with another element.
 * 
 * Returns: <para>whether replacing the element was successful </para>
 */
/**
 * plank_dock_container_connect_element:
 * @self: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance
 * @element: &nbsp;
 */
/**
 * plank_dock_container_disconnect_element:
 * @self: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance
 * @element: &nbsp;
 */
/**
 * PlankDockContainer:VisibleElements:
 * 
 * The ordered list of the visible dock elements.
 */
/**
 * plank_dock_container_get_VisibleElements:
 * @self: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockContainer--VisibleElements"><type>"VisibleElements"</type></link> property.
 * 
 * The ordered list of the visible dock elements.
 * 
 * Returns: the value of the <link linkend="PlankDockContainer--VisibleElements"><type>"VisibleElements"</type></link> property
 */
/**
 * PlankDockContainer:Elements:
 * 
 * The list of the all containing dock elements.
 */
/**
 * plank_dock_container_get_Elements:
 * @self: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockContainer--Elements"><type>"Elements"</type></link> property.
 * 
 * The list of the all containing dock elements.
 * 
 * Returns: the value of the <link linkend="PlankDockContainer--Elements"><type>"Elements"</type></link> property
 */
/**
 * PlankDockContainer::elements-changed:
 * @dock_container: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance that received the signal
 * @added: &nbsp;.  <para>the list of added elements </para><para></para>
 * @removed: &nbsp;.  <para>the list of removed elements </para><para></para>
 * 
 * Triggered when the collection of elements has changed.
 */
/**
 * PlankDockContainer::states-changed:
 * @dock_container: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance that received the signal
 * 
 * Triggered when the state of an element changes.
 */
/**
 * PlankDockContainer::positions-changed:
 * @dock_container: the <link linkend="PlankDockContainer"><type>PlankDockContainer</type></link> instance that received the signal
 * @elements: &nbsp;.  <para>the list of moved elements </para><para></para>
 * 
 * Triggered anytime element-positions were changed.
 */
/**
 * plank_dock_container_move_element:
 * @elements: &nbsp;
 * @from: &nbsp;
 * @to: &nbsp;
 * @moved: &nbsp;
 */
/**
 * PlankDockContainer:
 * 
 * A container and controller class for managing dock elements on a dock.
 */
/**
 * PlankDockContainerClass:
 * @prepare: virtual method called by <link linkend="plank-dock-container-prepare"><function>plank_dock_container_prepare()</function></link>
 * @update_visible_elements: virtual method used internally
 * @move_to: virtual method called by <link linkend="plank-dock-container-move-to"><function>plank_dock_container_move_to()</function></link>
 * @replace: virtual method called by <link linkend="plank-dock-container-replace"><function>plank_dock_container_replace()</function></link>
 * @connect_element: virtual method used internally
 * @disconnect_element: virtual method used internally
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-DOCK-CONTAINER:CAPS"><literal>PLANK_TYPE_DOCK_CONTAINER</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
