if SERVER then
    util.AddNetworkString("sensors_open_panel")
    util.AddNetworkString("sensors_open_manage")
    util.AddNetworkString("sensors_sync_entries")
    util.AddNetworkString("sensors_scan_request")
    util.AddNetworkString("sensors_scan_result")
    util.AddNetworkString("sensors_manage_add")
    util.AddNetworkString("sensors_manage_edit")
    util.AddNetworkString("sensors_manage_remove")
    util.AddNetworkString("scanner_start_scan")
    util.AddNetworkString("scanner_scan_result")
    util.AddNetworkString("scanner_cancel_scan")
    util.AddNetworkString("sensors_set_scannable")
end

SHRPSensors           = SHRPSensors or {}
SHRPSensors.Entries   = SHRPSensors.Entries   or {}
SHRPSensors.NextID    = SHRPSensors.NextID    or 0

function SHRPSensors.IsGM(ply)
    return IsValid(ply) and ply:IsPlayer() and
        (ply:IsSuperAdmin() or ply:GetUserGroup() == "gamemaster")
end

function SHRPSensors.GetRelayPercent()
    local relays = ents.FindByClass("relay_sensors")
    if #relays == 0 then return 0 end
    local total, count = 0, 0
    for _, ent in ipairs(relays) do
        if IsValid(ent) then
            local maxHP = ent.MaxHealth or 100
            total = total + math.Clamp(ent:Health() / maxHP * 100, 0, 100)
            count = count + 1
        end
    end
    return count > 0 and (total / count) or 0
end

-- ─────────────────────────────────────────────────────────────────────────────
-- SERVER
-- ─────────────────────────────────────────────────────────────────────────────
if SERVER then
    local function SyncEntries(target)
        net.Start("sensors_sync_entries")
        net.WriteTable(SHRPSensors.Entries)
        if target then
            net.Send(target)
        else
            net.Broadcast()
        end
    end

    -- Add entry (GM only)
    net.Receive("sensors_manage_add", function(_, ply)
        if not SHRPSensors.IsGM(ply) then return end
        local name   = net.ReadString()
        local result = net.ReadString()
        if name == "" then return end
        SHRPSensors.NextID = SHRPSensors.NextID + 1
        table.insert(SHRPSensors.Entries, {
            id     = SHRPSensors.NextID,
            name   = name,
            result = result,
        })
        SyncEntries()
    end)

    -- Edit entry (GM only)
    net.Receive("sensors_manage_edit", function(_, ply)
        if not SHRPSensors.IsGM(ply) then return end
        local id     = net.ReadUInt(16)
        local name   = net.ReadString()
        local result = net.ReadString()
        if name == "" then return end
        for _, entry in ipairs(SHRPSensors.Entries) do
            if entry.id == id then
                entry.name   = name
                entry.result = result
                break
            end
        end
        SyncEntries()
    end)

    -- Remove entry (GM only)
    net.Receive("sensors_manage_remove", function(_, ply)
        if not SHRPSensors.IsGM(ply) then return end
        local id = net.ReadUInt(16)
        for i, entry in ipairs(SHRPSensors.Entries) do
            if entry.id == id then
                table.remove(SHRPSensors.Entries, i)
                break
            end
        end
        SyncEntries()
    end)

    -- Panel scan request: 5-second timer then send result
    net.Receive("sensors_scan_request", function(_, ply)
        if not IsValid(ply) then return end
        if SHRPSensors.GetRelayPercent() < 1 then
            ply:ChatPrint("Sensor relays offline.")
            return
        end

        local id = net.ReadUInt(16)
        local entry
        for _, e in ipairs(SHRPSensors.Entries) do
            if e.id == id then entry = e break end
        end
        if not entry then return end

        -- Cancel any existing scan for this player
        local timerName = "SHRPPanelScan_" .. ply:SteamID()
        timer.Remove(timerName)

        -- Tell client to start the progress bar
        net.Start("scanner_start_scan")
        net.WriteFloat(5)
        net.WriteString("panel")
        net.Send(ply)

        timer.Create(timerName, 5, 1, function()
            if not IsValid(ply) then return end
            net.Start("sensors_scan_result")
            net.WriteUInt(id, 16)
            net.WriteString(entry.name)
            net.WriteString(entry.result)
            net.Send(ply)
        end)
    end)

    -- GM scanner tool: tag any entity as scannable
    net.Receive("sensors_set_scannable", function(_, ply)
        if not SHRPSensors.IsGM(ply) then return end
        local ent    = net.ReadEntity()
        local name   = net.ReadString()
        local result = net.ReadString()
        if not IsValid(ent) then return end
        ent:SetNWString("ScanName",   name)
        ent:SetNWString("ScanResult", result)
        ply:ChatPrint("Marked '" .. tostring(ent:GetClass()) .. "' as scannable: " .. name)
    end)

    -- GM console command: open the sensor management panel
    concommand.Add("shrp_gm_sensors_manage", function(ply)
        if not SHRPSensors.IsGM(ply) then
            ply:ChatPrint("[Sensors] You must be a Game Master to use this command.")
            return
        end
        net.Start("sensors_open_manage")
        net.Send(ply)
    end)

    -- Sync entries to each freshly spawned player
    hook.Add("PlayerInitialSpawn", "SHRPSensorsSyncOnJoin", function(ply)
        timer.Simple(1, function()
            if IsValid(ply) then SyncEntries(ply) end
        end)
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- CLIENT
-- ─────────────────────────────────────────────────────────────────────────────
if CLIENT then
    SHRPSensors.Entries = SHRPSensors.Entries or {}

    -- Per-client scan state
    local scanBar   = nil  -- {startTime, duration} – drives the HUD progress bar
    local panelCbs  = {}   -- callbacks registered by an open panel

    -- ── Sync entries ──────────────────────────────────────────────────────────
    net.Receive("sensors_sync_entries", function()
        SHRPSensors.Entries = net.ReadTable()
        for _, cb in ipairs(panelCbs) do
            if type(cb) == "function" then pcall(cb) end
        end
    end)

    -- ── Progress bar ──────────────────────────────────────────────────────────
    net.Receive("scanner_start_scan", function()
        local dur      = net.ReadFloat()
        local scanType = net.ReadString()
        scanBar = {startTime = CurTime(), duration = dur, scanType = scanType}
    end)

    net.Receive("scanner_cancel_scan", function()
        scanBar = nil
    end)

    hook.Add("HUDPaint", "SHRPSensorsScanBar", function()
        if not scanBar then return end
        local frac = math.Clamp((CurTime() - scanBar.startTime) / scanBar.duration, 0, 1)
        if frac >= 1 then scanBar = nil return end

        local sw, sh = ScrW(), ScrH()
        local bw, bh = 320, 24
        local bx, by = (sw - bw) * 0.5, sh - 90

        draw.RoundedBox(6, bx - 2, by - 2, bw + 4, bh + 4, Color(0, 0, 0, 180))
        draw.RoundedBox(6, bx, by, bw, bh, Color(10, 22, 36, 210))
        draw.RoundedBox(6, bx, by, bw * frac, bh, Color(20, 145, 220, 225))
        draw.SimpleText(
            "SCANNING  " .. math.floor(frac * 100) .. "%",
            "DermaDefaultBold", sw * 0.5, by + bh * 0.5,
            Color(200, 235, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
        )
    end)

    -- ── Panel scan result ─────────────────────────────────────────────────────
    net.Receive("sensors_scan_result", function()
        local id     = net.ReadUInt(16)
        local name   = net.ReadString()
        local result = net.ReadString()
        scanBar = nil
        if SHRPSensors.OnPanelScanResult then
            SHRPSensors.OnPanelScanResult(id, name, result)
        end
    end)

    -- ── Hand-scanner result ───────────────────────────────────────────────────
    net.Receive("scanner_scan_result", function()
        local name   = net.ReadString()
        local result = net.ReadString()
        scanBar = nil
        SHRPSensors.ShowScanResult(name, result)
    end)

    -- ── Open panel (from console Use) ─────────────────────────────────────────
    net.Receive("sensors_open_panel", function()
        SHRPSensors.OpenSensorPanel()
    end)

    -- ── Open management panel (from shrp_gm_sensors_manage command) ──────────
    net.Receive("sensors_open_manage", function()
        SHRPSensors.OpenManagePanel()
    end)

    -- ─────────────────────────────────────────────────────────────────────────
    -- Hand-scanner result popup
    -- ─────────────────────────────────────────────────────────────────────────
    function SHRPSensors.ShowScanResult(name, result)
        local frame = vgui.Create("DFrame")
        frame:SetTitle("")
        frame:SetSize(400, 300)
        frame:SetPos(ScrW() - 420, ScrH() * 0.5 - 150)
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)

        frame.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, Color(8, 16, 26, 252))
            draw.RoundedBox(10, 0, 0, w, 38, Color(0, 155, 90, 220))
            draw.SimpleText(
                "TRICORDER SCAN RESULT",
                "DermaDefaultBold", w * 0.5, 19,
                Color(180, 255, 215), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
        end

        local lName = vgui.Create("DLabel", frame)
        lName:SetPos(14, 46)
        lName:SetSize(372, 22)
        lName:SetText("Target:  " .. name)
        lName:SetTextColor(Color(90, 210, 255))
        lName:SetFont("DermaDefaultBold")

        local sep = vgui.Create("DPanel", frame)
        sep:SetPos(14, 72); sep:SetSize(372, 1)
        sep.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(0, 140, 190, 90)) end

        local lResult = vgui.Create("DLabel", frame)
        lResult:SetPos(14, 80)
        lResult:SetSize(372, 210)
        lResult:SetText(result)
        lResult:SetTextColor(Color(195, 240, 205))
        lResult:SetFont("DermaDefault")
        lResult:SetWrap(true)
        lResult:SetAutoStretchVertical(true)

        -- Auto-close after 12 seconds
        timer.Simple(12, function()
            if IsValid(frame) then frame:Close() end
        end)
    end

    -- ─────────────────────────────────────────────────────────────────────────
    -- Sensor Panel UI
    -- ─────────────────────────────────────────────────────────────────────────
    function SHRPSensors.OpenSensorPanel()
        if IsValid(SHRPSensors._SensorPanel) then
            SHRPSensors._SensorPanel:Close()
        end

        local frame = vgui.Create("DFrame")
        SHRPSensors._SensorPanel = frame
        frame:SetTitle("")
        frame:SetSize(520, 520)
        frame:Center()
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)

        frame.Paint = function(self, w, h)
            draw.RoundedBox(12, 0, 0, w, h, Color(10, 16, 26, 250))
            draw.RoundedBox(12, 0, 0, w, 40, Color(8, 100, 160, 235))
            draw.SimpleText(
                "SENSOR PANEL",
                "DermaDefaultBold", 16, 20,
                Color(205, 235, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
        end

        -- ── Output area ───────────────────────────────────────────────────────
        local outputPanel = vgui.Create("DPanel", frame)
        outputPanel:SetPos(10, 48)
        outputPanel:SetSize(500, 106)
        outputPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(6, 12, 20, 215))
            draw.RoundedBox(6, 0, 0, w, 22, Color(4, 76, 115, 190))
            draw.SimpleText(
                "SCAN OUTPUT",
                "DermaDefaultBold", 8, 11,
                Color(115, 175, 215), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
        end

        local lOutName = vgui.Create("DLabel", outputPanel)
        lOutName:SetPos(8, 26); lOutName:SetSize(484, 20)
        lOutName:SetText("No scan active.")
        lOutName:SetTextColor(Color(95, 195, 255))
        lOutName:SetFont("DermaDefaultBold")

        local lOutResult = vgui.Create("DLabel", outputPanel)
        lOutResult:SetPos(8, 50); lOutResult:SetSize(484, 50)
        lOutResult:SetText("")
        lOutResult:SetTextColor(Color(180, 220, 190))
        lOutResult:SetFont("DermaDefault")
        lOutResult:SetWrap(true)

        -- ── Status bar ────────────────────────────────────────────────────────
        local lStatus = vgui.Create("DLabel", frame)
        lStatus:SetPos(12, 158); lStatus:SetSize(496, 18)
        lStatus:SetText("Select an entry and press Scan.")
        lStatus:SetTextColor(Color(110, 155, 195))
        lStatus:SetFont("DermaDefault")

        -- ── Entry list ────────────────────────────────────────────────────────
        local scroll = vgui.Create("DScrollPanel", frame)
        scroll:SetPos(10, 178); scroll:SetSize(500, 260)
        scroll.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(6, 12, 20, 175))
        end

        local activeScanID = nil

        local function RebuildList()
            scroll:Clear()
            for _, entry in ipairs(SHRPSensors.Entries) do
                local row = vgui.Create("DPanel", scroll)
                row:SetSize(492, 38)
                row:Dock(TOP)
                row:DockMargin(4, 2, 4, 0)
                local eID = entry.id

                row.Paint = function(self, w, h)
                    local bg = (activeScanID == eID)
                        and Color(8, 55, 95, 210)
                        or  Color(14, 26, 40, 185)
                    draw.RoundedBox(4, 0, 0, w, h, bg)
                end

                local lName = vgui.Create("DLabel", row)
                lName:SetPos(8, 0); lName:SetSize(360, 38)
                lName:SetText(entry.name)
                lName:SetTextColor(Color(200, 230, 255))
                lName:SetFont("DermaDefaultBold")
                lName:SetContentAlignment(4)

                local btnScan = vgui.Create("DButton", row)
                btnScan:SetPos(372, 5)
                btnScan:SetSize(68, 28)
                btnScan:SetText("Scan")
                btnScan:SetFont("DermaDefaultBold")
                btnScan.DoClick = function()
                    if activeScanID then return end
                    activeScanID = eID
                    lOutName:SetText("Scanning: " .. entry.name .. "…")
                    lOutResult:SetText("")
                    lStatus:SetText("Scanning – please wait (5s)…")
                    net.Start("sensors_scan_request")
                    net.WriteUInt(eID, 16)
                    net.SendToServer()
                    RebuildList()
                end
            end
        end

        RebuildList()

        -- ── React to incoming scan results ────────────────────────────────────
        SHRPSensors.OnPanelScanResult = function(id, name, result)
            activeScanID = nil
            lOutName:SetText("Scan complete:  " .. name)
            lOutResult:SetText(result)
            lStatus:SetText("Scan complete. Select an entry to scan again.")
            RebuildList()
        end

        -- Re-draw list whenever the server pushes a new entry set
        local syncCbIdx = #panelCbs + 1
        panelCbs[syncCbIdx] = function()
            if IsValid(frame) then RebuildList() end
        end

        frame.OnClose = function()
            activeScanID                  = nil
            SHRPSensors.OnPanelScanResult = nil
            SHRPSensors._SensorPanel      = nil
            panelCbs[syncCbIdx]           = nil
        end
    end

    -- ─────────────────────────────────────────────────────────────────────────
    -- GM Management Panel  (opened via shrp_gm_sensors_manage concommand)
    -- ─────────────────────────────────────────────────────────────────────────
    function SHRPSensors.OpenManagePanel()
        if IsValid(SHRPSensors._ManagePanel) then
            SHRPSensors._ManagePanel:Close()
        end

        local frame = vgui.Create("DFrame")
        SHRPSensors._ManagePanel = frame
        frame:SetTitle("")
        frame:SetSize(520, 480)
        frame:Center()
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)

        frame.Paint = function(self, w, h)
            draw.RoundedBox(12, 0, 0, w, h, Color(10, 16, 26, 250))
            draw.RoundedBox(12, 0, 0, w, 40, Color(70, 8, 140, 235))
            draw.SimpleText(
                "SENSOR MANAGEMENT  –  GM ONLY",
                "DermaDefaultBold", 16, 20,
                Color(220, 205, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
        end

        -- ── Entry list ────────────────────────────────────────────────────────
        local scroll = vgui.Create("DScrollPanel", frame)
        scroll:SetPos(10, 48); scroll:SetSize(500, 340)
        scroll.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(6, 12, 20, 175))
        end

        local function RebuildManageList()
            scroll:Clear()
            for _, entry in ipairs(SHRPSensors.Entries) do
                local row = vgui.Create("DPanel", scroll)
                row:SetSize(492, 38)
                row:Dock(TOP)
                row:DockMargin(4, 2, 4, 0)
                local eID = entry.id

                row.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(14, 26, 40, 185))
                end

                local lName = vgui.Create("DLabel", row)
                lName:SetPos(8, 0); lName:SetSize(288, 38)
                lName:SetText(entry.name)
                lName:SetTextColor(Color(200, 230, 255))
                lName:SetFont("DermaDefaultBold")
                lName:SetContentAlignment(4)

                -- Edit button
                local btnEdit = vgui.Create("DButton", row)
                btnEdit:SetPos(300, 5); btnEdit:SetSize(84, 28)
                btnEdit:SetText("Edit")
                btnEdit.DoClick = function()
                    local ef = vgui.Create("DFrame")
                    ef:SetTitle("Edit Entry")
                    ef:SetSize(380, 230)
                    ef:Center(); ef:MakePopup()

                    local lN = vgui.Create("DLabel", ef)
                    lN:SetPos(10, 34); lN:SetSize(360, 20); lN:SetText("Name:")
                    local eN = vgui.Create("DTextEntry", ef)
                    eN:SetPos(10, 54); eN:SetSize(360, 22); eN:SetValue(entry.name)

                    local lR = vgui.Create("DLabel", ef)
                    lR:SetPos(10, 82); lR:SetSize(360, 20); lR:SetText("Scan Result:")
                    local eR = vgui.Create("DTextEntry", ef)
                    eR:SetPos(10, 102); eR:SetSize(360, 68)
                    eR:SetMultiline(true); eR:SetValue(entry.result)

                    local bSave = vgui.Create("DButton", ef)
                    bSave:SetPos(10, 186); bSave:SetSize(360, 28); bSave:SetText("Save")
                    bSave.DoClick = function()
                        local n, r = eN:GetValue(), eR:GetValue()
                        if n == "" then return end
                        net.Start("sensors_manage_edit")
                        net.WriteUInt(eID, 16)
                        net.WriteString(n)
                        net.WriteString(r)
                        net.SendToServer()
                        ef:Close()
                    end
                end

                -- Delete button
                local btnDel = vgui.Create("DButton", row)
                btnDel:SetPos(390, 5); btnDel:SetSize(98, 28)
                btnDel:SetText("Delete")
                btnDel.DoClick = function()
                    net.Start("sensors_manage_remove")
                    net.WriteUInt(eID, 16)
                    net.SendToServer()
                end
            end
        end

        RebuildManageList()

        -- ── Add entry button ──────────────────────────────────────────────────
        local btnAdd = vgui.Create("DButton", frame)
        btnAdd:SetPos(10, 398); btnAdd:SetSize(500, 34)
        btnAdd:SetText("+ Add New Sensor Entry")
        btnAdd:SetFont("DermaDefaultBold")
        btnAdd.DoClick = function()
            local af = vgui.Create("DFrame")
            af:SetTitle("Add Sensor Entry")
            af:SetSize(380, 230)
            af:Center(); af:MakePopup()

            local lN = vgui.Create("DLabel", af)
            lN:SetPos(10, 34); lN:SetSize(360, 20); lN:SetText("Name:")
            local eN = vgui.Create("DTextEntry", af)
            eN:SetPos(10, 54); eN:SetSize(360, 22)
            eN:SetPlaceholderText("e.g. Anomaly, Vessel, Life Form…")

            local lR = vgui.Create("DLabel", af)
            lR:SetPos(10, 82); lR:SetSize(360, 20); lR:SetText("Scan Result:")
            local eR = vgui.Create("DTextEntry", af)
            eR:SetPos(10, 102); eR:SetSize(360, 68)
            eR:SetMultiline(true)
            eR:SetPlaceholderText("Describe what the sensors detect…")

            local bAdd = vgui.Create("DButton", af)
            bAdd:SetPos(10, 186); bAdd:SetSize(360, 28); bAdd:SetText("Add Entry")
            bAdd.DoClick = function()
                local n, r = eN:GetValue(), eR:GetValue()
                if n == "" then return end
                net.Start("sensors_manage_add")
                net.WriteString(n)
                net.WriteString(r)
                net.SendToServer()
                af:Close()
            end
        end

        -- Rebuild list on server sync
        local syncCbIdx = #panelCbs + 1
        panelCbs[syncCbIdx] = function()
            if IsValid(frame) then RebuildManageList() end
        end

        frame.OnClose = function()
            SHRPSensors._ManagePanel = nil
            panelCbs[syncCbIdx]      = nil
        end
    end

    -- ── GM spawnmenu shortcut ─────────────────────────────────────────────────
    spawnmenu.AddToolTab("SHRP Sensors", "SHRP Sensors", "icon16/chart_bar.png")
    spawnmenu.AddToolMenuOption(
        "SHRP Sensors", "Manage", "Manage Sensor Entries",
        "Sensor Entries", "", "",
        function(panel)
            panel:ClearControls()

            local isGM = LocalPlayer():IsSuperAdmin() or
                         LocalPlayer():GetUserGroup() == "gamemaster"

            if not isGM then
                local lbl = panel:Help("You must be a Game Master to manage sensor entries.")
                return
            end

            panel:Help("Add, edit, or remove sensor panel entries below.")

            local list = vgui.Create("DListView", panel)
            list:SetSize(320, 200)
            list:AddColumn("ID"):SetFixedWidth(30)
            list:AddColumn("Name")

            local function RefreshList()
                list:Clear()
                for _, entry in ipairs(SHRPSensors.Entries) do
                    list:AddLine(entry.id, entry.name)
                end
            end
            RefreshList()
            panel:AddItem(list)

            local bAdd = vgui.Create("DButton", panel)
            bAdd:SetText("Add Entry")
            bAdd.DoClick = function()
                local af = vgui.Create("DFrame")
                af:SetTitle("Add Sensor Entry")
                af:SetSize(360, 230); af:Center(); af:MakePopup()

                local lN = vgui.Create("DLabel", af)
                lN:SetPos(10, 34); lN:SetSize(340, 20); lN:SetText("Name:")
                local eN = vgui.Create("DTextEntry", af)
                eN:SetPos(10, 54); eN:SetSize(340, 22)
                eN:SetPlaceholderText("Entry name…")

                local lR = vgui.Create("DLabel", af)
                lR:SetPos(10, 82); lR:SetSize(340, 20); lR:SetText("Scan Result:")
                local eR = vgui.Create("DTextEntry", af)
                eR:SetPos(10, 102); eR:SetSize(340, 68); eR:SetMultiline(true)

                local bSave = vgui.Create("DButton", af)
                bSave:SetPos(10, 186); bSave:SetSize(340, 28); bSave:SetText("Add")
                bSave.DoClick = function()
                    local n, r = eN:GetValue(), eR:GetValue()
                    if n == "" then return end
                    net.Start("sensors_manage_add")
                    net.WriteString(n)
                    net.WriteString(r)
                    net.SendToServer()
                    af:Close()
                    timer.Simple(0.5, RefreshList)
                end
            end
            panel:AddItem(bAdd)

            local bEdit = vgui.Create("DButton", panel)
            bEdit:SetText("Edit Selected")
            bEdit.DoClick = function()
                local line = list:GetSelectedLine()
                if not line then return end
                local id = tonumber(list:GetLine(line):GetValue(1))
                local entry
                for _, e in ipairs(SHRPSensors.Entries) do
                    if e.id == id then entry = e break end
                end
                if not entry then return end

                local ef = vgui.Create("DFrame")
                ef:SetTitle("Edit Entry")
                ef:SetSize(360, 230); ef:Center(); ef:MakePopup()

                local lN = vgui.Create("DLabel", ef)
                lN:SetPos(10, 34); lN:SetSize(340, 20); lN:SetText("Name:")
                local eN = vgui.Create("DTextEntry", ef)
                eN:SetPos(10, 54); eN:SetSize(340, 22); eN:SetValue(entry.name)

                local lR = vgui.Create("DLabel", ef)
                lR:SetPos(10, 82); lR:SetSize(340, 20); lR:SetText("Scan Result:")
                local eR = vgui.Create("DTextEntry", ef)
                eR:SetPos(10, 102); eR:SetSize(340, 68)
                eR:SetMultiline(true); eR:SetValue(entry.result)

                local bSave = vgui.Create("DButton", ef)
                bSave:SetPos(10, 186); bSave:SetSize(340, 28); bSave:SetText("Save")
                bSave.DoClick = function()
                    local n, r = eN:GetValue(), eR:GetValue()
                    if n == "" then return end
                    net.Start("sensors_manage_edit")
                    net.WriteUInt(id, 16)
                    net.WriteString(n)
                    net.WriteString(r)
                    net.SendToServer()
                    ef:Close()
                    timer.Simple(0.5, RefreshList)
                end
            end
            panel:AddItem(bEdit)

            local bRemove = vgui.Create("DButton", panel)
            bRemove:SetText("Remove Selected")
            bRemove.DoClick = function()
                local line = list:GetSelectedLine()
                if not line then return end
                local id = tonumber(list:GetLine(line):GetValue(1))
                net.Start("sensors_manage_remove")
                net.WriteUInt(id, 16)
                net.SendToServer()
                list:RemoveLine(line)
            end
            panel:AddItem(bRemove)
        end
    )

end
