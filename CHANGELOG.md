# Changelog

## Unreleased

### Documentation

- 新增 `docs/references/MCP-TOOL-COVERAGE.md`：对照 `server.ts` **30 个 MCP tool** 全覆盖审核。
- 各 skill 增加 **MCP mapping** 小节；修复 expose-webhook → expose-service 引用路径。
- 更新 `docs/MCP-SKILLS-PARITY.md` 工具级对照表。

### Repository

- 初始 **`zeronews-skills`** 对外主仓：自 monorepo `zeronews-client-skills` 同步 `skills/`、`docs/`、`evals/`。
- **去重**：删除 13 个短名 skill 目录；冲突处以 MCP 优化版为准（`zeronews-install-client` v1.2 + UPGRADE-ON-INSTALL、`zeronews-upgrade-client` v1.2、`manage-*` DELETE-CONFIRMATION v1.1）。

### Documentation

- 新增 `docs/references/LOCAL-EXECUTION.md`：**禁止 Agent 沙箱**；MCP/CLI 均在用户本机执行；26 个 skill 正文 + SKILL-ROUTER / MCP-SKILLS-PARITY。
- 新增 `docs/SKILLS-OPTIMIZATION-PLAN.md`：相对 **zeronews-mcp** 的 Skills 完善方案（阶段 A–D）。
- 新增 `docs/SKILL-ROUTER.md`、`docs/MCP-SKILLS-PARITY.md`、`docs/SCENARIOS.md`。
- 新增 `docs/references/ACCOUNT-CLI-JSON.md`（阶段 B 提纲）。
- 新增 `skills/zeronews-expose-service/references/LOCAL-LISTENERS.md`（阶段 A 端口发现规范）。
- 更新根 `README.md`：MCP 并存、文档索引、示例话术。
- **方案审核修订**：parity 脚注、认证双路径、阶段 D 收窄、B0 CLI 门禁、S-Win、LOCAL-LISTENERS fallback、mcp-bridge 基于用户声明。
- **方案第二轮**：PLAN §3.7 skill 分工；A 验收（无端口 Pre-flight）、A3b、version bump 策略；`PR-CHECKLIST.md`、`DOC-SITE-SYNC.md`；B skill 命名表。

### Skills (phase A)

- `zeronews-expose-service` v1.1：Step 0 门禁、LOCAL-LISTENERS、移除 webhook/LFS 主路径、强化 description。
- `inspect-client` v1.1：endpoints vs 账号隧道、`ACCOUNT-VS-ENDPOINTS.md`、expose 门禁 helper。
- `zeronews-configure-client` / `manage-client-service` v1.1：login 后 restart cross-ref。
- `zeronews-install-client` v1.1：已安装/探测/升级 handoff 表。
- `evals/evals.json`：阶段 A 验收话术（skill-creator 测试集）。

### Skills (phase B / C / D)

- 新增 `manage-account-tunnels`、`manage-platform-domains`、`manage-account-clients`、`upgrade-client`、`mcp-bridge`。
- `ACCOUNT-CLI-JSON.md`：MCP 对齐 + 结构样例 JSON。
- 更新 ROUTER、PARITY、SCENARIOS、README、DOC-SITE-SYNC。

### Audit fixes (P1/P2)

- `share-files` / `expose-webhook` v1.1：Step 0 门禁、webhook 无端口走 LOCAL-LISTENERS、`--bw`。
- `ACCOUNT-CLI-JSON` + B skills：`items[]` / `page.items[]` 统一；各 skill  bundled `CLI-JSON-PATHS.md`。
- `manage-account-tunnels` handoff 命名；`upgrade-client` 本机离线 handoff `zeronews-install-client`。
- **`zeronews-install-client` v1.2**：已安装自动对齐 latest（[UPGRADE-ON-INSTALL.md](../skills/zeronews-install-client/references/UPGRADE-ON-INSTALL.md)）；**不问**是否升级。
- **`upgrade-client` v1.2**：去掉升级确认；install 触发时自动执行。
- **删除二次确认**：MCP `delete_*` 增加 **`user_confirmed`** 门禁；Skills [DELETE-CONFIRMATION.md](./docs/references/DELETE-CONFIRMATION.md)；manage-* v1.1。
- 审核修复：`resource-picker` delete 文案；`docs/README` + PARITY 删除对照表。

### Planned (see optimization plan)

- **A**：~~修订 expose/configure/inspect/install/manage SKILL~~ **已完成 v1.1**（2026-11 方案落地）。
- **B**：~~新 skills~~ **已添加** `manage-account-tunnels`、`manage-platform-domains`、`manage-account-clients`。
- **C**：~~`upgrade-client`~~ **已添加**。
- **D**：~~可选 mcp-bridge~~ **已添加** `skills/zeronews-mcp-bridge/SKILL.md`。
