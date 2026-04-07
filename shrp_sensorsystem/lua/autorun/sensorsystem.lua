-- Register the network string for communication
util.AddNetworkString("sensor_scans_manage")

-- Server-only commands for managing scans
local scans = {}

-- GM-only console command to manage scans
concommand.Add("sensor_scans_manage", function(ply)
    -- Open the scanner console UI
    if IsValid(ply) then
        net.Start("sensor_console_ui")
        net.WriteTable(scans)
        net.Send(ply)
    end
end)

-- Function to start a scan
function StartScan(scanName)
    -- Code to trigger scan and store results
    -- Notify clients of scan progress
    for progress = 1, 5 do
        timer.Simple(progress, function()
            net.Start("sensor_scan_progress")
            net.WriteString(scanName)
            net.WriteInt(progress, 32)
            net.Broadcast()
        end)
    end

    -- Final results after 5 seconds
    timer.Simple(5, function()
        local result = "Scan Result for " .. scanName
        scans[scanName] = result
        net.Start("sensor_scan_result")
        net.WriteString(scanName)
        net.WriteString(result)
        net.Broadcast()
    end)
end

-- Example of triggering a scan
-- This would normally be called from the relevant entity or SWEP
StartScan("Default Scan")
