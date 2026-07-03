#!/usr/bin/env bash
# validate-update.sh — verify a staged skill update did not grow the skill.
#
# Usage:
#   validate-update.sh <live-skill.md> <staged-skill.md> [changes.md]
#
# Checks:
#   1. Staged skill line count is not greater than the live skill's.
#      If it grew, exit 1 — justify the growth in CHANGES.md or trim the skill.
#   2. (If changes.md is provided) CHANGES.md exists, is <= 50 lines, and its
#      first line contains "Net change:".
#
# Exit codes:
#   0 = ok (no growth; CHANGES.md valid if provided)
#   1 = validation failed (growth, or CHANGES.md invalid)
#   2 = usage / missing file error
set -euo pipefail

usage() {
	echo "Usage: $0 <live-skill.md> <staged-skill.md> [changes.md]" >&2
	exit 2
}

[ $# -ge 2 ] || usage

live="$1"
staged="$2"
changes="${3:-}"

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

fail=0

if [ -n "$changes" ]; then
	if [ ! -f "$changes" ]; then
		echo "FAIL: CHANGES.md missing: $changes" >&2
		fail=1
	else
		clines=$(wc -l <"$changes" | tr -d ' ')
		if [ "$clines" -gt 50 ]; then
			echo "FAIL: CHANGES.md is $clines lines (limit 50)" >&2
			fail=1
		fi
		if ! head -1 "$changes" | grep -q "Net change"; then
			echo "FAIL: CHANGES.md must start with a 'Net change:' line" >&2
			fail=1
		fi
		[ "$fail" -eq 0 ] && echo "CHANGES.md: $clines lines (<=50), net-change line present"
	fi
fi

if [ "$net" -gt 0 ]; then
	echo "FAIL: staged skill grew by $net lines. Justify the growth in CHANGES.md or trim the skill." >&2
	fail=1
fi

if [ "$fail" -ne 0 ]; then
	exit 1
fi

echo "OK: staged skill did not grow (net $net)."
exit 0
