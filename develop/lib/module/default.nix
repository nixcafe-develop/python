rec {
  stripName =
    dep:
    let
      # https://peps.python.org/pep-0508/#names
      m = builtins.match "^([a-zA-Z0-9_.-]+).*" dep;
    in
    if m != null then builtins.head m else dep;

  toml = builtins.fromTOML (builtins.readFile ../../../pyproject.toml);

  pythonVersion = "3";

  mapPackages = ps: names: map (dep: ps.${stripName dep}) names;

}
