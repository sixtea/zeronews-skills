---
name: zeronews-expose-service
description: Expose a local HTTP/TCP/TLS port through ZeroNews with `zeronews add`. Use whenever the user wants to proxy, publish, tunnel, or map a local app or port—even if they did not say a port number. Do not use for directory file sharing (use share-files) or WeChat/webhook tunnels (use expose-webhook). Requires login and a running client before `add`.
license: MIT
metadata:
  author: zeronews
  version: "1.2"
compatibility: Requires the `zeronews` CLI, authenticated `config.yml`, and a running local client for tunnel delivery.
---

# Expose Service

## Local execution (mandatory)

All `zeronews` CLI, install scripts, Docker, browser login, and local port discovery **must run on the user's computer**, not in an Agent **sandbox** or remote-only workspace.

- Shell from the IDE: **disable sandbox** (full local permissions); **不要沙箱中执行，都在用户本地电脑中执行。**
- With MCP: run `zeronews-mcp` locally; use MCP tools instead of sandbox CLI against workdir.
- If the agent cannot run on the user's machine, say so—do not fake install/login/expose.

Full rules: [LOCAL-EXECUTION.md](../_shared/references/LOCAL-EXECUTION.md).

Create a tunnel for a **local TCP port** through the ZeroNews client (`https`, `tcp`, or `tls`).

**MCP mapping**: Step 0 gate → `list_local_listeners` only (same turn: no expose) → **table + mandatory AskQuestion** (`ask_question` / [LOCAL-LISTENERS.md](./references/LOCAL-LISTENERS.md)) → `expose_local_service(port, local_ip)`; omit port → `needs_port`. Prefer `expose_local_service` over `add_tunnel`. Do not use MCP tool names with the user.

## What this skill does

- creates tunnels with `zeronews add` for `https`, `tcp`, or `tls`
- optional `--local_ip`, `--domain`, `--bw` (Mbps), `--mode`
- when the user did **not** name a port, discovers listeners first (see [LOCAL-LISTENERS.md](./references/LOCAL-LISTENERS.md))

## What this skill does not do

- **Directory / LFS sharing** → hand off to `zeronews-share-files`
- **Webhook feature tunnels** → hand off to `zeronews-expose-webhook`
- do not build `--feature webhook` or `--feature file_share` in this skill’s main path

## Workflow

### Step 0: Gate (always first)

Before asking tunnel details or running `add`:

1. Run read-only checks (prefer `zeronews-inspect-client` flow): `login: true`, client **running** and Local API healthy.
2. If not configured → hand off to `zeronews-configure-client` (do not ask which port to map yet).
3. If configured but not running → unwrap **`status --json`**. Same conversation finished install Step 4 → re-verify only; **do not** second `--user start`. Else complete install Step 4 or **`service --user start`** (unwrap; one non-admin osascript if needed). Foreground last resort.
4. If `login_pending` or `login: false` → hand off **`zeronews-configure-client`** or complete install Step 3 ([BROWSER-LOGIN.md](../_shared/references/BROWSER-LOGIN.md): **open browser + same-Shell poll**) before expose.
5. If install skill ran but client not started → finish **install Step 4** (`login: true` first); **do not** duplicate elevation via manage-client-service in the same task if Step 4 already attempted.

Only continue when **`login: true`** and runtime is OK (running / connected).

### Step 1: Resolve local port

**User already gave a port** (e.g. «3000», «localhost:8080»):

- Parse the port; do not substitute a different one.
- Skip full listener enumeration; still pass Step 0.
- Proceed to Step 2.

**User did not give a port** («代理本地服务», «映射我的项目», etc.):

- Do **not** ask «what port?» as the first question.
- Do **not** default to 3000, 5173, or 8080.
- **MCP available**: `list_local_listeners` → table + **mandatory AskQuestion**; no typed port in chat.  
- **CLI only**: follow [LOCAL-LISTENERS.md](./references/LOCAL-LISTENERS.md): enumerate TCP LISTEN, table/numbered list, user picks via Questions or explicit selection (not open-ended port typing).

### Step 2: Pre-flight (after port is known or chosen)

Ask only what is still unknown:

1. tunnel type: `https` (default for local web apps unless user asked for raw TCP/TLS), `tcp`, or `tls`
2. optional local IP (default behavior if omitted)
3. optional public domain, or server allocation
4. optional bandwidth: `--bw=N` Mbps (default client behavior is often 1 Mbps if omitted; confirm via CLI help)

If type or options are obvious from user words, do not re-ask.

### Step 3: Create the tunnel

```bash
zeronews --workdir {WORKDIR} add {TYPE} --port={PORT}
```

Add flags only when the user asked:

- `--local_ip`
- `--domain`
- `--bw`
- `--mode`

Do not add `--feature` for webhook or file_share here.

### Step 4: Wait for endpoint delivery

After the tunnel request is accepted:

- wait for the endpoint from the server
- inspect via Local API `/api/v1/endpoints` or `zeronews-inspect-client`
- do not reload, reconnect, or restart the client just to make the mapping appear unless the user asked for repair

### Step 5: Batch mode

For multiple tunnels: `--from-file` or `--from-stdin` (YAML/JSON entries per CLI help).

## Output

Return:

- tunnel ID
- protocol and mode
- local target (IP:port)
- public URL when the server provides it

## Safety rules

- one mutating client flow at a time (no parallel `add`)
- no UDP
- no guessing ports when the user did not specify one
- no expose workflow before login + running (Step 0)

## References

- [LOCAL-LISTENERS.md](./references/LOCAL-LISTENERS.md) — port discovery (required when port unknown)
- [TROUBLESHOOTING.md](./references/TROUBLESHOOTING.md) — failed `add`
