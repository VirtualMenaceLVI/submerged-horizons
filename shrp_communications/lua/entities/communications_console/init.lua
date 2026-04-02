AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/reciever01b.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
    self:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then
        return
    end

    if not SHRPComms or not SHRPComms.GetCommunicationsRelayPercent then
        activator:ChatPrint("Communications system is not ready.")
        return
    end

    if SHRPComms.GetCommunicationsRelayPercent() < 25 then
        activator:ChatPrint("Communications relays must be at least 25% to use this console.")
        return
    end

    local activeCall = SHRPComms.CallByPlayer[activator:SteamID()]
    if activeCall then
        if activeCall.type == "all" and activeCall.initiator ~= activator then
            activator:ChatPrint("Only the hail initiator can end this intercom.")
            return
        end

        SHRPComms.EndCall(activeCall)
        return
    end

    local pending = SHRPComms.PendingHails[activator:SteamID()]
    if pending then
        SHRPComms.AcceptPendingHail(activator)
        return
    end

    net.Start("comms_open_panel")
    net.Send(activator)
end
