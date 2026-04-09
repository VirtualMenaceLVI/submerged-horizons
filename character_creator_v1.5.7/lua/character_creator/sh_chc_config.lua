/*
    Addon id: 6caa0056-2e1c-4a99-9ba2-8bb2fe3a0232
    Version: v1.5.7 (stable)
*/

-----------------------------------------------------------------------------
---------------------------Main Configuration--------------------------------
-----------------------------------------------------------------------------

CharacterCreator = CharacterCreator or {}

CharacterCreator.LettersAllowed = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0", " "}

CharacterCreator.Lang = "en" -- You can Choose fr , en , es , ru , de

CharacterCreator.NameServer = "ServerName" -- The name of your server 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d90b40d7d178e5adda34201e534657c97e623b5b60bb31ab0498b85eaf4bace5

CharacterCreator.BackImage = "materials/CharacterCreatorImage.jpg" -- Back Image

CharacterCreator.Description = "Welcome to the server. In this menu, you can come to life with several characters. Feel free to contact the staff if you encounter any problem. Read the rules to have a great time . Good Game !"

CharacterCreator.MoneyOnStartCharacter = 0 -- The starting money of the Character (If you have ATM set this value to 0)

CharacterCreator.PlayerCanDeleteCharacter = true -- If the player can delete a character

CharacterCreator.CharacterNotify = true -- Notify when Character was Saved

CharacterCreator.SaveChangingName = true -- If when you change your name it was saved . 

CharacterCreator.CharacterRpNameDisable = false -- RpName Command Enabled/Disable 

CharacterCreator.CharacterSetTeamNoRespawn = false -- If When you change job you don't respawn 

CharacterCreator.CharacterDisableBodyGroup = false -- If you want disable Bodygroup 

CharacterCreator.CharacterDisableDeathOpenMenu = false -- If you want disable the menu when the player death 

CharacterCreator.CharacterAccountLinked = false -- If you want the account of the three character are linked

CharacterCreator.CanChooseJob = true -- If you can choose a job when you create your character

CharacterCreator.MaxCaractersName = 10 -- Max Caracters name

CharacterCreator.MaxCaractersSurname = 10 -- Max Caracters surname

CharacterCreator.RandomName = false -- If you want than the first part of the name is Random like for SCP-Roleplay ( 585596 Guard )

CharacterCreator.RandomNameConfiguration = {1,2,1,1,2,2,2,2,1} -- Letters = 1 , Numbers = 2 

CharacterCreator.PrefixName = false -- You can choose a prefix Name 

CharacterCreator.PrefixNameConfiguration = "CT-" -- You can choose a prefix Name 

CharacterCreator.DeleteCharacterDeath = false -- Delete the character when you death 

CharacterCreator.DisableSex = false -- Disable Sex menu 

CharacterCreator.DisableNationality = false -- Disable Nationality menu  

CharacterCreator.KeyOpenOption = false -- if the player can open a menu with a key 

CharacterCreator.KeyOpen = KEY_G -- The key for open the menu you find here all key https://wiki.facepunch.com/gmod/Enums/KEY

CharacterCreator.TimeReopen = 60 -- The time than the player have to wait for reopen the menu with the key 

CharacterCreator.JobCanChoose = { -- Job which can be choose when you create your character
	"Citizen", -- First the default job like : Citizen 
	"Hobo",
	"Civil Protection",
	"Medic",
}

CharacterCreator.NpcName = "Character Creator" -- The name of the npc 

CharacterCreator.RankToOpenAdmin = { -- Who can acces to the Admin Menu
	["superadmin"] = true, 
	["admin"] = true,
}

CharacterCreator.Character2VIP = false -- If Character2 requiered a rank 

CharacterCreator.Character2VIPRank = { -- Who can acces to the Character 2
	["superadmin"] = true, 
	["admin"] = true,
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 15478a1827bdd0ab07064f24626a05e7e8fa2b4b1e33baa627f3f8cb0b843238

CharacterCreator.Character3VIP = false -- If Character3 requiered a rank 

CharacterCreator.Character3VIPRank = { -- Who can acces to the Character 3 
	["superadmin"] = true, 
	["admin"] = true,
}

-----------------------------------------------------------------------------
---------------------------Music Configuration-------------------------------
-----------------------------------------------------------------------------

-- You can upload your sound mp3 here https://vocaroo.com/ and take the link like :
-- "https://vocaroo.com//media/download_temp/Vocaroo_s08bqIR6mgzh.mp3" 

CharacterCreator.MusicMenuActivate = false -- If you want music in the menu 

CharacterCreator.MusicMenu = "https://s0.vocaroo.com/media/download_temp/Vocaroo_s08bqIR6mgzh.mp3"

CharacterCreator.MusicMenuVolume = 1 -- 1 = 100 % / 0.5 = 50%  

CharacterCreator.MusicCreatedActivate = false -- If you want music when the character are created

CharacterCreator.MusicCreated = "https://s0.vocaroo.com/media/download_temp/Vocaroo_s08bqIR6mgzh.mp3"

CharacterCreator.MusicCreatedVolume = 1 -- 1 = 100 % / 0.5 = 50% 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 15478a1827bdd0ab07064f24626a05e7e8fa2b4b1e33baa627f3f8cb0b843238

-----------------------------------------------------------------------------
---------------------------Load Configuration--------------------------------
-----------------------------------------------------------------------------

CharacterCreator.CharacterLoadHealth = true -- Load Health of the Character

CharacterCreator.CharacterLoadArmor = true -- Load Armor of the Character

CharacterCreator.CharacterLoadMoney = true -- Load Money of the Character

CharacterCreator.CharacterLoadJob = true -- Load Job of the Character

CharacterCreator.CharacterLoadLicense = true -- Load license of the Character

CharacterCreator.CharacterLoadWanted = true -- Load Wanted of the Character

CharacterCreator.CharacterLoadPosition = true -- Load the Position of the Character

CharacterCreator.CharacterLoadWeapons = true -- Load the Weapons of the Character

-----------------------------------------------------------------------------
---------------------------Table Configuration-------------------------------
-----------------------------------------------------------------------------

-- When you set a job in this configuration the money and the job will not be saved 
-- Example : You don't want there to be two mayors on your server 

CharacterCreator.CharacterJobNotSave = {
	["Hobo"] = true, 
	["Civil Protection"] = false,
}

-- When you set a job in this configuration the Model of the character will not be applied
-- Example : In the Police Job you have custom model and you don't want the model of your character was applied

CharacterCreator.CharacterJobModelNotSave = { 
	["Hobo"] = true, 
	["Civil Protection"] = true,
}

CharacterCreator.CharacterJobWeaponNotSave = {
	["Civil Protection"] = true,
}

-----------------------------------------------------------------------------
----------------------- Compatibility Configuration--------------------------
-----------------------------------------------------------------------------

CharacterCreator.CompatibilityItemStore = false -- Compatibility with ItemStore  

CharacterCreator.CompatibilityMedicMod = false -- Compatibility with MedicMod

CharacterCreator.CompatibilityClothesMod = false -- Compatibility with Clothes Mod 

CharacterCreator.CompatibilityBricksCreditStore = false -- Compatibility with Clothes Mod 

-----------------------------------------------------------------------------
-------------------------- Button Configuration------------------------------
-----------------------------------------------------------------------------

CharacterCreator.Bouttons = {}
CharacterCreator.Bouttons[1] = { -- ( Five Max )

	NameButton = "INFO", -- Name of the button 
	UrlButton = "https://google.com" -- Url of the button 	

}

CharacterCreator.Bouttons[2] = { -- ( Five Max )

	NameButton = "DISCORD", -- Name of the button 
	UrlButton = "https://google.com" -- Url of the button 
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199063103813

CharacterCreator.Bouttons[3] = { -- ( Five Max )
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199063103813

	NameButton = "COLLECTION", -- Name of the button 
	UrlButton = "https://google.com" -- Url of the button 

}

-----------------------------------------------------------------------------
---------------------------- Table Configuration ----------------------------
-----------------------------------------------------------------------------

CharacterCreator.Nationality = { -- Name of the Nationality
	"French",
	"English",
	"Russian",
	"Americain",
}

CharacterCreator.CharacterName = { -- Random Name 
	"Ethan",
	"Robert",
	"Adrien",
	"William",
	"Mickael",
	"Emillie",
	"Sarah",
	"Jack",
	"David",
	"Vladimir",
}

CharacterCreator.CharacterSurName = { -- Random SurName 
	"Adam",
	"Austin",
	"Lincoln",
	"Murfy",
	"Gran",
	"Edouards",
	"Anderson",
	"Boswell",
	"Roswell",
	"Guthember",
}

-----------------------------------------------------------------------------
--------------------------- Model Configuration------------------------------
-----------------------------------------------------------------------------

CharacterCreator.Models = {}

CharacterCreator.Models[1] = { -- Boys Models Configuration
	"models/player/zelpa/male_01.mdl",
	"models/player/zelpa/male_02.mdl",
	"models/player/zelpa/male_03.mdl",
	"models/player/zelpa/male_04.mdl",
	"models/player/zelpa/male_05.mdl",
	"models/player/zelpa/male_06.mdl",
	"models/player/zelpa/male_07.mdl",
	"models/player/zelpa/male_08.mdl",
	"models/player/zelpa/male_09.mdl",
	"models/player/zelpa/male_10.mdl",
	"models/player/zelpa/male_11.mdl",
}

CharacterCreator.Models[2] = { -- Girls Models Configuration
	"models/player/zelpa/female_01.mdl",
	"models/player/zelpa/female_02.mdl",
	"models/player/zelpa/female_03.mdl",
	"models/player/zelpa/female_04.mdl",
	"models/player/zelpa/female_01_b.mdl",
	"models/player/zelpa/female_06.mdl",
	"models/player/zelpa/female_02_b.mdl",
	"models/player/zelpa/female_03_b.mdl",
	"models/player/zelpa/female_04_b.mdl",
	"models/player/zelpa/female_06_b.mdl",
}

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
