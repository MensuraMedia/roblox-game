--[[
	HazardManager.server.lua
	Manages acid pit damage zones. Uses CollectionService tags to find
	hazard parts and applies periodic damage to any character inside them.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Constants)

-- Wait for map to be ready
while not workspace:GetAttribute("MapReady") do
	task.wait(0.1)
end

print("[Deck22] HazardManager starting...")

-- Track which characters are currently in hazard zones
-- Key: character Model, Value: { connection: RBXScriptConnection, damageLoop: thread }
local activeHazards: { [Model]: { connection: RBXScriptConnection, damageLoop: thread } } = {}

--[[
	Start dealing periodic damage to a character in the hazard zone.
	@param character Model - The player's character
]]
local function startDamage(character: Model)
	if activeHazards[character] then
		return -- Already being damaged
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end

	local entry = {}

	-- Clean up when the character dies or is removed
	entry.connection = humanoid.Died:Connect(function()
		if activeHazards[character] then
			activeHazards[character] = nil
		end
	end)

	-- Damage loop
	entry.damageLoop = task.spawn(function()
		while activeHazards[character] and humanoid and humanoid.Health > 0 do
			humanoid:TakeDamage(Constants.ACID_DAMAGE_PER_TICK)
			task.wait(Constants.ACID_DAMAGE_INTERVAL)
		end
	end)

	activeHazards[character] = entry
end

--[[
	Stop dealing damage to a character (they left the hazard zone).
	@param character Model - The player's character
]]
local function stopDamage(character: Model)
	local entry = activeHazards[character]
	if entry then
		if entry.connection then
			entry.connection:Disconnect()
		end
		if entry.damageLoop then
			task.cancel(entry.damageLoop)
		end
		activeHazards[character] = nil
	end
end

--[[
	Setup a hazard zone part with Touched/TouchEnded events.
	@param hazardPart BasePart - The hazard detection zone
]]
local function setupHazardZone(hazardPart: BasePart)
	-- Track touch count per character for reliable enter/exit detection
	local touchCounts: { [Model]: number } = {}

	hazardPart.Touched:Connect(function(otherPart: BasePart)
		local character = otherPart.Parent
		if not character then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end

		-- Verify this is a player character
		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		touchCounts[character] = (touchCounts[character] or 0) + 1
		if touchCounts[character] == 1 then
			startDamage(character)
		end
	end)

	hazardPart.TouchEnded:Connect(function(otherPart: BasePart)
		local character = otherPart.Parent
		if not character then
			return
		end

		if touchCounts[character] then
			touchCounts[character] -= 1
			if touchCounts[character] <= 0 then
				touchCounts[character] = nil
				stopDamage(character)
			end
		end
	end)

	print("[Deck22] Hazard zone configured: " .. hazardPart.Name)
end

-- Find and setup all hazard zones
local hazardParts = CollectionService:GetTagged(Constants.TAG_ACID_HAZARD)
for _, part in hazardParts do
	setupHazardZone(part)
end

-- Handle dynamically added hazard zones (future-proof)
CollectionService:GetInstanceAddedSignal(Constants.TAG_ACID_HAZARD):Connect(function(part)
	if part:IsA("BasePart") then
		setupHazardZone(part)
	end
end)

-- Clean up when players leave
Players.PlayerRemoving:Connect(function(player: Player)
	if player.Character then
		stopDamage(player.Character)
	end
end)

print("[Deck22] HazardManager ready (" .. #hazardParts .. " zones)")
