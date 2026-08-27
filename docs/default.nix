{ pkgs, nixpiLib }:

let
  evaluated = nixpiLib.evalPi { inherit pkgs; };
  optionsDoc = pkgs.nixosOptionsDoc {
    options = builtins.removeAttrs evaluated.options [ "_module" ];
  };
in
pkgs.runCommand "nixpi-documentation"
  {
    nativeBuildInputs = [ pkgs.mdbook ];
  }
  ''
  destination="$out/share/doc/nixpi"
  source="$TMPDIR/book"
  sourceDirectory="$source/src"
  mkdir -p "$destination" "$sourceDirectory/reference"

  install -Dm644 ${optionsDoc.optionsCommonMark} "$destination/options.md"
  cp -R ${./.}/. "$sourceDirectory"
  install -Dm644 ${./book.toml} "$source/book.toml"
  install -Dm644 ${optionsDoc.optionsCommonMark} "$sourceDirectory/reference/options.md"
  install -Dm644 ${../README.md} "$sourceDirectory/reference/readme.md"
  install -Dm644 ${../CONTRIBUTING.md} "$sourceDirectory/reference/contributing.md"
  install -Dm644 ${../MAINTAINING.md} "$sourceDirectory/reference/maintaining.md"
  install -Dm644 ${../SECURITY.md} "$sourceDirectory/reference/security.md"
    mdbook build "$source" --dest-dir "$destination/html"
  ''
