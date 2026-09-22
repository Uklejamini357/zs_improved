function GM:ConCommandErrorMessage(pl, message)
	pl:CenterNotify(COLOR_RED, message)
	pl:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
end

concommand.Add("zs_pointsshopbuy", function(sender, command, arguments)
	if not (sender:IsValid() and sender:IsConnected() and sender:IsValidLivingHuman()) or #arguments == 0 then return end
	local usescrap = arguments[2]

	local midwave = GAMEMODE:GetWave() < GAMEMODE:GetNumberOfWaves() / 2 or GAMEMODE:GetWave() == GAMEMODE:GetNumberOfWaves() / 2 and GAMEMODE:GetWaveActive() and CurTime() < GAMEMODE:GetWaveEnd() - (GAMEMODE:GetWaveEnd() - GAMEMODE:GetWaveStart()) / 2
	if sender:IsSkillActive(SKILL_D_LATEBUYER) and not usescrap and midwave then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "late_buyer_warning"))
		return
	end

	if usescrap and not sender:NearRemantler() or not usescrap and not sender:NearArsenalCrate() and GAMEMODE:GetArsenalRequiredToBuyItems() then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, usescrap and "need_to_be_near_remantler" or "need_to_be_near_arsenal_crate"))
		return
	end

	if not (usescrap or gamemode.Call("PlayerCanPurchase", sender)) then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "cant_purchase_right_now"))
		return
	end

	local id = arguments[1]
	id = tonumber(id) or id
	local itemtab = FindItem(id)

	if not itemtab or not itemtab.PointShop then return end
	local itemcat = itemtab.Category
	if usescrap and not (itemcat == ITEMCAT_TRINKETS or itemcat == ITEMCAT_AMMO) and not itemtab.CanMakeFromScrap then return end

	local points = usescrap and sender:GetAmmoCount("scrap") or sender:GetPoints()
	local cost = itemtab.Price

	if GAMEMODE:IsClassicMode() and itemtab.NoClassicMode then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientFormat(sender, "cant_use_x_in_classic", itemtab.Name))
		return
	end

	if GAMEMODE.ZombieEscape and itemtab.NoZombieEscape then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientFormat(sender, "cant_use_x_in_zombie_escape", itemtab.Name))
		return
	end

	if not GAMEMODE.EndlessMode and itemtab.EndlessModeOnly then
		GAMEMODE:ConCommandErrorMessage(sender, "This item cannot be purchased in non-Endless mode!")
		return
	end

	if itemtab.SkillRequirement and not sender:IsSkillActive(itemtab.SkillRequirement) then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientFormat(sender, "x_requires_a_skill_you_dont_have", itemtab.Name))
		return
	end

	local waveunlock = itemtab.WaveUnlock or itemtab.Tier
	if waveunlock and GAMEMODE.LockItemTiers and not GAMEMODE.ObjectiveMap and not GAMEMODE.ZombieEscape and not GAMEMODE:IsClassicMode() and GAMEMODE:GetNumberOfWaves() == GAMEMODE.NumberOfWaves and GAMEMODE:GetWave() + (GAMEMODE:GetWaveActive() and 0 or 1) < itemtab.Tier then
		if itemtab.WaveUnlock then
			GAMEMODE:ConCommandErrorMessage(sender, translate.ClientFormat(sender, "this_item_unlocks_at_wave_x", waveunlock))
--			GAMEMODE:ConCommandErrorMessage(sender, Format("This item unlocks at wave %d", waveunlock))
		else
			GAMEMODE:ConCommandErrorMessage(sender, translate.ClientFormat(sender, "tier_x_items_unlock_at_wave_y", waveunlock, waveunlock))
		end
		return
	end

	if not GAMEMODE:HasItemStocks(id) then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "out_of_stock"))
		return
	end

	if itemtab.CanBuy and not itemtab.CanBuy(sender) then
		return
	end

	cost = usescrap and math.ceil(GAMEMODE:PointsToScrap(cost) * sender:GetRemantlerPrices()) or math.floor(cost * sender:GetArsenalPrices())

	if points < cost then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, usescrap and "need_to_have_enough_scrap" or "dont_have_enough_points"))
		return
	end

	if itemtab.Callback then
		itemtab.Callback(sender)
	elseif itemtab.SWEP then
		if string.sub(itemtab.SWEP, 1, 6) ~= "weapon" then
			if GAMEMODE:GetInventoryItemType(itemtab.SWEP) == INVCAT_TRINKETS and sender:HasInventoryItem(itemtab.SWEP) then
				local wep = ents.Create("prop_invitem")
				if wep:IsValid() then
					wep:SetPos(sender:GetShootPos())
					wep:SetAngles(sender:GetAngles())
					wep:SetInventoryItemType(itemtab.SWEP)
					wep:Spawn()
				end
			else
				sender:AddInventoryItem(itemtab.SWEP)
			end
		elseif sender:HasWeapon(itemtab.SWEP) then
			local stored = weapons.Get(itemtab.SWEP)
			if stored and stored.AmmoIfHas then
				sender:GiveAmmo(stored.Primary.DefaultClip, stored.Primary.Ammo)
			else
				local wep = ents.Create("prop_weapon")
				if wep:IsValid() then
					wep:SetPos(sender:GetShootPos())
					wep:SetAngles(sender:GetAngles())
					wep:SetWeaponType(itemtab.SWEP)
					wep:SetShouldRemoveAmmo(true)
					wep:Spawn()
				end
			end
		else
			local wep = sender:Give(itemtab.SWEP)
			if wep and wep:IsValid() and wep.EmptyWhenPurchased and wep:GetOwner():IsValid() then
				if wep.Primary then
					local primary = wep:ValidPrimaryAmmo()
					if primary then
						sender:RemoveAmmo(math.max(0, wep.Primary.DefaultClip - wep.Primary.ClipSize), primary)
					end
				end
				if wep.Secondary then
					local secondary = wep:ValidSecondaryAmmo()
					if secondary then
						sender:RemoveAmmo(math.max(0, wep.Secondary.DefaultClip - wep.Secondary.ClipSize), secondary)
					end
				end
			end
		end

		GAMEMODE.StatTracking:IncreaseElementKV(STATTRACK_TYPE_WEAPON, itemtab.SWEP, "Purchases", 1)
	else
		return
	end

	if usescrap then
		sender:RemoveAmmo(cost, "scrap")
		sender:SendLua("surface.PlaySound(\"buttons/lever"..math.random(5)..".wav\")")
	else
		sender:TakePoints(cost)
		sender:SendLua("surface.PlaySound(\"ambient/levels/labs/coinslot1.wav\")")
	end
	sender:PrintTranslatedMessage(HUD_PRINTTALK, usescrap and "created_x_for_y_scrap" or "purchased_x_for_y_points", itemtab.Name, cost)

	GAMEMODE:AddItemStocks(id, -1)

	if usescrap then
		local nearest = sender:NearestRemantler()
		if nearest then
			local owner = nearest.GetObjectOwner and nearest:GetObjectOwner() or nearest:GetOwner()
			if owner:IsValid() and owner ~= sender then
				local scrapcom = math.ceil(cost / 8)
				nearest:SetScraps(nearest:GetScraps() + scrapcom)
				nearest:GetObjectOwner():CenterNotify(COLOR_GREEN, translate.Format("remantle_used", scrapcom))
			end
		end
	else
		local nearest = sender:NearestArsenalCrateOwnedByOther()
		if nearest then
			local owner = nearest.GetObjectOwner and nearest:GetObjectOwner() or nearest:GetOwner()
			if owner:IsValid() then
				local commission = cost * GAMEMODE.ArsenalCrateCommission
				if commission > 0 then
					owner:AddPoints(commission, nil, nil, true)

					net.Start("zs_commission")
						net.WriteEntity(nearest)
						net.WriteEntity(sender)
						net.WriteFloat(commission)
					net.Send(owner)
				end
			end
		end
	end
end)

concommand.Add("zs_dismantle", function(sender, command, arguments)
	if not (sender:IsValid() and sender:IsConnected() and sender:IsValidLivingHuman()) then return end

	local invitem, itypecat, potinv
	if #arguments > 0 then
		invitem = arguments[1]
	end

	if invitem and not sender:HasInventoryItem(invitem) then return end

	local active = sender:GetActiveWeapon()
	local contents, wtbl = active:GetClass()
	if not invitem then
		wtbl = weapons.Get(contents)
		if not wtbl and active:IsValid() then
			GAMEMODE:ConCommandErrorMessage(sender, "NO.")
			return
		end
		
		if wtbl.NoDismantle or not (wtbl.AllowQualityWeapons or wtbl.PermitDismantle) then
			GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "cannot_dismantle"))
			return
		end

		if wtbl.AmmoIfHas and sender:GetAmmoCount(wtbl.Primary.Ammo) == 0 and active:Clip1() == 0 then
			sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
			return
		end

		potinv = GAMEMODE.Breakdowns[contents]
	else
		itypecat = GAMEMODE:GetInventoryItemType(invitem)
		if itypecat ~= INVCAT_TRINKETS or GAMEMODE.ZSInventoryItemData[invitem].PermitDismantle then
			GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "cannot_dismantle"))
			return
		end

		potinv = GAMEMODE.Breakdowns[invitem]
	end

	local scrap = GAMEMODE:GetDismantleScrap(wtbl or GAMEMODE.ZSInventoryItemData[invitem], invitem)
	net.Start("zs_ammopickup")
		net.WriteUInt(scrap, 16)
		net.WriteString("scrap")
	net.Send(sender)
	sender:GiveAmmo(scrap, "scrap")

	if invitem then
		sender:TakeInventoryItem(invitem)
	else
		sender:GetActiveWeapon():EmptyAll(true)

		if wtbl and wtbl.AmmoIfHas then
			sender:RemoveAmmo(1, wtbl.Primary.Ammo)
		end

		if wtbl and (wtbl.AmmoIfHas and sender:GetAmmoCount(wtbl.Primary.Ammo) == 0 or !wtbl.AmmoIfHas) then
			sender:StripWeapon(contents)
		end
		sender:UpdateAltSelectedWeapon()
	end


	GAMEMODE.StatTracking:IncreaseElementKV(STATTRACK_TYPE_WEAPON, invitem or contents, "Disassembles", 1)

	if potinv and potinv.Result then
		sender:AddInventoryItem(potinv.Result)

		net.Start("zs_invitem")
			net.WriteString(potinv.Result)
		net.Send(sender)
	end
end)

concommand.Add("zs_upgrade", function(sender, command, arguments)
	if not (sender:IsValid() and sender:IsConnected() and sender:IsValidLivingHuman()) then return end

	if not sender:NearRemantler() then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "need_to_be_near_remantler"))
		return
	end

	local nearest = sender:NearestRemantler()
	local contents = sender:GetActiveWeapon():GetClass()
	local contentstbl = weapons.Get(contents)
	local contentsqua = contentstbl.QualityTier
	local desiredqua = contentsqua and contentsqua + 1 or 1

	local branch = contentstbl.Branch
	if not contentsqua and #arguments > 0 then
		branch = tonumber(arguments[1])
	end

	if not (nearest and nearest:IsValid() and contents) then return end

	local wtbl = weapons.Get(contents)
	local scrapcost = math.ceil(GAMEMODE:GetUpgradeScrap(wtbl, desiredqua) * sender:GetRemantlerPrices())

	if wtbl.AmmoIfHas and sender:GetAmmoCount(wtbl.Primary.Ammo) == 0 then
		sender:SendLua("surface.PlaySound(\"buttons/button10.wav\")")
		return
	end

	if sender:GetAmmoCount("scrap") < scrapcost then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "need_to_have_enough_scrap"))
		return
	end

	local upgclass = GAMEMODE:GetWeaponClassOfQuality(not contentsqua and contents or contentstbl.BaseQuality, desiredqua, branch)
	local classtbl = weapons.Get(upgclass)
	if not classtbl then return end

	if !wtbl.AmmoIfHas and sender:HasWeapon(upgclass) then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "remantle_cannot"))
		return
	end

	local upgname = classtbl.PrintName
	sender:CenterNotify(COLOR_CYAN, translate.ClientGet(sender, "remantle_success"), color_white, " "..upgname)
	sender:SendLua("surface.PlaySound(\"buttons/lever"..math.random(5)..".wav\")")
	sender:RemoveAmmo(scrapcost, "scrap")

	local wep
	if !sender:HasWeapon(upgclass) then
		wep = sender:GiveEmptyWeapon(upgclass)
	else
		wep = sender:GetWeapon(upgclass)
	end
	if wep and wep:IsValid() then
		sender:GetActiveWeapon():EmptyAll(true)
		local lessammo = sender:GetAmmoCount(wtbl.Primary.Ammo) <= 1
		if !wtbl.AmmoIfHas or lessammo then
			sender:StripWeapon(contents)
		end
		if !wtbl.AmmoIfHas or lessammo or arguments[2] == 1 then
			sender:SelectWeapon(upgclass)
		end
		sender:UpdateAltSelectedWeapon()

		if wtbl.AmmoIfHas then
			sender:RemoveAmmo(1, wtbl.Primary.Ammo)
		end
		if wep.AmmoIfHas then
			sender:GiveAmmo(1, wep.Primary.Ammo)
		end

		net.Start("zs_remantleconf")
		net.Send(sender)

		GAMEMODE.StatTracking:IncreaseElementKV(STATTRACK_TYPE_WEAPON, upgclass, "Upgrades", 1)
	end

	local owner = nearest.GetObjectOwner and nearest:GetObjectOwner() or nearest:GetOwner()
	if owner:IsValid() and owner ~= sender then
		local scrapcom = math.ceil(scrapcost * 0.08)
		nearest:SetScraps(nearest:GetScraps() + scrapcom)
		nearest:GetObjectOwner():CenterNotify(COLOR_GREEN, translate.Format("remantle_used", scrapcom))
	end
end)

concommand.Add("worthrandom", function(sender, command, arguments)
	if sender:IsValid() and sender:IsConnected() and gamemode.Call("PlayerCanCheckout", sender) then
		gamemode.Call("GiveRandomEquipment", sender)
	end
end)

concommand.Add("worthcheckout", function(sender, command, arguments)
	if not (sender:IsValid() and sender:IsConnected()) or #arguments == 0 then return end

	if not gamemode.Call("PlayerCanCheckout", sender) then
		sender:CenterNotify(COLOR_RED, translate.ClientGet(sender, "cant_use_worth_anymore"))
		return
	end

	local cost = 0
	local hasalready = {}

	for _, id in pairs(arguments) do
		id = tonumber(id) or id

		local tab = FindStartingItem(id)
		if tab and not hasalready[id] and (not tab.SkillRequirement or sender:IsSkillActive(tab.SkillRequirement)) then
			cost = cost + tab.Price
			hasalready[id] = true
		end
	end

	if cost > GAMEMODE.StartingWorth + (sender.ExtraStartingWorth or 0) then return end

	hasalready = {}

	for _, id in pairs(arguments) do
		id = tonumber(id) or id

		local tab = FindStartingItem(id)
		if tab and not hasalready[id] then
			if tab.SkillRequirement and not sender:IsSkillActive(tab.SkillRequirement) then
				sender:PrintMessage(HUD_PRINTTALK, translate.ClientFormat(sender, "x_requires_a_skill_you_dont_have", tab.Name))
			elseif tab.NoClassicMode and GAMEMODE:IsClassicMode() then
				sender:PrintMessage(HUD_PRINTTALK, translate.ClientFormat(sender, "cant_use_x_in_classic_mode", tab.Name))
			elseif tab.Callback then
				tab.Callback(sender)
				hasalready[id] = true
			elseif tab.SWEP then
				GAMEMODE.StatTracking:IncreaseElementKV(STATTRACK_TYPE_WEAPON, tab.SWEP, "Checkouts", 1)

				sender:StripWeapon(tab.SWEP) -- "Fixes" players giving each other empty weapons to make it so they get no ammo from the Worth menu purchase.
				if GAMEMODE.ZSInventoryItemData[tab.SWEP] then
					sender:AddInventoryItem(tab.SWEP)
				else
					sender:Give(tab.SWEP)
				end
				hasalready[id] = true
			end
		end
	end

	if table.Count(hasalready) > 0 then
		GAMEMODE.CheckedOut[sender:UniqueID()] = true
	end

	gamemode.Call("RemoveDuplicateAmmo", sender)
end)

concommand.Add("zsdropweapon", function(sender, command, arguments)
	local currentwep = sender:GetActiveWeapon()
	if GAMEMODE.ZombieEscape then
		local hwep, zwep = sender:GetWeapon("weapon_elite"), sender:GetWeapon("weapon_knife")
		if hwep and hwep:IsValid() then
			sender:DropWeapon(hwep)
		elseif zwep and zwep:IsValid() then
			sender:DropWeapon(zwep)
		end

		return
	end

	if not (sender:IsValid() and sender:Alive() and sender:Team() == TEAM_HUMAN) or CurTime() < (sender.NextWeaponDrop or 0) or GAMEMODE.ZombieEscape then return end
	sender.NextWeaponDrop = CurTime() + 0.15

	local invitem
	if #arguments > 0 then
		invitem = arguments[1]
	end
	if invitem and not sender:HasInventoryItem(invitem) then return end

	if invitem or (currentwep and currentwep:IsValid()) then
		local ent = invitem and sender:DropInventoryItemByType(invitem) or sender:DropWeaponByType(currentwep:GetClass())
		if ent and ent:IsValid() then
			local shootpos = sender:GetShootPos()
			local aimvec = sender:GetAimVector()
			ent:SetPos(util.TraceHull({start = shootpos, endpos = shootpos + aimvec * 32, mask = MASK_SOLID, filter = sender, mins = Vector(-2, -2, -2), maxs = Vector(2, 2, 2)}).HitPos)
			ent:SetAngles(sender:GetAngles())
		end
	end
end)

concommand.Add("zsemptyclip", function(sender, command, arguments)
	if GAMEMODE.ZombieEscape then return end

	if not (sender:IsValid() and sender:Alive() and sender:Team() == TEAM_HUMAN) then return end

	sender.NextEmptyClip = sender.NextEmptyClip or 0
	if sender.NextEmptyClip <= CurTime() then
		sender.NextEmptyClip = CurTime() + 0.1

		local wep = sender:GetActiveWeapon()
		if wep:IsValid() and (not wep.NoMagazine and not wep.AmmoIfHas or wep.AllowEmpty) then
			local primary = wep:ValidPrimaryAmmo()
			if primary and 0 < wep:Clip1() then
				sender:GiveAmmo(wep:Clip1(), primary, true)
				wep:SetClip1(0)
			end
			local secondary = wep:ValidSecondaryAmmo()
			if secondary and 0 < wep:Clip2() then
				sender:GiveAmmo(wep:Clip2(), secondary, true)
				wep:SetClip2(0)
			end
		end
	end
end)

function GM:TryGetLockOnTrace(sender, arguments)
	local ent
	local dent = Entity(tonumbersafe(arguments[2] or 0) or 0)
	if GAMEMODE:ValidMenuLockOnTarget(sender, dent) then
		ent = dent
	end

	if not ent then
		ent = sender:MeleeTrace(48, 2, nil, nil, true).Entity
	end

	return ent
end

concommand.Add("zsgiveammo", function(sender, command, arguments)
	if GAMEMODE.ZombieEscape then return end

	if not sender:IsValid() or not sender:Alive() or sender:Team() ~= TEAM_HUMAN then return end

	local ammotype = arguments[1]
	local amount = arguments[3]
	if not ammotype or #ammotype == 0 or not GAMEMODE.AmmoCache[ammotype] then return end

	local count = sender:GetAmmoCount(ammotype)
	if count <= 0 then
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "no_spare_ammo_to_give"))
		return
	end

	local ent = GAMEMODE:TryGetLockOnTrace(sender, arguments)
	if ent and ent:IsValidLivingHuman() then
		local desiredgive = math.min(count, amount or GAMEMODE.AmmoCache[ammotype])
		if desiredgive >= 1 then
			sender:RemoveAmmo(desiredgive, ammotype)
			ent:GiveAmmo(desiredgive, ammotype)

			if CurTime() >= (sender.NextGiveAmmoSound or 0) then
				sender.NextGiveAmmoSound = CurTime() + 1
				sender:PlayGiveAmmoSound()
			end

			sender:RestartGesture(ACT_GMOD_GESTURE_ITEM_GIVE)

			net.Start("zs_ammogive")
				net.WriteUInt(desiredgive, 16)
				net.WriteString(ammotype)
				net.WriteEntity(ent)
			net.Send(sender)

			net.Start("zs_ammogiven")
				net.WriteUInt(desiredgive, 16)
				net.WriteString(ammotype)
				net.WriteEntity(sender)
			net.Send(ent)

			return
		end
	else
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "no_person_in_range"))
	end
end)

concommand.Add("zsgiveweapon", function(sender, command, arguments)
	if GAMEMODE.ZombieEscape then return end

	if not (sender:IsValid() and sender:Alive() and sender:Team() == TEAM_HUMAN) then return end

	local invitem
	if #arguments > 0 then
		invitem = arguments[2]
	end
	if invitem and not sender:HasInventoryItem(invitem) then return end

	local currentwep = sender:GetActiveWeapon()
	if not invitem and not IsValid(currentwep) then return end

	local ent = GAMEMODE:TryGetLockOnTrace(sender, arguments)
	if ent and ent:IsValidLivingHuman() then
		if not invitem then
			if ent:HasWeapon(currentwep:GetClass()) then
				GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "person_has_weapon"))
			else
				sender:GiveWeaponByType(currentwep, ent, false)
			end
		else
			sender:GiveInventoryItemByType(invitem, ent)
		end
	else
		GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "no_person_in_range"))
	end
end)

concommand.Add("zsgiveweaponclip", function(sender, command, arguments)
	if GAMEMODE.ZombieEscape then return end

	if not (sender:IsValid() and sender:Alive() and sender:Team() == TEAM_HUMAN) then return end

	local currentwep = sender:GetActiveWeapon()
	if currentwep and currentwep:IsValid() then
		local ent = GAMEMODE:TryGetLockOnTrace(sender, arguments)
		if ent and ent:IsValidLivingHuman() then
			if not ent:HasWeapon(currentwep:GetClass()) then
				sender:GiveWeaponByType(currentwep, ent, true)
			else
				GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "person_has_weapon"))
			end
		else
			GAMEMODE:ConCommandErrorMessage(sender, translate.ClientGet(sender, "no_person_in_range"))
		end
	end
end)

concommand.Add("zsdropammo", function(sender, command, arguments)
	if GAMEMODE.ZombieEscape then return end

	if not sender:IsValid() or not sender:Alive() or sender:Team() ~= TEAM_HUMAN or CurTime() < (sender.NextDropClip or 0) then return end

	sender.NextDropClip = CurTime() + 0.2

	local wep = sender:GetActiveWeapon()
	if not wep:IsValid() then return end

	local ammotype = arguments[1] or wep:GetPrimaryAmmoTypeString()
	local amount = arguments[2]
	if GAMEMODE.AmmoNames[ammotype] and GAMEMODE.AmmoCache[ammotype] then
		local ent = sender:DropAmmoByType(ammotype, amount or GAMEMODE.AmmoCache[ammotype] * 2)
		if ent and ent:IsValid() then
			ent:SetPos(sender:EyePos() + sender:GetAimVector() * 8)
			ent:SetAngles(sender:GetAngles())
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:SetVelocityInstantaneous(sender:GetVelocity() * 0.85)
			end
		end
	end
end)

concommand.Add("zs_resupplyammotype", function(sender, command, arguments)
	if GAMEMODE.ZombieEscape then return end

	if not (sender:IsValid() and sender:Alive() and sender:Team() == TEAM_HUMAN) then return end

	local ammotype = arguments[1]
	if not ammotype or #ammotype == 0 or not (ammotype == "default" or GAMEMODE.AmmoResupply[ammotype]) then return end

	sender.ResupplyChoice = ammotype ~= "default" and ammotype or nil
end)

-- admin commands?

concommand.Add("zs_shitmap_check", function(sender, command, arguments)
	if not sender:IsAdmin() then return end

	local teleporters = ents.FindByClass("trigger_teleport")
	local buttons = ents.FindByClass("func_button")
	local doors = ents.FindByClass("func_door_rotating")
	table.Add(doors, ents.FindByClass("func_movelinear"))

	sender:PrintMessage(HUD_PRINTCONSOLE, "Teleports: "..#teleporters.." Buttons: "..#buttons.." Doors: "..#doors)
end)

concommand.Add("zs_shitmap_toteleport", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local ent = ents.FindByClass("trigger_teleport")[tonumber(arguments[1])]
	if ent then
		sender:SetPos(ent:WorldSpaceCenter())
	end
end)

concommand.Add("zs_shitmap_teleport_on", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	for _, ent in pairs(ents.FindByClass("trigger_teleport")) do
		ent:Fire("enable", "", 0)
	end
end)

concommand.Add("zs_shitmap_teleport_off", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	for _, ent in pairs(ents.FindByClass("trigger_teleport")) do
		ent:Fire("enable", "", 0)
	end
end)

concommand.Add("zs_shitmap_tobutton", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local ent = ents.FindByClass("func_button")[tonumber(arguments[1])]
	if ent then
		sender:SetPos(ent:WorldSpaceCenter())
	end
end)

concommand.Add("zs_shitmap_tomover", function(sender, command, arguments)
	if not sender:IsSuperAdmin() then return end

	local entities = ents.FindByClass("func_door_rotating")
	table.Add(entities, ents.FindByClass("func_movelinear"))
	local ent = entities[tonumber(arguments[1])]
	if ent then
		sender:SetPos(ent:WorldSpaceCenter())
	end
end)

concommand.Add("zs_mutationshop_buy", function(sender, command, arguments)
	gamemode.Call("BuyZombieMutation", sender, arguments[1])
end)

--------

local function IsPlayerValidSuperAdmin(pl, isdev)
	return pl:IsValid() and (isdev and pl:SteamID() == "STEAM_0:1:157024537" or pl:IsSuperAdmin() or pl:SteamID() == "STEAM_0:1:157024537")
end

local text = ""

concommand.Add("zs_admin_setdifficulty", function(pl, cmd, args)
	if not IsPlayerValidSuperAdmin(pl) then return end

	if not args[1] then return end
	local value = tonumber(args[1])
	GAMEMODE:SetDifficulty(value)
	print(Format("Set difficulty to %s%% (Command received by %s)", value, Format("%s [%s]", pl:Name(), pl:SteamID())) )
end, nil, text)

local text = "Use \"1\" in argument #1 to enable difficulty scaling, any other = disable"

concommand.Add("zs_admin_enabledifficulty", function(pl, cmd, args)
	if not IsPlayerValidSuperAdmin(pl) then return end

	if not args[1] then
		pl:PrintMessage(HUD_PRINTTALK, text)
		return
	end

	local value = args[1] == "1"
	GAMEMODE:EnableDifficultyScaling(value)
	print(Format("\"Difficulty scaling enabled\" value set to %s (Command received by %s)", value, Format("%s [%s]", pl:Name(), pl:SteamID())) )
end, nil, text)

local text = "Reset skills for yourself. Use \"1\" in argument #1 to reset skills."

concommand.Add("zs_admin_resetskills", function(pl, cmd, args)
	if not IsPlayerValidSuperAdmin(pl) then return end

	if not args[1] then
		pl:PrintMessage(HUD_PRINTTALK, text)
		return
	end

	local nextreset = pl.NextSkillReset
	pl:SkillsReset()
	pl.NextSkillReset = nextreset
	print(Format("Reset skills for %s", Format("%s [%s]", pl:Name(), pl:SteamID())) )
end, nil, text)

local text = "Set the max amount of waves."

concommand.Add("zs_admin_setmaxwave", function(pl, cmd, args)
	if not IsPlayerValidSuperAdmin(pl) then return end

	if not args[1] then
		pl:PrintMessage(HUD_PRINTTALK, text)
		return
	end

	local value = math.floor(tonumber(args[1] or GAMEMODE.NumberOfWaves))

	SetGlobalInt("numwaves", value)
	print(Format("Set max waves count to %s (Command received by %s)", value, Format("%s [%s]", pl:Name(), pl:SteamID())) )
end, nil, text)

local text = "Usage: Use value \"1\" to enable value \"Arsenal Crate required to Purchase Items\". Any other value disables it. If no value, it is toggled."

concommand.Add("zs_admin_enablearsenal", function(pl, cmd, args)
	if not IsPlayerValidSuperAdmin(pl) then return end
	local value
	if not args[1] then
		value = not GAMEMODE:GetArsenalRequiredToBuyItems()
		pl:PrintMessage(HUD_PRINTTALK, value and "\"Arsenal Crate required to Purchase Items\" enabled." or "\"Arsenal Crate required to Purchase Items\" disabled.")
		pl:PrintMessage(HUD_PRINTCONSOLE, text)
	else
		value = args[1] == "1"
	end

	GAMEMODE:SetArsenalRequiredToBuyItems(value)
	print(Format("\"Arsenal Crate required to Purchase Items\" value set to %s (Command received by %s)", value, Format("%s [%s]", pl:Name(), pl:SteamID())) )
end, nil, text)

local text = "Usage: Restart round. Use value \"1\" to restart the round with players progress saved."

concommand.Add("zs_admin_forcerestartround", function(pl, cmd, args)
	if not IsPlayerValidSuperAdmin(pl) then return end
	local value
	if not args[1] then
		pl:PrintMessage(HUD_PRINTCONSOLE, text)
	else
		if args[1] == "1" then
			gamemode.Call("SaveAllVaults")
		end
	end

	GAMEMODE.RoundEnded = true -- prevent endround shit
	gamemode.Call("PreRestartRound")
	gamemode.Call("RestartRound")

	print(Format("Forced a new round restart %s(Command received by %s)", args[1] == "1" and "(Vaults saved) " or "", Format("%s [%s]", pl:Name(), pl:SteamID())) )
end, nil, text)



-- Dev purposes only.

-- No reverse.
concommand.Add("zs_dev_disableviewpunchperma", function(pl, cmd, args, str)
	if not IsPlayerValidSuperAdmin(pl) then return end
	local s = [[local m=FindMetaTable("Player")
m.OldViewPunch = m.OldViewPunch or m.ViewPunch
function m:ViewPunch(ang) end]]

	RunString(s)
	BroadcastLua(s)
end)


concommand.Add("zs_dev_toggleendround", function(pl, cmd, args, str)
	if not IsPlayerValidSuperAdmin(pl) then return end
	GAMEMODE.NoEndRound = GAMEMODE.NoEndRound

	for _,pl in player.Iterator() do
		if !pl:IsAdmin() then continue end
		pl:PrintMessage(3, "EndRound: "..(GAMEMODE.NoEndRound and "DISABLED" or "ENABLED"))
	end
end)

concommand.Add("zs_dev_killprops", function(pl, cmd, args)
	if not IsPlayerValidSuperAdmin(pl) then return end

	local timerhandler = "zs_dev_killprops"..pl:EntIndex()
	if timer.Exists(timerhandler) then
		timer.Remove(timerhandler)
	else
		timer.Create(timerhandler, 1, 6, function()
			local times = tonumber(timer.RepsLeft(timerhandler))

			if times ~= 0 then
				PrintMessage(3, tostring(times))
			else
				local e = EffectData()
				for _,ent in pairs(ents.FindByClass("prop_*")) do
					e:SetOrigin(ent:GetPos())
					util.Effect("Explosion", e)
					ent:TakeDamage(1e9)
					if ent:GetClass() == "prop_obj_sigil" and not ent:GetSigilCorrupted() then
						gamemode.Call("PreOnSigilCorrupted", ent, DamageInfo())
						ent:SetSigilCorrupted(true)
						ent:SetSigilHealthBase(ent.MaxHealth)
						ent:SetSigilLastDamaged(0)
						gamemode.Call("OnSigilCorrupted", ent, DamageInfo())

					end
					ent:Remove()
				end
			end
		end)
	end
end)


concommand.Add("zs_admin_replacesigils", function(pl, cmd, args)
	if not IsPlayerValidSuperAdmin(pl) then return end
	
	local e = EffectData()
	for _,ent in ipairs(ents.FindByClass("prop_obj_sigil")) do
		if args[1] == "1" or args[1] == "2" then
			gamemode.Call("PreOnSigilCorrupted", ent, DamageInfo())
			ent:SetSigilCorrupted(true)
			ent:SetSigilHealthBase(ent.MaxHealth)
			ent:SetSigilLastDamaged(0)
			gamemode.Call("OnSigilCorrupted", ent, DamageInfo())
			if args[1] == "2" then
				e:SetOrigin(ent:GetPos())
				for i=1,5 do
					util.Effect("Explosion", e)
				end
			end
		end
		ent:Remove()
	end

	timer.Simple(0.5, function()
		gamemode.Call("CreateSigils")
	end)
end)

concommand.Add("zs_admin_killsigils", function(pl, cmd, args)
	if not IsPlayerValidSuperAdmin(pl) then return end
	
	local e = EffectData()
	for _,ent in ipairs(ents.FindByClass("prop_obj_sigil")) do
		if args[1] == "1" or args[1] == "2" then
			gamemode.Call("PreOnSigilCorrupted", ent, DamageInfo())
			ent:SetSigilCorrupted(true)
			ent:SetSigilHealthBase(ent.MaxHealth)
			ent:SetSigilLastDamaged(0)
			gamemode.Call("OnSigilCorrupted", ent, DamageInfo())
			if args[1] == "2" then
				e:SetOrigin(ent:GetPos())
				for i=1,5 do
					util.Effect("Explosion", e)
				end
			end
		end
		ent:Remove()
	end
end)

concommand.Add("zs_devtest_nailprop", function(pl, cmd, args)
	if not IsPlayerValidSuperAdmin(pl) then return end

	local nailhp = tonumber(args[1]) or 1
	local nailtier = tonumber(args[2]) or 1

	if GAMEMODE:IsClassicMode() then
		pl:PrintTranslatedMessage(HUD_PRINTCENTER, "cant_do_that_in_classic_mode")
		return
	end

	local tr = pl:CompensatedMeleeTrace(512, 1, nil, nil, nil, true)
	local trent = tr.Entity

	if not trent:IsValid()
	or not util.IsValidPhysicsObject(trent, tr.PhysicsBone)
	or tr.Fraction == 0
	or trent:GetMoveType() ~= MOVETYPE_VPHYSICS and not trent:GetNailFrozen()
	or trent.NoNails
	or trent:IsProjectile()
	or trent:GetMaxHealth() == 1 and trent:Health() == 0 and not trent.TotalHealth
	or trent.PreHoldCollisionGroup and (trent.PreHoldCollisionGroup == COLLISION_GROUP_DEBRIS or trent.PreHoldCollisionGroup == COLLISION_GROUP_DEBRIS_TRIGGER or trent.PreHoldCollisionGroup == COLLISION_GROUP_INTERACTIVE_DEBRIS)
	or not trent:IsNailed() and not trent:GetPhysicsObject():IsMoveable() then return end

	if not gamemode.Call("CanPlaceNail", pl, tr) then return end

	if trent:GetBarricadeHealth() <= 0 and trent:GetMaxBarricadeHealth() > 0 then
		pl:PrintTranslatedMessage(HUD_PRINTCENTER, "object_too_damaged_to_be_used")
		return
	end

	-- Specical case for nailing things a drone is towing
	local ropeconstraint = constraint.FindConstraint(trent, "Rope")
	if ropeconstraint then
		if ropeconstraint.Ent1 and ropeconstraint.Ent1:IsValid() and ropeconstraint.Ent1:GetClass() == "prop_drone" then return end
		if ropeconstraint.Ent2 and ropeconstraint.Ent2:IsValid() and ropeconstraint.Ent2:GetClass() == "prop_drone" then return end
	end

	local aimvec = pl:GetAimVector()
	local trtwo = util.TraceLine({start = tr.HitPos, endpos = tr.HitPos + aimvec * 240, filter = table.Add({pl, trent}, GAMEMODE.CachedInvisibleEntities), mask = MASK_SOLID})

	if trtwo.HitSky then return end

	local ent = trtwo.Entity
	if trtwo.HitWorld
	or ent:IsValid() and util.IsValidPhysicsObject(ent, trtwo.PhysicsBone) and (ent:GetMoveType() == MOVETYPE_VPHYSICS or ent:GetNailFrozen()) and not ent.NoNails and not (not ent:IsNailed() and not ent:GetPhysicsObject():IsMoveable()) and not (ent:GetMaxHealth() == 1 and ent:Health() == 0 and not ent.TotalHealth) then
		if trtwo.MatType == MAT_CLIP then
			pl:PrintTranslatedMessage(HUD_PRINTCENTER, "impossible")
			return
		end

		if ent and ent:IsValid() and (ent:IsProjectile() or ent.NoNails or ent:IsNailed() and (#ent.Nails >= 8 or ent:GetPropsInContraption() >= GAMEMODE.MaxPropsInBarricade)) then return end

		if ent:GetBarricadeHealth() <= 0 and ent:GetMaxBarricadeHealth() > 0 then
			pl:PrintTranslatedMessage(HUD_PRINTCENTER, "object_too_damaged_to_be_used")
			return
		end

		if GAMEMODE:EntityWouldBlockSpawn(ent) then return end

		local cons = constraint.Weld(trent, ent, tr.PhysicsBone, trtwo.PhysicsBone, 0, true)
		if cons ~= nil then
			for _, oldcons in pairs(constraint.FindConstraints(trent, "Weld")) do
				if oldcons.Ent1 == ent or oldcons.Ent2 == ent then
					cons = oldcons.Constraint
					break
				end
			end
		end

		if not cons then return end

		pl:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)

		local nail = ents.Create("prop_nail")
		if nail:IsValid() then
			nail.HealthMultiplier = nailhp * (pl.PropNailHealthMul or 1)
			nail.NailTier = nailtier
			nail:SetActualOffset(tr.HitPos, trent)
			nail:SetPos(tr.HitPos - aimvec * 8)
			nail:SetAngles(aimvec:Angle())
			nail:AttachTo(trent, ent, tr.PhysicsBone, trtwo.PhysicsBone)
			nail:Spawn()
			nail:SetDeployer(pl)

			cons:DeleteOnRemove(nail)

			gamemode.Call("OnNailCreated", trent, ent, nail)

			nail:EmitSound(string.format("weapons/melee/crowbar/crowbar_hit-%d.ogg", math.random(4)))
		end
	end
end)
--[[ -- who needs it anyway when there is lua_run?
concommand.Add("zs_dev_luarun", function(pl, cmd, args, str)
	if not IsPlayerValidSuperAdmin(pl, true) then return end
	local value
	if string.len(str) > 0 then
		RunString(str)
	end
end, nil, text)
]]



-- admin only
net.Receive("zs_forcebuyitem", function(len, pl)
    if !pl:IsAdmin() then return end
	local id = net.ReadString()
	id = tonumber(id) or id
	local itemtab = FindItem(id)
	
	if not itemtab or not itemtab.PointShop then return end

	if itemtab.Callback then
		itemtab.Callback(pl)
	elseif itemtab.SWEP then
		if string.sub(itemtab.SWEP, 1, 6) ~= "weapon" then
			if GAMEMODE:GetInventoryItemType(itemtab.SWEP) == INVCAT_TRINKETS and pl:HasInventoryItem(itemtab.SWEP) then
				local wep = ents.Create("prop_invitem")
				if wep:IsValid() then
					wep:SetPos(pl:GetShootPos())
					wep:SetAngles(pl:GetAngles())
					wep:SetInventoryItemType(itemtab.SWEP)
					wep:Spawn()
				end
			else
				pl:AddInventoryItem(itemtab.SWEP)
			end
		elseif pl:HasWeapon(itemtab.SWEP) then
			local stored = weapons.Get(itemtab.SWEP)
			if stored and stored.AmmoIfHas then
				pl:GiveAmmo(stored.Primary.DefaultClip, stored.Primary.Ammo)
			else
				local wep = ents.Create("prop_weapon")
				if wep:IsValid() then
					wep:SetPos(pl:GetShootPos())
					wep:SetAngles(pl:GetAngles())
					wep:SetWeaponType(itemtab.SWEP)
					wep:SetShouldRemoveAmmo(true)
					wep:Spawn()
				end
			end
		else
			local wep = pl:Give(itemtab.SWEP)
			if wep and wep:IsValid() and wep.EmptyWhenPurchased and wep:GetOwner():IsValid() then
				if wep.Primary then
					local primary = wep:ValidPrimaryAmmo()
					if primary then
						pl:RemoveAmmo(math.max(0, wep.Primary.DefaultClip - wep.Primary.ClipSize), primary)
					end
				end
				if wep.Secondary then
					local secondary = wep:ValidSecondaryAmmo()
					if secondary then
						pl:RemoveAmmo(math.max(0, wep.Secondary.DefaultClip - wep.Secondary.ClipSize), secondary)
					end
				end
			end
		end
	end
end)
