{ lib, pkgs }:

# Helper to package a Pi extension into a standard Pi package derivation.
{
  pname,
  version ? "0.1.0",
  src ? null,
  content ? null,
  entrypoint ? null,
  runtimePackages ? [ ],
  runtimeEnvironment ? { },
  piManifest ? { },
  meta ? { },
  ...
}@args:

let
  sourcesCount =
    (if src != null then 1 else 0)
    + (if content != null then 1 else 0)
    + (if entrypoint != null then 1 else 0);

  _validateSources =
    if sourcesCount == 0 then
      throw "mkPiExtension: One of `src`, `content`, or `entrypoint` must be provided for '${pname}'"
    else if sourcesCount > 1 then
      throw "mkPiExtension: Conflicting source inputs provided for '${pname}'. Provide exactly one of `src`, `content`, or `entrypoint`."
    else
      true;

  cleanArgs = builtins.removeAttrs args [
    "pname"
    "version"
    "src"
    "content"
    "entrypoint"
    "runtimePackages"
    "runtimeEnvironment"
    "piManifest"
    "meta"
  ];

  resolvedSrc =
    assert _validateSources;
    if src != null then
      src
    else if content != null then
      pkgs.writeTextDir "extensions/index.ts" content
    else if entrypoint != null then
      pkgs.runCommand "pi-extension-${pname}-entrypoint" { } ''
        mkdir -p "$out/extensions"
        entrypointPath="${entrypoint}"
        baseName=$(basename "$entrypointPath")
        cleanName=$(echo "$baseName" | sed -E 's/^[a-z0-9]{32}-//')
        case "$cleanName" in
          *.ts|*.js)
            cp "$entrypointPath" "$out/extensions/$cleanName"
            ;;
          *)
            cp "$entrypointPath" "$out/extensions/index.ts"
            ;;
        esac
      ''
    else
      throw "mkPiExtension: One of `src`, `content`, or `entrypoint` must be provided for '${pname}'";

  manifestJson = builtins.toJSON (
    lib.recursiveUpdate {
      name = pname;
      version = version;
      keywords = [ "pi-package" ];
      pi = {
        extensions = [ "./extensions" ];
      };
    } piManifest
  );
in
pkgs.stdenv.mkDerivation (
  cleanArgs
  // {
    pname = "pi-extension-${pname}";
    inherit version;
    src = resolvedSrc;

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -r ./* "$out/"

      if [ ! -f "$out/package.json" ]; then
        echo '${manifestJson}' > "$out/package.json"
      fi
      runHook postInstall
    '';

    passthru = {
      isPiExtension = true;
      inherit runtimePackages runtimeEnvironment;
    };

    meta = meta // {
      description = meta.description or "Pi extension package: ${pname}";
    };
  }
)
