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

-------------------------------------------------------------------------------------------------------------------
-- Client / Server Setup

-- Client-side Only !
if AIO.AddAddon() then
	return
end

-------------------------------------------------------------------------------------------------------------------
-- Constants

-------------------------------------------------------------------------------------------------------------------
-- ClassLessClient - Declaration
ClassLessClient = class({
	-- Static Members
})

function ClassLessClient:init()
	-- Session Token
	self.m_strClientToken = nil
	
	-- Async IO
	self.m_strAIOHandlerName = nil
	self.m_hAIOHandlers = nil
	
	-- Server Data (Read-Only !)
	self.m_iFreeSpellPoints = nil
	self.m_iFreeTalentPoints = nil
	self.m_iRequiredTalentPointsPerTier = nil
	self.m_iFreeGlyphMajorSlots = nil
	self.m_iFreeGlyphMinorSlots = nil
	self.m_iResetCost = nil
	
	self.m_arrKnownSpells = nil
	self.m_arrKnownTalents = nil
	self.m_arrKnownGlyphs = nil
	
	-- Client Data
	self.m_hCLDataSpells = nil
	self.m_hCLDataTalents = nil
	self.m_hCLDataGlyphs = nil
	
	self.m_arrPendingSpells = {}
	self.m_arrPendingTalents = {}
	self.m_arrPendingGlyphs = {}

	-- UI
	self.m_hCLMainButton = nil
	self.m_hCLMainFrame = nil
	self.m_hCLMainToolTip = nil
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessClient : Methods - General
function ClassLessClient:GetResetCost()
	return self.m_iResetCost
end

function ClassLessClient:GetMainFrame()
	return self.m_hCLMainFrame
end
function ClassLessClient:GetMainToolTip()
	return self.m_hCLMainToolTip
end
function ClassLessClient:GetMainPointsFrame()
	return self.m_hCLMainFrame.m_hMainPointsFrame
end

function ClassLessClient:ApplyAbilities()
	-- Server-side : Call CommitAbilities
	AIO.Handle( self.m_strAIOHandlerName, "CommitAbilities",
		ClassLessSpellDesc:EncodeSpells( self.m_arrPendingSpells ),
		ClassLessTalentDesc:EncodeTalents( self.m_arrPendingTalents ),
		ClassLessGlyphDesc:EncodeGlyphs( self.m_arrPendingGlyphs ),
		self.m_strClientToken
	)
	
	-- Flush Pending Abilities
	self.m_arrPendingSpells = {}
	self.m_arrPendingTalents = {}
	self.m_arrPendingGlyphs = {}
end
function ClassLessClient:CancelAbilities()
	-- Flush Pending Abilities
	self.m_arrPendingSpells = {}
	self.m_arrPendingTalents = {}
	self.m_arrPendingGlyphs = {}
end
function ClassLessClient:ResetAbilities()
	-- Server-side : Call ResetAbilities
	AIO.Handle( self.m_strAIOHandlerName, "ResetAbilities", self.m_strClientToken )
	
	-- Flush Pending Abilities
	self.m_arrPendingSpells = {}
	self.m_arrPendingTalents = {}
	self.m_arrPendingGlyphs = {}
end

function ClassLessClient:GetAbilityLink( iAbilityID )
	local strLink = GetSpellLink( iAbilityID )
	if ( strLink == nil or strLink == "" ) then
		strLink = string.format( "|cff71d5ff|Hspell:%d:|h[%s]|h|r", iAbilityID, GetSpellInfo(iAbilityID) )
	end
	return strLink
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessClient : Methods - Spells
function ClassLessClient:GetDataSpells()
	return self.m_hCLDataSpells
end

function ClassLessClient:GetKnownSpellCount()
	return #( self.m_arrKnownSpells )
end
function ClassLessClient:GetKnownSpellDesc( iIndex )
	return self.m_arrKnownSpells[iIndex]
end

function ClassLessClient:IsSpellKnown( iClassIndex, iSpecIndex, iSpellIndex )
	return ( self:GetKnownSpellIndex(iClassIndex, iSpecIndex, iSpellIndex) ~= 0 )
end

function ClassLessClient:GetKnownSpellIndex( iClassIndex, iSpecIndex, iSpellIndex )
	local iSpellCount = self:GetKnownSpellCount()
	for i = 1, iSpellCount do
		local hSpellDesc = self:GetKnownSpellDesc( i )
		if ( iClassIndex == hSpellDesc:GetClassIndex() and iSpecIndex == hSpellDesc:GetSpecIndex() and
			 iSpellIndex == hSpellDesc:GetSpellIndex() ) then
			return i
		end
	end
	return 0
end

function ClassLessClient:GetPendingSpellCount()
	return #( self.m_arrPendingSpells )
end
function ClassLessClient:GetPendingSpellDesc( iIndex )
	return self.m_arrPendingSpells[iIndex]
end

function ClassLessClient:IsSpellPending( iClassIndex, iSpecIndex, iSpellIndex )
	return ( self:GetPendingSpellIndex(iClassIndex, iSpecIndex, iSpellIndex) ~= 0 )
end

function ClassLessClient:GetPendingSpellIndex( iClassIndex, iSpecIndex, iSpellIndex )
	local iSpellCount = self:GetPendingSpellCount()
	for i = 1, iSpellCount do
		local hSpellDesc = self:GetPendingSpellDesc( i )
		if ( iClassIndex == hSpellDesc:GetClassIndex() and iSpecIndex == hSpellDesc:GetSpecIndex() and
			 iSpellIndex == hSpellDesc:GetSpellIndex() ) then
			return i
		end
	end
	return 0
end

function ClassLessClient:GetFreeSpellPoints()
	return self.m_iFreeSpellPoints
end
function ClassLessClient:GetSpentSpellPoints()
	return self:GetPendingSpellCount()
end
function ClassLessClient:GetRemainingSpellPoints()
	return ( self:GetFreeSpellPoints() - self:GetSpentSpellPoints() )
end

function ClassLessClient:AddPendingSpell( iClassIndex, iSpecIndex, iSpellIndex )
	-- Check if we have enough points
	if ( self:GetRemainingSpellPoints() <= 0 ) then
		return
	end
	
	-- Check if Spell is pending
	if self:IsSpellPending(iClassIndex, iSpecIndex, iSpellIndex) then
		return
	end
	
	-- Check if Spell is known
	if self:IsSpellKnown(iClassIndex, iSpecIndex, iSpellIndex) then
		return
	end
	
	-- Get Spell Descriptor
	local hSpellDesc = self.m_hCLDataSpells:GetSpellDesc( iClassIndex, iSpecIndex, iSpellIndex )
	
	-- Apply appropriate Rank
	local iRank = hSpellDesc:GetRankFromLevel( UnitLevel("player") )
	if ( iRank == 0 ) then
		return
	end
	hSpellDesc:SetCurrentRank( iRank )
	
	-- Add Spell
	table.insert( self.m_arrPendingSpells, hSpellDesc )
end
function ClassLessClient:RemovePendingSpell( iClassIndex, iSpecIndex, iSpellIndex )
	-- Retrieve Index
	local iIndex = self:GetPendingSpellIndex( iClassIndex, iSpecIndex, iSpellIndex )
	if ( iIndex == 0 ) then
		return
	end
	
	-- Remove Spell
	table.remove( self.m_arrPendingSpells, iIndex )
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessClient : Methods - Talents
function ClassLessClient:GetDataTalents()
	return self.m_hCLDataTalents
end

function ClassLessClient:GetKnownTalentCount()
	return #( self.m_arrKnownTalents )
end
function ClassLessClient:GetKnownTalentDesc( iIndex )
	return self.m_arrKnownTalents[iIndex]
end

function ClassLessClient:IsTalentKnown( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	return ( self:GetKnownTalentIndex(iClassIndex, iSpecIndex, iGridTier, iGridSlot) ~= 0 )
end

function ClassLessClient:GetKnownTalentIndex( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	local iTalentCount = self:GetKnownTalentCount()
	for i = 1, iTalentCount do
		local hTalentDesc = self:GetKnownTalentDesc( i )
		if ( iClassIndex == hTalentDesc:GetClassIndex() and iSpecIndex == hTalentDesc:GetSpecIndex() and
			 iGridTier == hTalentDesc:GetGridTier() and iGridSlot == hTalentDesc:GetGridSlot() ) then
			return i
		end
	end
	return 0
end

function ClassLessClient:GetPendingTalentCount()
	return #( self.m_arrPendingTalents )
end
function ClassLessClient:GetPendingTalentDesc( iIndex )
	return self.m_arrPendingTalents[iIndex]
end

function ClassLessClient:IsTalentPending( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	return ( self:GetPendingTalentIndex(iClassIndex, iSpecIndex, iGridTier, iGridSlot) ~= 0 )
end

function ClassLessClient:GetPendingTalentIndex( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	local iTalentCount = self:GetPendingTalentCount()
	for i = 1, iTalentCount do
		local hTalentDesc = self:GetPendingTalentDesc( i )
		if ( iClassIndex == hTalentDesc:GetClassIndex() and iSpecIndex == hTalentDesc:GetSpecIndex() and
			 iGridTier == hTalentDesc:GetGridTier() and iGridSlot == hTalentDesc:GetGridSlot() ) then
			return i
		end
	end
	return 0
end

function ClassLessClient:GetFreeTalentPoints()
	return self.m_iFreeTalentPoints
end
function ClassLessClient:GetSpentTalentPoints()
	local iSpentTalentPoints = 0
	local iTalentCount = self:GetPendingTalentCount()
	for i = 1, iTalentCount do
		local hTalentDesc = self:GetPendingTalentDesc( i )
		if ( hTalentDesc:IsTalentSpell() ) then
			iSpentTalentPoints = iSpentTalentPoints + 1
		else
			local iPendingRank = hTalentDesc:GetCurrentRank()
			local iKnownRank = 0
			local iKnownIndex = self:GetKnownTalentIndex( hTalentDesc:GetClassIndex(), hTalentDesc:GetSpecIndex(),
														  hTalentDesc:GetGridTier(), hTalentDesc:GetGridSlot() )
			if ( iKnownIndex ~= 0 ) then
				iKnownRank = self:GetKnownTalentDesc(iKnownIndex):GetCurrentRank()
			end
			iSpentTalentPoints = iSpentTalentPoints + (iPendingRank - iKnownRank)
		end
	end
	return iSpentTalentPoints
end
function ClassLessClient:GetRemainingTalentPoints()
	return ( self:GetFreeTalentPoints() - self:GetSpentTalentPoints() )
end

function ClassLessClient:GetRequiredTalentPoints( iGridTier )
	return ( (iGridTier-1) * self.m_iRequiredTalentPointsPerTier )
end
function ClassLessClient:GetSpecAllocatedTalentPoints( iClassIndex, iSpecIndex, iGridTier )
	local iAllocatedTalentPoints = 0
	local iKnownTalentCount = self:GetKnownTalentCount()
	for i = 1, iKnownTalentCount do
		local hTalentDesc = self:GetKnownTalentDesc( i )
		if ( hTalentDesc:GetClassIndex() == iClassIndex and hTalentDesc:GetSpecIndex() == iSpecIndex ) then
			if ( iGridTier == nil or hTalentDesc:GetGridTier() == iGridTier ) then
				iAllocatedTalentPoints = iAllocatedTalentPoints + hTalentDesc:GetCurrentCost()
			end
		end
	end
	local iPendingTalentCount = self:GetPendingTalentCount()
	for i = 1, iPendingTalentCount do
		local hTalentDesc = self:GetPendingTalentDesc( i )
		if ( hTalentDesc:GetClassIndex() == iClassIndex and hTalentDesc:GetSpecIndex() == iSpecIndex ) then
			if ( iGridTier == nil or hTalentDesc:GetGridTier() == iGridTier ) then
				iAllocatedTalentPoints = iAllocatedTalentPoints + hTalentDesc:GetCurrentCost()
			end
		end
	end
	return iAllocatedTalentPoints
end

function ClassLessClient:AddPendingTalent( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	-- Get Talent Descriptor
	local hTalentDesc = self.m_hCLDataTalents:GetTalentDesc( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	
	-- Check if we have enough points
	if ( self:GetRemainingTalentPoints() <= 0 ) then
		return
	end
	
	-- Check Grid Tier Requirement
	local iSpecAllocatedTalentPoints = self:GetSpecAllocatedTalentPoints( iClassIndex, iSpecIndex )
	local iTierRequiredTalentPoints = self:GetRequiredTalentPoints( iGridTier )
	if ( iSpecAllocatedTalentPoints < iTierRequiredTalentPoints ) then
		return
	end
	
	-- Check Talent Requirement
	local iRequiredTalentGridTier, iRequiredTalentGridSlot = hTalentDesc:GetRequiredTalent()
	if ( iRequiredTalentGridTier ~= 0 and iRequiredTalentGridSlot ~= 0 ) then
		-- Must be present
		local iRequiredTalentIndex = self:GetPendingTalentIndex( iClassIndex, iSpecIndex, iRequiredTalentGridTier, iRequiredTalentGridSlot )
		if ( iRequiredTalentIndex ~= 0 ) then
			hRequiredTalentDesc = self:GetPendingTalentDesc( iRequiredTalentIndex )
		else
			iRequiredTalentIndex = self:GetKnownTalentIndex( iClassIndex, iSpecIndex, iRequiredTalentGridTier, iRequiredTalentGridSlot )
			if ( iRequiredTalentIndex ~= 0 ) then
				hRequiredTalentDesc = self:GetKnownTalentDesc( iRequiredTalentIndex )
			else
				return
			end
		end
		-- Must be maxed
		if ( not hRequiredTalentDesc:IsMaxed() ) then
			return
		end
	end
	
	-- TalentSpell case
	if hTalentDesc:IsTalentSpell() then
		-- Check if TalentSpell is pending
		if self:IsTalentPending(iClassIndex, iSpecIndex, iGridTier, iGridSlot) then
			return
		end
		
		-- Check if TalentSpell is known
		if self:IsTalentKnown(iClassIndex, iSpecIndex, iGridTier, iGridSlot) then
			return
		end
		
		-- Apply appropriate Rank
		local iRank = hTalentDesc:GetTalentSpellRankFromLevel( UnitLevel("player") )
		if ( iRank == 0 ) then
			return
		end
		hTalentDesc:SetCurrentRank( iRank )
		
		-- Add TalentSpell
		table.insert( self.m_arrPendingTalents, hTalentDesc )
	
		return
	end
	
	-- Check if Talent is pending
	local iIndex = self:GetPendingTalentIndex( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	if ( iIndex ~= 0 ) then
		-- Get current Rank
		local iRank = self.m_arrPendingTalents[iIndex]:GetCurrentRank()
		
		-- Check if already Maxed
		if ( iRank == self.m_arrPendingTalents[iIndex]:GetRankCount() ) then
			return
		end
	
		-- Upgrade Rank
		self.m_arrPendingTalents[iIndex]:SetCurrentRank( iRank + 1 )
		
		return
	end
	
	-- Check if Talent is known
	iIndex = self:GetKnownTalentIndex( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	if ( iIndex ~= 0 ) then
		-- Get current Rank
		local iRank = self.m_arrKnownTalents[iIndex]:GetCurrentRank()
		
		-- Check if already Maxed
		if ( iRank == self.m_arrKnownTalents[iIndex]:GetRankCount() ) then
			return
		end
		
		-- Upgrade Rank
		hTalentDesc:SetCurrentRank( iRank + 1 )
		
		-- Add Talent
		table.insert( self.m_arrPendingTalents, hTalentDesc )
		
		return
	end
	
	-- Apply appropriate Rank
	hTalentDesc:SetCurrentRank( 1 )

	-- Add Talent
	table.insert( self.m_arrPendingTalents, hTalentDesc )
end
function ClassLessClient:RemovePendingTalent( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	-- Retrieve Index
	local iIndex = self:GetPendingTalentIndex( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	if ( iIndex == 0 ) then
		return
	end
	
	-- Get current Rank
	local iRank = self.m_arrPendingTalents[iIndex]:GetCurrentRank()
	
	-- Check Grid Tier Requirement
	local iTierCount = self.m_hCLDataTalents:GetGridHeight( iClassIndex, iSpecIndex )
	local iSpecAllocatedTalentPoints = 0
	for i = 1, iTierCount do
		local iThisTierTalentPoints = self:GetSpecAllocatedTalentPoints( iClassIndex, iSpecIndex, i )
		if ( iThisTierTalentPoints > 0 and iSpecAllocatedTalentPoints < self:GetRequiredTalentPoints(i) ) then
			print( "Grid Tier Requirements Failed !" )
			return
		end
		iSpecAllocatedTalentPoints = iSpecAllocatedTalentPoints + iThisTierTalentPoints
		if ( i == iGridTier ) then
			iSpecAllocatedTalentPoints = iSpecAllocatedTalentPoints - 1
		end
	end
	
	-- Check Talent Requirement
	iPendingTalentCount = self:GetPendingTalentCount()
	for i = 1, iPendingTalentCount do
		local hTalentDesc = self:GetPendingTalentDesc( i )
		local iRequiredTalentGridTier, iRequiredTalentGridSlot = hTalentDesc:GetRequiredTalent()
		if ( iClassIndex == hTalentDesc:GetClassIndex() and iSpecIndex == hTalentDesc:GetSpecIndex() and
			 iGridTier == iRequiredTalentGridTier and iGridSlot == iRequiredTalentGridSlot ) then
			print( "Talent Requirements Failed !" )
			return
		end
	end
	
	-- TalentSpell & Remove cases
	if ( self.m_arrPendingTalents[iIndex]:IsTalentSpell() or (iRank == 1) ) then
		-- Remove Talent
		table.remove( self.m_arrPendingTalents, iIndex )
		
		return
	end
	
	-- Check if Talent is known
	local iKnownIndex = self:GetKnownTalentIndex( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	if ( iKnownIndex ~= 0 ) then
		-- Get known Rank
		local iKnownRank = self.m_arrKnownTalents[iKnownIndex]:GetCurrentRank()
		
		-- Check if it matches previous Rank
		if ( iKnownRank == (iRank - 1) ) then
			-- Remove Talent
			table.remove( self.m_arrPendingTalents, iIndex )
			
			return
		end
	end
	
	-- Downgrade Rank
	self.m_arrPendingTalents[iIndex]:SetCurrentRank( iRank - 1 )
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessClient : Methods - Glyphs
function ClassLessClient:GetDataGlyphs()
	return self.m_hCLDataGlyphs
end

function ClassLessClient:GetKnownGlyphCount()
	return #( self.m_arrKnownGlyphs )
end
function ClassLessClient:GetKnownGlyphDesc( iIndex )
	return self.m_arrKnownGlyphs[iIndex]
end

function ClassLessClient:IsGlyphKnown( iClassIndex, iSpecIndex, iGlyphIndex )
	return ( self:GetKnownGlyphIndex(iClassIndex, iSpecIndex, iGlyphIndex) ~= 0 )
end

function ClassLessClient:GetKnownGlyphIndex( iClassIndex, iSpecIndex, iGlyphIndex )
	local iGlyphCount = self:GetKnownGlyphCount()
	for i = 1, iGlyphCount do
		local hGlyphDesc = self:GetKnownGlyphDesc( i )
		if ( iClassIndex == hGlyphDesc:GetClassIndex() and iSpecIndex == hGlyphDesc:GetSpecIndex() and
			 iGlyphIndex == hGlyphDesc:GetGlyphIndex() ) then
			return i
		end
	end
	return 0
end

function ClassLessClient:GetPendingGlyphCount()
	return #( self.m_arrPendingGlyphs )
end
function ClassLessClient:GetPendingGlyphDesc( iIndex )
	return self.m_arrPendingGlyphs[iIndex]
end

function ClassLessClient:IsGlyphPending( iClassIndex, iSpecIndex, iGlyphIndex )
	return ( self:GetPendingGlyphIndex(iClassIndex, iSpecIndex, iGlyphIndex) ~= 0 )
end

function ClassLessClient:GetPendingGlyphIndex( iClassIndex, iSpecIndex, iGlyphIndex )
	local iGlyphCount = self:GetPendingGlyphCount()
	for i = 1, iGlyphCount do
		local hGlyphDesc = self:GetPendingGlyphDesc( i )
		if ( iClassIndex == hGlyphDesc:GetClassIndex() and iSpecIndex == hGlyphDesc:GetSpecIndex() and
			 iGlyphIndex == hGlyphDesc:GetGlyphIndex() ) then
			return i
		end
	end
	return 0
end

function ClassLessClient:GetFreeGlyphMajorSlots()
	return self.m_iFreeGlyphMajorSlots
end
function ClassLessClient:GetFreeGlyphMinorSlots()
	return self.m_iFreeGlyphMinorSlots
end
function ClassLessClient:GetSpentGlyphMajorSlots()
	local iGlyphCount = self:GetPendingGlyphCount()
	local iSpentGlyphSlots = 0
	for i = 1, iGlyphCount do
		if ( self:GetPendingGlyphDesc(i):IsMajor() ) then
			iSpentGlyphSlots = iSpentGlyphSlots + 1
		end
	end
	return iSpentGlyphSlots
end
function ClassLessClient:GetSpentGlyphMinorSlots()
	local iGlyphCount = self:GetPendingGlyphCount()
	local iSpentGlyphSlots = 0
	for i = 1, iGlyphCount do
		if ( not self:GetPendingGlyphDesc(i):IsMajor() ) then
			iSpentGlyphSlots = iSpentGlyphSlots + 1
		end
	end
	return iSpentGlyphSlots
end
function ClassLessClient:GetRemainingGlyphMajorSlots()
	return ( self:GetFreeGlyphMajorSlots() - self:GetSpentGlyphMajorSlots() )
end
function ClassLessClient:GetRemainingGlyphMinorSlots()
	return ( self:GetFreeGlyphMinorSlots() - self:GetSpentGlyphMinorSlots() )
end

function ClassLessClient:AddPendingGlyph( iClassIndex, iSpecIndex, iGlyphIndex )
	-- Get Glyph Descriptor
	local hGlyphDesc = self.m_hCLDataGlyphs:GetGlyphDesc( iClassIndex, iSpecIndex, iGlyphIndex )
	
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
	if self:IsGlyphPending(iClassIndex, iSpecIndex, iGlyphIndex) then
		return
	end
	
	-- Check if Glyph is known
	if self:IsGlyphKnown(iClassIndex, iSpecIndex, iGlyphIndex) then
		return
	end
	
	-- Add Glyph
	table.insert( self.m_arrPendingGlyphs, hGlyphDesc )
end
function ClassLessClient:RemovePendingGlyph( iClassIndex, iSpecIndex, iGlyphIndex )
	-- Retrieve Index
	local iIndex = self:GetPendingGlyphIndex( iClassIndex, iSpecIndex, iGlyphIndex )
	if ( iIndex == 0 ) then
		return
	end
	
	-- Remove Glyph
	table.remove( self.m_arrPendingGlyphs, iIndex )
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessClient : Initialization
function ClassLessClient:Initialize()
	if ( self.m_hAIOHandlers ~= nil ) then
		return
	end
	local hThis = self
	
	-- Async IO
	self.m_strAIOHandlerName = "ClassLessHandler"
	self.m_hAIOHandlers = AIO.AddHandlers( self.m_strAIOHandlerName, {} )
	
		-- OnClientInit
	self.m_hAIOHandlers.OnClientInit = function( hPlayer, iFreeSpellPoints, iFreeTalentPoints, iRequiredTalentPointsPerTier, iFreeGlyphMajorSlots, iFreeGlyphMinorSlots, iResetCost,
														  arrEncodedSpells, arrEncodedTalents, arrEncodedGlyphs, strServerToken )
		print( "[ClassLess][AIO] (Client-Side) OnClientInit !" )
		
		-- Save Session Token
		hThis.m_strClientToken = strServerToken
		
		-- Save Server Data
		hThis.m_iFreeSpellPoints = iFreeSpellPoints
		hThis.m_iFreeTalentPoints = iFreeTalentPoints
		hThis.m_iRequiredTalentPointsPerTier = iRequiredTalentPointsPerTier
		hThis.m_iFreeGlyphMajorSlots = iFreeGlyphMajorSlots
		hThis.m_iFreeGlyphMinorSlots = iFreeGlyphMinorSlots
		hThis.m_iResetCost = iResetCost

		hThis.m_arrKnownSpells = ClassLessSpellDesc:DecodeSpells( arrEncodedSpells )
		hThis.m_arrKnownTalents = ClassLessTalentDesc:DecodeTalents( arrEncodedTalents )
		hThis.m_arrKnownGlyphs = ClassLessGlyphDesc:DecodeGlyphs( arrEncodedGlyphs )
	
		-- Initialize Spell/Talent/Glyph Data
		self.m_hCLDataSpells = ClassLessDataSpells()
		self.m_hCLDataSpells:Initialize()
		
		self.m_hCLDataTalents = ClassLessDataTalents()
		self.m_hCLDataTalents:Initialize()
		
		self.m_hCLDataGlyphs = ClassLessDataGlyphs()
		self.m_hCLDataGlyphs:Initialize()
		
		-- Build UI
		self.m_hCLMainToolTip = ClassLessMainToolTip()
		self.m_hCLMainToolTip:Initialize()
		
		self.m_hCLMainFrame = ClassLessMainFrame()
		self.m_hCLMainFrame:Initialize()
		
		self.m_hCLMainButton = ClassLessMainButton()
		self.m_hCLMainButton:Initialize()
		
		print( "[ClassLess][AIO] Client Initialization Completed !" )
	end
	
	print( "[ClassLess][Client] AIO Handler OnClientInit Registered !" )
	
		-- OnCommitAbilities
	self.m_hAIOHandlers.OnCommitAbilities = function( hPlayer, iFreeSpellPoints, iFreeTalentPoints, iFreeGlyphMajorSlots, iFreeGlyphMinorSlots,
															   arrEncodedSpells, arrEncodedTalents, arrEncodedGlyphs )
		print( "[ClassLess][AIO] (Client-Side) OnCommitAbilities !" )
		
		-- Update Server Data
		hThis.m_iFreeSpellPoints = iFreeSpellPoints
		hThis.m_iFreeTalentPoints = iFreeTalentPoints
		hThis.m_iFreeGlyphMajorSlots = iFreeGlyphMajorSlots
		hThis.m_iFreeGlyphMinorSlots = iFreeGlyphMinorSlots
	
		hThis.m_arrKnownSpells = ClassLessSpellDesc:DecodeSpells( arrEncodedSpells )
		hThis.m_arrKnownTalents = ClassLessTalentDesc:DecodeTalents( arrEncodedTalents )
		hThis.m_arrKnownGlyphs = ClassLessGlyphDesc:DecodeGlyphs( arrEncodedGlyphs )
		
		-- Update UI
		hThis.m_hCLMainFrame:Update()
	end
	
	print( "[ClassLess][Client] AIO Handler OnCommitAbilities Registered !" )
	
		-- OnResetAbilities
	self.m_hAIOHandlers.OnResetAbilities = function( hPlayer, iFreeSpellPoints, iFreeTalentPoints, iFreeGlyphMajorSlots, iFreeGlyphMinorSlots, iResetCost )
		print( "[ClassLess][AIO] (Client-Side) OnResetAbilities !" )
		
		-- Update Server Data
		hThis.m_iFreeSpellPoints = iFreeSpellPoints
		hThis.m_iFreeTalentPoints = iFreeTalentPoints
		hThis.m_iFreeGlyphMajorSlots = iFreeGlyphMajorSlots
		hThis.m_iFreeGlyphMinorSlots = iFreeGlyphMinorSlots
		hThis.m_iResetCost = iResetCost
	
		hThis.m_arrKnownSpells = {}
		hThis.m_arrKnownTalents = {}
		hThis.m_arrKnownGlyphs = {}
		
		-- Update UI
		hThis.m_hCLMainFrame:Update()
	end
	
	print( "[ClassLess][Client] AIO Handler OnResetAbilities Registered !" )
	
		-- OnLevelChange
	self.m_hAIOHandlers.OnLevelChange = function( hPlayer, iFreeSpellPoints, iFreeTalentPoints, iFreeGlyphMajorSlots, iFreeGlyphMinorSlots, arrEncodedSpells, arrEncodedTalents )
		print( "[ClassLess][AIO] (Client-Side) OnLevelChange !" )
		
		-- Flush Pending Abilities
		hThis.m_arrPendingSpells = {}
		hThis.m_arrPendingTalents = {}
		hThis.m_arrPendingGlyphs = {}
		
		-- Update Server Data
		hThis.m_iFreeSpellPoints = iFreeSpellPoints
		hThis.m_iFreeTalentPoints = iFreeTalentPoints
		hThis.m_iFreeGlyphMajorSlots = iFreeGlyphMajorSlots
		hThis.m_iFreeGlyphMinorSlots = iFreeGlyphMinorSlots
	
		hThis.m_arrKnownSpells = ClassLessSpellDesc:DecodeSpells( arrEncodedSpells )
		hThis.m_arrKnownTalents = ClassLessTalentDesc:DecodeTalents( arrEncodedTalents )
		
		-- Update UI
		hThis.m_hCLMainFrame:Update()
	end
	
	print( "[ClassLess][Client] AIO Handler OnLevelChange Registered !" )
end

-------------------------------------------------------------------------------------------------------------------
-- Entry Point
print( "[ClassLess][Client] Client Initialization ..." )

CLClient = ClassLessClient()
CLClient:Initialize()

print( "[ClassLess][Client] Client Initialization Complete !" )

-------------------------------------------------------------------------------------------------------------------
-- Hook : Talent Frame
function ToggleTalentFrame()
	CLClient.m_hCLMainFrame:Toggle()
end

