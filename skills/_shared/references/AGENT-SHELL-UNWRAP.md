# Agent Shell unwrap（WorkBuddy / CodeBuddy / Cursor）

部分 Agent 执行 Shell 时会注入沙箱变量（常见 **`TOYBOX_SANDBOX_SOCK`**），且 **seatbelt 仍可能禁止 `launchctl` / 直接 `sudo`**。

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

1. **关闭 Shell 沙箱**（IDE 请求完整本机权限 / `all`），再跑 **osascript 提权** 或 `service`。
2. **非提权命令** 带上述 `env -u …` 前缀。
3. macOS Step 3/4 完成条件：**系统服务 running**（或 root/`sudo -n` 已起），**不是** `service --user`。
4. 用户 **取消管理员密码** 或 osascript 失败 → 可有一次关沙箱重试；仍失败 → 给 **Terminal.app** `sudo … service install/start` 说明；**不要**仅用前台冒充「已装好」。

## 相关

- [LOCAL-EXECUTION.md](./LOCAL-EXECUTION.md)
- [MACOS-AGENT-SERVICE.md](../../zeronews-install-client/references/MACOS-AGENT-SERVICE.md)
