# Changelog

All notable changes to Multigravity are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Forward host Wayland compositor sockets (`wayland-*`) into the profile's
  `XDG_RUNTIME_DIR`. Isolating `XDG_RUNTIME_DIR` prevented clipboard utilities
  like `wl-paste` from reaching the display server on Wayland desktop
  sessions, causing image paste in `agy` to fail with `exit status 1`.
  Stale or broken socket symlinks are also cleaned up automatically.

## [0.3.1] - 2026-09-07

### Fixed

- Isolate `agy` account state on Linux desktops with a session bus. New and
existing profiles keep their own `.antigravitycli`, `~/.local/share/keyrings`,
and `~/.local/share/kwalletd` directories instead of symlinking the host
ones, and `launch` unsets `DBUS_SESSION_BUS_ADDRESS` with an isolated
`XDG_RUNTIME_DIR` so `agy` uses per-profile file token storage rather than
the shared Secret Service keyring. Previously a new profile started logged
in as the host, and logout or login in one profile changed all of them.
Existing profiles with legacy symlinks are repaired on next launch.

## [0.3.0] - 2026-09-05

### Fixed

- Pass the current directory to Antigravity with `agy --add-dir` instead of
  as a positional argument. Recent `agy` releases (1.1.x) reject positional
  arguments with `Error: unexpected argument ...`, which broke
  `multigravity launch NAME` entirely. Launching a profile again opens the
  directory you are currently in.

## [0.2.1] - 2026-07-28

### Fixed

- Share host developer-tool configuration and credentials (Git, SSH, GitHub
  CLI, shells, keyrings) with profiles via symlinks, while keeping
  Antigravity and Gemini account state isolated per profile. Existing profile
  files are never overwritten.

## [0.2.0] - 2026-07-28

### Changed

- Simplify the CLI to `new`, `launch`, `list`, `delete`, `help`, and
  `version`. `launch` opens the current directory in the profile.
- Remove shortcuts, sharing flags, archives, self-update, signing,
  attestations, and extra release assets. Releases publish a single
  `multigravity` Bash artifact plus `SHA256SUMS`.

## [0.1.2] - 2026-07-28

### Fixed

- Discover the Antigravity `agy` command from `PATH` and standard locations
  (`/usr/bin/agy`, `/usr/local/bin/agy`, `~/.local/bin/agy`, Antigravity
  AppImage). Set `MULTIGRAVITY_APP` to an absolute executable path when `agy`
  is not found automatically.

## [0.1.1] - 2026-07-28

### Fixed

- Check out the release tag before publishing so release artifacts match the
  tagged sources.

## [0.1.0] - 2026-07-28

### Added

- Rebuild Multigravity as a secure Linux-only Bash CLI: isolated
  Antigravity profiles with their own home and XDG directories, profile
  lifecycle commands, and a deterministically bundled single-file artifact.

[Unreleased]: https://github.com/RyderAsKing/multigravity-cli/compare/v0.3.1...HEAD
[0.3.1]: https://github.com/RyderAsKing/multigravity-cli/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/RyderAsKing/multigravity-cli/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/RyderAsKing/multigravity-cli/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/RyderAsKing/multigravity-cli/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/RyderAsKing/multigravity-cli/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/RyderAsKing/multigravity-cli/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/RyderAsKing/multigravity-cli/releases/tag/v0.1.0
