{
  description = "nixos-config";

  inputs.helix.url = "github:helix-editor/helix";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/master";
  inputs.fnl.url = "path:fnl";
  inputs.fnl.flake = false;
  inputs.zls.url = "github:zigtools/zls";

  outputs =
    { self
    , home-manager
    , ...
    } @ inputs:
    let
      overlays = [
        (
          self: super: {
            fnl = self.pkgs.stdenv.mkDerivation {
              pname = "fnl";
              version = "unstable";
              src = inputs.fnl;
              buildInputs = [ self.pkgs.fennel ];
              installPhase = ''
                mkdir -p $out
                fennel --compile $src/init.fnl > $out/init.lua
                cp $src/highlights.scm $out/highlights.scm
              '';
            };
          }
        )
      ];
    in
    {
      homeConfigurations = {
        home = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs =
            inputs.nixpkgs.legacyPackages.aarch64-darwin
            // {
              inherit overlays;
              config = {
                permittedInsecurePackages = [ "libxls-1.6.2" ];
              };
            };
          modules = [
            ./modules/direnv.nix
            ./modules/fonts.nix
            ./modules/gh.nix
            ./modules/ghostty.nix
            ./modules/git.nix
            ./modules/helix.nix
            ./modules/kitty.nix
            ./modules/packages.nix
            ./modules/scim.nix
            ./modules/shell.nix
            ./modules/pass.nix
            ./modules/starship.nix
            ./modules/tmux.nix
            {
              home.username = "emredeger";
              home.stateVersion = "23.11";
              home.homeDirectory = "/Users/emredeger";
            }
          ];
        };
      };

      home = self.homeConfigurations.home.activationPackage;
    };
}
