AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props/bridge/bridge_captainschair.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end
    self:SetUseType(SIMPLE_USE)
    self.SeatedPlayer = nil
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    if IsValid(self.SeatedPlayer) then
        if self.SeatedPlayer == activator then
            -- Seated player pressed E again — unseat them.
            self.SeatedPlayer = nil
            net.Start("captain_chair_exit")
            net.Send(activator)
        else
            activator:ChatPrint("The captain's chair is already occupied.")
        end
        return
    end

    -- Seat the activator.
    self.SeatedPlayer = activator
    net.Start("captain_chair_enter")
    net.WriteEntity(self)
    net.Send(activator)
end

function ENT:OnRemove()
    if IsValid(self.SeatedPlayer) then
        net.Start("captain_chair_exit")
        net.Send(self.SeatedPlayer)
        self.SeatedPlayer = nil
    end
end
