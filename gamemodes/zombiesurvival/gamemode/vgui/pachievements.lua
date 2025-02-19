function GM:DoAchievementsPanel()
    if IsValid(self.AchievementsPanel) then self.AchievementsPanel:Remove() end
    self.AchievementsPanel = vgui.Create("ZSAchievementsPanel")
    self.AchievementsPanel:SetAlpha(0)
    self.AchievementsPanel:AlphaTo(255, 0.15, 0)
end

local PANEL = {}
local achievements_completed = 0

function PANEL:Init()
    self:SetSize(510, 600)
    self:Center()
    self:MakePopup()
    self:DockPadding(0, 24, 0, 0)
    self:SetTitle("")
    self:ShowCloseButton(false)
    -- New close button
    self.CB = self:Add("DButton")
    self.CB:SetSize(32, 24)
    self.CB:SetPos(478, 0)
    self.CB:SetText("")

    self.CB.DoClick = function()
        self:Close()
    end

    self.CB.Paint = function(this, w, h)
        self:ShadowedText("Exit", "ZSHUDFontTiny", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end


    self.SP = self:Add("DScrollPanel")
    self.SP:Dock(FILL)
    self.SP.VBar:SetHideButtons(true)
    self.SP.VBar.Paint = function() end

    self.SP.VBar.btnGrip.Paint = function(this, w, h)
        surface.SetDrawColor(self:GetTint())
        surface.DrawRect(0, 0, w, h)
    end

    local i = 1
    achievements_completed = 0
    local count = table.Count(GAMEMODE.Achievements)

    for id, ach in SortedPairs(GAMEMODE.Achievements) do
        local panel = self.SP:Add("DPanel")
        panel:Dock(TOP)
        panel:SetTall(ach.Goal and 120 or 90)

        local done
        if ach.Goal then
            done = (isnumber(GAMEMODE.AchievementsProgress[id]) and GAMEMODE.AchievementsProgress[id] or 0) >= ach.Goal
            panel.Done = done
            if done then
                achievements_completed = achievements_completed + 1
            end
        else
            done = GAMEMODE.AchievementsProgress[id]
            panel.Done = done
            if done then
                achievements_completed = achievements_completed + 1
            end
        end

        panel.BG = i % 2 + 1 == 1
        panel.Line = i < count

        panel.Paint = function(this, w, h)
            -- BG
            surface.SetDrawColor(self:GetTheme(this.BG and 2 or 1))
            surface.DrawRect(0, 0, w, h)

            if this.Done then
                surface.SetDrawColor(0, 175, 100)
                surface.DrawRect(0, 0, w, h)
            end

            -- Texts
            self:ShadowedText(ach.Name, "ZSHUDFontSmallest", 8, 7, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            self:ShadowedText(ach.Desc, "ZSHUDFontTiny", 8, 28, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            self:ShadowedText(translate.Format("ach_difficulty", translate.Get("ach_difficulty_"..(ach.Diff or 1)), ach.Diff or 1), "ZSHUDFontTiny", 8, 46, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            self:ShadowedText(translate.Format("ach_xpreward", ach.Reward or 0), "ZSHUDFontTiny", 8, 64, self:GetTheme(3), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            -- Bars
            if ach.Goal then
                surface.SetDrawColor(self:GetTheme(this.BG and 1 or 2))
                surface.DrawRect(8, 86, w - 16, 24)
                surface.SetDrawColor(self:GetTint())
                surface.DrawRect(8, 86, self:Map(GAMEMODE.AchievementsProgress[id] or 0, 0, ach.Goal, 0, w - 16), 24)
                self:ShadowedText(math.Round(GAMEMODE.AchievementsProgress[id] or 0, 2) .. "/" .. ach.Goal, "ZSHUDFontTiny", w / 2, 97, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            if this.Line then
                surface.SetDrawColor(self:GetTheme(3))
                surface.DrawLine(0, h - 1, w, h - 1)
            end
/*
            if this.Reward then
                self:ShadowedText(this.Reward, "ZSHUDFontTiny", w / 2, 10, self:GetTheme(3), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
*/
        end
/*
        panel.NameLabel = EasyLabel(nil, ach.Name, "ZSHUDFontSmallest", self:GetTheme(3))
        panel.NameLabel:SizeToContents()
        panel.NameLabel:SetPos()
*/
        i = i + 1
    end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(Color(0,0,0,195))
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(Color(0,0,0,225))
    surface.DrawRect(0, 0, w, 24)
    self:ShadowedText(translate.Format("ach_progress", achievements_completed, table.Count(GAMEMODE.Achievements)), "ZSHUDFontSmall", 8, 12, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

-- Should return HiderColor, SeekerColor or Specator color
function PANEL:GetTint()
    local col = Color(159, 159, 159)
    if LocalPlayer():Team() == TEAM_HUMAN then
        return col --Color(145, 156, 253)
    elseif LocalPlayer():Team() == TEAM_UNDEAD then
        return col --Color(7, 92, 18)
    else
        return col --team.GetColor(LocalPlayer():Team())
    end
end

-- Differences between themes
local light = {
    Color(255, 255, 255), -- BG
    Color(175, 175, 175), -- Header
    Color(0, 0, 0), -- Text
}

local dark = {
    Color(25, 25, 25), -- BG
    Color(50, 50, 50), -- Header
    Color(255, 255, 255), -- Text
}

function PANEL:GetTheme(i)
    return dark[i] or Color(0, 0, 0)
end

function PANEL:ShadowedText(text, font, x, y, color, alignx, aligny)
    draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0, 200), alignx, aligny)
    draw.SimpleText(text, font, x, y, color, alignx, aligny)
end

-- https://stackoverflow.com/questions/929103/convert-a-number-range-to-another-range-maintaining-ratio
function PANEL:Map(value, oldMin, oldMax, newMin, newMax)
    return (((value - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin
end

vgui.Register("ZSAchievementsPanel", PANEL, "DFrame")