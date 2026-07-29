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
   - `"@azure.argTenant"` (~line 506)
   - `"@azure.deployModel"` and `"@azure.enableAutoSetAzureRules"`
     (~lines 536–537)
   - the entire `"github.copilot.chat.codeGeneration.instructions"` array
     (~lines 510–527) — all five entries are "@azure Rule" instructions,
     so removing the whole key is correct; it contains nothing else.

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
Remove from `~/.config/Code/User/settings.json`:
- `@azure.argTenant`
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
