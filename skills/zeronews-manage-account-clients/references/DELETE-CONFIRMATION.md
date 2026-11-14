# 删除操作 — 二次确认（隧道 / 域名 / 端口 / 客户端）

**点选要删的对象 ≠ 确认删除。** MCP 与 Skills 路径都必须遵守。

## 流程（两步）

1. **选定目标**：Questions / 编号列表 → 用户选隧道、域名、端口或客户端（得到 id）。
2. **单独确认**：用自然语言复述将删除的对象（label + id 简写），询问用户是否确认；仅当用户明确 **确认删除 / yes / 是，删掉** 后，才执行 CLI 或 MCP。

禁止：用户刚点选选项就立刻 `delete …`；禁止把「我要删 test 隧道」直接当成已确认（仍须复述 id 并确认）。

## MCP

`delete_tunnel` / `delete_domain` / `delete_port` / `delete_client`：

- 第一次带 id 且 **`user_confirmed` 不为 true** → 返回 **`step: needs_user_confirmation`**，不调用 CLI。
- 用户确认后 → 再次调用同一 tool，**相同 id** + **`user_confirmed: true`**。

## Skills（CLI）

在运行下列命令 **之前** 必须完成步骤 2：

- `zeronews delete tunnel {ID} --json`
- `zeronews delete domain {ID} --json`
- `zeronews delete port {ID} --json`
- `zeronews delete client {ID} --json`

适用 skill：`zeronews-manage-account-tunnels`、`zeronews-manage-platform-domains`、`zeronews-manage-account-clients`。

## 非删除

`tunnel <id> enable/disable/set-bw`、`device enable/disable` 仍按各 skill 说明；本规则 **仅针对 delete**。
