--[[
	AtmosphereController.client.lua
	Sets up the dark industrial spaceship atmosphere for Deck 22.
	Configures Lighting, Atmosphere, ColorCorrection, and ambient sound.
]]

local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

print("[Deck22] Setting up atmosphere...")

--------------------------------------------------------------------------------
-- Lighting Configuration
--------------------------------------------------------------------------------

-- Dark industrial interior lighting
Lighting.Ambient = Color3.fromRGB(30, 32, 40)
Lighting.OutdoorAmbient = Color3.fromRGB(20, 22, 28)
Lighting.Brightness = 0.5
Lighting.ClockTime = 0 -- Midnight (no sun)
Lighting.FogEnd = 300
Lighting.FogStart = 50
Lighting.FogColor = Color3.fromRGB(15, 18, 25)
Lighting.GlobalShadows = true
Lighting.Technology = Enum.Technology.ShadowMap

-- Color shift for industrial blue-steel mood
Lighting.ColorShift_Top = Color3.fromRGB(180, 190, 210)
Lighting.ColorShift_Bottom = Color3.fromRGB(40, 45, 55)

--------------------------------------------------------------------------------
-- Atmosphere Effect (volumetric fog)
--------------------------------------------------------------------------------

-- Remove existing Atmosphere if any
local existingAtmo = Lighting:FindFirstChildOfClass("Atmosphere")
if existingAtmo then
	existingAtmo:Destroy()
end

local atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0.3
atmosphere.Offset = 0.2
atmosphere.Color = Color3.fromRGB(40, 45, 55)
atmosphere.Decay = Color3.fromRGB(25, 28, 35)
atmosphere.Glare = 0
atmosphere.Haze = 2
atmosphere.Parent = Lighting

--------------------------------------------------------------------------------
-- Color Correction (desaturation + contrast)
--------------------------------------------------------------------------------

local existingCC = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
if existingCC then
	existingCC:Destroy()
end

local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Brightness = -0.02
colorCorrection.Contrast = 0.15
colorCorrection.Saturation = -0.2
colorCorrection.TintColor = Color3.fromRGB(240, 245, 255) -- Slight cool tint
colorCorrection.Parent = Lighting

--------------------------------------------------------------------------------
-- Bloom (subtle glow on Neon materials)
--------------------------------------------------------------------------------

local existingBloom = Lighting:FindFirstChildOfClass("BloomEffect")
if existingBloom then
	existingBloom:Destroy()
end

local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.5
bloom.Size = 24
bloom.Threshold = 0.9
bloom.Parent = Lighting

--------------------------------------------------------------------------------
-- Ambient Sound (engine hum)
--------------------------------------------------------------------------------

-- Create a looping ambient sound for spaceship atmosphere
local ambientSound = Instance.new("Sound")
ambientSound.Name = "AmbientEngineHum"
ambientSound.SoundId = "" -- Placeholder: add a deep engine hum asset ID
ambientSound.Volume = 0.15
ambientSound.Looped = true
ambientSound.RollOffMode = Enum.RollOffMode.Linear
ambientSound.Parent = SoundService

-- Note: Sound won't play without a valid SoundId asset.
-- This is a placeholder for when a sound asset is uploaded.
-- ambientSound:Play()

print("[Deck22] Atmosphere configured")
