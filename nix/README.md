# NixOS Flake for Plank Reloaded

A Nix flake to build and run [Plank Reloaded](https://github.com/zquestz/plank-reloaded).

## Installation

1. **Clone the repo** and navigate to the directory:

   ```sh
   git clone https://github.com/zquestz/plank-reloaded.git
   cd plank-reloaded/nix
   ```

2. **Build the package** using Nix:

   ```sh
   sudo nix build .#packages.x86_64-linux.plank-reloaded
   ```

3. **Get the built package path**:

   ```sh
   readlink -f result
   ```

4. **Run Plank Reloaded**:
   ```sh
   /your/path/bin/plank
   ```

Replace `/your/path/` with the output from step 3.

## System-wide Installation

To include Plank Reloaded in your system-wide packages, add this to your `configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  # Other packages...
  (callPackage /your/path/package/plank-reloaded.nix {})
];
```

### Apply Changes:

1. Edit `configuration.nix` and add the package as shown above.
2. Rebuild your system:
   ```sh
   sudo nixos-rebuild switch
   ```
3. Verify installation by running:
   ```sh
   plank
   ```

## Notes

You might get an incorrect hash when building, just update `flake.nix` with the hash in the error message and rebuild the package.

## Credits

Thanks to [thecreativedg](https://github.com/thecreativedg) for the original code which can be found at:

[https://github.com/thecreativedg/plank-reloaded-flake](https://github.com/thecreativedg/plank-reloaded-flake)
