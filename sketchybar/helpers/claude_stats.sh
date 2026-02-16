#!/bin/bash
# Counts Claude Code stats from session JSONL files
# Output: sessions|messages|tool_calls|cost_daily|cost_weekly|cost_monthly
exec /usr/bin/python3 -c "
import os, json, glob
from datetime import date, datetime, timedelta

# API pricing per million tokens
PRICING = {
    'claude-opus-4-5-20251101': {'input': 15, 'output': 75, 'cache_write': 18.75, 'cache_read': 1.50},
    'claude-opus-4-6':          {'input': 15, 'output': 75, 'cache_write': 18.75, 'cache_read': 1.50},
    'claude-sonnet-4-5-20250929': {'input': 3, 'output': 15, 'cache_write': 3.75, 'cache_read': 0.30},
}
DEFAULT_PRICING = {'input': 15, 'output': 75, 'cache_write': 18.75, 'cache_read': 1.50}

today = date.today()
week_ago = (today - timedelta(days=7)).isoformat()
month_ago = (today - timedelta(days=30)).isoformat()
today_str = today.isoformat()

base = os.path.expanduser('~/.claude/projects')
sessions = messages = tools = 0
cost_daily = cost_weekly = cost_monthly = 0.0

def calc_cost(usage, model):
    p = PRICING.get(model, DEFAULT_PRICING)
    input_tok = usage.get('input_tokens', 0)
    output_tok = usage.get('output_tokens', 0)
    cache_write_tok = usage.get('cache_creation_input_tokens', 0)
    cache_read_tok = usage.get('cache_read_input_tokens', 0)
    return (input_tok * p['input'] + output_tok * p['output']
            + cache_write_tok * p['cache_write'] + cache_read_tok * p['cache_read']) / 1_000_000

for pd in glob.glob(os.path.join(base, '*')):
    for f in glob.glob(os.path.join(pd, '*.jsonl')):
        mtime = datetime.fromtimestamp(os.path.getmtime(f)).date().isoformat()
        if mtime < month_ago:
            continue
        counted = False
        with open(f) as fh:
            for line in fh:
                try:
                    d = json.loads(line)
                except:
                    continue
                ts = d.get('timestamp', '')[:10]
                if ts < month_ago:
                    continue
                if d.get('type') == 'assistant':
                    msg = d.get('message', {})
                    usage = msg.get('usage', {})
                    model = msg.get('model', '')
                    c = calc_cost(usage, model)
                    cost_monthly += c
                    if ts >= week_ago:
                        cost_weekly += c
                    if ts == today_str:
                        cost_daily += c
                # Today-only stats
                if ts != today_str:
                    continue
                if not counted:
                    sessions += 1
                    counted = True
                t = d.get('type', '')
                if t in ('user', 'assistant'):
                    messages += 1
                if t == 'assistant':
                    content = d.get('message', {}).get('content', [])
                    if isinstance(content, list):
                        tools += sum(1 for b in content if isinstance(b, dict) and b.get('type') == 'tool_use')

print(f'{sessions}|{messages}|{tools}|{cost_daily:.2f}|{cost_weekly:.2f}|{cost_monthly:.2f}')
"
