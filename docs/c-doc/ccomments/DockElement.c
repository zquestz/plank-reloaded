/**
 * SECTION:DockElement
 * @short_description: The base class for all dock elements.
 */
/**
 * PLANK_TYPE_DOCK_ELEMENT:
 * 
 * The type for <link linkend="PlankDockElement"><type>PlankDockElement</type></link>.
 */
/**
 * plank_dock_element_clicked:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance
 * @button: (in): &nbsp;.  <para>the button clicked </para>
 * @mod: (in): &nbsp;.  <para>the modifiers </para>
 * @event_time: (in): &nbsp;.  <para>the timestamp of the event triggering this action </para>
 * 
 * Called when an item is clicked on.
 */
/**
 * plank_dock_element_on_clicked:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance
 * @button: (in): &nbsp;.  <para>the button clicked </para>
 * @mod: (in): &nbsp;.  <para>the modifiers </para>
 * @event_time: (in): &nbsp;.  <para>the timestamp of the event triggering this action </para>
 * 
 * Called when an item is clicked on.
 * 
 * Returns: <para>which type of animation to trigger </para>
 */
/**
 * plank_dock_element_hovered:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance
 * 
 * Called when an item gets hovered.
 */
/**
 * plank_dock_element_on_hovered:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance
 * 
 * Called when an item gets hovered.
 * 
 * Returns: <para>which type of animation to trigger </para>
 */
/**
 * plank_dock_element_scrolled:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance
 * @direction: (in): &nbsp;.  <para>the scroll direction </para>
 * @mod: (in): &nbsp;.  <para>the modifiers </para>
 * @event_time: (in): &nbsp;.  <para>the timestamp of the event triggering this action </para>
 * 
 * Called when an item is scrolled over.
 */
/**
 * plank_dock_element_on_scrolled:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance
 * @direction: (in): &nbsp;.  <para>the scroll direction </para>
 * @mod: (in): &nbsp;.  <para>the modifiers </para>
 * @event_time: (in): &nbsp;.  <para>the timestamp of the event triggering this action </para>
 * 
 * Called when an item is scrolled over.
 * 
 * Returns: <para>which type of animation to trigger </para>
 */
/**
 * plank_dock_element_get_dock:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance
 * 
 * Get the dock which this element is part of
 * 
 * Returns: (transfer none): <para>the dock-controller of this element, or null </para>
 */
/**
 * plank_dock_element_get_menu_items:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance
 * 
 * Returns a list of the item&apos;s menu items.
 * 
 * Returns: <para>the item&apos;s menu items </para>
 */
/**
 * plank_dock_element_get_drop_text:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance
 * 
 * The item&apos;s text for drop actions.
 * 
 * Returns: <para>the item&apos;s drop-text </para>
 */
/**
 * plank_dock_element_can_be_removed:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance
 * 
 * Returns if this item can be removed from the dock.
 * 
 * Returns: <para>if this item can be removed from the dock </para>
 */
/**
 * plank_dock_element_can_accept_drop:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance
 * @uris: (in): &nbsp;.  <para>the URIs to check </para>
 * 
 * Returns if the item accepts a drop of the given URIs.
 * 
 * Returns: <para>if the item accepts a drop of the given URIs </para>
 */
/**
 * plank_dock_element_accept_drop:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance
 * @uris: (in): &nbsp;.  <para>the URIs to accept </para>
 * 
 * Accepts a drop of the given URIs.
 * 
 * Returns: <para>if the item accepted a drop of the given URIs </para>
 */
/**
 * plank_dock_element_unique_id:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance
 * 
 * Returns a unique ID for this dock item.
 * 
 * Returns: <para>a unique ID for this dock element </para>
 */
/**
 * plank_dock_element_as_uri:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance
 * 
 * Returns a unique URI for this dock element.
 * 
 * Returns: <para>a unique URI for this dock element </para>
 */
/**
 * plank_dock_element_reset_buffers:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance
 * 
 * Resets the buffers for this element.
 */
/**
 * PlankDockElement:Container:
 * 
 * The dock element&apos;s container which it is added too (if any).
 */
/**
 * plank_dock_element_get_Container:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--Container"><type>"Container"</type></link> property.
 * 
 * The dock element&apos;s container which it is added too (if any).
 * 
 * Returns: the value of the <link linkend="PlankDockElement--Container"><type>"Container"</type></link> property
 */
/**
 * plank_dock_element_set_Container:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--Container"><type>"Container"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--Container"><type>"Container"</type></link> property to @value.
 * 
 * The dock element&apos;s container which it is added too (if any).
 */
/**
 * PlankDockElement:Text:
 * 
 * The dock item&apos;s text.
 */
/**
 * plank_dock_element_get_Text:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--Text"><type>"Text"</type></link> property.
 * 
 * The dock item&apos;s text.
 * 
 * Returns: the value of the <link linkend="PlankDockElement--Text"><type>"Text"</type></link> property
 */
/**
 * plank_dock_element_set_Text:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--Text"><type>"Text"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--Text"><type>"Text"</type></link> property to @value.
 * 
 * The dock item&apos;s text.
 */
/**
 * PlankDockElement:IsAttached:
 * 
 * Whether the item is currently hidden on the dock. If TRUE it will be drawn and does consume space. If FALSE it will not be drawn and does not consume space.
 */
/**
 * plank_dock_element_get_IsAttached:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--IsAttached"><type>"IsAttached"</type></link> property.
 * 
 * Whether the item is currently hidden on the dock. If TRUE it will be drawn and does consume space. If FALSE it will not be drawn and does not consume space.
 * 
 * Returns: the value of the <link linkend="PlankDockElement--IsAttached"><type>"IsAttached"</type></link> property
 */
/**
 * plank_dock_element_set_IsAttached:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--IsAttached"><type>"IsAttached"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--IsAttached"><type>"IsAttached"</type></link> property to @value.
 * 
 * Whether the item is currently hidden on the dock. If TRUE it will be drawn and does consume space. If FALSE it will not be drawn and does not consume space.
 */
/**
 * PlankDockElement:IsVisible:
 * 
 * Whether the item is currently visible on the dock. If TRUE it will be drawn and does consume space. If FALSE it will not be drawn and does consume space.
 */
/**
 * plank_dock_element_get_IsVisible:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--IsVisible"><type>"IsVisible"</type></link> property.
 * 
 * Whether the item is currently visible on the dock. If TRUE it will be drawn and does consume space. If FALSE it will not be drawn and does consume space.
 * 
 * Returns: the value of the <link linkend="PlankDockElement--IsVisible"><type>"IsVisible"</type></link> property
 */
/**
 * plank_dock_element_set_IsVisible:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--IsVisible"><type>"IsVisible"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--IsVisible"><type>"IsVisible"</type></link> property to @value.
 * 
 * Whether the item is currently visible on the dock. If TRUE it will be drawn and does consume space. If FALSE it will not be drawn and does consume space.
 */
/**
 * PlankDockElement:Button:
 * 
 * The buttons this item shows popup menus for.
 */
/**
 * plank_dock_element_get_Button:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--Button"><type>"Button"</type></link> property.
 * 
 * The buttons this item shows popup menus for.
 * 
 * Returns: the value of the <link linkend="PlankDockElement--Button"><type>"Button"</type></link> property
 */
/**
 * plank_dock_element_set_Button:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--Button"><type>"Button"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--Button"><type>"Button"</type></link> property to @value.
 * 
 * The buttons this item shows popup menus for.
 */
/**
 * PlankDockElement:ClickedAnimation:
 * 
 * The animation to show for the item&apos;s last click event.
 */
/**
 * plank_dock_element_get_ClickedAnimation:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--ClickedAnimation"><type>"ClickedAnimation"</type></link> property.
 * 
 * The animation to show for the item&apos;s last click event.
 * 
 * Returns: the value of the <link linkend="PlankDockElement--ClickedAnimation"><type>"ClickedAnimation"</type></link> property
 */
/**
 * plank_dock_element_set_ClickedAnimation:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--ClickedAnimation"><type>"ClickedAnimation"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--ClickedAnimation"><type>"ClickedAnimation"</type></link> property to @value.
 * 
 * The animation to show for the item&apos;s last click event.
 */
/**
 * PlankDockElement:HoveredAnimation:
 * 
 * The animation to show for the item&apos;s last hover event.
 */
/**
 * plank_dock_element_get_HoveredAnimation:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--HoveredAnimation"><type>"HoveredAnimation"</type></link> property.
 * 
 * The animation to show for the item&apos;s last hover event.
 * 
 * Returns: the value of the <link linkend="PlankDockElement--HoveredAnimation"><type>"HoveredAnimation"</type></link> property
 */
/**
 * plank_dock_element_set_HoveredAnimation:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--HoveredAnimation"><type>"HoveredAnimation"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--HoveredAnimation"><type>"HoveredAnimation"</type></link> property to @value.
 * 
 * The animation to show for the item&apos;s last hover event.
 */
/**
 * PlankDockElement:ScrolledAnimation:
 * 
 * The animation to show for the item&apos;s last scroll event.
 */
/**
 * plank_dock_element_get_ScrolledAnimation:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--ScrolledAnimation"><type>"ScrolledAnimation"</type></link> property.
 * 
 * The animation to show for the item&apos;s last scroll event.
 * 
 * Returns: the value of the <link linkend="PlankDockElement--ScrolledAnimation"><type>"ScrolledAnimation"</type></link> property
 */
/**
 * plank_dock_element_set_ScrolledAnimation:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--ScrolledAnimation"><type>"ScrolledAnimation"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--ScrolledAnimation"><type>"ScrolledAnimation"</type></link> property to @value.
 * 
 * The animation to show for the item&apos;s last scroll event.
 */
/**
 * PlankDockElement:AddTime:
 * 
 * The time the item was added to the dock.
 */
/**
 * plank_dock_element_get_AddTime:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--AddTime"><type>"AddTime"</type></link> property.
 * 
 * The time the item was added to the dock.
 * 
 * Returns: the value of the <link linkend="PlankDockElement--AddTime"><type>"AddTime"</type></link> property
 */
/**
 * plank_dock_element_set_AddTime:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--AddTime"><type>"AddTime"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--AddTime"><type>"AddTime"</type></link> property to @value.
 * 
 * The time the item was added to the dock.
 */
/**
 * PlankDockElement:RemoveTime:
 * 
 * The time the item was removed from the dock.
 */
/**
 * plank_dock_element_get_RemoveTime:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--RemoveTime"><type>"RemoveTime"</type></link> property.
 * 
 * The time the item was removed from the dock.
 * 
 * Returns: the value of the <link linkend="PlankDockElement--RemoveTime"><type>"RemoveTime"</type></link> property
 */
/**
 * plank_dock_element_set_RemoveTime:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--RemoveTime"><type>"RemoveTime"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--RemoveTime"><type>"RemoveTime"</type></link> property to @value.
 * 
 * The time the item was removed from the dock.
 */
/**
 * PlankDockElement:LastClicked:
 * 
 * The last time the item was clicked.
 */
/**
 * plank_dock_element_get_LastClicked:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--LastClicked"><type>"LastClicked"</type></link> property.
 * 
 * The last time the item was clicked.
 * 
 * Returns: the value of the <link linkend="PlankDockElement--LastClicked"><type>"LastClicked"</type></link> property
 */
/**
 * plank_dock_element_set_LastClicked:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--LastClicked"><type>"LastClicked"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--LastClicked"><type>"LastClicked"</type></link> property to @value.
 * 
 * The last time the item was clicked.
 */
/**
 * PlankDockElement:LastHovered:
 * 
 * The last time the item was hovered.
 */
/**
 * plank_dock_element_get_LastHovered:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--LastHovered"><type>"LastHovered"</type></link> property.
 * 
 * The last time the item was hovered.
 * 
 * Returns: the value of the <link linkend="PlankDockElement--LastHovered"><type>"LastHovered"</type></link> property
 */
/**
 * plank_dock_element_set_LastHovered:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--LastHovered"><type>"LastHovered"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--LastHovered"><type>"LastHovered"</type></link> property to @value.
 * 
 * The last time the item was hovered.
 */
/**
 * PlankDockElement:LastScrolled:
 * 
 * The last time the item was scrolled.
 */
/**
 * plank_dock_element_get_LastScrolled:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--LastScrolled"><type>"LastScrolled"</type></link> property.
 * 
 * The last time the item was scrolled.
 * 
 * Returns: the value of the <link linkend="PlankDockElement--LastScrolled"><type>"LastScrolled"</type></link> property
 */
/**
 * plank_dock_element_set_LastScrolled:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--LastScrolled"><type>"LastScrolled"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--LastScrolled"><type>"LastScrolled"</type></link> property to @value.
 * 
 * The last time the item was scrolled.
 */
/**
 * PlankDockElement:LastUrgent:
 * 
 * The last time the item changed its urgent status.
 */
/**
 * plank_dock_element_get_LastUrgent:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--LastUrgent"><type>"LastUrgent"</type></link> property.
 * 
 * The last time the item changed its urgent status.
 * 
 * Returns: the value of the <link linkend="PlankDockElement--LastUrgent"><type>"LastUrgent"</type></link> property
 */
/**
 * plank_dock_element_set_LastUrgent:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--LastUrgent"><type>"LastUrgent"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--LastUrgent"><type>"LastUrgent"</type></link> property to @value.
 * 
 * The last time the item changed its urgent status.
 */
/**
 * PlankDockElement:LastActive:
 * 
 * The last time the item changed its active status.
 */
/**
 * plank_dock_element_get_LastActive:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--LastActive"><type>"LastActive"</type></link> property.
 * 
 * The last time the item changed its active status.
 * 
 * Returns: the value of the <link linkend="PlankDockElement--LastActive"><type>"LastActive"</type></link> property
 */
/**
 * plank_dock_element_set_LastActive:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--LastActive"><type>"LastActive"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--LastActive"><type>"LastActive"</type></link> property to @value.
 * 
 * The last time the item changed its active status.
 */
/**
 * PlankDockElement:LastMove:
 * 
 * The last time the item changed its position.
 */
/**
 * plank_dock_element_get_LastMove:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--LastMove"><type>"LastMove"</type></link> property.
 * 
 * The last time the item changed its position.
 * 
 * Returns: the value of the <link linkend="PlankDockElement--LastMove"><type>"LastMove"</type></link> property
 */
/**
 * plank_dock_element_set_LastMove:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--LastMove"><type>"LastMove"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--LastMove"><type>"LastMove"</type></link> property to @value.
 * 
 * The last time the item changed its position.
 */
/**
 * PlankDockElement:LastValid:
 * 
 * The last time the item was valid.
 */
/**
 * plank_dock_element_get_LastValid:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockElement--LastValid"><type>"LastValid"</type></link> property.
 * 
 * The last time the item was valid.
 * 
 * Returns: the value of the <link linkend="PlankDockElement--LastValid"><type>"LastValid"</type></link> property
 */
/**
 * plank_dock_element_set_LastValid:
 * @self: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockElement--LastValid"><type>"LastValid"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockElement--LastValid"><type>"LastValid"</type></link> property to @value.
 * 
 * The last time the item was valid.
 */
/**
 * PlankDockElement::needs-redraw:
 * @dock_element: the <link linkend="PlankDockElement"><type>PlankDockElement</type></link> instance that received the signal
 * 
 * Signal fired when the dock element needs redrawn.
 */
/**
 * plank_dock_element_create_menu_item:
 * @title: (in): &nbsp;.  <para>the title of the menu item </para>
 * @icon: (in) (allow-none): &nbsp;.  <para>the icon of the menu item </para>
 * @force_show_icon: (in): &nbsp;.  <para>whether to force showing the icon </para>
 * 
 * Creates a new menu item with mnemonics enabled.
 * 
 * Returns: <para>the new menu item </para>
 */
/**
 * plank_dock_element_create_menu_item_with_pixbuf:
 * @title: (in): &nbsp;.  <para>the title of the menu item </para>
 * @pixbuf: (in) (transfer full): &nbsp;.  <para>the icon of the menu item </para>
 * @force_show_icon: (in): &nbsp;.  <para>whether to force showing the icon </para>
 * 
 * Creates a new menu item with mnemonics enabled.
 * 
 * Returns: <para>the new menu item </para>
 */
/**
 * plank_dock_element_create_literal_menu_item:
 * @title: (in): &nbsp;.  <para>the title of the menu item </para>
 * @icon: (in) (allow-none): &nbsp;.  <para>the icon of the menu item </para>
 * @force_show_icon: (in): &nbsp;.  <para>whether to force showing the icon </para>
 * 
 * Creates a new menu item with mnemonics disabled.
 * 
 * Returns: <para>the new menu item </para>
 */
/**
 * plank_dock_element_create_literal_menu_item_with_pixbuf:
 * @title: (in): &nbsp;.  <para>the title of the menu item </para>
 * @pixbuf: (in) (transfer full): &nbsp;.  <para>the icon of the menu item </para>
 * @force_show_icon: (in): &nbsp;.  <para>whether to force showing the icon </para>
 * 
 * Creates a new menu item with mnemonics disabled.
 * 
 * Returns: <para>the new menu item </para>
 */
/**
 * PlankDockElement:
 * 
 * The base class for all dock elements.
 */
/**
 * PlankDockElementClass:
 * @on_clicked: virtual method used internally
 * @on_hovered: virtual method used internally
 * @on_scrolled: virtual method used internally
 * @get_menu_items: virtual method called by <link linkend="plank-dock-element-get-menu-items"><function>plank_dock_element_get_menu_items()</function></link>
 * @get_drop_text: virtual method called by <link linkend="plank-dock-element-get-drop-text"><function>plank_dock_element_get_drop_text()</function></link>
 * @can_be_removed: virtual method called by <link linkend="plank-dock-element-can-be-removed"><function>plank_dock_element_can_be_removed()</function></link>
 * @can_accept_drop: virtual method called by <link linkend="plank-dock-element-can-accept-drop"><function>plank_dock_element_can_accept_drop()</function></link>
 * @accept_drop: virtual method called by <link linkend="plank-dock-element-accept-drop"><function>plank_dock_element_accept_drop()</function></link>
 * @unique_id: virtual method called by <link linkend="plank-dock-element-unique-id"><function>plank_dock_element_unique_id()</function></link>
 * @reset_buffers: virtual method called by <link linkend="plank-dock-element-reset-buffers"><function>plank_dock_element_reset_buffers()</function></link>
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-DOCK-ELEMENT:CAPS"><literal>PLANK_TYPE_DOCK_ELEMENT</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
