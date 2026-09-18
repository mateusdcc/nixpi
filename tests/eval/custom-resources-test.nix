{
  pkgs,
  nixpiLib,
}:

let
  lib = pkgs.lib;

  testEntrypointFile = pkgs.writeText "my-entrypoint.js" ''
    export default function(pi) {
      console.log("Entrypoint extension loaded");
    }
  '';

  testSrcDir = pkgs.runCommand "test-ext-dir" { } ''
    mkdir -p "$out/extensions"
    echo 'export default function(pi) { console.log("Dir extension loaded"); }' > "$out/extensions/index.js"
  '';

  evaluated = nixpiLib.evalPi {
    inherit pkgs;
    modules = [
      {
        programs.pi = {
          enable = true;

          customExtensions = {
            inline-ext = {
              enable = true;
              version = "1.2.0";
              description = "Inline test extension";
              content = ''
                export default function(pi) {
                  pi.registerCommand("inline-cmd", {
                    description: "Inline command",
                    handler: async () => {}
                  });
                }
              '';
              runtimePackages = [ pkgs.jq ];
              runtimeEnvironment = {
                INLINE_EXT_ACTIVE = "1";
              };
            };

            entrypoint-ext = {
              enable = true;
              entrypoint = testEntrypointFile;
              runtimePackages = [ pkgs.ripgrep ];
            };

            dir-ext = {
              enable = true;
              src = testSrcDir;
            };

            disabled-ext = {
              enable = false;
              content = "export default function() {}";
            };
          };

          customSkills = {
            my-skill = {
              enable = true;
              description = "Custom test skill";
              content = "# My Custom Skill\nSkill instructions here.";
              runtimePackages = [ pkgs.curl ];
            };
          };

          customPrompts = {
            review-code = {
              enable = true;
              description = "Prompt for reviewing code";
              argumentHint = "[file]";
              content = "Please review the following code:\n$ARGUMENTS";
            };
          };

          customThemes = {
            custom-neon = {
              enable = true;
              colors = {
                accent = "#00ffcc";
                bg = "#111122";
              };
            };
          };
        };
      }
    ];
  };

  cfg = evaluated.config.programs.pi;

  # Verify extensions are packaged and listed
  hasInlineExtPkg = cfg.customExtensions.inline-ext.package != null;
  hasEntrypointExtPkg = cfg.customExtensions.entrypoint-ext.package != null;
  hasDirExtPkg = cfg.customExtensions.dir-ext.package != null;
  disabledExtNotIncluded = !lib.elem cfg.customExtensions.disabled-ext.package cfg.packages;

  # Verify runtime packages
  hasJq = lib.elem pkgs.jq cfg.finalRuntimePackages;
  hasRipgrep = lib.elem pkgs.ripgrep cfg.finalRuntimePackages;
  hasCurl = lib.elem pkgs.curl cfg.finalRuntimePackages;

  # Verify environment variables
  hasEnvVar = cfg.environment.variables.INLINE_EXT_ACTIVE or null == "1";

  # Verify skills
  hasSkill = lib.length cfg.extraSkills >= 1;

  # Verify prompts
  hasPrompt = lib.length cfg.prompts >= 1;

  # Verify themes
  hasTheme = lib.length cfg.themes >= 1;

  allPassed =
    hasInlineExtPkg
    && hasEntrypointExtPkg
    && hasDirExtPkg
    && disabledExtNotIncluded
    && hasJq
    && hasRipgrep
    && hasCurl
    && hasEnvVar
    && hasSkill
    && hasPrompt
    && hasTheme;
in
pkgs.runCommand "nixpi-custom-resources-test" { } ''
  ${lib.optionalString (!allPassed) "echo 'Custom resources eval test failed' >&2; exit 1"}
  grep -q "inline-ext" "${cfg.generatedSettingsFile}"
  grep -q "entrypoint-ext" "${cfg.generatedSettingsFile}"
  grep -q "dir-ext" "${cfg.generatedSettingsFile}"
  grep -q "my-skill" "${cfg.generatedSettingsFile}"
  grep -q "review-code.md" "${cfg.generatedSettingsFile}"
  grep -q "custom-neon.json" "${cfg.generatedSettingsFile}"
  echo "Custom resources evaluation test passed successfully" > "$out"
''
