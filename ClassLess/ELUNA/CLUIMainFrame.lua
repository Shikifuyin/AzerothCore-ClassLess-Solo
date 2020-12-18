-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess Client UI : Main Frame
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Requirements
local AIO = AIO or require("AIO")
if not class then require("class") end
if not CLClient then require("CLClient") end
if not CLUITabFrameSpells then require("CLUITabFrameSpells") end
if not CLUITabFrameTalents then require("CLUITabFrameTalents") end
if not CLUITabFrameGlyphs then require("CLUITabFrameGlyphs") end

-------------------------------------------------------------------------------------------------------------------
-- Client / Server Setup

-- Client-side Only !
if AIO.AddAddon() then
	return
end

-------------------------------------------------------------------------------------------------------------------
-- Constants

-------------------------------------------------------------------------------------------------------------------
-- CLUIMainFrame - Declaration
CLUIMainFrame = class({
	-- Static Members
})

function CLUIMainFrame:init()
	-- Members
	self.m_iWidth = 804
	self.m_iHeight = 688
	self.m_strPositionAnchor = "CENTER"
	self.m_iPositionX = 0
	self.m_iPositionY = 0
	
	self.m_hFrame = nil
	
	self.m_iPointsFrameWidth = 400
	self.m_iPointsFrameHeight = 32
	self.m_hPointsTextColor = NORMAL_FONT_COLOR
	
	self.m_hPointsText = nil
	
	self.m_iButtonsFrameWidth = 202
	self.m_iButtonsFrameHeight = 32
	
	self.m_iButtonsSpacing = 10
	self.m_iButtonsWidth = math.floor( (self.m_iButtonsFrameWidth - 4 * self.m_iButtonsSpacing) / 3 )
	
	self.m_hApplyButton = nil
	self.m_hCancelButton = nil
	self.m_hResetButton = nil
	
	self.m_iTabButtonsSpacing = 8
	self.m_iTabButtonsSize = 40
	
	self.m_iCurrentTabIndex = 0
	self.m_arrTabButtons = {}

	self.m_iCurrentClassIndex = 0
	self.m_arrClassButtons = {}

	self.m_arrSpellTabFrames = {}
	self.m_arrTalentTabFrames = {}
	self.m_arrGlyphTabFrames = {}
end

-------------------------------------------------------------------------------------------------------------------
-- CLUIMainFrame : Methods
function CLUIMainFrame:Toggle()
	if ( not self.m_hFrame:IsVisible() ) then
		self.m_hFrame:Show()
	elseif self.m_hFrame:IsVisible() then
		self.m_hFrame:Hide()
	end
end

function CLUIMainFrame:SwitchTab( iTabIndex, iClassIndex )
	if ( iTabIndex <= 0 or iTabIndex > 3 ) then
		return
	end
	if ( iClassIndex <= 0 or iClassIndex > CLClassCount ) then
		return
	end
	
	self.m_arrTabButtons[self.m_iCurrentTabIndex]:SetButtonState( "NORMAL" )
	self.m_arrClassButtons[self.m_iCurrentClassIndex]:SetButtonState( "NORMAL" )
	
	self.m_arrTabButtons[iTabIndex]:SetButtonState( "PUSHED", true )
	self.m_arrClassButtons[iClassIndex]:SetButtonState( "PUSHED", true )
	
	if ( self.m_iCurrentTabIndex == 1 ) then
		self.m_arrSpellTabFrames[self.m_iCurrentClassIndex]:Hide()
	elseif ( self.m_iCurrentTabIndex == 2 ) then
		self.m_arrTalentTabFrames[self.m_iCurrentClassIndex]:Hide()
	elseif ( self.m_iCurrentTabIndex == 3 ) then
		self.m_arrGlyphTabFrames[self.m_iCurrentClassIndex]:Hide()
	end
	
	if ( iTabIndex == 1 ) then
		self.m_arrSpellTabFrames[iClassIndex]:Show()
	elseif ( iTabIndex == 2 ) then
		self.m_arrTalentTabFrames[iClassIndex]:Show()
	elseif ( iTabIndex == 3 ) then
		self.m_arrGlyphTabFrames[iClassIndex]:Show()
	end
	
	self.m_iCurrentTabIndex = iTabIndex
	self.m_iCurrentClassIndex = iClassIndex
end

function CLUIMainFrame:Update()
	-- Update Points Frame
	local hClient = CLClient:GetInstance()
	local iSpellPoints = hClient:GetRemainingSpellPoints()
	local iPetSpellPoints = hClient:GetRemainingPetSpellPoints()
	local iTalentPoints = hClient:GetRemainingTalentPoints()
	local iPetTalentPoints = hClient:GetRemainingPetTalentPoints()
	local iGlyphMajorSlots = hClient:GetRemainingGlyphMajorSlots()
	local iGlyphMinorSlots = hClient:GetRemainingGlyphMinorSlots()
	
	self.m_hPointsText:SetText(
		"Remaining : " ..
		iSpellPoints .. " SP / " ..
		iTalentPoints .. " TP / " ..
		iPetSpellPoints .. " PSP / " ..
		iPetTalentPoints .. " PTP / " ..
		iGlyphMajorSlots .. " Major / " ..
		iGlyphMinorSlots .. " Minor"
	)

	-- Update Buttons Frame
	-- Nothing to do ... for now ...
	
	-- Update Spell/Talent/Glyph TabFrames
	for iClassIndex = 1, CLClassCount do
		self.m_arrSpellTabFrames[iClassIndex]:Update()
		self.m_arrTalentTabFrames[iClassIndex]:Update()
		self.m_arrGlyphTabFrames[iClassIndex]:Update()
	end
end

-------------------------------------------------------------------------------------------------------------------
-- CLUIMainFrame : Initialization
function CLUIMainFrame:Initialize()
	if ( self.m_hFrame ~= nil ) then
		return
	end
	local hThis = self
	
	-- Create Frame, Start Hidden
	self.m_hFrame = CreateFrame( "Frame", "CLMainFrame", UIParent )
	self.m_hFrame:Hide()
	
	-- Size & Position
	self.m_hFrame:SetSize( self.m_iWidth, self.m_iHeight )
	self.m_hFrame:SetPoint( self.m_strPositionAnchor, UIParent, self.m_strPositionAnchor, self.m_iPositionX, self.m_iPositionY )
	
	AIO.SavePosition( self.m_hFrame )
	
	-- Properties
	self.m_hFrame:SetToplevel( true )
	self.m_hFrame:SetMovable( true )
	self.m_hFrame:SetClampedToScreen( true )
    self.m_hFrame:EnableMouse( true )
	
	table.insert( UISpecialFrames, self.m_hFrame:GetName() ) -- Makes it closable with Esc key !
	
	-- Backdrop
	self.m_hFrame:SetBackdrop({
		bgFile = "Interface/AchievementFrame/UI-Achievement-StatsBackground",
		edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	
	-- Drag & Drop
	self.m_hFrame:RegisterForDrag( "LeftButton" )
    self.m_hFrame:SetScript( "OnDragStart", self.m_hFrame.StartMoving )
    self.m_hFrame:SetScript( "OnDragStop", self.m_hFrame.StopMovingOrSizing )
	
	-- Event : OnShow
	self.m_hFrame:SetScript( "OnShow",
        function()
			-- Init Tab index if first call
			if ( hThis.m_iCurrentTabIndex == 0 ) then
				hThis.m_iCurrentTabIndex = 1
			end
			if ( hThis.m_iCurrentClassIndex == 0 ) then
				hThis.m_iCurrentClassIndex = 1
			end
			
			-- Select current Tab
			hThis:SwitchTab( hThis.m_iCurrentTabIndex, hThis.m_iCurrentClassIndex )
			
			-- Update
			hThis:Update()
        end
    )
	
	-- Event : OnHide
	self.m_hFrame:SetScript( "OnHide",
        function()
			-- Ensure Drag & Drop ends properly
			hThis.m_hFrame:StopMovingOrSizing()
        end
    )
	
	-- Event : OnUpdate
	self.m_hFrame:SetScript( "OnUpdate",
        function()
			-- Update
			hThis:Update()
        end
    )
	
	-- Points Frame
	self.m_hFrame.pointsframe = CreateFrame( "Frame", "CLPointsFrame", self.m_hFrame )

		-- Size & Position
	self.m_hFrame.pointsframe:SetSize( self.m_iPointsFrameWidth, self.m_iPointsFrameHeight )
	self.m_hFrame.pointsframe:SetPoint( "BOTTOMLEFT", self.m_hFrame, "BOTTOMLEFT", 10, 10 )
	
		-- Text
	self.m_hPointsText = self.m_hFrame.pointsframe:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
	self.m_hPointsText:SetTextColor( self.m_hPointsTextColor.r, self.m_hPointsTextColor.g, self.m_hPointsTextColor.b )
	self.m_hPointsText:SetJustifyV( "MIDDLE" )
	self.m_hPointsText:SetJustifyH( "LEFT" )
    self.m_hPointsText:SetPoint( "CENTER", self.m_hFrame.pointsframe, "CENTER", 0, 0 )
	
	-- Buttons Frame
	self.m_hFrame.buttonsframe = CreateFrame( "Frame", "CLButtonsFrame", self.m_hFrame )
	
		-- Size & Position
	self.m_hFrame.buttonsframe:SetSize( self.m_iButtonsFrameWidth, self.m_iButtonsFrameHeight )
	self.m_hFrame.buttonsframe:SetPoint( "BOTTOMRIGHT", self.m_hFrame, "BOTTOMRIGHT", -10, 10 )
	
	-- Apply Button
	self.m_hApplyButton = CreateFrame( "Button", "CLApplyButton", self.m_hFrame.buttonsframe )
	
		-- Size & Position
	self.m_hApplyButton:SetSize( self.m_iButtonsWidth, self.m_iButtonsFrameHeight )
	self.m_hApplyButton:SetPoint( "LEFT", self.m_hFrame.buttonsframe, "LEFT", self.m_iButtonsSpacing, 0 )
	
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
				CLClient:GetInstance():ApplyAbilities()
			end
		end
	)
	
	-- Cancel Button
	self.m_hCancelButton = CreateFrame( "Button", "CLCancelButton", self.m_hFrame.buttonsframe )
	
		-- Size & Position
	self.m_hCancelButton:SetSize( self.m_iButtonsWidth, self.m_iButtonsFrameHeight )
	self.m_hCancelButton:SetPoint( "LEFT", self.m_hFrame.buttonsframe, "LEFT", self.m_iButtonsWidth + 2 * self.m_iButtonsSpacing, 0 )
	
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
				CLClient:GetInstance():CancelAbilities()
			end
		end
	)
	
	-- Reset Button
	self.m_hResetButton = CreateFrame( "Button", "CLResetButton", self.m_hFrame.buttonsframe )
	
		-- Size & Position
	self.m_hResetButton:SetSize( self.m_iButtonsWidth, self.m_iButtonsFrameHeight )
	self.m_hResetButton:SetPoint( "LEFT", self.m_hFrame.buttonsframe, "LEFT", 2 * self.m_iButtonsWidth + 3 * self.m_iButtonsSpacing, 0 )
	
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
			CLClient:GetInstance():ResetAbilities()
        end,
        OnShow = function( self )
			MoneyFrame_Update( self.moneyFrame, CLClient:GetInstance():GetResetCost() )
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        hasMoneyFrame = 1,
        preferredIndex = 3
    }
	
	-- Tabs Buttons
	local arrNames = { "CLSpellTabButton", "CLTalentTabButton", "CLGlyphTabButton" }
	local arrToolTipTexts = { "Spell Manager", "Talent Manager", "Glyph Manager" }
	local arrTextures = { "Interface\\Icons\\INV_Misc_Book_07", "Interface\\Icons\\INV_Misc_Book_11", "Interface\\Icons\\INV_Misc_Book_10" }
	
	for i = 1, 3 do
		-- Tab Button
		self.m_arrTabButtons[i] = CreateFrame( "Button", arrNames[i], self.m_hFrame )
	
		-- Size & Position
		local iButtonX = 10 + self.m_iTabButtonsSpacing + (i-1) * (self.m_iTabButtonsSpacing + self.m_iTabButtonsSize)
		local iButtonY = 10 + (self.m_iTabButtonsSpacing / 2)
		
		self.m_arrTabButtons[i]:SetSize( self.m_iTabButtonsSize, self.m_iTabButtonsSize )
		self.m_arrTabButtons[i]:SetPoint( "TOPLEFT", self.m_hFrame, "TOPLEFT", iButtonX, -iButtonY )
		
		-- Fonts
		self.m_arrTabButtons[i]:SetNormalFontObject( GameFontNormal )
		self.m_arrTabButtons[i]:SetHighlightFontObject( GameFontHighlight )
		self.m_arrTabButtons[i]:SetDisabledFontObject( GameFontDisable )

		-- Textures
		self.m_arrTabButtons[i].background = self.m_arrTabButtons[i]:CreateTexture( nil, "BACKGROUND" )
		self.m_arrTabButtons[i].background:SetTexture( arrTextures[i] )
		self.m_arrTabButtons[i].background:SetSize( self.m_iTabButtonsSize, self.m_iTabButtonsSize )
		self.m_arrTabButtons[i].background:SetAllPoints( self.m_arrTabButtons[i] )
		
		self.m_arrTabButtons[i].overlay = self.m_arrTabButtons[i]:CreateTexture( nil, "OVERLAY" )
		self.m_arrTabButtons[i].overlay:SetTexture( "Interface\\AchievementFrame\\UI-Achievement-IconFrame" )
		self.m_arrTabButtons[i].overlay:SetTexCoord( 0, 0.5, 0, 0.5 )
		self.m_arrTabButtons[i].overlay:SetSize( self.m_iTabButtonsSize * 1.2, self.m_iTabButtonsSize * 1.2 )
		self.m_arrTabButtons[i].overlay:SetPoint( "TOPLEFT", self.m_arrTabButtons[i], "TOPLEFT", -6, 6 )
		self.m_arrTabButtons[i]:SetPushedTexture( self.m_arrTabButtons[i].overlay )
		
		-- Event : OnEnter
		self.m_arrTabButtons[i]:SetScript( "OnEnter",
			function()
				-- Attach ToolTip to Button Frame
				local hToolTip = CLClient:GetInstance():GetToolTip()
				hToolTip:SetOwner( hThis.m_arrTabButtons[i], "ANCHOR_RIGHT" )

				-- Set Text
				hToolTip:AddLine( arrToolTipTexts[i], HIGHLIGHT_FONT_COLOR )
				
				-- Show tooltip
				hToolTip:Show()
			end
		)
		
		-- Event : OnLeave
		self.m_arrTabButtons[i]:SetScript( "OnLeave",
			function()
				-- Hide tooltip
				CLClient:GetInstance():GetToolTip():Hide()
			end
		)
		
		-- Event : OnClick
		self.m_arrTabButtons[i]:SetScript( "OnClick",
			function()
				hThis:SwitchTab( i, hThis.m_iCurrentClassIndex )
			end
		)
	end

	-- Classes Buttons
	local arrTexCoords = {
		{ 0.25, 0.5, 0.5, 0.75 },
		{ 0.75, 1, 0, 0.25 },
		{ 0, 0.25, 0.25, 0.5 },
		{ 0.25, 0.5, 0, 0.25 },
		{ 0, 0.25, 0.5, 0.75 },
		{ 0.5, 0.75, 0.25, 0.5 },
		{ 0.5, 0.75, 0, 0.25 },
		{ 0.25, 0.5, 0.25, 0.5 },
		{ 0.75, 1, 0.25, 0.5 },
		{ 0, 0.25, 0, 0.25 }
	}
	
	for i = 1, CLClassCount do
		-- Tab Button
		local strName = "CLClassTabButton" .. CLClassNames[i]
		self.m_arrClassButtons[i] = CreateFrame( "Button", strName, self.m_hFrame )
	
		-- Size & Position
		local iButtonX = 10 + self.m_iTabButtonsSpacing + (CLClassCount - i) * (self.m_iTabButtonsSpacing + self.m_iTabButtonsSize)
		local iButtonY = 10 + (self.m_iTabButtonsSpacing / 2)
		
		self.m_arrClassButtons[i]:SetSize( self.m_iTabButtonsSize, self.m_iTabButtonsSize )
		self.m_arrClassButtons[i]:SetPoint( "TOPRIGHT", self.m_hFrame, "TOPRIGHT", -iButtonX, -iButtonY )
		
		-- Fonts
		self.m_arrClassButtons[i]:SetNormalFontObject( GameFontNormal )
		self.m_arrClassButtons[i]:SetHighlightFontObject( GameFontHighlight )
		self.m_arrClassButtons[i]:SetDisabledFontObject( GameFontDisable )
		
		-- Textures
		self.m_arrClassButtons[i].background = self.m_arrClassButtons[i]:CreateTexture( nil, "BACKGROUND" )
		if ( i == CLClassCount ) then
			self.m_arrClassButtons[i].background:SetTexture( "Interface\\Icons\\Ability_Hunter_AspectMastery" )
		else
			self.m_arrClassButtons[i].background:SetTexture( "Interface\\GLUES\\CharacterCreate\\UI-CharacterCreate-Classes" )
			self.m_arrClassButtons[i].background:SetTexCoord( arrTexCoords[i][1], arrTexCoords[i][2], arrTexCoords[i][3], arrTexCoords[i][4] )
		end
		self.m_arrClassButtons[i].background:SetSize( self.m_iTabButtonsSize, self.m_iTabButtonsSize )
		self.m_arrClassButtons[i].background:SetAllPoints( self.m_arrClassButtons[i] )
		
		self.m_arrClassButtons[i].overlay = self.m_arrClassButtons[i]:CreateTexture( nil, "OVERLAY" )
		self.m_arrClassButtons[i].overlay:SetTexture( "Interface\\AchievementFrame\\UI-Achievement-IconFrame" )
		self.m_arrClassButtons[i].overlay:SetTexCoord( 0, 0.5, 0, 0.5 )
		self.m_arrClassButtons[i].overlay:SetSize( self.m_iTabButtonsSize * 1.2, self.m_iTabButtonsSize * 1.2 )
		self.m_arrClassButtons[i].overlay:SetPoint( "TOPLEFT", self.m_arrClassButtons[i], "TOPLEFT", -6, 6 )
		self.m_arrClassButtons[i]:SetPushedTexture( self.m_arrClassButtons[i].overlay )
		
		-- Event : OnEnter
		self.m_arrClassButtons[i]:SetScript( "OnEnter",
			function()
				-- Attach ToolTip to Button Frame
				local hToolTip = CLClient:GetInstance():GetToolTip()
				hToolTip:SetOwner( hThis.m_arrClassButtons[i], "ANCHOR_RIGHT" )

				-- Set Text
				hToolTip:AddLine( CLClassNames[i], HIGHLIGHT_FONT_COLOR )
				
				-- Show tooltip
				hToolTip:Show()
			end
		)
		
		-- Event : OnLeave
		self.m_arrClassButtons[i]:SetScript( "OnLeave",
			function()
				-- Hide tooltip
				CLClient:GetInstance():GetToolTip():Hide()
			end
		)
		
		-- Event : OnClick
		self.m_arrClassButtons[i]:SetScript( "OnClick",
			function()
				hThis:SwitchTab( hThis.m_iCurrentTabIndex, i )
			end
		)
	end
	
	-- SpellTab/TalentTab/GlyphTab Frames
	for iClassIndex = 1, CLClassCount do
		self.m_arrSpellTabFrames[iClassIndex] = CLUITabFrameSpells()
		self.m_arrSpellTabFrames[iClassIndex]:Initialize( self.m_hFrame, iClassIndex )
		
		self.m_arrTalentTabFrames[iClassIndex] = CLUITabFrameTalents()
		self.m_arrTalentTabFrames[iClassIndex]:Initialize( self.m_hFrame, iClassIndex )
		
		self.m_arrGlyphTabFrames[iClassIndex] = CLUITabFrameGlyphs()
		self.m_arrGlyphTabFrames[iClassIndex]:Initialize( self.m_hFrame, iClassIndex )
	end
	
	print( "CLUIMainFrame Initialized !" )
end

