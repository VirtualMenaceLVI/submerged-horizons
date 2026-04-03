if SERVER then
    AddCSLuaFile()
end

if SERVER then
    util.AddNetworkString("sensors_open_panel")
    util.AddNetworkString("sensors_scan_request")
    util.AddNetworkString("sensors_scan_result")
    util.AddNetworkString("sensors_sync_scans")
    util.AddNetworkString("sensors_add_scan")
    util.AddNetworkString("sensors_remove_scan")
    util.AddNetworkString("sensors_open_set_scan")
    util.AddNetworkString("sensors_set_scan")
    util.AddNetworkString("scanner_start_scan")
    util.AddNetworkString("scanner_cancel_scan")
end

SHRPSensors = SHRPSensors or {}
SHRPSensors.Scans = SHRPSensors.Scans or {
    ["Players"] = function()
        local players = {}
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                table.insert(players, ply:Nick() .. " at " .. tostring(ply:GetPos()))
            end
        end
        return table.concat(players, "\n")
    end,
    ["Props"] = function()
        local props = {}
        for _, ent in ipairs(ents.GetAll()) do
            if IsValid(ent) and ent:GetClass() == "prop_physics" then
                table.insert(props, ent:GetModel() .. " at " .. tostring(ent:GetPos()))
            end
        end
        return table.concat(props, "\n")
    end
}

function SHRPSensors.GetScanResult(scanName)
    local scanFunc = SHRPSensors.Scans[scanName]
    if scanFunc then
        return scanFunc()
    end
    return "Scan not found."
end

if SERVER then
    net.Receive("sensors_scan_request", function(len, ply)
        local scanName = net.ReadString()
        local result = SHRPSensors.GetScanResult(scanName)
        net.Start("sensors_scan_result")
        net.WriteString(result)
        net.Send(ply)
    end)

    net.Receive("sensors_add_scan", function(len, ply)
        local name = net.ReadString()
        local code = net.ReadString()
        if name and name ~= "" and code then
            local func = CompileString("return " .. code, "scan_func", false)
            if func then
                SHRPSensors.Scans[name] = func
                net.Start("sensors_sync_scans")
                net.WriteTable(SHRPSensors.Scans)
                net.Broadcast()
            end
        end
    end)

    net.Receive("sensors_remove_scan", function(len, ply)
        local name = net.ReadString()
        if SHRPSensors.Scans[name] then
            SHRPSensors.Scans[name] = nil
            net.Start("sensors_sync_scans")
            net.WriteTable(SHRPSensors.Scans)
            net.Broadcast()
        end
    end)

    net.Receive("sensors_set_scan", function(len, ply)
        local ent = net.ReadEntity()
        local name = net.ReadString()
        local result = net.ReadString()
        if IsValid(ent) then
            ent:SetNWString("ScanName", name)
            ent:SetNWString("ScanResult", result)
        end
    end)

    hook.Add("PlayerInitialSpawn", "SHRPSensorsSync", function(ply)
        net.Start("sensors_sync_scans")
        net.WriteTable(SHRPSensors.Scans)
        net.Send(ply)
    end)
end

if CLIENT then
    util.AddNetworkString("sensors_open_panel")
    util.AddNetworkString("sensors_scan_request")
    util.AddNetworkString("sensors_scan_result")
    util.AddNetworkString("sensors_sync_scans")
    util.AddNetworkString("sensors_add_scan")
    util.AddNetworkString("sensors_remove_scan")
    util.AddNetworkString("sensors_open_set_scan")
    util.AddNetworkString("sensors_set_scan")
    util.AddNetworkString("scanner_start_scan")
    util.AddNetworkString("scanner_cancel_scan")

    SHRPSensors.Scans = SHRPSensors.Scans or {}
    local currentReadout = nil
    local scanEndTime = 0

    net.Receive("sensors_sync_scans", function()
        SHRPSensors.Scans = net.ReadTable()
    end)

    net.Receive("scanner_start_scan", function()
        scanEndTime = CurTime() + net.ReadFloat()
    end)

    net.Receive("scanner_cancel_scan", function()
        scanEndTime = 0
    end)

    net.Receive("sensors_open_panel", function()
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Sensor Console")
        frame:SetSize(600, 400)
        frame:Center()
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)

        local scanList = vgui.Create("DListView", frame)
        scanList:SetSize(200, 350)
        scanList:SetPos(10, 40)
        scanList:AddColumn("Available Scans")

        for name, _ in pairs(SHRPSensors.Scans) do
            scanList:AddLine(name)
        end

        local readout = vgui.Create("DTextEntry", frame)
        readout:SetSize(350, 350)
        readout:SetPos(220, 40)
        readout:SetMultiline(true)
        readout:SetEditable(false)
        readout:SetText("Select a scan to begin.")
        currentReadout = readout

        local scanBtn = vgui.Create("DButton", frame)
        scanBtn:SetPos(10, 360)
        scanBtn:SetSize(200, 30)
        scanBtn:SetText("Scan Selected")
        scanBtn.DoClick = function()
            local line = scanList:GetSelectedLine()
            if line then
                local name = scanList:GetLine(line):GetValue(1)
                readout:SetText("Scanning...")
                surface.PlaySound("ambient/levels/labs/electric_explosion1.wav")
                local progress = vgui.Create("DProgress", frame)
                progress:SetPos(10, 330)
                progress:SetSize(200, 20)
                progress:SetFraction(0)
                local startTime = CurTime()
                local function updateProgress()
                    local frac = (CurTime() - startTime) / 2
                    if frac >= 1 then
                        progress:Remove()
                        net.Start("sensors_scan_request")
                        net.WriteString(name)
                        net.SendToServer()
                    else
                        progress:SetFraction(frac)
                        timer.Simple(0.1, updateProgress)
                    end
                end
                updateProgress()
            end
        end
    end)

    net.Receive("sensors_scan_result", function()
        local result = net.ReadString()
        if IsValid(currentReadout) then
            currentReadout:SetText(result)
        end
    end)

    net.Receive("sensors_open_set_scan", function()
        local ent = net.ReadEntity()
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Set Scan Properties")
        frame:SetSize(300, 200)
        frame:Center()
        frame:MakePopup()

        local nameEntry = vgui.Create("DTextEntry", frame)
        nameEntry:SetPos(10, 40)
        nameEntry:SetSize(280, 20)
        nameEntry:SetPlaceholderText("Scan Name")
        nameEntry:SetValue(ent:GetNWString("ScanName", ""))

        local resultEntry = vgui.Create("DTextEntry", frame)
        resultEntry:SetPos(10, 70)
        resultEntry:SetSize(280, 80)
        resultEntry:SetMultiline(true)
        resultEntry:SetPlaceholderText("Scan Result")
        resultEntry:SetValue(ent:GetNWString("ScanResult", ""))

        local saveBtn = vgui.Create("DButton", frame)
        saveBtn:SetPos(10, 160)
        saveBtn:SetSize(280, 30)
        saveBtn:SetText("Save")
        saveBtn.DoClick = function()
            net.Start("sensors_set_scan")
            net.WriteEntity(ent)
            net.WriteString(nameEntry:GetValue())
            net.WriteString(resultEntry:GetValue())
            net.SendToServer()
            frame:Close()
        end
    end)

    concommand.Add("sensors_manage", function()
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Manage Scans")
        frame:SetSize(400, 300)
        frame:Center()
        frame:MakePopup()

        local list = vgui.Create("DListView", frame)
        list:SetSize(380, 200)
        list:SetPos(10, 40)
        list:AddColumn("Scan Name")

        for name, _ in pairs(SHRPSensors.Scans) do
            list:AddLine(name)
        end

        local addBtn = vgui.Create("DButton", frame)
        addBtn:SetPos(10, 250)
        addBtn:SetSize(120, 30)
        addBtn:SetText("Add Scan")
        addBtn.DoClick = function()
            local addFrame = vgui.Create("DFrame")
            addFrame:SetTitle("Add Scan")
            addFrame:SetSize(300, 200)
            addFrame:Center()
            addFrame:MakePopup()

            local nameEntry = vgui.Create("DTextEntry", addFrame)
            nameEntry:SetPos(10, 40)
            nameEntry:SetSize(280, 20)
            nameEntry:SetPlaceholderText("Scan Name")

            local codeEntry = vgui.Create("DTextEntry", addFrame)
            codeEntry:SetPos(10, 70)
            codeEntry:SetSize(280, 80)
            codeEntry:SetMultiline(true)
            codeEntry:SetPlaceholderText("Lua function code, e.g., function() return 'Result' end")

            local saveBtn = vgui.Create("DButton", addFrame)
            saveBtn:SetPos(10, 160)
            saveBtn:SetSize(280, 30)
            saveBtn:SetText("Save")
            saveBtn.DoClick = function()
                local name = nameEntry:GetValue()
                local code = codeEntry:GetValue()
                if name and code then
                    net.Start("sensors_add_scan")
                    net.WriteString(name)
                    net.WriteString(code)
                    net.SendToServer()
                    list:AddLine(name)
                    addFrame:Close()
                end
            end
        end

        local removeBtn = vgui.Create("DButton", frame)
        removeBtn:SetPos(140, 250)
        removeBtn:SetSize(120, 30)
        removeBtn:SetText("Remove Selected")
        removeBtn.DoClick = function()
            local line = list:GetSelectedLine()
            if line then
                local name = list:GetLine(line):GetValue(1)
                net.Start("sensors_remove_scan")
                net.WriteString(name)
                net.SendToServer()
                list:RemoveLine(line)
            end
        end
    end)

    hook.Add("HUDPaint", "SHRPSensorsHUD", function()
        if scanEndTime > 0 and scanEndTime > CurTime() then
            local frac = 1 - ((scanEndTime - CurTime()) / 5)
            draw.RoundedBox(8, ScrW() / 2 - 150, ScrH() - 100, 300, 40, Color(0, 0, 0, 200))
            draw.RoundedBox(8, ScrW() / 2 - 145, ScrH() - 95, 290 * frac, 30, Color(0, 255, 0, 200))
            draw.SimpleText("Scanning...", "DermaDefaultBold", ScrW() / 2, ScrH() - 80, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end)
end
