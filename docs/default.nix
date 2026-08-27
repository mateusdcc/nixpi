{ pkgs, nixpiLib }:

let
  evaluated = nixpiLib.evalPi { inherit pkgs; };
  optionsDoc = pkgs.nixosOptionsDoc {
    options = builtins.removeAttrs evaluated.options [ "_module" ];
  };
in
pkgs.runCommand "nixpi-documentation" { } ''
  destination="$out/share/doc/nixpi"
  mkdir -p "$destination"

  install -Dm644 ${optionsDoc.optionsCommonMark} "$destination/options.md"
  install -Dm644 ${../README.md} "$destination/README.md"
  install -Dm644 ${../CONTRIBUTING.md} "$destination/CONTRIBUTING.md"
  install -Dm644 ${../MAINTAINING.md} "$destination/MAINTAINING.md"
  install -Dm644 ${../SECURITY.md} "$destination/SECURITY.md"
  cp -R ${./architecture-decisions} "$destination/architecture-decisions"
  cp -R ${./development} "$destination/development"
  cp -R ${./migrations} "$destination/migrations"
  cp -R ${./reference} "$destination/reference"
  cp -R ${./user-guide} "$destination/user-guide"
''
