-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess : Glyph Maps
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
-- CLGlyphDesc - Declaration
CLGlyphDesc = class({
	-- Static Members
})

function CLGlyphDesc:init( iClassIndex, iSpecIndex, iGlyphIndex, iGlyphID, iGlyphLevel, bIsMajor )
	-- Members
	self.m_iClassIndex = iClassIndex
	self.m_iSpecIndex = iSpecIndex
	self.m_iGlyphIndex = iGlyphIndex
	
	self.m_iGlyphID = iGlyphID
	self.m_iGlyphLevel = iGlyphLevel
	self.m_bIsMajor = bIsMajor
end

-------------------------------------------------------------------------------------------------------------------
-- CLGlyphDesc : Methods
function CLGlyphDesc:GetClassIndex()
	return self.m_iClassIndex
end
function CLGlyphDesc:GetSpecIndex()
	return self.m_iSpecIndex
end
function CLGlyphDesc:GetGlyphIndex()
	return self.m_iGlyphIndex
end

function CLGlyphDesc:GetGlyphID()
	return self.m_iGlyphID
end
function CLGlyphDesc:GetGlyphLevel()
	return self.m_iGlyphLevel
end
function CLGlyphDesc:IsMajor()
	return self.m_bIsMajor
end

function CLGlyphDesc:GetCost()
	return 1
end

function CLGlyphDesc:Encode()
	return {
		self.m_iClassIndex, self.m_iSpecIndex, self.m_iGlyphIndex,
		self.m_iGlyphID, self.m_iGlyphLevel, self.m_bIsMajor
	}
end
function CLGlyphDesc:Decode( arrEncodedGlyph )
	self.m_iClassIndex = arrEncodedGlyph[1]
	self.m_iSpecIndex = arrEncodedGlyph[2]
	self.m_iGlyphIndex = arrEncodedGlyph[3]
	self.m_iGlyphID = arrEncodedGlyph[4]
	self.m_iGlyphLevel = arrEncodedGlyph[5]
	self.m_bIsMajor = arrEncodedGlyph[6]
end

function CLGlyphDesc:GetIcon()
	local strType = "Minor"
	if ( self.m_bIsMajor ) then
		strType = "Major"
	end
	return "Interface\\Icons\\Inv_Glyph_" .. strType .. CLClassNames[self.m_iClassIndex]
end

-------------------------------------------------------------------------------------------------------------------
-- CLGlyphMap - Declaration
CLGlyphMap = class({
	-- Static Members
})

function CLGlyphMap:init()
	-- Members
	self.m_iGlyphMajorSlots = 0
	self.m_iGlyphMinorSlots = 0
	self.m_mapGlyphs = {}
end

-------------------------------------------------------------------------------------------------------------------
-- CLGlyphMap : Methods
function CLGlyphMap:IsEmpty()
	return ( self.m_iGlyphMajorSlots == 0 and self.m_iGlyphMinorSlots == 0 )
end
function CLGlyphMap:Clear()
	self.m_iGlyphMajorSlots = 0
	self.m_iGlyphMinorSlots = 0
	self.m_mapGlyphs = {}
end

function CLGlyphMap:EnumCallback( funcCallback )
	for iClassIndex, arrSpecs in pairs(self.m_mapGlyphs) do
		for iSpecIndex, arrGlyphs in pairs(arrSpecs) do
			for iGlyphIndex, hGlyphDesc in pairs(arrGlyphs) do
				funcCallback( hGlyphDesc )
			end
		end
	end
end

function CLGlyphMap:GetGlyphMajorSlots()
	return self.m_iGlyphMajorSlots
end
function CLGlyphMap:GetGlyphMinorSlots()
	return self.m_iGlyphMinorSlots
end
function CLGlyphMap:GetGlyphDesc( iClassIndex, iSpecIndex, iGlyphIndex )
	return self.m_mapGlyphs[iClassIndex][iSpecIndex][iGlyphIndex]
end

function CLGlyphMap:HasGlyph( iClassIndex, iSpecIndex, iGlyphIndex )
	if ( self.m_mapGlyphs[iClassIndex] == nil ) then
		return false
	end
	if ( self.m_mapGlyphs[iClassIndex][iSpecIndex] == nil ) then
		return false
	end
	if ( self.m_mapGlyphs[iClassIndex][iSpecIndex][iGlyphIndex] == nil ) then
		return false
	end
	return true
end

function CLGlyphMap:AddGlyph( hGlyphDesc )
	local iClassIndex = hGlyphDesc:GetClassIndex()
	local iSpecIndex = hGlyphDesc:GetSpecIndex()
	local iGlyphIndex = hGlyphDesc:GetGlyphIndex()
	
	-- Auto-Vivify arrays
	if ( self.m_mapGlyphs[iClassIndex] == nil ) then
		self.m_mapGlyphs[iClassIndex] = {}
	end
	if ( self.m_mapGlyphs[iClassIndex][iSpecIndex] == nil ) then
		self.m_mapGlyphs[iClassIndex][iSpecIndex] = {}
	end
	
	-- Check if already existing
	if ( self.m_mapGlyphs[iClassIndex][iSpecIndex][iGlyphIndex] ~= nil ) then
		return
	end
	
	-- Update Points
	local iCost = hGlyphDesc:GetCost()
	if hGlyphDesc:IsMajor() then
		self.m_iGlyphMajorSlots = self.m_iGlyphMajorSlots + iCost
	else
		self.m_iGlyphMinorSlots = self.m_iGlyphMinorSlots + iCost
	end
	
	-- Add Glyph
	self.m_mapGlyphs[iClassIndex][iSpecIndex][iGlyphIndex] = hGlyphDesc
end
function CLGlyphMap:RemoveGlyph( iClassIndex, iSpecIndex, iGlyphIndex )
	-- Check if present
	if ( not self:HasGlyph(iClassIndex, iSpecIndex, iGlyphIndex) ) then
		return
	end

	-- Update Points
	local iCost = self.m_mapGlyphs[iClassIndex][iSpecIndex][iGlyphIndex]:GetCost()
	if ( self.m_mapGlyphs[iClassIndex][iSpecIndex][iGlyphIndex]:IsMajor() ) then
		self.m_iGlyphMajorSlots = self.m_iGlyphMajorSlots - iCost
	else
		self.m_iGlyphMinorSlots = self.m_iGlyphMinorSlots - iCost
	end
	
	-- Remove Glyph
	self.m_mapGlyphs[iClassIndex][iSpecIndex][iGlyphIndex] = nil
end

function CLGlyphMap:Encode()
	local arrEncodedGlyphs = {}
	for iClassIndex, arrSpecs in pairs(self.m_mapGlyphs) do
		for iSpecIndex, arrGlyphs in pairs(arrSpecs) do
			for iGlyphIndex, hGlyphDesc in pairs(arrGlyphs) do
				table.insert( arrEncodedGlyphs, hGlyphDesc:Encode() )
			end
		end
	end
	return arrEncodedGlyphs
end
function CLGlyphMap:Decode( arrEncodedGlyphs )
	self:Clear()
	for i = 1, #arrEncodedGlyphs do
		local hGlyphDesc = CLGlyphDesc()
		hGlyphDesc:Decode( arrEncodedGlyphs[i] )
		self:AddGlyph( hGlyphDesc )
	end
end

