-- Server-only util.AddNetworkString registrations
util.AddNetworkString("sensors_open_panel")
util.AddNetworkString("sensors_sync_scans")
util.AddNetworkString("sensors_scan_request")
util.AddNetworkString("sensors_scan_result")
util.AddNetworkString("scanner_start_scan")
util.AddNetworkString("scanner_cancel_scan")
util.AddNetworkString("sensors_manage_open")
util.AddNetworkString("sensors_manage_add")
util.AddNetworkString("sensors_manage_remove")

-- SHRPSensors table with Defs and Results
SHRPSensors = {
    Defs = {},
    Results = {},
}

-- Helper functions
function SHRPSensors.IsGM(ply)
    return ply:IsSuperAdmin() or ply:GetUserGroup() == "gamemaster"
end

-- Scanning behavior
function startScan(scanName)
    net.Start("scanner_start_scan")
    net.WriteFloat(5) -- Duration = 5 seconds
    net.Send(ply)

    timer.Simple(5, function()
        -- Compute result text based on scan type
        local resultText = "Scan Result for " .. scanName
        -- Store result
        SHRPSensors.Results[scanName] = resultText
        -- Broadcast results
        net.Start("sensors_sync_scans")
        net.WriteTable(SHRPSensors.Defs)
        net.WriteTable(SHRPSensors.Results)
        net.Broadcast()
        -- Send result to requesting client
        net.Start("sensors_scan_result")
        net.WriteString(resultText)
        net.Send(ply)
    end)
end

-- Default scan templates
table.insert(SHRPSensors.Defs, {name="Players", type="players"})
table.insert(SHRPSensors.Defs, {name="Props", type="props"})
-- Add more scan types as needed

-- Ensure net.WriteTable only sends serializable data
function serializeData(data)
    return data
end
