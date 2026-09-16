-- GM.MapEventMode

if CLIENT then
    return
end

AddCSLuaFile()

local function SpawnProp(model, pos, ang, material, color, skin)
	local prop = ents.Create("prop_dynamic")
	prop:SetModel(model)
	prop:SetPos(pos)
	prop:SetAngles(ang)
	if material then
		prop:SetMaterial(material)
	end
	if color then
		prop:SetColor(color)
	end
	if skin then
		prop:SetSkin(skin)
	end
	prop:Spawn()
	prop:PhysicsInit(SOLID_VPHYSICS)
	
	local phys = prop:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	return prop
end

hook.Add("InitPostEntityMap", "CustomEvents", function()
    local GM = GAMEMODE

    if GM.MapEventMode == "td" then
        GAMEMODE.MapLivesLeft = 20

        PrintMessage(3, "Tower defense mode is now active.")

        SpawnProp("models/props_phx/construct/metal_plate4x4.mdl", Vector(798, -700, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(608, -700, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(418, -700, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(228, -700, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(38, -700, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-152, -700, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-342, -700, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-532, -700, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-722, -700, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-862, -652, -12288), Angle(0, 0, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-862, -462, -12288), Angle(0, 0, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-862, -272, -12288), Angle(0, 0, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-862, -82, -12288), Angle(0, 0, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-862, 108, -12288), Angle(0, 0, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-862, 298, -12288), Angle(0, 0, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-862, 488, -12288), Angle(0, 0, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-862, 678, -12288), Angle(0, 0, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-814, 818, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-624, 818, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-434, 818, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-244, 818, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-54, 818, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(86, 770, -12288), Angle(0, 0, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(38, 629, -12288), Angle(0, -90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-152, 629, -12288), Angle(0, -90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-342, 629, -12288), Angle(0, -90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-482, 581, -12288), Angle(0, 180, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-482, 391, -12288), Angle(0, 180, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-482, 201, -12288), Angle(0, 180, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-482, 11, -12288), Angle(0, 180, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-482, -178, -12288), Angle(0, 180, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-436, -320, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-246, -320, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-56, -320, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(86, -272, -12288), Angle(0, 0, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(38, -130, -12288), Angle(0, -90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-104, -82, -12288), Angle(0, 180, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(-56, 59, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(86, 107, -12288), Angle(0, 0, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(134, 249, -12288), Angle(0, -90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(324, 249, -12288), Angle(0, -90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(514, 249, -12288), Angle(0, -90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(656, 201, -12288), Angle(0, 180, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(608, 59, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(418, 59, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(276, 11, -12288), Angle(0, -0.001, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(324, -130, -12288), Angle(0, -90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(514, -130, -12288), Angle(0, -90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(704, -130, -12288), Angle(0, -90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(845, -82, -12288), Angle(0, 180, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(845, 107, -12288), Angle(0, 180, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(845, 297, -12288), Angle(0, 180, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(845, 487, -12288), Angle(0, 180, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(797, 629, -12288), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(656, 581, -12288), Angle(0, 0, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(608, 439, -12288), Angle(0, -90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(418, 439, -12288), Angle(0, -90, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(276, 487, -12288), Angle(0, 180, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(276, 677, -12288), Angle(0, 180, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(276, 866, -12288), Angle(0, 180, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(276, 1056, -12288), Angle(0, 180, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_phx/construct/metal_plate2x4.mdl", Vector(276, 1246, -12288), Angle(0, 180, 0), "", Color(255, 255, 255, 255), 0)
        SpawnProp("models/props_c17/substation_stripebox01a.mdl", Vector(276, 1294, -12196), Angle(0, 90, 0), "", Color(255, 255, 255, 255), 0):AddCallback("PhysicsCollide", function(ent, data)
			local pl = data.HitEntity

			if pl:IsValid() and pl:IsPlayer() and pl:Alive() and pl:Team() == TEAM_UNDEAD and ent.LastTouched ~= CurTime() then
                ent.LastTouched = CurTime()
                pl:KillSilent()
                pl:AddFrags(1)
                local zclass = pl:GetZombieClassTable()

                if !zclass then return end

                if zclass.SuperBoss then
                    GAMEMODE.MapLivesLeft = 0
                    BroadcastLua([[chat.AddText(COLOR_DARKRED, "SUPERBOSS DESTROYS THE BASE!!!!")]])
                elseif zclass.Boss then
                    GAMEMODE.MapLivesLeft = GAMEMODE.MapLivesLeft - 5
                    BroadcastLua([[chat.AddText(COLOR_RED, "THE BOSS HAS SEVERELY DAMAGED THE BASE!!!!")]])
                    PrintMessage(3, "Lives left: "..GAMEMODE.MapLivesLeft)
                elseif zclass.DemiBoss then
                    GAMEMODE.MapLivesLeft = GAMEMODE.MapLivesLeft - 3
                    BroadcastLua([[chat.AddText(COLOR_ORANGE, "A DEMIBOSS HAS DAMAGED THE BASE!")]])
                    PrintMessage(3, "Lives left: "..GAMEMODE.MapLivesLeft)
                elseif zclass.MiniBoss then
                    GAMEMODE.MapLivesLeft = GAMEMODE.MapLivesLeft - 2
                    PrintMessage(3, "Base got damaged! (By a miniboss) Lives left: "..GAMEMODE.MapLivesLeft)
                else
                    GAMEMODE.MapLivesLeft = GAMEMODE.MapLivesLeft - 1
                    PrintMessage(3, "Base got damaged! Lives left: "..GAMEMODE.MapLivesLeft)
                end


                if GAMEMODE.MapLivesLeft <= 0 then
                    local eff = EffectData()
                    eff:SetOrigin(ent:GetPos())
                    for i=1,5 do
                        util.Effect("Explosion", eff)
                    end
                    ent:Remove()

                    PrintMessage(3, "Game over! The base has been destroyed!")
                    timer.Simple(0.5, function()
                		SetGlobalVector("endcamerapos", Vector(276, 1294, -12196))
                        gamemode.Call("EndRound", TEAM_UNDEAD)
                    end)
                    timer.Simple(1.5, function()
                        for _,ply in pairs(team.GetPlayers(TEAM_HUMAN)) do
                            ply:StripWeapons()
                            ply:RemoveAllAmmo()
                            for item,count in pairs(ply:GetInventoryItems()) do
                                for i=1,count do
                                    ply:TakeInventoryItem(item)
                                end
                            end

                            ply:Kill()
                        end
                    end)
                else
                    if GAMEMODE.MapLivesLeft == 1 then
                        ent:EmitSound("ambient/alarms/siren.wav", 120)
                    end
                    ent:EmitSound("ambient/alarms/klaxon1.wav", 150, 150 - (1+GAMEMODE.MapLivesLeft*2.5))
                end
			end
		end)

        local gas = ents.Create("zombiegasses")
        gas:SetPos(Vector(798, -700, -12288))
        gas:Spawn()

        local hspawn = ents.Create("info_player_human")
        hspawn:SetPos(Vector(550, 850, -12288))
        hspawn:SetAngles(Angle(0,-90,0))
        hspawn:Spawn()

        local zspawn = ents.Create("info_player_zombie")
        zspawn:SetPos(Vector(798, -700, -12280))
        zspawn:SetAngles(Angle(0,180,0))
        zspawn:Spawn()

        local target = ents.Create("info_target")
        target:SetPos(Vector(276, 1340, -12196))
        target:Spawn()
        GAMEMODE.BaseTarget = target
        if D3bot then
            D3bot.ForceTarget = target
        end

        return
    end

    for _,ply in ipairs(player.GetHumans()) do
        if !ply:IsAdmin() then continue end

        ply:PrintMessage(3, "This map has custom events!")
        ply:PrintMessage(3, "!td - Do a tower defense event (requires d3bot to be modified first)")
        ply:PrintMessage(3, "!normal - Go back to normal")
    end
end)

hook.Add("Think", "Customevents", function()
    if GAMEMODE.MapEventMode ~= "td" then return end

    local zpos = ents.FindByClass("info_player_zombie")[1]:GetPos()
    local hpos = ents.FindByClass("info_player_human")[1]:GetPos()
    for _,zm in ipairs(team.GetPlayers(TEAM_UNDEAD)) do
        if zm:Alive() and zm:GetPos().z < -12400 then
            zm:SetPos(zpos)
        end
    end

    for _,hm in ipairs(team.GetPlayers(TEAM_HUMAN)) do
        if hm:Alive() and hm:GetPos().z < -12400 then
            hm:SetPos(hpos)
        end
    end
end)

hook.Add("PlayerSay", "CustomEvents.PlayerSay", function(pl, text)
    if !pl:IsAdmin() then return end

    local GM = GAMEMODE
    if text == "!td" then
        timer.Simple(0, function()
            if GM.MapEventMode == "td" then pl:PrintMessage(3, "event mode already set to td") return end
            if GM:GetWave() ~= 0 then pl:PrintMessage(3, "round cannot be active while switching") return end
            GM.MapEventMode = "td"
            PrintMessage(3, "event mode set to td")

            gamemode.Call("SaveAllVaults")
            gamemode.Call("PreRestartRound")
            gamemode.Call("RestartRound")
        end)
    elseif text == "!normal" then
        timer.Simple(0, function()
            if !GM.MapEventMode then pl:PrintMessage(3, "its already normal, what") return end
            if GM:GetWave() ~= 0 then pl:PrintMessage(3, "round cannot be active while switching") return end
            GM.MapEventMode = nil
            PrintMessage(3, "deleted event mode")

            gamemode.Call("SaveAllVaults")
            gamemode.Call("PreRestartRound")
            gamemode.Call("RestartRound")
        end)
    end
end)

hook.Add("OnWaveStateChanged", "Customevents", function()
    local wave = GAMEMODE:GetWave()
    local active = GAMEMODE:GetWaveActive()

    if active then
        if wave == 1 then
            PrintMessage(3, "Welcome to tower defense event.")
            timer.Simple(1, function()
                PrintMessage(3, "You must protect the base from incoming zombies.")
            end)
            timer.Simple(2, function()
                PrintMessage(3, "The base has 20 lives - each time zombie passes, 1 life is lost.")
            end)
            timer.Simple(3, function()
                PrintMessage(3, "ZOMBIES ONLY: Follow the path and reach the end. No cheating!")
            end)
            timer.Simple(4, function()
                PrintMessage(3, "If the base gets destroyed, all humans will lose!")
            end)
            timer.Simple(5, function()
                PrintMessage(3, "Have fun!")
            end)
        end

        if wave >= 6 then
            GAMEMODE:SetWaveEnd(CurTime() + 120+wave*10)
        else
            GAMEMODE:SetWaveEnd(CurTime() + 120)
        end
    else
        GAMEMODE:SetWaveStart(CurTime() + 20)
    end
end)

