What is the Luau Style Guide?
The Luau Style Guide (also referred to as the Roblox Lua Style Guide) is Roblox's official set of conventions for writing clean, consistent, and readable Lua code in Luau, Roblox's enhanced version of Lua 5.1. It promotes uniformity across teams, optimizes for readability (since code is read more than written), ensures clean diffs in version control, and encourages safe use of Lua's advanced features like metatables.
Modeled after Google's C++ Style Guide but tailored for Lua/Luau, it applies to Roblox scripting and focuses on practical rules rather than rigid enforcement. The guide is a single, self-contained page with no recent major updates noted as of early 2026 (Luau has seen type solver improvements, but not style changes).
Guiding Principles
These foundational ideas underpin the guide:

Agree on one standard to avoid debates.
Prioritize reading over writing.
Minimize diff noise for easier reviews.
Use features judiciously (e.g., avoid "magic" like unchecked metatables).
Be idiomatic to Lua/Luau where it fits.

Key Sections and Rules
The guide is organized into logical sections. Below is a structured breakdown with rules, explanations, and examples.
1. File Structure
Files follow a strict order:

Optional block comment (purpose only; no file/author/date).
game:GetService() calls.
require statements.
Constants.
Variables/functions.
Returned object.
return statement.

2. Requires (require Statements)

All at the top, sorted alphabetically by module name.
Group into blocks: common ancestor → packages → derived → project modules (subfolders alphabetical).
Consumers require the API table, not internals.

Example Lua:

local MyProject = script.Parent

local Baz = require(MyProject.Packages.Baz)
local Bazifyer = Baz.Bazifyer

local FooBar = MyProject.FooBar
local Foo = require(FooBar.Foo)
```<grok-card data-id="817012" data-type="citation_card" data-plain-type="render_inline_citation" ></grok-card>

#### 3. Metatables
Limited use:
- **Classes**: `__index` to self, `new()` constructor, dot for definition, colon for calls, type annotations.
- **Enums**: `__index` to error on invalid keys.

**Class Example:**
```lua
local MyClass = {}
MyClass.__index = MyClass

export type ClassType = typeof(setmetatable({ property: number }, MyClass))

function MyClass.new(property: number): ClassType
    local self = { property = property }
    setmetatable(self, MyClass)
    return self
end
```<grok-card data-id="a3fc6e" data-type="citation_card" data-plain-type="render_inline_citation" ></grok-card>

#### 4. Naming Conventions
| Convention | Style | Examples |
|------------|-------|----------|
| Classes/Enums/Roblox APIs | **PascalCase** | `MyClass`, `TweenService` |
| Variables/Members/Functions | **camelCase** | `myVariable`, `doSomething()` |
| Constants | **LOUD_SNAKE_CASE** | `MAX_PLAYERS` |
| Private Members | `_camelCase` | `_internalState` |
| Acronyms | Lowercase (unless set) | `anRGBValue` |
| Files | Match export | `doSomething.lua` |

- Spell out words; no abbreviations.<grok-card data-id="4c91b3" data-type="citation_card" data-plain-type="render_inline_citation" ></grok-card>

#### 5. Whitespace and Punctuation
- **Tabs** for indent (4-space width).
- **Line limits**: 100 chars (code), 80 (comments).
- No trailing whitespace/newlines at EOF.
- Spaces: Around operators/commas; no vertical alignment.
- **Trailing commas** in multi-line tables.
- One statement/line; functions on new lines.
- **No semicolons**.

**Example:**
```lua
local friends = { "bob", "amy", "joe", }
foo(5, 6, 7)
```<grok-card data-id="265bd8" data-type="citation_card" data-plain-type="render_inline_citation" ></grok-card>

#### 6. Tables and Literals
- Double quotes for strings (single only for embedded doubles).
- `ipairs` for arrays, `pairs` for dicts.
- Trailing commas in multi-line.

#### 7. Functions
- Low arg count (1-2 ideal).
- Always parentheses on calls.
- Local non-members; dot for static, colon for instance.

#### 8. Control Flow (if/Blocks/Newlines)
- Prefer `if ... then ... else` over `and/or`.
- No parens on conditions.
- Break long exprs at operators (operator at line start).
- `do` for scope limiting.

**if Example:**
```lua
local scale = if useNewScale then 1 else 2

```

9. Comments

-- inline, --[[ ]] blocks/docs.
Explain why, not what.
80 cols; no section comments (refactor instead).

10. Yielding and Errors

No yielding on main thread (use coroutines/task).
Errors: success, result tuples; assert preconditions; pcall wrappers.

Error Example Lua:
local success, result = thisCanFail(value)
if not success then
    -- Handle
end
```<grok-card data-id="93695a" data-type="citation_card" data-plain-type="render_inline_citation" ></grok-card>

#### Roblox-Specific
- `game:GetService()` for services.
- Module var = module name.

### Why Follow It?
Consistency speeds up onboarding, reviews, and maintenance. Roblox uses it internally (e.g., in core APIs). Tools like Rojo and Luau LSP enforce it via linters.<grok-card data-id="581f8b" data-type="citation_card" data-plain-type="render_inline_citation" ></grok-card><grok-card data-id="a0a487" data-type="citation_card" data-plain-type="render_inline_citation" ></grok-card>

For the full guide: [roblox.github.io/lua-style-guide/](https://roblox.github.io/lua-style-guide/).
```

Direct Link References:

Table:
Context,Link
"Publishing and Monitoring (metadata/analytics, unique icons/descriptions, retention/monetization KPIs, post-launch iteration)",https://create.roblox.com/docs/production/publishing/publish-experiences-and-places
"Planning, iteration, reuse code/assets, player enjoyment, organization (ServerScriptService/ReplicatedStorage), intuitive feedback, building/style, summary principles (thorough planning before coding, iterate/test early/often, YAGNI/DRY partially overlaps here)",https://devforum.roblox.com/t/best-practices-handbook/2593598
"UI/UX Design (scale vs offset, UDim2, Emulator testing, AnchorPoint mastery, responsive/mobile-first, safe areas, top bar/notches)","https://create.roblox.com/docs/production/game-design/ui-ux-design (Note: If not an exact match, closely related to general UI docs at https://create.roblox.com/docs/ui)"
"Planning (YAGNI/DRY), naming/style (camelCase/PascalCase, descriptive names), modularization (ModuleScripts, frameworks like Knit), Luau features (task.wait, guard clauses, types), connections/memory management (:Disconnect, task.defer), organization",https://roblox.github.io/lua-style-guide
"Naming and style (Roblox Lua Style Guide reference, consistent conventions)",https://roblox.github.io/lua-style-guide
"Performance (monitoring with Developer Console, Microprofiler, Luau Heap, PlaceMemory/PlaceScriptMemory, identifying issues)",https://create.roblox.com/docs/performance-optimization/identify
"Security and Anti-Cheat (server authority, never trust client, validate inputs/actions, secure remotes, threat modeling, minimize replicated state)",https://devforum.roblox.com/t/creating-proper-anti-exploits-the-ultimate-guide/2172882
"Building and Art (performance-friendly: minimize parts, reuse meshes, low poly, plugins like F3X, general optimization)",https://devforum.roblox.com/t/the-hitchhikers-guide-to-optimization-optimize-your-game-using-just-one-post-instead-of-many/3358345
"Building and Art (topology optimization, non-destructive sculpting, edge flow, preserve facial regions/eyelids/animation compatibility)",https://create.roblox.com/docs/art/characters/creating/modeling-best-practices
"Performance (memory optimization, Luau Heap snapshots, Developer Console metrics, PlaceMemory breakdown)",https://create.roblox.com/docs/studio/optimization/memory-usage
"Performance (scripting: task.wait, RunService limits, multithreading/parallel Luau, native code gen; physics: anchor static parts, CollisionFidelity low; rendering: reuse meshes/textures, culling, shadows disable, instancing; networking: minimal replication/on-change, client tweens/VFX; assets: low-res textures ≤512x512, preloading, trim sheets, ContentProvider)",https://create.roblox.com/docs/performance-optimization/improve