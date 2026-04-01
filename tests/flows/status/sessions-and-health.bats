#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"

  local repo="$TEST_ROOT/repos/status-project"
  create_git_repo "$repo"
  touch "$repo/package.json"
  cd "$repo"
  run_twf add
  [ "$status" -eq 0 ]
}

@test "oo status shows running sessions section and project health" {
  run_twf status
  [ "$status" -eq 0 ]
  assert_output_contains "Running project sessions"
  assert_output_contains "Project service health"
  assert_output_contains "status-project"
}
