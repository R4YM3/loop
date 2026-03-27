# tmuxinator-team-workflows

Shared tmuxinator workflows for teams, with a small CLI (`twf`) for install, scaffolding, validation, and lifecycle tasks.

`tmuxinator` remains the runtime. This project adds a collaboration layer for template sharing and developer overrides.

## What this is

- Team-managed tmuxinator project templates.
- Personal override support without editing shared templates.
- A single command surface (`twf`) for common workflows.

## What this is not

- Not a tmuxinator replacement.
- Not a generic dev environment orchestrator.
- Not another tmux session schema.

## Quick start

Install globally from GitHub:

```bash
curl -fsSL "https://raw.githubusercontent.com/R4YM3/tmuxinator-team-workflows/main/scripts/bootstrap.sh" | bash
```

Create a new project scaffold in an empty directory:

```bash
mkdir my-workflow && cd my-workflow
twf add my-workflow
```

Install project links and env config:

```bash
twf install --yes
```

Validate and start:

```bash
twf validate
twf start my-workflow
```

## CLI commands

Run `twf help` for the latest command text.

- `twf install [args...]` installs/updates CLI link and runs `install.sh`.
- `twf add <project-name> [--dry-run]` scaffolds a full project in the current directory.
- `twf remove <project-name> [--yes]` removes tmuxinator alias, then optionally removes local override/template files.
- `twf validate` validates templates (`check` is an alias).
- `twf doctor` checks environment and then runs validation.
- `twf update` pulls latest twf repo and reruns install.
- `twf list` shows template workflows and installed tmuxinator workflows.
- `twf start <project> [args...]` runs `tmuxinator start <project>`.
- `twf uninstall [--yes]` removes global twf CLI install (not project aliases).
- `twf version` prints the CLI version.

## `twf add` behavior

`twf add` is strict by design:

- Project name is required and must match `^[a-z0-9][a-z0-9-]*$`.
- `root:` in generated project template is set to `.`.
- Hard-fails if `~/.config/tmuxinator/<project>.yml` already exists.
- Hard-fails if destination files already exist in current directory.
- Supports `--dry-run` to preview generated files.

Scaffold output includes:

- `install.sh`, `uninstall.sh`, `twf`, `.install`
- `scripts/`, `templates/`, `developer/`
- `templates/projects/<project>.yml`
- `developer/projects/<project>.override.yml`

## `twf remove` behavior

`twf remove <project>` does the following:

1. Removes tmuxinator alias file:
   - `${XDG_CONFIG_HOME:-$HOME/.config}/tmuxinator/<project>.yml`
2. Prompts to remove (if present):
   - `developer/projects/<project>.override.yml`
   - `templates/projects/<project>.yml`

Use non-interactive removal:

```bash
twf remove my-workflow --yes
```

## Installation modes

### 1) Bootstrap (recommended)

```bash
curl -fsSL "https://raw.githubusercontent.com/R4YM3/tmuxinator-team-workflows/main/scripts/bootstrap.sh" | bash
```

Default bootstrap settings:

- Repo URL: `https://github.com/R4YM3/tmuxinator-team-workflows.git`
- Install root: `~/.local/share/twf`
- CLI symlink: `~/.local/bin/twf`

Optional overrides:

```bash
curl -fsSL "https://raw.githubusercontent.com/R4YM3/tmuxinator-team-workflows/main/scripts/bootstrap.sh" | TWF_REPO_URL="https://github.com/R4YM3/tmuxinator-team-workflows.git" TWF_INSTALL_ROOT="$HOME/.local/share/twf" TWF_BIN_DIR="$HOME/.local/bin" bash
```

### 2) Local repo clone

```bash
git clone git@github.com:R4YM3/tmuxinator-team-workflows.git
cd tmuxinator-team-workflows
./twf install --yes
```

## How install works

`install.sh` links team templates from `templates/projects/*.yml` into tmuxinator:

- `~/.config/tmuxinator/<project>.yml` -> `templates/projects/<project>.yml`

It also writes installer metadata to `.internal/`:

- `.internal/env.sh`
- `.internal/install-manifest.txt`
- `.internal/INFO.md`

and optionally adds a shell rc block that sources `.internal/env.sh`.

Environment variables used by template rendering:

- `REPOSITORIES_ROOT`
- `TEAM_WORKFLOWS_REPO_DIR`
- `TEAM_WORKFLOWS_HELPER_FILE`

## Project structure

```text
.
├── twf
├── install.sh
├── uninstall.sh
├── scripts/
│   ├── bootstrap.sh
│   ├── doctor.sh
│   ├── new-workflow.sh
│   └── validate-workflows.sh
├── templates/
│   ├── helpers/
│   ├── partials/
│   └── projects/
└── developer/
    └── projects/
```

## Template model

- Shared team templates live in `templates/projects/`.
- Reusable partials live in `templates/partials/`.
- Ruby helper methods live in `templates/helpers/workflow.rb`.
- Developer overrides live in `developer/projects/*.override.yml`.

Example project template pattern:

```yaml
<%
Kernel.load ENV.fetch("TEAM_WORKFLOWS_HELPER_FILE")
override_data = load_project_override("my-workflow")
%>

windows:
<%= include_window("example-app", folder: ".", overrides: partial_override(override_data, "example-app")) %>
<%= render_extra_windows(override_data) %>
```

## Troubleshooting

Validate templates:

```bash
twf validate
```

Environment and installation diagnostics:

```bash
twf doctor
```

Reinstall links/config:

```bash
twf install
```

Update twf repo and re-run install:

```bash
twf update
```

## Smoke test checklist

```bash
bash -n twf
bash -n scripts/bootstrap.sh
./twf help
./twf version
./twf validate
./twf check
./twf add demo --dry-run
```

Expected failure checks:

- `twf add demo` fails when `~/.config/tmuxinator/demo.yml` already exists.
- `twf add demo` fails when current directory is not empty with scaffold paths.

## Uninstall

Remove global twf CLI install:

```bash
twf uninstall
```

This removes:

- CLI link (default: `~/.local/bin/twf`)
- install root (default: `~/.local/share/twf`, when confirmed)

It does **not** remove tmuxinator project aliases; use `twf remove <project>` for that.

## License

MIT
