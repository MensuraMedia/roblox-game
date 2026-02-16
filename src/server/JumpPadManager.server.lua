--[[
	JumpPadManager.server.lua
	Manages jump pad launching using LinearVelocity + Attachment pattern.
	ApplyImpulse does NOT work on player characters, so we use a temporary
	LinearVelocity constraint with MaxForce = math.huge for reliable launches.
]]

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Constants)

-- Wait for map to be ready
while not workspace:GetAttribute("MapReady") do
	task.wait(0.1)
end

print("[Deck22] JumpPadManager starting...")

-- Create RemoteEvent for client-side effects
local jumpPadEvent = Instance.new("RemoteEvent")
jumpPadEvent.Name = "JumpPadActivated"
jumpPadEvent.Parent = ReplicatedStorage

-- Cooldown tracking: { [Player]: { [BasePart]: number (tick) } }
local cooldowns: { [Player]: { [BasePart]: number } } = {}

--[[
	Launch a character using the LinearVelocity + Attachment pattern.
	@param character Model - The player's character
	@param launchVector Vector3 - The velocity to apply
]]
local function launchCharacter(character: Model, launchVector: Vector3)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoidRootPart or not humanoid then
		return
	end

	-- Don't launch dead players
	if humanoid.Health <= 0 then
		return
	end

	-- Check if already being launched (prevent stacking)
	if humanoidRootPart:FindFirstChild("JumpPadVelocity") then
		return
	end

	-- Change humanoid state to allow physics override
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	-- Create LinearVelocity constraint
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Name = "JumpPadVelocity"
	linearVelocity.MaxForce = math.huge
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.VectorVelocity = launchVector

	-- Create attachment point
	local attachment = Instance.new("Attachment")
	attachment.Name = "JumpPadAttachment"
	attachment.Parent = humanoidRootPart

	-- Link and parent
	linearVelocity.Attachment0 = attachment
	linearVelocity.Parent = humanoidRootPart

	-- Clean up after brief duration
	task.delay(Constants.JUMP_PAD_FORCE_DURATION, function()
		if linearVelocity and linearVelocity.Parent then
			linearVelocity:Destroy()
		end
		if attachment and attachment.Parent then
			attachment:Destroy()
		end
		-- Return to normal movement state
		if humanoid and humanoid.Parent and humanoid.Health > 0 then
			humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		end
	end)
end

--[[
	Setup a jump pad part with Touched event.
	@param padPart BasePart - The jump pad surface
]]
local function setupJumpPad(padPart: BasePart)
	-- Read launch vector from part attributes
	local launchX = padPart:GetAttribute("LaunchX") or 0
	local launchY = padPart:GetAttribute("LaunchY") or 100
	local launchZ = padPart:GetAttribute("LaunchZ") or 0
	local launchVector = Vector3.new(launchX, launchY, launchZ)

	padPart.Touched:Connect(function(otherPart: BasePart)
		local character = otherPart.Parent
		if not character then
			return
		end

		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		-- Cooldown check
		if not cooldowns[player] then
			cooldowns[player] = {}
		end

		local now = tick()
		local lastUsed = cooldowns[player][padPart] or 0
		if now - lastUsed < Constants.JUMP_PAD_COOLDOWN then
			return
		end
		cooldowns[player][padPart] = now

		-- Launch the character
		launchCharacter(character, launchVector)

		-- Notify client for visual/sound effects
		jumpPadEvent:FireClient(player, padPart.Position)
	end)

	print("[Deck22] Jump pad configured: " .. padPart.Name)
end

-- Find and setup all jump pads
local jumpPads = CollectionService:GetTagged(Constants.TAG_JUMP_PAD)
for _, pad in jumpPads do
	setupJumpPad(pad)
end

-- Handle dynamically added jump pads
CollectionService:GetInstanceAddedSignal(Constants.TAG_JUMP_PAD):Connect(function(part)
	if part:IsA("BasePart") then
		setupJumpPad(part)
	end
end)

-- Clean up cooldowns when players leave
Players.PlayerRemoving:Connect(function(player: Player)
	cooldowns[player] = nil
end)

print("[Deck22] JumpPadManager ready (" .. #jumpPads .. " pads)")
