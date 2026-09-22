INC_SERVER()

function ENT:HitTarget(ent, damage, owner)
	ent:AddLegDamageExt(self.LegDamage, owner, self, SLOWTYPE_PULSE)

	if self.PointsMultiplier then
		POINTSMULTIPLIER = self.PointsMultiplier
	end
	ent:TakeSpecialDamage(damage * (owner.ZapperDamageMul or 1), DMG_SHOCK, owner, self)
	util.BlastDamagePlayer(self, owner, ent:GetPos(), 120, damage * (owner.ZapperDamageMul or 1) / 3, DMG_SHOCK, 0.8, true)
	if self.PointsMultiplier then
		POINTSMULTIPLIER = nil
	end

	self:EmitSound("ambient/office/zap1.wav", 70, 160, 0.6, CHAN_AUTO)
end

function ENT:Think()
	if self.Destroyed then
		self:Remove()
	end

	if CurTime() < self:GetNextZap() or CurTime() < self.NextZapCheck then return end

	local curammo = self:GetAmmo()
	local owner = self:GetObjectOwner()
	if curammo >= math.max(1, self.AmmoUsePerZap) and owner:IsValid() then
		self.NextZapCheck = CurTime() + self.ZapCheckDelay

		local pos = self:LocalToWorld(Vector(0, 0, 29))
		local target = self:FindZapperTarget(pos, owner)

		local shocked = {}
		if target then
			self:SetAmmo(curammo - self.AmmoUsePerZap)

			if self:GetAmmo() < self.AmmoUsePerZap then
				owner:SendDeployableOutOfAmmoMessage(self)
			end

			self:SetNextZap(CurTime() + self.ZapperDelay * (owner.FieldDelayMul or 1))
			self:HitTarget(target, self.Damage, owner)

			local effectdata = EffectData()
				effectdata:SetOrigin(target:WorldSpaceCenter())
				effectdata:SetStart(pos)
				effectdata:SetEntity(self)
			util.Effect("tracer_zapper", effectdata)

			shocked[target] = true

			local entindex = self:EntIndex()
			local zpr = {
				Damage = self.Damage,
				ArcRange = self.ZapperArcRange,
			}
			local div = 1
			if self.MaxArcZaps < 1 then return end

			local identifier
			for i=1,128 do
				identifier = "ArcZapper.Zapping_"..entindex.."_"..i
				if not timer.Exists(identifier) then
					-- timer.Remove(identifier)
					break
				end
			end

			timer.Create(identifier, self.ArcZapDelay or 0.15, math.max(1, self.MaxArcZaps), function()
				local tpos = target:WorldSpaceCenter()

				local zombiestozap = {}
				for _, ent in pairs(ents.FindInSphere(tpos, zpr.ArcRange)) do
					if (not shocked[ent] and ent:IsValidLivingZombie() and not ent:GetZombieClassTable().NeverAlive) and WorldVisible(tpos, ent:NearestPoint(tpos)) then
						zombiestozap[ent] = ent:GetPos():DistToSqr(tpos)
					end
				end

				table.sort(zombiestozap, function(a,b) return a < b end)

				for ent, distance in SortedPairsByValue(zombiestozap) do
					if not self:IsValid() then break end
					if self.ZapInfiniteChain then
						for zapped,_ in pairs(shocked) do
							shocked[zapped] = nil 
						end
					end

					shocked[ent] = true
					target = ent

					if not ent:IsValid() or not ent:IsValidLivingZombie() or not WorldVisible(tpos, ent:NearestPoint(tpos)) then return end
					if not self:IsValid() then break end
					local dmg = zpr.Damage * (owner.ZapperDamageMul or 1) / (div + 0.5)

					if dmg <= 5 then break end
					self:HitTarget(ent, dmg, owner)

					local worldspace = ent:WorldSpaceCenter()
					effectdata = EffectData()
					effectdata:SetOrigin(worldspace)
					effectdata:SetStart(tpos)
					effectdata:SetEntity(target)
					util.Effect("tracer_zapper", effectdata)

					div = div + 1

					return
				end

				timer.Remove(identifier)
			end)
		end
	end

	self:NextThink(CurTime())
	return true
end
