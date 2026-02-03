#!/usr/bin/env bash
set -euo pipefail

# =========================
# Codex + go-zero 一键初始化
# =========================

echo "==> 1) 创建目录结构"
mkdir -p .codex/skills/ai-context
mkdir -p .codex/skills/zero-skills

echo "==> 2) 添加 git submodule（如已存在则跳过）"
add_submodule_if_missing() {
  local repo_url="$1"
  local target_path="$2"

  if git config --file .gitmodules --get-regexp path 2>/dev/null | grep -q " $target_path$"; then
    echo "    - submodule 已存在: $target_path (skip)"
    return
  fi

  git submodule add "$repo_url" "$target_path"
}

add_submodule_if_missing \
  "https://github.com/zeromicro/ai-context.git" \
  ".codex/skills/ai-context/repo"

add_submodule_if_missing \
  "https://github.com/zeromicro/zero-skills.git" \
  ".codex/skills/zero-skills/repo"

echo "==> 3) 初始化 / 更新 submodule"
git submodule update --init --recursive

echo "==> 4) 写入 SKILL.md"
cat > .codex/skills/zero-skills/SKILL.md <<'EOF'
---
name: gozero-zero-skills
description: go-zero 的深度模式与最佳实践知识库（来自 zeromicro/zero-skills）
---

This skill is loaded by Codex.

Documentation lives under the `repo/` directory.
EOF

cat > .codex/skills/ai-context/SKILL.md <<'EOF'
---
name: gozero-ai-context
description: go-zero 的工作流与决策规则（来自 zeromicro/ai-context）
---

This skill is loaded by Codex.

Documentation lives under the `repo/` directory.
EOF

echo "==> 5) 安装 / 编译 mcp-zero"
MCP_DIR="$HOME/.mcp-zero"

if [ -d "$MCP_DIR/.git" ]; then
  git -C "$MCP_DIR" pull --rebase
else
  git clone https://github.com/zeromicro/mcp-zero.git "$MCP_DIR"
fi

if ! command -v go >/dev/null 2>&1; then
  echo "ERROR: Go 未安装" >&2
  exit 1
fi

pushd "$MCP_DIR" >/dev/null
go build -o mcp-zero main.go
popd >/dev/null

echo "==> 6) 写入个人 .codex/config.toml"
USER_CODEX_DIR="$HOME/.codex"
USER_CODEX_CONFIG="$USER_CODEX_DIR/config.toml"
mkdir -p "$USER_CODEX_DIR"

MCP_ZERO_BIN="$MCP_DIR/mcp-zero"
GOCTL_PATH="$(command -v goctl 2>/dev/null || true)"

if [ -f "$USER_CODEX_CONFIG" ] && grep -q "^\[mcp_servers\.go-zero\]" "$USER_CODEX_CONFIG"; then
  # Replace existing go-zero block in user config
  tmpfile="$(mktemp)"
  awk -v bin="$MCP_ZERO_BIN" -v goctl="$GOCTL_PATH" '
    BEGIN { in_block=0 }
    /^\[mcp_servers\.go-zero\]$/ {
      in_block=1
      print "[mcp_servers.go-zero]"
      print "type = \"stdio\""
      print "command = \"" bin "\""
      print "env = { GOCTL_PATH = \"" goctl "\" }"
      next
    }
    /^\[.*\]$/ {
      if (in_block) in_block=0
    }
    { if (!in_block) print }
  ' "$USER_CODEX_CONFIG" > "$tmpfile"
  mv "$tmpfile" "$USER_CODEX_CONFIG"
else
  # Append minimal config if not present
  {
    echo ""
    echo "[mcp_servers.go-zero]"
    echo "type = \"stdio\""
    echo "command = \"$MCP_ZERO_BIN\""
    echo "env = { GOCTL_PATH = \"$GOCTL_PATH\" }"
  } >> "$USER_CODEX_CONFIG"
fi

echo "==> 完成 ✅"
echo "  - MCP: $MCP_ZERO_BIN"
echo "  - goctl: ${GOCTL_PATH:-未检测到}"
echo "  - config: $USER_CODEX_CONFIG"
