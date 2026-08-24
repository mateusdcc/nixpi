import { registerObsidianTools } from "./tools.js";
import { registerObsidianCommands } from "./commands.js";
import { injectVaultInstructions } from "./instructions.js";

export default function(pi) {
  injectVaultInstructions(pi);
  registerObsidianTools(pi);
  registerObsidianCommands(pi);
}
