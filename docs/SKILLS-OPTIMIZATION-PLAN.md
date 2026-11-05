# ZeroNews Client Skills 完善方案

> 状态：**已立项（文档版）** · 对照实现：**[`zeronews-mcp`](https://www.npmjs.com/package/zeronews-mcp)**（monorepo：`zeronews-mcp-connector/`）  
> 目标：仅 Skills、无 MCP 的 Agent 在用户意图上与 MCP 行为 **一致、可预期**；补齐控制面 CLI 文档，不引入 Node 运行时。

---

## 1. 背景

| 项目 | 形态 | 作用 |
|------|------|------|
| **zeronews-client-skills** | Markdown Agent Skills | Agent 读 SKILL.md，在终端执行 **`zeronews` CLI** + Local API 只读 |
| **zeronews-mcp** | stdio MCP 服务 | 宿主加载 **具名 tool**，封装 CLI / Local API / 控制面 HTTP |

两者底层均为同一 **ZeroNews 客户端**。官网与用户控制台约定：

- 宿主 **已配置 MCP** → 优先 **zeronews-mcp**
- **仅 Skills** → 使用本仓库

本方案 **不** 在 Skills 中复制 MCP tool 实现，只补齐 **规程、缺口 skill、共享 reference**。

---

## 2. 能力对照与缺口

| 能力域 | MCP（参考） | Skills 现状 | 缺口 |
|--------|-------------|-------------|------|
| 安装 / 绑定 | `install_client`、`login` | `zeronews-install-client`、`zeronews-configure-client` | 升级预检、仅探测、与 `device download-resolve` 对齐 |
| 暴露本机服务 | `list_local_listeners` → 选端口 → `expose_local_service` | `zeronews-expose-service` 直接问端口 | **禁止猜端口**、先枚举监听、login/running **硬门禁** |
| 本机映射 | `list_endpoints` | `inspect-client`（Local API endpoints） | 需写明 **endpoints ≠ 账号下全部隧道** |
| 账号资源 | `list/delete/enable/disable` 隧道·域名·端口·设备；`add_domain` | **无** | **最大缺口** |
| LFS / Webhook | `add_tunnel` + feature | `share-files`、`expose-webhook` | **`--bw`**；expose-service **不写** file_share/webhook 主路径（见 §3.7） |
| 服务守护 | `service_*` | `manage-client-service` | A3 核对 **login 后 restart**（configure Step 2 已有；manage 补 cross-ref） |
| 认证 | 浏览器 login 为主 | login + authtoken | 保留 authtoken；expose/delete 流程统一 **login_pending** 规则 |

完善后能力 parity（相对 MCP）：约 **55% → 90%**（见下方脚注）；剩余 **Questions UI** 在 Skills 中用 **编号列表 + 用户选序号** 等价。

> **Parity 脚注（90% 含义）**  
> - **算入**：本机 install/configure/expose/inspect/service、账号侧 CLI 删改查（阶段 B）、升级（阶段 C）。  
> - **不算入 / 不等价**：宿主 **AskQuestion**、MCP elicitation 表单、连接器内 **`list_local_listeners` 结构化 JSON**、控制面 HTTP 自动下载（`install_client` 服务端逻辑）、WorkBuddy zip 上传。  
> - 端口发现为 **best-effort 等价**（见 LOCAL-LISTENERS），不要求与 MCP `choices[]` 字段级一致。

---

## 3. 统一设计原则

1. **分工**：有 MCP 时不重复跑完整 CLI 安装链；见 [SKILL-ROUTER.md](./SKILL-ROUTER.md)（认证双路径）与可选 **mcp-bridge**（阶段 D，基于用户声明）。
2. **栈约束**（与根目录 README 一致）  
   - **变更** → CLI  
   - **观测** → Local API（`/healthz`、`/api/v1/status` 等）  
   - **不** 手改 `config.yml`
3. **暴露本地服务 SOP**（迁入 `zeronews-expose-service` + [LOCAL-LISTENERS.md](../skills/zeronews-expose-service/references/LOCAL-LISTENERS.md)）  
   - 顺序：已 configure 且 **login** → **running** → **枚举本机 TCP 监听** → 用户确认端口 → `zeronews add`  
   - 禁止：未给出端口时默认 3000/5173；未 login 时询问映射哪一端口  
   - 枚举：OS 命令（`ss` / `lsof` 等）+ 排除 Local API 口（默认约 `127.0.0.1:37271`）；**best-effort**（权限不足时用简化列表或请用户口述端口）  
   - **endpoints** 列表只表示 **已有 ZeroNews 映射**，不能代替全机监听列表
4. **认证双路径**（避免 Agent 混用 MCP 与 Skills）  

   | 场景 | 绑定方式 |
   |------|----------|
   | **Skills only** | `zeronews login` 或用户已提供 token 时 `zeronews authtoken` |
   | **MCP 已配置** | 用 MCP **`login`** / 浏览器确认；**不要**用 Skills 教用户把 Token 写进 `mcp.json` |
   | **MCP + Skills 并存** | 暴露/删资源前仍须本机 **login + running**；认证动作优先 MCP，不重复 authtoken 链 |

5. **destructive 操作**：`delete`、`reset`、`service_uninstall` 等 **必须用户明确确认**（对齐 MCP delete_*）。
6. **对外命名**：提及 npm 连接器时统一 **`zeronews-mcp`**；Agent 规程见 docs 站 `zeronews-mcp-agent-setup.md`。
7. **Skill 分工（避免与 MCP `add_tunnel` 混用）**  

   | 用户意图 | 使用 skill | 勿用 |
   |----------|------------|------|
   | 暴露本机 HTTP/TCP/TLS 端口 | `zeronews-expose-service` | 不要用 expose 处理 LFS 根目录分享 |
   | 目录 LFS / `file_share` | `zeronews-share-files` | 不要在 expose-service Pre-flight 里选 file_share |
   | 微信等 webhook 隧道 | `zeronews-expose-webhook` | 标准 webhook 优先 handoff 专用 skill |
   | 带宽 `--bw` | expose / share / webhook 各自 SKILL 内写清 | 与 MCP 一致，默认 1 Mbps |

---

## 4. 分阶段实施

### 阶段 A — 高收益（P0，约 1～2 人日）

| ID | 交付 | 说明 |
|----|------|------|
| A1 | 修订 `skills/zeronews-expose-service/SKILL.md` | **Step 0** 门禁（login+running）；无端口时走 [LOCAL-LISTENERS.md](../skills/zeronews-expose-service/references/LOCAL-LISTENERS.md)；**禁止** Pre-flight 在未给端口时问 port；`--bw`；**移除** Pre-flight 的 file_share/webhook 主路径（handoff §3.7）；`metadata.version` → `1.1` |
| A2 | `LOCAL-LISTENERS.md` | 已完成；A1 **必须**链接本文 |
| A3 | `inspect-client` | 账号 `show tunnels` vs 本机 endpoints；`endpoints --json` / reload（reference 或正文） |
| A3b | `zeronews-configure-client` + `manage-client-service` | **核对** configure Step 2（login 后 start/restart/reload）与方案一致；manage 增加「browser login 改 config 后若服务在跑 → restart」cross-ref |
| A4 | `zeronews-install-client` | 已安装 / 升级 / 仅探测分支（提纲对齐 PARITY install vs upgrade） |
| A5 | 文档 | README/CHANGELOG/**docs 索引** 已完成；**A1–A4 全部合并后** 统一 bump 各 touched skill 的 `metadata.version` |

**验收（阶段 A 关闭条件）**：

1. [SCENARIOS.md](./SCENARIOS.md)：**S2、S3、S4、S-Win** 人工评审通过。  
2. `zeronews-expose-service`：用户**未给端口**时，SKILL 正文**不得**在 Pre-flight 列出「local port」必问项；须先 LOCAL-LISTENERS。  
3. [PR-CHECKLIST.md](./PR-CHECKLIST.md) 对 A 相关 diff 勾选通过。

### 阶段 B — 控制面（P1，约 2～3 人日）

**B0（开工门禁）**：对照本机 `zeronews … --help` 与 monorepo MCP `exec-cli` 调用，核对 [ACCOUNT-CLI-JSON.md](./references/ACCOUNT-CLI-JSON.md) 命令名与 `--json` 字段；补充 **脱敏 JSON 样例** 后再写 SKILL 正文。

| 新 Skill | 目录 | `name`（frontmatter） | 说明 |
|----------|------|----------------------|------|
| 账号隧道 | `skills/zeronews-manage-account-tunnels/` | `zeronews-manage-account-tunnels` | `show tunnels --json`、`delete tunnel`、`tunnel enable/disable` |
| 平台域名 | `skills/zeronews-manage-platform-domains/` | `zeronews-manage-platform-domains` | `add domain --subdomain`、`show domains --json`、`delete port/domain` |
| 账号客户端（可选） | `skills/zeronews-manage-account-clients/` | `zeronews-manage-account-clients` | `show devices --json`、`delete client`、device enable/disable |

B 阶段每个新 skill 需：`SKILL.md` + 链到 [ACCOUNT-CLI-JSON.md](./references/ACCOUNT-CLI-JSON.md)；`description` 一行说明触发话术（供 Agent 选型）。

共享 reference：[ACCOUNT-CLI-JSON.md](./references/ACCOUNT-CLI-JSON.md)（JSON 字段、分页、确认话术）。

**验收**：与 MCP `list_account_*` / `delete_*` / `add_domain` 同类用户话术，Skills 路径可走通 CLI。

### 阶段 C — 升级（P2，约 1 人日）

| 交付 | 说明 |
|------|------|
| 新 skill `upgrade-client` | 本机 `device download-resolve`、远程 `device upgrade`；与 `zeronews-install-client` 分工表（见 [MCP-SKILLS-PARITY.md](./MCP-SKILLS-PARITY.md)） |

### 阶段 D — 维护与同步（P3，约 0.5～1 人日）

> ROUTER / PARITY / SCENARIOS 已建立；本阶段 **不再重复** 编写这三份文档。

| 交付 | 说明 |
|------|------|
| 可选 `skills/zeronews-mcp-bridge/SKILL.md` 或 README 短节 | **基于用户/宿主声明**「已配 zeronews-mcp」时勿重复 CLI 安装链；不声称自动检测 MCP |
| [DOC-SITE-SYNC.md](./DOC-SITE-SYNC.md) | docs 站锚点与 B 新 skill 映射（负责人 TBD → 填表） |
| [SCENARIOS.md](./SCENARIOS.md) + [PR-CHECKLIST.md](./PR-CHECKLIST.md) | 阶段 A/B/C **回归门禁** |

---

## 5. 完善后的 Skills 全景（目标）

```text
安装链:   install-client → configure-client → manage-client-service
本机暴露: inspect-client (门禁) → expose-service | share-files | expose-webhook
本机只读: inspect-client
账号面:   manage-account-tunnels | manage-platform-domains | (manage-account-clients)
升级:     upgrade-client
清理:     reset-client（极窄触发）
Meta:     README 选型 + 可选 mcp-bridge
```

---

## 6. 明确不做

- 不在 Skills 仓库增加 Node/脚本运行时  
- 不把 MCP **tool 名**当作 Skills 主路径（除 mcp-bridge 说明）  
- 不删除 `authtoken` 文档（无 GUI / 自动化场景仍需要）

---

## 7. 跟踪

| 阶段 | 状态 | 备注 |
|------|------|------|
| A | **SKILL 正文已完成（A1–A4）** | 待人工 SCENARIOS S2–S4/S-Win + PR-CHECKLIST |
| B | **SKILL 已写入** | B0 样例 JSON 为结构示意；本机 help 签字待维护者 |
| C | **SKILL 已写入** | 与 install-client handoff 已链 |
| D | **部分** | `mcp-bridge` skill 已有；DOC-SITE-SYNC 填表、回归待做 |

更新本表与各文档时，请同步 `CHANGELOG.md`。

---

## 8. 相关文档

- [SKILL-ROUTER.md](./SKILL-ROUTER.md) — 话术路由  
- [MCP-SKILLS-PARITY.md](./MCP-SKILLS-PARITY.md) — 能力对照表  
- [SCENARIOS.md](./SCENARIOS.md) — 验收场景（含 S-Win）
- [PR-CHECKLIST.md](./PR-CHECKLIST.md) — 阶段 A/B PR 自检
- [DOC-SITE-SYNC.md](./DOC-SITE-SYNC.md) — 对外 docs 站同步清单
- [references/ACCOUNT-CLI-JSON.md](./references/ACCOUNT-CLI-JSON.md) — 账号 CLI JSON（阶段 B）
