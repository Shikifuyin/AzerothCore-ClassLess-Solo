# AzerothCore-ClassLess-Solo

ClassLess System for AzerothCore ... the Solo-friendly way !

Current Features :
- (ELUNA) Server Spell/Talent/Glyph manager
- (ELUNA) Client UI
- Secured against client-side tempering !

Work In Progress :
- Extensive testing of all Spells/Talents/Glyphs and interactions
- (ELUNA) Pet support 99% done but on hold : Eluna has no way to learn/unlearn pet spells, known issue. This
will require me to implement the feature in Eluna's source directly and request a pull. Repacks will have to
update.
- (DBC/SQL) Mana/Rage/Energy uniformisation
- (DBC/SQL) Item uniformisation
- (DBC/SQL) Quest uniformisation
- (C++,DBC/SQL) Generic Class
- (C++,DBC/SQL) Stat Allocation system ?
- Those which require C++ core edits are not planned in the near future. As much as possible I want this to
be compatible with any azerothcore/trinitycore-based repack ...

Compatibility :
- Any AzerothCore build/repack with Eluna support.
- Should also work on Trinity with a very slight change (ask me if you need help).

Requirements :
- Eluna : http://elunaluaengine.github.io/index.html
- AIO : https://github.com/Rochet2/AIO

Installation :
- Make sure you have AIO installed (both server-side and client-side) and AIO addon is enabled in your client.
- Make sure your SQL server is running and execute ClassLess/SQL/CLCreateTable.sql on your characters DB.
(Alternatively you can manually add the table by pasting the SQL in your favorite editor, HeidiSQL is a solid choice !)
- Copy the source files in ClassLess/ELUNA in the eluna script folder of your server, in a subdirectory of your choice (eg. 'ClassLess').
- Done !

Configuration : You can alter a few settings in CLConfig.lua, they should be self-explanatory :
- CLConfig.SpellPointsRate = 1.0
- CLConfig.PetSpellPointsRate = 1.0
- CLConfig.TalentPointsRate = 1.0
- CLConfig.PetTalentPointsRate = 1.0
- CLConfig.RequiredTalentPointsPerTier = 5
- CLConfig.RequiredPetTalentPointsPerTier = 3
- CLConfig.GlyphMajorSlotsRate = 1.0
- CLConfig.GlyphMinorSlotsRate = 1.0
- CLConfig.AbilityResetCosts = { 10000, 50000, 100000, 150000, 200000, 350000 } -- in copper, any number of values

Notes :
- Any suggestion / comment / feedback / bug report is very welcome !
- This is not meant to be balanced for regular play ! Feel free to go crazy on the settings above !
- This is meant to let you have fun creating your dream multi-class character build, while playing
a blizz-like content but solo-friendly server like the excellent repack from BrooksTech.
- There will be no custom-complex-crazy content like other classless system I've seen seem to have,
this is a classless module, period.

Thank you for your attention, I hope you find this useful & fun ! Cheers !

