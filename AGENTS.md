# go-zero Codex Skills

If the user asks to set up AI tools or says “one-prompt setup”, run:

```bash
./scripts/init-codex-skills.sh
```

What it does:
- Clones or updates `ai-context` and `zero-skills` into `.codex/skills/*/repo`.
- Installs `mcp-zero` into `.mcp-zero/` when Go is available, and builds the binary.
- Writes or updates `.codex/mcp.json` and `.codex/config.toml`.

Constraints:
- If a target directory exists and is not a git repo, the script exits. Ask the user how to proceed.
- If Go is missing, `mcp-zero` install is skipped; mention this and suggest installing Go if they want MCP support.
