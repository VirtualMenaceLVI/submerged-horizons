/*
    Addon id: 6caa0056-2e1c-4a99-9ba2-8bb2fe3a0232
    Version: v1.5.7 (stable)
*/

function CharacterCreator.SaveEntity()
    if not file.Exists("charactercreator", "DATA") then
        file.CreateDir("charactercreator") 
    end
    local data = {} 
    for u, ent in pairs(ents.FindByClass("character_creator_menuopen")) do
        table.insert(data, {
            GetClass = ent:GetClass(),          
            GetPos = ent:GetPos(),      
            GetAngle = ent:GetAngles()  
        })
        file.Write("charactercreator/" .. game.GetMap() .. "_chc_entities" .. ".txt", util.TableToJSON(data))    
    end
end 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199063103813

function CharacterCreator.Load()
    local directory = "charactercreator/" .. game.GetMap() .. "_chc_entities" .. ".txt" 
    if file.Exists(directory, "DATA") then  
        local data = file.Read(directory, "DATA")
        data = util.JSONToTable(data)   
        for k, GetClass in pairs(data) do
            local chc_entity = ents.Create(GetClass.GetClass)
            chc_entity:SetPos(GetClass.GetPos)  
            chc_entity:SetAngles(GetClass.GetAngle) 
            chc_entity:Spawn()            
            local chc_entityload = chc_entity:GetPhysicsObject()
            if (chc_entityload:IsValid()) then  
                chc_entityload:Wake()   
                chc_entityload:EnableMotion(false)              
            end
        end
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a45b4a0371527980aa45a614f82b3b1b5c437fbaab42e40b73e1d1d0309ff781
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a45b4a0371527980aa45a614f82b3b1b5c437fbaab42e40b73e1d1d0309ff781

concommand.Add("chc_save", function(ply, cmd, args)
    if ply:IsSuperAdmin() then
        CharacterCreator.SaveEntity()  
    end  
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e7470ef06f6b9f4cb7eb859aac9e04a5e1ab282313d4b3d8c10765ed2d3173a9

concommand.Add("chc_cleaupentities", function(ply, cmd, args) 
    if ply:IsSuperAdmin() then
        for u, ent in pairs(ents.FindByClass("character_creator_menuopen")) do
            ent:Remove() 
        end
    end
end )

concommand.Add("chc_removedata", function(ply, cmd, args)
    if ply:IsSuperAdmin() then
        if file.Exists("charactercreator/" .. game.GetMap() .. "_chc_entities" .. ".txt", "DATA") then 
            file.Delete( "charactercreator/" .. game.GetMap() .. "_chc_entities" .. ".txt" )
            concommand.Run(ply,"chc_cleaupentities")
        end  
    end  
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d90b40d7d178e5adda34201e534657c97e623b5b60bb31ab0498b85eaf4bace5

concommand.Add("chc_reloadentities", function(ply, cmd, args) 
    if ply:IsSuperAdmin() then
        concommand.Run(ply,"chc_cleaupentities")
        CharacterCreator.Load()
    end 
end )

hook.Add("InitPostEntity", "CharacterCreatorInit", CharacterCreator.Load)
hook.Add("PostCleanupMap", "CharacterCreatorLoad", CharacterCreator.Load)
