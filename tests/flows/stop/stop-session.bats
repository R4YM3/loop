#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
}

@test "oo stop reports when session is not running" {
  run_oo stop missing-workflow
  [ "$status" -eq 0 ]
  assert_output_contains "No running tmux session found"
}
