/**
 * plank_color_set_hsv:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * @h: &nbsp;
 * @s: &nbsp;
 * @v: &nbsp;
 * 
 * Set HSV color values of this color.
 */
/**
 * plank_color_set_hue:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * @hue: (in): &nbsp;.  <para>the new hue for the color </para>
 * 
 * Sets the hue for the color.
 */
/**
 * plank_color_set_sat:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * @sat: (in): &nbsp;.  <para>the new saturation for the color </para>
 * 
 * Sets the saturation for the color.
 */
/**
 * plank_color_set_val:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * @val: (in): &nbsp;.  <para>the new value for the color </para>
 * 
 * Sets the value for the color.
 */
/**
 * plank_color_get_hsv:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * @h: &nbsp;
 * @s: &nbsp;
 * @v: &nbsp;
 * 
 * Get HSV color values of this color.
 */
/**
 * plank_color_get_hue:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * 
 * Returns the hue for the color.
 * 
 * Returns: <para>the hue for the color </para>
 */
/**
 * plank_color_get_sat:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * 
 * Returns the saturation for the color.
 * 
 * Returns: <para>the saturation for the color </para>
 */
/**
 * plank_color_get_val:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * 
 * Returns the value for the color.
 * 
 * Returns: <para>the value for the color </para>
 */
/**
 * plank_color_add_hue:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * @val: (in): &nbsp;.  <para>the amount to add to the hue </para>
 * 
 * Increases the color&apos;s hue.
 */
/**
 * plank_color_set_min_sat:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * @sat: (in): &nbsp;.  <para>the minimum saturation </para>
 * 
 * Assures the color&apos;s saturation is greater than or equal to the given one.
 */
/**
 * plank_color_set_min_val:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * @val: (in): &nbsp;.  <para>the minimum value </para>
 * 
 * Assures the color&apos;s value is greater than or equal to the given one.
 */
/**
 * plank_color_set_max_sat:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * @sat: (in): &nbsp;.  <para>the maximum saturation </para>
 * 
 * Assures the color&apos;s saturation is less than or equal to the given one.
 */
/**
 * plank_color_set_max_val:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * @val: (in): &nbsp;.  <para>the maximum value </para>
 * 
 * Assures the color&apos;s value is less than or equal to the given one.
 */
/**
 * plank_color_multiply_sat:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * @amount: (in): &nbsp;.  <para>amount to multiply the saturation by </para>
 * 
 * Multiplies the color&apos;s saturation using the amount.
 */
/**
 * plank_color_brighten_val:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * @amount: (in): &nbsp;.  <para>percent of the value to brighten by </para>
 * 
 * Brighten the color&apos;s value using the value.
 */
/**
 * plank_color_darken_val:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * @amount: (in): &nbsp;.  <para>percent of the value to darken by </para>
 * 
 * Darkens the color&apos;s value using the value.
 */
/**
 * plank_color_darken_by_sat:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * @amount: (in): &nbsp;.  <para>percent of the saturation to darken by </para>
 * 
 * Darkens the color&apos;s value using the saturtion.
 */
/**
 * plank_color_get_hsl:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * @h: &nbsp;
 * @s: &nbsp;
 * @l: &nbsp;
 * 
 * Get HSL color values of this color.
 */
/**
 * plank_color_set_hsl:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * @h: &nbsp;
 * @s: &nbsp;
 * @v: &nbsp;
 * 
 * Set HSL color values of this color.
 */
/**
 * plank_color_to_prefs_string:
 * @self: the <link linkend="PlankColor"><type>PlankColor</type></link> instance
 * 
 * Convert color to string formatted like &quot;%d;;%d;;%d;;%d&quot; with numeric entries ranged in 0..255
 * 
 * Returns: <para>the string representation of this color </para>
 */
/**
 * plank_color_from_hsv:
 * @h: (in): &nbsp;.  <para>the hue for the color </para>
 * @s: (in): &nbsp;.  <para>the saturation for the color </para>
 * @v: (in): &nbsp;.  <para>the value for the color </para>
 * 
 * Create new color for the given HSV values while h in [0,360), s in [0,1] and v in [0,1]
 * 
 * Returns: <para>new <link linkend="PlankColor"><type>PlankColor</type></link> based on the HSV values </para>
 */
/**
 * plank_color_from_hsl:
 * @h: (in): &nbsp;.  <para>the hue for the color </para>
 * @s: (in): &nbsp;.  <para>the saturation for the color </para>
 * @l: (in): &nbsp;.  <para>the lightness for the color </para>
 * 
 * Create new color for the given HSL values while h in [0,360), s in [0,1] and l in [0,1]
 * 
 * Returns: <para>new <link linkend="PlankColor"><type>PlankColor</type></link> based on the HSL values </para>
 */
/**
 * plank_color_from_prefs_string:
 * @s: &nbsp;
 * 
 * Create new color converted from string formatted like &quot;%d;;%d;;%d;;%d&quot; with numeric entries ranged in 0..255
 * 
 * Returns: <para>new <link linkend="PlankColor"><type>PlankColor</type></link> based on the given string </para>
 */
/**
 * PlankColor:
 * 
 * Represents a RGBA color and has methods for manipulating the color.
 */
/**
 * plank_color_dup:
 * @self: the instance to duplicate
 * 
 * Creates a copy of self.
 * 
 * <emphasis>See also</emphasis>: plank_color_copy(), plank_color_destroy(), plank_color_free()
 * 
 * Returns: a copy of @self, free with plank_color_free()
 */
/**
 * plank_color_free:
 * @self: the struct to free
 * 
 * Frees the heap-allocated struct.
 * 
 * <emphasis>See also</emphasis>: plank_color_dup(), plank_color_copy(), plank_color_destroy()
 */
/**
 * plank_color_copy:
 * @self: the struct to copy
 * @dest: a unused struct. Use plank_color_destroy() to free the content.
 * 
 * Creates a copy of self.
 * 
 * <emphasis>See also</emphasis>: plank_color_dup(), plank_color_destroy(), plank_color_free()
 */
/**
 * plank_color_destroy:
 * @self: the struct to destroy
 * 
 * Frees the content of the struct pointed by @self.
 * 
 * <emphasis>See also</emphasis>: plank_color_dup(), plank_color_copy(), plank_color_free()
 */
