# Helper for Bats tests

# Stub curl to prevent real HTTP calls
curl() {
  echo "curl called with: $@"
  if [[ "$@" =~ "query" ]]; then
    echo '[{"package":"test-app:0.9.0"}]'
  fi
}
