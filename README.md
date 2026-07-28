# Multigravity

Run multiple fully isolated Antigravity profiles on Linux.

Each profile has its own login, settings, extensions, and cache. When launched,
Antigravity opens the directory you are currently in.

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
