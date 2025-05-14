{
  inputs,
  pkgs,
  system,
  ...
}:
let
  toml = builtins.fromTOML (builtins.readFile ../../../pyproject.toml);
  python = pkgs.python3;
  pythonPkgs = python.pkgs;
  stripName =
    dep:
    let
      # https://peps.python.org/pep-0508/#names
      m = builtins.match "^([a-zA-Z0-9_.-]+).*" dep;
    in
    if m != null then builtins.head m else dep;
in
pythonPkgs.buildPythonPackage {
  pname = toml.project.name or "example";
  version = toml.project.version or "0.1.0";
  format = "pyproject";

  src = ../../../.;

  build-system = map (dep: pythonPkgs.${stripName dep}) toml.build-system.requires;

  dependencies = map (dep: pythonPkgs.${stripName dep}) toml.project.dependencies;

  buildInputs = inputs.self.checks.${system}.pre-commit-check.enabledPackages;
}
