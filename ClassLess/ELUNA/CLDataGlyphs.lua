-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess Data : Glyphs
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Requirements
local AIO = AIO or require("AIO")
if not class then require("class") end
if not CLGlyphDesc then require("CLMapGlyphs") end

-------------------------------------------------------------------------------------------------------------------
-- Client / Server Setup

-- Needed on both sides !
if AIO.IsServer() then
	AIO.AddAddon()
end

-------------------------------------------------------------------------------------------------------------------
-- CLDataGlyphs : Declaration
CLDataGlyphs = class({
	-- Static Members
	sm_hInstance = nil
})
function CLDataGlyphs:GetInstance()
	if ( self.sm_hInstance == nil ) then
		self.sm_hInstance = CLDataGlyphs()
		self.sm_hInstance:Initialize()
	end
	return self.sm_hInstance
end

-- Format :
-- m_arrGlyphs[classname][specindex] = {
--     	[1] - string : specname
--     	[2] - string : spectexture
--		[3] - array( iGlyphIndex -> {iGlyphID, iGlyphLevel, bIsMajor} )
-- }
function CLDataGlyphs:init()
	-- Members
	self.m_arrGlyphs = nil
end

-------------------------------------------------------------------------------------------------------------------
-- CLDataGlyphs : Getters / Setters
function CLDataGlyphs:GetClassSpecName( iClassIndex, iSpecIndex )
	return self.m_arrGlyphs[CLClassNames[iClassIndex]][iSpecIndex][1]
end
function CLDataGlyphs:GetClassSpecTexture( iClassIndex, iSpecIndex )
	return self.m_arrGlyphs[CLClassNames[iClassIndex]][iSpecIndex][2]
end

function CLDataGlyphs:GetGlyphCount( iClassIndex, iSpecIndex )
	return #( self.m_arrGlyphs[CLClassNames[iClassIndex]][iSpecIndex][3] )
end

function CLDataGlyphs:GetGlyphDesc( iClassIndex, iSpecIndex, iGlyphIndex )
	return CLGlyphDesc(
		iClassIndex, iSpecIndex, iGlyphIndex,
		self.m_arrGlyphs[CLClassNames[iClassIndex]][iSpecIndex][3][iGlyphIndex][1],
		self.m_arrGlyphs[CLClassNames[iClassIndex]][iSpecIndex][3][iGlyphIndex][2],
		( self.m_arrGlyphs[CLClassNames[iClassIndex]][iSpecIndex][3][iGlyphIndex][3] ~= 0 )
	)
end

function CLDataGlyphs:SearchGlyph( iGlyphID )
	for iClassIndex = 1, CLClassCount do
		for iSpecIndex = 1, CLClassSpecCount do
			local iGlyphCount = self:GetGlyphCount( iClassIndex, iSpecIndex )
			for iGlyphIndex = 1, iGlyphCount do
				local iCurrentGlyphID = self.m_arrGlyphs[CLClassNames[iClassIndex]][iSpecIndex][3][iGlyphIndex][1]
				if ( iCurrentGlyphID == iGlyphID ) then
					return iClassIndex, iSpecIndex, iGlyphIndex
				end
			end
		end
	end
	return 0,0,0
end

-------------------------------------------------------------------------------------------------------------------
-- CLDataGlyphs : Initialization
function CLDataGlyphs:Initialize()
	if ( self.m_arrGlyphs ~= nil ) then
		return
	end

	-- Create Data Array
	self.m_arrGlyphs = {}
	
	-- DeathKnight
	self.m_arrGlyphs.DeathKnight = {
		{
			"Blood", "Interface\\TalentFrame\\DeathKnightBlood", {
				{58640,55,0},
				{59309,55,0},
				{59332,55,1},
				{58613,55,1},
				{63334,55,1},
				{58616,55,1},
				{59327,55,1},
				{58618,55,1},
				{58676,55,1},
				{63330,60,1}
			}
		},
		{
			"Frost", "Interface\\TalentFrame\\DeathKnightFrost", {
				{58680,55,0},
				{58620,55,1},
				{58647,55,1},
				{58625,55,1},
				{58631,55,1},
				{58671,55,1},
				{58669,55,1},
				{58635,55,1},
				{63335,60,1},
				{63331,60,1}
			}
		},
		{
			"Unholy", "Interface\\TalentFrame\\DeathKnightUnholy", {
				{59307,55,0},
				{58677,55,0},
				{60200,55,0},
				{58623,55,1},
				{58673,55,1},
				{63333,55,1},
				{58629,55,1},
				{62259,55,1},
				{59336,55,1},
				{58657,55,1},
				{58642,55,1},
				{58686,55,1},
				{63332,60,1}
			}
		}
	}
	
	-- Druid
	self.m_arrGlyphs.Druid = {
		{
			"Balance", "Interface\\TalentFrame\\DruidBalance", {
				{57862,15,0},
				{62135,70,0},
				{54760,15,1},
				{54829,15,1},
				{54756,15,1},
				{54830,20,1},
				{54845,20,1},
				{54831,40,1},
				{54832,40,1},
				{63057,44,1},
				{63056,50,1},
				{54828,60,1},
				{62080,70,1}
			}
		},
		{
			"Feral Combat", "Interface\\TalentFrame\\DruidFeralCombat", {
				{57856,16,0},
				{59219,16,0},
				{57858,28,0},
				{54812,15,1},
				{54811,15,1},
				{67598,20,1},
				{54818,20,1},
				{65243,20,1},
				{54815,22,1},
				{54821,24,1},
				{54810,36,1},
				{54813,50,1},
				{62969,60,1},
				{63055,75,1}
			}
		},
		{
			"Restoration", "Interface\\TalentFrame\\DruidRestoration", {
				{57855,15,0},
				{57857,20,0},
				{54825,15,1},
				{71013,15,1},
				{54743,15,1},
				{54754,15,1},
				{54733,20,1},
				{54824,40,1},
				{62970,60,1},
				{54826,64,1},
				{62971,80,1}
			}
		}
	}
	
	-- Hunter
	self.m_arrGlyphs.Hunter = {
		{
			"Beast Mastery", "Interface\\TalentFrame\\HunterBeastMastery", {
				{57870,15,0},
				{57900,15,0},
				{57866,15,0},
				{57902,15,0},
				{57904,40,0},
				{56833,15,1},
				{56856,15,1},
				{56851,20,1},
				{56857,30,1},
				{56830,40,1}
			}
		},
		{
			"Marksmanship", "Interface\\TalentFrame\\HunterMarksmanship", {
				{56841,15,1},
				{56829,15,1},
				{56832,15,1},
				{56836,18,1},
				{56824,20,1},
				{56828,26,1},
				{56842,40,1},
				{56838,40,1},
				{63065,60,1},
				{56826,62,1},
				{63067,71,1}
			}
		},
		{
			"Survival", "Interface\\TalentFrame\\HunterSurvival", {
				{57903,30,0},
				{63086,15,1},
				{56846,16,1},
				{56850,20,1},
				{56844,20,1},
				{56845,20,1},
				{63069,20,1},
				{56847,28,1},
				{63068,34,1},
				{56848,40,1},
				{63066,60,1},
				{56849,68,1}
			}
		}
	}
	
	-- Mage
	self.m_arrGlyphs.Mage = {
		{
			"Arcane", "Interface\\TalentFrame\\MageArcane", {
				{57924,15,0},
				{57925,15,0},
				{56360,15,1},
				{56363,15,1},
				{56375,15,1},
				{56364,18,1},
				{56365,20,1},
				{56380,20,1},
				{56367,30,1},
				{56383,34,1},
				{56381,40,1},
				{63092,60,1},
				{62210,64,1},
				{56366,68,1},
				{63093,80,1}
			}
		},
		{
			"Fire", "Interface\\TalentFrame\\MageFire", {
				{57926,20,0},
				{62126,70,0},
				{56369,15,1},
				{56368,15,1},
				{56371,20,1},
				{63091,60,1},
				{56382,62,1},
				{61205,75,1}
			}
		},
		{
			"Frost", "Interface\\TalentFrame\\MageFrost", {
				{57928,15,0},
				{57927,22,0},
				{56376,15,1},
				{56370,15,1},
				{56384,15,1},
				{56374,20,1},
				{56372,30,1},
				{63095,46,1},
				{70937,50,1},
				{56373,50,1},
				{63090,60,1},
				{56377,66,1}
			}
		}
	}
	
	-- Paladin
	self.m_arrGlyphs.Paladin = {
		{
			"Holy", "Interface\\TalentFrame\\PaladinHoly", {
				{57979,15,0},
				{57955,15,0},
				{57954,15,0},
				{57947,20,0},
				{54939,15,1},
				{54937,15,1},
				{54928,20,1},
				{54934,20,1},
				{54936,20,1},
				{54931,24,1},
				{54943,30,1},
				{54935,35,1},
				{54940,38,1},
				{63224,40,1},
				{56420,50,1},
				{56414,50,1},
				{63218,60,1},
				{63223,71,1}
			}
		},
		{
			"Protection", "Interface\\TalentFrame\\PaladinProtection", {
				{57937,20,0},
				{54923,15,1},
				{54929,15,1},
				{54924,18,1},
				{63225,26,1},
				{54930,50,1},
				{63219,60,1},
				{63222,75,1}
			}
		},
		{
			"Retribution", "Interface\\TalentFrame\\PaladinCombat", {
				{57958,15,0},
				{54922,15,1},
				{54927,20,1},
				{54925,20,1},
				{54926,44,1},
				{56416,50,1},
				{63220,60,1},
				{54938,70,1}
			}
		}
	}
	
	-- Priest
	self.m_arrGlyphs.Priest = {
		{
			"Discipline", "Interface\\TalentFrame\\PriestDiscipline", {
				{58009,15,0},
				{57986,20,0},
				{57987,34,0},
				{55686,15,1},
				{55672,15,1},
				{55677,18,1},
				{55678,20,1},
				{55690,20,1},
				{63248,50,1},
				{63235,60,1},
				{55691,70,1}
			}
		},
		{
			"Holy", "Interface\\TalentFrame\\PriestHoly", {
				{55674,15,1},
				{55692,15,1},
				{55679,20,1},
				{55683,20,1},
				{55680,30,1},
				{55685,30,1},
				{55673,40,1},
				{55675,50,1},
				{63231,60,1},
				{63246,60,1}
			}
		},
		{
			"Shadow", "Interface\\TalentFrame\\PriestShadow", {
				{57985,15,0},
				{58015,30,0},
				{58228,66,0},
				{55684,15,1},
				{55676,15,1},
				{55681,15,1},
				{55687,20,1},
				{55689,20,1},
				{55688,30,1},
				{63229,60,1},
				{55682,62,1},
				{63237,75,1}
			}
		}
	}
	
	-- Rogue
	self.m_arrGlyphs.Rogue = {
		{
			"Assassination", "Interface\\TalentFrame\\RogueAssassination", {
				{56802,15,1},
				{56803,15,1},
				{56812,15,1},
				{56810,15,1},
				{56813,18,1},
				{56820,20,1},
				{56801,20,1},
				{63268,50,1},
				{63249,60,1},
				{64199,62,1},
				{56806,64,1},
				{56805,70,1}
			}
		},
		{
			"Combat", "Interface\\TalentFrame\\RogueCombat", {
				{58039,15,0},
				{56800,15,1},
				{56799,15,1},
				{56809,15,1},
				{56821,15,1},
				{56811,15,1},
				{56804,16,1},
				{56818,30,1},
				{56808,40,1},
				{63252,60,1},
				{63254,80,1}
			}
		},
		{
			"Subtlety", "Interface\\TalentFrame\\RogueSubtlety", {
				{58017,15,0},
				{58027,16,0},
				{58032,22,0},
				{58038,22,0},
				{58033,40,0},
				{56798,15,1},
				{56814,20,1},
				{56807,30,1},
				{56819,30,1},
				{63253,60,1},
				{63269,66,1},
				{63256,75,1}
			}
		}
	}
	
	-- Shaman
	self.m_arrGlyphs.Shaman = {
		{
			"Elemental", "Interface\\TalentFrame\\ShamanElementalCombat", {
				{62132,70,0},
				{55450,15,1},
				{55447,15,1},
				{55453,15,1},
				{55442,15,1},
				{63298,15,1},
				{55443,20,1},
				{55449,32,1},
				{55452,50,1},
				{63280,50,1},
				{63270,60,1},
				{55454,66,1},
				{55455,68,1},
				{63291,80,1}
			}
		},
		{
			"Enhancement", "Interface\\TalentFrame\\ShamanEnhancement", {
				{59289,16,0},
				{58055,22,0},
				{58057,28,0},
				{58058,30,0},
				{55451,15,1},
				{55444,15,1},
				{55448,15,1},
				{55445,30,1},
				{55446,40,1},
				{63271,60,1}
			}
		},
		{
			"Restoration", "Interface\\TalentFrame\\ShamanRestoration", {
				{58063,20,0},
				{58059,30,0},
				{55440,15,1},
				{55456,20,1},
				{55438,20,1},
				{55436,20,1},
				{55439,30,1},
				{55437,40,1},
				{55441,40,1},
				{63279,50,1},
				{63273,60,1}
			}
		}
	}

	-- Warlock
	self.m_arrGlyphs.Warlock = {
		{
			"Affliction", "Interface\\TalentFrame\\WarlockCurses", {
				{58070,15,0},
				{58080,70,0},
				{56218,15,1},
				{56241,15,1},
				{56244,15,1},
				{63320,15,1},
				{70947,15,1},
				{56216,30,1},
				{56217,40,1},
				{56232,42,1},
				{56233,50,1},
				{63302,60,1}
			}
		},
		{
			"Demonology", "Interface\\TalentFrame\\WarlockSummoning", {
				{58079,15,0},
				{58081,22,0},
				{58107,30,0},
				{58094,68,0},
				{56238,15,1},
				{56224,15,1},
				{56248,15,1},
				{56247,15,1},
				{56231,18,1},
				{63312,20,1},
				{56250,26,1},
				{56249,30,1},
				{56246,50,1},
				{63303,60,1},
				{63309,80,1}
			}
		},
		{
			"Destruction", "Interface\\TalentFrame\\WarlockDestruction", {
				{56228,15,1},
				{56240,15,1},
				{56226,18,1},
				{56229,20,1},
				{56242,28,1},
				{56235,40,1},
				{63304,60,1},
				{63310,75,1}
			}
		}
	}
	
	-- Warrior
	self.m_arrGlyphs.Warrior = {
		{
			"Arms", "Interface\\TalentFrame\\WarriorArms", {
				{58097,15,0},
				{58098,15,0},
				{58099,16,0},
				{58372,15,1},
				{58357,15,1},
				{58386,15,1},
				{58355,15,1},
				{58385,15,1},
				{58356,15,1},
				{58365,16,1},
				{58384,30,1},
				{58368,40,1},
				{63324,60,1}
			}
		},
		{
			"Fury", "Interface\\TalentFrame\\WarriorFury", {
				{58095,15,0},
				{58104,62,0},
				{68164,68,0},
				{58382,15,1},
				{58366,20,1},
				{58367,24,1},
				{58370,36,1},
				{58369,40,1},
				{63327,75,1}
			}
		},
		{
			"Protection", "Interface\\TalentFrame\\WarriorProtection", {
				{58096,15,0},
				{58364,15,1},
				{58387,15,1},
				{58353,15,1},
				{58376,20,1},
				{63329,28,1},
				{58375,40,1},
				{63326,40,1},
				{58388,50,1},
				{63325,60,1},
				{63328,64,1},
				{58377,70,1}
			}
		}
	}
	
	-- Pet
	self.m_arrGlyphs.Pet = {
		{
			"Cunning", "Interface\\TalentFrame\\HunterPetCunning", {
				--{0,0,0},
			}
		},
		{
			"Ferocity", "Interface\\TalentFrame\\HunterPetFerocity", {
				--{0,0,0},
			}
		},
		{
			"Tenacity", "Interface\\TalentFrame\\HunterPetTenacity", {
				--{0,0,0},
			}
		}
	}

	print( "[ClassLess] Glyph Data Initialized !" )
end

