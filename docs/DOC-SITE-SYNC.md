# 对外 docs 站同步清单（阶段 D）

docs 站基址以环境为准（示例：`https://docs.zeronews.cc`）。**负责人 / 上线版本 TBD** — 填表后关 D 阶段项。

| 仓库内锚点 | docs 站路径（建议） | 同步内容 | 状态 |
|------------|---------------------|----------|------|
| 根 `README.md` Agent Skills 节 | `/ai/agent-skills` 或现有 Skills 页 | 安装 skill 包、与 MCP 并存说明 | TBD |
| [SKILL-ROUTER.md](./SKILL-ROUTER.md) | 同上页「路由」折叠块 | 话术 → skill 表（可摘要） | TBD |
| [SCENARIOS.md](./SCENARIOS.md) | 维护者文档 / 内部 | 可不对外全文；对外只保留用户示例话术 | TBD |
| B：`manage-account-tunnels` | Skills 页新增小节 | 账号隧道 CRUD + 安全确认 | 仓库 skill 已有 |
| B：`manage-platform-domains` | Skills 页新增小节 | 子域 / 删端口 | 仓库 skill 已有 |
| B：`manage-account-clients`（若做） | Skills 页新增小节 | 设备列表 / 删客户端 | 仓库 skill 已有 |
| C：`upgrade-client` | Skills + 可选 install 页交叉链 | 升级 CLI / 远程 device | 仓库 skill 已有 |
| D：`mcp-bridge` 或 README 节 | agent-setup 旁链 | 已配 MCP 勿重复 CLI 链 | 仓库 skill 已有 |
| npm **`zeronews-mcp`** | 已有 MCP 安装文档 | 包名统一 `zeronews-mcp`；与 Skills 选型一句 | 部分完成 |

**验收**：B/C skill 合并后，上表对应行「状态」改为「已同步 + 日期 + PR 链接」。
