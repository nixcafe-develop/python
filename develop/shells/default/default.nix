{
  inputs,
  mkShell,
  system,
  ...
}:
mkShell {
  inputsFrom = [ inputs.self.packages.${system}.default ];
  inherit (inputs.self.checks.${system}.pre-commit-check) shellHook;
}
