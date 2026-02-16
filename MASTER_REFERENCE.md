# Roblox Game Development - Master Reference

> **Repository:** [MensuraMedia/roblox-game](https://github.com/MensuraMedia/roblox-game)
> **Experience:** Deck 22 | **Universe:** 9742367441 | **Place:** 106979621663843
> **Platform:** Windows 11 Pro | Roblox Studio | Luau
> **Last Updated:** 2026-02-16

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Repository Structure](#repository-structure)
3. [Core Technology Stack](#core-technology-stack)
4. [Design Principles Summary](#design-principles-summary)
5. [AI Integration Architecture](#ai-integration-architecture)
6. [MCP Server Ecosystem](#mcp-server-ecosystem)
7. [Quick Reference Links](#quick-reference-links)
8. [Document Index](#document-index)

---

## Project Overview

This project is an AI-assisted Roblox game development system running on Windows 11 Pro. The core workflow uses a **file-system-based approach** where AI generates and modifies Luau scripts on disk, which are synced bidirectionally with Roblox Studio via **Rojo v7**. This eliminates manual copy-pasting, enables Git version control, and supports automated testing.

### Core Development Loop

```
Plan → Code (Luau in VS Code) → Sync (Rojo) → Test (Studio) → Debug (AI reads output) → Iterate → Commit (Git) → Publish
```

### AI-Enhanced Loop

```
Prompt AI → AI writes .lua to disk → Rojo auto-syncs to Studio → Playtest → AI reads console/screenshots → AI iterates → Git commit
```

---

## Repository Structure

```
D:\projects\roblox\
├── .claude/                          # Claude Code configuration
│   └── settings.local.json           # Local permission settings
├── .gitignore                        # Git ignore rules
├── CLAUDE.md                         # AI assistant project conventions
├── MASTER_REFERENCE.md               # THIS FILE - comprehensive index
├── PROJECT_STRUCTURE.md              # Architecture and folder conventions
├── DEVELOPMENT_WORKFLOW.md           # Step-by-step dev processes
├── TOOLCHAIN_SETUP.md                # Tool installation and configuration
│
├── design_principles/                # Game design and coding standards
│   ├── Luau_Style_Guide.md           # Roblox Luau coding conventions
│   ├── planning_development_process.md # Planning, iteration, optimization
│   ├── roact_ui_library.md           # Roact/react-lua UI framework guide
│   └── menu_systems.md               # Menu system documentation (WIP)
│
├── local_ai_and_roblox/              # AI integration and toolchain docs
│   └── claude_integration_to_roblox.md # Rojo, MCP servers, AI workflow
│
└── src/                              # Game source code (Rojo-synced)
    ├── server/                       # ServerScriptService scripts
    ├── client/                       # StarterPlayerScripts
    ├── shared/                       # ReplicatedStorage modules
    └── assets/                       # Models, sounds, configs
```

---

## Core Technology Stack

| Category | Tool | Version/Notes |
|----------|------|---------------|
| **Language** | Luau | Roblox's enhanced Lua 5.1 |
| **IDE** | Roblox Studio | v0.600+ (visual editing, testing, publishing) |
| **Editor** | VS Code | With sumneko.lua LSP, Rojo extension |
| **Sync** | Rojo v7 | Filesystem <-> Studio bidirectional sync |
| **Version Control** | Git + GitHub | CLI via `gh`, repo: MensuraMedia/roblox-game |
| **UI Framework** | react-lua | Successor to Roact (deprecated), supports hooks |
| **Animation** | roact-spring | Spring-physics animation for UI |
| **Testing** | TestEZ | Roblox unit testing framework |
| **AI Integration** | Claude Code | Via MCP servers for autonomous dev |
| **Platform** | Windows 11 Pro | Full admin privileges |
| **Package Manager** | Cargo (Rust) | For Rojo CLI installation |
| **Runtime** | Node.js | For AI API wrapper scripts |

---

## Design Principles Summary

### Luau Coding Standards

| Convention | Style | Example |
|------------|-------|---------|
| Classes/Enums/APIs | PascalCase | `MyClass`, `TweenService` |
| Variables/Functions | camelCase | `myVariable`, `doSomething()` |
| Constants | LOUD_SNAKE_CASE | `MAX_PLAYERS` |
| Private Members | _camelCase | `_internalState` |
| Acronyms | Lowercase | `anRGBValue` |

**File Structure Order:** Services -> Requires -> Constants -> Variables/Functions -> Return

**Key Rules:**
- Tabs for indentation (4-space width)
- 100 char code limit, 80 char comment limit
- No semicolons, trailing commas in multi-line tables
- Double quotes for strings
- Comments explain "why" not "what"
- `game:GetService()` for all services
- Always `:Disconnect()` events
- `task.wait()` over `wait()`

### Development Philosophy

- **Plan First:** Outline structure, levels, story, mechanics before coding
- **YAGNI:** Only implement what's needed now
- **DRY:** Extract repeated logic to ModuleScripts
- **Iterate Early:** Playtest often, gather feedback, refine
- **Server Authority:** Never trust client data
- **Performance First:** Monitor with Developer Console, Microprofiler

---

## AI Integration Architecture

### File-System Workflow

```
AI Service (Claude/GPT/Grok)
    │
    ▼
Lua Script Generation (written to disk)
    │
    ▼
src/server/*.server.lua  ──── Rojo v7 ────► Roblox Studio
src/client/*.client.lua       (auto-sync)     (DataModel)
src/shared/*.module.lua        localhost:34872
    │
    ▼
Git Version Control
    │
    ▼
GitHub (MensuraMedia/roblox-game)
```

### Rojo File-to-Instance Mapping

| File Pattern | Roblox Instance | Location |
|-------------|----------------|----------|
| `*.server.lua` | Script | ServerScriptService |
| `*.client.lua` | LocalScript | StarterPlayerScripts |
| `*.module.lua` | ModuleScript | ReplicatedStorage |
| `init.server.lua` | Script (folder child) | Parent folder |
| `*.json` | Properties override | Adjacent instance |
| `*.meta.json` | Metadata | ClassName/Name override |

### Script Organization

| Location | Purpose |
|----------|---------|
| `ServerScriptService` | Server-only logic (game rules, data, security) |
| `ReplicatedStorage` | Shared modules, RemoteEvents/Functions |
| `StarterPlayerScripts` | Client-side UI, input, local effects |
| `ServerStorage` | Sensitive server data, templates |

---

## MCP Server Ecosystem

### Top 3 Recommended MCP Servers for Claude

| Rank | Server | Key Feature | Best For |
|------|--------|-------------|----------|
| **1** | [kevinswint/roblox-studio-rust-mcp-server](https://github.com/kevinswint/roblox-studio-rust-mcp-server) | Autonomous debugging loop (`capture_screenshot`, `read_output`, `write_script`) | Claude Code + Claude Max autonomous workflows |
| **2** | [DefinitelyNotJosh1/roblox-mcp](https://github.com/DefinitelyNotJosh1/roblox-mcp) | 40+ tools with granular script editing (`edit_script_lines`, `insert_script_lines`) | Complex scripting, refactoring, large codebases |
| **3** | [dax8it/roblox-mcp](https://github.com/dax8it/roblox-mcp) | Live Luau execution + Roblox Open Cloud integration | Batch operations, DataStore management, publishing |

### Full MCP Server Registry

See [local_ai_and_roblox/claude_integration_to_roblox.md](local_ai_and_roblox/claude_integration_to_roblox.md) for the complete list of 20+ MCP servers with descriptions and links.

---

## Quick Reference Links

### Official Roblox

| Resource | URL |
|----------|-----|
| Lua Style Guide | https://roblox.github.io/lua-style-guide |
| Performance Optimization | https://create.roblox.com/docs/performance-optimization |
| UI/UX Design | https://create.roblox.com/docs/production/game-design/ui-ux-design |
| Publishing Guide | https://create.roblox.com/docs/production/publishing/publish-experiences-and-places |
| Anti-Cheat Guide | https://devforum.roblox.com/t/creating-proper-anti-exploits-the-ultimate-guide/2172882 |
| DevForum | https://devforum.roblox.com/ |

### Tools & Libraries

| Resource | URL |
|----------|-----|
| Rojo v7 Docs | https://rojo.space/docs/v7 |
| Rojo GitHub | https://github.com/rojo-rbx/rojo |
| react-lua (Roact successor) | https://github.com/jsdotlua/react-lua |
| Roact (archived) | https://github.com/Roblox/roact |
| roact-spring | https://github.com/chriscerie/roact-spring |
| Rojo VS Code Extension | https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo |

---

## Programmatic Publishing

The system supports **fully automated publishing** to Roblox via the Open Cloud API.

### Quick Publish Commands

```bash
bash tools/publish.sh                         # Build + publish (one command)
node tools/roblox-api.js publish              # Publish via Node.js
node tools/roblox-api.js list-versions        # Verify published versions
node tools/roblox-api.js datastore-get <n> <k> # Read player data
```

### Requirements

- `.env` file with `ROBLOX_OPEN_CLOUD_API_KEY`, `ROBLOX_UNIVERSE_ID`, `ROBLOX_PLACE_ID`
- API key created at [creator.roblox.com/credentials](https://creator.roblox.com/credentials)
- Universe/Place created once in Studio (API cannot create new universes)

See [PUBLISHING_GUIDE.md](PUBLISHING_GUIDE.md) for full details.

---

## Document Index

| Document | Path | Purpose |
|----------|------|---------|
| **Master Reference** | `MASTER_REFERENCE.md` | This file - comprehensive project index |
| **Agent Capabilities** | `AGENT_CAPABILITIES.md` | All programmatic operations for AI agents |
| **Publishing Guide** | `PUBLISHING_GUIDE.md` | Automated build and deploy pipeline |
| **Project Structure** | `PROJECT_STRUCTURE.md` | Architecture, folders, Rojo mapping |
| **Development Workflow** | `DEVELOPMENT_WORKFLOW.md` | Step-by-step processes and checklists |
| **Toolchain Setup** | `TOOLCHAIN_SETUP.md` | Installation, configuration, troubleshooting |
| **CLAUDE.md** | `CLAUDE.md` | AI assistant conventions and rules |
| **Luau Style Guide** | `design_principles/Luau_Style_Guide.md` | Coding conventions and standards |
| **Planning Process** | `design_principles/planning_development_process.md` | Design, performance, security principles |
| **Roact UI Library** | `design_principles/roact_ui_library.md` | UI framework guide with examples |
| **Menu Systems** | `design_principles/menu_systems.md` | Menu implementation (WIP) |
| **AI Integration** | `local_ai_and_roblox/claude_integration_to_roblox.md` | Rojo setup, MCP servers, AI workflow |

### Tools & Scripts

| Script | Path | Purpose |
|--------|------|---------|
| **Publish Script** | `tools/publish.sh` | Build Rojo project and publish to Roblox |
| **API Helper** | `tools/roblox-api.js` | Open Cloud API operations (publish, DataStore, etc.) |
