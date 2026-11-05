# Log Paths

Primary rolling client log:

```text
{workdir}/logs/zeronews-client.log
```

Service-mode logs may also exist depending on the operating system:

- Linux service logs are managed through `systemd` / syslog
- macOS launchd service files write:
  - `logs/zeronews-service.out.log`
  - `logs/zeronews-service.err.log`
- Windows service behavior is managed through the Windows service infrastructure

When diagnosing tunnel issues, combine:

- local API endpoint status
- endpoint snapshot output
- client logs
- service status
