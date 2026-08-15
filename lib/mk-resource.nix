{ lib, pkgs }:

{
  mkPiSkill =
    {
      name,
      description ? "",
      content ? "",
      src ? null,
      runtimePackages ? [ ],
      passthru ? { },
      meta ? { },
    }:
    if src != null then
      src
    else
      pkgs.stdenv.mkDerivation {
        pname = "pi-skill-${name}";
        version = "0.1.0";
        src = pkgs.writeTextDir "SKILL.md" ''
          ---
          name: ${name}
          description: ${description}
          ---
          ${content}
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
      content,
    }:
    let
      frontmatter =
        if description != "" || argumentHint != null then
          ''
            ---
            ${lib.optionalString (description != "") "description: ${description}\n"}${
              lib.optionalString (argumentHint != null) "argument-hint: \"${argumentHint}\"\n"
            }---
          ''
        else
          "";
    in
    pkgs.writeText "${name}.md" "${frontmatter}${content}";

  mkPiTheme =
    {
      name,
      colors,
    }:
    pkgs.writeText "${name}.json" (builtins.toJSON (colors // { inherit name; }));
}
