# AzerothCore-ClassLess-Solo

ClassLess System for AzerothCore ... the Solo-friendly way !

Current Features :
- Server Spell/Talent/Glyph manager (ELUNA)
- Client UI (ELUNA)
- Secured against client-side tempering !
- Need for extensive testing ... (especially DK and Spells/Talents involving shapeshifting)

Work In Progress :
- Add Pet support (ELUNA)
- Mana/Rage/Energy uniformisation (DBC/SQL)
- Item uniformisation (DBC/SQL)
- Quest uniformisation (DBC/SQL)
- Generic Class
- Extensive testing of all Spells/Talents/Glyphs and interactions
- Stat Allocation system ?
Some of those most likely require C++ core edits, hence a custom build.
As much as possible I want this to be compatible with any azerothcore-based
repack for now ...

Compatibility :
Any AzerothCore build/repack with eluna support.
Should also work on Trinity with a very slight change (ask me if you need help).

Requirements :
Eluna : http://elunaluaengine.github.io/index.html
AIO from Rochet2 : https://github.com/Rochet2/AIO

Installation :
- Make sure you have AIO installed (both server-side and client-side) and AIO addon is enabled in your client.
- Make sure your SQL server is running and execute ClassLess/SQL/CLCreateTable.sql on your characters DB.
- Copy the source files in ClassLess/ELUNA in the eluna script folder of your server, in a subdirectory of your choice (eg. 'ClassLess').
- Done !

Configuration :
- You can alter a few settings at the very top of CLServer.lua :
- CLCONFIG_SPELL_POINTS_RATE (default = 1)
Number of Spell Points you gain per level
- CLCONFIG_TALENT_POINTS_RATE (default = 1)
Talent Points rate, MUST match your worldserver config file
- CLCONFIG_REQUIRED_TALENT_POINTS_PER_TIER (default = 5)
Number of talent points to progress down talent tiers
- CLCONFIG_GLYPH_MAJOR_SLOT_COUNTS and CLCONFIG_GLYPH_MINOR_SLOT_COUNTS
Number of available Major/Minor Glyph Slots every 10th level
- CLCONFIG_RESET_PRICES
Sequence of cost increase when resetting Spells/Talents/Glyphs

Notes :
- Any suggestion / comment / feedback / bug report is very welcome !
- This is not meant to be balanced for regular play ! Feel free to go crazy on the settings above !
- This is meant to let you have fun creating your dream multi-class character build, while playing
a blizz-like content but solo-friendly server like the excellent repack from BrooksTech.
- There will be no custom-complex-crazy content like other classless system I've seen seem to have,
this is a classless module, period.

Thank you for your attention, I hope you find this useful & fun ! Cheers !

