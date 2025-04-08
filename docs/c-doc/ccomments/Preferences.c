/**
 * SECTION:Preferences
 * @short_description: The base class for all preferences in the system. Preferences are serialized to files. The file is watched for changes and loads new values if the backing file changed. When any public property of a sub-class is changed, the public properties are serialized to the backing file.
 */
/**
 * PLANK_TYPE_PREFERENCES:
 * 
 * The type for <link linkend="PlankPreferences"><type>PlankPreferences</type></link>.
 */
/**
 * plank_preferences_verify:
 * @self: the <link linkend="PlankPreferences"><type>PlankPreferences</type></link> instance
 * @prop: (in): &nbsp;.  <para>the name of the property that needs verified </para>
 * 
 * This method will verify the value of a property. If the value is wrong, this method should replace it with a sanitized value.
 */
/**
 * plank_preferences_reset_properties:
 * @self: the <link linkend="PlankPreferences"><type>PlankPreferences</type></link> instance
 * 
 * Resets all properties to their default values. Called from construct and before loading from the backing file.
 */
/**
 * plank_preferences_init_from_file:
 * @self: the <link linkend="PlankPreferences"><type>PlankPreferences</type></link> instance
 * @file: (in): &nbsp;.  <para>the <link linkend="GFile"><type>GFile</type></link> of the backing file for this preferences </para>
 * 
 * Initializes this preferences with a backing file.
 */
/**
 * plank_preferences_init_from_filename:
 * @self: the <link linkend="PlankPreferences"><type>PlankPreferences</type></link> instance
 * @filename: (in): &nbsp;.  <para>of the backing file for this preferences </para>
 * 
 * Initializes this preferences with a backing filename.
 */
/**
 * plank_preferences_delay:
 * @self: the <link linkend="PlankPreferences"><type>PlankPreferences</type></link> instance
 * 
 * Delays saving changes to the backing file until apply() is called.
 */
/**
 * plank_preferences_apply:
 * @self: the <link linkend="PlankPreferences"><type>PlankPreferences</type></link> instance
 * 
 * If any settings were changed, apply them now.
 */
/**
 * plank_preferences_get_filename:
 * @self: the <link linkend="PlankPreferences"><type>PlankPreferences</type></link> instance
 * 
 * Returns the filename of the backing file.
 * 
 * Returns: <para>the filename of the backing file </para>
 */
/**
 * plank_preferences_get_backing_file:
 * @self: the <link linkend="PlankPreferences"><type>PlankPreferences</type></link> instance
 * 
 * Returns the backing file.
 * 
 * Returns: (transfer none): <para>the backing file </para>
 */
/**
 * plank_preferences_delete:
 * @self: the <link linkend="PlankPreferences"><type>PlankPreferences</type></link> instance
 * 
 * This forces the deletion of the backing file for this preferences.
 */
/**
 * PlankPreferences::deleted:
 * @preferences: the <link linkend="PlankPreferences"><type>PlankPreferences</type></link> instance that received the signal
 * 
 * This signal indicates that the backing file for this preferences was deleted.
 */
/**
 * PlankPreferences:
 * 
 * The base class for all preferences in the system. Preferences are serialized to files. The file is watched for changes and loads new values if the backing file changed. When any public property of a sub-class is changed, the public properties are serialized to the backing file.
 */
/**
 * PlankPreferencesClass:
 * @verify: virtual method used internally
 * @reset_properties: virtual method used internally
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-PREFERENCES:CAPS"><literal>PLANK_TYPE_PREFERENCES</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
/**
 * plank_serializable_serialize:
 * @self: the <link linkend="PlankSerializable"><type>PlankSerializable</type></link> instance
 * 
 * Serializes the object into a string representation.
 * 
 * Returns: <para>the string representation of the object </para>
 */
/**
 * plank_serializable_deserialize:
 * @self: the <link linkend="PlankSerializable"><type>PlankSerializable</type></link> instance
 * @s: (in): &nbsp;.  <para>the string representation of the object </para>
 * 
 * De-serializes the object from a string representation.
 */
/**
 * PlankSerializable:
 * 
 * This interface is used by objects that need to be serialized in a Preferences. The object must have a string representation and provide these methods to translate between the string and object representations.
 */
/**
 * PlankSerializableIface:
 * @serialize: virtual method called by <link linkend="plank-serializable-serialize"><function>plank_serializable_serialize()</function></link>
 * @deserialize: virtual method called by <link linkend="plank-serializable-deserialize"><function>plank_serializable_deserialize()</function></link>
 * @parent_iface: the parent interface structure
 * 
 * Interface for creating <link linkend="PlankSerializable"><type>PlankSerializable</type></link> implementations.
 */
