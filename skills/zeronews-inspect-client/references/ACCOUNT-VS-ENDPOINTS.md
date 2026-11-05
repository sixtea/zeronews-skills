# 账号隧道 vs 本机 endpoints

Agent 常把「我有哪些映射」和「账号里所有隧道」混为一谈。Skills 路径要分开数据来源。

## 本机 endpoints（运行中客户端）

**含义**：当前这台机器、当前 workdir 下客户端 **已生效** 的公网映射。

**读取方式**（只读，runtime 健康时）：

- Local API: `GET /api/v1/endpoints` — see [LOCAL-API.md](./LOCAL-API.md)
- CLI（若 help 提供）: `zeronews --workdir {WORKDIR} endpoints --json`

用于：expose 前标注「该端口是否已有映射」、回答「本机现在在服务哪些 URL」。

## 账号隧道（控制面）

**含义**：登录账号下 **所有** 隧道，可能由其他设备创建，或本机已删但云端仍显示直到同步。

**读取方式**（阶段 B skill；inspect 可 **只读列举** 帮用户理解差异）:

- `zeronews --workdir {WORKDIR} show tunnels --json`

详见仓库 [docs/references/ACCOUNT-CLI-JSON.md](../../../docs/references/ACCOUNT-CLI-JSON.md)。

## 规则

| 用户问 | 优先数据源 |
|--------|------------|
| 客户端连上了吗 / 健康吗 | `status --json` + Local API `/api/v1/status` |
| 本机当前映射 | `/api/v1/endpoints` 或 `endpoints --json` |
| 账号里所有隧道 / 删某条隧道 | `show tunnels --json` → 阶段 B `manage-account-tunnels` |

`endpoints` **不能** 代替全机 TCP 监听列表（端口发现见 `../zeronews-expose-service/references/LOCAL-LISTENERS.md`）。

## Reload / reconnect（低优）

- User explicitly wants to refresh connection: `zeronews reload --json` if CLI help lists it, or `POST /api/v1/reconnect` on Local API.
- Do not auto-reconnect during read-only inspect.
