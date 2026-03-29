#!/usr/bin/env bash
set -euo pipefail

WORKFLOW_REPO_DIR="${TWF_WORKFLOW_REPO:-}"

[[ -n "$WORKFLOW_REPO_DIR" ]] || {
  echo "[error] TWF_WORKFLOW_REPO is required" >&2
  exit 1
}

[[ -d "$WORKFLOW_REPO_DIR" ]] || {
  echo "[error] Missing workflow root directory: $WORKFLOW_REPO_DIR" >&2
  exit 1
}

shopt -s nullglob
project_dirs=("$WORKFLOW_REPO_DIR"/*)
shopt -u nullglob

project_count=0
for dir in "${project_dirs[@]}"; do
  [[ -d "$dir" ]] || continue
  [[ -f "$dir/project.yml" ]] || continue
  project_count=$((project_count + 1))
done

[[ "$project_count" -gt 0 ]] || {
  echo "[error] No project templates found in $WORKFLOW_REPO_DIR" >&2
  exit 1
}

echo "[info] Validating $project_count workflow project(s)..."

for dir in "${project_dirs[@]}"; do
  [[ -d "$dir" ]] || continue
  project_file="$dir/project.yml"
  override_file="$dir/developer.yml"
  [[ -f "$project_file" ]] || continue

  if ! ruby -rerb -ryaml -e 'def load_yaml(path); rendered = ERB.new(File.read(path), trim_mode: "-").result(binding); data = YAML.safe_load(rendered, aliases: true); raise "Top-level YAML must be a map" unless data.is_a?(Hash); end; load_yaml(ARGV[0]); if File.exist?(ARGV[1]); load_yaml(ARGV[1]); end' "$project_file" "$override_file"; then
    echo "[error] Validation failed: $project_file" >&2
    exit 1
  fi
  echo "[ok] $project_file"
done

echo "[ok] All workflow templates are valid"
