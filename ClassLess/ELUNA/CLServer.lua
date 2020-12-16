-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess Server
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

-- Server Settings (Change these here if you want ... too lazy to make a config file !)
CLCONFIG_SPELL_POINTS_RATE = 1.0
CLCONFIG_TALENT_POINTS_RATE = 1.0
CLCONFIG_REQUIRED_TALENT_POINTS_PER_TIER = 5
CLCONFIG_GLYPH_MAJOR_SLOTS_RATE = 1.0
CLCONFIG_GLYPH_MINOR_SLOTS_RATE = 1.0
CLCONFIG_RESET_PRICES = { 10000, 50000, 100000, 150000, 200000, 350000 } -- in copper, any number of values

-------------------------------------------------------------------------------------------------------------------
-- ClassLessServer - Declaration
ClassLessServer = class({
	-- Static Members
})

function ClassLessServer:init()
	-- Session Token
	self.m_strServerToken = nil
	
	-- Async IO
	self.m_strAIOHandlerName = nil
	self.m_hAIOHandlers = nil
	
	-- Server Settings
	self.m_fSpellPointsRate = CLCONFIG_SPELL_POINTS_RATE
	self.m_fTalentPointsRate = CLCONFIG_TALENT_POINTS_RATE
	self.m_iRequiredTalentPointsPerTier = CLCONFIG_REQUIRED_TALENT_POINTS_PER_TIER
	self.m_fGlyphMajorSlotsRate = CLCONFIG_GLYPH_MAJOR_SLOTS_RATE
	self.m_fGlyphMinorSlotsRate = CLCONFIG_GLYPH_MINOR_SLOTS_RATE
	self.m_arrResetPrices = CLCONFIG_RESET_PRICES
	
	-- Spell/Talent/Glyph Data
	self.m_hCLDataSpells = nil
	self.m_hCLDataTalents = nil
	self.m_hCLDataGlyphs = nil
	
	-- Player Data
	self.m_arrPlayerData = {} -- array( iPlayerGUID -> ClassLessPlayerData )
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessServer : Methods - General
function ClassLessServer:CheckSession( hPlayer, strClientToken )
	local bValid = ( strClientToken == self.m_strServerToken )
	
	if ( not bValid ) then
		hPlayer:SendNotification( "INVALID SESSION : Failed to match Client/Server Tokens !" )
	end
	
	return bValid
end

function ClassLessServer:GetResetCost( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	local iResetCounter = self.m_arrPlayerData[iPlayerGUID]:GetResetCounter()
	return self.m_arrResetPrices[ 1 + math.min(iResetCounter, #(self.m_arrResetPrices) - 1) ]
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessServer : Methods - Spells
function ClassLessServer:GetDataSpells()
	return self.m_hCLDataSpells
end

function ClassLessServer:GetPlayerSpells( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	return self.m_arrPlayerData[iPlayerGUID]:GetSpells()
end

function ClassLessServer:GetTotalSpellPoints( hPlayer )
	return math.floor( hPlayer:GetLevel() * self.m_fSpellPointsRate )
end
function ClassLessServer:GetAllocatedSpellPoints( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	return self.m_arrPlayerData[iPlayerGUID]:GetAllocatedSpellPoints()
end
function ClassLessServer:GetFreeSpellPoints( hPlayer )
	return ( self:GetTotalSpellPoints(hPlayer) - self:GetAllocatedSpellPoints(hPlayer) )
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessServer : Methods - Talents
function ClassLessServer:GetDataTalents()
	return self.m_hCLDataTalents
end

function ClassLessServer:GetPlayerTalents( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	return self.m_arrPlayerData[iPlayerGUID]:GetTalents()
end

function ClassLessServer:GetTotalTalentPoints( hPlayer )
	return math.floor( math.max(hPlayer:GetLevel() - 9, 0) * self.m_fTalentPointsRate )
end
function ClassLessServer:GetAllocatedTalentPoints( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	return self.m_arrPlayerData[iPlayerGUID]:GetAllocatedTalentPoints()
end
function ClassLessServer:GetFreeTalentPoints( hPlayer )
	return ( self:GetTotalTalentPoints(hPlayer) - self:GetAllocatedTalentPoints(hPlayer) )
end

function ClassLessServer:GetRequiredTalentPoints( iGridTier )
	return ( (iGridTier-1) * self.m_iRequiredTalentPointsPerTier )
end
function ClassLessServer:GetRequiredTalentPointsPerTier()
	return self.m_iRequiredTalentPointsPerTier
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessServer : Methods - Glyphs
function ClassLessServer:GetDataGlyphs()
	return self.m_hCLDataGlyphs
end

function ClassLessServer:GetPlayerGlyphs( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	return self.m_arrPlayerData[iPlayerGUID]:GetGlyphs()
end

function ClassLessServer:GetTotalGlyphMajorSlots( hPlayer )
	return math.floor( ( (hPlayer:GetLevel() + 17.5) / 32.5 ) * self.m_fGlyphMajorSlotsRate )
end
function ClassLessServer:GetTotalGlyphMinorSlots( hPlayer )
	return math.floor( ( (hPlayer:GetLevel() + 12.5) / 27.5 ) * self.m_fGlyphMinorSlotsRate )
end
function ClassLessServer:GetAllocatedGlyphMajorSlots( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	return self.m_arrPlayerData[iPlayerGUID]:GetAllocatedGlyphMajorSlots()
end
function ClassLessServer:GetAllocatedGlyphMinorSlots( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	return self.m_arrPlayerData[iPlayerGUID]:GetAllocatedGlyphMinorSlots()
end
function ClassLessServer:GetFreeGlyphMajorSlots( hPlayer )
	return ( self:GetTotalGlyphMajorSlots(hPlayer) - self:GetAllocatedGlyphMajorSlots(hPlayer) )
end
function ClassLessServer:GetFreeGlyphMinorSlots( hPlayer )
	return ( self:GetTotalGlyphMinorSlots(hPlayer) - self:GetAllocatedGlyphMinorSlots(hPlayer) )
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessServer : Initialization
function ClassLessServer:Initialize()
	if ( self.m_hAIOHandlers ~= nil ) then
		return
	end
	local hThis = self
	
	-- Session Token
	math.randomseed( os.clock()^7 )
	
	local arrRandomCharSet = {} -- [0-9a-zA-Z]
	for iChar = 48, 57 do table.insert( arrRandomCharSet, string.char(iChar) ) end
	for iChar = 65, 90 do table.insert( arrRandomCharSet, string.char(iChar) ) end
	for iChar = 97, 122 do table.insert( arrRandomCharSet, string.char(iChar) ) end
	
	self.m_strServerToken = ""
	for i = 1, 128 do
		self.m_strServerToken = self.m_strServerToken .. arrRandomCharSet[math.random(1,#arrRandomCharSet)]
	end

	PrintInfo( "[ClassLess][Server] Session Token generated !" )
	
	-- PlayerEvent : OnDelete (PLAYER_EVENT_ON_CHARACTER_DELETE = 2)
	RegisterPlayerEvent( 2,
		function( iEvent, iPlayerGUID )
			hThis.m_arrPlayerData[iPlayerGUID]:DBDestroy()
			hThis.m_arrPlayerData[iPlayerGUID] = nil
			
			PrintInfo( "[ClassLess][PlayerEvent] Player Destroyed (GUIDLow = " .. iPlayerGUID .. ") !" )
		end
	)
	
	PrintInfo( "[ClassLess][Server] PlayerEvent On-Delete Registered !" )
	
	-- PlayerEvent : OnLogin (PLAYER_EVENT_ON_LOGIN = 3)
	RegisterPlayerEvent( 3,
		function( iEvent, hPlayer )
			local iPlayerGUID = hPlayer:GetGUIDLow()
			hThis.m_arrPlayerData[iPlayerGUID] = ClassLessPlayerData( iPlayerGUID )
			local bLoaded = hThis.m_arrPlayerData[iPlayerGUID]:DBLoad()
			if ( not bLoaded ) then
				hThis.m_arrPlayerData[iPlayerGUID]:DBCreate()
			end
			
			PrintInfo( "[ClassLess][PlayerEvent] Player Loaded/Created (GUIDLow = " .. iPlayerGUID .. ") !" )
		end
	)
	
	PrintInfo( "[ClassLess][Server] PlayerEvent On-Login Registered !" )
	
	-- PlayerEvent : OnLogout (PLAYER_EVENT_ON_LOGOUT = 4)
	RegisterPlayerEvent( 4,
		function( iEvent, hPlayer )
			local iPlayerGUID = hPlayer:GetGUIDLow()
			hThis.m_arrPlayerData[iPlayerGUID]:DBSave()
			hThis.m_arrPlayerData[iPlayerGUID] = nil
			
			PrintInfo( "[ClassLess][PlayerEvent] Player Saved & Disconnected (GUIDLow = " .. iPlayerGUID .. ") !" )
		end
	)
	
	PrintInfo( "[ClassLess][Server] PlayerEvent On-Logout Registered !" )

	-- PlayerEvent : OnSave (PLAYER_EVENT_ON_SAVE = 25)
	RegisterPlayerEvent( 25,
		function( iEvent, hPlayer )
			local iPlayerGUID = hPlayer:GetGUIDLow()
			hThis.m_arrPlayerData[iPlayerGUID]:DBSave()
			
			PrintInfo( "[ClassLess][PlayerEvent] Player Saved (GUIDLow = " .. iPlayerGUID .. ") !" )
		end
	)
	
	PrintInfo( "[ClassLess][Server] PlayerEvent On-Save Registered !" )
	
	-- PlayerEvent : OnLevelChange (PLAYER_EVENT_ON_LEVEL_CHANGE = 13)
	RegisterPlayerEvent( 13,
		function( iEvent, hPlayer, iOldLevel )
			local iPlayerGUID = hPlayer:GetGUIDLow()
			local iNewLevel = hPlayer:GetLevel()
			
			-- Auto-Learn Armor Skills
			if ( iNewLevel >= 10 ) then -- Leather
				if ( not hPlayer:HasSkill(414) ) then
					hPlayer:SetSkill( 414, 0, 1, 1 )
				end
			end
			if ( iNewLevel >= 20 ) then -- Mail
				if ( not hPlayer:HasSkill(413) ) then
					hPlayer:SetSkill( 413, 0, 1, 1 )
				end
			end
			if ( iNewLevel >= 40 ) then -- Plate
				if ( not hPlayer:HasSkill(293) ) then
					hPlayer:SetSkill( 293, 0, 1, 1 )
				end
			end
			
			-- Update All Spells & TalentSpells Ranks
			hThis.m_arrPlayerData[iPlayerGUID]:UpdateAllSpellsRanks()
			
			-- Save Player
			hThis.m_arrPlayerData[iPlayerGUID]:DBSave()
			hPlayer:SaveToDB()
			
			-- Update Client
			AIO.Handle( hPlayer, hThis.m_strAIOHandlerName, "OnLevelChange",
				hThis:GetFreeSpellPoints( hPlayer ),
				hThis:GetFreeTalentPoints( hPlayer ),
				hThis:GetFreeGlyphMajorSlots( hPlayer ),
				hThis:GetFreeGlyphMinorSlots( hPlayer ),
				ClassLessSpellDesc:EncodeSpells( hThis:GetPlayerSpells(hPlayer) ),
				ClassLessTalentDesc:EncodeTalents( hThis:GetPlayerTalents(hPlayer) )
			)
			
			PrintInfo( "[ClassLess][PlayerEvent] Player LevelUp Update (GUIDLow = " .. iPlayerGUID .. ") !" )
		end
	)
	
	PrintInfo( "[ClassLess][Server] PlayerEvent On-LevelChange Registered !" )

	-- Async IO
	self.m_strAIOHandlerName = "ClassLessHandler"
	self.m_hAIOHandlers = AIO.AddHandlers( self.m_strAIOHandlerName, {} )
	
		-- CommitAbilities
	self.m_hAIOHandlers.CommitAbilities = function( hPlayer, arrEncodedSpells, arrEncodedTalents, arrEncodedGlyphs, strClientToken )
		PrintInfo( "[ClassLess][AIO] CommitAbilities Request Received ..." )
		
		-- Validate Session
		local bValidSession = hThis:CheckSession( hPlayer, strClientToken )
		if ( not bValidSession ) then
			PrintInfo( "[ClassLess][AIO] Session Validation Failed !" )
			return
		end
		
		PrintInfo( "[ClassLess][AIO] Session Validation Succeeded !" )
		
		-- Decode Spells / Talents / Glyphs
		local arrPendingSpells = ClassLessSpellDesc:DecodeSpells( arrEncodedSpells )
		local arrPendingTalents = ClassLessTalentDesc:DecodeTalents( arrEncodedTalents )
		local arrPendingGlyphs = ClassLessGlyphDesc:DecodeGlyphs( arrEncodedGlyphs )
		
		-- Get Player GUID
		local iPlayerGUID = hPlayer:GetGUIDLow()
		
		-- Add Pending Spells
		local iSpellCount = #arrPendingSpells
		for i = 1, iSpellCount do
			local hSpellDesc = arrPendingSpells[i]
			hThis.m_arrPlayerData[iPlayerGUID]:AddSpell(
				hSpellDesc:GetClassIndex(), hSpellDesc:GetSpecIndex(),
				hSpellDesc:GetSpellIndex()
			)
		end

		-- Add Pending Talents
		local iTalentCount = #arrPendingTalents
		for i = 1, iTalentCount do
			local hTalentDesc = arrPendingTalents[i]
			hThis.m_arrPlayerData[iPlayerGUID]:AddTalent(
				hTalentDesc:GetClassIndex(), hTalentDesc:GetSpecIndex(),
				hTalentDesc:GetGridTier(), hTalentDesc:GetGridSlot(),
				hTalentDesc:GetCurrentRank()
			)
		end
		
		-- Add Pending Glyphs
		local iGlyphCount = #arrPendingGlyphs
		for i = 1, iGlyphCount do
			local hGlyphDesc = arrPendingGlyphs[i]
			hThis.m_arrPlayerData[iPlayerGUID]:AddGlyph(
				hGlyphDesc:GetClassIndex(), hGlyphDesc:GetSpecIndex(),
				hGlyphDesc:GetGlyphIndex()
			)
		end
		
		-- Save Player
		hThis.m_arrPlayerData[iPlayerGUID]:DBSave()
		hPlayer:SaveToDB()
		
		-- Update Client
		AIO.Handle( hPlayer, hThis.m_strAIOHandlerName, "OnCommitAbilities",
			hThis:GetFreeSpellPoints( hPlayer ),
			hThis:GetFreeTalentPoints( hPlayer ),
			hThis:GetFreeGlyphMajorSlots( hPlayer ),
			hThis:GetFreeGlyphMinorSlots( hPlayer ),
			ClassLessSpellDesc:EncodeSpells( hThis:GetPlayerSpells(hPlayer) ),
			ClassLessTalentDesc:EncodeTalents( hThis:GetPlayerTalents(hPlayer) ),
			ClassLessGlyphDesc:EncodeGlyphs( hThis:GetPlayerGlyphs(hPlayer) )
		)
		
		PrintInfo( "[ClassLess][AIO] CommitAbilities Completed !" )
	end
	
	PrintInfo( "[ClassLess][Server] AIO Handler CommitAbilities Registered !" )

		-- ResetAbilities
	self.m_hAIOHandlers.ResetAbilities = function( hPlayer, strClientToken )
		PrintInfo( "[ClassLess][AIO] ResetAbilities Request Received ..." )
		
		-- Validate Session
		local bValidSession = hThis:CheckSession( hPlayer, strClientToken )
		if ( not bValidSession ) then
			return
		end
		
		PrintInfo( "[ClassLess][AIO] Session Validation Succeeded !" )
		
		-- Get Player GUID
		local iPlayerGUID = hPlayer:GetGUIDLow()
		
		-- Check if the player can reset
		if ( not hThis.m_arrPlayerData[iPlayerGUID]:CanReset() ) then
			hPlayer:SendNotification( "There is nothing to reset !" )
			
			PrintInfo( "[ClassLess][AIO] ResetAbilities Aborted (Nothing to Reset) !" )
			return
		end
		
		-- Get Reset Cost
		local iResetCost = hThis:GetResetCost( hPlayer )

		-- Check if player has enough money
		if ( hPlayer:GetCoinage() < iResetCost ) then
			hPlayer:SendNotification( "Not enough money ! Sorry !" )
			
			PrintInfo( "[ClassLess][AIO] ResetAbilities Aborted (Not Enough Money) !" )
			return
		end

		-- Pay the Price !
		hPlayer:ModifyMoney( -iResetCost )

		-- Perform Reset
		hThis.m_arrPlayerData[iPlayerGUID]:Reset()
		
		-- Save Player
		hThis.m_arrPlayerData[iPlayerGUID]:DBSave()
		hPlayer:SaveToDB()
		
		-- Update Client
		AIO.Handle( hPlayer, hThis.m_strAIOHandlerName, "OnResetAbilities",
			hThis:GetFreeSpellPoints( hPlayer ),
			hThis:GetFreeTalentPoints( hPlayer ),
			hThis:GetFreeGlyphMajorSlots( hPlayer ),
			hThis:GetFreeGlyphMinorSlots( hPlayer ),
			hThis:GetResetCost( hPlayer )
		)
		
		PrintInfo( "[ClassLess][AIO] ResetAbilities Completed !" )
	end
	
	PrintInfo( "[ClassLess][Server] AIO Handler ResetAbilities Registered !" )
	
	-- Initialize Spell/Talent/Glyph Data
	self.m_hCLDataSpells = ClassLessDataSpells()
	self.m_hCLDataSpells:Initialize()
	
	self.m_hCLDataTalents = ClassLessDataTalents()
	self.m_hCLDataTalents:Initialize()
	
	self.m_hCLDataGlyphs = ClassLessDataGlyphs()
	self.m_hCLDataGlyphs:Initialize()
	
	-- Initialize Player Data
	local arrAllPlayers = GetPlayersInWorld()
	local iPlayerCount = #arrAllPlayers
	for i = 1, iPlayerCount do
		local iPlayerGUID = arrAllPlayers[i]:GetGUIDLow()
		self.m_arrPlayerData[iPlayerGUID] = ClassLessPlayerData( iPlayerGUID )
		local bLoaded = self.m_arrPlayerData[iPlayerGUID]:DBLoad()
		if ( not bLoaded ) then
			self.m_arrPlayerData[iPlayerGUID]:DBCreate()
		end
	end
	
	PrintInfo( "[ClassLess][Server] " .. iPlayerCount .. " Player(s) Loaded !" )
end

-------------------------------------------------------------------------------------------------------------------
-- Entry Point
PrintInfo( "[ClassLess][Server] Server Initialization ..." )

CLServer = ClassLessServer()
CLServer:Initialize()

-- Async IO
local function ClientInit( hMessage, hPlayer )
	PrintInfo( "[ClassLess][AIO] (Server-Side) ClientInit !" )

    -- Initialize Client
    AIO.Handle( hPlayer, CLServer.m_strAIOHandlerName, "OnClientInit",
		CLServer:GetFreeSpellPoints( hPlayer ),
		CLServer:GetFreeTalentPoints( hPlayer ),
		CLServer:GetRequiredTalentPointsPerTier(),
		CLServer:GetFreeGlyphMajorSlots( hPlayer ),
		CLServer:GetFreeGlyphMinorSlots( hPlayer ),
		CLServer:GetResetCost( hPlayer ),
		ClassLessSpellDesc:EncodeSpells( CLServer:GetPlayerSpells(hPlayer) ),
		ClassLessTalentDesc:EncodeTalents( CLServer:GetPlayerTalents(hPlayer) ),
		ClassLessGlyphDesc:EncodeGlyphs( CLServer:GetPlayerGlyphs(hPlayer) ),
		CLServer.m_strServerToken
	)

	return hMessage
end
AIO.AddOnInit( ClientInit )

PrintInfo( "[ClassLess][Server] AIO Handler ClientInit Registered !" )

PrintInfo( "[ClassLess][Server] Server Initialization Complete !" )

