#!/bin/bash
# Stop: lightweight verification gate (verification-and-lifecycle skill,
# Lecture 09-10). Only fires when source actually changed AND the
# matching manifest exists -- a no-op pre-scaffolding, so it doesn't
# fight normal doc/planning turns. Dispatches by manifest file; extend
# the block list if this project uses a stack not listed here.
set -u
cd "$(dirname "$0")/../.." || exit 0

input="$(cat)"
already_blocking="$(echo "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)"
[[ "$already_blocking" == "true" ]] && exit 0

block() {
  # $1 = log file path, $2 = human label for the failing command
  tail -n 40 "$1" | jq -Rs --arg label "$2" \
    '{decision:"block", reason:($label + " is failing on changed files -- fix before stopping. Last output:\n" + .)}'
}

run_check() {
  # $1 = command, $2 = log file, $3 = label. Returns 1 (and emits block JSON) on failure.
  if ! eval "$1" >"$2" 2>&1; then
    block "$2" "$3"
    return 1
  fi
  return 0
}

if [[ -f pyproject.toml ]] && [[ -n "$(git status --porcelain -- '*.py' 2>/dev/null)" ]]; then
  command -v pytest >/dev/null 2>&1 && { run_check "pytest -q" /tmp/stop-gate-pytest.log "pytest" || exit 0; }
  command -v ruff >/dev/null 2>&1 && { run_check "ruff check --quiet ." /tmp/stop-gate-ruff.log "ruff check" || exit 0; }
  exit 0
fi

if [[ -f package.json ]] && [[ -n "$(git status --porcelain -- '*.ts' '*.tsx' '*.js' '*.jsx' 2>/dev/null)" ]]; then
  if jq -e '.scripts.test' package.json >/dev/null 2>&1; then
    run_check "npm test --silent" /tmp/stop-gate-npmtest.log "npm test" || exit 0
  fi
  if jq -e '.scripts.lint' package.json >/dev/null 2>&1; then
    run_check "npm run lint --silent" /tmp/stop-gate-npmlint.log "npm run lint" || exit 0
  fi
  exit 0
fi

if [[ -f go.mod ]] && [[ -n "$(git status --porcelain -- '*.go' 2>/dev/null)" ]]; then
  command -v go >/dev/null 2>&1 || exit 0
  run_check "go build ./..." /tmp/stop-gate-gobuild.log "go build" || exit 0
  run_check "go vet ./..." /tmp/stop-gate-govet.log "go vet" || exit 0
  run_check "go test ./..." /tmp/stop-gate-gotest.log "go test" || exit 0
  exit 0
fi

if [[ -f Cargo.toml ]] && [[ -n "$(git status --porcelain -- '*.rs' 2>/dev/null)" ]]; then
  command -v cargo >/dev/null 2>&1 || exit 0
  run_check "cargo test --quiet" /tmp/stop-gate-cargotest.log "cargo test" || exit 0
  exit 0
fi

exit 0
