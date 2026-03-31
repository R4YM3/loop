#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"
}

@test "twf add auto-detects workspace mode from direct child repos" {
  local ws="$TEST_ROOT/workspace"
  local frontend="$ws/frontend"
  local api="$ws/api"

  create_git_repo "$frontend"
  create_git_repo "$api"
  touch "$frontend/package.json"
  touch "$api/pyproject.toml"

  cd "$ws"
  run_twf add team-workspace --dry-run
  [ "$status" -eq 0 ]
  assert_output_contains "Mode: workspace"
  assert_output_contains "- frontend"
  assert_output_contains "- api"
  assert_output_contains "node"
  assert_output_contains "python"
}
