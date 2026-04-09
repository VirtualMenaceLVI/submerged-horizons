/*
    Addon id: 6caa0056-2e1c-4a99-9ba2-8bb2fe3a0232
    Version: v1.5.7 (stable)
*/

AddCSLuaFile()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d90b40d7d178e5adda34201e534657c97e623b5b60bb31ab0498b85eaf4bace5

TOOL.Category = "Character Creator"
TOOL.Name = "Chc-Administration"
TOOL.Author = "Kobralost"
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199063103813

if CLIENT then
	language.Add("tool.character_creator_tooladmin.desc", "Administration - Character Creator" )
	language.Add("tool.character_creator_tooladmin.0", "Left-Click : Player Information / Right-Click : Your Information" )
	language.Add("tool.character_creator_tooladmin.name", "Character-Creator")
end

function TOOL:LeftClick(trace)
	local ply = self:GetOwner()
	local trace = ply:GetEyeTrace()
	if SERVER then 
		if CharacterCreator.RankToOpenAdmin[ply:GetUserGroup()] then  
			if IsValid(trace.Entity) and trace.Entity:IsPlayer() then 
				net.Start("CharacterCreator:MenuAdminOpen")
				net.WriteEntity(trace.Entity)
				net.Send(ply)
			end 
		end 
	end 
end 

function TOOL:RightClick(trace)
	local ply = self:GetOwner()
	if SERVER then
		if CharacterCreator.RankToOpenAdmin[ply:GetUserGroup()] then  
			if IsValid(ply) and ply:IsPlayer() then 
				net.Start("CharacterCreator:MenuAdminOpen")
				net.WriteEntity(ply)
				net.Send(ply)
			end 
		end 
	end 
end 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c24aa0f51c3521dc86ce13039a612ad6a262a16b758cd0bdb3462448d89950ac

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- c24aa0f51c3521dc86ce13039a612ad6a262a16b758cd0bdb3462448d89950ac
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199063103813
