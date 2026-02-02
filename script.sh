#!/usr/bin/env bash
set -euo pipefail

# =========================
# Codex + go-zero 一键初始化
# =========================

ROOT_DIR="$(pwd)"

echo "==> 1) 创建目录结构"
mkdir -p .codex/skills/ai-context
mkdir -p .codex/skills/zero-skills

echo "==> 2) 添加 git submodule（如已存在则跳过）"
add_submodule_if_missing() {
  local repo_url="$1"
  local target_path="$2"

  if [ -d "$target_path/.git" ] || git config --file .gitmodules --get-regexp path 2>/dev/null | grep -q " $target_path$"; then
    echo "    - submodule 已存在: $target_path (skip)"
    return 0
  fi

  git submodule add "$repo_url" "$target_path"
}

add_submodule_if_missing \
  "https://github.com/zeromicro/ai-context.git" \
  ".codex/skills/ai-context/repo"

add_submodule_if_missing \
  "https://github.com/zeromicro/zero-skills.git" \
  ".codex/skills/zero-skills/repo"

echo "==> 3) 初始化/更新 submodule"
git submodule update --init --recursive

echo "==> 4) 生成 SKILL.md（覆盖写入）"
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

echo "==> 5) 安装/编译 mcp-zero 到 \$HOME/.mcp-zero"
MCP_DIR="$HOME/.mcp-zero"
if [ -d "$MCP_DIR/.git" ]; then
  echo "    - 已存在 $MCP_DIR，执行 pull 更新"
  git -C "$MCP_DIR" pull --rebase
else
  git clone https://github.com/zeromicro/mcp-zero.git "$MCP_DIR"
fi

# 编译
if ! command -v go >/dev/null 2>&1; then
  echo "ERROR: 未检测到 go，请先安装 Go 再运行脚本" >&2
  exit 1
fi

pushd "$MCP_DIR" >/dev/null
go build -o mcp-zero main.go
popd >/dev/null

echo "==> 6) 生成 .codex/mcp.json（自动写入 GOCTL_PATH）"
mkdir -p .codex
GOCTL_PATH="$(command -v goctl 2>/dev/null || true)"

cat > .codex/mcp.json <<EOF
{
  "mcpServers": {
    "go-zero": {
      "command": "$HOME/.mcp-zero/mcp-zero",
      "env": {
        "GOCTL_PATH": "$GOCTL_PATH"
      }
    }
  }
}
EOF

echo "==> 完成 ✅"
echo "    - submodules: .codex/skills/*/repo"
echo "    - skills: .codex/skills/*/SKILL.md"
echo "    - mcp-zero: $HOME/.mcp-zero/mcp-zero"
echo "    - config: .codex/mcp.json"
