if SERVER then
    util.AddNetworkString("captain_chair_enter")
    util.AddNetworkString("captain_chair_exit")
    util.AddNetworkString("captain_alert_broadcast")
    util.AddNetworkString("captain_alert_display")
end

SHRPCaptain = SHRPCaptain or {}

-- ─────────────────────────────────────────────────────────────────────────────
-- SERVER
-- ─────────────────────────────────────────────────────────────────────────────
if SERVER then
    local ALERT_COLORS = {
        Red    = Color(220, 40,  40),
        Yellow = Color(220, 200, 40),
        Blue   = Color(40,  100, 220),
        Green  = Color(40,  200, 80),
    }

    -- Clean up seating state when a player disconnects.
    hook.Add("PlayerDisconnected", "SHRPCaptainDisconnect", function(ply)
        for _, chair in ipairs(ents.FindByClass("captain_chair")) do
            if IsValid(chair) and chair.SeatedPlayer == ply then
                chair.SeatedPlayer = nil
            end
        end
    end)

    -- Receive an alert broadcast request from the client.
    net.Receive("captain_alert_broadcast", function(len, ply)
        if not IsValid(ply) then return end

        -- Only allow seated players to broadcast alerts.
        local isSeated = false
        for _, chair in ipairs(ents.FindByClass("captain_chair")) do
            if IsValid(chair) and chair.SeatedPlayer == ply then
                isSeated = true
                break
            end
        end
        if not isSeated then return end

        local alert = net.ReadString()
        if not ALERT_COLORS[alert] then return end

        -- Relay the alert to every client for colored display.
        net.Start("captain_alert_display")
        net.WriteString(alert)
        net.Broadcast()
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- CLIENT
-- ─────────────────────────────────────────────────────────────────────────────
if CLIENT then
    SHRPCaptain.IsSeated  = false
    SHRPCaptain.ChairEnt  = nil

    -- ── Seat / unseat notifications ───────────────────────────────────────────
    net.Receive("captain_chair_enter", function()
        local ent = net.ReadEntity()
        SHRPCaptain.IsSeated = true
        SHRPCaptain.ChairEnt = ent
    end)

    net.Receive("captain_chair_exit", function()
        SHRPCaptain.IsSeated = false
        SHRPCaptain.ChairEnt = nil
    end)

    -- ── Alert display ─────────────────────────────────────────────────────────
    local ALERT_COLORS = {
        Red    = Color(220, 40,  40),
        Yellow = Color(220, 200, 40),
        Blue   = Color(40,  100, 220),
        Green  = Color(40,  200, 80),
    }

    net.Receive("captain_alert_display", function()
        local alert = net.ReadString()
        local col   = ALERT_COLORS[alert] or Color(255, 255, 255)
        chat.AddText(col, "[Destiny] " .. string.upper(alert) .. " ALERT!")
    end)

    -- ── Keybind overlay HUD ───────────────────────────────────────────────────
    hook.Add("HUDPaint", "SHRPCaptainHUD", function()
        if not SHRPCaptain.IsSeated then return end

        -- Auto-clear state if the chair entity was removed.
        if not IsValid(SHRPCaptain.ChairEnt) then
            SHRPCaptain.IsSeated = false
            SHRPCaptain.ChairEnt = nil
            return
        end

        local panelW, panelH = 230, 126
        local x = ScrW() - panelW - 20
        local y = ScrH() / 2 - panelH / 2

        -- Background
        draw.RoundedBox(8, x, y, panelW, panelH, Color(10, 16, 30, 200))
        -- Header bar
        draw.RoundedBox(8, x, y, panelW, 28, Color(20, 60, 120, 220))
        draw.SimpleText(
            "CAPTAIN'S CHAIR",
            "DermaDefaultBold", x + panelW / 2, y + 14,
            Color(180, 220, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
        )

        local binds = {
            { key = "[R]", label = "Alert System Control" },
            { key = "[F]", label = "MPC Access"           },
            { key = "[V]", label = "Tactical Control"     },
        }

        for i, bind in ipairs(binds) do
            local rowY = y + 30 + (i - 1) * 30 + 8
            draw.SimpleText(
                bind.key, "DermaDefaultBold",
                x + 14, rowY,
                Color(100, 200, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
            )
            draw.SimpleText(
                bind.label, "DermaDefault",
                x + 58, rowY,
                Color(200, 220, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP
            )
        end
    end)

    -- ── Keybind handler ───────────────────────────────────────────────────────
    hook.Add("PlayerButtonDown", "SHRPCaptainKeys", function(ply, btn)
        if not SHRPCaptain.IsSeated then return end
        if btn == KEY_R then
            SHRPCaptain.OpenAlertPanel()
        elseif btn == KEY_F then
            SHRPCaptain.OpenMPCPanel()
        elseif btn == KEY_V then
            if SHRPTactical and SHRPTactical.OpenTacticalPanel then
                SHRPTactical.OpenTacticalPanel()
            end
        end
    end)

    -- ─────────────────────────────────────────────────────────────────────────
    -- Alert System Panel
    -- ─────────────────────────────────────────────────────────────────────────
    function SHRPCaptain.OpenAlertPanel()
        if IsValid(SHRPCaptain._AlertPanel) then
            SHRPCaptain._AlertPanel:Close()
            return
        end

        local COL_BG     = Color(10, 14, 24, 250)
        local COL_HEADER = Color(90, 18, 18, 235)

        local alertDefs = {
            { name = "Red",    base = Color(160, 28, 28), hover = Color(210, 50, 50)  },
            { name = "Yellow", base = Color(150, 130, 18), hover = Color(200, 180, 30) },
            { name = "Blue",   base = Color(20,  55, 150), hover = Color(40,  90, 210) },
            { name = "Green",  base = Color(18,  110, 36), hover = Color(30,  155, 55) },
        }

        local frame = vgui.Create("DFrame")
        SHRPCaptain._AlertPanel = frame
        frame:SetTitle("")
        frame:SetSize(300, 236)
        frame:SetPos(ScrW() - 550, ScrH() / 2 - 118)
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)

        frame.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, COL_BG)
            draw.RoundedBox(10, 0, 0, w, 36, COL_HEADER)
            draw.SimpleText(
                "ALERT SYSTEM CONTROL",
                "DermaDefaultBold", 14, 18,
                Color(255, 160, 160), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
        end

        local statusLabel = vgui.Create("DLabel", frame)
        statusLabel:SetPos(10, 42)
        statusLabel:SetSize(280, 18)
        statusLabel:SetFont("DermaDefault")
        statusLabel:SetTextColor(Color(180, 180, 220))
        statusLabel:SetText("Select alert level to broadcast.")

        for i, alert in ipairs(alertDefs) do
            local btn = vgui.Create("DButton", frame)
            btn:SetPos(10, 64 + (i - 1) * 38)
            btn:SetSize(280, 32)
            btn:SetText("")

            local hovered = false
            btn.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, hovered and alert.hover or alert.base)
                draw.SimpleText(
                    string.upper(alert.name) .. " ALERT",
                    "DermaDefaultBold", w / 2, h / 2,
                    Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
                )
                return true
            end
            btn.OnCursorEntered = function() hovered = true  end
            btn.OnCursorExited  = function() hovered = false end

            btn.DoClick = function()
                surface.PlaySound("buttons/button14.wav")
                statusLabel:SetText(string.upper(alert.name) .. " ALERT broadcasted!")
                net.Start("captain_alert_broadcast")
                net.WriteString(alert.name)
                net.SendToServer()
            end
        end

        frame.OnClose = function()
            SHRPCaptain._AlertPanel = nil
        end
    end

    -- ─────────────────────────────────────────────────────────────────────────
    -- MPC Panel
    -- ─────────────────────────────────────────────────────────────────────────
    function SHRPCaptain.OpenMPCPanel()
        if IsValid(SHRPCaptain._MPCPanel) then
            SHRPCaptain._MPCPanel:Close()
            return
        end

        local COL_BG     = Color(10, 16, 26, 250)
        local COL_HEADER = Color(10, 60, 130, 235)

        local frame = vgui.Create("DFrame")
        SHRPCaptain._MPCPanel = frame
        frame:SetTitle("")
        frame:SetSize(360, 240)
        frame:SetPos(ScrW() - 550, ScrH() / 2 - 120)
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)

        frame.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, COL_BG)
            draw.RoundedBox(10, 0, 0, w, 36, COL_HEADER)
            draw.SimpleText(
                "MASTER PROGRAM COMPUTER",
                "DermaDefaultBold", 14, 18,
                Color(160, 210, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
        end

        local lines = {
            "MPC Terminal  —  Access Granted",
            "",
            "All ship systems operating within normal parameters.",
            "",
            "Additional MPC functionality pending integration.",
        }

        for i, line in ipairs(lines) do
            local lbl = vgui.Create("DLabel", frame)
            lbl:SetPos(14, 42 + (i - 1) * 20)
            lbl:SetSize(332, 18)
            lbl:SetFont(i == 1 and "DermaDefaultBold" or "DermaDefault")
            lbl:SetTextColor(i == 1 and Color(180, 220, 255) or Color(160, 185, 220))
            lbl:SetText(line)
        end

        frame.OnClose = function()
            SHRPCaptain._MPCPanel = nil
        end
    end
end
