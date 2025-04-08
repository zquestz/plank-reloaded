/**
 * SECTION:AbstractMain
 * @short_description: The main class for all dock applications. All docks should extend this class. In the constructor, the string fields should be initialized to customize the dock.
 */
/**
 * PLANK_TYPE_ABSTRACT_MAIN:
 * 
 * The type for <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link>.
 */
/**
 * plank_abstract_main_initialize:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance
 * 
 * Additional initializations before the dock is created.
 */
/**
 * plank_abstract_main_create_docks:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance
 * 
 * Creates the docks.
 */
/**
 * plank_abstract_main_create_actions:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance
 * 
 * Creates the actions and adds them to this <link linkend="GApplication"><type>GApplication</type></link>.
 */
/**
 * plank_abstract_main_is_launcher_for_dock:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance
 * @launcher: (in): &nbsp;.  <para>the launcher to test </para>
 * 
 * Is true if the launcher given is the launcher for this dock.
 */
/**
 * PlankAbstractMain:build-data-dir:
 * 
 * Should be Build.DATADIR
 */
/**
 * plank_abstract_main_get_build_data_dir:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--build-data-dir"><type>"build-data-dir"</type></link> property.
 * 
 * Should be Build.DATADIR
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--build-data-dir"><type>"build-data-dir"</type></link> property
 */
/**
 * PlankAbstractMain:build-pkg-data-dir:
 * 
 * Should be Build.PKGDATADIR
 */
/**
 * plank_abstract_main_get_build_pkg_data_dir:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--build-pkg-data-dir"><type>"build-pkg-data-dir"</type></link> property.
 * 
 * Should be Build.PKGDATADIR
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--build-pkg-data-dir"><type>"build-pkg-data-dir"</type></link> property
 */
/**
 * PlankAbstractMain:build-release-name:
 * 
 * Should be Build.RELEASE_NAME
 */
/**
 * plank_abstract_main_get_build_release_name:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--build-release-name"><type>"build-release-name"</type></link> property.
 * 
 * Should be Build.RELEASE_NAME
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--build-release-name"><type>"build-release-name"</type></link> property
 */
/**
 * PlankAbstractMain:build-version:
 * 
 * Should be Build.VERSION
 */
/**
 * plank_abstract_main_get_build_version:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--build-version"><type>"build-version"</type></link> property.
 * 
 * Should be Build.VERSION
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--build-version"><type>"build-version"</type></link> property
 */
/**
 * PlankAbstractMain:build-version-info:
 * 
 * Should be Build.VERSION_INFO
 */
/**
 * plank_abstract_main_get_build_version_info:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--build-version-info"><type>"build-version-info"</type></link> property.
 * 
 * Should be Build.VERSION_INFO
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--build-version-info"><type>"build-version-info"</type></link> property
 */
/**
 * PlankAbstractMain:program-name:
 * 
 * The displayed name of the program.
 */
/**
 * plank_abstract_main_get_program_name:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--program-name"><type>"program-name"</type></link> property.
 * 
 * The displayed name of the program.
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--program-name"><type>"program-name"</type></link> property
 */
/**
 * PlankAbstractMain:exec-name:
 * 
 * The executable name of the program.
 */
/**
 * plank_abstract_main_get_exec_name:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--exec-name"><type>"exec-name"</type></link> property.
 * 
 * The executable name of the program.
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--exec-name"><type>"exec-name"</type></link> property
 */
/**
 * PlankAbstractMain:app-copyright:
 * 
 * The copyright year(s).
 */
/**
 * plank_abstract_main_get_app_copyright:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--app-copyright"><type>"app-copyright"</type></link> property.
 * 
 * The copyright year(s).
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--app-copyright"><type>"app-copyright"</type></link> property
 */
/**
 * PlankAbstractMain:app-dbus:
 * 
 * The (unique) dbus path for this program.
 */
/**
 * plank_abstract_main_get_app_dbus:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--app-dbus"><type>"app-dbus"</type></link> property.
 * 
 * The (unique) dbus path for this program.
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--app-dbus"><type>"app-dbus"</type></link> property
 */
/**
 * PlankAbstractMain:app-icon:
 * 
 * The name of this program&apos;s icon.
 */
/**
 * plank_abstract_main_get_app_icon:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--app-icon"><type>"app-icon"</type></link> property.
 * 
 * The name of this program&apos;s icon.
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--app-icon"><type>"app-icon"</type></link> property
 */
/**
 * PlankAbstractMain:app-launcher:
 * 
 * The name of the launcher (.desktop file) for this program.
 */
/**
 * plank_abstract_main_get_app_launcher:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--app-launcher"><type>"app-launcher"</type></link> property.
 * 
 * The name of the launcher (.desktop file) for this program.
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--app-launcher"><type>"app-launcher"</type></link> property
 */
/**
 * PlankAbstractMain:main-url:
 * 
 * The URL for this program&apos;s website.
 */
/**
 * plank_abstract_main_get_main_url:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--main-url"><type>"main-url"</type></link> property.
 * 
 * The URL for this program&apos;s website.
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--main-url"><type>"main-url"</type></link> property
 */
/**
 * plank_abstract_main_set_main_url:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankAbstractMain--main-url"><type>"main-url"</type></link> property
 * 
 * Set the value of the <link linkend="PlankAbstractMain--main-url"><type>"main-url"</type></link> property to @value.
 * 
 * The URL for this program&apos;s website.
 */
/**
 * PlankAbstractMain:help-url:
 * 
 * The URL for this program&apos;s help.
 */
/**
 * plank_abstract_main_get_help_url:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--help-url"><type>"help-url"</type></link> property.
 * 
 * The URL for this program&apos;s help.
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--help-url"><type>"help-url"</type></link> property
 */
/**
 * plank_abstract_main_set_help_url:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankAbstractMain--help-url"><type>"help-url"</type></link> property
 * 
 * Set the value of the <link linkend="PlankAbstractMain--help-url"><type>"help-url"</type></link> property to @value.
 * 
 * The URL for this program&apos;s help.
 */
/**
 * PlankAbstractMain:translate-url:
 * 
 * The URL for translating this program.
 */
/**
 * plank_abstract_main_get_translate_url:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--translate-url"><type>"translate-url"</type></link> property.
 * 
 * The URL for translating this program.
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--translate-url"><type>"translate-url"</type></link> property
 */
/**
 * plank_abstract_main_set_translate_url:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankAbstractMain--translate-url"><type>"translate-url"</type></link> property
 * 
 * Set the value of the <link linkend="PlankAbstractMain--translate-url"><type>"translate-url"</type></link> property to @value.
 * 
 * The URL for translating this program.
 */
/**
 * PlankAbstractMain:about-authors:
 * @result_length1: return location for the length of the property's value
 * @value_length1: length of the property's new value
 * 
 * The list of authors (to show in about dialog).
 */
/**
 * plank_abstract_main_get_about_authors:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--about-authors"><type>"about-authors"</type></link> property.
 * 
 * The list of authors (to show in about dialog).
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--about-authors"><type>"about-authors"</type></link> property
 */
/**
 * plank_abstract_main_set_about_authors:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankAbstractMain--about-authors"><type>"about-authors"</type></link> property
 * 
 * Set the value of the <link linkend="PlankAbstractMain--about-authors"><type>"about-authors"</type></link> property to @value.
 * 
 * The list of authors (to show in about dialog).
 */
/**
 * PlankAbstractMain:about-documenters:
 * @result_length1: return location for the length of the property's value
 * @value_length1: length of the property's new value
 * 
 * The list of documenters (to show in about dialog).
 */
/**
 * plank_abstract_main_get_about_documenters:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--about-documenters"><type>"about-documenters"</type></link> property.
 * 
 * The list of documenters (to show in about dialog).
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--about-documenters"><type>"about-documenters"</type></link> property
 */
/**
 * plank_abstract_main_set_about_documenters:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankAbstractMain--about-documenters"><type>"about-documenters"</type></link> property
 * 
 * Set the value of the <link linkend="PlankAbstractMain--about-documenters"><type>"about-documenters"</type></link> property to @value.
 * 
 * The list of documenters (to show in about dialog).
 */
/**
 * PlankAbstractMain:about-artists:
 * @result_length1: return location for the length of the property's value
 * @value_length1: length of the property's new value
 * 
 * The list of artists (to show in about dialog).
 */
/**
 * plank_abstract_main_get_about_artists:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--about-artists"><type>"about-artists"</type></link> property.
 * 
 * The list of artists (to show in about dialog).
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--about-artists"><type>"about-artists"</type></link> property
 */
/**
 * plank_abstract_main_set_about_artists:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankAbstractMain--about-artists"><type>"about-artists"</type></link> property
 * 
 * Set the value of the <link linkend="PlankAbstractMain--about-artists"><type>"about-artists"</type></link> property to @value.
 * 
 * The list of artists (to show in about dialog).
 */
/**
 * PlankAbstractMain:about-translators:
 * 
 * The list of translators (to show in about dialog).
 */
/**
 * plank_abstract_main_get_about_translators:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--about-translators"><type>"about-translators"</type></link> property.
 * 
 * The list of translators (to show in about dialog).
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--about-translators"><type>"about-translators"</type></link> property
 */
/**
 * plank_abstract_main_set_about_translators:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankAbstractMain--about-translators"><type>"about-translators"</type></link> property
 * 
 * Set the value of the <link linkend="PlankAbstractMain--about-translators"><type>"about-translators"</type></link> property to @value.
 * 
 * The list of translators (to show in about dialog).
 */
/**
 * PlankAbstractMain:about-license-type:
 * 
 * The license of this program (to show in about dialog).
 */
/**
 * plank_abstract_main_get_about_license_type:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankAbstractMain--about-license-type"><type>"about-license-type"</type></link> property.
 * 
 * The license of this program (to show in about dialog).
 * 
 * Returns: the value of the <link linkend="PlankAbstractMain--about-license-type"><type>"about-license-type"</type></link> property
 */
/**
 * plank_abstract_main_set_about_license_type:
 * @self: the <link linkend="PlankAbstractMain"><type>PlankAbstractMain</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankAbstractMain--about-license-type"><type>"about-license-type"</type></link> property
 * 
 * Set the value of the <link linkend="PlankAbstractMain--about-license-type"><type>"about-license-type"</type></link> property to @value.
 * 
 * The license of this program (to show in about dialog).
 */
/**
 * PlankAbstractMain:
 * 
 * The main class for all dock applications. All docks should extend this class. In the constructor, the string fields should be initialized to customize the dock.
 */
/**
 * PlankAbstractMainClass:
 * @initialize: virtual method used internally
 * @create_docks: virtual method used internally
 * @create_actions: virtual method used internally
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-ABSTRACT-MAIN:CAPS"><literal>PLANK_TYPE_ABSTRACT_MAIN</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
