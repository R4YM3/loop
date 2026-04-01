#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"

  local repo="$TEST_ROOT/repos/strict-project"
  create_git_repo "$repo"
  touch "$repo/package.json"
  cd "$repo"
  run_twf add
  [ "$status" -eq 0 ]

  run_twf service add containers
  [ "$status" -eq 0 ]
}

@test "twf start --strict fails when service is not ready" {
  cd "$TEST_ROOT/repos/strict-project"

  run_twf start --strict --no-attach
  [ "$status" -ne 0 ]
  assert_output_contains "RUN-022"
  assert_output_contains "Start blocked"
}
