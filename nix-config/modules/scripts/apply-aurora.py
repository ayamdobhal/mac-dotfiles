#!/usr/bin/env python3
"""Deploy the Nix-built Aurora bundle; keep Spicetify's mutable state local."""
import argparse
import configparser
import fcntl
import json
import io
import os
from pathlib import Path
import plistlib
import re
import shutil
import subprocess
import tempfile


def read_config(path):
    config = configparser.ConfigParser(interpolation=None, strict=False)
    config.read(path)
    return config


def application_version(prefs):
    match = re.search(r'^app\.last-launched-version="([^"]+)"', prefs, re.M)
    return match[1] if match else None


def apply_commands(backup_version, backup_cli, spotify_version, cli_version):
    if backup_version != spotify_version:
        return ["backup", "apply"]
    if backup_cli != cli_version:
        return ["restore", "backup", "apply"]
    return ["apply"]


def atomic_write(path, contents):
    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as file:
        temp = Path(file.name)
        file.write(contents)
    try:
        temp.replace(path)
    finally:
        temp.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--force", action="store_true", help="Reapply even if versions are unchanged")
    args = parser.parse_args()
    home = Path.home()
    state = home / "Library/Caches/dotfiles-aurora"
    state.mkdir(parents=True, exist_ok=True)
    with (state / "apply.lock").open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        deploy(args.source, home, state, args.force)


def deploy(source, home, state, force=False, *, cli=None, spotify=None):
    cli = cli or next((p for p in [Path("/opt/homebrew/bin/spicetify"), Path("/usr/local/bin/spicetify")]
                if p.is_file()), None)
    spotify = spotify or Path("/Applications/Spotify.app")
    prefs = home / "Library/Application Support/Spotify/prefs"
    if cli is None or not spotify.is_dir() or not prefs.is_file():
        print("Aurora: waiting for Spotify, Spicetify and Spotify's first launch.")
        return
    with (spotify / "Contents/Info.plist").open("rb") as file:
        version = plistlib.load(file)["CFBundleShortVersionString"]
    spotify_version = application_version(prefs.read_text())
    if not spotify_version or not (spotify_version == version or spotify_version.startswith(version + ".")):
        print("Aurora: launch the updated Spotify once before applying.")
        return
    root = home / ".config/spicetify"
    env = dict(os.environ, XDG_CONFIG_HOME=str(home / ".config"))

    def run(*commands):
        return subprocess.run([str(cli), "--no-restart", *commands], env=env,
                              stdin=subprocess.DEVNULL, check=True, timeout=180)

    cli_version = subprocess.check_output([str(cli), "--version"], env=env, text=True, timeout=15).strip()
    extensions = sorted((source / "extensions").glob("*.js"))
    if not extensions or not (source / "theme/user.css").is_file():
        raise RuntimeError("Aurora build is missing its theme or extensions")
    managed = {
        "Setting": {"current_theme": "aurora", "color_scheme": "", "inject_css": "1",
                    "replace_colors": "1", "inject_theme_js": "1",
                    "spotify_path": str(spotify / "Contents/Resources"), "prefs_path": str(prefs)},
        "Preprocesses": {"expose_apis": "1"},
        "AdditionalOptions": {"extensions": "|".join(p.name for p in extensions), "custom_apps": ""},
    }
    config_path = root / "config-xpui.ini"
    config = read_config(config_path)
    fingerprint = json.dumps([str(source), spotify_version, cli_version], sort_keys=True)
    stamp = state / "applied.json"
    configured = all(config.get(section, key, fallback=None) == value
                     for section, values in managed.items() for key, value in values.items())
    installed = (root / "Themes/aurora/user.css").is_file() and all(
        (root / "Extensions" / p.name).is_file() for p in extensions)
    if not force and stamp.is_file() and stamp.read_text() == fingerprint and configured and installed:
        return

    # Preserve the previous local setup before taking ownership of these fields.
    backup = state / "before-nix"
    if not backup.exists():
        backup.mkdir()
        if config_path.exists():
            shutil.copy2(config_path, backup / "config-xpui.ini")
        for name in ["Themes/aurora", "Extensions"]:
            if (root / name).exists():
                shutil.copytree(root / name, backup / name)
    run("config", "spotify_path", str(spotify / "Contents/Resources"), "prefs_path", str(prefs))
    config = read_config(config_path)
    commands = apply_commands(config.get("Backup", "version", fallback=""),
                              config.get("Backup", "with", fallback=""), spotify_version, cli_version)
    for section, values in managed.items():
        if not config.has_section(section):
            config.add_section(section)
        for key, value in values.items():
            config.set(section, key, value)
    contents = io.StringIO()
    config.write(contents)
    atomic_write(config_path, contents.getvalue())
    (root / "Themes").mkdir(parents=True, exist_ok=True)
    target = root / "Themes/aurora"
    if target.is_symlink():
        target.unlink()
    elif target.exists():
        shutil.rmtree(target)
    shutil.copytree(source / "theme", target)
    # Nix source files are read-only; deployed files must remain writable.
    for path in [target, *target.rglob("*")]:
        path.chmod(0o700 if path.is_dir() else 0o600)
    (root / "Extensions").mkdir(exist_ok=True)
    for extension in extensions:
        atomic_write(root / "Extensions" / extension.name, extension.read_text())
    run(*commands)
    atomic_write(stamp, fingerprint)
    print("Aurora applied. Spotify was not restarted; reopen it to load the new UI.")


if __name__ == "__main__":
    main()
