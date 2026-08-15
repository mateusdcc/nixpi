{ lib, ... }:

{
  programs.pi = {
    enable = lib.mkDefault true;
    settings = {
      defaultThinkingLevel = lib.mkDefault "high";
    };
    extensions = {
      ripgrep-search.enable = lib.mkDefault true;
      echo.enable = lib.mkDefault true;
    };
  };
}
