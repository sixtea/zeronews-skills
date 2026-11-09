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
| 4 | Step 3 fails (see below) | `zeronews --workdir "$WORKDIR" start` (foreground — **last resort**) |
| — | User explicitly asked 前台 / no service | Skip 1–3; only foreground |

Commands for step 3:

```bash
zeronews --workdir "$WORKDIR" service --user install
zeronews --workdir "$WORKDIR" service --user start
zeronews --workdir "$WORKDIR" service --user status
```

Report which tier succeeded: `system`, `user-agent`, or `foreground`.

## When `--user` fails → foreground

Fallback **without** asking:

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
