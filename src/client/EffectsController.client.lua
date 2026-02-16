--[[
	EffectsController.client.lua
	Client-side visual effects for Deck 22:
	  - Damage flash (red screen overlay)
	  - Acid tint (green overlay when in acid)
	  - Jump pad effects (camera shake + visual)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- Screen Overlay GUI
--------------------------------------------------------------------------------

local effectsGui = Instance.new("ScreenGui")
effectsGui.Name = "EffectsGui"
effectsGui.IgnoreGuiInset = true
effectsGui.ResetOnSpawn = true
effectsGui.DisplayOrder = 100

-- Damage flash overlay (red)
local damageFlash = Instance.new("Frame")
damageFlash.Name = "DamageFlash"
damageFlash.Size = UDim2.fromScale(1, 1)
damageFlash.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
damageFlash.BackgroundTransparency = 1  -- Start invisible
damageFlash.BorderSizePixel = 0
damageFlash.Parent = effectsGui

-- Acid tint overlay (green)
local acidTint = Instance.new("Frame")
acidTint.Name = "AcidTint"
acidTint.Size = UDim2.fromScale(1, 1)
acidTint.BackgroundColor3 = Color3.fromRGB(80, 255, 40)
acidTint.BackgroundTransparency = 1  -- Start invisible
acidTint.BorderSizePixel = 0
acidTint.Parent = effectsGui

-- Jump pad flash (cyan)
local jumpFlash = Instance.new("Frame")
jumpFlash.Name = "JumpFlash"
jumpFlash.Size = UDim2.fromScale(1, 1)
jumpFlash.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
jumpFlash.BackgroundTransparency = 1
jumpFlash.BorderSizePixel = 0
jumpFlash.Parent = effectsGui

effectsGui.Parent = playerGui

--------------------------------------------------------------------------------
-- Damage Flash Effect
--------------------------------------------------------------------------------

local damageFlashTween: Tween? = nil

local function showDamageFlash()
	if damageFlashTween then
		damageFlashTween:Cancel()
	end

	damageFlash.BackgroundTransparency = 0.6

	damageFlashTween = TweenService:Create(
		damageFlash,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 }
	)
	damageFlashTween:Play()
end

-- Listen for health changes to trigger damage flash
local function onCharacterAdded(character: Model)
	local humanoid = character:WaitForChild("Humanoid")
	local lastHealth = humanoid.Health

	humanoid.HealthChanged:Connect(function(newHealth: number)
		if newHealth < lastHealth then
			showDamageFlash()
		end
		lastHealth = newHealth
	end)
end

if player.Character then
	task.spawn(onCharacterAdded, player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

--------------------------------------------------------------------------------
-- Acid Tint Effect
--------------------------------------------------------------------------------

local acidTweenIn: Tween? = nil
local acidTweenOut: Tween? = nil
local inAcid = false

local function showAcidTint()
	if inAcid then
		return
	end
	inAcid = true

	if acidTweenOut then
		acidTweenOut:Cancel()
	end

	acidTweenIn = TweenService:Create(
		acidTint,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.7 }
	)
	acidTweenIn:Play()
end

local function hideAcidTint()
	if not inAcid then
		return
	end
	inAcid = false

	if acidTweenIn then
		acidTweenIn:Cancel()
	end

	acidTweenOut = TweenService:Create(
		acidTint,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 }
	)
	acidTweenOut:Play()
end

-- Check if character is in acid zone by monitoring Y position
task.spawn(function()
	while true do
		local character = player.Character
		if character then
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			if rootPart and rootPart.Position.Y < 8 then
				showAcidTint()
			else
				hideAcidTint()
			end
		end
		task.wait(0.1)
	end
end)

--------------------------------------------------------------------------------
-- Jump Pad Effect
--------------------------------------------------------------------------------

local function showJumpPadFlash()
	jumpFlash.BackgroundTransparency = 0.7

	local tween = TweenService:Create(
		jumpFlash,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 }
	)
	tween:Play()

	-- Subtle camera shake
	local camera = workspace.CurrentCamera
	if camera then
		task.spawn(function()
			for _ = 1, 4 do
				local shakeX = (math.random() - 0.5) * 0.02
				local shakeY = (math.random() - 0.5) * 0.02
				camera.CFrame = camera.CFrame * CFrame.Angles(shakeX, shakeY, 0)
				task.wait(0.03)
			end
		end)
	end
end

-- Listen for jump pad activation from server
local jumpPadEvent = ReplicatedStorage:WaitForChild("JumpPadActivated", 30)
if jumpPadEvent then
	jumpPadEvent.OnClientEvent:Connect(function(_padPosition: Vector3)
		showJumpPadFlash()
	end)
end

print("[Deck22] EffectsController ready")
