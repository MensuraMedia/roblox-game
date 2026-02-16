--[[
	MapBuilder.module.lua
	Core geometry construction utilities for Deck 22.
	Provides declarative helpers to build rooms, corridors, ramps,
	platforms, hazard zones, jump pads, and decorations from data tables.
]]

local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")

local MaterialPalette = require(script.Parent.MaterialPalette)
local Constants = require(script.Parent.Constants)

local MapBuilder = {}

--------------------------------------------------------------------------------
-- Collision Groups
--------------------------------------------------------------------------------

--[[
	Register collision groups so pickup visuals don't block player movement.
	Must be called once before any pickups are created.
]]
function MapBuilder.setupCollisionGroups()
	PhysicsService:RegisterCollisionGroup(Constants.COLLISION_GROUP_PICKUPS)
	PhysicsService:RegisterCollisionGroup(Constants.COLLISION_GROUP_HAZARD)

	-- Players can walk through pickups
	PhysicsService:CollisionGroupSetCollidable(
		Constants.COLLISION_GROUP_DEFAULT,
		Constants.COLLISION_GROUP_PICKUPS,
		false
	)

	-- Players can walk through hazard detection zones
	PhysicsService:CollisionGroupSetCollidable(
		Constants.COLLISION_GROUP_DEFAULT,
		Constants.COLLISION_GROUP_HAZARD,
		false
	)
end

--------------------------------------------------------------------------------
-- Core Part Creation
--------------------------------------------------------------------------------

--[[
	Create a single anchored Part from a definition table.
	@param def table {
		size: Vector3,
		position: Vector3,
		rotation: Vector3? (euler degrees),
		preset: table? (MaterialPalette preset),
		material: Enum.Material?,
		color: Color3?,
		transparency: number?,
		canCollide: boolean?,
		name: string?,
		tags: { string }?,
		collisionGroup: string?,
	}
	@param parent Instance - Where to parent the part
	@return BasePart
]]
function MapBuilder.createPart(def: { [string]: any }, parent: Instance): BasePart
	local part = Instance.new("Part")
	part.Size = def.size
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth

	-- Position and rotation
	if def.rotation then
		local rx = math.rad(def.rotation.X)
		local ry = math.rad(def.rotation.Y)
		local rz = math.rad(def.rotation.Z)
		part.CFrame = CFrame.new(def.position) * CFrame.Angles(rx, ry, rz)
	else
		part.Position = def.position
	end

	-- Material and color
	if def.preset then
		MaterialPalette.apply(part, def.preset)
	end
	if def.material then
		part.Material = def.material
	end
	if def.color then
		part.Color = def.color
	end

	-- Optional properties
	if def.transparency then
		part.Transparency = def.transparency
	end
	if def.canCollide ~= nil then
		part.CanCollide = def.canCollide
	end
	if def.name then
		part.Name = def.name
	end
	if def.collisionGroup then
		part.CollisionGroup = def.collisionGroup
	end

	-- Tags for CollectionService
	if def.tags then
		for _, tag in def.tags do
			CollectionService:AddTag(part, tag)
		end
	end

	part.Parent = parent
	return part
end

--[[
	Create a WedgePart for ramp surfaces.
	The wedge slopes from the full-height face to the zero-height edge.
	@param def table - Same fields as createPart
	@param parent Instance
	@return WedgePart
]]
function MapBuilder.createWedge(def: { [string]: any }, parent: Instance): BasePart
	local wedge = Instance.new("WedgePart")
	wedge.Size = def.size
	wedge.Anchored = true
	wedge.TopSurface = Enum.SurfaceType.Smooth
	wedge.BottomSurface = Enum.SurfaceType.Smooth

	if def.rotation then
		local rx = math.rad(def.rotation.X)
		local ry = math.rad(def.rotation.Y)
		local rz = math.rad(def.rotation.Z)
		wedge.CFrame = CFrame.new(def.position) * CFrame.Angles(rx, ry, rz)
	else
		wedge.Position = def.position
	end

	if def.preset then
		MaterialPalette.apply(wedge, def.preset)
	end
	if def.material then
		wedge.Material = def.material
	end
	if def.color then
		wedge.Color = def.color
	end
	if def.transparency then
		wedge.Transparency = def.transparency
	end
	if def.canCollide ~= nil then
		wedge.CanCollide = def.canCollide
	end
	if def.name then
		wedge.Name = def.name
	end
	if def.tags then
		for _, tag in def.tags do
			CollectionService:AddTag(wedge, tag)
		end
	end

	wedge.Parent = parent
	return wedge
end

--------------------------------------------------------------------------------
-- Room Builder
--------------------------------------------------------------------------------

--[[
	Create a box room with floor, ceiling, and 4 walls.
	Walls can have openings cut out (via skip logic).
	@param config table {
		name: string,
		origin: Vector3 (center of floor surface),
		width: number (X), length: number (Z), height: number (Y),
		wallThickness: number?, floorThickness: number?,
		floorPreset: table?, wallPreset: table?, ceilingPreset: table?,
		noFloor: boolean?, noCeiling: boolean?,
		noWallNorth: boolean?, noWallSouth: boolean?,
		noWallEast: boolean?, noWallWest: boolean?,
	}
	@param parent Instance
	@return Model
]]
function MapBuilder.createRoom(config: { [string]: any }, parent: Instance): Model
	local model = Instance.new("Model")
	model.Name = config.name or "Room"

	local wt = config.wallThickness or Constants.WALL_THICKNESS
	local ft = config.floorThickness or Constants.FLOOR_THICKNESS
	local w = config.width
	local l = config.length
	local h = config.height or Constants.CEILING_HEIGHT
	local o = config.origin

	local floorPreset = config.floorPreset or MaterialPalette.FLOOR_METAL
	local wallPreset = config.wallPreset or MaterialPalette.WALL_HULL
	local ceilingPreset = config.ceilingPreset or MaterialPalette.CEILING

	-- Floor
	if not config.noFloor then
		MapBuilder.createPart({
			name = config.name .. "_Floor",
			size = Vector3.new(w, ft, l),
			position = Vector3.new(o.X, o.Y - ft / 2, o.Z),
			preset = floorPreset,
		}, model)
	end

	-- Ceiling
	if not config.noCeiling then
		MapBuilder.createPart({
			name = config.name .. "_Ceiling",
			size = Vector3.new(w, ft, l),
			position = Vector3.new(o.X, o.Y + h + ft / 2, o.Z),
			preset = ceilingPreset,
		}, model)
	end

	-- North wall (negative Z face)
	if not config.noWallNorth then
		MapBuilder.createPart({
			name = config.name .. "_WallNorth",
			size = Vector3.new(w, h, wt),
			position = Vector3.new(o.X, o.Y + h / 2, o.Z - l / 2 - wt / 2),
			preset = wallPreset,
		}, model)
	end

	-- South wall (positive Z face)
	if not config.noWallSouth then
		MapBuilder.createPart({
			name = config.name .. "_WallSouth",
			size = Vector3.new(w, h, wt),
			position = Vector3.new(o.X, o.Y + h / 2, o.Z + l / 2 + wt / 2),
			preset = wallPreset,
		}, model)
	end

	-- East wall (positive X face)
	if not config.noWallEast then
		MapBuilder.createPart({
			name = config.name .. "_WallEast",
			size = Vector3.new(wt, h, l + wt * 2),
			position = Vector3.new(o.X + w / 2 + wt / 2, o.Y + h / 2, o.Z),
			preset = wallPreset,
		}, model)
	end

	-- West wall (negative X face)
	if not config.noWallWest then
		MapBuilder.createPart({
			name = config.name .. "_WallWest",
			size = Vector3.new(wt, h, l + wt * 2),
			position = Vector3.new(o.X - w / 2 - wt / 2, o.Y + h / 2, o.Z),
			preset = wallPreset,
		}, model)
	end

	model.Parent = parent
	return model
end

--------------------------------------------------------------------------------
-- Corridor Builder
--------------------------------------------------------------------------------

--[[
	Create a straight corridor (a room oriented along a line).
	@param config table {
		name: string,
		origin: Vector3 (center of corridor floor),
		width: number (cross-section), length: number (along corridor),
		height: number?,
		direction: string ("NS" or "EW"),
		floorPreset: table?, wallPreset: table?,
		noFloor: boolean?, noCeiling: boolean?,
		noWallStart: boolean?, noWallEnd: boolean?,
	}
	@param parent Instance
	@return Model
]]
function MapBuilder.createCorridor(config: { [string]: any }, parent: Instance): Model
	-- A corridor is just a room oriented along a direction
	local roomConfig = {
		name = config.name,
		origin = config.origin,
		height = config.height or Constants.CEILING_HEIGHT,
		floorPreset = config.floorPreset or MaterialPalette.FLOOR_METAL,
		wallPreset = config.wallPreset or MaterialPalette.WALL_HULL,
		noFloor = config.noFloor,
		noCeiling = config.noCeiling,
	}

	if config.direction == "NS" then
		-- Corridor runs North-South (along Z axis)
		roomConfig.width = config.width or Constants.CORRIDOR_WIDTH
		roomConfig.length = config.length
		roomConfig.noWallNorth = config.noWallStart
		roomConfig.noWallSouth = config.noWallEnd
		roomConfig.noWallEast = config.noWallEast
		roomConfig.noWallWest = config.noWallWest
	else
		-- Corridor runs East-West (along X axis)
		roomConfig.width = config.length
		roomConfig.length = config.width or Constants.CORRIDOR_WIDTH
		roomConfig.noWallEast = config.noWallStart
		roomConfig.noWallWest = config.noWallEnd
		roomConfig.noWallNorth = config.noWallNorth
		roomConfig.noWallSouth = config.noWallSouth
	end

	return MapBuilder.createRoom(roomConfig, parent)
end

--------------------------------------------------------------------------------
-- Ramp Builder
--------------------------------------------------------------------------------

--[[
	Create a ramp using a WedgePart connecting two Y-levels.
	@param config table {
		name: string,
		bottomCenter: Vector3 (center of ramp at lower level, Y = floor surface),
		topCenter: Vector3 (center of ramp at upper level, Y = floor surface),
		width: number?,
		thickness: number?,
		preset: table?,
		railHeight: number? (0 = no rails),
	}
	@param parent Instance
	@return Model
]]
function MapBuilder.createRamp(config: { [string]: any }, parent: Instance): Model
	local model = Instance.new("Model")
	model.Name = config.name or "Ramp"

	local bottom = config.bottomCenter
	local top = config.topCenter
	local width = config.width or Constants.RAMP_WIDTH
	local preset = config.preset or MaterialPalette.RAMP_SURFACE

	-- Calculate ramp geometry
	local dx = top.X - bottom.X
	local dy = top.Y - bottom.Y
	local dz = top.Z - bottom.Z
	local horizontalDist = math.sqrt(dx * dx + dz * dz)

	-- Center position of the ramp
	local centerPos = Vector3.new(
		(bottom.X + top.X) / 2,
		(bottom.Y + top.Y) / 2,
		(bottom.Z + top.Z) / 2
	)

	-- Calculate rotation: yaw (horizontal direction) and pitch (slope angle)
	local yaw = math.atan2(dx, -dz)

	-- WedgePart: Size.Y = height of the wedge face, Size.Z = length along slope
	-- The wedge slopes from +Z face (full height) to -Z face (zero height)
	MapBuilder.createWedge({
		name = config.name .. "_Surface",
		size = Vector3.new(width, dy, horizontalDist),
		position = centerPos,
		rotation = Vector3.new(0, math.deg(yaw), 0),
		preset = preset,
	}, model)

	-- Optional side rails
	local railH = config.railHeight or Constants.RAIL_HEIGHT
	if railH > 0 then
		local railThick = Constants.RAIL_THICKNESS
		-- We create simple rail posts at bottom and top on both sides
		for _, side in { -1, 1 } do
			local offsetX = side * (width / 2 + railThick / 2)
			-- Bottom post
			local bottomRailPos = Vector3.new(
				bottom.X + offsetX * math.cos(yaw),
				bottom.Y + railH / 2,
				bottom.Z - offsetX * math.sin(yaw)
			)
			MapBuilder.createPart({
				name = config.name .. "_Rail",
				size = Vector3.new(railThick, railH, railThick),
				position = bottomRailPos,
				preset = MaterialPalette.CATWALK_RAIL,
			}, model)

			-- Top post
			local topRailPos = Vector3.new(
				top.X + offsetX * math.cos(yaw),
				top.Y + railH / 2,
				top.Z - offsetX * math.sin(yaw)
			)
			MapBuilder.createPart({
				name = config.name .. "_Rail",
				size = Vector3.new(railThick, railH, railThick),
				position = topRailPos,
				preset = MaterialPalette.CATWALK_RAIL,
			}, model)
		end
	end

	model.Parent = parent
	return model
end

--------------------------------------------------------------------------------
-- Platform / Catwalk Builder
--------------------------------------------------------------------------------

--[[
	Create a flat platform or catwalk with optional railings.
	@param config table {
		name: string,
		position: Vector3 (center of platform surface),
		size: Vector3 (X width, Y thickness, Z length),
		preset: table?,
		railHeight: number? (0 = no rails),
		railSides: string? ("all", "NS", "EW", "N", "S", "E", "W"),
	}
	@param parent Instance
	@return Model
]]
function MapBuilder.createPlatform(config: { [string]: any }, parent: Instance): Model
	local model = Instance.new("Model")
	model.Name = config.name or "Platform"

	local pos = config.position
	local sz = config.size or Vector3.new(20, Constants.FLOOR_THICKNESS, 20)
	local preset = config.preset or MaterialPalette.GRATING

	-- Platform surface
	MapBuilder.createPart({
		name = config.name .. "_Surface",
		size = sz,
		position = Vector3.new(pos.X, pos.Y - sz.Y / 2, pos.Z),
		preset = preset,
	}, model)

	-- Railings
	local railH = config.railHeight or 0
	if railH > 0 then
		local railThick = Constants.RAIL_THICKNESS
		local sides = config.railSides or "all"

		-- North rail (negative Z)
		if sides == "all" or string.find(sides, "N") then
			MapBuilder.createPart({
				name = config.name .. "_RailN",
				size = Vector3.new(sz.X, railH, railThick),
				position = Vector3.new(pos.X, pos.Y + railH / 2, pos.Z - sz.Z / 2),
				preset = MaterialPalette.CATWALK_RAIL,
			}, model)
		end

		-- South rail (positive Z)
		if sides == "all" or string.find(sides, "S") then
			MapBuilder.createPart({
				name = config.name .. "_RailS",
				size = Vector3.new(sz.X, railH, railThick),
				position = Vector3.new(pos.X, pos.Y + railH / 2, pos.Z + sz.Z / 2),
				preset = MaterialPalette.CATWALK_RAIL,
			}, model)
		end

		-- East rail (positive X)
		if sides == "all" or string.find(sides, "E") then
			MapBuilder.createPart({
				name = config.name .. "_RailE",
				size = Vector3.new(railThick, railH, sz.Z),
				position = Vector3.new(pos.X + sz.X / 2, pos.Y + railH / 2, pos.Z),
				preset = MaterialPalette.CATWALK_RAIL,
			}, model)
		end

		-- West rail (negative X)
		if sides == "all" or string.find(sides, "W") then
			MapBuilder.createPart({
				name = config.name .. "_RailW",
				size = Vector3.new(railThick, railH, sz.Z),
				position = Vector3.new(pos.X - sz.X / 2, pos.Y + railH / 2, pos.Z),
				preset = MaterialPalette.CATWALK_RAIL,
			}, model)
		end
	end

	model.Parent = parent
	return model
end

--------------------------------------------------------------------------------
-- Spawn Location
--------------------------------------------------------------------------------

--[[
	Create a SpawnLocation at the given CFrame.
	@param cframe CFrame
	@param parent Instance
	@return SpawnLocation
]]
function MapBuilder.createSpawn(cframe: CFrame, parent: Instance): SpawnLocation
	local spawn = Instance.new("SpawnLocation")
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.CFrame = cframe * CFrame.new(0, -0.5, 0)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = Constants.SPAWN_DURATION
	spawn.AllowTeamChangeOnTouch = false
	spawn.TopSurface = Enum.SurfaceType.Smooth
	spawn.BottomSurface = Enum.SurfaceType.Smooth
	MaterialPalette.apply(spawn, MaterialPalette.SPAWN_PAD)
	spawn.Transparency = 0.5
	spawn.Parent = parent
	return spawn
end

--------------------------------------------------------------------------------
-- Hazard Zone
--------------------------------------------------------------------------------

--[[
	Create an invisible hazard detection zone tagged for CollectionService.
	@param config table {
		name: string?,
		position: Vector3,
		size: Vector3,
		tag: string?,
	}
	@param parent Instance
	@return BasePart
]]
function MapBuilder.createHazardZone(config: { [string]: any }, parent: Instance): BasePart
	local tag = config.tag or Constants.TAG_ACID_HAZARD
	local part = Instance.new("Part")
	part.Name = config.name or "HazardZone"
	part.Size = config.size
	part.Position = config.position
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.CollisionGroup = Constants.COLLISION_GROUP_HAZARD
	CollectionService:AddTag(part, tag)
	part.Parent = parent
	return part
end

--------------------------------------------------------------------------------
-- Jump Pad
--------------------------------------------------------------------------------

--[[
	Create a visible jump pad surface tagged for the JumpPadManager.
	Stores launch vector as an Attribute on the part.
	@param config table {
		name: string?,
		position: Vector3 (top surface center),
		size: Vector3?,
		launchVector: Vector3 (velocity to apply),
	}
	@param parent Instance
	@return BasePart
]]
function MapBuilder.createJumpPad(config: { [string]: any }, parent: Instance): BasePart
	local sz = config.size or Constants.JUMP_PAD_SIZE
	local part = Instance.new("Part")
	part.Name = config.name or "JumpPad"
	part.Size = sz
	part.Position = Vector3.new(config.position.X, config.position.Y - sz.Y / 2, config.position.Z)
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	MaterialPalette.apply(part, MaterialPalette.JUMP_PAD)

	-- Store launch parameters as Attributes
	part:SetAttribute("LaunchX", config.launchVector.X)
	part:SetAttribute("LaunchY", config.launchVector.Y)
	part:SetAttribute("LaunchZ", config.launchVector.Z)

	CollectionService:AddTag(part, Constants.TAG_JUMP_PAD)
	part.Parent = parent
	return part
end

--------------------------------------------------------------------------------
-- Decorations
--------------------------------------------------------------------------------

--[[
	Create a cluster of crates for visual interest.
	@param config table {
		position: Vector3,
		count: number? (1-5),
		seed: number? (for deterministic layout),
	}
	@param parent Instance
	@return Model
]]
function MapBuilder.createCrateCluster(config: { [string]: any }, parent: Instance): Model
	local model = Instance.new("Model")
	model.Name = "CrateCluster"

	local count = config.count or 3
	local seed = config.seed or 1
	local rng = Random.new(seed)

	for i = 1, count do
		local sizeX = rng:NextNumber(3, 7)
		local sizeY = rng:NextNumber(3, 7)
		local sizeZ = rng:NextNumber(3, 7)
		local offsetX = rng:NextNumber(-4, 4)
		local offsetZ = rng:NextNumber(-4, 4)
		local preset = if i % 2 == 0 then MaterialPalette.CRATE_DARK else MaterialPalette.CRATE

		MapBuilder.createPart({
			name = "Crate_" .. i,
			size = Vector3.new(sizeX, sizeY, sizeZ),
			position = Vector3.new(
				config.position.X + offsetX,
				config.position.Y + sizeY / 2,
				config.position.Z + offsetZ
			),
			preset = preset,
		}, model)
	end

	model.Parent = parent
	return model
end

--[[
	Create a decorative pipe run between two points.
	@param config table {
		startPos: Vector3,
		endPos: Vector3,
		radius: number?,
	}
	@param parent Instance
	@return BasePart
]]
function MapBuilder.createPipeRun(config: { [string]: any }, parent: Instance): BasePart
	local startP = config.startPos
	local endP = config.endPos
	local radius = config.radius or 1
	local dx = endP.X - startP.X
	local dy = endP.Y - startP.Y
	local dz = endP.Z - startP.Z
	local length = math.sqrt(dx * dx + dy * dy + dz * dz)

	local part = Instance.new("Part")
	part.Name = "Pipe"
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(length, radius * 2, radius * 2)
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	MaterialPalette.apply(part, MaterialPalette.PIPE)

	-- Orient cylinder along the line between start and end
	local center = (startP + endP) / 2
	part.CFrame = CFrame.lookAt(center, endP) * CFrame.Angles(0, math.rad(90), 0)

	part.Parent = parent
	return part
end

--[[
	Create a hazard warning stripe (thin neon yellow bar).
	@param config table {
		position: Vector3,
		size: Vector3,
		rotation: Vector3?,
	}
	@param parent Instance
	@return BasePart
]]
function MapBuilder.createHazardStripe(config: { [string]: any }, parent: Instance): BasePart
	return MapBuilder.createPart({
		name = "HazardStripe",
		size = config.size,
		position = config.position,
		rotation = config.rotation,
		preset = MaterialPalette.HAZARD_STRIPE,
	}, parent)
end

--[[
	Create a ceiling-mounted light panel.
	@param config table {
		position: Vector3,
		size: Vector3?,
	}
	@param parent Instance
	@return BasePart
]]
function MapBuilder.createLightPanel(config: { [string]: any }, parent: Instance): BasePart
	local sz = config.size or Vector3.new(2, 0.5, 8)
	return MapBuilder.createPart({
		name = "LightPanel",
		size = sz,
		position = config.position,
		preset = MaterialPalette.LIGHT_PANEL,
	}, parent)
end

return MapBuilder
