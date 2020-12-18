-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess Client UI : ToolTip
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
-- CLUIToolTip - Declaration
CLUIToolTip = class({
	-- Static Members
})

function CLUIToolTip:init()
	-- Members
	self.m_hToolTip = nil
end

-------------------------------------------------------------------------------------------------------------------
-- CLUIToolTip : Methods
function CLUIToolTip:SetOwner( hOwner, strAnchor )
	self.m_hToolTip:SetOwner( hOwner, strAnchor )
end

function CLUIToolTip:Show()
	self.m_hToolTip:Show()
end
function CLUIToolTip:Hide()
	self.m_hToolTip:Hide()
end

function CLUIToolTip:AddLine( strText, colTextColor )
	self.m_hToolTip:AddLine( strText, colTextColor.r, colTextColor.g, colTextColor.b, nil )
end
function CLUIToolTip:SetHyperlink( strLink )
	self.m_hToolTip:SetHyperlink( strLink )
end

-------------------------------------------------------------------------------------------------------------------
-- CLUIToolTip : Initialization
function CLUIToolTip:Initialize()
	if ( self.m_hToolTip ~= nil ) then
		return
	end
	
	-- Create ToolTip
	self.m_hToolTip = CreateFrame( "GameTooltip", "CLToolTip", nil, "GameTooltipTemplate" )
	self.m_hToolTip:Hide()
	
	print( "CLUIToolTip Initialized !" )
end



