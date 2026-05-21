import sys
import json
import re
import os
from datetime import datetime

# Blocked patterns
BLOCKED_PATTERNS = [
    r"rm\s+-rf",
    r"DROP\s+TABLE",
    r"git\s+push\s+.*--force",
    r"TRUNCATE\s+",
    r"DELETE\s+FROM\s+(?!.*\bWHERE\b)"
]

LOG_FILE = os.path.expanduser("~/.claude/hooks/blocked.log")

def log_blocked_attempt(command, cwd):
    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
    timestamp = datetime.now().isoformat()
    log_entry = f"{timestamp} | Command: {command} | Project: {cwd}\n"
    with open(LOG_FILE, "a") as f:
        f.write(log_entry)

def main():
    try:
        input_data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})
    cwd = input_data.get("cwd", "unknown")

    if tool_name == "Bash":
        command = tool_input.get("command", "")
        for pattern in BLOCKED_PATTERNS:
            if re.search(pattern, command, re.IGNORECASE):
                log_blocked_attempt(command, cwd)
                
                # Decision for Claude Code
                reason = f"Security Violation: The command contains a blocked destructive pattern: '{pattern}'"
                output = {
                    "hookSpecificOutput": {
                        "hookEventName": "PreToolUse",
                        "permissionDecision": "deny",
                        "permissionDecisionReason": reason
                    }
                }
                print(json.dumps(output))
                sys.exit(0) # Using JSON decision

    # Allow by default
    sys.exit(0)

if __name__ == "__main__":
    main()
