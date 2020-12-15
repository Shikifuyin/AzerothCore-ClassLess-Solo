-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess Client UI : Main Buttons Frame
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
-- ClassLessMainButtonsFrame - Declaration
ClassLessMainButtonsFrame = class({
	-- Static Members
})

function ClassLessMainButtonsFrame:init()
	-- Members
	self.m_iWidth = 202
	self.m_iHeight = 32
	self.m_strPositionAnchor = "BOTTOMRIGHT"
	self.m_iPositionX = -10
	self.m_iPositionY = 10
	
	self.m_hFrame = nil
	
	self.m_iButtonSpacing = 10
	self.m_iButtonWidth = math.floor( (self.m_iWidth - 4 * self.m_iButtonSpacing) / 3 )
	
	self.m_hApplyButton = nil
	self.m_hCancelButton = nil
	self.m_hResetButton = nil
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessMainButtonsFrame : Methods
function ClassLessMainButtonsFrame:Update()
	-- Update Enabled / Disabled Buttons here ...
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessMainButtonsFrame : Initialization
function ClassLessMainButtonsFrame:Initialize( hParentFrame )
	if ( self.m_hFrame ~= nil ) then
		return
	end
	local hThis = self
	
	-- Create Frame
	self.m_hFrame = CreateFrame( "Frame", "CLMainButtonsFrame", hParentFrame )
	
	-- Size & Position
	self.m_hFrame:SetSize( self.m_iWidth, self.m_iHeight )
	self.m_hFrame:SetPoint( self.m_strPositionAnchor, hParentFrame, self.m_strPositionAnchor, self.m_iPositionX, self.m_iPositionY )
	
	-- Apply Button
	self.m_hApplyButton = CreateFrame( "Button", "CLApplyButton", self.m_hFrame )
	
		-- Size & Position
	self.m_hApplyButton:SetSize( self.m_iButtonWidth, self.m_iHeight )
	self.m_hApplyButton:SetPoint( "LEFT", self.m_hFrame, "LEFT", self.m_iButtonSpacing, 0 )
	
		-- Fonts
	self.m_hApplyButton:SetNormalFontObject( GameFontNormal )
	self.m_hApplyButton:SetHighlightFontObject( GameFontHighlight )
	self.m_hApplyButton:SetDisabledFontObject( GameFontDisable )
	
		-- Text
	self.m_hApplyButton:SetText( "Apply" )
	
		-- Textures
	self.m_hApplyButton.textureNormal = self.m_hApplyButton:CreateTexture()
	self.m_hApplyButton.textureNormal:SetTexture( "Interface\\Buttons\\UI-Panel-Button-Up" )
	self.m_hApplyButton.textureNormal:SetTexCoord( 0, 0.625, 0, 0.6875 )
	self.m_hApplyButton.textureNormal:SetAllPoints( self.m_hApplyButton )
	self.m_hApplyButton:SetNormalTexture( self.m_hApplyButton.textureNormal )
	
	self.m_hApplyButton.texturePushed = self.m_hApplyButton:CreateTexture()
	self.m_hApplyButton.texturePushed:SetTexture( "Interface\\Buttons\\UI-Panel-Button-Down" )
	self.m_hApplyButton.texturePushed:SetTexCoord( 0, 0.625, 0, 0.6875 )
	self.m_hApplyButton.texturePushed:SetAllPoints( self.m_hApplyButton )
	self.m_hApplyButton:SetPushedTexture( self.m_hApplyButton.texturePushed )
	
	self.m_hApplyButton.textureHighlight = self.m_hApplyButton:CreateTexture()
	self.m_hApplyButton.textureHighlight:SetTexture( "Interface\\Buttons\\UI-Panel-Button-Highlight" )
	self.m_hApplyButton.textureHighlight:SetTexCoord( 0, 0.625, 0, 0.6875 )
	self.m_hApplyButton.textureHighlight:SetAllPoints( self.m_hApplyButton )
	self.m_hApplyButton:SetHighlightTexture( self.m_hApplyButton.textureHighlight )
	
		-- Event : OnClick
	self.m_hApplyButton:SetScript( "OnClick",
		function()
			if hThis.m_hApplyButton:IsEnabled() then
				CLClient:ApplyAbilities()
			end
		end
	)
	
	-- Cancel Button
	self.m_hCancelButton = CreateFrame( "Button", "CLCancelButton", self.m_hFrame )
	
		-- Size & Position
	self.m_hCancelButton:SetSize( self.m_iButtonWidth, self.m_iHeight )
	self.m_hCancelButton:SetPoint( "LEFT", self.m_hFrame, "LEFT", self.m_iButtonWidth + 2 * self.m_iButtonSpacing, 0 )
	
		-- Fonts
	self.m_hCancelButton:SetNormalFontObject( GameFontNormal )
	self.m_hCancelButton:SetHighlightFontObject( GameFontHighlight )
	self.m_hCancelButton:SetDisabledFontObject( GameFontDisable )
	
		-- Text
	self.m_hCancelButton:SetText( "Cancel" )
	
		-- Textures
	self.m_hCancelButton.textureNormal = self.m_hCancelButton:CreateTexture()
	self.m_hCancelButton.textureNormal:SetTexture( "Interface\\Buttons\\UI-Panel-Button-Up" )
	self.m_hCancelButton.textureNormal:SetTexCoord( 0, 0.625, 0, 0.6875 )
	self.m_hCancelButton.textureNormal:SetAllPoints( self.m_hCancelButton )
	self.m_hCancelButton:SetNormalTexture( self.m_hCancelButton.textureNormal )
	
	self.m_hCancelButton.texturePushed = self.m_hCancelButton:CreateTexture()
	self.m_hCancelButton.texturePushed:SetTexture( "Interface\\Buttons\\UI-Panel-Button-Down" )
	self.m_hCancelButton.texturePushed:SetTexCoord( 0, 0.625, 0, 0.6875 )
	self.m_hCancelButton.texturePushed:SetAllPoints( self.m_hCancelButton )
	self.m_hCancelButton:SetPushedTexture( self.m_hCancelButton.texturePushed )
	
	self.m_hCancelButton.textureHighlight = self.m_hCancelButton:CreateTexture()
	self.m_hCancelButton.textureHighlight:SetTexture( "Interface\\Buttons\\UI-Panel-Button-Highlight" )
	self.m_hCancelButton.textureHighlight:SetTexCoord( 0, 0.625, 0, 0.6875 )
	self.m_hCancelButton.textureHighlight:SetAllPoints( self.m_hCancelButton )
	self.m_hCancelButton:SetHighlightTexture( self.m_hCancelButton.textureHighlight )
	
		-- Event : OnClick
	self.m_hCancelButton:SetScript( "OnClick",
		function()
			if hThis.m_hCancelButton:IsEnabled() then
				CLClient:CancelAbilities()
			end
		end
	)
	
	-- Reset Button
	self.m_hResetButton = CreateFrame( "Button", "CLResetButton", self.m_hFrame )
	
		-- Size & Position
	self.m_hResetButton:SetSize( self.m_iButtonWidth, self.m_iHeight )
	self.m_hResetButton:SetPoint( "LEFT", self.m_hFrame, "LEFT", 2 * self.m_iButtonWidth + 3 * self.m_iButtonSpacing, 0 )
	
		-- Fonts
	self.m_hResetButton:SetNormalFontObject( GameFontNormal )
	self.m_hResetButton:SetHighlightFontObject( GameFontHighlight )
	self.m_hResetButton:SetDisabledFontObject( GameFontDisable )
	
		-- Text
	self.m_hResetButton:SetText( "Reset" )
	
		-- Textures
	self.m_hResetButton.textureNormal = self.m_hResetButton:CreateTexture()
	self.m_hResetButton.textureNormal:SetTexture( "Interface\\Buttons\\UI-Panel-Button-Up" )
	self.m_hResetButton.textureNormal:SetTexCoord( 0, 0.625, 0, 0.6875 )
	self.m_hResetButton.textureNormal:SetAllPoints( self.m_hResetButton )
	self.m_hResetButton:SetNormalTexture( self.m_hResetButton.textureNormal )
	
	self.m_hResetButton.texturePushed = self.m_hResetButton:CreateTexture()
	self.m_hResetButton.texturePushed:SetTexture( "Interface\\Buttons\\UI-Panel-Button-Down" )
	self.m_hResetButton.texturePushed:SetTexCoord( 0, 0.625, 0, 0.6875 )
	self.m_hResetButton.texturePushed:SetAllPoints( self.m_hResetButton )
	self.m_hResetButton:SetPushedTexture( self.m_hResetButton.texturePushed )
	
	self.m_hResetButton.textureHighlight = self.m_hResetButton:CreateTexture()
	self.m_hResetButton.textureHighlight:SetTexture( "Interface\\Buttons\\UI-Panel-Button-Highlight" )
	self.m_hResetButton.textureHighlight:SetTexCoord( 0, 0.625, 0, 0.6875 )
	self.m_hResetButton.textureHighlight:SetAllPoints( self.m_hResetButton )
	self.m_hResetButton:SetHighlightTexture( self.m_hResetButton.textureHighlight )
	
		-- Event : OnClick
	self.m_hResetButton:SetScript( "OnClick",
		function()
			if hThis.m_hResetButton:IsEnabled() then
				StaticPopup_Show( "RESET_ALL_ABILITIES" )
			end
		end
	)
	
		-- Confirm Dialog
    StaticPopupDialogs["RESET_ALL_ABILITIES"] = {
        text = "ALL your Spells and Talents will be reset ! Are you sure ?",
        button1 = YES,
        button2 = NO,
        OnAccept = function()
			print( "Calling ResetAbilities ..." )
			CLClient:ResetAbilities()
        end,
        OnShow = function( self )
			MoneyFrame_Update( self.moneyFrame, CLClient:GetResetCost() )
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        hasMoneyFrame = 1,
        preferredIndex = 3
    }
	
	print( "CLMainButtonsFrame Initialized !" )
end



