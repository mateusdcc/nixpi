{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "gifted-diagnostic-probe";
  description = "Multidimensional diagnostic probing protocol to map baseline mental models, misconceptions, and causal predictions before roadmap generation.";
  content = ''
    # Multidimensional Diagnostic Probing Protocol

    ## Objective
    Calibrate prerequisite knowledge, mental models, misconceptions, and causal reasoning BEFORE authoring roadmaps or lessons.

    ## Critical Directives
    1. **Trigger Obsidian Modal via Bridge**:
       - When learning a topic, call `obsidian_prompt_modal` to display the diagnostic probe dialog directly inside Obsidian.
       - Allow learners to calibrate uncertainty with "I do not know" or confidence selectors. Guessing is not rewarded over calibrated uncertainty.
       - Zero emojis across all terminal outputs, banners, and notes.
    2. **Multidimensional Diagnostic Dimensions**:
       Structure probe questions across these 7 dimensions (do NOT classify purely by easy/medium/hard):
       - **Dimension 1: Definition in Own Words**: Verify foundational terminology without circularity.
       - **Dimension 2: Causal Mechanism & Prediction**: Given a system state, predict what happens next and why.
       - **Dimension 3: Example vs. Nonexample Discrimination**: Distinguish a valid instance from a near-miss lacking a decisive property.
       - **Dimension 4: Error & Misconception Detection**: Identify why a plausible-sounding statement or faulty implementation fails.
       - **Dimension 5: Changed-Assumption Counterfactual**: Predict how behavior changes when one foundational assumption is removed.
       - **Dimension 6: Transfer Application**: Apply the underlying invariant to an unfamiliar surface scenario.
       - **Dimension 7: Calibrated Confidence**: Capture high/medium/low confidence to identify priority misconceptions.

    3. **Internal Diagnosis Table Requirement**:
       Analyze submitted probe answers and construct an internal Diagnosis Table:
       | Objective | Evidence | Current Level (0-5) | Misconception or Gap | Instructional Response |
       | --- | --- | ---: | --- | --- |

    4. **Visible Roadmap Adaptation**:
       - The diagnostic answers MUST visibly reshape the roadmap.
       - Accelerate past confirmed foundations; expand modules targeting identified misconceptions or missing prerequisite mechanisms.
       - Output the adapted Table of Contents / Roadmap in Pi terminal for user confirmation before authoring Concept Labs.
  '';
}
