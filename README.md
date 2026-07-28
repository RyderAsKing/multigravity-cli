# Multigravity

Run Antigravity with separate profiles on Linux.

Each profile gets its own settings, extensions, cache, and login state, so you
can keep work, personal, and experimental environments apart.

## Quick start

```bash
multigravity new work
multigravity launch work
```

Create another profile whenever you need one:

```bash
multigravity new personal
multigravity list
multigravity launch personal
```

## Install

The easiest verified installation uses GitHub CLI 2.49 or newer:

```bash
tag=v0.1.2
gh release download "$tag" \
  --repo RyderAsKing/multigravity-cli \
  --pattern multigravity-linux-all
gh attestation verify multigravity-linux-all \
  --repo RyderAsKing/multigravity-cli
install -Dm755 multigravity-linux-all "$HOME/.local/bin/multigravity"
```

Make sure `$HOME/.local/bin` is on your `PATH`, then check the installation:

```bash
multigravity version
multigravity doctor
```

Multigravity requires Linux, Bash 4.4+, GNU coreutils, GNU tar, `curl`, and an
installed Antigravity IDE. If Antigravity is not detected automatically, set
`MULTIGRAVITY_APP` to the absolute path of its executable. Multigravity looks
for the Antigravity command `agy` on your `PATH`. Authenticated self-updates also
require [`cosign`](https://docs.sigstore.dev/cosign/system_config/installation/).

## Common commands

| Command | What it does |
| --- | --- |
| `multigravity new NAME` | Create a profile |
| `multigravity launch NAME` | Open a profile |
| `multigravity list` | List profiles |
| `multigravity status` | Show profile status |
| `multigravity clone OLD NEW` | Copy a profile |
| `multigravity rename OLD NEW` | Rename a profile |
| `multigravity delete NAME` | Delete a profile after confirmation |
| `multigravity doctor` | Check your setup |
| `multigravity update --check` | Check for a new version |
| `multigravity update` | Install the latest verified release |

Run `multigravity help` to see every command.

### Open a project

Arguments after `--` are passed directly to Antigravity:

```bash
multigravity launch work -- /path/to/project
```

## Back up a profile

```bash
multigravity export work work.multigravity.tar.gz
multigravity import work.multigravity.tar.gz restored-work
```

Imports are checked for unsafe paths, links, special files, and excessive
size before a profile is created. Only import profiles from sources you trust,
because their settings and extensions can still affect Antigravity.

## Shared profiles

Normal profiles are isolated. If you intentionally want a profile to reuse your
regular Antigravity settings and extensions, create it with:

```bash
multigravity new shared-work --shared
```

Changes made by a shared profile can affect your regular Antigravity setup and
other shared profiles.

## Where profiles are stored

Profiles are stored in:

```text
$HOME/AntigravityProfiles
```

To use another location, set `MULTIGRAVITY_HOME` to a safe absolute directory.
Multigravity isolates profile files; it is not a security sandbox for the IDE,
extensions, or opened projects.

## Uninstall

Remove the executable:

```bash
rm -f "$HOME/.local/bin/multigravity" "$HOME/.local/bin/multigravity.bak"
```

Your profiles are kept. Delete `$HOME/AntigravityProfiles` separately only if
you no longer need them.

<details>
<summary>Manual Sigstore verification</summary>

Every release includes SHA-256 checksums and keyless Sigstore bundles. Download
all four release assets, then run:

```bash
tag=v0.1.2
identity="https://github.com/RyderAsKing/multigravity-cli/.github/workflows/release.yml@refs/tags/$tag"
issuer="https://token.actions.githubusercontent.com"

cosign verify-blob --bundle SHA256SUMS.bundle \
  --certificate-identity "$identity" \
  --certificate-oidc-issuer "$issuer" SHA256SUMS
cosign verify-blob --bundle multigravity-linux-all.bundle \
  --certificate-identity "$identity" \
  --certificate-oidc-issuer "$issuer" multigravity-linux-all
sha256sum --check --ignore-missing SHA256SUMS
```

`multigravity-linux-all` is one architecture-independent Bash executable tested
on Linux amd64 and arm64. The `.bundle` files contain verification evidence and
are not programs.

</details>

## Development

```bash
make lint
make test
make reproducible
```

See [`SECURITY.md`](SECURITY.md) for vulnerability reporting and
[`NOTICE.md`](NOTICE.md) for provenance information. New code is licensed under
the [MIT License](LICENSE).
