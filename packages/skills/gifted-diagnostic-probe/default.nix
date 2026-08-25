{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "gifted-diagnostic-probe";
  description = "3-Tier (Easy/Medium/Hard) conversational diagnostic probing to map prerequisite knowledge and profound reasoning before teaching.";
  content = ''
    # Gifted-Level Diagnostic Probing Protocol

    ## Objective
    When the user requests to learn a topic, calibrate their exact prerequisite knowledge, mental models, and deep reasoning capabilities BEFORE writing any notes or explanations.

    ## Critical Invariant
    **DIAGNOSTIC PROBING QUESTIONS MUST REMAIN IN CHAT ONLY.**
    - NEVER write initial diagnostic probing questions into Obsidian vault note files.
    - Diagnostic probing is an interactive, real-time conversational calibration tool.

    ## Step 1: Vault Reconnaissance
    1. Scan the user's Obsidian vault (using `obsidian_all_links`, `obsidian_note_links`, or fast `ripgrep-search`).
    2. Identify existing notes, mental models, related domains, and potential prerequisite concepts already present in the vault graph.
    3. Formulate the prerequisite dependency graph for the target topic.

    ## Step 2: 3-Tier Conversational Calibration Sequence
    Present a focused, numbered sequence of probing questions in chat:

    ### Tier 1: Easy (Foundational Recall)
    - **Goal**: Rapidly verify factual baseline, axioms, definitions, and core terminology.
    - **Format**: Concise direct questions or multiple-choice questions testing foundational syntax/mechanics.
    - **Example**: "What is the primary difference between synchronous and asynchronous consensus in distributed systems?"

    ### Tier 2: Medium (Application & Mechanics)
    - **Goal**: Test deterministic application of concepts to concrete systems or problem scenarios.
    - **Format**: Given scenario X with parameters Y, what state transition occurs and why?
    - **Example**: "If a Raft leader partitions away from the majority during log replication, what happens when a client sends a write request?"

    ### Tier 3: Hard (Profound Multi-Hop & Intersubject Synthesis)
    - **Goal**: Designed for gifted individuals with high cognitive bandwidth. Tests profound, non-obvious connections, structural isomorphisms across disparate fields, edge-case failure modes, and invariant preservation under extreme constraints.
    - **Format**: Open-ended, challenging problems requiring cross-disciplinary intuition (e.g. mapping compiler optimization to category theory, or memory ordering to distributed vector clocks).
    - **Example**: "How does the CAP theorem's consistency-latency tradeoff structurally mirror the Heisenberg uncertainty principle or the Rice theorem in computability? Where does the analogy break down at the boundary of physical clock drift?"

    ## Step 3: Fast Calibration & Transition to Teaching
    1. Analyze the user's responses to immediately calibrate their level.
    2. Skip trivial explanations if Easy and Medium are mastered; accelerate directly to advanced insights and profound intersubject connections.
    3. Proceed to generate paginated atomic notes in the Obsidian vault following the `paginated-atomic-notes` skill.
  '';
}
