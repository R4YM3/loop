#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"

  local repo="$TEST_ROOT/repos/doctor-project"
  create_git_repo "$repo"
  touch "$repo/package.json"
  cd "$repo"
  run_twf add
  [ "$status" -eq 0 ]
}

@test "twf doctor shows runtime diagnostics and inferred project checks" {
  cd "$TEST_ROOT/repos/doctor-project"

  run_twf doctor
  [ "$status" -eq 0 ]
  assert_output_contains "[twf doctor] Runtime"
  assert_output_contains "- doctor-project"
}
