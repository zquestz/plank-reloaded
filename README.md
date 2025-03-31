# Plank Reloaded

[![GitHub Release](https://img.shields.io/github/v/release/zquestz/plank-reloaded)](https://github.com/zquestz/plank-reloaded/releases) [![Crowdin](https://badges.crowdin.net/plank-reloaded/localized.svg)](https://crowdin.com/project/plank-reloaded)

## What Is Plank Reloaded?

Plank Reloaded is a fork of the original [Plank](https://launchpad.net/plank) project, providing a simple dock for X11 desktop environments.
While development began with a focus on Cinnamon, we now actively support multiple desktop environments
including MATE and Xfce. Wayland is not supported at this time.

Like its predecessor, Plank Reloaded aims to be the simplest dock on the planet, providing just what a
dock needs and absolutely nothing more. It also remains a library which can be extended to create other dock
programs with more advanced features.

### Key Improvements in Plank Reloaded

- Enhanced compatibility with X11 desktop environments (Cinnamon, MATE, and Xfce)
- Migrated to modern meson build system for easier compilation and installation
- Added AnchorDocklets/AnchorFiles settings to anchor docklets/files to the end of the dock
- Fixed Restrict to Workspace so applications only show up on their active workspace
- Comprehensive docklet improvements:
  - Applications: Better reliability and fixed duplicate items issue
  - Battery: Modern UPower integration
  - Clock: Enhanced digital display with new pop-up calendar
  - Clippy: Better text handling and menu organization
  - Separator: A simple separator so you can setup a Mac OS X like dock experience
  - Workspaces: A graphical workspace switcher
  - Refreshed icons across all docklets
  - Support for third party docklets
- Updated Matte theme and added MatteLight theme, both based on the [Arian Plank Theme](https://github.com/arianXdev/arian-plank-theme)
- General code cleanup and stability improvements

## Themes

### Default

![Default Theme](screenshots/default.webp)

### Matte

![Matte Theme](screenshots/matte.webp)

### Matte Light

![Matte Light Theme](screenshots/matte-light.webp)

### Transparent

![Transparent Theme](screenshots/transparent.webp)

## Installation

### Arch Linux

```bash
yay -S plank-reloaded-git
```

### Linux Mint / Ubuntu (Noble Numbat)

You can download the latest release .deb package from the [Releases](https://github.com/zquestz/plank-reloaded/releases) page or build from source using the instructions below.

```bash
# Completely uninstall plank
sudo apt-get remove plank libplank-common libplank1

# Install required dependencies
sudo apt-get install git meson valac libgnome-menu-3.0 libgnome-menu-3-dev libxml2-utils gtk+-3.0 gee-0.8 libbamf3-dev libwnck-3.0 libwnck-3-dev bamfdaemon

# Clone the repository
git clone https://github.com/zquestz/plank-reloaded.git

# Enter the directory
cd plank-reloaded

# Build and install
meson setup --prefix=/usr build
meson compile -C build
sudo meson install -C build
```

### FreeBSD

Plank Reloaded is available in the FreeBSD Ports Collection. You can install it using one of the following methods:

#### Using pkg (Binary Package)

```bash
pkg install x11/plank
```

#### Using the Ports Collection

```bash
cd /usr/ports/x11/plank
make install clean
```

For more information about the port, visit [FreshPorts](https://www.freshports.org/x11/plank/).

### Nix

There is a Nix flake available for Plank Reloaded. Just follow the directions in `nix/README.md`.

### Fedora

Testing is still ongoing for Wayland based operating systems like Fedora. Bugs will be encountered. Please report them, and help us fix them.

```bash
# To start Plank you will need to set the following environment variables:
GDK_BACKEND=x11
XDG_SESSION_TYPE=x11

# Install required dependencies
sudo dnf install git meson valac clang cmake libgnome-devel libxml2-devel gnome-menus-devel libgee libgee-devel libdbusmenu-gtk3-devel libdbusmenu-gtk3 libwnck3 libwnck3-devel bamf bamf-devel bamf-daemon

# Clone the repository
git clone https://github.com/zquestz/plank-reloaded.git

# Enter the directory
cd plank-reloaded

# Build and install
meson setup --prefix=/usr build
meson compile -C build
sudo meson install -C build
```

Note: For other distributions, you'll need to build from source. The build dependencies and commands may vary slightly depending on your distribution.

## FAQ

### Can I use Plank Reloaded on Wayland?

No, Plank Reloaded is designed for X11 desktop environments only. Wayland is not supported at this time.

### How do I access Plank Reloaded preferences?

Hold Ctrl while right-clicking on any area of the dock to open the Preferences menu.

### Can I run Plank Reloaded alongside the original Plank?

No, you should completely uninstall the original Plank before installing Plank Reloaded to avoid conflicts. See the installation instructions for details.

### Does Plank Reloaded work with multiple monitors?

Yes, Plank Reloaded works with multiple monitors. To have a dock on each monitor, you need to launch multiple instances with different names:

```bash
# Launch first dock
plank

# Launch second dock
plank -n dock2
```

Each instance can be configured independently.

### How do I auto-start Plank Reloaded when I log in?

Add Plank Reloaded to your desktop environment's startup applications. The command to use is simply `plank`.

### Why can't I see certain applications in the dock?

Check if "Restrict to Workspace" is enabled in preferences. When enabled, applications will only show up on the workspace they're active on.

## Reporting Bugs

For Plank Reloaded specific issues, please report them here:
[Plank Reloaded Issues](https://github.com/zquestz/plank-reloaded/issues)

For reference, original Plank bugs were tracked at: [Plank Launchpad](https://bugs.launchpad.net/plank)

Please search for existing bugs before reporting new ones.

## Where Can I Get Help?

### For Plank Reloaded

- GitHub Issues: [https://github.com/zquestz/plank-reloaded/issues](https://github.com/zquestz/plank-reloaded/issues)

### Original Plank Resources

- IRC: `#plank` on FreeNode - `irc://irc.freenode.net/#plank`
- Common problems and solutions: [Plank Answers](https://answers.launchpad.net/plank)

## How Can I Get Involved?

- Visit the GitHub page: [https://github.com/zquestz/plank-reloaded](https://github.com/zquestz/plank-reloaded)
- Submit pull requests
- Report issues
- Contribute to development
- Translations: [https://crowdin.com/project/plank-reloaded](https://crowdin.com/project/plank-reloaded)
- Third party docklets

## Third Party Docklets

Plank Reloaded encourages developers to write custom docklets! Right now we only have one custom docklet available, but we hope that changes in the future! Feel free to use Picky as an example for writing your own!

- [Picky](https://github.com/zquestz/picky) - An advanced color picker docklet

## API Documentation

This project intends to be API compatible with the original Plank project.

Original Plank documentation: [API Docs](http://people.ubuntu.com/~ricotz/docs/vala-doc/plank/index.htm)

## Development Resources

Need more information about Vala?

- [Vala Project](https://wiki.gnome.org/Projects/Vala)
- [Vala Manual](https://wiki.gnome.org/Projects/Vala/Manual)

Refer to the HACKING.md file for further instructions.
