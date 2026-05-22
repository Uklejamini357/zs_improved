hook.Add("InitPostEntityMap", "Adding", function()
	

	for _, ent in ipairs(ents.FindInSphere(Vector(-3069.6348, -1300.0313, -159.9688), 24)) do
		if ent:GetClass() == "func_button" then ent:Remove() end
	end
end)
