#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"

  local repo="$TEST_ROOT/repos/strict-workflow"
  create_git_repo "$repo"
  touch "$repo/package.json"
  cd "$repo"
  run_oo add
  [ "$status" -eq 0 ]

  run_oo service add containers
  [ "$status" -eq 0 ]
}

@test "oo start --strict fails when service is not ready" {
  cd "$TEST_ROOT/repos/strict-workflow"

  run_oo start --strict --no-attach
  [ "$status" -ne 0 ]
  assert_output_contains "RUN-022"
  assert_output_contains "Start blocked"
}
