{
  description = "Plasma 6 plot-drop plasmoid";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = [
          pkgs.bash
          pkgs.gnuplot
          pkgs.kdePackages.kpackage
          pkgs.kdePackages.plasma-sdk
        ];
      };
    };
}
