# Agent Capabilities & Programmatic Operations

> Complete reference for all operations that AI agents can perform on this Roblox development system.
> Agents should assimilate this document into their working memory for autonomous game development.

---

## System Overview

| Component | Value |
|-----------|-------|
| **Roblox Account** | Mensura222 (User ID: 10484973275) |
| **GitHub Repo** | MensuraMedia/roblox-game |
| **Local Project** | D:\projects\roblox\ |
| **Platform** | Windows 11 Pro (full admin) |
| **API Key Location** | `.env` file (gitignored, NEVER commit) |

---

## 1. Code Generation & File Operations

Agents can create, read, edit, and delete any file in the project. These are the primary operations for building games.

### Write Game Scripts

| File Pattern | Destination | Context |
|-------------|-------------|---------|
| `src/server/name.server.lua` | ServerScriptService | Server authority, game logic, validation |
| `src/client/name.client.lua` | StarterPlayerScripts | UI, input, local effects |
| `src/shared/name.module.lua` | ReplicatedStorage | Shared modules, types, constants |

**Convention:** Follow `CLAUDE.md` and `design_principles/Luau_Style_Guide.md` for all Luau code.

### Example: Create a Complete Module

```lua
-- src/shared/Inventory.module.lua
local Inventory = {}
Inventory.__index = Inventory

export type InventoryType = typeof(setmetatable({
	_items: { [string]: number },
}, Inventory))

function Inventory.new(): InventoryType
	local self = {
		_items = {},
	}
	return setmetatable(self, Inventory)
end

function Inventory:add(itemName: string, count: number?)
	local amount = count or 1
	self._items[itemName] = (self._items[itemName] or 0) + amount
end

function Inventory:remove(itemName: string, count: number?): boolean
	local amount = count or 1
	local current = self._items[itemName] or 0
	if current < amount then
		return false
	end
	self._items[itemName] = current - amount
	if self._items[itemName] <= 0 then
		self._items[itemName] = nil
	end
	return true
end

function Inventory:getAll(): { [string]: number }
	return table.clone(self._items)
end

return Inventory
```

---

## 2. Build Operations

### Build Place File (Rojo)

```bash
export PATH="$HOME/.cargo/bin:$PATH"
rojo build default.project.json -o build/game.rbxl
```

**Output:** `build/game.rbxl` — binary Roblox place file ready for publishing or Studio testing.

### Live Sync (Rojo Serve)

```bash
rojo serve default.project.json
# Server at localhost:34872
# Studio plugin connects and auto-syncs file changes
```

### Rojo File Mapping

| Filesystem | Roblox Instance |
|-----------|----------------|
| `src/server/` | ServerScriptService |
| `src/client/` | StarterPlayerScripts |
| `src/shared/` | ReplicatedStorage |
| `*.server.lua` | Script |
| `*.client.lua` | LocalScript |
| `*.module.lua` | ModuleScript |
| `init.server.lua` | Script (folder default) |
| `*.meta.json` | Instance metadata override |

---

## 3. Publishing Operations

### Publish to Roblox

```bash
# Full pipeline: build + publish
bash tools/publish.sh

# Or step by step:
rojo build default.project.json -o build/game.rbxl
node tools/roblox-api.js publish
```

### API Operations via Node.js

```bash
node tools/roblox-api.js publish              # Upload new version
node tools/roblox-api.js get-place-info        # Place metadata
node tools/roblox-api.js list-versions         # Version history
node tools/roblox-api.js get-universe-info     # Universe metadata
node tools/roblox-api.js datastore-list        # List DataStores
node tools/roblox-api.js datastore-get <n> <k> # Read DataStore entry
node tools/roblox-api.js datastore-set <n> <k> <v>  # Write DataStore entry
```

### Direct curl (for custom operations)

```bash
# Load API key from .env
source .env

# Publish place
curl -X POST \
  "https://apis.roblox.com/universes/v1/${ROBLOX_UNIVERSE_ID}/places/${ROBLOX_PLACE_ID}/versions?versionType=Published" \
  -H "x-api-key: ${ROBLOX_OPEN_CLOUD_API_KEY}" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @build/game.rbxl

# Send message to live servers
curl -X POST \
  "https://apis.roblox.com/messaging-service/v1/universes/${ROBLOX_UNIVERSE_ID}/topics/MyTopic" \
  -H "x-api-key: ${ROBLOX_OPEN_CLOUD_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"message": "Server update incoming"}'
```

---

## 4. Linting & Formatting

### Lint Luau Code (Selene)

```bash
export PATH="$HOME/.cargo/bin:$PATH"
selene src/
```

Checks for: unused variables, shadowed locals, Roblox-specific antipatterns, type errors.
Config: `selene.toml` (std = "roblox")

### Format Luau Code (StyLua)

```bash
export PATH="$HOME/.cargo/bin:$PATH"

# Check formatting (dry-run)
stylua --check src/

# Auto-format
stylua src/
```

Config: `.stylua.toml` (tabs, 100 col, double quotes, sorted requires)

---

## 5. Version Control (Git/GitHub)

### Standard Operations

```bash
git status                              # Check changes
git add src/server/NewScript.server.lua # Stage specific files
git commit -m "feat: add new script"    # Commit
git push origin main                    # Push to GitHub
```

### GitHub CLI Operations

```bash
gh repo view                            # View repo info
gh pr create --title "feat: X"          # Create pull request
gh pr list                              # List open PRs
gh pr merge --squash                    # Merge PR
gh issue create --title "Bug: X"        # Create issue
gh issue list                           # List issues
gh release create v1.0.0                # Create release
```

### Branch Strategy

```
main                    # Stable, published
├── feature/name        # New features
├── fix/name            # Bug fixes
└── refactor/name       # Code improvements
```

### Commit Prefixes

```
feat:     New feature
fix:      Bug fix
refactor: Code restructuring
test:     Test additions
docs:     Documentation
```

---

## 6. MCP Server Operations (Studio Integration)

When the MCP server is connected to Roblox Studio, agents gain these additional capabilities:

### kevinswint MCP Server (Primary)

| Tool | What It Does | Use Case |
|------|-------------|----------|
| `write_script` | Create/update script source in Studio | Deploy code directly to Studio |
| `read_script` | Read existing script source | Inspect before modifying |
| `run_code` | Execute Luau in plugin context | Quick tests, workspace queries |
| `run_server_code` | Execute Luau in server context (playtest) | Test game logic, check state |
| `capture_screenshot` | Screenshot Studio viewport | Visual verification, debugging |
| `read_output` | Read Studio Output window | Check errors, print statements |
| `get_studio_state` | Check if edit/play/run mode | Determine safe operations |
| `start_playtest` | Begin F5 playtest | Automated testing |
| `start_simulation` | Begin F8 simulation | Physics-only testing |
| `stop_simulation` | Stop simulation | Return to edit mode |
| `simulate_input` | Send keyboard/mouse input | Automated gameplay testing |
| `click_gui` | Click UI elements | Automated UI testing |
| `move_character` | Teleport/walk character | Test movement, positions |
| `insert_model` | Insert marketplace model | Add assets to workspace |
| `search_assets` | Search marketplace | Find assets by query |
| `preview_asset` | Preview before inserting | Evaluate assets |
| `validate_ui` | Check UI for layout issues | Responsive design QA |
| `create_responsive_layout` | Create responsive ScreenGui | Quick UI scaffolding |
| `preview_layout` | Preview UI at viewport size | Mobile/tablet testing |

### MCP Server Binary Location

```
D:\projects\roblox\tools\roblox-studio-mcp\target\release\rbx-studio-mcp.exe
```

### DefinitelyNotJosh1 roblox-mcp (npm)

Installed globally. Offers 40+ tools including granular script editing:
- `edit_script_lines` — Edit specific line ranges
- `insert_script_lines` — Insert at specific line
- `delete_script_lines` — Remove specific lines
- `get_file_tree` — View project structure in Studio
- `get_project_structure` — Architecture analysis

---

## 7. Testing Operations

### Manual Testing (Studio)

```bash
# Build and open in Studio
rojo build -o build/game.rbxl
# Then open build/game.rbxl in Studio and press F5
```

### Automated Testing (TestEZ)

```lua
-- tests/Inventory.spec.lua
return function()
    local Inventory = require(game.ReplicatedStorage.Shared.Inventory)

    describe("Inventory", function()
        it("should add items", function()
            local inv = Inventory.new()
            inv:add("Sword", 1)
            expect(inv:getAll()["Sword"]).to.equal(1)
        end)
    end)
end
```

### MCP-Assisted Testing (Autonomous)

```
1. Agent writes script via write_script
2. Agent starts playtest via start_playtest
3. Agent reads output via read_output (errors/prints)
4. Agent captures screenshot via capture_screenshot (visual state)
5. Agent analyzes results and iterates
6. Loop until passing
```

---

## 8. Project Configuration Files

| File | Purpose | Agent Access |
|------|---------|-------------|
| `default.project.json` | Rojo filesystem-to-Studio mapping | Read/Write |
| `.env` | API keys and credentials (GITIGNORED) | Read only (never commit) |
| `CLAUDE.md` | AI coding conventions | Read (follow always) |
| `selene.toml` | Linter configuration | Read/Write |
| `.stylua.toml` | Formatter configuration | Read/Write |
| `.vscode/settings.json` | Editor settings | Read/Write |
| `.vscode/extensions.json` | Recommended extensions | Read/Write |
| `.gitignore` | Files excluded from Git | Read/Write |

---

## 9. Full Autonomous Workflow

This is the end-to-end process an agent follows to build and deploy a Roblox game:

```
┌─────────────────────────────────────────────────────────┐
│ 1. PLAN                                                  │
│    Read CLAUDE.md, design_principles/, requirements      │
│    Define game structure, modules, data models           │
├─────────────────────────────────────────────────────────┤
│ 2. CODE                                                  │
│    Write .server.lua, .client.lua, .module.lua files     │
│    Follow Luau Style Guide conventions                   │
│    Type annotations, error handling, :Disconnect()       │
├─────────────────────────────────────────────────────────┤
│ 3. LINT & FORMAT                                         │
│    selene src/          (catch bugs)                     │
│    stylua src/          (consistent formatting)          │
├─────────────────────────────────────────────────────────┤
│ 4. BUILD                                                 │
│    rojo build -o build/game.rbxl                         │
├─────────────────────────────────────────────────────────┤
│ 5. TEST (if MCP connected)                               │
│    write_script → start_playtest → read_output           │
│    capture_screenshot → analyze → iterate                │
├─────────────────────────────────────────────────────────┤
│ 6. COMMIT                                                │
│    git add <specific files>                              │
│    git commit -m "feat: description"                     │
│    git push origin main                                  │
├─────────────────────────────────────────────────────────┤
│ 7. PUBLISH                                               │
│    bash tools/publish.sh                                 │
│    (reads .env, builds, uploads to Roblox)               │
├─────────────────────────────────────────────────────────┤
│ 8. VERIFY                                                │
│    node tools/roblox-api.js list-versions                │
│    Confirm new version appears                           │
└─────────────────────────────────────────────────────────┘
```

---

## 10. Security Rules for Agents

1. **NEVER** commit `.env` or any file containing API keys
2. **NEVER** echo, print, or log API keys in output
3. **NEVER** hardcode credentials in source files
4. **ALWAYS** use `source .env` or the Node.js loader to read keys
5. **ALWAYS** check `.gitignore` before committing new file types
6. **ALWAYS** validate server-side — never trust client data in game code
7. **Server is authority** — all game state changes must be server-validated
8. Rate limit RemoteEvent handlers to prevent exploit abuse

---

## 11. Key Reference Documents

| Document | Path | Read When |
|----------|------|-----------|
| AI Conventions | `CLAUDE.md` | Always (coding standards) |
| Master Reference | `MASTER_REFERENCE.md` | Project overview |
| Project Structure | `PROJECT_STRUCTURE.md` | Architecture decisions |
| Development Workflow | `DEVELOPMENT_WORKFLOW.md` | Step-by-step processes |
| Toolchain Setup | `TOOLCHAIN_SETUP.md` | Tool versions, troubleshooting |
| Publishing Guide | `PUBLISHING_GUIDE.md` | Deploy pipeline |
| Luau Style Guide | `design_principles/Luau_Style_Guide.md` | Code formatting rules |
| Planning Process | `design_principles/planning_development_process.md` | Design principles |
| UI Framework | `design_principles/roact_ui_library.md` | react-lua/Roact patterns |
| AI Integration | `local_ai_and_roblox/claude_integration_to_roblox.md` | Rojo, MCP, AI workflow |
