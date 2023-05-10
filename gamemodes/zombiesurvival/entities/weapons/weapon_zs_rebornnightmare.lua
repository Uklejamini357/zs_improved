AddCSLuaFile()

SWEP.PrintName = "Reborn Nightmare"

SWEP.Base = "weapon_zs_zombie"

SWEP.MeleeDamage = 15
SWEP.BleedDamage = 13
SWEP.SlowDownScale = 3.4
SWEP.MeleeDamageVsProps = 42
SWEP.EnfeebleDurationMul = 10 / SWEP.MeleeDamage

SWEP.SpecialMeleeDamage = 27
SWEP.SpecialMeleeDamageVsProps = 85
SWEP.SpecialBleedDamage = 25
SWEP.SpecialAttackDelay = 10

function SWEP:SecondaryAttack()
	if CurTime() < self:GetNextSecondaryFire() then return end

	local owner = self:GetOwner()
	local armdelay = owner:GetMeleeSpeedMul()

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(self:GetNextPrimaryFire() + self.SpecialAttackDelay)
	self:SetNextSpecialAttack(self:GetNextPrimaryFire() + 0.5)

	self.IsSpecialAttackActive = true

	self:StartSwinging()

--	self.BaseClass.SecondaryAttack(self)
end

function SWEP:Reload()
	if CurTime() < self:GetNextSpecialAttack() then return end
	self:SetNextSpecialAttack(CurTime() + self.AlertDelay)

	self:DoAlert()
end

function SWEP:Swung()
	if self.IsSpecialAttackActive then
		self.OriginalMeleeDamage = self.MeleeDamage
		self.OriginalMeleeDamageVsProps = self.MeleeDamageVsProps
		self.OriginalBleedDamage = self.BleedDamage

		self.MeleeDamage = self.SpecialMeleeDamage
		self.MeleeDamageVsProps = self.SpecialMeleeDamageVsProps
		self.BleedDamage = self.SpecialBleedDamage
	end

	self.BaseClass.Swung(self)

	if self.IsSpecialAttackActive then
		self.IsSpecialAttackActive = false
		self.MeleeDamage = self.OriginalMeleeDamage
		self.MeleeDamageVsProps = self.OriginalMeleeDamageVsProps
		self.BleedDamage = self.OriginalBleedDamage
	end	
end

function SWEP:PlayAlertSound()
	self:GetOwner():EmitSound("npc/barnacle/barnacle_tongue_pull"..math.random(3)..".wav")
end
SWEP.PlayIdleSound = SWEP.PlayAlertSound

function SWEP:PlayAttackSound()
	self:EmitSound("npc/barnacle/barnacle_bark"..math.random(2)..".wav", 75, 90)
end

function SWEP:MeleeHit(ent, trace, damage, forcescale)
	if not ent:IsPlayer() then
		damage = self.MeleeDamageVsProps
	end

	self.BaseClass.MeleeHit(self, ent, trace, damage, forcescale)
end

function SWEP:ApplyMeleeDamage(ent, trace, damage)
	if SERVER and ent:IsPlayer() then
		local gt = ent:GiveStatus("enfeeble", damage * self.EnfeebleDurationMul)
		if gt and gt:IsValid() then
			gt.Applier = self:GetOwner()
		end

		ent:GiveStatus("dimvision", 10)

		local bleed = ent:GiveStatus("bleed")
		if bleed and bleed:IsValid() then
			bleed:AddDamage(self.BleedDamage)
			bleed.Damager = self:GetOwner()
		end


		if self.IsSpecialAttackActive then
			gt = ent:GiveStatus("sickness", 12)
			if gt and gt:IsValid() then
				gt.Applier = self:GetOwner()
			end

			gt = ent:GiveStatus("frightened", 6)
			if gt and gt:IsValid() then
				gt.Applier = self:GetOwner()
			end

			if (not self.LastRebornNightmareHit or self.LastRebornNightmareHit + 5 < CurTime()) and (not ent.LastRebornNightmareHit or ent.LastRebornNightmareHit + 5 < CurTime()) then
				ent:EmitSound("weapons/flashbang/flashbang_explode2.wav")

				local effectdata = EffectData()
				effectdata:SetOrigin(ent:GetPos())
				util.Effect("HelicopterMegaBomb", effectdata)

				if not ent:HasTrinket("bleaksoul") then
					ent:ScreenFade(SCREENFADE.IN, nil, 1, 1) 
					ent:SetDSP(36)
					ent:GiveStatus("disorientation", 1.5)
				end

				self.LastRebornNightmareHit = CurTime()
				ent.LastRebornNightmareHit = CurTime()
			end
		end
	end

	self.BaseClass.ApplyMeleeDamage(self, ent, trace, damage)
end

function SWEP:GetNextSpecialAttack()
	return self:GetDTFloat(1, 0)
end

function SWEP:SetNextSpecialAttack(amt)
	self:SetDTFloat(1, amt)
end

if not CLIENT then return end

function SWEP:ViewModelDrawn()
	render.ModelMaterialOverride(0)
end

local matSheet = Material("Models/Charple/Charple1_sheet")
function SWEP:PreDrawViewModel(vm)
	render.ModelMaterialOverride(matSheet)
end
