# 账号侧 CLI（`--json`）— 阶段 B 共享 reference

> **状态**：命令与 MCP connector **已对齐**（B0 代码侧）；脱敏 **样例 JSON** 为结构示意，上线前建议本机跑一次 `--json` 替换占位值。

## B0：CLI 核对清单（开工门禁）

- [x] 命令名与 monorepo MCP `exec-cli` / `list-account-resources` 一致（2026-11 核对）
- [ ] 本机 `zeronews --help` 最终签字（维护者）
- [ ] 用真实 `--json` 输出替换下方样例中的占位 id

## 前提

- 本机已 **login**（`zeronews status --json` → `login: true`）
- 变更命令使用：`zeronews --workdir {WORKDIR} … --json`
- **删除类**命令前必须与用户确认（**点选对象后须二次确认**，见 [DELETE-CONFIRMATION.md](./DELETE-CONFIRMATION.md)）

## 列举

| 意图 | 命令 | 列表行 ID |
|------|------|-----------|
| 账号隧道分页 | `zeronews show tunnels --json` | `items[].id`（见下节解析） |
| 账号域名（含 ports） | `zeronews show domains --json` | `items[].id`；`items[].ports[].id` |
| 账号客户端设备 | `zeronews show devices --json` | `items[].id`（即 client_id） |

可选：`--workspace-id`、`--page`、`--size`（MCP 使用 `--workspace-id` 连字符形式）。

## 解析 `show * --json` 列表

CLI **stdout** 通常为单个 JSON 对象。行数据优先取 **`items[]`**；若嵌套在分页对象下则取 **`page.items[]`**：

```text
items = root.items ?? root.page?.items ?? []
```

Skills 内说明：[manage-account-tunnels/references/CLI-JSON-PATHS.md](../../skills/zeronews-manage-account-tunnels/references/CLI-JSON-PATHS.md)（三份 B skill 各有一份副本便于打包）。

## 变更

| 意图 | 命令 | 确认 |
|------|------|------|
| 删隧道 | `zeronews delete tunnel <id> --json` | 选定 id 后 **单独一步** 确认 |
| 启停隧道 | `zeronews tunnel enable/disable <id> --json` | disable 建议确认 |
| 加平台域名 | `zeronews add domain --subdomain <prefix> --json` | 前缀 6–12 小写字母数字 |
| 删端口 | `zeronews delete port <id> --json` | 选定 id 后 **单独一步** 确认 |
| 删域名 | `zeronews delete domain <id> --json` | 须无 port；**单独一步** 确认 |
| 删客户端 | `zeronews delete client <id> --json` | **单独一步** 确认；注意 LB 策略限制 |
| 远程升级 | `zeronews device upgrade <id> --json` | 预检 `device download-resolve` |

## 多选 UI（Skills）

当 ID 未知时：解析 JSON → 编号列表 → 用户选序号 → **二次确认** → 再 delete（见 DELETE-CONFIRMATION）。

子域未提供时：生成 **4 个随机 8 字符前缀**供选，或用户自定义（校验规则同 MCP `add_domain`）。

## 与本机 endpoints 的区别

- `show tunnels`：**账号**维度，可能包含非本机创建的隧道  
- Local API `/api/v1/endpoints`：**本机运行中客户端**已生效映射  

勿混用。

## 样例 JSON（结构示意 — 脱敏）

`show tunnels --json`（分页壳 + items，路径以本机 CLI 为准）:

```json
{
  "total": 2,
  "items": [
    {
      "id": "tunnel_id_example_abc",
      "type": "https",
      "enabled": true,
      "subdomain": "myapp",
      "root_domain": { "domain": "example.zeronews.cc" }
    }
  ]
}
```

MCP 连接器把同一段 JSON 放在响应字段 `page` 里；Skills 路径只解析 **CLI stdout**，用上一节 **`items[]` / `page.items[]`** 规则即可。

`show domains --json`:

```json
{
  "total": 1,
  "items": [
    {
      "id": "domain_id_example",
      "domain": "myapp.example.zeronews.cc",
      "ports": [{ "id": "port_id_example", "public_url": "https://…" }]
    }
  ]
}
```

`show devices --json`:

```json
{
  "total": 1,
  "items": [
    {
      "id": "client_id_example",
      "custom_name": "dev-mac",
      "enabled": true,
      "is_online": true,
      "version": "1.0.0"
    }
  ]
}
```
