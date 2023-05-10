INC_SERVER()

function ENT:Initialize()
	self:DrawShadow(false)
end


function ENT:Think()
	local owner = self:GetOwner()
	if not (owner:Alive() and owner:Team() == TEAM_UNDEAD and owner:GetZombieClassTable().IsEradicator) then self:Remove() end
--	and owner:GetZombieClassTable().Name == "Eradicator"
end

