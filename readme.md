# go-zero Codex tools

This repo bootstraps the Codex tools environment for go-zero.

## Quick Start

```bash
# from the repo root
curl https://github.com/xbclub/go-zero-codex-tools/scripts/init-codex-skills.sh | bash
```

What it does:
- Syncs the latest `.codex/` from the upstream repo.
- Clones/updates `ai-context` and `zero-skills` under `.codex/skills/*/repo`.
- If Go is installed, clones/builds `mcp-zero` into `.mcp-zero/`.
- Generates/updates `.codex/mcp.json` and `.codex/config.toml`.
