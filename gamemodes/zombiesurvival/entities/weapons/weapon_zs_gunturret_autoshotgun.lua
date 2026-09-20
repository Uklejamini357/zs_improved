AddCSLuaFile()

SWEP.Base = "weapon_zs_gunturret"

SWEP.PrintName = "Auto Shotgun Turret"
SWEP.Description = "An automated turret that fires rapid buck shots. Massive damage in close range, but is overall less accurate.\nPress PRIMARY ATTACK to deploy the turret.\nPress SECONDARY ATTACK and RELOAD to rotate the turret.\nPress USE on a deployed turret to give it some of your buckshot ammunition.\nPress USE on a deployed turret with no owner (blue light) to reclaim it."

SWEP.Primary.Damage = 5.85

SWEP.GhostStatus = "ghost_gunturret_autoshotgun"
SWEP.DeployClass = "prop_gunturret_autoshotgun"
SWEP.TurretAmmoType = "buckshot"
SWEP.TurretAmmoStartAmount = 50
SWEP.TurretSpread = 7.5

SWEP.MaxStock = 2
SWEP.Tier = 6

SWEP.Primary.Ammo = "turret_buckshot"

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_TURRET_SPREAD, -0.9)
