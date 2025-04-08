/**
 * SECTION:Paths
 * @short_description: A wrapper class that gives static instances of <link linkend="GFile"><type>GFile</type></link> for commonly used paths. Most paths are retrieved from GLib.Environment, which on Linux uses the XDG Base Directory specification (see <ulink url="http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html"></ulink>).
 * 
 * <para>Initializing this class also ensures any writable directories exist.</para>
 */
/**
 * PLANK_TYPE_PATHS:
 * 
 * The type for <link linkend="PlankPaths"><type>PlankPaths</type></link>.
 */
/**
 * PlankPaths:HomeFolder:
 * 
 * User&apos;s home folder - $HOME
 */
/**
 * plank_paths_get_HomeFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPaths--HomeFolder"><type>"HomeFolder"</type></link> property.
 * 
 * User&apos;s home folder - $HOME
 * 
 * Returns: the value of the <link linkend="PlankPaths--HomeFolder"><type>"HomeFolder"</type></link> property
 */
/**
 * plank_paths_set_HomeFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankPaths--HomeFolder"><type>"HomeFolder"</type></link> property
 * 
 * Set the value of the <link linkend="PlankPaths--HomeFolder"><type>"HomeFolder"</type></link> property to @value.
 * 
 * User&apos;s home folder - $HOME
 */
/**
 * PlankPaths:DataFolder:
 * 
 * Path passed in to initialize method should be Build.PKGDATADIR
 */
/**
 * plank_paths_get_DataFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPaths--DataFolder"><type>"DataFolder"</type></link> property.
 * 
 * Path passed in to initialize method should be Build.PKGDATADIR
 * 
 * Returns: the value of the <link linkend="PlankPaths--DataFolder"><type>"DataFolder"</type></link> property
 */
/**
 * plank_paths_set_DataFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankPaths--DataFolder"><type>"DataFolder"</type></link> property
 * 
 * Set the value of the <link linkend="PlankPaths--DataFolder"><type>"DataFolder"</type></link> property to @value.
 * 
 * Path passed in to initialize method should be Build.PKGDATADIR
 */
/**
 * PlankPaths:ThemeFolder:
 * 
 * DataFolder/themes
 */
/**
 * plank_paths_get_ThemeFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPaths--ThemeFolder"><type>"ThemeFolder"</type></link> property.
 * 
 * DataFolder/themes
 * 
 * Returns: the value of the <link linkend="PlankPaths--ThemeFolder"><type>"ThemeFolder"</type></link> property
 */
/**
 * plank_paths_set_ThemeFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankPaths--ThemeFolder"><type>"ThemeFolder"</type></link> property
 * 
 * Set the value of the <link linkend="PlankPaths--ThemeFolder"><type>"ThemeFolder"</type></link> property to @value.
 * 
 * DataFolder/themes
 */
/**
 * PlankPaths:ConfigHomeFolder:
 * 
 * HomeFolder/.config
 */
/**
 * plank_paths_get_ConfigHomeFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPaths--ConfigHomeFolder"><type>"ConfigHomeFolder"</type></link> property.
 * 
 * HomeFolder/.config
 * 
 * Returns: the value of the <link linkend="PlankPaths--ConfigHomeFolder"><type>"ConfigHomeFolder"</type></link> property
 */
/**
 * plank_paths_set_ConfigHomeFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankPaths--ConfigHomeFolder"><type>"ConfigHomeFolder"</type></link> property
 * 
 * Set the value of the <link linkend="PlankPaths--ConfigHomeFolder"><type>"ConfigHomeFolder"</type></link> property to @value.
 * 
 * HomeFolder/.config
 */
/**
 * PlankPaths:DataHomeFolder:
 * 
 * HomeFolder/.local/share
 */
/**
 * plank_paths_get_DataHomeFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPaths--DataHomeFolder"><type>"DataHomeFolder"</type></link> property.
 * 
 * HomeFolder/.local/share
 * 
 * Returns: the value of the <link linkend="PlankPaths--DataHomeFolder"><type>"DataHomeFolder"</type></link> property
 */
/**
 * plank_paths_set_DataHomeFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankPaths--DataHomeFolder"><type>"DataHomeFolder"</type></link> property
 * 
 * Set the value of the <link linkend="PlankPaths--DataHomeFolder"><type>"DataHomeFolder"</type></link> property to @value.
 * 
 * HomeFolder/.local/share
 */
/**
 * PlankPaths:CacheHomeFolder:
 * 
 * HomeFolder/.cache
 */
/**
 * plank_paths_get_CacheHomeFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPaths--CacheHomeFolder"><type>"CacheHomeFolder"</type></link> property.
 * 
 * HomeFolder/.cache
 * 
 * Returns: the value of the <link linkend="PlankPaths--CacheHomeFolder"><type>"CacheHomeFolder"</type></link> property
 */
/**
 * plank_paths_set_CacheHomeFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankPaths--CacheHomeFolder"><type>"CacheHomeFolder"</type></link> property
 * 
 * Set the value of the <link linkend="PlankPaths--CacheHomeFolder"><type>"CacheHomeFolder"</type></link> property to @value.
 * 
 * HomeFolder/.cache
 */
/**
 * PlankPaths:DataDirFolders:
 * 
 * /usr/local/share/:/usr/share/
 */
/**
 * plank_paths_get_DataDirFolders:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPaths--DataDirFolders"><type>"DataDirFolders"</type></link> property.
 * 
 * /usr/local/share/:/usr/share/
 * 
 * Returns: the value of the <link linkend="PlankPaths--DataDirFolders"><type>"DataDirFolders"</type></link> property
 */
/**
 * plank_paths_set_DataDirFolders:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankPaths--DataDirFolders"><type>"DataDirFolders"</type></link> property
 * 
 * Set the value of the <link linkend="PlankPaths--DataDirFolders"><type>"DataDirFolders"</type></link> property to @value.
 * 
 * /usr/local/share/:/usr/share/
 */
/**
 * PlankPaths:AppConfigFolder:
 * 
 * defaults to ConfigHomeFolder/app_name
 */
/**
 * plank_paths_get_AppConfigFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPaths--AppConfigFolder"><type>"AppConfigFolder"</type></link> property.
 * 
 * defaults to ConfigHomeFolder/app_name
 * 
 * Returns: the value of the <link linkend="PlankPaths--AppConfigFolder"><type>"AppConfigFolder"</type></link> property
 */
/**
 * plank_paths_set_AppConfigFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankPaths--AppConfigFolder"><type>"AppConfigFolder"</type></link> property
 * 
 * Set the value of the <link linkend="PlankPaths--AppConfigFolder"><type>"AppConfigFolder"</type></link> property to @value.
 * 
 * defaults to ConfigHomeFolder/app_name
 */
/**
 * PlankPaths:AppDataFolder:
 * 
 * defaults to DataHomeFolder/app_name
 */
/**
 * plank_paths_get_AppDataFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPaths--AppDataFolder"><type>"AppDataFolder"</type></link> property.
 * 
 * defaults to DataHomeFolder/app_name
 * 
 * Returns: the value of the <link linkend="PlankPaths--AppDataFolder"><type>"AppDataFolder"</type></link> property
 */
/**
 * plank_paths_set_AppDataFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankPaths--AppDataFolder"><type>"AppDataFolder"</type></link> property
 * 
 * Set the value of the <link linkend="PlankPaths--AppDataFolder"><type>"AppDataFolder"</type></link> property to @value.
 * 
 * defaults to DataHomeFolder/app_name
 */
/**
 * PlankPaths:AppThemeFolder:
 * 
 * defaults to AppDataFolder/themes
 */
/**
 * plank_paths_get_AppThemeFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPaths--AppThemeFolder"><type>"AppThemeFolder"</type></link> property.
 * 
 * defaults to AppDataFolder/themes
 * 
 * Returns: the value of the <link linkend="PlankPaths--AppThemeFolder"><type>"AppThemeFolder"</type></link> property
 */
/**
 * plank_paths_set_AppThemeFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankPaths--AppThemeFolder"><type>"AppThemeFolder"</type></link> property
 * 
 * Set the value of the <link linkend="PlankPaths--AppThemeFolder"><type>"AppThemeFolder"</type></link> property to @value.
 * 
 * defaults to AppDataFolder/themes
 */
/**
 * PlankPaths:AppCacheFolder:
 * 
 * defaults to CacheHomeFolder/app_name
 */
/**
 * plank_paths_get_AppCacheFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPaths--AppCacheFolder"><type>"AppCacheFolder"</type></link> property.
 * 
 * defaults to CacheHomeFolder/app_name
 * 
 * Returns: the value of the <link linkend="PlankPaths--AppCacheFolder"><type>"AppCacheFolder"</type></link> property
 */
/**
 * plank_paths_set_AppCacheFolder:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankPaths--AppCacheFolder"><type>"AppCacheFolder"</type></link> property
 * 
 * Set the value of the <link linkend="PlankPaths--AppCacheFolder"><type>"AppCacheFolder"</type></link> property to @value.
 * 
 * defaults to CacheHomeFolder/app_name
 */
/**
 * PlankPaths:AppName:
 * 
 * application name which got passed to initialize
 */
/**
 * plank_paths_get_AppName:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankPaths--AppName"><type>"AppName"</type></link> property.
 * 
 * application name which got passed to initialize
 * 
 * Returns: the value of the <link linkend="PlankPaths--AppName"><type>"AppName"</type></link> property
 */
/**
 * plank_paths_set_AppName:
 * @self: the <link linkend="PlankPaths"><type>PlankPaths</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankPaths--AppName"><type>"AppName"</type></link> property
 * 
 * Set the value of the <link linkend="PlankPaths--AppName"><type>"AppName"</type></link> property to @value.
 * 
 * application name which got passed to initialize
 */
/**
 * plank_paths_initialize:
 * @app_name: (in): &nbsp;.  <para>the name of the application </para>
 * @data_folder: (in): &nbsp;.  <para>the path to the application&apos;s data folder </para>
 * 
 * Initialize the class, creating the <link linkend="GFile"><type>GFile</type></link> instances for all common paths. Also ensure that any writable directory exists.
 */
/**
 * plank_paths_ensure_directory_exists:
 * @dir: (in): &nbsp;.  <para>the directory to ensure exists </para>
 * 
 * Creates the directory if it does not already exist
 * 
 * Returns: <para>true if a directory was created, false otherwise </para>
 */
/**
 * PlankPaths:
 * 
 * A wrapper class that gives static instances of <link linkend="GFile"><type>GFile</type></link> for commonly used paths. Most paths are retrieved from GLib.Environment, which on Linux uses the XDG Base Directory specification (see <ulink url="http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html"></ulink>).
 * 
 * <para>Initializing this class also ensures any writable directories exist.</para>
 */
/**
 * PlankPathsClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-PATHS:CAPS"><literal>PLANK_TYPE_PATHS</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
