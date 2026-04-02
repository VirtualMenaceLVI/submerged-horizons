ENT.Type = ENT.Type or "anim"
ENT.Base = ENT.Base or "base_gmodentity"
ENT.Spawnable = ENT.Spawnable or false
ENT.AdminOnly = ENT.AdminOnly or false
ENT.RenderGroup = ENT.RenderGroup or RENDERGROUP_OPAQUE
ENT.AutomaticFrameAdvance = ENT.AutomaticFrameAdvance or true
ENT.MaxHealth = ENT.MaxHealth or 100
ENT.RepairDuration = ENT.RepairDuration or 5
ENT.RepairRange = ENT.RepairRange or 100

local function IsRepairTool(wep)
    if not IsValid(wep) then
        return false
    end

    local class = wep:GetClass() or ""
    return string.find(class, "tricorder") ~= nil
end

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props/console_control_round.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(true)
        self:SetUseType(SIMPLE_USE)
        self:SetHealth(self.MaxHealth)
        self:SetNWInt("RelayHealth", self:Health())
        self:SetNWString("RelaySystem", self.RelaySystem or "UNKNOWN")
        self:SetNWBool("RelayDamaged", false)
        self.RepairingPlayer = nil
        self.RepairStartTime = nil
        self.RepairEndTime = nil
    end

    function ENT:IsDamaged()
        return self:Health() < self.MaxHealth
    end

    function ENT:OnTakeDamage(dmg)
        local newHealth = math.max(self:Health() - dmg:GetDamage(), 0)
        self:SetHealth(newHealth)
        self:SetNWInt("RelayHealth", newHealth)
        self:SetNWBool("RelayDamaged", self:IsDamaged())

        if self:IsDamaged() then
            self:SetColor(Color(180, 90, 90))
        end
    end

    function ENT:Repair()
        self:SetHealth(self.MaxHealth)
        self:SetNWInt("RelayHealth", self.MaxHealth)
        self:SetNWBool("RelayDamaged", false)
        self:SetColor(Color(255, 255, 255))
    end

    function ENT:Use(activator)
        if not IsValid(activator) or not activator:IsPlayer() then return end
        if not activator:Alive() then return end

        if not self:IsDamaged() then
            activator:ChatPrint("Relay is already functional.")
            return
        end

        net.Start("relay_repair_open")
        net.WriteEntity(self)
        net.WriteString(self.RelaySystem or "UNKNOWN")
        net.Send(activator)
    end
else
    function ENT:Draw()
        self:DrawModel()

        local ang = self:GetAngles()
        ang:RotateAroundAxis(ang:Up(), 90)
        ang:RotateAroundAxis(ang:Forward(), 90)

        local pos = self:GetPos() + self:GetUp() * 12 + self:GetForward() * 8
        local health = self:GetNWInt("RelayHealth", 100)
        local damaged = self:GetNWBool("RelayDamaged", false)
        local title = self.RelaySystem and self.RelaySystem .. " Relay" or "Power Relay"
        local color = damaged and Color(255, 150, 150) or Color(120, 255, 140)

        cam.Start3D2D(pos, ang, 0.08)
            draw.RoundedBox(8, -90, -45, 180, 90, Color(10, 20, 36, 230))
            draw.SimpleText(title, "DermaLarge", 0, -24, Color(160, 220, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Health: " .. health .. "%", "DermaDefaultBold", 0, 4, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(damaged and "Damaged" or "Online", "DermaDefault", 0, 26, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end
