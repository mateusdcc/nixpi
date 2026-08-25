{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "gifted-diagnostic-probe";
  description = "3-Tier (Easy/Medium/Hard) interactive Obsidian modal diagnostic probing to map prerequisite knowledge and profound reasoning.";
  content = ''
    # Gifted-Level Diagnostic Probing Protocol

    ## Objective
    When the user requests to learn a topic, calibrate prerequisite knowledge, mental models, and profound intersubject reasoning BEFORE writing any notes or explanations.

    ## Critical Directives
    1. **ALWAYS Trigger Obsidian Modal via Bridge**:
       - When the user asks to learn a topic, IMMEDIATELY call the `obsidian_prompt_modal` tool.
       - This opens an interactive popup modal directly in the user's Obsidian window.
       - NEVER dump roadmaps, introductions, or generic explanations into terminal text.
       - NEVER use emojis in terminal output or note content.
    2. **Scan the Vault First**:
       - Run `obsidian_all_links` or file searches to check what related notes and mental models exist in the vault.
    3. **Construct the 3-Tier Diagnostic Questions**:
       Structure the payload for `obsidian_prompt_modal`:
       - **Tier 1: Easy (Foundational Axioms)**:
         - Rapid verification of baseline definitions, primitives, and deterministic syntax.
         - Format: Choice or concise definition check.
       - **Tier 2: Medium (Application & Mechanics)**:
         - Concrete scenario testing: how the system transitions states under specific operational parameters.
         - Format: Scenario analysis.
       - **Tier 3: Hard (Profound Synthesis & Intersubject Reasoning)**:
         - Tailored for high-cognitive-bandwidth / gifted learners.
         - Tests cross-disciplinary isomorphisms (e.g. distributed consensus <-> physical clock relativity, memory ordering <-> causal consistency graphs).
         - Explores extreme boundary conditions, non-obvious failure modes, and invariant degradation under Byzantine faults.
    4. **Transition to Note Generation**:
       - Upon receiving the modal answers from `obsidian_prompt_modal`, calibrate the user's level immediately.
       - Proceed to author paginated atomic notes directly into the Obsidian vault following the `paginated-atomic-notes` protocol.
       - DO NOT output the lesson in terminal chat. Write the `.md` note file and open it in Obsidian using `obsidian_open_note`.
  '';
}
