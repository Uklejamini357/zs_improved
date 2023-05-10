local draw_SimpleText = draw.SimpleText

local render_SetBlend = render.SetBlend
local render_DrawBeam = render.DrawBeam
local render_ModelMaterialOverride = render.ModelMaterialOverride
local render_SetColorModulation = render.SetColorModulation
local render_SuppressEngineLighting = render.SuppressEngineLighting

net.Receive("zs_skills_notify", function(length)
	if GAMEMODE.SkillWeb then
		GAMEMODE.SkillWeb:DisplayMessage(net.ReadString(), net.ReadColor() or COLOR_WHITE)
	end
end)

net.Receive("zs_skill_is_desired", function(length)
	local skillid = net.ReadUInt(16)
	local yesno = net.ReadBool()

	if MySelf:IsValid() then
		MySelf:SetSkillDesired(skillid, yesno)

		if GAMEMODE.SkillWeb and GAMEMODE.SkillWeb:IsValid() then
			if not GAMEMODE.SkillPanelNoUnlockSound then
				surface.PlaySound("zombiesurvival/ui/misc" .. (yesno and 2 or 1) .. ".ogg")
			end

			GAMEMODE.SkillWeb:UpdateQuickStats()
		end
	end
end)

net.Receive("zs_skill_is_unlocked", function(length)
	local skillid = net.ReadUInt(16)
	local yesno = net.ReadBool()

	if MySelf:IsValid() then
		MySelf:SetSkillUnlocked(skillid, yesno)
	end
end)

net.Receive("zs_skills_active", function(length)
	local t = {}

	for skillid in pairs(GAMEMODE.Skills) do
		if net.ReadBool() then
			t[skillid] = true
		end
	end

	if MySelf:IsValid() then
		MySelf:ApplySkills(t)
	end
end)

net.Receive("zs_skills_init", function(length)
	GAMEMODE.ReceivedInitialSkills = true

	local unlocked = {}
	local desired = {}
	local active = {}

	for skillid in pairs(GAMEMODE.Skills) do
		if net.ReadBool() then
			unlocked[skillid] = true
		end
	end

	for skillid in pairs(GAMEMODE.Skills) do
		if net.ReadBool() then
			desired[skillid] = true
		end
	end
	if net.ReadBool() then
		for skillid in pairs(GAMEMODE.Skills) do
			if net.ReadBool() then
				active[skillid] = true
			end
		end
	end

	if MySelf:IsValid() then
		MySelf:SetUnlockedSkills(unlocked)
		MySelf:SetDesiredActiveSkills(desired)
		MySelf:ApplySkills(active)
	end
end)

net.Receive("zs_skills_desired", function(length)
	local t = {}

	for skillid in pairs(GAMEMODE.Skills) do
		if net.ReadBool() then
			t[#t + 1] = skillid
		end
	end

	if MySelf:IsValid() then
		MySelf:SetDesiredActiveSkills(t)
	end

	if GAMEMODE.SkillWeb and GAMEMODE.SkillWeb:IsValid() then
		GAMEMODE.SkillWeb:UpdateQuickStats()
	end
end)

net.Receive("zs_skills_unlocked", function(length)
	local t = {}

	for skillid in pairs(GAMEMODE.Skills) do
		if net.ReadBool() then
			t[#t + 1] = skillid
		end
	end

	if MySelf:IsValid() then
		MySelf:SetUnlockedSkills(t)
	end
end)

net.Receive("zs_skills_nextreset", function(length)
	GAMEMODE.NextSkillReset = net.ReadUInt(32)

	if GAMEMODE.SkillWeb and GAMEMODE.SkillWeb:IsValid() then
		local hours = math.floor(GAMEMODE.NextSkillReset / 3600)
		local btn = GAMEMODE.SkillWeb.Reset

		btn:SetText(GAMEMODE.NextSkillReset <= 0 and "Reset" or (hours .. " hours left"))
		btn:SetDisabled(GAMEMODE.NextSkillReset > 0)
	end
end)

GM.SavedSkillLoadouts = {}
hook.Add("Initialize", "LoadSkillLoadouts", function()
	if file.Exists(GAMEMODE.SkillLoadoutsFile, "DATA") then
		GAMEMODE.SavedSkillLoadouts = Deserialize(file.Read(GAMEMODE.SkillLoadoutsFile)) or {}
	end
end)

local function UpdateDropDown(dropdown)
	dropdown:Clear()

	for i, cart in ipairs(GAMEMODE.SavedSkillLoadouts) do
		dropdown:AddChoice(cart[1])
	end
end

local function SaveSkillLoadout(name)
	for i, cart in ipairs(GAMEMODE.SavedSkillLoadouts) do
		if string.lower(cart[1]) == string.lower(name) then
			cart[1] = name
			cart[2] = MySelf:GetDesiredActiveSkills()

			file.Write(GAMEMODE.SkillLoadoutsFile, Serialize(GAMEMODE.SavedSkillLoadouts))
			return
		end
	end

	GAMEMODE.SavedSkillLoadouts[#GAMEMODE.SavedSkillLoadouts + 1] = {name, MySelf:GetDesiredActiveSkills()}
	file.Write(GAMEMODE.SkillLoadoutsFile, Serialize(GAMEMODE.SavedSkillLoadouts))
end

-- For getting the positions of skill webs. See skillwebgrid.png
-- The file is not used in the gamemode so feel free to edit it.
function GM:GenerateFromSkillWebGrid()
	local mat = Material("zombiesurvival/skillwebgrid.png")
	local w, h = mat:Width(), mat:Height()
	local prelines = {}
	local lines = {}
	local col

	for y = 1, h do
		for x = 1, w do
			col = mat:GetColor(x - 1, y - 1)
			if col.r ~= 255 or col.g ~= 255 or col.b ~= 255 then
				local id = col.r + col.g * 255 + col.b * 65052
				local lx, ly = math.ceil(x - w / 2), math.floor(y - h / 2)

				if lines[id] then
					print(string.format("-- WARNING: Skill ID %d already exists (pixel %d, %d)", id, x, y))
				end

				prelines[id] = string.format("SKILL_%d = %d",
					id,
					id
				)
				lines[id] =	string.format(
					"GM:AddSkill(SKILL_%d, \"\", \"\",\n%s%d,%s%d,%s{})",
					id,
					string.rep("\t", 16),
					lx,
					string.rep("\t", 3),
					ly,
					string.rep("\t", 3)
				)
			end
		end
	end

	print(table.concat(prelines, "\n"))
	print("")
	print(table.concat(lines, "\n"))
end

local hoveredskill

local REMORT_SKILL = {
	Name = "Remort",
	Description = Format("Go even further beyond.\
Lose all skills, experience, skill points, and levels.\
Start at level 1 once again, but with an extra SP.\
Can remort multiple times for multiple extra skill points.\
To remort, you need level %d.\
(1 remort = 1 extra skill point)", GM.MaxRemortableLevel)}
/*
local TREE_SKILLS = {
	[TREE_HEALTHTREE] = {
		Name = "Survival",
		Description = "Improve your vitality.",
	},

	[TREE_SPEEDTREE] = {
		Name = "Speed",
		Description = "",
	},

	[TREE_GUNTREE] = {
		Name = "Gunnery",
		Description = "",
	},

	[TREE_MELEETREE] = {
		Name = "Melee",
		Description = "Hit harder with melee.",
	},

	[TREE_BUILDINGTREE] = {
		Name = "Defense",
		Description = "",
	},

	[TREE_SUPPORTTREE] = {
		Name = "Support",
		Description = "Heal more effectively.",
	},

	[TREE_TORMENTTREE] = {
		Name = "Torment",
		Description = "Gain more experience for debuffs.",
	},

	[TREE_REMORTTREE] = {
		Name = "Special",
		Description = "",
	},
}
*/
local PANEL = {}

AccessorFunc( PANEL, "vCamPos",			"CamPos" )
AccessorFunc( PANEL, "fFOV",			"FOV" )
AccessorFunc( PANEL, "vLookatPos",		"LookAt" )
AccessorFunc( PANEL, "aLookAngle",		"LookAng" )
AccessorFunc( PANEL, "colAmbientLight",	"AmbientLight" )

PANEL.CreationTime = 0
PANEL.DesiredZoom = 5000
PANEL.ZoomChange = 0
PANEL.DesiredTree = 0
PANEL.ShadeAlpha = 0
PANEL.ShadeVelocity = 0

-- Old
local offsets = {
	[TREE_HEALTHTREE] = {0, 20},
	[TREE_SPEEDTREE] = {0, -16},
	[TREE_GUNTREE] = {15, -9},
	[TREE_MELEETREE] = {15, 10},
	[TREE_BUILDINGTREE] = {-16, 10},
	[TREE_SUPPORTTREE] = {-15, -9},
	[TREE_TORMENTTREE] = {31,1},
	[TREE_REMORTTREE] = {2,0.5}
}

/*
local node_models = {
	[TREE_HEALTHTREE] = "models/Items/ammocrate_ar2.mdl",
	[TREE_SPEEDTREE] = "models/props_junk/Shoe001a.mdl",
	[TREE_GUNTREE] = "models/weapons/w_smg1.mdl",
	[TREE_MELEETREE] = "models/props/cs_militia/axe.mdl",
	[TREE_BUILDINGTREE] = "models/weapons/w_hammer.mdl",
	[TREE_SUPPORTTREE] = "models/weapons/w_medkit.mdl",
	[TREE_TORMENTTREE] = "models/weapons/w_medkit.mdl",
	[TREE_REMORTTREE] = "models/weapons/w_medkit.mdl",

}
*/
local function ActivateSkill(self, skillid)
	local name = GAMEMODE.Skills[skillid].Name
	net.Start("zs_skill_is_desired")
	net.WriteUInt(skillid, 16)
	net.WriteBool(true)
	net.SendToServer()

	self:DisplayMessage(name.." activated.", COLOR_DARKGREEN)
end

local function DeactivateSkill(self, skillid)
	local name = GAMEMODE.Skills[skillid].Name
	net.Start("zs_skill_is_desired")
	net.WriteUInt(skillid, 16)
	net.WriteBool(false)
	net.SendToServer()

	self:DisplayMessage(name.." deactivated.")
end

local function UnlockSkill(self, skillid)
	local name = GAMEMODE.Skills[skillid].Name
	net.Start("zs_skill_is_unlocked")
	net.WriteUInt(skillid, 16)
	net.WriteBool(true)
	net.SendToServer()

	self:DisplayMessage(name.." unlocked and activated!", COLOR_GREEN)
end

function PANEL:Init()
	local allskills = GAMEMODE.Skills
	local node

	self.LastPaint = RealTime()
	self.DirectionalLight = {}
	self.FarZ = 32000

	self:SetCamPos( Vector( 12000, 0, 0 ) )
	self:SetLookAt( Vector( 0, 0, 0 ) )
	self:SetFOV(6)

	self:SetAmbientLight( Color( 50, 50, 50 ) )

	self:SetDirectionalLight( BOX_TOP, color_white )
	self:SetDirectionalLight( BOX_FRONT, color_white )

	self.SkillNodes = {}

/* -- New
	for i=0,8 do
		self.SkillNodes[i] = {}
	end
*/
	for id, skill in pairs(allskills) do
		if not skill.Trinket then
			node = ClientsideModel("models/dav0r/hoverball.mdl", RENDER_GROUP_OPAQUE_ENTITY)
			if IsValid(node) then
				node:SetNoDraw(true)
				-- Old
				node:SetPos(Vector(0, (skill.x + offsets[skill.Tree][1]) * 20, (skill.y + offsets[skill.Tree][2]) * 20))
				-- New
--				node:SetPos(Vector(0, skill.x * 20, skill.y * 20))
				if skill.Disabled then
					node:SetModelScale(0.46, 0)
				else
					-- Old
					node:SetModelScale(0.66, 0)
					-- New
--					node:SetModelScale(0.57 * (skill.ModelScale or 1), 0)
				end

				node.Skill = skill
				node.SkillID = id
				-- Old
				self.SkillNodes[id] = node
				-- New
--				self.SkillNodes[skill.Tree][id] = node
			end
		end
	end

	-- Create the special remort node
	node = ClientsideModel("models/Gibs/HGIBS.mdl", RENDER_GROUP_OPAQUE_ENTITY)
	if IsValid(node) then
		node:SetNoDraw(true)
		node:SetPos(Vector(0, 0, 10))
		-- Old
		node:SetModelScale(1.5, 0)
		-- New
--		node:SetModelScale(2.5, 0)

		node.Skill = REMORT_SKILL
		node.SkillID = -1
		-- Old
		self.SkillNodes[-1] = node
		-- New
--		self.SkillNodes[0][-1] = node
	end

/* -- New
	for tree, treenode in pairs(TREE_SKILLS) do
		node = ClientsideModel("models/Gibs/HGIBS.mdl", RENDER_GROUP_OPAQUE_ENTITY)
		
		if IsValid(node) then
			local rads = ((30 / #TREE_SKILLS) * math.pi) * ((tree - 1) / 15)
			
			node:SetNoDraw(true)
			node:SetPos(Vector(0, math.sin(rads) * 70, math.cos(rads) * 70 + 10))
			node:SetAngles(Angle(0, 0, -rads * 180/math.pi))
			node:SetModelScale(5, 0)
			node.Skill = treenode
			node.SkillID = -tree - 1
			self.SkillNodes[0][node.SkillID] = node
		end
	end
*/

	local top = vgui.Create("Panel", self)
	top:SetSize(ScrW(), 256)
	top:SetMouseInputEnabled(false)

	local skillname = vgui.Create("DLabel", top)
	skillname:SetFont("ZSHUDFont")
	skillname:SetTextColor(COLOR_WHITE)
	skillname:SetContentAlignment(8)
	skillname:Dock(TOP)

	local desc = {}
	for i=1, 7 do
		local skilldesc = vgui.Create("DLabel", top)
		skilldesc:SetFont("ZSHUDFontSmaller") --"ZSHUDFontSmall"
		skilldesc:SetTextColor(COLOR_GRAY)
		skilldesc:SetContentAlignment(8)
		skilldesc:Dock(TOP)
		table.insert(desc, skilldesc)
	end

	local screenscale = BetterScreenScale()

	local bottomleft = vgui.Create("DEXRoundedPanel", self)
	bottomleft:DockPadding(10, 10, 10, 10)
	bottomleft:SetSize(190 * screenscale, 130 * screenscale)

	local bottomleftup = vgui.Create("DEXRoundedPanel", self)
	bottomleftup:DockPadding(10, 10, 10, 10)
	bottomleftup:SetSize(190 * screenscale, 120 * screenscale)

	local quickstats = {}
	for i=1,4 do
		local hpstat = vgui.Create("DLabel", bottomleftup)
		hpstat:SetFont("ZSHUDFontTiny") --"ZSHUDFontSmaller"
		hpstat:SetTextColor(COLOR_WHITE)
		hpstat:SetContentAlignment(8)
		hpstat:Dock(TOP)
		hpstat:SizeToContents()
		hpstat:SetText("---")
		table.insert(quickstats, hpstat)
	end

	local dropdown = vgui.Create("DComboBox", bottomleft)
	dropdown:Dock(TOP)
	dropdown:SetMouseInputEnabled(true)
	dropdown:SetTextColor(color_black)

	local delbtn = vgui.Create("DButton", bottomleft)
	delbtn:SetFont("ZSHUDFontSmallest")
	delbtn:SetText("Delete")
	delbtn:SizeToContents()
	delbtn:SetTall(bottomleft:GetTall() / 5)
	delbtn:Dock(BOTTOM)
	delbtn.DoClick = function(me)
		surface.PlaySound("zombiesurvival/ui/misc1.ogg")

		local delloadout
		for k, v in pairs(GAMEMODE.SavedSkillLoadouts) do
			if v[1] == dropdown:GetSelected() then
				delloadout = k
				break
			end
		end

		if not delloadout then return end

		table.remove(GAMEMODE.SavedSkillLoadouts, delloadout)
		file.Write(GAMEMODE.SkillLoadoutsFile, Serialize(GAMEMODE.SavedSkillLoadouts))
		surface.PlaySound("buttons/button19.wav")

		UpdateDropDown(dropdown)
	end

	local savebtn = vgui.Create("DButton", bottomleft)
	savebtn:SetFont("ZSHUDFontSmallest")
	savebtn:SetText("Save")
	savebtn:SizeToContents()
	savebtn:SetTall(bottomleft:GetTall() / 5)
	savebtn:Dock(BOTTOM)
	savebtn.DoClick = function(me)
		surface.PlaySound("zombiesurvival/ui/misc1.ogg")

		local frame = Derma_StringRequest("Save skill loadout", "Enter a name for this skill loadout.", "Name", function(strTextOut)
			SaveSkillLoadout(strTextOut)
			UpdateDropDown(dropdown)

			self:DisplayMessage("Skill loadout '" .. strTextOut .."' saved!", COLOR_GREEN)
		end,
		function(strTextOut) end,
		"OK", "Cancel")

		frame:GetChildren()[5]:GetChildren()[2]:SetTextColor(Color(30, 30, 30))
	end

	UpdateDropDown(dropdown)

	local loadbtn = vgui.Create("DButton", bottomleft)
	loadbtn:SetFont("ZSHUDFontSmallest")
	loadbtn:SetText("Load")
	loadbtn:SizeToContents()
	loadbtn:SetTall(bottomleft:GetTall() / 5)
	loadbtn:Dock(BOTTOM)
	loadbtn.DoClick = function(me)
		surface.PlaySound("zombiesurvival/ui/misc1.ogg")

		local newloadout, nlname
		for _, v in pairs(GAMEMODE.SavedSkillLoadouts) do
			if v[1] == dropdown:GetSelected() then
				newloadout = v[2]
				nlname = v[1]
				break
			end
		end

		if not newloadout then return end

		net.Start("zs_skill_set_desired")
			net.WriteTable(newloadout)
		net.SendToServer()

		self:DisplayMessage("Skill loadout '" .. nlname .."' loaded!", COLOR_GREEN)
	end

	local bottomlefttop = vgui.Create("DEXRoundedPanel", self)
	bottomlefttop:DockPadding(10, 10, 10, 10)
	bottomlefttop:SetSize(160 * screenscale, 130 * screenscale)

	local activateall = vgui.Create("DButton", bottomlefttop)
	activateall:SetFont("ZSHUDFontSmallest")
	activateall:SetText("Activate All")
	activateall:SizeToContents()
	activateall:SetTall(activateall:GetTall())
	activateall:Dock(TOP)
	activateall.DoClick = function(me)
		surface.PlaySound("zombiesurvival/ui/misc1.ogg")

		if #MySelf:GetUnlockedSkills() == 0 then
			self:DisplayMessage("You have no skills to activate!", COLOR_RED)
		else
			self:DisplayMessage("All unlocked skills activated.", COLOR_GREEN)
		end

		net.Start("zs_skills_all_desired")
			net.WriteBool(true)
		net.SendToServer()
	end

	local deactivateall = vgui.Create("DButton", bottomlefttop)
	deactivateall:SetFont("ZSHUDFontSmallest")
	deactivateall:SetText("Deactivate All")
	deactivateall:SizeToContents()
	deactivateall:SetTall(deactivateall:GetTall())
	deactivateall:DockMargin(0, 5, 0, 0)
	deactivateall:Dock(TOP)
	deactivateall.DoClick = function(me)
		surface.PlaySound("zombiesurvival/ui/misc1.ogg")

		if #MySelf:GetUnlockedSkills() == 0 then
			self:DisplayMessage("You have no skills to deactivate!", COLOR_RED)
		else
			self:DisplayMessage("All unlocked skills deactivated.", COLOR_RORANGE)
		end

		net.Start("zs_skills_all_desired")
			net.WriteBool(false)
		net.SendToServer()
	end

	local resettime = GAMEMODE.NextSkillReset or 0
	local hours = math.floor(resettime / 3600)

	local reset = vgui.Create("DButton", bottomlefttop)
	reset:SetFont("ZSHUDFontSmaller")
	reset:SetText(resettime <= 0 and "Reset" or (hours .. " hours left"))
	reset:SetDisabled(resettime > 0)
	reset:SizeToContents()
	reset:SetTall(reset:GetTall())
	reset:DockMargin(0, 5, 0, 0)
	reset:Dock(TOP)
	reset.DoClick = function(me)
		Derma_Query(
			"Reset all skills and refund SP?\nYou can only do this once per 8 hours.",
			"Warning",
			"OK",
			function() net.Start("zs_skills_reset") net.SendToServer() end,
			"Cancel",
			function() end
		)
	end

	local topright = vgui.Create("DEXRoundedPanel", self)
	topright:SetSize(160 * screenscale, 64 * screenscale)
	topright:DockPadding(10, 10, 10, 10)

	-- Old
	local quit = vgui.Create("DButton", topright)
	quit:SetText("Quit")
	quit:SetFont("ZSHUDFont")
	quit:Dock(FILL)
	quit.DoClick = function()
		self:Remove()
	end

/*	-- New
	local quit = vgui.Create("DButton", topright)
	quit:SetText("Close")
	quit:SetFont("ZSHUDFont")
	quit:Dock(FILL)
	quit.DoClick = function()
		if self.DesiredTree == 0 then
			self:Remove()
		else
			self.DesiredTree = 0
			self.DesiredZoom = 2500
			self.ShadeVelocity = 255 * FrameTime() * 10
			
			timer.Simple(0.1, function()
				if not IsValid(self) then return end

				quit:SetText("Close")
				self.DesiredZoom = 5000
				self.DesiredTree = 0
				self.ShadeVelocity = 255 * FrameTime() * -10
				
				local campos = self:GetCamPos()
				campos.y = 0
				campos.z = 0
				self:SetCamPos(campos)
			end)

			self.ContextMenu:SetVisible(false)
			MySelf:EmitSound("buttons/button24.wav", 60, 180)
		end
	end
*/

	local bottom = vgui.Create("DEXRoundedPanel", self)
	bottom:SetSize(600 * screenscale, math.Clamp(84 * screenscale, 70, 125))
	bottom:DockPadding(10, 10, 10, 10)

	local spremaining = vgui.Create("DEXChangingLabel", bottom)
	spremaining:SetChangeFunction(function()
		return "Unused skill points: "..MySelf:GetZSSPRemaining()
	end, true)
	spremaining:SetChangedFunction(function()
		if MySelf:GetZSSPRemaining() >= 1 then
			spremaining:SetTextColor(COLOR_GRAY)
		else
			spremaining:SetTextColor(COLOR_RED)
		end
	end)
	spremaining:SetFont("ZSHUDFontSmall")
	spremaining:SetContentAlignment(5)
	spremaining:Dock(TOP)

	local expbar = vgui.Create("Panel", bottom)
	expbar.Paint = function(me, w, h)
		GAMEMODE:DrawXPBar(0, 2 - screenscale * 2, w, h, w, 1, 0.95, MySelf:GetZSLevel())
	end
	expbar:SetContentAlignment(5)
	expbar:Dock(BOTTOM)

	local contextmenu = vgui.Create("Panel", self)
	contextmenu:SetSize(128 * screenscale, 128 * screenscale)
	contextmenu:SetVisible(false)

	local button = vgui.Create("DButton", contextmenu)
	button:SetText("Activate")
	button:SetFont("ZSHUDFontSmall")
	button:SetDisabled(false)
	button:SetSize(128 * screenscale, 40 * screenscale)
	button:AlignTop()
	button:CenterHorizontal()
	button.DoClick = function(me)
		local skillid = contextmenu.SkillID
		local name = allskills[skillid].Name
		if MySelf:IsSkillDesired(skillid) then
			DeactivateSkill(self, skillid)
		elseif MySelf:IsSkillUnlocked(skillid) then
			ActivateSkill(self, skillid)
		else
			UnlockSkill(self, skillid)
		end

		contextmenu:SetVisible(false)
	end
	contextmenu.Button = button

	local messagebox = vgui.Create("Panel", self)
	messagebox:SetSize(850 * screenscale, 48)
	messagebox.Paint = function(me, w, h)
		surface.SetDrawColor(5, 5, 5, 240)
		PaintGenericFrame(me, 0, 0, w, h, 16)
	end
	messagebox:SetKeyboardInputEnabled(false)
	messagebox:SetMouseInputEnabled(false)
	messagebox:SetZPos(-100)

	local messagetext = vgui.Create("DLabel", messagebox)
	messagetext:SetTextColor(COLOR_GRAY)
	messagetext:SetText("")
	messagetext:SetFont("ZSHUDFontSmall")
	messagetext:SetContentAlignment(5)
	messagetext:Dock(FILL)
	messagetext:SetKeyboardInputEnabled(false)
	messagetext:SetMouseInputEnabled(false)
	messagetext:SetZPos(-200)
	messagebox:SetVisible(false)

	local warningtext = vgui.Create("DLabel", self)
	warningtext:SetTextColor(COLOR_RED)
	warningtext:SetFont("ZSHUDFontSmall")
	warningtext:SetText("Changes applied on respawn!")
	warningtext:SizeToContents()
	warningtext:SetKeyboardInputEnabled(false)
	warningtext:SetMouseInputEnabled(false)

	local panel_
	local bankxptext
	local bankxpbutton
	
	if MySelf:GetZSBankXP() > 0 then
		bankxptext = vgui.Create("DLabel", self)
		bankxptext:SetTextColor(COLOR_GRAY)
		bankxptext:SetFont("ZSHUDFontSmall")
		bankxptext:SetText(Format("XP in bank: %d", MySelf:GetZSBankXP()))
		bankxptext:SizeToContents()
		bankxptext:SetKeyboardInputEnabled(false)
		bankxptext:SetMouseInputEnabled(false)
		bankxptext.Think = function()
			bankxptext:SetText(Format("XP in bank: %d", MySelf:GetZSBankXP()))
		end

		bankxpbutton = vgui.Create("DButton", self)
		bankxpbutton:SetText("Withdraw XP")
		bankxpbutton:SetFont("ZSHUDFontSmaller")
		bankxpbutton:SetDisabled(false)
		bankxpbutton:SizeToContents()
		bankxpbutton:SetTall(40)
		bankxpbutton:AlignTop()
		bankxpbutton:CenterHorizontal()
		bankxpbutton.DoClick = function(me)
			if MySelf:GetZSXP() >= GAMEMODE.MaxXP then
				self:DisplayMessage("You are at max level! Remort, if you want to withdraw more XP!", COLOR_RED)
				surface.PlaySound("buttons/button8.wav")
				return
			end

			if panel_ and panel_:IsValid() then panel_:Remove() end
			panel_ = vgui.Create("DFrame", self)
			panel_:SetTitle("Add XP")
			panel_:SetSize(400, 200)
			panel_:SetDraggable(false)
			panel_:SetAlpha(55)
			panel_:AlphaTo(255, 0.3, 0)
			panel_:Center()
			panel_.Paint = function()
				surface.SetDrawColor(Color(125,125,125,165))
				surface.DrawOutlinedRect(0, 0, panel_:GetWide(), panel_:GetTall())
				surface.SetDrawColor(Color(60,60,60,65))
				surface.DrawRect(0, 0, panel_:GetWide(), panel_:GetTall())
			end
			panel_:MakePopup()

			local text1 = EasyLabel(panel_, "NOTE: Value must be higher than 1.", "ZSHUDFontTiny")
			text1:SetPos(10, 40)

			local value = vgui.Create("DNumberWang", panel_)
			value:SetPos(10, 80)
			value:SetSize(120, 30)
			value:SetValue(1)
			value:SetMin(1)
			value:SetMax(MySelf:GetZSBankXP())
			value.Think = function()
				value:SetMax(math.min(GAMEMODE.MaxXP - MySelf:GetZSXP(), MySelf:GetZSBankXP()))
				value:SetValue(math.min(value:GetValue(), value:GetMax()))
			end

			local button = EasyButton(panel_, "Withdraw XP!")
			button:SetPos(10, 120)
			button:SetSize(120, 30)
			button.Paint = function()
				surface.SetDrawColor(Color(125,125,125,165))
				surface.DrawOutlinedRect(0, 0, button:GetWide(), button:GetTall())
				surface.SetDrawColor(Color(60,60,60,65))
				surface.DrawRect(0, 0, button:GetWide(), button:GetTall())
			end
			button.DoClick = function()
				net.Start("zs_bankxp")
				net.WriteUInt(math.min(2147483647, value:GetValue()), 32)
				net.SendToServer()
				panel_:Close()
			end

/*
			local frame = Derma_StringRequest("Add XP from bank", Format("Enter amount of XP to add from bank. Value must be a number! Max value: %s", MySelf:GetZSBankXP()), "0",
			function(strTextOut)
				if not strTextOut then self:DisplayMessage("Value must be a number!", COLOR_RED) return end
				if tonumber(strTextOut or 0) then self:DisplayMessage("Value must be at least \"1\" or more!", COLOR_RED) return end

				net.Start("zs_bankxp")
				net.WriteUInt(32, tonumber(strTextOut or 0))
				net.SendToServer()
			end,
			function(strTextOut) end,
			"OK", "Cancel")

			frame:GetChildren()[5]:GetChildren()[2]:SetTextColor(Color(30, 30, 30))
*/
		end
	end

	self:GenerateParticles()

	self.Top = top
	self.BottomLeft = bottomleft
	self.BottomLeftTop = bottomlefttop
	self.BottomLeftUp = bottomleftup
	self.QuickStats = quickstats
	self.Bottom = bottom
	self.TopRight = topright
	self.QuitButton = quit
	self.SkillName = skillname
	self.SkillDesc = desc
	self.ContextMenu = contextmenu
	self.MessageBox = messagebox
	self.MessageText = messagetext
	self.WarningText = warningtext
	if bankxptext then
		self.BankXPText = bankxptext
	end
	if bankxpbutton then
		self.BankXPButton = bankxpbutton
	end

	self.LoadoutsDrop = dropdown
	self.Reset = reset

	top:SetAlpha(0)

	self.AmbientSound = CreateSound(MySelf, "zombiesurvival/skilltree_ambiance.ogg")
	self.AmbientSound:PlayEx(0, 60)
	if not GAMEMODE.SkillPanelNoAmbientSound then
		self.AmbientSound:ChangeVolume(0, 0)
		self.AmbientSound:ChangeVolume(0.66, 1.5)
	end

	self:DockMargin(0, 0, 0, 0)
	self:DockPadding(0, 0, 0, 0)
	self:Dock(FILL)

	self:InvalidateLayout()

	self.CreationTime = RealTime()

	self:MakePopup()
	self:SetMouseInputEnabled(true)
	self:SetKeyboardInputEnabled(false)

	self:UpdateQuickStats()

	net.Start("zs_skills_refunded")
	net.SendToServer()
end

function PANEL:UpdateQuickStats()
	local skillmodifiers = {}
	local gm_modifiers = GAMEMODE.SkillModifiers
	for skillid in pairs(table.ToAssoc(MySelf:GetDesiredActiveSkills())) do
		local modifiers = gm_modifiers[skillid]
		if modifiers then
			for modid, amount in pairs(modifiers) do
				skillmodifiers[modid] = (skillmodifiers[modid] or 0) + amount
			end
		end
	end

	for i=1,4 do
		local prefix = i == SKILLMOD_HEALTH and "Health" or i == SKILLMOD_BLOODARMOR and "Blood Armor" or i == SKILLMOD_SPEED and "Speed" or i == SKILLMOD_WORTH and "Worth"
		local val = i == 1 and 100 or i == 2 and 20 or i == 3 and SPEED_NORMAL or GAMEMODE.StartingWorth

		self.QuickStats[i]:SetText(prefix .. " : " .. (val + (skillmodifiers[i] or 0)))
	end
end

function PANEL:DisplayMessage(msg, col)
	self.MessageText:SetText(msg)
	self.MessageText:SetTextColor(col or COLOR_GRAY)

	self.MessageBox:SetVisible(true)

	timer.Create("SKillWebMessageRemove", 4, 1, function() if self:IsValid() then self.MessageBox:SetVisible(false) end end)
end

PANEL.NextWarningThink = 0
/*
PANEL.NextProgressThink = 0
PANEL.Progress = {}
PANEL.TreeCount = {}
*/
function PANEL:Think()
	local time = RealTime()

	if not GAMEMODE.SkillPanelNoAmbientSound and self.AmbientSound and time >= self.CreationTime + 1 then
		self.AmbientSound:PlayEx(0.66, 60 + CurTime() % 0.1)
	end

	-- there's bug where using trinkets can set warning text to visible, but screw it
	if time < self.NextWarningThink then return end
		self.NextWarningThink = time + 0.1
	
		local display_warning = false
		local desired = table.ToAssoc(MySelf:GetDesiredActiveSkills())
		local active = MySelf:GetActiveSkills()
		for k, v in pairs(desired) do
			if v and not active[k] then
				display_warning = true
				break
			end
		end
	
		for k, v in pairs(active) do
			if v and not desired[k] then
				display_warning = true
				break
			end
		end
	
		if display_warning ~= self.WarningText:IsVisible() then
			self.WarningText:SetVisible(display_warning)
		end
	
/* -- New
	if time > self.NextProgressThink then
		self.NextProgressThink = time + 1
		self.Progress = {}
		self.TreeCount = {}
			
		for skill, skillinf in pairs(GAMEMODE.Skills) do
			if not skillinf.Tree then 
				continue
			end
				
			local tree = skillinf.Tree
			self.TreeCount[tree] = (self.TreeCount[tree] or 0) + 1
		end
			
		local active = MySelf:GetUnlockedSkills()
			
		for tree, _ in pairs(TREE_SKILLS) do
			for i, j in pairs(active) do
				local skillinf = GAMEMODE.Skills[j]
					
				if not skillinf or not skillinf.Tree then
					continue
				end
					
				if skillinf.Tree == tree then
					self.Progress[tree] = (self.Progress[tree] or 0) + 1
				end
			end
		end
	end
*/

end

function PANEL:GenerateParticles()
	local particles = {}
	local particle

/*	-- New
	for i=1, 140 do
		local dist = math.Rand(-5000, -32)
		local size_m = 1
			
		if dist <= -3000 then
			size_m = -(dist/3000)
		end
			
		particle = {}
		particle[1] = Vector(dist, math.Rand(-710, 710), math.Rand(-710, 710))
		particle[2] = math.Rand(0, 360)
		particle[3] = math.Rand(-5, 5)
		particle[4] = math.Rand(180, 190) * size_m
		particle[5] = math.Rand(30, 90)
		particles[i] = particle
	end
*/		

	-- Old
	for i=1, 230 do
		-- struct: Position, Roll, Roll rate, Size, Alpha
		particle = {}
		particle[1] = Vector(math.Rand(-1724, -32), math.Rand(-1210, 1210), math.Rand(-1210, 1210))
		particle[2] = math.Rand(0, 360)
		particle[3] = math.Rand(-5, 5)
		particle[4] = math.Rand(180, 240)
		particle[5] = math.Rand(30, 90)
		particles[i] = particle
	end


	self.Particles = particles
end

function PANEL:GenerateSplines()
	if GAMEMODE.SkillsSplined then return end

	-- for skillid, skill in pairs(GAMEMODE.Skills) do
	-- 	if skill.Curves then
	-- 		skill.Splines = {}
	-- 		local pos_a = self.SkillNodes[1][skillid]:GetPos()
	-- 		pos_a.x = 0
	-- 		for connectid, curve in pairs(skill.Curves) do
	-- 			local cm
	-- 			local splines = {}
	-- 			local pos_b = self.SkillNodes[1][connectid]:GetPos()
	-- 			pos_b.x = 0
	--
	-- 			table.insert(splines, pos_a)
	-- 			for mu=0, 0.9, 0.1 do
	-- 				cm = CatmullInterpolate(pos_a, pos_a, curve * 20, pos_b, mu, 1)
	-- 				cm.x = -16
	-- 				table.insert(splines, cm)
	-- 			end
	-- 			for mu=0, 0.9, 0.1 do
	-- 				cm = CatmullInterpolate(pos_a, curve * 20, pos_b, pos_b, mu, 1)
	-- 				cm.x = -16
	-- 				table.insert(splines, cm)
	-- 			end
	-- 			table.insert(splines, pos_b)
	-- 			skill.Splines[connectid] = splines
	-- 		end
	-- 		skill.Curves = nil
	-- 	end
	-- end

	GAMEMODE.SkillsSplined = true
end

function PANEL:PerformLayout()
	self.Top:AlignTop(8)
	self.Top:CenterHorizontal()

	self.BottomLeftTop:AlignLeft(ScrH() * 0.2)
	self.BottomLeftTop:AlignBottom(10)

	self.BottomLeftUp:AlignLeft(10)
	self.BottomLeftUp:AlignBottom(ScrW() * 0.08)

	self.BottomLeft:AlignLeft(10)
	self.BottomLeft:AlignBottom(10)

	self.Bottom:AlignBottom(10)
	self.Bottom:CenterHorizontal()

	self.TopRight:AlignRight(10)
	self.TopRight:AlignTop(10)

	self.MessageBox:CenterHorizontal()
	self.MessageBox:AlignTop(ScrH() * 0.65)

	self.WarningText:AlignBottom(32)
	self.WarningText:AlignRight(32)

	if self.BankXPText and self.BankXPText:IsValid() then
		self.BankXPText:AlignTop(32)
		self.BankXPText:AlignLeft(32)
	end

	if self.BankXPButton and self.BankXPButton:IsValid() then
		self.BankXPButton:AlignTop(64)
		self.BankXPButton:AlignLeft(32)
	end
end

function PANEL:SetDirectionalLight(iDirection, color)
	self.DirectionalLight[iDirection] = color
end

local camera_velocity = Vector(0, 0, 0)
function PANEL:DoEdgeScroll(deltatime)
	if not system.HasFocus() then return end

	local mx, my = gui.MousePos()
	local edge = math.min(w, h) * 0.035
	local scrolldir = Vector(0, 0, 0)
	local campos = self.vCamPos

	if mx <= edge and mx >= 0 then
		scrolldir.y = scrolldir.y - 1
	elseif mx >= w - edge and mx <= w then
		scrolldir.y = scrolldir.y + 1
	end

	if my <= edge and my >= 0 then
		scrolldir.z = scrolldir.z + 1
	elseif my >= h - edge and my <= h then
		scrolldir.z = scrolldir.z - 1
	end

	scrolldir:Normalize()

	if scrolldir.y ~= 0 or scrolldir.z ~= 0 and self.ContextMenu and self.ContextMenu:IsVisible() then
		self.ContextMenu:SetVisible(false)
	end

	camera_velocity = LerpVector(deltatime * (scrolldir.y == 0 and scrolldir.z == 0 and 3 or 1), camera_velocity, scrolldir)

	if camera_velocity.y ~= 0 or camera_velocity.z ~= 0 then
		campos = campos + deltatime * edge * 12 * camera_velocity
		-- Old
		campos.y = math.Clamp(campos.y, -662, 662)
		campos.z = math.Clamp(campos.z, -662, 662)

/*		-- New
		campos.y = math.Clamp(campos.y, -312, 312)
		campos.z = math.Clamp(campos.z, -312, 312)
*/
		self:SetCamPos(campos)
		self.vLookatPos:Set(campos)
		self.vLookatPos.x = 0
	end
end
/*
local particlecolors = {
	[TREE_HEALTHTREE] = Color(210, 150, 105, 90),
	[TREE_MELEETREE] = Color(180, 111, 111, 90),
	[TREE_GUNTREE] = Color(130, 170, 205, 90),
	[TREE_SPEEDTREE] = Color(160, 160, 55, 90),
	[TREE_BUILDINGTREE] = Color(215, 110, 170, 90),
	[TREE_SUPPORTTREE] = Color(130, 200, 135, 90),
	[TREE_TORMENTTREE] = Color(175, 175, 175, 90),
	[TREE_REMORTTREE] = Color(115, 115, 115, 90),
}
*/

local nodecolors = {
	[TREE_HEALTHTREE] = {1.75, 3, 5},
	[TREE_SPEEDTREE] = {2, 2, 5},
	[TREE_SUPPORTTREE] = {3, 1.5, 6},
	[TREE_BUILDINGTREE] = {2, 6, 3},
	[TREE_MELEETREE] = {1.5, 7, 7},
	[TREE_GUNTREE] = {5, 2, 2},
	[TREE_TORMENTTREE] = {2, 2, 2},
	[TREE_REMORTTREE] = {3.5, 3.5, 3.5}
}

-- This one is really hard to manage if you don't know what it does (it's there if you want to have custom skill colors if they can be unlocked, are unlocked, or are active)
local nc_canunlock = {
	[TREE_HEALTHTREE] = {1, 1, 1},
	[TREE_SPEEDTREE] = {1, 1, 1},
	[TREE_SUPPORTTREE] = {1, 1, 1},
	[TREE_BUILDINGTREE] = {1, 1, 1},
	[TREE_MELEETREE] = {1, 1, 1},
	[TREE_GUNTREE] = {1, 1, 1},
	[TREE_TORMENTTREE] = {1, 1, 1},
	[TREE_REMORTTREE] = {1, 1, 1}
}

local nc_unlocked = {
	[TREE_HEALTHTREE] = {1, 1, 1},
	[TREE_SPEEDTREE] = {1, 1, 1},
	[TREE_SUPPORTTREE] = {1, 1, 1},
	[TREE_BUILDINGTREE] = {1, 1, 1},
	[TREE_MELEETREE] = {1, 1, 1},
	[TREE_GUNTREE] = {1, 1, 1},
	[TREE_TORMENTTREE] = {1, 1, 1},
	[TREE_REMORTTREE] = {1, 1, 1}
}

local nc_active = {
	[TREE_HEALTHTREE] = {1, 1, 1},
	[TREE_SPEEDTREE] = {1, 1, 1},
	[TREE_SUPPORTTREE] = {1, 1, 1},
	[TREE_BUILDINGTREE] = {1, 1, 1},
	[TREE_MELEETREE] = {1, 1, 1},
	[TREE_GUNTREE] = {1, 1, 1},
	[TREE_TORMENTTREE] = {1, 1, 1},
	[TREE_REMORTTREE] = {1, 1, 1}
}

local matBeam = Material("effects/laser1")
local matGlow = Material("sprites/glow04_noz")
local matSmoke = Material("particles/smokey")
local matWhite = Material("models/debug/debugwhite")
local matGear = Material("models/shadertest/shader2")
local colBeam = Color(0, 0, 0)
local colBeam2 = Color(255, 255, 255)
local colSmoke = Color(140, 160, 185, 160)
local colGlow = Color(0, 0, 0)

function PANEL:Paint(w, h)
	local realtime = RealTime()
	local lifetime = realtime - self.CreationTime
	local dt = realtime - self.LastPaint
	local can_remort = MySelf:CanSkillsRemort()
	local skillid, skill, nodepos, selected
	local col, connectskill, othernode, othernodepos
	local add, pos_a, pos_b, sat
	local size, desc, ang
--	local size, desc, curve, desired_curve, ang
--	local dir = Vector(0, 0, 0)

	self:DoEdgeScroll(dt)

	local campos = self.vCamPos
	--campos.x = Lerp(math.min(lifetime * 0.1, (realtime - self.ZoomChange) * 4), campos.x, self.DesiredZoom)
	campos.x = math.Approach(campos.x, self.DesiredZoom, dt * 13500)
	self:SetCamPos(campos)

	surface.SetDrawColor(0, 0, 0, 250)
	surface.DrawRect(0, 0, w, h)

	ang = self.aLookAngle
	if not ang then
		ang = (self.vLookatPos - self.vCamPos):Angle()
	end
	local to_camera = ang:Forward() * -1
	--ang.roll = math.sin(realtime / 4) * 1.8

	local mx, my = gui.MousePos()
	local aimvector = util.AimVector(ang, self.fFOV, mx, my, w, h)
	local intersectpos = util.IntersectRayWithPlane(self.vCamPos, aimvector, self:GetLookAt(), Vector(-1, 0, 0))

	cam.Start3D( self.vCamPos, ang, self.fFOV, 0, 0, w, h, 5, self.FarZ )
	cam.IgnoreZ( true )

	render_SuppressEngineLighting( true )
	render.SetLightingOrigin( vector_origin )
	render.ResetModelLighting( self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255 )

	-- Old
	for i=0, 6 do
		col = self.DirectionalLight[ i ]
		if col then
			render.SetModelLighting( i, col.r / 255, col.g / 255, col.b / 255 )
		end
	end


/*	-- New
	for i=0, 55 do
		col = self.DirectionalLight[ i ]
			
		if col then
			render.SetModelLighting( i, col.r / 255, col.g / 255, col.b / 255 )
		end
	end
*/
	local particles = self.Particles
	render.SetMaterial(matSmoke)

	for i, particle in pairs(particles) do
		particle[2] = particle[2] + particle[3] * dt
		colSmoke.a = particle[5]
--		Old
		render.DrawQuadEasy(particle[1], to_camera, particle[4], particle[4], colSmoke, particle[2])
--		New
--		render.DrawQuadEasy(particle[1], to_camera, particle[4], particle[4] * 1, particlecolors[self.DesiredTree] or colSmoke, particle[2])
	end

	-- Old
	local skillnodes = self.SkillNodes
	-- New
/*
	local skillnodes = self.SkillNodes[self.DesiredTree]
*/
	local campost = self.vCamPos
	local camheightadj = (campost.x ^ 2) * 1.0035 -- Don't render nodes outside our view.

	render.SetMaterial(matBeam)
	for id, node in pairs(skillnodes) do
		if IsValid(node) then
			nodepos = node:GetPos()

			if (nodepos - campost):LengthSqr() > camheightadj then
				continue
			end

			skill = node.Skill

			if skill.Disabled then
				continue
			end

			if skill.Connections then
				for connectid, _ in pairs(skill.Connections) do
					connectskill = GAMEMODE.Skills[connectid]
					if id < connectid and (not connectskillskill or connectskill and not connectskill.Disabled) then -- Nodes are double linked so only draw one half-edge
						othernode = skillnodes[connectid]
						if IsValid(othernode) then
							othernodepos = othernode:GetPos()
							local beamsize = 4
							local nodeskill = GAMEMODE.Skills[node.SkillID]
							if MySelf:IsSkillUnlocked(node.SkillID) or MySelf:IsSkillUnlocked(connectid) then
								colBeam.r = 32
								colBeam.g = 128
								colBeam.b = 255
							elseif MySelf:SkillCanUnlock(node.SkillID) or MySelf:SkillCanUnlock(connectid) then
								colBeam.r = 255
								colBeam.g = 192
								colBeam.b = 0
							else
								colBeam.r = 128
								colBeam.g = 40
								colBeam.b = 40

								beamsize = 2
							end

							if hoveredskill == node.SkillID or hoveredskill == connectid then
								add = math.abs(math.sin(realtime * math.pi)) * 120
								colBeam.r = math.min(colBeam.r + add, 255)
								colBeam.g = math.min(colBeam.g + add, 255)
								colBeam.b = math.min(colBeam.b + add, 255)

								colBeam.a = 180
								colBeam2.a = 255
							else
								colBeam.a = 110
								colBeam2.a = 190
							end

							pos_a = nodepos + Vector(-16, 0, 0)
							pos_b = othernodepos + Vector(-16, 0, 0)
							splines = skill.Splines and skill.Splines[connectid]
							if splines then
								local numsplines = #splines
								render_StartBeam(#splines)
								for i, spline in ipairs(splines) do
									render.AddBeam(spline, 4, i / numsplines, colBeam2)
								end
								render_EndBeam()
								render_StartBeam(#splines)
								for i, spline in ipairs(splines) do
									render.AddBeam(spline, 12, i / numsplines, colBeam)
								end
								render_EndBeam()
							else
								render_DrawBeam(pos_a, pos_b, beamsize, 0, 1, colBeam2)
								render_DrawBeam(pos_a, pos_b, 16, 0, 1, colBeam)
							end
						end
					end
				end
			end
		end
	end

	local oldskill = hoveredskill
	hoveredskill = nil

	-- Old
	local angle = (realtime * 180) % 360
	-- New
--	local angle = (realtime * 90) % 360

	for id, node in pairs(skillnodes) do
		if IsValid(node) then
			nodepos = node:GetPos()
			if (nodepos - campost):LengthSqr() > camheightadj then
				continue
			end

			skillid = node.SkillID
			skill = node.Skill
			selected = not skill.Disabled and intersectpos and nodepos:DistToSqr(intersectpos) <= 36 -- 6^2

-- Old
			local sel_radius = 36 * (skill.ModelScale or 1)
			selected = not skill.Disabled and intersectpos and nodepos:DistToSqr(intersectpos) <= sel_radius
			local scale = 0.09
			-- New
/*
			local sel_radius = skillid <= -2 and 300 or skillid == -1 and 90 or 36 * (skill.ModelScale or 1)
			selected = not skill.Disabled and intersectpos and nodepos:DistToSqr(intersectpos) <= sel_radius
			local scale = skillid <= -2 and 0.08 or 0.09
*/
			cam.Start3D2D(node:GetPos() - to_camera * 8, Angle(0, 90, 90), scale)

			surface.DisableClipping(true)
			DisableClipping(true)

			if selected then
				hoveredskill = skillid

				sat = 1 - math.abs(math.sin(realtime * math.pi)) * 0.25
			else
				sat = 1
			end

			local notunlockable = false
			local divs = skill.ColorModifierOverride or nodecolors[skill.Tree] or {0, 0, 0}
			local divs1 = skill.ColorModifierOverrideCanUnlock or nc_canunlock and nc_canunlock[skill.Tree] or {1, 1, 1}
			local divs2 = skill.ColorModifierOverrideUnlocked or nc_unlocked and nc_unlocked[skill.Tree] or {1, 1, 1}
			local divs3 = skill.ColorModifierOverrideActive or nc_active and nc_active[skill.Tree] or {1, 1, 1}

			if skill.Disabled or (skillid == -1 and not can_remort) then
				render_SetColorModulation(sat / 6, sat / 6, sat / 6)
			elseif skillid == -1 then
				render_SetColorModulation(sat, sat, sat)
			elseif skillid < -1 then
				local tbl = particlecolors[-skillid - 1]

				render_SetColorModulation(tbl.r/255, tbl.g/255, tbl.b/255)
			elseif MySelf:IsSkillDesired(skillid) then
				render_SetColorModulation(sat / divs3[2] / 4,
				sat / divs3[2] / 4,
				sat / divs3[3] / 2)
--				render_SetColorModulation(sat / 4, sat / 4, sat / 2)
			elseif MySelf:IsSkillUnlocked(skillid) then
				render_SetColorModulation(sat / divs2[1],
				sat / divs2[2],
				sat / divs2[3])
--				render_SetColorModulation(sat, sat, sat)
			elseif MySelf:SkillCanUnlock(skillid) then
				render_SetColorModulation((sat / divs1[1]),
				(sat / divs1[2]) / 1.25,
				(sat / divs1[3]) / 4)
--				render_SetColorModulation(sat, sat / 1.25, sat / 4)
			else
				render_SetColorModulation(sat / divs[1] / 1.25,
					sat / divs[2] / 1.25,
					sat / divs[3] / 1.25)
				notunlockable = true
			end
/* -- New
			if skillid <= -2 then
				render_ModelMaterialOverride()
				render_SetBlend(0.95)
				node:SetModelScale(3.7)
				node:DrawModel()
				node:SetModelScale(3.8)
			end
*/
			render_ModelMaterialOverride(matWhite)
-- Old
			render_SetBlend(0.95)
-- New
--			render_SetBlend(skillid <= 2 and 0.2 or 0.95)

			node:DrawModel()

			render_SetBlend(1)
			render_ModelMaterialOverride()

			render_SetColorModulation(1, 1, 1)

			if self.vCamPos.x < (self.DesiredTree == 0 and 11500 or 9500) then
				local colo = skill.Disabled and COLOR_DARKGRAY or skill.Rainbow and HSVToColor(RealTime() * 160 % 360, 0.5, 1) or selected and color_white or notunlockable and COLOR_MIDGRAY or COLOR_GRAY
				local colo2 = COLOR_GRAY

				local greencolor = Color(71,231,119)
				local redcolor = Color(238,37,37)

	-- Old
				draw_SimpleText(skill.Name, skillid <= -1 and "ZS3D2DFont2" or "ZS3D2DFont2Small", 0, 0, colo, TEXT_ALIGN_CENTER) -- "ZS3D2DFont2Big" "ZS3D2DFont2"

/*	-- New
				local skill_text_y = skillid <= -2 and 120 or 0

				draw_SimpleText(skill.Name, skillid <= -2 and "ZS3D2DFont2Big" or skillid <= -1 and "ZS3D2DFont2" or "ZS3D2DFont2Small", 0, skill_text_y, colo, TEXT_ALIGN_CENTER) -- "ZS3D2DFont2Big" "ZS3D2DFont2"

				if skillid <= -2 and self.TreeCount[-skillid - 1] then
					draw_SimpleText((self.Progress[-skillid - 1] or 0).."/"..self.TreeCount[-skillid - 1], "ZS3D2DFont2Big", 0, skill_text_y + 130, colo, TEXT_ALIGN_CENTER)
				end
*/
				if self.vCamPos.x < 7000 then
					local font = "ZSHUDFontSmall" --"ZSHUDFont"
					local y_pos = 42 --58
					local y_pos_add = 26 --32
					if skill.AlwaysActive then
						draw_SimpleText(translate.Get("s_always_active"), font, 0, y_pos, COLOR_RPINK, TEXT_ALIGN_CENTER)
						y_pos = y_pos + y_pos_add
					end


					if skill.RemortReq then
						draw_SimpleText(translate.Format("s_remort_req", skill.RemortReq), font, 0, y_pos, skill.RemortReq <= MySelf:GetZSRemortLevel() and COLOR_GREEN or COLOR_SOFTRED, TEXT_ALIGN_CENTER)
						y_pos = y_pos + y_pos_add
					end

					if skill.RemortMaxReq then
						draw_SimpleText(translate.Format("s_remort_max", skill.RemortMaxReq), font, 0, y_pos, skill.RemortMaxReq >= MySelf:GetZSRemortLevel() and COLOR_GREEN or COLOR_SOFTRED, TEXT_ALIGN_CENTER)
						y_pos = y_pos + y_pos_add
					end

					if skill.RequiredSP then
						draw_SimpleText(translate.Format("s_need_sp", skill.RequiredSP), font, 0, y_pos, COLOR_YELLOW, TEXT_ALIGN_CENTER)
						y_pos = y_pos + y_pos_add
					end

					if skill.GiveSP then
						draw_SimpleText(translate.Format("s_give_sp", skill.GiveSP), font, 0, y_pos, greencolor, TEXT_ALIGN_CENTER)
						y_pos = y_pos + y_pos_add
					end

					local colo = skill.Hidden and Color(0,0,0,0) or skill.Disabled and COLOR_DARKGRAY or selected and color_white or notunlockable and COLOR_MIDGRAY or COLOR_GRAY

					if hoveredskill == skillid then
						if /*GAMEMODE.ZombieEscape and*/ skill.CanUseInZE then
							draw_SimpleText(translate.Get("can_use_in_escape_mode"), font, 0, y_pos, colo2, TEXT_ALIGN_CENTER)
							y_pos = y_pos + y_pos_add
						end

						if /*GAMEMODE.ClassicMode and*/ skill.CanUseInClassicMode then
							draw_SimpleText(translate.Get("can_use_in_classic_mode"), font, 0, y_pos, colo2, TEXT_ALIGN_CENTER)
							y_pos = y_pos + y_pos_add
						end
					end


					-- Allows to show skill modifier text, to see if there is any error in balancing.
					if hoveredskill == skillid and self.vCamPos.x < 5000 and GAMEMODE.AddSkillDescriptions then
						--local c = string.Explode("\n", skill.Description)
						if (type(GAMEMODE.SkillModifiers[skillid]) == "table" and table.Count(GAMEMODE.SkillModifiers[skillid]) or 0) > 0 then
							for k,v in pairs(GAMEMODE.SkillModifiers[skillid]) do
								local i = v or 1

								if !table.HasValue(GAMEMODE.SkillModifiersNonMulOnly, k) then
									i = (i*100).."%"
								end

								if (v or 0) > 0 then
									i = "+"..i
								end
								local colorred = table.HasValue(GAMEMODE.SkillModifiersBadOnly, k) and greencolor or redcolor
								local colorgreen = table.HasValue(GAMEMODE.SkillModifiersBadOnly, k) and redcolor or greencolor
								--translate.Format("skillmod_n"..i,c)
								if (v or 0) < 0 then
									col = colorred
								elseif (v or 0) > 0 then
									col = colorgreen
								else
									col = Color(255,255,255)
								end
								draw_SimpleText(translate.Format("skillmod_n"..k,i), font, 0, y_pos, col, TEXT_ALIGN_CENTER)
								y_pos = y_pos + y_pos_add
							end
						end
					end
				end
			end

			DisableClipping(false)
			surface.DisableClipping(false)
			cam.End3D2D()

			render.SetMaterial(matGlow)
	-- Old
			if skillid == -1 then
				if can_remort then
					render.DrawQuadEasy(nodepos, to_camera, 32, 32, color_white, angle)
				end


/* -- New
			if skillid <= -1 then

				local size
				if skillid == -1 and can_remort then
					size = 32
					render.DrawQuadEasy(nodepos, to_camera, size, size, color_white, angle)
				elseif skillid <= -2 then
					size = 65
					render.DrawQuadEasy(nodepos, to_camera, size/2, size/2, Color(166, 166, 166), angle)
					render.DrawQuadEasy(nodepos, to_camera, size, size, particlecolors[-skillid - 1] or color_white, angle)
				end
*/
			elseif not skill.Disabled then
				colGlow.r = sat * 255
				colGlow.g = sat * 255
				colGlow.b = sat * 255
				if MySelf:IsSkillDesired(skillid) then
					colGlow.r = (colGlow.r / divs3[1]) / 4
					colGlow.g = (colGlow.g / divs3[2]) / 4
					colGlow.b = colGlow.b / divs3[3]
--					colGlow.r = colGlow.r / 4
--					colGlow.g = colGlow.g / 4
				elseif not MySelf:IsSkillUnlocked(skillid) then
					if MySelf:SkillCanUnlock(skillid) then
						colGlow.r = colGlow.r / divs1[1]
						colGlow.g = (colGlow.g / divs1[2]) / 1.5
--						colGlow.g = colGlow.g / 1.5
						colGlow.b = 0
					else
						colGlow.r = colGlow.r / divs[1]
						colGlow.g = colGlow.g / divs[2]
						colGlow.b = colGlow.b / divs[3]
					end
				else
					colGlow.r = colGlow.r / divs2[1]
					colGlow.g = colGlow.g / divs2[2]
					colGlow.b = colGlow.b / divs2[3]
				end
				size = selected and 40 or 27
				render.DrawQuadEasy(nodepos, to_camera, size, size, colGlow, angle)
				angle = angle + 45
			end
		end
	end

	if intersectpos then
		intersectpos = intersectpos + Vector(16, 0, 0)
		render.SetMaterial(matGlow)
		render.DrawQuadEasy(intersectpos, to_camera, 12, 12, color_white, realtime * 90)
	end

	render_SuppressEngineLighting(false)

	cam.IgnoreZ(false)
	cam.End3D()

	if oldskill ~= hoveredskill then
		self.Top:Stop()

		if hoveredskill then
			skill = hoveredskill < -1 and TREE_SKILLS[-hoveredskill - 1] or hoveredskill == -1 and REMORT_SKILL or GAMEMODE.Skills[hoveredskill]
			self.SkillName:SetText(skill.Name)
			self.SkillName:SizeToContents()

			desc = string.Explode("\n", skill.Description)
			local txt, colid
			for i=1, 7 do
				txt = desc[i] or " "
				if txt:sub(1, 1) == "^" then
					colid = tonumber(txt:sub(2, 2)) or 0
					txt = txt:sub(3)
					self.SkillDesc[i]:SetTextColor(util.ColorIDToColor(colid, COLOR_GRAY))
				else
					self.SkillDesc[i]:SetTextColor(COLOR_GRAY)
				end
				self.SkillDesc[i]:SetText(txt)
				self.SkillDesc[i]:SizeToContents()
			end

			surface.PlaySound("zombiesurvival/ui/misc1.ogg")

			self.Top:SetAlpha(0)
			self.Top:AlphaTo(255, 0.15)
		else
			self.Top:AlphaTo(0, 0.15)
		end
	end

	self.LastPaint = realtime
/* -- New
	self.ShadeAlpha = math.Clamp(self.ShadeAlpha + self.ShadeVelocity, 0, 255)
	surface.SetDrawColor(0, 0, 0, self.ShadeAlpha)
	surface.DrawRect(0, 0, w, h)
*/
	local fgalpha = 255 - lifetime * 100
	if fgalpha > 0 then
		surface.SetDrawColor(0, 0, 0, fgalpha)
		surface.DrawRect(0, 0, w, h)
	end

	return true
end

function PANEL:OnMousePressed(mc)
	if mc == MOUSE_LEFT then
		local contextmenu = self.ContextMenu

		if hoveredskill then
			local mx, my = gui.MousePos()
			local can_remort = MySelf:CanSkillsRemort()
			contextmenu:SetPos(mx - contextmenu:GetWide() / 2, my - contextmenu:GetTall() / 2)

			if hoveredskill == -1 and can_remort then
				local function StartRemorting()
					net.Start("zs_skills_remort")
					net.SendToServer()
				end

				if GAMEMODE.NoRemortConfirmation then
					StartRemorting()
				else
					Derma_Query(
						Format("Are you ABSOLUTELY sure you want to remort? You will revert to level 1, lose all skills, but have 1 extra SP.\nThis cannot be undone!"),
						"Warning",
						"OK",
						function() StartRemorting() end,
						"Cancel",
						function() end
					)
				end

				return
			elseif hoveredskill == -1 then
				self:DisplayMessage(Format("You need to be level %d to remort!", GAMEMODE.MaxRemortableLevel), COLOR_RED)
				surface.PlaySound("buttons/button8.wav")

				return
/*	-- New
			elseif hoveredskill <= -1 then
				local destree = -hoveredskill - 1
				self.DesiredZoom = 2500
				self.ShadeVelocity = 255 * FrameTime() * 15
				
				timer.Simple(0.1, function()
					if not IsValid(self) then
						return
					end

					self.QuitButton:SetText("Back")
					self.DesiredZoom = 6500
					self.DesiredTree = destree
					self.ShadeVelocity = 255 * FrameTime() * -20
					local campos = self:GetCamPos()  campos.y = 0  campos.z = 0
				end)
					
				MySelf:EmitSound("buttons/button24.wav", 60, 200)
					
				return
*/

			elseif MySelf:IsSkillDesired(hoveredskill) then
				if GAMEMODE.Skills[hoveredskill].AlwaysActive then
					self:DisplayMessage("You can't deactivate this skill!", COLOR_RED)
					surface.PlaySound("buttons/button8.wav")

					return
				end

				if GAMEMODE.OneClickSkillActivate then DeactivateSkill(self, hoveredskill) return end
				contextmenu.Button:SetText("Deactivate")
			elseif MySelf:IsSkillUnlocked(hoveredskill) then
				if GAMEMODE.OneClickSkillActivate then ActivateSkill(self, hoveredskill) return end
				contextmenu.Button:SetText("Activate")
			elseif MySelf:SkillCanUnlock(hoveredskill) then
				local skillhovered = GAMEMODE.Skills[hoveredskill]
				if skillhovered.RequiredSP == 0 or MySelf:GetZSSPRemaining() >= (skillhovered.RequiredSP or 1) then
					if GAMEMODE.OneClickSkillActivate then UnlockSkill(self, hoveredskill) return end
					contextmenu.Button:SetText("Unlock")
				else
					self:DisplayMessage(Format("You need %s SP to unlock this skill!", skillhovered.RequiredSP or 1), COLOR_RED)
					surface.PlaySound("buttons/button8.wav")

					return
				end
			else
				self:DisplayMessage("You need to unlock an adjacent skill and meet any listed requirements!", COLOR_RED)
				surface.PlaySound("buttons/button8.wav")

				return
			end

			contextmenu.SkillID = hoveredskill

			contextmenu:SetVisible(true)
		else
			contextmenu:SetVisible(false)
		end
/*	-- New
	elseif mc == MOUSE_RIGHT and not hoveredskill then
		if self.DesiredTree == 0 then
			self:Remove()
		else
			self.DesiredTree = 0
			self.DesiredZoom = 2500
			self.ShadeVelocity = 255 * FrameTime() * 10
				
			timer.Simple(0.1, function()
				if not IsValid(self) then return end

				self.QuitButton:SetText("Close")
				self.DesiredZoom = 5000
				self.DesiredTree = 0
				self.ShadeVelocity = 255 * FrameTime() * -10
				local campos = self:GetCamPos()
				campos.y = 0
				campos.z = 0
				self:SetCamPos(campos)
			end)

			self.ContextMenu:SetVisible(false)
			MySelf:EmitSound("buttons/button24.wav", 60, 180)
		end
*/
	end
end

function PANEL:OnMouseWheeled(delta)
	self.DesiredZoom = math.Clamp(self.DesiredZoom - delta * 500, 2500, 15000)
end

function PANEL:OnRemove()
	-- Old
	for _, node in pairs(self.SkillNodes) do
		if IsValid(node) then
			node:Remove()
		end
	end

/* -- New
	for _, nodetrees in pairs(self.SkillNodes) do
		for _, node in pairs(nodetrees) do
			if IsValid(node) then
				node:Remove()
			end
		end
	end
*/
	local snd = self.AmbientSound
	snd:FadeOut(1.5)
	timer.Simple(1.5, function() if snd then snd:Stop() end end)
end

vgui.Register("ZSSkillWeb", PANEL, "Panel")

function GM:DrawXPBar(x, y, w, h, xpw, barwm, hm, level)
	local barw = xpw * barwm
	local xp = MySelf:GetZSXP()
	local progress = GAMEMODE:ProgressForXP(xp)
	local rlevel = MySelf:GetZSRemortLevel()
	local append = ""
	if rlevel > 0 then
		append = " // R.Lvl "..rlevel
	end

	surface.SetDrawColor(0, 0, 0, 220)
	surface.DrawRect(x, y, barw, 4)

	surface.SetDrawColor(10, 200, 10, 160)
	surface.DrawRect(x, y, barw * progress, 2)
	surface.SetDrawColor(0, 170, 0, 160)
	surface.DrawRect(x, y + 2, barw * progress, 2)

	if level == GAMEMODE.MaxLevel then
		draw_SimpleText("Lvl "..level.." (MAX)"..append, "ZSXPBar", xpw / 2, h / 2 + y, COLOR_GREEN, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		if progress > 0 then
			local lx = x + barw * progress - 1
			surface.SetDrawColor(255, 255, 255, 20 + math.abs(math.sin(RealTime() * 2)) * 170)
			surface.DrawLine(lx, y - 2, lx, y + 7)
			surface.SetDrawColor(255, 255, 255, 160)
			surface.DrawLine(x, y - 1, x, y + 5)
			lx = x + barw - 1
			surface.DrawLine(lx, y - 1, lx, y + 5)
		end

		local text = "Lvl "..level..append
		local text2 = string.CommaSeparate(xp).." / "..string.CommaSeparate(GAMEMODE:XPForLevel(level + 1)).." XP"
		local size = string.len(text) + string.len(text2)
		local font = size > 44 and "ZSXPBarSmall" or "ZSXPBar"
		draw_SimpleText(text, font, x, h / 2 + y, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw_SimpleText(text2, font, x + barw, h / 2 + y, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
end

PANEL = {}

PANEL.PlayerLevel = 0

function PANEL:Init()
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
end

function PANEL:PerformLayout()
	local screenscale = BetterScreenScale()

	self:SetSize(350 * screenscale, 36 * screenscale)
	if GAMEMODE.GameStatePanel2 and GAMEMODE.GameStatePanel2:IsValid() then
		self:MoveBelow(GAMEMODE.GameStatePanel2, screenscale * 32)
	elseif GAMEMODE.GameStatePanel and GAMEMODE.GameStatePanel:IsValid() then
		self:MoveBelow(GAMEMODE.GameStatePanel, screenscale * 32)
	else
		self:AlignTop(400)
	end
	self:AlignLeft()
end

local rl = 0

function PANEL:Think()
	local new_level = MySelf:GetZSLevel()
	local remort = MySelf:GetZSRemortLevel() 

	if new_level ~= self.PlayerLevel then
		if new_level ~= 1 and self.FirstLevelChange and remort == rl then
			GAMEMODE:CenterNotify(translate.Format("you_ascended_to_level_x", new_level))
			surface.PlaySound("weapons/physcannon/energy_disintegrate"..math.random(4, 5)..".wav")
		else
			self.FirstLevelChange = true
		end
	end

	self.PlayerLevel = new_level
	rl = remort
end

local matGradientLeft = CreateMaterial("gradient-l", "UnlitGeneric", {["$basetexture"] = "vgui/gradient-l", ["$vertexalpha"] = "1", ["$vertexcolor"] = "1", ["$ignorez"] = "1", ["$nomip"] = "1"})
local colFlash = Color(255, 255, 255)
function PANEL:Paint(w, h)
	surface.SetDrawColor(0, 0, 0, 160)
	surface.DrawRect(0, 0, w * 0.4, h)
	surface.SetMaterial(matGradientLeft)
	surface.DrawTexturedRect(w * 0.4, 0, w * 0.6, h)

	local xpw = w * 0.85
	local x = xpw * 0.03
	local y = h * 0.15
	GAMEMODE:DrawXPBar(x, y, w, h, xpw, 0.9, 0.85, self.PlayerLevel)

	local sp = MySelf:GetZSSPRemaining()
	if sp > 0 then
		colFlash.a = 90 + math.abs(math.sin(RealTime() * 2)) * 160
		draw_SimpleText(sp > 99 and ">99 SP" or sp.." SP", "ZSHUDFontSmallest", w - (70 * BetterScreenScale()), h / 2, colFlash, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
end

vgui.Register("ZSExperienceHUD", PANEL, "Panel")

function GM:ToggleSkillWeb()
	if self.SkillWeb and self.SkillWeb:IsValid() then
		self.SkillWeb:Remove()
		self.SkillWeb = nil
		return
	end

	self.SkillWeb = vgui.Create("ZSSkillWeb")
end

local meta = FindMetaTable("Player")
if not meta then return end

function meta:SetSkillDesired(skillid, desired)
	local desiredskills = self:GetDesiredActiveSkills()

	if desired then
		if self:IsSkillUnlocked(skillid) and not self:IsSkillDesired(skillid) then
			table.insert(desiredskills, skillid)
		end
	else
		table.RemoveByValue(desiredskills, skillid)
	end

	self:SetDesiredActiveSkills(desiredskills)
end

function meta:SetSkillUnlocked(skillid, unlocked)
	local unlockedskills = self:GetUnlockedSkills()

	if self:IsSkillUnlocked(skillid) ~= unlocked then
		if unlocked then
			table.insert(unlockedskills, skillid)
		else
			table.RemoveByValue(unlockedskills, skillid)
		end
	end

	self:SetUnlockedSkills(unlockedskills)
end

function meta:SetDesiredActiveSkills(skills, nosend)
	self.DesiredActiveSkills = table.ToKeyValues(skills)
end

function meta:SetActiveSkills(skills, nosend)
	self.ActiveSkills = table.ToAssoc(skills)
end

function meta:SetUnlockedSkills(skills, nosend)
	self.UnlockedSkills = table.ToKeyValues(skills)
end
