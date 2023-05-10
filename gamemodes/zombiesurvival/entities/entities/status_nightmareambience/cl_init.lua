INC_CLIENT()

ENT.RenderGroup = RENDERGROUP_NONE

function ENT:Initialize()
	self:DrawShadow(false)

	local owner = self:GetOwner()
	local classname = owner:GetZombieClassTable().Name
	self.AmbientSound = CreateSound(self, "zombiesurvival/nightmare_ambiance.ogg")
	self.AmbientSound:PlayEx(0.8, classname == "Reborn Nightmare" and 85 or 100)
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

function ENT:Think()
	--[[owner = self:GetOwner()
	if owner:IsValid() then
		local wep = owner:GetActiveWeapon()
		if wep:IsValid() and wep.IsSwinging and wep:IsSwinging() then
			self.AmbientSound:Stop()
		else]]
			--self.AmbientSound:PlayEx(0.8, 100 + RealTime() % 0.1)
		--[[end
	end]]
end

function ENT:Draw()
end
