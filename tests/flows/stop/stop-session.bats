#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
}

@test "twf stop reports when session is not running" {
  run_twf stop missing-project
  [ "$status" -eq 0 ]
  assert_output_contains "No running tmux session found"
}
