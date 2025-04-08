/**
 * plank_get_major_version:
 * @self: the (null) instance
 * 
 * Returns the major version number of the plank library.
 * 
 * <para>This function is in the library, so it represents the GTK+ library your code is are running against.</para>
 * 
 * Returns: <para>the major version number of the plank library </para>
 */
/**
 * plank_get_minor_version:
 * @self: the (null) instance
 * 
 * Returns the minor version number of the plank library.
 * 
 * <para>This function is in the library, so it represents the plank library your code is are running against.</para>
 * 
 * Returns: <para>the minor version number of the plank library </para>
 */
/**
 * plank_get_micro_version:
 * @self: the (null) instance
 * 
 * Returns the micro version number of the plank library.
 * 
 * <para>This function is in the library, so it represents the plank library your code is are running against.</para>
 * 
 * Returns: <para>the micro version number of the plank library </para>
 */
/**
 * plank_get_nano_version:
 * @self: the (null) instance
 * 
 * Returns the nano version number of the plank library.
 * 
 * <para>This function is in the library, so it represents the plank library your code is are running against.</para>
 * 
 * Returns: <para>the nano version number of the plank library </para>
 */
/**
 * plank_check_version:
 * @self: the (null) instance
 * @required_major: (in): &nbsp;.  <para>the required major version </para>
 * @required_minor: (in): &nbsp;.  <para>the required minor version </para>
 * @required_micro: (in): &nbsp;.  <para>the required micro version </para>
 * 
 * Checks that the plank library in use is compatible with the given version.
 * 
 * <para>This function is in the library, so it represents the plank library your code is are running against.</para>
 * 
 * Returns: (transfer none): <para>null if the plank library is compatible with the given version, or a string describing the version mismatch. </para>
 */
/**
 * PLANK_MAJOR_VERSION:
 * 
 * Like get_major_version, but from the headers used at application compile time, rather than from the library linked against at application run time
 */
/**
 * PLANK_MINOR_VERSION:
 * 
 * Like get_minor_version, but from the headers used at application compile time, rather than from the library linked against at application run time
 */
/**
 * PLANK_MICRO_VERSION:
 * 
 * Like get_micro_version, but from the headers used at application compile time, rather than from the library linked against at application run time
 */
/**
 * PLANK_NANO_VERSION:
 * 
 * Like get_nano_version, but from the headers used at application compile time, rather than from the library linked against at application run time
 */
