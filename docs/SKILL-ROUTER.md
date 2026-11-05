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
| **仅 Skills** | `zeronews-configure-client`：`login` 或 `authtoken`（用户已给 token） |
| **MCP 已配置** | 用 MCP `login` / 浏览器确认；**勿**把 Auth Token 写入 `mcp.json` |
| **两者并存** | 隧道/删资源仍须本机 login + running；绑定优先走 MCP，避免重复 authtoken 安装链 |

---

## 路由表（当前 + 规划）

| 用户意图（示例） | Skill | 前置 / handoff |
|------------------|-------|----------------|
| 安装 ZeroNews / Docker 部署 | `zeronews-install-client` | — |
| 绑定账号 / login / authtoken | `zeronews-configure-client` | 已安装 CLI；expose 前必须 **login** |
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
install-client → configure-client → manage-client-service (可选)
                → inspect-client (门禁) → expose-service
```

```text
「帮我代理本地服务」且未给端口:
  inspect-client (login? running?) → expose-service (list listeners → user picks) → zeronews add
```

---

## Meta（阶段 D）

**`zeronews-mcp-bridge`**：当 **用户或宿主明确说已配置 zeronews-mcp** 时，提示 Reload MCP、用对话触发 MCP 工具，**不要**再跑 Skills 完整 install/configure CLI 链。  
Skills **无法可靠自动检测** MCP 是否已加载，勿写「检测到 MCP 则…」类绝对逻辑。
