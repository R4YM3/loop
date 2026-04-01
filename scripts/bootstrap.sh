#!/usr/bin/env bash
set -euo pipefail

OO_REPO_URL="${OO_REPO_URL:-https://github.com/R4YM3/tmuxinator-team-workflows.git}"
OO_INSTALL_ROOT="${OO_INSTALL_ROOT:-$HOME/.local/share/oo}"
OO_BIN_DIR="${OO_BIN_DIR:-$HOME/.local/bin}"

ok() { printf "\033[1;32m[ok]\033[0m %s\n" "$1"; }
info() { printf "\033[1;34m[info]\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$1"; }
error() { printf "\033[1;31m[error]\033[0m %s\n" "$1" >&2; }

can_prompt_user() {
  [[ -t 0 && -t 1 ]] || [[ -r /dev/tty ]]
}

confirm_install() {
  local prompt="$1"
  local response=""

  if [[ -t 0 ]]; then
    read -r -p "$prompt [Y/n]: " response
  elif [[ -r /dev/tty ]]; then
    read -r -p "$prompt [Y/n]: " response </dev/tty
  else
    return 1
  fi

  [[ -z "${response:-}" || "${response:-}" =~ ^[Yy]$ ]]
}

detect_package_manager() {
  if command -v brew >/dev/null 2>&1; then
    echo "brew"
  elif command -v apt-get >/dev/null 2>&1; then
    echo "apt-get"
  elif command -v dnf >/dev/null 2>&1; then
    echo "dnf"
  elif command -v pacman >/dev/null 2>&1; then
    echo "pacman"
  else
    echo ""
  fi
}

install_requirements() {
  local manager
  manager="$(detect_package_manager)"

  case "$manager" in
  brew)
    info "Installing required dependencies with Homebrew"
    brew install tmux tmuxinator
    ;;
  apt-get)
    info "Installing required dependencies with apt-get"
    sudo apt-get update
    sudo apt-get install -y tmux ruby-full
    sudo gem install tmuxinator
    ;;
  dnf)
    info "Installing required dependencies with dnf"
    sudo dnf install -y tmux ruby rubygems
    sudo gem install tmuxinator
    ;;
  pacman)
    info "Installing required dependencies with pacman"
    sudo pacman -Sy --noconfirm tmux ruby
    sudo gem install tmuxinator
    ;;
  *)
    error "Could not detect a supported package manager for automatic install"
    info "Install these required dependencies manually and rerun bootstrap:"
    echo "  - tmux"
    echo "  - tmuxinator"
    return 1
    ;;
  esac
}

ensure_required_dependencies() {
  local missing=()
  command -v tmux >/dev/null 2>&1 || missing+=("tmux")
  command -v tmuxinator >/dev/null 2>&1 || missing+=("tmuxinator")

  if [[ ${#missing[@]} -eq 0 ]]; then
    ok "Required dependencies are installed (tmux, tmuxinator)"
    return 0
  fi

  warn "Missing required dependencies: ${missing[*]}"
  info "oo requires both tmux and tmuxinator."

  if ! can_prompt_user; then
    error "Cannot prompt for dependency installation in this shell"
    info "Install required dependencies manually, then rerun bootstrap."
    return 1
  fi

  if ! confirm_install "Install missing required dependencies now?"; then
    error "Bootstrap cancelled because required dependencies are missing"
    return 1
  fi

  install_requirements || return 1

  command -v tmux >/dev/null 2>&1 || {
    error "tmux is still missing after installation"
    return 1
  }
  command -v tmuxinator >/dev/null 2>&1 || {
    error "tmuxinator is still missing after installation"
    return 1
  }

  ok "Installed required dependencies (tmux, tmuxinator)"
}

detect_shell_rc_files() {
  local shell_name
  shell_name="$(basename "${SHELL:-}")"

  case "$shell_name" in
  zsh)
    printf '%s\n' "$HOME/.zprofile" "$HOME/.zshrc" "$HOME/.profile"
    ;;
  bash)
    printf '%s\n' "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.profile"
    ;;
  fish)
    printf '%s\n' "$HOME/.config/fish/config.fish"
    ;;
  ksh)
    printf '%s\n' "$HOME/.kshrc" "$HOME/.profile"
    ;;
  sh | dash)
    printf '%s\n' "$HOME/.profile"
    ;;
  *)
    printf '%s\n' "$HOME/.profile"
    ;;
  esac
}

ensure_path_block_in_file() {
  local bin_dir="$1"
  local rc_file="$2"
  local start_marker="# >>> oo path >>>"
  local end_marker="# <<< oo path <<<"

  mkdir -p "$(dirname "$rc_file")"
  [[ -f "$rc_file" ]] || touch "$rc_file"

  if grep -qF "$start_marker" "$rc_file"; then
    ok "PATH block already present in $rc_file"
    return 0
  fi

  if [[ "$rc_file" == *"/config.fish" ]]; then
    {
      printf '\n%s\n' "$start_marker"
      printf 'if not contains "%s" $PATH\n' "$bin_dir"
      printf '  set -gx PATH "%s" $PATH\n' "$bin_dir"
      printf 'end\n'
      printf '%s\n' "$end_marker"
    } >>"$rc_file"
  else
    {
      printf '\n%s\n' "$start_marker"
      printf 'export PATH="%s:$PATH"\n' "$bin_dir"
      printf '%s\n' "$end_marker"
    } >>"$rc_file"
  fi

  ok "Added oo PATH block to $rc_file"
}

ensure_path_persisted() {
  local bin_dir="$1"
  local rc_files=()
  local rc_file

  while IFS= read -r rc_file; do
    [[ -n "$rc_file" ]] || continue
    rc_files+=("$rc_file")
  done < <(detect_shell_rc_files)

  if [[ ${#rc_files[@]} -eq 0 ]]; then
    warn "Could not detect shell rc file from SHELL=${SHELL:-unknown}"
    return 0
  fi

  for rc_file in "${rc_files[@]}"; do
    ensure_path_block_in_file "$bin_dir" "$rc_file"
  done
}

if [[ -z "$OO_REPO_URL" ]]; then
  error "OO_REPO_URL is empty."
  info "Set OO_REPO_URL and rerun, for example:"
  echo "  OO_REPO_URL='https://github.com/R4YM3/tmuxinator-team-workflows.git' bash scripts/bootstrap.sh"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  error "git is required for bootstrap"
  exit 1
fi

ensure_required_dependencies || exit 1

mkdir -p "$(dirname "$OO_INSTALL_ROOT")"

if [[ -d "$OO_INSTALL_ROOT/.git" ]]; then
  info "Updating existing installation at $OO_INSTALL_ROOT"
  git -C "$OO_INSTALL_ROOT" pull --ff-only
elif [[ -e "$OO_INSTALL_ROOT" ]]; then
  error "Install root exists and is not a git checkout: $OO_INSTALL_ROOT"
  info "Remove it manually or choose another location with OO_INSTALL_ROOT"
  exit 1
else
  info "Cloning oo repository into $OO_INSTALL_ROOT"
  git clone "$OO_REPO_URL" "$OO_INSTALL_ROOT"
fi

info "Ensuring latest runtime revision"
git -C "$OO_INSTALL_ROOT" pull --ff-only

mkdir -p "$OO_BIN_DIR"
ln -sfn "$OO_INSTALL_ROOT/oo" "$OO_BIN_DIR/oo"
chmod +x "$OO_INSTALL_ROOT/oo"
ok "Installed CLI symlink: $OO_BIN_DIR/oo"

ensure_path_persisted "$OO_BIN_DIR"

case ":$PATH:" in
*":$OO_BIN_DIR:"*)
  ok "$OO_BIN_DIR is on PATH"
  ;;
*)
  warn "$OO_BIN_DIR is not on PATH"
  info "Add this line to your shell rc file:"
  printf '  export PATH="%s:$PATH"\n' "$OO_BIN_DIR"
  ;;
esac

ok "Bootstrap complete"
echo
info "Next steps:"
echo "  exec \"\$SHELL\" -l"
echo "  cd /path/to/your/codebase"
echo "  oo add"
echo "  oo install"
echo "  oo start"
