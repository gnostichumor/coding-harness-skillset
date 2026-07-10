#!/bin/bash
# PostToolUse (Edit|Write): auto-fix lint/format on the file just touched.
# Dispatches by file extension; no-ops gracefully if the matching
# manifest/tool isn't present yet (e.g. pre-scaffolding) -- never errors
# the turn. Extend the case statement if this project uses a stack not
# listed here.
set -u

input="$(cat)"
file_path="$(echo "$input" | jq -r '.tool_input.file_path // empty')"

[[ -z "$file_path" ]] && exit 0
[[ ! -f "$file_path" ]] && exit 0

remaining=""
case "$file_path" in
  *.py)
    command -v ruff >/dev/null 2>&1 || exit 0
    ruff check --fix --quiet "$file_path" >/dev/null 2>&1
    ruff format --quiet "$file_path" >/dev/null 2>&1
    remaining="$(ruff check --quiet "$file_path" 2>&1)"
    ;;
  *.ts|*.tsx|*.js|*.jsx)
    [[ -f package.json ]] || exit 0
    if command -v eslint >/dev/null 2>&1 || [[ -x node_modules/.bin/eslint ]]; then
      npx --no-install eslint --fix "$file_path" >/dev/null 2>&1
      remaining="$(npx --no-install eslint "$file_path" 2>&1)"
    fi
    if command -v prettier >/dev/null 2>&1 || [[ -x node_modules/.bin/prettier ]]; then
      npx --no-install prettier --write "$file_path" >/dev/null 2>&1
    fi
    ;;
  *.go)
    command -v gofmt >/dev/null 2>&1 || exit 0
    gofmt -w "$file_path" >/dev/null 2>&1
    if command -v go >/dev/null 2>&1 && [[ -f go.mod ]]; then
      remaining="$(go vet "$(dirname "$file_path")" 2>&1)"
    fi
    ;;
  *.rs)
    command -v rustfmt >/dev/null 2>&1 || exit 0
    rustfmt "$file_path" >/dev/null 2>&1
    ;;
  *)
    exit 0
    ;;
esac

if [[ -n "$remaining" ]]; then
  printf '%s' "$remaining" | jq -Rs --arg f "$file_path" \
    '{hookSpecificOutput:{hookEventName:"PostToolUse", decision:"block", reason:("Lint still reports issues in " + $f + " after autofix:\n" + .)}}'
fi

exit 0
