--[[
	WeaponConfig.module.lua
	Weapon definitions and spawn locations for Deck 22.
	All damage processing is server-authoritative via workspace:Raycast().
]]

local WeaponConfig = {}

-- Weapon stat definitions
WeaponConfig.weapons = {
	Pistol = {
		name = "Pistol",
		damage = 15,
		fireRate = 3, -- Shots per second
		range = 500,
		maxAmmo = 100, -- Generous default ammo
		reloadTime = 1.5,
		headshotMultiplier = 2,
		color = Color3.fromRGB(180, 180, 180),
		isDefault = true, -- Given on spawn
	},
	Shotgun = {
		name = "Shotgun",
		damage = 12, -- Per pellet
		pellets = 8, -- Number of pellets
		fireRate = 1.2,
		range = 80,
		maxAmmo = 40,
		reloadTime = 2,
		spread = 0.08, -- Pellet spread angle (radians)
		headshotMultiplier = 1.5,
		color = Color3.fromRGB(200, 150, 50),
	},
	RocketLauncher = {
		name = "Rocket Launcher",
		damage = 80,
		splashRadius = 15,
		splashFalloff = 0.5, -- Damage multiplier at edge of radius
		fireRate = 0.8,
		range = 300,
		maxAmmo = 20,
		reloadTime = 2.5,
		projectileSpeed = 120, -- Studs per second (not hitscan)
		headshotMultiplier = 1,
		color = Color3.fromRGB(255, 80, 30),
	},
	Sniper = {
		name = "Sniper Rifle",
		damage = 70,
		fireRate = 0.6,
		range = 1000,
		maxAmmo = 20,
		reloadTime = 2,
		headshotMultiplier = 3,
		color = Color3.fromRGB(100, 180, 255),
	},
	PulseRifle = {
		name = "Pulse Rifle",
		damage = 10,
		fireRate = 10, -- Fast fire rate
		range = 400,
		maxAmmo = 150,
		reloadTime = 2,
		headshotMultiplier = 1.5,
		color = Color3.fromRGB(150, 0, 255),
	},
}

-- Weapon spawn locations on the map
WeaponConfig.spawnLocations = {
	{
		weaponType = "RocketLauncher",
		position = Vector3.new(0, 45, -65), -- Weapon platform, Main Deck North
		respawnTime = 25,
	},
	{
		weaponType = "Shotgun",
		position = Vector3.new(-59, 21, -25), -- West corridor
		respawnTime = 20,
	},
	{
		weaponType = "Sniper",
		position = Vector3.new(-20, 61, -75), -- Sniper ledge (L4)
		respawnTime = 25,
	},
	{
		weaponType = "PulseRifle",
		position = Vector3.new(59, 21, 30), -- East corridor
		respawnTime = 20,
	},
	{
		weaponType = "Shotgun",
		position = Vector3.new(30, 21, 0), -- Lower east catwalk
		respawnTime = 20,
	},
}

return WeaponConfig
