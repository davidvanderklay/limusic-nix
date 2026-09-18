{
  description = "Nix flake for the Limusic desktop app";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          limusic = pkgs.callPackage ./package.nix { };
        in
        {
          inherit limusic;
          default = limusic;
        }
      );

      apps = forAllSystems (system: {
        default = {
          meta = {
            description = "Limusic desktop app";
          };
          type = "app";
          program = "${toString self.packages.${system}.default}/bin/limusic";
        };
      });

      checks = forAllSystems (system: {
        limusic = self.packages.${system}.default;
      });
    };
}
