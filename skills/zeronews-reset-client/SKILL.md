---
name: zeronews-reset-client
description: Reset local ZeroNews client state with `zeronews reset`. Use when the user explicitly wants to remove service registration and local client state, including after choosing Reset during an authtoken conflict.
license: MIT
metadata:
  author: zeronews
  version: "1.1"
compatibility: Requires the `zeronews` CLI. This is destructive. May require elevated privileges when a system service is installed.
---

# Reset Client

## Local execution (mandatory)

All `zeronews` CLI, install scripts, Docker, browser login, and local port discovery **must run on the user's computer**, not in an Agent **sandbox** or remote-only workspace.

- Shell from the IDE: **disable sandbox** (full local permissions); **不要沙箱中执行，都在用户本地电脑中执行。**
- With MCP: run `zeronews-mcp` locally; use MCP tools instead of sandbox CLI against workdir.
- If the agent cannot run on the user's machine, say so—do not fake install/login/expose.

Full rules: [LOCAL-EXECUTION.md](../_shared/references/LOCAL-EXECUTION.md).

Reset the local client only on explicit user request.

This skill is also the required path when the user chooses **Reset** after `authtoken` prints `Local config file already exists, token update ignored`.

## What this skill does

The reset flow:

- attempts to uninstall the system service
- removes `config.yml`
- removes `login_pending.json`
- removes `control-plane.request.lock`
- removes `prg_runtime.json`
- removes the log directory
- removes the workdir if it becomes empty

## Prerequisites

- `zeronews` command available
- user explicitly confirmed reset
- elevated privileges when a system service is installed:
  - Linux / macOS: run with `sudo` when service uninstall is needed
  - Windows: run from an Administrator PowerShell or CMD when service uninstall is needed

The agent cannot obtain privileges automatically. Tell the user when `sudo` or an Administrator shell is required and rerun reset there.

Before any command that would use `sudo`, check the current user. On Linux/macOS, if `id -u` is `0`, run the command directly without `sudo`. See `../configure-client/references/PRIVILEGE-EXECUTION.md`.

## Workflow

### Step 1: Confirm intent clearly

Ask the user to confirm they want local client state removed.

When this reset comes from an auth conflict, explain that reset will clear the old binding so a new AuthToken can be applied afterward.

Do not use this as a convenience shortcut unless the user agreed.

### Step 2: Detect privileges, then run reset

Silently check whether the session is already elevated:

- Linux / macOS: `id -u` → `0` means root
- Windows: Administrator shell check per `../configure-client/references/PRIVILEGE-EXECUTION.md`

Linux / macOS when a service may be installed:

```bash
# non-root session
sudo zeronews --workdir {WORKDIR} reset

# already root
zeronews --workdir {WORKDIR} reset
```

**macOS:** full reset **requires** `sudo` (uninstalls **system LaunchDaemon and user LaunchAgent**). Do **not** rely on non-elevated `zeronews reset` when any service was installed. See [MACOS-AGENT-SERVICE.md](../zeronews-install-client/references/MACOS-AGENT-SERVICE.md).

Windows when a service may be installed:

```powershell
.\zeronews.exe reset
```

Run from an Administrator shell when not already elevated.

When **only** a foreground client ran (no service, no `--user` Agent) and the workdir is user-writable, non-Linux platforms may allow non-elevated reset — **not on macOS** if LaunchAgent or LaunchDaemon was ever installed.

If reset fails with:

```text
Reset requires administrator privileges. Please run with sudo
```

stop, tell the user to rerun with the required privileges, and do not claim reset completed.

### Step 3: Explain what was removed

Report the removed paths and whether service uninstall was skipped, completed, or blocked by privileges.

### Step 4: Resume the calling flow when applicable

If reset was triggered from an auth conflict in `zeronews-install-client` or `zeronews-configure-client`:

1. return to the calling skill
2. re-bind with `NO_TTY=1 zeronews --workdir {WORKDIR} login` (or `authtoken {TOKEN}` if the user is using a token)
3. continue only after `status --json` shows `login: true` (or the CLI prints `Authentication successful`)

## Safety rules

- this skill is destructive
- before any command that would use `sudo`, check whether the session is already root; if `id -u` is `0`, run without `sudo`
- do not manually delete individual files when `zeronews reset` is the chosen reset path
- surface privilege failures plainly instead of pretending reset completed
- do not run reset unless the user explicitly chose reset or asked for full local cleanup
