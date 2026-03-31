#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"

  local repo="$TEST_ROOT/repos/infer-project"
  create_git_repo "$repo"
  touch "$repo/package.json"
  cd "$repo"
  run_twf add
  [ "$status" -eq 0 ]
}

@test "twf start infers project from local .twf link" {
  local repo="$TEST_ROOT/repos/infer-project"
  cd "$repo"

  run_twf start --no-attach
  [ "$status" -eq 0 ]
  assert_output_contains "[twf] Project: infer-project"
  assert_output_contains "✔ Session started"
}
