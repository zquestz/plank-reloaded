# Clippy Docklet - Global Hotkey Implementation

## Overview

This document describes the implementation of the global hotkey feature for the Clippy docklet, which allows users to bring up the clipboard menu at the current mouse position from anywhere on the desktop.

## Changes Made

### 1. Added keybinder-3.0 VAPI Bindings

**File:** `plank-reloaded/vapi/keybinder-3.0.vapi`

Created Vala bindings for the keybinder-3.0 library, which provides cross-platform global keyboard shortcut functionality on X11.

Key functions exposed:
- `init()` - Initialize the keybinder library
- `bind()` - Bind a global hotkey
- `unbind_all()` - Unbind all handlers for a hotkey
- `supported()` - Check if keybinder is supported

### 2. Updated ClippyPreferences

**File:** `plank-reloaded/docklets/Clippy/ClippyPreferences.vala`

Added a new preference property:
- `Hotkey` (string) - Stores the user's configured hotkey (e.g., "<Super>v")

### 3. Enhanced ClippyDockItem

**File:** `plank-reloaded/docklets/Clippy/ClippyDockItem.vala`

Added comprehensive hotkey support:

#### New Private Members
- `keybinder_initialized` (static bool) - Ensures keybinder is initialized only once
- `current_hotkey` (string?) - Tracks the currently bound hotkey

#### New Methods

##### `initialize_hotkey()`
- Initializes the keybinder library
- Sets up a property change listener for the Hotkey preference
- Applies the initial hotkey binding

##### `update_hotkey_binding()`
- Unbinds any existing hotkey
- Binds the new hotkey if one is configured

##### `bind_hotkey(string keystring)`
- Binds a global hotkey using keybinder
- Stores the current hotkey on success
- Logs warnings on failure

##### `unbind_hotkey()`
- Unbinds the currently active hotkey
- Clears the current_hotkey tracker

##### `on_hotkey_pressed(string keystring, void* user_data)`
- Static callback for keybinder (required due to C callback constraints)
- Casts user_data back to ClippyDockItem instance
- Calls `show_clipboard_menu_at_pointer()`

##### `show_clipboard_menu_at_pointer()`
- Creates and populates the clipboard menu
- Uses `gtk_menu_popup_at_pointer()` to show menu at current mouse position
- Reuses existing menu item generation code

##### `show_hotkey_dialog()`
- Interactive dialog for setting the hotkey
- Captures keyboard input and converts to GTK accelerator format
- Provides examples: `<Super>v`, `<Ctrl><Alt>c`, etc.
- Offers Clear, Cancel, and OK buttons

##### `set_hotkey(string hotkey)`
- Updates the hotkey preference
- Triggers automatic rebinding via property change notification

#### Updated Menu
- Added "Set Hotkey..." menu item to the right-click context menu
- Opens the hotkey configuration dialog

### 4. Updated Build Configuration

**File:** `plank-reloaded/docklets/Clippy/meson.build`

Modified to conditionally include keybinder-3.0:
- Checks for keybinder-3.0 availability
- Adds dependency if found
- Includes proper Vala package arguments

## Architecture

### Hotkey Flow

```
User sets hotkey via dialog
    ↓
Preference updated (ClippyPreferences.Hotkey)
    ↓
Property change notification triggered
    ↓
update_hotkey_binding() called
    ↓
unbind_hotkey() clears old binding
    ↓
bind_hotkey() creates new binding with keybinder
    ↓
User presses hotkey anywhere
    ↓
X11 captures key event
    ↓
keybinder triggers on_hotkey_pressed()
    ↓
show_clipboard_menu_at_pointer() displays menu at mouse
```

### Memory Management

- The hotkey handler uses a static callback with user_data pointer
- User_data contains `this` pointer to ClippyDockItem instance
- Cleanup handled in destructor (`~ClippyDockItem()`)
- No memory leaks as keybinder manages internal state

## User Experience

### Setting a Hotkey

1. Right-click Clippy docklet
2. Select "Set Hotkey..."
3. Press desired key combination (modifiers + key)
4. Dialog shows the captured combination
5. Click OK to save, Clear to remove, or Cancel to abort

### Using the Hotkey

1. Press the configured hotkey anywhere
2. Clipboard menu appears at current mouse position
3. Click an item to copy it to clipboard
4. Menu closes automatically

## Technical Considerations

### Why keybinder-3.0?

- **System-wide hotkeys**: Works regardless of window focus
- **X11 integration**: Directly grabs keys at X server level
- **Well-tested**: Used by many GTK applications
- **GTK 3 compatible**: Matches Plank's GTK version

### Accelerator Format

Uses GTK accelerator notation:
- `<Super>` - Windows/Command/Meta key
- `<Ctrl>` - Control key
- `<Alt>` - Alt key
- `<Shift>` - Shift key
- Combined: `<Ctrl><Alt>v`, `<Super>c`, etc.

### Fallback Behavior

If keybinder-3.0 is not available:
- Docklet compiles without hotkey support
- "Set Hotkey..." menu item still appears
- User is informed if binding fails
- All other clipboard functionality works normally

## Dependencies

### Runtime
- `keybinder-3.0` (libkeybinder-3.0-0)

### Build-time
- `keybinder-3.0` development headers
- Properly configured VAPI file

## Testing

### Manual Testing Steps

1. Build and install the docklet
2. Add Clippy to dock
3. Right-click → "Set Hotkey..."
4. Test various key combinations:
   - Single modifier: `<Super>v`
   - Multiple modifiers: `<Ctrl><Alt>c`
   - With special keys: `<Super>Insert`
5. Verify hotkey works from different applications
6. Test clearing the hotkey
7. Test changing to a different hotkey
8. Verify clipboard menu appears at mouse position
9. Test selecting items from the hotkey-triggered menu

### Edge Cases Tested

- Empty clipboard (hotkey does nothing)
- Hotkey conflicts (keybinder handles gracefully)
- Rapid hotkey presses (debounced by keybinder)
- Multiple Clippy instances (each manages own hotkey)
- Invalid accelerator strings (rejected gracefully)

## Future Enhancements

Possible improvements:
- Visual feedback when hotkey is pressed but clipboard is empty
- Hotkey conflict detection and warning
- Multiple hotkey support (e.g., one for history, one for quick paste)
- Wayland support (requires different keybinding approach)
- Customizable menu position (mouse vs. dock vs. custom)

## Compatibility

- **X11**: Fully supported
- **Wayland**: Not supported (keybinder-3.0 is X11-only)
- **GTK 3.10+**: Required (Plank's minimum GTK version)
- **Vala 0.34+**: Required (Plank's minimum Vala version)

## Documentation

User-facing documentation in:
- `README.md` - Usage instructions and examples
- Context menu tooltips
- Interactive hotkey dialog with examples

## License

Maintains GPL-3.0 license consistent with Plank Reloaded project.