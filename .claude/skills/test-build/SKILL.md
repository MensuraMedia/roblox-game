---
name: test-build
description: Build, lint, format-check, and prepare for Studio testing. Run this before committing or publishing to validate the full Roblox development pipeline.
---

# Test Build Workflow

Execute the full validation pipeline for the Deck 22 Roblox project. Run each step in sequence. Report results clearly after each step.

## Important: PATH Setup

All commands require cargo tools on PATH. Prefix every bash command with:

```bash
export PATH="$HOME/.cargo/bin:$PATH"
```

Or combine it with the command using `&&`.

## Step 1: Build with Rojo

Build the Rojo project into a Studio-ready `.rbxl` file:

```bash
export PATH="$HOME/.cargo/bin:$PATH" && rojo build D:/projects/roblox/default.project.json -o D:/projects/roblox/build/game.rbxl
```

Report the file size on success. If the build fails, show the error and stop.

## Step 2: Lint with Selene

Run the Luau linter across all source files:

```bash
selene D:/projects/roblox/src/
```

Report the count of errors and warnings. Errors are blockers; warnings are informational.
If there are errors, list them and suggest fixes.

## Step 3: Format Check with StyLua

Check code formatting without modifying files:

```bash
stylua --check D:/projects/roblox/src/
```

If the check fails, report which files need formatting and suggest running `stylua D:/projects/roblox/src/` to auto-fix.

**Note:** StyLua 2.3.1 may fail on Luau type annotations. If it exits with parse errors on type-annotated files, report this as a known limitation (not a real formatting issue) and mark the step as passed with a caveat.

## Step 4: Studio Test Readiness

After steps 1-3 pass, report the test readiness summary:

1. Confirm `build/game.rbxl` exists and show its file size
2. Provide instructions to test in Roblox Studio:
   - **Option A (direct):** Open `D:\projects\roblox\build\game.rbxl` in Roblox Studio and press F5 to Play
   - **Option B (live sync):** Run `rojo serve D:/projects/roblox/default.project.json` then connect via the Rojo plugin in Studio

3. Provide the Studio test checklist:
   - [ ] Walk through all zones (no geometry gaps)
   - [ ] Fall into acid pit (character takes damage and dies)
   - [ ] Step on jump pads (character launches correctly)
   - [ ] Weapons spawn and can be collected
   - [ ] Firing weapons works (hit markers appear)
   - [ ] Pickups spawn and restore health/armor
   - [ ] HUD displays health, armor, score, timer
   - [ ] Kill feed shows kills
   - [ ] Round timer counts down
   - [ ] Score increments on kills

## Results Summary

Present a final summary table:

| Step | Status | Details |
|------|--------|---------|
| Build | PASS/FAIL | File size or error |
| Lint | PASS/WARN/FAIL | Error/warning count |
| Format | PASS/FAIL/SKIP | Issues or known limitation |
| Studio Ready | YES/NO | Path to .rbxl file |
