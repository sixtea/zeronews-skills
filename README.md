# zeronews-skills

ZeroNews 官方 **Agent Skills** 仓库（对外主仓）。供 Cursor、Claude Code 等宿主通过 [Skills CLI](https://github.com/vercel-labs/skills) 安装，在无 MCP 或需 CLI 规程时指导 Agent 安全操作 ZeroNews 客户端。

## Install

从本仓库安装全部 skills（示例：Cursor，全局拷贝）：

```bash
npx skills add <this-repo-url> -g --agent cursor --copy
```

仅安装单个 skill 时，指向 `skills/zeronews-<name>/` 或仓库根目录（以 Skills CLI 文档为准）。

## Skills vs MCP (`zeronews-mcp`)

| Host | Use |
|------|-----|
| **MCP configured** | Prefer npm **[`zeronews-mcp`](https://www.npmjs.com/package/zeronews-mcp)** |
| **Skills only** | This repository |

Agent MCP 规程：[zeronews-mcp-agent-setup.md](https://docs.zeronews.cc/raw/ai/zeronews-mcp-agent-setup.md)

维护文档：[docs/SKILL-ROUTER.md](./docs/SKILL-ROUTER.md) · [MCP-SKILLS-PARITY.md](./docs/MCP-SKILLS-PARITY.md) · [MCP-TOOL-COVERAGE.md](./docs/references/MCP-TOOL-COVERAGE.md)（**30/30 MCP tools**）· [LOCAL-EXECUTION.md](./docs/references/LOCAL-EXECUTION.md)

## Skill catalog

对外 skill 目录名均为 **`zeronews-*`**（13 个能力 + `zeronews-mcp-bridge`，见 `skills-lock.json`）。

| Skill | Purpose |
|-------|---------|
| `zeronews-install-client` | 在线安装 / 已装自动升级 |
| `zeronews-configure-client` | login / authtoken |
| `zeronews-expose-service` | 映射本地 HTTP/TCP/TLS |
| `zeronews-inspect-client` | 状态、endpoints |
| `zeronews-manage-client-service` | 系统服务启停 |
| `zeronews-expose-webhook` | Webhook / 微信支付回调 |
| `zeronews-share-files` | 目录分享 LFS |
| `zeronews-reset-client` | 本机 reset（须用户确认） |
| `zeronews-manage-account-tunnels` | 账号隧道 CRUD / 启停 |
| `zeronews-manage-platform-domains` | 平台子域 / 删端口 |
| `zeronews-manage-account-clients` | 账号设备 |
| `zeronews-upgrade-client` | 本机或远程升级 |
| `zeronews-mcp-bridge` | 已配 MCP 时的路由说明 |

## Repository layout

```
skills/zeronews-*/SKILL.md   # skill 定义
skills/*/references/         # 补充规程
docs/                        # 路由、验收、与 MCP 对照
evals/                       # skill 评测用例
```

## Monorepo mirror (transition)

开发期 monorepo 内仍可能有 **`zeronews-client-skills/`** 副本；**以本仓库 `zeronews-skills` 为 canonical**。同步脚本：`scripts/sync-from-monorepo.sh`（从 sibling 目录拉取源稿）。

## License

MIT — see [LICENSE](./LICENSE).
