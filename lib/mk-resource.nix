{ lib, pkgs }:

{
  mkPiSkill =
    {
      name,
      description ? "",
      content ? "",
      src ? null,
    }:
    if src != null then
      src
    else
      pkgs.writeTextDir "${name}/SKILL.md" ''
        ---
        name: ${name}
        description: ${description}
        ---
        ${content}
      '';

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
