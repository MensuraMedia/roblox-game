--[[
	WeaponController.client.lua
	Client-side weapon input handling for Deck 22.
	Captures mouse clicks and key presses, sends fire/switch requests
	to server, and plays local visual/sound effects.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local WeaponConfig = require(ReplicatedStorage.WeaponConfig)

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------------------------------------
-- Remote Events
--------------------------------------------------------------------------------

local fireWeaponEvent = ReplicatedStorage:WaitForChild("FireWeapon", 30)
local equipWeaponEvent = ReplicatedStorage:WaitForChild("EquipWeapon", 30)
local weaponPickedUpEvent = ReplicatedStorage:WaitForChild("WeaponPickedUp", 30)
local hitMarkerEvent = ReplicatedStorage:WaitForChild("HitMarker", 30)

--------------------------------------------------------------------------------
-- Local Weapon State
--------------------------------------------------------------------------------

local currentWeapon: string = "Pistol"
local currentWeaponDef: any = WeaponConfig.weapons.Pistol
local lastFireTime = 0
local isFiring = false

-- Weapon inventory (synced from server)
local ownedWeapons: { [string]: boolean } = { Pistol = true }
local weaponSlots = { "Pistol", "Shotgun", "PulseRifle", "RocketLauncher", "Sniper" }

--------------------------------------------------------------------------------
-- Weapon Name Display
--------------------------------------------------------------------------------

local playerGui = player:WaitForChild("PlayerGui")

local weaponGui = Instance.new("ScreenGui")
weaponGui.Name = "WeaponGui"
weaponGui.IgnoreGuiInset = false
weaponGui.ResetOnSpawn = true
weaponGui.DisplayOrder = 51
weaponGui.Parent = playerGui

-- Current weapon name (bottom center)
local weaponLabel = Instance.new("TextLabel")
weaponLabel.Name = "WeaponName"
weaponLabel.Size = UDim2.new(0, 200, 0, 30)
weaponLabel.Position = UDim2.new(0.5, 0, 1, -30)
weaponLabel.AnchorPoint = Vector2.new(0.5, 1)
weaponLabel.BackgroundTransparency = 1
weaponLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
weaponLabel.TextScaled = true
weaponLabel.Font = Enum.Font.GothamBold
weaponLabel.Text = "Pistol"
weaponLabel.Parent = weaponGui

-- Ammo indicator (bottom center-right)
local ammoLabel = Instance.new("TextLabel")
ammoLabel.Name = "AmmoLabel"
ammoLabel.Size = UDim2.new(0, 100, 0, 24)
ammoLabel.Position = UDim2.new(0.5, 110, 1, -32)
ammoLabel.AnchorPoint = Vector2.new(0, 1)
ammoLabel.BackgroundTransparency = 1
ammoLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
ammoLabel.TextScaled = true
ammoLabel.Font = Enum.Font.GothamBold
ammoLabel.Text = ""
ammoLabel.Parent = weaponGui

-- Hit marker overlay (center of screen, brief flash)
local hitMarker = Instance.new("TextLabel")
hitMarker.Name = "HitMarker"
hitMarker.Size = UDim2.new(0, 40, 0, 40)
hitMarker.Position = UDim2.new(0.5, 0, 0.5, 0)
hitMarker.AnchorPoint = Vector2.new(0.5, 0.5)
hitMarker.BackgroundTransparency = 1
hitMarker.TextColor3 = Color3.fromRGB(255, 50, 50)
hitMarker.TextTransparency = 1
hitMarker.TextScaled = true
hitMarker.Font = Enum.Font.GothamBold
hitMarker.Text = "X"
hitMarker.Parent = weaponGui

--------------------------------------------------------------------------------
-- Firing Logic
--------------------------------------------------------------------------------

local function fireWeapon()
	if not currentWeaponDef then
		return
	end

	local now = tick()
	local fireInterval = 1 / currentWeaponDef.fireRate
	if now - lastFireTime < fireInterval then
		return
	end
	lastFireTime = now

	-- Get camera direction for aiming
	local camCFrame = camera.CFrame
	local origin = camCFrame.Position
	local direction = camCFrame.LookVector

	-- Send to server
	if fireWeaponEvent then
		fireWeaponEvent:FireServer(origin, direction)
	end

	-- Local muzzle flash effect (brief screen flash)
	-- In a full implementation this would be a particle effect at the weapon model
end

-- Continuous fire loop
task.spawn(function()
	while true do
		if isFiring then
			fireWeapon()
		end
		task.wait(0.016)  -- ~60fps input poll
	end
end)

--[[
	Switch to a weapon slot (1-5).
	@param slot number
]]
local function switchToSlot(slot: number)
	local weaponType = weaponSlots[slot]
	if not weaponType then
		return
	end
	if not ownedWeapons[weaponType] then
		return
	end

	currentWeapon = weaponType
	currentWeaponDef = WeaponConfig.weapons[weaponType]
	weaponLabel.Text = currentWeaponDef.name
	weaponLabel.TextColor3 = currentWeaponDef.color
end

--------------------------------------------------------------------------------
-- Input Handling
--------------------------------------------------------------------------------

-- Mouse button for firing
UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	-- Left mouse button = fire
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isFiring = true
	end

	-- Number keys 1-5 for weapon switching
	if input.KeyCode == Enum.KeyCode.One then
		switchToSlot(1)
	elseif input.KeyCode == Enum.KeyCode.Two then
		switchToSlot(2)
	elseif input.KeyCode == Enum.KeyCode.Three then
		switchToSlot(3)
	elseif input.KeyCode == Enum.KeyCode.Four then
		switchToSlot(4)
	elseif input.KeyCode == Enum.KeyCode.Five then
		switchToSlot(5)
	end
end)

UserInputService.InputEnded:Connect(function(input: InputObject, _gameProcessed: boolean)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isFiring = false
	end
end)


--------------------------------------------------------------------------------
-- Server Event Handlers
--------------------------------------------------------------------------------

-- Weapon equip from server (on pickup or respawn)
if equipWeaponEvent then
	equipWeaponEvent.OnClientEvent:Connect(function(weaponType: string, weaponDef: any)
		ownedWeapons[weaponType] = true
		currentWeapon = weaponType
		currentWeaponDef = WeaponConfig.weapons[weaponType] or weaponDef
		weaponLabel.Text = currentWeaponDef.name
		weaponLabel.TextColor3 = currentWeaponDef.color
	end)
end

-- Weapon picked up notification
if weaponPickedUpEvent then
	weaponPickedUpEvent.OnClientEvent:Connect(function(weaponType: string)
		ownedWeapons[weaponType] = true
	end)
end

-- Hit marker feedback
if hitMarkerEvent then
	hitMarkerEvent.OnClientEvent:Connect(function(isHeadshot: boolean)
		hitMarker.TextColor3 = if isHeadshot
			then Color3.fromRGB(255, 255, 0)
			else Color3.fromRGB(255, 50, 50)
		hitMarker.Text = if isHeadshot then "!" else "X"
		hitMarker.TextTransparency = 0

		local tween = TweenService:Create(
			hitMarker,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ TextTransparency = 1 }
		)
		tween:Play()
	end)
end

-- Reset on respawn
player.CharacterAdded:Connect(function()
	ownedWeapons = { Pistol = true }
	currentWeapon = "Pistol"
	currentWeaponDef = WeaponConfig.weapons.Pistol
	weaponLabel.Text = "Pistol"
	weaponLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	isFiring = false
end)

-- Lock mouse for FPS-style aiming
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

print("[Deck22] WeaponController ready")
