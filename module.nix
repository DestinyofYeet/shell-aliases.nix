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

  mkFirstCharUpper = string:
    (toUpper (substring 0 1 string)) + (substring 1 (stringLength string) string);

  mkShellAliasShell = shell: lib.mkIf cfg."enable${mkFirstCharUpper shell}" (mapAttrs (name: value: (value.${shell})) (filter-null shell));

  mkShellOption = shell: mkOption {
    type = types.bool;
    default = cfg.enable;
  };

  mkShells = shells: listToAttrs (map (name: { name = "enable${mkFirstCharUpper name}"; value = mkShellOption name; }) shells);

  shellAliasShells = [
    "bash"
    "zsh"
    "fish"
  ];

  shells = [
    "nushell"
  ] ++ shellAliasShells;
in {
  options = {
    programs.shell-aliases = {
      enable = mkEnableOption " shell-aliases";

      aliases = mkOption {
        type = types.attrsOf (types.either (types.submodule ({name, ...}: {
          options = {
            default = mkOption {
              type = types.str;
              description = "The alias applied to all shells if not overridden";
            };

            # shellName = mkOption {
            #   type = types.nullOr types.str;
            #   description = "The override value of zsh";
            #   default = cfg.aliases.${name}.default;
            # };

            # the below merge achieves the option above, but for every shell
          } // listToAttrs (map (shellName: { name = shellName; value = mkOption {
            type = types.nullOr types.str;
            description = "The override value of ${shellName}";
            default = cfg.aliases.${name}.default;
          };}) shells);
        })) types.str);

        apply = old:
          mapAttrs (name: value: if !isString value then value else {
            default = value;

            # generates shellName = value;
          } // (listToAttrs (map (name: { inherit name value; }) shells))) old;
      };
    } // mkShells shells;
  };

  config = mkIf cfg.enable {
    programs = {
      nushell.configFile.text = lib.mkIf cfg.enableNushell (concatStringsSep "\n" (mapAttrsToList (name: value: "alias ${name} = ${value.nushell}") (filter-null "nushell")));
  
    } // listToAttrs (map (name: { inherit name; value = { shellAliases = mkShellAliasShell name;};}) shellAliasShells);
  };
}
