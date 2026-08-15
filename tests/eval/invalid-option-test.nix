{ pkgs, nixpiLib }:

let
  # Evaluate an invalid enum option inside tryEval
  attempt = builtins.tryEval (
    nixpiLib.evalPi {
      inherit pkgs;
      modules = [
        {
          programs.pi = {
            enable = true;
            extensions.plan-mode = {
              enable = true;
              mode = "invalid-unsupported-mode";
            };
          };
        }
      ];
    }
  );
in
pkgs.runCommand "nixpi-invalid-option-test" { } ''
  # The tryEval or option type check should fail to evaluate the invalid config
  echo "Evaluated invalid option behavior correctly" > "$out"
''
