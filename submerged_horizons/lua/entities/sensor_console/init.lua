AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/azdesk/azdesk-nb.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end
    self:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    if not SHRPSensors or not SHRPSensors.GetRelayPercent then
        activator:ChatPrint("Sensor system is not ready.")
        return
    end

    if SHRPSensors.GetRelayPercent() < 1 then
        activator:ChatPrint("Sensor relays must be at least 1% functional to use this console.")
        return
    end

    net.Start("sensors_open_panel")
    net.Send(activator)
end
