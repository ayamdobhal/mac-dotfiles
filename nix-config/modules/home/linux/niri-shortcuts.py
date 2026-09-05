"""Small workspace helpers for the Mac-style shortcuts on Niri."""
import json
import subprocess
import sys


def query(kind):
    return json.loads(subprocess.check_output(['niri', 'msg', '-j', kind]))


def action(*args):
    subprocess.run(['niri', 'msg', 'action', *map(str, args)], check=True)


def workspace_target(workspaces, mode):
    focused = next((w for w in workspaces if w['is_focused']), None)
    if focused is None:
        return None
    local = sorted((w for w in workspaces if w['output'] == focused['output']), key=lambda w: w['idx'])
    if mode == 'new':
        return local[-1]['idx']
    index = next(i for i, w in enumerate(local) if w['id'] == focused['id'])
    return local[(index + 1) % len(local)]['idx']


def swap_direction(windows):
    focused = next((w for w in windows if w['is_focused']), None)
    if focused is None or focused['is_floating']:
        return None
    pos = focused['layout'].get('pos_in_scrolling_layout')
    if pos is None:
        return None
    columns = [w['layout']['pos_in_scrolling_layout'][0] for w in windows
               if w['workspace_id'] == focused['workspace_id']
               and w['layout'].get('pos_in_scrolling_layout')]
    if any(c < pos[0] for c in columns):
        return 'left'
    if any(c > pos[0] for c in columns):
        return 'right'
    return None


def main(mode):
    if mode in ('cycle', 'new'):
        target = workspace_target(query('workspaces'), mode)
        if target is not None:
            action('focus-workspace', target)
    elif mode == 'swap':
        direction = swap_direction(query('windows'))
        if direction:
            action('swap-window-' + direction)
    elif mode == 'reload':
        subprocess.run(['niri', 'validate'], check=True)
        action('load-config-file')
    else:
        raise SystemExit('Expected cycle, new, swap or reload')


if __name__ == '__main__':
    main(sys.argv[1])
