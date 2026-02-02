## One-Prompt Setup

Just tell your AI assistant:

```
Set up go-zero AI tools for this project from https://github.com/xbclub/go-zero-codex-tools
```

### codex

```bash
mkdir -p .codex/skills/ai-context
mkdir -p .codex/skills/zero-skills
# Add ai-context as submodule
git submodule add https://github.com/zeromicro/ai-context.git .codex/skills/ai-context/repo

# Add zero-skills for reference
git submodule add https://github.com/zeromicro/zero-skills.git .codex/skills/zero-skills/repo

# create skill file
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

# 安装 mcp-zero（代码生成工具）- 个人目录，不在项目内
git clone https://github.com/zeromicro/mcp-zero.git ~/.mcp-zero
cd ~/.mcp-zero && go build -o mcp-zero main.go

GOCTL_PATH="$(which goctl || true)" cat > .codex/mcp.json <<EOF
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

```
