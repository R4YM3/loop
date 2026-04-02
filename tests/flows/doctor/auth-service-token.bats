#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"

  local repo="$TEST_ROOT/repos/doctor-auth"
  create_git_repo "$repo"
  touch "$repo/package.json"
  cd "$repo"
  run_oo add --no-install
  [ "$status" -eq 0 ]

  cat >"$TEAM_ROOT/doctor-auth/override.yaml" <<'EOF'
services:
  enabled:
    - node
  config: {}
auth:
  services:
    node:
      token_env: NODE_SERVICE_TOKEN
EOF
}

@test "oo doctor reports missing service auth token" {
  cd "$TEST_ROOT/repos/doctor-auth"

  run_oo doctor
  [ "$status" -eq 0 ]
  assert_output_contains "auth: node requires env NODE_SERVICE_TOKEN"
  assert_output_contains "Setup incomplete"
}
