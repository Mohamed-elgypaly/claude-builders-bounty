#!/bin/bash
set -e

HOOK_DIR="$HOME/.claude/hooks"
SETTINGS_FILE="$HOME/.claude/settings.json"
HOOK_FILE="$HOOK_DIR/destructive_bash_hook.py"

echo "Installing Destructive Command Hook..."

# 1. Create hooks directory
mkdir -p "$HOOK_DIR"

# 2. Copy the hook script
cp hooks/destructive_bash_hook.py "$HOOK_FILE"
chmod +x "$HOOK_FILE"

# 3. Update settings.json
if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{"hooks": {"PreToolUse": []}}' > "$SETTINGS_FILE"
fi

# Simple JSON update using python (as it is likely available if we are using a python hook)
python3 - <<EOF
import json
import os

path = os.path.expanduser("$SETTINGS_FILE")
with open(path, "r") as f:
    data = json.load(f)

hooks = data.get("hooks", {})
pre_tool = hooks.get("PreToolUse", [])

# Check if hook already exists
exists = any(h.get("matcher") == "Bash" and any("destructive_bash_hook.py" in str(sh.get("command")) for sh in h.get("hooks", [])) for h in pre_tool)

if not exists:
    new_hook = {
        "matcher": "Bash",
        "hooks": [
            {
                "type": "command",
                "command": "python3 $HOOK_FILE",
                "timeout": 10
            }
        ]
    }
    pre_tool.append(new_hook)
    hooks["PreToolUse"] = pre_tool
    data["hooks"] = hooks
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
    print("Updated ~/.claude/settings.json")
else:
    print("Hook already configured in ~/.claude/settings.json")
EOF

echo "Installation complete! Blocked commands will be logged to $HOOK_DIR/blocked.log"
