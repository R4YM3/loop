# Loop Project Description

## Product Summary

`oo` (Loop) is a terminal-first CLI for defining and running team development workflows.

It is used to:

- create project/workspace workflow config,
- prepare local environment setup,
- manage reusable services,
- run and diagnose project workflows.

Target platform: macOS + Linux (WSL counts as Linux context).

## Core Terminology

- **project** = runnable development workflow
- **service** = reusable workflow unit (e.g. web, api, worker, redis)
- **command** = executable run instruction
- **requirements** = what must be installed to support project/services
- **environment setup** = install machine/project prerequisites
- **runtime** = workflow execution

Important: command sources (like `package.json` scripts) are command sources, not services.

## Installation

Global install:

```bash
curl -fsSL "https://raw.githubusercontent.com/R4YM3/tmuxinator-team-workflows/main/scripts/bootstrap.sh" | bash && exec "$SHELL" -l
```

What install does (high level):

- installs/updates `oo` runtime locally,
- creates CLI symlink (`oo`) in user bin path,
- ensures shell can resolve `oo`,
- prepares baseline prerequisites for using the CLI.

Verify install:

```bash
oo version
oo help
```

Uninstall:

```bash
oo uninstall
```

## CLI Surface

Top-level commands:

- `oo add [project-name] [--dry-run] [--no-install]`
- `oo remove <project-name> [--yes]`
- `oo install [--project <project>] [--yes] [--plan] [--no-project-deps] [--verbose]`
- `oo service add <service> [--project <project>]`
- `oo service remove <service> [--project <project>]`
- `oo service list [--project <project> | --global]`
- `oo service install [--project <project>] [--yes] | --global [--yes]`
- `oo start <project> [args...] [--strict]`
- `oo stop <project>`
- `oo status`
- `oo doctor [--project <project> | --global] [--fix] [--yes] [--verbose]`
- `oo validate`
- `oo list`
- `oo demo [target-dir]`
- `oo update`
- `oo uninstall [--yes]`
- `oo version`
- `oo help`

Most commands can infer project context when run inside a linked repository.

## Output and Return Behavior

`oo` uses concise CLI output with a calm default mode.

Default symbols:

- `◆` section heading
- `...` in progress
- `✓` success
- `!` warning
- `✖` blocking error

Failure blocks include:

- stable code (`INS-0xx`, `RUN-0xx`, `DOC-0xx`)
- short title
- `Reason`
- `What you can do`

Suggested code domains:

- `RUN` runtime/start flows
- `INS` install flows
- `ENV` environment issues
- `CFG` configuration issues
- `SYS` internal/system issues

Exit behavior:

- `0` on success
- non-zero on blocking failures

Examples:

- `oo add`
  - creates config and links,
  - can run setup immediately,
  - supports skipping setup with `--no-install`
- `oo install`
  - installs required environment setup,
  - installs project dependencies,
  - supports `--plan` preview mode
- `oo start`
  - starts workflow,
  - warns in non-strict mode when setup is incomplete,
  - fails in strict mode with code `RUN-022`
- `oo doctor`
  - prints grouped diagnostics (`Environment`, `Project`, result)
  - defaults to collapsed healthy output
  - supports `--verbose` for expanded checks

## Main Developer Flows

### Flow A: First-Time Setup

1. `oo add`
2. setup runs automatically in interactive mode (or run `oo install`)
3. `oo start`

### Flow B: Controlled Setup

1. `oo add --dry-run`
2. `oo add`
3. `oo install --project <name>`
4. `oo doctor`
5. `oo start <name>`

### Flow C: Non-Interactive Setup

1. `oo add`
2. `oo install --yes`
3. `oo start`

### Flow D: Existing Project Service Update

1. `oo service add redis`
2. `oo install` (or `oo service install`)
3. `oo start`

## Install Behavior Details

`oo install` does both:

1. machine readiness requirements
2. project dependencies

Default behavior:

- setup and dependency install run without repeated prompts,
- supports `--yes` for non-interactive execution,
- supports `--plan` for trust-first preview,
- supports `--no-project-deps` to limit scope to environment setup.

Project dependency installers are detected from project root:

- `package.json` -> `npm install`
- `requirements.txt` -> `pip3 install -r requirements.txt`
- `Gemfile` -> `bundle install`
- `go.mod` -> `go mod download`

## Runtime and Readiness Behavior

- `oo` tracks per-project service install state/version/config hash.
- `oo start` checks readiness before starting.
- Non-strict mode:
  - warns when requirements are missing,
  - still starts runtime.
- Strict mode (`--strict`):
  - fails when required readiness is missing.

## Config and Workspace Model

`oo` separates shared and personal config:

- `.oo/workflow.yaml`
- `.oo/override.yaml`

Workflow root stores per-project config:

- `<team-workflows-root>/<project>/workflow.yaml`
- `<team-workflows-root>/<project>/override.yaml`

Workspace mode:

- if `oo add` runs in a directory with multiple direct child codebases, it can create one workspace workflow automatically.

## Responsibility Boundaries

`oo` is responsible for:

- project/workspace detection,
- service selection/management,
- requirements intent,
- install/start UX and diagnostics.

`oo` is not:

- a deployment tool,
- a production orchestrator,
- a replacement for app package managers.

## README Generation Notes

Use this document as source material when generating a public README.

Desired README qualities:

- clear and practical,
- concept-first,
- focused on real developer usage,
- includes install + quickstart + command reference + flows,
- consistent terminology.
