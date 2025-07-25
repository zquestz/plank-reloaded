# Plank Reloaded: Still stupidly simple

**Note:** There is no stability of ABI/API until further notice!

## 0.11.146 "Reloaded" (2025-07-21)

- Improve default application detection for fresh installs

## 0.11.145 "Reloaded" (2025-07-20)

- Fixed KDE dock positioning after resolution change

## 0.11.144 "Reloaded" (2025-07-20)

- Fixed dock positioning issues during display transitions
- Updated Apport to report bugs to GitHub
- Added Notifications docklet icon for MATE

## 0.11.143 "Reloaded" (2025-07-19)

- Retry updates on screen_changed signals
- Added Catalan translations
- Added optional systemd service

## 0.11.142 "Reloaded" (2025-07-18)

- Added new Notifications docklet for system notifications
- Updated Applications docklet locks and menu spacing
- Added explicit StartupWMClass to .desktop file

## 0.11.141 "Reloaded" (2025-07-11)

- Fixed slight miscalculation in centering logic
- Fixed window animations when using fractional scaling

## 0.11.140 "Reloaded" (2025-07-08)

- Updated Dutch translation
- Added ActiveItemStyle options (radial gradient, averaged color)
- Updated Matte themes to use radial gradients
- Update plank.desktop to net.launchpad.plank.desktop

## 0.11.139 "Reloaded" (2025-06-27)

- Fix magnification when using pressure reveal
- Minor bug fixes for GapSize barrier

## 0.11.138 "Reloaded" (2025-06-27)

- Update barrier logic to support GapSize
- Fix issue with hidden docks capturing click events
- Fix animation issues when GapSize > 0
- Improved support for multi-monitor setups

## 0.11.137 "Reloaded" (2025-06-27)

- Use screen edge to unhide dock with gap size set

## 0.11.136 "Reloaded" (2025-06-26)

- Fix icon hitbox issues on KDE

## 0.11.135 "Reloaded" (2025-06-24)

- Improve window minimize/restore animations
- Centralize icon region updates for improved reliability

## 0.11.134 "Reloaded" (2025-06-21)

- Handle null window in intelligent_focus_off_viewport_window
- Update Trash docklet to support KDE
- Update tooltip hovering logic for Docklets
- Add SeparatorPadding to themes - Thx to Hilyxx.

## 0.11.133 "Reloaded" (2025-06-17)

- Update monitors list dynamically in preferences

## 0.11.132 "Reloaded" (2025-06-17)

- Add multi-monitor support via "On Active Display" setting
- Improve Clippy handling of PRIMARY/CLIPBOARD clipboards

## 0.11.131 "Reloaded" (2025-06-09)

- Improve reliability of Steam menu activation workaround

## 0.11.130 "Reloaded" (2025-06-09)

- Fix Steam menu activation unhiding dock

## 0.11.129 "Reloaded" (2025-06-08)

- Update Application Docklet menu icons on theme change
- Support custom Workspace names

## 0.11.128 "Reloaded" (2025-05-22)

- Add close buttons to context menu window list

## 0.11.127 "Reloaded" (2025-05-10)

- Update reveal logic when using GapSize > 0
- Reduce pressure threshold for "Pressure Reveal"

## 0.11.126 "Reloaded" (2025-05-09)

- Fix regression showing unpinned items

## 0.11.125 "Reloaded" (2025-05-09)

- Added option to disable tooltips
- Removed docs from source package

## 0.11.124 "Reloaded" (2025-05-04)

- Updated theme engine to support badge theming options
- Substantial reworking of "Restrict to Workspace" functionality

## 0.11.123 "Reloaded" (2025-04-29)

- Added USR1 signal support to move dock to the active monitor
- Updated quality and consistency of drop shadows
- Renamed production release option to production-release

## 0.11.122 "Reloaded" (2025-04-26)

- Add new theming options for app indicators and active app
- Add new Minimal and Minimal-Light themes
- Fix panel display logic for Xfce/MATE/KDE
- Shorten long window titles in dock content menu
- Update default logging level to INFO
- Fix icon race condition when reinstalling/updating applications
- Updated documentation to reflect new features

## 0.11.121 "Reloaded" (2025-04-23)

- Added GapSize to set the gap between the dock and the screen edge

## 0.11.120 "Reloaded" (2025-04-21)

- Increased Max Zoom to 400%
- Removed requirement on GLib truncate_middle in Clippy Docklet

## 0.11.119 "Reloaded" (2025-04-17)

- Added sorting options for directories
- Updated translations

## 0.11.118 "Reloaded" (2025-04-02)

- Fix choppy magnification for digital clock
- Show preview of hex colors in Clippy
- Updated translations for Russian, Turkish, and Portuguese

## 0.11.117 "Reloaded" (2025-04-01)

- Added Portuguese translations
- Fixed inconsistent menu positioning
- No longer highlight Separator Docklets
- Correctly restore hover tooltips on menu close

## 0.11.116 "Reloaded" (2025-03-31)

- Rewrite of Clippy Docklet with image support and settings toggles
- Battery Docklet has settings menu for non UPower systems
- Added default icon to iconless apps in Applications Docklet

## 0.11.115 "Reloaded" (2025-03-29)

- Improved Applications Docklet: Large Icons, Custom Icon, and Edit Menu.
- Currently selected clipboard entry is highlighted in Clippy Docklet

## 0.11.114 "Reloaded" (2025-03-27)

- Added Workspaces Docklet

## 0.11.113 "Reloaded" (2025-03-25)

- Add Romanian, Turkish and Traditional Chinese translations

## 0.11.112 "Reloaded" (2025-03-24)

- Fix Xfce dock shadow issue
- Don't zoom separators

## 0.11.111 "Reloaded" (2025-03-22)

- Allow multiple separators

## 0.11.110 "Reloaded" (2025-03-21)

- Fix Applications Docklet loading for MATE desktops
- Fix misc Docklet translation issues
- Improve external drag and drop operations

## 0.11.109 "Reloaded" (2025-03-19)

- Updated Hindi translations
- Added Separator Docklet
- Added AnchorFiles to mimic OS X dock behavior
- Allow changing battery device for non-upower users
- Fixed Elementary OS settings lookup
- Actually fixed magnification state

## 0.11.108 "Reloaded" (2025-03-11)

- Fixed stuck magnification state

## 0.11.107 "Reloaded" (2025-03-09)

- Reduced GlowSize to 30 in Matte/Matte-Light themes
- Updated English UK translations

## 0.11.106 "Reloaded" (2025-03-08)

- Updated GlowSize in Matte themes to prevent screen artifacts
- Updated Portuguese translations

## 0.11.105 "Reloaded" (2025-03-04)

- Fix dock positioning issue in XFCE/Xubuntu
- Updated Korean translations

## 0.11.104 "Reloaded" (2025-03-03)

- Improved Clippy menu and support for multi line clipboard items.
- Updated project description and translation files.

## 0.11.103 "Reloaded" (2025-02-27)

- Updated spanish translation.
- Updated all .po files to prepare for new translations.
- Misc improvements to Clippy and Applications Docklets.

## 0.11.102 "Reloaded" (2025-02-25)

- Fix duplicate applications in the Applications Docklet.
- Remove explicit libbamf3-2t64 dependency in deb package.

## 0.11.101 "Reloaded" (2025-02-23)

- Updated Confirm Trash dialog handling.
- Improve reliability of Applications Docklet.
- Update directory handling to just show directory instead of custom grouped graphic.
- Moved to Meson build system.
- Fix all deprecation warnings.
- Slight fix to Calendar positioning in Clock Docklet.
- Added more icon possibilities for Docklets in the preferences UI.
- Added AnchorDocklets setting to allow Docklets to be anchored to the end of the dock.
- Fixed Restrict to Workspace so applications reliably show up.

## 0.11.100 "Reloaded" (2025-01-18)

- Enhanced Cinnamon desktop environment compatibility. Now all Docklets are fully functional.
- Updated Battery Docklet with modern UPower integration.
- Updated the Matte theme, and added MatteLight based on the Arian theme.
- Fixed Clock Docklet settings crash, updated the look of the Digital Clock and added a Calendar when clicked.
- General code cleanup and bug fixes.

## 0.11.89 "Nazz" (2019-08-19)

- Various adjustments/fixes and preparations for 0.12.0

## 0.11.4 "Eddy" (2017-03-28)

- Fix underscores not being shown in some menu items (LP: #1662968)
- Make window-manager aware that empty-trash dialog is part of plank
  (LP: #1652653)
- Fix build with -Werror=pointer-to-int-cast, -Werror=format,
  -Werror=implicit-function-declaration
- Generate manpage with help2man
- Update appdata
- Update translations

## 0.11.3 "Eddy" (2016-12-06)

- Add CPUMonitor docklet (LP: #1611504)
- Hide tooltips if the user performed action on a dockitem (LP: #1638680)
- Use the file's display-name where possible
- Trust Bamf with providing us the window-count
- Don't over-react on user-visible changes and keep transient items
- SurfaceCache: Never clear the cache completely
- tests: Fix build with valac 0.35+
- Drop references to gthread-2.0
- Update appdata
- Update translations

## 0.11.2 "Eddy" (2016-06-06)

- Require valac >= 0.26.0 and drop conditionals accordingly
- Add support for HSL and some convenience functions
- Fill in docklet descriptions
- Add and enforce some file-count limits
- Need to own clipboard's content before allowed to clear it (LP: #1540081)
- Pass correct index in menu-item-callback (LP: #1577745)
- Update translations

## 0.11.1 "Eddy" (2016-03-30)

- ApplicationDockItem: Use child-\* signals of Bamf.View and force
  indicator-update if running-state changed
- Actually emit DockController.elements_changed() to make DBusClient work
- DockletManager: Only handle properly named docklet-libraries
- Update translations

## 0.11.0 "Eddy" (2016-03-12)

- Use non-linear transition in/out of the "zoom" state
- Add docklets support (Clippy, Clock, Desktop, Trash) (LP: #731915)
- Use GSettings for dock settings (themes and dockitem files remain at their
  location) (LP: #994007)
- Consolidate public API (breaks old themes and dockitem files, those are
  transitioned accordingly if possible)
- Add "CascadeHide" theme option
- Don't grab input and abort this drag if DragItem is null (LP: #1517897)
- Add runtime support for gtk+ 3.19.1+ (LP: #1523208)
- Show descriptive tooltip for external-dnd actions (LP: #1512998)
- Update appdata to 0.6+ format
- Hide "Keep in Dock" wile LockItems is enabled (LP: #1530963)
- Don't apply window-scale-factor twice on foreground-icon-size
- Handle bad LauncherAPI clients which have an insane update-rate
  (LP: #1514201)
- Expose API to handle LauncherEntry DBus clients
- Expand dock on external-drag without enabled zoom too (LP: #1007058)
- Drop support for gee-1.0, having gee-0.8 is mandatory now
- Require glib >= 2.40 and gtk+ >= 3.10
- Handle file-monitor moved-event where launcher was target (LP: #1522917)
- Add "simple and experimental" multi-dock support
- Follow environment's setting whether to show notifications (LP: #1523266)
- Force SurfaceCache to allow downscale if drawing-time is insanely high
  (LP: #1502429)
- Add TooltipsEnabled setting (LP: #1553246)
- TOUCHPAD devices are able to perform pressure on a barrier too
- Some tweaking of the default themes
- Update translations

## 0.10.1 "Bartonschmeer" (2015-10-09)

- Require valac >= 0.24.0 as actually needed
- Correctly display filenames with underscores in folder-menu (LP: #1501499)
- plankdockitem: Open "preferences" on left-click instead of "about"
- Properly determine drop-position of external drags with enabled icon-zoom
- Update translations

## 0.10.0 "Bartonschmeer" (2015-09-07)

- Clean up and review appearances of DockItem in API an prefer DockElement
- Make the item for the dock-itself really special with its own setting
- Pass-through event on scroll/click to have a proper timestamps for
  WindowControl.\* calls (LP: #1167787) (LP: #1431556)
- Handle invalid item on runtime (LP: #1444830)
- Fix LogLevel naming (Logger.FATAL -> Logger.ERROR, Logger.ERROR ->
  Logger.CRITICAL)
- Make DockItem abstract
- Add frame_time to AnimatedRenderer with conditional use of GdkFrameClock
  (gtk+ >= 3.8)
- Add RTL support (LP: #1455892)
- Add DODGE_ACTIVE hide-mode
- Conditional use of GtkStack instead of GtkNotebook in preferences-dialog
  (gtk+ >= 3.10)
- Drop conditional dependency on gnome-common (and rely on autoconf-archive)
- Add icon-zoom hover-effect (LP: #707650)
- Don't use pressure reveal for absolute input devices (LP: #1349506)
- Force indicating running applications (LP: #1406282)

## 0.9.1 "Kanker" (2015-05-02)

- Initialize i18n as suggested [here](https://developer.gnome.org/glib/stable/)glib-I18N.html#glib-I18N.description
- Draw/unhide the dock on login when there are no windows (LP: #1256626)
- Explictly request/specify the FileMonitor-type which is needed
- Don't apply addition-animation to all items on startup
- Update translations

## 0.9.0 "Kanker" (2015-04-12)

- Add standard set of easing-functions
- Animate addition and removal for items (LP: #707651) (increase ItemMoveTime
  of Default theme to 450ms)
- Add "hide-delay" setting (LP: #1411644)
- Add "window-dodge" hide-mode (LP: #1431076)
- Add DBusManager to provide some remotely accessible actions (LP: #1365168)
- Increase default ItemMoveTime to 450ms
- settings: Save display-plug-name as "Monitor" which dock should be shown on
- Refactor and split up draw_item(), draw final internal dock-buffer on
  window-context at (0,0) (LP: #1426847)
- Trap XErrors caused by Wnck/Cairo (LP: #1293252)
- Optimize application-default-icon.svg and replace poof.png with newly
  created poof.svg (Thanks to Daniel Foré)
- Do not stop motion-events by default (LP: #1420043)
- Add support for loading icons with "resource://"-uris
- Generally watch for changes of the "Launcher"-file
- Refactor dealing with monitor-/size-changes to catch races-conditions
- Reverse ordering of menu-items for top-docks
- Add support for coverage analysis using gcov and lcov
- Start to improve coverage of tests
- Various API changes and refactoring, see full Changelog for details
- Update translations

## 0.8.1 "May" (2015-01-25)

- Make use of Gdk.EVENT_PROPAGATE and Gdk.EVENT_STOP
- Compatibility for BSD, use replacement for sys/prctl.h
- Request gee-0.8 without an automatic fallback to gee-1.0
- positionmanager: Alignment should have same meaning for dock and items
  START and END were treated differently resulting in a contradicting
  settings-behaviour of Aligment and ItemsAlignment
- Fix broken virtual LauncherEntry-items
- Fix menu-position with gtk+ 3.15+
- Fix enable/disable pressure-reveal on runtime
- Output information for more enabled features
- Fix some sensitivity assignments in preferences dialog
- Update translations

## 0.8.0 "May" (2015-01-02)

- Use selected-focused background-color from current gtk-theme (LP: #1406462)
- Add FileDockItem.with_file() and expose OwnedFile
- plank.pc: Add pkgdatadir and missing dependency on libbamf3
- Add special theme "Gtk+" which looks in current gtk-theme (LP: #1402272)
- Only show window-list and use "Close All" for more than one window
  (LP: #1398216) (LP: #1402139)
- lib: Handle DesktopAppInfo constructors returning NULL
- Don't hide while obstructed by one of our dialogs
- Fallback on "application-default-icon" only, otherwise use the internal
  default icon (LP: #1352467)
- Do not allow multiple dockitems pointing to the same application/launcher
- Fix gee assert triggered in handle_name_owner_changed (LP: #1393054)
- Require --enable-new-dtags support
- Update manpage
- Fix updating item-positions in panel-mode (LP: #1381518)
- Accept all supported URIs (LP: #1112519)
- Allow opening dropped files while LockItems is true
- Handle additional mouse-events for gtk+ 3.14+ to restore old behaviour
  while the dock-menu is shown
- Clean up and remove unused public API of position-manager
- Increase hover-window delay to 200ms
- Use ActionGroup/ActionMap capabilities to provide global-menu functions
- Port AbstractMain to inherit directly from Gtk.Application
- Add simple preferences dialog (hidden in Pantheon environments)
- Fix some HiDPI issues ()
- Fix DockContainer destructor name (Fix build with valac 0.27/git-master)

## 0.7.1 "Lee" (2014-09-23)

- hidemanager: Improve build- and runtime-checks for barrier-support
- renderer: Fix hide/unhide in non-compositing mode
- build: Missing the required valac version must be fatal
- hidemanager: Add missing HAVE_BARRIERS conditional
- positionmanager: Do not allow negative dimensions for the background

## 0.7.0 "Lee" (2014-09-15)

- Update the barrier for pressure-reveal if needed (LP: #1339846)
- Hide "Quit" while running on Pantheon (LP: #1355497)
- Introduce abstract DockContainer and let DockController implement it
- Let Drawing.Color inherit from Gdk.RGBA
- Clean up API of PositionManager
- Remove all LauncherEntry-items which match a dbus-sender-name and try to
  avoid adding superfluous LauncherEntry-items (LP: #1295750)
- Force internal Wnck update when needed and try to redruce races with
  Bamf (LP: #1355633)
- Add auto-pinning setting and enable by default (LP: #1336594)
- Monitor icon changes if it points to an existing local file (LP: #1354875)
- Add DrawingService.try_get_icon_file() to handle possible icon-files
- Creating transient-items on dockitem-deletion belongs in default-provider
- ItemFactory: Only strip the extension from the launcher-filename
- Provider: Handle item-target is placeholder-item correctly
- load_pixbuf: Properly try icon-name with stripped extension (LP: #1350347)
- ItemFactory: Update creation of default applications-items
- Add ability to show pinned applications only (LP: #1098018)
- Don't count or provide menu-entries for windows which have a transient
  (LP: #1347882)
- Don't optimize drawing of the first frame
- Use GLib.get_monotonic_time() for timestamps used to calculate animations
  (LP: #1341839)
- Add pressure-reveal support to unhide the dockwindow and disable by default
  (LP: #1079907)
- AppDockItem: Shorten window-title shown in menu using application-name
- Refactor dockitem-loading and serialization of pinned items
- Drop maximize/unmaximize menu-entries (LP: #1329551)
- Add compile time and runtime retrievable version information
- Require valac >= 0.22.0

## 0.6.1 "Marie" (2014-05-20)

- Actually pass all moved items on item_positions_changed (LP: #1042439)
- Make controller aware of changed items on replace_item
- Provide and install plank.appdata.xml file

## 0.6.0 "Marie" (2014-04-14)

- Allow other applications to steal and provide com.canonical.Unity
- Add animations on hovering and scrolling items
- Fix menu positioning with gtk+ 3.10.6 and later
- Desktop entries with Type=Link are not opened correctly (LP: #1042439)
- Plank switches workspace when it shouldn't (LP: #1090976)
- Recognize long-press mouse clicks (LP: #1179087)
- Fix crash using an invalid Wnck.Window object (LP: #1219929)
- Dock returns to primary monitor when wake up from suspend (LP: #1264194)
- Showing Plank menu should not darken dock items (LP: #1268376)
- New windows minimize to center instead of Plank (LP: #1214728)
- Support for GTK's HiDPI (LP: #1288845)
- Dragging file over dockitem doesn't raise window (LP: #1303975)
- Show placeholder if the dock is empty (LP: #1228397)
- Properly center non-square thumbails
- Further minor clean ups and fixes, see Changelog further information

## 0.5.0 "Jimmy" (2013-11-17)

- Pin applications which were dragged on the dock (LP: #1227636)
- Intialize DockRenderer as last (LP: #1168414)
- Fix showing and handling of PoofWindow (LP: #1185557)
- Use correct hide-duration to adjust last-hide moment (LP: #1244451)
- Reset drawing buffers on theme changes
- Fix intersection-checking of point with rectangle (LP: #1242176)
- Fix item-move-animation for right/top docks
- Further minor clean ups and fixes

## 0.4.0 "Jonny 2x4" (2013-10-18)

- Add developer documentation to HACKING and some information to README.md
- Add LockItems setting (LP: #1182077)
- Add dodge-maximized hide-mode
- Use Gdk.threads_add_timeout and Gdk.threads_add_idle
- Remove app-item if its application got uninstalled (LP: #1119860)
- Use "metadata::custom-icon-name" as icon-source
- Fix retrieving thumbnails for files
- Make DockController able to handle multiple Providers
- Force to show menu-icons for all file- and window entries
- Fix determining if the folder has a custom icon (LP: #1241158)
- Mimic a Gtk.Tooltip drawn based on gtk-css-theme (LP: #1082968)
- Don't draw the complete dock if it isn't visible at all
- Properly respect the given FadeTime
- Decrease icon bounce-height depending on animation-progress (LP: #1094275)
- Use Operator.OVER for drawing the icon shadows (LP: #1213418)
- Explictly set struts if the HideMode was changed (LP: #1130009)
- Update HoveredItem on button-pressed if needed (LP: #1213787)
- Update input-mask after calling draw_dock (LP: #1204856)

## 0.3.0 "Basement Treasure" (2013-06-25)

- Initial Release
