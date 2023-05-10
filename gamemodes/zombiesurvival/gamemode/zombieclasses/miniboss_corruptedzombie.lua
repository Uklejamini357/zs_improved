CLASS.Name = "Corrupted Zombie"
CLASS.TranslationName = "class_corrupted_zombie"
CLASS.Description = "description_corrupted_zombie"
CLASS.Help = "controls_corrupted_zombie"

CLASS.Base = "zombie"

CLASS.Health = 335
CLASS.DynamicHealth = 20
CLASS.Speed = 180
CLASS.Revives = true

CLASS.CanTaunt = true
CLASS.MiniBoss = true

CLASS.DamageNeedPerPoint = GM.HumanoidZombiePointRatio
CLASS.Points = CLASS.Health/GM.HumanoidZombiePointRatio

CLASS.SWEP = "weapon_zs_zombie"

CLASS.Model = Model("models/player/zombie_classic_hbfix.mdl")

CLASS.PainSounds = {"npc/zombie/zombie_pain1.wav", "npc/zombie/zombie_pain2.wav", "npc/zombie/zombie_pain3.wav", "npc/zombie/zombie_pain4.wav", "npc/zombie/zombie_pain5.wav", "npc/zombie/zombie_pain6.wav"}
CLASS.DeathSounds = {"npc/zombie/zombie_die1.wav", "npc/zombie/zombie_die2.wav", "npc/zombie/zombie_die3.wav"}

CLASS.VoicePitch = 0.65

CLASS.CanFeignDeath = true

if SERVER then
	function CLASS:ProcessDamage(pl, dmginfo)
		dmginfo:ScaleDamage(1 - math.min(0.35, GAMEMODE:NumCorruptedSigils() * 0.125))
	end
	return
end

CLASS.Icon = "zombiesurvival/killicons/zombie"
CLASS.IconColor = Color(191, 255, 191)
