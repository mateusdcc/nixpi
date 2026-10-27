{ pkgs }:

pkgs.runCommand "nixpi-updater-test"
  {
    nativeBuildInputs = [
      pkgs.bash
      pkgs.jq
      pkgs.gnugrep
      pkgs.coreutils
    ];
  }
  ''
    export HOME="$TMPDIR/fake-home"
    mkdir -p "$HOME"
    export UPDATER_SCRIPT="${../../scripts/update-upstream.sh}"
    bash ${./test-updater.sh}
    touch "$out"
  ''
