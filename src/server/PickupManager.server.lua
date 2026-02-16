--[[
	PickupManager.server.lua
	Manages health, armor, and ammo pickups for Deck 22.
	Pickups are visible floating objects that respawn after collection.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PickupConfig = require(ReplicatedStorage.PickupConfig)
local GameConfig = require(ReplicatedStorage.GameConfig)
local Constants = require(ReplicatedStorage.Constants)

-- Wait for map
while not workspace:GetAttribute("MapReady") do
	task.wait(0.1)
end

print("[Deck22] PickupManager starting...")

--------------------------------------------------------------------------------
-- Remote Events
--------------------------------------------------------------------------------

local pickupCollectedEvent = Instance.new("RemoteEvent")
pickupCollectedEvent.Name = "PickupCollected"
pickupCollectedEvent.Parent = ReplicatedStorage

--------------------------------------------------------------------------------
-- Pickup Creation
--------------------------------------------------------------------------------

local function createPickup(spawnDef: any)
	local typeDef = PickupConfig.types[spawnDef.pickupType]
	if not typeDef then
		warn("[Deck22] Unknown pickup type: " .. tostring(spawnDef.pickupType))
		return
	end

	local part = Instance.new("Part")
	part.Name = "Pickup_" .. spawnDef.pickupType
	part.Size = typeDef.size
	part.Position = spawnDef.position
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = typeDef.color
	part.Shape = Enum.PartType.Block
	part.CollisionGroup = Constants.COLLISION_GROUP_PICKUPS

	-- Billboard label
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 25)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = false
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = typeDef.color
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = typeDef.name
	label.Parent = billboard

	-- Slow floating bob animation
	local startY = spawnDef.position.Y
	task.spawn(function()
		local t = math.random() * math.pi * 2  -- Random phase offset
		while part and part.Parent do
			t += 0.05
			local bobY = math.sin(t) * 0.5
			part.Position = Vector3.new(spawnDef.position.X, startY + bobY, spawnDef.position.Z)
			part.CFrame = part.CFrame * CFrame.Angles(0, math.rad(1.5), 0)
			task.wait(0.03)
		end
	end)

	-- Touched event for collection
	local debounce = false
	part.Touched:Connect(function(otherPart: BasePart)
		if debounce then
			return
		end

		local character = otherPart.Parent
		if not character then
			return
		end

		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end

		-- Check if pickup would be useful
		local collected = false

		if typeDef.pickupType == "health" then
			if humanoid.Health < GameConfig.MAX_HEALTH then
				local newHealth = math.min(humanoid.Health + typeDef.value, GameConfig.MAX_HEALTH)
				humanoid.Health = newHealth
				collected = true
			end

		elseif typeDef.pickupType == "armor" then
			local getArmor = ReplicatedStorage:FindFirstChild("GetPlayerArmor")
			local setArmor = ReplicatedStorage:FindFirstChild("SetPlayerArmor")
			if getArmor and setArmor then
				local currentArmor = getArmor:Invoke(player)
				if currentArmor < typeDef.maxStack then
					local newArmor = math.min(currentArmor + typeDef.value, typeDef.maxStack)
					setArmor:Invoke(player, newArmor)
					collected = true
				end
			end

		elseif typeDef.pickupType == "ammo" then
			-- Ammo is always useful — grant to all weapons
			collected = true
			-- Ammo is managed by WeaponManager via attributes; signal it
		end

		if not collected then
			return
		end

		debounce = true

		-- Notify client
		pickupCollectedEvent:FireClient(player, spawnDef.pickupType, typeDef.name)

		-- Hide pickup
		part.Transparency = 1
		billboard.Enabled = false

		-- Respawn timer
		local respawnTime = spawnDef.respawnTime or Constants.DEFAULT_PICKUP_RESPAWN
		task.delay(respawnTime, function()
			if part and part.Parent then
				part.Transparency = 0
				billboard.Enabled = true
				debounce = false
			end
		end)
	end)

	part.Parent = workspace:FindFirstChild("Deck22Map") or workspace
end

-- Spawn all pickups
for _, spawnDef in PickupConfig.spawnLocations do
	createPickup(spawnDef)
end

print("[Deck22] PickupManager ready (" .. #PickupConfig.spawnLocations .. " pickups)")
