/**
 * SECTION:DragManager
 * @short_description: Handles all of the drag&apos;n&apos;drop events for a dock.
 */
/**
 * PLANK_TYPE_DRAG_MANAGER:
 * 
 * The type for <link linkend="PlankDragManager"><type>PlankDragManager</type></link>.
 */
/**
 * plank_drag_manager_initialize:
 * @self: the <link linkend="PlankDragManager"><type>PlankDragManager</type></link> instance
 * 
 * Initializes the drag-manager. Call after the DockWindow is constructed.
 */
/**
 * plank_drag_manager_drop_is_accepted_by:
 * @self: the <link linkend="PlankDragManager"><type>PlankDragManager</type></link> instance
 * @item: (in): &nbsp;.  <para>the dock-item </para>
 * 
 * Whether the current dragged-data is accepted by the given dock-item
 */
/**
 * plank_drag_manager_ensure_proxy:
 * @self: the <link linkend="PlankDragManager"><type>PlankDragManager</type></link> instance
 */
/**
 * plank_drag_manager_new:
 * @controller: (in): &nbsp;.  <para>the <link linkend="PlankDockController"><type>PlankDockController</type></link> to manage drag&apos;n&apos;drop for </para>
 * 
 * Creates a new instance of a DragManager, which handles drag&apos;n&apos;drop interactions of a dock.
 */
/**
 * PlankDragManager:controller:
 */
/**
 * PlankDragManager:InternalDragActive:
 */
/**
 * plank_drag_manager_get_InternalDragActive:
 * @self: the <link linkend="PlankDragManager"><type>PlankDragManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDragManager--InternalDragActive"><type>"InternalDragActive"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDragManager--InternalDragActive"><type>"InternalDragActive"</type></link> property
 */
/**
 * PlankDragManager:DragItem:
 */
/**
 * plank_drag_manager_get_DragItem:
 * @self: the <link linkend="PlankDragManager"><type>PlankDragManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDragManager--DragItem"><type>"DragItem"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDragManager--DragItem"><type>"DragItem"</type></link> property
 */
/**
 * PlankDragManager:DragNeedsCheck:
 */
/**
 * plank_drag_manager_get_DragNeedsCheck:
 * @self: the <link linkend="PlankDragManager"><type>PlankDragManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDragManager--DragNeedsCheck"><type>"DragNeedsCheck"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDragManager--DragNeedsCheck"><type>"DragNeedsCheck"</type></link> property
 */
/**
 * PlankDragManager:ExternalDragActive:
 */
/**
 * plank_drag_manager_get_ExternalDragActive:
 * @self: the <link linkend="PlankDragManager"><type>PlankDragManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDragManager--ExternalDragActive"><type>"ExternalDragActive"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDragManager--ExternalDragActive"><type>"ExternalDragActive"</type></link> property
 */
/**
 * PlankDragManager:RepositionMode:
 */
/**
 * plank_drag_manager_get_RepositionMode:
 * @self: the <link linkend="PlankDragManager"><type>PlankDragManager</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDragManager--RepositionMode"><type>"RepositionMode"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDragManager--RepositionMode"><type>"RepositionMode"</type></link> property
 */
/**
 * PlankDragManager:
 * 
 * Handles all of the drag&apos;n&apos;drop events for a dock.
 */
/**
 * PlankDragManagerClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-DRAG-MANAGER:CAPS"><literal>PLANK_TYPE_DRAG_MANAGER</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
