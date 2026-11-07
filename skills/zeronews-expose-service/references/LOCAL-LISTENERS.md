# 本机监听端口发现（expose-service 用）

> **阶段 A 规范**。`zeronews-expose-service` SKILL **必须引用**本文（A1 验收项）。与 MCP `list_local_listeners` 为 **best-effort 等价**，不要求 JSON `choices` 字段一致。

## 何时使用

- 用户说「代理本地服务」「映射到公网」等，**没有**给出端口或 URL  
- 已通过门禁：`login: true` 且客户端 **running**（否则 handoff `zeronews-configure-client` / `manage-client-service` / `inspect-client`）

## 禁止

- 默认使用 3000、5173、8080 等「常见开发端口」  
- 在未 login 时询问「要映射哪个端口」  
- 把 Local API **`/api/v1/endpoints`** 当作全机监听列表（那只是 **已有 ZeroNews 映射**）

## 推荐步骤

1. 确定 `{WORKDIR}`（与 configure 一致）。  
2. 用 OS 命令列举 **TCP LISTEN**（按平台选一）：  
   - Linux：`ss -tlnp` 或 `ss -tln`  
   - macOS：`lsof -nP -iTCP -sTCP:LISTEN`  
   - Windows：`netstat -ano | findstr LISTEN`  
3. **排除** ZeroNews Local API 端口（常见 `127.0.0.1:37271`，以 `prg_runtime.json` / 文档为准）。  
4. 可选：与 `GET /api/v1/endpoints`（或 CLI `zeronews endpoints --json`，以 help 为准）交叉标注「该端口是否已有公网映射」；**标注失败时仍可直接列端口，不阻塞**。  
5. 将候选格式化为 **表格或编号列表**（列：地址、端口、进程、映射状态），每行一个 **label**，例如：  
   - `1) 127.0.0.1:3000 · node · 尚未映射`  
   - `2) 127.0.0.1:5432 · postgres · 已有映射 → https://…`  
6. **有 `zeronews-mcp` 时（优先）**：`list_local_listeners` → 先表格 → **强制宿主 AskQuestion**（`ask_question.options` 或 `choices[].label`）；**禁止**在聊天里让用户手打端口。点选后用 `expose_local_service(port, local_ip)`。  
7. **无 MCP（纯 CLI Skills）**：请用户 **点选序号或在 Questions 中选一项**（不要用开放式「请输入端口」）；确认后：  
   `zeronews --workdir {WORKDIR} add https --port={PORT}`（及 `--bw`、`--local_ip` 等）。

### Fallback（权限 / 平台）

- `ss -tlnp` / `lsof` 不可用：改用 `ss -tln` / `netstat`；**有 MCP 时**修好枚举后重调 `list_local_listeners`，仍走 AskQuestion。  
- **无 MCP**：可请用户 **先启动服务再重扫**；仅在用户**已在对话中明确给出端口数字**时可直接 `add`（不算猜端口）。  
- **Windows**：`netstat` 标签信息较少，仍为 best-effort；验收见 SCENARIOS **S-Win**。

## 用户已给出端口

仍执行 **login + running** 检查，然后可直接 `add`（无需完整枚举，但禁止覆盖用户未指定的端口）。

## 带宽

用户要求限速时加 `--bw=N`（Mbps），与 MCP `expose_local_service` / 控制台一致；省略时客户端默认通常为 1 Mbps（以 CLI help 为准）。

## 故障

- 枚举为空：提示用户先启动目标应用，**重扫**；有 MCP 时勿聊天索要端口  
- `add` 失败：见 [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
