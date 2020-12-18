-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess Client UI : Spell Tab Frame
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
-- CLUITabFrameSpells - Declaration
CLUITabFrameSpells = class({
	-- Static Members
})

function CLUITabFrameSpells:init()
	-- Members
	self.m_iSpellButtonsSpacing = 8
	self.m_iSpellButtonsPerRow = 5
	self.m_iSpellButtonsSize = 40
	
	self.m_iSpecAreaTitleHeight = 32
	
	self.m_iSpecAreaSpacing = 10
	self.m_iSpecAreaWidth = self.m_iSpellButtonsSize * self.m_iSpellButtonsPerRow + self.m_iSpellButtonsSpacing * (self.m_iSpellButtonsPerRow + 1)
	self.m_iSpecAreaHeight = self.m_iSpellButtonsSize * 11 + self.m_iSpellButtonsSpacing * 12 + self.m_iSpecAreaTitleHeight
	
	self.m_iWidth = self.m_iSpecAreaWidth * CLClassSpecCount + self.m_iSpecAreaSpacing * (CLClassSpecCount + 1)
	self.m_iHeight = self.m_iSpecAreaHeight
	self.m_strPositionAnchor = "BOTTOM"
	self.m_iPositionX = 0
	self.m_iPositionY = 42
	
	self.m_hFrame = nil
	
	self.m_iClassIndex = 0
	self.m_arrSpecFrames = nil
	self.m_arrSpellButtons = nil
end

-------------------------------------------------------------------------------------------------------------------
-- CLUITabFrameSpells : Getters / Setters

-------------------------------------------------------------------------------------------------------------------
-- CLUITabFrameSpells : Methods
function CLUITabFrameSpells:Show()
	if ( not self.m_hFrame:IsVisible() ) then
		self.m_hFrame:Show()
	end
end
function CLUITabFrameSpells:Hide()
	if self.m_hFrame:IsVisible() then
		self.m_hFrame:Hide()
	end
end

function CLUITabFrameSpells:UpdateButton( iSpecIndex, iSpellIndex )
	-- Get Client Instance
	local hClient = CLClient:GetInstance()
	
	-- Get Spell Desc
	local hSpellDesc = CLDataSpells:GetInstance():GetSpellDesc( self.m_iClassIndex, iSpecIndex, iSpellIndex )
	local iRank = hSpellDesc:GetRankFromLevel( UnitLevel("player") )
	
	-- Get State
	local bKnown = hClient:GetKnownSpells():HasSpell( self.m_iClassIndex, iSpecIndex, iSpellIndex )
	local bPending = hClient:GetPendingSpells():HasSpell( self.m_iClassIndex, iSpecIndex, iSpellIndex )
	local bCanLearn = ( iRank > 0 )
	
	-- Setup Button State
	if ( not bCanLearn ) then
		self.m_arrSpellButtons[iSpecIndex][iSpellIndex].background:SetVertexColor( 0.8, 0.2, 0.2 )
		self.m_arrSpellButtons[iSpecIndex][iSpellIndex].background:SetDesaturated( false )
		self.m_arrSpellButtons[iSpecIndex][iSpellIndex].overlay:Hide()
	else
		self.m_arrSpellButtons[iSpecIndex][iSpellIndex].background:SetVertexColor( 1.0, 1.0, 1.0 )
		if bKnown then
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].background:SetDesaturated( false )
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].overlay:Show()
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].overlay:SetDesaturated( false )
		elseif bPending then
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].background:SetDesaturated( false )
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].overlay:Show()
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].overlay:SetDesaturated( true )
		else
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].background:SetDesaturated( true )
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].overlay:Hide()
		end
	end
end
function CLUITabFrameSpells:Update()
	-- Get Spells Data
	local hDataSpells = CLDataSpells:GetInstance()
	
	-- Enum all Specs
	for iSpecIndex = 1, CLClassSpecCount do
		-- Enum all Spells
		local iSpellCount = hDataSpells:GetSpellCount( self.m_iClassIndex, iSpecIndex )
		for iSpellIndex = 1, iSpellCount do
			-- Update State
			self:UpdateButton( iSpecIndex, iSpellIndex )
		end
	end
end

-------------------------------------------------------------------------------------------------------------------
-- CLUITabFrameSpells : Initialization
function CLUITabFrameSpells:Initialize( hParentFrame, iClassIndex )
	if ( self.m_hFrame ~= nil ) then
		return
	end
	local hThis = self
	
	-- Save Class Index & Setup arrays
	self.m_iClassIndex = iClassIndex
	self.m_arrSpecFrames = {}
	self.m_arrSpellButtons = {}
	
	-- Create Frame, Start Hidden
	local strFrameName = "CLSpellTabFrame_Class" .. self.m_iClassIndex
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
	
	-- Get Spells Data
	local hDataSpells = CLDataSpells:GetInstance()

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
		local strTextureBaseName = hDataSpells:GetClassSpecTexture( self.m_iClassIndex, iSpecIndex )
		
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
		self.m_arrSpecFrames[iSpecIndex].title.text:SetText( hDataSpells:GetClassSpecName(self.m_iClassIndex, iSpecIndex) )
		
		-- Setup Button array
		self.m_arrSpellButtons[iSpecIndex] = {}
		
		-- Enum all Spells
		local iSpellCount = hDataSpells:GetSpellCount( self.m_iClassIndex, iSpecIndex )
		
		for iSpellIndex = 1, iSpellCount do
			-- Get Spell Desc
			local hSpellDesc = hDataSpells:GetSpellDesc( self.m_iClassIndex, iSpecIndex, iSpellIndex )
			
			-- Create Button
			local strButtonName = "CLSpellButton_Class" .. self.m_iClassIndex .. "_Spec" .. iSpecIndex .. "_Index" .. iSpellIndex
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex] = CreateFrame( "Button", strButtonName, self.m_arrSpecFrames[iSpecIndex] )
			
			-- Size & Position
			local iRow = math.floor( (iSpellIndex-1) / self.m_iSpellButtonsPerRow )
			local iCol = (iSpellIndex-1) - iRow * self.m_iSpellButtonsPerRow -- (iSpellIndex-1) % self.m_iSpellButtonsPerRow
			local iButtonX = self.m_iSpellButtonsSpacing + iCol * (self.m_iSpellButtonsSize + self.m_iSpellButtonsSpacing)
			local iButtonY = self.m_iSpellButtonsSpacing + iRow * (self.m_iSpellButtonsSize + self.m_iSpellButtonsSpacing) + self.m_iSpecAreaTitleHeight
			
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex]:SetSize( self.m_iSpellButtonsSize, self.m_iSpellButtonsSize )
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex]:SetPoint( "TOPLEFT", self.m_arrSpecFrames[iSpecIndex], "TOPLEFT", iButtonX, -iButtonY )
			
			-- Properties
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex]:RegisterForClicks( "LeftButtonDown", "RightButtonDown" )
			
			-- Fonts
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex]:SetNormalFontObject( GameFontNormal )
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex]:SetHighlightFontObject( GameFontHighlight )
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex]:SetDisabledFontObject( GameFontDisable )
			
			-- Textures
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].background = self.m_arrSpellButtons[iSpecIndex][iSpellIndex]:CreateTexture( nil, "BACKGROUND" )
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].background:SetTexture( hSpellDesc:GetIcon() )
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].background:SetSize( self.m_iSpellButtonsSize, self.m_iSpellButtonsSize )
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].background:SetAllPoints( self.m_arrSpellButtons[iSpecIndex][iSpellIndex] )
			
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].overlay = self.m_arrSpellButtons[iSpecIndex][iSpellIndex]:CreateTexture( nil, "OVERLAY" )
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].overlay:SetTexture( "Interface\\AchievementFrame\\UI-Achievement-IconFrame" )
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].overlay:SetTexCoord( 0, 0.5, 0, 0.5 )
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].overlay:SetSize( self.m_iSpellButtonsSize * 1.2, self.m_iSpellButtonsSize * 1.2 )
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex].overlay:SetPoint( "TOPLEFT", self.m_arrSpellButtons[iSpecIndex][iSpellIndex], "TOPLEFT", -6, 6 )
			
			-- Setup Button State
			hThis:UpdateButton( iSpecIndex, iSpellIndex )
			
			-- Event : OnEnter
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex]:SetScript( "OnEnter",
				function()
					-- Attach ToolTip to Button Frame
					local hToolTip = CLClient:GetInstance():GetToolTip()
					hToolTip:SetOwner( hThis.m_arrSpellButtons[iSpecIndex][iSpellIndex], "ANCHOR_RIGHT" )

					-- Get Spell Desc
					local hSpellDesc = hDataSpells:GetSpellDesc( self.m_iClassIndex, iSpecIndex, iSpellIndex )
					local iRankCount = hSpellDesc:GetRankCount()
					local iRank = hSpellDesc:GetRankFromLevel( UnitLevel("player") )
					if ( iRank == 0 ) then
						iRank = 1
					end
					
					hSpellDesc:SetCurrentRank( iRank )
					local iSpellID = hSpellDesc:GetCurrentSpellID()
					local iSpellLevel = hSpellDesc:GetCurrentSpellLevel()
					local strLink = CLClient:GetInstance():GetAbilityLink( iSpellID )
					
					-- Build ToolTip
					hToolTip:SetHyperlink( strLink )
					hToolTip:AddLine( "Rank: " .. iRank .. "/" .. iRankCount, HIGHLIGHT_FONT_COLOR )
					hToolTip:AddLine( "Req. Level: " .. iSpellLevel, HIGHLIGHT_FONT_COLOR )
					hToolTip:AddLine( "SPELLID: " .. iSpellID, RED_FONT_COLOR )
					
					-- Show tooltip
					hToolTip:Show()
				end
			)
			
			-- Event : OnLeave
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex]:SetScript( "OnLeave",
				function()
					-- Hide tooltip
					CLClient:GetInstance():GetToolTip():Hide()
				end
			)
			
			-- Event : OnClick
			self.m_arrSpellButtons[iSpecIndex][iSpellIndex]:SetScript( "OnClick",
				function( self, strMouseButton, bHeldDown )
					-- Add/Remove Pending Spell
					if ( strMouseButton == "LeftButton" ) then
						CLClient:GetInstance():AddPendingSpell( hThis.m_iClassIndex, iSpecIndex, iSpellIndex )
					elseif ( strMouseButton == "RightButton" ) then
						CLClient:GetInstance():RemovePendingSpell( hThis.m_iClassIndex, iSpecIndex, iSpellIndex )
					end
					
					-- Update Button State
					hThis:UpdateButton( iSpecIndex, iSpellIndex )
				end
			)
		end
	end
	
	print( strFrameName .. " Initialized !" )
end



