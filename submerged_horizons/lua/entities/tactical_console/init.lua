AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/azdesk/azdesk.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end
    self:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    if not SHRPTactical or not SHRPTactical.GetWeaponsRelayPercent then
        activator:ChatPrint("Tactical system is not ready.")
        return
    end

    if SHRPTactical.GetWeaponsRelayPercent() < 1 then
        activator:ChatPrint("Weapons relays must be at least 1% functional to use this console.")
        return
    end

    net.Start("tactical_open_panel")
    net.Send(activator)
end
