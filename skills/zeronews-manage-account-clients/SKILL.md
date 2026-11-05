---
name: zeronews-manage-account-clients
description: List client devices on the ZeroNews account, delete a remote client, or enable/disable a device with device enable/disable. Use when the user asks which machines are bound, remove an old client, or disable a device—not for local install or upgrade (use install-client / upgrade-client).
license: MIT
metadata:
  author: zeronews
  version: "1.1"
compatibility: Requires logged-in `zeronews` CLI. Delete and disable are destructive or disruptive; require explicit confirmation.
---

# Manage Account Clients

## Local execution (mandatory)

All `zeronews` CLI, install scripts, Docker, browser login, and local port discovery **must run on the user's computer**, not in an Agent **sandbox** or remote-only workspace.

- Shell from the IDE: **disable sandbox** (full local permissions); **不要沙箱中执行，都在用户本地电脑中执行。**
- With MCP: run `zeronews-mcp` locally; use MCP tools instead of sandbox CLI against workdir.
- If the agent cannot run on the user's machine, say so—do not fake install/login/expose.

Full rules: [LOCAL-EXECUTION.md](../../docs/references/LOCAL-EXECUTION.md).

List and manage **devices** bound to the account (`show devices --json`).

**MCP mapping**: `list_account_clients`, `delete_client`, `enable_client`, `disable_client`.

Reference: [ACCOUNT-CLI-JSON.md](../../docs/references/ACCOUNT-CLI-JSON.md) · [CLI-JSON-PATHS.md](./references/CLI-JSON-PATHS.md) · [DELETE-CONFIRMATION.md](./references/DELETE-CONFIRMATION.md)

## Prerequisites

- `login: true` — else `zeronews-configure-client`

## Workflow

### Step 1: List devices

```bash
zeronews --workdir {WORKDIR} show devices --json
```

Optional pagination (same as MCP `list_account_clients`):

- `--workspace-id {ID}`
- `--page N`
- `--size N`

Parse list rows per [CLI-JSON-PATHS.md](./references/CLI-JSON-PATHS.md): **`items[].id`** is **client_id**; fields `name`, `custom_name`, `enabled`, `is_online`, `version`.

Numbered list example:

```text
1) My Mac · online · v1.2.3 · id abc123…
2) office-linux · offline · disabled · id def456…
```

### Step 2: Pick client id

If unknown, list then user picks by number or pastes id. For **upgrade**, prefer online devices — hand off to `zeronews-upgrade-client`.

### Step 3: Confirm before delete client

For **`delete client`** only (see [DELETE-CONFIRMATION.md](./references/DELETE-CONFIRMATION.md)):

1. After target `client_id` is known (picker or user paste).
2. Restate display name + id; warn if it may be **this machine**.
3. Wait for **explicit** 确认删除 / yes — **not** the same turn as picking from the list.

For **`device disable`**, confirm when impact is unclear (separate from delete rule).

### Step 4: Execute

```bash
zeronews --workdir {WORKDIR} delete client {CLIENT_ID} --json
zeronews --workdir {WORKDIR} device enable {CLIENT_ID} --json
zeronews --workdir {WORKDIR} device disable {CLIENT_ID} --json
```

Delete may fail when load-balancer policies still reference the client — report CLI error; do not bypass.

## Output

Return `--json` payload summary and next steps (e.g. re-login if local client was disabled).

## Safety rules

- **delete client**: mandatory second-step confirm after picker — DELETE-CONFIRMATION
- confirm **device disable** when disruptive
- do not delete the client the user is actively using without strong explicit wording
- upgrading binaries → `zeronews-upgrade-client`, not delete

## Handoff

- upgrade version → `zeronews-upgrade-client`
- local health → `zeronews-inspect-client`
