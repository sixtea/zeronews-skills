---
name: zeronews-configure-client
description: Bind a ZeroNews client with `zeronews login` (browser confirm) or `zeronews authtoken` when the user already has a token. Use when asked to register, authenticate, bind, or initialize a ZeroNews client.
license: MIT
metadata:
  author: zeronews
  version: "1.1"
compatibility: Requires the `zeronews` CLI. The skill may work against a stopped client or a running local client runtime.
---

# Configure Client

## Local execution (mandatory)

All `zeronews` CLI, install scripts, Docker, browser login, and local port discovery **must run on the user's computer**, not in an Agent **sandbox** or remote-only workspace.

- Shell from the IDE: **disable sandbox** (full local permissions); **不要沙箱中执行，都在用户本地电脑中执行。**
- With MCP: run `zeronews-mcp` locally; use MCP tools instead of sandbox CLI against workdir.
- If the agent cannot run on the user's machine, say so—do not fake install/login/expose.

Full rules: [LOCAL-EXECUTION.md](../../docs/references/LOCAL-EXECUTION.md).

Configure a ZeroNews client by using `zeronews login` or `zeronews authtoken` instead of editing local files manually.

**MCP mapping**: `login`, `configure_auth`, `prompt_auth_token` (legacy aliases → browser login). Skills may still use `authtoken` when the user pasted a token. Do **not** put Auth Token into MCP host config.

## What this skill does

- binds the machine with browser login by default
- still accepts a pasted AuthToken via `zeronews authtoken`
- writes the local `config.yml` (login path: poll `status --json` writes it)
- returns the resolved client ID and cloud server address

## Prerequisites

- `zeronews` command available
- browser the account owner can use, or an auth token issued by the control-plane

## Workflow

### Step 1: Pre-flight

Silently inspect:

- whether `zeronews` is installed
- the intended workdir
- whether `{workdir}/config.yml` already exists
- whether `{workdir}/prg_runtime.json` points to a healthy running local client

Ask all questions upfront:

1. If `status --json` already shows `login: true`, stop. Do not confirm again and do not ask for a token.
2. Prefer browser login unless the user already pasted an AuthToken.
3. Use the default workdir, or a specific absolute `--workdir` path?
4. Is this only a local one-time setup, or should the client also be prepared for service mode afterward?

If `config.yml` already exists, ask whether the user wants to keep the current binding or replace it.

### Step 2: Bind

Browser login (default):

```bash
NO_TTY=1 zeronews --workdir {WORKDIR} login
zeronews --workdir {WORKDIR} status --json
```

Set `NO_TTY=1` even when a TTY exists so login returns immediately. Poll `status --json` until `login` is true. Exit `3` means wait. Do not paste the verify URL into chat if the local browser opened.

If the user provided a token:

```bash
zeronews --workdir {WORKDIR} authtoken {TOKEN}
```

If the user also provides a client ID:

```bash
zeronews --workdir {WORKDIR} authtoken {TOKEN} {CLIENT_ID}
```

After login writes `config.yml`: if the process is not running, `service start`; if it is already running, `service restart` or `reload`. Do not POST the granted token to the local API Configure endpoint.

### Step 3: Handle `Local config file already exists, token update ignored`

If `authtoken` prints:

```text
Local config file already exists, token update ignored
```

stop immediately. The new token was **not** applied. Do not continue as if auth succeeded.

Present a clear choice to the user:

1. **Reset** — hand off to `zeronews-reset-client`, then re-run `authtoken`
2. **Ignore** — keep the existing config and stop the auth attempt

Do not auto-reset. Do not manually delete files when the user chose reset. Follow `references/EXISTING-CONFIG-CONFLICT.md`.

Expected behavior before the warning appears:

- if a running local client is reachable, the CLI can reconfigure through the local API without this warning
- if no running local client is reachable and `config.yml` already exists, the CLI keeps the old config and prints the warning

If the user chooses **Reset**:

1. hand off to `zeronews-reset-client`
2. use elevated privileges when required; if `id -u` is already `0`, run without `sudo` (see `references/PRIVILEGE-EXECUTION.md`)
3. after reset succeeds, re-bind with `NO_TTY=1 zeronews --workdir {WORKDIR} login` (or `authtoken {TOKEN}` if using a token)
4. continue only after `status --json` shows `login: true` (or the CLI prints `Authentication successful`)

If the user chooses **Ignore**:

- explain that the existing binding was kept
- do not retry auth unless the user changes their mind
- hand off to `zeronews-inspect-client` if they want to verify current state

### Step 4: If the user asked for long-lived operation

Do not install or start a system service unless the user explicitly asked for it.

If they did, hand off to **`zeronews-manage-client-service`** after auth succeeds.

If auth changed an **already running** service (browser login wrote new `config.yml`), Step 2 already covers `service restart` or `reload`—ensure the service process picks up config before expose or share workflows.

## Output

Return:

- config path
- client ID
- cloud server address

## Safety rules

- do not write `config.yml` by hand when `zeronews login` or `zeronews authtoken` can do it
- do not delete an existing config without explicit user approval
- when auth prints `Local config file already exists, token update ignored`, require an explicit reset-or-ignore choice; never auto-delete config
- when the user chooses reset, hand off to `zeronews-reset-client` instead of manually deleting files
- before any command that would use `sudo`, check whether the session is already root; if `id -u` is `0`, run without `sudo`
- do not assume the runtime file means the local client is healthy; probe it first
