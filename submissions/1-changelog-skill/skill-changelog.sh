#!/usr/bin/env bash
# Skill: CHANGELOG Generator for Claude Code
# Invocation: claude changelog [--since TAG] [--output FILE]
# Description: Generates a CHANGELOG.md from git history since last tag

set -euo pipefail

SINCE=""
OUTPUT="CHANGELOG.md"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --since) SINCE="$2"; shift 2 ;;
    --output) OUTPUT="$2"; shift 2 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

if [[ -z "$SINCE" ]]; then
  SINCE=$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)
fi

echo "# Changelog" > "$OUTPUT"
echo "" >> "$OUTPUT"
echo "## [Unreleased]" >> "$OUTPUT"
echo "" >> "$OUTPUT"

git log "$SINCE..HEAD" --pretty=format:"%s" --no-merges | while IFS= read -r msg; do
  case "$msg" in
    feat:*|feature:*) echo "### Added" >> "$OUTPUT"; echo "- ${msg#*: }" >> "$OUTPUT" ;;
    fix:*) echo "### Fixed" >> "$OUTPUT"; echo "- ${msg#*: }" >> "$OUTPUT" ;;
    break:*|breaking:*) echo "### Changed" >> "$OUTPUT"; echo "- ${msg#*: } [BREAKING]" >> "$OUTPUT" ;;
    docs:*) echo "### Documentation" >> "$OUTPUT"; echo "- ${msg#*: }" >> "$OUTPUT" ;;
    refactor:*|chore:*) echo "### Maintenance" >> "$OUTPUT"; echo "- ${msg#*: }" >> "$OUTPUT" ;;
    test:*) echo "### Testing" >> "$OUTPUT"; echo "- ${msg#*: }" >> "$OUTPUT" ;;
    *) echo "- $msg" >> "$OUTPUT" ;;
  esac
done

echo "Generated $OUTPUT from $SINCE..HEAD"
