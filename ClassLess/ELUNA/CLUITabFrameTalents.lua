-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess Client UI : Talent Tab Frame
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
-- CLUITabFrameTalents - Declaration
CLUITabFrameTalents = class({
	-- Static Members
})

function CLUITabFrameTalents:init()
	-- Members
	self.m_iTalentButtonsSpacing = 16
	self.m_iTalentButtonsSize = 32
	self.m_iTalentCellSize = self.m_iTalentButtonsSize + self.m_iTalentButtonsSpacing

	self.m_iSpecAreaTitleHeight = 32
	
	self.m_iSpecAreaSpacing = 10
	self.m_iSpecAreaWidth = self.m_iTalentCellSize * 4
	self.m_iSpecAreaHeight = self.m_iTalentCellSize * 11 + self.m_iSpecAreaTitleHeight
	
	self.m_iWidth = self.m_iSpecAreaWidth * CLClassSpecCount + self.m_iSpecAreaSpacing * (CLClassSpecCount + 1)
	self.m_iHeight = self.m_iSpecAreaHeight
	self.m_strPositionAnchor = "BOTTOM"
	self.m_iPositionX = 0
	self.m_iPositionY = 42
	
	self.m_hFrame = nil
	
	self.m_iClassIndex = 0
	self.m_arrSpecFrames = nil
	self.m_arrTalentButtons = nil
end

-------------------------------------------------------------------------------------------------------------------
-- CLUITabFrameTalents : Getters / Setters

-------------------------------------------------------------------------------------------------------------------
-- CLUITabFrameTalents : Methods
function CLUITabFrameTalents:Show()
	if ( not self.m_hFrame:IsVisible() ) then
		self.m_hFrame:Show()
	end
end
function CLUITabFrameTalents:Hide()
	if self.m_hFrame:IsVisible() then
		self.m_hFrame:Hide()
	end
end

function CLUITabFrameTalents:UpdateButton( iSpecIndex, iGridTier, iGridSlot )
	-- Get Client Instance
	local hClient = CLClient:GetInstance()
	
	-- Get Talent Desc
	local hTalentDesc = CLDataTalents:GetInstance():GetTalentDesc( self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot )

	-- Get State
	local bKnown = hClient:GetKnownTalents():HasTalent( self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	local bPending = hClient:GetPendingTalents():HasTalent( self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	
	local iSpecAllocatedTalentPoints = hClient:GetSpecSpentTalentPoints( self.m_iClassIndex, iSpecIndex )
	local iRequiredTalentPoints = 0
	if hTalentDesc:IsPetTalent() then
		iRequiredTalentPoints = hClient:GetRequiredPetTalentPoints( iGridTier )
	else
		iRequiredTalentPoints = hClient:GetRequiredTalentPoints( iGridTier )
	end
	local bCanLearn = ( iSpecAllocatedTalentPoints >= iRequiredTalentPoints )
	
	local iRequiredTalentGridTier, iRequiredTalentGridSlot = hTalentDesc:GetRequiredTalent()
	if ( iRequiredTalentGridTier ~= 0 and iRequiredTalentGridSlot ~= 0 ) then
		-- Must be present
		local hRequiredTalentDesc = nil
		if ( hClient:GetPendingTalents():HasTalent(self.m_iClassIndex, iSpecIndex, iRequiredTalentGridTier, iRequiredTalentGridSlot) ) then
			hRequiredTalentDesc = hClient:GetPendingTalents():GetTalentDesc( self.m_iClassIndex, iSpecIndex, iRequiredTalentGridTier, iRequiredTalentGridSlot )
		elseif ( hClient:GetKnownTalents():HasTalent(self.m_iClassIndex, iSpecIndex, iRequiredTalentGridTier, iRequiredTalentGridSlot) ) then
			hRequiredTalentDesc = hClient:GetKnownTalents():GetTalentDesc( self.m_iClassIndex, iSpecIndex, iRequiredTalentGridTier, iRequiredTalentGridSlot )
		end
		-- Must be maxed
		if ( hRequiredTalentDesc == nil or (not hRequiredTalentDesc:IsMaxed()) ) then
			bCanLearn = false
		end
	end
	
	-- Setup Button State
	if ( not bCanLearn ) then
		self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].background:SetVertexColor( 0.8, 0.2, 0.2 )
		self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].background:SetDesaturated( false )
		self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].overlay:Hide()
	else
		self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].background:SetVertexColor( 1.0, 1.0, 1.0 )
		if bKnown then
			self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].background:SetDesaturated( false )
			self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].overlay:Show()
			self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].overlay:SetDesaturated( false )
		elseif bPending then
			self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].background:SetDesaturated( false )
			self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].overlay:Show()
			self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].overlay:SetDesaturated( true )
		else
			self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].background:SetDesaturated( true )
			self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].overlay:Hide()
		end
	end
	
	-- Update Counter
	local iCurrentCost = 0
	if bPending then
		iCurrentCost = hClient:GetPendingTalents():GetTalentDesc(self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot):GetCost()
	elseif bKnown then
		iCurrentCost = hClient:GetKnownTalents():GetTalentDesc(self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot):GetCost()
	end
	self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].counter.text:SetText( iCurrentCost )
end
function CLUITabFrameTalents:Update()
	-- Get Talents Data
	local hDataTalents = CLDataTalents:GetInstance()
	
	-- Enum all Specs
	for iSpecIndex = 1, CLClassSpecCount do
		-- Enum all Talents
		local iGridWidth = hDataTalents:GetGridWidth( self.m_iClassIndex, iSpecIndex )
		local iGridHeight = hDataTalents:GetGridHeight( self.m_iClassIndex, iSpecIndex )
		
		for iGridTier = 1, iGridHeight do
			for iGridSlot = 1, iGridWidth do
				-- Check for non-Empty Cells
				if ( not hDataTalents:IsEmptyCell(self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot) ) then
					-- Update State
					self:UpdateButton( iSpecIndex, iGridTier, iGridSlot )
				end
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------
-- CLUITabFrameTalents : Initialization
function CLUITabFrameTalents:Initialize( hParentFrame, iClassIndex )
	if ( self.m_hFrame ~= nil ) then
		return
	end
	local hThis = self
	
	-- Save Class Index & Setup arrays
	self.m_iClassIndex = iClassIndex
	self.m_arrSpecFrames = {}
	self.m_arrTalentButtons = {}
	
	-- Create Frame, Start Hidden
	local strFrameName = "CLTalentTabFrame_Class" .. self.m_iClassIndex
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
	
	-- Get Talents Data
	local hDataTalents = CLDataTalents:GetInstance()

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
		local strTextureBaseName = hDataTalents:GetClassSpecTexture( self.m_iClassIndex, iSpecIndex )
		
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
		self.m_arrSpecFrames[iSpecIndex].title.text:SetText( hDataTalents:GetClassSpecName(self.m_iClassIndex, iSpecIndex) )
		
		-- Setup Button & Arrows array
		self.m_arrTalentButtons[iSpecIndex] = {}
		self.m_arrSpecFrames[iSpecIndex].arrows = {}
		
		-- Walk through Talent Grid
		local iGridWidth = hDataTalents:GetGridWidth( self.m_iClassIndex, iSpecIndex )
		local iGridHeight = hDataTalents:GetGridHeight( self.m_iClassIndex, iSpecIndex )
		
		-- Enum all Tiers
		for iGridTier = 1, iGridHeight do
			-- Setup Button & Arrows array
			self.m_arrTalentButtons[iSpecIndex][iGridTier] = {}
			self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier] = {}
			
			-- Enum all Slots
			for iGridSlot = 1, iGridWidth do
				-- Cell Position
				local iCellX = (iGridSlot - 1) * self.m_iTalentCellSize
				local iCellY = (iGridTier - 1) * self.m_iTalentCellSize + self.m_iSpecAreaTitleHeight
			
				-- Check for non-Empty Cells
				if ( not hDataTalents:IsEmptyCell(self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot) ) then
					-- Get Talent Desc
					local hTalentDesc = hDataTalents:GetTalentDesc( self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot )

					-- Create Button
					local strButtonName = "CLTalentButton_Class" .. self.m_iClassIndex .. "_Spec" .. iSpecIndex .. "_Tier" .. iGridTier .. "_Slot" .. iGridSlot
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot] = CreateFrame( "Button", strButtonName, self.m_arrSpecFrames[iSpecIndex] )
					
					-- Size & Position
					local iButtonX = iCellX + self.m_iTalentButtonsSpacing / 2
					local iButtonY = iCellY + self.m_iTalentButtonsSpacing / 2
					
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot]:SetSize( self.m_iTalentButtonsSize, self.m_iTalentButtonsSize )
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot]:SetPoint( "TOPLEFT", self.m_arrSpecFrames[iSpecIndex], "TOPLEFT", iButtonX, -iButtonY )
					
					-- Properties
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot]:RegisterForClicks( "LeftButtonDown", "RightButtonDown" )
					
					-- Fonts
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot]:SetNormalFontObject( GameFontNormal )
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot]:SetHighlightFontObject( GameFontHighlight )
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot]:SetDisabledFontObject( GameFontDisable )
					
					-- Textures
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].background = self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot]:CreateTexture( nil, "BACKGROUND" )
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].background:SetTexture( hTalentDesc:GetIcon() )
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].background:SetSize( self.m_iTalentButtonsSize, self.m_iTalentButtonsSize )
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].background:SetAllPoints( self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot] )
					
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].overlay = self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot]:CreateTexture( nil, "OVERLAY" )
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].overlay:SetTexture( "Interface\\AchievementFrame\\UI-Achievement-IconFrame" )
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].overlay:SetTexCoord( 0, 0.5, 0, 0.5 )
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].overlay:SetSize( self.m_iTalentButtonsSize * 1.2, self.m_iTalentButtonsSize * 1.2 )
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].overlay:SetPoint( "TOPLEFT", self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot], "TOPLEFT", -6, 6 )
					
					-- Counter
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].counter = CreateFrame( "Frame", strButtonName .. "_Counter", self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot] )
					
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].counter:SetSize( self.m_iTalentButtonsSize * 0.2, self.m_iTalentButtonsSize * 0.2 )
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].counter:SetPoint( "BOTTOMLEFT", self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot], "BOTTOMLEFT", 0, 0 )
					
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].counter.text = self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].counter:CreateFontString( nil, "OVERLAY", "NumberFontNormalSmall" )
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].counter.text:SetTextColor( HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b )
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].counter.text:SetJustifyV( "MIDDLE" )
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].counter.text:SetJustifyH( "MIDDLE" )
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].counter.text:SetPoint( "CENTER", self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot].counter, "CENTER", 0, 0 )
					
					-- Setup Button State
					hThis:UpdateButton( iSpecIndex, iGridTier, iGridSlot )
					
					-- Event : OnEnter
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot]:SetScript( "OnEnter",
						function()
							-- Get Client Instance
							local hClient = CLClient:GetInstance()
			
							-- Attach ToolTip to Button Frame
							local hToolTip = hClient:GetToolTip()
							hToolTip:SetOwner( hThis.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot], "ANCHOR_RIGHT" )

							-- Get Talent Desc
							local hTalentDesc = hDataTalents:GetTalentDesc( self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot )
							local iRankCount = hTalentDesc:GetRankCount()
							
							-- Check for TalentSpell
							if hTalentDesc:IsTalentSpell() then
								-- Get appropriate rank
								local iRank = hTalentDesc:GetTalentSpellRankFromLevel( UnitLevel("player") )
								if ( iRank == 0 ) then
									iRank = 1
								end
								
								hTalentDesc:SetCurrentRank( iRank )
								local iTalentID = hTalentDesc:GetCurrentTalentID()
								local iTalentSpellLevel = hTalentDesc:GetCurrentTalentSpellLevel()
								local strLink = hClient:GetAbilityLink( iTalentID )
								
								-- Build ToolTip
								hToolTip:SetHyperlink( strLink )
								hToolTip:AddLine( "Rank: " .. iRank .. "/" .. iRankCount, HIGHLIGHT_FONT_COLOR )
								hToolTip:AddLine( "Req. Level: " .. iTalentSpellLevel, HIGHLIGHT_FONT_COLOR )
								hToolTip:AddLine( "SPELLID: " .. iTalentID, RED_FONT_COLOR )
							else
								-- Get appropriate rank
								local iRank = 0
								if ( hClient:GetPendingTalents():HasTalent(self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot) ) then
									iRank = hClient:GetPendingTalents():GetTalentDesc(self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot):GetCurrentRank()
								elseif ( hClient:GetKnownTalents():HasTalent(self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot) ) then
									iRank = hClient:GetKnownTalents():GetTalentDesc(self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot):GetCurrentRank()
								end
								if ( iRank == 0 ) then
									iRank = 1
								end
								
								hTalentDesc:SetCurrentRank( iRank )
								local iTalentID = hTalentDesc:GetCurrentTalentID()
								local strLink = hClient:GetAbilityLink( iTalentID )
								
								-- Build ToolTip
								hToolTip:SetHyperlink( strLink )
								hToolTip:AddLine( "Rank: " .. iRank .. "/" .. iRankCount, HIGHLIGHT_FONT_COLOR )
								hToolTip:AddLine( "SPELLID: " .. iTalentID, RED_FONT_COLOR )
							end
							
							-- Show tooltip
							hToolTip:Show()
						end
					)
					
					-- Event : OnLeave
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot]:SetScript( "OnLeave",
						function()
							-- Hide tooltip
							CLClient:GetInstance():GetToolTip():Hide()
						end
					)
					
					-- Event : OnClick
					self.m_arrTalentButtons[iSpecIndex][iGridTier][iGridSlot]:SetScript( "OnClick",
						function( self, strMouseButton, bHeldDown )
							-- Add/Remove Pending Talent
							if ( strMouseButton == "LeftButton" ) then
								CLClient:GetInstance():AddPendingTalent( hThis.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot )
							elseif ( strMouseButton == "RightButton" ) then
								CLClient:GetInstance():RemovePendingTalent( hThis.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot )
							end
							
							-- Update Button State
							hThis:UpdateButton( iSpecIndex, iGridTier, iGridSlot )
						end
					)
				end
				
				-- Draw Arrows
				local strBranchesTexture = "Interface\\TalentFrame\\UI-TalentBranches"
				local strArrowsTexture = "Interface\\TalentFrame\\UI-TalentArrows"
				
				if hDataTalents:IsEmptyCell( self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot ) then
					local strArrow = hDataTalents:GetEmptyCellArrow( self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot )
					if ( strArrow ~= "None" ) then
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot] = self.m_arrSpecFrames[iSpecIndex]:CreateTexture( nil, "ARTWORK" )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot]:SetTexture( strBranchesTexture )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot]:SetSize( self.m_iTalentCellSize, self.m_iTalentCellSize )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot]:SetPoint( "TOPLEFT", self.m_arrSpecFrames[iSpecIndex], "TOPLEFT", iCellX, -iCellY )
						
						if ( strArrow == "Horiz" ) then
							self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot]:SetTexCoord( 0.2578125, 0.37890625, 0, 0.484375 )
						elseif ( strArrow == "Vert" ) then
							self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot]:SetTexCoord( 0.12890625, 0.25, 0, 0.484375 )
						elseif ( strArrow == "LeftDown" ) then
							self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot]:SetTexCoord( 0.515625, 0.63671875, 0, 0.484375 )
						elseif ( strArrow == "RightDown" ) then
							self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot]:SetTexCoord( 0.5078125, 0.484375, 0.5078125, 0, 0.38671875, 0.484375, 0.38671875, 0 )
							self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot]:SetPoint( "TOPLEFT", self.m_arrSpecFrames[iSpecIndex], "TOPLEFT", iCellX + 1.5, -iCellY - 1.5 )
						end
					end
				else
					self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot] = {}
					
					local strArrowLeft = hDataTalents:GetTalentCellArrowLeft( self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot )
					local strArrowRight = hDataTalents:GetTalentCellArrowRight( self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot )
					local strArrowTop = hDataTalents:GetTalentCellArrowTop( self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot )
					local strArrowBottom = hDataTalents:GetTalentCellArrowBottom( self.m_iClassIndex, iSpecIndex, iGridTier, iGridSlot )
					if ( strArrowLeft ~= "None" ) then
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].leftbranch = self.m_arrSpecFrames[iSpecIndex]:CreateTexture( nil, "ARTWORK" )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].leftbranch:SetTexture( strBranchesTexture )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].leftbranch:SetTexCoord( 0.2578125, 0.37890625, 0, 0.484375 )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].leftbranch:SetSize( self.m_iTalentCellSize * 0.5, self.m_iTalentCellSize )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].leftbranch:SetPoint( "TOPLEFT", self.m_arrSpecFrames[iSpecIndex], "TOPLEFT",
							iCellX - 0.5,
							-iCellY
						)
						-- if ( strArrowLeft == "In" ) then
							-- self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].leftarrow = self.m_arrSpecFrames[iSpecIndex]:CreateTexture( nil, "OVERLAY" )
							-- self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].leftarrow:SetTexture( strArrowsTexture )
							-- self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].leftarrow:SetTexCoord( 0, 0, 0, 0 )
							-- self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].leftarrow:SetSize( self.m_iTalentCellSize * 0.5, self.m_iTalentCellSize * 0.5 )
							-- self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].leftarrow:SetPoint( "TOPLEFT", self.m_arrSpecFrames[iSpecIndex], "TOPLEFT",
								-- iCellX,
								-- -iCellY - ( self.m_iTalentCellSize * 0.25 )
							-- )
						-- end
					end
					if ( strArrowRight ~= "None" ) then
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].rightbranch = self.m_arrSpecFrames[iSpecIndex]:CreateTexture( nil, "ARTWORK" )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].rightbranch:SetTexture( strBranchesTexture )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].rightbranch:SetTexCoord( 0.2578125, 0.37890625, 0, 0.484375 )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].rightbranch:SetSize( self.m_iTalentCellSize * 0.5, self.m_iTalentCellSize )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].rightbranch:SetPoint( "TOPLEFT", self.m_arrSpecFrames[iSpecIndex], "TOPLEFT",
							iCellX + ( self.m_iTalentCellSize * 0.5 ) + 0.5,
							-iCellY
						)
						-- if ( strArrowRight == "In" ) then
							-- self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].rightarrow = self.m_arrSpecFrames[iSpecIndex]:CreateTexture( nil, "OVERLAY" )
							-- self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].rightarrow:SetTexture( strArrowsTexture )
							-- self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].rightarrow:SetTexCoord( 0, 0, 0, 0 )
							-- self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].rightarrow:SetSize( self.m_iTalentCellSize * 0.5, self.m_iTalentCellSize * 0.5 )
							-- self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].rightarrow:SetPoint( "TOPLEFT", self.m_arrSpecFrames[iSpecIndex], "TOPLEFT",
								-- iCellX + ( self.m_iTalentCellSize * 0.5 ),
								-- -iCellY - ( self.m_iTalentCellSize * 0.25 )
							-- )
						-- end
					end
					if ( strArrowTop ~= "None" ) then
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].topbranch = self.m_arrSpecFrames[iSpecIndex]:CreateTexture( nil, "ARTWORK" )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].topbranch:SetTexture( strBranchesTexture )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].topbranch:SetTexCoord( 0.12890625, 0.25, 0, 0.484375 )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].topbranch:SetSize( self.m_iTalentCellSize, self.m_iTalentCellSize * 0.5 )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].topbranch:SetPoint( "TOPLEFT", self.m_arrSpecFrames[iSpecIndex], "TOPLEFT",
							iCellX,
							-iCellY
						)
						-- if ( strArrowTop == "In" ) then
							-- self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].toparrow = self.m_arrSpecFrames[iSpecIndex]:CreateTexture( nil, "OVERLAY" )
							-- self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].toparrow:SetTexture( strArrowsTexture )
							-- self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].toparrow:SetTexCoord( 0, 0, 0, 0 )
							-- self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].toparrow:SetSize( self.m_iTalentCellSize * 0.5, self.m_iTalentCellSize * 0.5 )
							-- self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].toparrow:SetPoint( "TOPLEFT", self.m_arrSpecFrames[iSpecIndex], "TOPLEFT",
								-- iCellX + ( self.m_iTalentCellSize * 0.25 ),
								-- -iCellY
							-- )
						-- end
					end
					if ( strArrowBottom ~= "None" ) then
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].bottombranch = self.m_arrSpecFrames[iSpecIndex]:CreateTexture( nil, "ARTWORK" )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].bottombranch:SetTexture( strBranchesTexture )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].bottombranch:SetTexCoord( 0.12890625, 0.25, 0, 0.484375 )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].bottombranch:SetSize( self.m_iTalentCellSize, self.m_iTalentCellSize * 0.5 )
						self.m_arrSpecFrames[iSpecIndex].arrows[iGridTier][iGridSlot].bottombranch:SetPoint( "TOPLEFT", self.m_arrSpecFrames[iSpecIndex], "TOPLEFT",
							iCellX,
							-iCellY - ( self.m_iTalentCellSize * 0.5 )
						)
					end
				end
			end
		end
	end
	
	print( strFrameName .. " Initialized !" )
end



