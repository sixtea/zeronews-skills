# macOS Agent service (start order)

**Audience:** AI Agent / Skills only — **not** for end-user install docs or `INSTALL-COMMANDS.md` (human path stays `sudo service` in Terminal).

**Requires:** Client with `zeronews service` (system LaunchDaemon) and `zeronews service --user` (LaunchAgent).

## Workdir

**Default:** `/Applications/zeronews` — binary and `--workdir` are the **same path**.

```bash
WORKDIR="${WORKDIR:-/Applications/zeronews}"
BIN="${BIN:-/Applications/zeronews/zeronews}"
```

## Mandatory start order (macOS native, Step 4)

**After `login: true`**, try **in this order** — do **not** skip to foreground before (1) and (2) each get **one** unwrap + non-sandbox retry (and allowed osascript tier below):

| Tier | Mode | When | How |
|------|------|------|-----|
| **1** | **System service** | Always try first | `service install` + `service start` via root / `sudo -n`, or **one** `osascript` **with** `administrator privileges` batching both (sandboxed Agent) |
| **2** | **User service** (`--user`) | Tier 1 failed or unavailable | `service --user install` + `service --user start` — unwrap first; **one** `osascript` **without** `administrator privileges` if Bootstrap error 5 |
| **3** | **Foreground** | Tier 1–2 failed after retry | `zeronews --workdir … start` for **this session only** — **not** install/setup complete |

**Do not** hand-craft `launchctl bootstrap` / `load` — use **`zeronews service …`** only.

Report outcome: **`system`**, **`user-agent`** (`--user`), or **`foreground`**.

### User message when Tier 3 (foreground)

**Must** tell the user (简体):

> 当前客户端为**前台运行**，本对话结束后进程会退出。若需要**开机自启**和持久后台，请使用**系统服务**：在终端执行  
> `sudo /Applications/zeronews/zeronews --workdir /Applications/zeronews service install && sudo … service start`  
> 或在本机 Terminal 中完成一次系统服务安装（Agent 内 Tier 1 若未弹出管理员授权可重试）。

Do **not** treat Step 3 / install as finished on skills-setup when only foreground is running unless the user explicitly chose 前台调试.

## Elevation / osascript policy

| Command class | How to run |
|---------------|------------|
| `login`, `status --json`, `--version`, `reload`, upgrade `curl`, `zeronews add`, probe | **关沙箱** + `env -u …` only — **no osascript** (no admin) |
| **Tier 1 only:** `service install` + `service start` (system) | `sudo -n` or **one** admin `osascript` per task |
| **Tier 2 only:** `service --user install` + `service --user start` | Unwrap first; **one** non-admin `osascript` if needed |
| `service --user stop|uninstall|status`, system `service status` | Unwrap only |

**Forbidden:** admin osascript for `status --json` / `login` / version checks.

## Tier 1: system service (preferred)

```bash
# root or sudo -n
"$BIN" --workdir "$WORKDIR" service install
"$BIN" --workdir "$WORKDIR" service start
```

Sandboxed Agent (at most **one** admin sheet per task):

```bash
osascript <<'APPLESCRIPT'
do shell script "/bin/bash -lc '/Applications/zeronews/zeronews --workdir /Applications/zeronews service install && /Applications/zeronews/zeronews --workdir /Applications/zeronews service start'" with administrator privileges
APPLESCRIPT
```

## Tier 2: `service --user` (non-root fallback)

```bash
osascript <<'APPLESCRIPT'
do shell script "/bin/bash -lc '/Applications/zeronews/zeronews --workdir /Applications/zeronews service --user install && /Applications/zeronews/zeronews --workdir /Applications/zeronews service --user start'"
APPLESCRIPT
```

Non-sandbox Shell: same two commands with unwrap — skip osascript if both succeed.

## Tier 3: foreground

See mandatory user message above.

## Verify (no osascript)

```bash
env -u NODE_OPTIONS -u PYTHONPATH -u CODEBUDDY_BROKERED_FS_HOOK_ENABLED -u TOYBOX_SANDBOX_SOCK \
  "$BIN" --workdir "$WORKDIR" status --json
```

Use **`status --json` → running** (and `connected` when applicable).

## WorkBuddy / IDE Agents

- At most **one** admin osascript (Tier 1) **or** **one** non-admin osascript (Tier 2) per install/start task — not both tiers in duplicate sheets unless Tier 1 clearly failed.
- Terminal fallback: print Tier 1 `sudo … service install/start` first; Tier 2 `--user` second.

## Coexistence with system LaunchDaemon

- Prefer **one** daemon mode on a workdir: if Tier 1 succeeded, **do not** also run Tier 2 install in the same task unless Tier 1 was rolled back.
- **`service --user stop`** / **`service --user uninstall`**: unwrap only (no osascript).
