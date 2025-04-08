/**
 * SECTION:Client
 * @short_description: Connects to a running instance of plank via DBus and provides remote interface to a currently runnning dock.
 */
/**
 * PLANK_TYPE_DBUS_CLIENT:
 * 
 * The type for <link linkend="PlankDBusClient"><type>PlankDBusClient</type></link>.
 */
/**
 * plank_dbus_client_add_item:
 * @self: the <link linkend="PlankDBusClient"><type>PlankDBusClient</type></link> instance
 * @uri: (in): &nbsp;.  <para>an URI </para>
 * 
 * Add a new item for the given uri to the dock
 * 
 * Returns: <para>whether it was successfully added </para>
 */
/**
 * plank_dbus_client_remove_item:
 * @self: the <link linkend="PlankDBusClient"><type>PlankDBusClient</type></link> instance
 * @uri: (in): &nbsp;.  <para>an URI </para>
 * 
 * Remove an existing item for the given uri from the dock
 * 
 * Returns: <para>whether it was successfully removed </para>
 */
/**
 * plank_dbus_client_get_items_count:
 * @self: the <link linkend="PlankDBusClient"><type>PlankDBusClient</type></link> instance
 * 
 * Returns the number of currently visible items on the dock
 * 
 * Returns: <para>the item-count </para>
 */
/**
 * plank_dbus_client_get_persistent_applications:
 * @self: the <link linkend="PlankDBusClient"><type>PlankDBusClient</type></link> instance
 * 
 * Returns an array of uris of the persistent applications on the dock
 * 
 * Returns: (array length=result_length1) (transfer none): <para>the array of uris </para>
 */
/**
 * plank_dbus_client_get_transient_applications:
 * @self: the <link linkend="PlankDBusClient"><type>PlankDBusClient</type></link> instance
 * 
 * Returns an array of uris of the transient applications on the dock
 * 
 * Returns: (array length=result_length1) (transfer none): <para>the array of uris </para>
 */
/**
 * plank_dbus_client_get_hover_position:
 * @self: the <link linkend="PlankDBusClient"><type>PlankDBusClient</type></link> instance
 * @uri: (in): &nbsp;.  <para>an URI </para>
 * @x: (out): &nbsp;.  <para>the resulting x position </para>
 * @y: (out): &nbsp;.  <para>the resulting y position </para>
 * @dock_position: (out): &nbsp;.  <para>the position of the dock </para>
 * 
 * Gets the x,y coords with the dock&apos;s position to display a hover window for an item.
 * 
 * Returns: <para>whether it was successfully retrieved </para>
 */
/**
 * PlankDBusClient:is-connected:
 * 
 * Whether the client is in an operatable state and connected to a running dock
 */
/**
 * plank_dbus_client_get_is_connected:
 * @self: the <link linkend="PlankDBusClient"><type>PlankDBusClient</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDBusClient--is-connected"><type>"is-connected"</type></link> property.
 * 
 * Whether the client is in an operatable state and connected to a running dock
 * 
 * Returns: the value of the <link linkend="PlankDBusClient--is-connected"><type>"is-connected"</type></link> property
 */
/**
 * PlankDBusClient::proxy-changed:
 * @dbus_client: the <link linkend="PlankDBusClient"><type>PlankDBusClient</type></link> instance that received the signal
 * 
 * If the proxy interfaces for the dock are ready to be used or were changed on runtime this signal will be emitted.
 */
/**
 * plank_dbus_client_get_instance:
 * 
 * Get the singleton instance of <link linkend="PlankDBusClient"><type>PlankDBusClient</type></link>
 * 
 * Returns: (transfer none): 
 */
/**
 * PlankDBusClient:
 * 
 * Connects to a running instance of plank via DBus and provides remote interface to a currently runnning dock.
 */
/**
 * PlankDBusClientClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-DBUS-CLIENT:CAPS"><literal>PLANK_TYPE_DBUS_CLIENT</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
