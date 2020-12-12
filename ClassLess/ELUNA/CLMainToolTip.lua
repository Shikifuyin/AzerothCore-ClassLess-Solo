-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess Client UI : Main Button
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Requirements
local AIO = AIO or require("AIO")
if not class then require("class") end

-------------------------------------------------------------------------------------------------------------------
-- Client / Server Setup

-- Client-side Only !
if AIO.AddAddon() then
	return
end

-------------------------------------------------------------------------------------------------------------------
-- Constants

-------------------------------------------------------------------------------------------------------------------
-- ClassLessMainToolTip - Declaration
ClassLessMainToolTip = class({
	-- Static Members
})

function ClassLessMainToolTip:init()
	-- Members
	self.m_hToolTip = nil
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessMainToolTip : Getters / Setters

-------------------------------------------------------------------------------------------------------------------
-- ClassLessMainToolTip : Methods
function ClassLessMainToolTip:SetOwner( hOwner, strAnchor )
	self.m_hToolTip:SetOwner( hOwner, strAnchor )
end

function ClassLessMainToolTip:Show()
	self.m_hToolTip:Show()
end
function ClassLessMainToolTip:Hide()
	self.m_hToolTip:Hide()
end

function ClassLessMainToolTip:AddLine( strText, colTextColor )
	self.m_hToolTip:AddLine( strText, colTextColor.r, colTextColor.g, colTextColor.b, nil )
end
function ClassLessMainToolTip:SetHyperlink( strLink )
	self.m_hToolTip:SetHyperlink( strLink )
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessMainToolTip : Initialization
function ClassLessMainToolTip:Initialize()
	if ( self.m_hToolTip ~= nil ) then
		return
	end
	
	-- Create ToolTip
	self.m_hToolTip = CreateFrame( "GameTooltip", "CLMainToolTip", nil, "GameTooltipTemplate" )
	self.m_hToolTip:Hide()
	
	print( "CLMainToolTip Initialized !" )
end



