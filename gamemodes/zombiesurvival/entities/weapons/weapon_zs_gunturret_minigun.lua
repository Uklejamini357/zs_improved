AddCSLuaFile()

SWEP.Base = "weapon_zs_gunturret"

SWEP.PrintName = "Minigun Turret"
SWEP.Description = "Very heavy turret with high fire rate that uses SMG ammo.\nPress PRIMARY ATTACK to deploy the turret.\nPress SECONDARY ATTACK and RELOAD to rotate the turret.\nPress USE on a deployed turret to give it some of your SMG ammunition.\nPress USE on a deployed turret with no owner (blue light) to reclaim it."

SWEP.Primary.Damage = 9.8

SWEP.GhostStatus = "ghost_gunturret_minigun"
SWEP.DeployClass = "prop_gunturret_minigun"

SWEP.TurretAmmoType = "smg1"
SWEP.TurretAmmoStartAmount = 150
SWEP.TurretSpread = 2.3

SWEP.Tier = 5

SWEP.Primary.Ammo = "turret_minigun"

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_TURRET_SPREAD, -0.5)
