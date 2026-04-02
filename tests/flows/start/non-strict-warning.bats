#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"

  local repo="$TEST_ROOT/repos/start-warning"
  create_git_repo "$repo"
  touch "$repo/package.json"
  cd "$repo"
  run_oo add
  [ "$status" -eq 0 ]

  run_oo service add containers
  [ "$status" -eq 0 ]
}

@test "oo start warns when requirements are missing in non-strict mode" {
  cd "$TEST_ROOT/repos/start-warning"

  run_oo start --no-attach
  [ "$status" -eq 0 ]
  assert_output_contains "RUN-012"
  assert_output_contains "Runtime may be degraded"
}
