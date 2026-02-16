# Toolchain Setup Guide

> Installation, configuration, and troubleshooting for the Roblox AI development environment.

---

## Prerequisites

| Requirement | Details |
|-------------|---------|
| **OS** | Windows 11 Pro (admin privileges required) |
| **Roblox Studio** | v0.600+ from roblox.com |
| **VS Code** | Latest from code.visualstudio.com |
| **Git** | From git-scm.com or `winget install Git.Git` |
| **Node.js** | LTS from nodejs.org (for AI wrapper scripts) |
| **Rust/Cargo** | From rustup.rs (for Rojo CLI installation) |
| **GitHub CLI** | `winget install GitHub.cli` |
| **Roblox Account** | Developer account with Open Cloud API access |
| **AI API Key** | Claude/OpenAI/Grok API key (set as env variable) |

---

## 1. Rojo v7 Setup

### Install Rojo CLI

```bash
# Option A: Via Cargo (requires Rust)
cargo install rojo

# Option B: Via VS Code Extension (recommended)
# Extensions > Search "Rojo - Roblox Studio Sync" > Install
```

### Install Rojo Studio Plugin

1. Open Roblox Studio
2. Plugins tab > Manage Plugins > Search "Rojo"
3. Install the official Rojo plugin

### Initialize Project

```bash
cd D:\projects\roblox
rojo init .
```

This creates `default.project.json`. Edit to match project structure:

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

### Start Sync Server

```bash
rojo serve default.project.json
# Server runs at localhost:34872
```

### Connect in Studio

1. Open `build.rbxlx` in Studio
2. Plugins > Rojo > Connect
3. Enter `localhost:34872`
4. Verify "Connected" status

---

## 2. VS Code Setup

### Required Extensions

| Extension | ID | Purpose |
|-----------|-----|---------|
| Lua Language Server | `sumneko.lua` | LSP, IntelliSense, type checking |
| Rojo | `evaera.vscode-rojo` | Integrated Rojo serve/sync |
| Roblox Lua | Various | Syntax highlighting for Luau |

### Workspace Settings

Create `.vscode/settings.json`:

```json
{
  "Lua.runtime.version": "Lua 5.1",
  "Lua.diagnostics.globals": [
    "game", "script", "workspace", "plugin",
    "Instance", "Vector3", "CFrame", "Color3",
    "UDim2", "UDim", "Enum", "task", "typeof",
    "setmetatable", "getmetatable", "newproxy",
    "shared", "require"
  ],
  "Lua.workspace.library": [],
  "files.associations": {
    "*.lua": "lua"
  }
}
```

---

## 3. Git & GitHub Setup

### Initial Repository Setup

```bash
cd D:\projects\roblox
git init
git remote add origin https://github.com/MensuraMedia/roblox-game.git
```

### GitHub CLI Authentication

```bash
gh auth login
# Follow prompts: GitHub.com > HTTPS > Browser authentication
gh auth status  # Verify: "Logged in to github.com"
```

### Verify Access

```bash
gh repo view MensuraMedia/roblox-game
```

---

## 4. AI Service Integration

### Environment Variables

Set API keys as Windows environment variables (run as admin):

```cmd
setx AI_API_KEY "your-api-key-here"
setx OPENAI_API_KEY "your-openai-key"
```

Restart terminal for changes to take effect.

### AI Script Generator (Node.js)

Create `tools/ai_generate.js`:

```javascript
const fs = require('fs');
const axios = require('axios');
const prompt = process.argv[2];

axios.post('https://api.groq.com/openai/v1/chat/completions', {
  model: 'mixtral-8x7b-32768',
  messages: [{ role: 'user', content: `Generate Roblox Luau script: ${prompt}` }]
}, {
  headers: { Authorization: `Bearer ${process.env.AI_API_KEY}` }
}).then(response => {
  const luaCode = response.data.choices[0].message.content;
  fs.writeFileSync('src/server/generated.server.lua', luaCode);
  console.log('Script generated and saved.');
});
```

```bash
npm init -y && npm install axios
node tools/ai_generate.js "Generate NPC patrol AI"
```

---

## 5. MCP Server Setup

### Option 1: kevinswint/roblox-studio-rust-mcp-server (Recommended)

Best for autonomous debugging with Claude Code.

```bash
# Clone the repository
git clone https://github.com/kevinswint/roblox-studio-rust-mcp-server.git

# Build (requires Rust)
cd roblox-studio-rust-mcp-server
cargo build --release

# Configure in Claude Code MCP settings
# Add to .claude/mcp.json or equivalent config
```

**Key Tools:** `write_script`, `capture_screenshot`, `read_output`, playtest controls

### Option 2: DefinitelyNotJosh1/roblox-mcp

Best for granular script editing (40+ tools).

```bash
npm install -g roblox-mcp
# Or clone: git clone https://github.com/DefinitelyNotJosh1/roblox-mcp.git
```

**Key Tools:** `edit_script_lines`, `insert_script_lines`, `delete_script_lines`, `get_file_tree`

### Option 3: dax8it/roblox-mcp (Vibe Blocks)

Best for live Luau execution + Open Cloud.

```bash
git clone https://github.com/dax8it/roblox-mcp.git
cd roblox-mcp
pip install -r requirements.txt
```

**Key Tools:** Execute arbitrary Luau in live Studio, DataStore management, asset upload

---

## 6. Testing Framework (TestEZ)

### Install TestEZ

1. Download from [Roblox TestEZ GitHub](https://github.com/Roblox/testez)
2. Place in `tests/` folder
3. Configure in Rojo project:

```json
{
  "TestService": {
    "$path": "tests"
  }
}
```

### Example Test

```lua
-- tests/Inventory.spec.lua
return function()
    local Inventory = require(game.ReplicatedStorage.Shared.Inventory)

    describe("Inventory", function()
        it("should add items", function()
            local inv = Inventory.new()
            inv:add("Sword")
            expect(inv:getAll()).to.be.ok()
        end)

        it("should remove items", function()
            local inv = Inventory.new()
            inv:add("Shield")
            inv:remove("Shield")
            expect(#inv:getAll()).to.equal(0)
        end)
    end)
end
```

---

## 7. Windows Firewall Configuration

Allow outbound HTTPS for AI APIs:

```powershell
# Run PowerShell as admin
New-NetFirewallRule -DisplayName "Allow AI API HTTPS" `
  -Direction Outbound -Protocol TCP -RemotePort 443 `
  -Action Allow
```

Allow Rojo sync (localhost):

```powershell
New-NetFirewallRule -DisplayName "Allow Rojo Sync" `
  -Direction Inbound -Protocol TCP -LocalPort 34872 `
  -Action Allow
```

---

## 8. Troubleshooting

| Issue | Solution |
|-------|----------|
| Rojo port conflict | Use `rojo serve --port 34873` |
| Rojo sync fails | Disconnect plugin, reconnect; check firewall |
| VS Code Lua LSP not working | Verify `sumneko.lua` extension installed; check settings.json |
| Git push denied | Run `gh auth login` to refresh token |
| Studio permissions error | Run VS Code and Studio as administrator |
| Rojo not found | Add `%USERPROFILE%\.cargo\bin` to PATH |
| AI API timeout | Check internet connection; verify API key in env vars |
| Studio Plugin missing | Plugins > Manage Plugins > Reinstall Rojo |
| Build file corrupted | Delete `build/` folder, run `rojo build` again |
| File watcher lag | Restart `rojo serve`; close other file-watching tools |

---

## 9. Useful Aliases

Add to PowerShell profile (`$PROFILE`):

```powershell
function Start-Rojo { rojo serve "D:\projects\roblox\default.project.json" }
function Build-Rojo { rojo build "D:\projects\roblox\default.project.json" -o "D:\projects\roblox\build\game.rbxlx" }
function Open-Project { code "D:\projects\roblox" }

Set-Alias rserve Start-Rojo
Set-Alias rbuild Build-Rojo
Set-Alias rcode Open-Project
```
