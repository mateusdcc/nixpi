# Example of how a third-party extension can be packaged and configured with nixpi
{ pkgs, nixpiLib }:

let
  # 1. Package the extension derivation
  myExtensionPackage = nixpiLib.mkPiExtension {
    pname = "git-summary";
    version = "1.0.0";
    runtimePackages = [
      pkgs.git
      pkgs.jq
    ];

    src = pkgs.writeTextDir "extensions/index.js" ''
      import { execSync } from "node:child_process";

      export default function(pi) {
        if (pi && pi.registerCommand) {
          pi.registerCommand("git-summary", {
            description: "Show quick summary of git status",
            handler: async (args, ctx) => {
              const status = execSync("git status -s", { encoding: "utf-8" });
              console.log("Git status:\n" + status);
            }
          });
        }
      }
    '';
  };

  # 2. Define the Nix module for the extension
  myExtensionModule =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.programs.pi.extensions.git-summary;
    in
    {
      options.programs.pi.extensions.git-summary = {
        enable = lib.mkEnableOption "Git summary Pi extension";
        package = lib.mkOption {
          type = lib.types.package;
          default = myExtensionPackage;
        };
      };

      config = lib.mkIf cfg.enable {
        programs.pi.runtimePackages = [
          pkgs.git
          pkgs.jq
        ];
      };
    };
in
# 3. Create a configured Pi utilizing this custom module
nixpiLib.makePi {
  inherit pkgs;
  modules = [
    myExtensionModule
    {
      programs.pi = {
        enable = true;
        extensions.git-summary.enable = true;
      };
    }
  ];
}
