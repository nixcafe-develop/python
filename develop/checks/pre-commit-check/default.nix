{ inputs, system, ... }:
inputs.pre-commit-hooks.lib.${system}.run {
  src = ../../../.;
  hooks = {
    # formatter
    ruff.enable = true;
    ruff-format.enable = true;
  };
}
