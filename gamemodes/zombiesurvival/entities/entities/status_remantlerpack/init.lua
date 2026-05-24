INC_SERVER()

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetNotSolid(true)
	self:SetModelScale(0.35, 0) -- 0.25x model scale before
	
	self:SetModel("models/props_lab/powerbox01a.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:PhysicsInitSphere(3)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
end

function ENT:Think()
	local owner = self:GetOwner()
	if not (owner:IsValid() and owner:Alive() and owner:HasTrinket("remantlerpack")) then self:Remove() end
end
