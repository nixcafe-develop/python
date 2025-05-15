{
  lib,
  namespace,
  inputs,
  pkgs,
  system,
  ...
}:
let
  inherit (lib.${namespace}) pythonVersion stripName;
  toml = builtins.fromTOML (builtins.readFile ../../../pyproject.toml);
  python = pkgs."python${pythonVersion}";
  pythonPkgs = python.pkgs;
in
pythonPkgs.buildPythonApplication {
  pname = toml.project.name or "example";
  version = toml.project.version or "0.1.0";
  format = "pyproject";

  src = ../../../.;

  build-system = map (dep: pythonPkgs.${stripName dep}) toml.build-system.requires;

  dependencies = map (dep: pythonPkgs.${stripName dep}) toml.project.dependencies;

  buildInputs = inputs.self.checks.${system}.pre-commit-check.enabledPackages;
}
