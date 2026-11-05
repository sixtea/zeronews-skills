# zeronews-mcp 工具 → Skills 覆盖清单

> 对照源码：`zeronews-mcp-connector/src/server.ts`（npm **`zeronews-mcp`**）。  
> **目标**：仅 Skills、无 MCP 时，Agent 仍能通过 CLI / Local API 完成 **同等用户意图**（Questions UI 用编号列表等价，见 [MCP-SKILLS-PARITY.md](../MCP-SKILLS-PARITY.md)）。

## 图例

| 状态 | 含义 |
|------|------|
| ✅ | Skill 规程已覆盖 CLI/行为 |
| 🔀 | 多 skill 分工（同一 MCP 参数域） |
| ⚠️ | 等价但 best-effort（如端口枚举无 MCP JSON） |
| — | MCP 无对应 tool（Skills 独有） |

## 完整对照（30 个 MCP tools）

| MCP tool | CLI / 行为 | Skill(s) | 状态 |
|----------|------------|----------|------|
| `install_client` | 下载/探测/升级预检 | `zeronews-install-client` | ✅ |
| `login` | `zeronews login` + 缺客户端时安装 | `zeronews-install-client` + `zeronews-configure-client` | ✅ |
| `prompt_auth_token` | legacy → 同 `login` | `zeronews-configure-client`（优先 `login`；MCP 勿 authtoken 写配置） | ✅ |
| `configure_auth` | legacy → 同 `login` | 同上 | ✅ |
| `auth_status` | 磁盘 + `status --json` 是否 configured | `zeronews-inspect-client` | ✅ |
| `client_status` | `status --json` + 运行探测 | `zeronews-inspect-client` | ✅ |
| `list_local_listeners` | 本机 LISTEN + label | `zeronews-expose-service` + [LOCAL-LISTENERS.md](../../skills/zeronews-expose-service/references/LOCAL-LISTENERS.md) | ⚠️ |
| `expose_local_service` | 门禁 + `add` + port | `zeronews-expose-service` | ✅ |
| `add_tunnel` | `zeronews add` + type/feature/bw | 🔀 `zeronews-expose-service` / `zeronews-share-files` / `zeronews-expose-webhook` | ✅ |
| `list_endpoints` | `endpoints --json` / Local API | `zeronews-inspect-client` | ✅ |
| `list_account_tunnels` | `show tunnels --json` | `zeronews-manage-account-tunnels` | ✅ |
| `delete_tunnel` | `delete tunnel` + 二次确认 | `zeronews-manage-account-tunnels` | ✅ |
| `enable_tunnel` | `tunnel enable` | `zeronews-manage-account-tunnels` | ✅ |
| `disable_tunnel` | `tunnel disable` | `zeronews-manage-account-tunnels` | ✅ |
| `list_account_domains` | `show domains --json` | `zeronews-manage-platform-domains` | ✅ |
| `add_domain` | `add domain --subdomain` + picker | `zeronews-manage-platform-domains` | ✅ |
| `delete_domain` | `delete domain` + 确认 | `zeronews-manage-platform-domains` | ✅ |
| `delete_port` | `delete port` + 确认 | `zeronews-manage-platform-domains` | ✅ |
| `list_account_clients` | `show devices --json` | `zeronews-manage-account-clients` | ✅ |
| `delete_client` | `delete client` + 确认 | `zeronews-manage-account-clients` | ✅ |
| `enable_client` | `device enable` | `zeronews-manage-account-clients` | ✅ |
| `disable_client` | `device disable` | `zeronews-manage-account-clients` | ✅ |
| `upgrade_client` | `device download-resolve` / `device upgrade` | `zeronews-upgrade-client` | ✅ |
| `service_install` | `service install` | `zeronews-manage-client-service` | ✅ |
| `service_start` | `service start` | `zeronews-manage-client-service` | ✅ |
| `service_stop` | `service stop` | `zeronews-manage-client-service` | ✅ |
| `service_restart` | `service restart` | `zeronews-manage-client-service` | ✅ |
| `service_status` | `service status` | `zeronews-manage-client-service` | ✅ |
| `service_uninstall` | `service uninstall` | `zeronews-manage-client-service` | ✅ |
| `client_reload` | `reload --json` / `/api/v1/reconnect` | `zeronews-inspect-client`（用户明确要求时）；login 后见 `zeronews-manage-client-service` | ✅ |

## Skills 独有（无 MCP tool）

| 能力 | Skill | 说明 |
|------|-------|------|
| 本机 `zeronews reset` | `zeronews-reset-client` | 破坏性；须用户明确确认 |
| MCP vs Skills 路由 | `zeronews-mcp-bridge` | 用户声明已配 MCP 时避免重复 CLI 链 |

## MCP 参数 → Skills 等价

| MCP | Skills 等价 |
|-----|-------------|
| `install_client.download_install=false` | 只探测：不下载、不升级 → `zeronews-install-client` 探测分支 + `zeronews-inspect-client` |
| `delete_* .user_confirmed=true` | 编号选择后 **第二步** 口头确认 → CLI delete（[DELETE-CONFIRMATION.md](./DELETE-CONFIRMATION.md)） |
| `add_domain` 无 `subdomain` | 4 个随机 8 位前缀 + 自定义 → [SUBDOMAIN-PREFIX.md](../../skills/zeronews-manage-platform-domains/references/SUBDOMAIN-PREFIX.md) |
| `list_account_*` 分页 | CLI `--workspace-id` / `--page` / `--size`（manage-* skills Step list） |
| `add_tunnel.bw` | `--bw=N` Mbps（expose / share / webhook skills） |
| `choices[].label` picker | 编号列表；用户回复序号（禁止 Agent 代选） |

## 审核结论（2026-11-05）

- **30/30 MCP tools** 均有 Skills 路径；无遗漏 tool。
- **已知不等价边界**：`list_local_listeners` 结构化 JSON、MCP elicitation、连接器内 HTTP 下载逻辑 — 见 [SKILLS-OPTIMIZATION-PLAN.md](../SKILLS-OPTIMIZATION-PLAN.md) parity 脚注。
- 维护者改 MCP 时：**先改本表 + 对应 skill**，再发 `zeronews-mcp` / `zeronews-skills`。
