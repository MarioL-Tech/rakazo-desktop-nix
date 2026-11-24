{
  description = "Rakazo desktop AppImage packaged for NixOS";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  outputs = { nixpkgs, ... }: {
    packages.x86_64-linux = rec {
      rakazo-desktop = nixpkgs.legacyPackages.x86_64-linux.callPackage ./package.nix { };
      default = rakazo-desktop;
    };
    nixosModules.default = { config, lib, pkgs, ... }: {
      options.programs.rakazo-desktop.enable = lib.mkEnableOption "Rakazo desktop";
      config = lib.mkIf config.programs.rakazo-desktop.enable {
        environment.systemPackages = [ (pkgs.callPackage ./package.nix { }) ];
      };
    };
  };
}
