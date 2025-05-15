{
  lib,
  namespace,
  pkgs,
  inputs,
  mkShell,
  system,
  ...
}:
let
  inherit (lib.${namespace}) pythonVersion mapPackages toml;

  python = pkgs."python${pythonVersion}";

  currentPackage = inputs.self.packages.${system}.default;
in
mkShell {
  packages = [
    (python.withPackages (
      ps:
      [
        currentPackage
      ]
      ++ mapPackages ps toml.project.dependencies
    ))
  ];

  inputsFrom = [ currentPackage ];
  inherit (inputs.self.checks.${system}.pre-commit-check) shellHook;
}
