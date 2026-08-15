{ pkgs, mkPiExtension }:

mkPiExtension {
  pname = "echo";
  version = "0.1.0";
  src = pkgs.writeTextDir "extensions/index.js" ''
    export default function(pi) {
      if (pi && pi.registerCommand) {
        pi.registerCommand("echo-hello", {
          description: "Say hello from nixpi echo extension",
          handler: async (args, ctx) => {
            console.log("nixpi echo extension active: " + (args || ""));
          }
        });
      }
    }
  '';
}
