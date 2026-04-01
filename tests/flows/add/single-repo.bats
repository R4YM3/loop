#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"
}

@test "oo add creates single project workflow and links" {
  local repo="$TEST_ROOT/repos/my-project"
  create_git_repo "$repo"
  touch "$repo/package.json"

  cd "$repo"
  run_twf add
  [ "$status" -eq 0 ]

  assert_file_exists "$TEAM_ROOT/my-project/workflow.yaml"
  assert_file_exists "$TEAM_ROOT/my-project/override.yaml"
  run grep -q -- "- node" "$TEAM_ROOT/my-project/override.yaml"
  [ "$status" -eq 0 ]

  assert_symlink_points_to "$XDG_CONFIG_HOME/tmuxinator/my-project.yml" "$TEAM_ROOT/my-project/workflow.yaml"
  assert_symlink_points_to "$repo/.oo/workflow.yaml" "$TEAM_ROOT/my-project/workflow.yaml"
  assert_symlink_points_to "$repo/.oo/override.yaml" "$TEAM_ROOT/my-project/override.yaml"
}
