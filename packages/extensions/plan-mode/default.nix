{ pkgs, mkPiExtension }:

mkPiExtension {
  pname = "plan-mode";
  version = "0.1.0";
  src = pkgs.writeTextDir "extensions/index.js" ''
    export default function(pi) {
      if (pi && pi.registerCommand) {
        pi.registerCommand("plan", {
          description: "Execute task planning",
          handler: async (args, ctx) => {
            console.log("nixpi plan-mode active");
          }
        });
      }
    }
  '';
}
