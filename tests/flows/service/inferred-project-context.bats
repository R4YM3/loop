#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"

  local repo="$TEST_ROOT/repos/service-workflow"
  create_git_repo "$repo"
  touch "$repo/package.json"
  cd "$repo"
  run_oo add
  [ "$status" -eq 0 ]
}

@test "oo service add infers current workflow when --workflow is omitted" {
  cd "$TEST_ROOT/repos/service-workflow"

  run_oo service add redis
  [ "$status" -eq 0 ]
  assert_output_contains "inferred 'service-workflow'"

  run grep -q -- "- redis" "$TEAM_ROOT/service-workflow/override.yaml"
  [ "$status" -eq 0 ]
}
