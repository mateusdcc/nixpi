{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.pi.skills.commit-style;
  defaultCommitStylePkg = pkgs.callPackage ../../packages/skills/commit-style {
    mkPiSkill = (pkgs.callPackage ../../lib/mk-resource.nix { }).mkPiSkill;
    inherit (cfg)
      types
      scopes
      examples
      customGuidelines
      ;
  };
in
{
  options.programs.pi.skills.commit-style = {
    enable = lib.mkEnableOption "Pi commit-style skill (Conventional Commits v1.0.0)";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultCommitStylePkg;
      defaultText = lib.literalExpression "pkgs.piSkills.commit-style";
      description = "Package providing the commit-style skill.";
    };

    types = lib.mkOption {
      type = lib.types.listOf (
        lib.types.oneOf [
          lib.types.str
          (lib.types.submodule {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                description = "Commit type name.";
              };
              description = lib.mkOption {
                type = lib.types.str;
                description = "Description of the commit type.";
              };
            };
          })
        ]
      );
      default = [
        {
          name = "feat";
          description = "A new feature for the user or library (correlates with SemVer MINOR)";
        }
        {
          name = "fix";
          description = "A bug fix for the user or library (correlates with SemVer PATCH)";
        }
        {
          name = "docs";
          description = "Documentation changes only";
        }
        {
          name = "style";
          description = "Code style/formatting changes that do not affect code logic or semantics";
        }
        {
          name = "refactor";
          description = "Refactoring production code (neither fixes a bug nor adds a feature)";
        }
        {
          name = "perf";
          description = "A code change that improves performance";
        }
        {
          name = "test";
          description = "Adding missing tests, refactoring tests, or correcting test fixtures";
        }
        {
          name = "build";
          description = "Changes that affect the build system or external dependencies (e.g. Nix, npm, Cargo)";
        }
        {
          name = "ci";
          description = "Changes to CI/CD configuration files, scripts, and workflows (e.g. GitHub Actions)";
        }
        {
          name = "chore";
          description = "Routine maintenance tasks, tool configs, or auxiliary changes";
        }
        {
          name = "revert";
          description = "Reverts a previous commit";
        }
      ];
      description = "List of allowed commit types with descriptions.";
    };

    scopes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of recommended or repository-specific scopes.";
    };

    examples = lib.mkOption {
      type = lib.types.listOf (
        lib.types.oneOf [
          lib.types.str
          (lib.types.submodule {
            options = {
              title = lib.mkOption {
                type = lib.types.str;
                description = "Example title.";
              };
              content = lib.mkOption {
                type = lib.types.str;
                description = "Example commit message content.";
              };
            };
          })
        ]
      );
      default = [ ];
      description = "Additional repository-specific commit examples.";
    };

    customGuidelines = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional guidelines or rules for writing commit messages.";
    };
  };
}
