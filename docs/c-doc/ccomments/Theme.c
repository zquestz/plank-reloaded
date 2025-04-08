/**
 * SECTION:Theme
 * @short_description: A themed renderer for windows.
 */
/**
 * PLANK_TYPE_THEME:
 * 
 * The type for <link linkend="PlankTheme"><type>PlankTheme</type></link>.
 */
/**
 * plank_theme_get_style_context:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance
 * 
 * Returns: (transfer none): 
 */
/**
 * plank_theme_load:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance
 * @type: (in): &nbsp;.  <para>the type of theme to load </para>
 * 
 * Loads a theme for the renderer to use.
 */
/**
 * plank_theme_get_top_offset:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance
 * 
 * Returns the top offset.
 * 
 * Returns: <para>the top offset </para>
 */
/**
 * plank_theme_get_bottom_offset:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance
 * 
 * Returns the bottom offset.
 * 
 * Returns: <para>the bottom offset </para>
 */
/**
 * plank_theme_draw_background:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance
 * @surface: (in): &nbsp;.  <para>the surface to draw on </para>
 * 
 * Draws a background onto the surface.
 */
/**
 * plank_theme_draw_inner_rect:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance
 * @cr: (in): &nbsp;.  <para>the context to draw with </para>
 * @width: (in): &nbsp;.  <para>the width of the rect </para>
 * @height: (in): &nbsp;.  <para>the height of the rect </para>
 * 
 * Similar to draw_rounded_rect, but moves in to avoid a containing rounded rect&apos;s lines.
 */
/**
 * PLANK_THEME_DEFAULT_NAME:
 */
/**
 * PLANK_THEME_GTK_THEME_NAME:
 */
/**
 * PlankTheme:TopRoundness:
 */
/**
 * plank_theme_get_TopRoundness:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankTheme--TopRoundness"><type>"TopRoundness"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankTheme--TopRoundness"><type>"TopRoundness"</type></link> property
 */
/**
 * plank_theme_set_TopRoundness:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankTheme--TopRoundness"><type>"TopRoundness"</type></link> property
 * 
 * Set the value of the <link linkend="PlankTheme--TopRoundness"><type>"TopRoundness"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankTheme:BottomRoundness:
 */
/**
 * plank_theme_get_BottomRoundness:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankTheme--BottomRoundness"><type>"BottomRoundness"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankTheme--BottomRoundness"><type>"BottomRoundness"</type></link> property
 */
/**
 * plank_theme_set_BottomRoundness:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankTheme--BottomRoundness"><type>"BottomRoundness"</type></link> property
 * 
 * Set the value of the <link linkend="PlankTheme--BottomRoundness"><type>"BottomRoundness"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankTheme:LineWidth:
 */
/**
 * plank_theme_get_LineWidth:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankTheme--LineWidth"><type>"LineWidth"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankTheme--LineWidth"><type>"LineWidth"</type></link> property
 */
/**
 * plank_theme_set_LineWidth:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankTheme--LineWidth"><type>"LineWidth"</type></link> property
 * 
 * Set the value of the <link linkend="PlankTheme--LineWidth"><type>"LineWidth"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankTheme:OuterStrokeColor:
 */
/**
 * plank_theme_get_OuterStrokeColor:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankTheme--OuterStrokeColor"><type>"OuterStrokeColor"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankTheme--OuterStrokeColor"><type>"OuterStrokeColor"</type></link> property
 */
/**
 * plank_theme_set_OuterStrokeColor:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankTheme--OuterStrokeColor"><type>"OuterStrokeColor"</type></link> property
 * 
 * Set the value of the <link linkend="PlankTheme--OuterStrokeColor"><type>"OuterStrokeColor"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankTheme:FillStartColor:
 */
/**
 * plank_theme_get_FillStartColor:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankTheme--FillStartColor"><type>"FillStartColor"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankTheme--FillStartColor"><type>"FillStartColor"</type></link> property
 */
/**
 * plank_theme_set_FillStartColor:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankTheme--FillStartColor"><type>"FillStartColor"</type></link> property
 * 
 * Set the value of the <link linkend="PlankTheme--FillStartColor"><type>"FillStartColor"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankTheme:FillEndColor:
 */
/**
 * plank_theme_get_FillEndColor:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankTheme--FillEndColor"><type>"FillEndColor"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankTheme--FillEndColor"><type>"FillEndColor"</type></link> property
 */
/**
 * plank_theme_set_FillEndColor:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankTheme--FillEndColor"><type>"FillEndColor"</type></link> property
 * 
 * Set the value of the <link linkend="PlankTheme--FillEndColor"><type>"FillEndColor"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankTheme:InnerStrokeColor:
 */
/**
 * plank_theme_get_InnerStrokeColor:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankTheme--InnerStrokeColor"><type>"InnerStrokeColor"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankTheme--InnerStrokeColor"><type>"InnerStrokeColor"</type></link> property
 */
/**
 * plank_theme_set_InnerStrokeColor:
 * @self: the <link linkend="PlankTheme"><type>PlankTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankTheme--InnerStrokeColor"><type>"InnerStrokeColor"</type></link> property
 * 
 * Set the value of the <link linkend="PlankTheme--InnerStrokeColor"><type>"InnerStrokeColor"</type></link> property to @value.
 * 
 * 
 */
/**
 * plank_theme_create_style_context:
 * @widget_type: &nbsp;
 * @parent_style: &nbsp;
 * @provider: &nbsp;
 * @object_name: &nbsp;
 * @first_class: &nbsp;
 * @...: &nbsp;
 */
/**
 * plank_theme_draw_rounded_rect:
 * @cr: (in): &nbsp;.  <para>the context to draw with </para>
 * @x: (in): &nbsp;.  <para>the x location of the rect </para>
 * @y: (in): &nbsp;.  <para>the y location of the rect </para>
 * @width: (in): &nbsp;.  <para>the width of the rect </para>
 * @height: (in): &nbsp;.  <para>the height of the rect </para>
 * @top_radius: (in): &nbsp;.  <para>the roundedness of the top edge </para>
 * @bottom_radius: (in): &nbsp;.  <para>the roundedness of the bottom edge </para>
 * @line_width: (in): &nbsp;.  <para>the line-width of the rect </para>
 * 
 * Draws a rounded rectangle. If compositing is disabled, just draws a normal rectangle.
 */
/**
 * plank_theme_draw_rounded_line:
 * @cr: (in): &nbsp;.  <para>the context to draw with </para>
 * @x: (in): &nbsp;.  <para>the x location of the line </para>
 * @y: (in): &nbsp;.  <para>the y location of the line </para>
 * @width: (in): &nbsp;.  <para>the width of the line </para>
 * @height: (in): &nbsp;.  <para>the height of the line </para>
 * @is_round_left: (in): &nbsp;.  <para>weather the left is round or not </para>
 * @is_round_right: (in): &nbsp;.  <para>weather the right is round or not </para>
 * @stroke: (in) (allow-none): &nbsp;.  <para>filling style of the outline </para>
 * @fill: (in) (allow-none): &nbsp;.  <para>filling style of the inner area </para>
 * 
 * Draws a rounded horizontal line.
 */
/**
 * plank_theme_get_theme_list:
 * 
 * Get a sorted array of all available theme-names
 * 
 * Returns: (array length=result_length1): <para>array containing all available theme-names </para>
 */
/**
 * plank_theme_get_theme_folder:
 * @name: (in): &nbsp;.  <para>the basename of the folder </para>
 * 
 * Try to get an already existing folder located in the themes folder while prefering the user&apos;s themes folder. If there is no folder found we fallback to the &quot;Default&quot; theme. If even that folder doesn&apos;t exist return NULL (and use built-in defaults)
 * 
 * Returns: <para><link linkend="GFile"><type>GFile</type></link> the folder of the theme or NULL </para>
 */
/**
 * PlankTheme:
 * 
 * A themed renderer for windows.
 */
/**
 * PlankThemeClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-THEME:CAPS"><literal>PLANK_TYPE_THEME</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
