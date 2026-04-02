# Tests

This test suite is organized by product behavior, not internals.
It serves as both validation and living documentation for oo business logic.

## Run locally

```bash
tests/scripts/test-flow
tests/scripts/test-services
tests/scripts/test-docker
tests/scripts/test-all
tests/scripts/test-changed
tests/scripts/test-act
```

## Run GitHub workflows locally with act

```bash
brew install act
tests/scripts/test-act
tests/scripts/test-act changes
tests/scripts/test-act full
```

- `test-act` (quick mode) runs `act` change-detection jobs plus native test scripts.
- `test-act changes` runs only `act` change-detection jobs (fast sanity check).
- `test-act full` runs full `act` Linux jobs for flow + service workflows, then native scripts.
- Set `OO_SKIP_DOCKER=1` to skip the native docker integration step during local runs.
- `wsl-smoke` is `windows-latest` and is not run via `act`.

## Structure

- `tests/flows/`: end-to-end CLI behavior
- `tests/services/contract/`: one-file-per-service contract tests
- `tests/integration/docker/`: clean-environment integration tests
- `tests/helpers/`: shared setup and assertions
- `tests/fixtures/`: reusable fixture templates

## Business rules mapped to flow tests

- `oo add` single repo flow -> `tests/flows/add/single-repo.bats`
- `oo add` workspace auto-detect -> `tests/flows/add/workspace-auto-detect.bats`
- `oo add --dry-run` writes nothing -> `tests/flows/add/dry-run.bats`
- `oo start` workflow inference -> `tests/flows/start/infer-workflow.bats`
- `oo start --strict` behavior -> `tests/flows/start/strict-mode.bats`
- `oo service` inferred context -> `tests/flows/service/inferred-workflow-context.bats`
- `oo doctor` runtime/workflow checks -> `tests/flows/doctor/runtime-and-workflow.bats`
- `oo status` output -> `tests/flows/status/sessions-and-health.bats`
- `oo stop` flow -> `tests/flows/stop/stop-session.bats`
