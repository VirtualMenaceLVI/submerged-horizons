if SERVER then
    util.AddNetworkString("tactical_open_panel")
    util.AddNetworkString("tactical_fire_torpedo")
    util.AddNetworkString("tactical_fire_dew")
end

SHRPTactical = SHRPTactical or {}

function SHRPTactical.GetWeaponsRelayPercent()
    local relays = ents.FindByClass("relay_weapons")
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
    net.Receive("tactical_fire_torpedo", function(_, ply)
        if not IsValid(ply) then return end
        if SHRPTactical.GetWeaponsRelayPercent() < 1 then
            ply:ChatPrint("Weapons relays offline.")
            return
        end

        local name = ply:Nick()
        ply:EmitSound("weapons/rpg/rocketfire1.wav", 85, 100)
        ply:ChatPrint("[TACTICAL] Torpedo fired.")
        for _, p in ipairs(player.GetAll()) do
            if p ~= ply then
                p:ChatPrint("[TACTICAL] " .. name .. " has fired a torpedo!")
            end
        end
    end)

    net.Receive("tactical_fire_dew", function(_, ply)
        if not IsValid(ply) then return end
        if SHRPTactical.GetWeaponsRelayPercent() < 1 then
            ply:ChatPrint("Weapons relays offline.")
            return
        end

        local name = ply:Nick()
        ply:EmitSound("weapons/physcannon/energy_sing_explode2.wav", 85, 100)
        ply:ChatPrint("[TACTICAL] FBX-9 D.E.W. fired.")
        for _, p in ipairs(player.GetAll()) do
            if p ~= ply then
                p:ChatPrint("[TACTICAL] " .. name .. " has fired the FBX-9 Directed Energy Weapon!")
            end
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- CLIENT
-- ─────────────────────────────────────────────────────────────────────────────
if CLIENT then
    -- ── Open panel ────────────────────────────────────────────────────────────
    net.Receive("tactical_open_panel", function()
        SHRPTactical.OpenTacticalPanel()
    end)

    -- ─────────────────────────────────────────────────────────────────────────
    -- Tactical Panel UI
    -- ─────────────────────────────────────────────────────────────────────────
    function SHRPTactical.OpenTacticalPanel()
        if IsValid(SHRPTactical._TacticalPanel) then
            SHRPTactical._TacticalPanel:Close()
        end

        -- Toggle states (client-side RP controls)
        local torpedoArmed = false
        local dewArmed     = false
        local hullPolarized = false

        local COL_BG         = Color(10, 16, 26, 250)
        local COL_HEADER     = Color(110, 20, 20, 235)
        local COL_SECTION    = Color(6, 12, 20, 215)
        local COL_SECTION_HDR = Color(80, 18, 18, 190)
        local COL_ARMED      = Color(18, 130, 60, 220)
        local COL_DISARMED   = Color(60, 14, 14, 220)
        local COL_FIRE       = Color(160, 30, 30, 230)
        local COL_FIRE_OFF   = Color(40, 40, 50, 200)
        local COL_POLARIZED  = Color(20, 90, 160, 220)
        local COL_INACTIVE   = Color(60, 14, 14, 220)

        local frame = vgui.Create("DFrame")
        SHRPTactical._TacticalPanel = frame
        frame:SetTitle("")
        frame:SetSize(480, 420)
        frame:Center()
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)

        frame.Paint = function(self, w, h)
            draw.RoundedBox(12, 0, 0, w, h, COL_BG)
            draw.RoundedBox(12, 0, 0, w, 40, COL_HEADER)
            draw.SimpleText(
                "TACTICAL CONSOLE",
                "DermaDefaultBold", 16, 20,
                Color(255, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
        end

        -- ── Status panel ──────────────────────────────────────────────────────
        local statusPanel = vgui.Create("DPanel", frame)
        statusPanel:SetPos(10, 48)
        statusPanel:SetSize(460, 50)
        statusPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, COL_SECTION)
            draw.RoundedBox(6, 0, 0, w, 22, COL_SECTION_HDR)
            draw.SimpleText(
                "WEAPONS STATUS",
                "DermaDefaultBold", 8, 11,
                Color(215, 155, 155), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
        end

        local lRelay = vgui.Create("DLabel", statusPanel)
        lRelay:SetPos(8, 26); lRelay:SetSize(444, 18)
        lRelay:SetFont("DermaDefault")
        lRelay:SetTextColor(Color(200, 230, 255))

        local function UpdateRelayStatus()
            if not IsValid(lRelay) then return end
            local pct = SHRPTactical.GetWeaponsRelayPercent and SHRPTactical.GetWeaponsRelayPercent() or 0
            local col = pct >= 50 and Color(80, 220, 120) or (pct >= 1 and Color(220, 180, 60) or Color(220, 80, 80))
            lRelay:SetText(string.format("Weapons Relay: %d%% functional", math.floor(pct)))
            lRelay:SetTextColor(col)
        end
        UpdateRelayStatus()

        -- ── Tactical controls section ─────────────────────────────────────────
        local ctrlPanel = vgui.Create("DPanel", frame)
        ctrlPanel:SetPos(10, 106)
        ctrlPanel:SetSize(460, 130)
        ctrlPanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, COL_SECTION)
            draw.RoundedBox(6, 0, 0, w, 22, COL_SECTION_HDR)
            draw.SimpleText(
                "TACTICAL CONTROLS",
                "DermaDefaultBold", 8, 11,
                Color(215, 155, 155), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
        end

        -- Arm Torpedoes toggle
        local btnArmTorp = vgui.Create("DButton", ctrlPanel)
        btnArmTorp:SetPos(8, 30); btnArmTorp:SetSize(216, 38)
        btnArmTorp:SetFont("DermaDefaultBold")
        btnArmTorp:SetText("TORPEDOES: DISARMED")
        btnArmTorp.Paint = function(self, w, h)
            local col = torpedoArmed and COL_ARMED or COL_DISARMED
            draw.RoundedBox(6, 0, 0, w, h, col)
            draw.SimpleText(
                torpedoArmed and "TORPEDOES: ARMED" or "TORPEDOES: DISARMED",
                "DermaDefaultBold", w * 0.5, h * 0.5,
                Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
            return true
        end
        btnArmTorp.DoClick = function()
            torpedoArmed = not torpedoArmed
            surface.PlaySound(torpedoArmed and "buttons/button14.wav" or "buttons/button10.wav")
        end

        -- Arm DEW toggle
        local btnArmDEW = vgui.Create("DButton", ctrlPanel)
        btnArmDEW:SetPos(236, 30); btnArmDEW:SetSize(216, 38)
        btnArmDEW:SetFont("DermaDefaultBold")
        btnArmDEW.Paint = function(self, w, h)
            local col = dewArmed and COL_ARMED or COL_DISARMED
            draw.RoundedBox(6, 0, 0, w, h, col)
            draw.SimpleText(
                dewArmed and "D.E.W.: ARMED" or "D.E.W.: DISARMED",
                "DermaDefaultBold", w * 0.5, h * 0.5,
                Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
            return true
        end
        btnArmDEW.DoClick = function()
            dewArmed = not dewArmed
            surface.PlaySound(dewArmed and "buttons/button14.wav" or "buttons/button10.wav")
        end

        -- Polarize Hull Plating toggle
        local btnPolarize = vgui.Create("DButton", ctrlPanel)
        btnPolarize:SetPos(8, 80); btnPolarize:SetSize(444, 38)
        btnPolarize:SetFont("DermaDefaultBold")
        btnPolarize.Paint = function(self, w, h)
            local col = hullPolarized and COL_POLARIZED or COL_INACTIVE
            draw.RoundedBox(6, 0, 0, w, h, col)
            draw.SimpleText(
                hullPolarized and "HULL PLATING: POLARIZED" or "HULL PLATING: INACTIVE",
                "DermaDefaultBold", w * 0.5, h * 0.5,
                Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
            return true
        end
        btnPolarize.DoClick = function()
            hullPolarized = not hullPolarized
            surface.PlaySound(hullPolarized and "buttons/button14.wav" or "buttons/button10.wav")
        end

        -- ── Weapons fire section ──────────────────────────────────────────────
        local firePanel = vgui.Create("DPanel", frame)
        firePanel:SetPos(10, 244)
        firePanel:SetSize(460, 120)
        firePanel.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, COL_SECTION)
            draw.RoundedBox(6, 0, 0, w, 22, COL_SECTION_HDR)
            draw.SimpleText(
                "WEAPONS FIRE",
                "DermaDefaultBold", 8, 11,
                Color(215, 155, 155), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
        end

        -- Fire Torpedoes button
        local btnFireTorp = vgui.Create("DButton", firePanel)
        btnFireTorp:SetPos(8, 30); btnFireTorp:SetSize(216, 78)
        btnFireTorp:SetFont("DermaDefaultBold")
        btnFireTorp.Paint = function(self, w, h)
            local enabled = torpedoArmed
            local col = enabled and COL_FIRE or COL_FIRE_OFF
            draw.RoundedBox(6, 0, 0, w, h, col)
            draw.SimpleText(
                "FIRE TORPEDOES",
                "DermaDefaultBold", w * 0.5, h * 0.5 - 8,
                Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
            draw.SimpleText(
                torpedoArmed and "[ ARMED ]" or "[ NOT ARMED ]",
                "DermaDefault", w * 0.5, h * 0.5 + 10,
                torpedoArmed and Color(180, 255, 180) or Color(200, 100, 100),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
            return true
        end
        btnFireTorp.DoClick = function()
            if not torpedoArmed then
                surface.PlaySound("buttons/button8.wav")
                return
            end
            net.Start("tactical_fire_torpedo")
            net.SendToServer()
        end

        -- Fire DEW button
        local btnFireDEW = vgui.Create("DButton", firePanel)
        btnFireDEW:SetPos(236, 30); btnFireDEW:SetSize(216, 78)
        btnFireDEW:SetFont("DermaDefaultBold")
        btnFireDEW.Paint = function(self, w, h)
            local enabled = dewArmed
            local col = enabled and COL_FIRE or COL_FIRE_OFF
            draw.RoundedBox(6, 0, 0, w, h, col)
            draw.SimpleText(
                "FIRE FBX-9 D.E.W.",
                "DermaDefaultBold", w * 0.5, h * 0.5 - 8,
                Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
            draw.SimpleText(
                dewArmed and "[ ARMED ]" or "[ NOT ARMED ]",
                "DermaDefault", w * 0.5, h * 0.5 + 10,
                dewArmed and Color(180, 255, 180) or Color(200, 100, 100),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
            )
            return true
        end
        btnFireDEW.DoClick = function()
            if not dewArmed then
                surface.PlaySound("buttons/button8.wav")
                return
            end
            net.Start("tactical_fire_dew")
            net.SendToServer()
        end

        -- ── Status bar ────────────────────────────────────────────────────────
        local lStatus = vgui.Create("DLabel", frame)
        lStatus:SetPos(12, 372); lStatus:SetSize(456, 18)
        lStatus:SetText("Arm weapons before firing.")
        lStatus:SetTextColor(Color(180, 110, 110))
        lStatus:SetFont("DermaDefault")

        frame.OnClose = function()
            SHRPTactical._TacticalPanel = nil
        end

        -- Refresh relay status periodically while panel is open
        timer.Create("SHRPTacticalRelayPoll", 2, 0, function()
            if not IsValid(frame) then
                timer.Remove("SHRPTacticalRelayPoll")
                return
            end
            UpdateRelayStatus()
        end)
    end
end
