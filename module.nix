self: {
  lib,
  config,
  ...
}:


let 

  inherit (lib) mkEnableOption mkOption types mkIf concatStringsSep mapAttrsToList mapAttrs isString filterAttrs substring toUpper stringLength listToAttrs;

  cfg = config.programs.shell-aliases;

  filter-null = shell:
    filterAttrs (name: value: value.${shell} != null) cfg.aliases;
  mkShellAliasShell = shell: lib.mkIf cfg."enable${(toUpper (substring 0 1 shell)) + (substring 1 (stringLength shell) shell)}" (mapAttrs (name: value: (value.${shell})) (filter-null shell));
in {
  options = {
    programs.shell-aliases = {
      enable = mkEnableOption " shell-aliases";

      enableNushell = mkOption {
        type = types.bool;
        default = cfg.enable;
      };
      enableBash = mkOption {
        type = types.bool;
        default = cfg.enable;
      };
      enableZsh = mkOption {
        type = types.bool;
        default = cfg.enable;
      };

      aliases = mkOption {
        type = types.attrsOf (types.either (types.submodule ({name, ...}: {
          options = {
            default = mkOption {
              type = types.str;
              description = "The alias applied to all shells if not overridden";
            };

            nushell = mkOption {
              type = types.nullOr types.str;
              description = "The override value of nushell";
              default = cfg.aliases.${name}.default;
            };

            bash = mkOption {
              type = types.nullOr types.str;
              description = "The override value of bash";
              default = cfg.aliases.${name}.default;
            };

            zsh = mkOption {
              type = types.nullOr types.str;
              description = "The override value of zsh";
              default = cfg.aliases.${name}.default;
            };
          };
        })) types.str);

        apply = old:
          mapAttrs (name: value: if !isString value then value else {
            default = value;
            nushell = value;
            bash = value;
            zsh = value;
          }) old;
      };
    };
  };

  config = mkIf cfg.enable {
    programs = {
      nushell.configFile.text = lib.mkIf cfg.enableNushell (concatStringsSep "\n" (mapAttrsToList (name: value: "alias ${name} = ${value.nushell}") (filter-null "nushell")));
  
    } // listToAttrs (map (name: { inherit name; value = { shellAliases = mkShellAliasShell name;};}) [ "zsh" "bash" ]);
  };
}
