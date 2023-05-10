AddCSLuaFile()

SWEP.PrintName = "Omega Zombie"

SWEP.Base = "weapon_zs_zombie"

SWEP.MeleeDelay = 0.73
SWEP.MeleeReach = 54
SWEP.MeleeDamage = 37
SWEP.MeleeDamageVsProps = 45
SWEP.Primary.Delay = 1.08

if SERVER then return end

function SWEP:PreDrawViewModel(vm)
	local col = HSVToColor((CurTime() - MySelf:GetNW2Float("SpawnTime", 0)) * 85 % 360, 1, 1)
	col.r = col.r / 255
	col.g = col.g / 255
	col.b = col.b / 255
	render.SetColorModulation(col.r, col.g, col.b)
end

function SWEP:ViewModelDrawn()
	render.SetColorModulation(1, 1, 1)
end
