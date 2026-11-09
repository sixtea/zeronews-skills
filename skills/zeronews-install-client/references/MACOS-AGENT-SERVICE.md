# macOS Agent service (`service --user`)

**Audience:** AI Agent / Skills only — **not** for end-user install docs or `INSTALL-COMMANDS.md` (human path stays `sudo service`).

**Requires:** Client build with `zeronews service --user` (LaunchAgent in `~/Library/LaunchAgents/`).

## Workdir

**Default (Agent + install skill):** `/Applications/zeronews` — binary directory and `--workdir` are the **same path**. Use it for `login`, `status`, `service`, `service --user`, `reset`, and foreground `start`.

```bash
WORKDIR="${WORKDIR:-/Applications/zeronews}"
```

Preflight and all commands use this path unless the user explicitly overrides `--workdir`. Align with [WORKDIRS.md](../../zeronews-configure-client/references/WORKDIRS.md).

`service --user` requires the workdir to be **writable** by the current user. Official install targets `/Applications/zeronews` (often admin-writable after install). If install reports `workdir must be writable`, fix permissions on that directory or fall through to **foreground** `start` (Step 4 tier 4) — do **not** silently pick another workdir.

## User LaunchAgent: install before start (mandatory)

Whenever Skills bring up the **user** service (`service --user`), run **two commands in order**:

1. `zeronews --workdir "$WORKDIR" service --user install`
2. `zeronews --workdir "$WORKDIR" service --user start`

Do **not** call `service --user start` alone on first bring-up or after upgrade/reset unless `install` just succeeded in the same flow. Re-running `install` is idempotent when the plist already exists. Use `service --user restart` only when the Agent is already registered **and** the process was running.

## Start order (macOS native, install Step 4)

Do **not** ask the user to choose service vs foreground. **Do not** wait for interactive `sudo`.

| Order | When | Action |
|------|------|--------|
| 1 | `id -u` is `0` | `zeronews --workdir "$WORKDIR" service install` then `service start` (system LaunchDaemon) |
| 2 | Non-root and `sudo -n zeronews --workdir "$WORKDIR" service install` **and** `service start` succeed | System service (no password prompt) |
| 3 | Non-root and silent `sudo` unavailable | `zeronews --workdir "$WORKDIR" service --user install` then `service --user start` |
| 4 | Step 3 fails after **WorkBuddy unwrap + non-sandbox retry** (see below) | Foreground **session only** — **not** install complete |
| — | User explicitly asked 前台 / no service | Skip 1–3; only foreground |

Commands for step 3 (WorkBuddy / sandboxed Agent Shell — **mandatory prefix** on **both** lines):

```bash
ZN='env -u NODE_OPTIONS -u PYTHONPATH -u CODEBUDDY_BROKERED_FS_HOOK_ENABLED -u TOYBOX_SANDBOX_SOCK'
$ZN zeronews --workdir "$WORKDIR" service --user install
$ZN zeronews --workdir "$WORKDIR" service --user start
$ZN zeronews --workdir "$WORKDIR" service --user status
```

Run with **Shell sandbox disabled**. Full details: [AGENT-SHELL-UNWRAP.md](../../_shared/references/AGENT-SHELL-UNWRAP.md).

Report which tier succeeded: `system`, `user-agent`, or `foreground`.

## WorkBuddy: `--user` must succeed for a finished install

- **Foreground `start` dies when the Agent chat ends** (child of the sandboxed Shell). For default install / skills-setup, **`user-agent` or system daemon** is the success mode — not foreground.
- **`Bootstrap error 5`** on `service --user start` → retry tier 3 with [AGENT-SHELL-UNWRAP.md](../../_shared/references/AGENT-SHELL-UNWRAP.md) prefix and **non-sandbox** Shell before any foreground attempt.
- **Do not** advance to expose / Step 4 setup on foreground-only unless the user explicitly chose 前台 / no service.
- After a successful `--user start`, verify **`service --user status`** → `running` and Local API health — same as Step 5.

## When `--user` fails → foreground

Retry tier 3 with unwrap + non-sandbox **once** before foreground. Fallback **without** asking only after that:

- Client too old (no `--user` flag / unknown flag error)
- `workdir must be writable` on install (and user did not ask to change workdir)
- `another zeronews client is already running` (often **system** still running) — Agent cannot `sudo service stop` silently; tell user if needed, then try foreground for this session
- `service --user start` OK but Step 5 shows not running (no **Aqua** / headless SSH — LaunchAgent may not load)
- Any non-zero exit after one install+start attempt

## Coexistence with system service

- System Daemon and user Agent plists may both exist; **only one process** per workdir.
- If `sudo` system service is already running, stop it before `--user start` (needs user in the loop for `sudo`) or use foreground until stopped.

## Reset / uninstall (Agent)

- Full local cleanup on macOS: **`sudo zeronews --workdir "$WORKDIR" reset`** (uninstalls **both** sides + clears state).
- Service registration only: **`sudo zeronews --workdir "$WORKDIR" service uninstall`**.

Do **not** run bare `zeronews reset` on macOS for full cleanup.
