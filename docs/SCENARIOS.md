# 验收场景（Skills / 与 MCP 对齐）

执行 Skills 路径时，Agent 应满足「期望行为」。MCP 列供对照，不要求本表在无 MCP 时调用 tool。

| ID | 用户话术 | 期望 skill / 行为 | MCP 对照 |
|----|----------|-------------------|----------|
| S1 | 帮我安装 ZeroNews | `zeronews-install-client` → login 或 authtoken | `install_client` → `login` |
| S2 | 代理本地服务（**无端口**） | 不 `add`；先 login+running；**列监听**再让用户选 | `list_local_listeners` → `expose_local_service` |
| S3 | 映射 localhost:3000 | 用户已给端口；仍检查 login+running 后 `add` | `expose_local_service(port=3000)` |
| S4 | 客户端连上了吗 | `inspect-client`；不误读 exit 3 | `client_status` |
| S5 | 用 authtoken 绑定 | `zeronews-configure-client` authtoken 分支 | Skills 特有；MCP 偏 browser login |
| S6 | 分享 /opt/share 目录 | `share-files` + password | `add_tunnel` LFS |
| S7 | 微信支付回调 webhook | `expose-webhook` | `add_tunnel` + webhook feature |
| S8 | 列出我账号下所有隧道 | `manage-account-tunnels` | `list_account_tunnels` |
| S9 | 删除 xxx 隧道 | 选目标 → **二次确认** → `manage-account-tunnels` delete | `delete_tunnel` + **`user_confirmed: true`** |
| S10 | 加一个随机子域名 | `manage-platform-domains` + 用户选前缀 | `add_domain` |
| S11 | 升级这台客户端 | `upgrade-client` | `upgrade_client` |
| S12 | 重置 ZeroNews | 用户 **二次确认** → `reset-client` | 无 MCP 等价（慎用） |
| S-Win | 代理本地服务（Windows，无端口） | 同 S2；`netstat` best-effort 列端口，禁止默认 3000 | 同 MCP 意图 |

**阶段门禁**：A 完成 → S2、S3、S4、**S-Win**；B 完成 → S8–S10；C 完成 → S11。

合并 PR 前见 [PR-CHECKLIST.md](./PR-CHECKLIST.md)。
