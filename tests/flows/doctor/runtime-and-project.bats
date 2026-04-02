#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"

  local repo="$TEST_ROOT/repos/doctor-workflow"
  create_git_repo "$repo"
  touch "$repo/package.json"
  cd "$repo"
  run_oo add
  [ "$status" -eq 0 ]
}

@test "oo doctor shows runtime diagnostics and inferred workflow checks" {
  cd "$TEST_ROOT/repos/doctor-workflow"

  run_oo doctor
  [ "$status" -eq 0 ]
  assert_output_contains "◆ Doctor"
  assert_output_contains "Workflow: doctor-workflow"
  assert_output_contains "✓ System healthy"
}
