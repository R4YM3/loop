#!/usr/bin/env bash
set -euo pipefail

RUNTIME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKFLOW_REPO_DIR="${OO_WORKFLOW_REPO:-}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TMUXINATOR_DIR="$CONFIG_HOME/tmuxinator"

ok() { printf "\033[1;32m[ok]\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$1"; }
error() { printf "\033[1;31m[error]\033[0m %s\n" "$1"; }

[[ -n "$WORKFLOW_REPO_DIR" ]] || {
  error "OO_WORKFLOW_REPO is required"
  exit 1
}

command -v tmux >/dev/null 2>&1 && ok "tmux found" || error "tmux not found"
command -v tmuxinator >/dev/null 2>&1 && ok "tmuxinator found" || error "tmuxinator not found"

if [[ -d "$WORKFLOW_REPO_DIR" ]]; then
  ok "Workflow root dir exists: $WORKFLOW_REPO_DIR"
else
  error "Workflow root dir missing: $WORKFLOW_REPO_DIR"
  exit 1
fi

if [[ -d "$TMUXINATOR_DIR" ]]; then
  ok "Tmuxinator config dir exists: $TMUXINATOR_DIR"
else
  warn "Tmuxinator config dir missing: $TMUXINATOR_DIR"
fi

shopt -s nullglob
project_dirs=("$WORKFLOW_REPO_DIR"/*)
shopt -u nullglob

project_files=()
for dir in "${project_dirs[@]}"; do
  [[ -d "$dir" ]] || continue
  if [[ -f "$dir/workflow.yaml" ]]; then
    project_files+=("$dir/workflow.yaml")
    continue
  fi
  if [[ -f "$dir/workflow.yml" ]]; then
    project_files+=("$dir/workflow.yml")
  fi
done

if [[ ${#project_files[@]} -eq 0 ]]; then
  warn "No workflow templates found in $WORKFLOW_REPO_DIR"
else
  ok "Found ${#project_files[@]} workflow template(s)"
fi

project_file=""
for project_file in "${project_files[@]}"; do
  project_name="$(basename "$(dirname "$project_file")")"
  alias_file="$TMUXINATOR_DIR/$project_name.yml"

  if [[ ! -e "$alias_file" ]]; then
    warn "Missing alias for '$project_name': $alias_file"
    continue
  fi

  if [[ -L "$alias_file" ]]; then
    alias_target="$(readlink "$alias_file")"
    if [[ "$alias_target" == "$project_file" ]]; then
      ok "Alias linked for '$project_name'"
    else
      warn "Alias target differs for '$project_name': $alias_target"
    fi
  elif [[ -f "$alias_file" ]]; then
    warn "Alias exists as regular file for '$project_name': $alias_file"
  else
    warn "Alias path is not a file for '$project_name': $alias_file"
  fi
done

OO_WORKFLOW_REPO="$WORKFLOW_REPO_DIR" bash "$RUNTIME_DIR/scripts/validate-workflows.sh"
