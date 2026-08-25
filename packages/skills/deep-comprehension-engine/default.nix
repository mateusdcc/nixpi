{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "deep-comprehension-engine";
  description = "Canonical orchestrator for fast-paced, high-rigor, example-rich, adaptively scaffolded deep comprehension and Concept Lab authoring.";
  content = ''
    # Deep Comprehension Engine Protocol

    ## Fundamental Objective
    The learning environment is built for a cognitively fast learner who wants unusually deep, durable comprehension.

    Core Invariants:
    - Cognitive pace: fast.
    - Conceptual depth: immersive.
    - Example density: high (mandatory 8-family Example Lattice).
    - Question density: high (12-16 interleaved questions per concept).
    - Formal rigor: high when appropriate (no jargon inflation).
    - Scaffolding: adaptive rather than automatically minimal.
    - Abstraction order: concrete -> causal -> visual -> formal -> adversarial -> transfer.
    - Mastery standard: explain, predict, discriminate, apply, critique, and transfer.

    Prohibitions:
    - Never skip intermediate causal steps.
    - Never replace examples with empty abstractions.
    - Never introduce decorative cross-domain analogies before the primary mechanism is understood.
    - Never ask only difficult essay questions; use diverse question families.
    - Never use jargon density as a proxy for rigor.
    - Never mark a concept as learned after one correct answer.
    - Never dump large amounts of information without interleaved interaction.
    - Zero emojis across all terminal outputs, banners, and notes.

    ---

    ## Teaching vs. Storage Separation
    - **Concept Lab** (`type: concept-lab`): The interactive teaching, practicing, and diagnostic environment in Obsidian. Contains all 13 structured sections, the 8-family Example Lattice, negation labs, and interleaved `pi-quiz` and `pi-action` blocks.
    - **Permanent Atomic Note** (`type: permanent-atomic-note`): Compressed reference note generated ONLY after the learner passes the objective-level mastery gate.

    ---

    ## 8-Phase Deep-Comprehension Workflow

    ### Phase 1: Define the Learning Contract
    Determine:
    - Topic and intended capability.
    - Desired depth and available time.
    - Relevant prior knowledge.
    - Target mastery standard (default: transfer).
    Default profile:
    `pace: fast, depth: immersive, example_density: high, question_density: high, formalism: adaptive, interaction: frequent, mastery_required: transfer`

    ### Phase 2: Retrieve Relevant Prior Knowledge
    Targeted search across the vault:
    1. Search titles, aliases, tags, and contents for the topic and prerequisites.
    2. Read the most relevant notes and inspect their local link neighborhoods.
    3. Identify likely prerequisites, prior misconceptions, and known terminology.

    ### Phase 3: Multidimensional Diagnostic Probe
    Open interactive Obsidian modal via `obsidian_prompt_modal`.
    Probe across multidimensional axes:
    1. Definition in learner's own words.
    2. Causal model & prediction.
    3. Example vs. nonexample discrimination.
    4. Error or misconception detection.
    5. Changed-assumption prediction.
    6. Transfer to a nearby context.
    7. Confidence calibration (allow "I do not know").

    Generate internal Diagnosis Table:
    | Objective | Evidence | Current level | Misconception or gap | Instructional response |
    | --- | --- | ---: | --- | --- |

    ### Phase 4: Roadmap Alignment
    Output structured Table of Contents / Roadmap in Pi terminal:
    - List planned Concept Labs, capability objectives, core invariants, and mastery gates.
    - Wait for user confirmation or questions before authoring notes.

    ### Phase 5: Concept Immersion in Concept Lab
    Author one Concept Lab at a time in the vault (`notes/<topic>-concept-lab.md`) using the 13-section structure and open via `obsidian_open_note`.

    ### Phase 6: Mastery Gate
    Evaluate evidence across objectives (0: unprobed -> 5: critiqued/constructed).
    Concept is mastered only when:
    - Core objectives reach at least applied (level 3).
    - At least one objective reaches transferred (level 4).
    - No critical misconception remains unresolved.
    - Learner discriminates matched nonexamples and analyzes changed assumptions.

    ### Phase 7: Permanent Note Synthesis
    Generate compressed permanent atomic note in `notes/<topic>-atomic-note.md` containing:
    - Precise definition & core mechanism/invariant.
    - Key assumptions & scope.
    - One canonical example & one decisive nonexample.
    - Failure boundary & semantic links.
    - High-quality active retrieval prompts.

    ### Phase 8: Spaced Review Queue
    Schedule retrieval prompts at intervals: 0d (end of session), 1d, 3d, 7d, 21d.
  '';
}
