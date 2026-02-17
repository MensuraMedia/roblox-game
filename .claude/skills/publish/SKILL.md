---
name: publish
description: Build and publish the Deck 22 game to Roblox via Open Cloud API. Runs the full test-build pipeline first, then publishes.
---

# Publish to Roblox

Publish the Deck 22 experience to Roblox. This runs the full validation pipeline before publishing.

## Pre-Publish Validation

First, run the `/test-build` skill to ensure the project is clean:
1. Build with Rojo
2. Lint with Selene
3. Format check with StyLua

Only proceed to publish if the build succeeds.

## Publish

Run the publish script:

```bash
bash D:/projects/roblox/tools/publish.sh
```

If the publish fails with HTTP 409 (server busy), wait 30 seconds and retry up to 3 times.

If the publish fails with HTTP 401 (invalid API key), inform the user that their API key in `.env` may need to be regenerated from the Roblox Creator Dashboard.

## Verify

After successful publish, verify the version:

```bash
node D:/projects/roblox/tools/roblox-api.js list-versions
```

Report the new version number and timestamp.

## Results

| Step | Status | Details |
|------|--------|---------|
| Build | PASS/FAIL | File size |
| Lint | PASS/WARN/FAIL | Issues |
| Publish | PASS/FAIL | Version number or error |
| Verify | PASS/FAIL | Version confirmed |
