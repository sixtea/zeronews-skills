# macOS Agent system service (LaunchDaemon + osascript)

**Audience:** AI Agent / Skills only — **not** for end-user install docs or `INSTALL-COMMANDS.md` (human path stays `sudo service` in Terminal).

**Requires:** Client with macOS `zeronews service install|start` (system LaunchDaemon under `/Library/LaunchDaemons/`).

**Do not** use `service --user` (LaunchAgent) on the **default Agent install / manage path**. User LaunchAgent remains in the CLI for advanced/human use only when the user **explicitly** asks for `--user`.

## Workdir

**Default (Agent + install skill):** `/Applications/zeronews` — binary directory and `--workdir` are the **same path**. Use it for `login`, `status`, `service`, `reset`, and foreground `start`.

```bash
WORKDIR="${WORKDIR:-/Applications/zeronews}"
BIN="${BIN:-/Applications/zeronews/zeronews}"
```

Preflight and all commands use this path unless the user explicitly overrides `--workdir`. Align with [WORKDIRS.md](../../zeronews-configure-client/references/WORKDIRS.md).

## Elevation policy (mandatory)

**Never** use `osascript … with administrator privileges` for commands that run as the normal user. Use [AGENT-SHELL-UNWRAP.md](../../_shared/references/AGENT-SHELL-UNWRAP.md) only (sandbox off + `env -u …`):

| No elevation | Examples |
|--------------|----------|
| Bind / health | `login`, `status --json`, `inspect-client`, Local API probe |
| Version / upgrade fetch | `--version`, `curl` download, CP `download/latest` |
| Tunnels / expose | `zeronews add`, expose-service steps (daemon already **running**) |
| Config hot reload | **`reload`** while system service is **running** (prefer over `service restart` after login) |
| User LaunchAgent cleanup | `service --user stop`, `service --user uninstall` (no root) |
| Service text status | **Do not** osascript `service status` — use **`status --json`** |

**Elevation required** (root / `sudo -n` / **one** osascript per phase — batch with `&&`):

| Elevated only | Examples |
|---------------|----------|
| Register / control system daemon | `service install`, `service start`, `service stop`, `service restart` (only if `reload` failed), `service uninstall` |
| Full wipe | `reset` (macOS) |

**One password per phase:** pack every root command needed in that phase into **one** `do shell script "cmd1 && cmd2 …" with administrator privileges`. **Do not** split install/start into two osascripts unless the combined line failed and you are isolating errors.

## Start order (macOS native, install Step 4)

Do **not** ask the user to choose service vs foreground. **Do not** block on «要不要 sudo».

| Order | When | Action |
|------|------|--------|
| 1 | `id -u` is `0` | `zeronews --workdir "$WORKDIR" service install` then `service start` (system LaunchDaemon) |
| 2 | Non-root and `sudo -n` succeeds for **both** `service install` and `service start` | System service (no password prompt) |
| 3 | Non-root and step 2 did **not** run | **osascript administrator** — one macOS password dialog — runs **system** `service install` then `service start` as root (see below) |
| 4 | Step 3 cancelled or failed after unwrap + non-sandbox retry | Foreground **session only** — **not** install complete |
| — | User explicitly asked 前台 / no service | Skip 1–3; only foreground |

Report which tier succeeded: `system` (root / `sudo -n` / **osascript-admin**), or `foreground`.

## Tier 3: osascript with administrator privileges (mandatory for non-root Agents)

**Goal:** Run **`zeronews service install`** and **`zeronews service start`** as **root** inside `do shell script … with administrator privileges`, so the user sees the **standard macOS administrator password** sheet. This is **Skills-side orchestration** — not the client’s internal no-privilege osascript used for `--user` launchctl.

**Before tier 3:**

1. **Shell sandbox off** + [AGENT-SHELL-UNWRAP.md](../../_shared/references/AGENT-SHELL-UNWRAP.md) on all non-elevated `zeronews` probes (`login`, `status --json`, upgrade).
2. If a **user LaunchAgent** was registered earlier (`~/Library/LaunchAgents/com.zeronews.client.plist`), best-effort **`service --user stop`** + **`service --user uninstall`** (unwrap prefix) so only the system daemon owns the workdir — **do not** register `--user` again on the default path.
3. Tell the user briefly: **macOS will ask for your login password once** to install the system service (not Terminal).

**Single password (preferred)** — install then start in one elevated shell:

```bash
osascript <<'APPLESCRIPT'
do shell script "/Applications/zeronews/zeronews --workdir /Applications/zeronews service install && /Applications/zeronews/zeronews --workdir /Applications/zeronews service start" with administrator privileges
APPLESCRIPT
```

**Two prompts** — **avoid**; only if the combined line failed and you must bisect install vs start errors.

Adjust `$BIN` / `$WORKDIR` only when the user explicitly overrode install path.

**After tier 3 succeeds**, verify **without elevation**:

```bash
env -u NODE_OPTIONS -u PYTHONPATH -u CODEBUDDY_BROKERED_FS_HOOK_ENABLED -u TOYBOX_SANDBOX_SOCK \
  "$BIN" --workdir "$WORKDIR" status --json
```

Use **`status --json` → `running`** as the only install health signal. **Never** osascript for `service status`.

**User cancelled the password dialog** → tier 3 failed; do **not** fall back to `service --user`; go to tier 4 (foreground) or give a **Terminal.app** block with `sudo … service install && sudo … service start`.

## WorkBuddy / IDE Agents

- **Do not** use `service --user install` / `service --user start` to finish install or skills-setup Step 3.
- Direct `sudo` or `launchctl` from a sandboxed Agent Shell often fails; **tier 3 osascript** is the intended interactive elevation for **system** service.
- Foreground `zeronews start` in the Agent may still work for debugging but **dies when the chat ends** — not a completed install.

## When tier 3 fails → foreground

Retry tier 3 **once** with Shell sandbox disabled and unwrap applied. Fallback **without** asking only after that:

- User **cancelled** administrator dialog
- `osascript` / Automation blocked (no GUI session, policy denies OSA)
- `service install` / `start` error inside elevated script (read AppleScript error text)
- `another zeronews client is already running` — try non-elevated `shutdown` / `stop` first; only **`service stop`** via osascript (batched in **one** elevated script with the next install+start) if needed
- Any non-zero exit after one combined osascript attempt + one retry

## Coexistence with user LaunchAgent

- System LaunchDaemon and user LaunchAgent plists must **not** both run the same workdir.
- Default Agent path: **system only** after tier 3. Remove stale `--user` registration before install when possible.

## Reset / uninstall (Agent)

- Only when the user explicitly asked for reset/uninstall: **one** osascript with `reset` or `service uninstall` — **not** for routine install/expose.
- Full local cleanup: `do shell script "$BIN --workdir $WORKDIR reset" with administrator privileges` when not root.
- Service registration only: same pattern with `service uninstall` (elevated once).

**After login on a running daemon:** run **`reload`** with unwrap only — **do not** osascript `service restart` unless `reload` failed or the process is not running.

Do **not** run bare `zeronews reset` on macOS for full cleanup.

## Explicit `--user` (exception only)

If the user **explicitly** requests user LaunchAgent / no system daemon / 不要系统服务:

- You may use `service --user` per CLI help — **outside** the default install pipeline.
- Do **not** treat that as skills-setup Step 3 complete unless they accept session or persistence limits.
