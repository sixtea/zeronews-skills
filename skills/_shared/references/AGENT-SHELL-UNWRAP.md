# Agent Shell unwrap（WorkBuddy / CodeBuddy / Cursor）

部分 Agent 执行 Shell 时会注入沙箱变量（常见 **`TOYBOX_SANDBOX_SOCK`**），且 **seatbelt 仍可能禁止 `launchctl` / 直接 `sudo`**。

## 禁止对下列命令提权（只用 `env -u …`，不要 osascript）

`login`、`status --json`、`--version`、`reload`（服务已 running 时）、升级 `curl`、`zeronews add` / expose、探活、`service --user stop|uninstall`、读取配置。**禁止** osascript 执行 `service status` — 用 `status --json`。

## macOS 持久后台（install / setup 默认）

**默认路径是系统 LaunchDaemon**，不是 `service --user`。

| 步骤 | Agent 做法 |
|------|------------|
| `login` / `status --json` / 下载升级 | **关沙箱** + 下方 `env -u …` 前缀 |
| 非 root、`sudo -n` 不可用 | **`osascript` + `with administrator privileges`** 跑 `service install && service start`（一次密码） |
| 完成判定 | `status --json` → **running**，系统 **`service status`** 或 Local API 探活 |

详见 [MACOS-AGENT-SERVICE.md](../../zeronews-install-client/references/MACOS-AGENT-SERVICE.md)。**禁止**在默认安装里用 `service --user` 冒充完成。

```bash
osascript <<'APPLESCRIPT'
do shell script "/Applications/zeronews/zeronews --workdir /Applications/zeronews service install && /Applications/zeronews/zeronews --workdir /Applications/zeronews service start" with administrator privileges
APPLESCRIPT
```

与客户端内部的 **无提权** osascript（仅 `--user` launchctl 兜底）**不是同一路径**。

前台 `zeronews start` 在 Agent 里往往仍能跑，但 **对话结束即进程退出**，不能替代系统服务。

## 每条普通 `zeronews` 命令前缀（与 skills-setup Step 2 一致）

```bash
env -u NODE_OPTIONS -u PYTHONPATH -u CODEBUDDY_BROKERED_FS_HOOK_ENABLED -u TOYBOX_SANDBOX_SOCK
```

示例（探测 / login / status — **不要**把整段 env 塞进未 `eval` 的单个变量；请写满一行或 `eval`）：

```bash
env -u NODE_OPTIONS -u PYTHONPATH -u CODEBUDDY_BROKERED_FS_HOOK_ENABLED -u TOYBOX_SANDBOX_SOCK \
  /Applications/zeronews/zeronews --workdir /Applications/zeronews status --json
```

**不要用**错误写法：`ZN='env -u …'` 后仅 `$ZN /path`（部分 Shell 会把整串当成一个命令名）。

## Agent 必须

1. **关闭 Shell 沙箱**（IDE 请求完整本机权限 / `all`）。
2. **默认**：所有 CLI 仅 **`env -u …` 前缀**，不提权。
3. **仅** macOS 系统 `service install|start|stop|restart|uninstall` 或 `reset` 在 `sudo -n` 失败时 → **一条** osascript（多命令用 `&&` 合并），每阶段至多 **一次** 密码。
4. 完成判定：`status --json` **running**（不提权）；**不是** `service --user`。
5. 用户 **取消密码** → 关沙箱重试一次；仍失败 → Terminal `sudo …`；**不要**前台冒充装好。

## 相关

- [LOCAL-EXECUTION.md](./LOCAL-EXECUTION.md)
- [MACOS-AGENT-SERVICE.md](../../zeronews-install-client/references/MACOS-AGENT-SERVICE.md)
