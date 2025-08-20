{
  description = "Plank Reloaded";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
    };
  in
  {
    packages.x86_64-linux.plank-reloaded = pkgs.stdenv.mkDerivation rec {
      pname = "plank-reloaded";
      version = "latest";

      src = pkgs.fetchFromGitHub {
        owner = "zquestz";
        repo = "plank-reloaded";
        rev = "master";
        sha256 = "sha256-yHvD6pjVKwIBNYr3GWBMbdqcMdBWgxiwrTKqBfVt7+8=";
      };

      nativeBuildInputs = [
        pkgs.meson
        pkgs.ninja
        pkgs.pkg-config
        pkgs.vala
        pkgs.glib
        pkgs.bamf
        pkgs.wrapGAppsHook  # Added for GSettings support
      ];

      buildInputs = [
        pkgs.gnome-settings-daemon
        pkgs.dconf
        pkgs.glib
        pkgs.git
        pkgs.gtk3
        pkgs.gnome-menus
        pkgs.libgee
        pkgs.libwnck
        pkgs.pango
        pkgs.desktop-file-utils
      ];

      # Compile schemas in post-install phase
      postInstall = ''
        glib-compile-schemas $out/share/glib-2.0/schemas
      '';

      patches = [
        ./hide-in-pantheon.patch
      ];

      meta = with pkgs.lib; {
        description = "A simple dock for X11 environments";
        license = licenses.mit;
        platforms = platforms.linux;
      };
    };
  };
}
