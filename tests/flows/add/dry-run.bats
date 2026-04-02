#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"
}

@test "oo add --dry-run writes nothing" {
  local repo="$TEST_ROOT/repos/dry-repo"
  create_git_repo "$repo"
  touch "$repo/package.json"

  cd "$repo"
  run_oo add dry-repo --dry-run
  [ "$status" -eq 0 ]
  assert_output_contains "Dry run: no files were written"

  [ ! -e "$TEAM_ROOT/dry-repo/workflow.yaml" ]
  [ ! -e "$XDG_CONFIG_HOME/tmuxinator/dry-repo.yml" ]
}
