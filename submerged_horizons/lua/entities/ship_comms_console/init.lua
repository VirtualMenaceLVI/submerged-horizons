AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/hunter/plates/plate05x075.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end
    self:SetUseType(SIMPLE_USE)
    self.BridgeRange = 1000 -- configurable range for bridge area
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
        if activeCall.type == "ship" and activeCall.initiator ~= activator then
            activator:ChatPrint("Only the hail initiator can end this ship-to-ship call.")
            return
        end

        SHRPComms.EndCall(activeCall)
        return
    end

    net.Start("comms_open_ship_panel")
    net.Send(activator)
end