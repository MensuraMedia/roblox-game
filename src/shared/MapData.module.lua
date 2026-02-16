--[[
	MapData.module.lua
	Complete map layout definition for Deck 22.
	Pure data tables consumed by MapBuilder via MapBootstrap.

	Coordinate system:
	  Origin (0,0,0) = center of acid pit floor
	  X = East(+) / West(-)
	  Y = Up(+) / Down(-)
	  Z = South(+) / North(-)

	Levels:
	  L1 Y=0   Acid pit (lethal)
	  L2 Y=20  Lower catwalks, corridor floor
	  L3 Y=40  Main deck (primary combat)
	  L4 Y=60  Upper catwalks, sniper ledge
]]

local Constants = require(script.Parent.Constants)

local MapData = {}

--------------------------------------------------------------------------------
-- Central Acid Pit (L1)
--------------------------------------------------------------------------------

MapData.centralPit = {
	-- Pit walls: 4 walls enclosing the pit from L1 to L2
	walls = {
		-- North pit wall
		{
			name = "PitWallNorth",
			size = Vector3.new(100, 20, Constants.WALL_THICKNESS),
			position = Vector3.new(0, 10, -35 - Constants.WALL_THICKNESS / 2),
		},
		-- South pit wall
		{
			name = "PitWallSouth",
			size = Vector3.new(100, 20, Constants.WALL_THICKNESS),
			position = Vector3.new(0, 10, 35 + Constants.WALL_THICKNESS / 2),
		},
		-- East pit wall
		{
			name = "PitWallEast",
			size = Vector3.new(Constants.WALL_THICKNESS, 20, 70),
			position = Vector3.new(50 + Constants.WALL_THICKNESS / 2, 10, 0),
		},
		-- West pit wall
		{
			name = "PitWallWest",
			size = Vector3.new(Constants.WALL_THICKNESS, 20, 70),
			position = Vector3.new(-50 - Constants.WALL_THICKNESS / 2, 10, 0),
		},
	},

	-- Acid visual surface (neon green, non-collidable, slightly above pit floor)
	acidSurface = {
		name = "AcidSurface",
		size = Vector3.new(98, 1, 68),
		position = Vector3.new(0, 1, 0),
		canCollide = false,
		transparency = 0.3,
	},

	-- Hazard detection zone (invisible, covers pit volume)
	hazardZone = {
		name = "AcidHazardZone",
		size = Vector3.new(98, 6, 68),
		position = Vector3.new(0, 3, 0),
	},

	-- Pit bottom floor (solid, below acid)
	floor = {
		name = "PitFloor",
		size = Vector3.new(100, Constants.FLOOR_THICKNESS, 70),
		position = Vector3.new(0, -Constants.FLOOR_THICKNESS / 2, 0),
	},
}

--------------------------------------------------------------------------------
-- Lower Catwalks (L2, Y=20) — Over the acid pit
--------------------------------------------------------------------------------

MapData.lowerCatwalks = {
	-- North-South catwalk (east side of pit)
	eastCatwalk = {
		name = "LowerCatwalkEast",
		position = Vector3.new(30, 20),
		size = Vector3.new(8, Constants.FLOOR_THICKNESS, 68),
		railHeight = Constants.RAIL_HEIGHT,
		railSides = "EW",
	},
	-- North-South catwalk (west side of pit)
	westCatwalk = {
		name = "LowerCatwalkWest",
		position = Vector3.new(-30, 20, 0),
		size = Vector3.new(8, Constants.FLOOR_THICKNESS, 68),
		railHeight = Constants.RAIL_HEIGHT,
		railSides = "EW",
	},
	-- East-West cross catwalk (center)
	crossCatwalk = {
		name = "LowerCatwalkCross",
		position = Vector3.new(0, 20, 0),
		size = Vector3.new(68, Constants.FLOOR_THICKNESS, 8),
		railHeight = Constants.RAIL_HEIGHT,
		railSides = "NS",
	},
}

--------------------------------------------------------------------------------
-- Main Deck North (L3, Y=40) — Large open combat hall
--------------------------------------------------------------------------------

MapData.mainDeckNorth = {
	room = {
		name = "MainDeckNorth",
		origin = Vector3.new(0, 40, -65),
		width = 100,
		length = 60,
		height = Constants.CEILING_HEIGHT,
		noWallSouth = true, -- Opens to pit overlook
		noWallEast = true, -- Opens to east corridor
		noWallWest = true, -- Opens to west corridor
	},

	-- Support columns (4 pillars)
	columns = {
		{ position = Vector3.new(-25, 47, -80), size = Vector3.new(6, 14, 6) },
		{ position = Vector3.new(25, 47, -80), size = Vector3.new(6, 14, 6) },
		{ position = Vector3.new(-25, 47, -50), size = Vector3.new(6, 14, 6) },
		{ position = Vector3.new(25, 47, -50), size = Vector3.new(6, 14, 6) },
	},

	-- Elevated weapon platform in center
	weaponPlatform = {
		name = "WeaponPlatform",
		position = Vector3.new(0, 44, -65),
		size = Vector3.new(14, 1, 14),
		railHeight = 0,
	},

	-- Steps up to weapon platform (small ramp)
	weaponSteps = {
		name = "WeaponSteps",
		size = Vector3.new(14, 4, 6),
		bottomCenter = Vector3.new(0, 40, -58),
		topCenter = Vector3.new(0, 44, -58),
	},

	-- South edge railing (overlook into pit)
	pitOverlookRail = {
		name = "NorthDeckPitRail",
		position = Vector3.new(0, 42, -35),
		size = Vector3.new(100, Constants.RAIL_HEIGHT, Constants.RAIL_THICKNESS),
	},
}

--------------------------------------------------------------------------------
-- Main Deck South (L3, Y=40) — Tighter combat area
--------------------------------------------------------------------------------

MapData.mainDeckSouth = {
	room = {
		name = "MainDeckSouth",
		origin = Vector3.new(0, 40, 60),
		width = 100,
		length = 50,
		height = Constants.CEILING_HEIGHT,
		noWallNorth = true, -- Opens to pit overlook
		noWallEast = true, -- Opens to east corridor
		noWallWest = true, -- Opens to west corridor
	},

	-- North edge railing (overlook into pit)
	pitOverlookRail = {
		name = "SouthDeckPitRail",
		position = Vector3.new(0, 42, 35),
		size = Vector3.new(100, Constants.RAIL_HEIGHT, Constants.RAIL_THICKNESS),
	},

	-- Armor alcove (recessed room off west wall)
	armorAlcove = {
		name = "ArmorAlcove",
		origin = Vector3.new(-60, 40, 55),
		width = 16,
		length = 16,
		height = Constants.CEILING_HEIGHT,
		noWallEast = true, -- Opens into main deck south
	},
}

--------------------------------------------------------------------------------
-- U-Shaped Corridor System (L2-L3)
--------------------------------------------------------------------------------

MapData.corridorEast = {
	name = "CorridorEast",
	origin = Vector3.new(59, 20, 0),
	width = Constants.CORRIDOR_WIDTH,
	length = 170,
	height = 34, -- Spans from L2 to almost L3 ceiling
	direction = "NS",
	noWallWest = true, -- Inner wall has openings to pit/decks

	-- Inner wall segments (with gaps for connections)
	innerWalls = {
		-- Wall between pit and corridor (L2 level section)
		{
			name = "EastInnerWallPit",
			size = Vector3.new(Constants.WALL_THICKNESS, 20, 70),
			position = Vector3.new(50 + Constants.WALL_THICKNESS / 2, 30, 0),
		},
	},

	-- Floor at L2 level
	floor = {
		name = "CorridorEastFloor",
		size = Vector3.new(Constants.CORRIDOR_WIDTH, Constants.FLOOR_THICKNESS, 170),
		position = Vector3.new(59, 20 - Constants.FLOOR_THICKNESS / 2, 0),
	},
}

MapData.corridorWest = {
	name = "CorridorWest",
	origin = Vector3.new(-59, 20, 0),
	width = Constants.CORRIDOR_WIDTH,
	length = 170,
	height = 34,
	direction = "NS",
	noWallEast = true,

	innerWalls = {
		{
			name = "WestInnerWallPit",
			size = Vector3.new(Constants.WALL_THICKNESS, 20, 70),
			position = Vector3.new(-50 - Constants.WALL_THICKNESS / 2, 30, 0),
		},
	},

	floor = {
		name = "CorridorWestFloor",
		size = Vector3.new(Constants.CORRIDOR_WIDTH, Constants.FLOOR_THICKNESS, 170),
		position = Vector3.new(-59, 20 - Constants.FLOOR_THICKNESS / 2, 0),
	},
}

MapData.corridorConnector = {
	name = "CorridorConnector",
	origin = Vector3.new(0, 20, 95),
	width = Constants.CORRIDOR_WIDTH,
	length = 136, -- Spans between east and west corridors
	height = Constants.CEILING_HEIGHT,
	direction = "EW",
}

--------------------------------------------------------------------------------
-- Outer Walls (Map boundary)
--------------------------------------------------------------------------------

MapData.outerWalls = {
	-- East outer wall
	{
		name = "OuterWallEast",
		size = Vector3.new(Constants.WALL_THICKNESS, 70, 220),
		position = Vector3.new(68 + Constants.WALL_THICKNESS / 2, 35, 0),
	},
	-- West outer wall
	{
		name = "OuterWallWest",
		size = Vector3.new(Constants.WALL_THICKNESS, 70, 220),
		position = Vector3.new(-68 - Constants.WALL_THICKNESS / 2, 35, 0),
	},
	-- North outer wall
	{
		name = "OuterWallNorth",
		size = Vector3.new(140, 70, Constants.WALL_THICKNESS),
		position = Vector3.new(0, 35, -95 - Constants.WALL_THICKNESS / 2),
	},
	-- South outer wall
	{
		name = "OuterWallSouth",
		size = Vector3.new(140, 70, Constants.WALL_THICKNESS),
		position = Vector3.new(0, 35, 105 + Constants.WALL_THICKNESS / 2),
	},
	-- Map ceiling
	{
		name = "MapCeiling",
		size = Vector3.new(140, Constants.FLOOR_THICKNESS, 220),
		position = Vector3.new(0, 70 + Constants.FLOOR_THICKNESS / 2, 0),
	},
}

--------------------------------------------------------------------------------
-- Three Diagonal Ramps
--------------------------------------------------------------------------------

MapData.ramps = {
	-- NE Ramp: L2 (east catwalk area) → L3 (Main Deck North)
	{
		name = "RampNorthEast",
		bottomCenter = Vector3.new(38, 20, -20),
		topCenter = Vector3.new(38, 40, -45),
		width = Constants.RAMP_WIDTH,
		railHeight = Constants.RAIL_HEIGHT,
	},
	-- SE Ramp: L2 (east catwalk area) → L3 (Main Deck South)
	{
		name = "RampSouthEast",
		bottomCenter = Vector3.new(38, 20, 20),
		topCenter = Vector3.new(38, 40, 45),
		width = Constants.RAMP_WIDTH,
		railHeight = Constants.RAIL_HEIGHT,
	},
	-- West Ramp: L3 (west corridor) → L4 (upper catwalks / sniper ledge)
	{
		name = "RampWest",
		bottomCenter = Vector3.new(-45, 40, 10),
		topCenter = Vector3.new(-45, 60, -25),
		width = 10, -- Narrower, more dangerous
		railHeight = Constants.RAIL_HEIGHT,
	},
}

--------------------------------------------------------------------------------
-- Upper Catwalks / Sniper Ledge (L4, Y=60)
--------------------------------------------------------------------------------

MapData.upperCatwalks = {
	-- Main sniper ledge platform (overlooking everything)
	sniperLedge = {
		name = "SniperLedge",
		position = Vector3.new(-20, 60, -75),
		size = Vector3.new(20, Constants.FLOOR_THICKNESS, 12),
		railHeight = Constants.RAIL_HEIGHT,
		railSides = "SE", -- Open toward north wall, rails on south and east
	},
	-- Connecting catwalk from west ramp to sniper ledge
	westUpperCatwalk = {
		name = "UpperCatwalkWest",
		position = Vector3.new(-45, 60, -50),
		size = Vector3.new(8, Constants.FLOOR_THICKNESS, 40),
		railHeight = Constants.RAIL_HEIGHT,
		railSides = "EW",
	},
	-- North upper catwalk (runs along north wall)
	northUpperCatwalk = {
		name = "UpperCatwalkNorth",
		position = Vector3.new(-10, 60, -85),
		size = Vector3.new(60, Constants.FLOOR_THICKNESS, 8),
		railHeight = Constants.RAIL_HEIGHT,
		railSides = "S", -- Rail on south side (open to map below)
	},
}

--------------------------------------------------------------------------------
-- L3 Floor Sections (connecting rooms to corridors)
--------------------------------------------------------------------------------

MapData.deckFloors = {
	-- Floor bridge from north deck to east corridor at L3
	{
		name = "NorthEastBridge",
		size = Vector3.new(18, Constants.FLOOR_THICKNESS, 60),
		position = Vector3.new(59, 40 - Constants.FLOOR_THICKNESS / 2, -65),
	},
	-- Floor bridge from north deck to west corridor at L3
	{
		name = "NorthWestBridge",
		size = Vector3.new(18, Constants.FLOOR_THICKNESS, 60),
		position = Vector3.new(-59, 40 - Constants.FLOOR_THICKNESS / 2, -65),
	},
	-- Floor bridge from south deck to east corridor at L3
	{
		name = "SouthEastBridge",
		size = Vector3.new(18, Constants.FLOOR_THICKNESS, 50),
		position = Vector3.new(59, 40 - Constants.FLOOR_THICKNESS / 2, 60),
	},
	-- Floor bridge from south deck to west corridor at L3
	{
		name = "SouthWestBridge",
		size = Vector3.new(18, Constants.FLOOR_THICKNESS, 50),
		position = Vector3.new(-59, 40 - Constants.FLOOR_THICKNESS / 2, 60),
	},
}

--------------------------------------------------------------------------------
-- Spawn Points (8 locations)
--------------------------------------------------------------------------------

MapData.spawnPoints = {
	-- Main Deck North (2)
	CFrame.new(-20, 40, -70),
	CFrame.new(20, 40, -60),
	-- Main Deck South (2)
	CFrame.new(-15, 40, 55),
	CFrame.new(20, 40, 65),
	-- East Corridor (1)
	CFrame.new(59, 20, -10),
	-- West Corridor (1)
	CFrame.new(-59, 20, 10),
	-- Upper Catwalk (1)
	CFrame.new(-35, 60, -55),
	-- Lower Catwalk (1)
	CFrame.new(30, 20, -15),
}

--------------------------------------------------------------------------------
-- Jump Pads (3)
--------------------------------------------------------------------------------

MapData.jumpPads = {
	-- South connector → launches up to L4 upper catwalks
	{
		name = "JumpPadSouth",
		position = Vector3.new(0, 20, 95),
		launchVector = Vector3.new(0, 120, -40),
	},
	-- Pit-edge escape → launches from L2 east up to L3 east corridor
	{
		name = "JumpPadEastEscape",
		position = Vector3.new(45, 20, 10),
		launchVector = Vector3.new(15, 80, 0),
	},
	-- North deck → launches up to sniper ledge
	{
		name = "JumpPadToSniper",
		position = Vector3.new(-10, 40, -75),
		launchVector = Vector3.new(-10, 70, -10),
	},
}

--------------------------------------------------------------------------------
-- Decorations
--------------------------------------------------------------------------------

MapData.crates = {
	{ position = Vector3.new(-35, 20, 90), count = 3, seed = 1 },
	{ position = Vector3.new(35, 20, 90), count = 2, seed = 2 },
	{ position = Vector3.new(-40, 40, -50), count = 4, seed = 3 },
	{ position = Vector3.new(40, 40, 55), count = 3, seed = 4 },
	{ position = Vector3.new(55, 20, -40), count = 2, seed = 5 },
}

MapData.pipes = {
	-- Pipe run along north pit wall
	{ startPos = Vector3.new(-48, 15, -33), endPos = Vector3.new(48, 15, -33), radius = 1.5 },
	-- Pipe run along east pit wall
	{ startPos = Vector3.new(48, 8, -33), endPos = Vector3.new(48, 8, 33), radius = 1 },
	-- Pipe along south corridor ceiling
	{ startPos = Vector3.new(-50, 32, 95), endPos = Vector3.new(50, 32, 95), radius = 1.5 },
	-- Vertical pipe on west wall
	{ startPos = Vector3.new(-66, 5, -20), endPos = Vector3.new(-66, 55, -20), radius = 1 },
}

MapData.hazardStripes = {
	-- Pit edges (hazard warning on L2 catwalks near pit)
	{ position = Vector3.new(0, 20.1, -34), size = Vector3.new(98, 0.2, 1) },
	{ position = Vector3.new(0, 20.1, 34), size = Vector3.new(98, 0.2, 1) },
	{ position = Vector3.new(49, 20.1, 0), size = Vector3.new(1, 0.2, 68) },
	{ position = Vector3.new(-49, 20.1, 0), size = Vector3.new(1, 0.2, 68) },
}

MapData.lightPanels = {
	-- North deck ceiling lights
	{ position = Vector3.new(-20, 53.5, -70) },
	{ position = Vector3.new(20, 53.5, -70) },
	{ position = Vector3.new(0, 53.5, -55) },
	-- South deck ceiling lights
	{ position = Vector3.new(-20, 53.5, 55) },
	{ position = Vector3.new(20, 53.5, 65) },
	-- Corridor lights
	{ position = Vector3.new(59, 33.5, -30) },
	{ position = Vector3.new(59, 33.5, 30) },
	{ position = Vector3.new(-59, 33.5, -30) },
	{ position = Vector3.new(-59, 33.5, 30) },
	-- Upper catwalk light
	{ position = Vector3.new(-20, 69.5, -75) },
}

return MapData
