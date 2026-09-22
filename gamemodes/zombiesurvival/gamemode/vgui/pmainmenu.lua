local function HelpMenuPaint(self)
	Derma_DrawBackgroundBlur(self, self.Created)
	Derma_DrawBackgroundBlur(self, self.Created)
end

local pPlayerModel
local function SwitchPlayerModel(self)
	surface.PlaySound("buttons/button14.wav")
	RunConsoleCommand("cl_playermodel", self.m_ModelName)
	chat.AddText(COLOR_LIMEGREEN, "You've changed your desired player model to "..tostring(self.m_ModelName))

	pPlayerModel:Close()
end
function MakepPlayerModel()
	if pPlayerModel and pPlayerModel:IsValid() then pPlayerModel:Remove() end

	PlayMenuOpenSound()

	local numcols = 8
	local wid = numcols * 68 + 24
	local hei = 400

	pPlayerModel = vgui.Create("DFrame")
	pPlayerModel:SetSkin("Default")
	pPlayerModel:SetTitle("Player model selection")
	pPlayerModel:SetSize(wid, hei)
	pPlayerModel:Center()
	pPlayerModel:SetDeleteOnClose(true)

	local list = vgui.Create("DPanelList", pPlayerModel)
	list:StretchToParent(8, 24, 8, 8)
	list:EnableVerticalScrollbar()

	local grid = vgui.Create("DGrid", pPlayerModel)
	grid:SetCols(numcols)
	grid:SetColWide(68)
	grid:SetRowHeight(68)

	for name, mdl in pairs(player_manager.AllValidModels()) do
		local button = vgui.Create("SpawnIcon", grid)
		button:SetPos(0, 0)
		button:SetModel(mdl)
		button.m_ModelName = name
		button.OnMousePressed = SwitchPlayerModel
		grid:AddItem(button)
	end
	grid:SetSize(wid - 16, math.ceil(table.Count(player_manager.AllValidModels()) / numcols) * grid:GetRowHeight())

	list:AddItem(grid)

	pPlayerModel:SetSkin("Default")
	pPlayerModel:MakePopup()
end

function MakepPlayerColor()
	if pPlayerColor and pPlayerColor:IsValid() then pPlayerColor:Remove() end

	PlayMenuOpenSound()

	pPlayerColor = vgui.Create("DFrame")
	pPlayerColor:SetWide(math.min(ScrW(), 500))
	pPlayerColor:SetTitle(" ")
	pPlayerColor:SetDeleteOnClose(true)

	local y = 8

	local label = EasyLabel(pPlayerColor, "Colors", "ZSHUDFont", color_white)
	label:SetPos((pPlayerColor:GetWide() - label:GetWide()) / 2, y)
	y = y + label:GetTall() + 8

	local lab = EasyLabel(pPlayerColor, "Player color")
	lab:SetPos(8, y)
	y = y + lab:GetTall()

	local colpicker = vgui.Create("DColorMixer", pPlayerColor)
	colpicker:SetAlphaBar(false)
	colpicker:SetPalette(false)
	colpicker.UpdateConVars = function(me, color)
		me.NextConVarCheck = SysTime() + 0.2
		RunConsoleCommand("cl_playercolor", color.r / 100 .." ".. color.g / 100 .." ".. color.b / 100)
	end
	local r, g, b = string.match(GetConVar("cl_playercolor"):GetString(), "(%g+) (%g+) (%g+)")
	if r then
		colpicker:SetColor(Color(r * 100, g * 100, b * 100))
	end
	colpicker:SetSize(pPlayerColor:GetWide() - 16, 72)
	colpicker:SetPos(8, y)
	y = y + colpicker:GetTall()

	lab = EasyLabel(pPlayerColor, "Weapon color")
	lab:SetPos(8, y)
	y = y + lab:GetTall()

	colpicker = vgui.Create("DColorMixer", pPlayerColor)
	colpicker:SetAlphaBar(false)
	colpicker:SetPalette(false)
	colpicker.UpdateConVars = function(me, color)
		me.NextConVarCheck = SysTime() + 0.2
		RunConsoleCommand("cl_weaponcolor", color.r / 100 .." ".. color.g / 100 .." ".. color.b / 100)
	end
	r, g, b = string.match(GetConVar("cl_weaponcolor"):GetString(), "(%g+) (%g+) (%g+)")
	if r then
		colpicker:SetColor(Color(r * 100, g * 100, b * 100))
	end
	colpicker:SetSize(pPlayerColor:GetWide() - 16, 72)
	colpicker:SetPos(8, y)
	y = y + colpicker:GetTall()

	pPlayerColor:SetTall(y + 8)
	pPlayerColor:Center()
	pPlayerColor:MakePopup()
end

function MakepChangelog()
	PlayMenuOpenSound()

	local wid = math.min(ScrW(), 750)

	local y = 40

	local frame = vgui.Create("DEXRoundedFrame")
	frame:SetColorAlpha(230)
	frame:SetWide(wid)
	frame:SetTitle(" ")
	frame:SetKeyboardInputEnabled(false)

	local scroll = vgui.Create("DScrollPanel", frame)
	scroll:Dock(FILL)

	local label = EasyLabel(frame, GAMEMODE.Name.." changelogs", "ZSHUDFontNS", color_white)
	label:CenterHorizontal()
	label:Dock(TOP)
	y = y + label:GetTall() + 8

	local desc = string.Explode("\n", GAMEMODE.ReleaseNotes)
	local txt, colid
	for i=1, #desc do
		local changelogtxt = vgui.Create("DLabel", scroll)
		changelogtxt:SetFont("ZSHUDFontSmallest")
		changelogtxt:SetTextColor(COLOR_GRAY)
		changelogtxt:SetContentAlignment(4)
		changelogtxt:SetWrap(true)
		changelogtxt:SetAutoStretchVertical(true)
		changelogtxt:Dock(TOP)

		txt = desc[i] or " "
		if txt:sub(1, 1) == "^" then
			colid = tonumber(txt:sub(2, 2)) or 0
			txt = txt:sub(3)
			changelogtxt:SetTextColor(util.ColorIDToColor(colid, COLOR_GRAY))
		else
			changelogtxt:SetTextColor(COLOR_GRAY)
		end

		local hashtag = txt:sub(1, 1) == "#"
		if hashtag or i == 1 then
			changelogtxt:SetFont("ZSHUDFontSmall")
			changelogtxt:SetContentAlignment(5)
			changelogtxt:SetWrap(false)

			if hashtag then
				txt = txt:sub(2)
			end

			if i == 1 then
				txt = txt.." ("..GAMEMODE.Version..")"
			end

			txt = txt.."\n"
		end
		changelogtxt:SetText(txt)
		y = y + changelogtxt:GetTall() + 8
	end

	frame:SetTall(math.min(ScrH()*0.8, y + 8))
	frame:Center()
	frame:SetAlpha(0)
	frame:AlphaTo(255, 0.15, 0)
	frame:MakePopup()
end

function GM:ShowHelp()
	if self.HelpMenu and self.HelpMenu:IsValid() then
		self.HelpMenu:Remove()
	end

	PlayMenuOpenSound()

	local screenscale = BetterScreenScale()
	local menu = vgui.Create("Panel")
	menu:SetSize(screenscale * 450, ScrH())
	menu:Center()
	menu.Paint = HelpMenuPaint
	menu.Created = SysTime()

	local header = EasyLabel(menu, self.Name, "ZSHUDFontSmall")
	header:SetContentAlignment(8)
	header:DockMargin(0, ScrH() * 0.2, 0, 64)
	header:Dock(TOP)
	header.Think = function()
		header:SetTextColor(HSVToColor(RealTime() * -60 % 360, 1, 1))
	end
	-- local mat = Material("gui/center_gradient")
	-- header.PaintOver = function(self, w, h)
	-- 	-- vibecoded (FUCK IT)
	-- 	render.OverrideBlend(true, BLEND_SRC_ALPHA, BLEND_DST_ALPHA, BLENDFUNC_ADD)
	-- 	render.OverrideColorWriteEnable(true, true)
	-- 	surface.SetMaterial(mat)
	-- 	surface.SetDrawColor(255, 0, 0, 255)
	-- 	surface.DrawTexturedRect(0, 0, w, h)
	-- 	render.OverrideColorWriteEnable(false, false)
	-- 	render.OverrideBlend(false)
	-- end

	local buttonhei = 32 * screenscale

	local but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText("Help")
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepHelp() end

	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText("Player Model")
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepPlayerModel() end

	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText("Player Color")
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepPlayerColor() end

	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText("Options")
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepOptions() end

	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText("Weapon Database")
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepWeapons() end

	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText("Skills")
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() GAMEMODE:ToggleSkillWeb() end

	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText("Worth Menu")
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepWorth() menu:Remove() end

	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText("Achievements")
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() self:DoAchievementsPanel() menu:Remove() end

	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText("Character Stats")
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepStats() menu:Remove() end

	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText("Credits")
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepCredits() end

	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText("Changelog")
	but:SetTall(buttonhei)
	but:DockMargin(0, 0, 0, 12)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() MakepChangelog() end

	but = vgui.Create("DButton", menu)
	but:SetFont("ZSHUDFontSmaller")
	but:SetText("Close")
	but:SetTall(buttonhei)
	but:DockMargin(0, 24, 0, 0)
	but:DockPadding(0, 12, 0, 12)
	but:Dock(TOP)
	but.DoClick = function() menu:Remove() end

	if MySelf:IsSuperAdmin() then
		but = vgui.Create("DButton", menu)
		but:SetFont("ZSHUDFontSmaller")
		but:SetText("(dev) Open class menu")
		but:SetTall(buttonhei)
		but:DockMargin(0, 34, 0, 0)
		but:DockPadding(0, 12, 0, 12)
		but:Dock(TOP)
		but.DoClick = function() GAMEMODE:OpenClassSelect() menu:Remove() end

		but = vgui.Create("DButton", menu)
		but:SetFont("ZSHUDFontSmaller")
		but:SetText("(dev) Open arsenal menu")
		but:SetTall(buttonhei)
		but:DockMargin(0, 24, 0, 0)
		but:DockPadding(0, 12, 0, 12)
		but:Dock(TOP)
		but.DoClick = function() GAMEMODE:OpenArsenalMenu() menu:Remove() end

		but = vgui.Create("DButton", menu)
		but:SetFont("ZSHUDFontSmaller")
		but:SetText("(dev) Close all panels")
		but:SetTall(buttonhei)
		but:DockMargin(0, 24, 0, 0)
		but:DockPadding(0, 12, 0, 12)
		but:Dock(TOP)
		but.DoClick = function()
			if IsValid(GAMEMODE.ArsenalInterface) then
				GAMEMODE.ArsenalInterface:Remove()
			end

			menu:Remove()
		end

		but = vgui.Create("DButton", menu)
		but:SetFont("ZSHUDFontSmaller")
		but:SetText(MySelf:Team() ~= TEAM_SPECTATOR and "(dev) Spectate" or "(dev) Stop Spectating")
		but:SetTall(buttonhei)
		but:DockMargin(0, 0, 0, 12)
		but:DockPadding(0, 12, 0, 12)
		but:Dock(TOP)
		but.DoClick = function()
			if MySelf:Team() ~= TEAM_SPECTATOR then
				Derma_Query("Enter spectator mode?", "Spectator Mode", "Yes", function()
					net.Start("zs_startspectate")
					net.WriteBool(true)
					net.SendToServer()
					menu:Remove()
				end, "No")

			else
				Derma_Query("Stop spectating?", "Spectator Mode", "Yes", function()
					net.Start("zs_startspectate")
					net.WriteBool(false)
					net.SendToServer()
					menu:Remove()
				end, "No")
			end
		end
	end

	menu:MakePopup()
end
