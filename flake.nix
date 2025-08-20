{
    description = "Plank Reloaded";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs, ... }: let
        systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
        forAllSystems = arch: nixpkgs.lib.genAttrs systems (system: arch system);
    in {
        packages = forAllSystems (system:
            let
                pkgs = import nixpkgs { inherit system; };
            in {
                plank-reloaded = pkgs.stdenv.mkDerivation rec {

                    pname = "plank-reloaded";

                    version = "latest";

                    src = ./.;

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
                        ./nix-hide-in-pantheon.patch
                    ];

                    meta = with pkgs.lib; {
                        description = "A simple dock for X11 environments";
                        license = licenses.mit;
                        platforms = platforms.linux;
                    };
                };
                default = self.packages.${system}.plank-reloaded;
            });
        defaultPackage = forAllSystems (system: self.packages.${system}.plank-reloaded);
        defaultApp = forAllSystems (system: {
            type = "app";
            program = "${self.packages.${system}.plank-reloaded}/bin/plank";
        });
    };
}
