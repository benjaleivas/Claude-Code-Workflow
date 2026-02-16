Cancel the active Ralph Wiggum iteration loop.

## Current Loop State
```bash
$(cat /tmp/ralph-loop-state.json 2>/dev/null || echo '{"active": false, "message": "No active loop to cancel"}')
```

---

## Cancel Ralph Loop

Update the state file to mark the loop as cancelled:

```bash
python3 -c "
import json, os
from datetime import datetime

state_file = '/tmp/ralph-loop-state.json'

if not os.path.exists(state_file):
    print('No active Ralph loop found')
else:
    try:
        with open(state_file, 'r') as f:
            state = json.load(f)
        if not state.get('active', False):
            print('Ralph loop is already inactive')
            print(f'Last status: {state.get(\"status\", \"unknown\")}')
            print(f'Iterations completed: {state.get(\"iteration\", 0)}')
        else:
            state['active'] = False
            state['cancelled_at'] = datetime.utcnow().isoformat() + 'Z'
            state['status'] = 'cancelled'
            with open(state_file, 'w') as f:
                json.dump(state, f, indent=2)
            print('Ralph loop CANCELLED')
            print(f'Iterations completed: {state.get(\"iteration\", 1)}')
    except Exception as e:
        print(f'Error: {e}')
        print('Manual override: rm /tmp/ralph-loop-state.json')
"
```

After cancellation, the Stop hook (if installed) will allow normal session exit.

### Manual Cancellation

If the command above fails, delete the state file directly:

```bash
rm /tmp/ralph-loop-state.json
```

### Troubleshooting

If the loop seems stuck:
1. Check state: `cat /tmp/ralph-loop-state.json`
2. Look for `[RALPH]` messages in output (hook feedback)
3. Manual override: delete the state file
