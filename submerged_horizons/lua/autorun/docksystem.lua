-- Dock / Undock command system
-- /undock  – teleports the player's vehicle (and the seated player) to the undock position
-- /dock    – teleports the player to the dock position with the specified angle

if not SERVER then return end

local DOCK_POS   = Vector(-9931.525391, 12375.989258, -1969.734253)
local DOCK_ANG   = Angle(359.854126, 359.777832, 0.000000)
local UNDOCK_POS = Vector(-11454.078, -4860.151, 4757.668)

hook.Add("PlayerSay", "SHRPDockCommands", function(ply, text)
    local cmd = string.lower(string.Trim(text))

    if cmd == "/dock" then
        ply:SetPos(DOCK_POS)
        ply:SetEyeAngles(DOCK_ANG)
        ply:ChatPrint("[DOCK] Teleported to dock.")
        return ""
    end

    if cmd == "/undock" then
        local vehicle = ply:GetVehicle()
        if not IsValid(vehicle) then
            ply:ChatPrint("[UNDOCK] You must be inside a vehicle to undock.")
            return ""
        end

        vehicle:SetPos(UNDOCK_POS)
        ply:ChatPrint("[UNDOCK] Teleported to undock position.")
        return ""
    end
end)
