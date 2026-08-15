{
  pkgs,
  mkPiExtension,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
}:

mkPiExtension {
  pname = "pi-gpt-search";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "mateusdcc";
    repo = "pi-gpt-search";
    rev = "5e468c5671a1e48a88fb3b8175feac434d6594ec";
    sha256 = "0azgbnjnm5fz57i1s1mll0y9qm83hi4xvpqrwf2z95k7ca1px70j";
  };

  meta = {
    description = "Model-independent standalone web search extension for Pi coding agent powered by OpenAI Codex search engine";
    homepage = "https://github.com/mateusdcc/pi-gpt-search";
    license = pkgs.lib.licenses.mit;
  };
}
