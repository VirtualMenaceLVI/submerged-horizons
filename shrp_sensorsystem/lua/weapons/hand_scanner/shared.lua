SWEP.PrintName = "Hand Scanner"
SWEP.Author = "SHRP"
SWEP.Category = "SHRP"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_bugbait.mdl"

function SWEP:Initialize()
    self:SetHoldType("pistol")
end

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

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
        ply:ChatPrint("Sensor relays must be at least 1% functional to use this scanner.")
        return
    end

    local tr = ply:GetEyeTrace()
    local ent = tr.Entity
    if not IsValid(ent) or tr.HitPos:Distance(ply:GetShootPos()) > 100 then
        ply:ChatPrint("No valid target in range.")
        return
    end

    local scanName = ent:GetNWString("ScanName", "")
    if scanName == "" then
        ply:ChatPrint("This object is not scannable.")
        return
    end

    ply:ChatPrint("Scanning " .. scanName .. "...")
    ply:EmitSound("buttons/button17.wav")
    ply:Freeze(true)
    ply:SetNWBool("Scanning", true)
    self:SetNextPrimaryFire(CurTime() + 5)
    net.Start("scanner_start_scan")
    net.WriteFloat(5)
    net.Send(ply)

    timer.Simple(5, function()
        if IsValid(ply) and ply:GetNWBool("Scanning", false) and IsValid(ent) then
            ply:Freeze(false)
            ply:SetNWBool("Scanning", false)
            ply:SetNWFloat("scanEndTime", 0)
            local result = ent:GetNWString("ScanResult", "No data.")
            ply:ChatPrint("Scan Result: " .. result)
        elseif IsValid(ply) then
            ply:Freeze(false)
            ply:SetNWBool("Scanning", false)
            ply:SetNWFloat("scanEndTime", 0)
            ply:ChatPrint("Scan failed: Target no longer valid.")
        end
    end)
end

function SWEP:SecondaryAttack()
    if CLIENT then return end

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    -- Cancel scan if in progress
    if ply:GetNWBool("Scanning", false) then
        ply:SetNWBool("Scanning", false)
        ply:SetNWFloat("scanEndTime", 0)
        ply:Freeze(false)
        ply:ChatPrint("Scan cancelled.")
        net.Start("scanner_cancel_scan")
        net.Send(ply)
    end
end