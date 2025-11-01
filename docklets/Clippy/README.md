# Clippy Docklet

Clippy is a clipboard manager docklet for Plank Reloaded that keeps track of your recent clipboard entries.

## Features

- **Clipboard History**: Keep track of recent clipboard entries (text and images)
- **Global Hotkey**: Set a keyboard shortcut to bring up the clipboard menu anywhere
- **Mouse Selection Tracking**: Optionally track PRIMARY clipboard (mouse selections)
- **Image Support**: Track and restore images copied to the clipboard
- **Configurable History Size**: Choose how many entries to keep (5-25)

## Usage

### Basic Usage

1. Add the Clippy docklet to your Plank dock
2. Click the docklet to see your clipboard history
3. Click any item to copy it back to the clipboard

### Setting a Global Hotkey

The hotkey feature allows you to bring up the clipboard menu at your current mouse position from anywhere on your desktop:

1. Right-click the Clippy docklet
2. Select **"Set Hotkey..."** from the menu
3. Press the key combination you want to use (e.g., `Super+V`, `Ctrl+Alt+C`)
4. Click **OK** to save

**Example Hotkeys:**
- `<Super>v` - Super (Windows/Command) key + V
- `<Ctrl><Alt>c` - Ctrl + Alt + C
- `<Shift><Super>Insert` - Shift + Super + Insert

To clear a hotkey, use the **"Set Hotkey..."** dialog and click the **Clear** button.

### Configuration Options

Right-click the Clippy docklet to access these options:

- **Enable Clipboard Tracking**: Toggle clipboard monitoring on/off
- **Track Mouse Selections**: Enable/disable tracking of text selected with the mouse
- **Track Images**: Enable/disable tracking of images in the clipboard
- **Maximum Entries**: Set how many clipboard items to remember (5, 10, 15, 20, or 25)

## Requirements

- **keybinder-3.0**: Required for global hotkey support
  - On Debian/Ubuntu: `sudo apt install libkeybinder-3.0-0`
  - On Arch Linux: `sudo pacman -S keybinder3`
  - On Fedora: `sudo dnf install keybinder3`

If keybinder-3.0 is not available, the docklet will still work but the hotkey feature will be disabled.

## Tips

- The most recent clipboard entry is shown as the docklet's text
- Images are indicated with the text "Image"
- Clipboard entries are deduplicated automatically
- Use `Ctrl+C` or copy as usual - Clippy tracks it automatically
- The global hotkey shows the menu at your current mouse position for quick access

## Technical Details

- Tracks both CLIPBOARD (Ctrl+C) and PRIMARY (mouse selection) clipboards
- Uses a debounce mechanism to avoid duplicate entries
- Stores clipboard items with MD5 hashes for efficient deduplication
- Global hotkey binding uses the X11 keybinder library