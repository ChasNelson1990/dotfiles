# Azure removal — cleaning up Azure tooling and artefacts

Companion to [aws-cleanup.md](aws-cleanup.md). Written 2026-07-15 after an
audit of the system. Azure turned out much lighter than AWS — notably there
are **no credentials anywhere**: `~/.azure` exists but is completely empty,
so there is nothing to revoke server-side before deleting.

## What's on the system

1. **Package**: `azure-cli 2.87.0-1` (pacman), 626 MiB, owning `/usr/bin/az`.
   Depends only on `glibc`, `libgcc`, `libsecret`, `python` — all shared
   system packages required by other software, so nothing else is removed
   with it. Nothing depends on `azure-cli`.
2. **`~/.azure/`** — empty directory (no profile, no MSAL token cache, no
   credentials).
3. **VS Code stale settings** in `~/.config/Code/User/settings.json`, left
   over from the since-uninstalled "GitHub Copilot for Azure" extension:
   - `"@azure.argTenant"` — **removed from the tracked repo** as of the
     `chore: :fire: remove stale Azure key from settings.json` commit.
   - `"@azure.deployModel"`, `"@azure.enableAutoSetAzureRules"`, and the
     entire `"github.copilot.chat.codeGeneration.instructions"` array (all
     five entries are "@azure Rule" instructions) — **not present in the
     tracked repo file** at all, so there's nothing to remove there; if
     they show up on a live system's settings.json (e.g. from a newer
     Copilot-for-Azure install than what's reflected in git), remove them
     by hand using the same logic.

**Clean already**: no azcopy / func / bicep / azd / azurite binaries, no
Azure pip/pipx/uv/npm packages, nothing in shell configs or env vars, no
Azure Docker images.

**Keep — not Azure cloud tooling despite the name:**
- VS Code extensions `ms-azuretools.vscode-docker` and
  `ms-azuretools.vscode-containers` — these are the Docker/Containers
  extensions; the publisher just happens to be Microsoft's Azure-tools team.
- the `"ms-azuretools"` entry in `extensions.trustedPublishers` (~line 470)
  — required for those Docker extensions to stay trusted.

## Steps

### 1. Uninstall the CLI
```bash
sudo pacman -Rns azure-cli
```
Removes only azure-cli itself; its four dependencies are shared and stay.

### 2. Delete the empty config dir
```bash
rmdir ~/.azure
```
`rmdir` rather than `rm -rf` — it's empty, and rmdir fails loudly if
something has appeared in it since the audit.

### 3. Clean VS Code settings
`@azure.argTenant` is already removed from the tracked repo (see above). The
other three keys aren't present in the tracked file; if found on a live
system, remove them by hand:
- `@azure.deployModel`
- `@azure.enableAutoSetAzureRules`
- the whole `github.copilot.chat.codeGeneration.instructions` array

Leave `extensions.trustedPublishers` untouched. Watch for a trailing comma
on the preceding line after each removal.

## Verification
- `command -v az` → nothing found
- `pacman -Qsq azure` → no matches
- `ls -d ~/.azure` → no such directory
- `grep -i azure ~/.config/Code/User/settings.json` → only the
  `ms-azuretools` trustedPublishers line remains
- Open VS Code once to confirm `settings.json` still parses cleanly
