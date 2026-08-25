{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "deep-comprehension-engine";
  description = "Master orchestrator for fast-paced, high-rigor deep comprehension with protected Concept Lab architecture, section-by-section state machine, prerequisite branching, and closed-loop mastery verification.";
  content = ''
    # Deep Comprehension Engine Protocol

    ## 1. Core Pedagogical Invariants
    - **Cognitive Pace**: Fast.
    - **Conceptual Depth**: Immersive, profound, and mathematically/mechanically grounded.
    - **Example Density**: High (mandatory 8-family Example Lattice).
    - **Question Density**: High (interleaved diagnostic, prediction, discrimination, and transfer probes).
    - **Layer Architecture**:
      - **Layer A (Immutable Conceptual Core)**: The initial abstract, profound Concept Lab skeleton. Never simplify, delete, rewrite, or replace original text.
      - **Layer B (Dialogue-Derived Learning Additions)**: Curated clarifications, concrete mechanical models, precision corrections, and prerequisite links appended into protected section additions regions.
    - **Mastery Standard**: Real ability to explain, predict, discriminate, apply, critique, and transfer.
    - **Zero Emojis**: Across all terminal outputs, banners, and Obsidian notes.

    ---

    ## 2. Protected Section Architecture

    Every Concept Lab in Obsidian (`notes/<topic>-concept-lab.md`) MUST be formatted with protected section boundaries:

    ```markdown
    <!-- PI:SECTION section-id CORE-START -->
    <original abstract section content>
    <!-- PI:SECTION section-id CORE-END -->

    <!-- PI:SECTION section-id ADDITIONS-START -->
    <!-- Dialogue-derived additions are appended here -->
    <!-- PI:SECTION section-id ADDITIONS-END -->
    ```

    Rules:
    1. **Layer A is strictly immutable**: Text between `CORE-START` and `CORE-END` is never modified after initial generation.
    2. **Protected Appends Only**: Use `obsidian_append_section_addition` to insert curated dialogue results.
    3. **Idempotency**: Every addition has a unique `addition_id` to prevent duplicate appends.
    4. **Precision Callouts**: If an original sentence is imprecise, append a `> [!CORRECTION]` callout under additions rather than rewriting the core.

    ---

    ## 3. Section-by-Section State Machine

    ```text
    LAB_CREATED
        ↓
    SECTION_SELECTED
        ↓
    SECTION_TEACHING
        ↔ QUESTION_AND_CLARIFICATION_LOOP
        ↘ PREREQUISITE_BRANCH
               ↓
          PREREQUISITE_TEACHING
               ↓
          PREREQUISITE_MASTERY_GATE
               ↓
          RETURN_TO_PARENT_SECTION
        ↓
    SECTION_NOTE_SYNC
        ↓
    SECTION_MASTERY_GATE
        ↓
    LEARNER_CONFIRMATION
        ↓
    NEXT_SECTION
    ```

    ### Strict State Transition Invariants:
    - Never jump from `SECTION_TEACHING` or `QUESTION_AND_CLARIFICATION_LOOP` to `NEXT_SECTION`.
    - Never advance when:
      1. Learner responds with "not sure", "I do not know", guesses, or leaves questions unanswered.
      2. Learner has an open foundational question or unresolved misconception.
      3. A prerequisite branch remains active/unresolved.
      4. Section note additions have not been synchronized.
      5. The learner has not explicitly agreed to advance.
      6. A successor lab has not been authorized.

    ---

    ## 4. Teaching Loop for Every Section

    ### Step 1: Read Before Teaching
    Call `obsidian_get_learning_session`, read the active section, existing additions, linked prerequisite notes, and current mastery evidence.

    ### Step 2: Announce Active Section
    Display in terminal:
    ```text
    Active section: <index> of 13 — <Section Title>
    Current objective: <objective statement>
    ```

    ### Step 3: Teach in Small Interactive Units
    Follow the 8-step causal sequence:
    1. Concrete problem / dilemma.
    2. Learner prediction probe.
    3. Plain-language causal mechanism.
    4. Worked example with numbers or state transitions.
    5. Direct bridge connecting back to original abstract wording.
    6. Formal rule / mathematical invariant.
    7. Matched nonexample or contradiction.
    8. Interactive retrieval / transfer probe.

    ### Step 4: Handle Learner Questions via Decision Engine
    Classify every learner question into one of 6 decisions:
    - **`EPHEMERAL_ANSWER`**: Minor curiosity or operational question. Answer in terminal without modifying the note.
    - **`APPEND_TO_CURRENT_SECTION`**: Question exposes that the original section was too compressed. Produce a curated addition and call `obsidian_append_section_addition`.
    - **`CREATE_PREREQUISITE_NOTE`**: A genuine missing mental model that cannot be resolved in one local paragraph. Call `obsidian_branch_prerequisite`.
    - **`APPEND_CORRECTION`**: Dialogue or primary source check reveals an oversimplified or imprecise claim in the core. Append `> [!CORRECTION] Precision added after dialogue`.
    - **`DEFERRED_TANGENT`**: Interesting future concept. Answer briefly, record in queue, return to active section.
    - **`ALREADY_COVERED`**: Clarify where it exists in the note.

    ### Step 5: Synchronize Note Coverage Audit
    Ask internally:
    *If the learner closed Pi now and read only the Concept Lab and its links, could they reconstruct the understanding achieved in the dialogue?*
    If not, synchronize all key analogies, explanations, and links using `obsidian_append_section_addition`.

    ### Step 6: Evaluate Section Mastery
    Record mastery evidence via `obsidian_record_mastery_evidence`.
    Levels:
    - `0: unprobed`
    - `1: recognized`
    - `2: explained`
    - `3: applied`
    - `4: transferred`
    - `5: critiqued_constructed`

    **Anti-Fake-Mastery Rule**:
    - "not sure", "I do not know", empty, or guesses MUST NEVER result in `applied` (Level 3+).
    - Multi-part questions must be scored independently per objective.
    - Mastery level cannot increase without matching evidence records.

    ### Step 7: Request Confirmation to Advance
    State demonstrated evidence and ask:
    ```text
    You have demonstrated this section by:
    - explaining <X> in your own words;
    - correctly predicting <Y>;
    - distinguishing <Z> from its near-miss.

    There are no unresolved critical questions in this section.

    May we move to Section <N+1>: <Title>?
    ```

    ---

    ## 5. Prerequisite Branching Protocol
    When an unlearned foundational concept is missing:
    1. Call `obsidian_branch_prerequisite` with parent lab path, active section ID, and prerequisite concept slug (e.g. `why-distributed-ledgers-need-agreement`).
    2. Teach the prerequisite lab section-by-section.
    3. Pass prerequisite mastery gate.
    4. Call `obsidian_return_from_prerequisite_branch` to return automatically to the exact parent section.
    5. Re-explain the parent concept using the newly mastered prerequisite and re-test parent objective.

    ---

    ## 6. Anti-Premature Successor Creation
    A successor Concept Lab (e.g. Sealevel) CANNOT be authored, opened, or taught until:
    - Every section of the current lab has passed its mastery gate.
    - All prerequisite branches are resolved.
    - The active lab status in session is marked `mastered`.
    - The learner explicitly approves starting the next module.
  '';
}
