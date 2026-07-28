# Security policy

## Supported versions

Security fixes are provided for the latest stable release. Development builds
and older releases are unsupported.

## Reporting a vulnerability

Use GitHub private vulnerability reporting for
`RyderAsKing/multigravity-cli`. Do not open a public issue for an unpatched
vulnerability. Include the affected version, reproduction steps, impact, and
any suggested mitigation. Please allow maintainers time to investigate before
public disclosure.

## Release identity

Release blobs are signed keylessly by GitHub Actions. Verification must require:

- OIDC issuer: `https://token.actions.githubusercontent.com`
- Certificate identity:
  `https://github.com/RyderAsKing/multigravity-cli/.github/workflows/release.yml@refs/tags/vX.Y.Z`

The CLI fails closed when `cosign`, a valid bundle, or a matching SHA-256 value
is unavailable. A checksum without a valid Sigstore identity is not sufficient
for installation or update authenticity.
