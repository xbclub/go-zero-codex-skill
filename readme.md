# go-zero Codex tools

This repo bootstraps the Codex tools environment for go-zero.

## Quick Start

```bash
# from the repo root
./scripts/init-codex-skills.sh
```

What it does:
- Syncs the latest `.codex/` from the upstream repo.
- Clones/updates `ai-context` and `zero-skills` under `.codex/skills/*/repo`.
- If Go is installed, clones/builds `mcp-zero` into `.mcp-zero/`.
- Generates/updates `.codex/mcp.json` and `.codex/config.toml`.

## Options

- Skip syncing `.codex`:

```bash
SKIP_CODEX_SYNC=1 ./scripts/init-codex-skills.sh
```

- Override the upstream `.codex` source:

```bash
CODEX_SOURCE_REPO=https://github.com/xbclub/go-zero-codex-skill.git \
  ./scripts/init-codex-skills.sh
```

- Override skill repos:

```bash
AI_CONTEXT_URL=https://github.com/zeromicro/ai-context.git \
ZERO_SKILLS_URL=https://github.com/zeromicro/zero-skills.git \
  ./scripts/init-codex-skills.sh
```
