# AWS removal — cleaning up AWS tooling and artefacts

## Context

AWS is no longer needed on this laptop. This is a runbook for manually removing
the AWS CLI, its dependencies, cached credentials/SSO tokens, and leftover VS
Code AWS Toolkit settings. Written 2026-07-15 after an audit of the system found
no AWS references outside the items below — nothing in shell configs, env
vars, or npm/pipx/uv global installs.

## What's on the system

1. **Package**: `aws-cli-v2 2.34.32-1` (pacman), owning `/usr/bin/aws`,
   `/usr/bin/aws_completer`, and the `awscli` Python package under
   `/usr/lib/python3.14/site-packages`. Its dependency chain —
   `python-awscrt` plus twelve `aws-c-*` / `aws-checksums` libs — is required
   by nothing else installed.
2. **Credentials & config**: `~/.aws/` containing:
   - `credentials` — a live IAM access key for profile `Malawi`
   - `config` — profiles `ZaRR-Admin`, `Romania-Admin`, `Malawi`,
     `Avenir-Admin`; SSO sessions `Fjelltopp` and `WHO Romania`
   - `sso/cache/` — cached SSO/OIDC tokens (one entry left over from the
     VS Code AWS Toolkit extension)
   - `cli/` — CLI command history/cache
3. **VS Code settings**: four stale `aws.*` keys in
   `~/.config/Code/User/settings.json` (around lines 315–317 and 385),
   left over from a since-uninstalled AWS Toolkit extension — no AWS
   extension or globalStorage remains.

**Explicitly out of scope**: the `public.ecr.aws/supabase/*` Docker images
are Supabase's local-dev images, just hosted on Amazon's public ECR — not
AWS tooling, leave them alone.

## Steps

### 1. Revoke credentials first (do this before deleting local files)
The local files are the last record of what exists, so identify and revoke
before wiping:
```bash
grep aws_access_key_id ~/.aws/credentials   # note the Malawi key ID
```
Deactivate/delete that access key in the AWS IAM console (assuming it isn't
used on another machine). Optionally log out of the cached SSO sessions —
otherwise the tokens just expire on their own:
```bash
aws sso logout --profile Fjelltopp
aws sso logout --profile "WHO Romania"
```

### 2. Uninstall the CLI and orphaned dependencies
```bash
sudo pacman -Rns aws-cli-v2
```
Cascades `python-awscrt` and the `aws-c-*`/`aws-checksums` libs (verified
nothing else depends on them). Removes the CLI binaries, Python package, and
shell completions.

### 3. Delete user data
```bash
rm -rf ~/.aws
```

### 4. Clean VS Code settings
Remove these keys from `~/.config/Code/User/settings.json`:
- `aws.codeWhisperer.importRecommendation`
- `aws.codeWhisperer.includeSuggestionsWithCodeReferences`
- `aws.codeWhisperer.shareCodeWhispererContentWithAWS`
- `aws.resources.enabledResources`

Watch for a trailing comma on the preceding line after removal.

## Verification
- `command -v aws aws_completer` → nothing found
- `pacman -Qsq aws` → only `texlive-*` matches remain (name coincidence,
  unrelated package)
- `ls ~/.aws` → no such directory
- `grep -i aws ~/.config/Code/User/settings.json` → no matches
- Open VS Code once to confirm `settings.json` still parses cleanly
