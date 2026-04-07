-- Server-only network strings
util.AddNetworkString("sensors_open_panel")
util.AddNetworkString("sensors_sync_defs")
util.AddNetworkString("sensors_start_scan")
util.AddNetworkString("sensors_progress_update")
util.AddNetworkString("sensors_result_update")

-- Check for permission
function isValidUser(ply)
    return ply:IsUserGroup("gamemaster") or ply:IsUserGroup("superadmin")
end

-- Safe scan definitions stored server-side
local scanDefs = {}  -- Add definitions here

-- Net message for opening the console
net.Receive("sensors_open_panel", function(len, ply)
    if not isValidUser(ply) then return end
    -- Open console logic here
end)

-- Syncing scan definitions and results
net.Receive("sensors_sync_defs", function(len, ply)
    if not isValidUser(ply) then return end
    -- Sync definitions logic here
end)

-- Starting scans
net.Receive("sensors_start_scan", function(len, ply)
    if not isValidUser(ply) then return end
    local scanId = math.random(1, 10000)  -- Example scan ID
    timer.Simple(5, function()
        -- Scan logic and broadcast results
        net.Start("sensors_result_update")
        net.WriteString("Scan complete for ID: " .. scanId)
        net.Broadcast()
    end)
    -- Progress updates example
end)

-- Create a concommand for GM-only scan management
concommand.Add("sensor_scans_manage", function(ply)
    if not isValidUser(ply) then return end
    -- Open Derma UI for managing scans
end)