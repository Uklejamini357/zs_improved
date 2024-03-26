AddCSLuaFile()

ENT.Base = "prop_gunturret"

ENT.SWEP = "weapon_zs_gunturret_minigun"

ENT.AmmoType = "smg1"
ENT.FireDelay = 0.057
ENT.NumShots = 1
ENT.Damage = 9.8
ENT.PlayLoopingShootSound = false
ENT.Spread = 2.3
ENT.MaxAmmo = 2500
ENT.MaxHealth = 300

function ENT:PlayShootSound()
	self:EmitSound("weapons/smg1/smg1_fire1.wav", 70, 125, 0.75, CHAN_WEAPON)
end
