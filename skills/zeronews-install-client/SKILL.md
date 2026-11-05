---
name: zeronews-install-client
description: Download and install the ZeroNews client on Linux, macOS, Windows, or Docker. If the client binary already exists, automatically compare version to the control plane and upgrade to latest without asking the user. After bind, try OS service when already root/Administrator; if service needs elevation and the session cannot elevate silently, skip service and run foreground start immediately with no user prompt. Native installs use zeronews login unless the user gave an AuthToken; Docker still requires TOKEN.
license: MIT
metadata:
  author: zeronews
  version: "1.5"
compatibility: Requires network access to the configured client download host (currently test CDN agentv2.testenv.waitoin.com:8443 for native installs) or pull a ZeroNews Docker image. Linux/macOS/Windows native installs need a shell; Docker installs need Docker available on the host.
---

# Install Client

## Local execution (mandatory)

All `zeronews` CLI, install scripts, Docker, browser login, and local port discovery **must run on the user's computer**, not in an Agent **sandbox** or remote-only workspace.

- Shell from the IDE: **disable sandbox** (full local permissions); **不要沙箱中执行，都在用户本地电脑中执行。**
- With MCP: run `zeronews-mcp` locally; use MCP tools instead of sandbox CLI against workdir.
- If the agent cannot run on the user's machine, say so—do not fake install/login/expose.

Full rules: [LOCAL-EXECUTION.md](../_shared/references/LOCAL-EXECUTION.md).

Install the ZeroNews client from official online sources, bind the machine (browser `zeronews login` by default, or AuthToken if the user provided one), start the runtime, and confirm the device appears online.

This skill covers the full first-time setup path. For auth-only changes on an already-installed client, prefer `zeronews-configure-client`. For service management after install, prefer `zeronews-manage-client-service`. For health checks, prefer `zeronews-inspect-client`.

## What this skill does

- detects or asks for the target platform: Linux, macOS, Windows, or Docker
- downloads the official client or pulls the official image
- binds the machine during install (native: `zeronews login`; Docker: `TOKEN` env)
- **by default** tries **OS service / background** (`service install` + `service start` on native; detached container on Docker); if system service is **not supported or fails** after auth/retry, **automatically** falls back to **foreground** `start` so the client still runs
- verifies installation through CLI output, local API, container logs, or console guidance
- when the client **already exists**, reads version and **automatically upgrades to latest** without asking (see [UPGRADE-ON-INSTALL.md](./references/UPGRADE-ON-INSTALL.md))

## Prerequisites

- native install: a browser the account owner can use to confirm (no AuthToken required)
- Docker install: AuthToken from the ZeroNews user console ("快速开始")
- outbound network access to the **download base** below (native) or Docker registries

### Download base (TEST — temporary)

**Native** Linux / macOS / Windows installs use this CDN root (same path layout as production):

```text
https://agentv2.testenv.waitoin.com:8443/
```

Examples: `/linux/zeronews-install.sh`, `/macos/arm/zeronews`, `/windows/x64/zeronews.exe`. Full commands: [INSTALL-COMMANDS.md](./references/INSTALL-COMMANDS.md). Index: [agentv2 test CDN](https://agentv2.testenv.waitoin.com:8443/).

After testing, revert skill docs to **`https://download.zeronews.cc`**. Control-plane `download_url` from `device download-resolve` may still point elsewhere — prefer CP URL when upgrading an **already installed** client unless the user is explicitly testing this CDN.

- for native Linux service mode: elevated privileges when not already root
- for native macOS service mode: elevated privileges when not already root
- for native Windows service mode: administrator PowerShell or CMD
- for Docker: Docker installed and able to pull images

## Workflow

### Step 1: Pre-flight

Silently inspect when possible:

- current OS and CPU architecture (`uname -s`, `uname -m`, or Windows environment)
- whether `zeronews` / `zeronews.exe` is already installed
- whether Docker is available (`docker version`)
- whether an existing workdir or Docker data directory already contains `config.yml`

Ask all questions upfront before running any install command:

1. **Native vs Docker** — native Linux/macOS/Windows use `zeronews login` (browser confirm) unless the user already pasted an AuthToken. **Docker still requires AuthToken first.** Do not invent, guess, or reuse a token from unrelated context.
2. **Install method** — native Linux, native macOS, native Windows, or Docker.
3. **Start mode** — **default: try system service / background** on native (`service install` then `service start`). Use foreground `start` **only** if the user explicitly asked (e.g. 前台、调试). **Do not** ask «要不要装服务» on a normal install. If service is **unsupported** or **cannot be installed** (see Step 4 fallback), run **foreground `start` automatically** — do not leave the client stopped.
4. **Optional client ID** — only if the user explicitly wants to bind a specific client ID.
5. **Docker-only choices** when Docker is selected:
   - image registry: China mirror (`docker.zeronews.cc/zeronews/zeronews`) or Docker Hub (`zeronews/zeronews`)
   - launch style: `docker run` or `docker compose`
   - host data directory, default `/opt/zeronews`
6. **macOS-only** — if architecture is unclear, ask whether the Mac is Apple Silicon or Intel, or detect with `uname -m`.
7. **Windows-only** — install directory, default a dedicated folder such as `D:\zeronews`.

Do **not** ask upfront questions that duplicate silent detection (OS, existing binary) when you can probe first.

### Step 1b: Already installed — automatic version sync (default)

When `zeronews` / `zeronews.exe` is already present and the user did **not** say probe-only / 只探测 / 不要升级 / don't download:

1. Follow **[UPGRADE-ON-INSTALL.md](./references/UPGRADE-ON-INSTALL.md)** end-to-end.
2. **Do not** ask «已安装，是否跳过 / 是否要升级».
3. After version is **latest** (or upgrade exhausted with clear error), continue with bind/start/verify below — skip redundant full download if binary is already current.

**Explicit exceptions** (these override auto-upgrade):

| User intent | Path |
|-------------|------|
| «有没有装过 / 探测一下 / 别升级» | **MCP `install_client(download_install=false)` 等价**：No download, no upgrade. `zeronews --version`, `status --json`, hand off `zeronews-inspect-client`. |
| «装过了，只想启动/看一下» | No upgrade unless version precheck shows **must_upgrade** / blocking old build; otherwise start + inspect only. |
| «换机器重装 / reset» | **`zeronews-reset-client`** with explicit confirmation, then fresh install. |
| Auth token conflict | Step 3b reset/ignore — not an upgrade prompt. |

For «升到最新版» as the **only** ask, you may use **`zeronews-upgrade-client`** directly; install skill still auto-upgrades when the task is **install**.

**MCP mapping**: `install_client` (default download+upgrade precheck) → this skill; `login` when missing binary → install then `zeronews-configure-client` login flow.

### Step 1c: Not installed yet

If no binary was found after probe, continue to Step 2 (platform install). After first install, run the same version precheck once so a stale bundled binary cannot slip through.

### Step 2: Install by platform

Use the exact commands in [INSTALL-COMMANDS.md](./references/INSTALL-COMMANDS.md) (test download base **`https://agentv2.testenv.waitoin.com:8443/`**). Do not invent other hosts; only use URLs under that base or CP-returned `download_url` during upgrade.

Summary:

| Platform | Install | Bind |
| --- | --- | --- |
| Linux | official install script, token optional | default: `NO_TTY=1 zeronews login` then poll `zeronews status --json`; or `sh -s install {TOKEN}` |
| macOS | download binary to `/Applications/zeronews` | `NO_TTY=1 ./zeronews login` then poll `status --json` |
| Windows | download `zeronews.exe` | `zeronews.exe login` then poll `status --json` |
| Docker | `docker run` or `docker compose` | **must ask user for token first**, then inject `-e TOKEN=<TOKEN>` |

#### Docker auth rule

For Docker installs, **always ask the user for AuthToken before generating or running any command**. Never start a container with a placeholder token and promise to fix it later. Never write the token into a compose file on disk unless the user explicitly accepts that persistence risk.

Docker auth happens through the `TOKEN` environment variable. Do not run a separate `authtoken` command inside the container for first-time setup.

### Step 3: Bind the machine (native installs only)

If `zeronews status --json` already has `"login": true` (valid `config.yml`), skip this step. Do not ask for a token and do not open login again.

If the user pasted an AuthToken, keep the old path: Linux `sh -s install {TOKEN}`, or `zeronews authtoken {TOKEN}` on macOS/Windows.

Otherwise use browser login:

```bash
NO_TTY=1 zeronews --workdir {WORKDIR} login
```

Only add `--client {NAME}` when the host product name is known (for example Cursor). Do not hardcode `--client Cursor` when unknown.

Stdout first line is the verify URL. Open it locally. If the browser opened, do not paste the URL into the chat. If open failed, show the URL and say it is only for the account owner — do not forward it.

Then poll:

```bash
zeronews --workdir {WORKDIR} status --json
```

- exit `0` and `"login": true` → bound. Then run **Step 4 (default service start)** — do not leave the client stopped after install unless the user chose foreground-only.
- exit `3` and `"login_pending": true` → still waiting; poll again. This is not a failure. Do not treat JSON parse success as logged in.
- exit `1` and `"login_error"` → stop and report the error (`denied` / `expired` / `quota_exceeded` / `failed`)
- `NO_TTY` **exists** (including `NO_TTY=0`) means non-interactive: `login` prints the URL and exits; only `status --json` writes `config.yml`.

Linux sudo must use the same workdir as later commands (`/etc/zeronews` is the default for the official script).

Do not hand-edit `config.yml`. Do not call `zeronews authtoken` after a successful login poll.

### Step 3b: Handle `Local config file already exists, token update ignored`

If `authtoken` or the Linux install script leaves the client unauthenticated and the CLI prints:

```text
Local config file already exists, token update ignored
```

stop immediately. The new token was **not** applied. Do not continue to start or service-install steps.

Tell the user plainly what happened, then ask them to choose:

1. **Reset** — hand off to `zeronews-reset-client`, then re-run auth
2. **Ignore** — keep the existing config and stop the install/auth flow

Do not auto-reset. Do not manually delete files when the user chose reset. Follow `../zeronews-configure-client/references/EXISTING-CONFIG-CONFLICT.md`.

If the user chooses **Reset**:

1. hand off to `zeronews-reset-client`
2. use elevated privileges when required; if `id -u` is already `0`, run without `sudo` (see `../zeronews-configure-client/references/PRIVILEGE-EXECUTION.md`)
3. after reset succeeds, re-bind with `zeronews login` (or `authtoken {TOKEN}` / the Linux script with `{TOKEN}` if that was the original path)
4. continue install/start only after `login: true` or `Authentication successful`

If the user chooses **Ignore**:

- explain that the existing binding was kept
- skip start steps unless the user still wants to start the already-configured client
- hand off to `zeronews-inspect-client` if they want to verify current state

For Docker volumes that already contain `config.yml`, apply the same reset-or-ignore choice. If reset is chosen, hand off to `zeronews-reset-client` against the mounted host workdir before recreating the container with a new `TOKEN`.

### Step 4: Start the client

**Default (native): try OS service first** — run automatically after bind (Step 3) or upgrade (Step 1b). **Do not** ask the user to confirm service install on a standard install task.

Order of attempts:

1. **System service** (`service install` + `service start`) when supported.
2. **Foreground** `start` when service is unavailable, unsupported, or still failing after the steps below — **without** asking «改用前台吗» unless the user had explicitly forbidden service.

#### Privilege / service vs foreground (native)

**Never ask** the user to approve service install, sudo, or «改用前台吗» during install. **Never wait** for the user to confirm elevation.

1. If already **root** (`id -u` is `0` on Linux/macOS) or shell is **Administrator** on Windows → run `service install` + `service start` **immediately** (skip install if service already registered).
2. If the session is **non-elevated** and `service install` / `service start` would require **interactive** sudo or admin approval (agent cannot elevate silently):
   - **Do not** prompt for authorization.
   - **Do not** retry with `sudo` expecting a password dialog.
   - **Immediately** run foreground **`zeronews start`** (see commands below) and note in the report: *foreground because service requires admin and this session cannot elevate silently* (macOS **launchd** / Linux **systemd** / Windows Service Manager).
3. If non-root but **`sudo -n`** (or equivalent) succeeds for service commands → you may run service **without asking**; if `sudo -n` fails, treat as (2) and go **straight to foreground** — no user message asking for sudo.

If service is **already installed** (from a prior admin setup) but not running → try `service start` **without sudo** if CLI allows; if that needs elevation and fails silently, use foreground `start`.

If service is installed and running but stale config after login/upgrade → try `service restart` when permitted without interactive elevation; otherwise foreground `start` or `reload` per configure skill.

```bash
# elevated session only — no user prompt on install path
zeronews --workdir {WORKDIR} service install
zeronews --workdir {WORKDIR} service start
```

Windows (Administrator shell only, no prompt): `zeronews.exe service install` then `service start`.

Platform notes: `../zeronews-configure-client/references/SERVICE-PRIVILEGES.md`, `../zeronews-configure-client/references/PRIVILEGE-EXECUTION.md`.

#### Fallback: foreground when service is not viable

**Do not** stop the install flow with «服务装不上». After service path fails, run foreground **`start`** and report which mode was used.

Fall back to foreground **without** a second confirmation when any of these apply:

| Condition | Action |
|-----------|--------|
| CLI/help indicates **no `service` subcommand** or OS not supported for daemon | `zeronews start` immediately |
| `service install` / `service start` exits non-zero with **unsupported / not implemented / no systemd or launchd** (read stderr) | `zeronews start`; note service unavailable |
| **Non-elevated session** and service needs **admin / sudo** (cannot run `service install` without interactive elevation) | **`zeronews start` immediately — no ask, no confirm** |
| `sudo -n service …` or service start fails with permission denied | **`zeronews start` immediately — no ask** |
| Service installed but **start keeps failing** without silent fix | `zeronews start` once |
| User **explicitly** asked foreground / 前台 / no service | skip service; foreground only |

Foreground commands:

```bash
zeronews --workdir {WORKDIR} start
```

macOS: `cd /Applications/zeronews && ./zeronews --workdir {WORKDIR} start`  
Windows: `.\zeronews.exe start` (from install dir with workdir)

Tell the user **after** start (in the install report only): preferred service when admin is available; **foreground was used automatically** when service required elevation this session could not apply silently.

Hand off ongoing service tweaks to `zeronews-manage-client-service` when the user later wants daemon mode.

#### Native foreground (user-requested only)

When the user **explicitly** requested foreground / 前台 / no service, **skip** service install and use foreground commands above only.

#### Docker (default background)

Containers start detached as part of `docker run -d` or `docker compose up -d`. After launch, inspect with:

```bash
docker ps
docker logs zeronews --tail 50
```

See `references/DOCKER.md` for full run and compose examples.

### Step 5: Verify installation

Confirm success using the best available signal:

- native: command exit code, then `zeronews-inspect-client` flow if the local runtime is reachable
- Docker: container is running, recent logs show no fatal auth or startup error
- user console: device appears online

Return:

- install method used
- binary path, workdir, or container name
- config path (`config.yml` location or Docker volume mount)
- client ID and cloud server address when available
- start mode used
- verification result

## Output

Return a concise install report:

- platform and install method
- download URL or image name used
- config path
- client ID and cloud server address if resolved
- how the client was started
- whether the device appears online or what the user should check next

## Handoff

After install succeeds:

- add tunnels → `zeronews-expose-service`, `zeronews-expose-webhook`, or `zeronews-share-files`
- inspect runtime → `zeronews-inspect-client`
- manage an already-installed service → `zeronews-manage-client-service`

## Safety rules

- native installs default to `zeronews login`; Docker installs must still ask for AuthToken explicitly
- **default native start = try system service only when already elevated or `sudo -n` works**; never prompt for service/sudo/前台 choice on install
- if service needs admin and the session **cannot elevate silently**, **immediately** run foreground `start` — **no user confirmation, no authorization dialog request**
- if **system service is not supported or fails**, **automatically** run foreground `start` — do not leave client stopped
- do not embed real tokens in examples, logs, or committed compose files
- do not use unofficial mirrors, scripts, or package sources
- do not claim UDP tunnel support
- skip service and use foreground **only** when the user explicitly asked for 前台 / no service
- do not reset or wipe an existing configured client without explicit user approval (**binary upgrade to latest is not a reset**)
- when the client already exists on an **install** task, **never** ask whether to upgrade — run [UPGRADE-ON-INSTALL.md](./references/UPGRADE-ON-INSTALL.md) instead
- when auth prints `Local config file already exists, token update ignored`, require an explicit reset-or-ignore choice before continuing
- when the user chooses reset, hand off to `zeronews-reset-client` instead of manually deleting files
- before any command that would use `sudo`, check whether the session is already root; if `id -u` is `0`, run without `sudo`
- prefer official commands from `references/INSTALL-COMMANDS.md` over improvised package managers
- on macOS, if Gatekeeper blocks the binary, tell the user to allow it in System Settings rather than disabling security globally
