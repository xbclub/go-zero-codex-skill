# Codex Skills 初始化

本脚本用于初始化/更新 `.codex/skills` 下的两个依赖仓库：
- ai-context
- zero-skills

## 默认源

脚本默认从以下源拉取：
- https://github.com/zeromicro/ai-context.git
- https://github.com/zeromicro/zero-skills.git

如需切换到内网或镜像源，请使用环境变量覆盖。

## 使用方式

```bash
./scripts/init-codex-skills.sh
```

## 一句话加载（One-Prompt Setup）

直接告诉 AI 助理：

```
Set up go-zero Codex skills for this project from <repo-url>
```

将 `<repo-url>` 替换为当前项目的仓库地址或本地路径。

AI 将自动执行以下操作：

1. 运行 `./scripts/init-codex-skills.sh`
2. 拉取/更新 `ai-context` 与 `zero-skills`
3. 安装并配置 `mcp-zero`（如检测到已安装 Go）
4. 生成/更新 `.codex/mcp.json` 与 `.codex/config.toml`

> 如果 AI 未能完成，手动执行 `./scripts/init-codex-skills.sh` 即可。

## 安装 MCP 工具（mcp-zero）

该脚本会自动安装 mcp-zero（用于 goctl 能力集成），默认安装到项目内：

```
<repo>/.mcp-zero/mcp-zero
```

安装完成后会将 MCP 配置写入当前项目的 `.codex/mcp.json`，
并指向 `<repo>/.mcp-zero/mcp-zero`。
如项目内不存在 `.codex/config.toml`，脚本会初始化并写入默认 MCP 配置段。

### 自定义源

```bash
AI_CONTEXT_URL=https://your-mirror/ai-context.git \
ZERO_SKILLS_URL=https://your-mirror/zero-skills.git \
./scripts/init-codex-skills.sh
```

## 行为说明

- 如果目录已是 git 仓库：执行 `git pull --ff-only`
- 如果目录不存在或为空：执行 `git clone`
- 如果目录非空但不是 git 仓库：脚本退出并提示
- MCP 部分默认执行，无需额外开关

## AI 使用说明（自动加载工具）

> 目标：让 AI 仅根据本 README 自动完成工具加载。

1. 运行初始化脚本：

```bash
./scripts/init-codex-skills.sh
```

2. 脚本会生成或更新 `.codex/mcp.json` 与 `.codex/config.toml`。
3. AI 需要读取 `.codex/mcp.json`，并按其中的 MCP 配置加载工具。
4. 若 `.codex/mcp.json` 不存在，说明脚本未成功执行，应先修复并重试。
