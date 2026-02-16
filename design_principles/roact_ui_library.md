Roact is Roblox's original declarative UI library inspired by React, allowing you to build UIs purely in code with components, state, props, and reconciliation (efficient updates). It uses Roact.createElement to describe trees of Roblox GUI instances (e.g., Frames, Buttons), which are mounted into PlayerGui or elsewhere.
Important: Roact is deprecated/archived (last release Aug 2022) and no longer maintained. Use react-lua (official successor, Roact-compatible with hooks like useState) for new projects. Examples below use Roact syntax (works in react-lua by swapping Roact → React).
Installation

Download Roact.rbxm from GitHub releases.
Insert into ReplicatedStorage (Roact folder appears).
Use in LocalScript (e.g., StarterPlayer > StarterPlayerScripts).

Core Principles for Responsive Menus

Table:
Feature,Roact Implementation,Responsive Benefit
Scaling,"UDim2.fromScale(0.75, 0.6) for Size/Position",Adapts to screen size (PC/mobile).
Anchoring,"AnchorPoint = Vector2.new(0.5, 0.5)",Centers reliably.
Layouts,"UIListLayout, UIGridLayout as children",Auto-arrange buttons/lists.
State/Bindings,"self:setState, Roact.createBinding","Toggle open/close, dynamic content."
Constraints,UIAspectRatioConstraint child,Maintains proportions.

Test in Studio Emulator.
Example 1: Basic Responsive Menu Frame (Static)
LocalScript (mounts centered, scaled Frame with buttons):

Lua:

```
local Players = game:GetService("Players")
local Roact = require(game.ReplicatedStorage.Roact)

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local menuElement = Roact.createElement("ScreenGui", {
    IgnoreGuiInset = true
}, {
    MenuFrame = Roact.createElement("Frame", {
        Size = UDim2.fromScale(0.75, 0.6),  -- 75% width, 60% height
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    }, {
        UICorner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0, 12)
        }),
        UIListLayout = Roact.createElement("UIListLayout", {
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        }),
        PlayButton = Roact.createElement("TextButton", {
            Size = UDim2.fromScale(0.8, 0.15),
            Text = "Play",
            BackgroundColor3 = Color3.fromRGB(0, 170, 0),
            TextColor3 = Color3.new(1,1,1),
            [Roact.Event.Activated] = function()
                print("Play clicked!")
            end
        }),
        SettingsButton = Roact.createElement("TextButton", {
            Size = UDim2.fromScale(0.8, 0.15),
            Text = "Settings",
            BackgroundColor3 = Color3.fromRGB(0, 120, 170)
        })
    })
})

local handle = Roact.mount(menuElement, playerGui)
```
Scales perfectly; add UIAspectRatioConstraint (AspectRatio=1.33) child for widescreen lock.
Example 2: Stateful Toggle Menu (Bindings for Visibility)
Uses Roact.createBinding for reactive show/hide (like React state).

Lua
```

local Roact = require(game.ReplicatedStorage.Roact)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local Menu = Roact.Component:extend("Menu")

function Menu:init()
    self.visible, self.setVisible = Roact.createBinding(false)  -- Start hidden
end

function Menu:render()
    return Roact.createElement("ScreenGui", {}, {
        OpenBtn = Roact.createElement("TextButton", {
            Size = UDim2.fromOffset(150, 50),
            Position = UDim2.fromScale(1, 1).Tween(UDim2.fromScale(0.95, 0.95)),
            Text = "Open Menu",
            [Roact.Event.Activated] = function()
                self.setVisible(true)
            end
        }),
        MenuFrame = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.8, 0.7),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Visible = self.visible  -- Reactive!
        }, {
            -- Add buttons/list as in Ex1
            CloseBtn = Roact.createElement("TextButton", {
                Size = UDim2.fromOffset(40, 40),
                Position = UDim2.fromScale(1, 0),
                AnchorPoint = Vector2.new(1, 0),
                Text = "X",
                BackgroundColor3 = Color3.fromRGB(200, 50, 50),
                [Roact.Event.Activated] = function()
                    self.setVisible(false)
                end
            })
        })
    })
end

Roact.mount(Roact.createElement(Menu), playerGui)
```

Toggle via binding; add TweenService in didUpdate for slide-in.
Example 3: Themed Dark Menu (Full from Community, Responsive)
Complete toggleable menu with styles, close button (centered, scaled).

luau:
```
-- Requires 'Style' module (community addon for CSS-like props; optional)
local Roact = require(game.ReplicatedStorage.Roact)
local Players = game:GetService("Players").LocalPlayer

local DarkMode = {  -- Style object
    Global = { BackgroundColor3 = Color3.new(0.1,0.1,0.1), TextColor3 = Color3.new(0.9,0.9,0.9) },
    TextLabel = { Text = "DarkTextLabel", Size = UDim2.fromOffset(200,50) },
    CloseButton = { BackgroundColor3 = Color3.new(1,0.2,0.2), Size = UDim2.fromOffset(50,50), TextScaled = true, Text = "X" }
}

local Menu = Roact.Component:extend("Menu")
function Menu:init()
    self.visible, self.updateVisible = Roact.createBinding(true)
end
function Menu:render()
    return Roact.createElement("ScreenGui", {}, {
        Roact.createElement("Frame", {
            Size = UDim2.new(1, -100, 1, -100),  -- Responsive margins
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Visible = self.visible
        }, {
            Roact.createElement("TextLabel"),  -- Styled
            Roact.createElement("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.fromScale(1, 0),
                Tag = "CloseButton",  -- Applies style
                [Roact.Event.Activated] = function() self.updateVisible(false) end
            })
        }),
        Roact.createElement("TextButton", {  -- Toggle
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromOffset(200, 50),
            Text = "Toggle Visible",
            [Roact.Event.Activated] = function() self.updateVisible(not self.visible:getValue()) end
        })
    })
end

Roact.mount(Roact.createElement(Menu), Players.PlayerGui, "Dark Menu")
```
Responsive: Scale-based sizing/positioning; works on all devices.
Example 4: Dynamic List Menu (e.g., Inventory)
Uses fragments + loop for buttons.

Luau

```
-- In render():
local items = {"Sword", "Potion", "Shield"}
local buttons = {}
for i, item in ipairs(items) do
    buttons[i] = Roact.createElement("TextButton", {
        Size = UDim2.fromScale(0.9, 0.1),
        Text = item,
        [Roact.Event.Activated] = function() print("Selected:", item) end
    })
end
return Roact.createFragment(buttons)  -- No wrapper Frame
```
Wrap in ScrollingFrame + UIListLayout for scrollable menu.
For animations: Pair with roact-spring. Full docs: roblox.github.io/roact. Migrate to react-lua for hooks/performance.

Here is a table listing all the key resources and references mentioned in the previous response about Roact UI framework examples. It maps each context (what the resource covers or was used for) to its primary link (based on official sources, GitHub, and highly regarded community references as of February 2026). Roact is deprecated/archived, with react-lua as the maintained successor.

Direct Link Reference:
Context,Link
"Official Roact Documentation (full guide, API reference, elements, bindings/refs, portals, installation, etc.)",https://roblox.github.io/roact
"Roact API Reference (methods like createElement, mount, etc.)",https://roblox.github.io/roact/api-reference
"Roact Installation (download .rbxm model from releases, place in ReplicatedStorage)",https://roblox.github.io/roact/guide/installation
Roact GitHub Repository (archived; includes releases history and model downloads),https://github.com/Roblox/roact
"Roact Releases Page (latest .rbxm files, last release Aug 2022)",https://github.com/Roblox/roact/releases
"react-lua (official/community successor to Roact; supports hooks, functional components, closer to modern React)",https://github.com/jsdotlua/react-lua
Roact-Rodux Documentation (state management binding for Roact),https://roblox.github.io/roact-rodux
"Roact UI Framework Crash Course (Deprecated) (DevForum tutorial with basics, examples, and 2025 update recommending react-lua)",https://devforum.roblox.com/t/roact-ui-framework-crash-course-deprecated/796618
roact-spring (spring-physics animation library for Roact/react-lua; used for smooth animations in examples),https://github.com/chriscerie/roact-spring
roact-spring DevForum Announcement (introduction and usage for UI animations),https://devforum.roblox.com/t/bring-ui-animations-to-life-with-roact-spring-a-modern-spring-based-animation-library/1670138
Roact Tutorial Examples Repository (code from Roblox Developer Academy/ChipioIndustries video series),https://github.com/ChipioIndustries/Roact-Tutorial
Perfect your UI with Roact! (YouTube tutorial by ChipioIndustries; linked examples and discussion),https://www.youtube.com/watch?v=pA5iDkhKqLw

These cover every major reference in the examples provided (official docs, installation, successor library, animations, and community tutorials). For new work, prioritize react-lua and its ecosystem (e.g., via Wally package manager).

