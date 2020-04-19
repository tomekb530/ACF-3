local PANEL = {}

DEFINE_BASECLASS("Panel")

-- Panels don't have a CallOnRemove function
-- This roughly replicates the same behavior
local function AddOnRemove(Panel, Parent)
	local OldRemove = Panel.Remove

	function Panel:Remove()
		Parent:EndTemporal(self)
		Parent:ClearTemporal(self)

		Parent.Items[self] = nil

		for TempParent in pairs(self.TempParents) do
			TempParent.TempItems[self] = nil
		end

		if self == Parent.LastItem then
			Parent.LastItem = self.PrevItem
		end

		if IsValid(self.PrevItem) then
			self.PrevItem.NextItem = self.NextItem
		end

		if IsValid(self.NextItem) then
			self.NextItem.PrevItem = self.PrevItem
		end

		OldRemove(self)
	end
end

function PANEL:Init()
	self.Items = {}
	self.TempItems = {}
end

function PANEL:ClearAll()
	for Item in pairs(self.Items) do
		Item:Remove()
	end

	self:Clear()
end

function PANEL:ClearTemporal(Panel)
	local Target = IsValid(Panel) and Panel or self

	if not Target.TempItems then return end

	for K in pairs(Target.TempItems) do
		K:Remove()
	end
end

local TemporalPanels = {}

function PANEL:StartTemporal(Panel)
	local Target = IsValid(Panel) and Panel or self

	if not Target.TempItems then
		Target.TempItems = {}
	end

	TemporalPanels[Target] = true
end

function PANEL:EndTemporal(Panel)
	local Target = IsValid(Panel) and Panel or self

	TemporalPanels[Target] = nil
end

function PANEL:ClearAllTemporal()
	for Panel in pairs(TemporalPanels) do
		self:EndTemporal(Panel)
		self:ClearTemporal(Panel)
	end
end

function PANEL:AddPanel(Name)
	if not Name then return end

	local Panel = vgui.Create(Name, self)

	if not IsValid(Panel) then return end

	Panel:Dock(TOP)
	Panel:DockMargin(0, 0, 0, 10)
	Panel:InvalidateParent()
	Panel:InvalidateLayout()
	Panel.TempParents = {}

	self:InvalidateLayout()
	self.Items[Panel] = true

	local LastItem = self.LastItem

	if IsValid(LastItem) then
		LastItem.NextItem = Panel

		Panel.PrevItem = LastItem

		for Temp in pairs(LastItem.TempParents) do
			Panel.TempParents[Temp] = true
			Temp.TempItems[Panel] = true
		end
	end

	self.LastItem = Panel

	for Temp in pairs(TemporalPanels) do
		Panel.TempParents[Temp] = true
		Temp.TempItems[Panel] = true
	end

	AddOnRemove(Panel, self)

	return Panel
end

function PANEL:AddButton(Text, Command, ...)
	local Panel = self:AddPanel("DButton")
	Panel:SetText(Text or "Button")
	Panel:SetFont("ACF_Control")

	if Command then
		Panel:SetConsoleCommand(Command, ...)
	end

	return Panel
end

function PANEL:AddCheckBox(Text)
	local Panel = self:AddPanel("DCheckBoxLabel")
	Panel:SetText(Text or "Checkbox")
	Panel:SetFont("ACF_Control")
	Panel:SetDark(true)

	return Panel
end

function PANEL:AddTitle(Text)
	local Panel = self:AddPanel("DLabel")
	Panel:SetAutoStretchVertical(true)
	Panel:SetText(Text or "Text")
	Panel:SetFont("ACF_Title")
	Panel:SetWrap(true)
	Panel:SetDark(true)

	return Panel
end

function PANEL:AddLabel(Text)
	local Panel = self:AddTitle(Text)
	Panel:SetFont("ACF_Label")

	return Panel
end

function PANEL:AddHelp(Text)
	local TextColor = self:GetSkin().Colours.Tree.Hover
	local Panel = self:AddLabel(Text)
	Panel:DockMargin(32, 0, 32, 10)
	Panel:SetTextColor(TextColor)
	Panel:InvalidateLayout()

	return Panel
end

function PANEL:AddComboBox()
	local Panel = self:AddPanel("DComboBox")
	Panel:SetFont("ACF_Control")
	Panel:SetSortItems(false)
	Panel:SetDark(true)
	Panel:SetWrap(true)

	return Panel
end

function PANEL:AddSlider(Title, Min, Max, Decimals)
	local Panel = self:AddPanel("DNumSlider")
	Panel:DockMargin(0, 0, 0, 5)
	Panel:SetDecimals(Decimals or 0)
	Panel:SetText(Title or "")
	Panel:SetMinMax(Min, Max)
	Panel:SetValue(Min)
	Panel:SetDark(true)

	Panel.Label:SetFont("ACF_Control")

	return Panel
end

function PANEL:AddNumberWang(Label, Min, Max, Decimals)
	local Base = self:AddPanel("ACF_Panel")

	local Wang = Base:Add("DNumberWang")
	Wang:SetDecimals(Decimals or 0)
	Wang:SetMinMax(Min, Max)
	Wang:SetTall(20)
	Wang:Dock(RIGHT)

	local Text = Base:Add("DLabel")
	Text:SetText(Label or "Text")
	Text:SetFont("ACF_Control")
	Text:SetDark(true)
	Text:Dock(TOP)

	return Wang, Text
end

function PANEL:PerformLayout()
	self:SizeToChildren(true, true)
end

function PANEL:GenerateExample()
end

derma.DefineControl("ACF_Panel", "", PANEL, "Panel")