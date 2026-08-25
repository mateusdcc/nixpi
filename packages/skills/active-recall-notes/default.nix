{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "active-recall-notes";
  description = "Active retrieval and spaced review queue protocol with multi-objective prompts, discrimination probes, and post-mastery synthesis.";
  content = ''
    # Active Retrieval & Spaced Review Queue Protocol

    ## Objective
    Ensure durable, long-term retention and fast retrieval through generative prompts and automated review scheduling.

    ## Rules
    1. **Post-Mastery Generation**:
       - Permanent notes are generated ONLY after all core objectives reach level 3 (applied) and at least one reaches level 4 (transferred).
    2. **Multi-Objective Retrieval Prompts**:
       Do not use simple definition flashcards. For each concept, author prompts across 3 distinct families:
       - **Causal Prediction**: "Given initial state X and input Y, derive the terminal state and state which invariant ensures safety."
       - **Near-Miss Discrimination**: "Distinguish mechanism A from near-miss B. What single property makes B fail under concurrency?"
       - **Changed-Assumption Counterfactual**: "If network assumption Z is relaxed from synchronous to asynchronous, what vulnerability emerges?"
    3. **Spaced Review Scheduling**:
       Store review intervals in `.pi/learning/review_queue.json`:
       - Interval 0: End of learning session (same day).
       - Interval 1: 1 day later.
       - Interval 2: 3 days later.
       - Interval 3: 7 days later.
       - Interval 4: 21 days later.
       - Retrieval begins with generation from memory before rereading notes.
  '';
}
