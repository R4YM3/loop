#!/usr/bin/env bash
set -euo pipefail

SERVICE_VERSION="1"

check_service() {
  command -v go >/dev/null 2>&1
}

install_service() {
  if check_service; then
    echo "[ok] go already installed"
    return 0
  fi

  if command -v brew >/dev/null 2>&1; then
    echo "[info] Installing go with Homebrew"
    brew install go
    return 0
  fi

  echo "[error] Could not install go automatically" >&2
  return 1
}

case "${1:-}" in
version)
  echo "$SERVICE_VERSION"
  ;;
check)
  check_service
  ;;
install)
  install_service
  ;;
*)
  echo "Usage: go.sh <version|check|install>" >&2
  exit 1
  ;;
esac
