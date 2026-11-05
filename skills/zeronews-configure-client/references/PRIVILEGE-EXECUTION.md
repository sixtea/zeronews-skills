# Privilege-Aware Command Execution

Before running any command that would normally use `sudo` or an Administrator shell, detect whether the current session already has the required privileges.

Do not prepend `sudo` when the session is already elevated.

## Detect elevated session

### Linux / macOS

Any of these means the session is already root:

```bash
id -u
# 0 means root

whoami
# root means root
```

If `id -u` is `0`, run the command **without** `sudo`.

If `id -u` is not `0`, prepend `sudo` only when the command requires elevated privileges.

### Windows

When a command requires the Windows Service Manager or other admin-only operations, check whether the shell is already elevated.

PowerShell example:

```powershell
([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
```

If the result is `True`, run the command directly.

If the result is `False`, tell the user to reopen an Administrator PowerShell or CMD and rerun there.

## Command shaping rule

Use this pattern when building shell commands:

| Docs example | Already root / admin | Non-elevated session |
| --- | --- | --- |
| `sudo zeronews reset` | `zeronews reset` | `sudo zeronews reset` |
| `sudo zeronews service install` | `zeronews service install` | `sudo zeronews service install` |
| `sudo ./zeronews start` | `./zeronews start` | `sudo ./zeronews start` |
| `curl ... \| sudo sh -s install {TOKEN}` | `curl ... \| sh -s install {TOKEN}` | `curl ... \| sudo sh -s install {TOKEN}` |
| `sudo docker run ...` | `docker run ...` | `sudo docker run ...` |

## Failure handling

If a non-root command fails with messages such as:

```text
Reset requires administrator privileges. Please run with sudo
installing service requires administrator privileges. Please run with sudo
permission denied
```

then:

1. check whether the session is already root
2. if not root, tell the user to rerun with `sudo` or an Administrator shell
3. do not claim the operation succeeded

The agent cannot enter a password interactively. If `sudo` requires a password and fails, stop and ask the user to run the exact command in their own terminal.

## Docker note

Even when the user is root, still omit `sudo` only because the session is already elevated.

If the user is not root and not in the `docker` group, `sudo docker ...` may still be required unless they are already root.
