# Library API

The public library is `nixpi.lib.nixpi`. Builder functions accept `pkgs` either as an argument in their input set or through the extensible library used by nixpi itself.

## Evaluate and build

### `evalPi`

`evalPi { pkgs, modules ? [], extraSpecialArgs ? {} }` evaluates the complete Pi module system and returns the normal Nix module evaluation result, including `config` and `options`.

```nix
let
  evaluated = nixpi.lib.nixpi.evalPi {
    inherit pkgs;
    modules = [{ programs.pi.enable = true; }];
  };
in evaluated.config.programs.pi.finalPackage
```

### `makePi`

`makePi { pkgs, modules ? [], extraSpecialArgs ? {} }` returns the configured Pi package. Its `passthru` exposes `config`, `options`, `unwrapped`, and `extend`.

```nix
let
  pi = nixpi.lib.nixpi.makePi {
    inherit pkgs;
    modules = [{ programs.pi.enable = true; }];
  };
in pi.extend {
  programs.pi.skills.commit-style.enable = true;
}
```

## Package resources

### `mkPiExtension`

`mkPiExtension { pname, src, version ? "0.1.0", runtimePackages ? [], runtimeEnvironment ? {}, piManifest ? {}, meta ? {}, ... }` packages an extension directory. It writes a default Pi manifest if `src` does not provide `package.json`.

```nix
myExtension = nixpi.lib.nixpi.mkPiExtension {
  inherit pkgs;
  pname = "hello";
  src = pkgs.writeTextDir "extensions/index.js" ''
    export default pi => pi.registerCommand("hello", { handler: () => console.log("hello") });
  '';
};
```

### `mkPiSkill`

`mkPiSkill { name, description ? "", content ? "", src ? null, runtimePackages ? [], passthru ? {}, meta ? {} }` creates a skill package. With `src`, it returns that source unchanged.

```nix
nixpi.lib.nixpi.mkPiSkill {
  inherit pkgs;
  name = "release-check";
  description = "Check a release before publishing.";
  content = "Run nix flake check before a release.";
}
```

### `mkPiPrompt`

`mkPiPrompt { name, description ? "", argumentHint ? null, content }` creates a prompt Markdown resource, adding front matter when requested.

```nix
nixpi.lib.nixpi.mkPiPrompt {
  inherit pkgs;
  name = "review";
  argumentHint = "[path]";
  content = "Review the requested path for correctness and maintainability.";
}
```

### `mkPiTheme`

`mkPiTheme { name, colors }` creates a JSON theme resource. `name` is added to the supplied color attribute set.

```nix
nixpi.lib.nixpi.mkPiTheme {
  inherit pkgs;
  name = "night";
  colors.background = "#111827";
}
```

### `mkPiProvider`

`mkPiProvider { name, src ? null, package ? null, version ? "0.1.0", baseUrl ? null, api ? null, apiKey ? null, models ? {}, runtimePackages ? [], environment ? {}, piManifest ? {}, meta ? {}, ... }` returns a normalized provider object. `models` may be a list or attribute set. A `src` is packaged as an extension when no package is supplied.

```nix
nixpi.lib.nixpi.mkPiProvider {
  inherit pkgs;
  name = "local";
  baseUrl = "http://localhost:11434/v1";
  models = [{ id = "qwen2.5-coder"; }];
}
```

## Module factories

### `mkPiExtensionModule`

Creates a complete `programs.pi.extensions.<name>` module. It accepts `name`, optional `description`, `package` or `defaultPackage`, `runtimePackages`, `extraPackages`, `settingsOptions`, `settingsExample`, `settingsDescription`, `defaultText`, `extraOptions`, and `extraConfig`.

```nix
nixpi.lib.nixpi.mkPiExtensionModule {
  name = "hello";
  defaultPackage = myExtension;
  runtimePackages = [ pkgs.git ];
}
```

### `mkPiSkillModule`

Creates a complete `programs.pi.skills.<name>` module. It accepts `name`, optional `description`, `package` or `defaultPackage`, `runtimePackages`, `extraPackages`, `defaultText`, `extraOptions`, and `extraConfig`.

```nix
nixpi.lib.nixpi.mkPiSkillModule {
  name = "release-check";
  defaultPackage = mySkill;
}
```

### `mkPiProviderModule`

Creates a complete `programs.pi.providers.<name>` module. It accepts `name`, optional `description`, `package` or `defaultPackage`, `baseUrl`, `api`, `apiKey`, `models`, `runtimePackages`, `extraPackages`, and `extraConfig`.

```nix
nixpi.lib.nixpi.mkPiProviderModule {
  name = "local";
  baseUrl = "http://localhost:11434/v1";
  models = [{ id = "qwen2.5-coder"; }];
}
```

### `deprecation.warn`

`deprecation.warn { old, replacement, supportedThrough ? "1.x" } value` returns `value` while emitting a Nix evaluation warning. It is used for compatibility aliases.

```nix
nixpi.lib.nixpi.deprecation.warn {
  old = "oldOutput";
  replacement = "newOutput";
} value
```
