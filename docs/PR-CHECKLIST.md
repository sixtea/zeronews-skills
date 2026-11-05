# PR 自检清单（Skills 方案阶段 A / B / C）

合并前维护者勾选。适用于 `zeronews-client-skills` 内 SKILL / reference / docs 变更。

## 阶段 A（本机暴露与门禁）

- [ ] `expose-service/SKILL.md` 含 **Step 0**：未 login 或进程未 running 时 handoff，**不** `add`
- [ ] 用户**未给端口**时，Pre-flight **不**把「local port」列为必问项；正文 **链接** [LOCAL-LISTENERS.md](../skills/zeronews-expose-service/references/LOCAL-LISTENERS.md)
- [ ] 全文 **无**「默认猜 3000」类表述（Windows 见 S-Win）
- [ ] `file_share` / webhook **主路径**不在 expose-service；LFS → `share-files`，webhook → `expose-webhook`（见 PLAN §3.7）
- [ ] `inspect-client` 区分账号 `show tunnels` 与本机 `endpoints`
- [ ] `zeronews-configure-client` login 后 start/restart/reload 与 PLAN A3b 一致；`manage-client-service` 有 cross-ref（若 touched）
- [ ] `share-files` / `expose-webhook` 含 **Step 0**（login + running）；webhook 无端口链 **LOCAL-LISTENERS**
- [ ] 已改 skill 的 `metadata.version` 在批次末统一 bump（expose 系含 share/webhook **1.1**）
- [ ] [SCENARIOS.md](./SCENARIOS.md) **S2、S3、S4、S-Win** 对照 SKILL 人工过一遍

### 可选 grep（本地）

```bash
rg -n "3000|upfront.*port|local port" skills/zeronews-expose-service/SKILL.md
rg -n "LOCAL-LISTENERS" skills/zeronews-expose-service/SKILL.md
rg -n "file_share|webhook" skills/zeronews-expose-service/SKILL.md
```

期望：expose 正文引用 LOCAL-LISTENERS；file_share/webhook 仅出现在 handoff/勿用说明中。

## 阶段 B（账号 CLI skills）

- [ ] **B0** 已完成：`ACCOUNT-CLI-JSON.md` 含脱敏 `--json` 样例
- [ ] 新 skill `name` 与 PLAN 表一致（`zeronews-manage-account-tunnels` 等）
- [ ] 删隧道 / 删客户端 / 删域名/端口：**点选后二次确认**（[DELETE-CONFIRMATION.md](./references/DELETE-CONFIRMATION.md)）
- [ ] 列表 JSON 按 [CLI-JSON-PATHS.md](../skills/zeronews-manage-account-tunnels/references/CLI-JSON-PATHS.md) 解析 `items[]` / `page.items[]`

## 阶段 C

- [ ] `upgrade-client` 与 MCP `upgrade_client` 意图一致
- [ ] SCENARIOS **S11**

## 文档

- [ ] `CHANGELOG.md` Unreleased 已更新
- [ ] 若新增对外锚点，更新 [DOC-SITE-SYNC.md](./DOC-SITE-SYNC.md)
