/**
 * PlankIndicatorStyleType:
 * @PLANK_INDICATOR_STYLE_TYPE_LEGACY: A glowing dot which is gtk-theme-colored.
 * @PLANK_INDICATOR_STYLE_TYPE_GLOW: A glowing dot using a color defined by the theme
 * @PLANK_INDICATOR_STYLE_TYPE_CIRCLE: A solid circle using a color defined by the theme
 * @PLANK_INDICATOR_STYLE_TYPE_LINE: A solid line using a color defined by the theme
 * 
 * The style of the item indicator.
 */
/**
 * PlankActiveItemStyleType:
 * @PLANK_ACTIVE_ITEM_STYLE_TYPE_LEGACY: A vertical gradient which is colored based of the item&apos;s icon.
 * @PLANK_ACTIVE_ITEM_STYLE_TYPE_GRADIENT: A vertical gradient using a color defined by the theme
 * @PLANK_ACTIVE_ITEM_STYLE_TYPE_SOLID: A solid color defined by the theme
 * 
 * The style of the active item.
 */
/**
 * PlankAnimationType:
 * @PLANK_ANIMATION_TYPE_NONE: No animation.
 * @PLANK_ANIMATION_TYPE_BOUNCE: Bounce the icon.
 * @PLANK_ANIMATION_TYPE_DARKEN: Darken the icon, then restore it.
 * @PLANK_ANIMATION_TYPE_LIGHTEN: Brighten the icon, then restore it.
 * 
 * What type of animation to perform when an item is or was interacted with.
 */
/**
 * PlankIndicatorState:
 * @PLANK_INDICATOR_STATE_NONE: None - no windows for this item.
 * @PLANK_INDICATOR_STATE_SINGLE: Show a single indicator - there is 1 window for this item.
 * @PLANK_INDICATOR_STATE_SINGLE_PLUS: Show multiple indicators - there are more than 1 window for this item.
 * 
 * What item indicator to show.
 */
/**
 * PlankUpdateIndicatorEvent:
 * @PLANK_UPDATE_INDICATOR_EVENT_INITIALIZE: Initialize - App state was just initialized.
 * @PLANK_UPDATE_INDICATOR_EVENT_WINDOW_ADDED: Window added - a new window was added to the item.
 * @PLANK_UPDATE_INDICATOR_EVENT_WINDOW_REMOVED: Window removed - a window was removed from the item.
 * @PLANK_UPDATE_INDICATOR_EVENT_RUNNING_CHANGED: Running changed - the running state of the item changed.
 * 
 * Type of event update_indicator is processing.
 */
/**
 * PlankItemState:
 * @PLANK_ITEM_STATE_NORMAL: The item is in a normal state.
 * @PLANK_ITEM_STATE_ACTIVE: The item is currently active (a window in the group is focused).
 * @PLANK_ITEM_STATE_URGENT: The item is currently urgent (a window in the group has the urgent flag).
 * @PLANK_ITEM_STATE_MOVE: The item is currently moved to its new position.
 * @PLANK_ITEM_STATE_INVALID: The item is invalid and should be removed.
 * 
 * The current activity state of an item. The item has several states to track and can be in any combination of them.
 */
/**
 * plank_popup_button_from_event_button:
 * @event: (in): &nbsp;.  <para>the event to map </para>
 * 
 * Convenience method to map <link linkend="GdkEventButton"><type>GdkEventButton</type></link> to this enum.
 * 
 * Returns: <para>the PopupButton representation of the event </para>
 */
/**
 * PlankPopupButton:
 * @PLANK_POPUP_BUTTON_NONE: No button pops up the context.
 * @PLANK_POPUP_BUTTON_LEFT: Left button pops up the context.
 * @PLANK_POPUP_BUTTON_MIDDLE: Middle button pops up the context.
 * @PLANK_POPUP_BUTTON_RIGHT: Right button pops up the context.
 * 
 * What mouse button pops up the context menu on an item. Can be multiple buttons.
 */
