/*
    Addon id: 6caa0056-2e1c-4a99-9ba2-8bb2fe3a0232
    Version: v1.5.7 (stable)
*/

AddCSLuaFile()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a45b4a0371527980aa45a614f82b3b1b5c437fbaab42e40b73e1d1d0309ff781

TOOL.Category = "Character Creator"
TOOL.Name = "Chc-Configuration"
TOOL.Author = "Kobralost"

if CLIENT then
	language.Add("tool.character_creator_tools.desc", "Npc Generator - Character Creator" )
	language.Add("tool.character_creator_tools.0", "Left-Click to place Npc" )
	language.Add("tool.character_creator_tools.name", "Character-Creator")
end

function TOOL:RightClick(trace)
	local ply = self:GetOwner()
	if SERVER then
		if self:GetOwner():IsSuperAdmin() then
			if (trace.Entity:GetClass() == "character_creator_menuopen" ) then 
				trace.Entity:Remove() 
			end 
		end 
	end 
end  

function TOOL:LeftClick(trace)
	local ply = self:GetOwner()
	if SERVER then
		timer.Create("chc_antispam_leftclick", 0.00000001, 1, function()
			if not IsValid( ply ) && not ply:IsPlayer() then return end  
			local trace = ply:GetEyeTrace()
			local position = trace.HitPos
			local angle = ply:GetAngles()
			local team = ply:GetUserGroup()
			if ply:IsSuperAdmin() then
				chc_createent = ents.Create( "character_creator_menuopen" )
				chc_createent:SetPos(position + Vector(0, 0, 0))
				chc_createent:SetAngles(Angle(0,angle.Yaw+180, 0))
				chc_createent:Spawn()
				chc_createent:Activate() 			
			end
		end)
	end
end 

function TOOL.BuildCPanel( CPanel )
	CPanel:AddControl("label", {
	Text = "Save Character Creator Entities" })
	CPanel:Button("Save Entities", "chc_save")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199063103813

	CPanel:AddControl("label", {
	Text = "Remove all Entities in The Data" })
	CPanel:Button("Remove Entities Data", "chc_removedata")

	CPanel:AddControl("label", {
	Text = "Remove all Entities in The Map" })
	CPanel:Button("Remove Entities Map", "chc_cleaupentities")

	CPanel:AddControl("label", {
	Text = "Reload all Entities in The Map" })
	CPanel:Button("Reload Entities Map", "chc_reloadentities")
end

function TOOL:CreateRWCEnt()
	if CLIENT then
		if IsValid(self.CHCEnt) then else
 			self.CHCEnt = ClientsideModel("models/player/Group01/male_01.mdl", RENDERGROUP_OPAQUE)
			self.CHCEnt:SetModel("models/player/Group01/male_01.mdl")
			self.CHCEnt:SetMaterial("models/wireframe")
			self.CHCEnt:SetPos(Vector(0,0,0))
			self.CHCEnt:SetAngles(Angle(0,0,0))
			self.CHCEnt:Spawn()
			self.CHCEnt:Activate()	
			self.CHCEnt.Ang = Angle(0,0,0)
			self.CHCEnt:SetRenderMode(RENDERMODE_TRANSALPHA)
			self.CHCEnt:SetColor(Color( 255, 255, 255, 150))
		end
	end 
end

function TOOL:Think() 
	if IsValid(self.CHCEnt) then
		ply = self:GetOwner()
		trace = util.TraceLine(util.GetPlayerTrace(ply))
		ang = ply:GetAimVector():Angle() 
		Pos = Vector(trace.HitPos.X, trace.HitPos.Y, trace.HitPos.Z)
		Ang = Angle(0, ang.Yaw+180, 0) + self.CHCEnt.Ang
		self.CHCEnt:SetPos(Pos)
		self.CHCEnt:SetAngles(Ang)
	else 
		self:CreateRWCEnt() 
	end 
end 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199063103813
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199063103813

function TOOL:Holster()
	if IsValid(self.CHCEnt) then  
		self.CHCEnt:Remove()
	end 
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d90b40d7d178e5adda34201e534657c97e623b5b60bb31ab0498b85eaf4bace5
