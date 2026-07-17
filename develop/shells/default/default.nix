{
  lib,
  namespace,
  pkgs,
  inputs,
  system,
  ...
}:
let
  inherit (lib.${namespace}) pythonVersion mapPackages toml;

  python = pkgs."python${pythonVersion}";

  currentPackage = inputs.self.packages.${system}.default;
in
pkgs.mkShell {
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
  inherit (inputs.self.checks.${system}.git-hooks) shellHook;
}
