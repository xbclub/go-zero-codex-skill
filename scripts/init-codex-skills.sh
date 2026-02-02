#!/usr/bin/env bash
set -euo pipefail

if [ -n "${BASH_SOURCE[0]:-}" ]; then
  ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -L)"
else
  ROOT_DIR="$(pwd -L)"
fi
if [ -z "$ROOT_DIR" ] || [ ! -w "$ROOT_DIR" ]; then
  echo "ROOT_DIR is not writable: $ROOT_DIR"
  exit 1
fi
AI_CONTEXT_DIR="$ROOT_DIR/.codex/skills/ai-context/repo"
ZERO_SKILLS_DIR="$ROOT_DIR/.codex/skills/zero-skills/repo"
CODEX_DIR="$ROOT_DIR/.codex"
MCP_JSON_PATH="$CODEX_DIR/mcp.json"
CODEX_CONFIG_PATH="$CODEX_DIR/config.toml"
MCP_ZERO_DIR="$ROOT_DIR/.mcp-zero"

AI_CONTEXT_URL="${AI_CONTEXT_URL:-https://github.com/zeromicro/ai-context.git}"
ZERO_SKILLS_URL="${ZERO_SKILLS_URL:-https://github.com/zeromicro/zero-skills.git}"
MCP_ZERO_URL="https://github.com/zeromicro/mcp-zero.git"
CODEX_SOURCE_REPO="${CODEX_SOURCE_REPO:-https://github.com/xbclub/go-zero-codex-skill.git}"

sync_codex_dir() {
  local repo="$1"
  local dest="$2"
  local tmp_dir

  tmp_dir="$(mktemp -d)"
  echo "Fetching latest .codex from $repo"
  git clone --depth 1 "$repo" "$tmp_dir"

  if [ ! -d "$tmp_dir/.codex" ]; then
    echo "No .codex directory found in $repo."
    rm -rf "$tmp_dir"
    exit 1
  fi

  if command -v rsync >/dev/null 2>&1; then
    mkdir -p "$dest"
    rsync -a --delete "$tmp_dir/.codex/" "$dest/"
  else
    rm -rf "$dest"
    mkdir -p "$dest"
    cp -a "$tmp_dir/.codex/." "$dest/"
  fi

  rm -rf "$tmp_dir"
}

clone_or_update() {
  local url="$1"
  local dir="$2"

  if [ -d "$dir/.git" ]; then
    echo "Updating $(basename "$(dirname "$dir")") repo in $dir"
    git -C "$dir" pull --ff-only
    return
  fi

  if [ -d "$dir" ] && [ "$(ls -A "$dir")" ]; then
    echo "Directory $dir exists and is not empty, but is not a git repo."
    echo "Please remove it or move it aside, then re-run."
    exit 1
  fi

  mkdir -p "$(dirname "$dir")"
  echo "Cloning $url into $dir"
  git clone "$url" "$dir"
}

if [ "${SKIP_CODEX_SYNC:-}" != "1" ]; then
  sync_codex_dir "$CODEX_SOURCE_REPO" "$CODEX_DIR"
fi

clone_or_update "$AI_CONTEXT_URL" "$AI_CONTEXT_DIR"
clone_or_update "$ZERO_SKILLS_URL" "$ZERO_SKILLS_DIR"

install_mcp_zero() {
  if ! command -v go >/dev/null 2>&1; then
    echo "go is not installed; skipping mcp-zero install."
    return
  fi

  if [ -d "$MCP_ZERO_DIR/.git" ]; then
    echo "Updating mcp-zero in $MCP_ZERO_DIR"
    git -C "$MCP_ZERO_DIR" pull --ff-only
  else
    if [ -d "$MCP_ZERO_DIR" ] && [ "$(ls -A "$MCP_ZERO_DIR")" ]; then
      echo "Directory $MCP_ZERO_DIR exists and is not empty, but is not a git repo."
      echo "Please remove it or move it aside, then re-run."
      exit 1
    fi
    mkdir -p "$(dirname "$MCP_ZERO_DIR")"
    echo "Cloning $MCP_ZERO_URL into $MCP_ZERO_DIR"
    git clone "$MCP_ZERO_URL" "$MCP_ZERO_DIR"
  fi

  echo "Building mcp-zero..."
  (cd "$MCP_ZERO_DIR" && go build -o mcp-zero main.go)

  mkdir -p "$CODEX_DIR"

  if [ ! -f "$CODEX_CONFIG_PATH" ]; then
    cat >"$CODEX_CONFIG_PATH" <<EOF
[features]
skills = true

[mcp_servers.go-zero]
type = "stdio"
command = "$MCP_ZERO_DIR/mcp-zero"
env = { GOCTL_PATH = "$(command -v goctl || true)" }
EOF
  fi

  python3 - <<'PY' "$MCP_JSON_PATH" "$MCP_ZERO_DIR"
import json
import os
import sys

mcp_json_path = sys.argv[1]
mcp_zero_dir = sys.argv[2]
goctl_path = os.popen("command -v goctl").read().strip()

data = {}
if os.path.exists(mcp_json_path):
    with open(mcp_json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

data.setdefault("mcpServers", {})
data["mcpServers"]["go-zero"] = {
    "command": os.path.join(mcp_zero_dir, "mcp-zero"),
    "env": {
        "GOCTL_PATH": goctl_path,
    },
}

with open(mcp_json_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=4, ensure_ascii=False)
    f.write("\\n")
PY
}

install_mcp_zero

echo "Done."
