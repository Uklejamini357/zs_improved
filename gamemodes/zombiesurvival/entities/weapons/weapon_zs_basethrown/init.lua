INC_SERVER()

SWEP.ThrownProjectile = "projectile_zsgrenade"
SWEP.ThrowAngVel = 5
SWEP.ThrowVel = 800
SWEP.LifeTime = 2.5

function SWEP:ShootBullets(damage, numshots, cone)
	local owner = self:GetOwner()
	self:SendWeaponAnim(ACT_VM_THROW)
	owner:DoAttackEvent()

	local ent = ents.Create(self.ThrownProjectile)
	if ent:IsValid() then
		ent.LifeTime = self.LifeTime or ent.LifeTime
		local pos = owner:GetShootPos()
		pos.z = pos.z - (damage and 16 or 0)
		ent:SetPos(pos)
		ent:SetOwner(owner)
		ent:Spawn()

		ent.GrenadeDamage = self.GrenadeDamage
		ent.GrenadeRadius = self.GrenadeRadius
		ent.DamageType = self.DamageType or ent.DamageType or DMG_GENERIC
--		ent.DieTime = CurTime() + self.LifeTime

		ent.Team = owner:Team()

		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:AddAngleVelocity(VectorRand() * self.ThrowAngVel)
			phys:SetVelocityInstantaneous(self:GetOwner():GetAimVector() * self.ThrowVel * (damage and 0.4 or 1) * (owner.ObjectThrowStrengthMul or 1))
		end

		ent:SetPhysicsAttacker(owner)
	end
end
