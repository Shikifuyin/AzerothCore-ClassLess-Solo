-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess Client UI : Glyph Tab Frame
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Requirements
local AIO = AIO or require("AIO")
if not class then require("class") end
if not CLClient then require("CLClient") end

-------------------------------------------------------------------------------------------------------------------
-- Client / Server Setup

-- Client-side Only !
if AIO.AddAddon() then
	return
end

-------------------------------------------------------------------------------------------------------------------
-- Constants

-------------------------------------------------------------------------------------------------------------------
-- CLUITabFrameGlyphs - Declaration
CLUITabFrameGlyphs = class({
	-- Static Members
})

function CLUITabFrameGlyphs:init()
	-- Members
	self.m_iGlyphButtonsSpacing = 8
	self.m_iGlyphButtonsPerRow = 5
	self.m_iGlyphButtonsSize = 40
	
	self.m_iSpecAreaTitleHeight = 32
	
	self.m_iSpecAreaSpacing = 10
	self.m_iSpecAreaWidth = self.m_iGlyphButtonsSize * self.m_iGlyphButtonsPerRow + self.m_iGlyphButtonsSpacing * (self.m_iGlyphButtonsPerRow + 1)
	self.m_iSpecAreaHeight = self.m_iGlyphButtonsSize * 11 + self.m_iGlyphButtonsSpacing * 12 + self.m_iSpecAreaTitleHeight
	
	self.m_iWidth = self.m_iSpecAreaWidth * CLClassSpecCount + self.m_iSpecAreaSpacing * (CLClassSpecCount + 1)
	self.m_iHeight = self.m_iSpecAreaHeight
	self.m_strPositionAnchor = "BOTTOM"
	self.m_iPositionX = 0
	self.m_iPositionY = 42
	
	self.m_hFrame = nil
	
	self.m_iClassIndex = 0
	self.m_arrSpecFrames = nil
	self.m_arrGlyphButtons = nil
end

-------------------------------------------------------------------------------------------------------------------
-- CLUITabFrameGlyphs : Getters / Setters

-------------------------------------------------------------------------------------------------------------------
-- CLUITabFrameGlyphs : Methods
function CLUITabFrameGlyphs:Show()
	if ( not self.m_hFrame:IsVisible() ) then
		self.m_hFrame:Show()
	end
end
function CLUITabFrameGlyphs:Hide()
	if self.m_hFrame:IsVisible() then
		self.m_hFrame:Hide()
	end
end

function CLUITabFrameGlyphs:UpdateButton( iSpecIndex, iGlyphIndex )
	-- Get Client Instance
	local hClient = CLClient:GetInstance()
	
	-- Get Glyph Desc
	local hGlyphDesc = CLDataGlyphs:GetInstance():GetGlyphDesc( self.m_iClassIndex, iSpecIndex, iGlyphIndex )

	-- Get State
	local bKnown = hClient:GetKnownGlyphs():HasGlyph( self.m_iClassIndex, iSpecIndex, iGlyphIndex )
	local bPending = hClient:GetPendingGlyphs():HasGlyph( self.m_iClassIndex, iSpecIndex, iGlyphIndex )
	local bCanLearn = ( UnitLevel("player") >= hGlyphDesc:GetGlyphLevel() )
	
	-- Setup Button State
	if ( not bCanLearn ) then
		self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].background:SetVertexColor( 0.8, 0.2, 0.2 )
		self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].background:SetDesaturated( false )
		self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].overlay:Hide()
	else
		self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].background:SetVertexColor( 1.0, 1.0, 1.0 )
		if bKnown then
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].background:SetDesaturated( false )
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].overlay:Show()
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].overlay:SetDesaturated( false )
		elseif bPending then
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].background:SetDesaturated( false )
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].overlay:Show()
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].overlay:SetDesaturated( true )
		else
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].background:SetDesaturated( true )
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].overlay:Hide()
		end
	end
end
function CLUITabFrameGlyphs:Update()
	-- Get Glyphs Data
	local hDataGlyphs = CLDataGlyphs:GetInstance()
	
	-- Enum all Specs
	for iSpecIndex = 1, CLClassSpecCount do
		-- Enum all Glyphs
		local iGlyphCount = hDataGlyphs:GetGlyphCount( self.m_iClassIndex, iSpecIndex )
		for iGlyphIndex = 1, iGlyphCount do
			-- Update State
			self:UpdateButton( iSpecIndex, iGlyphIndex )
		end
	end
end

-------------------------------------------------------------------------------------------------------------------
-- CLUITabFrameGlyphs : Initialization
function CLUITabFrameGlyphs:Initialize( hParentFrame, iClassIndex )
	if ( self.m_hFrame ~= nil ) then
		return
	end
	local hThis = self
	
	-- Save Class Index & Setup arrays
	self.m_iClassIndex = iClassIndex
	self.m_arrSpecFrames = {}
	self.m_arrGlyphButtons = {}
	
	-- Create Frame, Start Hidden
	local strFrameName = "CLGlyphTabFrame_Class" .. self.m_iClassIndex
	self.m_hFrame = CreateFrame( "Frame", strFrameName, hParentFrame )
	self.m_hFrame:Hide()
	
	-- Size & Position
	self.m_hFrame:SetSize( self.m_iWidth, self.m_iHeight )
	self.m_hFrame:SetPoint( self.m_strPositionAnchor, hParentFrame, self.m_strPositionAnchor, self.m_iPositionX, self.m_iPositionY )
	
	-- Event : OnShow
	self.m_hFrame:SetScript( "OnShow",
        function()
			-- Update
			hThis:Update()
        end
    )
	
	-- Event : OnUpdate
	self.m_hFrame:SetScript( "OnUpdate",
        function()
			-- Update
			hThis:Update()
        end
    )
	
	-- Get Glyphs Data
	local hDataGlyphs = CLDataGlyphs:GetInstance()

	-- Enum all Specs
	for iSpecIndex = 1, CLClassSpecCount do
		-- Create SubFrame
		local strSpecFrameName = strFrameName .. "_Spec" .. iSpecIndex
		self.m_arrSpecFrames[iSpecIndex] = CreateFrame( "Frame", strSpecFrameName, self.m_hFrame )
	
		-- Size & Position
		local iSpecX = self.m_iSpecAreaSpacing + (iSpecIndex - 1) * (self.m_iSpecAreaWidth + self.m_iSpecAreaSpacing)
		
		self.m_arrSpecFrames[iSpecIndex]:SetSize( self.m_iSpecAreaWidth, self.m_iSpecAreaHeight )
		self.m_arrSpecFrames[iSpecIndex]:SetPoint( "TOPLEFT", self.m_hFrame, "TOPLEFT", iSpecX, 0 )
		
		-- Textures
		local strTextureBaseName = hDataGlyphs:GetClassSpecTexture( self.m_iClassIndex, iSpecIndex )
		
		self.m_arrSpecFrames[iSpecIndex].backgroundTL = self.m_arrSpecFrames[iSpecIndex]:CreateTexture( nil, "BACKGROUND" )
		self.m_arrSpecFrames[iSpecIndex].backgroundTL:SetTexture( strTextureBaseName .. "-TopLeft" )
		self.m_arrSpecFrames[iSpecIndex].backgroundTL:SetSize( self.m_iSpecAreaWidth * 0.8, self.m_iSpecAreaHeight * 0.8 )
		self.m_arrSpecFrames[iSpecIndex].backgroundTL:SetPoint( "TOPLEFT", self.m_arrSpecFrames[iSpecIndex], "TOPLEFT", 0, 0 )
		
		self.m_arrSpecFrames[iSpecIndex].backgroundTR = self.m_arrSpecFrames[iSpecIndex]:CreateTexture( nil, "BACKGROUND" )
		self.m_arrSpecFrames[iSpecIndex].backgroundTR:SetTexture( strTextureBaseName .. "-TopRight" )
		self.m_arrSpecFrames[iSpecIndex].backgroundTR:SetTexCoord( 0, 0.6875, 0, 1 )
		self.m_arrSpecFrames[iSpecIndex].backgroundTR:SetSize( self.m_iSpecAreaWidth * 0.2, self.m_iSpecAreaHeight * 0.8 )
		self.m_arrSpecFrames[iSpecIndex].backgroundTR:SetPoint( "TOPRIGHT", self.m_arrSpecFrames[iSpecIndex], "TOPRIGHT", 0, 0 )
		
		self.m_arrSpecFrames[iSpecIndex].backgroundBL = self.m_arrSpecFrames[iSpecIndex]:CreateTexture( nil, "BACKGROUND" )
		self.m_arrSpecFrames[iSpecIndex].backgroundBL:SetTexture( strTextureBaseName .. "-BottomLeft" )
		self.m_arrSpecFrames[iSpecIndex].backgroundBL:SetTexCoord( 0, 1, 0, 0.578125 )
		self.m_arrSpecFrames[iSpecIndex].backgroundBL:SetSize( self.m_iSpecAreaWidth * 0.8, self.m_iSpecAreaHeight * 0.2 )
		self.m_arrSpecFrames[iSpecIndex].backgroundBL:SetPoint( "BOTTOMLEFT", self.m_arrSpecFrames[iSpecIndex], "BOTTOMLEFT", 0, 0 )
		
		self.m_arrSpecFrames[iSpecIndex].backgroundBR = self.m_arrSpecFrames[iSpecIndex]:CreateTexture( nil, "BACKGROUND" )
		self.m_arrSpecFrames[iSpecIndex].backgroundBR:SetTexture( strTextureBaseName .. "-BottomRight" )
		self.m_arrSpecFrames[iSpecIndex].backgroundBR:SetTexCoord( 0, 0.6875, 0, 0.578125 )
		self.m_arrSpecFrames[iSpecIndex].backgroundBR:SetSize( self.m_iSpecAreaWidth * 0.2, self.m_iSpecAreaHeight * 0.2 )
		self.m_arrSpecFrames[iSpecIndex].backgroundBR:SetPoint( "BOTTOMRIGHT", self.m_arrSpecFrames[iSpecIndex], "BOTTOMRIGHT", 0, 0 )
		
		-- Backdrop
		self.m_arrSpecFrames[iSpecIndex]:SetBackdrop({
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			edgeSize = 8,
			insets = { left = 0, right = 0, top = 0, bottom = 0 }
		})
		
		-- Spec Title
		self.m_arrSpecFrames[iSpecIndex].title = CreateFrame( "Frame", strSpecFrameName .. "_Title", self.m_arrSpecFrames[iSpecIndex] )
		
		self.m_arrSpecFrames[iSpecIndex].title:SetSize( self.m_iSpecAreaWidth, self.m_iSpecAreaTitleHeight )
		self.m_arrSpecFrames[iSpecIndex].title:SetPoint( "TOPLEFT", self.m_arrSpecFrames[iSpecIndex], "TOPLEFT", 0, 0 )
		
		self.m_arrSpecFrames[iSpecIndex].title.text = self.m_arrSpecFrames[iSpecIndex].title:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
		self.m_arrSpecFrames[iSpecIndex].title.text:SetTextColor( HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b )
		self.m_arrSpecFrames[iSpecIndex].title.text:SetJustifyV( "MIDDLE" )
		self.m_arrSpecFrames[iSpecIndex].title.text:SetJustifyH( "MIDDLE" )
		self.m_arrSpecFrames[iSpecIndex].title.text:SetPoint( "CENTER", self.m_arrSpecFrames[iSpecIndex].title, "CENTER", 0, 0 )
		self.m_arrSpecFrames[iSpecIndex].title.text:SetText( hDataGlyphs:GetClassSpecName(self.m_iClassIndex, iSpecIndex) )
		
		-- Setup Button array
		self.m_arrGlyphButtons[iSpecIndex] = {}
		
		-- Enum all Glyphs
		local iGlyphCount = hDataGlyphs:GetGlyphCount( self.m_iClassIndex, iSpecIndex )
		
		for iGlyphIndex = 1, iGlyphCount do
			-- Get Glyph Desc
			local hGlyphDesc = hDataGlyphs:GetGlyphDesc( self.m_iClassIndex, iSpecIndex, iGlyphIndex )
			
			-- Create Button
			local strButtonName = "CLGlyphButton_Class" .. self.m_iClassIndex .. "_Spec" .. iSpecIndex .. "_Index" .. iGlyphIndex
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex] = CreateFrame( "Button", strButtonName, self.m_arrSpecFrames[iSpecIndex] )
			
			-- Size & Position
			local iRow = math.floor( (iGlyphIndex-1) / self.m_iGlyphButtonsPerRow )
			local iCol = (iGlyphIndex-1) - iRow * self.m_iGlyphButtonsPerRow -- (iGlyphIndex-1) % self.m_iGlyphButtonsPerRow
			local iButtonX = self.m_iGlyphButtonsSpacing + iCol * (self.m_iGlyphButtonsSize + self.m_iGlyphButtonsSpacing)
			local iButtonY = self.m_iGlyphButtonsSpacing + iRow * (self.m_iGlyphButtonsSize + self.m_iGlyphButtonsSpacing) + self.m_iSpecAreaTitleHeight
			
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex]:SetSize( self.m_iGlyphButtonsSize, self.m_iGlyphButtonsSize )
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex]:SetPoint( "TOPLEFT", self.m_arrSpecFrames[iSpecIndex], "TOPLEFT", iButtonX, -iButtonY )
			
			-- Properties
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex]:RegisterForClicks( "LeftButtonDown", "RightButtonDown" )
			
			-- Fonts
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex]:SetNormalFontObject( GameFontNormal )
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex]:SetHighlightFontObject( GameFontHighlight )
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex]:SetDisabledFontObject( GameFontDisable )
			
			-- Textures
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].background = self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex]:CreateTexture( nil, "BACKGROUND" )
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].background:SetTexture( hGlyphDesc:GetIcon() )
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].background:SetSize( self.m_iGlyphButtonsSize, self.m_iGlyphButtonsSize )
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].background:SetAllPoints( self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex] )
			
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].overlay = self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex]:CreateTexture( nil, "OVERLAY" )
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].overlay:SetTexture( "Interface\\AchievementFrame\\UI-Achievement-IconFrame" )
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].overlay:SetTexCoord( 0, 0.5, 0, 0.5 )
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].overlay:SetSize( self.m_iGlyphButtonsSize * 1.2, self.m_iGlyphButtonsSize * 1.2 )
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex].overlay:SetPoint( "TOPLEFT", self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex], "TOPLEFT", -6, 6 )
			
			-- Setup Button State
			hThis:UpdateButton( iSpecIndex, iGlyphIndex )
			
			-- Event : OnEnter
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex]:SetScript( "OnEnter",
				function()
					-- Attach ToolTip to Button Frame
					local hToolTip = CLClient:GetInstance():GetToolTip()
					hToolTip:SetOwner( hThis.m_arrGlyphButtons[iSpecIndex][iGlyphIndex], "ANCHOR_RIGHT" )

					-- Get Glyph Desc
					local hGlyphDesc = hDataGlyphs:GetGlyphDesc( self.m_iClassIndex, iSpecIndex, iGlyphIndex )
					local iGlyphID = hGlyphDesc:GetGlyphID()
					local iGlyphLevel = hGlyphDesc:GetGlyphLevel()
					local bIsMajor = hGlyphDesc:IsMajor()
					local strLink = CLClient:GetInstance():GetAbilityLink( iGlyphID )
					
					-- Build ToolTip
					hToolTip:SetHyperlink( strLink )
					if bIsMajor then
						hToolTip:AddLine( "Major Slot", HIGHLIGHT_FONT_COLOR )
					else
						hToolTip:AddLine( "Minor Slot", HIGHLIGHT_FONT_COLOR )
					end
					hToolTip:AddLine( "Req. Level: " .. iGlyphLevel, HIGHLIGHT_FONT_COLOR )
					hToolTip:AddLine( "SPELLID: " .. iGlyphID, RED_FONT_COLOR )
					
					-- Show tooltip
					hToolTip:Show()
				end
			)
			
			-- Event : OnLeave
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex]:SetScript( "OnLeave",
				function()
					-- Hide tooltip
					CLClient:GetInstance():GetToolTip():Hide()
				end
			)
			
			-- Event : OnClick
			self.m_arrGlyphButtons[iSpecIndex][iGlyphIndex]:SetScript( "OnClick",
				function( self, strMouseButton, bHeldDown )
					-- Add/Remove Pending Glyph
					if ( strMouseButton == "LeftButton" ) then
						CLClient:GetInstance():AddPendingGlyph( hThis.m_iClassIndex, iSpecIndex, iGlyphIndex )
					elseif ( strMouseButton == "RightButton" ) then
						CLClient:GetInstance():RemovePendingGlyph( hThis.m_iClassIndex, iSpecIndex, iGlyphIndex )
					end
					
					-- Update Button State
					hThis:UpdateButton( iSpecIndex, iGlyphIndex )
				end
			)
		end
	end
	
	print( strFrameName .. " Initialized !" )
end



