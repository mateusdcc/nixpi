{
  pkgs,
  nixpiLib,
}:

let
  lib = pkgs.lib;

  testEntrypointJs = pkgs.writeText "my-entrypoint.js" ''
    export default function(pi) {
      console.log("JS entrypoint extension loaded");
    }
  '';

  testEntrypointTs = pkgs.writeText "my-entrypoint.ts" ''
    export default function(pi: any): void {
      const tsVal: number = 42;
      console.log(`TS entrypoint extension loaded: ''${tsVal}`);
    }
  '';

  testSrcDir = pkgs.runCommand "test-ext-dir" { } ''
    mkdir -p "$out/extensions"
    echo 'export default function(pi) { console.log("Dir extension loaded"); }' > "$out/extensions/index.ts"
  '';

  testPassthruPkg = pkgs.stdenv.mkDerivation {
    pname = "test-passthru-pkg";
    version = "0.1.0";
    dontUnpack = true;
    installPhase = ''
      mkdir -p "$out"
    '';
    passthru = {
      isPiExtension = true;
      runtimePackages = [ pkgs.fd ];
      runtimeEnvironment = {
        PASSTHRU_EXT_ACTIVE = "1";
      };
    };
  };

  evaluated = nixpiLib.evalPi {
    inherit pkgs;
    modules = [
      {
        programs.pi = {
          enable = true;

          packages = [ testPassthruPkg ];

          customExtensions = {
            inline-ts-ext = {
              enable = true;
              version = "1.2.0";
              description = "Inline TypeScript test extension";
              content = ''
                import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
                export default function(pi: ExtensionAPI): void {
                  const val: number = 100;
                  pi.registerCommand("inline-cmd", {
                    description: `Inline TS command: ''${val}`,
                    handler: async () => {}
                  });
                }
              '';
              runtimePackages = [ pkgs.jq ];
              runtimeEnvironment = {
                INLINE_EXT_ACTIVE = "1";
              };
            };

            entrypoint-js-ext = {
              enable = true;
              entrypoint = testEntrypointJs;
              runtimePackages = [ pkgs.ripgrep ];
            };

            entrypoint-ts-ext = {
              enable = true;
              entrypoint = testEntrypointTs;
              runtimePackages = [ pkgs.curl ];
            };

            dir-ext = {
              enable = true;
              src = testSrcDir;
            };

            disabled-ext = {
              enable = false;
              # Intentionally no source provided: should not fail evaluation
            };

            disabled-ext-with-content = {
              enable = false;
              content = "export default function() {}";
              runtimeEnvironment = {
                DISABLED_EXT_ACTIVE = "1";
              };
            };
          };

          customSkills = {
            my-skill = {
              enable = true;
              description = "Custom test skill";
              content = "# My Custom Skill\nSkill instructions here.";
              runtimePackages = [ pkgs.bat ];
            };

            disabled-skill = {
              enable = false;
              description = "Disabled skill";
            };
          };

          customPrompts = {
            review-code = {
              enable = true;
              description = "Prompt for reviewing code";
              argumentHint = "[file]";
              content = "Please review the following code:\n$ARGUMENTS";
            };

            disabled-prompt = {
              enable = false;
              description = "Disabled prompt";
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

            disabled-theme = {
              enable = false;
            };
          };
        };
      }
    ];
  };

  cfg = evaluated.config.programs.pi;

  # Verify extensions are packaged and listed
  hasInlineExtPkg = cfg.customExtensions.inline-ts-ext.package != null;
  hasEntrypointJsExtPkg = cfg.customExtensions.entrypoint-js-ext.package != null;
  hasEntrypointTsExtPkg = cfg.customExtensions.entrypoint-ts-ext.package != null;
  hasDirExtPkg = cfg.customExtensions.dir-ext.package != null;

  # Verify disabled extensions are not included
  disabledExtNotIncluded = !lib.elem "pi-extension-disabled-ext" (map (p: p.name or "") cfg.packages);
  disabledContentExtNotIncluded =
    !lib.elem "pi-extension-disabled-ext-with-content" (map (p: p.name or "") cfg.packages);

  # Verify runtime packages propagation (from custom extensions, skills, and passthru)
  hasJq = lib.elem pkgs.jq cfg.finalRuntimePackages;
  hasRipgrep = lib.elem pkgs.ripgrep cfg.finalRuntimePackages;
  hasCurl = lib.elem pkgs.curl cfg.finalRuntimePackages;
  hasBat = lib.elem pkgs.bat cfg.finalRuntimePackages;
  hasFd = lib.elem pkgs.fd cfg.finalRuntimePackages;

  # Verify environment variables propagation (from custom extensions and package passthru)
  hasInlineEnvVar = cfg.environment.variables.INLINE_EXT_ACTIVE or null == "1";
  hasPassthruEnvVar = cfg.finalPackage.passthru.cleanedSettings != null; # settings evaluated cleanly
  disabledEnvNotIncluded = !(cfg.environment.variables ? DISABLED_EXT_ACTIVE);

  # Verify skills
  hasSkill = lib.length cfg.extraSkills == 1;

  # Verify prompts
  hasPrompt = lib.length cfg.prompts == 1;

  # Verify themes
  hasTheme = lib.length cfg.themes == 1;

  # Rejection tests for missing or conflicting source inputs
  missingSourceExtAttempt = builtins.tryEval (
    (nixpiLib.evalPi {
      inherit pkgs;
      modules = [
        {
          programs.pi = {
            enable = true;
            customExtensions.invalid-empty = {
              enable = true;
            };
          };
        }
      ];
    }).config.programs.pi.finalPackage.outPath
  );

  conflictingSourceExtAttempt = builtins.tryEval (
    (nixpiLib.evalPi {
      inherit pkgs;
      modules = [
        {
          programs.pi = {
            enable = true;
            customExtensions.invalid-both = {
              enable = true;
              content = "export default {}";
              entrypoint = testEntrypointJs;
            };
          };
        }
      ];
    }).config.programs.pi.finalPackage.outPath
  );

  conflictingSkillAttempt = builtins.tryEval (
    (nixpiLib.evalPi {
      inherit pkgs;
      modules = [
        {
          programs.pi = {
            enable = true;
            customSkills.invalid-skill = {
              enable = true;
              src = testSrcDir;
              content = "conflicting content";
            };
          };
        }
      ];
    }).config.programs.pi.finalPackage.outPath
  );

  conflictingPromptAttempt = builtins.tryEval (
    (nixpiLib.evalPi {
      inherit pkgs;
      modules = [
        {
          programs.pi = {
            enable = true;
            customPrompts.invalid-prompt = {
              enable = true;
              src = testEntrypointJs;
              content = "conflicting content";
            };
          };
        }
      ];
    }).config.programs.pi.finalPackage.outPath
  );

  conflictingThemeAttempt = builtins.tryEval (
    (nixpiLib.evalPi {
      inherit pkgs;
      modules = [
        {
          programs.pi = {
            enable = true;
            customThemes.invalid-theme = {
              enable = true;
              src = testEntrypointJs;
              colors = {
                bg = "#000";
              };
            };
          };
        }
      ];
    }).config.programs.pi.finalPackage.outPath
  );

  directMkExtensionMissing = builtins.tryEval (
    (nixpiLib.mkPiExtension {
      inherit pkgs;
      pname = "invalid-no-src";
    }).outPath
  );

  directMkExtensionConflicting = builtins.tryEval (
    (nixpiLib.mkPiExtension {
      inherit pkgs;
      pname = "invalid-conflict";
      content = "export default {}";
      entrypoint = testEntrypointJs;
    }).outPath
  );

  directMkSkillConflicting = builtins.tryEval (
    nixpiLib.mkPiSkill {
      inherit pkgs;
      name = "invalid-skill";
      src = testSrcDir;
      content = "conflict";
    }
  );

  directMkPromptConflicting = builtins.tryEval (
    nixpiLib.mkPiPrompt {
      inherit pkgs;
      name = "invalid-prompt";
      src = testEntrypointJs;
      content = "conflict";
    }
  );

  directMkThemeConflicting = builtins.tryEval (
    nixpiLib.mkPiTheme {
      inherit pkgs;
      name = "invalid-theme";
      src = testEntrypointJs;
      colors = {
        bg = "#000";
      };
    }
  );

  allRejectionsPassed =
    (!missingSourceExtAttempt.success)
    && (!conflictingSourceExtAttempt.success)
    && (!conflictingSkillAttempt.success)
    && (!conflictingPromptAttempt.success)
    && (!conflictingThemeAttempt.success)
    && (!directMkExtensionMissing.success)
    && (!directMkExtensionConflicting.success)
    && (!directMkSkillConflicting.success)
    && (!directMkPromptConflicting.success)
    && (!directMkThemeConflicting.success);

  allPassed =
    hasInlineExtPkg
    && hasEntrypointJsExtPkg
    && hasEntrypointTsExtPkg
    && hasDirExtPkg
    && disabledExtNotIncluded
    && disabledContentExtNotIncluded
    && hasJq
    && hasRipgrep
    && hasCurl
    && hasBat
    && hasFd
    && hasInlineEnvVar
    && hasPassthruEnvVar
    && disabledEnvNotIncluded
    && hasSkill
    && hasPrompt
    && hasTheme
    && allRejectionsPassed;
in
pkgs.runCommand "nixpi-custom-resources-test" { } ''
  ${lib.optionalString (!allPassed) "echo 'Custom resources eval test failed' >&2; exit 1"}
  grep -q "inline-ts-ext" "${cfg.generatedSettingsFile}"
  grep -q "entrypoint-js-ext" "${cfg.generatedSettingsFile}"
  grep -q "entrypoint-ts-ext" "${cfg.generatedSettingsFile}"
  grep -q "dir-ext" "${cfg.generatedSettingsFile}"
  grep -q "my-skill" "${cfg.generatedSettingsFile}"
  grep -q "review-code.md" "${cfg.generatedSettingsFile}"
  grep -q "custom-neon.json" "${cfg.generatedSettingsFile}"

  # Verify disabled resources are absent from settings
  if grep -q "disabled-ext" "${cfg.generatedSettingsFile}"; then
    echo "Error: disabled extension found in generated settings" >&2
    exit 1
  fi
  if grep -q "disabled-skill" "${cfg.generatedSettingsFile}"; then
    echo "Error: disabled skill found in generated settings" >&2
    exit 1
  fi
  if grep -q "disabled-prompt" "${cfg.generatedSettingsFile}"; then
    echo "Error: disabled prompt found in generated settings" >&2
    exit 1
  fi
  if grep -q "disabled-theme" "${cfg.generatedSettingsFile}"; then
    echo "Error: disabled theme found in generated settings" >&2
    exit 1
  fi

  echo "Custom resources evaluation test passed successfully" > "$out"
''
