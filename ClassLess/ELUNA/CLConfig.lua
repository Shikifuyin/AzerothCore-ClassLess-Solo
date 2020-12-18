-------------------------------------------------------------------------------------------------------------------
-- ClassLess System by Shikifuyin
-- Target = AzerothCore - WotLK 3.3.5a
-------------------------------------------------------------------------------------------------------------------
-- ClassLess : Server Configuration
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Requirements
local AIO = AIO or require("AIO")

-------------------------------------------------------------------------------------------------------------------
-- Client / Server Setup

-- Server-side Only !

-------------------------------------------------------------------------------------------------------------------
-- Constant Definitions
CLConfig = CLConfig or {}

CLConfig.SpellPointsRate = 1.0
CLConfig.PetSpellPointsRate = 1.0

CLConfig.TalentPointsRate = 1.0
CLConfig.PetTalentPointsRate = 1.0

CLConfig.RequiredTalentPointsPerTier = 5
CLConfig.RequiredPetTalentPointsPerTier = 3

CLConfig.GlyphMajorSlotsRate = 1.0
CLConfig.GlyphMinorSlotsRate = 1.0

CLConfig.AbilityResetCosts = { 10000, 50000, 100000, 150000, 200000, 350000 } -- in copper, any number of values

