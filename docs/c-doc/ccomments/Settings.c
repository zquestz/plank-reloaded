/**
 * SECTION:Settings
 * @short_description: The base class for gsettings-based configuration classes. Defined properties will be bound to the corresponing schema-key of the given schema-path. The property&apos;s nick-name must match the schema-key.
 */
/**
 * PLANK_TYPE_SETTINGS:
 * 
 * The type for <link linkend="PlankSettings"><type>PlankSettings</type></link>.
 */
/**
 * plank_settings_verify:
 * @self: the <link linkend="PlankSettings"><type>PlankSettings</type></link> instance
 * @name: (in): &nbsp;.  <para>the name of the property </para>
 * 
 * Verify the property given by its name and change the property if necessary.
 */
/**
 * plank_settings_reset_all:
 * @self: the <link linkend="PlankSettings"><type>PlankSettings</type></link> instance
 * 
 * Resets all properties to their default values.
 */
/**
 * plank_settings_delay:
 * @self: the <link linkend="PlankSettings"><type>PlankSettings</type></link> instance
 * 
 * Delays saving changes until apply() is called.
 */
/**
 * plank_settings_apply:
 * @self: the <link linkend="PlankSettings"><type>PlankSettings</type></link> instance
 * 
 * If any settings were changed, apply them now.
 */
/**
 * PlankSettings:settings:
 */
/**
 * plank_settings_get_settings:
 * @self: the <link linkend="PlankSettings"><type>PlankSettings</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankSettings--settings"><type>"settings"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankSettings--settings"><type>"settings"</type></link> property
 */
/**
 * PlankSettings:bind-flags:
 */
/**
 * plank_settings_get_bind_flags:
 * @self: the <link linkend="PlankSettings"><type>PlankSettings</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankSettings--bind-flags"><type>"bind-flags"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankSettings--bind-flags"><type>"bind-flags"</type></link> property
 */
/**
 * PlankSettings:
 * 
 * The base class for gsettings-based configuration classes. Defined properties will be bound to the corresponing schema-key of the given schema-path. The property&apos;s nick-name must match the schema-key.
 */
/**
 * PlankSettingsClass:
 * @verify: virtual method used internally
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-SETTINGS:CAPS"><literal>PLANK_TYPE_SETTINGS</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
