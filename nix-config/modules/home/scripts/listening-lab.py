#!/usr/bin/env python3
"""User-owned private build; credentials never enter a Nix derivation/store."""
import argparse
import fcntl
import os
from pathlib import Path
import shutil
import subprocess
import sys

LABEL = 'org.nix-community.home.listening-lab'

def run(*args, **kwargs):
    return subprocess.run(args, check=True, **kwargs)

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--revision', required=True)
    p.add_argument('command', nargs='?', default='status', choices=['setup','run','start','stop','status'])
    a = p.parse_args()
    base = Path.home() / 'Library/Application Support/ListeningLab'
    base.mkdir(parents=True, exist_ok=True)
    current = base / 'current'
    service = f'gui/{os.getuid()}/{LABEL}'
    if a.command == 'stop':
        subprocess.run(['launchctl','kill','SIGTERM',service], check=False); return
    if a.command == 'start':
        run('launchctl','kickstart',service); return
    if a.command == 'status':
        print(f'Pinned revision: {a.revision}\nRuntime: {current}\nMac mode: capture only (no delayed audio output)')
        subprocess.run(['launchctl','print',service], check=False); return
    if a.command == 'run':
        if not (current / 'helper/server.cjs').exists(): raise RuntimeError('Run listening-lab setup first.')
        subprocess.run(['launchctl','kill','SIGTERM',service], check=False)
        import time
        time.sleep(1)
        os.chdir(current)
        os.execvp('node',['node','helper/server.cjs'])
    with (base / 'setup.lock').open('w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        target = base / 'revisions' / a.revision
        fresh = not target.exists()
        if fresh:
            target.parent.mkdir(parents=True, exist_ok=True)
            run('git','clone','--no-checkout','git@github.com:ayamdobhal/spotify-listening-lab.git',str(target), env={**os.environ, 'GIT_SSH_COMMAND':'ssh -o BatchMode=yes'})
        if not (target / '.git').is_dir(): raise RuntimeError(f'Unexpected directory: {target}')
        if not fresh and subprocess.check_output(['git','-C',str(target),'status','--porcelain'],text=True).strip():
            raise RuntimeError(f'Local source edits in {target}; refusing to replace them.')
        run('git','-C',str(target),'checkout','--detach',a.revision)
        if not (target / '.built').exists():
            run('npm','ci',cwd=target)
            run('npm','run','build',cwd=target)
            run('sh','scripts/build-native-mac.sh',cwd=target)
            run('node','scripts/test-pcm.cjs',cwd=target)
            (target / '.built').touch()
        run(sys.executable,str(target / 'scripts/install-mac.py'))
        if not current.is_symlink() or current.resolve() != target:
            link = base / 'current.new'
            if link.is_symlink(): link.unlink()
            link.symlink_to(target, target_is_directory=True)
            link.replace(current)
            if subprocess.run(['launchctl', 'print', service], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0:
                run('launchctl', 'kickstart', '-k', service)
        print('Listening Lab ready. Reopen Spotify. Mac recording permission may be required.')

if __name__ == '__main__':
    try: main()
    except Exception as e:
        print(f'Listening Lab: {e}',file=sys.stderr); sys.exit(1)
