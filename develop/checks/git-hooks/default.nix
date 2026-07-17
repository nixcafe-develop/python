{ inputs, system, ... }:
inputs.git-hooks.lib.${system}.run {
  src = ../../../.;
  hooks = {
    ruff.enable = true;
    ruff-format.enable = true;
  };
}
