--[[
	MaterialPalette.module.lua
	Industrial/spaceship cargo deck visual theme for Deck 22.
	Each preset defines a Material + Color3 pair applied via the apply() helper.
]]

local MaterialPalette = {}

-- Type: { material: Enum.Material, color: Color3 }

MaterialPalette.FLOOR_METAL = {
	material = Enum.Material.DiamondPlate,
	color = Color3.fromRGB(80, 82, 85),
}

MaterialPalette.WALL_HULL = {
	material = Enum.Material.Metal,
	color = Color3.fromRGB(100, 105, 110),
}

MaterialPalette.CEILING = {
	material = Enum.Material.Metal,
	color = Color3.fromRGB(70, 72, 75),
}

MaterialPalette.GRATING = {
	material = Enum.Material.CorrodedMetal,
	color = Color3.fromRGB(60, 62, 65),
}

MaterialPalette.CRATE = {
	material = Enum.Material.SmoothPlastic,
	color = Color3.fromRGB(140, 110, 60),
}

MaterialPalette.CRATE_DARK = {
	material = Enum.Material.SmoothPlastic,
	color = Color3.fromRGB(90, 75, 45),
}

MaterialPalette.RAMP_SURFACE = {
	material = Enum.Material.DiamondPlate,
	color = Color3.fromRGB(90, 92, 95),
}

MaterialPalette.CATWALK_RAIL = {
	material = Enum.Material.Metal,
	color = Color3.fromRGB(110, 115, 120),
}

MaterialPalette.ACID = {
	material = Enum.Material.Neon,
	color = Color3.fromRGB(80, 255, 40),
}

MaterialPalette.JUMP_PAD = {
	material = Enum.Material.Neon,
	color = Color3.fromRGB(0, 200, 255),
}

MaterialPalette.HAZARD_STRIPE = {
	material = Enum.Material.Neon,
	color = Color3.fromRGB(255, 200, 0),
}

MaterialPalette.LIGHT_PANEL = {
	material = Enum.Material.Neon,
	color = Color3.fromRGB(220, 220, 255),
}

MaterialPalette.PIPE = {
	material = Enum.Material.Metal,
	color = Color3.fromRGB(70, 75, 80),
}

MaterialPalette.COLUMN = {
	material = Enum.Material.Concrete,
	color = Color3.fromRGB(85, 88, 90),
}

MaterialPalette.SPAWN_PAD = {
	material = Enum.Material.Neon,
	color = Color3.fromRGB(100, 150, 255),
}

--[[
	Apply a material preset to a BasePart.
	@param part BasePart - The part to style
	@param preset table - A MaterialPalette preset { material, color }
]]
function MaterialPalette.apply(part: BasePart, preset: { material: Enum.Material, color: Color3 })
	part.Material = preset.material
	part.Color = preset.color
end

return MaterialPalette
