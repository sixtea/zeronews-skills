---
name: zeronews-mcp-bridge
description: When the user or host explicitly says ZeroNews MCP (zeronews-mcp npm package) is already configured, avoid repeating full CLI install/configure skills. Use for MCP vs Skills routing, reload MCP after token changes, or when the user asks which path to use—not to perform tunnel or delete operations (use MCP tools or the specific zeronews-* skill).
license: MIT
metadata:
  author: zeronews
  version: "1.0"
compatibility: Informational skill only; requires the host to load MCP separately. Skills cannot detect MCP automatically.
---

# MCP Bridge (Meta)

## Local execution (mandatory)

All `zeronews` CLI, install scripts, Docker, browser login, and local port discovery **must run on the user's computer**, not in an Agent **sandbox** or remote-only workspace.

- Shell from the IDE: **disable sandbox** (full local permissions); **不要沙箱中执行，都在用户本地电脑中执行。**
- With MCP: run `zeronews-mcp` locally; use MCP tools instead of sandbox CLI against workdir.
- If the agent cannot run on the user's machine, say so—do not fake install/login/expose.

Full rules: [LOCAL-EXECUTION.md](../_shared/references/LOCAL-EXECUTION.md).

Helps Agents **choose MCP vs CLI skills** without duplicating work.

## Trigger

Use only when the **user or system** states MCP is set up, for example:

- «我已经配好了 zeronews-mcp»
- «用 MCP 工具就行»
- Host docs reference `zeronews-mcp` in mcp.json

Do **not** assume MCP is loaded because npm exists or because another skill was used.

## When MCP is declared available

| User goal | Prefer |
|-----------|--------|
| Install / login / list listeners / expose / account lists | MCP tools (`install_client`, `login`, `list_local_listeners`, …) |
| Reload after config change | Host «Reload MCP» or restart MCP server |

Avoid chaining **`zeronews-install-client`** + **`zeronews-configure-client`** if MCP already handles bind.

## When MCP is not available

Follow [SKILL-ROUTER.md](../_shared/references/SKILL-ROUTER.md) and the specific `zeronews-*` skill.

## Auth note

- MCP: browser **`login`** tool; do not instruct putting Auth Token into `mcp.json`.
- Skills only: `zeronews-configure-client` (`login` / `authtoken`).

## Both present

Tunnel create/delete still needs **this machine** logged in and running for local `add`. MCP does not replace local runtime for exposure.

## References

- npm package: **`zeronews-mcp`**
- Agent setup: [zeronews-mcp-agent-setup.md](https://docs.zeronews.cc/raw/ai/zeronews-mcp-agent-setup.md)
- Router: [SKILL-ROUTER.md](../_shared/references/SKILL-ROUTER.md)
