# Subdomain prefix (add domain)

Matches MCP `add_domain` / CLI validation.

## Rules

- Pattern: **`^[a-z0-9]{6,12}$`**
- Lowercase only; no hyphens or underscores in prefix

## When user did not specify a prefix

Skills have no MCP Questions UI. Equivalent flow:

1. Generate **four distinct** random prefixes, each **8 characters** from `a-z0-9` (use secure random if available, e.g. `openssl rand` + map to alphabet, or a short Python one-liner — do not reuse the same four strings every time).
2. Present as numbered options **1–4**, plus **5) 自定义** — user types their own prefix; validate before CLI.
3. Run `add domain --subdomain {chosen} --json`.

Do **not** call CLI until a valid prefix is chosen.

## Errors

| Symptom | Guidance |
|---------|----------|
| invalid prefix | Re-prompt with rules |
| no entitlement | User must upgrade plan |
| no available domain | Try another prefix or check account limits |
