# Development Workflow

> Step-by-step processes for building, testing, and deploying Roblox games with AI assistance.

---

## 1. Standard Development Cycle

### Phase 1: Planning

- [ ] Define game concept (genre, mechanics, target audience)
- [ ] Outline game structure (levels, story, progression)
- [ ] Sketch UI layouts (mobile-first, responsive)
- [ ] Plan data models (player data, inventories, leaderboards)
- [ ] Identify reusable modules from past projects
- [ ] Set up Rojo project structure

### Phase 2: Development

```
1. Write Luau in VS Code (following Luau Style Guide)
2. Rojo auto-syncs to Studio on save
3. Playtest in Studio (F5 or Play button)
4. Review Developer Console for errors
5. Fix issues, repeat
6. Git commit when feature is stable
```

### Phase 3: Testing

- [ ] Unit test with TestEZ for core modules
- [ ] Playtest on PC and mobile via Studio Emulator
- [ ] Stress test with multiple players (Studio local server)
- [ ] Check performance via Microprofiler
- [ ] Verify memory usage isn't growing (Luau Heap)
- [ ] Test edge cases for security (remote validation)

### Phase 4: Polish & Publish

- [ ] Optimize textures (<= 512x512)
- [ ] Add game icons, descriptions, metadata
- [ ] Configure instance streaming
- [ ] Final playtest pass
- [ ] Publish via Studio or Roblox API
- [ ] Monitor analytics post-launch
- [ ] Iterate based on engagement data

---

## 2. AI-Assisted Development Workflow

### Prompting for Code Generation

```
1. Describe what you need clearly
   Example: "Generate a Luau ModuleScript for an inventory system
   with add, remove, and getAll functions"

2. AI generates code following project conventions
3. Code is written to src/shared/Inventory.module.lua
4. Rojo syncs automatically to Studio
5. Playtest to verify behavior
6. AI reads console output / screenshots for debugging
7. AI iterates until working correctly
8. Git commit the stable version
```

### AI Debugging Loop (with MCP Server)

```
Claude Code ──write_script──► Roblox Studio
     │                              │
     │◄──read_output────────────────┘  (console errors/prints)
     │◄──capture_screenshot─────────┘  (visual state)
     │
     ▼
  Analyze → Fix → Write Again → Repeat until resolved
```

### Best Practices for AI Prompts

- Reference the Luau Style Guide conventions
- Specify server vs client context
- Include type annotations in requests
- Ask for error handling patterns (success/result tuples)
- Request TestEZ tests alongside implementation

---

## 3. Git Workflow

### Branch Strategy

```
main                    # Stable, published version
├── develop             # Integration branch
│   ├── feature/name    # New features
│   ├── fix/name        # Bug fixes
│   └── refactor/name   # Code improvements
```

### Commit Conventions

```
feat: add inventory system with DataStore persistence
fix: correct remote event validation for currency
refactor: extract player data module from main server script
test: add TestEZ specs for combat module
docs: update development workflow documentation
```

### Standard Commands

```bash
# Check status
git status
git diff

# Feature workflow
git checkout -b feature/inventory-system
# ... make changes ...
git add src/shared/Inventory.module.lua
git commit -m "feat: add inventory system with add/remove/getAll"
git push -u origin feature/inventory-system

# Create PR via GitHub CLI
gh pr create --title "feat: inventory system" --body "Adds inventory module"

# Merge after review
gh pr merge --squash
```

---

## 4. Rojo Sync Workflow

### Starting a Dev Session

```bash
# Terminal 1: Start Rojo sync server
cd D:\projects\roblox
rojo serve default.project.json

# Terminal 2: Open VS Code
code .
```

Then in Roblox Studio:
1. Open `build.rbxlx` (File > Open from File)
2. Plugins > Rojo > Connect to `localhost:34872`
3. Status should show "Connected"

### During Development

- Save `.lua` files in VS Code → Instant sync to Studio
- Playtest in Studio → Changes hot-reload
- Use "Sync Selection to Disk" for pulling Studio-only changes back

### Ending a Session

1. Stop playtest in Studio
2. Disconnect Rojo plugin
3. Git commit changes
4. Stop `rojo serve` (Ctrl+C)

---

## 5. Rojo Build Commands

| Command | Purpose |
|---------|---------|
| `rojo serve` | Start live sync server on localhost:34872 |
| `rojo serve --port 34873` | Use alternate port (if 34872 is busy) |
| `rojo build -o build/game.rbxlx` | Build place file for publishing |
| `rojo build -o build/model.rbxm` | Build model file for asset export |
| `rojo init .` | Initialize new Rojo project in current folder |

---

## 6. Testing Checklist

### Code Quality

- [ ] All services accessed via `game:GetService()`
- [ ] No `wait()` - using `task.wait()` instead
- [ ] All event connections stored and `:Disconnect()`-ed on cleanup
- [ ] Type annotations on function signatures
- [ ] Guard clauses instead of deep nesting
- [ ] No client-side authority over game state

### Performance

- [ ] Static parts are Anchored
- [ ] CollisionFidelity set to Box/Hull where possible
- [ ] Textures <= 512x512
- [ ] Meshes/textures reused (GPU instancing)
- [ ] Heavy loops broken with `task.wait()`
- [ ] Client-side tweens for visual effects
- [ ] Instance streaming enabled

### Security

- [ ] Server validates all RemoteEvent inputs
- [ ] Distance checks on interactions
- [ ] Currency/item ownership verified server-side
- [ ] Rate limiting on remote calls
- [ ] Sensitive data in ServerStorage only
- [ ] No exploitable state replicated to clients

### UI/UX

- [ ] UDim2 scale-based sizing (not offset)
- [ ] AnchorPoint set correctly (0.5, 0.5 for centered)
- [ ] Tested on mobile via Studio Emulator
- [ ] Top bar safe area respected (58px)
- [ ] UIAspectRatioConstraint where needed
- [ ] Responsive across all device sizes

---

## 7. Performance Monitoring

### Developer Console (F9 in Studio)

| Tab | What to Check |
|-----|---------------|
| Log | Errors, warnings, print output |
| Memory | PlaceMemory, LuaHeap growth |
| Network | Replication data volume |
| Scripts | Script performance stats |

### Microprofiler (Ctrl+F6)

- Frame time breakdown (compute, physics, rendering)
- Identify bottleneck scripts
- Spot expensive RunService connections

### Luau Heap Snapshots

- Take snapshots before and after actions
- Compare to find memory leaks
- Track table/closure growth

---

## 8. Publishing Workflow

```bash
# 1. Build the place file
rojo build -o build/game.rbxlx

# 2. Test the built file in Studio
#    File > Open from File > build/game.rbxlx

# 3. Publish from Studio
#    File > Publish to Roblox

# 4. Or publish via Roblox Open Cloud API (automated)
#    curl -X POST https://apis.roblox.com/universes/v1/...
```

### Pre-Publish Checklist

- [ ] All features tested and working
- [ ] Performance acceptable on target devices
- [ ] Security validation complete
- [ ] Game icon and metadata set
- [ ] Description and tags configured
- [ ] Git tagged with version number
