# CLI list JSON paths (`show tunnels|domains|devices --json`)

Parse **stdout JSON** from the CLI (not MCP wrapper keys).

## Where rows live

Most builds return a **single object** with list rows at:

1. **`items[]`** — common (see ACCOUNT-CLI-JSON samples)
2. **`page.items[]`** — if the CLI nests pagination under `page`

Use:

```text
items = root.items ?? root.page?.items ?? []
total = root.total ?? root.page?.total
```

If `items` is empty but `total > 0`, retry with `--page` / `--size`.

## IDs for mutations

| Command | Id field |
|---------|----------|
| `show tunnels` | `items[].id` → `delete tunnel` / `tunnel enable|disable` |
| `show domains` | `items[].id` (domain); `items[].ports[].id` → `delete port` |
| `show devices` | `items[].id` → `delete client` / `device upgrade` / `device enable|disable` |

Device **`id`** is the **client_id** for device subcommands.

Full command table: [ACCOUNT-CLI-JSON.md](../../../docs/references/ACCOUNT-CLI-JSON.md) (repo) or bundled copy in sibling skills.
