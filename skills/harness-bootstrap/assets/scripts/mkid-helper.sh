#!/bin/bash
# Source this file (`source mkid-helper.sh`), then call mkid() to create
# bd issues without re-deriving the bash/jq incantations from scratch.
#
# KNOWN PITFALL this fixes: under `set -u` (which your seeding script
# should use), `local extra=(); [[ cond ]] && extra+=(...); "${extra[@]}"`
# throws "extra[@]: unbound variable" on macOS's bash 3.2 when the array
# ends up empty, because bash 3.2 doesn't support ${arr[@]} on a
# zero-element array under `set -u`. The if/elif/else dispatch below
# avoids ever expanding a possibly-empty array.
#
# RUBRIC for decomposing a PRD into this issue tree (see SKILL.md step 6
# for the full version):
#   - Every epic is TOP-LEVEL. Never pass one epic's ID as another
#     epic's --parent -- that nests epics inside epics, which is a
#     hierarchy bug, not a build-order dependency. Build order between
#     epics is expressed ONLY via `bd dep add <epic> <epic-it-depends-on>`.
#   - Every requirement/feature issue's --parent is its OWNING epic
#     (flat, one level). Sequencing between sibling features within the
#     same epic is expressed via `bd dep add`, never by chaining
#     --parent from one sibling to the next.
#   - Every issue's description/acceptance uses the Behavior/
#     Verification/State triple (see SKILL.md).
#   - Unresolved PRD open questions become `chore` issues labeled
#     "human" (mkid's 7th arg), parented to the epic they most affect;
#     `bd dep add` from the blocked feature onto the open question only
#     when it's a genuine hard blocker, not just related context.

mkid() {
  # $1=title $2=type(epic|feature|task|chore|bug) $3=priority(0-4)
  # $4=description $5=acceptance $6=parent-id(optional) $7=labels(optional, comma-sep)
  local title="$1" type="$2" prio="$3" desc="$4" accept="$5"
  local parent="${6:-}" labels="${7:-}"
  if [[ -n "$parent" && -n "$labels" ]]; then
    bd create "$title" -t "$type" -p "$prio" --description "$desc" --acceptance "$accept" --silent --json --parent "$parent" --labels "$labels" | jq -r '.id // .[0].id'
  elif [[ -n "$parent" ]]; then
    bd create "$title" -t "$type" -p "$prio" --description "$desc" --acceptance "$accept" --silent --json --parent "$parent" | jq -r '.id // .[0].id'
  elif [[ -n "$labels" ]]; then
    bd create "$title" -t "$type" -p "$prio" --description "$desc" --acceptance "$accept" --silent --json --labels "$labels" | jq -r '.id // .[0].id'
  else
    bd create "$title" -t "$type" -p "$prio" --description "$desc" --acceptance "$accept" --silent --json | jq -r '.id // .[0].id'
  fi
}

# Usage example (delete this comment block once adapted):
#   set -euo pipefail
#   source mkid-helper.sh
#   E_SCAFFOLD=$(mkid "Environment & code scaffolding" epic 0 "..." "...")
#   E_CONFIG=$(mkid "Config & state foundations" epic 1 "..." "...")
#   bd dep add "$E_CONFIG" "$E_SCAFFOLD"
#   R1=$(mkid "R1: ..." feature 1 "..." "..." "$E_CONFIG")   # parent = owning epic
#   R2=$(mkid "R2: ..." feature 1 "..." "..." "$E_CONFIG")
#   bd dep add "$R2" "$R1"                                    # sequencing = dep add, not parent
#   OQ1=$(mkid "OPEN QUESTION: ..." chore 2 "..." "..." "$E_CONFIG" "human")
