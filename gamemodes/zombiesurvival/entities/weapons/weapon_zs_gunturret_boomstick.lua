AddCSLuaFile()

SWEP.Base = "weapon_zs_gunturret"

SWEP.PrintName = "Boomstick Turret"
SWEP.Description = "Uses up to 5 shotgun rounds in one shot to inflict massive damage.\nPress PRIMARY ATTACK to deploy the turret.\nPress SECONDARY ATTACK and RELOAD to rotate the turret.\nPress USE on a deployed turret to give it some of your buckshot ammunition.\nPress USE on a deployed turret with no owner (blue light) to reclaim it."

SWEP.Primary.Damage = 6.75

SWEP.GhostStatus = "ghost_gunturret_boomstick"
SWEP.DeployClass = "prop_gunturret_boomstick"
SWEP.TurretAmmoType = "buckshot"
SWEP.TurretAmmoStartAmount = 25
SWEP.TurretSpread = 5

SWEP.MaxStock = 2
SWEP.Tier = 6

SWEP.Primary.Ammo = "turret_buckshot"

GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_TURRET_SPREAD, -0.9)
