if SERVER then
    util.AddNetworkString("helm_open_panel")
    util.AddNetworkString("helm_set_heading")
    util.AddNetworkString("helm_adjust_speed")
    util.AddNetworkString("helm_all_stop")
end

SHRPHelm = SHRPHelm or {}
SHRPHelm.CurrentSpeed   = SHRPHelm.CurrentSpeed   or 0
SHRPHelm.CurrentHeading = SHRPHelm.CurrentHeading or "NORTH"

-- ─────────────────────────────────────────────────────────────────────────────
-- SERVER
-- ─────────────────────────────────────────────────────────────────────────────
if SERVER then
    net.Receive("helm_set_heading", function(_, ply)
        if not IsValid(ply) then return end
        local heading = net.ReadString()
        local valid = {
            NORTH = true, ["NORTH-EAST"] = true, EAST = true, ["SOUTH-EAST"] = true,
            SOUTH = true, ["SOUTH-WEST"] = true, WEST = true, ["NORTH-WEST"] = true,
        }
        if not valid[heading] then return end
        SHRPHelm.CurrentHeading = heading
        local name = ply:Nick()
        for _, p in ipairs(player.GetAll()) do
            p:ChatPrint("[HELM] " .. name .. " changed heading to " .. heading .. ".")
        end
    end)

    net.Receive("helm_adjust_speed", function(_, ply)
        if not IsValid(ply) then return end
        local delta = net.ReadInt(4)
        if delta ~= 1 and delta ~= -1 then return end
        timer.Remove("SHRPHelmAllStop")
        SHRPHelm.CurrentSpeed = math.Clamp(SHRPHelm.CurrentSpeed + delta, 0, 10)
        local name   = ply:Nick()
        local action = delta > 0 and "increased" or "decreased"
        for _, p in ipairs(player.GetAll()) do
            p:ChatPrint("[HELM] " .. name .. " " .. action .. " speed to " .. SHRPHelm.CurrentSpeed .. "/10.")
        end
    end)

    net.Receive("helm_all_stop", function(_, ply)
        if not IsValid(ply) then return end
        timer.Remove("SHRPHelmAllStop")
        if SHRPHelm.CurrentSpeed == 0 then
            for _, p in ipairs(player.GetAll()) do
                p:ChatPrint("[HELM] Speed is already at All Stop.")
            end
            return
        end
        local name = ply:Nick()
        for _, p in ipairs(player.GetAll()) do
            p:ChatPrint("[HELM] " .. name .. " has initiated All Stop!")
        end
        timer.Create("SHRPHelmAllStop", 1.5, 0, function()
            if SHRPHelm.CurrentSpeed <= 0 then
                SHRPHelm.CurrentSpeed = 0
                timer.Remove("SHRPHelmAllStop")
                for _, p in ipairs(player.GetAll()) do
                    p:ChatPrint("[HELM] All Stop complete. Speed: 0/10.")
                end
                return
            end
            SHRPHelm.CurrentSpeed = SHRPHelm.CurrentSpeed - 1
            if SHRPHelm.CurrentSpeed > 0 then
                for _, p in ipairs(player.GetAll()) do
                    p:ChatPrint("[HELM] All Stop in progress... Speed: " .. SHRPHelm.CurrentSpeed .. "/10.")
                end
            else
                timer.Remove("SHRPHelmAllStop")
                for _, p in ipairs(player.GetAll()) do
                    p:ChatPrint("[HELM] All Stop complete. Speed: 0/10.")
                end
            end
        end)
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- CLIENT
-- ─────────────────────────────────────────────────────────────────────────────
if CLIENT then
    SHRPHelm._ClientSpeed = SHRPHelm._ClientSpeed or 0

    net.Receive("helm_open_panel", function()
        SHRPHelm.OpenHelmPanel()
    end)

    function SHRPHelm.OpenHelmPanel()
        if IsValid(SHRPHelm._HelmPanel) then
            SHRPHelm._HelmPanel:Close()
        end

        local COL_BG          = Color(8,  20,  30,  250)
        local COL_HEADER      = Color(10, 60,  80,  235)
        local COL_SECTION     = Color(5,  15,  25,  215)
        local COL_SECTION_HDR = Color(10, 50,  70,  190)
        local COL_BTN_DIR     = Color(15, 80,  110, 220)
        local COL_BTN_DIR_HOV = Color(20, 110, 150, 220)
        local COL_BTN_SPD_UP  = Color(20, 100, 50,  220)
        local COL_BTN_SPD_DN  = Color(110, 55, 10,  220)
        local COL_BTN_STOP    = Color(160, 20,  20, 230)
        local COL_BTN_STOP_HOV = Color(200, 30, 30, 230)
        local COL_PIP_ON      = Color(0,  200, 230, 255)
        local COL_PIP_OFF     = Color(15,  35,  50, 255)

        local FULL_NAME = {
            N  = "NORTH",      NE = "NORTH-EAST",
            E  = "EAST",       SE = "SOUTH-EAST",
            S  = "SOUTH",      SW = "SOUTH-WEST",
            W  = "WEST",       NW = "NORTH-WEST",
        }

        local frame = vgui.Create("DFrame")
        SHRPHelm._HelmPanel = frame
        frame:SetTitle("")
        frame:SetSize(560, 520)
        frame:Center()
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)

        frame.Paint = function(self, w, h)
            draw.RoundedBox(12, 0, 0, w, h, COL_BG)
            draw.RoundedBox(12, 0, 0, w, 40, COL_HEADER)
            draw.SimpleText(
                "HELM CONSOLE",
                "DermaDefaultBold", 16, 20,
                Color(150, 230, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
        end

        -- ── Heading section ───────────────────────────────────────────────────
        local headPanel = vgui.Create("DPanel", frame)
        headPanel:SetPos(10, 48)
        headPanel:SetSize(312, 390)
        headPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, COL_SECTION)
            draw.RoundedBox(6, 0, 0, w, 22, COL_SECTION_HDR)
            draw.SimpleText(
                "HEADING CONTROL",
                "DermaDefaultBold", 8, 11,
                Color(130, 210, 240), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
        end

        local currentHeadingLabel = vgui.Create("DLabel", headPanel)
        currentHeadingLabel:SetPos(8, 354)
        currentHeadingLabel:SetSize(296, 22)
        currentHeadingLabel:SetFont("DermaDefaultBold")
        currentHeadingLabel:SetTextColor(Color(150, 230, 255))
        currentHeadingLabel:SetText("Current Heading: NORTH")
        currentHeadingLabel:SetContentAlignment(5)

        -- D-pad: 3×3 grid, center empty
        -- button size 86, gap 6, step 92 → total 3×86 + 2×6 = 270
        local BTN_SIZE = 86
        local BTN_STEP = 92
        local GRID_X   = math.floor((312 - 3 * BTN_STEP + (BTN_STEP - BTN_SIZE)) / 2)
        local GRID_Y   = 32

        local dirs = {
            { lbl = "NW", row = 1, col = 1 },
            { lbl = "N",  row = 1, col = 2 },
            { lbl = "NE", row = 1, col = 3 },
            { lbl = "W",  row = 2, col = 1 },
            { lbl = "E",  row = 2, col = 3 },
            { lbl = "SW", row = 3, col = 1 },
            { lbl = "S",  row = 3, col = 2 },
            { lbl = "SE", row = 3, col = 3 },
        }

        for _, dir in ipairs(dirs) do
            local bx = GRID_X + (dir.col - 1) * BTN_STEP
            local by = GRID_Y + (dir.row - 1) * BTN_STEP
            local btn = vgui.Create("DButton", headPanel)
            btn:SetPos(bx, by)
            btn:SetSize(BTN_SIZE, BTN_SIZE)
            btn:SetText("")
            local lbl = dir.lbl
            btn.Paint = function(self, w, h)
                local col = self:IsHovered() and COL_BTN_DIR_HOV or COL_BTN_DIR
                draw.RoundedBox(8, 0, 0, w, h, col)
                draw.SimpleText(
                    lbl,
                    "DermaDefaultBold", w * 0.5, h * 0.5,
                    Color(200, 240, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
                )
                return true
            end
            btn.DoClick = function()
                surface.PlaySound("buttons/button14.wav")
                local full = FULL_NAME[lbl] or lbl
                if IsValid(currentHeadingLabel) then
                    currentHeadingLabel:SetText("Current Heading: " .. full)
                end
                net.Start("helm_set_heading")
                net.WriteString(full)
                net.SendToServer()
            end
        end

        -- Center compass marker
        local cx = GRID_X + BTN_STEP + math.floor((BTN_SIZE - 30) * 0.5)
        local cy = GRID_Y + BTN_STEP + math.floor((BTN_SIZE - 30) * 0.5)
        local compass = vgui.Create("DPanel", headPanel)
        compass:SetPos(cx, cy)
        compass:SetSize(30, 30)
        compass.Paint = function(self, w, h)
            draw.RoundedBox(15, 0, 0, w, h, Color(10, 50, 70, 200))
            draw.SimpleText("✦", "DermaDefaultBold", w * 0.5, h * 0.5, Color(0, 200, 230, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- ── Speed section ─────────────────────────────────────────────────────
        local speedPanel = vgui.Create("DPanel", frame)
        speedPanel:SetPos(332, 48)
        speedPanel:SetSize(218, 390)
        speedPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, COL_SECTION)
            draw.RoundedBox(6, 0, 0, w, 22, COL_SECTION_HDR)
            draw.SimpleText(
                "SPEED CONTROL",
                "DermaDefaultBold", 8, 11,
                Color(130, 210, 240), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
        end

        -- Speed up button
        local btnSpeedUp = vgui.Create("DButton", speedPanel)
        btnSpeedUp:SetPos(14, 30)
        btnSpeedUp:SetSize(190, 50)
        btnSpeedUp:SetText("")
        btnSpeedUp.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, COL_BTN_SPD_UP)
            draw.SimpleText(
                "▲  SPEED UP",
                "DermaDefaultBold", w * 0.5, h * 0.5,
                Color(200, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
            return true
        end
        btnSpeedUp.DoClick = function()
            if SHRPHelm._ClientSpeed >= 10 then
                surface.PlaySound("buttons/button8.wav")
                return
            end
            timer.Remove("SHRPHelmClientStop")
            SHRPHelm._ClientSpeed = SHRPHelm._ClientSpeed + 1
            surface.PlaySound("buttons/button14.wav")
            net.Start("helm_adjust_speed")
            net.WriteInt(1, 4)
            net.SendToServer()
        end

        -- Pip display (10 pips, top = 10, bottom = 1)
        local PIP_H    = 16
        local PIP_GAP  = 4
        local PIP_STEP = PIP_H + PIP_GAP
        local pipsPanel = vgui.Create("DPanel", speedPanel)
        pipsPanel:SetPos(14, 90)
        pipsPanel:SetSize(190, 10 * PIP_STEP - PIP_GAP)
        pipsPanel.Paint = function(self, w, h)
            for i = 10, 1, -1 do
                local py  = (10 - i) * PIP_STEP
                local col = (i <= SHRPHelm._ClientSpeed) and COL_PIP_ON or COL_PIP_OFF
                draw.RoundedBox(3, 0, py, w, PIP_H, col)
                draw.SimpleText(
                    tostring(i),
                    "DermaDefault", w * 0.5, py + PIP_H * 0.5,
                    Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
                )
            end
        end

        -- Speed label
        local speedLabel = vgui.Create("DLabel", speedPanel)
        speedLabel:SetPos(14, 302)
        speedLabel:SetSize(190, 22)
        speedLabel:SetFont("DermaDefaultBold")
        speedLabel:SetTextColor(Color(150, 230, 255))
        speedLabel:SetText("Speed: 0 / 10")
        speedLabel:SetContentAlignment(5)

        local function UpdateSpeedLabel()
            if IsValid(speedLabel) then
                speedLabel:SetText("Speed: " .. SHRPHelm._ClientSpeed .. " / 10")
            end
        end

        -- Refresh speed label each frame via Think
        speedPanel.Think = function()
            UpdateSpeedLabel()
        end

        -- Speed down button
        local btnSpeedDn = vgui.Create("DButton", speedPanel)
        btnSpeedDn:SetPos(14, 330)
        btnSpeedDn:SetSize(190, 50)
        btnSpeedDn:SetText("")
        btnSpeedDn.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, COL_BTN_SPD_DN)
            draw.SimpleText(
                "▼  SPEED DOWN",
                "DermaDefaultBold", w * 0.5, h * 0.5,
                Color(255, 210, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
            return true
        end
        btnSpeedDn.DoClick = function()
            if SHRPHelm._ClientSpeed <= 0 then
                surface.PlaySound("buttons/button8.wav")
                return
            end
            timer.Remove("SHRPHelmClientStop")
            SHRPHelm._ClientSpeed = SHRPHelm._ClientSpeed - 1
            surface.PlaySound("buttons/button14.wav")
            net.Start("helm_adjust_speed")
            net.WriteInt(-1, 4)
            net.SendToServer()
        end

        -- ── All Stop button ───────────────────────────────────────────────────
        local btnAllStop = vgui.Create("DButton", frame)
        btnAllStop:SetPos(10, 448)
        btnAllStop:SetSize(540, 58)
        btnAllStop:SetText("")
        btnAllStop.Paint = function(self, w, h)
            local col = self:IsHovered() and COL_BTN_STOP_HOV or COL_BTN_STOP
            draw.RoundedBox(8, 0, 0, w, h, col)
            draw.SimpleText(
                "⬛  ALL STOP",
                "DermaLarge", w * 0.5, h * 0.5,
                Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
            return true
        end
        btnAllStop.DoClick = function()
            if SHRPHelm._ClientSpeed == 0 then
                surface.PlaySound("buttons/button8.wav")
                return
            end
            surface.PlaySound("buttons/button10.wav")
            net.Start("helm_all_stop")
            net.SendToServer()
            -- Visual countdown matches server-side 1.5s timer
            timer.Remove("SHRPHelmClientStop")
            timer.Create("SHRPHelmClientStop", 1.5, 0, function()
                if SHRPHelm._ClientSpeed <= 0 then
                    SHRPHelm._ClientSpeed = 0
                    timer.Remove("SHRPHelmClientStop")
                    return
                end
                SHRPHelm._ClientSpeed = SHRPHelm._ClientSpeed - 1
            end)
        end

        frame.OnClose = function()
            SHRPHelm._HelmPanel = nil
        end
    end
end
