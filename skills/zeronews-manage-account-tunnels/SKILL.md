---
name: zeronews-manage-account-tunnels
description: List, delete, enable, or disable tunnels on the logged-in ZeroNews account using CLI show tunnels and tunnel enable/disable. Use when the user asks for all account tunnels, to remove a tunnel, turn off a mapping on the console, or re-enable a disabled tunnel—not for listing only this machine's active endpoints (use inspect-client).
license: MIT
metadata:
  author: zeronews
  version: "1.1"
compatibility: "Requires zeronews CLI and login true. Account commands do not require the local client to be running, but login must be valid."
---

# Manage Account Tunnels

## Local execution (mandatory)

All `zeronews` CLI, install scripts, Docker, browser login, and local port discovery **must run on the user's computer**, not in an Agent **sandbox** or remote-only workspace.

- Shell from the IDE: **disable sandbox** (full local permissions); **不要沙箱中执行，都在用户本地电脑中执行。**
- With MCP: run `zeronews-mcp` locally; use MCP tools instead of sandbox CLI against workdir.
- If the agent cannot run on the user's machine, say so—do not fake install/login/expose.

Full rules: [LOCAL-EXECUTION.md](../_shared/references/LOCAL-EXECUTION.md).

Operate **account-wide** tunnels via the control plane CLI. This is not the same as local `/api/v1/endpoints` — see [ACCOUNT-CLI-JSON.md](../_shared/references/ACCOUNT-CLI-JSON.md) and `zeronews-inspect-client` references.

**MCP mapping**: `list_account_tunnels`, `delete_tunnel`, `enable_tunnel`, `disable_tunnel` (+ picker / `user_confirmed` delete flow).

## Prerequisites

1. `zeronews --workdir {WORKDIR} status --json` → `login: true` (hand off to `zeronews-configure-client` if not).
2. Mutations: `zeronews --workdir {WORKDIR} … --json`

Shared command reference: [ACCOUNT-CLI-JSON.md](../_shared/references/ACCOUNT-CLI-JSON.md) · [CLI-JSON-PATHS.md](./references/CLI-JSON-PATHS.md) · [DELETE-CONFIRMATION.md](./references/DELETE-CONFIRMATION.md) · label hints: [PICKER-LABELS.md](./references/PICKER-LABELS.md)

## Workflow

### Step 1: Gate

If not logged in, stop and configure first. Do not delete or toggle tunnels without a valid session.

### Step 2: List (read-only)

```bash
zeronews --workdir {WORKDIR} show tunnels --json
```

Optional pagination (match CLI help / MCP):

- `--workspace-id {ID}`
- `--page N`
- `--size N`

Parse list rows per [CLI-JSON-PATHS.md](./references/CLI-JSON-PATHS.md): **`items[]`** first, else **`page.items[]`**. Each row needs **`id`** for mutations.

Present results as a **numbered list**. Each line should help the user recognize the tunnel:

- public URL / subdomain
- type / feature (e.g. HTTPS, LFS)
- enabled vs disabled
- optional local `ip:port` summary
- short id token

If `total` exceeds one page, say so and offer another `--page` or ask the user for an id.

### Step 3: Pick target (when id unknown)

When the user did not give a tunnel id:

1. Run list (Step 2).
2. Filter to what they described (domain, disabled only, etc.).
3. Show numbered choices; user replies with **序号** or id.
4. Do not pick for them.

**Selecting an option is only Step 1 of delete** — see [DELETE-CONFIRMATION.md](./references/DELETE-CONFIRMATION.md).

### Step 4: Delete — explicit confirmation (mandatory)

Before **`delete tunnel`** only (enable/disable use Step 4b):

1. Restate **id** + **public label** in plain language.
2. Ask whether to **确认删除** (separate question — not the same message as the picker).
3. Run CLI **only** after explicit yes / 确认删除 / 是，删除.

Never delete immediately after the user picks a list number. Never skip confirmation because the user said «删 xxx」without confirming the resolved id.

### Step 4b: Enable / disable (not delete)

Before **`tunnel disable`** when impact is unclear, confirm with the user. **`tunnel enable`** may proceed when intent is clear.

### Step 5: Execute

**Delete**

```bash
zeronews --workdir {WORKDIR} delete tunnel {TUNNEL_ID} --json
```

**Enable / disable**

```bash
zeronews --workdir {WORKDIR} tunnel enable {TUNNEL_ID} --json
zeronews --workdir {WORKDIR} tunnel disable {TUNNEL_ID} --json
```

Deleting removes the tunnel for the **account**; it may not be bound to this device. Caller must be logged in as the owning account (same rules as MCP `delete_tunnel`).

## Output

Return CLI JSON summary: ok/error, tunnel id, and any message fields from `--json` stdout.

## Safety rules

- confirm before **every** delete (picker ≠ confirm) — [DELETE-CONFIRMATION.md](./references/DELETE-CONFIRMATION.md)
- prefer disable over delete when the user only asked to «停掉» or «暂时关闭»
- one mutating command at a time
- do not use `show tunnels` to discover arbitrary local app ports (use `expose-service` + LOCAL-LISTENERS)

## Handoff

- create new local mapping → `zeronews-expose-service` / `zeronews-share-files` / `zeronews-expose-webhook`
- «本机现在在服务什么」→ `zeronews-inspect-client` (endpoints)
