# 本机执行（Agent / MCP 硬约束）

ZeroNews 依赖 **用户电脑** 上的客户端二进制、`config.yml`、系统浏览器、以及本机 TCP 监听。下列操作 **不得** 在 Agent **沙箱 Shell**、无本机挂载的 Cloud Agent、或仅远程 CI/容器里执行并当作已完成。

## 适用范围

| 类型 | 须在本机执行的内容 |
|------|---------------------|
| **Skills** | 所有 `zeronews …` CLI、安装脚本、`docker pull/run`、`service install/start`、端口发现（`ss` / `lsof` 等） |
| **MCP** | `zeronews-mcp` 以 **用户本机 stdio** 运行；各 tool 在本机 spawn `zeronews`（与 Agent 沙箱无关） |
| **登录** | `NO_TTY=1 login` 后 **Agent 必须** `open` / `xdg-open` / `start` 打开 verify URL（CLI 在 NO_TTY 下**不会**自启浏览器）；详见 [BROWSER-LOGIN.md](./BROWSER-LOGIN.md) |
| **暴露** | `list_local_listeners` / `zeronews add` / 读写 `ZERONEWS_WORKDIR` |

## WorkBuddy / CodeBuddy（`TOYBOX_SANDBOX_SOCK`）

macOS 默认 **系统 LaunchDaemon**（非 `service --user`）。**仅** `service install|start|stop|restart|uninstall` / `reset` 在 `sudo -n` 失败时用 **一条** osascript 提权；`login`、`status --json`、`reload`、隧道等 **不提权**。沙箱内直连 `sudo` 常失败；前台 `start` **对话结束即停**。

- 探测类 `zeronews` 须 **关沙箱** + [AGENT-SHELL-UNWRAP.md](./AGENT-SHELL-UNWRAP.md)；提权策略见 [MACOS-AGENT-SERVICE.md](../../zeronews-install-client/references/MACOS-AGENT-SERVICE.md)。
- skills-setup / install **不得以仅前台** 作为 Step 3 完成条件（除非用户明确要前台）。

## Agent 怎么做

1. **Cursor / IDE Shell 跑 CLI**：关闭沙箱（请求完整本机权限，例如 Cursor 的 `all` / 在用户真实终端执行）。**不要沙箱中执行，都在用户本地电脑中执行。**
2. **已配置 MCP**：优先调 MCP 工具；确保 MCP 进程在用户本机；**勿**在沙箱里重复跑 CLI 碰 workdir 来「验证」。
3. **无 MCP、仅 Skills**：同上，所有 Shell 步骤均 **本机非沙箱**。
4. **无法在用户本机执行时**：明确说明限制，引导用户在本地终端或配置本地 MCP；**不要**伪造 `login: true` / `running: true`。

## MCP 与 Agent 沙箱

- **MCP 进程所在机器** = CLI 与 Local API 所在机器。
- Agent 沙箱若与 MCP 不同环境，沙箱内 `zeronews status` **不能** 替代 MCP 工具返回。
- `ZERONEWS_EXECUTABLE` / `ZERONEWS_WORKDIR` 指向的路径必须在 **该本机** 可读可写。

## 相关

- [BROWSER-LOGIN.md](./BROWSER-LOGIN.md)（Skills 路径 login + open + 轮询）
- [SKILL-ROUTER.md](./SKILL-ROUTER.md)（skill 路由，同目录）
- Skills 端到端规程：[zeronews-skills-setup.md](https://docs.zeronews.cc/raw/ai/zeronews-skills-setup.md)
- 删除二次确认：各 `zeronews-manage-*` skill 内 `references/DELETE-CONFIRMATION.md`
- Agent MCP 规程：[zeronews-mcp-agent-setup.md](https://docs.zeronews.cc/raw/ai/zeronews-mcp-agent-setup.md)
