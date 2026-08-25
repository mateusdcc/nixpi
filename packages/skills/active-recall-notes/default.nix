{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "active-recall-notes";
  description = "Synthesizes concepts into atomic Obsidian markdown notes with wikilinks, tags, callouts, and Q&A flashcards.";
  content = ''
    # Active Recall & Obsidian Note Synthesis Protocol

    ## Objective
    Transform transient learning discussions into high-retention, atomic markdown notes stored directly in the Obsidian vault.

    ## Note Structure Requirements
    - **YAML Frontmatter**: Include `tags: [concept, learning, <domain>]`, `created: YYYY-MM-DD`, and `status: draft | permanent`.
    - **Atomic Summary**: 1-2 sentence core definition at the top.
    - **Mental Model & Mechanics**: Core principles, diagrams (Mermaid when applicable), and examples.
    - **Obsidian Wikilinks**: Connect to existing or parent notes using `[[Topic]]` and `[[Parent MOC]]`.
    - **Callouts**: Use `> [!NOTE]`, `> [!TIP]`, `> [!WARNING]` for distinctions and gotchas.
    - **Active Recall Q&A / Flashcards**:
      Append a `# Flashcards` section using standard spaced-repetition Q&A format:
      ```markdown
      Q: What is the primary purpose of X?
      A: X ensures Y by doing Z.
      ```
  '';
}
