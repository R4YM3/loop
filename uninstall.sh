#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$REPO_DIR/templates"
LOCAL_DIR="$REPO_DIR/local"
INTERNAL_DIR="$REPO_DIR/.internal"

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TMUXINATOR_DIR="$CONFIG_HOME/tmuxinator"

ENV_FILE="$INTERNAL_DIR/env.sh"
MANIFEST_FILE="$INTERNAL_DIR/install-manifest.txt"
INTERNAL_README_FILE="$INTERNAL_DIR/README"

REMOVE_ALL=false
KEEP_ALL=false

REMOVED_COUNT=0
SKIPPED_COUNT=0

info() { printf "\033[1;34m[info]\033[0m %s\n" "$1"; }
ok() { printf "\033[1;32m[ok]\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$1"; }

detect_shell_rc() {
  case "${SHELL:-}" in
  */zsh) echo "$HOME/.zshrc" ;;
  */bash) echo "$HOME/.bashrc" ;;
  */fish) echo "$HOME/.config/fish/config.fish" ;;
  *) echo "" ;;
  esac
}

remove_source_block() {
  local rc_file="$1"

  [[ -n "$rc_file" ]] || return 0
  [[ -f "$rc_file" ]] || return 0

  sed -i.bak '/# >>> tmuxinator projects >>>/,/# <<< tmuxinator projects <<</d' "$rc_file"
  rm -f "$rc_file.bak"

  ok "Removed shell block from $rc_file if present"
}

should_remove_local_file() {
  local local_file="$1"
  local template_file="$2"

  if [[ ! -e "$local_file" ]]; then
    return 1
  fi

  if [[ "$REMOVE_ALL" == true ]]; then
    return 0
  fi

  if [[ "$KEEP_ALL" == true ]]; then
    warn "Keeping local file: $local_file"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    return 1
  fi

  if [[ -f "$template_file" ]] && cmp -s "$template_file" "$local_file"; then
    return 0
  fi

  echo
  if [[ -f "$template_file" ]]; then
    warn "Local editable file differs from shared template:"
    echo "  $local_file"
  else
    warn "No matching template exists for local file:"
    echo "  $local_file"
  fi
  echo
  echo "Choose an action:"
  echo "  [y] remove this local file"
  echo "  [n] keep local file"
  echo "  [a] remove this and all remaining local files"
  echo "  [k] keep this and all remaining local files"
  read -r -p "Your choice [y/N/a/k]: " remove_choice

  case "${remove_choice:-N}" in
  [Yy]) return 0 ;;
  [Aa])
    REMOVE_ALL=true
    return 0
    ;;
  [Kk])
    KEEP_ALL=true
    warn "Keeping local file: $local_file"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    return 1
    ;;
  *)
    warn "Keeping local file: $local_file"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    return 1
    ;;
  esac
}

remove_local_file() {
  local local_file="$1"
  local filename template_file

  filename="$(basename "$local_file")"
  template_file="$TEMPLATES_DIR/$filename"

  if should_remove_local_file "$local_file" "$template_file"; then
    rm -f "$local_file"
    ok "Removed local file: $local_file"
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
  fi
}

remove_link_file() {
  local link_file="$1"

  if [[ -L "$link_file" ]]; then
    rm -f "$link_file"
    ok "Removed symlink: $link_file"
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
  elif [[ -e "$link_file" ]]; then
    warn "Skipped non-symlink file in tmuxinator dir: $link_file"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  fi
}

remove_internal_file() {
  local file_path="$1"
  local label="$2"

  if [[ -e "$file_path" ]]; then
    rm -f "$file_path"
    ok "Removed $label: $file_path"
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
  fi
}

remove_installed_files() {
  local rc_file_from_manifest=""
  local path=""

  if [[ -f "$MANIFEST_FILE" ]]; then
    while IFS= read -r line; do
      [[ -n "$line" ]] || continue

      case "$line" in
      LOCAL_FILE=*)
        path="${line#LOCAL_FILE=}"
        remove_local_file "$path"
        ;;
      LINK_FILE=*)
        path="${line#LINK_FILE=}"
        remove_link_file "$path"
        ;;
      ENV_FILE=*)
        path="${line#ENV_FILE=}"
        remove_internal_file "$path" "env file"
        ;;
      INTERNAL_README_FILE=*)
        path="${line#INTERNAL_README_FILE=}"
        remove_internal_file "$path" "internal README"
        ;;
      RC_FILE=*)
        rc_file_from_manifest="${line#RC_FILE=}"
        ;;
      esac
    done <"$MANIFEST_FILE"

    rm -f "$MANIFEST_FILE"
    ok "Removed manifest: $MANIFEST_FILE"
    REMOVED_COUNT=$((REMOVED_COUNT + 1))
  else
    warn "Manifest not found, falling back to internal file cleanup only"
    remove_internal_file "$ENV_FILE" "env file"
    remove_internal_file "$INTERNAL_README_FILE" "internal README"
  fi

  if [[ -n "$rc_file_from_manifest" ]]; then
    remove_source_block "$rc_file_from_manifest"
  else
    local detected_rc_file
    detected_rc_file="$(detect_shell_rc)"
    remove_source_block "$detected_rc_file"
  fi

  rmdir "$INTERNAL_DIR" 2>/dev/null || true
}

main() {
  remove_installed_files

  echo
  ok "Uninstall complete"
  printf "Removed files: %d\n" "$REMOVED_COUNT"
  printf "Kept local files: %d\n" "$SKIPPED_COUNT"
}

main "$@"
