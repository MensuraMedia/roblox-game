--[[
	PickupConfig.module.lua
	Health, armor, and ammo pickup definitions and spawn locations for Deck 22.
]]

local PickupConfig = {}

-- Pickup type definitions
PickupConfig.types = {
	HealthSmall = {
		name = "Health Vial",
		pickupType = "health",
		value = 25,
		maxStack = 100,
		color = Color3.fromRGB(0, 255, 80),
		size = Vector3.new(2, 2, 2),
	},
	HealthLarge = {
		name = "Health Pack",
		pickupType = "health",
		value = 50,
		maxStack = 100,
		color = Color3.fromRGB(0, 200, 50),
		size = Vector3.new(3, 3, 3),
	},
	ArmorSmall = {
		name = "Armor Shard",
		pickupType = "armor",
		value = 10,
		maxStack = 150,
		color = Color3.fromRGB(50, 150, 255),
		size = Vector3.new(2, 2, 2),
	},
	ArmorLarge = {
		name = "Armor Vest",
		pickupType = "armor",
		value = 50,
		maxStack = 150,
		color = Color3.fromRGB(0, 100, 255),
		size = Vector3.new(3, 3, 3),
	},
	AmmoBox = {
		name = "Ammo Box",
		pickupType = "ammo",
		value = 50,
		maxStack = 999,
		color = Color3.fromRGB(255, 200, 0),
		size = Vector3.new(2.5, 2, 2.5),
	},
}

-- Pickup spawn locations on the map
PickupConfig.spawnLocations = {
	-- Health vials on lower catwalks (risky over acid)
	{ pickupType = "HealthSmall", position = Vector3.new(30, 22, -15), respawnTime = 15 },
	{ pickupType = "HealthSmall", position = Vector3.new(-30, 22, 15), respawnTime = 15 },
	{ pickupType = "HealthSmall", position = Vector3.new(0, 22, 0), respawnTime = 15 },

	-- Health pack in east corridor
	{ pickupType = "HealthLarge", position = Vector3.new(59, 22, 0), respawnTime = 20 },

	-- Armor shards scattered across main deck
	{ pickupType = "ArmorSmall", position = Vector3.new(-15, 42, -60), respawnTime = 15 },
	{ pickupType = "ArmorSmall", position = Vector3.new(15, 42, 55), respawnTime = 15 },
	{ pickupType = "ArmorSmall", position = Vector3.new(59, 22, -40), respawnTime = 15 },
	{ pickupType = "ArmorSmall", position = Vector3.new(-59, 22, 40), respawnTime = 15 },

	-- Large armor in the armor alcove (high value, specific location)
	{ pickupType = "ArmorLarge", position = Vector3.new(-60, 42, 55), respawnTime = 30 },

	-- Ammo boxes
	{ pickupType = "AmmoBox", position = Vector3.new(40, 42, -70), respawnTime = 15 },
	{ pickupType = "AmmoBox", position = Vector3.new(-40, 42, 65), respawnTime = 15 },
	{ pickupType = "AmmoBox", position = Vector3.new(0, 22, 95), respawnTime = 15 },
}

return PickupConfig
