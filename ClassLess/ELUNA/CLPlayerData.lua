-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess Server : Player Data
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Requirements
local AIO = AIO or require("AIO")
if not class then require("class") end

-------------------------------------------------------------------------------------------------------------------
-- Client / Server Setup

-- Server-side Only !

-------------------------------------------------------------------------------------------------------------------
-- Constants

-------------------------------------------------------------------------------------------------------------------
-- ClassLessPlayerData - Declaration
ClassLessPlayerData = class({
	-- Static Members
})

function ClassLessPlayerData:init( iPlayerGUID )
	-- Members
	self.m_iGUID = iPlayerGUID
	
	self.m_arrSpells = {} -- array( ClassLessSpellDesc )
	self.m_arrTalents = {} -- array( ClassLessTalentDesc )
	self.m_iResetCounter = 0
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessPlayerData : Getters / Setters
function ClassLessPlayerData:GetGUID()
	return self.m_iGUID
end

function ClassLessPlayerData:GetSpells()
	return self.m_arrSpells
end
function ClassLessPlayerData:GetSpellCount()
	return #( self.m_arrSpells )
end
function ClassLessPlayerData:GetSpellDesc( iIndex )
	return self.m_arrSpells[iIndex]
end
function ClassLessPlayerData:GetSpellCost( iIndex )
	return 1
end

function ClassLessPlayerData:HasSpell( iClassIndex, iSpecIndex, iSpellIndex )
	return ( self:GetSpellIndex(iClassIndex, iSpecIndex, iSpellIndex) ~= 0 )
end

function ClassLessPlayerData:GetTalents()
	return self.m_arrTalents
end
function ClassLessPlayerData:GetTalentCount()
	return #( self.m_arrTalents )
end
function ClassLessPlayerData:GetTalentDesc( iIndex )
	return self.m_arrTalents[iIndex]
end
function ClassLessPlayerData:GetTalentCost( iIndex )
	return self.m_arrTalents[iIndex]:GetCurrentCost()
end

function ClassLessPlayerData:HasTalent( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	return ( self:GetTalentIndex(iClassIndex, iSpecIndex, iGridTier, iGridSlot) ~= 0 )
end

function ClassLessPlayerData:GetResetCounter()
	return self.m_iResetCounter
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessPlayerData : Methods
function ClassLessPlayerData:GetSpellIndex( iClassIndex, iSpecIndex, iSpellIndex )
	local iSpellCount = self:GetSpellCount()
	for i = 1, iSpellCount do
		local hSpellDesc = self:GetSpellDesc( i )
		if ( iClassIndex == hSpellDesc:GetClassIndex() and iSpecIndex == hSpellDesc:GetSpecIndex() and
			 iSpellIndex == hSpellDesc:GetSpellIndex() ) then
			return i
		end
	end
	return 0
end

function ClassLessPlayerData:GetTalentIndex( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	local iTalentCount = self:GetTalentCount()
	for i = 1, iTalentCount do
		local hTalentDesc = self:GetTalentDesc( i )
		if ( iClassIndex == hTalentDesc:GetClassIndex() and iSpecIndex == hTalentDesc:GetSpecIndex() and
			 iGridTier == hTalentDesc:GetGridTier() and iGridSlot == hTalentDesc:GetGridSlot() ) then
			return i
		end
	end
	return 0
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessPlayerData : Methods - Spell/Talent Points
function ClassLessPlayerData:GetAllocatedSpellPoints()
	local iSpellCount = self:GetSpellCount()
	local iAllocatedSpellPoints = 0
	for i = 1, iSpellCount do
		iAllocatedSpellPoints = iAllocatedSpellPoints + self:GetSpellCost( i )
	end
	return iAllocatedSpellPoints
end
function ClassLessPlayerData:GetAllocatedTalentPoints()
	local iTalentCount = self:GetTalentCount()
	local iAllocatedTalentPoints = 0
	for i = 1, iTalentCount do
		iAllocatedTalentPoints = iAllocatedTalentPoints + self:GetTalentCost( i )
	end
	return iAllocatedTalentPoints
end

function ClassLessPlayerData:GetSpecAllocatedTalentPoints( iClassIndex, iSpecIndex )
	local iTalentCount = self:GetTalentCount()
	local iAllocatedTalentPoints = 0
	for i = 1, iTalentCount do
		local hTalentDesc = self:GetTalentDesc( i )
		if ( hTalentDesc:GetClassIndex() == iClassIndex and hTalentDesc:GetSpecIndex() == iSpecIndex ) then
			iAllocatedTalentPoints = iAllocatedTalentPoints + self:GetTalentCost( i )
		end
	end
	return iAllocatedTalentPoints
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessPlayerData : Methods - Spells / Talents
function ClassLessPlayerData:AddSpell( iClassIndex, iSpecIndex, iSpellIndex )
	-- Get Spell Descriptor
	local hSpellDesc = CLServer:GetDataSpells():GetSpellDesc( iClassIndex, iSpecIndex, iSpellIndex )
	
	-- Get Player
	local hPlayer = GetPlayerByGUID( GetPlayerGUID(self.m_iGUID) )
	
	-- Check if we have enough points
	if ( CLServer:GetFreeSpellPoints(hPlayer) <= 0 ) then
		return
	end
	
	-- Compute appropriate Rank
	local iRank = hSpellDesc:GetRankFromLevel( hPlayer:GetLevel() )
	if ( iRank == 0 ) then
		return
	end
	
	-- Check if already present
	local iIndex = self:GetSpellIndex( iClassIndex, iSpecIndex, iSpellIndex )
	if ( iIndex ~= 0 ) then
		-- Check Rank
		if ( self.m_arrSpells[iIndex]:GetCurrentRank() == iRank ) then
			return
		end
		
		-- Remove previous Rank
		local iSpellID = self.m_arrSpells[iIndex]:GetCurrentSpellID()
		if hPlayer:HasSpell( iSpellID ) then
			hPlayer:RemoveSpell( iSpellID, 255, false )
		end
		
		-- Update Rank
		self.m_arrSpells[iIndex]:SetCurrentRank( iRank )
		
		-- Add current Rank
		iSpellID = self.m_arrSpells[iIndex]:GetCurrentSpellID()
		if ( not hPlayer:HasSpell(iSpellID) ) then
			hPlayer:LearnSpell( iSpellID )
		end
		
		return
	end
	
	-- Apply appropriate Rank
	hSpellDesc:SetCurrentRank( iRank )
	
	-- Add current Rank
	local iSpellID = hSpellDesc:GetCurrentSpellID()
	if ( not hPlayer:HasSpell(iSpellID) ) then
		hPlayer:LearnSpell( iSpellID )
	end
	
	-- Add Spell
	table.insert( self.m_arrSpells, hSpellDesc )
end
function ClassLessPlayerData:AddTalent( iClassIndex, iSpecIndex, iGridTier, iGridSlot, iTalentRank )
	-- Get Talent Descriptor
	local hTalentDesc = CLServer:GetDataTalents():GetTalentDesc( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	
	-- Get Player
	local hPlayer = GetPlayerByGUID( GetPlayerGUID(self.m_iGUID) )
	
	-- Check Grid Tier Requirement
	local iSpecAllocatedTalentPoints = self:GetSpecAllocatedTalentPoints( iClassIndex, iSpecIndex )
	local iTierRequiredTalentPoints = CLServer:GetRequiredTalentPoints( iGridTier )
	if ( iSpecAllocatedTalentPoints < iTierRequiredTalentPoints ) then
		return
	end
	
	-- Check Talent Requirement
	local iRequiredTalentGridTier, iRequiredTalentGridSlot = hTalentDesc:GetRequiredTalent()
	if ( iRequiredTalentGridTier ~= 0 and iRequiredTalentGridSlot ~= 0 ) then
		-- Must be present
		local iRequiredTalentIndex = self:GetTalentIndex( iClassIndex, iSpecIndex, iRequiredTalentGridTier, iRequiredTalentGridSlot )
		if ( iRequiredTalentIndex == 0 ) then
			return
		end
		-- Must be maxed
		local hRequiredTalentDesc = self:GetTalentDesc( iRequiredTalentIndex )
		if ( not hRequiredTalentDesc:IsMaxed() ) then
			return
		end
	end
	
	-- TalentSpell case
	if ( hTalentDesc:IsTalentSpell() ) then
		-- Check if we have enough points
		if ( CLServer:GetFreeTalentPoints(hPlayer) <= 0 ) then
			return
		end
	
		-- Compute appropriate Rank
		local iRank = hTalentDesc:GetTalentSpellRankFromLevel( hPlayer:GetLevel() )
		if ( iRank == 0 ) then
			return
		end
		
		-- Check if already present
		local iIndex = self:GetTalentIndex( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
		if ( iIndex ~= 0 ) then
			-- Check Rank
			if ( self.m_arrTalents[iIndex]:GetCurrentRank() == iRank ) then
				return
			end
			
			-- Remove previous Rank
			local iTalentID = self.m_arrTalents[iIndex]:GetCurrentTalentID()
			if hPlayer:HasSpell( iTalentID ) then
				hPlayer:RemoveSpell( iTalentID, 255, false )
			end
			
			-- Update Rank
			self.m_arrTalents[iIndex]:SetCurrentRank( iRank )
			
			-- Add current Rank
			iTalentID = self.m_arrTalents[iIndex]:GetCurrentTalentID()
			if ( not hPlayer:HasSpell(iTalentID) ) then
				hPlayer:LearnSpell( iTalentID )
			end
			
			return
		end
		
		-- Apply appropriate Rank
		hTalentDesc:SetCurrentRank( iRank )
		
		-- Add current Rank
		local iTalentID = hTalentDesc:GetCurrentTalentID()
		if ( not hPlayer:HasSpell(iTalentID) ) then
			hPlayer:LearnSpell( iTalentID )
		end
		
		-- Add Talent
		table.insert( self.m_arrTalents, hTalentDesc )
		
		return
	end
	
	-- Check if TalentRank is valid
	if ( iTalentRank > hTalentDesc:GetRankCount() ) then
		iTalentRank = hTalentDesc:GetRankCount()
	end
	
	-- Check if already present
	local iIndex = self:GetTalentIndex( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	if ( iIndex ~= 0 ) then
		-- Get current Rank
		local iRank = self.m_arrTalents[iIndex]:GetCurrentRank()
		
		-- Check if already Maxed
		if ( iRank == self.m_arrTalents[iIndex]:GetRankCount() ) then
			return
		end
		
		-- Check for attempt at downgrade (you meanie !)
		if ( iTalentRank <= iRank ) then
			return
		end
		
		-- Check if we have enough points
		if ( CLServer:GetFreeTalentPoints(hPlayer) <= (iTalentRank - iRank) ) then
			return
		end
		
		-- Remove previous Rank
		local iTalentID = self.m_arrTalents[iIndex]:GetCurrentTalentID()
		if hPlayer:HasSpell( iTalentID ) then
			hPlayer:RemoveSpell( iTalentID, 255, false )
		end
		
		-- Upgrade Rank
		self.m_arrTalents[iIndex]:SetCurrentRank( iTalentRank )
	
		-- Add upgraded Rank
		iTalentID = self.m_arrTalents[iIndex]:GetCurrentTalentID()
		if ( not hPlayer:HasSpell(iTalentID) ) then
			hPlayer:LearnSpell( iTalentID )
		end
		
		return
	end
	
	-- Check if we have enough points
	if ( CLServer:GetFreeTalentPoints(hPlayer) <= iTalentRank ) then
		return
	end
	
	-- Apply appropriate Rank
	hTalentDesc:SetCurrentRank( iTalentRank )
	
	-- Add current Rank
	local iTalentID = hTalentDesc:GetCurrentTalentID()
	if ( not hPlayer:HasSpell(iTalentID) ) then
		hPlayer:LearnSpell( iTalentID )
	end
	
	-- Add Talent
	table.insert( self.m_arrTalents, hTalentDesc )
end

function ClassLessPlayerData:CanReset()
	return ( (self:GetSpellCount() + self:GetTalentCount()) > 0 )
end
function ClassLessPlayerData:Reset()
	-- Get Player
	local hPlayer = GetPlayerByGUID( GetPlayerGUID(self.m_iGUID) )
	
	-- Remove all Spells
	local iSpellCount = #(self.m_arrSpells)
	for i = 1, iSpellCount do
		local iSpellID = self.m_arrSpells[i]:GetCurrentSpellID()
		if ( hPlayer:HasSpell(iSpellID) ) then
			hPlayer:RemoveSpell( iSpellID, 255, false )
		end
	end

	-- Remove all Talents
	local iTalentCount = #(self.m_arrTalents)
	for i = 1, iTalentCount do
		local iTalentID = self.m_arrTalents[i]:GetCurrentTalentID()
		if ( hPlayer:HasSpell(iTalentID) ) then
			hPlayer:RemoveSpell( iTalentID, 255, false )
		end
	end
	
	-- Reset & Increment Counter
	self.m_arrSpells = {}
	self.m_arrTalents = {}
	self.m_iResetCounter = self.m_iResetCounter + 1
end

function ClassLessPlayerData:UpdateAllSpellsRanks()
	-- Get Player & Level
	local hPlayer = GetPlayerByGUID( GetPlayerGUID(self.m_iGUID) )
	local iNewLevel = hPlayer:GetLevel()
	
	-- Check All Spells for Rank upgrade
	local iSpellCount = self:GetSpellCount()
	for i = 1, iSpellCount do
		local iCurrentRank = self.m_arrSpells[i]:GetCurrentRank()
		local iNewRank = self.m_arrSpells[i]:GetRankFromLevel( iNewLevel )
		if ( iNewRank ~= iCurrentRank ) then
			-- Remove previous Rank
			local iOldSpellID = self.m_arrSpells[i]:GetCurrentSpellID()
			if ( hPlayer:HasSpell(iOldSpellID) ) then
				hPlayer:RemoveSpell( iOldSpellID, 255, false )
			end
			
			-- Update Rank
			self.m_arrSpells[i]:SetCurrentRank( iNewRank )
			
			-- Add new Rank
			local iNewSpellID = self.m_arrSpells[i]:GetCurrentSpellID()
			if ( not hPlayer:HasSpell(iNewSpellID) ) then
				hPlayer:LearnSpell( iNewSpellID )
			end
		end
	end
	
	-- Check All TalentSpells for Rank upgrade
	local iTalentCount = self:GetTalentCount()
	for i = 1, iTalentCount do
		if ( self.m_arrTalents[i]:IsTalentSpell() ) then
			local iCurrentRank = self.m_arrTalents[i]:GetCurrentRank()
			local iNewRank = self.m_arrTalents[i]:GetTalentSpellRankFromLevel( iNewLevel )
			if ( iNewRank ~= iCurrentRank ) then
				-- Remove previous Rank
				local iOldTalentSpellID = self.m_arrTalents[i]:GetCurrentTalentID()
				if ( hPlayer:HasSpell(iOldTalentSpellID) ) then
					hPlayer:RemoveSpell( iOldTalentSpellID, 255, false )
				end
				
				-- Update Rank
				self.m_arrTalents[i]:SetCurrentRank( iNewRank )
				
				-- Add new Rank
				local iNewTalentSpellID = self.m_arrTalents[i]:GetCurrentTalentID()
				if ( not hPlayer:HasSpell(iNewTalentSpellID) ) then
					hPlayer:LearnSpell( iNewTalentSpellID )
				end
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessPlayerData : Methods - Database
local function CLArrayFromString( strData )
    local arrResult = {}
    if ( not strData or strData == "" ) then
		return arrResult
	end
	for i in string.gmatch(strData, "([^,]+)") do
		table.insert(arrResult, tonumber(i))
	end
    return arrResult
end
local function CLArrayToString( arrData )
    local strResult = ""
    if ( #arrData > 1 ) then
        strResult = table.concat(arrData, ",")
    elseif ( #arrData == 1 ) then
        strResult = arrData[1]
    end
    return strResult
end

function ClassLessPlayerData:DBCreate()
    CharDBQuery( "INSERT INTO character_classless VALUES (" .. self.m_iGUID .. ", '', '', 0)" )
end
function ClassLessPlayerData:DBDestroy()
	CharDBQuery( "DELETE FROM character_classless WHERE guid = " .. self.m_iGUID )
end

function ClassLessPlayerData:DBLoad()
	-- Load from DB
	local hQuery = CharDBQuery( "SELECT * FROM character_classless WHERE guid = " .. self.m_iGUID )
	if ( hQuery == nil ) then
		return false
	end
	
	local strSpells 	= hQuery:GetString(1)
	local strTalents 	= hQuery:GetString(2)
	local iResetCounter = hQuery:GetUInt32(3)
	
	-- Build Player Data
	self.m_arrSpells = {}
	self.m_arrTalents = {}
	self.m_iResetCounter = iResetCounter

	local arrSpellIDs = CLArrayFromString( strSpells )
	local iSpellCount = #arrSpellIDs
	for i = 1, iSpellCount do
		local iClassIndex, iSpecIndex, iSpellIndex, iRank = CLServer:GetDataSpells():SearchSpell( arrSpellIDs[i] )
		local hSpellDesc = CLServer:GetDataSpells():GetSpellDesc( iClassIndex, iSpecIndex, iSpellIndex )
		hSpellDesc:SetCurrentRank( iRank )
		table.insert( self.m_arrSpells, hSpellDesc )
	end

	local arrTalentIDs = CLArrayFromString( strTalents )
	local iTalentCount = #arrTalentIDs
	for i = 1, iTalentCount do
		local iClassIndex, iSpecIndex, iGridTier, iGridSlot, iRank = CLServer:GetDataTalents():SearchTalent( arrTalentIDs[i] )
		local hTalentDesc = CLServer:GetDataTalents():GetTalentDesc( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
		hTalentDesc:SetCurrentRank( iRank )
		table.insert( self.m_arrTalents, hTalentDesc )
	end
	
	return true
end
function ClassLessPlayerData:DBSave()
	-- Build SpellID String
	local arrSpellIDs = {}
	local iSpellCount = self:GetSpellCount()
	for i = 1, iSpellCount do
		table.insert( arrSpellIDs, self.m_arrSpells[i]:GetCurrentSpellID() )
	end
	
	local strSpells = CLArrayToString( arrSpellIDs )
	
	-- Build TalentID String
	local arrTalentIDs = {}
	local iTalentCount = self:GetTalentCount()
	for i = 1, iTalentCount do
		table.insert( arrTalentIDs, self.m_arrTalents[i]:GetCurrentTalentID() )
	end
	
	local strTalents = CLArrayToString( arrTalentIDs )
	
	-- Reset Counter
	local iResetCounter = self.m_iResetCounter
	
	-- Save to DB
	CharDBQuery( "UPDATE character_classless SET spells='" .. strSpells .. "' WHERE guid = " .. self.m_iGUID )
	CharDBQuery( "UPDATE character_classless SET talents='" .. strTalents .. "' WHERE guid = " .. self.m_iGUID )
	CharDBQuery( "UPDATE character_classless SET reset_counter='" .. iResetCounter .. "' WHERE guid = " .. self.m_iGUID )
end


