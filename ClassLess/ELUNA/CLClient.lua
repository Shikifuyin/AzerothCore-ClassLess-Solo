-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess Client
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Requirements
local AIO = AIO or require("AIO")
if not class then require("class") end
if not CLDataSpells then require("CLDataSpells") end
if not CLDataTalents then require("CLDataTalents") end
if not CLDataGlyphs then require("CLDataGlyphs") end

-------------------------------------------------------------------------------------------------------------------
-- Client / Server Setup

-- Client-side Only !
if AIO.AddAddon() then
	return
end

-------------------------------------------------------------------------------------------------------------------
-- Constants

-------------------------------------------------------------------------------------------------------------------
-- CLClient - Declaration
CLClient = class({
	-- Static Members
	sm_hInstance = nil
})
function CLClient:GetInstance()
	if ( self.sm_hInstance == nil ) then
		self.sm_hInstance = CLClient()
		self.sm_hInstance:Initialize()
	end
	return self.sm_hInstance
end

function CLClient:init()
	-- Session Token
	self.m_strClientToken = nil
	
	-- Async IO
	self.m_strAIOHandlerName = nil
	self.m_hAIOHandlers = nil
	
	-- Server Data (Read-Only !)
	self.m_iFreeSpellPoints = nil
	self.m_iFreePetSpellPoints = nil
	self.m_iFreeTalentPoints = nil
	self.m_iFreePetTalentPoints = nil
	self.m_iRequiredTalentPointsPerTier = nil
	self.m_iRequiredPetTalentPointsPerTier = nil
	self.m_iFreeGlyphMajorSlots = nil
	self.m_iFreeGlyphMinorSlots = nil
	self.m_iResetCost = nil
	
	self.m_mapKnownSpells = CLSpellMap()
	self.m_mapKnownTalents = CLTalentMap()
	self.m_mapKnownGlyphs = CLGlyphMap()
	
	-- Client Data
	self.m_mapPendingSpells = CLSpellMap()
	self.m_mapPendingTalents = CLTalentMap()
	self.m_mapPendingGlyphs = CLGlyphMap()

	-- UI
	self.m_hCLUIToolTip = nil
	self.m_hCLUIMainFrame = nil
	self.m_hCLUIMainButton = nil
end

-------------------------------------------------------------------------------------------------------------------
-- CLClient : Methods - General
function CLClient:GetResetCost()
	return self.m_iResetCost
end

function CLClient:GetToolTip()
	return self.m_hCLUIToolTip
end
function CLClient:GetMainFrame()
	return self.m_hCLUIMainFrame
end

function CLClient:ApplyAbilities()
	-- Server-side : Call CommitAbilities
	AIO.Handle( self.m_strAIOHandlerName, "CommitAbilities",
		self.m_mapPendingSpells:Encode(),
		self.m_mapPendingTalents:Encode(),
		self.m_mapPendingGlyphs:Encode(),
		self.m_strClientToken
	)
	
	-- Flush Pending Abilities
	self.m_mapPendingSpells:Clear()
	self.m_mapPendingTalents:Clear()
	self.m_mapPendingGlyphs:Clear()
end
function CLClient:CancelAbilities()
	-- Flush Pending Abilities
	self.m_mapPendingSpells:Clear()
	self.m_mapPendingTalents:Clear()
	self.m_mapPendingGlyphs:Clear()
end
function CLClient:ResetAbilities()
	-- Server-side : Call ResetAbilities
	AIO.Handle( self.m_strAIOHandlerName, "ResetAbilities", self.m_strClientToken )
	
	-- Flush Pending Abilities
	self.m_mapPendingSpells:Clear()
	self.m_mapPendingTalents:Clear()
	self.m_mapPendingGlyphs:Clear()
end

function CLClient:GetAbilityLink( iAbilityID )
	local strLink = GetSpellLink( iAbilityID )
	if ( strLink == nil or strLink == "" ) then
		strLink = string.format( "|cff71d5ff|Hspell:%d:|h[%s]|h|r", iAbilityID, GetSpellInfo(iAbilityID) )
	end
	return strLink
end

-------------------------------------------------------------------------------------------------------------------
-- CLClient : Methods - Spells
function CLClient:GetKnownSpells()
	return self.m_mapKnownSpells
end
function CLClient:GetPendingSpells()
	return self.m_mapPendingSpells
end

function CLClient:GetFreeSpellPoints()
	return self.m_iFreeSpellPoints
end
function CLClient:GetFreePetSpellPoints()
	return self.m_iFreePetSpellPoints
end
function CLClient:GetSpentSpellPoints()
	return self.m_mapPendingSpells:GetSpellPoints()
end
function CLClient:GetSpentPetSpellPoints()
	return self.m_mapPendingSpells:GetPetSpellPoints()
end
function CLClient:GetRemainingSpellPoints()
	return ( self:GetFreeSpellPoints() - self:GetSpentSpellPoints() )
end
function CLClient:GetRemainingPetSpellPoints()
	return ( self:GetFreePetSpellPoints() - self:GetSpentPetSpellPoints() )
end

function CLClient:AddPendingSpell( iClassIndex, iSpecIndex, iSpellIndex )
	-- Get Spell Descriptor
	local hSpellDesc = CLDataSpells:GetInstance():GetSpellDesc( iClassIndex, iSpecIndex, iSpellIndex )
	
	-- Check if we have enough points
	if hSpellDesc:IsPetSpell() then
		if ( self:GetRemainingPetSpellPoints() <= 0 ) then
			return
		end
	else
		if ( self:GetRemainingSpellPoints() <= 0 ) then
			return
		end
	end
	
	-- Check if Spell is pending
	if self.m_mapPendingSpells:HasSpell( iClassIndex, iSpecIndex, iSpellIndex ) then
		return
	end
	
	-- Check if Spell is known
	if self.m_mapKnownSpells:HasSpell( iClassIndex, iSpecIndex, iSpellIndex ) then
		return
	end
	
	-- Apply appropriate Rank
	local iRank = hSpellDesc:GetRankFromLevel( UnitLevel("player") )
	if ( iRank == 0 ) then
		return
	end
	hSpellDesc:SetCurrentRank( iRank )
	
	-- Add Spell
	self.m_mapPendingSpells:AddSpell( hSpellDesc )
end
function CLClient:RemovePendingSpell( iClassIndex, iSpecIndex, iSpellIndex )
	self.m_mapPendingSpells:RemoveSpell( iClassIndex, iSpecIndex, iSpellIndex )
end

-------------------------------------------------------------------------------------------------------------------
-- CLClient : Methods - Talents
function CLClient:GetKnownTalents()
	return self.m_mapKnownTalents
end
function CLClient:GetPendingTalents()
	return self.m_mapPendingTalents
end

function CLClient:GetFreeTalentPoints()
	return self.m_iFreeTalentPoints
end
function CLClient:GetFreePetTalentPoints()
	return self.m_iFreePetTalentPoints
end
function CLClient:GetSpentTalentPoints()
	local iSpentTalentPoints = 0
	self.m_mapPendingTalents:EnumCallback(
		function( hTalentDesc )
			if hTalentDesc:IsPetTalent() then
				return
			end
			if hTalentDesc:IsTalentSpell() then
				iSpentTalentPoints = iSpentTalentPoints + hTalentDesc:GetCost()
				return
			end
			local iPendingCost = hTalentDesc:GetCost()
			local iKnownCost = 0
			if ( self.m_mapKnownTalents:HasTalent(hTalentDesc:GetClassIndex(), hTalentDesc:GetSpecIndex(),
												  hTalentDesc:GetGridTier(), hTalentDesc:GetGridSlot()) ) then
				iKnownCost = self.m_mapKnownTalents:GetTalentDesc( hTalentDesc:GetClassIndex(), hTalentDesc:GetSpecIndex(),
																   hTalentDesc:GetGridTier(), hTalentDesc:GetGridSlot() ):GetCost()
			end
			iSpentTalentPoints = iSpentTalentPoints + (iPendingCost - iKnownCost)
		end
	)
	return iSpentTalentPoints
end
function CLClient:GetSpentPetTalentPoints()
	local iSpentTalentPoints = 0
	self.m_mapPendingTalents:EnumCallback(
		function( hTalentDesc )
			if ( not hTalentDesc:IsPetTalent() ) then
				return
			end
			if hTalentDesc:IsTalentSpell() then
				iSpentTalentPoints = iSpentTalentPoints + hTalentDesc:GetCost()
				return
			end
			local iPendingCost = hTalentDesc:GetCost()
			local iKnownCost = 0
			if ( self.m_mapKnownTalents:HasTalent(hTalentDesc:GetClassIndex(), hTalentDesc:GetSpecIndex(),
												  hTalentDesc:GetGridTier(), hTalentDesc:GetGridSlot()) ) then
				iKnownCost = self.m_mapKnownTalents:GetTalentDesc( hTalentDesc:GetClassIndex(), hTalentDesc:GetSpecIndex(),
																   hTalentDesc:GetGridTier(), hTalentDesc:GetGridSlot() ):GetCost()
			end
			iSpentTalentPoints = iSpentTalentPoints + (iPendingCost - iKnownCost)
		end
	)
	return iSpentTalentPoints
end
function CLClient:GetRemainingTalentPoints()
	return ( self:GetFreeTalentPoints() - self:GetSpentTalentPoints() )
end
function CLClient:GetRemainingPetTalentPoints()
	return ( self:GetFreePetTalentPoints() - self:GetSpentPetTalentPoints() )
end

function CLClient:GetRequiredTalentPoints( iGridTier )
	return ( (iGridTier-1) * self.m_iRequiredTalentPointsPerTier )
end
function CLClient:GetRequiredPetTalentPoints( iGridTier )
	return ( (iGridTier-1) * self.m_iRequiredPetTalentPointsPerTier )
end
function CLClient:GetSpecSpentTalentPoints( iClassIndex, iSpecIndex, iGridTier )
	local iSpentTalentPoints = 0
	
	self.m_mapKnownTalents:EnumCallback(
		function( hTalentDesc )
			if ( hTalentDesc:GetClassIndex() ~= iClassIndex or hTalentDesc:GetSpecIndex() ~= iSpecIndex ) then
				return
			end
			if ( iGridTier == nil or hTalentDesc:GetGridTier() == iGridTier ) then
				iSpentTalentPoints = iSpentTalentPoints + hTalentDesc:GetCost()
			end
		end
	)
	self.m_mapPendingTalents:EnumCallback(
		function( hTalentDesc )
			if ( hTalentDesc:GetClassIndex() ~= iClassIndex or hTalentDesc:GetSpecIndex() ~= iSpecIndex ) then
				return
			end
			if ( iGridTier == nil or hTalentDesc:GetGridTier() == iGridTier ) then
				local iPendingCost = hTalentDesc:GetCost()
				local iKnownCost = 0
				if ( self.m_mapKnownTalents:HasTalent(hTalentDesc:GetClassIndex(), hTalentDesc:GetSpecIndex(),
													  hTalentDesc:GetGridTier(), hTalentDesc:GetGridSlot()) ) then
					iKnownCost = self.m_mapKnownTalents:GetTalentDesc( hTalentDesc:GetClassIndex(), hTalentDesc:GetSpecIndex(),
																	   hTalentDesc:GetGridTier(), hTalentDesc:GetGridSlot() ):GetCost()
				end
				iSpentTalentPoints = iSpentTalentPoints + (iPendingCost - iKnownCost)
			end
		end
	)

	return iSpentTalentPoints
end

function CLClient:AddPendingTalent( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	-- Get Talent Descriptor
	local hTalentDesc = CLDataTalents:GetInstance():GetTalentDesc( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	
	-- Check if we have enough points
	if hTalentDesc:IsPetTalent() then
		if ( self:GetRemainingPetTalentPoints() <= 0 ) then
			return
		end
	else
		if ( self:GetRemainingTalentPoints() <= 0 ) then
			return
		end
	end
	
	-- Check Grid Tier Requirement
	local iSpecSpentTalentPoints = self:GetSpecSpentTalentPoints( iClassIndex, iSpecIndex )
	local iTierRequiredTalentPoints = 0
	if hTalentDesc:IsPetTalent() then
		iTierRequiredTalentPoints = self:GetRequiredPetTalentPoints( iGridTier )
	else
		iTierRequiredTalentPoints = self:GetRequiredTalentPoints( iGridTier )
	end
	if ( iSpecSpentTalentPoints < iTierRequiredTalentPoints ) then
		return
	end
	
	-- Check Talent Requirement
	local iRequiredTalentGridTier, iRequiredTalentGridSlot = hTalentDesc:GetRequiredTalent()
	if ( iRequiredTalentGridTier ~= 0 and iRequiredTalentGridSlot ~= 0 ) then
		-- Must be present
		local hRequiredTalentDesc = nil
		if ( self.m_mapPendingTalents:HasTalent(iClassIndex, iSpecIndex, iRequiredTalentGridTier, iRequiredTalentGridSlot) ) then
			hRequiredTalentDesc = self.m_mapPendingTalents:GetTalentDesc( iClassIndex, iSpecIndex, iRequiredTalentGridTier, iRequiredTalentGridSlot )
		elseif ( self.m_mapKnownTalents:HasTalent(iClassIndex, iSpecIndex, iRequiredTalentGridTier, iRequiredTalentGridSlot) ) then
			hRequiredTalentDesc = self.m_mapKnownTalents:GetTalentDesc( iClassIndex, iSpecIndex, iRequiredTalentGridTier, iRequiredTalentGridSlot )
		else
			return
		end
		-- Must be maxed
		if ( not hRequiredTalentDesc:IsMaxed() ) then
			return
		end
	end
	
	-- TalentSpell case
	if hTalentDesc:IsTalentSpell() then
		-- Check if TalentSpell is pending
		if ( self.m_mapPendingTalents:HasTalent(iClassIndex, iSpecIndex, iGridTier, iGridSlot) ) then
			return
		end
		
		-- Check if TalentSpell is known
		if ( self.m_mapKnownTalents:HasTalent(iClassIndex, iSpecIndex, iGridTier, iGridSlot) ) then
			return
		end
		
		-- Apply appropriate Rank
		local iRank = hTalentDesc:GetTalentSpellRankFromLevel( UnitLevel("player") )
		if ( iRank == 0 ) then
			return
		end
		hTalentDesc:SetCurrentRank( iRank )
		
		-- Add TalentSpell
		self.m_mapPendingTalents:AddTalent( hTalentDesc )
	
		return
	end
	
	-- Check if Talent is pending
	if ( self.m_mapPendingTalents:HasTalent(iClassIndex, iSpecIndex, iGridTier, iGridSlot) ) then
		local hPendingTalentDesc = self.m_mapPendingTalents:GetTalentDesc( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	
		-- Get current Rank
		local iRank = hPendingTalentDesc:GetCurrentRank()
		
		-- Check if already Maxed
		if ( iRank == hPendingTalentDesc:GetRankCount() ) then
			return
		end
	
		-- Upgrade Rank
		self.m_mapPendingTalents:SetTalentRank( iClassIndex, iSpecIndex, iGridTier, iGridSlot, iRank + 1 )
		
		return
	end
	
	-- Check if Talent is known
	if ( self.m_mapKnownTalents:HasTalent(iClassIndex, iSpecIndex, iGridTier, iGridSlot) ) then
		local hKnownTalentDesc = self.m_mapKnownTalents:GetTalentDesc( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
		
		-- Get current Rank
		local iRank = hKnownTalentDesc:GetCurrentRank()
		
		-- Check if already Maxed
		if ( iRank == hKnownTalentDesc:GetRankCount() ) then
			return
		end
		
		-- Upgrade Rank
		hTalentDesc:SetCurrentRank( iRank + 1 )
		
		-- Add Talent
		self.m_mapPendingTalents:AddTalent( hTalentDesc )
		
		return
	end
	
	-- Apply appropriate Rank
	hTalentDesc:SetCurrentRank( 1 )

	-- Add Talent
	self.m_mapPendingTalents:AddTalent( hTalentDesc )
end
function CLClient:RemovePendingTalent( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	-- Check if present
	if ( not self.m_mapPendingTalents:HasTalent(iClassIndex, iSpecIndex, iGridTier, iGridSlot) ) then
		return
	end
	local hTalentDesc = self.m_mapPendingTalents:GetTalentDesc( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	
	-- Get current Rank
	local iRank = hTalentDesc:GetCurrentRank()
	
	-- Check Grid Tier Requirement
	local iTierCount = CLDataTalents:GetInstance():GetGridHeight( iClassIndex, iSpecIndex )
	local iSpecSpentTalentPoints = 0
	for i = 1, iTierCount do
		local iThisTierTalentPoints = self:GetSpecSpentTalentPoints( iClassIndex, iSpecIndex, i )
		local iRequiredTalentPoints = 0
		if hTalentDesc:IsPetTalent() then
			iRequiredTalentPoints = self:GetRequiredPetTalentPoints(i)
		else
			iRequiredTalentPoints = self:GetRequiredTalentPoints(i)
		end
		if ( iThisTierTalentPoints > 0 and iSpecSpentTalentPoints < iRequiredTalentPoints ) then
			print( "Grid Tier Requirements Failed !" )
			return
		end
		iSpecSpentTalentPoints = iSpecSpentTalentPoints + iThisTierTalentPoints
		if ( i == iGridTier ) then
			iSpecSpentTalentPoints = iSpecSpentTalentPoints - 1
		end
	end
	
	-- Check Talent Requirement
	self.m_mapPendingTalents:EnumCallback(
		function( hDependentTalentDesc )
			local iRequiredTalentGridTier, iRequiredTalentGridSlot = hDependentTalentDesc:GetRequiredTalent()
			if ( iClassIndex == hDependentTalentDesc:GetClassIndex() and iSpecIndex == hDependentTalentDesc:GetSpecIndex() and
				 iGridTier == iRequiredTalentGridTier and iGridSlot == iRequiredTalentGridSlot ) then
				print( "Talent Requirements Failed !" )
				return
			end
		end
	)
	self.m_mapKnownTalents:EnumCallback(
		function( hDependentTalentDesc )
			local iRequiredTalentGridTier, iRequiredTalentGridSlot = hDependentTalentDesc:GetRequiredTalent()
			if ( iClassIndex == hDependentTalentDesc:GetClassIndex() and iSpecIndex == hDependentTalentDesc:GetSpecIndex() and
				 iGridTier == iRequiredTalentGridTier and iGridSlot == iRequiredTalentGridSlot ) then
				print( "Talent Requirements Failed !" )
				return
			end
		end
	)
	
	-- TalentSpell & Remove cases
	if ( hTalentDesc:IsTalentSpell() or (iRank == 1) ) then
		-- Remove Talent
		self.m_mapPendingTalents:RemoveTalent( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
		
		return
	end
	
	-- Check if Talent is known
	if ( self.m_mapKnownTalents:HasTalent(iClassIndex, iSpecIndex, iGridTier, iGridSlot) ) then
		local hKnownTalentDesc = self.m_mapKnownTalents:GetTalentDesc( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	
		-- Get known Rank
		local iKnownRank = hKnownTalentDesc:GetCurrentRank()
		
		-- Check if it matches previous Rank
		if ( iKnownRank == (iRank - 1) ) then
			-- Remove Talent
			self.m_mapPendingTalents:RemoveTalent( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
			
			return
		end
	end
	
	-- Downgrade Rank
	self.m_mapPendingTalents:SetTalentRank( iClassIndex, iSpecIndex, iGridTier, iGridSlot, iRank - 1 )
end

-------------------------------------------------------------------------------------------------------------------
-- CLClient : Methods - Glyphs
function CLClient:GetKnownGlyphs()
	return self.m_mapKnownGlyphs
end
function CLClient:GetPendingGlyphs()
	return self.m_mapPendingGlyphs
end

function CLClient:GetFreeGlyphMajorSlots()
	return self.m_iFreeGlyphMajorSlots
end
function CLClient:GetFreeGlyphMinorSlots()
	return self.m_iFreeGlyphMinorSlots
end
function CLClient:GetSpentGlyphMajorSlots()
	return self.m_mapPendingGlyphs:GetGlyphMajorSlots()
end
function CLClient:GetSpentGlyphMinorSlots()
	return self.m_mapPendingGlyphs:GetGlyphMinorSlots()
end
function CLClient:GetRemainingGlyphMajorSlots()
	return ( self:GetFreeGlyphMajorSlots() - self:GetSpentGlyphMajorSlots() )
end
function CLClient:GetRemainingGlyphMinorSlots()
	return ( self:GetFreeGlyphMinorSlots() - self:GetSpentGlyphMinorSlots() )
end

function CLClient:AddPendingGlyph( iClassIndex, iSpecIndex, iGlyphIndex )
	-- Get Glyph Descriptor
	local hGlyphDesc = CLDataGlyphs:GetInstance():GetGlyphDesc( iClassIndex, iSpecIndex, iGlyphIndex )
	
	-- Check if we have a free slot
	if hGlyphDesc:IsMajor() then
		if ( self:GetRemainingGlyphMajorSlots() <= 0 ) then
			return
		end
	else
		if ( self:GetRemainingGlyphMinorSlots() <= 0 ) then
			return
		end
	end
	
	-- Check if Glyph is pending
	if ( self.m_mapPendingGlyphs:HasGlyph(iClassIndex, iSpecIndex, iGlyphIndex) ) then
		return
	end
	
	-- Check if Glyph is known
	if ( self.m_mapKnownGlyphs:HasGlyph(iClassIndex, iSpecIndex, iGlyphIndex) ) then
		return
	end
	
	-- Add Glyph
	self.m_mapPendingGlyphs:AddGlyph( hGlyphDesc )
end
function CLClient:RemovePendingGlyph( iClassIndex, iSpecIndex, iGlyphIndex )
	self.m_mapPendingGlyphs:RemoveGlyph( iClassIndex, iSpecIndex, iGlyphIndex )
end

-------------------------------------------------------------------------------------------------------------------
-- CLClient : Initialization
function CLClient:Initialize()
	if ( self.m_hAIOHandlers ~= nil ) then
		return
	end
	local hThis = self
	
	-- Async IO
	self.m_strAIOHandlerName = "ClassLessHandler"
	self.m_hAIOHandlers = AIO.AddHandlers( self.m_strAIOHandlerName, {} )
	
		-- OnClientInit
	self.m_hAIOHandlers.OnClientInit = function( hPlayer, iFreeSpellPoints, iFreePetSpellPoints,
														  iFreeTalentPoints, iFreePetTalentPoints,
														  iRequiredTalentPointsPerTier, iRequiredPetTalentPointsPerTier,
														  iFreeGlyphMajorSlots, iFreeGlyphMinorSlots, iResetCost,
														  arrEncodedSpells, arrEncodedTalents, arrEncodedGlyphs, strServerToken )
		print( "[ClassLess][AIO] (Client-Side) OnClientInit !" )
		
		-- Save Session Token
		hThis.m_strClientToken = strServerToken
		
		-- Save Server Data
		hThis.m_iFreeSpellPoints = iFreeSpellPoints
		hThis.m_iFreePetSpellPoints = iFreePetSpellPoints
		hThis.m_iFreeTalentPoints = iFreeTalentPoints
		hThis.m_iFreePetTalentPoints = iFreePetTalentPoints
		hThis.m_iRequiredTalentPointsPerTier = iRequiredTalentPointsPerTier
		hThis.m_iRequiredPetTalentPointsPerTier = iRequiredPetTalentPointsPerTier
		hThis.m_iFreeGlyphMajorSlots = iFreeGlyphMajorSlots
		hThis.m_iFreeGlyphMinorSlots = iFreeGlyphMinorSlots
		hThis.m_iResetCost = iResetCost

		hThis.m_mapKnownSpells:Decode( arrEncodedSpells )
		hThis.m_mapKnownTalents:Decode( arrEncodedTalents )
		hThis.m_mapKnownGlyphs:Decode( arrEncodedGlyphs )
		
		-- Build UI
		self.m_hCLUIToolTip = CLUIToolTip()
		self.m_hCLUIToolTip:Initialize()
		
		self.m_hCLUIMainFrame = CLUIMainFrame()
		self.m_hCLUIMainFrame:Initialize()
		
		self.m_hCLUIMainButton = CLUIMainButton()
		self.m_hCLUIMainButton:Initialize()
		
		print( "[ClassLess][AIO] Client Initialization Completed !" )
	end
	
	print( "[ClassLess][Client] AIO Handler OnClientInit Registered !" )
	
		-- OnCommitAbilities
	self.m_hAIOHandlers.OnCommitAbilities = function( hPlayer, iFreeSpellPoints, iFreePetSpellPoints,
															   iFreeTalentPoints, iFreePetTalentPoints,
															   iFreeGlyphMajorSlots, iFreeGlyphMinorSlots,
															   arrEncodedSpells, arrEncodedTalents, arrEncodedGlyphs )
		print( "[ClassLess][AIO] (Client-Side) OnCommitAbilities !" )
		
		-- Update Server Data
		hThis.m_iFreeSpellPoints = iFreeSpellPoints
		hThis.m_iFreePetSpellPoints = iFreePetSpellPoints
		hThis.m_iFreeTalentPoints = iFreeTalentPoints
		hThis.m_iFreePetTalentPoints = iFreePetTalentPoints
		hThis.m_iFreeGlyphMajorSlots = iFreeGlyphMajorSlots
		hThis.m_iFreeGlyphMinorSlots = iFreeGlyphMinorSlots
	
		hThis.m_mapKnownSpells:Decode( arrEncodedSpells )
		hThis.m_mapKnownTalents:Decode( arrEncodedTalents )
		hThis.m_mapKnownGlyphs:Decode( arrEncodedGlyphs )
		
		-- Update UI
		hThis.m_hCLUIMainFrame:Update()
	end
	
	print( "[ClassLess][Client] AIO Handler OnCommitAbilities Registered !" )
	
		-- OnResetAbilities
	self.m_hAIOHandlers.OnResetAbilities = function( hPlayer, iFreeSpellPoints, iFreePetSpellPoints,
															  iFreeTalentPoints, iFreePetTalentPoints,
															  iFreeGlyphMajorSlots, iFreeGlyphMinorSlots, iResetCost )
		print( "[ClassLess][AIO] (Client-Side) OnResetAbilities !" )
		
		-- Update Server Data
		hThis.m_iFreeSpellPoints = iFreeSpellPoints
		hThis.m_iFreePetSpellPoints = iFreePetSpellPoints
		hThis.m_iFreeTalentPoints = iFreeTalentPoints
		hThis.m_iFreePetTalentPoints = iFreePetTalentPoints
		hThis.m_iFreeGlyphMajorSlots = iFreeGlyphMajorSlots
		hThis.m_iFreeGlyphMinorSlots = iFreeGlyphMinorSlots
		hThis.m_iResetCost = iResetCost
	
		hThis.m_mapKnownSpells:Clear()
		hThis.m_mapKnownTalents:Clear()
		hThis.m_mapKnownGlyphs:Clear()
		
		-- Update UI
		hThis.m_hCLUIMainFrame:Update()
	end
	
	print( "[ClassLess][Client] AIO Handler OnResetAbilities Registered !" )
	
		-- OnLevelChange
	self.m_hAIOHandlers.OnLevelChange = function( hPlayer, iFreeSpellPoints, iFreePetSpellPoints,
														   iFreeTalentPoints, iFreePetTalentPoints,
														   iFreeGlyphMajorSlots, iFreeGlyphMinorSlots,
														   arrEncodedSpells, arrEncodedTalents )
		print( "[ClassLess][AIO] (Client-Side) OnLevelChange !" )
		
		-- Flush Pending Abilities
		hThis.m_mapPendingSpells:Clear()
		hThis.m_mapPendingTalents:Clear()
		hThis.m_mapPendingGlyphs:Clear()
		
		-- Update Server Data
		hThis.m_iFreeSpellPoints = iFreeSpellPoints
		hThis.m_iFreePetSpellPoints = iFreePetSpellPoints
		hThis.m_iFreeTalentPoints = iFreeTalentPoints
		hThis.m_iFreePetTalentPoints = iFreePetTalentPoints
		hThis.m_iFreeGlyphMajorSlots = iFreeGlyphMajorSlots
		hThis.m_iFreeGlyphMinorSlots = iFreeGlyphMinorSlots
	
		hThis.m_mapKnownSpells:Decode( arrEncodedSpells )
		hThis.m_mapKnownTalents:Decode( arrEncodedTalents )
		
		-- Update UI
		hThis.m_hCLUIMainFrame:Update()
	end
	
	print( "[ClassLess][Client] AIO Handler OnLevelChange Registered !" )
end

-------------------------------------------------------------------------------------------------------------------
-- Entry Point
print( "[ClassLess][Client] Client Initialization ..." )

local hClientInstance = CLClient:GetInstance()

print( "[ClassLess][Client] Client Initialization Complete !" )

-------------------------------------------------------------------------------------------------------------------
-- Hook : Talent Frame
function ToggleTalentFrame()
	hClientInstance:GetMainFrame():Toggle()
end

