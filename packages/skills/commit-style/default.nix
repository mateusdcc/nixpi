{
  pkgs,
  mkPiSkill ? (pkgs.callPackage ../../../lib/mk-resource.nix { }).mkPiSkill,
  types ? [
    {
      name = "feat";
      description = "A new feature for the user or library (correlates with SemVer MINOR)";
    }
    {
      name = "fix";
      description = "A bug fix for the user or library (correlates with SemVer PATCH)";
    }
    {
      name = "docs";
      description = "Documentation changes only";
    }
    {
      name = "style";
      description = "Code style/formatting changes that do not affect code logic or semantics";
    }
    {
      name = "refactor";
      description = "Refactoring production code (neither fixes a bug nor adds a feature)";
    }
    {
      name = "perf";
      description = "A code change that improves performance";
    }
    {
      name = "test";
      description = "Adding missing tests, refactoring tests, or correcting test fixtures";
    }
    {
      name = "build";
      description = "Changes that affect the build system or external dependencies (e.g. Nix, npm, Cargo)";
    }
    {
      name = "ci";
      description = "Changes to CI/CD configuration files, scripts, and workflows (e.g. GitHub Actions)";
    }
    {
      name = "chore";
      description = "Routine maintenance tasks, tool configs, or auxiliary changes";
    }
    {
      name = "revert";
      description = "Reverts a previous commit";
    }
  ],
  scopes ? [ ],
  examples ? [ ],
  customGuidelines ? [ ],
}:

let
  lib = pkgs.lib;

  formattedTypesList = lib.concatStringsSep "\n" (
    map (t: if builtins.isAttrs t then "- `${t.name}`: ${t.description}" else "- `${t}`") types
  );

  formattedScopesList =
    if scopes != [ ] then
      ''
        ### Recommended Scopes
        ${lib.concatStringsSep "\n" (map (s: "- `${s}`") scopes)}
      ''
    else
      "";

  formattedCustomGuidelines =
    if customGuidelines != [ ] then
      ''
        ### Custom Repository Guidelines
        ${lib.concatStringsSep "\n" (map (g: "- ${g}") customGuidelines)}
      ''
    else
      "";

  formattedCustomExamples =
    if examples != [ ] then
      ''
        ### Repository-Specific Examples
        ${lib.concatStringsSep "\n\n" (
          map (
            ex:
            if builtins.isAttrs ex then
              ''
                #### ${ex.title or "Example"}
                ```text
                ${ex.content}
                ```
              ''
            else
              "```text\n${ex}\n```"
          ) examples
        )}
      ''
    else
      "";

  skillContent = ''
    # Conventional Commits v1.0.0 Specification and Commit Style Guide

    This skill defines the Git commit message formatting rules based on the Conventional Commits v1.0.0 specification. All commit messages must follow these rules strictly.

    ---

    ## Commit Message Structure

    Each commit message consists of a **header**, an optional **body**, and optional **footer(s)**:

    ```text
    <type>[optional scope]: <description>

    [optional body]

    [optional footer(s)]
    ```

    ---

    ## Structural Breakdown

    1. **Type (`<type>`)**:
       - Mandatory prefix identifying the intent of the commit.
       - Common types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
    2. **Scope (`[optional scope]`)**:
       - Optional noun describing the codebase section/subsystem enclosed in parentheses.
       - Examples: `fix(api):`, `feat(auth):`, `refactor(parser):`, `chore(deps):`.
    3. **Breaking Change Marker (`!`)**:
       - Placed immediately before the `:` to draw attention to breaking API/behavior changes.
       - Examples: `feat!:`, `fix(core)!:`.
    4. **Separator (`: `)**:
       - Mandatory colon and single space following the type/scope prefix.
    5. **Description (`<description>`)**:
       - Short summary in imperative, present tense: "fix(api): bklabkakblalbalkblak", "add authentication endpoint" (not "added" or "adds").
       - Lowercase start, no trailing period.
    6. **Body (`[optional body]`)**:
       - Begins one blank line below the description.
       - Free-form text or bullet points explaining *what* changed and *why*.
    7. **Footers (`[optional footer(s)]`)**:
       - Begins one blank line below the body.
       - Each footer format: `<token>: <value>` or `<token> #<value>` (e.g. `BREAKING CHANGE: <text>`, `Fixes: #123`, `Reviewed-by: <name>`).
       - Tokens use `-` instead of whitespace, except for `BREAKING CHANGE` or `BREAKING-CHANGE`.

    ---

    ## Allowed Commit Types

    ${formattedTypesList}

    ${formattedScopesList}
    ---

    ## Specification Rules (RFC 2119)

    1. Commits MUST be prefixed with a type consisting of a noun (e.g. `feat`, `fix`), followed by an OPTIONAL scope, OPTIONAL `!`, and REQUIRED terminal colon and space (`: `).
    2. The type `feat` MUST be used when adding a new user-facing or library feature (SemVer MINOR).
    3. The type `fix` MUST be used when fixing a bug (SemVer PATCH).
    4. A scope MAY be provided after a type enclosed in parentheses, e.g. `fix(parser): ...` or `fix(api): ...`.
    5. A description MUST immediately follow the colon and space.
    6. A longer body MAY follow one blank line after the description.
    7. One or more footers MAY follow one blank line after the body.
    8. Breaking changes MUST be indicated in the type/scope prefix (with `!`) or as a footer entry starting with `BREAKING CHANGE:`.
    9. `BREAKING-CHANGE` MUST be synonymous with `BREAKING CHANGE`.

    ---

    ## Concrete Examples

    ### 1. Simple fix with scope
    ```text
    fix(api): prevent null pointer exception on missing user ID
    ```

    ### 2. Feature with scope
    ```text
    feat(auth): implement OAuth2 PKCE login authentication flow
    ```

    ### 3. Feature with scope and breaking change indicator `!`
    ```text
    feat(api)!: send an email to the customer when a product is shipped
    ```

    ### 4. Fix with description, multi-paragraph body, and footers
    ```text
    fix(sync): prevent racing of incoming state updates

    Introduce a request id and a reference to latest request. Dismiss
    incoming responses other than from latest request.

    Remove timeouts which were used to mitigate the racing issue but are
    obsolete now.

    Reviewed-by: maintainer
    Refs: #123
    ```

    ### 5. Breaking change with BREAKING CHANGE footer
    ```text
    feat(config): support declarative nix modules for extension authoring

    BREAKING CHANGE: the legacy json-only config format is no longer supported.
    Users must migrate their settings to flake modules.
    ```

    ### 6. Documentation update
    ```text
    docs(readme): add quick start guide and architectural overview
    ```

    ### 7. Revert commit
    ```text
    revert: revert "feat(parser): add experimental streaming parser"

    Refs: 676104e, a215868
    ```

    ${formattedCustomExamples}
    ---

    ## Agent & Pair Programming Workflow Rules

    - **Atomicity**: Make minimal, atomic, single-intent commits (one logical task per commit).
    - **Imperative Mood**: Use imperative verbs ("add", "fix", "refactor", "update").
    - **Never Auto-Add Co-Author**: Never automatically append assistant/agent co-author credits.
    - **Character Limit**: Keep the summary line under 72 characters whenever possible.
    - **No Em-Dash**: Use standard hyphen-dash `-` instead of em-dash `—`.

    ${formattedCustomGuidelines}
  '';
in
mkPiSkill {
  name = "commit-style";
  description = "Guidelines, specification, and examples for writing Conventional Commits v1.0.0 git commit messages.";
  content = skillContent;
  runtimePackages = [ pkgs.git ];
  meta = {
    description = "Pi skill for Conventional Commits v1.0.0 specification and style guide";
    homepage = "https://www.conventionalcommits.org/en/v1.0.0/";
  };
}
