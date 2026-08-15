{
  pkgs,
  mkPiExtension,
  ripgrep ? pkgs.ripgrep,
}:

mkPiExtension {
  pname = "ripgrep-search";
  version = "0.1.0";
  runtimePackages = [ ripgrep ];

  src = pkgs.writeTextDir "extensions/index.js" ''
    import { execSync } from "node:child_process";

    export default function(pi) {
      if (pi && pi.registerTool) {
        pi.registerTool({
          name: "rg_search",
          label: "Ripgrep Search",
          description: "Search file contents using ripgrep",
          parameters: {
            type: "object",
            properties: {
              pattern: { type: "string", description: "Regex pattern to search" }
            },
            required: ["pattern"]
          },
          async execute(id, params) {
            try {
              const output = execSync(`rg -n "''${params.pattern}" .`, { encoding: "utf-8" });
              return { content: [{ type: "text", text: output }] };
            } catch (err) {
              return { content: [{ type: "text", text: err.message }] };
            }
          }
        });
      }
    }
  '';
}
