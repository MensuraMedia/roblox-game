# Project Structure & Architecture

> Defines the folder layout, Rojo mapping, and architectural conventions for this Roblox project.

---

## Directory Layout

```
D:\projects\roblox\
│
├── .claude/                        # Claude Code configuration
│   └── settings.local.json         # Permission settings for AI tools
│
├── .gitignore                      # Files excluded from version control
├── CLAUDE.md                       # AI assistant project rules
├── MASTER_REFERENCE.md             # Comprehensive project index
├── PROJECT_STRUCTURE.md            # THIS FILE
├── DEVELOPMENT_WORKFLOW.md         # Dev process documentation
├── TOOLCHAIN_SETUP.md              # Setup and installation guide
│
├── design_principles/              # Standards and design documentation
│   ├── Luau_Style_Guide.md         # Luau coding conventions (PascalCase, camelCase, etc.)
│   ├── planning_development_process.md  # Planning, performance, security principles
│   ├── roact_ui_library.md         # react-lua/Roact UI framework reference
│   └── menu_systems.md             # Menu system patterns (WIP)
│
├── local_ai_and_roblox/            # AI integration documentation
│   └── claude_integration_to_roblox.md  # Rojo, MCP servers, AI workflow
│
├── src/                            # Game source code (synced via Rojo)
│   ├── server/                     # ServerScriptService
│   │   └── *.server.lua            # Server-only scripts
│   ├── client/                     # StarterPlayerScripts
│   │   └── *.client.lua            # Client-only scripts
│   ├── shared/                     # ReplicatedStorage
│   │   └── *.module.lua            # Shared ModuleScripts
│   └── assets/                     # Game assets and configs
│
├── tests/                          # TestEZ unit tests
│   └── *.spec.lua                  # Test specification files
│
├── assets/                         # External assets (models, sounds, images)
│
├── build/                          # Rojo build output (gitignored)
│   └── *.rbxlx                     # Compiled place files
│
└── default.project.json            # Rojo project configuration
```

---

## Rojo Project Configuration

The `default.project.json` maps the filesystem to Roblox's DataModel:

```json
{
  "name": "RobloxGame",
  "tree": {
    "$className": "DataModel",
    "ServerScriptService": {
      "$path": "src/server"
    },
    "ReplicatedStorage": {
      "$path": "src/shared"
    },
    "StarterPlayer": {
      "StarterPlayerScripts": {
        "$path": "src/client"
      }
    }
  }
}
```

---

## Rojo File Naming Conventions

| File Pattern | Creates | Runs On |
|-------------|---------|---------|
| `name.server.lua` | Script | Server |
| `name.client.lua` | LocalScript | Client |
| `name.module.lua` or `name.lua` | ModuleScript | Wherever required |
| `init.server.lua` | Script (as folder's default) | Server |
| `init.client.lua` | LocalScript (as folder's default) | Client |
| `init.lua` | ModuleScript (as folder's default) | Wherever required |
| `name.json` | Properties override for adjacent instance | N/A |
| `name.meta.json` | Metadata (ClassName, Name override) | N/A |

---

## Service Architecture

### Server-Side (`src/server/`)

Purpose: Authoritative game logic. **Never trust client data.**

| Script | Responsibility |
|--------|---------------|
| `main.server.lua` | Core game loop, initialization |
| `dataManager.server.lua` | DataStore handling, player data persistence |
| `gameRules.server.lua` | Game mechanics, validation, anti-cheat |
| `remoteHandlers.server.lua` | RemoteEvent/Function handlers with validation |

### Client-Side (`src/client/`)

Purpose: UI, input handling, local effects. **No authority over game state.**

| Script | Responsibility |
|--------|---------------|
| `ui.client.lua` | Main UI controller |
| `input.client.lua` | Input handling, keybinds |
| `effects.client.lua` | Local VFX, tweens, animations |
| `camera.client.lua` | Camera control |

### Shared (`src/shared/`)

Purpose: Modules accessible by both server and client.

| Module | Responsibility |
|--------|---------------|
| `Constants.module.lua` | Game constants (MAX_PLAYERS, etc.) |
| `Utils.module.lua` | Utility functions |
| `Types.module.lua` | Type definitions |
| `Config.module.lua` | Game configuration tables |
| `Remotes.module.lua` | RemoteEvent/Function references |

---

## Naming Conventions (from Luau Style Guide)

| Item | Convention | Example |
|------|-----------|---------|
| Files | Match export name | `PlayerManager.server.lua` |
| Classes | PascalCase | `PlayerManager` |
| Functions | camelCase | `getPlayerData()` |
| Variables | camelCase | `playerScore` |
| Constants | LOUD_SNAKE_CASE | `MAX_HEALTH` |
| Private | _camelCase | `_cachedData` |
| Services | Full name via GetService | `game:GetService("TweenService")` |
| Modules | Variable matches module name | `local Utils = require(...)` |

---

## Security Architecture

```
CLIENT (untrusted)          NETWORK              SERVER (authoritative)
┌──────────────────┐    RemoteEvent/     ┌──────────────────────┐
│ Input handling   │───Function calls───▶│ Validate ALL inputs  │
│ UI rendering     │                     │ Distance checks      │
│ Local effects    │◀──Filtered data────│ Money/item validation│
│ Camera control   │                     │ Rate limiting        │
│                  │                     │ DataStore operations │
│ NO game state    │                     │ FULL game state      │
│ authority        │                     │ authority            │
└──────────────────┘                     └──────────────────────┘
```

**Rules:**
- Server validates every client action (distance, ownership, currency)
- Client handles only visuals and input
- Sensitive data stays in ServerStorage
- RemoteEvents have rate limiting
- Minimize replicated state

---

## Performance Targets

| Category | Metric | Target | Tool |
|----------|--------|--------|------|
| Frame Rate | Compute time | < 16ms per frame (60 FPS) | Microprofiler |
| Memory | PlaceMemory | Monitor for leaks | Developer Console |
| Memory | LuaHeap | Minimal growth over time | Luau Heap snapshots |
| Load Time | Asset preload | Essential assets only | ContentProvider |
| Network | Replication | Minimal, on-change only | Network stats |

**Optimization Rules:**
- Anchor all static parts
- Low CollisionFidelity (Box/Hull) for non-critical physics
- Reuse meshes/textures for GPU instancing
- Textures <= 512x512
- Break heavy loops with `task.wait()`
- Client-side tweens and VFX (don't replicate)
- Enable instance streaming
