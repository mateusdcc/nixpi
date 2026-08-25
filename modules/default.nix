{ ... }:

{
  imports = [
    ./core/package.nix
    ./core/settings.nix
    ./core/providers.nix
    ./core/environment.nix
    ./core/resources.nix
    ./core/output.nix
    ./extensions/echo.nix
    ./extensions/ripgrep-search.nix
    ./extensions/plan-mode.nix
    ./extensions/pi-gpt-search.nix
    ./extensions/research-tools.nix
    ./skills/default.nix
    ./providers/antigravity.nix
  ];
}
