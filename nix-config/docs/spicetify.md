# Spotify + Listening Lab on macOS

Both Mac hosts install the private Listening Lab player over plain Spotify.
Aurora's periodic apply agent has been removed. Linux is unaffected.

The [module](../modules/home/spicetify.nix) pins the private source commit.
The [bootstrap](../modules/home/scripts/listening-lab.py) clones and builds it
as the logged-in user under `~/Library/Application Support/ListeningLab`;
private GitHub credentials never go into the Nix store. Updates use separate
revision directories and switch `current` only after a successful build/apply.

## Setup

Ensure this Mac can clone `git@github.com:ayamdobhal/spotify-listening-lab.git`
and has Xcode Command Line Tools (`xcode-select --install` if missing).
Open Spotify and log in once, then run your normal rebuild:

```sh
sudo darwin-rebuild switch --flake ~/.config/nix-config#ayam-magbog-work
```

Use `#ayam-magbog-personal` on the personal Mac. If Spotify was not initialized
or private Git access was unavailable during activation, retry:

```sh
listening-lab setup
listening-lab start
```

Quit/reopen Spotify to load the extension. Click the waveform button beside
Lyrics; Back/Escape returns to normal Spotify. The app starts in normal view.
Setup backs up the previous Spicetify config and disables other themes,
extensions and custom apps without deleting their files.

**Mac currently uses capture-only audio. It does not include Windows' buffered
playback or equivalent visual timing.** The experimental Mac Core Audio relay
is not enabled. Audio must be playing on this Mac, not a remote Connect device.

## Recording permissions and diagnostics

Grant macOS Screen & System Audio Recording permission when requested.
Background helpers have their own permission context; a successful build does
not prove capture is authorized on a new Mac. For an interactive permission
prompt / troubleshooting:

```sh
listening-lab run
```

This stops the managed background helper and runs it in Terminal. Grant the
requested permission in System Settings, restart the command, and leave the
terminal open while testing. Ctrl-C stops it; `listening-lab start` returns to
the background service (which still needs its own permission).

`listening-lab status` shows the pin/service state. Logs:
`~/Library/Logs/listening-lab.log`. `listening-lab stop` stops the helper.
A stale manually installed helper on port 4738 must be stopped first; the
installer does not kill arbitrary processes. The old pre-Nix test agent was
`dev.iamdobhal.listening-lab`; the managed agent is
`org.nix-community.home.listening-lab`.

Setup applies with `--no-restart`; it does not interrupt Spotify automatically.
There is no five-minute patching loop. After Spotify updates, rerun setup and
restart Spotify. Keep Spicetify current through Homebrew.
