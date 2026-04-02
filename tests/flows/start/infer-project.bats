#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"

  local repo="$TEST_ROOT/repos/infer-workflow"
  create_git_repo "$repo"
  touch "$repo/package.json"
  cd "$repo"
  run_oo add
  [ "$status" -eq 0 ]
}

@test "oo start infers workflow from local .oo link" {
  local repo="$TEST_ROOT/repos/infer-workflow"
  cd "$repo"

  run_oo start --no-attach
  [ "$status" -eq 0 ]
  assert_output_contains "[oo] Workflow: infer-workflow"
  assert_output_contains "✔ Session started"
}
