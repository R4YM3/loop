#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"

  local repo="$TEST_ROOT/repos/auth-source"
  create_git_repo "$repo"
  touch "$repo/package.json"
  cd "$repo"
  run_oo add --no-install
  [ "$status" -eq 0 ]

  cat >"$TEAM_ROOT/auth-source/override.yaml" <<'EOF'
services:
  enabled: []
  config: {}
auth:
  sources:
    npm:
      registry: https://npm.company.example/
      token_env: NPM_TOKEN
EOF
}

@test "oo install blocks when source auth token is missing" {
  cd "$TEST_ROOT/repos/auth-source"

  run_oo install --yes
  [ "$status" -ne 0 ]
  assert_output_contains "INS-131"
  assert_output_contains "Required env: NPM_TOKEN"
}

@test "oo install resolves source token from .env" {
  local mock_bin="$TEST_ROOT/bin"
  create_mock_command "$mock_bin" "npm" '[[ -n "${NPM_TOKEN:-}" ]] && touch "$TEST_ROOT/npm.auth.called"'
  printf 'NPM_TOKEN=local-token\n' >"$TEST_ROOT/repos/auth-source/.env"

  cd "$TEST_ROOT/repos/auth-source"
  run_oo_with_path "$mock_bin" install --yes

  [ "$status" -eq 0 ]
  assert_file_exists "$TEST_ROOT/npm.auth.called"
}
