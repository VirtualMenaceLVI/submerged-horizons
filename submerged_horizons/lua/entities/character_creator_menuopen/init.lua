/*
    Addon id: 6caa0056-2e1c-4a99-9ba2-8bb2fe3a0232
    Version: v1.5.7 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Humans/Group01/Female_02.mdl")
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:SetUseType(SIMPLE_USE)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d90b40d7d178e5adda34201e534657c97e623b5b60bb31ab0498b85eaf4bace5

function ENT:AcceptInput( name, activator, caller )
 	if ( name == "Use" && activator:IsPlayer() ) then
 		if activator:GetNWString("CharacterCreator1") == "Player1Create" or activator:GetNWString("CharacterCreator2") == "Player2Create" or activator:GetNWString("CharacterCreator3") == "Player3Create" then 
 			activator:CharacterCreatorSave()
 		end 
	 	timer.Simple(0.2, function()
	 		if not IsValid( activator ) && not activator:IsPlayer() then return end 
			net.Start("CharacterCreator:OpenMenu")
				net.WriteBool(true)
		    net.Send(activator)
		end) 
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c24aa0f51c3521dc86ce13039a612ad6a262a16b758cd0bdb3462448d89950ac
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199063103813
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199063103836
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c24aa0f51c3521dc86ce13039a612ad6a262a16b758cd0bdb3462448d89950ac

function ENT:OnTakeDamage()
    return 0
end
