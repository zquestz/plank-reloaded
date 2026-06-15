Name:           plank-reloaded-plus
Version:        %{version}
Release:        %{release}%{?dist}
Summary:        Elegant and simple dock with per-monitor window tracking

License:        GPL-3.0-or-later
URL:            https://github.com/cdmdotnet/plank-reloaded-plus
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  meson >= 0.59.0
BuildRequires:  ninja-build
BuildRequires:  vala
BuildRequires:  pkgconfig
BuildRequires:  gettext
BuildRequires:  desktop-file-utils
BuildRequires:  cmake
BuildRequires:  clang
BuildRequires:  libgnome-devel
BuildRequires:  libxml2-devel
BuildRequires:  gnome-menus-devel
BuildRequires:  libgee-devel
BuildRequires:  libdbusmenu-gtk3-devel
BuildRequires:  libwnck3-devel
BuildRequires:  bamf-devel
BuildRequires:  gtk3-devel
BuildRequires:  cairo-devel
BuildRequires:  gdk-pixbuf2-devel
BuildRequires:  glib2-devel

# Don't require specific library versions - let RPM auto-generate them
Requires:       bamf
Requires:       bamf-daemon
Requires:       gtk3
Requires:       cairo
Requires:       gdk-pixbuf2

Conflicts:      plank
Conflicts:      libplank-common
Conflicts:      libplank1

%description
Plank Reloaded Plus is a fork of Plank Reloaded, which itself is a fork of
the original Plank project. It provides a simple dock for X11 desktop
environments, actively supporting Cinnamon, MATE, Xfce, and KDE.

Building on Plank Reloaded's foundation, Plank Reloaded Plus introduces
enhanced multi-monitor awareness. Each dock instance tracks which monitor it
is running on and filters window indicators accordingly: pinned app indicators
only count windows present on the same monitor as the dock, and unpinned apps
are hidden from a dock instance when none of their windows are on that
monitor. This applies both when running one dock per monitor and when using
the single-instance "follow active monitor" mode.

Like its predecessors, Plank Reloaded Plus aims to be the simplest dock on
the planet, providing just what a dock needs and absolutely nothing more.

%package devel
Summary:        Development files for plank-reloaded-plus
Requires:       %{name}%{?_isa} = %{version}-%{release}
Requires:       vala
Requires:       pkgconfig

%description devel
This package contains the development files for plank-reloaded-plus, including
headers, libraries, and Vala bindings needed to develop applications or
docklets that use libplank.

%prep
%autosetup -n %{name}-%{version}

%build
%meson \
    -D enable-apport=false \
    -D production-release=true
%meson_build

%install
%meson_install

# Compress man pages
gzip -9n %{buildroot}%{_mandir}/man1/plank.1

# Fix shared library permissions
chmod 755 %{buildroot}%{_libdir}/libplank.so.*

%find_lang %{name}

%files -f %{name}.lang
%license COPYING COPYRIGHT
%doc README.md NEWS.md AUTHORS
%{_bindir}/plank
%{_libdir}/libplank.so.*
%{_libdir}/plank/
%{_datadir}/plank/
%{_datadir}/applications/net.launchpad.plank.desktop
%{_datadir}/glib-2.0/schemas/net.launchpad.plank.gschema.xml
%{_datadir}/icons/hicolor/*/apps/plank-reloaded.png
%{_mandir}/man1/plank.1.gz
%{_datadir}/metainfo/plank.appdata.xml

%files devel
%doc README.md
%{_includedir}/plank/
%{_libdir}/libplank.so
%{_libdir}/pkgconfig/plank.pc
%{_datadir}/vala/vapi/plank.deps
%{_datadir}/vala/vapi/plank.vapi

%post
/sbin/ldconfig
/usr/bin/glib-compile-schemas %{_datadir}/glib-2.0/schemas >/dev/null 2>&1 || :
/usr/bin/update-desktop-database >/dev/null 2>&1 || :
/usr/bin/gtk-update-icon-cache %{_datadir}/icons/hicolor >/dev/null 2>&1 || :

%postun
/sbin/ldconfig
if [ $1 -eq 0 ] ; then
    /usr/bin/glib-compile-schemas %{_datadir}/glib-2.0/schemas >/dev/null 2>&1 || :
    /usr/bin/update-desktop-database >/dev/null 2>&1 || :
    /usr/bin/gtk-update-icon-cache %{_datadir}/icons/hicolor >/dev/null 2>&1 || :
fi

%changelog
* Thu Jun 12 2026 cdmdotnet Limited <support@cdmdotnet.com> - 0.12.4-3
- Fix docks on the inner edge of a monitor incorrectly reserving work area
  space from the screen edge, making adjacent monitors unusable for window
  snapping, maximising, and resizing
- Dock settings and launchers now follow the physical monitor rather than
  the port name, so configurations survive dock or hub changes between sessions

* Thu Mar 12 2026 cdmdotnet Limited <support@cdmdotnet.com> - 0.12.3-1
- Fix monitor manager child instances starting on the wrong monitor: managed
  dock prefs are now applied before PositionManager initialises so the dock
  renders at the correct position from the first frame
- Fix DBus object path assertion failures for monitors with hyphens in their
  names (e.g. DP-2-8): illegal characters are sanitised to underscores
- Fix position retry storm: raise retry ceiling to 10 with verbose logging,
  then warn once and stop rather than spamming CRITICAL on every configure event
- Fix On Primary Display and Active Display controls not locked when running as
  a monitor manager child; all three monitor controls are now insensitive
- Fix monitor manager not exiting when its only child dock is closed: remove
  unreliable loop.is_running() guard from the auto-quit check

* Sat Mar 08 2026 cdmdotnet Limited <support@cdmdotnet.com> - 0.12.2-1
- Add --monitor-manager mode: automatically opens a dock on each connected
  monitor, opens new docks when monitors are plugged in, closes docks when
  monitors are unplugged — no script or manual per-monitor configuration needed
- When a monitor is unplugged its dock closes gracefully preserving settings
- Monitor manager exits automatically when all dock instances have been closed

* Wed Feb 26 2026 cdmdotnet Limited <support@cdmdotnet.com> - 0.12.1-1
- Add window preview popup on hover for running application icons
- Preview shows thumbnail cards for each open window with title labels
- Left-click a preview card to focus that window; middle-click to close it
- Hovering a preview card outlines the corresponding live desktop window
- Preview popup inherits the user's active GTK tooltip theme colours
- Preview Windows toggle added to Behaviour preferences

* Tue Feb 24 2026 cdmdotnet Limited <support@cdmdotnet.com> - 0.11.167-1
- Fork from plank-reloaded as plank-reloaded-plus
- Add per-monitor window indicator filtering: each dock instance now tracks
  which monitor it is running on and counts only windows present on that
  monitor when displaying app indicators
- Hide unpinned apps from a dock instance when none of their windows are on
  the same monitor as that dock
- Support both multi-instance (one dock per monitor) and single-instance
  "follow active monitor" configurations

* Mon Apr 13 2026 Josh Ellithorpe <quest@mac.com> - 0.11.167-1
- Decouple GapSize dock reveal from X11 barriers using edge pointer polling

* Thu Feb 13 2026 Josh Ellithorpe <quest@mac.com> - 0.11.166-1
- Fix struts double-scaling on HiDPI and xrandr multi-monitor setups
- Fix dock positioning with xrandr scaling transforms
- Reposition dock when window scale factor changes at runtime

* Thu Feb 13 2026 Josh Ellithorpe <quest@mac.com> - 0.11.165-1
- Fix dock becoming unclickable when using GapSize > 0 with barrier-based reveal

* Sun Feb 08 2026 Josh Ellithorpe <quest@mac.com> - 0.11.164-1
- Fix drag occasionally ending prematurely
- Fix desktop environment detection on Debian XFCE
- Fix dock unhide with graphics tablets
- Fix sticky and pinned windows not minimizing or focusing on non-original workspaces
- Fix HoverWindow positioning on XFCE and KDE
- Fix icon lookup to try all windows instead of only the first
- Improve animation smoothness and reduce CPU usage
- Increase poof animation framerate
- Add docklet development guide

* Fri Feb 07 2026 Josh Ellithorpe <quest@mac.com> - 0.11.163-1
- Fix workspace switch when focusing sticky windows

* Fri Feb 07 2026 Josh Ellithorpe <quest@mac.com> - 0.11.162-1
- Fix struts using primary monitor dimensions instead of full screen size on multi-monitor setups
- Skip workspace switch when focusing pinned windows

* Mon Jan 27 2026 Josh Ellithorpe <quest@mac.com> - 0.11.161-1
- Fix use-after-free crash in window operations using XID-based queue
- Fix urgent glow position when GapSize > 0
- Optimize render loop with reusable scratch surface and early exits
- Eliminate per-frame HashMap allocations for draw values
- Add fast path for idle dock state (no zoom active)

* Sun Jan 25 2026 Josh Ellithorpe <quest@mac.com> - 0.11.160-1
- Fix CPUMonitorDocklet thread-safety by marshalling UI updates to main thread
- Fix ApplicationsDocklet crashes during package installation/removal with re-entrancy guard
- Optimize DockRenderer to avoid unnecessary Surface.copy() during animations
- Move Battery docklet I/O to background thread
- Cache can_accept_drop results to avoid repeated I/O during drag motion
- Fix timer leaks, remove UI thread blocking, and document app-specific workarounds
- Update docs: fix branch name, copyright year, and IRC reference
- Bump GTK minimum to 3.22
- Fix drag-and-drop to check if app accepts file arguments
- Clean up outdated version-specific FIXMEs and TODOs
- Fix inner stroke transparency (thanks guritso)
- Add MATE desktop support to respect Caja's confirm-trash setting

* Mon Dec 29 2025 Josh Ellithorpe <quest@mac.com> - 0.11.159-1
- Fix Cinnamon desktop detection for X-Cinnamon XDG_CURRENT_DESKTOP value

* Tue Dec 23 2025 Josh Ellithorpe <quest@mac.com> - 0.11.158-1
- Fix dock not moving when switching between monitors with identical resolution
- Fix ActiveDisplay preferences warning messages

* Thu Dec 11 2025 Josh Ellithorpe <quest@mac.com> - 0.11.157-1
- Remove systemd support in favor of desktop environment autostart

* Thu Nov 13 2025 Josh Ellithorpe <quest@mac.com> - 0.11.156-1
- Add 7 new language translations: Bengali, Farsi, Filipino, Marathi, Punjabi, Swahili, and Urdu
- Complete translations for 64 existing languages
- Now supporting 71 languages total covering over 1 billion additional speakers

* Sun Nov 02 2025 Josh Ellithorpe <quest@mac.com> - 0.11.155-1
- Reduce minimum icon size to 16 pixels
- Increase maximum GapSize to 200 pixels
- Fix struts calculation to respect GapSize
- Fix input mask capturing events with GapSize enabled

* Thu Oct 30 2025 Josh Ellithorpe <quest@mac.com> - 0.11.154-1
- Refactor systemd service to work more reliably with bamf failures
