---
name: zeronews-inspect-client
description: Inspect a local ZeroNews client—running or not—via runtime file, Local API, CLI status, service, and logs. Use when asked if the client is running, connected, logged in, healthy, or what endpoints it serves. Also use as a gate before expose-service when login or running state is unclear.
license: MIT
metadata:
  author: zeronews
  version: "1.1"
compatibility: Works best when a local client runtime is running, but can still inspect workdir state and service state without an active runtime.
---

# Inspect Client

## Local execution (mandatory)

All `zeronews` CLI, install scripts, Docker, browser login, and local port discovery **must run on the user's computer**, not in an Agent **sandbox** or remote-only workspace.

- Shell from the IDE: **disable sandbox** (full local permissions); **不要沙箱中执行，都在用户本地电脑中执行。**
- With MCP: run `zeronews-mcp` locally; use MCP tools instead of sandbox CLI against workdir.
- If the agent cannot run on the user's machine, say so—do not fake install/login/expose.

Full rules: [LOCAL-EXECUTION.md](../../docs/references/LOCAL-EXECUTION.md).

Inspect the local ZeroNews client without mutating state unless the user explicitly asks for a repair action.

**MCP mapping**: `client_status` / `auth_status` → `status --json` + config/workdir checks below; `list_endpoints` → `/api/v1/endpoints` or `endpoints --json`; `client_reload` → `zeronews reload --json` or `POST /api/v1/reconnect` **only when the user asks to reconnect** (Step 4).

`zeronews status --json` is **not** read-only when `{workdir}/login_pending.json` exists: it will poll the control plane and may write `config.yml`. For a read-only check, prefer `{workdir}/config.yml` plus the local API `/api/v1/status` when the runtime is healthy. If the user wants to finish a pending browser login, then `status --json` is the correct command.

Read these JSON fields; do not treat exit `3` as failure, and do not treat “JSON parsed” as logged in:

- `login`
- `login_pending`
- `login_error`

## What this skill does

- reads `prg_runtime.json` and validates with health probe
- reads `/api/v1/status`, `/api/v1/config`, `/api/v1/endpoints` when healthy
- lists **local** active mappings (endpoints ≠ account-wide tunnels — see [ACCOUNT-VS-ENDPOINTS.md](./references/ACCOUNT-VS-ENDPOINTS.md))
- falls back to `zeronews service status` and logs when runtime is stale

## Gate helper (for expose / share / webhook)

When another skill needs «login + running»:

1. `zeronews --workdir {WORKDIR} status --json` → need `login: true` (handle `login_pending` / exit 3 per configure skill).
2. Probe Local API health (see [LOCAL-API.md](./references/LOCAL-API.md)).
3. If not running → report clearly; hand off to `zeronews-manage-client-service` or `zeronews start`.

Do not proceed to `zeronews add` from inspect alone unless the user asked to create a tunnel here—then hand off to `zeronews-expose-service`.

## Workflow

### Step 1: Find the runtime

Inspect:

- `{workdir}/prg_runtime.json`
- `{workdir}/config.yml`
- log files under `{workdir}/logs/` — see [LOG-PATHS.md](./references/LOG-PATHS.md)

Do not assume `prg_runtime.json` is current. Validate with a health check.

### Step 2: Probe health

If a runtime file exists, probe:

- `GET http://{connect_addr}{health_path}`

If health succeeds, the runtime is live.

If health fails with a network or decode error, treat the runtime file as possibly stale and fall back to service and log inspection.

### Step 3: Query the local API

When the runtime is healthy, use:

- `GET /api/v1/status`
- `GET /api/v1/config`
- `GET /api/v1/endpoints`

Optional CLI mirror (when documented in CLI help):

```bash
zeronews --workdir {WORKDIR} endpoints --json
```

Use the responses to answer:

- is the client configured and connected
- client ID and cloud server address
- **local** endpoint count and URLs
- whether any endpoint is in an error state

If the user asks for **all account tunnels**, explain the difference and use `show tunnels --json` (full workflow in stage B `zeronews-manage-account-tunnels`) — see [ACCOUNT-VS-ENDPOINTS.md](./references/ACCOUNT-VS-ENDPOINTS.md).

### Step 4: Reconnect / reload (MCP `client_reload`)

When the user explicitly wants to restore connection (same as MCP **`client_reload`**):

```bash
zeronews --workdir {WORKDIR} reload --json
```

Or Local API `POST /api/v1/reconnect` when documented for this client version. Do not reload after every `add` — see expose-service Step 4.

After **browser login** while a **service** is already running, prefer **`service restart`** via `zeronews-manage-client-service` instead of reload alone.

## Output

Return the most important runtime facts:

- configured or not; logged in or not (`login`, `login_pending`)
- connected or not
- client ID; cloud server address
- **local** endpoint count and any errors
- whether the runtime file looked stale

## Safety rules

- prefer read-only inspection first
- do not trust `prg_runtime.json` without a health probe
- do not restart, reconnect, or reset unless the user asked for a repair action
- do not use `/api/v1/endpoints` as a substitute for discovering arbitrary app ports (that is expose-service + LOCAL-LISTENERS)
