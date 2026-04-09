if SERVER then
    AddCSLuaFile()
    util.AddNetworkString("ops_open_panel")
    util.AddNetworkString("ops_alert_broadcast")
    util.AddNetworkString("ops_alert_display")
    util.AddNetworkString("ops_ship_message")
    util.AddNetworkString("ops_ship_display")
end

SHRPOps = SHRPOps or {}
SHRPOps.ShipName = SHRPOps.ShipName or "Destiny"

-- ─────────────────────────────────────────────────────────────────────────────
-- SERVER
-- ─────────────────────────────────────────────────────────────────────────────
if SERVER then
    net.Receive("ops_alert_broadcast", function(len, ply)
        if not IsValid(ply) then return end
        local alert = net.ReadString()
        if not SHRPCaptain or not SHRPCaptain.AlertColors or not SHRPCaptain.AlertColors[alert] then return end

        net.Start("ops_alert_display")
        net.WriteString(alert)
        net.Broadcast()
    end)

    net.Receive("ops_ship_message", function(len, ply)
        if not IsValid(ply) then return end

        if SHRPComms and SHRPComms.GetCommunicationsRelayPercent then
            if SHRPComms.GetCommunicationsRelayPercent() < 25 then
                ply:ChatPrint("Communications relays must be at least 25% to transmit.")
                return
            end
        end

        local msg = net.ReadString()
        if not msg or #msg == 0 then return end
        msg = string.sub(msg, 1, 250)

        net.Start("ops_ship_display")
        net.WriteString(msg)
        net.Broadcast()
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- CLIENT
-- ─────────────────────────────────────────────────────────────────────────────
if CLIENT then
    SHRPOps.ShipLog = SHRPOps.ShipLog or {}
    SHRPOps._Panel = nil
    SHRPOps._RefreshLog = nil

    -- Alert display — reuse captain system colours if available
    net.Receive("ops_alert_display", function()
        local alert = net.ReadString()
        local col = (SHRPCaptain and SHRPCaptain.AlertColors and SHRPCaptain.AlertColors[alert]) or Color(255, 255, 255)
        chat.AddText(col, "[" .. SHRPOps.ShipName .. "] " .. string.upper(alert) .. " ALERT!")
    end)

    -- Ship-to-ship message broadcast
    net.Receive("ops_ship_display", function()
        local msg = net.ReadString()

        -- Store in log (keep last 100 entries)
        table.insert(SHRPOps.ShipLog, msg)
        if #SHRPOps.ShipLog > 100 then
            table.remove(SHRPOps.ShipLog, 1)
        end

        -- Show in main chat
        chat.AddText(Color(100, 200, 255), "[" .. SHRPOps.ShipName .. "] " .. msg)

        -- Update the panel log if it is open
        if SHRPOps._RefreshLog then
            SHRPOps._RefreshLog(msg)
        end
    end)

    -- Open the ops console panel
    net.Receive("ops_open_panel", function()
        SHRPOps.OpenOpsPanel()
    end)

    -- ─────────────────────────────────────────────────────────────────────────
    -- Ops Console UI
    -- ─────────────────────────────────────────────────────────────────────────
    function SHRPOps.OpenOpsPanel()
        if IsValid(SHRPOps._Panel) then
            SHRPOps._Panel:Close()
            return
        end

        local frame = vgui.Create("DFrame")
        SHRPOps._Panel = frame
        frame:SetSize(620, 500)
        frame:Center()
        frame:SetTitle("")
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)

        frame.Paint = function(self, w, h)
            draw.RoundedBox(12, 0, 0, w, h, Color(12, 16, 28, 245))
            draw.RoundedBoxEx(12, 0, 0, w, 48, Color(10, 80, 160, 230), true, true, false, false)
            draw.SimpleText("OPERATIONS CONSOLE", "Trebuchet24", w * 0.5, 24, Color(180, 220, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        frame.OnClose = function()
            SHRPOps._Panel = nil
            SHRPOps._RefreshLog = nil
        end

        local sheet = vgui.Create("DPropertySheet", frame)
        sheet:SetPos(6, 54)
        sheet:SetSize(608, 440)

        -- ── TAB 1: Alert Control ─────────────────────────────────────────────
        local alertPanel = vgui.Create("DPanel")
        alertPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(8, 12, 22, 0))
        end

        local alertDefs = {
            { name = "Red",    base = Color(160, 28, 28),  hover = Color(210, 50, 50)   },
            { name = "Yellow", base = Color(150, 130, 18), hover = Color(200, 180, 30)  },
            { name = "Blue",   base = Color(20, 55, 150),  hover = Color(40, 90, 210)   },
            { name = "Green",  base = Color(18, 110, 36),  hover = Color(30, 155, 55)   },
        }

        local alertStatus = vgui.Create("DLabel", alertPanel)
        alertStatus:SetPos(14, 14)
        alertStatus:SetSize(580, 20)
        alertStatus:SetFont("DermaDefaultBold")
        alertStatus:SetTextColor(Color(180, 200, 240))
        alertStatus:SetText("Select alert level to broadcast ship-wide.")

        for i, alert in ipairs(alertDefs) do
            local btn = vgui.Create("DButton", alertPanel)
            btn:SetPos(14, 44 + (i - 1) * 56)
            btn:SetSize(580, 48)
            btn:SetText("")

            local hovered = false
            btn.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, hovered and alert.hover or alert.base)
                draw.SimpleText(string.upper(alert.name) .. " ALERT", "DermaLarge", w * 0.5, h * 0.5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                return true
            end
            btn.OnCursorEntered = function() hovered = true  end
            btn.OnCursorExited  = function() hovered = false end

            btn.DoClick = function()
                surface.PlaySound("buttons/button14.wav")
                alertStatus:SetText(string.upper(alert.name) .. " ALERT broadcasted!")
                net.Start("ops_alert_broadcast")
                net.WriteString(alert.name)
                net.SendToServer()
            end
        end

        sheet:AddSheet("ALERT CONTROL", alertPanel, "icon16/bell.png")

        -- ── TAB 2: Power Management ──────────────────────────────────────────
        local powerPanel = vgui.Create("DPanel")
        powerPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(8, 12, 22, 0))
        end

        local powerInfo = vgui.Create("DLabel", powerPanel)
        powerInfo:SetPos(14, 14)
        powerInfo:SetSize(580, 20)
        powerInfo:SetFont("DermaDefaultBold")
        powerInfo:SetTextColor(Color(180, 200, 240))
        powerInfo:SetText("Ship Power Management — Engineering Grid Control")

        local powerBtn = vgui.Create("DButton", powerPanel)
        powerBtn:SetPos(14, 48)
        powerBtn:SetSize(580, 48)
        powerBtn:SetText("OPEN POWER MANAGEMENT PANEL")
        powerBtn:SetFont("DermaLarge")
        powerBtn:SetTextColor(Color(180, 220, 255))
        powerBtn.Paint = function(self, w, h)
            local isHovered = self:IsHovered()
            draw.RoundedBox(8, 0, 0, w, h, isHovered and Color(20, 80, 160) or Color(10, 55, 130))
            return true
        end
        powerBtn.DoClick = function()
            surface.PlaySound("buttons/button14.wav")
            net.Start("eng_request")
            net.SendToServer()
        end

        sheet:AddSheet("POWER MANAGEMENT", powerPanel, "icon16/lightning.png")

        -- ── TAB 3: Ship-to-Ship Comms ────────────────────────────────────────
        local commsPanel = vgui.Create("DPanel")
        commsPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(8, 12, 22, 0))
        end

        local commsInfo = vgui.Create("DLabel", commsPanel)
        commsInfo:SetPos(14, 10)
        commsInfo:SetSize(580, 20)
        commsInfo:SetFont("DermaDefaultBold")
        commsInfo:SetTextColor(Color(180, 200, 240))
        commsInfo:SetText("Ship-to-Ship Communications — Long Range Transmitter")

        local logPanel = vgui.Create("RichText", commsPanel)
        logPanel:SetPos(14, 36)
        logPanel:SetSize(580, 320)
        logPanel.PerformLayout = function(self)
            self:SetFontInternal("DermaDefault")
        end
        logPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(8, 12, 22, 200))
            self:DrawPanelBackground(false)
        end

        -- Populate with existing log history
        for _, msg in ipairs(SHRPOps.ShipLog) do
            logPanel:InsertColorChange(100, 200, 255, 255)
            logPanel:AppendText("[" .. SHRPOps.ShipName .. "] " .. msg .. "\n")
        end
        logPanel:GotoTextEnd()

        -- Callback so incoming messages can be appended live
        SHRPOps._RefreshLog = function(msg)
            if not IsValid(logPanel) then
                SHRPOps._RefreshLog = nil
                return
            end
            logPanel:InsertColorChange(100, 200, 255, 255)
            logPanel:AppendText("[" .. SHRPOps.ShipName .. "] " .. msg .. "\n")
            logPanel:GotoTextEnd()
        end

        local textEntry = vgui.Create("DTextEntry", commsPanel)
        textEntry:SetPos(14, 366)
        textEntry:SetSize(472, 32)
        textEntry:SetPlaceholderText("Enter transmission message...")
        textEntry:SetMaxLength(250)

        local sendBtn = vgui.Create("DButton", commsPanel)
        sendBtn:SetPos(492, 366)
        sendBtn:SetSize(108, 32)
        sendBtn:SetText("TRANSMIT")
        sendBtn:SetFont("DermaDefaultBold")
        sendBtn:SetTextColor(Color(180, 220, 255))
        sendBtn.Paint = function(self, w, h)
            local isHovered = self:IsHovered()
            draw.RoundedBox(6, 0, 0, w, h, isHovered and Color(20, 130, 80) or Color(10, 90, 50))
            return true
        end

        local function SendMessage()
            local msg = textEntry:GetValue()
            if not msg or #msg == 0 then return end
            net.Start("ops_ship_message")
            net.WriteString(msg)
            net.SendToServer()
            textEntry:SetValue("")
        end

        sendBtn.DoClick = SendMessage
        textEntry.OnEnter = function() SendMessage() end

        sheet:AddSheet("SHIP COMMS", commsPanel, "icon16/transmit.png")
    end
end
