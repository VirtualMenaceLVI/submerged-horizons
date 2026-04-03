AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/azdesk/azdesk-nb.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
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

    -- Check sensors relay power
    local relayPercent = 0
    if EngineeringSystems and EngineeringSystems.Sensors and EngineeringSystems.Sensors.enabled then
        local class = "relay_sensors"
        local relays = ents.FindByClass(class)
        if #relays > 0 then
            local totalHealth = 0
            local count = 0
            for _, ent in ipairs(relays) do
                if IsValid(ent) then
                    local health = ent:Health()
                    local maxHealth = ent.MaxHealth or 100
                    totalHealth = totalHealth + math.Clamp(health / maxHealth * 100, 0, 100)
                    count = count + 1
                end
            end
            if count > 0 then
                relayPercent = totalHealth / count
            end
        end
    end

    if relayPercent < 1 then
        activator:ChatPrint("Sensor relays must be at least 1% functional to use this console.")
        return
    end

    net.Start("sensors_open_panel")
    net.Send(activator)
end