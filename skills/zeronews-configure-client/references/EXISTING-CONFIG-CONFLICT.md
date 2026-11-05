# Existing Config Conflict

## When this happens

During `zeronews authtoken`, the CLI may print:

```text
Local config file already exists, token update ignored
Use [zeronews reset] or remove the config file and try again
```

This means:

- `{workdir}/config.yml` already exists
- the local client runtime is **not** reachable for live reconfiguration
- the new AuthToken was **not** applied

Do not treat this as successful authentication.

## Required agent behavior

Stop immediately and present a clear choice to the user:

1. **重置（Reset）** — hand off to `zeronews-reset-client`, then bind the new token again
2. **忽略（Ignore）** — keep the existing config and stop the auth attempt

Do not auto-reset. Do not manually delete files when the user chose reset; use `zeronews-reset-client` instead.

## If the user chooses Ignore

- explain that the existing binding was kept
- report the current config path
- read current `client_id` from config or local API only if the client can be inspected safely
- do not run `authtoken` again unless the user changes their mind
- hand off to `zeronews-inspect-client` if the user wants to verify the current device state

## If the user chooses Reset

Hand off to `zeronews-reset-client`. Do not manually `rm` config or logs in this path.

### Reset flow

1. confirm the user wants local client state removed before rebinding the new token
2. warn that reset is destructive and may require elevated privileges when a system service is installed
3. run `zeronews-reset-client`:
   - first check privileges per `PRIVILEGE-EXECUTION.md`
   - Linux / macOS with an installed service and non-root session: `sudo zeronews --workdir {WORKDIR} reset`
   - Linux / macOS when already root (`id -u` is `0`): `zeronews --workdir {WORKDIR} reset`
   - Windows with an installed service: run from an Administrator shell when not already elevated
   - otherwise: `zeronews --workdir {WORKDIR} reset`
4. if reset fails with `Reset requires administrator privileges. Please run with sudo`, tell the user to rerun with the required privileges; do not claim reset completed
5. after reset succeeds, return to the calling skill and re-run auth:

```bash
zeronews --workdir {WORKDIR} authtoken {TOKEN}
```

If the user also supplied a client ID:

```bash
zeronews --workdir {WORKDIR} authtoken {TOKEN} {CLIENT_ID}
```

6. continue only after the CLI prints `Authentication successful`

### Handoff map

| Calling skill | After reset + successful authtoken |
| --- | --- |
| `zeronews-install-client` | resume install/start steps in that skill |
| `zeronews-configure-client` | return configure result (config path, client ID, cloud server address) |

## When live reconfiguration may still work

If a healthy local client runtime is already running, `authtoken` may reconfigure through the local API without hitting this warning.

## Docker note

This warning applies to native CLI auth against a host workdir. Docker first-time setup uses the `TOKEN` environment variable instead of `authtoken`.

If a Docker volume already contains `config.yml` and the user chooses reset:

1. stop and remove the container
2. hand off to `zeronews-reset-client` against the mounted host workdir, or remove the persisted volume contents through the same reset command when the CLI is available on the host
3. recreate the container with the new `TOKEN`

If the user chooses ignore, keep the existing volume and stop the token change attempt.
