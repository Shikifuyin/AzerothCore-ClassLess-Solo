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

-------------------------------------------------------------------------------------------------------------------
-- Client / Server Setup

-- Client-side Only !
if AIO.AddAddon() then
	return
end

-------------------------------------------------------------------------------------------------------------------
-- Constants

-------------------------------------------------------------------------------------------------------------------
-- ClassLessMainFrame - Declaration
ClassLessMainFrame = class({
	-- Static Members
})

function ClassLessMainFrame:init()
	-- Members
	self.m_iWidth = 804
	self.m_iHeight = 688
	self.m_strPositionAnchor = "CENTER"
	self.m_iPositionX = 0
	self.m_iPositionY = 0
	
	self.m_iTabButtonsSpacing = 16
	self.m_iTabButtonsSize = 40
		
	self.m_hFrame = nil
	
	self.m_hMainPointsFrame = nil
	self.m_hMainButtonsFrame = nil
	
	self.m_iCurrentTabIndex = 0
	self.m_arrTabButtons = {}

	self.m_iCurrentClassIndex = 0
	self.m_arrClassButtons = {}

	self.m_arrSpellTabFrames = {}
	self.m_arrTalentTabFrames = {}
	self.m_arrGlyphTabFrames = {}
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessMainFrame : Methods
function ClassLessMainFrame:Toggle()
	if ( self.m_hFrame == nil ) then
		return
	end

	if ( not self.m_hFrame:IsVisible() ) then
		self.m_hFrame:Show()
	elseif self.m_hFrame:IsVisible() then
		self.m_hFrame:Hide()
	end
end

function ClassLessMainFrame:SwitchTab( iTabIndex, iClassIndex )
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

function ClassLessMainFrame:Update()
	-- Update Points Frame
	self.m_hMainPointsFrame:Update()

	-- Update Buttons Frame
	self.m_hMainButtonsFrame:Update()
	
	-- Update SpellTab/TalentTab/GlyphTab Frames
	for iClassIndex = 1, CLClassCount do
		self.m_arrSpellTabFrames[iClassIndex]:Update()
		self.m_arrTalentTabFrames[iClassIndex]:Update()
		self.m_arrGlyphTabFrames[iClassIndex]:Update()
	end
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessMainFrame : Initialization
function ClassLessMainFrame:Initialize()
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
	
	tinsert( UISpecialFrames, self.m_hFrame:GetName() ) -- Makes it closable with Esc key !
	
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
	
	-- Spell/Talent Points / Glyph Slots
	self.m_hMainPointsFrame = ClassLessMainPointsFrame()
	self.m_hMainPointsFrame:Initialize( self.m_hFrame )
	
	-- Apply/Cancel/Reset Buttons
	self.m_hMainButtonsFrame = ClassLessMainButtonsFrame()
	self.m_hMainButtonsFrame:Initialize( self.m_hFrame )
	
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
				local hToolTip = CLClient:GetMainToolTip()
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
				CLClient:GetMainToolTip():Hide()
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
	arrNames = {
		"CLClassTabButtonDeathKnight", "CLClassTabButtonDruid", "CLClassTabButtonHunter", "CLClassTabButtonMage", "CLClassTabButtonPaladin",
		"CLClassTabButtonPriest", "CLClassTabButtonRogue", "CLClassTabButtonShaman", "CLClassTabButtonWarlock", "CLClassTabButtonWarrior"
	}
	local arrClassNames = { "Death Knight", "Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior" }
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
		self.m_arrClassButtons[i] = CreateFrame( "Button", arrNames[i], self.m_hFrame )
	
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
		self.m_arrClassButtons[i].background:SetTexture( "Interface\\GLUES\\CharacterCreate\\UI-CharacterCreate-Classes" )
		self.m_arrClassButtons[i].background:SetTexCoord( arrTexCoords[i][1], arrTexCoords[i][2], arrTexCoords[i][3], arrTexCoords[i][4] )
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
				local hToolTip = CLClient:GetMainToolTip()
				hToolTip:SetOwner( hThis.m_arrClassButtons[i], "ANCHOR_RIGHT" )

				-- Set Text
				hToolTip:AddLine( arrClassNames[i], HIGHLIGHT_FONT_COLOR )
				
				-- Show tooltip
				hToolTip:Show()
			end
		)
		
		-- Event : OnLeave
		self.m_arrClassButtons[i]:SetScript( "OnLeave",
			function()
				-- Hide tooltip
				CLClient:GetMainToolTip():Hide()
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
		self.m_arrSpellTabFrames[iClassIndex] = ClassLessSpellTabFrame()
		self.m_arrSpellTabFrames[iClassIndex]:Initialize( self.m_hFrame, iClassIndex )
		
		self.m_arrTalentTabFrames[iClassIndex] = ClassLessTalentTabFrame()
		self.m_arrTalentTabFrames[iClassIndex]:Initialize( self.m_hFrame, iClassIndex )
		
		self.m_arrGlyphTabFrames[iClassIndex] = ClassLessGlyphTabFrame()
		self.m_arrGlyphTabFrames[iClassIndex]:Initialize( self.m_hFrame, iClassIndex )
	end
	
	print( "CLMainFrame Initialized !" )
end

