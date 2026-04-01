# tmuxinator-team-workflows

`twf` helps teams run development workflows with less setup friction and fewer local differences.

It keeps team workflows consistent while still allowing developer-level overrides.

## Why teams use `twf`

- Onboarding is faster because setup is guided and repeatable.
- Local environments are more consistent across developers.
- Daily startup friction is reduced to a small command flow.
- Team defaults and personal overrides can coexist without conflict.

## Try it in 30 seconds

```bash
twf add
twf start
```

That flow creates a runnable project workflow, prepares your environment, and starts your session.

Without `twf`, developers usually stitch setup together manually.
With `twf`, setup and startup are explicit, repeatable, and easier to debug.

## Core Concepts

- **project** = runnable development workflow
- **service** = reusable workflow unit (for example: web, api, worker, redis)
- **command** = executable run instruction
- **requirements** = what must be installed to support projects and services
- **environment setup** = installing machine and project prerequisites
- **runtime** = workflow execution

## Quickstart

Install globally:

```bash
curl -fsSL "https://raw.githubusercontent.com/R4YM3/tmuxinator-team-workflows/main/scripts/bootstrap.sh" | bash && exec "$SHELL" -l
```

Create and run your first workflow:

```bash
twf add
twf install
twf start
```

`twf add` can run setup immediately in interactive mode.

## Typical Flow

1. `twf add`
   - detects project/workspace context
   - creates project config
   - links local `.twf/` files
2. `twf install`
   - installs missing environment requirements
   - installs project dependencies
3. `twf start`
   - starts the workflow
   - warns if readiness is incomplete
4. `twf doctor`
   - diagnoses readiness and configuration issues

## Team + Developer Config

Shared and personal settings are separated:

```text
.twf/project.yml
.twf/developer.yml
```

- Team defaults live in project workflow config.
- Developer-specific adjustments live in override config.

## Workspace Detection

If `twf add` runs in a directory with multiple direct child repositories, `twf` can create one workspace workflow automatically.

## Commands

Most commands infer the current project when run inside a linked repository.

### Project

- `twf add [--dry-run] [--no-install]`
- `twf remove`

### Environment Setup

- `twf install [--yes] [--plan] [--no-project-deps] [--verbose]`

### Services

- `twf service add`
- `twf service remove`
- `twf service list`
- `twf service install`

### Runtime and Health

- `twf start`
- `twf stop`
- `twf status`
- `twf doctor`

## CLI Output Style

`twf` uses concise, scan-friendly output by default:

- `◆` section heading
- `...` in progress
- `✓` success
- `!` warning
- `✖` blocking error

When a command fails, `twf` prints a structured error block with a stable code, reason, and next actions.

Error code groups:

- `RUN-*` runtime/start issues
- `INS-*` install issues
- `ENV-*` environment state issues
- `CFG-*` configuration issues
- `SYS-*` internal/system issues

Example:

```text
✖ Start blocked (RUN-022)

Reason
  Strict mode is enabled and required environment setup is incomplete.

What you can do
  • Run: twf install
  • Check status: twf doctor
  • Retry (strict): twf start --strict
```

### Other

- `twf demo`
- `twf validate`
- `twf list`
- `twf update`
- `twf uninstall`
- `twf version`

## Workflow Structure

Workflows are stored in a central root and linked into local repositories.

```text
<team-workflows-root>/
├── project-a/
│   ├── project.yml
│   └── developer.yml
```

Example files:

- `examples/my-project/project.yml`
- `examples/my-project/developer.yml`

## Testing

Run locally:

```bash
tests/scripts/test-flow
tests/scripts/test-services
tests/scripts/test-docker
```

## License

MIT
