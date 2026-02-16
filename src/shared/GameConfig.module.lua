--[[
	GameConfig.module.lua
	Game rules and balance configuration for Deck 22 deathmatch.
]]

local GameConfig = {}

-- Round settings
GameConfig.ROUND_TIME = 600 -- 10 minutes per round
GameConfig.FRAG_LIMIT = 25 -- Kills to win
GameConfig.WARMUP_TIME = 10 -- Seconds before round starts
GameConfig.POST_ROUND_TIME = 10 -- Seconds after round ends before restart
GameConfig.MIN_PLAYERS = 1 -- Minimum players to start

-- Player settings
GameConfig.DEFAULT_HEALTH = 100
GameConfig.DEFAULT_ARMOR = 0
GameConfig.MAX_HEALTH = 100
GameConfig.MAX_ARMOR = 150
GameConfig.RESPAWN_DELAY = 3

-- Armor damage reduction (fraction absorbed by armor)
GameConfig.ARMOR_ABSORPTION = 0.5 -- 50% of damage absorbed by armor

-- Game states
GameConfig.STATE_WAITING = "Waiting"
GameConfig.STATE_WARMUP = "Warmup"
GameConfig.STATE_ACTIVE = "Active"
GameConfig.STATE_POST_ROUND = "PostRound"

return GameConfig
