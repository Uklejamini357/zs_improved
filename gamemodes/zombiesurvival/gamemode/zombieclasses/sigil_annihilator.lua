CLASS.Name = "Sigil Annihilator"
CLASS.TranslationName = "class_sigil_annihilator"
CLASS.Description = "description_sigil_annihilator"
CLASS.Help = "controls_sigil_annihilator"

CLASS.Model = Model("models/Zombie/Poison.mdl")

CLASS.Wave = 7 / GM.NumberOfWaves
CLASS.Infliction = 0.82
CLASS.EndlessOnly = true

CLASS.Health = 335
CLASS.DynamicHealth = 5
CLASS.Speed = 130
CLASS.JumpPower = DEFAULT_JUMP_POWER * 1.081
CLASS.SWEP = "weapon_zs_sigilannihilator"

CLASS.Mass = DEFAULT_MASS * 1.5

CLASS.DamageNeedPerPoint = GM.PoisonZombiePointRatio
CLASS.Points = CLASS.Health/GM.PoisonZombiePointRatio

CLASS.PainSounds = {
	{"npc/zombie_poison/pz_pain1.wav", 75, 90},
	{"npc/zombie_poison/pz_pain2.wav", 75, 85},
	{"npc/zombie_poison/pz_pain3.wav", 75, 85}
}
CLASS.DeathSounds = {
	{"npc/zombie_poison/pz_die1.wav", 75, 90},
	{"npc/zombie_poison/pz_die2.wav", 75, 90}
}
CLASS.VoicePitch = 0.6

CLASS.ViewOffset = Vector(0, 0, 50)
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 64)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 35)}

CLASS.BloodColor = BLOOD_COLOR_YELLOW

local math_random = math.random

local ACT_IDLE = ACT_IDLE
local ACT_WALK = ACT_WALK
local STEPSOUNDTIME_NORMAL = STEPSOUNDTIME_NORMAL
local STEPSOUNDTIME_WATER_FOOT = STEPSOUNDTIME_WATER_FOOT
local STEPSOUNDTIME_ON_LADDER = STEPSOUNDTIME_ON_LADDER
local STEPSOUNDTIME_WATER_KNEE = STEPSOUNDTIME_WATER_KNEE

function CLASS:CalcMainActivity(pl, velocity)
	if velocity:Length2DSqr() <= 1 then
		return ACT_IDLE, -1
	end

	return ACT_WALK, -1
end

function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 and math_random(3) < 3 then
		pl:EmitSound("npc/zombie_poison/pz_right_foot1.wav", 75, 80)
	else
		pl:EmitSound("npc/zombie_poison/pz_left_foot1.wav", 75, 80)
	end

	return true
end

function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 365 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 300
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 450
	end

	return 150
end

function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MELEE_ATTACK1, true)
		return ACT_INVALID
	end
end

if SERVER then
	function CLASS:ProcessDamage(pl, dmginfo)
		dmginfo:ScaleDamage(1 - math.min(0.25, GAMEMODE:NumCorruptedSigils() * 0.15))
	end
	return
end

function CLASS:PrePlayerDraw(pl)
	render.SetColorModulation(0.17, 0.95, 0)
end

function CLASS:PostPlayerDraw(pl)
	render.SetColorModulation(1, 1, 1)
end


CLASS.Icon = "zombiesurvival/killicons/poisonzombie"
CLASS.IconColor = Color(63,255,63)
