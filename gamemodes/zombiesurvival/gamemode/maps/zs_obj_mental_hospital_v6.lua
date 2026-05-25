hook.Add("SetupProps", "RemoveBoomstick", function()
	for _, ent in pairs(ents.FindByClass("prop_weapon")) do
		if ent:GetWeaponType() == "weapon_zs_boomstick" then
			ent:Remove()
		end
	end
end)

-- hook.Add("AcceptInput", "InfWavesOnEndless", function(ent, input)
-- 	if (ent:GetName() == "infinite_wave" or ent:GetName() == "wave_5_end_time") and GAMEMODE:IsEndlessMode() then
-- 		local wavetime = GAMEMODE:GetWaveEnd()
-- 		timer.Simple(0, function()
-- 			GAMEMODE:SetWaveEnd(wavetime)
-- 		end)
-- 		return true
-- 	end
-- end)

-- hook.Add("OnWaveStateChanged", "InfWave", function()
-- 	if !GAMEMODE:IsEndlessMode() then return end
-- 	if GAMEMODE:GetWaveActive() then return end
-- 	if GAMEMODE:GetWave() < 5 then return end

-- 	gamemode.Call("SetWaveActive", true)
-- 	gamemode.Call("SetWaveEnd", CurTime() + 180)
-- end)
