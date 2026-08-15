{ pkgs, nixpiLib }:

let
  # Evaluate an invalid enum option inside tryEval
  modeAttempt = builtins.tryEval (
    let
      res = nixpiLib.evalPi {
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
      };
    in
    res.config.programs.pi.extensions.plan-mode.mode
  );

  # Evaluate an undeclared provider inside tryEval
  providerAttempt = builtins.tryEval (
    let
      res = nixpiLib.evalPi {
        inherit pkgs;
        modules = [
          {
            programs.pi = {
              enable = true;
              settings.defaultProvider = "nonexistent-fake-provider-12345";
            };
          }
        ];
      };
    in
    res.config.programs.pi.finalPackage.outPath
  );

  correctRejections = (!modeAttempt.success) && (!providerAttempt.success);
in
pkgs.runCommand "nixpi-invalid-option-test" { } ''
  ${pkgs.lib.optionalString (
    !correctRejections
  ) "echo 'Invalid option rejection assertion failed' >&2; exit 1"}
  echo "Evaluated invalid option and provider rejection behavior correctly" > "$out"
''
