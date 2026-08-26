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
  };

  evaluated = nixpiLib.evalPi {
    inherit pkgs;
    modules = [
      customExtModule
      customSkillModule
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
          extraPackages = [ pkgs.ripgrep ];
          extraSkills = [ "/mock/skill/path" ];
        };
      }
    ];
  };

  cfg = evaluated.config.programs.pi;
  extEnabled = cfg.extensions.custom-extension.enable == true;
  extKey = cfg.extensions.custom-extension.settings.apiKey == "configured-key";
  skillEnabled = cfg.skills.custom-skill.enable == true;
  hasExtraPkg = lib.elem pkgs.ripgrep cfg.finalRuntimePackages;

  allPass = extEnabled && extKey && skillEnabled && hasExtraPkg;
in
pkgs.runCommand "nixpi-factory-test" { } ''
  ${lib.optionalString (!allPass) "echo 'Factory module evaluation test failed' >&2; exit 1"}
  echo "Factory module evaluation test passed" > "$out"
''
