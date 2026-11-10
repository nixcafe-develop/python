# Python development template

Nix flake template for Python projects. The development shell uses the Python version from `requires-python`, installs the project package and its runtime dependencies, and enables `ruff` hooks for commits. The flake is built with [purr](https://flakehub.com/f/nixcafe/purr) and [git-hooks.nix](https://flakehub.com/f/cachix/git-hooks.nix).

This repository is part of the [develop-templates](https://github.com/nixcafe/develop-templates) collection.

## Quick start

Create a project from the template:

```bash
nix flake init -t "github:nixcafe/develop-templates#python" --refresh
```

To use a shorter registry name:

```bash
nix registry add beans "github:nixcafe/develop-templates"
nix flake init -t beans#python
```

If you use [cattery-modules](https://github.com/nixcafe/cattery-modules), the `beans` registry entry already exists.

You can also create a GitHub repository from this template:

```bash
gh repo create my-python-project --template nixcafe-develop/python --clone
```

Enter the development shell:

```bash
direnv allow
python -c "import example; print(example.__version__)"
example
```

You need [Nix](https://nixos.org/download) with [flakes enabled](https://nixos.wiki/wiki/Flakes). [direnv](https://direnv.net/) is optional; without it, use `nix develop`.

## What's included

| Tool | Purpose |
|------|---------|
| Python | Interpreter selected from `requires-python` (`>=3.12` selects `python312`) |
| `ruff` | Linter, enabled as a pre-commit hook |
| `ruff-format` | Formatter, enabled as a pre-commit hook |
| `hatchling` | Build backend declared in `pyproject.toml` |

The shell installs the project package and every package in `project.dependencies`. `build-system.requires` is used to build the package.

## Customization

### Change the Python version

Set `requires-python` in `pyproject.toml`. The Nix code reads the major and minor version, so `>=3.12` selects `pkgs.python312`. If the field is missing or has no major and minor version, it uses `pkgs.python3`:

```toml
[project]
requires-python = ">=3.12"
```

### Add dependencies

Add runtime dependencies to `project.dependencies`. They are passed to both the package build and the shell:

```toml
[project]
dependencies = ["requests", "click>=8"]
```

Version specifiers are removed before the name is looked up in nixpkgs, so `click>=8` uses `pkgs.python312Packages.click`.

Add build dependencies to `build-system.requires`.

The Nix expressions do not read `[dependency-groups]`. To add a development tool to the shell, add it to the `python.withPackages` list in `develop/shells/default/default.nix`.

### Pre-commit hooks

`develop/checks/git-hooks/default.nix` enables ruff and ruff-format:

```nix
{ inputs, system, ... }:
inputs.git-hooks.lib.${system}.run {
  src = ../../../.;
  hooks = {
    ruff.enable = true;
    ruff-format.enable = true;
  };
}
```

Hooks run on `git commit`. To run all checks, including the hooks, use `nix flake check`.

## Project structure

```
.
├── flake.nix                          # flake entrypoint
├── pyproject.toml                     # project metadata and dependencies
├── .envrc                             # direnv integration (use flake)
├── .gitignore
├── src/
│   └── example/
│       ├── __init__.py                # reads the installed package version
│       ├── __main__.py                # python -m example
│       └── main.py                    # entry point for project.scripts
└── develop/
    ├── lib/default.nix                # TOML parser, pythonVersion, mapPackages
    ├── packages/default/default.nix   # buildPythonPackage derivation
    ├── shells/default/default.nix     # development shell
    └── checks/git-hooks/default.nix   # ruff and ruff-format hooks
```

## How it works

1. `develop/lib/default.nix` parses `pyproject.toml` and resolves `requires-python` to a nixpkgs Python attribute, for example `python312`.
2. `develop/packages/default/default.nix` builds the project with `buildPythonPackage` in `pyproject` format. Entries in `build-system.requires` and `project.dependencies` are mapped to nixpkgs Python packages.
3. `develop/shells/default/default.nix` creates a shell with that interpreter, the project package, its dependencies, and the git hook shell hook.
4. `develop/checks/git-hooks/default.nix` enables `ruff` and `ruff-format`.

## Useful commands

```bash
direnv allow                                      # load the development shell
nix develop                                       # load the shell without direnv
nix build                                         # build the default package
nix flake check                                   # run the flake checks, including the git hooks
python -c "import example; print(example.__version__)"
example                                           # run the console script
```

## References

- [purr](https://flakehub.com/f/nixcafe/purr) for the flake framework
- [git-hooks.nix](https://flakehub.com/f/cachix/git-hooks.nix) for the commit hooks
- [ruff](https://docs.astral.sh/ruff/) for linting and formatting
- [PEP 508](https://peps.python.org/pep-0508/) for dependency names and version specifiers
