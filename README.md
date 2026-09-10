# Multigravity

Run multiple account-isolated Antigravity profiles on Linux.

Each profile has its own Antigravity login, settings, extensions, and cache.
Host tool configuration and credentials are shared, so Git, SSH, GitHub CLI,
shells, and other developer tools behave as they do outside Multigravity. When
launched, Antigravity opens the directory you are currently in.

## Install

Download the latest `multigravity` and `SHA256SUMS` files from
[GitHub Releases](https://github.com/RyderAsKing/multigravity-cli/releases/latest),
then run:

```bash
sha256sum --check SHA256SUMS
chmod +x multigravity
mkdir -p "$HOME/.local/bin"
mv multigravity "$HOME/.local/bin/"
```

Make sure `$HOME/.local/bin` is on your `PATH`.

Requirements: Linux, Bash 4.4+, GNU coreutils, and the Antigravity `agy`
command. Set `MULTIGRAVITY_APP` to an absolute executable path if `agy` is not
on your `PATH`.

## Use

```bash
# Create an isolated profile
multigravity new work

# Open the current directory in that profile
cd ~/projects/example
multigravity launch work

# Manage profiles
multigravity list
multigravity delete work
```

Available commands:

| Command | Description |
| --- | --- |
| `multigravity new NAME` | Create an isolated profile |
| `multigravity launch NAME` | Open the current directory in a profile |
| `multigravity list` | List profiles |
| `multigravity delete NAME` | Delete a profile after confirmation |
| `multigravity help` | Show help |
| `multigravity version` | Show the installed version |

Profiles are stored in `$HOME/AntigravityProfiles`. Set `MULTIGRAVITY_HOME` to
a different absolute directory if needed.

Multigravity links non-Antigravity files from your home and XDG directories
into each profile. Existing profile files are never overwritten. This makes
normal developer workflows seamless, but it also means every profile can
access the same host developer-tool state. Antigravity and Gemini account
state remains local to each profile, including `.antigravitycli`, keyrings
(`~/.local/share/keyrings`, `~/.local/share/kwalletd`), and file token
storage. Launch also isolates the D-Bus session bus (`DBUS_SESSION_BUS_ADDRESS`
is unset and `XDG_RUNTIME_DIR` points at the profile) so `agy` falls back to
per-profile file tokens instead of the shared Secret Service keyring. That
matches headless, container, SSH, and WSL behavior where no session bus is
present. Host Wayland compositor sockets (`wayland-*`) from `XDG_RUNTIME_DIR`
are forwarded into the profile's runtime directory so clipboard operations
(such as pasting images via `wl-paste`) continue to work seamlessly.

## Uninstall

```bash
rm -f "$HOME/.local/bin/multigravity"
```

This does not remove your profiles.

## Development

```bash
make lint test reproducible
```

Licensed under the [MIT License](LICENSE).
