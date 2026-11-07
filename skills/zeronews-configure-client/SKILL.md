---
name: zeronews-configure-client
description: Auth-only bind for an existing `zeronews` CLI (`login` or user-provided `authtoken`). Do not invoke after a completed skills-setup `zeronews-install-client` run that already reached `login: true`.
license: MIT
metadata:
  author: zeronews
  version: "1.2"
compatibility: Requires the `zeronews` CLI. The skill may work against a stopped client or a running local client runtime.
---

# Configure Client

## When to use / When not to use

**Use when:**

- CLI is installed; user wants **login / bind / replace token** and `login` is **false** (or user explicitly wants re-bind).
- Handoff from expose/share/manage skills when **not** `login: true`.
- Install did **not** complete Step 3 in the same task (interrupted, probe-only, download-only).

**Do not use when:**

- Same task just finished **`zeronews-install-client` 1→n** with **`login: true`** (skills-setup: no **客户端登陆** STEP).
- `status --json` already shows **`login: true`** and the user did not ask to replace binding.
- User wants **first-time full install** and has not run install yet → invoke **`zeronews-install-client`** (bind is install Step 3), not this skill alone.

## Local execution (mandatory)

All `zeronews` CLI, install scripts, Docker, browser login, and local port discovery **must run on the user's computer**, not in an Agent **sandbox** or remote-only workspace.

- Shell from the IDE: **disable sandbox** (full local permissions); **不要沙箱中执行，都在用户本地电脑中执行。**
- With MCP: run `zeronews-mcp` locally; use MCP tools instead of sandbox CLI against workdir.
- If the agent cannot run on the user's machine, say so—do not fake install/login/expose.

Full rules: [LOCAL-EXECUTION.md](../_shared/references/LOCAL-EXECUTION.md).

Configure a ZeroNews client by using `zeronews login` or `zeronews authtoken` instead of editing local files manually.

**MCP mapping**: **WorkBuddy / connector** → **`configure_auth`** only (`ZERONEWS_AUTH_TOKEN`). **`login`** only when **no** connector token (browser); MCP 子进程可能打不开浏览器，需用户本机打开 `verify_url`。Skills 无 MCP 时仍可用 shell `NO_TTY=1 login` 或 `authtoken`。勿把 Token 写进聊天。

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

Browser login (default) — **mandatory** [BROWSER-LOGIN.md](../_shared/references/BROWSER-LOGIN.md) / [references/BROWSER-LOGIN.md](./references/BROWSER-LOGIN.md):

1. `NO_TTY=1 zeronews --workdir {WORKDIR} login` → parse verify URL from stdout.
2. **Same Shell:** run `open "$url"` (macOS) / `xdg-open` / Windows `start` on the **user machine** (sandbox off). CLI does **not** open the browser when `NO_TTY=1` — **Agent must**.
3. **Same Shell:** poll `status --json` every 3s with `jq '.login == true'` until success or terminal error; continue while `login_pending`. **Do not** end the Agent turn after step 1 without steps 2–3 (setup 包 ②, F-18).
4. After `login: true`, ensure client **running** (`service start` or `start`) before handoff to expose skills.

Do not paste the verify URL into chat if the browser opened successfully on the user's machine.

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
