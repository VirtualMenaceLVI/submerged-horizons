/*
    Addon id: 6caa0056-2e1c-4a99-9ba2-8bb2fe3a0232
    Version: v1.5.7 (stable)
*/

CharacterCreator = CharacterCreator or {}
include("character_creator/sh_chc_config.lua")
include("character_creator/languages/sh_language_pl.lua")
include("character_creator/languages/sh_language_fr.lua")
include("character_creator/languages/sh_language_en.lua")
include("character_creator/languages/sh_language_es.lua")
include("character_creator/languages/sh_language_ru.lua")
include("character_creator/languages/sh_language_de.lua")
include("character_creator/languages/sh_language_tr.lua")
include("character_creator/shared/sh_functions.lua")
include("character_creator/sh_chc_materials.lua")
if SERVER then	
	resource.AddFile(CharacterCreator.BackImage)
	AddCSLuaFile("character_creator/sh_chc_config.lua")
	AddCSLuaFile("character_creator/languages/sh_language_pl.lua")
	AddCSLuaFile("character_creator/languages/sh_language_fr.lua")
	AddCSLuaFile("character_creator/languages/sh_language_en.lua")
	AddCSLuaFile("character_creator/languages/sh_language_es.lua")
	AddCSLuaFile("character_creator/languages/sh_language_ru.lua")
	AddCSLuaFile("character_creator/languages/sh_language_de.lua")
	AddCSLuaFile("character_creator/languages/sh_language_tr.lua")
	AddCSLuaFile("character_creator/shared/sh_functions.lua") 
	AddCSLuaFile("character_creator/sh_chc_materials.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c24aa0f51c3521dc86ce13039a612ad6a262a16b758cd0bdb3462448d89950ac
	
	AddCSLuaFile("character_creator/client/cl_character_creator.lua")
	AddCSLuaFile("character_creator/client/cl_character_creator_admin.lua")
	AddCSLuaFile("character_creator/client/cl_character_creator_fonts.lua")

	include("character_creator/server/sv_character_creator_save.lua")
	include("character_creator/server/sv_character_creator_tool.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a45b4a0371527980aa45a614f82b3b1b5c437fbaab42e40b73e1d1d0309ff781

elseif CLIENT then

	include("character_creator/client/cl_character_creator.lua")
	include("character_creator/client/cl_character_creator_admin.lua")
	include("character_creator/client/cl_character_creator_fonts.lua")
	
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 15478a1827bdd0ab07064f24626a05e7e8fa2b4b1e33baa627f3f8cb0b843238
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199063103836
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a45b4a0371527980aa45a614f82b3b1b5c437fbaab42e40b73e1d1d0309ff781
