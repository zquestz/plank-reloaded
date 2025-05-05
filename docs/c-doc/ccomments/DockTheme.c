/**
 * SECTION:DockTheme
 * @short_description: A themed renderer for dock windows.
 */
/**
 * PLANK_TYPE_DOCK_THEME:
 * 
 * The type for <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link>.
 */
/**
 * plank_dock_theme_create_background:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance
 * @width: (in): &nbsp;.  <para>the width of the background </para>
 * @height: (in): &nbsp;.  <para>the height of the background </para>
 * @position: (in): &nbsp;.  <para>the position of the dock </para>
 * @model: (in): &nbsp;.  <para>existing surface to use as basis of new surface </para>
 * 
 * Creates a surface for the dock background.
 * 
 * Returns: <para>a new surface with the background drawn on it </para>
 */
/**
 * plank_dock_theme_create_indicator:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance
 * @size: (in): &nbsp;.  <para>the size of the indicator </para>
 * @color: (in): &nbsp;.  <para>the color of the indicator </para>
 * @model: (in): &nbsp;.  <para>existing surface to use as basis of new surface </para>
 * 
 * Creates a surface for an indicator.
 * 
 * Returns: <para>a new surface with the indicator drawn on it </para>
 */
/**
 * plank_dock_theme_create_indicator_for_state:
 * @color: <para>the color of the indicator </para>
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance
 * @indicator_state: (in): &nbsp;.  <para>the state of indicator </para>
 * @item_state: (in): &nbsp;.  <para>the state of item </para>
 * @icon_size: (in): &nbsp;.  <para>the size of icons </para>
 * @position: (in): &nbsp;.  <para>the position of the dock </para>
 * @model: (in): &nbsp;.  <para>existing surface to use as basis of new surface </para>
 * 
 * Creates a surface of an indicator for the given states.
 * 
 * Returns: <para>a new surface with the indicator drawn on it </para>
 */
/**
 * plank_dock_theme_create_urgent_glow:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance
 * @size: (in): &nbsp;.  <para>the size of the urgent glow </para>
 * @color: (in): &nbsp;.  <para>the color of the urgent glow </para>
 * @model: (in): &nbsp;.  <para>existing surface to use as basis of new surface </para>
 * 
 * Creates a surface for an urgent glow.
 * 
 * Returns: <para>a new surface with the urgent glow drawn on it </para>
 */
/**
 * plank_dock_theme_draw_active_glow:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance
 * @surface: (in): &nbsp;.  <para>the surface to draw onto </para>
 * @clip_rect: (in): &nbsp;.  <para>the rect to clip the glow to </para>
 * @rect: (in): &nbsp;.  <para>the rect for the glow </para>
 * @color: (in): &nbsp;.  <para>the color of the glow </para>
 * @opacity: (in): &nbsp;.  <para>the opacity of the glow </para>
 * @pos: (in): &nbsp;.  <para>the dock&apos;s position </para>
 * 
 * Draws an active glow for an item.
 */
/**
 * plank_dock_theme_draw_item_count:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance
 * @surface: (in): &nbsp;.  <para>the surface to draw the badge onto </para>
 * @icon_size: (in): &nbsp;.  <para>the icon-size of the dock </para>
 * @color: (in): &nbsp;.  <para>the color of the badge </para>
 * @count: (in): &nbsp;.  <para>the number for the badge to show </para>
 * 
 * Draws a badge for an item.
 */
/**
 * plank_dock_theme_draw_item_progress:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance
 * @surface: (in): &nbsp;.  <para>the surface to draw the progress onto </para>
 * @icon_size: (in): &nbsp;.  <para>the icon-size of the dock </para>
 * @color: (in): &nbsp;.  <para>the color of the progress </para>
 * @progress: (in): &nbsp;.  <para>the value between 0.0 and 1.0 </para>
 * 
 * Draws a progress bar for an item.
 */
/**
 * plank_dock_theme_get_styled_color:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance
 */
/**
 * plank_dock_theme_new:
 * @name: &nbsp;
 */
/**
 * PlankDockTheme:HorizPadding:
 */
/**
 * plank_dock_theme_get_HorizPadding:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--HorizPadding"><type>"HorizPadding"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--HorizPadding"><type>"HorizPadding"</type></link> property
 */
/**
 * plank_dock_theme_set_HorizPadding:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--HorizPadding"><type>"HorizPadding"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--HorizPadding"><type>"HorizPadding"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:TopPadding:
 */
/**
 * plank_dock_theme_get_TopPadding:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--TopPadding"><type>"TopPadding"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--TopPadding"><type>"TopPadding"</type></link> property
 */
/**
 * plank_dock_theme_set_TopPadding:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--TopPadding"><type>"TopPadding"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--TopPadding"><type>"TopPadding"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:BottomPadding:
 */
/**
 * plank_dock_theme_get_BottomPadding:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--BottomPadding"><type>"BottomPadding"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--BottomPadding"><type>"BottomPadding"</type></link> property
 */
/**
 * plank_dock_theme_set_BottomPadding:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--BottomPadding"><type>"BottomPadding"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--BottomPadding"><type>"BottomPadding"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:ItemPadding:
 */
/**
 * plank_dock_theme_get_ItemPadding:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--ItemPadding"><type>"ItemPadding"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--ItemPadding"><type>"ItemPadding"</type></link> property
 */
/**
 * plank_dock_theme_set_ItemPadding:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--ItemPadding"><type>"ItemPadding"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--ItemPadding"><type>"ItemPadding"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:IndicatorColor:
 */
/**
 * plank_dock_theme_get_IndicatorColor:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--IndicatorColor"><type>"IndicatorColor"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--IndicatorColor"><type>"IndicatorColor"</type></link> property
 */
/**
 * plank_dock_theme_set_IndicatorColor:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--IndicatorColor"><type>"IndicatorColor"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--IndicatorColor"><type>"IndicatorColor"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:IndicatorSize:
 */
/**
 * plank_dock_theme_get_IndicatorSize:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--IndicatorSize"><type>"IndicatorSize"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--IndicatorSize"><type>"IndicatorSize"</type></link> property
 */
/**
 * plank_dock_theme_set_IndicatorSize:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--IndicatorSize"><type>"IndicatorSize"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--IndicatorSize"><type>"IndicatorSize"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:IndicatorStyle:
 */
/**
 * plank_dock_theme_get_IndicatorStyle:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--IndicatorStyle"><type>"IndicatorStyle"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--IndicatorStyle"><type>"IndicatorStyle"</type></link> property
 */
/**
 * plank_dock_theme_set_IndicatorStyle:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--IndicatorStyle"><type>"IndicatorStyle"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--IndicatorStyle"><type>"IndicatorStyle"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:IconShadowSize:
 */
/**
 * plank_dock_theme_get_IconShadowSize:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--IconShadowSize"><type>"IconShadowSize"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--IconShadowSize"><type>"IconShadowSize"</type></link> property
 */
/**
 * plank_dock_theme_set_IconShadowSize:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--IconShadowSize"><type>"IconShadowSize"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--IconShadowSize"><type>"IconShadowSize"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:UrgentBounceHeight:
 */
/**
 * plank_dock_theme_get_UrgentBounceHeight:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--UrgentBounceHeight"><type>"UrgentBounceHeight"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--UrgentBounceHeight"><type>"UrgentBounceHeight"</type></link> property
 */
/**
 * plank_dock_theme_set_UrgentBounceHeight:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--UrgentBounceHeight"><type>"UrgentBounceHeight"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--UrgentBounceHeight"><type>"UrgentBounceHeight"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:LaunchBounceHeight:
 */
/**
 * plank_dock_theme_get_LaunchBounceHeight:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--LaunchBounceHeight"><type>"LaunchBounceHeight"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--LaunchBounceHeight"><type>"LaunchBounceHeight"</type></link> property
 */
/**
 * plank_dock_theme_set_LaunchBounceHeight:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--LaunchBounceHeight"><type>"LaunchBounceHeight"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--LaunchBounceHeight"><type>"LaunchBounceHeight"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:FadeOpacity:
 */
/**
 * plank_dock_theme_get_FadeOpacity:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--FadeOpacity"><type>"FadeOpacity"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--FadeOpacity"><type>"FadeOpacity"</type></link> property
 */
/**
 * plank_dock_theme_set_FadeOpacity:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--FadeOpacity"><type>"FadeOpacity"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--FadeOpacity"><type>"FadeOpacity"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:ClickTime:
 */
/**
 * plank_dock_theme_get_ClickTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--ClickTime"><type>"ClickTime"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--ClickTime"><type>"ClickTime"</type></link> property
 */
/**
 * plank_dock_theme_set_ClickTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--ClickTime"><type>"ClickTime"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--ClickTime"><type>"ClickTime"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:UrgentBounceTime:
 */
/**
 * plank_dock_theme_get_UrgentBounceTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--UrgentBounceTime"><type>"UrgentBounceTime"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--UrgentBounceTime"><type>"UrgentBounceTime"</type></link> property
 */
/**
 * plank_dock_theme_set_UrgentBounceTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--UrgentBounceTime"><type>"UrgentBounceTime"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--UrgentBounceTime"><type>"UrgentBounceTime"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:LaunchBounceTime:
 */
/**
 * plank_dock_theme_get_LaunchBounceTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--LaunchBounceTime"><type>"LaunchBounceTime"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--LaunchBounceTime"><type>"LaunchBounceTime"</type></link> property
 */
/**
 * plank_dock_theme_set_LaunchBounceTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--LaunchBounceTime"><type>"LaunchBounceTime"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--LaunchBounceTime"><type>"LaunchBounceTime"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:ActiveTime:
 */
/**
 * plank_dock_theme_get_ActiveTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--ActiveTime"><type>"ActiveTime"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--ActiveTime"><type>"ActiveTime"</type></link> property
 */
/**
 * plank_dock_theme_set_ActiveTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--ActiveTime"><type>"ActiveTime"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--ActiveTime"><type>"ActiveTime"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:SlideTime:
 */
/**
 * plank_dock_theme_get_SlideTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--SlideTime"><type>"SlideTime"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--SlideTime"><type>"SlideTime"</type></link> property
 */
/**
 * plank_dock_theme_set_SlideTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--SlideTime"><type>"SlideTime"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--SlideTime"><type>"SlideTime"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:FadeTime:
 */
/**
 * plank_dock_theme_get_FadeTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--FadeTime"><type>"FadeTime"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--FadeTime"><type>"FadeTime"</type></link> property
 */
/**
 * plank_dock_theme_set_FadeTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--FadeTime"><type>"FadeTime"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--FadeTime"><type>"FadeTime"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:HideTime:
 */
/**
 * plank_dock_theme_get_HideTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--HideTime"><type>"HideTime"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--HideTime"><type>"HideTime"</type></link> property
 */
/**
 * plank_dock_theme_set_HideTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--HideTime"><type>"HideTime"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--HideTime"><type>"HideTime"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:GlowSize:
 */
/**
 * plank_dock_theme_get_GlowSize:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--GlowSize"><type>"GlowSize"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--GlowSize"><type>"GlowSize"</type></link> property
 */
/**
 * plank_dock_theme_set_GlowSize:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--GlowSize"><type>"GlowSize"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--GlowSize"><type>"GlowSize"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:GlowTime:
 */
/**
 * plank_dock_theme_get_GlowTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--GlowTime"><type>"GlowTime"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--GlowTime"><type>"GlowTime"</type></link> property
 */
/**
 * plank_dock_theme_set_GlowTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--GlowTime"><type>"GlowTime"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--GlowTime"><type>"GlowTime"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:GlowPulseTime:
 */
/**
 * plank_dock_theme_get_GlowPulseTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--GlowPulseTime"><type>"GlowPulseTime"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--GlowPulseTime"><type>"GlowPulseTime"</type></link> property
 */
/**
 * plank_dock_theme_set_GlowPulseTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--GlowPulseTime"><type>"GlowPulseTime"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--GlowPulseTime"><type>"GlowPulseTime"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:UrgentHueShift:
 */
/**
 * plank_dock_theme_get_UrgentHueShift:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--UrgentHueShift"><type>"UrgentHueShift"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--UrgentHueShift"><type>"UrgentHueShift"</type></link> property
 */
/**
 * plank_dock_theme_set_UrgentHueShift:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--UrgentHueShift"><type>"UrgentHueShift"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--UrgentHueShift"><type>"UrgentHueShift"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:ItemMoveTime:
 */
/**
 * plank_dock_theme_get_ItemMoveTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--ItemMoveTime"><type>"ItemMoveTime"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--ItemMoveTime"><type>"ItemMoveTime"</type></link> property
 */
/**
 * plank_dock_theme_set_ItemMoveTime:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--ItemMoveTime"><type>"ItemMoveTime"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--ItemMoveTime"><type>"ItemMoveTime"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:CascadeHide:
 */
/**
 * plank_dock_theme_get_CascadeHide:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--CascadeHide"><type>"CascadeHide"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--CascadeHide"><type>"CascadeHide"</type></link> property
 */
/**
 * plank_dock_theme_set_CascadeHide:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--CascadeHide"><type>"CascadeHide"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--CascadeHide"><type>"CascadeHide"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:BadgeColor:
 */
/**
 * plank_dock_theme_get_BadgeColor:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--BadgeColor"><type>"BadgeColor"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--BadgeColor"><type>"BadgeColor"</type></link> property
 */
/**
 * plank_dock_theme_set_BadgeColor:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--BadgeColor"><type>"BadgeColor"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--BadgeColor"><type>"BadgeColor"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:BadgeStyle:
 */
/**
 * plank_dock_theme_get_BadgeStyle:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--BadgeStyle"><type>"BadgeStyle"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--BadgeStyle"><type>"BadgeStyle"</type></link> property
 */
/**
 * plank_dock_theme_set_BadgeStyle:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--BadgeStyle"><type>"BadgeStyle"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--BadgeStyle"><type>"BadgeStyle"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:BadgeTextColor:
 */
/**
 * plank_dock_theme_get_BadgeTextColor:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--BadgeTextColor"><type>"BadgeTextColor"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--BadgeTextColor"><type>"BadgeTextColor"</type></link> property
 */
/**
 * plank_dock_theme_set_BadgeTextColor:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--BadgeTextColor"><type>"BadgeTextColor"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--BadgeTextColor"><type>"BadgeTextColor"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:ActiveItemStyle:
 */
/**
 * plank_dock_theme_get_ActiveItemStyle:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--ActiveItemStyle"><type>"ActiveItemStyle"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--ActiveItemStyle"><type>"ActiveItemStyle"</type></link> property
 */
/**
 * plank_dock_theme_set_ActiveItemStyle:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--ActiveItemStyle"><type>"ActiveItemStyle"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--ActiveItemStyle"><type>"ActiveItemStyle"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:ActiveItemColor:
 */
/**
 * plank_dock_theme_get_ActiveItemColor:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to query
 * 
 * Get and return the current value of the <link linkend="PlankDockTheme--ActiveItemColor"><type>"ActiveItemColor"</type></link> property.
 * 
 * 
 * 
 * Returns: the value of the <link linkend="PlankDockTheme--ActiveItemColor"><type>"ActiveItemColor"</type></link> property
 */
/**
 * plank_dock_theme_set_ActiveItemColor:
 * @self: the <link linkend="PlankDockTheme"><type>PlankDockTheme</type></link> instance to modify
 * @value: the new value of the <link linkend="PlankDockTheme--ActiveItemColor"><type>"ActiveItemColor"</type></link> property
 * 
 * Set the value of the <link linkend="PlankDockTheme--ActiveItemColor"><type>"ActiveItemColor"</type></link> property to @value.
 * 
 * 
 */
/**
 * PlankDockTheme:
 * 
 * A themed renderer for dock windows.
 */
/**
 * PlankDockThemeClass:
 * @parent_class: the parent class structure
 * 
 * The class structure for <link linkend="PLANK-TYPE-DOCK-THEME:CAPS"><literal>PLANK_TYPE_DOCK_THEME</literal></link>. All the fields in this structure are private and should never be accessed directly.
 */
