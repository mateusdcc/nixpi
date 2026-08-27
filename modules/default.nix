{ ... }:

{
  imports = [
    ./core
    ./extensions/echo.nix
    ./extensions/ripgrep-search.nix
    ./extensions/plan-mode.nix
    ./extensions/pi-gpt-search.nix
    ./extensions/research-tools.nix
    ./skills/default.nix
  ];
}
