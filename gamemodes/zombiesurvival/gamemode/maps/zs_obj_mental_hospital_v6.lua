hook.Add("SetupProps", "RemoveBoomstick", function()
	for _, ent in pairs(ents.FindByClass("prop_weapon")) do
		if ent:GetWeaponType() == "weapon_zs_boomstick" then
			ent:Remove()
		end
	end
end)

hook.Add("AcceptInput", "InfWavesOnEndless", function(ent, input)
	if (ent:GetName() == "infinite_wave" or ent:GetName() == "wave_5_end_time") and GAMEMODE:IsEndlessMode() then
		return true
	end
end)
