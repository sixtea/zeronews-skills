#!/usr/bin/env bash
# Sync maintainer source from monorepo zeronews-client-skills → this repo (zeronews-skills).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${ZERONEWS_SKILLS_SRC:-$(cd "$ROOT/.." && pwd)/zeronews-client-skills}"

if [[ ! -d "$SRC/skills" ]]; then
  echo "Source not found: $SRC/skills" >&2
  echo "Set ZERONEWS_SKILLS_SRC to zeronews-client-skills path." >&2
  exit 1
fi

rsync -a --delete --exclude='.DS_Store' "$SRC/skills/" "$ROOT/skills/"
rsync -a --delete "$SRC/docs/" "$ROOT/docs/"
rsync -a --delete "$SRC/evals/" "$ROOT/evals/"
cp "$SRC/CHANGELOG.md" "$SRC/skills-lock.json" "$SRC/LICENSE" "$ROOT/"

# Canonical layout: keep MCP-optimized content on zeronews-* only (see repo CHANGELOG).
SK="$ROOT/skills"
merge_pair() {
  local short="$1" canon="$2"
  [[ -d "$SK/$short" ]] || return 0
  if [[ -f "$SK/$short/SKILL.md" ]] && [[ -d "$SK/$canon" ]]; then
    cp "$SK/$short/SKILL.md" "$SK/$canon/SKILL.md"
  fi
  if [[ -d "$SK/$short/references" ]]; then
    mkdir -p "$SK/$canon/references"
    rsync -a "$SK/$short/references/" "$SK/$canon/references/"
  fi
  rm -rf "$SK/$short"
}

for short in configure-client expose-service expose-webhook inspect-client install-client \
  manage-account-clients manage-account-tunnels manage-client-service manage-platform-domains \
  mcp-bridge reset-client share-files upgrade-client; do
  if [[ "$short" == "mcp-bridge" ]]; then
    merge_pair mcp-bridge zeronews-mcp-bridge
  else
    merge_pair "$short" "zeronews-$short"
  fi
done

echo "Synced from $SRC → $ROOT (deduped to zeronews-* only)"
