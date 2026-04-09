/*
    Addon id: 6caa0056-2e1c-4a99-9ba2-8bb2fe3a0232
    Version: v1.5.7 (stable)
*/

util.AddNetworkString("CharacterCreator:OpenMenu")
util.AddNetworkString("CharacterCreator:MenuAdminOpen")
util.AddNetworkString("CharacterCreator:SaveFirst")
util.AddNetworkString("CharacterCreator:SaveCharacter")
util.AddNetworkString("CharacterCreator:LoadCharacter")
util.AddNetworkString("CharacterCreator:InformationClient")
util.AddNetworkString("CharacterCreator:DeleteCharacterClient")
util.AddNetworkString("CharacterCreator:CharacterAdmin")
util.AddNetworkString("CharacterCreator:ChangeTeam")
util.AddNetworkString("CharacterCreator:ClothesSend")
util.AddNetworkString("CharacterCreator:Notify")

local CharacterCreatorMetaTable = FindMetaTable("Player")
CharacterCreator.CharacterId = {
    ["Character #1"] = 1,
    ["Character #2"] = 2,
    ["Character #3"] = 3,
}

function CharacterCreatorMetaTable:CHCNotify(msg, time)
	local tbl = {
		["message"] = msg,
		["time"] = time, 
	}
	net.Start("CharacterCreator:Notify")
		net.WriteTable(tbl)
	net.Send(self)
end 

net.Receive("CharacterCreator:SaveFirst", function(len, ply)
	ply.countdownSaveFirst = ply.countdownSaveFirst or CurTime()
    if ply.countdownSaveFirst > CurTime() then return end
    ply.countdownSaveFirst = CurTime() + 1
	if IsValid( ply ) && ply:IsPlayer() then
		local steamid = ply:SteamID64()
		local CharacterCreatorTable = net.ReadTable() or {}
		local CharacterCreatorIdMenu = net.ReadInt(8)
		local CharacterCreatorJobChoose = net.ReadString() or ""

		ply:StripWeapons()
		ply:Spawn()

		if table.HasValue(CharacterCreator.Models[1], CharacterCreatorTable["CharacterCreatorModel"]) or table.HasValue(CharacterCreator.Models[2], CharacterCreatorTable["CharacterCreatorModel"])  then 
			CharacterCreatorTable["CharacterCreatorModel"] = CharacterCreatorTable["CharacterCreatorModel"] 
		else 
			CharacterCreatorTable["CharacterCreatorModel"] = table.Random(CharacterCreator.Models[1])
		end 

		if CharacterCreator.CanChooseJob then 
			timer.Simple(1, function()
				if table.HasValue(CharacterCreator.JobCanChoose, CharacterCreatorJobChoose) then 
					local CharacterCreatorTeam = 0
					for k,v in pairs(RPExtraTeams) do
						if v.name == CharacterCreatorJobChoose then
							CharacterCreatorTeam = k
							break
						end
					end 
					if CharacterCreatorTeam != ply:Team() then
						ply:changeTeam( CharacterCreatorTeam, true ) 
					end 
				end 
			end ) 
		end 

		if CharacterCreator.CompatibilityClothesMod then 
			ply.CanCreateCharacter = true
			CharacterCreatorTable = {
				CharacterCreatorName = ply:GetName(),
				CharacterCreatorSaveNationality = "", 
				CharacterCreatorModel = "", 
				CharacterCreatorSaveSexe = "",
				CharacterCreatorHeadId = 1,
				CharacterCreatorTorseId = 1, 
				CharacterCreatorGlovesId = 1,
				CharacterCreatorTrousersId = 1, 
				CharacterCreatorBg0Id = 0,
				CharacterCreatorBg4Id = 0,
				CharacterCreatorBg6Id = 0,
				CharacterCreatorBg7Id = 0,
			}	
			if file.Exists("clothesmod/"..ply:SteamID64(), "DATA") then 
				file.Delete("clothesmod/"..ply:SteamID64(), "DATA") 
			end 	
		end

		if BATM then 
			local Accounts = CBLib.LoadModule("batm/bm_accounts.lua", false)
			Accounts.GetCachedPersonalAccount(ply:SteamID64(), function(account, didExist)
				local BlueATMAmount = (account["balance"] or 0) 

				account:AddBalance(-BlueATMAmount)
				account:SaveAccount()
			end)
		end 

		if table.Count(CharacterCreatorTable) == 0 then return end 
		local CharacterCreatorMoneyOnStart = CharacterCreator.MoneyOnStartCharacter

		if CharacterCreatorIdMenu >= 1 or CharacterCreatorIdMenu <= 3 then
			if not file.Exists("charactercreator", "DATA") then
				file.CreateDir("charactercreator")
			end

			if not file.Exists("charactercreator/"..steamid, "DATA") then
				file.CreateDir("charactercreator/"..steamid)
			end

			file.Write("charactercreator/"..steamid.."/kobra_character_"..CharacterCreatorIdMenu..".txt", util.TableToJSON(CharacterCreatorTable, true))

			if CharacterCreator.CompatibilityItemStore == true then 
				for k, v in pairs( ply.Inventory:GetItems() ) do
					ply.Inventory:SetItem( k, nil )
				end

				for k, v in pairs( ply.Bank:GetItems() ) do
					ply.Bank:SetItem( k, nil )
				end
			end 
			if not CharacterCreator.CharacterAccountLinked then 
				ply:setDarkRPVar("money", CharacterCreatorMoneyOnStart)
			end 
		end
		if ply:Team() != GAMEMODE.DefaultTeam then 
			ply:changeTeam( GAMEMODE.DefaultTeam, true ) 
		end 
	end 
end)

net.Receive("CharacterCreator:SaveCharacter", function(len, ply) 
	ply.countdownSaveCharacter = ply.countdownSaveCharacter or CurTime()
    if ply.countdownSaveCharacter > CurTime() then return end
    ply.countdownSaveCharacter = CurTime() + 0.1
	if not IsValid( ply ) && not ply:IsPlayer() then return end 
	local CharacterCreatorIdSaveCharacter = net.ReadInt(8) 
	ply:SetVar( "CharacterCreatorIdSaveLoad", CharacterCreatorIdSaveCharacter ) 
	ply:CharacterCreatorSave()
end ) 

function CharacterCreatorMetaTable:LoadInformations(Bool)
	if file.Exists("charactercreator/"..self:SteamID64().."/kobra_character_1.txt", "DATA") then
		local CharacterCreatorFil1 = file.Read("charactercreator/"..self:SteamID64().."/kobra_character_1.txt", "DATA") or ""
		CharacterCreatorTab1 = util.JSONToTable(CharacterCreatorFil1) or {}
		self:SetNWString("CharacterCreator1","Player1Create")
	else 
		self:SetNWString("CharacterCreator1","PlayerNotCreate")
	end 

	if file.Exists("charactercreator/"..self:SteamID64().."/kobra_character_2.txt", "DATA") then
		local CharacterCreatorFil2 = file.Read("charactercreator/"..self:SteamID64().."/kobra_character_2.txt", "DATA") or ""
		CharacterCreatorTab2 = util.JSONToTable(CharacterCreatorFil2) or {}
		self:SetNWString("CharacterCreator2","Player2Create")
	else 
		self:SetNWString("CharacterCreator2","PlayerNotCreate")
	end 

	if file.Exists("charactercreator/"..self:SteamID64().."/kobra_character_3.txt", "DATA") then
		local CharacterCreatorFil3 = file.Read("charactercreator/"..self:SteamID64().."/kobra_character_3.txt", "DATA") or ""
		CharacterCreatorTab3 = util.JSONToTable(CharacterCreatorFil3) or {}
		self:SetNWString("CharacterCreator3","Player3Create")
	else
		self:SetNWString("CharacterCreator3","PlayerNotCreate")
	end 

	local tbl = { CharacterCreatorTab1, CharacterCreatorTab2, CharacterCreatorTab3 }
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199063103813

	net.Start("CharacterCreator:InformationClient")
		net.WriteTable(tbl)
		net.WriteBool(Bool)
	net.Send(self)
end 

function CharacterCreatorMetaTable:CharacterCreatorSave()
	if not self:GetVar( "CharacterCreatorIdSaveLoad") then return end 

	local steamid = self:SteamID64()
	CharacterCreatorFil = file.Read("charactercreator/"..steamid.."/kobra_character_"..self:GetVar( "CharacterCreatorIdSaveLoad")..".txt", "DATA") or ""
	CharacterCreatorTabSaveCharacter = util.JSONToTable(CharacterCreatorFil) or {}

	if table.Count(CharacterCreatorTabSaveCharacter) == 0 then return end 

	CharacterCreatorPosition = self:Alive() && self:GetPos() or nil
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e7470ef06f6b9f4cb7eb859aac9e04a5e1ab282313d4b3d8c10765ed2d3173a9

	if CharacterCreator.CompatibilityClothesMod then 
		CharacterCreatorClothing = self:CM_GetInfos()
		CharacterCreatorModelSave = self:CM_GetInfos()["model"]
	else
		CharacterCreatorModelSave = CharacterCreatorTabSaveCharacter["CharacterCreatorModel"] 
	end 

	if CharacterCreator.CharacterNotify then 
		self:CHCNotify(CharacterCreator.GetSentence("characterSaved"), 5)
	end

	if CharacterCreator.CompatibilityItemStore then 
		CharacterCreatorInventoryItemStore = self.Inventory:GetItems()
		for k, v in pairs(CharacterCreatorInventoryItemStore) do
			CharacterCreatorInventoryItemStore[k].Container = nil
		end
		CharacterCreatorItemJson = util.TableToJSON(CharacterCreatorInventoryItemStore)
		CharacterCreatorBankItemStore = self.Bank:GetItems()
		for k, v in pairs(CharacterCreatorBankItemStore) do
			CharacterCreatorBankItemStore[k].Container = nil
		end
		CharaterCreatorJsonBank = util.TableToJSON(CharacterCreatorBankItemStore)
	end

	if self:Health() == 0 && not self:Alive() then 
		CharacterCreatorSaveHealth = self:GetMaxHealth() 
	elseif self:Alive() then 
		CharacterCreatorSaveHealth = self:Health()
	end 

	if CharacterCreator.CompatibilityClothesMod then 
		if not istable(CharacterCreatorTabSaveCharacter["CharacterCreatorClothesTops"]) or #CharacterCreatorTabSaveCharacter["CharacterCreatorClothesTops"] == 0 then 
			if not istable(CLOTHESMOD.PlayerTops) then CLOTHESMOD.PlayerTops = {} end 
			if not istable(CLOTHESMOD.PlayerTops[self:SteamID64()]) then CLOTHESMOD.PlayerTops[self:SteamID64()] = {} end 
			CharacterCreatorClothesTops = CLOTHESMOD.PlayerTops[self:SteamID64()]
		else 
			CharacterCreatorClothesBottoms = CharacterCreatorTabSaveCharacter["CharacterCreatorClothesTops"]
		end 
		if not istable(CharacterCreatorTabSaveCharacter["CharacterCreatorClothesBottoms"]) or #CharacterCreatorTabSaveCharacter["CharacterCreatorClothesBottoms"] == 0 then 
			if not istable(CLOTHESMOD.PlayerBottoms) then CLOTHESMOD.PlayerBottoms = {} end 
			if not istable(CLOTHESMOD.PlayerBottoms[self:SteamID64()]) then CLOTHESMOD.PlayerBottoms[self:SteamID64()] = {} end 
			CharacterCreatorClothesBottoms = CLOTHESMOD.PlayerBottoms[self:SteamID64()]
		else 
			CharacterCreatorClothesBottoms = CharacterCreatorTabSaveCharacter["CharacterCreatorClothesBottoms"]
		end 
		if CharacterCreatorTabSaveCharacter["CharacterCreatorName"] != self:GetName() then 
			CharacterCreatorName = self:GetName()
		else
			CharacterCreatorName = CharacterCreatorTabSaveCharacter["CharacterCreatorName"] 
		end
	else
		CharacterCreatorName = CharacterCreatorTabSaveCharacter["CharacterCreatorName"] 
		CharacterCreatorClothesTops = {}
		CharacterCreatorClothesBottoms = {}
	end 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c24aa0f51c3521dc86ce13039a612ad6a262a16b758cd0bdb3462448d89950ac
	
	local BlueATMAmount = nil
	if BATM then 
		local Accounts = CBLib.LoadModule("batm/bm_accounts.lua", false)
		Accounts.GetCachedPersonalAccount(self:SteamID64(), function(account, didExist)
			BlueATMAmount = (account["balance"] or 0) 
		end)
	end 
	local trainingData = nil
	if Diablos && Diablos.TS then
		trainingData = self:TSGetTrainingInfo()
		if not trainingData then
			trainingData = CharacterCreatorTabSaveCharacter["CharacterCreatorDiablosTraining"]
		end
	end

	if self:getDarkRPVar("money") != nil then 
		CharacterCreatorSaveMoney = self:getDarkRPVar("money") 
	end 
	
	local CharacterCreatorWeapons = {}
	local data = {
		CharacterCreatorName = CharacterCreatorName,
		CharacterCreatorSaveSexe = CharacterCreatorTabSaveCharacter["CharacterCreatorSaveSexe"],
		CharacterCreatorSaveNationality = CharacterCreatorTabSaveCharacter["CharacterCreatorSaveNationality"],
		CharacterCreatorHeadId = CharacterCreatorTabSaveCharacter["CharacterCreatorHeadId"], 
		CharacterCreatorTorseId = CharacterCreatorTabSaveCharacter["CharacterCreatorTorseId"], 
		CharacterCreatorTrousersId = CharacterCreatorTabSaveCharacter["CharacterCreatorTrousersId"], 
		CharacterCreatorGlovesId = CharacterCreatorTabSaveCharacter["CharacterCreatorGlovesId"], 
		CharacterCreatorBg0Id = CharacterCreatorTabSaveCharacter["CharacterCreatorBg0Id"],
		CharacterCreatorBg4Id = CharacterCreatorTabSaveCharacter["CharacterCreatorBg4Id"],
		CharacterCreatorBg6Id = CharacterCreatorTabSaveCharacter["CharacterCreatorBg6Id"],
		CharacterCreatorBg7Id = CharacterCreatorTabSaveCharacter["CharacterCreatorBg7Id"],
		CharacterCreatorModel = CharacterCreatorModelSave,
		CharacterCreatorWeapons = CharacterCreatorWeapons,
		CharacterCreatorSaveHealth = CharacterCreatorSaveHealth,
		CharacterCreatorModelJob = self:GetModel(),
		CharacterCreatorSaveArmor = self:Armor(),  
		CharacterCreatorSaveMoney = CharacterCreatorSaveMoney,
		CharacterCreatorClothing = CharacterCreatorClothing, 
		CharacterCreatorSaveJob = team.GetName( self:Team() ), 
		CharacterCreatorSaveLicense = self:getDarkRPVar("HasGunlicense"),
		CharacterCreatorSaveIsWanted = self:getDarkRPVar("wanted"),
		CharacterCreatorSaveWantedReason = self:getDarkRPVar("wantedReason"),
		CharacterCreatorPosition = CharacterCreatorPosition, 
		CharacterCreatorInventoryItemStore = CharacterCreatorInventoryItemStore, 
		CharacterCreatorBankItemStore = CharacterCreatorBankItemStore, 
		CharacterCreatorClothesTops = CharacterCreatorClothesTops, 
		CharacterCreatorClothesBottoms = CharacterCreatorClothesBottoms, 
		CharacterCreatorBlueAtm = BlueATMAmount,
		CharacterCreatorDiablosTraining = trainingData,
	}

	for k,v in pairs(self:GetWeapons()) do
		if not CharacterCreator.CharacterJobNotSave[team.GetName(self:Team())] then 
			table.insert(CharacterCreatorWeapons, v:GetClass())
		end 
	end 
	
	if istable(self:GetWeapons()) && self:getDarkRPVar("money") != nil then  
		file.Write("charactercreator/"..steamid.."/kobra_character_"..self:GetVar( "CharacterCreatorIdSaveLoad")..".txt", util.TableToJSON(data, true))
	end 

	timer.Simple(1, function()
		if not IsValid(self) or not self:IsPlayer() then return end 
		self:LoadInformations(false)
	end)
end 

hook.Add("ClothesMod.OnInfosSaved", "CharacterCreator:ClothesModOnInfosSaved", function(ply) 
	timer.Simple(1, function()
		if not IsValid(ply) or not ply:IsPlayer() then return end 
		ply:CharacterCreatorSave()
	end)
end )

hook.Add( "ShutDown", "CharacterCreator:SaveShutDown", function()
	for k,v in pairs(player.GetAll()) do 
		if IsValid(v) && v:IsPlayer() then
			v:CharacterCreatorSave()
		end 
	end 
end ) 

hook.Add( "playerWalletChanged", "CharacterCreator:WalletChanged", function(ply, amount, wallet)
	local steamid = ply:SteamID64()
	if not isnumber(ply:GetVar( "CharacterCreatorIdSaveLoad")) then return end
	if not isnumber(amount) or not isnumber(wallet) then return end 
	if ply:GetVar( "CharacterCreatorIdSaveLoad") > 3 or ply:GetVar( "CharacterCreatorIdSaveLoad") < 1 then return end 
	CharacterCreatorFil = file.Read("charactercreator/"..steamid.."/kobra_character_"..ply:GetVar( "CharacterCreatorIdSaveLoad")..".txt", "DATA") or ""
	CharacterCreatorTabSaveCharacter = util.JSONToTable(CharacterCreatorFil) or {}

	CharacterCreatorTabSaveCharacter["CharacterCreatorSaveMoney"] = wallet + amount 

	file.Write("charactercreator/"..steamid.."/kobra_character_"..ply:GetVar( "CharacterCreatorIdSaveLoad")..".txt", util.TableToJSON(CharacterCreatorTabSaveCharacter, true))
end ) 

net.Receive("CharacterCreator:LoadCharacter", function(len, ply)
	ply.countdownLoad = ply.countdownLoad or CurTime()
    if ply.countdownLoad > CurTime() then return end
    ply.countdownLoad = CurTime() + 1
	local steamid = ply:SteamID64()
	local CharacterCreatorIdLoad = net.ReadInt(8)
	if CharacterCreatorIdLoad < 1 or CharacterCreatorIdLoad > 3 then return end 
	local CharacterCreatorFil = file.Read("charactercreator/"..steamid.."/kobra_character_"..CharacterCreatorIdLoad..".txt", "DATA") or ""
	local CharacterCreatorTable = util.JSONToTable(CharacterCreatorFil) or {}

	if table.Count(CharacterCreatorTable) == 0 then return end 
	if not IsValid( ply ) && not ply:IsPlayer() then return end 
	
	local CharacterCreatorTeam = 0
	for k,v in pairs(RPExtraTeams) do
		if CharacterCreator.CharacterJobNotSave[CharacterCreatorTable[ "CharacterCreatorSaveJob" ]] then 
			if CharacterCreatorTeam != ply:Team() then
				ply:changeTeam( GAMEMODE.DefaultTeam, true )
			end 
		end 
		if v.name == CharacterCreatorTable["CharacterCreatorSaveJob"] then
			CharacterCreatorTeam = k
			break
		end
	end 
	if CharacterCreator.CharacterLoadJob then 
		if not CharacterCreator.CharacterJobNotSave[CharacterCreatorTable[ "CharacterCreatorSaveJob" ]] then 
			if CharacterCreatorTable[ "CharacterCreatorSaveJob" ] != team.GetName(ply:Team()) then
				ply:changeTeam( CharacterCreatorTeam, true ) 
			end 
		end 
	end
	if CharacterCreator.CompatibilityItemStore then 
		for k, v in pairs( ply.Inventory:GetItems() ) do
			ply.Inventory:SetItem( k, nil )
		end

		for k, v in pairs( ply.Bank:GetItems() ) do
			ply.Bank:SetItem( k, nil )
		end
	end 
	ply:Spawn()
	ply:setDarkRPVar("wanted", false) 

	timer.Simple(0.1, function()
		if not IsValid( ply ) && not ply:IsPlayer() then return end  
		if CharacterCreator.CompatibilityItemStore then 
			for k, v in pairs( ply.Inventory:GetItems() ) do
				ply.Inventory:SetItem( k, nil )
			end

			for k, v in pairs( ply.Bank:GetItems() ) do
				ply.Bank:SetItem( k, nil )
			end
		end 
		if CharacterCreator.CharacterLoadMoney then 
			if not CharacterCreator.CharacterAccountLinked then 
				ply:setDarkRPVar("money", CharacterCreatorTable[ "CharacterCreatorSaveMoney" ])
			end 
		end
		if ply:getDarkRPVar("rpname") != CharacterCreatorTable["CharacterCreatorName"] then 
			ply:setRPName( CharacterCreatorTable["CharacterCreatorName"], false)
		end 
		if CharacterCreator.CharacterLoadLicense then 
			if CharacterCreatorTable["CharacterCreatorSaveLicense"] == true then 
				ply:setDarkRPVar("HasGunlicense", true) 
			end 
		end
		if CharacterCreator.CharacterLoadWanted then 
			if CharacterCreatorTable["CharacterCreatorSaveIsWanted"] == true then 
				ply:setDarkRPVar("wanted", true) 
				ply:setDarkRPVar("wantedReason", CharacterCreatorTable["CharacterCreatorSaveWantedReason"]) 
			end
		end 
		if CharacterCreator.CharacterLoadHealth then 
			ply:SetHealth(CharacterCreatorTable[ "CharacterCreatorSaveHealth" ])
		end
		if CharacterCreator.CharacterLoadArmor then 
			ply:SetArmor(CharacterCreatorTable[ "CharacterCreatorSaveArmor" ])
		end
		if CharacterCreator.CharacterLoadPosition then 
			if not isvector(CharacterCreatorTable[ "CharacterCreatorPosition" ]) then return end 
			ply:SetPos(CharacterCreatorTable[ "CharacterCreatorPosition" ])
		end 
		if CharacterCreator.CharacterLoadWeapons then 
			if not CharacterCreator.CharacterJobNotSave[CharacterCreatorTable[ "CharacterCreatorSaveJob" ]] && not CharacterCreator.CharacterJobWeaponNotSave[CharacterCreatorTable[ "CharacterCreatorSaveJob" ]] then 
				if istable(CharacterCreatorTable["CharacterCreatorWeapons"]) then 
					ply:StripWeapons()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199063103813
					
					for k,v in pairs(CharacterCreatorTable["CharacterCreatorWeapons"]) do
						ply:Give(v)
					end
				end 
			end
		end 
		if not CharacterCreator.CharacterJobModelNotSave[CharacterCreatorTable[ "CharacterCreatorSaveJob" ]] then 
			if not CharacterCreator.CompatibilityClothesMod then 
				if isstring(CharacterCreatorTable[ "CharacterCreatorModel" ]) then 
					ply:SetModel(CharacterCreatorTable[ "CharacterCreatorModel" ]) 
				end  
				ply:SetBodygroup(1, CharacterCreatorTable[ "CharacterCreatorTorseId" ])
				ply:SetBodygroup(2, CharacterCreatorTable[ "CharacterCreatorGlovesId" ])
				ply:SetBodygroup(3, CharacterCreatorTable[ "CharacterCreatorTrousersId" ])
				ply:SetBodygroup(5, CharacterCreatorTable[ "CharacterCreatorHeadId" ])
				ply:SetBodygroup(0, CharacterCreatorTable[ "CharacterCreatorBg0Id" ] or 0)
				ply:SetBodygroup(4, CharacterCreatorTable[ "CharacterCreatorBg4Id" ] or 0)
				ply:SetBodygroup(6, CharacterCreatorTable[ "CharacterCreatorBg6Id" ] or 0)
				ply:SetBodygroup(7, CharacterCreatorTable[ "CharacterCreatorBg7Id" ] or 0)
			end 
		end 
		if CharacterCreator.CompatibilityItemStore then 
			if istable(CharacterCreatorTable["CharacterCreatorInventoryItemStore"]) then 
				for k, v in pairs( CharacterCreatorTable["CharacterCreatorInventoryItemStore"] ) do
					if v != nil then 
						if CharacterCreator.CompatibilityItemStore then 
							ply.Inventory:SetItem( k, itemstore.Item( v.Class, v.Data ) )
						end 
					end 
				end
			end 
			if istable(CharacterCreatorTable["CharacterCreatorBankItemStore"]) then 
				for k, v in pairs( CharacterCreatorTable["CharacterCreatorBankItemStore"] ) do
					if v != nil then 
						if CharacterCreator.CompatibilityItemStore then 
							ply.Bank:SetItem( k, itemstore.Item( v.Class, v.Data ) )
						end 
					end 
				end
			end 
		end 
		if BATM then 
			local Accounts = CBLib.LoadModule("batm/bm_accounts.lua", false)
			Accounts.GetCachedPersonalAccount(ply:SteamID64(), function(account, didExist)
				local BlueATMAmount = (account["balance"] or 0) 

				account:AddBalance(-BlueATMAmount)
				account:AddBalance(CharacterCreatorTable["CharacterCreatorBlueAtm"])
				account:SaveAccount()
			end)
		end 
		if Diablos && Diablos.TS then
			local tableConstruct = Diablos.TS:TransformSavedTableToSQLTable(CharacterCreatorTable["CharacterCreatorDiablosTraining"])
			Diablos.TS:ConstructTrainingData(ply, tableConstruct, true)
		end
		if CharacterCreator.CompatibilityClothesMod then 
			timer.Simple(1, function() 
				if not IsValid(ply) or not ply:IsPlayer() then return end 
				
				CLOTHESMOD.PlayerInfos[ply:SteamID64()] = CharacterCreatorTable[ "CharacterCreatorClothing" ]
				CLOTHESMOD.PlayerTops[ply:SteamID64()] = CharacterCreatorTable[ "CharacterCreatorClothesTops" ]
				CLOTHESMOD.PlayerBottoms[ply:SteamID64()] = CharacterCreatorTable[ "CharacterCreatorClothesBottoms" ]

				ply:CM_ApplyModel()

				local TableToSend = {
					["Clothing"] = CharacterCreatorTable[ "CharacterCreatorClothing" ], 
					["Tops"] = CharacterCreatorTable[ "CharacterCreatorClothesTops" ],
					["Bottoms"] = CharacterCreatorTable[ "CharacterCreatorClothesBottoms" ],
				}

				net.Start("CharacterCreator:ClothesSend")
					net.WriteTable( TableToSend )
				net.Send(ply)
			end  ) 
		end 
	end )
end) 

net.Receive("CharacterCreator:DeleteCharacterClient", function(len, ply)
	ply.countdownDelete = ply.countdownDelete or CurTime()
    if ply.countdownDelete > CurTime() then return end
    ply.countdownDelete = CurTime() + 0.1
	if IsValid( ply ) && ply:IsPlayer() then
		local CharacterCreatorIdDelete = net.ReadInt(8)
		if CharacterCreatorIdDelete < 1 or CharacterCreatorIdDelete > 3 then return end 

		if file.Exists("charactercreator/"..ply:SteamID64().."/kobra_character_"..CharacterCreatorIdDelete..".txt", "DATA") then
			file.Delete("charactercreator/"..ply:SteamID64().."/kobra_character_"..CharacterCreatorIdDelete..".txt", "DATA") 
		end
		ply:Spawn()
		timer.Simple(0.3, function()
			if not IsValid( ply ) && not ply:IsPlayer() then return end 
			net.Start("CharacterCreator:OpenMenu")
				net.WriteBool(false)
			net.Send(ply)
		end) 
	end 
end) 

net.Receive("CharacterCreator:CharacterAdmin", function(len, ply) 
	if IsValid(ply) && ply:IsPlayer() then 
		if CharacterCreator.RankToOpenAdmin[ply:GetUserGroup()] then 
			local CharacterCreatorBool = net.ReadBool()
			if CharacterCreatorBool == false then 

				local CharacterCreatorString = net.ReadString()
				local CharacterCreatorChoice = net.ReadString()
				local CharacterCreatorEntity = net.ReadEntity()

				CharacterCreatorId = CharacterCreator.CharacterId[CharacterCreatorChoice]

				if CharacterCreatorString == "CharacterCreator:RecupData" then 
					local CharacterCreatorFil = file.Read("charactercreator/"..CharacterCreatorEntity:SteamID64().."/kobra_character_"..CharacterCreatorId..".txt", "DATA")
					CharacterCreatorTab = util.JSONToTable(CharacterCreatorFil)

					net.Start("CharacterCreator:CharacterAdmin")
					net.WriteTable(CharacterCreatorTab)
					net.Send(ply)
 
				elseif CharacterCreatorString == "CharacterCreator:RemoveData" then 
					if file.Exists("charactercreator/"..CharacterCreatorEntity:SteamID64().."/kobra_character_"..CharacterCreatorId..".txt", "DATA") then 
						file.Delete("charactercreator/"..CharacterCreatorEntity:SteamID64().."/kobra_character_"..CharacterCreatorId..".txt", "DATA")
						CharacterCreatorEntity:Spawn() 
						
						timer.Simple(0.1, function()
							if not IsValid( ply ) && not ply:IsPlayer() then return end 
							net.Start("CharacterCreator:OpenMenu")
								net.WriteBool(false)
							net.Send(CharacterCreatorEntity)
						end ) 
					end 
				end 

			elseif CharacterCreatorBool == true then 
				local CharacterCreatorChoice = net.ReadString()
				local CharacterCreatorName = net.ReadString()
				local CharacterCreatorEntity = net.ReadEntity()
				local CharacterCreatorMoney = net.ReadInt(32)
				if not IsValid(CharacterCreatorEntity) then return end

				CharacterCreatorId = CharacterCreator.CharacterId[CharacterCreatorChoice]

				local CharacterCreatorFil = file.Read("charactercreator/"..CharacterCreatorEntity:SteamID64().."/kobra_character_"..CharacterCreatorId..".txt", "DATA")
				CharacterCreatorTab = util.JSONToTable(CharacterCreatorFil)

				CharacterCreatorEntity:setDarkRPVar("rpname", CharacterCreatorName)

				CharacterCreatorTab["CharacterCreatorName"] = CharacterCreatorName
				CharacterCreatorTab["CharacterCreatorSaveMoney"] = CharacterCreatorMoney
				
				if CharacterCreatorTab["CharacterCreatorClothing"] then
					local tblstr = string.Explode(" ", CharacterCreatorName)

					CharacterCreatorTab["CharacterCreatorClothing"]["name"] = (tblstr[1] or CharacterCreatorName)
					CharacterCreatorTab["CharacterCreatorClothing"]["surname"] = (tblstr[2] or "")
				end

				file.Write("charactercreator/"..CharacterCreatorEntity:SteamID64().."/kobra_character_"..CharacterCreatorId..".txt", util.TableToJSON(CharacterCreatorTab, true))
				CharacterCreatorEntity:Spawn() 
				timer.Simple(0.1, function()
					if not IsValid( ply ) && not ply:IsPlayer() then return end 
					net.Start("CharacterCreator:OpenMenu")
						net.WriteBool(false)
					net.Send(CharacterCreatorEntity)
				end ) 
			end
		end 
	end   
end) 

net.Receive("CharacterCreator:ChangeTeam", function(len, ply)
	if CharacterCreator.CharacterSetTeamNoRespawn then 
		local steamid = ply:SteamID64()
		local CharacterCreatorId = ply:GetVar( "CharacterCreatorIdSaveLoad" )
		if CharacterCreatorId < 1 or CharacterCreatorId > 3 then return end 
		local CharacterCreatorFil = file.Read("charactercreator/"..steamid.."/kobra_character_"..CharacterCreatorId..".txt", "DATA") or ""
		local CharacterCreatorTable = util.JSONToTable(CharacterCreatorFil) or {}

		if not CharacterCreator.CharacterJobModelNotSave[team.GetName(ply:Team())] then 
			if not CharacterCreator.CompatibilityClothesMod then 
				timer.Simple(1, function()
					if not IsValid(ply) and not ply:IsPlayer() then return end 
					if Diablos && Diablos.TS then
						-- Diablos.TS:UpdateTrainingBones(ply, Diablos.TS.TrainingsChangingBone)
					end
					ply:SetModel(CharacterCreatorTable[ "CharacterCreatorModel" ]) 
					ply:SetBodygroup(1, CharacterCreatorTable[ "CharacterCreatorTorseId" ])
					ply:SetBodygroup(2, CharacterCreatorTable[ "CharacterCreatorGlovesId" ])
					ply:SetBodygroup(3, CharacterCreatorTable[ "CharacterCreatorTrousersId" ])
					ply:SetBodygroup(5, CharacterCreatorTable[ "CharacterCreatorHeadId" ])
					ply:SetBodygroup(0, CharacterCreatorTable[ "CharacterCreatorBg0Id" ] or 0)
					ply:SetBodygroup(4, CharacterCreatorTable[ "CharacterCreatorBg4Id" ] or 0)
					ply:SetBodygroup(6, CharacterCreatorTable[ "CharacterCreatorBg6Id" ] or 0)
					ply:SetBodygroup(7, CharacterCreatorTable[ "CharacterCreatorBg7Id" ] or 0)
				end ) 
			end 
		end 
	end 
end ) 


hook.Add("PlayerInitialSpawn","CharacterCreator:SpawnOpen", function(ply) 
	if IsValid( ply ) && ply:IsPlayer() then
		ply.CanCreateCharacter = false 
		timer.Simple(3, function()
			if not IsValid( ply ) && not ply:IsPlayer() then return end 
			if CharacterCreator.CompatibilityClothesMod then
				ply.CanCreateCharacter = false 
			end 
			if not CharacterCreator.CharacterAccountLinked then 
				ply:setDarkRPVar("money", 0)
			end 
			ply:LoadInformations(true)
		end) 
		timer.Create("RealisticProperties:Timer"..ply:EntIndex(), 240, 0, function()
			if isnumber(ply:GetVar( "CharacterCreatorIdSaveLoad")) then 
				if IsValid(ply) && ply:IsPlayer() then 
					if ply:GetVar( "CharacterCreatorIdSaveLoad") < 3 or ply:GetVar( "CharacterCreatorIdSaveLoad") > 1 then
						ply:CharacterCreatorSave() 
					end 
				end 
			end 
		end )
	end 
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 15478a1827bdd0ab07064f24626a05e7e8fa2b4b1e33baa627f3f8cb0b843238

hook.Add("PlayerButtonDown", "CharacterCreator:PlayerButtonDown", function(ply,button)
	if CharacterCreator.KeyOpenOption then 
		if button == CharacterCreator.KeyOpen then 
			if IsValid( ply ) && ply:IsPlayer() then
				ply.CanCreateCharacter = false 
				
				if not IsValid( ply ) && not ply:IsPlayer() then return end 
				if CharacterCreator.CompatibilityClothesMod then
					ply.CanCreateCharacter = false 
				end 
				if not CharacterCreator.CharacterAccountLinked then 
					ply:setDarkRPVar("money", 0)
				end 
				ply:LoadInformations(true)

				timer.Create("RealisticProperties:Timer"..ply:EntIndex(), 240, 0, function()
					if isnumber(ply:GetVar( "CharacterCreatorIdSaveLoad")) then 
						if IsValid(ply) && ply:IsPlayer() then 
							if ply:GetVar( "CharacterCreatorIdSaveLoad") < 3 or ply:GetVar( "CharacterCreatorIdSaveLoad") > 1 then
								ply:CharacterCreatorSave() 
							end 
						end 
					end 
				end)
			end 
		end 
	end 
end) 

hook.Add("PlayerDisconnected","CharacterCreator:PlayerDisconnected", function(ply) 
	if IsValid( ply ) && ply:IsPlayer() then
		ply:CharacterCreatorSave()
		timer.Remove("RealisticProperties:Timer"..ply:EntIndex()) 
	end 
end)

hook.Add("PlayerDeath","CharacterCreator:PlayerDeath", function(ply)  
	if IsValid( ply ) && ply:IsPlayer() then
		if not isnumber(isnumber(ply:GetVar("CharacterCreatorIdSaveLoad"))) then return end
		
		local CharacterCreatorFil = file.Read("charactercreator/"..ply:SteamID64().."/kobra_character_"..ply:GetVar("CharacterCreatorIdSaveLoad")..".txt", "DATA") or ""
		CharacterCreatorTab = util.JSONToTable(CharacterCreatorFil) or {}

		if CharacterCreator.CompatibilityItemStore then 
			CharacterCreatorTab["CharacterCreatorInventoryItemStore"] = nil 
			--CharacterCreatorTab["CharacterCreatorBankItemStore"] = nil 
			file.Write("charactercreator/"..ply:SteamID64().."/kobra_character_"..ply:GetVar( "CharacterCreatorIdSaveLoad")..".txt", util.TableToJSON(CharacterCreatorTab, true))
		end 

		if CharacterCreator.DeleteCharacterDeath then 
			file.Delete("charactercreator/"..ply:SteamID64().."/kobra_character_"..ply:GetVar( "CharacterCreatorIdSaveLoad")..".txt", "DATA")
		end 

		ply:SetNWBool("CharacterCreatorPlayerDeath",true)
		timer.Simple(0.2, function()
			if not IsValid( ply ) && not ply:IsPlayer() then return end 
			ply:CharacterCreatorSave()
		end )
	end 
end) 

hook.Add( "CanChangeRPName", "CharacterCreator:CanChangeRPName", function() 
	return !CharacterCreator.CharacterRpNameDisable 
end)

hook.Add("onPlayerRevived","CharacterCreator:CompatibilityMedicModRevived", function(ply) 
	if IsValid(ply) && ply:IsPlayer() then
		timer.Remove("CharacterCreatorTimerRespawn")
	end  
end)

hook.Add("CH_AdvMedic_OnBodyRemoved", "CharacterCreator:CH_AdvMedic_OnBodyRemoved", function(ply, revived)
	if revived then 
		if IsValid(ply) && ply:IsPlayer() then
			timer.Remove("CharacterCreatorTimerRespawn")
		end 
	end
end)


hook.Add("PlayerSpawn","CharacterCreator:SpawnPlayer", function(ply)
	if IsValid(ply) && ply:IsPlayer() then
		
		ply:LoadInformations(false)

		if ply:GetNWBool("CharacterCreatorPlayerDeath") == true then
			ply:SetNWBool("CharacterCreatorPlayerDeath",false)
			timer.Create("CharacterCreatorTimerRespawn", 0.2, 1, function()
				if not IsValid( ply ) && not ply:IsPlayer() then return end
				ply:Spawn()
				if not CharacterCreator.CharacterDisableDeathOpenMenu then 
					net.Start("CharacterCreator:OpenMenu")
						net.WriteBool(false)
					net.Send(ply)
				end 
			end)
		end 

		timer.Simple(2, function()
			if ply:GetVar( "CharacterCreatorIdSaveLoad") == nil then return end 
			if not IsValid( ply ) && not ply:IsPlayer() then return end 
			local steamid = ply:SteamID64()
			CharacterCreatorFil = file.Read("charactercreator/"..steamid.."/kobra_character_"..ply:GetVar( "CharacterCreatorIdSaveLoad")..".txt", "DATA") or ""
			CharacterCreatorTable = util.JSONToTable(CharacterCreatorFil) or {}

			if not CharacterCreator.CharacterJobModelNotSave[team.GetName(ply:Team())] then 
				if not CharacterCreator.CharacterJobModelNotSave[CharacterCreatorTable[ "CharacterCreatorSaveJob" ]] && not CharacterCreator.CharacterJobModelNotSave[ply:getDarkRPVar("job")]  then 
					if not CharacterCreator.CompatibilityClothesMod then 
						if not isstring(CharacterCreatorTable[ "CharacterCreatorModel" ]) then return end 
						
						ply:SetModel(CharacterCreatorTable[ "CharacterCreatorModel" ]) 
						ply:SetBodygroup(1, CharacterCreatorTable[ "CharacterCreatorTorseId" ])
						ply:SetBodygroup(2, CharacterCreatorTable[ "CharacterCreatorGlovesId" ])
						ply:SetBodygroup(3, CharacterCreatorTable[ "CharacterCreatorTrousersId" ])
						ply:SetBodygroup(5, CharacterCreatorTable[ "CharacterCreatorHeadId" ])
						ply:SetBodygroup(0, CharacterCreatorTable[ "CharacterCreatorBg0Id" ] or 0)
						ply:SetBodygroup(4, CharacterCreatorTable[ "CharacterCreatorBg4Id" ] or 0)
						ply:SetBodygroup(6, CharacterCreatorTable[ "CharacterCreatorBg6Id" ] or 0)
						ply:SetBodygroup(7, CharacterCreatorTable[ "CharacterCreatorBg7Id" ] or 0)
					end 
				end 
			end   
			if CharacterCreator.CompatibilityBricksCreditStore then 
				local PlyLocker = ply:GetBRCS_Locker()
                for k, v in pairs( ply:GetBRCS_Active() ) do
                    if( PlyLocker[k] and PlyLocker[k][1] and PlyLocker[k][2] and BRICKSCREDITSTORE.LOCKERTYPES[PlyLocker[k][1]] and BRICKSCREDITSTORE.LOCKERTYPES[PlyLocker[k][1]].OnSpawn ) then
                        BRICKSCREDITSTORE.LOCKERTYPES[PlyLocker[k][1]].OnSpawn( ply, PlyLocker[k][2] )
                    end
                end
			end 
		end) 
	end 
end) 

hook.Add("onPlayerChangedName", "CharacterCreator:OnPlayerChangeName", function(ply, oldName, newName)
	timer.Simple(0.1, function()
		if not IsValid( ply ) && not ply:IsPlayer() then return end 
		if not isnumber(ply:GetVar( "CharacterCreatorIdSaveLoad")) then return end
		if ply:GetVar( "CharacterCreatorIdSaveLoad") > 3 or ply:GetVar( "CharacterCreatorIdSaveLoad") < 1 then return end 
		local steamid = ply:SteamID64()
		CharacterCreatorFil = file.Read("charactercreator/"..steamid.."/kobra_character_"..ply:GetVar( "CharacterCreatorIdSaveLoad")..".txt", "DATA") or ""
		CharacterCreatorTable = util.JSONToTable(CharacterCreatorFil) or {}

		if CharacterCreator.SaveChangingName then 
			CharacterCreatorTable["CharacterCreatorName"] = ply:Name()
		end 

		file.Write("charactercreator/"..ply:SteamID64().."/kobra_character_"..ply:GetVar( "CharacterCreatorIdSaveLoad")..".txt", util.TableToJSON(CharacterCreatorTable, true))
	end) 
end)

timer.Simple(2, function()
	net.Receive("ClothesMod:PlayerHasLoaded", function(len, ply) end)
end)

concommand.Add("save_allcharacter", function( ply, cmd, args )
	if CharacterCreator.RankToOpenAdmin[ply:GetUserGroup()] then 
		for k,v in pairs(player.GetAll()) do 
			if IsValid(v) && v:IsPlayer() then 
				v:CharacterCreatorSave() 
			end 
		end
	end 
end)
