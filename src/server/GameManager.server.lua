--[[
	GameManager.server.lua
	Manages the deathmatch round lifecycle: Waiting â†’ Warmup â†’ Active â†’ PostRound.
	Tracks kills, handles respawning, and broadcasts game state to clients.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.GameConfig)
local MapData = require(ReplicatedStorage.MapData)

-- Forward declaration (used before definition)
local endRound

-- Wait for map
while not workspace:GetAttribute("MapReady") do
	task.wait(0.1)
end

print("[Deck22] GameManager starting...")

--------------------------------------------------------------------------------
-- Remote Events
--------------------------------------------------------------------------------

local gameStateEvent = Instance.new("RemoteEvent")
gameStateEvent.Name = "GameStateChanged"
gameStateEvent.Parent = ReplicatedStorage

local scoreUpdateEvent = Instance.new("RemoteEvent")
scoreUpdateEvent.Name = "ScoreUpdate"
scoreUpdateEvent.Parent = ReplicatedStorage

local killFeedEvent = Instance.new("RemoteEvent")
killFeedEvent.Name = "KillFeed"
killFeedEvent.Parent = ReplicatedStorage

--------------------------------------------------------------------------------
-- Game State
--------------------------------------------------------------------------------

local gameState = GameConfig.STATE_WAITING
local roundTimer = 0
local scores: { [Player]: number } = {}
local armorValues: { [Player]: number } = {}

--[[
	Get a random spawn CFrame from MapData.
	@return CFrame
]]
local function getRandomSpawn(): CFrame
	local spawns = MapData.spawnPoints
	return spawns[math.random(1, #spawns)]
end

--[[
	Broadcast current game state to all clients.
]]
local function broadcastState()
	gameStateEvent:FireAllClients(gameState, roundTimer)
end

--[[
	Broadcast scores to all clients.
]]
local function broadcastScores()
	local scoreData = {}
	for player, score in scores do
		if player and player.Parent then
			table.insert(scoreData, {
				name = player.Name,
				kills = score,
			})
		end
	end

	-- Sort by kills descending
	table.sort(scoreData, function(a, b)
		return a.kills > b.kills
	end)

	scoreUpdateEvent:FireAllClients(scoreData)
end

--[[
	Record a kill and check win condition.
	@param killer Player? - The player who got the kill (nil for environment kills)
	@param victim Player - The player who died
]]
local function recordKill(killer: Player?, victim: Player)
	if killer and killer ~= victim and scores[killer] then
		scores[killer] += 1
		broadcastScores()

		-- Kill feed
		killFeedEvent:FireAllClients(killer.Name, victim.Name)

		-- Check frag limit
		if scores[killer] >= GameConfig.FRAG_LIMIT then
			endRound(killer)
		end
	else
		-- Environment kill (acid, falling) â€” notify kill feed
		killFeedEvent:FireAllClients(nil, victim.Name)
	end
end

--[[
	Setup armor for a player character.
	@param player Player
]]
local function setupPlayerArmor(player: Player)
	armorValues[player] = GameConfig.DEFAULT_ARMOR

	-- Store armor as an attribute on the character for easy access
	if player.Character then
		player.Character:SetAttribute("Armor", GameConfig.DEFAULT_ARMOR)
	end
end

--[[
	Handle player death and respawning.
	@param player Player
]]
local function onPlayerDied(player: Player)
	-- Find killer (last damager would be tracked by weapon system)
	-- For now, record as environment kill
	-- TODO: integrate with WeaponManager for kill attribution
	recordKill(nil, player)

	-- Respawn after delay
	task.delay(GameConfig.RESPAWN_DELAY, function()
		if player and player.Parent and gameState == GameConfig.STATE_ACTIVE then
			player:LoadCharacter()
		end
	end)
end

--[[
	Setup a player's character when it spawns.
	@param player Player
	@param character Model
]]
local function onCharacterAdded(player: Player, character: Model)
	local humanoid = character:WaitForChild("Humanoid")

	-- Set health
	humanoid.MaxHealth = GameConfig.DEFAULT_HEALTH
	humanoid.Health = GameConfig.DEFAULT_HEALTH

	-- Setup armor
	setupPlayerArmor(player)

	-- Teleport to a spawn point
	local rootPart = character:WaitForChild("HumanoidRootPart")
	rootPart.CFrame = getRandomSpawn() * CFrame.new(0, 3, 0)

	-- Listen for death
	humanoid.Died:Connect(function()
		onPlayerDied(player)
	end)
end

--------------------------------------------------------------------------------
-- Player Connection
--------------------------------------------------------------------------------

local function onPlayerAdded(player: Player)
	scores[player] = 0

	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)

	-- Load character immediately if game is active
	if gameState == GameConfig.STATE_ACTIVE or gameState == GameConfig.STATE_WARMUP then
		player:LoadCharacter()
	end

	broadcastScores()
end

local function onPlayerRemoving(player: Player)
	scores[player] = nil
	armorValues[player] = nil
	broadcastScores()
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Setup any players already connected
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

--------------------------------------------------------------------------------
-- Round Lifecycle
--------------------------------------------------------------------------------

--[[
	Start a new round.
]]
local function startRound()
	-- Reset scores
	for player, _ in scores do
		scores[player] = 0
	end

	gameState = GameConfig.STATE_WARMUP
	roundTimer = GameConfig.WARMUP_TIME
	broadcastState()
	broadcastScores()

	print("[Deck22] Warmup phase (" .. GameConfig.WARMUP_TIME .. "s)")

	-- Warmup countdown
	while roundTimer > 0 and gameState == GameConfig.STATE_WARMUP do
		task.wait(1)
		roundTimer -= 1
		broadcastState()
	end

	-- Start active round
	gameState = GameConfig.STATE_ACTIVE
	roundTimer = GameConfig.ROUND_TIME
	broadcastState()

	print("[Deck22] Round started! Frag limit: " .. GameConfig.FRAG_LIMIT)

	-- Spawn all players
	for _, player in Players:GetPlayers() do
		if not player.Character or player.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
			player:LoadCharacter()
		end
	end

	-- Round timer countdown
	while roundTimer > 0 and gameState == GameConfig.STATE_ACTIVE do
		task.wait(1)
		roundTimer -= 1
		broadcastState()
	end

	-- Time's up â€” end round
	if gameState == GameConfig.STATE_ACTIVE then
		-- Find player with most kills
		local topPlayer = nil
		local topKills = 0
		for player, kills in scores do
			if kills > topKills then
				topPlayer = player
				topKills = kills
			end
		end
		endRound(topPlayer)
	end
end

--[[
	End the current round.
	@param winner Player? - The winning player (nil if no winner)
]]
endRound = function(winner: Player?)
	gameState = GameConfig.STATE_POST_ROUND
	roundTimer = GameConfig.POST_ROUND_TIME
	broadcastState()

	if winner then
		print("[Deck22] Round over! Winner: " .. winner.Name .. " with " .. (scores[winner] or 0) .. " kills")
	else
		print("[Deck22] Round over! No winner.")
	end

	-- Post-round countdown
	while roundTimer > 0 and gameState == GameConfig.STATE_POST_ROUND do
		task.wait(1)
		roundTimer -= 1
		broadcastState()
	end

	-- Restart
	print("[Deck22] Restarting round...")
	startRound()
end

--------------------------------------------------------------------------------
-- Public API for other server scripts
--------------------------------------------------------------------------------

-- Expose armor system for WeaponManager to use
local armorModule = Instance.new("BindableFunction")
armorModule.Name = "GetPlayerArmor"
armorModule.OnInvoke = function(player: Player): number
	return armorValues[player] or 0
end
armorModule.Parent = ReplicatedStorage

local setArmorModule = Instance.new("BindableFunction")
setArmorModule.Name = "SetPlayerArmor"
setArmorModule.OnInvoke = function(player: Player, amount: number)
	armorValues[player] = math.clamp(amount, 0, GameConfig.MAX_ARMOR)
	if player.Character then
		player.Character:SetAttribute("Armor", armorValues[player])
	end
end
setArmorModule.Parent = ReplicatedStorage

-- Expose kill recording for WeaponManager
local recordKillEvent = Instance.new("BindableEvent")
recordKillEvent.Name = "RecordKill"
recordKillEvent.Event:Connect(function(killer: Player?, victim: Player)
	recordKill(killer, victim)
end)
recordKillEvent.Parent = ReplicatedStorage

--------------------------------------------------------------------------------
-- Start the game loop
--------------------------------------------------------------------------------

-- Wait a moment for all systems to initialize
task.wait(2)

print("[Deck22] GameManager ready, starting first round...")
startRound()
