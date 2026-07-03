#!/usr/bin/env bash
# validate-update.sh — verify a staged skill update did not grow the skill.
#
# Usage:
#   validate-update.sh <live-skill.md> <staged-skill.md>
#
# This is the cross-file gate only: it diffs the live vs staged SKILL.md line
# counts and fails if the staged skill grew (net > 0). CHANGES.md structure
# (required fields, Resolves: end goal, net-change line format, length) is
# validated by docfence via the `changes` type — run that separately:
#   docfence validate <CHANGES.md>
#
# Exit codes:
#   0 = ok (staged skill did not grow)
#   1 = staged skill grew (net > 0)
#   2 = usage / missing file error
set -euo pipefail

usage() {
	echo "Usage: $0 <live-skill.md> <staged-skill.md>" >&2
	exit 2
}

[ $# -ge 2 ] || usage

live="$1"
staged="$2"

for f in "$live" "$staged"; do
	[ -f "$f" ] || {
		echo "ERROR: file not found: $f" >&2
		exit 2
	}
done

live_lines=$(wc -l <"$live" | tr -d ' ')
staged_lines=$(wc -l <"$staged" | tr -d ' ')

# additions/deletions approximated from diff (> = added, < = removed)
add=$(diff "$live" "$staged" 2>/dev/null | grep -c '^>' || true)
del=$(diff "$live" "$staged" 2>/dev/null | grep -c '^<' || true)
net=$((staged_lines - live_lines))

echo "Live:      $live_lines lines  ($live)"
echo "Staged:    $staged_lines lines  ($staged)"
echo "Additions: +$add"
echo "Deletions: -$del"
echo "Net:       $net lines"

if [ "$net" -gt 0 ]; then
	echo "FAIL: staged skill grew by $net lines. Trim it (strategy A/B/C) or justify growth in CHANGES.md and get user approval." >&2
	exit 1
fi

echo "OK: staged skill did not grow (net $net)."
exit 0