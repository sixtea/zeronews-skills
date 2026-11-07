# zeronews-skills

ZeroNews 官方 **Agent Skills**。供 Cursor、Claude Code 等通过 [Skills CLI](https://github.com/vercel-labs/skills) 安装，在无 MCP 时指导 Agent 使用 `zeronews` CLI。

## Install

```bash
npx skills add sixtea/zeronews-skills -g --all
```

或指定 Agent（示例 Cursor，全局拷贝）：

```bash
npx skills add sixtea/zeronews-skills -g --agent cursor --copy
```

Skill 目录在仓库 **`skills/zeronews-*`** 下（共 13 个能力 skill + `zeronews-mcp-bridge`）。

## Skills vs MCP

| 场景 | 使用 |
|------|------|
| 已配置 **`zeronews-mcp`** | 优先 MCP 工具 |
| 仅 Skills | 本仓库 |

MCP 安装规程：<https://docs.zeronews.cc/raw/ai/zeronews-mcp-agent-setup.md>

## Skill 列表

| 目录 | 用途 |
|------|------|
| `zeronews-install-client` | 安装 + Step 3 绑机（setup 全量勿再 configure） |
| `zeronews-configure-client` | 仅绑机 / authtoken（CLI 已在） |
| `zeronews-expose-service` | 映射本地 HTTP/TCP/TLS |
| `zeronews-inspect-client` | 状态、本机 endpoints |
| `zeronews-manage-client-service` | 系统服务 |
| `zeronews-expose-webhook` | Webhook 隧道 |
| `zeronews-share-files` | 目录分享 LFS |
| `zeronews-reset-client` | 本机 reset |
| `zeronews-manage-account-tunnels` | 账号隧道 |
| `zeronews-manage-platform-domains` | 平台域名 |
| `zeronews-manage-account-clients` | 账号设备 |
| `zeronews-upgrade-client` | 升级客户端 |
| `zeronews-mcp-bridge` | 已配 MCP 时的路由说明 |

共享规程（skill 内引用）：`skills/_shared/references/`

## License

MIT — see [LICENSE](./LICENSE).
