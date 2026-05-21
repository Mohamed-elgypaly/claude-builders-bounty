# Destructive Bash Command Hook for Claude Code

This hook intercepts and blocks dangerous bash commands in Claude Code before they are executed.

## Features
- **Blocks Destructive Patterns**:
  - `rm -rf`
  - `DROP TABLE`
  - `git push --force`
  - `TRUNCATE`
  - `DELETE FROM` (without a `WHERE` clause)
- **Logging**: All blocked attempts are logged to `~/.claude/hooks/blocked.log` with timestamp, command, and project path.
- **Claude Integration**: Returns a clear reason to Claude explaining why the command was blocked.

## Installation

Run these two commands from the root of this repository:

```bash
chmod +x install.sh
./install.sh
```

## How it works
The hook follows the `PreToolUse` hook format. When a `Bash` tool is called, the hook checks the command against a set of regular expressions. If a match is found, it returns a `deny` decision to Claude Code.

## Logging
Blocked commands are logged in the following format:
`2026-05-21T12:00:00.000000 | Command: rm -rf / | Project: /home/user/my-project`
