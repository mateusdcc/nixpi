{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "literature-deep-dive";
  description = "Deep-dive methodology for reading, analyzing, and synthesizing papers, documentation, and technical literature.";
  content = ''
    # Literature & Technical Paper Deep-Dive Protocol

    ## Objective
    Perform rigorous, critical analysis of research papers, RFCs, technical documentation, and complex architecture guides.

    ## 3-Pass Reading Technique
    1. **Pass 1 (Bird's Eye)**: Read title, abstract, section headings, and conclusion. Identify what category of problem this solves.
    2. **Pass 2 (Mechanisms & Arguments)**: Inspect key figures, diagrams, and proof/evidence steps. Highlight unverified claims or implicit assumptions.
    3. **Pass 3 (Synthesis & Critique)**:
       - What trade-offs were made?
       - What are the operational failure modes?
       - How does this relate to existing systems in our vault?
    4. **Generate Obsidian Literature Note**:
       - Capture full bibliographic metadata.
       - Synthesize core contributions and extract actionable insights.
  '';
}
