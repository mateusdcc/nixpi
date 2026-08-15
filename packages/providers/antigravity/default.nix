{
  pkgs,
  mkPiExtension,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
}:

mkPiExtension {
  pname = "pi-antigravity";
  version = "0.2.9";

  src = fetchFromGitHub {
    owner = "Rahularya01";
    repo = "pi-antigravity";
    rev = "10c5f39db8d85fd2bee5ecc55763875a4b41c7ab";
    sha256 = "0b5gzci9f1v3cvlcy1sqldi2wz57lhfyjkbbqcacls0pmxbsir56";
  };

  piManifest = {
    name = "pi-antigravity";
    version = "0.2.9";
    keywords = [
      "pi-package"
      "pi-extension"
      "antigravity"
      "provider"
    ];
    pi = {
      extensions = [ "./src/index.ts" ];
    };
  };

  meta = {
    description = "Antigravity / Cloud Code Assist provider for Pi Coding Agent with OAuth login and native streaming";
    homepage = "https://github.com/Rahularya01/pi-antigravity";
    license = pkgs.lib.licenses.mit;
  };
}
