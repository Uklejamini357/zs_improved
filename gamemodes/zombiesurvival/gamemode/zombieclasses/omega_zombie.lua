CLASS.Base = "zombie"

CLASS.Name = "Omega Zombie"
CLASS.TranslationName = "class_omega_zombie"
CLASS.Description = "description_omega_zombie"
CLASS.Help = "controls_omega_zombie"

CLASS.Wave = 17 / GM.NumberOfWaves
CLASS.EndlessOnly = true

CLASS.Health = 625
CLASS.DynamicHealth = 20
CLASS.Speed = 195

CLASS.CanTaunt = true

CLASS.DamageNeedPerPoint = GM.HumanoidZombiePointRatio * 0.85
CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio * 0.85

CLASS.SWEP = "weapon_zs_omega_zombie"

CLASS.Model = Model("models/player/zombie_classic_hbfix.mdl")

CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

CLASS.VoicePitch = 0.65

CLASS.CanFeignDeath = true

function CLASS:OnSpawned(pl)
	pl:SetNW2Float("SpawnTime", CurTime())
end

if SERVER then return end
CLASS.Icon = "zombiesurvival/killicons/zombie"
CLASS.IconColor = Color(0, 128, 255)

local matSkin = Material("models/Zombie_Classic/Zombie_Classic_sheet.vtf")

function CLASS:PrePlayerDraw(pl)
	render.ModelMaterialOverride(matSkin)
	local col = HSVToColor((CurTime() - pl:GetNW2Float("SpawnTime", 0)) * 85 % 360, 1, 1)
	render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
end

function CLASS:PostPlayerDraw(pl)
	render.ModelMaterialOverride()
	render.SetColorModulation(1, 1, 1)
end

