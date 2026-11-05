# Tunnel list labels (Skills picker)

When MCP `choices[].label` is unavailable, build human-readable lines from `show tunnels --json` items.

## Fields (typical)

| Field | Use in label |
|-------|----------------|
| `id` | Required for CLI; show shortened prefix |
| `subdomain` + `root_domain.domain` | Public host |
| `self_hosted_domain` | Overrides subdomain display if set |
| `type` | HTTPS / TCP / TLS |
| `feature` | `file_share` → show as LFS |
| `enabled` | 启用 / 停用 |
| `route_rules…backend_endpoints` | Optional `local_ip:local_port` |

## Example line format

```text
1) abc12345… · https://myapp.example.com · HTTPS · 启用 · 127.0.0.1:3000
2) def67890… · share.example.com · LFS · 停用
```

Align intent with MCP `tunnel-delete-choices` / enable-disable pickers; exact wording may differ.

## Pagination

If JSON includes `total` > `items.length`, note that the picker shows only the current page.
