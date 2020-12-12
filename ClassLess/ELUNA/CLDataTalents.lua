-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess Data : Talents
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Requirements
local AIO = AIO or require("AIO")
if not class then require("class") end

-------------------------------------------------------------------------------------------------------------------
-- Client / Server Setup

-- Needed on both sides !
if AIO.IsServer() then
	AIO.AddAddon()
end

-------------------------------------------------------------------------------------------------------------------
-- Constants
if ( CLClassCount == nil ) then
	CLClassCount = 10
end
if ( CLClassNames == nil ) then
	CLClassNames = { "DeathKnight", "Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior" }
end

if ( CLClassSpecCount == nil ) then
	CLClassSpecCount = 3
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessTalentDesc - Declaration
ClassLessTalentDesc = class({
	-- Static Members
})

function ClassLessTalentDesc:init( iClassIndex, iSpecIndex, iGridTier, iGridSlot,
								   arrTalentIDs, iRequiredTalentGridTier, iRequiredTalentGridSlot,
								   bIsTalentSpell, arrTalentSpellLevels, hObject )
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
-- ClassLessTalentDesc : Encoding / Decoding
function ClassLessTalentDesc:ToArray( hTalentDesc )
	return {
		hTalentDesc.m_iClassIndex, hTalentDesc.m_iSpecIndex, hTalentDesc.m_iGridTier, hTalentDesc.m_iGridSlot,
		hTalentDesc.m_arrTalentIDs, hTalentDesc.m_iRequiredTalentGridTier, hTalentDesc.m_iRequiredTalentGridSlot,
		hTalentDesc.m_bIsTalentSpell, hTalentDesc.m_arrTalentSpellLevels, hTalentDesc.m_iCurrentRank
	}
end
function ClassLessTalentDesc:FromArray( arrTalentDesc )
	local hTalentDesc = ClassLessTalentDesc(
		arrTalentDesc[1], arrTalentDesc[2], arrTalentDesc[3], arrTalentDesc[4],
		arrTalentDesc[5], arrTalentDesc[6], arrTalentDesc[7],
		arrTalentDesc[8], arrTalentDesc[9]
	)
	hTalentDesc.m_iCurrentRank = arrTalentDesc[10]
	return hTalentDesc
end

function ClassLessTalentDesc:EncodeTalents( arrTalents )
	local arrEncodedTalents = {}
	for i = 1, #arrTalents do
		arrEncodedTalents[i] = ClassLessTalentDesc:ToArray( arrTalents[i] )
	end
	return arrEncodedTalents
end
function ClassLessTalentDesc:DecodeTalents( arrTalents )
	local arrDecodedTalents = {}
	for i = 1, #arrTalents do
		arrDecodedTalents[i] = ClassLessTalentDesc:FromArray( arrTalents[i] )
	end
	return arrDecodedTalents
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessTalentDesc : Getters / Setters
function ClassLessTalentDesc:GetClassIndex()
	return self.m_iClassIndex
end
function ClassLessTalentDesc:GetSpecIndex()
	return self.m_iSpecIndex
end
function ClassLessTalentDesc:GetGridTier()
	return self.m_iGridTier
end
function ClassLessTalentDesc:GetGridSlot()
	return self.m_iGridSlot
end

function ClassLessTalentDesc:GetRankCount()
	return #( self.m_arrTalentIDs )
end
function ClassLessTalentDesc:GetTalentID( iRank )
	return self.m_arrTalentIDs[iRank]
end
function ClassLessTalentDesc:GetRequiredTalent()
	return self.m_iRequiredTalentGridTier, self.m_iRequiredTalentGridSlot
end
function ClassLessTalentDesc:IsTalentSpell()
	return self.m_bIsTalentSpell
end
function ClassLessTalentDesc:GetTalentSpellLevel( iRank )
	return self.m_arrTalentSpellLevels[iRank]
end

function ClassLessTalentDesc:GetCurrentRank()
	return self.m_iCurrentRank
end
function ClassLessTalentDesc:SetCurrentRank( iRank )
	self.m_iCurrentRank = iRank
end
function ClassLessTalentDesc:GetCurrentTalentID()
	return self.m_arrTalentIDs[self.m_iCurrentRank]
end
function ClassLessTalentDesc:GetCurrentTalentSpellLevel()
	return self.m_arrTalentSpellLevels[self.m_iCurrentRank]
end
function ClassLessTalentDesc:GetCurrentCost()
	if self.m_bIsTalentSpell then
		return 1
	end
	return self.m_iCurrentRank
end
function ClassLessTalentDesc:IsMaxed()
	if self.m_bIsTalentSpell then
		return ( self.m_iCurrentRank >= 1 )
	end
	return ( self.m_iCurrentRank >= self:GetRankCount() )
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessTalentDesc : Methods
function ClassLessTalentDesc:GetIcon()
	local strName, iRank, hIcon = GetSpellInfo( self.m_arrTalentIDs[1] )
	return hIcon
end

function ClassLessTalentDesc:GetTalentSpellRankFromLevel( iPlayerLevel )
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
function ClassLessTalentDesc:GetTalentSpellIDFromLevel( iPlayerLevel )
	local iRank = self:GetTalentSpellRankFromLevel( iPlayerLevel )
	return self:GetTalentID( iRank )
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessDataTalents : Declaration
ClassLessDataTalents = class({
	-- Static Members
})

-- Format :
-- m_arrTalents[classname][specindex] = {
--     	[1] - string : specname
--     	[2] - string : specicon
--		[3] - int : talent grid width
--		[4] - int : talent grid height
--		[5] - array : talentgrid = {
--			[1] - array : SpellIDs per rank, can be empty
--			[2] - array : {gridTier,gridSlot}, required Talent, {0,0} if none
--			[3] - bool int : is TalentSpell ?
--			[4] - array : TalentSpell Levels per rank, empty if not a TalentSpell
--			[5] - string : arrow layout (empty cell case) = "Vert" or "Horiz" or "LeftDown" or "RightDown" or "None"
--			[5] - array : arrow layout (talent cell case) = {
--				[1] - string : left arrow = "In" or "Out" or "None"
--				[2] - string : right arrow = "In" or "Out" or "None"
--				[3] - string : top arrow = "In" or "None"
--				[4] - string : bottom arrow = "Out" or "None"
--			}
--		}
-- }
function ClassLessDataTalents:init()
	-- Members
	self.m_arrTalents = nil
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessDataTalents : Getters / Setters
function ClassLessDataTalents:GetClassSpecName( iClassIndex, iSpecIndex )
	return self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][1]
end
function ClassLessDataTalents:GetClassSpecTexture( iClassIndex, iSpecIndex )
	return self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][2]
end

function ClassLessDataTalents:GetGridWidth( iClassIndex, iSpecIndex )
	return self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][3]
end
function ClassLessDataTalents:GetGridHeight( iClassIndex, iSpecIndex )
	return self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][4]
end

function ClassLessDataTalents:IsEmptyCell( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	return ( #(self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][5][iGridTier][iGridSlot][1]) == 0 )
end

function ClassLessDataTalents:GetTalentDesc( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	return ClassLessTalentDesc(
		iClassIndex, iSpecIndex, iGridTier, iGridSlot,
		self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][5][iGridTier][iGridSlot][1],
		self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][5][iGridTier][iGridSlot][2][1],
		self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][5][iGridTier][iGridSlot][2][2],
		( self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][5][iGridTier][iGridSlot][3] ~= 0 ),
		self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][5][iGridTier][iGridSlot][4]
	)
end

function ClassLessDataTalents:GetEmptyCellArrow( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	return self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][5][iGridTier][iGridSlot][5]
end

function ClassLessDataTalents:GetTalentCellArrowLeft( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	return self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][5][iGridTier][iGridSlot][5][1]
end
function ClassLessDataTalents:GetTalentCellArrowRight( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	return self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][5][iGridTier][iGridSlot][5][2]
end
function ClassLessDataTalents:GetTalentCellArrowTop( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	return self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][5][iGridTier][iGridSlot][5][3]
end
function ClassLessDataTalents:GetTalentCellArrowBottom( iClassIndex, iSpecIndex, iGridTier, iGridSlot )
	return self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][5][iGridTier][iGridSlot][5][4]
end

function ClassLessDataTalents:SearchTalent( iTalentID )
	for iClassIndex = 1, CLClassCount do
		for iSpecIndex = 1, CLClassSpecCount do
			local iGridWidth = self:GetGridWidth( iClassIndex, iSpecIndex )
			local iGridHeight = self:GetGridHeight( iClassIndex, iSpecIndex )
			for iGridTier = 1, iGridHeight do
				for iGridSlot = 1, iGridWidth do
					local iRankCount = #( self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][5][iGridTier][iGridSlot][1] )
					for iRank = 1, iRankCount do
						local iCurrentTalentID = self.m_arrTalents[CLClassNames[iClassIndex]][iSpecIndex][5][iGridTier][iGridSlot][1][iRank]
						if ( iCurrentTalentID == iTalentID ) then
							return iClassIndex, iSpecIndex, iGridTier, iGridSlot, iRank
						end
					end
				end
			end
		end
	end
	return 0,0,0,0,0
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessDataTalents : Initialization
function ClassLessDataTalents:Initialize()
	if ( self.m_arrTalents ~= nil ) then
		return
	end

	-- Create Data Array
	self.m_arrTalents = {}
	
	-- DeathKnight
	self.m_arrTalents.DeathKnight = {
		{
			"Blood", "Interface\\TalentFrame\\DeathKnightBlood", 4, 11, {
				{
					{ {48979,49483}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {48997,49490,49491}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49182,49500,49501,55225,55226}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {48978,49390,49391,49392,49393}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49004,49508,49509}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {55107,55108}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {48982}, {0,0}, 1, {20}, {"None","None","None","Out"} },
					{ {48987,49477,49478,49479,49480}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {49467,50033,50034}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {48985,49488,49489}, {3,1}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {49145,49495,49497}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49015,50154,55136}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {48977,49394,49395}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {49006,49526,50029}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49005}, {0,0}, 1, {30}, {"None","None","None","None"} }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {48988,49503,49504}, {3,2}, 0, {}, {"None","None","In","None"} },
					{ {53137,53138}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {49027,49542,49543}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49016}, {0,0}, 1, {40}, {"None","None","None","None"} },
					{ {50365,50371}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {62905,62908}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49018,49529,49530}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {55233}, {0,0}, 1, {45}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {49189,50149,50150}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {55050,55258,55259,55260,55261,55262}, {0,0}, 1, {50,59,64,69,74,80}, {"None","None","None","None"} },
					{ {49023,49533,49534}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {61154,61155,61156,61157,61158}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {49028}, {0,0}, 1, {60}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Frost", "Interface\\TalentFrame\\DeathKnightFrost", 4, 11, {
				{
					{ {49175,50031,51456}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {49455,50147}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49042,49786,49787,49788,49789}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {55061,55062}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49140,49661,49662,49663,49664}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49226,50137,50138}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {50880,50884,50885,50886,50887}, {1,1}, 0, {}, {"None","None","In","Out"} },
					{ {49039}, {0,0}, 1, {20}, {"None","None","None","None"} },
					{ {51468,51472,51473}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {51123,51127,51128,51129,51130}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49149,50115}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49137,49657}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {49186,51108,51109}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49471,49790,49791}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49796}, {0,0}, 1, {30}, {"None","None","None","None"} }
				},
				{
					{ {55610}, {3,1}, 0, {}, {"None","None","In","None"} },
					{ {49024,49538}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49188,56822,59057}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {50040,50041,50043}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49203}, {0,0}, 1, {40}, {"None","None","None","None"} },
					{ {50384,50385}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {65661,66191,66192}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {54639,54638,54637}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {51271}, {0,0}, 1, {45}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {49200,50151,50152}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49143,51416,51417,51418,41419,55268}, {0,0}, 1, {50,60,65,70,75,80}, {"None","None","None","None"} },
					{ {50187,50190,50191}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {49202,50127,50128,50129,50130}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {49184,51409,51410,51411}, {0,0}, 1, {60,70,75,80}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Unholy", "Interface\\TalentFrame\\DeathKnightUnholy", 4, 11, {
				{
					{ {51745,51746}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {48962,49567,49568}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {55129,55130,55131,55132,55133}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {49036,49562}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {48963,49564,49565}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49588,49589}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {48965,49571,49572}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {49013,55236,55237}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {51459,51462,51463,51464,51465}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49158,51325,51326,51327,51328}, {0,0}, 1, {20,60,70,75,80}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {49146,51267}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49219,49627,49628}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {55620,55623}, {0,0}, 0, {}, {"None","None","None","Out"} }
				},
				{
					{ {49194}, {0,0}, 1, {30}, {"None","None","None","None"} },
					{ {49220,49633,49635,49636,49638}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49223,49599}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" }
				},
				{
					{ {55666,55667}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {49224,49610,49611}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {49208,56834,56835}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {52143}, {4,4}, 0, {}, {"None","None","In","Out"} }
				},
				{
					{ {66799,66814,66815,66816,66817}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {51052}, {6,2}, 1, {40}, {"None","None","In","None"} },
					{ {50391,50392}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {63560}, {6,4}, 1, {40}, {"None","None","In","None"} }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {49032,49631,49632}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {49222}, {0,0}, 1, {45}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {49217,49654,49655}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {51099,51160,51161}, {8,2}, 0, {}, {"None","None","In","None"} },
					{ {55090,55265,55270,55271}, {0,0}, 1, {50,67,73,79}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {50117,50118,50119,50120,50121}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {49206}, {0,0}, 1, {60}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		}
	}
	
	-- Druid
	self.m_arrTalents.Druid = {
		{
			"Balance", "Interface\\TalentFrame\\DruidBalance", 4, 11, {
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {16814,16815,16816,16817,16818}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {57810,57811,57812,57813,57814}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {16845,16846,16847}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {35363,35364}, {0,0}, 0, {}, {"None","Out","None","Out"} },
					{ {}, {0,0}, 0, {}, "LeftDown" },
					{ {16821,16822}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {16836,16839,16840}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16880,61345,61346}, {2,2}, 0, {}, {"None","None","In","None"} },
					{ {57865}, {2,2}, 0, {}, {"None","None","In","None"} },
					{ {16819,16820}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {16909,16910,16911,16912,16913}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16850,16923,16924}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {33589,33590,33591}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {5570,24974,24975,24976,24977,27013,48468}, {0,0}, 1, {20,30,40,50,60,70,80}, {"None","Out","None","None"} },
					{ {57849,57850,57851}, {5,2}, 0, {}, {"In","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {33597,33599,33956}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16896,16897,16899}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {33592,33596}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "RightDown" },
					{ {24858}, {0,0}, 1, {40}, {"Out","Out","None","Out"} },
					{ {48384,48395,48396}, {7,2}, 0, {}, {"In","None","None","None"} },
					{ {33600,33601,33602}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {48389,48392,48393}, {7,2}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {33603,33604,33605,33606,33607}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {48516,48521,48525}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {50516,53223,53225,53226,61384}, {7,2}, 1, {50,60,70,75,80}, {"None","None","In","None"} },
					{ {33831}, {0,0}, 1, {50}, {"None","None","None","None"} },
					{ {48488,48514}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {48506,48510,48511}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {48505,53199,53200,53201}, {0,0}, 1, {60,70,75,80}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Feral Combat", "Interface\\TalentFrame\\DruidFeralCombat", 4, 11, {
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {16934,16935,16936,16937,16938}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16858,16859,16860,16861,16862}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {16947,16948,16949}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16998,16999}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16929,16930,16931}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {17002,24866}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {61336}, {0,0}, 1, {20}, {"None","None","None","None"} },
					{ {16942,16943,16944}, {0,0}, 0, {}, {"None","Out","None","Out"} },
					{ {}, {0,0}, 0, {}, "LeftDown" }
				},
				{
					{ {16966,16968}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16972,16974,16975}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {37116,37117}, {3,3}, 0, {}, {"None","None","In","None"} },
					{ {48409,48410}, {3,3}, 0, {}, {"None","None","In","None"} }
				},
				{
					{ {16940,16941}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {49377}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {33872,33873}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {57878,57880,57881}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {17003,17004,17005,17006,24894}, {4,2}, 0, {}, {"None","None","In","None"} },
					{ {33853,33855,33856}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "RightDown" },
					{ {17007}, {0,0}, 0, {}, {"Out","Out","None","Out"} }, -- Leader of the Pack ... TODO : check this is properly handled
					{ {34297,34300}, {7,2}, 0, {}, {"In","None","None","None"} },
					{ {33851,33852,33957}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {57873,57876,57877}, {7,2}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {33859,33866,33867}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {48483,48484,48485}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {48492,48494,48495}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {33917}, {7,2}, 0, {}, {"None","Out","In","None"} }, -- Mangle has both bear & cat spells ... TODO : Find a way to handle this without changing everything !
					{ {48532,48489,48491}, {9,2}, 0, {}, {"In","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {48432,48433,48434,51268,51269}, {0,0}, 0, {}, {"None","Out","None","None"} },
					{ {63503}, {10,2}, 0, {}, {"In","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {50334}, {0,0}, 1, {60}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Restoration", "Interface\\TalentFrame\\DruidRestoration", 4, 11, {
				{
					{ {17050,17051}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {17063,17065,17066}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {17056,17058,17059,17060,17061}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {17069,17070,17071,17072,17073}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {17118,17119,17120}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16833,16834,16835}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {17106,17107,17108}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {16864}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {48411,48412}, {2,3}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {24968,24969,24970,24971,24972}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {17111,17112,17113}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {17116}, {3,1}, 1, {30}, {"None","None","In","None"} },
					{ {17104,24943,24944,24945,24946}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {17123,17124}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {33879,33880}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {17074,17075,17076,17077,17078}, {4,3}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {34151,34152,34153}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {18562}, {5,2}, 1, {40}, {"None","None","In","None"} },
					{ {33881,33882,33883}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {33886,33887,33888,33889,33890}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {48496,48499,48500}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {48539,48544,48545}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {65139}, {8,2}, 0, {}, {"None","Out","In","Out"} }, -- Tree of Life : 65139 = talent, 33891 = shapeshift spell ... TODO : Deal with it !
					{ {48535,48536,48537}, {9,2}, 0, {}, {"In","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {63410,63411}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {51179,51180,51181,51182,51183}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {48438,53248,53249,53251}, {9,2}, 1, {60,70,75,80}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		}
	}
	
	-- Hunter
	self.m_arrTalents.Hunter = {
		{
			"Beast Mastery", "Interface\\TalentFrame\\HunterBeastMastery", 4, 11, {
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {19552,19553,19554,19555,19556}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19583,19584,19585,19586,19587}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {35029,35030}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19549,19550,19551}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19609,19610,19612}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {24443,19575}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {19559,19560}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {53265}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19616,19617,19618,19619,19620}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {19572,19573}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19598,19599,19600,19601,19602}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {19578,20895}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19577}, {0,0}, 1, {30}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {19590,19592}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {34453,34454}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {19621,19622,19623,19624,19625}, {4,3}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {34455,34459,34460}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {19574}, {5,2}, 1, {40}, {"None","None","In","Out"} },
					{ {34462,34464,34465}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {53252,53253}, {7,1}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {34466,34467,34468,34469,34470}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {53262,53263,53264}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {34692}, {7,2}, 0, {}, {"None","None","In","None"} },
					{ {53256,53259,53260}, {8,3}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {56314,56315,56316,56317,56318}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {53270}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Marksmanship", "Interface\\TalentFrame\\HunterMarksmanship", 4, 11, {
				{
					{ {19407,19412}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {53620,53621,53622}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19426,19427,19429,19430,19431}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {34482,34483,34484}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19421,19422,19423}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19485,19487,19488,19489,19490}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {34950,34954}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19454,19455,19456}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19434,20900,20901,20902,20903,20904,27065,49049,49050}, {2,3}, 1, {20,28,36,44,52,60,70,75,80}, {"None","None","In","None"} },
					{ {34948,34949}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {19464,19465,19466}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19416,19417,19418,19419,19420}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {35100,35102}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {23989}, {0,0}, 1, {30}, {"None","None","None","Out"} },
					{ {19461,19462,24691}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {34475,34476}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {19507,19508,19509}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {53234,53237,53238}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19506}, {5,2}, 1, {40}, {"None","None","In","None"} },
					{ {35104,35110,35111}, {5,3}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {34485,34486,34487,34488,34489}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {53228,53232}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {53215,53216,53217}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {34490}, {8,2}, 1, {50}, {"None","None","In","None"} },
					{ {53221,53222,53224}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {53241,53243,53244,53245,53246}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {53209}, {0,0}, 1, {60}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Survival", "Interface\\TalentFrame\\HunterSurvival", 4, 11, {
				{
					{ {52783,52785,52786,52787,52788}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19498,19499,19500}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19159,19160}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {19290,19294,24283}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19184,19387,19388}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19376,63457,63458}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {34494,34496}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {19255,19256,19257,19258,19259}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {19503}, {0,0}, 1, {20}, {"None","None","None","None"} },
					{ {19295,19297,19298}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {19286,19287}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {56333,56336,56337}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {56342,56343,56344}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {56339,56340,56341}, {3,1}, 0, {}, {"None","None","In","None"} },
					{ {19370,19371,19373}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {19306,20909,20910,27067,48998,48999}, {3,3}, 1, {30,42,54,66,72,78}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {19168,19180,19181,24296,24297}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {34491,34492,34493}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {34500,34502,34503}, {6,1}, 0, {}, {"None","None","In","None"} },
					{ {19386,24132,24133,27068,49011,49012}, {5,2}, 1, {40,50,60,70,75,80}, {"None","None","In","Out"} },
					{ {34497,34498,34499}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {34506,34507,34508,34838,34839}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {53295,53296,53297}, {7,2}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {53298,53299}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {3674,63668,63669,63670,63671,63672}, {0,0}, 1, {50,57,63,69,75,80}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {53302,53303,53304}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {53290,53291,53292}, {7,3}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {53301,60051,60052,60053}, {9,2}, 1, {60,70,75,80}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		}
	}
	
	-- Mage
	self.m_arrTalents.Mage = {
		{
			"Arcane", "Interface\\TalentFrame\\MageArcane", 4, 11, {
				{
					{ {11210,12592}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11222,12839,12840}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11237,12463,12464,16769,16770}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {28574,54658,54659}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {29441,29444}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11213,12574,12575,12576,12577}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {11247,12606}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11242,12467,12469}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {44397,44398,44399}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {54646}, {0,0}, 1, {20}, {"None","None","None","None"} }
				},
				{
					{ {11252,12605}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11255,12598}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {18462,18463,18464}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {29447,55339,55340}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {31569,31570}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12043}, {0,0}, 1, {30}, {"None","Out","None","Out"} },
					{ {}, {0,0}, 0, {}, "LeftDown" },
					{ {11232,12500,12501,12502,12503}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {31574,31575,54354}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {15058,15059,15060}, {5,2}, 0, {}, {"None","None","In","Out"} },
					{ {31571,31572}, {5,2}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {31579,31582,31583}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12042}, {6,2}, 1, {40}, {"None","None","In","Out"} },
					{ {44394,44395,44396}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {44378,44379}, {7,2}, 0, {}, {"None","None","In","None"} },
					{ {31584,31585,31586,31587,31588}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {31589}, {0,0}, 1, {50}, {"None","None","None","None"} },
					{ {44404,54486,54488,54489,54490}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {44400,44402,44403}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {35578,35581}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {44425,44780,44781}, {0,0}, 1, {60,70,80}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Fire", "Interface\\TalentFrame\\MageFire", 4, 11, {
				{
					{ {11078,11080}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {18459,18460,54734}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11069,12338,12339,12340,12341}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {11119,11120,12846,12847,12848}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {54747,54749}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11108,12349,12350}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {11100,12353}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11103,12357,12358}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11366,12505,12522,12523,12524,12525,12526,18809,27132,33938,42890,42891}, {0,0}, 1, {20,24,30,36,42,48,54,60,66,70,73,77}, {"None","None","None","Out"} },
					{ {11083,12351}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {11095,12872,12873}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11094,13043}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {29074,29075,29076}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {31638,31639,31640}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11115,11367,11368}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {11113,13018,13019,13020,13021,27133,33933,42944,42945}, {3,3}, 1, {30,36,44,52,60,65,70,75,80}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {31641,31642}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {11124,12378,12398,12399,12400}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {34293,34295,34296}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11129}, {5,2}, 1, {40}, {"None","None","In","Out"} },
					{ {31679,31680}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {64353,64357}, {0,0}, 0, {}, {"None","None","None","None"} }, -- Fiery Payback ... TODO : Check this is handled properly
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {31656,31657,31658}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {44442,44443}, {9,2}, 0, {}, {"None","In","None","None"} },
					{ {31661,33041,33042,33043,42949,42950}, {7,2}, 1, {50,56,64,70,75,80}, {"Out","None","In","None"} },
					{ {44445,44446,44448}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {44449,44469,44470,44471,44472}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {44457,55359,55360}, {0,0}, 1, {60,70,80}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Frost", "Interface\\TalentFrame\\MageFrost", 4, 11, {
				{
					{ {11071,12496,12497}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11070,12473,16763,16765,16766}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {31670,31672,55094}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {11207,12672,15047}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11189,28332}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {29438,29439,29440}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11175,12569,12571}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {11151,12952,12953}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12472}, {0,0}, 1, {20}, {"None","None","None","None"} },
					{ {11185,12487,12488}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {16757,16758}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11160,12518,12519}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {11170,12982,12983}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "RightDown" },
					{ {11958}, {0,0}, 1, {30}, {"Out","None","None","Out"} },
					{ {11190,12489,12490}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {31667,31668,31669}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {55091,55092}, {5,2}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {11180,28592,28593}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {44745,54787}, {7,2}, 0, {}, {"None","In","None","None"} },
					{ {11426,13031,13032,13033,27134,33405,43038,43039}, {5,2}, 1, {40,46,52,58,64,70,75,80}, {"Out","None","In","None"} },
					{ {31674,31675,31676,31677,31678}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {31682,31683}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {44543,44545}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {44546,44548,44549}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {31687}, {0,0}, 1, {50}, {"None","Out","None","None"} },
					{ {44557,44560,44561}, {9,2}, 0, {}, {"In","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {44566,44567,44568,44570,44571}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {44572}, {0,0}, 1, {60}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		}
	}
	
	-- Paladin
	self.m_arrTalents.Paladin = {
		{
			"Holy", "Interface\\TalentFrame\\PaladinHoly", 4, 11, {
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {20205,20206,20207,20209,20208}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20224,20225,20330,20331,20332}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {20237,20238,20239}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20257,20258,20259,20260,20261}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {9453,25836}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {31821}, {0,0}, 1, {20}, {"None","None","None","None"} },
					{ {20210,20212,20213,20214,20215}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {20234,20235}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {20254,20255,20256}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {20244,20245}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {53660,53661}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {31822,31823}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20216}, {3,2}, 1, {30}, {"None","None","In","Out"} },
					{ {20359,20360,20361}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {31825,31826}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {5923,5924,5925,5926,25829}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {31833,31835,31836}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20473,20929,20930,27174,33072,48824,48825}, {5,2}, 1, {40,48,56,64,70,75,80}, {"None","None","In","Out"} },
					{ {31828,31829,31830}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {53551,53552,53553}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {31837,31838,31839,31840,31841}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {31842}, {0,0}, 1, {50}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {53671,53673,54151,54154,54155}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {53569,53576}, {7,2}, 0, {}, {"None","None","In","None"} },
					{ {53556,53557}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {53563}, {0,0}, 1, {60}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Protection", "Interface\\TalentFrame\\PaladinProtection", 4, 11, {
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {63646,63647,63648,63649,63650}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20262,20263,20264,20265,20266}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {31844,31845,53519}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20174,20175}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20096,20097,20098,20099,20100}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {64205}, {0,0}, 1, {20}, {"None","None","None","Out"} },
					{ {20468,20469,20470}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20143,20144,20145,20146,20147}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {53527,53530}, {3,1}, 0, {}, {"None","None","In","None"} },
					{ {20487,20488}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20138,20139,20140}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {20911}, {0,0}, 1, {30}, {"None","None","None","Out"} },
					{ {20177,20179,20181,20180,20182}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {31848,31849}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {20196,20197,20198}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {31785,33776}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20925,20927,20928,27179,48951,48952}, {5,2}, 1, {40,50,60,70,75,80}, {"None","None","In","Out"} },
					{ {31850,31851,31852}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {20127,20130,20135}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {31858,31859,31860}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {53590,53591,53592}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {31935,32699,32700,48826,48827}, {7,2}, 1, {50,60,70,75,80}, {"None","None","In","Out"} },
					{ {53583,53585}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {53709,53710,53711}, {9,2}, 0, {}, {"None","None","In","None"} },
					{ {53695,53696}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {53595}, {0,0}, 1, {60}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Retribution", "Interface\\TalentFrame\\PaladinCombat", 4, 11, {
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {20060,20061,20062,20063,20064}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20101,20102,20103,20104,20105}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {25956,25957}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20335,20336,20337}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20042,20045}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {9452,26016}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20117,20118,20119,20120,20121}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {20375}, {0,0}, 1, {20}, {"None","None","None","None"} },
					{ {26022,26023}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {9799,25988}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {32043,35396,35397}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {31866,31867,31868}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {20111,20112,20113}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {31869}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {20049,20056,20057}, {3,2}, 0, {}, {"None","None","In","None"} },
					{ {31871,31872}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {53486,53488}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20066}, {0,0}, 1, {40}, {"None","None","None","Out"} },
					{ {31876,31877,31878}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {31879,31880,31881}, {7,2}, 0, {}, {"None","None","In","None"} },
					{ {53375,53376}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {53379,53484,53648}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {35395}, {0,0}, 1, {50}, {"None","None","None","None"} },
					{ {53501,53502,53503}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {53380,53381,53382}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {53385}, {0,0}, 1, {60}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		}
	}
	
	-- Priest
	self.m_arrTalents.Priest = {
		{
			"Discipline", "Interface\\TalentFrame\\PriestDiscipline", 4, 11, {
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {14522,14788,14789,14790,14791}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {47586,47587,47588,52802,52803}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {14523,14784,14785}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14747,14770,14771}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14749,14767}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14531,14774}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {14521,14776,14777}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14751}, {0,0}, 1, {20}, {"None","None","None","None"} },
					{ {14748,14768,14769}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {33167,33171,33172}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14520,14780,14781}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {14750,14772}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {33201,33202}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {18551,18552,18553,18554,18555}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {63574}, {3,3}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {33186,33190}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {34908,34909,34910}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {45234,45243,45244}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {10060}, {5,2}, 1, {40}, {"None","None","In","None"} },
					{ {63504,63505,63506}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {57470,57472}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {47535,47536,47537}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {47507,47508}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {47509,47511,47515}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {33206}, {0,0}, 1, {50}, {"None","None","None","None"} },
					{ {47516,47517}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {52795,52797,52798,52799,52800}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {47540,53005,53006,53007}, {0,0}, 1, {60,70,75,80}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Holy", "Interface\\TalentFrame\\PriestHoly", 4, 11, {
				{
					{ {14913,15012}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14908,15020,17191}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14889,15008,15009,15010,15011}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {27900,27901,27902,27903,27904}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {18530,18531,18533,18534,18535}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {19236,19238,19240,19241,19242,19243,25437,48172,48173}, {0,0}, 1, {20,26,34,42,50,58,66,73,80}, {"None","None","None","None"} },
					{ {27811,27815,27816}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {14892,15362,15363}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {27789,27790}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14912,15013,15014}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14909,15017}, {2,3}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {14911,15018}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20711}, {0,0}, 0, {}, {"None","None","None","Out"} }, -- Spirit of Redemption ... TODO : Check this is handled properly
					{ {14901,15028,15029,15030,15031}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {33150,33154}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {14898,15349,15354,15355,15356}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {34753,34859,34860}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {724,27870,27871,28275,48086,48087}, {5,2}, 1, {40,50,60,70,75,80}, {"None","None","In","None"} },
					{ {33142,33145,33146}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {64127,64129}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {33158,33159,33160,33161,33162}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {63730,63733,63737}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {63534,63542,63543}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {34861,34863,34864,34865,34866,48088,48089}, {0,0}, 1, {50,56,60,65,70,75,80}, {"None","None","None","None"} },
					{ {47558,47559,47560}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {47562,47564,47565,47566,47567}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {47788}, {0,0}, 1, {60}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Shadow", "Interface\\TalentFrame\\PriestShadow", 4, 11, {
				{
					{ {15270,15335,15336}, {0,0}, 0, {}, {"None","Out","None","None"} },
					{ {15337,15338}, {1,1}, 0, {}, {"In","None","None","None"} },
					{ {15259,15307,15308,15309,15310}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {15318,15272,15320}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {15275,15317}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {15260,15327,15328}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {15392,15448}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {15273,15312,15313,15314,15316}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {15407,17311,17312,17313,17314,18807,25387,48155,48156}, {0,0}, 1, {20,28,36,44,52,60,68,74,80}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {15274,15311}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {17322,17323}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {15257,15331,15332}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {15487}, {3,1}, 1, {30}, {"None","None","In","None"} },
					{ {15286}, {0,0}, 1, {30}, {"None","Out","None","Out"} },
					{ {27839,27840}, {5,2}, 0, {}, {"In","None","None","None"} },
					{ {33213,33214,33215}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {14910,33371}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {63625,63626,63627}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "RightDown" },
					{ {15473}, {5,2}, 1, {40}, {"Out","None","In","Out"} },
					{ {33221,33222,33223,33224,33225}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {47569,47570}, {7,2}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {33191,33192,33193}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {64044}, {0,0}, 1, {50}, {"None","None","None","None"} },
					{ {34914,34916,34917,48159,48160}, {7,2}, 1, {50,60,70,75,80}, {"None","None","In","Out"} },
					{ {47580,47581,47582}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {47573,47577,47578,51166,51167}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {47585}, {9,2}, 1, {60}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		}
	}
	
	-- Rogue
	self.m_arrTalents.Rogue = {
		{
			"Assassination", "Interface\\TalentFrame\\RogueAssassination", 4, 11, {
				{
					{ {14162,14163,14164}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14144,14148}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14138,14139,14140,14141,14142}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {14156,14160,14161}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {51632,51633}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {13733,13865,13866}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {14983}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14168,14169}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14128,14132,14135,14136,14137}, {1,3}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {16513,16514,16515}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14113,14114,14115,14116,14117}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {31208,31209}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14177}, {0,0}, 1, {30}, {"None","None","None","Out"} },
					{ {14174,14175,14176}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {31244,31245}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {14186,14190,14193,14194,14195}, {5,2}, 0, {}, {"None","None","In","None"} },
					{ {14158,14159}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {51625,51626}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {58426}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {31380,31382,31383}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {51634,51635,51636}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {31234,31235,31236}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {31226,31227,58410}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {1329,34411,34412,34413,48663,48666}, {7,2}, 1, {40,50,60,70,75,80}, {"None","None","In","None"} },
					{ {51627,51628,51629}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {51664,51665,51667,51668,51669}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {51662}, {0,0}, 1, {60}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Combat", "Interface\\TalentFrame\\RogueCombat", 4, 11, {
				{
					{ {13741,13793,13792}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {13732,13863}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {13715,13848,13849,13851,13852}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {14165,14166}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {13713,13853,13854}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {13705,13832,13843,13844,13845}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {13742,13872}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14251}, {2,2}, 1, {20}, {"None","None","In","None"} },
					{ {13706,13804,13805,13806,13807}, {1,3}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {13754,13867}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {13743,13875}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {13712,13788,13789}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {18427,18428,18429,61330,61331}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {13709,13800,13801,13802,13803}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {13877}, {0,0}, 1, {30}, {"None","None","None","Out"} },
					{ {13960,13961,13962,13963,13964}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {30919,30920}, {5,2}, 0, {}, {"None","None","In","None"} },
					{ {31124,31126}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {31122,31123,61329}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {13750}, {0,0}, 1, {40}, {"None","None","None","Out"} },
					{ {31130,31131}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {5952,51679}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {35541,35550,35551,35552,35553}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {51672,51674}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {32601}, {7,2}, 0, {}, {"None","None","In","None"} },
					{ {51682,58413}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {51685,51686,51687,51688,51689}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {51690}, {0,0}, 1, {60}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Subtlety", "Interface\\TalentFrame\\RogueSubtlety", 4, 11, {
				{
					{ {14179,58422,58423,58424,58425}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {13958,13970,13971}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14057,14072}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {30892,30893}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14076,14094}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {13975,14062,14063}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {13981,14066}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14278}, {0,0}, 1, {20}, {"None","None","None","None"} },
					{ {14171,14172,14173}, {0,0}, 0, {}, {"None","Out","None","None"} },
					{ {}, {0,0}, 0, {}, "LeftDown" }
				},
				{
					{ {13983,14070,14071}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {13976,13979,13980}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14079,14080}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" }
				},
				{
					{ {30894,30895}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14185}, {0,0}, 1, {30}, {"None","None","None","Out"} },
					{ {14082,14083}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16511,17347,17348,26864,48660}, {3,3}, 1, {30,46,58,70,80}, {"None","None","In","None"} }
				},
				{
					{ {31221,31222,31223}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {30902,30903,30904,30905,30906}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {31211,31212,31213}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {14183}, {5,2}, 1, {40}, {"None","None","In","Out"} },
					{ {31228,31229,31230}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {31216,31217,31218,31219,31220}, {7,2}, 0, {}, {"None","None","In","None"} },
					{ {51692,51696}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {51698,51700,51701}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {36554}, {0,0}, 1, {50}, {"None","None","None","None"} },
					{ {58414,58415}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {51708,51709,51710,51711,51712}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {51713}, {0,0}, 1, {60}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		}
	}
	
	-- Shaman
	self.m_arrTalents.Shaman = {
		{
			"Elemental", "Interface\\TalentFrame\\ShamanElementalCombat", 4, 11, {
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {16039,16109,16110,16111,16112}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16035,16105,16106,16107,16108}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {16038,16160,16161}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {28996,28997,28998}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {30160,29179,29180}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {16040,16113,16114,16115,16116}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16164}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {16089,60184,60185,60187,60188}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {16086,16544}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {29062,29064,29065}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {28999,29000}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16041}, {3,2}, 0, {}, {"None","None","In","Out"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {30664,30665,30666}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {30672,30673,30674}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {16578,16579,16580,16581,16582}, {3,3}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {16166}, {5,2}, 1, {40}, {"None","None","In","Out"} },
					{ {51483,51485,51486}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {63370,63372}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {51466,51470}, {7,2}, 0, {}, {"None","None","In","None"} },
					{ {30675,30678,30679}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {51474,51478,51479}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {30706,57720,57721,57722}, {0,0}, 1, {50,60,70,80}, {"None","None","None","None"} },
					{ {51480,51481,51482}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {62097,62098,62099,62100,62101}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {51490,59156,59158,59159}, {0,0}, 1, {60,70,75,80}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Enhancement", "Interface\\TalentFrame\\ShamanEnhancement", 4, 11, {
				{
					{ {16259,16295,52456}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16043,16130}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {17485,17486,17487,17488,17489}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {16258,16293}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16255,16302,16303,16304,16305}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {16262,16287}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16261,16290,51881}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {16266,29079,29080}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {43338}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16254,16271,16272}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {16256,16281,16282,16283,16284}, {2,2}, 0, {}, {"None","None","In","None"} },
					{ {16252,16306,16307,16308,16309}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {29192,29193}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16268}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {51883,51884,51885}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {30802,30808,30809}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {29082,29084,29086}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {63373,63374}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {30816,30818,30819}, {7,2}, 0, {}, {"None","In","None","None"} },
					{ {30798}, {5,2}, 0, {}, {"Out","None","In","Out"} },
					{ {17364}, {0,0}, 1, {40}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {51525,51526,51527}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {60103}, {7,2}, 1, {45}, {"None","None","In","None"} },
					{ {51521,51522}, {7,3}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {30812,30813,30814}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {30823}, {0,0}, 1, {50}, {"None","None","None","None"} },
					{ {51523,51524}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {51528,51529,51530,51531,51532}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {51533}, {0,0}, 1, {60}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Restoration", "Interface\\TalentFrame\\ShamanRestoration", 4, 11, {
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {16182,16226,16227,16228,16229}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16173,16222,16223,16224,16225}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {16184,16209}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {29187,29189,29191}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16179,16214,16215,16216,16217}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {16180,16196,16198}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16181,16230,16232}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {55198}, {0,0}, 1, {20}, {"None","None","None","None"} },
					{ {16176,16235,16240}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {16187,16205,16206}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {16194,16218,16219,16220,16221}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {29206,29205,29202}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {16188}, {0,0}, 1, {30}, {"None","None","None","None"} },
					{ {30864,30865,30866}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {16178,16210,16211,16212,16213}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {30881,30883,30884,30885,30886}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16190}, {4,2}, 1, {40}, {"None","None","In","None"} },
					{ {51886}, {6,3}, 1, {40}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {51554,51555}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {30872,30873}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {30867,30868,30869}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {51556,51557,51558}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {974,32593,32594,49283,49284}, {0,0}, 1, {50,60,70,75,80}, {"None","Out","None","None"} },
					{ {51560,51561}, {9,2}, 0, {}, {"In","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {51562,51563,51564,51565,51566}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {61295,61299,61300,61301}, {0,0}, 1, {60,70,75,80}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		}
	}
	
	-- Warlock
	self.m_arrTalents.Warlock = {
		{
			"Affliction", "Interface\\TalentFrame\\WarlockCurses", 4, 11, {
				{
					{ {18827,18829}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {18174,18175,18176}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {17810,17811,17812,17813,17814}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {18179,18180}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {18213,18372}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {18182,18183}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {17804,17805}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {53754,53759}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {17783,17784,17785}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {18288}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {18218,18219}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {18094,18095}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {32381,32382,32383}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {32385,32387,32392,32393,32394}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {63108}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {18223}, {3,3}, 1, {30}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {54037,54038}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {18271,18272,18273,18274,18275}, {5,2}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {47195,47196,47197}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {30060,30061,30062,30063,30064}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {18220,18937,18938,27265,59092}, {0,0}, 1, {40,50,60,70,80}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {30054,30057}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {32477,32483,32484}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {47198,47199,47200}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {30108,30404,30405,47841,47843}, {7,2}, 1, {50,60,70,75,80}, {"None","Out","In","None"} },
					{ {58435}, {9,2}, 0, {}, {"In","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {47201,47202,47203,47204,47205}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {48181,59161,59163,59164}, {0,0}, 1, {60,70,75,80}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Demonology", "Interface\\TalentFrame\\WarlockSummoning", 4, 11, {
				{
					{ {18692,18693}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {18694,18695,18696}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {18697,18698,18699}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {47230,47231}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {18703,18704}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {18705,18706,18707}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {18731,18743,18744}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {18754,18755,18756}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {19028}, {0,0}, 1, {20}, {"None","None","None","Out"} },
					{ {18708}, {0,0}, 1, {20}, {"None","None","None","Out"} },
					{ {30143,30144,30145}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {}, {0,0}, 0, {}, "RightDown" },
					{ {18769,18770,18771,18772,18773}, {3,2}, 0, {}, {"Out","None","In","Out"} },
					{ {18709,18710}, {3,3}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {30326}, {4,2}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {18767,18768}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {23785,23822,23823,23824,23825}, {4,2}, 0, {}, {"None","None","In","Out"} },
					{ {47245,47246,47247}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {30319,30320,30321}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {47193}, {6,2}, 1, {40}, {"None","None","In","None"} },
					{ {35691,35692,35693}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "RightDown" },
					{ {30242,30245,30246,30247,30248}, {0,0}, 0, {}, {"Out","None","None","None"} },
					{ {63156,63158}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {54347,54348,54349}, {8,2}, 0, {}, {"None","None","In","None"} },
					{ {30146}, {0,0}, 1, {50}, {"None","None","None","None"} },
					{ {63117,63121,63123}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {47236,47237,47238,47239,47240}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {47241}, {0,0}, 1, {60}, {"None","None","None","None"} }, -- Metamorphosis ... TODO : Check this is handled properly
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Destruction", "Interface\\TalentFrame\\WarlockDestruction", 4, 11, {
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {17793,17796,17801,17802,17803}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {17788,17789,17790,17791,17792}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {18119,18120}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {63349,63350,63351}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {17778,17779,17780}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {18126,18127}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {17877,18867,18868,18869,18870,18871,27263,30546,47826,47827}, {0,0}, 1, {20,24,32,40,48,56,63,70,75,80}, {"None","None","None","None"} },
					{ {17959,59738,59739,59740,59741}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {18135,18136}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {17917,17918}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {17927,17929,17930}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {34935,34938,34939}, {4,1}, 0, {}, {"None","None","In","None"} },
					{ {17815,17833,17834}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {18130}, {3,3}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {30299,30301,30302}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {17954,17955,17956,17957,17958}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "RightDown" },
					{ {17962}, {5,2}, 1, {40}, {"Out","None","In","None"} },
					{ {30293,30295,30296}, {0,0}, 0, {}, {"None","None","None","Out"} },
					{ {18096,18073,63245}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {30288,30289,30290,30291,30292}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {54117,54118}, {7,3}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {47258,47259,47260}, {7,2}, 0, {}, {"None","None","In","None"} },
					{ {30283,30413,30414,47846,47847}, {0,0}, 1, {50,60,70,75,80}, {"None","None","None","None"} },
					{ {47220,47221,47223}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {47266,47267,47268,47269,47270}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {50796,59170,59171,59172}, {0,0}, 1, {60,70,75,80}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		}
	}
	
	-- Warrior
	self.m_arrTalents.Warrior = {
		{
			"Arms", "Interface\\TalentFrame\\WarriorArms", 4, 11, {
				{
					{ {12282,12663,12664}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16462,16463,16464,16465,16466}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12286,12658}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {12285,12697}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12300,12959,12960}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12295,12676,12677}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {12290,12963}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12296}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {16493,16494}, {0,0}, 0, {}, {"None","Out","None","None"} },
					{ {12834,12849,12867}, {3,3}, 0, {}, {"In","None","None","None"} }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {12163,12711,12712}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {56636,56637,56638}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {12700,12781,12783,12784,12785}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12328}, {0,0}, 1, {30}, {"None","None","None","Out"} },
					{ {12284,12701,12702,12703,12704}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12281,12812,12813,12814,12815}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {20504,20505}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {12289,12668,23695}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {46854,46855}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {29834,29838}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12294,21551,21552,21553,25248,30330,47485,47486}, {5,2}, 1, {40,48,54,60,66,70,75,80}, {"None","None","In","Out"} },
					{ {46865,46866}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12862,12330}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {64976}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {35446,35448,35449}, {7,2}, 0, {}, {"None","None","In","None"} },
					{ {46859,46860}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {29723,29725,29724}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {29623}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {29836,29859}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {46867,56611,56612,56613,56614}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {46924}, {0,0}, 1, {60}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Fury", "Interface\\TalentFrame\\WarriorFury", 4, 11, {
				{
					{ {61216,61221,61222}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12321,12835}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12320,12852,12853,12855,12856}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {12324,12876,12877,12878,12879}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12322,12999,13000,13001,13002}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {12329,12950,20496}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12323}, {0,0}, 1, {20}, {"None","None","None","None"} },
					{ {16487,16489,16492}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12318,12857,12858,12860,12861}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {23584,23585,23586,23587,23588}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20502,20503}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12317,13045,13046,13047,13048}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {29590,29591,29592}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12292}, {0,0}, 1, {30}, {"None","None","None","Out"} },
					{ {29888,29889}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {20500,20501}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {12319,12971,12972,12973,12974}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {46908,46909,56924}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {23881}, {5,2}, 1, {40}, {"None","Out","In","Out"} },
					{ {}, {0,0}, 0, {}, "LeftDown" },
					{ {29721,29776}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {46910,46911}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {29759,29760,29761,29762,29763}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {60970}, {0,0}, 1, {50}, {"None","None","None","None"} },
					{ {29801}, {7,2}, 0, {}, {"None","None","In","None"} },
					{ {46913,46914,46915}, {7,2}, 0, {}, {"None","None","In","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {56927,56929,56930,56931,56932}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {46917}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		},
		{
			"Protection", "Interface\\TalentFrame\\WarriorProtection", 4, 11, {
				{
					{ {12301,12818}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12298,12724,12725,12726,12727}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12287,12665,12666}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {50685,50686,50687}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12297,12750,12751,12752,12753}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {12975}, {0,0}, 1, {20}, {"None","None","None","None"} },
					{ {12797,12799}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {29598,29599}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12299,12761,12762,12763,12764}, {0,0}, 0, {}, {"None","None","None","None"} }
				},
				{
					{ {59088,59089}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12313,12804}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12308,12810,12811}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {12312,12803}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {12809}, {0,0}, 1, {30}, {"None","None","None","Out"} },
					{ {12311,12958}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "Vert" },
					{ {16538,16539,16540,16541,16542}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {29593,29594}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {50720}, {5,2}, 1, {40}, {"None","None","In","None"} },
					{ {29787,29790,29792}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {29140,29143,29144}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {46945,46949}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {57499}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {20243,30016,30022,47497,47498}, {0,0}, 1, {50,60,70,75,80}, {"None","None","None","Out"} },
					{ {47294,47295,47296}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {46951,46952,46953}, {9,2}, 0, {}, {"None","None","In","None"} },
					{ {58872,58874}, {0,0}, 0, {}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" }
				},
				{
					{ {}, {0,0}, 0, {}, "None" },
					{ {46968}, {0,0}, 1, {60}, {"None","None","None","None"} },
					{ {}, {0,0}, 0, {}, "None" },
					{ {}, {0,0}, 0, {}, "None" }
				}
			}
		}
	}
	
	print( "[ClassLess] Talent Data Initialized !" )
end




