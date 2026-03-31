#!/usr/bin/env bash

run_service_contract() {
  local service_name="$1"
  local script="$REPO_ROOT/services/$service_name.sh"

  [[ -x "$script" ]]

  run bash "$script" version
  [ "$status" -eq 0 ]
  [ -n "$output" ]

  run bash "$script" check
  [ "$status" -ne 127 ]
}
