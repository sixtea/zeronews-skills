---
name: zeronews-manage-client-service
description: Manage the ZeroNews client as a native OS service with `zeronews service`—install, start, stop, restart, status, uninstall. Use after configure or when expose fails because the client is not running. After browser login changes config while the service is already running, restart or reload so tunnels see the new binding.
license: MIT
metadata:
  author: zeronews
  version: "1.1"
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

If not elevated and the action requires it, tell the user to rerun with `sudo` or an Administrator shell. The agent cannot enter a password interactively.

### Step 2: Use the existing service commands

Examples for a non-root session:

```bash
sudo zeronews --workdir {WORKDIR} service install
sudo zeronews --workdir {WORKDIR} service start
zeronews --workdir {WORKDIR} service status
```

If `id -u` is already `0`, omit `sudo`:

```bash
zeronews --workdir {WORKDIR} service install
zeronews --workdir {WORKDIR} service start
zeronews --workdir {WORKDIR} service status
```

### Step 3: Respect OS differences

- Linux uses `systemd`
- macOS uses `launchd`
- Windows uses the Windows Service Manager

Do not paper over platform-specific privilege or file-path errors.

### Step 4: After configure / login (cross-skill)

When **`zeronews-configure-client`** or **`zeronews-install-client`** completes browser login and a system service is **already installed and running**, run **`service restart`** (or `reload` if that is what configure used) so the daemon loads the new `config.yml`. Skipping this leaves expose/share flows talking to a stale process.

If no service is installed, foreground `zeronews start` is enough.

## Safety rules

- before any command that would use `sudo`, check whether the session is already root; if so, run without `sudo`
- do not install a service unless the user explicitly asked for service mode
- do not uninstall a service unless the user explicitly asked for removal
- do not claim service install succeeded without checking the command result
