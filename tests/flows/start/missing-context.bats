#!/usr/bin/env bats

setup() {
  source tests/helpers/common.bash
  setup_test_env
}

@test "oo start fails when project cannot be inferred" {
  mkdir -p "$TEST_ROOT/random-dir"
  cd "$TEST_ROOT/random-dir"

  run_twf start
  [ "$status" -ne 0 ]
  assert_output_contains "Missing project name and could not infer"
}
