# Nix Flake · Python Dev Template

> purr · git-hooks · python · ruff · pyproject · uv · reproducible · nix-flake

Nix flake template for Python development — reproducible dev shell with auto-configured Python version, package build, and pre-commit hooks out of the box. Uses [purr](https://flakehub.com/f/nixcafe/purr) as the flake framework and [git-hooks.nix](https://flakehub.com/f/cachix/git-hooks.nix) for linting/formatting on commit.

## What's Inside

| Tool | Purpose |
|------|---------|
| `python3` | Python interpreter version auto-detected from `pyproject.toml` |
| `ruff` | Fast Python linter (enforced on commit) |
| `ruff-format` | Fast Python formatter (enforced on commit) |
| `hatchling` | PEP 517 build backend |

## Quick Start

```bash
# clone template
git clone <repo> my-project && cd my-project

# allow direnv
direnv allow

# done — dev shell is ready
python -c "import example; print('works')"
```

Requires [Nix](https://nixos.org/download) with [flakes enabled](https://nixos.wiki/wiki/Flakes) and [direnv](https://direnv.net/) installed.

## Customizing

### Change Python Version

Edit `requires-python` in `pyproject.toml`:

```toml
[project]
requires-python = ">=3.11"
```

### Add Dependencies

Add runtime dependencies to `pyproject.toml`:

```toml
[project]
dependencies = ["requests", "click>=8"]
```

Add dev dependencies:

```toml
[dependency-groups]
dev = ["pytest", "mypy"]
```

### Pre-commit Hooks

Configured via `develop/checks/git-hooks/default.nix`:

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

Hooks run automatically on `git commit`. To run manually:

```bash
nix flake check
```

## How It Works

1. **Version detection** — `develop/lib/module/default.nix` parses `pyproject.toml` (TOML) and resolves the Python version from `requires-python`.
2. **Package build** — `develop/packages/default/default.nix` builds a `buildPythonPackage` from `pyproject.toml`, mapping all `build-system.requires` and `project.dependencies` to nixpkgs Python packages.
3. **Dev shell** — `develop/shells/default/default.nix` auto-generates a `mkShell` with the correct Python + all dependencies + git hook shellHook.
4. **Git hooks** — `develop/checks/git-hooks/default.nix` runs `ruff` and `ruff-format` via cachix/git-hooks.nix.

## Project Structure

```
.
├── flake.nix                          # Flake entrypoint — wires purr inputs
├── pyproject.toml                     # Python project metadata & deps
├── .envrc                             # direnv integration (use flake)
├── .gitignore                         # nix artifacts, python cache, etc.
├── src/
│   └── example/
│       ├── __init__.py
│       ├── __main__.py
│       └── main.py                    # Entry point (see project.scripts)
└── develop/
    ├── lib/module/default.nix         # TOML parser, pythonVersion, mapPackages
    ├── packages/default/default.nix   # buildPythonPackage derivation
    ├── shells/default/default.nix     # Dev shell with all deps + hooks
    └── checks/git-hooks/default.nix   # ruff + ruff-format pre-commit
```

## References

- [purr](https://flakehub.com/f/nixcafe/purr) — Nix flake framework
- [git-hooks.nix](https://flakehub.com/f/cachix/git-hooks.nix) — Configurable git hooks
- [ruff](https://docs.astral.sh/ruff/) — Fast Python linter & formatter
- [PEP 508](https://peps.python.org/pep-0508/) — Dependency specification format
