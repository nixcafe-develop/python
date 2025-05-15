{
  lib,
  namespace,
  inputs,
  pkgs,
  system,
  ...
}:
let
  inherit (lib.${namespace})
    pythonVersion
    toml
    mapPackages
    ;

  python = pkgs."python${pythonVersion}";
  pythonPkgs = python.pkgs;
in
pythonPkgs.buildPythonPackage {
  pname = toml.project.name or "example";
  version = toml.project.version or "0.1.0";
  format = "pyproject";

  src = ../../../.;

  build-system = mapPackages pythonPkgs toml.build-system.requires;

  dependencies = mapPackages pythonPkgs toml.project.dependencies;

  buildInputs = inputs.self.checks.${system}.pre-commit-check.enabledPackages;
}
