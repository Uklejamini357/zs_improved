CLASS.Base = "headcrab"

CLASS.Name = "Frost Headcrab"
CLASS.TranslationName = "class_frostheadcrab"
CLASS.Description = "description_frostheadcrab"
CLASS.Help = "controls_frostheadcrab"

CLASS.Model = Model("models/headcrabclassic.mdl")

CLASS.Wave = 3 / GM.NumberOfWaves
CLASS.Disabled = true
CLASS.Hidden = true

CLASS.SWEP = "weapon_zs_frostheadcrab"

CLASS.Health = 75
CLASS.Speed = 155
CLASS.JumpPower = 100

CLASS.NoFallDamage = true
CLASS.NoFallSlowdown = true

CLASS.DamageNeedPerPoint = GM.HeadcrabZombiePointRatio * 0.9
CLASS.Points = CLASS.Health/GM.HeadcrabZombiePointRatio / 0.9

CLASS.Hull = {Vector(-12, -12, 0), Vector(12, 12, 18.1)}
CLASS.HullDuck = {Vector(-12, -12, 0), Vector(12, 12, 18.1)}
CLASS.ViewOffset = Vector(0, 0, 10)
CLASS.ViewOffsetDucked = Vector(0, 0, 10)
CLASS.StepSize = 8
CLASS.CrouchedWalkSpeed = 1
CLASS.Mass = 25


CLASS.PainSounds = {"NPC_HeadCrab.Pain"}
CLASS.DeathSounds = {"NPC_HeadCrab.Die"}

CLASS.BloodColor = BLOOD_COLOR_YELLOW

local CurTime = CurTime
local math_min = math.min
local math_Clamp = math.Clamp
local math_abs = math.abs

if SERVER then return end

CLASS.Icon = "zombiesurvival/killicons/headcrab"
CLASS.IconColor = Color(0, 0, 205)

function CLASS:PrePlayerDraw(pl)
	render.SetColorModulation(0, 0, 0.8)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetBurrowTime and wep:GetBurrowTime() ~= 0 and CurTime() >= math_abs(wep:GetBurrowTime()) then
		return true
	end
end
