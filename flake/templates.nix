{
  templates = {
    standalone = {
      path = ../templates/standalone;
      description = "Standalone configured Pi environment";
    };
    home-manager = {
      path = ../templates/home-manager;
      description = "Home Manager configuration for Pi";
    };
    devshell = {
      path = ../templates/devshell;
      description = "Project-specific development shell with Pi";
    };
    learning = {
      path = ../templates/learning;
      description = "Deprecated learning environment compatibility template";
    };
  };
}
