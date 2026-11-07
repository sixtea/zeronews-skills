# Skill 路由（Agent / 维护者）

用户自然语言 → **优先使用的 skill** → **前置条件**（须先完成或 handoff）。

## 本机执行（硬约束）

**不要沙箱中执行，都在用户本地电脑中执行。** Skills 内所有 CLI / 安装 / 浏览器登录 / 端口枚举，以及 MCP 工具所调用的 `zeronews`，必须在 **用户本机** 完成（IDE Shell 须关闭沙箱；MCP 须本机 stdio）。详见 [LOCAL-EXECUTION.md](./references/LOCAL-EXECUTION.md)。

## 与 MCP 并存

| 条件 | 行为 |
|------|------|
| 宿主已配置 **`zeronews-mcp`** 且工具可用 | 优先 MCP；**不要**重复执行完整 CLI 安装链 |
| 仅 Skills | 按下表选择 skill |
| 用户明确「只用命令 / 没有 MCP」 | Skills |

npm 包名：**[`zeronews-mcp`](https://www.npmjs.com/package/zeronews-mcp)**。规程：[zeronews-mcp-agent-setup.md](https://docs.zeronews.cc/raw/ai/zeronews-mcp-agent-setup.md)（路径随文档环境可能不同）。

### 认证：Skills vs MCP

| 场景 | 做法 |
|------|------|
| **[skills-setup](https://docs.zeronews.cc/raw/ai/zeronews-skills-setup.md)** | 浏览器 **`login`** + Agent **`open`** + 同 Shell 轮询（[BROWSER-LOGIN.md](./BROWSER-LOGIN.md)）；**禁止 MCP 旁路**（F-15） |
| **skills-setup 全量安装** | **`zeronews-install-client` Step 3**（browser login）；**勿** 再 `configure-client` |
| **仅 Skills（无 setup 规程）** | `zeronews-configure-client`：`login`（同上）或用户已给 token 时 `authtoken` |
| **MCP / WorkBuddy 连接器** | `configure_auth`（`ZERONEWS_AUTH_TOKEN`）；**不要**用 Skills 规程里的浏览器 login 混跑 |
| **两者并存** | 按用户选的 **一条** 规程（setup **或** mcp-agent-setup）；映射前均须本机 **login + running** |

---

## 路由表（当前 + 规划）

| 用户意图（示例） | Skill | 前置 / handoff |
|------------------|-------|----------------|
| 安装 ZeroNews / Docker 部署 | `zeronews-install-client` | — |
| 绑定账号 / login / authtoken | `zeronews-configure-client` | 已安装 CLI；**setup 全量 install 1→n 时由 install Step 3 完成，勿 configure**；expose 前必须 **login** |
| 客户端是否在跑 / 健康 / 本机 endpoints | `zeronews-inspect-client` | — |
| 装系统服务 / 启停守护进程 | `zeronews-manage-client-service` | 通常已 configure；login 后改配置需 **restart** |
| 映射本地 Web/端口（**未说端口**） | `zeronews-expose-service` | configure + running → **先枚举监听**（见 LOCAL-LISTENERS）；**勿**在 expose 里做 LFS |
| 映射指定端口（如「3000」） | `zeronews-expose-service` | 仍须 login + running；**禁止**替用户改口 |
| SSH/RDP/远程 TCP | `zeronews-expose-service` | `tcp`/`tls` + 明确目标 |
| 微信支付 / 合约 webhook | `zeronews-expose-webhook` | configured |
| 分享目录 LFS | `zeronews-share-files` | configured；`root_path` + `admin_password` |
| 重置本机客户端 | `zeronews-reset-client` | **用户明确确认** |
| 查账号下所有隧道 / 删隧道 | `zeronews-manage-account-tunnels` | 须 login |
| 加子域 / 删域名端口 | `zeronews-manage-platform-domains` | 须 login |
| 列设备 / 删远程客户端 | `zeronews-manage-account-clients` | 删/禁用前确认 |
| 升级本机或远程客户端 | `zeronews-upgrade-client` | login；远程须 online |

---

## 推荐链（常见）

```text
install-client (下载 → login+open浏览器 → poll → start → verify)
  → 全量 install 成功后 **不要** 再 configure-client
  → 若仅补绑机 / 未 login: configure-client（同上 BROWSER-LOGIN）
  → manage-client-service (可选)
  → inspect-client (login? running?) → expose-service
```

**映射门禁：** `login: true` **且** 客户端 **running** 后才 `expose-service`。未完成浏览器确认前 **禁止** 枚举端口建隧道。

```text
「帮我代理本地服务」且未给端口:
  inspect-client (login? running?) → expose-service (list listeners → user picks) → zeronews add
```

---

## Meta（阶段 D）

**`zeronews-mcp-bridge`**：当 **用户或宿主明确说已配置 zeronews-mcp** 时，提示 Reload MCP、用对话触发 MCP 工具，**不要**再跑 Skills 完整 install/configure CLI 链。  
Skills **无法可靠自动检测** MCP 是否已加载，勿写「检测到 MCP 则…」类绝对逻辑。
