#!/usr/bin/env bash
# Hook: Pre-tool-use — Block Destructive Bash Commands in Claude Code
# Install: Place in .claude/hooks/pre-tool-use.sh or configure in claude.json
#
# This hook runs BEFORE every tool execution.
# It blocks dangerous bash commands that could cause irreversible damage.

set -euo pipefail

BLOCKED_COMMANDS=(
  "rm -rf"
  "rm -rf /"
  "rm -rf ~"
  "rm -rf ."
  "rm -rf /*"
  "rm -rf /etc"
  "rm -rf /usr"
  "rm -rf /var"
  "rm -rf /home"
  "rm -rf /root"
  "dd if="
  "mkfs"
  "format"
  "fdisk"
  "> /dev/sda"
  "> /dev/sdb"
  "| sh"
  "| bash"
  "curl.*| bash"
  "wget.*| bash"
  "chmod -R 000"
  "chown -R"
  "mv.*/dev/null"
  "echo.*>/dev/sda"
  "git push --force"
  "git push origin +main"
  "git push origin +master"
  "DROP TABLE"
  "DROP DATABASE"
  "TRUNCATE TABLE"
  "DELETE FROM.*WHERE"
  "UPDATE.*SET.*= NULL"
  "ALTER TABLE.*DROP"
  "ufw disable"
  "iptables -F"
  "systemctl stop"
  "service.*stop"
  "kill -9"
  "pkill -9"
)

ALLOWED_PATTERNS=(
  "rm -rf node_modules"
  "rm -rf .next"
  "rm -rf dist"
  "rm -rf build"
  "rm -rf .cache"
  "rm -rf target"
  "rm -rf .git"
  "DROP TABLE IF EXISTS"
  "git push --force-with-lease"
)

get_stdin() {
  if [ -p /dev/stdin ]; then
    cat -
  elif [ -n "$*" ]; then
    echo "$*"
  fi
}

COMMAND=$(get_stdin "$@")

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

COMMAND_LOWER=$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]')

for allowed in "${ALLOWED_PATTERNS[@]}"; do
  ALLOWED_LOWER=$(echo "$allowed" | tr '[:upper:]' '[:lower:]')
  if [[ "$COMMAND_LOWER" == *"$ALLOWED_LOWER"* ]]; then
    exit 0
  fi
done

for blocked in "${BLOCKED_COMMANDS[@]}"; do
  BLOCKED_LOWER=$(echo "$blocked" | tr '[:upper:]' '[:lower:]')
  if [[ "$COMMAND_LOWER" == *"$BLOCKED_LOWER"* ]]; then
    echo "⚠️  BLOCKED by pre-tool-use hook: Destructive command detected"
    echo "   Pattern: '$blocked'"
    echo "   Command: $COMMAND"
    echo "   Tip: Use --force flag to override (e.g., 'rm -rf node_modules' is allowed)"
    exit 1
  fi
done

exit 0
