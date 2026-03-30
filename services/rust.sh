#!/usr/bin/env bash
set -euo pipefail

SERVICE_VERSION="1"

check_service() {
  command -v rustc >/dev/null 2>&1 && command -v cargo >/dev/null 2>&1
}

install_service() {
  if check_service; then
    echo "[ok] rust toolchain already installed"
    return 0
  fi

  if command -v brew >/dev/null 2>&1; then
    echo "[info] Installing rust with Homebrew"
    brew install rust
    return 0
  fi

  if command -v curl >/dev/null 2>&1; then
    echo "[info] Installing rust with rustup"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    return 0
  fi

  echo "[error] Could not install rust automatically" >&2
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
  echo "Usage: rust.sh <version|check|install>" >&2
  exit 1
  ;;
esac
