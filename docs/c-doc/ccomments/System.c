/**
 * SECTION:System
 * @short_description: A utility class for launching applications and opening files/URIs.
 */
/**
 * PLANK_TYPE_SYSTEM:
 * 
 * The type for <link linkend="PlankSystem"><type>PlankSystem</type></link>.
 */
/**
 * plank_system_open_uri:
 * @self: the <link linkend="PlankSystem"><type>PlankSystem</type></link> instance
 * @uri: (in): &nbsp;.  <para>the URI to open </para>
 * 
 * Opens a file based on a URI.
 */
/**
 * plank_system_open:
 * @self: the <link linkend="PlankSystem"><type>PlankSystem</type></link> instance
 * @file: (in): &nbsp;.  <para>the <link linkend="GFile"><type>GFile</type></link> to open </para>
 * 
 * Opens a file based on a <link linkend="GFile"><type>GFile</type></link>.
 */
/**
 * plank_system_open_files:
 * @self: the <link linkend="PlankSystem"><type>PlankSystem</type></link> instance
 * @files: (in) (array length=files_length1): &nbsp;.  <para>the <link linkend="GFile"><type>GFile</type></link>s to open </para>
 * @files_length1: length of the @files array
 * 
 * Opens multiple files based on <link linkend="GFile"><type>GFile</type></link>.
 */
/**
 * plank_system_launch:
 * @self: the <link linkend="PlankSystem"><type>PlankSystem</type></link> instance
 * @app: (in): &nbsp;.  <para>the application to launch </para>
 * 
 * Launches an application.
 */
/**
 * plank_system_launch_with_files:
 * @self: the <link linkend="PlankSystem"><type>PlankSystem</type></link> instance
 * @app: (in) (allow-none): &nbsp;.  <para>the application to launch </para>
 * @files: (in) (array length=files_length1): &nbsp;.  <para>the files to open with the application </para>
 * @files_length1: length of the @files array
 * 
 * Launches an application and opens files.
 */
/**
 * plank_system_new:
 * @context: &nbsp;
 */
/**
 * PlankSystem:context:
 */
/**
 * plank_system_get_context:
 * @self: the <link linkend="PlankSystem"><type>PlankSystem</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankSystem--context"><type>"context"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankSystem--context"><type>"context"</type></link> property
 */
/**
 * plank_system_get_default:
 * 
 * Returns: (transfer none): 
 */
/**
 * PlankSystem:
 * 
 * A utility class for launching applications and opening files/URIs.
 */
/**
 * PlankSystemClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-SYSTEM:CAPS"><literal>PLANK_TYPE_SYSTEM</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
