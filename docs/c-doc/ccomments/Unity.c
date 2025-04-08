/**
 * SECTION:Unity
 * @short_description: Handle the LauncherEntry DBus interface implemented by applications.
 */
/**
 * PLANK_TYPE_UNITY:
 * 
 * The type for <link linkend="PlankUnity"><type>PlankUnity</type></link>.
 */
/**
 * plank_unity_add_client:
 * @self: the <link linkend="PlankUnity"><type>PlankUnity</type></link> instance
 * @client: (in): &nbsp;.  <para>the client to add </para>
 * 
 * Add a client which will receive all update requests of running LauncherEntry applications.
 */
/**
 * plank_unity_remove_client:
 * @self: the <link linkend="PlankUnity"><type>PlankUnity</type></link> instance
 * @client: (in): &nbsp;.  <para>the client to remove </para>
 * 
 * Remove a client.
 */
/**
 * plank_unity_get_default:
 * 
 * Returns: (transfer none): 
 */
/**
 * PlankUnity:
 * 
 * Handle the LauncherEntry DBus interface implemented by applications.
 */
/**
 * PlankUnityClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-UNITY:CAPS"><literal>PLANK_TYPE_UNITY</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
/**
 * plank_unity_client_update_launcher_entry:
 * @self: the <link linkend="PlankUnityClient"><type>PlankUnityClient</type></link> instance
 * @sender_name: (in): &nbsp;.  <para>the dbusname </para>
 * @parameters: (in): &nbsp;.  <para>the data in a standardize format &apos;(sa{sv})&apos; from libunity </para>
 * @is_retry: (in): &nbsp;.  <para>whether this data was already processed before and decided to give is another run </para>
 * 
 * The LauncherEntry corresponding to the sender_name requested an update
 */
/**
 * plank_unity_client_remove_launcher_entry:
 * @self: the <link linkend="PlankUnityClient"><type>PlankUnityClient</type></link> instance
 * @sender_name: (in): &nbsp;.  <para>the dbusname </para>
 * 
 * The LauncherEntry corresponding to the sender_name vanished
 */
/**
 * PlankUnityClient:
 * 
 * The interface to provide the LauncherEntry handling.
 */
/**
 * PlankUnityClientIface:
 * @update_launcher_entry: virtual method called by <link linkend="plank-unity-client-update-launcher-entry"><function>plank_unity_client_update_launcher_entry()</function></link>
 * @remove_launcher_entry: virtual method called by <link linkend="plank-unity-client-remove-launcher-entry"><function>plank_unity_client_remove_launcher_entry()</function></link>
 * @parent_iface: the parent interface structure
 * 
 * Interface for creating <link linkend="PlankUnityClient"><type>PlankUnityClient</type></link> implementations.
 */
