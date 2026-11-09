---
name: zeronews-manage-client-service
description: Manage the ZeroNews client as a native OS service with `zeronews service`—install, start, stop, restart, status, uninstall. Use after configure or when expose fails because the client is not running. After browser login changes config while the service is already running, restart or reload so tunnels see the new binding.
license: MIT
metadata:
  author: zeronews
  version: "1.5"
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

On **macOS**:

- **`status`:** **never** osascript — use unwrap + **`status --json`** (or `service status` only when already root).
- **`reload`:** unwrap only when the daemon is running — **no** osascript.
- **`install` / `start` / `stop` / `restart` / `uninstall`:** root / `sudo -n` first; else **one** osascript per request (batch subcommands with `&&`). See [MACOS-AGENT-SERVICE.md](../zeronews-install-client/references/MACOS-AGENT-SERVICE.md).

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
- macOS uses `launchd` — **system LaunchDaemon** (default Agent path: root / `sudo -n` / **osascript administrator**)
- Windows uses the Windows Service Manager

Do not paper over platform-specific privilege or file-path errors.

#### macOS Agent path (system service + osascript)

When the session is **not root** and `sudo -n` does not work, use **one** osascript only for the **mutating** `service …` action (see [MACOS-AGENT-SERVICE.md](../zeronews-install-client/references/MACOS-AGENT-SERVICE.md)). Example start when already installed:

```bash
osascript -e 'do shell script "/Applications/zeronews/zeronews --workdir /Applications/zeronews service start" with administrator privileges'
```

**Do not** osascript for status. **`service --user` is not the default Agent path** — only if the user explicitly requested user LaunchAgent.

**Uninstall / reset on macOS (both sides):** `sudo zeronews --workdir "$WORKDIR" service uninstall` or `sudo zeronews --workdir "$WORKDIR" reset`.

### Step 4: After configure / login (cross-skill)

**Out of scope:** **`zeronews-install-client` Step 1b** binary upgrade — no `service restart` / stop / start (see [UPGRADE-ON-INSTALL.md](../zeronews-install-client/references/UPGRADE-ON-INSTALL.md)). **Install Step 4** owns first `service install/start` after `login: true` — do not duplicate in the same task.

When **`zeronews-configure-client`** or **`zeronews-install-client`** completes browser login and a system service is **already installed and running**, run **`reload`** with unwrap first (no elevation). Use **`service restart`** via root / `sudo -n` / **one** osascript **only if** `reload` failed and `status --json` is still wrong, or the client is not running. Skipping reload leaves expose/share flows talking to a stale process.

If no service is installed, foreground `zeronews start` is enough.

## Safety rules

- before any command that would use `sudo`, check whether the session is already root; if so, run without `sudo`
- do not install a service unless the user explicitly asked for service mode
- do not uninstall a service unless the user explicitly asked for removal
- do not claim service install succeeded without checking the command result
