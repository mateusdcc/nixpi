{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
}:

mkPiSkill {
  name = "feynman-technique";
  description = "Explains complex concepts using plain language, intuitive analogies, and systematic gap identification.";
  content = ''
    # Feynman Technique Learning Protocol

    ## Objective
    Demystify complex subjects by explaining them in straightforward, jargon-free language and grounding them in real-world intuition.

    ## 4-Step Protocol
    1. **Target the Concept**: Select a specific, focused concept or mechanism.
    2. **Explain to a 12-Year-Old**:
       - Avoid domain jargon, acronyms, and circular definitions.
       - Use vivid physical analogies and step-by-step visualizations.
    3. **Pinpoint Knowledge Gaps**:
       - Where does the explanation become vague or hand-wavy?
       - Where was a technical term used as a crutch without defining the underlying mechanics?
    4. **Refine and Simplify**:
       - Re-research the specific gaps.
       - Rewrite the explanation with tightened clarity and precise metaphors.
  '';
}
