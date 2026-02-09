# Plank Reloaded

[![GitHub Release](https://img.shields.io/github/v/release/zquestz/plank-reloaded)](https://github.com/zquestz/plank-reloaded/releases) [![Crowdin](https://badges.crowdin.net/plank-reloaded/localized.svg)](https://crowdin.com/project/plank-reloaded)

## What Is Plank Reloaded?

Plank Reloaded is a fork of the original [Plank](https://launchpad.net/plank) project, providing a simple dock for X11 desktop environments. We actively support Cinnamon, MATE, Xfce, and KDE. Wayland is not supported at this time.

Like its predecessor, Plank Reloaded aims to be the simplest dock on the planet, providing just what a dock needs and absolutely nothing more. It also remains a library which can be extended to create other dock programs with more advanced features.

![Plank Reloaded](screenshots/minimal.webp)

### Key Improvements in Plank Reloaded

- Enhanced compatibility with X11 desktop environments (Cinnamon, MATE, Xfce, and KDE)
- Translated into 71 languages
- Migrated to modern meson build system for easier compilation and installation
- Anchor docklets and files to the end of the dock
- Fixed Restrict to Workspace so applications only show up on their active workspace
- Max zoom increased to 400%
- Floating dock support with configurable gap from the screen edge
- Multi-monitor support with active display tracking
- Comprehensive docklet improvements:
  - Applications: Better reliability and fixed duplicate items issue
  - Battery: Modern UPower integration
  - Clock: Enhanced digital display with new pop-up calendar
  - Clippy: Image support, improved text handling and menu organization
  - Notifications: Displays system notifications on the dock
  - Separator: A simple separator so you can set up a macOS-like dock experience
  - Workspaces: A graphical workspace switcher
  - Refreshed icons across all docklets
  - Support for third party docklets
- Added Matte-Light, Minimal, and Minimal-Light themes
- Added theme options to set the indicator, active item, and badge styles

## Themes

Plank Reloaded ships with six built-in themes. You can switch themes in **Preferences → Appearance → Theme**.

### Default

![Default Theme](screenshots/default.webp)

### Matte

![Matte Theme](screenshots/matte.webp)

### Matte Light

![Matte Light Theme](screenshots/matte-light.webp)

### Minimal

![Minimal Theme](screenshots/minimal.webp)

### Minimal Light

![Minimal Light Theme](screenshots/minimal-light.webp)

### Transparent

![Transparent Theme](screenshots/transparent.webp)

### GTK Themes

Plank Reloaded also supports GTK themes. To use one, install it and set it as your default theme, then select **Gtk+** as the Plank Reloaded theme in preferences.

Here is a list of themes known to support Plank Reloaded:

- [Celestial](https://github.com/zquestz/celestial-gtk-theme)
- [Matcha](https://github.com/zquestz/Matcha-gtk-theme)
- [Semabe](https://github.com/sewbej/Plank-Themes)
- [WhiteSur](https://github.com/vinceliuice/WhiteSur-gtk-theme)

## Installation

### Arch Linux

```bash
yay -S plank-reloaded-git
```

### Linux Mint / Ubuntu (Noble Numbat)

#### Option 1: Using the PPA (Recommended)

Plank Reloaded is available for Ubuntu through an official PPA. This is the easiest way to install and keep Plank Reloaded updated.

```bash
# Add the repository
curl -fsSL https://zquestz.github.io/ppa/ubuntu/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/zquestz-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/zquestz-archive-keyring.gpg] https://zquestz.github.io/ppa/ubuntu ./" | sudo tee /etc/apt/sources.list.d/zquestz.list
sudo apt update

# Install Plank Reloaded
sudo apt install plank-reloaded
```

#### Option 2: Manual Installation

You can download the `plank-reloaded.deb` package from the [Releases](https://github.com/zquestz/plank-reloaded/releases) page or build from source using the instructions below.

```bash
# Completely uninstall plank
sudo apt-get remove plank libplank-common libplank1

# Install required dependencies
sudo apt-get install git meson gettext valac libgnome-menu-3.0 libgnome-menu-3-dev libxml2-utils gtk+-3.0 gee-0.8 libbamf3-dev libwnck-3.0 libwnck-3-dev bamfdaemon

# Clone the repository
git clone https://github.com/zquestz/plank-reloaded.git

# Enter the directory
cd plank-reloaded

# Build and install
meson setup --prefix=/usr build
meson compile -C build
sudo meson install -C build
```

### LMDE / Debian (Bookworm)

#### Option 1: Using the PPA (Recommended)

Plank Reloaded is available for Debian through an official PPA. This is the easiest way to install and keep Plank Reloaded updated.

```bash
# Add the repository
curl -fsSL https://zquestz.github.io/ppa/debian/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/zquestz-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/zquestz-archive-keyring.gpg] https://zquestz.github.io/ppa/debian ./" | sudo tee /etc/apt/sources.list.d/zquestz.list
sudo apt update

# Install Plank Reloaded
sudo apt install plank-reloaded
```

#### Option 2: Manual Installation

You can download the `plank-reloaded-debian.deb` package from the [Releases](https://github.com/zquestz/plank-reloaded/releases) page or build from source using the instructions below.

```bash
# Completely uninstall plank
sudo apt-get remove plank libplank-common libplank1

# Install required dependencies
sudo apt-get install git meson gettext valac libgnome-menu-3.0 libgnome-menu-3-dev libxml2-utils gtk+-3.0 gee-0.8 libbamf3-dev libwnck-3.0 libwnck-3-dev bamfdaemon

# Clone the repository
git clone https://github.com/zquestz/plank-reloaded.git

# Enter the directory
cd plank-reloaded

# Build and install
meson setup --prefix=/usr build
meson compile -C build
sudo meson install -C build
```

### openSUSE

There is a community supported openSUSE package available at:

[https://build.opensuse.org/package/show/home:asdhio/plank](https://build.opensuse.org/package/show/home:asdhio/plank)

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

There is a Nix flake available for Plank Reloaded located at [./flake.nix](./flake.nix).

#### Running

An easy way to test out plank reloaded if you have flakes enabled is to simply run

```sh
nix run github:zquestz/plank-reloaded
```

This will download, build and launch the dock

#### Building

To build plank-reloaded on Nix, simply run

```sh
nix build github:zquestz/plank-reloaded
```

The built application will be generated in the "result" directory of
the current directory. You can then launch it by running the executable located at `./result/bin/plank`

You can also build the app locally by doing the following steps:

1. Clone the repository

   ```sh
   git clone https://github.com/zquestz/plank-reloaded.git
   ```

2. Switch to the repository's directory

   ```sh
   cd plank-reloaded
   ```

3. Build plank reloaded
   ```sh
   nix build .
   ```

#### System-wide Installation

To include Plank Reloaded in your system-wide packages, do the following steps to incorporate the flake. Note that the following is an example system config. Yours most likely will be different.

1. First add the plank-reloaded flake to the inputs section of your own system's flake and add it as a parameter to your outputs:

   ```nix
   {
       inputs = {
           nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
           plank-reloaded = {
               url = "github:zquestz/plank-reloaded";
               inputs.nixpkgs.follows = "nixpkgs";
           };
           # ...
       };
       outputs = inputs @ {
               self,
               nixpkgs,
               plank-reloaded,
               # ...
           }: {
           nixosConfigurations.my-computer = nixpkgs.lib.nixosSystem {
               system = "x86_64-linux";
               specialArgs = { inherit plank-reloaded; };
               modules = [
                   ./configuration.nix
                   # ...
               ];
           };
       };
   }
   ```

2. Next, in your `configuration.nix` or whichever module you prefer, add plank reloaded to your system packages

   ```nix
   { config, pkgs, plank-reloaded, ... }:
   let
       # Allows the package to be referred to by a handy variable
       plank-reloaded = plank-reloaded.defaultPackage.${pkgs.system};
   in {
       environment.systemPackages = with pkgs; [
          plank-reloaded
          # ...
       ];
       # ...
   }
   ```

   Note that in order for your module to import plank-reloaded, you will need to pass either `plank-reloaded` or `inputs` into `specialArgs` for NixOS or `home-manager.extraSpecialArgs` if running home manager. The above example just passes `plank-reloaded` to the module.

3. Rebuild your system:
   ```sh
   sudo nixos-rebuild switch
   ```
4. Verify installation by running:
   ```sh
   plank
   ```

#### Credits

Thanks to [thecreativedg](https://github.com/thecreativedg) for the initial flake which can be found at:

[https://github.com/thecreativedg/plank-reloaded-flake](https://github.com/thecreativedg/plank-reloaded-flake)

### Fedora

Plank Reloaded works on Fedora when running in X11 mode. Wayland is not supported at this time.

#### Option 1: Using RPM Packages (Recommended for X11 users)

You can download the latest RPM packages from the [Releases](https://github.com/zquestz/plank-reloaded/releases) page.

```bash
# Install the downloaded package
sudo dnf install ./plank-reloaded-*.rpm

# Optional: Install development files if you plan to develop docklets
sudo dnf install ./plank-reloaded-devel-*.rpm
```

#### Option 2: Build from Source

If you prefer to build from source or are using Wayland (with limitations):

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

### How do I auto-start Plank Reloaded when I log in?

Add Plank Reloaded to your desktop environment's startup applications. The command to use is simply `plank`.

### Does Plank Reloaded work with multiple monitors?

Yes, Plank Reloaded works with multiple monitors. To have a dock on each monitor, you need to launch multiple instances with different names:

```bash
# Launch first dock
plank

# Launch second dock
plank -n dock2
```

Each instance can be configured independently.

#### Moving Docks Between Monitors

You can move docks to your active monitor (where your cursor is) by enabling "On Active Display" in the preferences or by sending a USR1 signal to the plank process:

```bash
killall -USR1 plank
```

The signaling feature is particularly useful when:

- Assigned to a global keyboard shortcut
- Configured as a hot corner action
- Working with dynamic multi-monitor setups

### Why can't I see certain applications in the dock?

Check if "Restrict to Workspace" is enabled in preferences. When enabled, applications will only show up on the workspace they're active on.

### Why does my dock fade instead of slide when hiding?

The hide animation style is controlled by your dock theme's `FadeOpacity` setting. When `FadeOpacity` is `1`, the dock slides in and out. When it's less than `1` (e.g., `0`), the dock fades instead. The Default and Transparent themes use slide, while Matte and Matte-Light use fade. You can change this in your theme's `dock.theme` file or switch themes in **Preferences → Appearance → Theme**.

### Does Plank Reloaded work with graphics tablets?

Yes, but with a limitation. Tablets use absolute positioning and don't generate the pressure events that mice and touchpads do, so the dock unhides via hover instead of pressure for tablet input. This works well when GapSize is 0 (dock flush with screen edge). However, when GapSize is greater than 0 (floating dock), the hover region is not available due to an X11 limitation, and the dock cannot be unhidden with a tablet pen. If you use a tablet frequently with a floating dock, consider setting GapSize to 0.

### Running indicators not showing after login?

If running indicators (the glow effect showing active applications) don't appear after logging in, this is typically caused by bamfdaemon not starting properly with systemd.

**Solution 1:** Manually add bamfdaemon to your startup applications. Common paths include:

- `/usr/lib/x86_64-linux-gnu/bamf/bamfdaemon`
- `/usr/lib/bamf/bamfdaemon`

**Solution 2:** Fix the bamf systemd service using a drop-in override. The default service uses `Restart=on-failure`, which causes the service to enter a failed state on logout and not restart on the next login. Create an override to disable the restart behavior:

```bash
mkdir -p ~/.config/systemd/user/bamfdaemon.service.d/
echo -e "[Service]\nRestart=no" > ~/.config/systemd/user/bamfdaemon.service.d/override.conf
systemctl --user daemon-reload
```

This allows dbus activation to cleanly start bamfdaemon on demand, and survives package updates.

### Plank sensitivity extends too far in IceWM?

If you're using IceWM and experiencing issues where clicking near the dock becomes unresponsive in applications (e.g., Firefox's back button doesn't work when too close to the dock), you need to tell IceWM not to manage the Plank window.

**Solution:** Add the following line to your IceWM winoptions file (typically `~/.icewm/winoptions`):

```
plank.doNotManage: 1
```

This tells IceWM not to apply window management rules to Plank, resolving the click sensitivity issues.

See [issue #124](https://github.com/zquestz/plank-reloaded/issues/124) for more details.

### How can application developers show counts or progress indicators on their dock icons?

Plank Reloaded supports the [Unity LauncherAPI specification](https://wiki.ubuntu.com/Unity/LauncherAPI), which allows applications to display notification counts, progress bars, and other indicators on their dock icons.

## Third Party Docklets

Plank Reloaded encourages developers to write custom docklets! See [DOCKLETS.md](DOCKLETS.md) for a complete development guide. Here are some existing third-party docklets:

- [Last.fm](https://github.com/zquestz/lastfm-docklet) - A Last.fm docklet to show recent scrobbles.
- [Picky](https://github.com/zquestz/picky) - An advanced color picker docklet
- [Quit](https://github.com/androlekss/quit.git) - A docklet to quick access to session actions.
- [myIP](https://github.com/androlekss/ip-docklet.git) - A docklet to show public IP.
- [Volmatic](https://github.com/androlekss/volmatic-docklet.git) - A Volmatic docklet for managing system volume.

## Reporting Bugs

Please report issues on the [GitHub Issues](https://github.com/zquestz/plank-reloaded/issues) page. Search for existing bugs before reporting new ones.

## Getting Involved

- Visit the GitHub page: [https://github.com/zquestz/plank-reloaded](https://github.com/zquestz/plank-reloaded)
- Submit pull requests
- Report issues
- Contribute to development
- Translations: [https://crowdin.com/project/plank-reloaded](https://crowdin.com/project/plank-reloaded)
- Third party docklets
- Refer to [HACKING.md](HACKING.md) for development guidelines

## API Documentation

This project intends to be API compatible with the original Plank project.

To build the latest documentation:

```
meson setup --prefix=/usr build
meson configure -D enable-docs=true build
meson compile -C build
meson compile -C build all-docs
```

Then you can find the docs in the `build/docs` directory.

## Development Resources

Need more information about Vala?

- [Vala Project](https://wiki.gnome.org/Projects/Vala)
- [Vala Manual](https://wiki.gnome.org/Projects/Vala/Manual)

Refer to the [HACKING.md](HACKING.md) file for further instructions.
