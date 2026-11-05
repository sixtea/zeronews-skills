# Local API Reference

Verified local API endpoints:

- `GET /healthz`
- `GET /api/v1/auth/status`
- `POST /api/v1/auth/configure`
- `GET /api/v1/status`
- `GET /api/v1/config`
- `GET /api/v1/endpoints`
- `POST /api/v1/tunnels`
- `POST /api/v1/reconnect`

Default listen address:

```text
127.0.0.1:37271
```

The runtime file stores:

- `listen_addr`
- `connect_addr`
- `api_prefix`
- `health_path`
- `pid`
- `started_at`

If the runtime binds to a wildcard address, the stored `connect_addr` is normalized to loopback for safe local probing.
