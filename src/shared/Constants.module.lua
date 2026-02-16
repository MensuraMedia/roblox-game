--[[
	Constants.module.lua
	Global constants for the Deck 22 deathmatch arena.
	All measurements in Roblox studs. Character height ≈ 5 studs.
]]

local Constants = {}

-- Map coordinate origin: center of acid pit floor = (0, 0, 0)
-- X = East(+)/West(-), Y = Up(+)/Down(-), Z = South(+)/North(-)

-- Structural dimensions
Constants.WALL_THICKNESS = 4
Constants.FLOOR_THICKNESS = 3
Constants.CEILING_HEIGHT = 14
Constants.CORRIDOR_WIDTH = 18
Constants.RAMP_WIDTH = 12
Constants.RAIL_HEIGHT = 4
Constants.RAIL_THICKNESS = 1

-- Level heights (Y position of floor SURFACE)
Constants.LEVEL_1_Y = 0 -- Acid pit floor (hazard)
Constants.LEVEL_2_Y = 20 -- Lower catwalks / corridor floor
Constants.LEVEL_3_Y = 40 -- Main deck (primary combat)
Constants.LEVEL_4_Y = 60 -- Upper catwalks / sniper ledge

-- Central pit dimensions
Constants.PIT_WIDTH = 100 -- X axis
Constants.PIT_LENGTH = 70 -- Z axis
Constants.PIT_DEPTH = 20 -- From L2 down to L1

-- Main deck dimensions
Constants.DECK_NORTH_WIDTH = 100
Constants.DECK_NORTH_LENGTH = 60
Constants.DECK_SOUTH_WIDTH = 100
Constants.DECK_SOUTH_LENGTH = 50

-- Overall map footprint
Constants.MAP_WIDTH = 160 -- X axis (pit + corridors on both sides)
Constants.MAP_LENGTH = 220 -- Z axis (north deck + pit + south deck + connector)

-- Hazard
Constants.ACID_DAMAGE_PER_TICK = 25
Constants.ACID_DAMAGE_INTERVAL = 0.25

-- Jump pads
Constants.JUMP_PAD_SIZE = Vector3.new(8, 1, 8)
Constants.JUMP_PAD_FORCE_DURATION = 0.1
Constants.JUMP_PAD_COOLDOWN = 0.5

-- Pickups
Constants.DEFAULT_PICKUP_RESPAWN = 15
Constants.DEFAULT_WEAPON_RESPAWN = 20

-- Game rules
Constants.FRAG_LIMIT = 25
Constants.ROUND_TIME = 600 -- 10 minutes
Constants.RESPAWN_DELAY = 3
Constants.WARMUP_TIME = 10
Constants.DEFAULT_HEALTH = 100
Constants.DEFAULT_ARMOR = 0
Constants.MAX_ARMOR = 150

-- Spawn
Constants.SPAWN_DURATION = 0

-- Collision groups
Constants.COLLISION_GROUP_DEFAULT = "Default"
Constants.COLLISION_GROUP_PICKUPS = "Pickups"
Constants.COLLISION_GROUP_HAZARD = "Hazard"

-- Tags (CollectionService)
Constants.TAG_ACID_HAZARD = "AcidHazard"
Constants.TAG_JUMP_PAD = "JumpPad"
Constants.TAG_WEAPON_SPAWN = "WeaponSpawn"
Constants.TAG_PICKUP_SPAWN = "PickupSpawn"
Constants.TAG_MAP_GEOMETRY = "MapGeometry"

return Constants
