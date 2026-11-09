---
name: zeronews-manage-client-service
description: Manage the ZeroNews client as a native OS service with `zeronews service`—install, start, stop, restart, status, uninstall. Use after configure or when expose fails because the client is not running. After browser login changes config while the service is already running, restart or reload so tunnels see the new binding.
license: MIT
metadata:
  author: zeronews
  version: "1.6"
compatibility: Requires the `zeronews` CLI. Available behavior is platform-specific across Linux, macOS, and Windows.
---

# Manage Client Service

## Local execution (mandatory)

All `zeronews` CLI, install scripts, Docker, browser login, and local port discovery **must run on the user's computer**, not in an Agent **sandbox** or remote-only workspace.

- Shell from the IDE: **disable sandbox** (full local permissions); **不要沙箱中执行，都在用户本地电脑中执行。**
- With MCP: run `zeronews-mcp` locally; use MCP tools instead of sandbox CLI against workdir.
- If the agent cannot run on the user's machine, say so—do not fake install/login/expose.

Full rules: [LOCAL-EXECUTION.md](../_shared/references/LOCAL-EXECUTION.md).

Use the built-in service management commands instead of trying to script your own daemon wrapper.

**MCP mapping**: `service_install`, `service_start`, `service_stop`, `service_restart`, `service_status`, `service_uninstall` → Step 2 commands below. Uninstall is destructive — confirm first (MCP same rule).

## What this skill does

- installs the client as a system service
- starts and stops the service
- restarts the service
- checks service status
- uninstalls the service when explicitly requested

## Workflow

### Step 1: Ask intent and detect privileges

Ask all questions upfront:

1. What action is needed: install, start, stop, restart, status, or uninstall?
2. Which workdir should the service use?

Silently inspect whether the session is already elevated:

- Linux / macOS: `id -u` → `0` means root
- Windows: Administrator shell check per `../zeronews-configure-client/references/PRIVILEGE-EXECUTION.md`

If not elevated and the action requires it on **Linux/Windows**, tell the user to rerun with `sudo` or an Administrator shell.

On **macOS** (non-root):

- **`status` / `reload`:** unwrap only — **no** osascript.
- **`service --user install` + `start`:** unwrap first; **one** osascript **without** `administrator privileges` batching both if needed ([MACOS-AGENT-SERVICE.md](../zeronews-install-client/references/MACOS-AGENT-SERVICE.md)).
- **`service --user stop|uninstall`:** unwrap only.
- **System `service …`:** only when root / `sudo -n` or user explicitly asked system daemon — not default Agent path.

### Step 2: Use the existing service commands

Examples for a non-root session (health **without** sudo):

```bash
env -u NODE_OPTIONS -u PYTHONPATH -u CODEBUDDY_BROKERED_FS_HOOK_ENABLED -u TOYBOX_SANDBOX_SOCK \
  zeronews --workdir {WORKDIR} status --json
```

Elevated service control when `sudo -n` works:

```bash
sudo -n zeronews --workdir {WORKDIR} service install
sudo -n zeronews --workdir {WORKDIR} service start
```

If `id -u` is already `0`, omit `sudo`:

```bash
zeronews --workdir {WORKDIR} service install
zeronews --workdir {WORKDIR} service start
zeronews --workdir {WORKDIR} service status
```

### Step 3: Respect OS differences

- Linux uses `systemd`
- macOS uses `launchd` — **user LaunchAgent** (`service --user`) default for Agents; system daemon when root/explicit request
- Windows uses the Windows Service Manager

Do not paper over platform-specific privilege or file-path errors.

#### macOS Agent path (`service --user` + osascript)

When **not root**, use **`service --user`**. **Only** `install` and/or `start` may use **one** non-admin osascript (batch with `&&`). Example when already installed:

```bash
osascript -e 'do shell script "/bin/bash -lc '\''/Applications/zeronews/zeronews --workdir /Applications/zeronews service --user start'\''"'
```

**Do not** osascript for status/reload/stop/uninstall.

**Uninstall / reset on macOS (both sides):** `sudo zeronews --workdir "$WORKDIR" service uninstall` or `sudo zeronews --workdir "$WORKDIR" reset`.

### Step 4: After configure / login (cross-skill)

**Out of scope:** **`zeronews-install-client` Step 1b** binary upgrade — no `service restart` / stop / start (see [UPGRADE-ON-INSTALL.md](../zeronews-install-client/references/UPGRADE-ON-INSTALL.md)). **Install Step 4** owns first `service install/start` after `login: true` — do not duplicate in the same task.

When **`zeronews-configure-client`** or **`zeronews-install-client`** completes browser login and a system service is **already installed and running**, run **`reload`** with unwrap first (no elevation). Use **`service --user restart`** with unwrap only if `reload` failed; **do not** osascript restart unless combined with install/start in same policy. Skipping reload leaves expose flows stale.

If no service is installed, foreground `zeronews start` is enough.

## Safety rules

- before any command that would use `sudo`, check whether the session is already root; if so, run without `sudo`
- do not install a service unless the user explicitly asked for service mode
- do not uninstall a service unless the user explicitly asked for removal
- do not claim service install succeeded without checking the command result
