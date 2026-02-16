--[[
	WeaponManager.server.lua
	Server-authoritative weapon system for Deck 22.
	Handles weapon spawning, collection, firing validation via raycasting,
	and damage application.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponConfig = require(ReplicatedStorage.WeaponConfig)
local GameConfig = require(ReplicatedStorage.GameConfig)
local Constants = require(ReplicatedStorage.Constants)

-- Wait for map
while not workspace:GetAttribute("MapReady") do
	task.wait(0.1)
end

print("[Deck22] WeaponManager starting...")

--------------------------------------------------------------------------------
-- Remote Events
--------------------------------------------------------------------------------

local fireWeaponEvent = Instance.new("RemoteEvent")
fireWeaponEvent.Name = "FireWeapon"
fireWeaponEvent.Parent = ReplicatedStorage

local equipWeaponEvent = Instance.new("RemoteEvent")
equipWeaponEvent.Name = "EquipWeapon"
equipWeaponEvent.Parent = ReplicatedStorage

local weaponPickedUpEvent = Instance.new("RemoteEvent")
weaponPickedUpEvent.Name = "WeaponPickedUp"
weaponPickedUpEvent.Parent = ReplicatedStorage

local hitMarkerEvent = Instance.new("RemoteEvent")
hitMarkerEvent.Name = "HitMarker"
hitMarkerEvent.Parent = ReplicatedStorage

--------------------------------------------------------------------------------
-- Player Weapon State
--------------------------------------------------------------------------------

-- { [Player]: { currentWeapon: string, weapons: { [string]: { ammo: number } }, lastFireTime: number } }
local playerWeapons: { [Player]: any } = {}

local function initPlayerWeapons(player: Player)
	local defaultWeapon = "Pistol"
	playerWeapons[player] = {
		currentWeapon = defaultWeapon,
		weapons = {
			[defaultWeapon] = { ammo = WeaponConfig.weapons[defaultWeapon].maxAmmo },
		},
		lastFireTime = 0,
	}

	-- Notify client of default weapon
	equipWeaponEvent:FireClient(player, defaultWeapon, WeaponConfig.weapons[defaultWeapon])
end

local function giveWeapon(player: Player, weaponType: string)
	local state = playerWeapons[player]
	if not state then
		return
	end

	local weaponDef = WeaponConfig.weapons[weaponType]
	if not weaponDef then
		return
	end

	-- Give weapon with full ammo (or top up if already owned)
	state.weapons[weaponType] = { ammo = weaponDef.maxAmmo }
	state.currentWeapon = weaponType

	-- Notify client
	equipWeaponEvent:FireClient(player, weaponType, weaponDef)
end

--------------------------------------------------------------------------------
-- Weapon Pickup Spawning
--------------------------------------------------------------------------------

local activePickups: { [any]: { part: BasePart, timer: thread? } } = {}

local function createWeaponPickup(spawnDef: any)
	local weaponDef = WeaponConfig.weapons[spawnDef.weaponType]
	if not weaponDef then
		return
	end

	local part = Instance.new("Part")
	part.Name = "WeaponPickup_" .. spawnDef.weaponType
	part.Size = Vector3.new(3, 3, 3)
	part.Position = spawnDef.position
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = weaponDef.color
	part.Shape = Enum.PartType.Block
	part.CollisionGroup = Constants.COLLISION_GROUP_PICKUPS

	-- Billboard label
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 120, 0, 30)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = false
	billboard.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = weaponDef.color
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = weaponDef.name
	label.Parent = billboard

	-- Slow rotation
	task.spawn(function()
		while part and part.Parent do
			part.CFrame = part.CFrame * CFrame.Angles(0, math.rad(1), 0)
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

		debounce = true

		-- Give weapon
		giveWeapon(player, spawnDef.weaponType)
		weaponPickedUpEvent:FireClient(player, spawnDef.weaponType)

		-- Hide pickup
		part.Transparency = 1
		if billboard then
			billboard.Enabled = false
		end

		-- Respawn timer
		local respawnTime = spawnDef.respawnTime or Constants.DEFAULT_WEAPON_RESPAWN
		task.delay(respawnTime, function()
			if part and part.Parent then
				part.Transparency = 0
				if billboard then
					billboard.Enabled = true
				end
				debounce = false
			end
		end)
	end)

	part.Parent = workspace:FindFirstChild("Deck22Map") or workspace
	activePickups[spawnDef] = { part = part }
end

-- Spawn all weapon pickups
for _, spawnDef in WeaponConfig.spawnLocations do
	createWeaponPickup(spawnDef)
end

print("[Deck22] " .. #WeaponConfig.spawnLocations .. " weapon pickups spawned")

--------------------------------------------------------------------------------
-- Fire Weapon (Server Validation)
--------------------------------------------------------------------------------

-- Rate limit tracking
local FIRE_RATE_TOLERANCE = 1.2  -- Allow 20% tolerance for network latency

fireWeaponEvent.OnServerEvent:Connect(function(player: Player, origin: Vector3, direction: Vector3)
	local state = playerWeapons[player]
	if not state then
		return
	end

	local weaponType = state.currentWeapon
	local weaponDef = WeaponConfig.weapons[weaponType]
	if not weaponDef then
		return
	end

	local weaponState = state.weapons[weaponType]
	if not weaponState then
		return
	end

	-- Rate limit check
	local now = tick()
	local minInterval = 1 / (weaponDef.fireRate * FIRE_RATE_TOLERANCE)
	if now - state.lastFireTime < minInterval then
		return
	end
	state.lastFireTime = now

	-- Ammo check
	if weaponState.ammo <= 0 then
		return
	end
	weaponState.ammo -= 1

	-- Validate origin is near player's head
	local character = player.Character
	if not character then
		return
	end
	local head = character:FindFirstChild("Head")
	if not head then
		return
	end
	if (origin - head.Position).Magnitude > 10 then
		return -- Origin too far from player (possible exploit)
	end

	-- Perform server-side raycast
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { character }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local range = weaponDef.range
	local normalizedDir = direction.Unit

	-- Handle shotgun pellets
	local pelletCount = weaponDef.pellets or 1
	local spread = weaponDef.spread or 0

	for _ = 1, pelletCount do
		local fireDir = normalizedDir
		if spread > 0 then
			-- Apply random spread
			local spreadX = (math.random() - 0.5) * spread * 2
			local spreadY = (math.random() - 0.5) * spread * 2
			fireDir = (CFrame.lookAt(Vector3.zero, normalizedDir) * CFrame.Angles(spreadX, spreadY, 0)).LookVector
		end

		local result = workspace:Raycast(origin, fireDir * range, raycastParams)
		if result and result.Instance then
			local hitCharacter = result.Instance:FindFirstAncestorOfClass("Model")
			if hitCharacter then
				local hitHumanoid = hitCharacter:FindFirstChildOfClass("Humanoid")
				if hitHumanoid and hitHumanoid.Health > 0 then
					local hitPlayer = Players:GetPlayerFromCharacter(hitCharacter)
					if hitPlayer and hitPlayer ~= player then
						-- Calculate damage
						local damage = weaponDef.damage

						-- Headshot check
						if result.Instance.Name == "Head" then
							damage *= weaponDef.headshotMultiplier
						end

						-- Apply armor absorption
						local getArmor = ReplicatedStorage:FindFirstChild("GetPlayerArmor")
						local setArmor = ReplicatedStorage:FindFirstChild("SetPlayerArmor")
						if getArmor and setArmor then
							local armor = getArmor:Invoke(hitPlayer)
							if armor > 0 then
								local absorbed = damage * GameConfig.ARMOR_ABSORPTION
								local armorDamage = math.min(absorbed, armor)
								setArmor:Invoke(hitPlayer, armor - armorDamage)
								damage = damage - armorDamage
							end
						end

						-- Apply damage
						hitHumanoid:TakeDamage(damage)

						-- Hit marker feedback
						hitMarkerEvent:FireClient(player, result.Instance.Name == "Head")

						-- Check for kill
						if hitHumanoid.Health <= 0 then
							local recordKill = ReplicatedStorage:FindFirstChild("RecordKill")
							if recordKill then
								recordKill:Fire(player, hitPlayer)
							end
						end
					end
				end
			end
		end
	end
end)

--------------------------------------------------------------------------------
-- Player Setup / Cleanup
--------------------------------------------------------------------------------

Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAdded:Connect(function()
		initPlayerWeapons(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	playerWeapons[player] = nil
end)

-- Init for already-connected players
for _, player in Players:GetPlayers() do
	if player.Character then
		initPlayerWeapons(player)
	end
	player.CharacterAdded:Connect(function()
		initPlayerWeapons(player)
	end)
end

print("[Deck22] WeaponManager ready")
