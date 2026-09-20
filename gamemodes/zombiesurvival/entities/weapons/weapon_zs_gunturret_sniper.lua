AddCSLuaFile()

SWEP.Base = "weapon_zs_gunturret"

SWEP.PrintName = "Sniper Turret"
SWEP.Description = "A bulky turret that uses rifle ammo.\nPress PRIMARY ATTACK to deploy the turret.\nPress SECONDARY ATTACK and RELOAD to rotate the turret.\nPress USE on a deployed turret to give it some of your buckshot ammunition.\nPress USE on a deployed turret with no owner (blue light) to reclaim it."

SWEP.Primary.Damage = 130

SWEP.GhostStatus = "ghost_gunturret_sniper"
SWEP.DeployClass = "prop_gunturret_sniper"

SWEP.TurretAmmoType = "357"
SWEP.TurretAmmoStartAmount = 100
SWEP.TurretSpread = 2

SWEP.MaxStock = 3
SWEP.Tier = 5

SWEP.Primary.Ammo = "turret_sniper"

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_TURRET_SPREAD, -0.5)
