/**
 * SECTION:Logger
 * @short_description: A logging class to display all console messages in a nice colored format.
 */
/**
 * PLANK_TYPE_LOGGER:
 * 
 * The type for <link linkend="PlankLogger"><type>PlankLogger</type></link>.
 */
/**
 * PlankLogger:DisplayLevel:
 * 
 * The current log level. Controls what log messages actually appear on the console.
 */
/**
 * plank_logger_get_DisplayLevel:
 * @self: the <link linkend="PlankLogger"><type>PlankLogger</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankLogger--DisplayLevel"><type>"DisplayLevel"</type></link> property.
 * 
 * The current log level. Controls what log messages actually appear on the console.
 * 
 * Returns: the value of the <link linkend="PlankLogger--DisplayLevel"><type>"DisplayLevel"</type></link> property
 */
/**
 * plank_logger_set_DisplayLevel:
 * @self: the <link linkend="PlankLogger"><type>PlankLogger</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankLogger--DisplayLevel"><type>"DisplayLevel"</type></link> property
 * 
 * Set the value of the <link linkend="PlankLogger--DisplayLevel"><type>"DisplayLevel"</type></link> property to @value.
 * 
 * The current log level. Controls what log messages actually appear on the console.
 */
/**
 * plank_logger_initialize:
 * @app_name: (in): &nbsp;.  <para>the name of the application </para>
 * 
 * Initializes the logger for the application.
 */
/**
 * plank_logger_notification:
 * @msg: (in): &nbsp;.  <para>the log message to display </para>
 * @icon: (in): &nbsp;.  <para>the icon to display in the notification </para>
 * 
 * Displays a log message using libnotify. Also displays on the console.
 */
/**
 * plank_logger_verbose:
 * @msg: (in): &nbsp;.  <para>the log message to display </para>
 * @...: &nbsp;
 * 
 * Displays a verbose log message to the console.
 */
/**
 * PlankLogger:
 * 
 * A logging class to display all console messages in a nice colored format.
 */
/**
 * PlankLoggerClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-LOGGER:CAPS"><literal>PLANK_TYPE_LOGGER</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
/**
 * PlankLogLevel:
 * @PLANK_LOG_LEVEL_VERBOSE: Extra debugging info. A *LOT* of messages.
 * @PLANK_LOG_LEVEL_DEBUG: Debugging messages that help track what the application is doing.
 * @PLANK_LOG_LEVEL_INFO: General information messages. Similar to debug but perhaps useful to non-debug users.
 * @PLANK_LOG_LEVEL_NOTIFY: Messages that also show a libnotify message.
 * @PLANK_LOG_LEVEL_WARN: Any messsage that is a warning.
 * @PLANK_LOG_LEVEL_CRITICAL: Any message considered critical. These can be recovered from but might make the application function abnormally.
 * @PLANK_LOG_LEVEL_ERROR: Any message considered an error. These generally break the application.
 * 
 * Controls what messages show in the console log.
 */
