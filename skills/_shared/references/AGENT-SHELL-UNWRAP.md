# Agent Shell unwrap（WorkBuddy / CodeBuddy / Cursor）

部分 Agent 执行 Shell 时会注入沙箱变量（常见 **`TOYBOX_SANDBOX_SOCK`**），导致 **`launchctl bootstrap`** 失败（例如 **Bootstrap error 5**）。`zeronews service --user start` 依赖 launchd，**必须在非沙箱、剥离注入后**执行。

前台 `zeronews start` 在沙箱剥离后往往仍可跑，但 **Agent 对话结束即进程退出**，不能替代用户级 LaunchAgent。

## 每条 `zeronews` / `launchctl` 命令前缀（与 skills-setup Step 2 一致）

```bash
env -u NODE_OPTIONS -u PYTHONPATH -u CODEBUDDY_BROKERED_FS_HOOK_ENABLED -u TOYBOX_SANDBOX_SOCK
```

示例（macOS 非 root、持久后台）：

```bash
ZN='env -u NODE_OPTIONS -u PYTHONPATH -u CODEBUDDY_BROKERED_FS_HOOK_ENABLED -u TOYBOX_SANDBOX_SOCK'
$ZN /Applications/zeronews/zeronews --workdir /Applications/zeronews service --user install
$ZN /Applications/zeronews/zeronews --workdir /Applications/zeronews service --user start
$ZN /Applications/zeronews/zeronews --workdir /Applications/zeronews service --user status
```

## Agent 必须

1. **关闭 Shell 沙箱**（IDE 请求完整本机权限 / `all`），再跑 `service --user`。
2. **`install` 与 `start` 都带** 上述 `env -u …` 前缀（不要只给前台 `start` 加前缀）。
3. `service --user status` 为 **running** 且 Local API 探活通过后，才算 install Step 4 / skills-setup Step 3 **完成**。
4. 若剥离 + 关沙箱后仍失败 → 明确告诉用户须在 **本机 Terminal.app** 执行同样两条命令；**不要** 仅用前台冒充「已装好」。

## 相关

- [LOCAL-EXECUTION.md](./LOCAL-EXECUTION.md)
- [MACOS-AGENT-SERVICE.md](../../zeronews-install-client/references/MACOS-AGENT-SERVICE.md)
