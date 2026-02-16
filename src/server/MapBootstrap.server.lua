--[[
	MapBootstrap.server.lua
	Server entry point: builds the Deck 22 map geometry from MapData using MapBuilder.
	Runs once on server start before any players join.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MapBuilder = require(ReplicatedStorage.MapBuilder)
local MapData = require(ReplicatedStorage.MapData)
local MaterialPalette = require(ReplicatedStorage.MaterialPalette)
local Constants = require(ReplicatedStorage.Constants)

print("[Deck22] Map construction starting...")

-- Setup collision groups before creating any parts
MapBuilder.setupCollisionGroups()

-- Create root container for all map geometry
local mapModel = Instance.new("Model")
mapModel.Name = "Deck22Map"

--------------------------------------------------------------------------------
-- 1. Central Acid Pit (L1)
--------------------------------------------------------------------------------

local pitGroup = Instance.new("Model")
pitGroup.Name = "CentralPit"

-- Pit bottom floor
MapBuilder.createPart({
	name = MapData.centralPit.floor.name,
	size = MapData.centralPit.floor.size,
	position = MapData.centralPit.floor.position,
	preset = MaterialPalette.GRATING,
}, pitGroup)

-- Pit walls
for _, wallDef in MapData.centralPit.walls do
	MapBuilder.createPart({
		name = wallDef.name,
		size = wallDef.size,
		position = wallDef.position,
		preset = MaterialPalette.WALL_HULL,
	}, pitGroup)
end

-- Acid visual surface
local acidDef = MapData.centralPit.acidSurface
MapBuilder.createPart({
	name = acidDef.name,
	size = acidDef.size,
	position = acidDef.position,
	preset = MaterialPalette.ACID,
	canCollide = acidDef.canCollide,
	transparency = acidDef.transparency,
}, pitGroup)

-- Hazard detection zone
local hazDef = MapData.centralPit.hazardZone
MapBuilder.createHazardZone({
	name = hazDef.name,
	size = hazDef.size,
	position = hazDef.position,
}, pitGroup)

pitGroup.Parent = mapModel

print("[Deck22] Central pit built")

--------------------------------------------------------------------------------
-- 2. Lower Catwalks (L2)
--------------------------------------------------------------------------------

local catwalkGroup = Instance.new("Model")
catwalkGroup.Name = "LowerCatwalks"

for _, catwalkData in pairs(MapData.lowerCatwalks) do
	MapBuilder.createPlatform({
		name = catwalkData.name,
		position = Vector3.new(
			catwalkData.position.X,
			catwalkData.position.Y or 20,
			catwalkData.position.Z or 0
		),
		size = catwalkData.size,
		preset = MaterialPalette.GRATING,
		railHeight = catwalkData.railHeight,
		railSides = catwalkData.railSides,
	}, catwalkGroup)
end

catwalkGroup.Parent = mapModel

print("[Deck22] Lower catwalks built")

--------------------------------------------------------------------------------
-- 3. Main Deck North (L3)
--------------------------------------------------------------------------------

local northDeckGroup = Instance.new("Model")
northDeckGroup.Name = "MainDeckNorth"

-- Main room structure
MapBuilder.createRoom(MapData.mainDeckNorth.room, northDeckGroup)

-- Columns
for i, colDef in MapData.mainDeckNorth.columns do
	MapBuilder.createPart({
		name = "Column_" .. i,
		size = colDef.size,
		position = colDef.position,
		preset = MaterialPalette.COLUMN,
	}, northDeckGroup)
end

-- Weapon platform
MapBuilder.createPlatform({
	name = MapData.mainDeckNorth.weaponPlatform.name,
	position = MapData.mainDeckNorth.weaponPlatform.position,
	size = MapData.mainDeckNorth.weaponPlatform.size,
	preset = MaterialPalette.FLOOR_METAL,
	railHeight = 0,
}, northDeckGroup)

-- Pit overlook railing
local railDef = MapData.mainDeckNorth.pitOverlookRail
MapBuilder.createPart({
	name = railDef.name,
	size = railDef.size,
	position = railDef.position,
	preset = MaterialPalette.CATWALK_RAIL,
}, northDeckGroup)

northDeckGroup.Parent = mapModel

print("[Deck22] Main Deck North built")

--------------------------------------------------------------------------------
-- 4. Main Deck South (L3)
--------------------------------------------------------------------------------

local southDeckGroup = Instance.new("Model")
southDeckGroup.Name = "MainDeckSouth"

-- Main room structure
MapBuilder.createRoom(MapData.mainDeckSouth.room, southDeckGroup)

-- Pit overlook railing
local southRailDef = MapData.mainDeckSouth.pitOverlookRail
MapBuilder.createPart({
	name = southRailDef.name,
	size = southRailDef.size,
	position = southRailDef.position,
	preset = MaterialPalette.CATWALK_RAIL,
}, southDeckGroup)

-- Armor alcove
MapBuilder.createRoom(MapData.mainDeckSouth.armorAlcove, southDeckGroup)

southDeckGroup.Parent = mapModel

print("[Deck22] Main Deck South built")

--------------------------------------------------------------------------------
-- 5. Corridors
--------------------------------------------------------------------------------

local corridorGroup = Instance.new("Model")
corridorGroup.Name = "Corridors"

-- East corridor outer wall + floor
MapBuilder.createPart({
	name = "CorridorEastOuterWall",
	size = Vector3.new(Constants.WALL_THICKNESS, 34, 170),
	position = Vector3.new(68, 37, 0),
	preset = MaterialPalette.WALL_HULL,
}, corridorGroup)

MapBuilder.createPart({
	name = MapData.corridorEast.floor.name,
	size = MapData.corridorEast.floor.size,
	position = MapData.corridorEast.floor.position,
	preset = MaterialPalette.FLOOR_METAL,
}, corridorGroup)

-- East corridor ceiling
MapBuilder.createPart({
	name = "CorridorEastCeiling",
	size = Vector3.new(Constants.CORRIDOR_WIDTH, Constants.FLOOR_THICKNESS, 170),
	position = Vector3.new(59, 54 + Constants.FLOOR_THICKNESS / 2, 0),
	preset = MaterialPalette.CEILING,
}, corridorGroup)

-- West corridor outer wall + floor
MapBuilder.createPart({
	name = "CorridorWestOuterWall",
	size = Vector3.new(Constants.WALL_THICKNESS, 34, 170),
	position = Vector3.new(-68, 37, 0),
	preset = MaterialPalette.WALL_HULL,
}, corridorGroup)

MapBuilder.createPart({
	name = MapData.corridorWest.floor.name,
	size = MapData.corridorWest.floor.size,
	position = MapData.corridorWest.floor.position,
	preset = MaterialPalette.FLOOR_METAL,
}, corridorGroup)

-- West corridor ceiling
MapBuilder.createPart({
	name = "CorridorWestCeiling",
	size = Vector3.new(Constants.CORRIDOR_WIDTH, Constants.FLOOR_THICKNESS, 170),
	position = Vector3.new(-59, 54 + Constants.FLOOR_THICKNESS / 2, 0),
	preset = MaterialPalette.CEILING,
}, corridorGroup)

-- South connector corridor
MapBuilder.createCorridor({
	name = MapData.corridorConnector.name,
	origin = MapData.corridorConnector.origin,
	width = MapData.corridorConnector.width,
	length = MapData.corridorConnector.length,
	height = MapData.corridorConnector.height,
	direction = MapData.corridorConnector.direction,
}, corridorGroup)

corridorGroup.Parent = mapModel

print("[Deck22] Corridors built")

--------------------------------------------------------------------------------
-- 6. L3 Deck Floor Bridges (connecting rooms to corridors)
--------------------------------------------------------------------------------

local bridgeGroup = Instance.new("Model")
bridgeGroup.Name = "DeckFloors"

for _, bridgeDef in MapData.deckFloors do
	MapBuilder.createPart({
		name = bridgeDef.name,
		size = bridgeDef.size,
		position = bridgeDef.position,
		preset = MaterialPalette.FLOOR_METAL,
	}, bridgeGroup)
end

bridgeGroup.Parent = mapModel

print("[Deck22] Deck floor bridges built")

--------------------------------------------------------------------------------
-- 7. Outer Walls + Map Ceiling
--------------------------------------------------------------------------------

local outerGroup = Instance.new("Model")
outerGroup.Name = "OuterWalls"

for _, wallDef in MapData.outerWalls do
	local preset = MaterialPalette.WALL_HULL
	if wallDef.name == "MapCeiling" then
		preset = MaterialPalette.CEILING
	end
	MapBuilder.createPart({
		name = wallDef.name,
		size = wallDef.size,
		position = wallDef.position,
		preset = preset,
	}, outerGroup)
end

outerGroup.Parent = mapModel

print("[Deck22] Outer walls built")

--------------------------------------------------------------------------------
-- 8. Ramps
--------------------------------------------------------------------------------

local rampGroup = Instance.new("Model")
rampGroup.Name = "Ramps"

for _, rampDef in MapData.ramps do
	MapBuilder.createRamp(rampDef, rampGroup)
end

rampGroup.Parent = mapModel

print("[Deck22] Ramps built")

--------------------------------------------------------------------------------
-- 9. Upper Catwalks / Sniper Ledge (L4)
--------------------------------------------------------------------------------

local upperGroup = Instance.new("Model")
upperGroup.Name = "UpperCatwalks"

for _, catwalkData in pairs(MapData.upperCatwalks) do
	MapBuilder.createPlatform({
		name = catwalkData.name,
		position = catwalkData.position,
		size = catwalkData.size,
		preset = MaterialPalette.GRATING,
		railHeight = catwalkData.railHeight,
		railSides = catwalkData.railSides,
	}, upperGroup)
end

upperGroup.Parent = mapModel

print("[Deck22] Upper catwalks built")

--------------------------------------------------------------------------------
-- 10. Spawn Points
--------------------------------------------------------------------------------

for _, spawnCF in MapData.spawnPoints do
	MapBuilder.createSpawn(spawnCF, mapModel)
end

print("[Deck22] " .. #MapData.spawnPoints .. " spawn points placed")

--------------------------------------------------------------------------------
-- 11. Jump Pads
--------------------------------------------------------------------------------

for _, padDef in MapData.jumpPads do
	MapBuilder.createJumpPad(padDef, mapModel)
end

print("[Deck22] " .. #MapData.jumpPads .. " jump pads placed")

--------------------------------------------------------------------------------
-- 12. Decorations
--------------------------------------------------------------------------------

local decoGroup = Instance.new("Model")
decoGroup.Name = "Decorations"

-- Crate clusters
for _, crateDef in MapData.crates do
	MapBuilder.createCrateCluster(crateDef, decoGroup)
end

-- Pipe runs
for _, pipeDef in MapData.pipes do
	MapBuilder.createPipeRun(pipeDef, decoGroup)
end

-- Hazard stripes
for _, stripeDef in MapData.hazardStripes do
	MapBuilder.createHazardStripe(stripeDef, decoGroup)
end

-- Light panels
for _, lightDef in MapData.lightPanels do
	MapBuilder.createLightPanel(lightDef, decoGroup)
end

decoGroup.Parent = mapModel

print("[Deck22] Decorations placed")

--------------------------------------------------------------------------------
-- 13. Parent entire map to workspace
--------------------------------------------------------------------------------

mapModel.Parent = workspace

-- Count total parts
local partCount = 0
for _, descendant in mapModel:GetDescendants() do
	if descendant:IsA("BasePart") then
		partCount += 1
	end
end

print("[Deck22] Map construction complete! Total parts: " .. partCount)

-- Signal that map is ready (other server scripts can listen for this)
workspace:SetAttribute("MapReady", true)
