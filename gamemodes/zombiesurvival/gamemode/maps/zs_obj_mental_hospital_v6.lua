hook.Add("SetupProps", "RemoveBoomstick", function()
	for _, ent in pairs(ents.FindByClass("prop_weapon")) do
		if ent:GetWeaponType() == "weapon_zs_boomstick" then
			ent:Remove()
		end
	end
end)

hook.Add("OnWaveStateChanged", "InfWave", function()
	if !GAMEMODE:IsEndlessMode() then return end
	if GAMEMODE:GetWave() < 5 then return end

	if !GAMEMODE:GetWaveActive() then
		gamemode.Call("SetWaveActive", true)
	end
	gamemode.Call("SetWaveEnd", CurTime() + 180)
	timer.Simple(0, function()
		if GAMEMODE:GetWaveEnd() ~= -1 then return end
		gamemode.Call("SetWaveEnd", CurTime() + 180)
	end)
	timer.Simple(0.1, function()
		if GAMEMODE:GetWaveEnd() ~= -1 then return end
		gamemode.Call("SetWaveEnd", CurTime() + 180)
	end)
end)
