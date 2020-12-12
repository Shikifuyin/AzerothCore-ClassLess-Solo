-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess Client UI : Main Points Frame
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
-- ClassLessMainPointsFrame - Declaration
ClassLessMainPointsFrame = class({
	-- Static Members
})

function ClassLessMainPointsFrame:init()
	-- Members
	self.m_iWidth = 200
	self.m_iHeight = 32
	self.m_strPositionAnchor = "BOTTOMLEFT"
	self.m_iPositionX = 10
	self.m_iPositionY = 10
	
	self.m_hFrame = nil
	
	self.m_hText = nil
	self.m_colTextColor = NORMAL_FONT_COLOR
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessMainPointsFrame : Getters / Setters

-------------------------------------------------------------------------------------------------------------------
-- ClassLessMainPointsFrame : Methods
function ClassLessMainPointsFrame:Update()
	local iSpellPoints = CLClient:GetRemainingSpellPoints()
	local iTalentPoints = CLClient:GetRemainingTalentPoints()
	
	self.m_hText:SetText( "Remaining Points : " .. iSpellPoints .. " SP / " .. iTalentPoints .. " TP" )
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessMainPointsFrame : Initialization
function ClassLessMainPointsFrame:Initialize( hParentFrame )
	if ( self.m_hFrame ~= nil ) then
		return
	end
	local hThis = self
	
	-- Create Frame
	self.m_hFrame = CreateFrame( "Frame", "CLMainPointsFrame", hParentFrame )
	
	-- Size & Position
	self.m_hFrame:SetSize( self.m_iWidth, self.m_iHeight )
	self.m_hFrame:SetPoint( self.m_strPositionAnchor, hParentFrame, self.m_strPositionAnchor, self.m_iPositionX, self.m_iPositionY )
	
	-- Setup Text
	self.m_hText = self.m_hFrame:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
	self.m_hText:SetTextColor( self.m_colTextColor.r, self.m_colTextColor.g, self.m_colTextColor.b )
	self.m_hText:SetJustifyV( "MIDDLE" )
	self.m_hText:SetJustifyH( "LEFT" )
    self.m_hText:SetPoint( "CENTER", self.m_hFrame, "CENTER", 0, 0 )
	
	-- Event : OnUpdate
	self.m_hFrame:SetScript( "OnUpdate",
        function()
			hThis:Update()
        end
    )
	
	print( "CLMainPointsFrame Initialized !" )
end





