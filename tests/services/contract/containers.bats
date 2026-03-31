#!/usr/bin/env bats

setup() { source tests/helpers/common.bash; source tests/helpers/service_contract.bash; setup_test_env; }

@test "service contract: containers" { run_service_contract containers; }
