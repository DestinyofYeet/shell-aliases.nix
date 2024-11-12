# Shell-aliases.nix

Allows you to define shell aliases like home.aliases, but you can disable or re-define aliases per shell.

## Include in your flake:

```nix
inputs = {
  shell-aliases = {      
    url = "github:DestinyofYeet/shell-aliases.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
  
```

Then just import it in your home-manager.sharedModules 

```nix
home-manager.sharedModules = [
  shell-aliases.homeManagerModules.default
];
  
```

## Usage Example:

```nix
programs.shell-aliases = {
  enable = true;
  enableBash = false; # don't write aliases for the bash shell
  aliases = {
    "lg" = "lazygit"; # will set that alias for all shells

    "ll" = {
      default = "ls -lah"; # will be set for all shells unless overriden

      nushell = "ls -la"; # specific overide for nushell
    };
  };
};
```

or [this configuration](https://github.com/DestinyofYeet/nix-config/blob/5d9f5a57e95f4221ed9c9a14c29ac6d58627c2e6/non-server/modules/shell-aliases.nix)
