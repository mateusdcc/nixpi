import { registerObsidianTools } from "./tools.js";
import { registerObsidianCommands } from "./commands.js";

export default function(pi) {
  registerObsidianTools(pi);
  registerObsidianCommands(pi);
}
