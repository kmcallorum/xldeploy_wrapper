#!/usr/bin/env bats

load 'test_helper.bash'

setup() {
  export ENV="DEV"
  export APP_NAME="test-app"
  export PACKAGE_VERSION="1.0.0"
  export OVERRIDE_VERSION=""
  export XLD_USER="dummy"
  export XLD_PASS="dummy"
  export XLD_SERVER="http://localhost:4516"
  export TEAMS_WEBHOOK_URL="http://localhost:9999"
}

@test "entrypoint.sh sets PACKAGE_ID correctly with PACKAGE_VERSION" {
  run ./../.github/actions/xldeploy-deploy/entrypoint.sh
  [ "$status" -eq 0 ]
  [[ "$output" =~ "PACKAGE_ID=test-app:1.0.0" ]]
}
