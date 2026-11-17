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

**After `login: true`**, on the **default Agent install path** try **in this order** — **no elevation** (`sudo`, `sudo -n`, `with administrator privileges`) at any tier:

| Tier | Mode | When | How |
|------|------|------|-----|
| **1** | **User service** (`--user`) | Default first try | `service --user install` + `service --user start` — unwrap + 关沙箱 first; **one** `osascript` **without** `administrator privileges` if Bootstrap error 5 |
| **2** | **Foreground** | Tier 1 failed after retry | `zeronews --workdir … start` — valid for skills-setup **running** gate when Local API is up |

**Do not** hand-craft `launchctl bootstrap` / `load` — use **`zeronews service …`** only.

Report outcome: **`user-agent`** (`--user`) or **`foreground`**.

### System service (LaunchDaemon) — user-initiated only

**Not part of default Step 4.** Agent **must not** run system `service install` / `service start`, **`sudo -n`**, or admin `osascript` during install/start unless the user **explicitly** asked for **系统服务 / 开机自启 / sudo 装服务** — and even then **prefer** printing Terminal commands for the user to run locally instead of triggering an elevation prompt from the Agent.

```bash
# User runs in Terminal (Agent does not auto-run this on default path)
sudo "$BIN" --workdir "$WORKDIR" service install
sudo "$BIN" --workdir "$WORKDIR" service start
```

## Elevation / osascript policy

| Command class | How to run |
|---------------|------------|
| `login`, `status --json`, `--version`, `reload`, upgrade `curl`, `zeronews add`, probe | **关沙箱** + `env -u …` only — **no osascript** (no admin) |
| **Tier 1 only:** `service --user install` + `service --user start` | Unwrap first; **one** non-admin `osascript` if needed — **never** `administrator privileges` |
| System `service install/start`, `sudo` service control | **Default path: forbidden.** Explicit user request → print Terminal `sudo …` steps; do not Agent-elevate |
| `service --user stop|uninstall|status`, system `service status` (read-only) | Unwrap only |

**Forbidden on Agent paths:** admin osascript for **any** command; auto `sudo -n` for service install on install/start tasks.

## Tier 1: `service --user` (default)

```bash
"$BIN" --workdir "$WORKDIR" service --user install
"$BIN" --workdir "$WORKDIR" service --user start
```

If unwrap Shell fails (e.g. Bootstrap error 5), **at most one** non-admin osascript:

```bash
osascript <<'APPLESCRIPT'
do shell script "/bin/bash -lc '/Applications/zeronews/zeronews --workdir /Applications/zeronews service --user install && /Applications/zeronews/zeronews --workdir /Applications/zeronews service --user start'"
APPLESCRIPT
```

## Tier 2: foreground

```bash
"$BIN" --workdir "$WORKDIR" start
```

### User message when Tier 2 (foreground)

**Should** tell the user (简体):

> 当前客户端为**前台运行**，本对话结束后进程会退出。若需要**开机自启**和持久后台，请在本机 **终端** 自行执行系统服务安装（会要求管理员密码）：  
> `sudo /Applications/zeronews/zeronews --workdir /Applications/zeronews service install && sudo /Applications/zeronews/zeronews --workdir /Applications/zeronews service start`  
> macOS 也可先尝试用户级后台：`… service --user install` / `service --user start`（无需管理员密码）。

Foreground **can** satisfy skills-setup **running** when `status --json` shows the client up.

## Verify (no osascript)

```bash
env -u NODE_OPTIONS -u PYTHONPATH -u CODEBUDDY_BROKERED_FS_HOOK_ENABLED -u TOYBOX_SANDBOX_SOCK \
  "$BIN" --workdir "$WORKDIR" status --json
```

Use **`status --json` → running** (and `connected` when applicable).

## WorkBuddy / IDE Agents

- At most **one** non-admin osascript (Tier 1) per install/start task.
- Do **not** chain system + user service install in the same task unless the user explicitly switched mode after rollback.

## Coexistence with system LaunchDaemon

- If a **system** daemon is already registered from a prior manual install, **`service --user start`** may be skipped; use unwrap `status --json` and existing system `service start` only when session is already root **and** user asked — otherwise ask user to start via Terminal.
- **`service --user stop`** / **`service --user uninstall`**: unwrap only (no osascript).