#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"
}

@test "bootstrap script exists and oo help works in clean container" {
  run test -f "$REPO_ROOT/scripts/bootstrap.sh"
  [ "$status" -eq 0 ]

  run_twf help
  [ "$status" -eq 0 ]
}

@test "oo add works in clean container workspace" {
  local repo="$TEST_ROOT/repos/docker-project"
  create_git_repo "$repo"
  touch "$repo/package.json"
  cd "$repo"

  run_twf add
  [ "$status" -eq 0 ]
  run test -f "$TEAM_ROOT/docker-project/workflow.yaml"
  [ "$status" -eq 0 ]
}
