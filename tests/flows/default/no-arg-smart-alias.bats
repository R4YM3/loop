#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
}

@test "oo with no args runs add in non-workflow repo" {
  local repo="$TEST_ROOT/repos/default-add"
  create_git_repo "$repo"
  cd "$repo"

  local mock_bin="$TEST_ROOT/bin"
  create_mock_command "$mock_bin" "tmux" 'if [[ "${1:-}" == "has-session" ]]; then exit 1; fi; exit 0'
  create_mock_command "$mock_bin" "tmuxinator" 'if [[ "${1:-}" == "start" ]]; then exit 0; fi; exit 0'

  run_oo_with_path "$mock_bin"
  [ "$status" -eq 0 ]
  assert_output_contains "Created workflow template"
  assert_output_contains "◆ Installing default-add"
  assert_output_contains "Session started"
  assert_file_exists "$repo/.oo/workflow.yaml"
}

@test "oo with no args runs install when linked workflow is not installed" {
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"

  local repo="$TEST_ROOT/repos/default-install"
  create_git_repo "$repo"
  cd "$repo"

  run_oo add --no-install
  [ "$status" -eq 0 ]

  cat >"$TEAM_ROOT/default-install/override.yaml" <<'EOF'
services:
  enabled:
    - python
  config: {}
EOF

  local mock_bin="$TEST_ROOT/bin"
  create_mock_command "$mock_bin" "tmux" 'if [[ "${1:-}" == "has-session" ]]; then exit 1; fi; exit 0'
  create_mock_command "$mock_bin" "tmuxinator" 'if [[ "${1:-}" == "start" ]]; then exit 0; fi; exit 0'

  run_oo_with_path "$mock_bin"
  [ "$status" -eq 0 ]
  assert_output_contains "◆ Installing default-install"
  assert_output_contains "Session started"
}

@test "oo with no args runs start when linked workflow is already installed" {
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"

  local repo="$TEST_ROOT/repos/default-start"
  create_git_repo "$repo"
  cd "$repo"

  run_oo add --no-install
  [ "$status" -eq 0 ]

  cat >"$TEAM_ROOT/default-start/override.yaml" <<'EOF'
services:
  enabled:
    - python
  config: {}
EOF

  local mock_bin="$TEST_ROOT/bin"
  create_mock_command "$mock_bin" "tmux" 'if [[ "${1:-}" == "has-session" ]]; then exit 1; fi; exit 0'
  create_mock_command "$mock_bin" "tmuxinator" 'if [[ "${1:-}" == "start" ]]; then exit 0; fi; exit 0'

  run_oo_with_path "$mock_bin" install --workflow default-start --yes --no-workflow-deps
  [ "$status" -eq 0 ]

  run_oo_with_path "$mock_bin"
  [ "$status" -eq 0 ]
  assert_output_contains "[oo] Workflow: default-start"
  assert_output_contains "Session started"
}

@test "oo with no args shows help outside repo context" {
  local dir="$TEST_ROOT/scratch"
  mkdir -p "$dir"
  cd "$dir"

  run_oo
  [ "$status" -eq 0 ]
  assert_output_contains "Common commands:"
}
