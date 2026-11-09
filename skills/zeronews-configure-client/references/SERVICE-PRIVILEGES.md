# Service Privileges

Before running any command shown here with `sudo`, check whether the current session is already root. If `id -u` is `0`, run the command without `sudo`. See `PRIVILEGE-EXECUTION.md`.

Service actions use native OS integrations and may require elevated privileges.

- Linux: `systemd` under `/etc/systemd/system/zeronews-client.service`
- macOS (system): `launchd` under `/Library/LaunchDaemons/com.zeronews.client.plist` — **requires root / sudo**
- macOS (Agent, Skills, default): **system** `zeronews service` → `/Library/LaunchDaemons/…` — **root** via `sudo -n` or **osascript `with administrator privileges`** (see [MACOS-AGENT-SERVICE.md](../../zeronews-install-client/references/MACOS-AGENT-SERVICE.md)); **`service --user` is not the default Agent path**
- Windows: native Windows Service Manager

Verified guidance from code:

- Linux install/start/stop/restart/uninstall require root
- macOS **system** service install/start/stop/restart/uninstall require root
- macOS **`service --user`** does not require root (CLI feature; **Agents default to system service + osascript** instead)
- Windows service operations require access to the Windows service manager

Do not attempt service installation or removal unless the user explicitly wants service mode.
