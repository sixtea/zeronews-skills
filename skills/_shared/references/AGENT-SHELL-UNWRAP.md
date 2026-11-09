# Agent Shell unwrap（WorkBuddy / CodeBuddy / Cursor）

部分 Agent 执行 Shell 时会注入沙箱变量（常见 **`TOYBOX_SANDBOX_SOCK`**），且 **seatbelt 仍可能禁止 `launchctl bootstrap`**（Bootstrap error 5）。

## 禁止 osascript（只用 `env -u …`）

`login`、`status --json`、`--version`、`reload`、升级 `curl`、`zeronews add` / expose、`service --user stop|uninstall|status`、探活。**不要** `with administrator privileges`。

**硬禁止（常见 Agent 误操作）：**

```bash
# ❌ 永远不要 — status/login/version 不需要管理员，也不需要 osascript
osascript -e 'do shell script "... zeronews ... status --json" with administrator privileges'
```

若 `status --json` 在沙箱里失败 → **关 Shell 沙箱（`all`）** + 下面前缀 **直接执行**，**禁止** 用 osascript「提权」代替：

```bash
env -u NODE_OPTIONS -u PYTHONPATH -u CODEBUDDY_BROKERED_FS_HOOK_ENABLED -u TOYBOX_SANDBOX_SOCK \
  /Applications/zeronews/zeronews --workdir /Applications/zeronews status --json
```

## macOS Step 4 启动顺序（强制）

**系统服务 → 用户服务（`--user`）→ 前台**。禁止跳步直接 `launchctl`。**禁止**用前台冒充 setup 完成。

| Tier | 做法 |
|------|------|
| 多数 CLI | **关沙箱** + `env -u …` |
| **1 系统** | `service install && service start`（`sudo -n` 或 **一条** admin osascript） |
| **2 用户** | `service --user install && start`（unwrap；必要时 **一条** 无 admin osascript） |
| **3 前台** | `zeronews start`；**必须**提示用户：需**开机自启**请改**系统服务**（见 [MACOS-AGENT-SERVICE.md](../../zeronews-install-client/references/MACOS-AGENT-SERVICE.md)） |

完成判定：`status --json` → **running**（且非仅前台时方可宣称 Step 3/setup 装完）。

## 每条普通命令前缀

```bash
env -u NODE_OPTIONS -u PYTHONPATH -u CODEBUDDY_BROKERED_FS_HOOK_ENABLED -u TOYBOX_SANDBOX_SOCK
```

不要用 `ZN='env -u …'` 再裸 `$ZN /path`（会整串当成命令名）。

## Agent 必须

1. **关 Shell 沙箱**（`all`），再跑服务或 osascript。
2. **除** Tier 1/2 的 `service … install+start` 外 **一律不提权、不 osascript**（`status` 等仍禁止 admin osascript）。
3. Step 4 **仅在 `login: true` 之后**；Tier 1 **至多一条** admin osascript，Tier 2 **至多一条** 无 admin osascript。
4. Tier 3 前台 → **必须**说明系统服务与开机自启；给 Terminal `sudo … service install/start` 备选。

## 相关

- [LOCAL-EXECUTION.md](./LOCAL-EXECUTION.md)
- [MACOS-AGENT-SERVICE.md](../../zeronews-install-client/references/MACOS-AGENT-SERVICE.md)
