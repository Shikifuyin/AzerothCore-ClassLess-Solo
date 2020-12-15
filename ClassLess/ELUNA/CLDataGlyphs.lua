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
-- ClassLessGlyphDesc - Declaration
ClassLessGlyphDesc = class({
	-- Static Members
})

function ClassLessGlyphDesc:init( iClassIndex, iSpecIndex, iGlyphIndex, iGlyphID, iGlyphLevel, bIsMajor )
	-- Members
	self.m_iClassIndex = iClassIndex
	self.m_iSpecIndex = iSpecIndex
	self.m_iGlyphIndex = iGlyphIndex
	
	self.m_iGlyphID = iGlyphID
	self.m_iGlyphLevel = iGlyphLevel
	self.m_bIsMajor = bIsMajor
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessGlyphDesc : Encoding / Decoding
function ClassLessGlyphDesc:ToArray( hGlyphDesc )
	return {
		hGlyphDesc.m_iClassIndex, hGlyphDesc.m_iSpecIndex, hGlyphDesc.m_iGlyphIndex,
		hGlyphDesc.m_iGlyphID, hGlyphDesc.m_iGlyphLevel, hGlyphDesc.m_bIsMajor
	}
end
function ClassLessGlyphDesc:FromArray( arrGlyphDesc )
	local hGlyphDesc = ClassLessGlyphDesc(
		arrGlyphDesc[1], arrGlyphDesc[2], arrGlyphDesc[3],
		arrGlyphDesc[4], arrGlyphDesc[5], arrGlyphDesc[6]
	)
	return hGlyphDesc
end

function ClassLessGlyphDesc:EncodeGlyphs( arrGlyphs )
	local arrEncodedGlyphs = {}
	for i = 1, #arrGlyphs do
		arrEncodedGlyphs[i] = ClassLessGlyphDesc:ToArray( arrGlyphs[i] )
	end
	return arrEncodedGlyphs
end
function ClassLessGlyphDesc:DecodeGlyphs( arrGlyphs )
	local arrDecodedGlyphs = {}
	for i = 1, #arrGlyphs do
		arrDecodedGlyphs[i] = ClassLessGlyphDesc:FromArray( arrGlyphs[i] )
	end
	return arrDecodedGlyphs
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessGlyphDesc : Getters / Setters
function ClassLessGlyphDesc:GetClassIndex()
	return self.m_iClassIndex
end
function ClassLessGlyphDesc:GetSpecIndex()
	return self.m_iSpecIndex
end
function ClassLessGlyphDesc:GetGlyphIndex()
	return self.m_iGlyphIndex
end

function ClassLessGlyphDesc:GetGlyphID()
	return self.m_iGlyphID
end
function ClassLessGlyphDesc:GetGlyphLevel()
	return self.m_iGlyphLevel
end
function ClassLessGlyphDesc:IsMajor()
	return self.m_bIsMajor
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessGlyphDesc : Methods
function ClassLessGlyphDesc:GetIcon()
	local strName, iRank, hIcon = GetSpellInfo( self.m_iGlyphID )
	return hIcon
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessDataGlyphs : Declaration
ClassLessDataGlyphs = class({
	-- Static Members
})

-- Format :
-- m_arrGlyphs[classname][specindex] = {
--     	[1] - string : specname
--     	[2] - string : spectexture
--		[3] - array( iGlyphIndex -> {iGlyphSpellID, iGlyphLevel, bIsMajor} )
-- }
function ClassLessDataGlyphs:init()
	-- Members
	self.m_arrGlyphs = nil
end

-------------------------------------------------------------------------------------------------------------------
-- ClassLessDataGlyphs : Getters / Setters
function ClassLessDataGlyphs:GetClassSpecName( iClassIndex, iSpecIndex )
	return self.m_arrGlyphs[CLClassNames[iClassIndex]][iSpecIndex][1]
end
function ClassLessDataGlyphs:GetClassSpecTexture( iClassIndex, iSpecIndex )
	return self.m_arrGlyphs[CLClassNames[iClassIndex]][iSpecIndex][2]
end

function ClassLessDataGlyphs:GetGlyphCount( iClassIndex, iSpecIndex )
	return #( self.m_arrGlyphs[CLClassNames[iClassIndex]][iSpecIndex][3] )
end

function ClassLessDataGlyphs:GetGlyphDesc( iClassIndex, iSpecIndex, iGlyphIndex )
	return ClassLessGlyphDesc(
		iClassIndex, iSpecIndex, iGlyphIndex,
		self.m_arrGlyphs[CLClassNames[iClassIndex]][iSpecIndex][3][iGlyphIndex][1],
		self.m_arrGlyphs[CLClassNames[iClassIndex]][iSpecIndex][3][iGlyphIndex][2],
		( self.m_arrGlyphs[CLClassNames[iClassIndex]][iSpecIndex][3][iGlyphIndex][3] ~= 0 )
	)
end

function ClassLessDataGlyphs:SearchGlyph( iGlyphID )
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
-- ClassLessDataSpells : Initialization
function ClassLessDataSpells:Initialize()
	if ( self.m_arrGlyphs ~= nil ) then
		return
	end

	-- Create Data Array
	self.m_arrGlyphs = {}
	
	-- DeathKnight
	self.m_arrGlyphs.DeathKnight = {
		{
			"Blood", "Interface\\TalentFrame\\DeathKnightBlood", {
				{0,0,0},
			}
		},
		{
			"Frost", "Interface\\TalentFrame\\DeathKnightFrost", {
				{0,0,0},
			}
		},
		{
			"Unholy", "Interface\\TalentFrame\\DeathKnightUnholy", {
				{0,0,0},
			}
		}
	}
	
	-- Druid
	self.m_arrGlyphs.Druid = {
		{
			"Balance", "Interface\\TalentFrame\\DruidBalance", {
				{0,0,0},
			}
		},
		{
			"Feral Combat", "Interface\\TalentFrame\\DruidFeralCombat", {
				{0,0,0},
			}
		},
		{
			"Restoration", "Interface\\TalentFrame\\DruidRestoration", {
				{0,0,0},
			}
		}
	}
	
	-- Hunter
	self.m_arrGlyphs.Hunter = {
		{
			"Beast Mastery", "Interface\\TalentFrame\\HunterBeastMastery", {
				{0,0,0},
			}
		},
		{
			"Marksmanship", "Interface\\TalentFrame\\HunterMarksmanship", {
				{0,0,0},
			}
		},
		{
			"Survival", "Interface\\TalentFrame\\HunterSurvival", {
				{0,0,0},
			}
		}
	}
	
	-- Mage
	self.m_arrGlyphs.Mage = {
		{
			"Arcane", "Interface\\TalentFrame\\MageArcane", {
				{0,0,0},
			}
		},
		{
			"Fire", "Interface\\TalentFrame\\MageFire", {
				{0,0,0},
			}
		},
		{
			"Frost", "Interface\\TalentFrame\\MageFrost", {
				{0,0,0},
			}
		}
	}
	
	-- Paladin
	self.m_arrGlyphs.Paladin = {
		{
			"Holy", "Interface\\TalentFrame\\PaladinHoly", {
				{0,0,0},
			}
		},
		{
			"Protection", "Interface\\TalentFrame\\PaladinProtection", {
				{0,0,0},
			}
		},
		{
			"Retribution", "Interface\\TalentFrame\\PaladinCombat", {
				{0,0,0},
			}
		}
	}
	
	-- Priest
	self.m_arrGlyphs.Priest = {
		{
			"Discipline", "Interface\\TalentFrame\\PriestDiscipline", {
				{0,0,0},
			}
		},
		{
			"Holy", "Interface\\TalentFrame\\PriestHoly", {
				{0,0,0},
			}
		},
		{
			"Shadow", "Interface\\TalentFrame\\PriestShadow", {
				{0,0,0},
			}
		}
	}
	
	-- Rogue
	self.m_arrGlyphs.Rogue = {
		{
			"Assassination", "Interface\\TalentFrame\\RogueAssassination", {
				{0,0,0},
			}
		},
		{
			"Combat", "Interface\\TalentFrame\\RogueCombat", {
				{0,0,0},
			}
		},
		{
			"Subtlety", "Interface\\TalentFrame\\RogueSubtlety", {
				{0,0,0},
			}
		}
	}
	
	-- Shaman
	self.m_arrGlyphs.Shaman = {
		{
			"Elemental", "Interface\\TalentFrame\\ShamanElementalCombat", {
				{0,0,0},
			}
		},
		{
			"Enhancement", "Interface\\TalentFrame\\ShamanEnhancement", {
				{0,0,0},
			}
		},
		{
			"Restoration", "Interface\\TalentFrame\\ShamanRestoration", {
				{0,0,0},
			}
		}
	}

	-- Warlock
	self.m_arrGlyphs.Warlock = {
		{
			"Affliction", "Interface\\TalentFrame\\WarlockCurses", {
				{0,0,0},
			}
		},
		{
			"Demonology", "Interface\\TalentFrame\\WarlockSummoning", {
				{0,0,0},
			}
		},
		{
			"Destruction", "Interface\\TalentFrame\\WarlockDestruction", {
				{0,0,0},
			}
		}
	}
	
	-- Warrior
	self.m_arrGlyphs.Warrior = {
		{
			"Arms", "Interface\\TalentFrame\\WarriorArms", {
				{0,0,0},
			}
		},
		{
			"Fury", "Interface\\TalentFrame\\WarriorFury", {
				{0,0,0},
			}
		},
		{
			"Protection", "Interface\\TalentFrame\\WarriorProtection", {
				{0,0,0},
			}
		}
	}

	print( "[ClassLess] Glyph Data Initialized !" )
end

