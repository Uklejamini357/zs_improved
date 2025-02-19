CLASS.Base = "freshdead"

CLASS.Hidden = true

CLASS.Name = "ZE Super Zombie"
CLASS.TranslationName = "class_super_zombie"

CLASS.Health = 1600
CLASS.Speed = SPEED_ZOMBIEESCAPE_ZOMBIE
CLASS.DamageNeedPerPoint = 0
CLASS.Points = 8

CLASS.SWEP = "weapon_zs_zesuperzombie"

CLASS.UsePlayerModel = true
CLASS.UsePreviousModel = false
CLASS.NoFallDamage = true

local ACT_ZOMBIE_CLIMB_UP = ACT_ZOMBIE_CLIMB_UP
local math_Clamp = math.Clamp
local bit_band = bit.band

if SERVER then
	function CLASS:OnKilled(pl, attacker, inflictor, suicide, headshot, dmginfo) end

	function CLASS:AltUse(pl)
		if not GAMEMODE.ZombieEscape then
			pl:StartFeignDeath()
		end
	end

	function CLASS:ProcessDamage(pl, dmginfo)
		if bit_band(dmginfo:GetDamageType(), DMG_BULLET) ~= 0 then
			pl:SetVelocity(dmginfo:GetAttacker():GetAimVector() * dmginfo:GetDamage() * ZE_KNOCKBACKSCALE)
		end
	end
end

function CLASS:Move(pl, mv)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.Move and wep:Move(mv) then
		return true
	end
end

function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetClimbing and wep:GetClimbing() then
		return ACT_ZOMBIE_CLIMB_UP, -1
	end

	return self.BaseClass.CalcMainActivity(self, pl, velocity)
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.GetClimbing and wep:GetClimbing() then
		local vel = pl:GetVelocity()
		local speed = vel:LengthSqr()
		if speed > 64 then
			pl:SetPlaybackRate(math_Clamp(speed / 3600, 0, 1) * (vel.z < 0 and -1 or 1) * 0.25)
		else
			pl:SetPlaybackRate(0)
		end

		return true
	end

	return self.BaseClass.UpdateAnimation(self, pl, velocity, maxseqgroundspeed)
end

if SERVER then return end

CLASS.Icon = "zombiesurvival/killicons/fresh_dead"
CLASS.IconColor = Color(127, 255, 127)
