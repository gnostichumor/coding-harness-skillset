#!/bin/bash
# Source this file (`source mkid-helper.sh`), then call mkid() to create
# br (beads_rust) issues without re-deriving the bash/jq incantations from
# scratch.
#
# KNOWN PITFALL to avoid if you touch this: under `set -u` (which your
# seeding script should use), `local extra=(); "${extra[@]}"` throws
# "extra[@]: unbound variable" on macOS's bash 3.2 when the array ends up
# empty (bash 3.2 doesn't support ${arr[@]} on a zero-element array under
# `set -u`). `extra` below is seeded with 6 always-present elements before
# any conditional `+=`, so it can never be empty when expanded -- don't
# "simplify" it back down to an array that could start empty.
#
# RUBRIC for decomposing a PRD into this issue tree (see SKILL.md step 6
# for the full version):
#   - Every epic is TOP-LEVEL. Never pass one epic's ID as another
#     epic's --parent -- that nests epics inside epics, which is a
#     hierarchy bug, not a build-order dependency. Build order between
#     epics is expressed ONLY via `br dep add <epic> <epic-it-depends-on>`.
#   - Every requirement/feature issue's --parent is its OWNING epic
#     (flat, one level). Sequencing between sibling features within the
#     same epic is expressed via `br dep add`, never by chaining
#     --parent from one sibling to the next.
#   - Every issue's description/acceptance-criteria uses the Behavior/
#     Verification/State triple (see SKILL.md).
#   - Unresolved PRD open questions become `chore` issues labeled
#     "human" (mkid's 7th arg), parented to the epic they most affect;
#     `br dep add` from the blocked feature onto the open question only
#     when it's a genuine hard blocker, not just related context.
#   - Brownfield: a requirement that's already fully implemented still
#     gets an issue (for traceability), but pass "closed" as an 8th arg
#     so it's seeded pre-closed instead of looking like open work.

mkid() {
  # $1=title $2=type(epic|feature|task|chore|bug) $3=priority(0-4)
  # $4=description $5=acceptance-criteria $6=parent-id(optional)
  # $7=labels(optional, comma-sep) $8=status(optional, e.g. "closed" for
  # already-implemented brownfield requirements)
  local title="$1" type="$2" prio="$3" desc="$4" accept="$5"
  local parent="${6:-}" labels="${7:-}" status="${8:-}"
  local -a extra=(-t "$type" -p "$prio" --description "$desc" --acceptance-criteria "$accept" --silent --json)
  [[ -n "$parent" ]] && extra+=(--parent "$parent")
  [[ -n "$labels" ]] && extra+=(--labels "$labels")
  [[ -n "$status" ]] && extra+=(--status "$status")
  br create "$title" "${extra[@]}" | jq -r '.id // .[0].id'
}

# Usage example (delete this comment block once adapted):
#   set -euo pipefail
#   source mkid-helper.sh
#   E_SCAFFOLD=$(mkid "Environment & code scaffolding" epic 0 "..." "...")
#   E_CONFIG=$(mkid "Config & state foundations" epic 1 "..." "...")
#   br dep add "$E_CONFIG" "$E_SCAFFOLD"
#   R1=$(mkid "R1: ..." feature 1 "..." "..." "$E_CONFIG")   # parent = owning epic
#   R2=$(mkid "R2: ..." feature 1 "..." "..." "$E_CONFIG")
#   br dep add "$R2" "$R1"                                    # sequencing = dep add, not parent
#   OQ1=$(mkid "OPEN QUESTION: ..." chore 2 "..." "..." "$E_CONFIG" "human")
#   R3=$(mkid "R3: already implemented, see src/foo.py" feature 1 "..." "..." "$E_CONFIG" "" "closed")
