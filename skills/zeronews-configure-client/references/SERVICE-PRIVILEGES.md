# Service Privileges

Before running any command shown here with `sudo`, check whether the current session is already root. If `id -u` is `0`, run the command without `sudo`. See `PRIVILEGE-EXECUTION.md`.

Service actions use native OS integrations and may require elevated privileges.

- Linux: `systemd` under `/etc/systemd/system/zeronews-client.service`
- macOS: `launchd` under `/Library/LaunchDaemons/com.zeronews.client.plist`
- Windows: native Windows Service Manager

Verified guidance from code:

- Linux install/start/stop/restart/uninstall require root
- macOS install/start/stop/restart/uninstall require root
- Windows service operations require access to the Windows service manager

Do not attempt service installation or removal unless the user explicitly wants service mode.
