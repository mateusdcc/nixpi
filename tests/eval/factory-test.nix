{
  pkgs,
  nixpiLib,
}:

let
  lib = pkgs.lib;

  # Create an extension module using the new factory
  customExtModule = nixpiLib.mkPiExtensionModule {
    name = "custom-extension";
    description = "Test custom extension generated via factory";
    runtimePackages = [ pkgs.jq ];
    extraPackages = [ pkgs.bat ];
    settingsOptions = {
      apiKey = lib.mkOption {
        type = lib.types.str;
        default = "test-key";
        description = "API key for custom extension.";
      };
      timeout = lib.mkOption {
        type = lib.types.int;
        default = 30;
        description = "Timeout in seconds.";
      };
    };
  };

  # Create a skill module using the new factory
  customSkillModule = nixpiLib.mkPiSkillModule {
    name = "custom-skill";
    description = "Test custom skill generated via factory";
    runtimePackages = [ pkgs.curl ];
  };

  # Create a provider module using the new factory
  customProvModule = nixpiLib.mkPiProviderModule {
    name = "custom-provider";
    description = "Test custom provider generated via factory";
    runtimePackages = [ pkgs.coreutils ];
  };

  evaluated = nixpiLib.evalPi {
    inherit pkgs;
    modules = [
      customExtModule
      customSkillModule
      customProvModule
      {
        programs.pi = {
          enable = true;
          extensions.custom-extension = {
            enable = true;
            settings.apiKey = "configured-key";
          };
          skills.custom-skill = {
            enable = true;
          };
          providers.custom-provider = {
            enable = true;
          };
          extraPackages = [ pkgs.ripgrep ];
          extraExtensions = [ "/mock/ext/path" ];
          extraSkills = [ "/mock/skill/path" ];
        };
      }
    ];
  };

  cfg = evaluated.config.programs.pi;
  extEnabled = cfg.extensions.custom-extension.enable == true;
  extKey = cfg.extensions.custom-extension.settings.apiKey == "configured-key";
  skillEnabled = cfg.skills.custom-skill.enable == true;
  provEnabled = cfg.providers.custom-provider.enable == true;

  hasRipgrep = lib.elem pkgs.ripgrep cfg.finalRuntimePackages;
  hasJq = lib.elem pkgs.jq cfg.finalRuntimePackages;
  hasBat = lib.elem pkgs.bat cfg.finalRuntimePackages;
  hasCurl = lib.elem pkgs.curl cfg.finalRuntimePackages;
  hasCoreutils = lib.elem pkgs.coreutils cfg.finalRuntimePackages;
  hasExtraExt = lib.elem "/mock/ext/path" cfg.extraExtensions;
  hasExtraSkill = lib.elem "/mock/skill/path" cfg.extraSkills;

  allPass =
    extEnabled
    && extKey
    && skillEnabled
    && provEnabled
    && hasRipgrep
    && hasJq
    && hasBat
    && hasCurl
    && hasCoreutils
    && hasExtraExt
    && hasExtraSkill;
in
pkgs.runCommand "nixpi-factory-test" { } ''
  ${lib.optionalString (!allPass) "echo 'Factory module evaluation test failed' >&2; exit 1"}
  grep -q "/mock/ext/path" "${cfg.generatedSettingsFile}"
  grep -q "/mock/skill/path" "${cfg.generatedSettingsFile}"
  echo "Factory module evaluation test passed: verified mkPiExtensionModule, mkPiSkillModule, mkPiProviderModule, and extra resources" > "$out"
''
