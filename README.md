# Plank Reloaded

## What Is Plank Reloaded?

Plank Reloaded is a fork of the original Plank project, focusing on Cinnamon desktop compatibility
and modernized features. Like its predecessor, it aims to be the simplest dock on the planet,
providing just what a dock needs and absolutely nothing more. It remains a library which can be
extended to create other dock programs with more advanced features.

### Key Improvements in Plank Reloaded:
* Enhanced Cinnamon desktop environment compatibility. Now all Docklets are fully functional.
* Updated Battery Docklet with modern UPower integration.
* Updated the Matte theme, and added MatteLight based on the Arian theme.
* Fixed Clock Docklet settings crash, updated the look of the Digital Clock and added a Calendar when clicked.
* General code cleanup and bug fixes.

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

### Linux Mint
```bash
# Completely uninstall plank
sudo apt-get remove plank libplank-common libplank1

# Install required dependencies
sudo apt-get install git autogen autoconf autopoint libtool make valac libgnome-menu-3.0 libgnome-menu-3-dev libxml2-utils gtk+-3.0 gee-0.8 libbamf3-dev libwnck-3.0 libwnck-3-dev bamfdaemon

# Clone the repository
git clone https://github.com/zquestz/plank-reloaded.git

# Enter the directory
cd plank-reloaded

# Build and install
./bootstrap
make -j2
sudo make install
sudo gtk-update-icon-cache -f /usr/share/icons/hicolor
sudo xdg-desktop-menu forceupdate
```

Note: For other distributions, you'll need to build from source. The build dependencies and commands may vary slightly depending on your distribution.

## Reporting Bugs

For Plank Reloaded specific issues, please report them here:
[Plank Reloaded Issues](https://github.com/zquestz/plank-reloaded/issues)

For reference, original Plank bugs were tracked at: [Plank Launchpad](https://bugs.launchpad.net/plank)

Please search for existing bugs before reporting new ones.

## Where Can I Get Help?

### For Plank Reloaded:
* GitHub Issues: [https://github.com/zquestz/plank-reloaded/issues](https://github.com/zquestz/plank-reloaded/issues)

### Original Plank Resources:
* IRC: `#plank` on FreeNode - `irc://irc.freenode.net/#plank`
* Common problems and solutions: [Plank Answers](https://answers.launchpad.net/plank)

## How Can I Get Involved?

### Plank Reloaded:
* Visit the GitHub page: [https://github.com/zquestz/plank-reloaded](https://github.com/zquestz/plank-reloaded)
* Submit pull requests
* Report issues
* Contribute to development

### Original Plank Resources:
* Launchpad page: [https://launchpad.net/plank](https://launchpad.net/plank)
* Translations: [https://translations.launchpad.net/plank](https://translations.launchpad.net/plank)

## API Documentation

This project intends to be API compatible with the original Plank project.

Original Plank documentation: [API Docs](http://people.ubuntu.com/~ricotz/docs/vala-doc/plank/index.htm)

## Development Resources

Need more information about Vala?

* [Vala Project](https://wiki.gnome.org/Projects/Vala)
* [Vala Manual](https://wiki.gnome.org/Projects/Vala/Manual)

Refer to the HACKING file for further instructions.
