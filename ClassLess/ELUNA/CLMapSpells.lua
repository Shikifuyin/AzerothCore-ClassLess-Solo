-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess : Spell Maps
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
-- CLSpellDesc - Declaration
CLSpellDesc = class({
	-- Static Members
})

function CLSpellDesc:init( iClassIndex, iSpecIndex, iSpellIndex, arrSpellIDs, arrSpellLevels )
	-- Members
	self.m_iClassIndex = iClassIndex
	self.m_iSpecIndex = iSpecIndex
	self.m_iSpellIndex = iSpellIndex
	
	self.m_arrSpellIDs = arrSpellIDs
	self.m_arrSpellLevels = arrSpellLevels
	
	self.m_iCurrentRank = 0
end

-------------------------------------------------------------------------------------------------------------------
-- CLSpellDesc : Methods
function CLSpellDesc:GetClassIndex()
	return self.m_iClassIndex
end
function CLSpellDesc:GetSpecIndex()
	return self.m_iSpecIndex
end
function CLSpellDesc:GetSpellIndex()
	return self.m_iSpellIndex
end

function CLSpellDesc:IsPetSpell()
	return ( self.m_iClassIndex == CLClassCount )
end

function CLSpellDesc:GetRankCount()
	return #( self.m_arrSpellIDs )
end
function CLSpellDesc:GetSpellID( iRank )
	return self.m_arrSpellIDs[iRank]
end
function CLSpellDesc:GetSpellLevel( iRank )
	return self.m_arrSpellLevels[iRank]
end

function CLSpellDesc:GetCurrentRank()
	return self.m_iCurrentRank
end
function CLSpellDesc:SetCurrentRank( iRank )
	self.m_iCurrentRank = iRank
end
function CLSpellDesc:GetCurrentSpellID()
	return self.m_arrSpellIDs[self.m_iCurrentRank]
end
function CLSpellDesc:GetCurrentSpellLevel()
	return self.m_arrSpellLevels[self.m_iCurrentRank]
end

function CLSpellDesc:GetCost()
	return 1
end

function CLSpellDesc:GetRankFromLevel( iPlayerLevel )
	local iRankCount = self:GetRankCount()
	local iRank = 0
	for i = 1, iRankCount do
		local iSpellLevel = self:GetSpellLevel( i )
		if ( iPlayerLevel >= iSpellLevel ) then
			iRank = i
		else
			break
		end
	end
	return iRank
end
function CLSpellDesc:GetSpellIDFromLevel( iPlayerLevel )
	local iRank = self:GetRankFromLevel( iPlayerLevel )
	return self:GetSpellID( iRank )
end

function CLSpellDesc:Encode()
	return {
		self.m_iClassIndex, self.m_iSpecIndex, self.m_iSpellIndex,
		self.m_arrSpellIDs, self.m_arrSpellLevels, self.m_iCurrentRank
	}
end
function CLSpellDesc:Decode( arrEncodedSpell )
	self.m_iClassIndex = arrEncodedSpell[1]
	self.m_iSpecIndex = arrEncodedSpell[2]
	self.m_iSpellIndex = arrEncodedSpell[3]
	self.m_arrSpellIDs = arrEncodedSpell[4]
	self.m_arrSpellLevels = arrEncodedSpell[5]
	self.m_iCurrentRank = arrEncodedSpell[6]
end

function CLSpellDesc:GetIcon()
	local strName, iRank, hIcon = GetSpellInfo( self.m_arrSpellIDs[1] )
	return hIcon
end

-------------------------------------------------------------------------------------------------------------------
-- CLSpellMap - Declaration
CLSpellMap = class({
	-- Static Members
})

function CLSpellMap:init()
	-- Members
	self.m_iSpellPoints = 0
	self.m_iPetSpellPoints = 0
	self.m_mapSpells = {}
end

-------------------------------------------------------------------------------------------------------------------
-- CLSpellMap : Methods
function CLSpellMap:IsEmpty()
	return ( self.m_iSpellPoints == 0 and self.m_iPetSpellPoints == 0 )
end
function CLSpellMap:Clear()
	self.m_iSpellPoints = 0
	self.m_iPetSpellPoints = 0
	self.m_mapSpells = {}
end

function CLSpellMap:EnumCallback( funcCallback )
	for iClassIndex, arrSpecs in pairs(self.m_mapSpells) do
		for iSpecIndex, arrSpells in pairs(arrSpecs) do
			for iSpellIndex, hSpellDesc in pairs(arrSpells) do
				funcCallback( hSpellDesc )
			end
		end
	end
end

function CLSpellMap:GetSpellPoints()
	return self.m_iSpellPoints
end
function CLSpellMap:GetPetSpellPoints()
	return self.m_iPetSpellPoints
end
function CLSpellMap:GetSpellDesc( iClassIndex, iSpecIndex, iSpellIndex )
	return self.m_mapSpells[iClassIndex][iSpecIndex][iSpellIndex]
end

function CLSpellMap:SetSpellRank( iClassIndex, iSpecIndex, iSpellIndex, iRank )
	self.m_mapSpells[iClassIndex][iSpecIndex][iSpellIndex]:SetCurrentRank( iRank )
end

function CLSpellMap:HasSpell( iClassIndex, iSpecIndex, iSpellIndex )
	if ( self.m_mapSpells[iClassIndex] == nil ) then
		return false
	end
	if ( self.m_mapSpells[iClassIndex][iSpecIndex] == nil ) then
		return false
	end
	if ( self.m_mapSpells[iClassIndex][iSpecIndex][iSpellIndex] == nil ) then
		return false
	end
	return true
end

function CLSpellMap:AddSpell( hSpellDesc )
	local iClassIndex = hSpellDesc:GetClassIndex()
	local iSpecIndex = hSpellDesc:GetSpecIndex()
	local iSpellIndex = hSpellDesc:GetSpellIndex()
	
	-- Auto-Vivify arrays
	if ( self.m_mapSpells[iClassIndex] == nil ) then
		self.m_mapSpells[iClassIndex] = {}
	end
	if ( self.m_mapSpells[iClassIndex][iSpecIndex] == nil ) then
		self.m_mapSpells[iClassIndex][iSpecIndex] = {}
	end
	
	-- Check if already existing
	if ( self.m_mapSpells[iClassIndex][iSpecIndex][iSpellIndex] ~= nil ) then
		return
	end
	
	-- Update Points
	local iCost = hSpellDesc:GetCost()
	if hSpellDesc:IsPetSpell() then
		self.m_iPetSpellPoints = self.m_iPetSpellPoints + iCost
	else
		self.m_iSpellPoints = self.m_iSpellPoints + iCost
	end
	
	-- Add Spell
	self.m_mapSpells[iClassIndex][iSpecIndex][iSpellIndex] = hSpellDesc
end

function CLSpellMap:RemoveSpell( iClassIndex, iSpecIndex, iSpellIndex )
	-- Check if present
	if ( not self:HasSpell(iClassIndex, iSpecIndex, iSpellIndex) ) then
		return
	end
	
	-- Update Points
	local iCost = self.m_mapSpells[iClassIndex][iSpecIndex][iSpellIndex]:GetCost()
	if ( self.m_mapSpells[iClassIndex][iSpecIndex][iSpellIndex]:IsPetSpell() ) then
		self.m_iPetSpellPoints = self.m_iPetSpellPoints - iCost
	else
		self.m_iSpellPoints = self.m_iSpellPoints - iCost
	end
	
	-- Remove Spell
	self.m_mapSpells[iClassIndex][iSpecIndex][iSpellIndex] = nil
end

function CLSpellMap:Encode()
	local arrEncodedSpells = {}
	for iClassIndex, arrSpecs in pairs(self.m_mapSpells) do
		for iSpecIndex, arrSpells in pairs(arrSpecs) do
			for iSpellIndex, hSpellDesc in pairs(arrSpells) do
				table.insert( arrEncodedSpells, hSpellDesc:Encode() )
			end
		end
	end
	return arrEncodedSpells
end
function CLSpellMap:Decode( arrEncodedSpells )
	self:Clear()
	for i = 1, #arrEncodedSpells do
		local hSpellDesc = CLSpellDesc()
		hSpellDesc:Decode( arrEncodedSpells[i] )
		self:AddSpell( hSpellDesc )
	end
end


