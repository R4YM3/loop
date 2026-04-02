# Loop (oo)

Stop wasting time setting up dev environments. Start shipping faster.

Loop is a terminal-first CLI that helps teams define, install, and run consistent local development workflows with minimal setup friction.

No onboarding guesswork. No setup drift. No "works on my machine" loops.

## Why teams use Loop

- **Faster onboarding**: teams can get running through a guided setup flow.
- **Consistent environments**: teams start the same workflow the same way.
- **Lower daily friction**: startup becomes a short, repeatable command sequence.
- **Team defaults + personal overrides**: shared standards without losing local flexibility.

## Try it in 30 seconds

```bash
oo add
oo start
```

That flow creates a runnable workflow, prepares your environment (if needed), and starts your development session.

## What problem Loop solves

Without Loop, teams often:

- manually document setup steps,
- rely on tribal knowledge,
- run slightly different local environments,
- spend time debugging inconsistent startup behavior.

With Loop:

- setup is explicit,
- workflows are repeatable,
- issues are diagnosable.

## Core concepts

- **workflow**: runnable development workflow
- **service**: reusable workflow unit (for example: web, api, worker, redis)
- **command**: executable run instruction
- **requirements**: what must be installed
- **environment setup**: preparing machine and workflow prerequisites
- **runtime**: executing the workflow

## Installation

Install globally:

```bash
curl -fsSL "https://raw.githubusercontent.com/R4YM3/tmuxinator-team-workflows/main/scripts/bootstrap.sh" | bash && exec "$SHELL" -l
```

Verify:

```bash
oo version
oo help
```

Uninstall:

```bash
oo uninstall
```

## Quickstart

```bash
oo add
oo install
oo start
```

Notes:

- `oo add` can run setup immediately in interactive mode.
- `oo install` ensures your environment and dependencies are ready.
- `oo start` launches your workflow.

## Typical workflow

1. **Create or link a workflow**

   ```bash
   oo add
   ```

   - detects workflow or workspace context,
   - creates workflow config,
   - links `.oo/` files.

2. **Install requirements**

   ```bash
   oo install
   ```

   - installs missing system requirements,
   - installs workflow dependencies.

3. **Start your workflow**

   ```bash
   oo start
   ```

   - runs services and commands,
   - warns if setup is incomplete.

4. **Diagnose issues**

   ```bash
   oo doctor
   ```

   - checks environment and workflow readiness,
   - highlights blocking issues and next actions.

## Command overview

### Workflow

- `oo add [--dry-run] [--no-install]`
- `oo remove`

### Environment setup

- `oo install [--yes] [--plan] [--no-workflow-deps] [--verbose]`

### Services

- `oo service add`
- `oo service remove`
- `oo service list`
- `oo service install`

### Runtime and health

- `oo start`
- `oo stop`
- `oo status`
- `oo doctor [--verbose]`

### Other

- `oo demo`
- `oo validate`
- `oo list`
- `oo update`
- `oo uninstall`
- `oo version`

## CLI output style

Loop uses concise, scan-friendly output:

- `◆` section heading
- `...` in progress
- `✓` success
- `!` warning
- `✖` blocking error

Example error:

```text
✖ Start blocked (RUN-022)

Reason
  Strict mode requires a fully prepared environment, but setup is incomplete.

What you can do
  • Run: oo install
  • Check status: oo doctor
  • Retry (strict): oo start --strict
```

## Error code groups

- `RUN-*` runtime/start issues
- `INS-*` install issues
- `ENV-*` environment state issues
- `CFG-*` configuration issues
- `SYS-*` internal/system issues

## Team + override config

Loop separates shared and personal configuration:

```text
.oo/workflow.yaml     # team defaults
.oo/override.yaml   # personal overrides
```

This gives teams consistency while preserving safe local customization.

## Workspace support

If you run `oo add` in a directory with multiple repositories, Loop can automatically create a workspace workflow.

## Workflow structure

Workflows live in a central root and are linked into local repositories:

```text
<team-workflows-root>/
├── workflow-a/
│   ├── workflow.yaml
│   └── override.yaml
```

## Dependency detection

Loop detects workflow dependency systems automatically:

- `package.json` -> `npm install`
- `requirements.txt` -> `pip3 install -r requirements.txt`
- `Gemfile` -> `bundle install`
- `go.mod` -> `go mod download`

## Common flows

### First-time setup

```bash
oo add
oo start
```

### Controlled setup

```bash
oo add --dry-run
oo add
oo install --workflow <name>
oo doctor
oo start <name>
```

### Non-interactive setup

```bash
oo add
oo install --yes
oo start
```

### Adding a service

```bash
oo service add redis
oo install
oo start
```

## What Loop is (and is not)

Loop is:

- a local development workflow orchestrator,
- a consistency layer for teams,
- a CLI-first workflow tool.

Loop is not:

- a deployment tool,
- a production orchestrator,
- a replacement for package managers.

## Testing

Run locally:

```bash
tests/scripts/test-flow
tests/scripts/test-services
tests/scripts/test-docker
```

## License

MIT

## Final note

Loop is about reducing friction without removing flexibility.

Define workflows once. Run them the same way every day.
