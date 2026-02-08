# Docklet Development Guide

This guide covers everything you need to know to build a docklet for Plank Reloaded. A docklet is a shared library plugin that adds custom functionality to the dock — anything from a color picker to a music scrobbler.

## Start With the Examples

The best way to learn is by reading existing docklets. They all use the same `Plank.Docklet` interface, whether built-in or third-party. They're listed here from simplest to most complex.

### Built-in Docklets

These live in the `docklets/` directory of the Plank Reloaded source tree:

- **Desktop** — The simplest possible docklet. Just a click handler that toggles show-desktop. Start here to understand the basic pattern.
- **Separator** — A minimal docklet with custom preferences and icon drawing.
- **Trash** — File monitoring, desktop-environment-specific behavior, and D-Bus integration.
- **Battery** — Background I/O on a worker thread with UPower integration.
- **Clock** — Custom icon rendering with Cairo, a popup calendar widget, and timer-based updates.
- **Clippy** — Clipboard monitoring, image handling, and a scrollable menu.
- **CPUMonitor** — Background thread with main-thread marshalling for UI updates.
- **Notifications** — D-Bus service integration for system notifications.
- **Workspaces** — Wnck workspace management with graphical previews.
- **Applications** — The most complex built-in docklet, with menu tree parsing and app launching.

### Third-Party Docklets

These are standalone projects with their own build systems — good references for how to package and distribute a docklet:

- **[Last.fm](https://github.com/zquestz/lastfm-docklet)** — Fetches and displays recent scrobbles with album art, async HTTP, custom menus, and preference monitoring. A good reference for network-connected docklets.
- **[Picky](https://github.com/zquestz/picky)** — A color picker with custom icon rendering, scroll interaction, clipboard integration, palette persistence, and a popup picker window. A good reference for interactive tool docklets.

## Architecture

A docklet consists of three core components:

1. **Docklet** — Implements `Plank.Docklet`, registers the plugin with the dock and provides metadata (name, icon, description).
2. **DockItem** — Extends `Plank.DockletItem`, contains the actual logic — click handling, icon rendering, menus, and state.
3. **Preferences** — Extends `Plank.DockItemPreferences`, defines user-configurable settings that are automatically persisted.

The entry point is a module-level function `docklet_init` that registers your docklet with the `DockletManager`.

## Project Structure

A minimal docklet project looks like this:

```
my-docklet/
├── meson.build
├── MyDocklet.vala        # Docklet interface (registration + metadata)
├── MyDockItem.vala       # Dock item (logic, UI, interactions)
├── MyPreferences.vala    # Preferences (optional, for configurable settings)
├── my.gresource.xml      # GResource manifest (optional, for bundled icons)
├── icons/
│   └── my-icon.png       # Docklet icon
└── po/
    └── meson.build       # Translations (optional)
```

## Reference

### The Docklet (Registration)

This is the entry point. It implements the `Plank.Docklet` interface and registers with the dock.

```vala
public static void docklet_init(Plank.DockletManager manager) {
  manager.register_docklet(typeof (MyNamespace.MyDocklet));
}

namespace MyNamespace {
  public const string G_RESOURCE_PATH = "/com/example/mydocklet";

  public class MyDocklet : Object, Plank.Docklet {
    public unowned string get_id() {
      return "mydocklet";
    }

    public unowned string get_name() {
      return _("My Docklet");
    }

    public unowned string get_description() {
      return _("A brief description of what the docklet does");
    }

    public unowned string get_icon() {
      return "resource://" + G_RESOURCE_PATH + "/icons/my-icon.png";
    }

    public bool is_supported() {
      return true;
    }

    public Plank.DockElement make_element(string launcher, GLib.File file) {
      return new MyDockItem.with_dockitem_file(file);
    }
  }
}
```

Key points:
- `get_id()` must return a unique identifier for your docklet.
- `get_icon()` can return a resource URI, file path, or icon theme name.
- `is_supported()` can check for required system capabilities and return `false` if the docklet can't run on the current system.
- `make_element()` creates a new instance of your dock item, passing the `.dockitem` config file.

### The DockItem (Logic)

This is where your docklet's behavior lives. Extend `Plank.DockletItem` and override methods for click handling, icon rendering, and menus.

```vala
using Plank;

namespace MyNamespace {
  public class MyDockItem : DockletItem {
    MyPreferences prefs;

    public MyDockItem.with_dockitem_file(GLib.File file) {
      GLib.Object(Prefs: new MyPreferences.with_file(file));
    }

    construct {
      prefs = (MyPreferences) Prefs;
      Icon = "resource://" + G_RESOURCE_PATH + "/icons/my-icon.png";
      Text = _("My Docklet");
    }

    ~MyDockItem() {
      // Clean up timers, connections, etc.
    }

    // Handle click events
    protected override AnimationType on_clicked(PopupButton button,
                                                Gdk.ModifierType mod,
                                                uint32 event_time) {
      if (button == PopupButton.LEFT) {
        // Do something on left click
        return AnimationType.BOUNCE;
      }
      return AnimationType.NONE;
    }

    // Handle scroll events
    protected override AnimationType on_scrolled(Gdk.ScrollDirection direction,
                                                 Gdk.ModifierType mod,
                                                 uint32 event_time) {
      if (direction == Gdk.ScrollDirection.UP) {
        // Scroll up action
      } else if (direction == Gdk.ScrollDirection.DOWN) {
        // Scroll down action
      }
      return AnimationType.NONE;
    }

    // Right-click context menu
    public override Gee.ArrayList<Gtk.MenuItem> get_menu_items() {
      var items = new Gee.ArrayList<Gtk.MenuItem>();

      var item = create_menu_item(_("_My Action"), "icon-name", true);
      item.activate.connect(() => {
        // Menu action
      });
      items.add(item);

      return items;
    }

    // Custom icon drawing (optional, override for dynamic icons)
    protected override void draw_icon(Plank.Surface surface) {
      Cairo.Context cr = surface.Context;
      // Draw onto the surface using Cairo
    }
  }
}
```

### DockItem Properties

These properties control what the dock displays for your item:

| Property | Type | Description |
|----------|------|-------------|
| `Icon` | `string` | Icon name, file path, or resource URI |
| `ForcePixbuf` | `Gdk.Pixbuf?` | Set a pixbuf directly as the icon (overrides `Icon`) |
| `Text` | `string` | Tooltip text shown on hover |
| `Count` | `int64` | Badge count displayed on the icon |
| `CountVisible` | `bool` | Whether to show the badge count |
| `Progress` | `double` | Progress bar value (0.0 to 1.0) |
| `ProgressVisible` | `bool` | Whether to show the progress bar |
| `Indicator` | `IndicatorState` | Indicator dots (`NONE`, `SINGLE`, `SINGLE_PLUS`) |

### Animation Types

Return these from `on_clicked` and `on_scrolled`:

| Type | Effect |
|------|--------|
| `AnimationType.NONE` | No animation |
| `AnimationType.BOUNCE` | Icon bounces (good for launch actions) |
| `AnimationType.DARKEN` | Icon briefly darkens |
| `AnimationType.LIGHTEN` | Icon briefly lightens |

### Accessing the Dock Controller

When you need to interact with the dock itself (e.g., for positioning custom menus), use `get_dock()`:

```vala
DockController? controller = get_dock();
if (controller != null) {
  // Access position_manager, window, hide_manager, renderer, etc.
  controller.position_manager.get_menu_position(this, requisition, out x, out y);
}
```

### Preferences (Settings)

Extend `Plank.DockItemPreferences` to add configurable settings. Properties are automatically saved to and loaded from the `.dockitem` file.

```vala
using Plank;

namespace MyNamespace {
  public class MyPreferences : DockItemPreferences {
    [Description(nick = "api-key", blurb = "API key for the service")]
    public string APIKey { get; set; default = ""; }

    [Description(nick = "max-entries", blurb = "Maximum number of entries to display")]
    public int MaxEntries { get; set; default = 10; }

    [Description(nick = "show-notifications", blurb = "Whether to show notifications")]
    public bool ShowNotifications { get; set; default = true; }

    public MyPreferences.with_file(GLib.File file) {
      base.with_file(file);
    }

    protected override void reset_properties() {
      APIKey = "";
      MaxEntries = 10;
      ShowNotifications = true;
    }
  }
}
```

Key points:
- The `Description` annotation's `nick` is the key name in the `.dockitem` file.
- `reset_properties()` must set all properties to their default values.
- Listen for changes with `prefs.notify.connect()` to react to settings updates:

```vala
prefs.notify.connect((pspec) => {
  switch (pspec.name) {
  case "APIKey":
    // Re-authenticate
    break;
  case "MaxEntries":
    // Rebuild menu
    break;
  }
});
```

Users edit settings by modifying the `.dockitem` file directly (typically found in `~/.config/plank/dock1/launchers/`).

### Build System (meson.build)

```meson
project(
  'docklet-mydocklet',
  'vala',
  'c',
  version: '0.1.0',
)

gtk_dep = dependency('gtk+-3.0')
plank_dep = dependency('plank')
i18n = import('i18n')

customconf = configuration_data()
customconf.set('GETTEXT_PACKAGE', meson.project_name())

# Bundle icons as GResources (optional)
gnome = import('gnome')
resources = gnome.compile_resources(
  'resources',
  'my.gresource.xml',
  source_dir: '.',
  c_name: 'resources',
)

add_project_arguments(
  [
    '-Wno-discarded-qualifiers',
    '-Wno-incompatible-pointer-types',
    '-Wno-unused',
    '-Wl,--enable-new-dtags',
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
  ],
  language: 'c',
)

sources = [
  'MyDocklet.vala',
  'MyDockItem.vala',
  'MyPreferences.vala',
  resources,
]

shared_module(
  'docklet-mydocklet',
  sources,
  dependencies: [gtk_dep, plank_dep],
  install: true,
  install_dir: join_paths(get_option('libdir'), 'plank/docklets'),
)

subdir('po')
```

The `shared_module` output must be installed to `libdir/plank/docklets/` for Plank to discover it.

### GResource File (Optional)

If you bundle icons or other assets, create a `.gresource.xml` file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<gresources>
  <gresource prefix="/com/example/mydocklet">
    <file>icons/my-icon.png</file>
  </gresource>
</gresources>
```

## Building and Testing

```bash
# Build
meson setup build
meson compile -C build

# Install
sudo meson install -C build

# Test without installing (point Plank to your build directory)
PLANK_DOCKLET_DIRS=./build plank
```

After installing, the docklet appears in the dock's right-click menu under **Add Docklet**.

## Tips

- **Async operations**: Use GLib async methods for network requests or I/O to avoid blocking the UI thread. The Last.fm docklet demonstrates this with `async` methods and `yield`.
- **Thread safety**: If you use background threads, use `GLib.Mutex` to protect shared state and `Idle.add()` to marshal UI updates back to the main thread.
- **Timer cleanup**: Always remove timers (`GLib.Source.remove()`) in your destructor to prevent callbacks firing after your object is freed.
- **Icon updates**: Call `reset_icon_buffer()` after changing `ForcePixbuf` or after custom drawing changes to force a redraw.
- **Custom menus**: For complex popup menus (beyond `get_menu_items`), see the Last.fm docklet's `show_tracks_menu()` for an example of manually positioning and displaying a `Gtk.Menu`.
- **Translations**: Use `_()` for translatable strings and set up a `po/` directory with a `meson.build` that calls `i18n.gettext()`.

## API Reference

For the full Plank API, build the documentation:

```bash
meson setup --prefix=/usr build
meson configure -D enable-docs=true build
meson compile -C build
meson compile -C build all-docs
```

The generated docs will be in `build/docs`.