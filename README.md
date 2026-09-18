# limusic-nix

Nix packaging for the official Limusic Linux AppImage.

Run it directly:

```bash
nix run github:davidvanderklay/limusic-nix
```

Use it as a flake input:

```nix
limusic = {
  url = "github:davidvanderklay/limusic-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

The update workflow checks Limusic releases every six hours, updates the version and hash, runs `nix flake check`, and opens a pull request when a new AppImage is available.
