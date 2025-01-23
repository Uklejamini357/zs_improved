AddCSLuaFile()
DEFINE_BASECLASS("weapon_zs_base")

SWEP.PrintName = "Bullet Storm Machine Gun"
SWEP.Description = "Bullet Storm Machine Gun is an upgraded version of 'Bullet Storm' SMG, however it lacks the Storm Firing mode. No zombie will survive under the immense bullet hell... Uses 3 ammo per shot"
SWEP.Slot = 2
SWEP.SlotPos = 0

if CLIENT then
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50

	SWEP.HUD3DBone = "v_weapon.p90_Release"
	SWEP.HUD3DPos = Vector(-1.35, -0.5, -6.5)
	SWEP.HUD3DAng = Angle(0, 0, 0)
end

SWEP.Base = "weapon_zs_base"

SWEP.HoldType = "smg"

SWEP.ViewModel = "models/weapons/cstrike/c_smg_p90.mdl"
SWEP.WorldModel = "models/weapons/w_smg_p90.mdl"
SWEP.UseHands = true

SWEP.Primary.Sound = Sound("Weapon_p90.Single")
SWEP.Primary.Damage = 18.5
SWEP.Primary.NumShots = 3
SWEP.Primary.Delay = 0.08

SWEP.Primary.ClipSize = 180
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "ar2"
GAMEMODE:SetupDefaultClip(SWEP.Primary)

SWEP.RequiredClip = 3

SWEP.ConeMax = 6
SWEP.ConeMin = 3.5

SWEP.Primary.Gesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
SWEP.ReloadGesture = ACT_HL2MP_GESTURE_RELOAD_SMG1

SWEP.WalkSpeed = SPEED_SLOWER

SWEP.Tier = 6
SWEP.MaxStock = 1

SWEP.IronSightsPos = Vector(-2, 6, 3)
SWEP.IronSightsAng = Vector(0, 2, 0)

GAMEMODE:SetPrimaryWeaponModifier(SWEP, WEAPON_MODIFIER_DAMAGE, SWEP.Primary.Damage*0.16)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -SWEP.Primary.Delay*0.07, 2)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_CLIP_SIZE, 5*SWEP.RequiredClip, 1, 2)

if SERVER then return end

function SWEP:PreDrawViewModel(vm)
	render.SetColorModulation(1, 0.5, 0.5)
end

function SWEP:ViewModelDrawn()
	render.SetColorModulation(1, 1, 1)
end
