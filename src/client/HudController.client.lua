--[[
	HudController.client.lua
	Heads-up display for Deck 22 deathmatch:
	  - Health bar, armor bar
	  - Score display (kills)
	  - Round timer
	  - Kill feed (recent kills)
	  - Game state banner
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.GameConfig)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- GUI Creation Helpers
--------------------------------------------------------------------------------

local function createFrame(props: { [string]: any }): Frame
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = props.bgColor or Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = props.bgTransparency or 0.5
	frame.BorderSizePixel = 0
	frame.Size = props.size or UDim2.fromScale(1, 1)
	frame.Position = props.position or UDim2.fromScale(0, 0)
	frame.AnchorPoint = props.anchor or Vector2.new(0, 0)
	if props.name then
		frame.Name = props.name
	end
	if props.parent then
		frame.Parent = props.parent
	end
	return frame
end

local function createLabel(props: { [string]: any }): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.TextColor3 = props.textColor or Color3.fromRGB(255, 255, 255)
	label.TextScaled = props.scaled ~= false
	label.Font = Enum.Font.GothamBold
	label.Text = props.text or ""
	label.Size = props.size or UDim2.fromScale(1, 1)
	label.Position = props.position or UDim2.fromScale(0, 0)
	label.AnchorPoint = props.anchor or Vector2.new(0, 0)
	label.TextXAlignment = props.alignX or Enum.TextXAlignment.Center
	label.TextYAlignment = props.alignY or Enum.TextYAlignment.Center
	if props.name then
		label.Name = props.name
	end
	if props.parent then
		label.Parent = props.parent
	end
	return label
end

--------------------------------------------------------------------------------
-- Main HUD ScreenGui
--------------------------------------------------------------------------------

local hudGui = Instance.new("ScreenGui")
hudGui.Name = "HudGui"
hudGui.IgnoreGuiInset = false
hudGui.ResetOnSpawn = false
hudGui.DisplayOrder = 50
hudGui.Parent = playerGui

--------------------------------------------------------------------------------
-- Health Bar (bottom left)
--------------------------------------------------------------------------------

local healthContainer = createFrame({
	name = "HealthContainer",
	size = UDim2.new(0, 200, 0, 24),
	position = UDim2.new(0, 20, 1, -60),
	bgColor = Color3.fromRGB(30, 30, 30),
	bgTransparency = 0.3,
	parent = hudGui,
})

local healthBar = createFrame({
	name = "HealthBar",
	size = UDim2.fromScale(1, 1),
	bgColor = Color3.fromRGB(0, 200, 50),
	bgTransparency = 0,
	parent = healthContainer,
})

local healthLabel = createLabel({
	name = "HealthLabel",
	text = "100",
	size = UDim2.fromScale(1, 1),
	textColor = Color3.fromRGB(255, 255, 255),
	parent = healthContainer,
})

-- Health icon label
createLabel({
	name = "HealthIcon",
	text = "HP",
	size = UDim2.new(0, 30, 0, 24),
	position = UDim2.new(0, -35, 1, -60),
	textColor = Color3.fromRGB(0, 200, 50),
	parent = hudGui,
})

--------------------------------------------------------------------------------
-- Armor Bar (bottom left, above health)
--------------------------------------------------------------------------------

local armorContainer = createFrame({
	name = "ArmorContainer",
	size = UDim2.new(0, 200, 0, 18),
	position = UDim2.new(0, 20, 1, -90),
	bgColor = Color3.fromRGB(30, 30, 30),
	bgTransparency = 0.3,
	parent = hudGui,
})

local armorBar = createFrame({
	name = "ArmorBar",
	size = UDim2.fromScale(0, 1),
	bgColor = Color3.fromRGB(0, 150, 255),
	bgTransparency = 0,
	parent = armorContainer,
})

local armorLabel = createLabel({
	name = "ArmorLabel",
	text = "0",
	size = UDim2.fromScale(1, 1),
	textColor = Color3.fromRGB(200, 220, 255),
	parent = armorContainer,
})

createLabel({
	name = "ArmorIcon",
	text = "AR",
	size = UDim2.new(0, 30, 0, 18),
	position = UDim2.new(0, -35, 1, -90),
	textColor = Color3.fromRGB(0, 150, 255),
	parent = hudGui,
})

--------------------------------------------------------------------------------
-- Round Timer (top center)
--------------------------------------------------------------------------------

local timerLabel = createLabel({
	name = "TimerLabel",
	text = "10:00",
	size = UDim2.new(0, 120, 0, 40),
	position = UDim2.new(0.5, 0, 0, 10),
	anchor = Vector2.new(0.5, 0),
	textColor = Color3.fromRGB(255, 255, 255),
	parent = hudGui,
})

--------------------------------------------------------------------------------
-- Game State Banner (top center, below timer)
--------------------------------------------------------------------------------

local stateBanner = createLabel({
	name = "StateBanner",
	text = "",
	size = UDim2.new(0, 300, 0, 30),
	position = UDim2.new(0.5, 0, 0, 50),
	anchor = Vector2.new(0.5, 0),
	textColor = Color3.fromRGB(255, 200, 0),
	parent = hudGui,
})

--------------------------------------------------------------------------------
-- Score Display (top right)
--------------------------------------------------------------------------------

local scoreContainer = createFrame({
	name = "ScoreContainer",
	size = UDim2.new(0, 180, 0, 200),
	position = UDim2.new(1, -10, 0, 10),
	anchor = Vector2.new(1, 0),
	bgTransparency = 0.6,
	parent = hudGui,
})

local scoreTitle = createLabel({
	name = "ScoreTitle",
	text = "SCOREBOARD",
	size = UDim2.new(1, 0, 0, 24),
	textColor = Color3.fromRGB(255, 200, 0),
	parent = scoreContainer,
})

-- Score entries (up to 8 players)
local scoreLabels = {}
for i = 1, 8 do
	local entry = createLabel({
		name = "Score_" .. i,
		text = "",
		size = UDim2.new(1, -10, 0, 18),
		position = UDim2.new(0, 5, 0, 24 + (i - 1) * 20),
		alignX = Enum.TextXAlignment.Left,
		textColor = Color3.fromRGB(200, 200, 200),
		scaled = false,
		parent = scoreContainer,
	})
	entry.TextSize = 14
	scoreLabels[i] = entry
end

--------------------------------------------------------------------------------
-- Kill Feed (top left)
--------------------------------------------------------------------------------

local killFeedContainer = createFrame({
	name = "KillFeedContainer",
	size = UDim2.new(0, 300, 0, 120),
	position = UDim2.new(0, 10, 0, 10),
	bgTransparency = 1,
	parent = hudGui,
})

local killFeedEntries: { TextLabel } = {}
local MAX_KILL_FEED = 5

for i = 1, MAX_KILL_FEED do
	local entry = createLabel({
		name = "KillFeed_" .. i,
		text = "",
		size = UDim2.new(1, 0, 0, 18),
		position = UDim2.new(0, 0, 0, (i - 1) * 22),
		alignX = Enum.TextXAlignment.Left,
		textColor = Color3.fromRGB(200, 200, 200),
		scaled = false,
		parent = killFeedContainer,
	})
	entry.TextSize = 13
	entry.TextTransparency = 0
	killFeedEntries[i] = entry
end

--------------------------------------------------------------------------------
-- Crosshair (center of screen)
--------------------------------------------------------------------------------

local crosshairSize = 2
local crosshairGap = 4
local crosshairLength = 10
local crosshairColor = Color3.fromRGB(255, 255, 255)

local function createCrosshairLine(posX: number, posY: number, sizeX: number, sizeY: number)
	local line = createFrame({
		name = "CrosshairLine",
		size = UDim2.new(0, sizeX, 0, sizeY),
		position = UDim2.new(0.5, posX, 0.5, posY),
		anchor = Vector2.new(0.5, 0.5),
		bgColor = crosshairColor,
		bgTransparency = 0,
		parent = hudGui,
	})
	return line
end

-- Top line
createCrosshairLine(0, -(crosshairGap + crosshairLength / 2), crosshairSize, crosshairLength)
-- Bottom line
createCrosshairLine(0, crosshairGap + crosshairLength / 2, crosshairSize, crosshairLength)
-- Left line
createCrosshairLine(-(crosshairGap + crosshairLength / 2), 0, crosshairLength, crosshairSize)
-- Right line
createCrosshairLine(crosshairGap + crosshairLength / 2, 0, crosshairLength, crosshairSize)

--------------------------------------------------------------------------------
-- Update Functions
--------------------------------------------------------------------------------

local function updateHealth()
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local healthPct = humanoid.Health / humanoid.MaxHealth
			healthBar.Size = UDim2.fromScale(math.clamp(healthPct, 0, 1), 1)
			healthLabel.Text = tostring(math.floor(humanoid.Health))

			-- Color shift as health decreases
			if healthPct > 0.5 then
				healthBar.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
			elseif healthPct > 0.25 then
				healthBar.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
			else
				healthBar.BackgroundColor3 = Color3.fromRGB(255, 50, 0)
			end
		end
	end
end

local function updateArmor()
	local character = player.Character
	if character then
		local armor = character:GetAttribute("Armor") or 0
		local armorPct = armor / GameConfig.MAX_ARMOR
		armorBar.Size = UDim2.fromScale(math.clamp(armorPct, 0, 1), 1)
		armorLabel.Text = tostring(math.floor(armor))
	end
end

local function formatTime(seconds: number): string
	local mins = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%d:%02d", mins, secs)
end

--------------------------------------------------------------------------------
-- Event Listeners
--------------------------------------------------------------------------------

-- Game state updates
local gameStateEvent = ReplicatedStorage:WaitForChild("GameStateChanged", 30)
if gameStateEvent then
	gameStateEvent.OnClientEvent:Connect(function(state: string, timer: number)
		timerLabel.Text = formatTime(timer)

		if state == GameConfig.STATE_WARMUP then
			stateBanner.Text = "WARMUP - " .. timer .. "s"
			stateBanner.TextColor3 = Color3.fromRGB(255, 200, 0)
		elseif state == GameConfig.STATE_ACTIVE then
			stateBanner.Text = ""
		elseif state == GameConfig.STATE_POST_ROUND then
			stateBanner.Text = "ROUND OVER"
			stateBanner.TextColor3 = Color3.fromRGB(255, 100, 100)
		elseif state == GameConfig.STATE_WAITING then
			stateBanner.Text = "WAITING FOR PLAYERS"
			stateBanner.TextColor3 = Color3.fromRGB(150, 150, 150)
		end
	end)
end

-- Score updates
local scoreUpdateEvent = ReplicatedStorage:WaitForChild("ScoreUpdate", 30)
if scoreUpdateEvent then
	scoreUpdateEvent.OnClientEvent:Connect(function(scoreData: { { name: string, kills: number } })
		for i = 1, 8 do
			if scoreData[i] then
				local entry = scoreData[i]
				local prefix = if entry.name == player.Name then "> " else "  "
				scoreLabels[i].Text = prefix .. entry.name .. "  " .. entry.kills
				scoreLabels[i].TextColor3 = if entry.name == player.Name
					then Color3.fromRGB(255, 255, 100)
					else Color3.fromRGB(200, 200, 200)
			else
				scoreLabels[i].Text = ""
			end
		end
	end)
end

-- Kill feed
local killFeedEvent = ReplicatedStorage:WaitForChild("KillFeed", 30)
if killFeedEvent then
	killFeedEvent.OnClientEvent:Connect(function(killerName: string?, victimName: string)
		-- Shift existing entries down
		for i = MAX_KILL_FEED, 2, -1 do
			killFeedEntries[i].Text = killFeedEntries[i - 1].Text
			killFeedEntries[i].TextColor3 = killFeedEntries[i - 1].TextColor3
		end

		-- Add new entry at top
		if killerName then
			killFeedEntries[1].Text = killerName .. " → " .. victimName
			killFeedEntries[1].TextColor3 = if killerName == player.Name
				then Color3.fromRGB(255, 200, 100)
				else Color3.fromRGB(200, 200, 200)
		else
			killFeedEntries[1].Text = victimName .. " died"
			killFeedEntries[1].TextColor3 = Color3.fromRGB(150, 150, 150)
		end

		-- Fade old entries
		for i = 1, MAX_KILL_FEED do
			killFeedEntries[i].TextTransparency = (i - 1) * 0.15
		end
	end)
end

-- Health/armor update loop
local function onCharacterAdded(character: Model)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.HealthChanged:Connect(updateHealth)
	character:GetAttributeChangedSignal("Armor"):Connect(updateArmor)
	updateHealth()
	updateArmor()
end

if player.Character then
	task.spawn(onCharacterAdded, player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Periodic update for armor (backup)
task.spawn(function()
	while true do
		updateHealth()
		updateArmor()
		task.wait(0.5)
	end
end)

print("[Deck22] HudController ready")
