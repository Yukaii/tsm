# Release and Homebrew Automation

This document covers release artifacts and automated Homebrew formula update PRs.

## Release flow

### 1. Build release artifacts

```bash
make release-dist VERSION=v0.1.0
```

Artifacts:

- `dist/tsm-v0.1.0.tar.gz`
- `dist/tsm-v0.1.0.tar.gz.sha256`

### 2. Publish release tag

```bash
git tag v0.1.0
git push origin v0.1.0
```

The release workflow publishes these artifacts to GitHub Releases.

## Homebrew tap PR automation

The release workflow also opens/updates a PR in `Yukaii/homebrew-tap` for `Formula/tsm.rb`.

Behavior:

- uses the exact built release artifact checksum
- updates only `url` and `sha256` in the formula
- pushes a branch and creates/updates a PR

### Required setup in `Yukaii/tsm`

- Secret: `HOMEBREW_TAP_DEPLOY_KEY`
- Variable: `APP_ID`
- Secret: `APP_PRIVATE_KEY`

The workflow mints a short-lived GitHub App installation token and uses `gh` for PR operations.

If these are missing, release publishing still works; only the Homebrew PR job is skipped.

## Manual fallback

```bash
SHA=$(cut -d' ' -f1 dist/tsm-v0.1.0.tar.gz.sha256)
./scripts/update-homebrew-formula.sh /path/to/homebrew-tap/Formula/tsm.rb v0.1.0 "$SHA"
```
