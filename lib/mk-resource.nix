{ lib, pkgs }:

{
  mkPiSkill =
    {
      name,
      description ? "",
      content ? null,
      src ? null,
      runtimePackages ? [ ],
      passthru ? { },
      meta ? { },
    }:
    let
      sourcesCount = (if src != null then 1 else 0) + (if content != null then 1 else 0);
      _validateSources =
        if sourcesCount > 1 then
          throw "mkPiSkill: Conflicting source inputs provided for '${name}'. Provide either `src` or `content`, not both."
        else
          true;
    in
    assert _validateSources;
    if src != null then
      src
    else
      pkgs.stdenv.mkDerivation {
        pname = "pi-skill-${name}";
        version = "0.1.0";
        src = pkgs.writeTextDir "SKILL.md" ''
          ---
          name: ${name}
          description: ${builtins.toJSON description}
          ---
          ${if content != null then content else ""}
        '';
        dontBuild = true;
        installPhase = ''
          runHook preInstall
          mkdir -p "$out/${name}"
          cp SKILL.md "$out/SKILL.md"
          cp SKILL.md "$out/${name}/SKILL.md"
          runHook postInstall
        '';
        passthru = passthru // {
          isPiSkill = true;
          inherit runtimePackages;
        };
        meta = meta // {
          description = if meta ? description then meta.description else description;
        };
      };

  mkPiPrompt =
    {
      name,
      description ? "",
      argumentHint ? null,
      content ? null,
      src ? null,
    }:
    let
      sourcesCount = (if src != null then 1 else 0) + (if content != null then 1 else 0);
      _validateSources =
        if sourcesCount > 1 then
          throw "mkPiPrompt: Conflicting source inputs provided for '${name}'. Provide either `src` or `content`, not both."
        else
          true;
      frontmatter =
        if description != "" || argumentHint != null then
          ''
            ---
            ${lib.optionalString (description != "") "description: ${builtins.toJSON description}\n"}${
              lib.optionalString (argumentHint != null) "argument-hint: \"${argumentHint}\"\n"
            }---
          ''
        else
          "";
      resolvedContent = if content != null then content else "";
    in
    assert _validateSources;
    if src != null then src else pkgs.writeText "${name}.md" "${frontmatter}${resolvedContent}";

  mkPiTheme =
    {
      name,
      colors ? null,
      src ? null,
    }:
    let
      sourcesCount = (if src != null then 1 else 0) + (if colors != null then 1 else 0);
      _validateSources =
        if sourcesCount > 1 then
          throw "mkPiTheme: Conflicting source inputs provided for '${name}'. Provide either `src` or `colors`, not both."
        else
          true;
    in
    assert _validateSources;
    if src != null then
      src
    else if colors != null then
      pkgs.writeText "${name}.json" (builtins.toJSON (colors // { inherit name; }))
    else
      pkgs.writeText "${name}.json" (builtins.toJSON { inherit name; });
}
