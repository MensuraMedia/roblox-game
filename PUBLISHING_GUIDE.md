# Publishing Guide - Programmatic Roblox Deployment

> Complete guide for building, publishing, and managing Roblox games via command line and API.

---

## Quick Reference

```bash
# Build only (no publish)
bash tools/publish.sh --build-only

# Build and publish to Roblox
bash tools/publish.sh

# API operations
node tools/roblox-api.js publish
node tools/roblox-api.js get-place-info
node tools/roblox-api.js list-versions
node tools/roblox-api.js datastore-list
node tools/roblox-api.js datastore-get <store> <key>
node tools/roblox-api.js datastore-set <store> <key> <json>
```

---

## Prerequisites

### Credentials (stored in `.env`, gitignored)

| Variable | Description | How to Get |
|----------|-------------|------------|
| `ROBLOX_OPEN_CLOUD_API_KEY` | Open Cloud API key | [creator.roblox.com/credentials](https://creator.roblox.com/credentials) |
| `ROBLOX_UNIVERSE_ID` | Your game's universe ID | Creator Dashboard → Game → Settings → Basic Info |
| `ROBLOX_PLACE_ID` | Your game's starting place ID | Creator Dashboard → Game → Places |
| `ROBLOX_USER_ID` | Your Roblox user ID | `10484973275` (Mensura222) |
| `ROBLOX_EXPERIENCE_NAME` | Current experience name | `Deck 22` |

### API Key Permissions Required

When creating the Open Cloud API key at creator.roblox.com, grant these permissions:

| Permission | Scope | Operations Enabled |
|-----------|-------|-------------------|
| **Place** | Universe-level | Publish, update place versions |
| **DataStore** | Universe-level | Read/write DataStore entries |
| **Messaging** | Universe-level | Send messages to live servers |
| **Assets** | User-level | Upload assets (images, models) |

### IP Restrictions

Set the API key IP restriction to `0.0.0.0/0` for development, or lock to your machine's IP for production.

---

## Publishing Pipeline

### Step 1: Write Game Code

```
src/
├── server/*.server.lua    → ServerScriptService
├── client/*.client.lua    → StarterPlayerScripts
└── shared/*.module.lua    → ReplicatedStorage
```

All code follows the conventions in `CLAUDE.md` and `design_principles/Luau_Style_Guide.md`.

### Step 2: Build with Rojo

```bash
export PATH="$HOME/.cargo/bin:$PATH"
rojo build default.project.json -o build/game.rbxl
```

This compiles the filesystem project into a binary `.rbxl` place file.

### Step 3: Publish via Open Cloud API

```bash
# Using the publish script (recommended)
bash tools/publish.sh

# Or using the Node.js helper
node tools/roblox-api.js publish

# Or manually via curl
curl -X POST \
  "https://apis.roblox.com/universes/v1/${UNIVERSE_ID}/places/${PLACE_ID}/versions?versionType=Published" \
  -H "x-api-key: ${API_KEY}" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @build/game.rbxl
```

### Step 4: Verify

```bash
node tools/roblox-api.js list-versions
# Shows version history with timestamps
```

---

## First-Time Setup: Creating a New Game

The Open Cloud API **cannot create new universes/places** — this must be done once in Studio or the Creator Dashboard:

1. Open Roblox Studio → File → New
2. File → Publish to Roblox → Create new game
3. Note the **Universe ID** and **Place ID** from the Creator Dashboard
4. Add them to `.env`:
   ```
   ROBLOX_UNIVERSE_ID=123456789
   ROBLOX_PLACE_ID=987654321
   ```
5. From now on, all updates can be pushed programmatically

---

## Available API Operations

### Publishing

| Operation | Command | Description |
|-----------|---------|-------------|
| Publish game | `node tools/roblox-api.js publish` | Upload `.rbxl` as new published version |
| Get place info | `node tools/roblox-api.js get-place-info` | Retrieve place metadata |
| List versions | `node tools/roblox-api.js list-versions` | Show last 10 published versions |
| Get universe info | `node tools/roblox-api.js get-universe-info` | Retrieve universe metadata |

### DataStores (Player Data)

| Operation | Command | Description |
|-----------|---------|-------------|
| List DataStores | `node tools/roblox-api.js datastore-list` | List all DataStores in universe |
| Get entry | `node tools/roblox-api.js datastore-get <store> <key>` | Read a DataStore entry |
| Set entry | `node tools/roblox-api.js datastore-set <store> <key> <json>` | Write a DataStore entry |

### Open Cloud API Endpoints Reference

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/universes/v1/{uid}/places/{pid}/versions` | POST | Publish place |
| `/universes/v1/{uid}/places/{pid}/versions` | GET | List versions |
| `/universes/v1/{uid}/places/{pid}` | GET/PATCH | Place metadata |
| `/universes/v1/{uid}` | GET | Universe metadata |
| `/datastores/v1/universes/{uid}/standard-datastores` | GET | List DataStores |
| `/datastores/v1/universes/{uid}/.../entries/entry` | GET/POST | DataStore CRUD |
| `/messaging-service/v1/universes/{uid}/topics/{topic}` | POST | Send live message |

---

## Security Rules

1. **API key lives ONLY in `.env`** — this file is gitignored and never committed
2. **Never hardcode keys** in scripts, docs, or source files
3. **Never echo/log the key** — scripts read it silently
4. **Rotate keys** if they are ever exposed (chat, logs, screenshots)
5. **Restrict IP** on production API keys at creator.roblox.com
6. **Use separate keys** for dev vs production if managing multiple games

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| HTTP 401 | Invalid or expired API key | Regenerate at creator.roblox.com/credentials |
| HTTP 403 | Key lacks required permissions | Edit key permissions (Place, DataStore, etc.) |
| HTTP 404 | Wrong Universe/Place ID | Verify IDs in Creator Dashboard |
| HTTP 429 | Rate limited | Wait and retry (60 requests/min for publish) |
| HTTP 500 | Roblox server error | Retry after a few minutes |
| "Build file not found" | Rojo build not run | Run `rojo build -o build/game.rbxl` first |
| ".env not found" | Missing config file | Create `.env` with required variables |
