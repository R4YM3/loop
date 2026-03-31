#!/usr/bin/env bats

setup() { source tests/helpers/common.bash; source tests/helpers/service_contract.bash; setup_test_env; }

@test "service contract: worker" { run_service_contract worker; }
