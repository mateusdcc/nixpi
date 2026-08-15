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
    ./skills/commit-style.nix
    ./providers/antigravity.nix
  ];
}
