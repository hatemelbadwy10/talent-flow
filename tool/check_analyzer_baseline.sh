#!/usr/bin/env bash

set -euo pipefail

readonly MAX_ANALYZER_ISSUES=129
readonly OUTPUT_FILE="${TMPDIR:-/tmp}/talent_flow_analyzer_output.txt"

if ! flutter analyze --no-fatal-infos 2>&1 | tee "$OUTPUT_FILE"; then
  echo "Analyzer reported an error or warning." >&2
  exit 1
fi

issue_count="$(
  sed -nE 's/^[[:space:]]*([0-9]+) issues? found.*$/\1/p' "$OUTPUT_FILE" |
    tail -n 1
)"
issue_count="${issue_count:-0}"

if (( issue_count > MAX_ANALYZER_ISSUES )); then
  echo "Analyzer issue count increased: ${issue_count} > ${MAX_ANALYZER_ISSUES}." >&2
  exit 1
fi

echo "Analyzer baseline passed: ${issue_count}/${MAX_ANALYZER_ISSUES} issues."
