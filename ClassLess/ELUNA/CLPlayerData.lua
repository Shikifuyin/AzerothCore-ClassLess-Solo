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
if not CLDataSpells then require("CLDataSpells") end
if not CLDataTalents then require("CLDataTalents") end
if not CLDataGlyphs then require("CLDataGlyphs") end

-------------------------------------------------------------------------------------------------------------------
-- Client / Server Setup

-- Server-side Only !

-------------------------------------------------------------------------------------------------------------------
-- Internal Helpers
local function _Learn( hPlayer, iSpellID )
	if ( not hPlayer:HasSpell(iSpellID) ) then
		hPlayer:LearnSpell( iSpellID )
	end
end
local function _Unlearn( hPlayer, iSpellID )
	if ( hPlayer:HasSpell(iSpellID) ) then
		hPlayer:RemoveSpell( iSpellID, 255, false )
	end
end

local function _GetPlayerPet( hPlayer )
	return hPlayer:GetMap():GetWorldObject( hPlayer:GetPetGUID() )
end
local function _PetLearn( hPlayer, iSpellID )
	-- No way to implement this for now in Eluna ?
end
local function _PetUnlearn( hPlayer, iSpellID )
	-- No way to implement this for now in Eluna ?
end

local function _ArrayFromString( strData )
    local arrResult = {}
    if ( not strData or strData == "" ) then
		return arrResult
	end
	for i in string.gmatch(strData, "([^,]+)") do
		table.insert(arrResult, tonumber(i))
	end
    return arrResult
end
local function _ArrayToString( arrData )
    local strResult = ""
    if ( #arrData > 1 ) then
        strResult = table.concat(arrData, ",")
    elseif ( #arrData == 1 ) then
        strResult = arrData[1]
    end
    return strResult
end

-------------------------------------------------------------------------------------------------------------------
-- CLPlayerData - Declaration
CLPlayerData = class({
	-- Static Members
})

function CLPlayerData:init( iPlayerGUID )
	-- Members
	self.m_iGUID = iPlayerGUID
	
	self.m_mapSpells = CLSpellMap()
	self.m_mapTalents = CLTalentMap()
	self.m_mapGlyphs = CLGlyphMap()
	self.m_iResetCounter = 0
end

-------------------------------------------------------------------------------------------------------------------
-- CLPlayerData : Methods - General
function CLPlayerData:GetGUID()
	return self.m_iGUID
end

function CLPlayerData:GetResetCounter()
	return self.m_iResetCounter
end
function CLPlayerData:CanReset()
	return ( not (self.m_mapSpells:IsEmpty() and self.m_mapTalents:IsEmpty() and self.m_mapGlyphs:IsEmpty()) )
end

function CLPlayerData:Reset()
	-- Get Player
	local hPlayer = GetPlayerByGUID( GetPlayerGUID(self.m_iGUID) )
	
	-- Remove all Spells
	self.m_mapSpells:EnumCallback(
		function( hSpellDesc )
			_Unlearn( hPlayer, hSpellDesc:GetCurrentSpellID() )
		end
	)

	-- Remove all Talents
	self.m_mapTalents:EnumCallback(
		function( hTalentDesc )
			_Unlearn( hPlayer, hTalentDesc:GetCurrentTalentID() )
		end
	)
	
	-- Remove all Glyphs
	self.m_mapGlyphs:EnumCallback(
		function( hGlyphDesc )
			_Unlearn( hPlayer, hGlyphDesc:GetGlyphID() )
		end
	)
	
	-- Reset & Increment Counter
	self.m_mapSpells:Clear()
	self.m_mapTalents:Clear()
	self.m_mapGlyphs:Clear()
	self.m_iResetCounter = self.m_iResetCounter + 1
end

function CLPlayerData:UpdateAllSpellsRanks()
	-- Get Player & Level
	local hPlayer = GetPlayerByGUID( GetPlayerGUID(self.m_iGUID) )
	local iNewLevel = hPlayer:GetLevel()
	
	-- Check All Spells for Rank Update
	self.m_mapSpells:EnumCallback(
		function( hSpellDesc )
			local iCurrentRank = hSpellDesc:GetCurrentRank()
			local iNewRank = hSpellDesc:GetRankFromLevel( iNewLevel )
			if ( iNewRank ~= iCurrentRank ) then
				-- Remove previous Rank
				_Unlearn( hPlayer, hSpellDesc:GetCurrentSpellID() )
				
				-- Update Rank
				self.m_mapSpells:SetSpellRank( hSpellDesc:GetClassIndex(), hSpellDesc:GetSpecIndex(), hSpellDesc:GetSpellIndex(), iNewRank )

				-- Add new Rank
				_Learn( hPlayer, hSpellDesc:GetCurrentSpellID() )
			end
		end
	)
	
	-- Check All TalentSpells for Rank Update
	self.m_mapTalents:EnumCallback(
		function( hTalentDesc )
			if ( not hTalentDesc:IsTalentSpell() ) then
				return
			end
			local iCurrentRank = hTalentDesc:GetCurrentRank()
			local iNewRank = hTalentDesc:GetTalentSpellRankFromLevel( iNewLevel )
			if ( iNewRank ~= iCurrentRank ) then
				-- Remove previous Rank
				_Unlearn( hPlayer, hTalentDesc:GetCurrentTalentID() )
				
				-- Update Rank
				self.m_mapTalents:SetTalentRank( hTalentDesc:GetClassIndex(), hTalentDesc:GetSpecIndex(), hTalentDesc:GetGridTier(), hTalentDesc:GetGridSlot(), iNewRank )

				-- Add new Rank
				_Learn( hPlayer, hTalentDesc:GetCurrentTalentID() )
			end
		end
	)
end

-------------------------------------------------------------------------------------------------------------------
-- CLPlayerData : Methods - Spells
function CLPlayerData:GetSpellMap()
	return self.m_mapSpells
end

function CLPlayerData:AddSpell( iClassIndex, iSpecIndex, iSpellIndex )
	-- Get Spell Descriptor
	local hSpellDesc = CLDataSpells:GetInstance():GetSpellDesc( iClassIndex, iSpecIndex, iSpellIndex )
	
	-- Get Player
	local hPlayer = GetPlayerByGUID( GetPlayerGUID(self.m_iGUID) )
	
	-- Check if we have enough points
	if hSpellDesc:IsPetSpell() then
		if ( CLServer:GetInstance():GetFreePetSpellPoints(hPlayer) <= 0 ) then
			return
		end
	else
		if ( CLServer:GetInstance():GetFreeSpellPoints(hPlayer) <= 0 ) then
			return
		end
	end
	
	-- Compute appropriate Rank
	local iRank = hSpellDesc:GetRankFromLevel( hPlayer:GetLevel() )
	if ( iRank == 0 ) then
		return
	end
	
	-- Check if already present
	if self.m_mapSpells:HasSpell( hSpellDesc ) then
		hSpellDesc = self.m_mapSpells:GetSpellDesc( iClassIndex, iSpecIndex, iSpellIndex )
	
		-- Check Rank
		if ( hSpellDesc:GetCurrentRank() == iRank ) then
			return
		end
		
		-- Remove previous Rank
		_Unlearn( hPlayer, hSpellDesc:GetCurrentSpellID() )
		
		-- Update Rank
		self.m_mapSpells:SetSpellRank( iClassIndex, iSpecIndex, iSpellIndex, iRank )
		
		-- Add current Rank
		_Learn( hPlayer, hSpellDesc:GetCurrentSpellID() )
		
		return
	end
	
	-- Apply appropriate Rank
	hSpellDesc:SetCurrentRank( iRank )
	
	-- Add current Rank
	_Learn( hPlayer, hSpellDesc:GetCurrentSpellID() )
	
	-- Add Spell
	self.m_mapSpells:AddSpell( hSpellDesc )
end

-------------------------------------------------------------------------------------------------------------------
-- CLPlayerData : Methods - Talents
function CLPlayerData:GetTalentMap()
	return self.m_mapTalents
end

function CLPlayerData:AddTalent( iClassIndex, iSpecIndex, iGridTier, iGridSlot, iTalentRank )
	-- Get Talent Descriptor
	local hTalentDesc = CLDataTalents:GetInstance():GetTalentDesc( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	
	-- Get Player
	local hPlayer = GetPlayerByGUID( GetPlayerGUID(self.m_iGUID) )
	
	-- Check Grid Tier Requirement
	local iSpecAllocatedTalentPoints = self.m_mapTalents:GetSpecTalentPoints( iClassIndex, iSpecIndex )
	local iTierRequiredTalentPoints = 0
	if hTalentDesc:IsPetTalent() then
		iTierRequiredTalentPoints = CLServer:GetInstance():GetRequiredPetTalentPoints( iGridTier )
	else
		iTierRequiredTalentPoints = CLServer:GetInstance():GetRequiredTalentPoints( iGridTier )
	end
	if ( iSpecAllocatedTalentPoints < iTierRequiredTalentPoints ) then
		return
	end
	
	-- Check Talent Requirement
	local iRequiredTalentGridTier, iRequiredTalentGridSlot = hTalentDesc:GetRequiredTalent()
	if ( iRequiredTalentGridTier ~= 0 and iRequiredTalentGridSlot ~= 0 ) then
		-- Must be present
		if ( not self.m_mapTalents:HasTalent(iClassIndex, iSpecIndex, iRequiredTalentGridTier, iRequiredTalentGridSlot) ) then
			return
		end
		-- Must be maxed
		local hRequiredTalentDesc = self.m_mapTalents:GetTalentDesc( iClassIndex, iSpecIndex, iRequiredTalentGridTier, iRequiredTalentGridSlot )
		if ( not hRequiredTalentDesc:IsMaxed() ) then
			return
		end
	end
	
	-- TalentSpell case
	if hTalentDesc:IsTalentSpell() then
		-- Check if we have enough points
		if hTalentDesc:IsPetTalent() then
			if ( CLServer:GetInstance():GetFreePetTalentPoints(hPlayer) <= 0 ) then
				return
			end
		else
			if ( CLServer:GetInstance():GetFreeTalentPoints(hPlayer) <= 0 ) then
				return
			end
		end
		
		-- Compute appropriate Rank
		local iRank = hTalentDesc:GetTalentSpellRankFromLevel( hPlayer:GetLevel() )
		if ( iRank == 0 ) then
			return
		end
		
		-- Check if already present
		if ( self.m_mapTalents:HasTalent(iClassIndex, iSpecIndex, iGridTier, iGridSlot) ) then
			hTalentDesc = self.m_mapTalents:GetTalentDesc( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
			
			-- Check Rank
			if ( hTalentDesc:GetCurrentRank() == iRank ) then
				return
			end
			
			-- Remove previous Rank
			_Unlearn( hPlayer, hTalentDesc:GetCurrentTalentID() )
			
			-- Update Rank
			self.m_mapTalents:SetTalentRank( iClassIndex, iSpecIndex, iGridTier, iGridSlot, iRank )
			
			-- Add current Rank
			_Learn( hPlayer, hTalentDesc:GetCurrentTalentID() )
			
			return
		end
		
		-- Apply appropriate Rank
		hTalentDesc:SetCurrentRank( iRank )
		
		-- Add current Rank
		_Learn( hPlayer, hTalentDesc:GetCurrentTalentID() )
		
		-- Add Talent
		self.m_mapTalents:AddTalent( hTalentDesc )
		
		return
	end
	
	-- Check if TalentRank is valid
	if ( iTalentRank > hTalentDesc:GetRankCount() ) then
		iTalentRank = hTalentDesc:GetRankCount()
	end
	
	-- Check if already present
	if ( self.m_mapTalents:HasTalent(iClassIndex, iSpecIndex, iGridTier, iGridSlot) ) then
		hTalentDesc = self.m_mapTalents:GetTalentDesc( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	
		-- Get current Rank
		local iRank = hTalentDesc:GetCurrentRank()
		
		-- Check if already Maxed
		if ( iRank == hTalentDesc:GetRankCount() ) then
			return
		end
		
		-- Check for attempt at downgrade (you meanie !)
		if ( iTalentRank <= iRank ) then
			return
		end
		
		-- Check if we have enough points
		if hTalentDesc:IsPetTalent() then
			if ( CLServer:GetInstance():GetFreePetTalentPoints(hPlayer) < (iTalentRank - iRank) ) then
				return
			end
		else
			if ( CLServer:GetInstance():GetFreeTalentPoints(hPlayer) < (iTalentRank - iRank) ) then
				return
			end
		end
		
		-- Remove previous Rank
		_Unlearn( hPlayer, hTalentDesc:GetCurrentTalentID() )
		
		-- Upgrade Rank
		self.m_mapTalents:SetTalentRank( iClassIndex, iSpecIndex, iGridTier, iGridSlot, iTalentRank )
	
		-- Add upgraded Rank
		_Learn( hPlayer, hTalentDesc:GetCurrentTalentID() )
		
		return
	end
	
	-- Check if we have enough points
	if hTalentDesc:IsPetTalent() then
		if ( CLServer:GetInstance():GetFreePetTalentPoints(hPlayer) < iTalentRank ) then
			return
		end
	else
		if ( CLServer:GetInstance():GetFreeTalentPoints(hPlayer) < iTalentRank ) then
			return
		end
	end
	
	-- Apply appropriate Rank
	hTalentDesc:SetCurrentRank( iTalentRank )
	
	-- Add current Rank
	_Learn( hPlayer, hTalentDesc:GetCurrentTalentID() )
	
	-- Add Talent
	self.m_mapTalents:AddTalent( hTalentDesc )
end

-------------------------------------------------------------------------------------------------------------------
-- CLPlayerData : Methods - Glyphs
function CLPlayerData:GetGlyphMap()
	return self.m_mapGlyphs
end

function CLPlayerData:AddGlyph( iClassIndex, iSpecIndex, iGlyphIndex )
	-- Get Glyph Descriptor
	local hGlyphDesc = CLDataGlyphs:GetInstance():GetGlyphDesc( iClassIndex, iSpecIndex, iGlyphIndex )
	
	-- Get Player
	local hPlayer = GetPlayerByGUID( GetPlayerGUID(self.m_iGUID) )
	
	-- Check if we have a free slot
	if hGlyphDesc:IsMajor() then
		if ( CLServer:GetInstance():GetFreeGlyphMajorSlots(hPlayer) <= 0 ) then
			return
		end
	else
		if ( CLServer:GetInstance():GetFreeGlyphMinorSlots(hPlayer) <= 0 ) then
			return
		end
	end
	
	-- Check Level Requirement
	local iLevel = hGlyphDesc:GetGlyphLevel()
	if ( iLevel > hPlayer:GetLevel() ) then
		return
	end
	
	-- Check if already present
	if ( self.m_mapGlyphs:HasGlyph(iClassIndex, iSpecIndex, iGlyphIndex) ) then
		return
	end
	
	-- Add Glyph
	_Learn( hPlayer, hGlyphDesc:GetGlyphID() )

	self.m_mapGlyphs:AddGlyph( hGlyphDesc )
end

-------------------------------------------------------------------------------------------------------------------
-- CLPlayerData : Methods - Database
function CLPlayerData:DBCreate()
    CharDBQuery( "INSERT INTO character_classless VALUES (" .. self.m_iGUID .. ", '', '', '', 0)" )
end
function CLPlayerData:DBDestroy()
	CharDBQuery( "DELETE FROM character_classless WHERE guid = " .. self.m_iGUID )
end

function CLPlayerData:DBLoad()
	-- Load from DB
	local hQuery = CharDBQuery( "SELECT * FROM character_classless WHERE guid = " .. self.m_iGUID )
	if ( hQuery == nil ) then
		return false
	end
	
	local strSpells 	= hQuery:GetString(1)
	local strTalents 	= hQuery:GetString(2)
	local strGlyphs 	= hQuery:GetString(3)
	local iResetCounter = hQuery:GetUInt32(4)
	
	-- Build Player Data
	self.m_mapSpells:Clear()
	self.m_mapTalents:Clear()
	self.m_mapGlyphs:Clear()
	self.m_iResetCounter = iResetCounter

	local arrSpellIDs = _ArrayFromString( strSpells )
	local iSpellCount = #arrSpellIDs
	for i = 1, iSpellCount do
		local iClassIndex, iSpecIndex, iSpellIndex, iRank = CLDataSpells:GetInstance():SearchSpell( arrSpellIDs[i] )
		local hSpellDesc = CLDataSpells:GetInstance():GetSpellDesc( iClassIndex, iSpecIndex, iSpellIndex )
		hSpellDesc:SetCurrentRank( iRank )
		self.m_mapSpells:AddSpell( hSpellDesc )
	end

	local arrTalentIDs = _ArrayFromString( strTalents )
	local iTalentCount = #arrTalentIDs
	for i = 1, iTalentCount do
		local iClassIndex, iSpecIndex, iGridTier, iGridSlot, iRank = CLDataTalents:GetInstance():SearchTalent( arrTalentIDs[i] )
		local hTalentDesc = CLDataTalents:GetInstance():GetTalentDesc( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
		hTalentDesc:SetCurrentRank( iRank )
		self.m_mapTalents:AddTalent( hTalentDesc )
	end
	
	local arrGlyphIDs = _ArrayFromString( strGlyphs )
	local iGlyphCount = #arrGlyphIDs
	for i = 1, iGlyphCount do
		local iClassIndex, iSpecIndex, iGlyphIndex = CLDataGlyphs:GetInstance():SearchGlyph( arrGlyphIDs[i] )
		local hGlyphDesc = CLDataGlyphs:GetInstance():GetGlyphDesc( iClassIndex, iSpecIndex, iGlyphIndex )
		self.m_mapGlyphs:AddGlyph( hGlyphDesc )
	end
	
	return true
end
function CLPlayerData:DBSave()
	-- Build SpellID String
	local arrSpellIDs = {}
	self.m_mapSpells:EnumCallback(
		function( hSpellDesc )
			table.insert( arrSpellIDs, hSpellDesc:GetCurrentSpellID() )
		end
	)
	
	local strSpells = _ArrayToString( arrSpellIDs )
	
	-- Build TalentID String
	local arrTalentIDs = {}
	self.m_mapTalents:EnumCallback(
		function( hTalentDesc )
			table.insert( arrTalentIDs, hTalentDesc:GetCurrentTalentID() )
		end
	)
	
	local strTalents = _ArrayToString( arrTalentIDs )
	
	-- Build GlyphID String
	local arrGlyphIDs = {}
	self.m_mapGlyphs:EnumCallback(
		function( hGlyphDesc )
			table.insert( arrGlyphIDs, hGlyphDesc:GetGlyphID() )
		end
	)

	local strGlyphs = _ArrayToString( arrGlyphIDs )
	
	-- Reset Counter
	local iResetCounter = self.m_iResetCounter
	
	-- Save to DB
	CharDBQuery( "UPDATE character_classless SET spells='" .. strSpells .. "' WHERE guid = " .. self.m_iGUID )
	CharDBQuery( "UPDATE character_classless SET talents='" .. strTalents .. "' WHERE guid = " .. self.m_iGUID )
	CharDBQuery( "UPDATE character_classless SET glyphs='" .. strGlyphs .. "' WHERE guid = " .. self.m_iGUID )
	CharDBQuery( "UPDATE character_classless SET reset_counter='" .. iResetCounter .. "' WHERE guid = " .. self.m_iGUID )
end


