{
  description = "A flake to provide cross-shell aliases";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    homeManagerModules.default = import ./module.nix self;
  };
}
