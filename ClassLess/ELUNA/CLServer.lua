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
if not CLConfig then require("CLConfig") end
if not CLDataSpells then require("CLDataSpells") end
if not CLDataTalents then require("CLDataTalents") end
if not CLDataGlyphs then require("CLDataGlyphs") end

-------------------------------------------------------------------------------------------------------------------
-- Client / Server Setup

-- Server-side Only !

-------------------------------------------------------------------------------------------------------------------
-- Constants

-------------------------------------------------------------------------------------------------------------------
-- CLServer - Declaration
CLServer = class({
	-- Static Members
	sm_hInstance = nil
})
function CLServer:GetInstance()
	if ( self.sm_hInstance == nil ) then
		self.sm_hInstance = CLServer()
		self.sm_hInstance:Initialize()
	end
	return self.sm_hInstance
end

function CLServer:init()
	-- Session Token
	self.m_strServerToken = nil
	
	-- Async IO
	self.m_strAIOHandlerName = nil
	self.m_hAIOHandlers = nil
	
	-- Player Data
	self.m_arrPlayerData = {} -- array( iPlayerGUID -> ClassLessPlayerData )
end

-------------------------------------------------------------------------------------------------------------------
-- CLServer : Methods - General
function CLServer:CheckSession( hPlayer, strClientToken )
	local bValid = ( strClientToken == self.m_strServerToken )
	
	if ( not bValid ) then
		hPlayer:SendNotification( "INVALID SESSION : Failed to match Client/Server Tokens !" )
	end
	
	return bValid
end

function CLServer:GetResetCost( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	local iResetCounter = self.m_arrPlayerData[iPlayerGUID]:GetResetCounter()
	return CLConfig.AbilityResetCosts[ 1 + math.min(iResetCounter, #(CLConfig.AbilityResetCosts) - 1) ]
end

-------------------------------------------------------------------------------------------------------------------
-- CLServer : Methods - Spells
function CLServer:GetPlayerSpells( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	return self.m_arrPlayerData[iPlayerGUID]:GetSpellMap()
end

function CLServer:GetTotalSpellPoints( hPlayer )
	return math.floor( hPlayer:GetLevel() * CLConfig.SpellPointsRate )
end
function CLServer:GetTotalPetSpellPoints( hPlayer )
	return math.floor( hPlayer:GetLevel() * 0.5 * CLConfig.PetSpellPointsRate )
end
function CLServer:GetAllocatedSpellPoints( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	return self.m_arrPlayerData[iPlayerGUID]:GetSpellMap():GetSpellPoints()
end
function CLServer:GetAllocatedPetSpellPoints( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	return self.m_arrPlayerData[iPlayerGUID]:GetSpellMap():GetPetSpellPoints()
end
function CLServer:GetFreeSpellPoints( hPlayer )
	return ( self:GetTotalSpellPoints(hPlayer) - self:GetAllocatedSpellPoints(hPlayer) )
end
function CLServer:GetFreePetSpellPoints( hPlayer )
	return ( self:GetTotalPetSpellPoints(hPlayer) - self:GetAllocatedPetSpellPoints(hPlayer) )
end

-------------------------------------------------------------------------------------------------------------------
-- CLServer : Methods - Talents
function CLServer:GetPlayerTalents( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	return self.m_arrPlayerData[iPlayerGUID]:GetTalentMap()
end

function CLServer:GetTotalTalentPoints( hPlayer )
	return math.floor( math.max(hPlayer:GetLevel() - 9, 0) * CLConfig.TalentPointsRate )
end
function CLServer:GetTotalPetTalentPoints( hPlayer )
	return math.floor( math.max(hPlayer:GetLevel() - 9, 0) * 0.5 * CLConfig.PetTalentPointsRate )
end
function CLServer:GetAllocatedTalentPoints( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	return self.m_arrPlayerData[iPlayerGUID]:GetTalentMap():GetTalentPoints()
end
function CLServer:GetAllocatedPetTalentPoints( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	return self.m_arrPlayerData[iPlayerGUID]:GetTalentMap():GetPetTalentPoints()
end
function CLServer:GetFreeTalentPoints( hPlayer )
	return ( self:GetTotalTalentPoints(hPlayer) - self:GetAllocatedTalentPoints(hPlayer) )
end
function CLServer:GetFreePetTalentPoints( hPlayer )
	return ( self:GetTotalPetTalentPoints(hPlayer) - self:GetAllocatedPetTalentPoints(hPlayer) )
end

function CLServer:GetRequiredTalentPoints( iGridTier )
	return ( (iGridTier-1) * CLConfig.RequiredTalentPointsPerTier )
end
function CLServer:GetRequiredPetTalentPoints( iGridTier )
	return ( (iGridTier-1) * CLConfig.RequiredPetTalentPointsPerTier )
end

-------------------------------------------------------------------------------------------------------------------
-- CLServer : Methods - Glyphs
function CLServer:GetPlayerGlyphs( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	return self.m_arrPlayerData[iPlayerGUID]:GetGlyphMap()
end

function CLServer:GetTotalGlyphMajorSlots( hPlayer )
	return math.floor( ( (hPlayer:GetLevel() + 17.5) / 32.5 ) * CLConfig.GlyphMajorSlotsRate )
end
function CLServer:GetTotalGlyphMinorSlots( hPlayer )
	return math.floor( ( (hPlayer:GetLevel() + 12.5) / 27.5 ) * CLConfig.GlyphMinorSlotsRate )
end
function CLServer:GetAllocatedGlyphMajorSlots( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	return self.m_arrPlayerData[iPlayerGUID]:GetGlyphMap():GetGlyphMajorSlots()
end
function CLServer:GetAllocatedGlyphMinorSlots( hPlayer )
	local iPlayerGUID = hPlayer:GetGUIDLow()
	return self.m_arrPlayerData[iPlayerGUID]:GetGlyphMap():GetGlyphMinorSlots()
end
function CLServer:GetFreeGlyphMajorSlots( hPlayer )
	return ( self:GetTotalGlyphMajorSlots(hPlayer) - self:GetAllocatedGlyphMajorSlots(hPlayer) )
end
function CLServer:GetFreeGlyphMinorSlots( hPlayer )
	return ( self:GetTotalGlyphMinorSlots(hPlayer) - self:GetAllocatedGlyphMinorSlots(hPlayer) )
end

-------------------------------------------------------------------------------------------------------------------
-- CLServer : Initialization
function CLServer:Initialize()
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
			hThis.m_arrPlayerData[iPlayerGUID] = CLPlayerData( iPlayerGUID )
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
				hThis:GetFreePetSpellPoints( hPlayer ),
				hThis:GetFreeTalentPoints( hPlayer ),
				hThis:GetFreePetTalentPoints( hPlayer ),
				hThis:GetFreeGlyphMajorSlots( hPlayer ),
				hThis:GetFreeGlyphMinorSlots( hPlayer ),
				hThis:GetPlayerSpells(hPlayer):Encode(),
				hThis:GetPlayerTalents(hPlayer):Encode()
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
		local mapPendingSpells = CLSpellMap()
		local mapPendingTalents = CLTalentMap()
		local mapPendingGlyphs = CLGlyphMap()
		mapPendingSpells:Decode( arrEncodedSpells )
		mapPendingTalents:Decode( arrEncodedTalents )
		mapPendingGlyphs:Decode( arrEncodedGlyphs )
		
		-- Get Player GUID
		local iPlayerGUID = hPlayer:GetGUIDLow()
		
		-- Add Pending Spells
		mapPendingSpells:EnumCallback(
			function( hSpellDesc )
				hThis.m_arrPlayerData[iPlayerGUID]:AddSpell(
					hSpellDesc:GetClassIndex(), hSpellDesc:GetSpecIndex(),
					hSpellDesc:GetSpellIndex()
				)
			end
		)

		-- Add Pending Talents
		mapPendingTalents:EnumCallback(
			function( hTalentDesc )
				hThis.m_arrPlayerData[iPlayerGUID]:AddTalent(
					hTalentDesc:GetClassIndex(), hTalentDesc:GetSpecIndex(),
					hTalentDesc:GetGridTier(), hTalentDesc:GetGridSlot(),
					hTalentDesc:GetCurrentRank()
				)
			end
		)
		
		-- Add Pending Glyphs
		mapPendingGlyphs:EnumCallback(
			function( hGlyphDesc )
				hThis.m_arrPlayerData[iPlayerGUID]:AddGlyph(
					hGlyphDesc:GetClassIndex(), hGlyphDesc:GetSpecIndex(),
					hGlyphDesc:GetGlyphIndex()
				)
			end
		)
		
		-- Save Player
		hThis.m_arrPlayerData[iPlayerGUID]:DBSave()
		hPlayer:SaveToDB()
		
		-- Update Client
		AIO.Handle( hPlayer, hThis.m_strAIOHandlerName, "OnCommitAbilities",
			hThis:GetFreeSpellPoints( hPlayer ),
			hThis:GetFreePetSpellPoints( hPlayer ),
			hThis:GetFreeTalentPoints( hPlayer ),
			hThis:GetFreePetTalentPoints( hPlayer ),
			hThis:GetFreeGlyphMajorSlots( hPlayer ),
			hThis:GetFreeGlyphMinorSlots( hPlayer ),
			hThis:GetPlayerSpells(hPlayer):Encode(),
			hThis:GetPlayerTalents(hPlayer):Encode(),
			hThis:GetPlayerGlyphs(hPlayer):Encode()
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
			hThis:GetFreePetSpellPoints( hPlayer ),
			hThis:GetFreeTalentPoints( hPlayer ),
			hThis:GetFreePetTalentPoints( hPlayer ),
			hThis:GetFreeGlyphMajorSlots( hPlayer ),
			hThis:GetFreeGlyphMinorSlots( hPlayer ),
			hThis:GetResetCost( hPlayer )
		)
		
		PrintInfo( "[ClassLess][AIO] ResetAbilities Completed !" )
	end
	
	PrintInfo( "[ClassLess][Server] AIO Handler ResetAbilities Registered !" )
	
	-- Initialize Player Data
	local arrAllPlayers = GetPlayersInWorld()
	local iPlayerCount = #arrAllPlayers
	for i = 1, iPlayerCount do
		local iPlayerGUID = arrAllPlayers[i]:GetGUIDLow()
		self.m_arrPlayerData[iPlayerGUID] = CLPlayerData( iPlayerGUID )
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

local hServerInstance = CLServer:GetInstance()

-- Async IO
local function ClientInit( hMessage, hPlayer )
	PrintInfo( "[ClassLess][AIO] (Server-Side) ClientInit !" )

    -- Initialize Client
    AIO.Handle( hPlayer, hServerInstance.m_strAIOHandlerName, "OnClientInit",
		hServerInstance:GetFreeSpellPoints( hPlayer ),
		hServerInstance:GetFreePetSpellPoints( hPlayer ),
		hServerInstance:GetFreeTalentPoints( hPlayer ),
		hServerInstance:GetFreePetTalentPoints( hPlayer ),
		CLConfig.RequiredTalentPointsPerTier,
		CLConfig.RequiredPetTalentPointsPerTier,
		hServerInstance:GetFreeGlyphMajorSlots( hPlayer ),
		hServerInstance:GetFreeGlyphMinorSlots( hPlayer ),
		hServerInstance:GetResetCost( hPlayer ),
		hServerInstance:GetPlayerSpells(hPlayer):Encode(),
		hServerInstance:GetPlayerTalents(hPlayer):Encode(),
		hServerInstance:GetPlayerGlyphs(hPlayer):Encode(),
		hServerInstance.m_strServerToken
	)

	return hMessage
end
AIO.AddOnInit( ClientInit )

PrintInfo( "[ClassLess][Server] AIO Handler ClientInit Registered !" )

PrintInfo( "[ClassLess][Server] Server Initialization Complete !" )

