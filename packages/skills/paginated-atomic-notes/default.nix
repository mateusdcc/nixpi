{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "paginated-atomic-notes";
  description = "Architecture for protected Concept Lab interactive teaching environments and post-mastery permanent atomic note synthesis.";
  content = ''
    # Concept Lab & Permanent Atomic Note Protocol

    ## Architectural Rule
    **Atomic notes are a storage format. They are NOT the primary teaching format.**
    Teaching occurs inside an immersive **Concept Lab**. Only after demonstrated mastery at the mastery gate does Pi synthesize the compressed **Permanent Atomic Note**.

    ---

    ## Part A: Concept Lab Template (Teaching Surface with Protected Sections)

    File path: `notes/<topic-id>-concept-lab.md`
    Zero emojis anywhere.

    ```markdown
    ---
    type: concept-lab
    topic_id: <topic-id>
    concept_id: <concept-id>
    status: learning
    depth: immersive
    created: YYYY-MM-DD
    prerequisites: [...]
    objectives: [...]
    ---

    # Concept Lab: <Concept Title>

    <!-- PI:SECTION capability-target CORE-START -->
    ## 1. Capability Target
    <!-- State what the learner will be able to explain, predict, distinguish, construct, diagnose, or solve after the lab. -->
    <!-- PI:SECTION capability-target CORE-END -->
    <!-- PI:SECTION capability-target ADDITIONS-START -->
    <!-- PI:SECTION capability-target ADDITIONS-END -->

    <!-- PI:SECTION problem-context CORE-START -->
    ## 2. The Problem Before the Terminology
    <!-- Introduce a concrete situation in which the concept becomes necessary. Ask prediction before revealing the formal model. -->

    ```pi-quiz
    question_id: <concept_id>_pred_01
    concept_id: <concept_id>
    objective_id: obj_problem_context
    question_family: prediction
    question: "Before reading further: in the scenario above, what failure will occur if no synchronization mechanism exists?"
    answer_mode: text
    ```
    <!-- PI:SECTION problem-context CORE-END -->
    <!-- PI:SECTION problem-context ADDITIONS-START -->
    <!-- PI:SECTION problem-context ADDITIONS-END -->

    ---

    <!-- PI:SECTION intuitive-causal-model CORE-START -->
    ## 3. Intuitive Causal Model
    <!-- Explain the mechanism in plain language without sacrificing intermediate causal steps. -->

    ```pi-action
    section: "3. Intuitive Causal Model"
    label: "Ask Pi About Causal Steps"
    context: "Clarify intermediate causal transitions in the intuitive model."
    ```
    <!-- PI:SECTION intuitive-causal-model CORE-END -->
    <!-- PI:SECTION intuitive-causal-model ADDITIONS-START -->
    <!-- PI:SECTION intuitive-causal-model ADDITIONS-END -->

    ---

    <!-- PI:SECTION formal-core CORE-START -->
    ## 4. Formal Core
    - **Precise Definition**: Formal mathematical or operational specification.
    - **Components & Variables**: State variables, message types, constraints.
    - **Core Invariant / Rule**: Invariant that must hold across all valid state transitions.
    - **Assumptions & Scope**: Required environment properties.
    - **Non-Claims**: What the concept explicitly does not guarantee.
    <!-- PI:SECTION formal-core CORE-END -->
    <!-- PI:SECTION formal-core ADDITIONS-START -->
    <!-- PI:SECTION formal-core ADDITIONS-END -->

    ---

    <!-- PI:SECTION representation-ladder CORE-START -->
    ## 5. Representation Ladder
    Explicitly map between:
    1. Concrete scenario
    2. Step-by-step causal trace
    3. Diagram or comparative table (when purpose justifies it)
    4. Formal statement / pseudocode / state machine
    5. Compressed verbal rule
    <!-- PI:SECTION representation-ladder CORE-END -->
    <!-- PI:SECTION representation-ladder ADDITIONS-START -->
    <!-- PI:SECTION representation-ladder ADDITIONS-END -->

    ---

    <!-- PI:SECTION example-lattice CORE-START -->
    ## 6. Mandatory Example Lattice
    Provide at least these 8 distinct example families:
    1. **Minimal Example**: Smallest case where the concept is visible.
    2. **Canonical Worked Example**: Standard full walkthrough of every step.
    3. **Concrete Practical Example**: Real-world system, calculation, or implementation.
    4. **Matched Nonexample / Near-Miss**: Superficially similar, missing one decisive property.
    5. **Boundary / Degenerate Case**: Behavior at the edge of definitions or zero/infinite limits.
    6. **Changed-Assumption Counterfactual**: Modify one assumption and trace consequences.
    7. **Failure / Adversarial Example**: How the mechanism is broken, misapplied, or attacked.
    8. **Transfer Example**: Same underlying invariant in an unfamiliar domain.
    <!-- PI:SECTION example-lattice CORE-END -->
    <!-- PI:SECTION example-lattice ADDITIONS-START -->
    <!-- PI:SECTION example-lattice ADDITIONS-END -->

    ---

    <!-- PI:SECTION negation-boundary CORE-START -->
    ## 7. Negation, Contradiction, & Boundary Lab
    Analyze what happens if the core invariant or assumption is negated:
    - Formal invariant: Negate claim, trace state transitions, derive impossibility / countermodel.
    - Mechanism: Remove one component, observe failure signature.
    - Definition: Inspect exact inclusion/exclusion boundary.
    - Empirical / Design claim: Analyze trade-off reversal (never fabricate fake mathematical contradictions for design choices).
    <!-- PI:SECTION negation-boundary CORE-END -->
    <!-- PI:SECTION negation-boundary ADDITIONS-START -->
    <!-- PI:SECTION negation-boundary ADDITIONS-END -->

    ---

    <!-- PI:SECTION common-misconceptions CORE-START -->
    ## 8. Common Misconceptions
    For each known misconception:
    - Tempting wrong belief & why it feels plausible.
    - Smallest concrete case that exposes it.
    - Correct replacement model.
    - One diagnostic check.
    <!-- PI:SECTION common-misconceptions CORE-END -->
    <!-- PI:SECTION common-misconceptions ADDITIONS-START -->
    <!-- PI:SECTION common-misconceptions ADDITIONS-END -->

    ---

    <!-- PI:SECTION guided-practice CORE-START -->
    ## 9. Guided Practice with Fading Support
    1. Fully worked example.
    2. Partially worked example with completion prompts.
    3. Unworked analogous problem.
    4. Changed-context transfer problem.
    <!-- PI:SECTION guided-practice CORE-END -->
    <!-- PI:SECTION guided-practice ADDITIONS-START -->
    <!-- PI:SECTION guided-practice ADDITIONS-END -->

    ---

    <!-- PI:SECTION interleaved-probes CORE-START -->
    ## 10. Interleaved Diagnostic & Transfer Probes
    ```pi-quiz
    question_id: <concept_id>_transfer_01
    concept_id: <concept_id>
    objective_id: obj_transfer
    question_family: transfer
    question: "Apply this core invariant to an asynchronous network with variable packet delay. How is consistency maintained?"
    answer_mode: text
    ```
    <!-- PI:SECTION interleaved-probes CORE-END -->
    <!-- PI:SECTION interleaved-probes ADDITIONS-START -->
    <!-- PI:SECTION interleaved-probes ADDITIONS-END -->

    ---

    <!-- PI:SECTION learner-compression CORE-START -->
    ## 11. Learner Compression
    Prompts for the learner:
    - 1-sentence compression.
    - 5-sentence rigorous explanation.
    - Diagram / causal trace from memory.
    - 1 original example & 1 original nonexample.
    - Decisive boundary assumption.
    <!-- PI:SECTION learner-compression CORE-END -->
    <!-- PI:SECTION learner-compression ADDITIONS-START -->
    <!-- PI:SECTION learner-compression ADDITIONS-END -->

    ---

    <!-- PI:SECTION mastery-gate CORE-START -->
    ## 12. Mastery Evidence & Gate
    Tracks objective-level status:
    - `0: unprobed`, `1: recognized`, `2: explained`, `3: applied`, `4: transferred`, `5: critiqued/constructed`.
    - Mastery gate threshold: Core objectives >= 3 (applied), >= 1 objective at 4 (transferred), 0 unresolved critical misconceptions.
    <!-- PI:SECTION mastery-gate CORE-END -->
    <!-- PI:SECTION mastery-gate ADDITIONS-START -->
    <!-- PI:SECTION mastery-gate ADDITIONS-END -->

    ---

    <!-- PI:SECTION next-review CORE-START -->
    ## 13. Next Review & Semantic Successors
    - Review metadata: schedule [0d, 1d, 3d, 7d, 21d].
    - Semantic links: `requires: [[...]]`, `contrasts-with: [[...]]`, `generalizes: [[...]]`, `instantiates: [[...]]`, `fails-when: [[...]]`.
    <!-- PI:SECTION next-review CORE-END -->
    <!-- PI:SECTION next-review ADDITIONS-START -->
    <!-- PI:SECTION next-review ADDITIONS-END -->
    ```

    ---

    ## Part B: Post-Mastery Permanent Atomic Note Template (Storage Surface)

    File path: `notes/<topic-id>-<concept-id>-atomic.md`
    Generated ONLY after the mastery gate is passed.

    ```markdown
    ---
    type: permanent-atomic-note
    concept_id: <concept-id>
    topic_id: <topic-id>
    status: permanent
    mastered_date: YYYY-MM-DD
    prerequisites: [...]
    successors: [...]
    ---

    # [[<Predecessor>]] <- **<Concept Title>** -> [[<Successor>]]

    ## 1. Precise Definition & Core Invariant
    <!-- Concise, high-precision definition and governing invariant -->

    ## 2. Core Mechanism
    <!-- Essential causal steps and formal constraints -->

    ## 3. Assumptions & Scope
    <!-- Operational assumptions and non-claims -->

    ## 4. Canonical Example vs. Decisive Nonexample
    - **Canonical Example**: <Minimal, illustrative case>
    - **Decisive Nonexample**: <Matched near-miss exposing the boundary>

    ## 5. Failure Boundary & Degenerate Limits
    <!-- Conditions where the invariant breaks or degrades -->

    ## 6. Active Recall Retrieval Prompts
    <!-- High-yield generation and discrimination prompts for spaced review -->
    - Q1: <Causal prediction prompt>
    - Q2: <Changed-assumption counterfactual prompt>
    - Q3: <Transfer discrimination prompt>

    ## 7. Semantic Graph Connections
    - Requires: [[...]]
    - Contrasts with: [[...]]
    - Generalizes: [[...]]
    - Fails when: [[...]]
    ```
  '';
}
