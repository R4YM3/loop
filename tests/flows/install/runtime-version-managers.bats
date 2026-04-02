#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
  export TEAM_ROOT="$TEST_ROOT/team-workflows"
  configure_workflow_root "$TEAM_ROOT"
}

@test "oo install auto-switches Python runtime with pyenv when required" {
  local repo="$TEST_ROOT/repos/python-runtime-workflow"
  create_git_repo "$repo"
  printf 'requests==2.31.0\n' >"$repo/requirements.txt"
  printf '9.9.9\n' >"$repo/.python-version"
  cd "$repo"

  run_oo add --no-install
  [ "$status" -eq 0 ]

  cat >"$TEAM_ROOT/python-runtime-workflow/override.yaml" <<'EOF'
services:
  enabled: []
  config: {}
EOF

  local mock_bin="$TEST_ROOT/bin"
  create_mock_command "$mock_bin" "pyenv" '
case "${1:-}" in
  init) exit 0 ;;
  install) touch "$TEST_ROOT/pyenv.install.called"; exit 0 ;;
  shell) touch "$TEST_ROOT/pyenv.shell.called"; exit 0 ;;
  *) exit 0 ;;
esac
'
  create_mock_command "$mock_bin" "python" '
if [[ "${1:-}" == "-m" && "${2:-}" == "pip" ]]; then
  touch "$TEST_ROOT/python.pip.called"
  exit 0
fi
exit 0
'

  run_oo_with_path "$mock_bin" install --yes
  [ "$status" -eq 0 ]
  assert_file_exists "$TEST_ROOT/pyenv.install.called"
  assert_file_exists "$TEST_ROOT/pyenv.shell.called"
  assert_file_exists "$TEST_ROOT/python.pip.called"
}

@test "oo install auto-switches Ruby runtime with rbenv when required" {
  local repo="$TEST_ROOT/repos/ruby-runtime-workflow"
  create_git_repo "$repo"
  cat >"$repo/Gemfile" <<'EOF'
source "https://rubygems.org"
gem "rake"
EOF
  printf '9.9.9\n' >"$repo/.ruby-version"
  cd "$repo"

  run_oo add --no-install
  [ "$status" -eq 0 ]

  cat >"$TEAM_ROOT/ruby-runtime-workflow/override.yaml" <<'EOF'
services:
  enabled: []
  config: {}
EOF

  local mock_bin="$TEST_ROOT/bin"
  create_mock_command "$mock_bin" "rbenv" '
case "${1:-}" in
  init) exit 0 ;;
  install) touch "$TEST_ROOT/rbenv.install.called"; exit 0 ;;
  shell) touch "$TEST_ROOT/rbenv.shell.called"; exit 0 ;;
  rehash) exit 0 ;;
  *) exit 0 ;;
esac
'
  create_mock_command "$mock_bin" "bundle" 'touch "$TEST_ROOT/bundle.called"; exit 0'

  run_oo_with_path "$mock_bin" install --yes
  [ "$status" -eq 0 ]
  assert_file_exists "$TEST_ROOT/rbenv.install.called"
  assert_file_exists "$TEST_ROOT/rbenv.shell.called"
  assert_file_exists "$TEST_ROOT/bundle.called"
}
