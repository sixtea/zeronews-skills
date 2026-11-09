# Agent Shell unwrap（WorkBuddy / CodeBuddy / Cursor）

部分 Agent 执行 Shell 时会注入沙箱变量（常见 **`TOYBOX_SANDBOX_SOCK`**），且 **seatbelt 仍可能禁止 `launchctl bootstrap`**（Bootstrap error 5）。

## 禁止 osascript（只用 `env -u …`）

`login`、`status --json`、`--version`、`reload`、升级 `curl`、`zeronews add` / expose、`service --user stop|uninstall|status`、探活。**不要** `with administrator privileges`。

## macOS 持久后台（install / setup 默认：`service --user`）

| 步骤 | Agent 做法 |
|------|------------|
| 多数 CLI | **关沙箱** + `env -u NODE_OPTIONS -u PYTHONPATH -u CODEBUDDY_BROKERED_FS_HOOK_ENABLED -u TOYBOX_SANDBOX_SOCK` |
| **仅** Step 4：`service --user install` **且** `service --user start` | 先试 unwrap 直连；失败则 **一条** `osascript` `do shell script`（**无** administrator privileges），两条命令 `&&` 合并 |
| 完成判定 | `service --user status` + `status --json` → **running** |

```bash
osascript <<'APPLESCRIPT'
do shell script "/bin/bash -lc '/Applications/zeronews/zeronews --workdir /Applications/zeronews service --user install && /Applications/zeronews/zeronews --workdir /Applications/zeronews service --user start'"
APPLESCRIPT
```

前台 `zeronews start` 不能替代 LaunchAgent（对话结束即停）。

## 每条普通命令前缀

```bash
env -u NODE_OPTIONS -u PYTHONPATH -u CODEBUDDY_BROKERED_FS_HOOK_ENABLED -u TOYBOX_SANDBOX_SOCK
```

不要用 `ZN='env -u …'` 再裸 `$ZN /path`（会整串当成命令名）。

## Agent 必须

1. **关 Shell 沙箱**（`all`），再跑 `--user` 或 osascript。
2. **除** `--user install+start` 外 **一律不提权、不 osascript**。
3. Step 4 **仅在 `login: true` 之后**；每任务 **至多一条** osascript。
4. 仍失败 → 给用户 Terminal 两条 `--user` 命令；不要前台冒充完成。

## 相关

- [LOCAL-EXECUTION.md](./LOCAL-EXECUTION.md)
- [MACOS-AGENT-SERVICE.md](../../zeronews-install-client/references/MACOS-AGENT-SERVICE.md)
