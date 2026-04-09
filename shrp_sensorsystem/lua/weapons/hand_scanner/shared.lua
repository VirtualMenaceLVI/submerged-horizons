-- ─────────────────────────────────────────────────────────────────────────────
-- SHRP Hand Scanner  –  Star Trek-style tricorder
-- ─────────────────────────────────────────────────────────────────────────────
SWEP.PrintName      = "Hand Scanner"
SWEP.Author         = "SHRP"
SWEP.Category       = "SHRP"
SWEP.Spawnable      = true
SWEP.AdminOnly      = false

SWEP.Primary.ClipSize    = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic   = false
SWEP.Primary.Ammo        = "none"

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

SWEP.Weight          = 5
SWEP.AutoSwitchTo    = false
SWEP.AutoSwitchFrom  = false
SWEP.Slot            = 1
SWEP.SlotPos         = 2
SWEP.DrawAmmo        = false
SWEP.DrawCrosshair   = true

SWEP.ViewModel  = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_bugbait.mdl"

function SWEP:Initialize()
    self:SetHoldType("pistol")
end

-- ── Primary: begin scan ───────────────────────────────────────────────────────
function SWEP:PrimaryAttack()
    if CLIENT then return end

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    -- Relay power check
    if SHRPSensors and SHRPSensors.GetRelayPercent and SHRPSensors.GetRelayPercent() < 1 then
        ply:ChatPrint("Sensor relays offline – cannot scan.")
        return
    end

    -- Already scanning?
    if ply:GetNWBool("SHRPScanning", false) then
        ply:ChatPrint("Scan already in progress.")
        return
    end

    -- Trace to target
    local tr  = ply:GetEyeTrace()
    local ent = tr.Entity
    if not IsValid(ent) or tr.HitPos:Distance(ply:GetShootPos()) > 200 then
        ply:ChatPrint("No valid target in range.")
        return
    end

    local scanName = ent:GetNWString("ScanName", "")
    if scanName == "" then
        ply:ChatPrint("This object is not scannable.")
        return
    end

    -- Begin 5-second scan
    ply:SetNWBool("SHRPScanning", true)
    ply:EmitSound("buttons/button17.wav")
    self:SetNextPrimaryFire(CurTime() + 5.5)

    -- Tell client to show the progress bar
    net.Start("scanner_start_scan")
    net.WriteFloat(5)
    net.WriteString("hand")
    net.Send(ply)

    local timerName = "SHRPHandScan_" .. ply:SteamID()
    timer.Create(timerName, 5, 1, function()
        if not IsValid(ply) then return end
        ply:SetNWBool("SHRPScanning", false)

        if not IsValid(ent) then
            net.Start("scanner_cancel_scan")
            net.Send(ply)
            ply:ChatPrint("Scan failed: target no longer valid.")
            return
        end

        local result = ent:GetNWString("ScanResult", "No data available.")
        net.Start("scanner_scan_result")
        net.WriteString(ent:GetNWString("ScanName", scanName))
        net.WriteString(result)
        net.Send(ply)
    end)
end

-- ── Secondary: cancel scan ────────────────────────────────────────────────────
function SWEP:SecondaryAttack()
    if CLIENT then return end

    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    if not ply:GetNWBool("SHRPScanning", false) then return end

    ply:SetNWBool("SHRPScanning", false)
    timer.Remove("SHRPHandScan_" .. ply:SteamID())

    net.Start("scanner_cancel_scan")
    net.Send(ply)
    ply:ChatPrint("Scan cancelled.")
end

-- ── Clean up if weapon is dropped / owner disconnects ────────────────────────
function SWEP:OnRemove()
    if SERVER then
        local ply = self:GetOwner()
        if IsValid(ply) then
            ply:SetNWBool("SHRPScanning", false)
            timer.Remove("SHRPHandScan_" .. ply:SteamID())
        end
    end
end