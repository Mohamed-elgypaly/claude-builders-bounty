import subprocess
import json
import os

def test_hook(command):
    hook_input = {
        "tool_name": "Bash",
        "tool_input": {
            "command": command
        },
        "cwd": os.getcwd()
    }
    
    proc = subprocess.Popen(
        ["python3", "hooks/destructive_bash_hook.py"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    stdout, stderr = proc.communicate(input=json.dumps(hook_input))
    
    print(f"Testing: {command}")
    if stdout:
        print(f"Output: {stdout.strip()}")
        try:
            res = json.loads(stdout)
            decision = res.get("hookSpecificOutput", {}).get("permissionDecision")
            print(f"Decision: {decision}")
        except:
            pass
    else:
        print("Decision: allow (no output)")
    print("-" * 20)

commands = [
    "ls -la",
    "rm -rf /tmp/test",
    "git push origin main --force",
    "DROP TABLE users;",
    "DELETE FROM logs",
    "DELETE FROM logs WHERE id = 1"
]

for cmd in commands:
    test_hook(cmd)
