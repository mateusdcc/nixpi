{ lib, pkgs }:

# Helper to construct custom Pi provider objects and packages
{
  name,
  src ? null,
  package ? null,
  version ? "0.1.0",
  baseUrl ? null,
  api ? null,
  apiKey ? null,
  models ? { },
  runtimePackages ? [ ],
  environment ? { },
  piManifest ? { },
  meta ? { },
  ...
}@args:

let
  mkExtension = import ./mk-extension.nix { inherit lib pkgs; };

  providerPkg =
    if package != null then
      package
    else if src != null then
      mkExtension {
        pname = name;
        inherit
          version
          src
          runtimePackages
          piManifest
          meta
          ;
      }
    else
      null;

  normalizedModels =
    if builtins.isList models then
      builtins.listToAttrs (
        map (
          m:
          if builtins.isString m then
            {
              name = m;
              value = {
                id = m;
              };
            }
          else
            {
              name = m.id or m.name;
              value = m;
            }
        ) models
      )
    else if builtins.isAttrs models then
      models
    else
      { };
in
{
  inherit
    name
    version
    baseUrl
    api
    apiKey
    runtimePackages
    environment
    ;
  models = normalizedModels;
  package = providerPkg;
  isPiProvider = true;
  passthru = {
    inherit name;
    isPiProvider = true;
    package = providerPkg;
    models = normalizedModels;
  };
}
