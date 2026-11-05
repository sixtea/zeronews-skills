# MCP 与 Client Skills 能力对照

实现参考：`zeronews-mcp-connector/src/server.ts`（npm **`zeronews-mcp`**），connector 规程 `connector/skills/zeronews/SKILL.md`。

**本机执行**：MCP 与 Skills 均须在 **用户本地电脑** 运行 CLI / 浏览器登录；Agent **不要沙箱执行**。见 [LOCAL-EXECUTION.md](./references/LOCAL-EXECUTION.md)。

**完整 30 工具清单（审核用）**：[MCP-TOOL-COVERAGE.md](./references/MCP-TOOL-COVERAGE.md) — **30/30 MCP tools 均有 Skills 覆盖**。

## 按能力域（摘要）

| 域 | MCP tools | Skills |
|----|-----------|--------|
| 安装 / 绑定 | `install_client`, `login`, `auth_status`, `client_status`, `configure_auth`†, `prompt_auth_token`† | `zeronews-install-client`, `zeronews-configure-client`, `zeronews-inspect-client` |
| 暴露本机 | `list_local_listeners`‡, `expose_local_service`, `add_tunnel` | `zeronews-expose-service`；LFS/webhook → share / expose-webhook |
| 本机观测 | `list_endpoints`, `client_reload` | `zeronews-inspect-client` |
| 账号隧道 | `list_account_tunnels`, `delete_tunnel`, `enable_tunnel`, `disable_tunnel` | `zeronews-manage-account-tunnels` |
| 账号域名 | `list_account_domains`, `add_domain`, `delete_domain`, `delete_port` | `zeronews-manage-platform-domains` |
| 账号设备 | `list_account_clients`, `delete_client`, `enable_client`, `disable_client` | `zeronews-manage-account-clients` |
| 升级 | `upgrade_client` | `zeronews-upgrade-client` |
| 系统服务 | `service_install` … `service_uninstall` | `zeronews-manage-client-service` |
| 路由 | — | `zeronews-mcp-bridge`（已配 MCP 时） |
| 本机 reset | — | `zeronews-reset-client`（仅 Skills） |

† legacy MCP 别名，行为同 `login`。  
‡ Skills 用 [LOCAL-LISTENERS.md](../skills/zeronews-expose-service/references/LOCAL-LISTENERS.md) **best-effort** 等价。

## 工具级对照（与 MCP 注册名一致）

| MCP tool | Skills 覆盖 |
|----------|-------------|
| `install_client` | `zeronews-install-client` |
| `login` | `zeronews-configure-client` / install 链 |
| `prompt_auth_token` / `configure_auth` | `zeronews-configure-client`（Skills 仍可用 `authtoken` 若用户给 token） |
| `auth_status` / `client_status` | `zeronews-inspect-client` |
| `list_local_listeners` | `zeronews-expose-service` + LOCAL-LISTENERS |
| `expose_local_service` | `zeronews-expose-service` |
| `add_tunnel` | `zeronews-expose-service` / `zeronews-share-files` / `zeronews-expose-webhook` |
| `list_endpoints` | `zeronews-inspect-client` |
| `list_account_tunnels` | `zeronews-manage-account-tunnels` |
| `delete_tunnel` / `enable_tunnel` / `disable_tunnel` | `zeronews-manage-account-tunnels` |
| `list_account_domains` | `zeronews-manage-platform-domains` |
| `add_domain` | `zeronews-manage-platform-domains` |
| `delete_domain` / `delete_port` | `zeronews-manage-platform-domains` |
| `list_account_clients` | `zeronews-manage-account-clients` |
| `delete_client` / `enable_client` / `disable_client` | `zeronews-manage-account-clients` |
| `upgrade_client` | `zeronews-upgrade-client` |
| `service_install` / `service_start` / `service_stop` / `service_restart` / `service_status` / `service_uninstall` | `zeronews-manage-client-service` |
| `client_reload` | `zeronews-inspect-client`（显式修复）；configure 后 restart → manage-client-service |

## Install vs upgrade（Skills）

| 用户意图 | Skills 路径 |
|----------|-------------|
| 装客户端 / expose 前门禁 | `zeronews-install-client`（已存在则自动 version sync） |
| 只探测、不下载 | `zeronews-install-client` 探测分支（≈ MCP `download_install=false`） |
| 升**本机**且在线 | `zeronews-upgrade-client` |
| 升**其他在线设备** | `zeronews-upgrade-client` |
| 换二进制、未 login | `zeronews-install-client` |

## Skills 中 Questions UI 的等价

MCP 返回 `choices[].label` 由宿主 **AskQuestion** 渲染。Skills 路径：

1. Agent 列出 **编号选项**（一行一个 label）  
2. 用户回复序号或复制 label  
3. 再执行带 **明确 port / tunnel_id / domain_id** 的 CLI  

禁止 Agent 自行选择「最常见端口」。

## 删除资源 — MCP `user_confirmed` vs Skills

| 步骤 | MCP | Skills |
|------|-----|--------|
| 1 | `choices` 或已知 id | 编号列表 / 用户给 id |
| 2 | 单独一步：**确认删除** | [DELETE-CONFIRMATION.md](./references/DELETE-CONFIRMATION.md) |
| 3 | `user_confirmed: true` + 相同 id | `zeronews delete … --json` |

> **Parity 边界**：见 [SKILLS-OPTIMIZATION-PLAN.md](./SKILLS-OPTIMIZATION-PLAN.md) §2 脚注。
