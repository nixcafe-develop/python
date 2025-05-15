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
  inherit (lib.${namespace}) pythonVersion;
  currentPackage = inputs.self.packages.${system}.default;

  python = pkgs."python${pythonVersion}";
in
mkShell {
  packages = [
    (python.withPackages (ps: [
      currentPackage
    ]))
  ];

  inputsFrom = [ currentPackage ];
  inherit (inputs.self.checks.${system}.pre-commit-check) shellHook;
}
