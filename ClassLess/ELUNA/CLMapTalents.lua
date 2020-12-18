-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess : Talent Maps
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Requirements
local AIO = AIO or require("AIO")
if not class then require("class") end
if not CLClassCount then require("CLConstants") end

-------------------------------------------------------------------------------------------------------------------
-- Client / Server Setup

-- Needed on both sides !
if AIO.IsServer() then
	AIO.AddAddon()
end

-------------------------------------------------------------------------------------------------------------------
-- CLTalentDesc - Declaration
CLTalentDesc = class({
	-- Static Members
})

function CLTalentDesc:init( iClassIndex, iSpecIndex, iGridTier, iGridSlot,
							arrTalentIDs, iRequiredTalentGridTier, iRequiredTalentGridSlot,
							bIsTalentSpell, arrTalentSpellLevels )
	-- Members
	self.m_iClassIndex = iClassIndex
	self.m_iSpecIndex = iSpecIndex
	self.m_iGridTier = iGridTier
	self.m_iGridSlot = iGridSlot
	
	self.m_arrTalentIDs = arrTalentIDs
	self.m_iRequiredTalentGridTier = iRequiredTalentGridTier
	self.m_iRequiredTalentGridSlot = iRequiredTalentGridSlot
	
	self.m_bIsTalentSpell = bIsTalentSpell
	self.m_arrTalentSpellLevels = arrTalentSpellLevels

	self.m_iCurrentRank = 0
end

-------------------------------------------------------------------------------------------------------------------
-- CLTalentDesc : Methods
function CLTalentDesc:GetClassIndex()
	return self.m_iClassIndex
end
function CLTalentDesc:GetSpecIndex()
	return self.m_iSpecIndex
end
function CLTalentDesc:GetGridTier()
	return self.m_iGridTier
end
function CLTalentDesc:GetGridSlot()
	return self.m_iGridSlot
end

function CLTalentDesc:IsPetTalent()
	return ( self.m_iClassIndex == CLClassCount )
end

function CLTalentDesc:GetRankCount()
	return #( self.m_arrTalentIDs )
end
function CLTalentDesc:GetTalentID( iRank )
	return self.m_arrTalentIDs[iRank]
end
function CLTalentDesc:GetRequiredTalent()
	return self.m_iRequiredTalentGridTier, self.m_iRequiredTalentGridSlot
end

function CLTalentDesc:IsTalentSpell()
	return self.m_bIsTalentSpell
end
function CLTalentDesc:GetTalentSpellLevel( iRank )
	return self.m_arrTalentSpellLevels[iRank]
end

function CLTalentDesc:GetCurrentRank()
	return self.m_iCurrentRank
end
function CLTalentDesc:SetCurrentRank( iRank )
	self.m_iCurrentRank = iRank
end
function CLTalentDesc:GetCurrentTalentID()
	return self.m_arrTalentIDs[self.m_iCurrentRank]
end
function CLTalentDesc:GetCurrentTalentSpellLevel()
	return self.m_arrTalentSpellLevels[self.m_iCurrentRank]
end

function CLTalentDesc:GetCost()
	if self.m_bIsTalentSpell then
		return 1
	end
	return self.m_iCurrentRank
end
function CLTalentDesc:IsMaxed()
	if self.m_bIsTalentSpell then
		return ( self.m_iCurrentRank >= 1 )
	end
	return ( self.m_iCurrentRank >= self:GetRankCount() )
end

function CLTalentDesc:GetTalentSpellRankFromLevel( iPlayerLevel )
	local iRankCount = self:GetRankCount()
	local iRank = 0
	for i = 1, iRankCount do
		local iTalentSpellLevel = self:GetTalentSpellLevel( i )
		if ( iPlayerLevel >= iTalentSpellLevel ) then
			iRank = i
		else
			break
		end
	end
	return iRank
end
function CLTalentDesc:GetTalentSpellIDFromLevel( iPlayerLevel )
	local iRank = self:GetTalentSpellRankFromLevel( iPlayerLevel )
	return self:GetTalentID( iRank )
end

function CLTalentDesc:Encode()
	return {
		self.m_iClassIndex, self.m_iSpecIndex, self.m_iGridTier, self.m_iGridSlot,
		self.m_arrTalentIDs, self.m_iRequiredTalentGridTier, self.m_iRequiredTalentGridSlot,
		self.m_bIsTalentSpell, self.m_arrTalentSpellLevels,
		self.m_iCurrentRank
	}
end
function CLTalentDesc:Decode( arrEncodedTalent )
	self.m_iClassIndex = arrEncodedTalent[1]
	self.m_iSpecIndex = arrEncodedTalent[2]
	self.m_iGridTier = arrEncodedTalent[3]
	self.m_iGridSlot = arrEncodedTalent[4]
	self.m_arrTalentIDs = arrEncodedTalent[5]
	self.m_iRequiredTalentGridTier = arrEncodedTalent[6]
	self.m_iRequiredTalentGridSlot = arrEncodedTalent[7]
	self.m_bIsTalentSpell = arrEncodedTalent[8]
	self.m_arrTalentSpellLevels = arrEncodedTalent[9]
	self.m_iCurrentRank = arrEncodedTalent[10]
end

function CLTalentDesc:GetIcon()
	local strName, iRank, hIcon = GetSpellInfo( self.m_arrTalentIDs[1] )
	return hIcon
end

-------------------------------------------------------------------------------------------------------------------
-- CLTalentMap - Declaration
CLTalentMap = class({
	-- Static Members
})

function CLTalentMap:init()
	-- Members
	self.m_iTalentPoints = 0
	self.m_iPetTalentPoints = 0
	self.m_mapSpecTalentPoints = {}
	self.m_mapTalents = {}
end

-------------------------------------------------------------------------------------------------------------------
-- CLTalentMap : Methods
function CLTalentMap:IsEmpty()
	return ( self.m_iTalentPoints == 0 and self.m_iPetTalentPoints == 0 )
end
function CLTalentMap:Clear()
	self.m_iTalentPoints = 0
	self.m_iPetTalentPoints = 0
	self.m_mapSpecTalentPoints = {}
	self.m_mapTalents = {}
end

function CLTalentMap:EnumCallback( funcCallback )
	for iClassIndex, arrSpecs in pairs(self.m_mapTalents) do
		for iSpecIndex, arrGridTiers in pairs(arrSpecs) do
			for iGridTier, arrGridSlots in pairs(arrGridTiers) do
				for iGridSlot, hTalentDesc in pairs(arrGridSlots) do
					funcCallback( hTalentDesc )
				end
			end
		end
	end
end

function CLTalentMap:GetTalentPoints()
	return self.m_iTalentPoints
end
function CLTalentMap:GetPetTalentPoints()
	return self.m_iPetTalentPoints
end
function CLTalentMap:GetSpecTalentPoints( iClassIndex, iSpecIndex )
	if ( self.m_mapSpecTalentPoints[iClassIndex] == nil ) then
		return 0
	end
	if ( self.m_mapSpecTalentPoints[iClassIndex][iSpecIndex] == nil ) then
		return 0
	end
	return self.m_mapSpecTalentPoints[iClassIndex][iSpecIndex]
end
function CLTalentMap:GetTalentDesc( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	return self.m_mapTalents[iClassIndex][iSpecIndex][iGridTier][iGridSlot]
end

function CLTalentMap:SetTalentRank( iClassIndex, iSpecIndex, iGridTier, iGridSlot, iRank )
	-- Save old Cost
	local iOldCost = self.m_mapTalents[iClassIndex][iSpecIndex][iGridTier][iGridSlot]:GetCost()

	-- Update Rank
	self.m_mapTalents[iClassIndex][iSpecIndex][iGridTier][iGridSlot]:SetCurrentRank( iRank )
	
	-- Update Points
	local iNewCost = self.m_mapTalents[iClassIndex][iSpecIndex][iGridTier][iGridSlot]:GetCost()
	if ( self.m_mapTalents[iClassIndex][iSpecIndex][iGridTier][iGridSlot]:IsPetTalent() ) then
		self.m_iPetTalentPoints = self.m_iPetTalentPoints - iOldCost + iNewCost
	else
		self.m_iTalentPoints = self.m_iTalentPoints - iOldCost + iNewCost
	end
	self.m_mapSpecTalentPoints[iClassIndex][iSpecIndex] = self.m_mapSpecTalentPoints[iClassIndex][iSpecIndex] - iOldCost + iNewCost
end

function CLTalentMap:HasTalent( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	if ( self.m_mapTalents[iClassIndex] == nil ) then
		return false
	end
	if ( self.m_mapTalents[iClassIndex][iSpecIndex] == nil ) then
		return false
	end
	if ( self.m_mapTalents[iClassIndex][iSpecIndex][iGridTier] == nil ) then
		return false
	end
	if ( self.m_mapTalents[iClassIndex][iSpecIndex][iGridTier][iGridSlot] == nil ) then
		return false
	end
	return true
end

function CLTalentMap:AddTalent( hTalentDesc )
	local iClassIndex = hTalentDesc:GetClassIndex()
	local iSpecIndex = hTalentDesc:GetSpecIndex()
	local iGridTier = hTalentDesc:GetGridTier()
	local iGridSlot = hTalentDesc:GetGridSlot()
	
	-- Auto-Vivify arrays
	if ( self.m_mapTalents[iClassIndex] == nil ) then
		self.m_mapTalents[iClassIndex] = {}
		self.m_mapSpecTalentPoints[iClassIndex] = {}
	end
	if ( self.m_mapTalents[iClassIndex][iSpecIndex] == nil ) then
		self.m_mapTalents[iClassIndex][iSpecIndex] = {}
		self.m_mapSpecTalentPoints[iClassIndex][iSpecIndex] = 0
	end
	if ( self.m_mapTalents[iClassIndex][iSpecIndex][iGridTier] == nil ) then
		self.m_mapTalents[iClassIndex][iSpecIndex][iGridTier] = {}
	end
	
	-- Check if already existing
	if ( self.m_mapTalents[iClassIndex][iSpecIndex][iGridTier][iGridSlot] ~= nil ) then
		return
	end
	
	-- Update Points
	local iCost = hTalentDesc:GetCost()
	if hTalentDesc:IsPetTalent() then
		self.m_iPetTalentPoints = self.m_iPetTalentPoints + iCost
	else
		self.m_iTalentPoints = self.m_iTalentPoints + iCost
	end
	self.m_mapSpecTalentPoints[iClassIndex][iSpecIndex] = self.m_mapSpecTalentPoints[iClassIndex][iSpecIndex] + iCost
	
	-- Add Talent
	self.m_mapTalents[iClassIndex][iSpecIndex][iGridTier][iGridSlot] = hTalentDesc
end
function CLTalentMap:RemoveTalent( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	-- Check if present
	if ( not self:HasTalent(iClassIndex, iSpecIndex, iGridTier, iGridSlot) ) then
		return
	end
	
	-- Update Points
	local iCost = self.m_mapTalents[iClassIndex][iSpecIndex][iGridTier][iGridSlot]:GetCost()
	if ( self.m_mapTalents[iClassIndex][iSpecIndex][iGridTier][iGridSlot]:IsPetTalent() ) then
		self.m_iPetTalentPoints = self.m_iPetTalentPoints - iCost
	else
		self.m_iTalentPoints = self.m_iTalentPoints - iCost
	end
	self.m_mapSpecTalentPoints[iClassIndex][iSpecIndex] = self.m_mapSpecTalentPoints[iClassIndex][iSpecIndex] - iCost
	
	-- Remove Talent
	self.m_mapTalents[iClassIndex][iSpecIndex][iGridTier][iGridSlot] = nil
end

function CLTalentMap:Encode()
	local arrEncodedTalents = {}
	for iClassIndex, arrSpecs in pairs(self.m_mapTalents) do
		for iSpecIndex, arrGridTiers in pairs(arrSpecs) do
			for iGridTier, arrGridSlots in pairs(arrGridTiers) do
				for iGridSlot, hTalentDesc in pairs(arrGridSlots) do
					table.insert( arrEncodedTalents, hTalentDesc:Encode() )
				end
			end
		end
	end
	return arrEncodedTalents
end
function CLTalentMap:Decode( arrEncodedTalents )
	self:Clear()
	for i = 1, #arrEncodedTalents do
		local hTalentDesc = CLTalentDesc()
		hTalentDesc:Decode( arrEncodedTalents[i] )
		self:AddTalent( hTalentDesc )
	end
end
