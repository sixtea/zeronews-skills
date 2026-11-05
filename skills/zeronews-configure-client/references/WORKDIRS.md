# Workdir Defaults

Verified default client workdirs:

- Linux: `/etc/zeronews`
- macOS: `/Applications/zeronews`
- Windows: the current executable directory

The CLI supports overriding the location with:

```bash
zeronews --workdir /absolute/path ...
```

Important files under the workdir:

- `config.yml`
- `prg_runtime.json`
- `control-plane.request.lock`
- `logs/zeronews-client.log`
