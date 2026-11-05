let
  stripName =
    dep:
    let
      # https://peps.python.org/pep-0508/#names
      m = builtins.match "^([a-zA-Z0-9_.-]+).*" dep;
    in
    if m != null then builtins.head m else dep;

  toml = builtins.fromTOML (builtins.readFile ../../pyproject.toml);

  # Resolve `<major>.<minor>` from `requires-python` into a nixpkgs
  # attribute name, e.g. ">=3.12" -> "python312".
  versionMatch = builtins.match "[^0-9]*([0-9]+)\\.([0-9]+).*" (
    toml.project.requires-python or ">=3"
  );
  pythonVersion =
    if versionMatch != null then
      "python${builtins.elemAt versionMatch 0}${builtins.elemAt versionMatch 1}"
    else
      "python3";
in
rec {
  inherit
    stripName
    toml
    pythonVersion
    ;

  mapPackages = ps: names: map (dep: ps.${stripName dep}) names;
}
