-- WORK IN PROGRESS

CLASS.Base = "boss_shade"

CLASS.Name = "Fire Shade"
CLASS.TranslationName = "class_fireshade"
CLASS.Description = "description_fireshade"
CLASS.Help = "controls_fireshade"

CLASS.Boss = false
CLASS.SuperBoss = false --true
CLASS.Unlocked = false
CLASS.Disabled = true
CLASS.Hidden = true

CLASS.Health = 3750
CLASS.DynamicHealth = 0
CLASS.Speed = 160

CLASS.DamageNeedPerPoint = 0
CLASS.Points = 120

CLASS.SWEP = "weapon_zs_fireshade"

CLASS.ResistFrost = true

CLASS.Model = Model("models/player/zombie_fast.mdl")

local math_cos = math.cos
local math_abs = math.abs
local math_Clamp = math.Clamp
local CurTime = CurTime

function CLASS:ScalePlayerDamage(pl, hitgroup, dmginfo)
	if not dmginfo:IsBulletDamage() then return true end

	if hitgroup == HITGROUP_LEFTLEG or hitgroup == HITGROUP_RIGHTLEG or hitgroup == HITGROUP_GEAR or hitgroup == HITGROUP_GENERIC then
		dmginfo:SetDamage(0)
		dmginfo:ScaleDamage(0)
	end

	return true
end

function CLASS:IgnoreLegDamage(pl, dmginfo)
	return true
end

function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo, assister)
	if SERVER then
		local effectdata = EffectData()
		effectdata:SetOrigin(pl:WorldSpaceCenter())
		effectdata:SetNormal(pl:GetUp())
		effectdata:SetEntity(pl)
		effectdata:SetColor(Color(255, 0, 0))
		util.Effect("death_shade", effectdata, nil, true)
	end

	return true
end

if SERVER then
	function CLASS:OnSpawned(pl)
		pl:CreateAmbience("fireshadeambience")
		pl:SetRenderMode(RENDERMODE_TRANSALPHA)
	end

	function CLASS:ProcessDamage(pl, dmginfo)
		if SERVER then
			local inflictor = dmginfo:GetInflictor()
			if inflictor:IsValid() and (inflictor:IsPhysicsModel() or inflictor.IsPhysbox) then
				return
			end

			local status = pl.status_fireshadeambience
			if status and status:IsValid() then
				status:SetLastDamaged(CurTime())
			end
		end
	end

	function CLASS:ShadeShield(pl)
		local shadeshield = pl.ShadeShield
		local curtime = CurTime()
		if pl.NextShield and curtime <= pl.NextShield then return end

		if shadeshield and shadeshield:IsValid() then
			if curtime >= shadeshield:GetStateEndTime() then
				shadeshield:SetState(1)
				shadeshield:SetStateEndTime(curtime + 0.5)
			end
		elseif pl:IsOnGround() and not pl:IsPlayingTaunt() then
			local wep = pl:GetActiveWeapon()
			if wep:IsValid() and curtime > wep:GetNextPrimaryFire() and curtime > wep:GetNextSecondaryFire() then
				local status = pl:GiveStatus("fireshadeshield")
				if status and status:IsValid() then
					status:SetStateEndTime(curtime + 0.5)

					for _, ent in pairs(ents.FindByClass("env_frostshadecontrol")) do
						if ent:IsValid() and ent:GetOwner() == pl then
							ent:Remove()
							return
						end
					end
				end
			end
		end
	end

	function CLASS:AltUse(pl)
		self:ShadeShield(pl)
	end
end

if not CLIENT then return end

CLASS.Icon = "zombiesurvival/killicons/shadev2"
CLASS.IconColor = Color(255, 5, 45)

local nodraw = false
local matWhite = Material("models/debug/debugwhite")
local matRefract = Material("models/spawn_effect")
function CLASS:PreRenderEffects(pl)
	if render.SupportsVertexShaders_2_0() then
		local normal = pl:GetUp()
		render.EnableClipping(true)
		render.PushCustomClipPlane(normal, normal:Dot(pl:GetPos() + normal * 16))
	end

	if nodraw then return end

	local red = 0
	local status = pl.status_fireshadeambience
	if status and status:IsValid() then
		red = 1 - math_Clamp((CurTime() - status:GetLastDamaged()) * 3, 0, 1) ^ 3
	end

	render.SetColorModulation(red, 0.7 * (1 - red), 1 - red)
	render.SetBlend(0.5 + math_abs(math_cos(CurTime())) ^ 2 * 0.1)
	render.SuppressEngineLighting(true)
	render.ModelMaterialOverride(matWhite)
end

function CLASS:PostRenderEffects(pl)
	if render.SupportsVertexShaders_2_0() then
		render.PopCustomClipPlane()
		render.EnableClipping(false)
	end

	if nodraw then return end

	render.SetColorModulation(1, 1, 1)
	render.SetBlend(1)
	render.SuppressEngineLighting(false)
	render.ModelMaterialOverride()

	if render.SupportsPixelShaders_2_0() then
		render.UpdateRefractTexture()

		matRefract:SetFloat("$refractamount", 0.01)

		render.ModelMaterialOverride(matRefract)
		nodraw = true
		pl:DrawModel()
		nodraw = false
		render.ModelMaterialOverride(0)
	end
end

function CLASS:PrePlayerDraw(pl)
	pl:RemoveAllDecals()

	self:PreRenderEffects(pl)
end

function CLASS:PostPlayerDraw(pl)
	self:PostRenderEffects(pl)
end
