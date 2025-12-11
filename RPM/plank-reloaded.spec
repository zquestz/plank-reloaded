Name:           plank-reloaded
Version:        %{version}
Release:        %{release}%{?dist}
Summary:        Elegant and simple dock

License:        GPL-3.0-or-later
URL:            https://github.com/zquestz/plank-reloaded
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
Plank Reloaded is a fork of the original Plank project, providing a simple dock
for X11 desktop environments. While development began with a focus on Cinnamon,
we now actively support multiple desktop environments including MATE and Xfce.
Like its predecessor, Plank Reloaded aims to be the simplest dock on the
planet, providing just what a dock needs and absolutely nothing more.

%package devel
Summary:        Development files for plank-reloaded
Requires:       %{name}%{?_isa} = %{version}-%{release}
Requires:       vala
Requires:       pkgconfig

%description devel
This package contains the development files for plank-reloaded, including
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
