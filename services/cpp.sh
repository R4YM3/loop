#!/usr/bin/env bash
set -euo pipefail

SERVICE_VERSION="1"

check_service() {
  command -v c++ >/dev/null 2>&1 || command -v clang++ >/dev/null 2>&1 || command -v g++ >/dev/null 2>&1
}

install_service() {
  if check_service; then
    echo "[ok] C++ compiler already installed"
    return 0
  fi

  if command -v brew >/dev/null 2>&1; then
    echo "[info] Installing LLVM with Homebrew"
    brew install llvm
    return 0
  fi

  echo "[error] Could not install C++ compiler automatically" >&2
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
  echo "Usage: cpp.sh <version|check|install>" >&2
  exit 1
  ;;
esac
