local PANEL = {}

PANEL.NextRefresh = 0
PANEL.RefreshTime = 1

local col2 = Color(190, 150, 80, 210)
local coldark = Color(0, 0, 0, 100)

local function GetTargetEntIndex()
	return GAMEMODE.HumanMenuLockOn and GAMEMODE.HumanMenuLockOn:IsValid() and GAMEMODE.HumanMenuLockOn:EntIndex() or 0
end

local function DropDoClick(self, amt, ammotypeoverride)
	RunConsoleCommand("zsdropammo", ammotypeoverride or self:GetParent():GetAmmoType(), amt)
end

local function GiveDoClick(self, amt, ammotypeoverride)
	RunConsoleCommand("zsgiveammo", ammotypeoverride or self:GetParent():GetAmmoType(), GetTargetEntIndex(), amt)
end

local panel_
local function MakeDropPanel(ammotype, shouldgive)
	if panel_ and panel_:IsValid() then panel_:Remove() end

	panel_ = vgui.Create("DFrame")
	panel_:SetTitle(shouldgive and "Give ammo" or "Drop Ammo")
	panel_:SetSize(340, 180)
	panel_:SetDraggable(false)
	panel_:Center()
	panel_.Paint = function(self)
		surface.SetDrawColor(Color(25,25,25,165))
		surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
		surface.SetDrawColor(Color(0,0,0,65))
		surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
	end
	panel_.Think = function(self)
		if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then
			timer.Simple(0, function()
				self:Remove()
			end)
			gui.HideGameUI()
		end
	end
	panel_:MakePopup()

	local text1 = EasyLabel(panel_, shouldgive and "Give ammo to player" or "Drop desired ammo count", "ZSHUDFontTiny")
	text1:SetPos(10, 40)

	local value = vgui.Create("DNumberWang", panel_)
	value:SetPos(10, 80)
	value:SetSize(120, 30)
	value:SetValue(math.min(MySelf:GetAmmoCount(ammotype), shouldgive and GAMEMODE.AmmoCache[ammotype] or GAMEMODE.AmmoCache[ammotype] * 2 or 1))
	value:SetMin(1)
	value:SetMax(99999)
	value.OnEnter = function(self)
		if shouldgive then
			GiveDoClick(self, value:GetValue(), ammotype)
		else
			DropDoClick(self, value:GetValue(), ammotype)
		end
		panel_:Remove()
	end
	value:RequestFocus()

	local button = EasyButton(panel_, shouldgive and "Give ammo" or "Drop ammo")
	button:SetPos(10, 120)
	button:SetSize(120, 30)
	button.Paint = function()
		surface.SetDrawColor(Color(65,65,65,165))
		surface.DrawOutlinedRect(0, 0, button:GetWide(), button:GetTall())
		surface.SetDrawColor(Color(25,25,25,65))
		surface.DrawRect(0, 0, button:GetWide(), button:GetTall())
	end
	button.DoClick = function(self)
		if shouldgive then
			GiveDoClick(self, value:GetValue(), ammotype)
		else
			DropDoClick(self, value:GetValue(), ammotype)
		end
		panel_:Remove()
	end
end

function PANEL:Init()
	local font = "ZSAmmoName"
	self.m_AmmoCountLabel = EasyLabel(self, "0", font, color_black)

	self.m_AmmoTypeLabel = EasyLabel(self, " ", font, col2)

	self.m_DropButton = vgui.Create("DImageButton", self)
	self.m_DropButton:SetImage("icon16/box.png")
	self.m_DropButton:SizeToContents()
	self.m_DropButton:SetTooltip("Drop\nRight-click to drop desired amount")
	self.m_DropButton.DoClick = DropDoClick
	self.m_DropButton.DoRightClick = function(this)
		MakeDropPanel(self:GetAmmoType(), false)
	end

	self.m_GiveButton = vgui.Create("DImageButton", self)
	self.m_GiveButton:SetImage("icon16/user_go.png")
	self.m_GiveButton:SizeToContents()
	self.m_GiveButton:SetTooltip("Give\nRight-click to give desired amount")
	self.m_GiveButton.DoClick = GiveDoClick
	self.m_GiveButton.DoRightClick = function(this)
		MakeDropPanel(self:GetAmmoType(), true)
	end

	self:SetAmmoType("pistol")
end

local colBG = Color(5, 5, 5, 180)
function PANEL:Paint()
	local tall = self:GetTall()
	local csize = tall - 8
	draw.RoundedBoxEx(8, 0, 0, self:GetWide(), tall, colBG)
	draw.RoundedBox(4, 8, tall * 0.5 - csize * 0.5, csize, csize, col2)

	return true
end

function PANEL:Think()
	if RealTime() >= self.NextRefresh then
		self.NextRefresh = RealTime() + self.RefreshTime
		self:RefreshContents()
	end
end

function PANEL:RefreshContents()
	local count = MySelf:GetAmmoCount(self:GetAmmoType())

	self.m_AmmoCountLabel:SetTextColor(count == 0 and coldark or color_black)
	self.m_AmmoCountLabel:SetText(count)
	self.m_AmmoCountLabel:SizeToContents()

	self:InvalidateLayout()
end

function PANEL:PerformLayout()
	self.m_AmmoTypeLabel:Center()

	self.m_AmmoCountLabel:SetPos(8 + (self:GetTall() - 8) * 0.5 - self.m_AmmoCountLabel:GetWide() / 2, 0)
	self.m_AmmoCountLabel:CenterVertical()

	self.m_DropButton:AlignTop(1)
	self.m_DropButton:AlignRight(8)

	self.m_GiveButton:AlignBottom(1)
	self.m_GiveButton:AlignRight(8)
end

function PANEL:SetAmmoType(ammotype)
	self.m_AmmoType = ammotype

	self.m_AmmoTypeLabel:SetText(GAMEMODE.AmmoNames[ammotype] or ammotype)
	self.m_AmmoTypeLabel:SizeToContents()

	self:RefreshContents()
end

function PANEL:GetAmmoType()
	return self.m_AmmoType
end

vgui.Register("DAmmoCounter", PANEL, "DPanel")
