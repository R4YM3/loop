#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
}

@test "analytics is off by default in non-interactive runs" {
  run_oo version
  [ "$status" -eq 0 ]
  [[ ! -f "$XDG_DATA_HOME/oo/state/analytics/events.jsonl" ]]
}

@test "analytics can be enabled with env override" {
  run env HOME="$HOME" XDG_CONFIG_HOME="$XDG_CONFIG_HOME" XDG_DATA_HOME="$XDG_DATA_HOME" OO_ANALYTICS=1 "$OO_BIN" version
  [ "$status" -eq 0 ]
  [ -f "$XDG_DATA_HOME/oo/state/analytics/events.jsonl" ]
  grep -q '"command":"version"' "$XDG_DATA_HOME/oo/state/analytics/events.jsonl"
}

@test "oo install --no-analytics disables analytics preference" {
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"

  local repo="$TEST_ROOT/repos/analytics-install-workflow"
  create_git_repo "$repo"
  touch "$repo/package.json"
  cd "$repo"
  run_oo add
  [ "$status" -eq 0 ]

  cat >"$TEAM_ROOT/analytics-install-workflow/override.yaml" <<'EOF'
services:
  enabled: []
  config: {}
EOF

  local mock_bin="$TEST_ROOT/bin"
  create_mock_command "$mock_bin" "npm" 'if [[ "$1" == "install" ]]; then exit 0; fi'

  run_oo_with_path "$mock_bin" install --yes --no-analytics
  [ "$status" -eq 0 ]

  run_oo analytics status
  [ "$status" -eq 0 ]
  assert_output_contains "Status: disabled"
}
