#!/bin/bash
# Counts today's Claude Code stats live from session JSONL files
# Output: sessions|messages|tool_calls
exec /usr/bin/python3 -c "
import os, json, glob
from datetime import date

today = date.today().isoformat()
base = os.path.expanduser('~/.claude/projects')
sessions = messages = tools = 0

for pd in glob.glob(os.path.join(base, '*')):
    for f in glob.glob(os.path.join(pd, '*.jsonl')):
        from datetime import datetime
        if datetime.fromtimestamp(os.path.getmtime(f)).date().isoformat() != today:
            continue
        counted = False
        with open(f) as fh:
            for line in fh:
                try:
                    d = json.loads(line)
                except:
                    continue
                ts = d.get('timestamp', '')[:10]
                if ts != today:
                    continue
                if not counted:
                    sessions += 1
                    counted = True
                t = d.get('type', '')
                if t in ('user', 'assistant'):
                    messages += 1
                if t == 'assistant':
                    c = d.get('message', {}).get('content', [])
                    if isinstance(c, list):
                        tools += sum(1 for b in c if isinstance(b, dict) and b.get('type') == 'tool_use')

print(f'{sessions}|{messages}|{tools}')
"
