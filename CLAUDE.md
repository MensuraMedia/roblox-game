# CLAUDE.md - AI Assistant Project Conventions

## Project

Roblox game development system with AI-assisted workflows on Windows 11 Pro.
Repository: https://github.com/MensuraMedia/roblox-game

## Key Paths

- Project root: `D:\projects\roblox\`
- Game source: `src/server/`, `src/client/`, `src/shared/`
- Design docs: `design_principles/`
- AI integration docs: `local_ai_and_roblox/`
- Master reference: `MASTER_REFERENCE.md`

## Coding Conventions (Luau)

- **PascalCase** for classes, enums, Roblox APIs
- **camelCase** for variables, functions, members
- **LOUD_SNAKE_CASE** for constants
- **_camelCase** for private members
- Tabs for indentation (4-space width)
- 100 char line limit, 80 char comment limit
- Double quotes for strings
- No semicolons; trailing commas in multi-line tables
- Comments explain "why" not "what"
- `game:GetService()` for all services
- `task.wait()` not `wait()`
- Always `:Disconnect()` event connections
- Type annotations on function signatures

## File Naming (Rojo)

- `name.server.lua` → Script (ServerScriptService)
- `name.client.lua` → LocalScript (StarterPlayerScripts)
- `name.module.lua` → ModuleScript (ReplicatedStorage)

## Architecture Rules

- Server is authority; never trust client data
- Validate ALL inputs server-side (distance, ownership, currency)
- Shared modules in `src/shared/`, required by both server and client
- Sensitive data in ServerStorage only
- Rate limit RemoteEvent calls

## Git Conventions

- Commit messages: `feat:`, `fix:`, `refactor:`, `test:`, `docs:` prefix
- Branch from `main`: `feature/name`, `fix/name`, `refactor/name`
- Push all changes to GitHub: `MensuraMedia/roblox-game`

## Tools

- **Rojo v7** for filesystem <-> Studio sync (port 34872)
- **TestEZ** for unit testing
- **react-lua** for UI (not legacy Roact)
- **GitHub CLI** (`gh`) for repo operations
- **MCP servers** for Claude-Studio integration

## Don't

- Don't use `wait()` (use `task.wait()`)
- Don't trust client data for game state
- Don't skip event `:Disconnect()`
- Don't use textures > 512x512
- Don't replicate unnecessary state to clients
- Don't use Roact directly (use react-lua successor)
