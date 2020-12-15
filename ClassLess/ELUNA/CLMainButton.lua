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
-- ClassLessMainButton - Declaration
ClassLessMainButton = class({
	-- Static Members
})

function ClassLessMainButton:init()
	-- Members
	self.m_iSize = 32
	self.m_strPositionAnchor = "BOTTOMRIGHT"
	self.m_iPositionX = -50
	self.m_iPositionY = 50
	
	self.m_hButton = nil
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessMainButton : Methods

-------------------------------------------------------------------------------------------------------------------
-- ClassLessMainButton : Initialization
function ClassLessMainButton:Initialize()
	if ( self.m_hButton ~= nil ) then
		return
	end
	local hThis = self
	
	-- Create Button
	self.m_hButton = CreateFrame( "Button", "CLMainButton", UIParent )
	
	-- Size & Position
	self.m_hButton:SetSize( self.m_iSize, self.m_iSize )
	self.m_hButton:SetPoint( self.m_strPositionAnchor, UIParent, self.m_strPositionAnchor, self.m_iPositionX, self.m_iPositionY )
	
	AIO.SavePosition( self.m_hButton )
	
	-- Properties
	self.m_hButton:SetToplevel( true )
	self.m_hButton:SetMovable( true )
	self.m_hButton:SetClampedToScreen( true )
    self.m_hButton:EnableMouse( true )
	
	-- Textures
	self.m_hButton.background = self.m_hButton:CreateTexture( nil, "BACKGROUND" )
	self.m_hButton.background:SetTexture( "Interface\\Icons\\INV_Misc_Book_01" )
	self.m_hButton.background:SetSize( self.m_iSize, self.m_iSize )
	self.m_hButton.background:SetAllPoints( self.m_hButton )
	
	-- Drag & Drop
	self.m_hButton:RegisterForDrag( "RightButton" )
    self.m_hButton:SetScript( "OnDragStart", self.m_hButton.StartMoving )
    self.m_hButton:SetScript( "OnDragStop", self.m_hButton.StopMovingOrSizing )
	
	-- Event : OnEnter
    self.m_hButton:SetScript( "OnEnter",
        function()
			-- Attach ToolTip to Button Frame
			local hToolTip = CLClient:GetMainToolTip()
            hToolTip:SetOwner( hThis.m_hButton, "ANCHOR_RIGHT" )
			
			-- Set ToolTip Text
			local iSpellPoints = CLClient:GetFreeSpellPoints()
			local iTalentPoints = CLClient:GetFreeTalentPoints()
			local iGlyphMajorSlots = CLClient:GetFreeGlyphMajorSlots()
			local iGlyphMinorSlots = CLClient:GetFreeGlyphMinorSlots()

			hToolTip:AddLine( "Spell/Talent/Glyph Manager", NORMAL_FONT_COLOR )
			hToolTip:AddLine( "Left Click : Open UI", HIGHLIGHT_FONT_COLOR )
			hToolTip:AddLine( "Right Click : Drag Button", HIGHLIGHT_FONT_COLOR )
			if ( iSpellPoints > 0 or iTalentPoints > 0 ) then
				hToolTip:AddLine( "Ability Points : " .. iSpellPoints .. " SP / " .. iTalentPoints .. " TP", GREEN_FONT_COLOR )
			end
			if ( iGlyphMajorSlots > 0 or iGlyphMinorSlots > 0 ) then
				hToolTip:AddLine( "Glyphs Slots : " .. iGlyphMajorSlots .. " Major / " .. iGlyphMinorSlots .. " Minor", GREEN_FONT_COLOR )
			end
			
			-- Show tooltip
            hToolTip:Show()
        end
    )
	
	-- Event : OnLeave
    self.m_hButton:SetScript( "OnLeave",
        function()
			-- Hide tooltip
            CLClient:GetMainToolTip():Hide()
        end
    )
	
	-- Event : OnClick
	self.m_hButton:SetScript( "OnClick",
        function()
			CLClient:GetMainFrame():Toggle()
        end
    )
	
	print( "CLMainButton Initialized !" )
end


