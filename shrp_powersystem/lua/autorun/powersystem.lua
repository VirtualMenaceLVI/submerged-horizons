if SERVER then
    AddCSLuaFile()

    util.AddNetworkString("eng_open")
    util.AddNetworkString("eng_update")
    util.AddNetworkString("eng_request")
    util.AddNetworkString("relay_repair_open")
    util.AddNetworkString("relay_repair_submit")

    local SYSTEM_SAVE_PATH = "shrp_powersystem/engineering_systems.txt"

    local function GetDefaultSystems()
        return {
            Sensors = {power = 100, enabled = true},
            Engines = {power = 100, enabled = true},
            Weapons = {power = 100, enabled = true},
            Communications = {power = 100, enabled = true},
            Lighting = {power = 75, enabled = true}
        }
    end

    local function LoadEngineeringSystems()
        if file.Exists(SYSTEM_SAVE_PATH, "DATA") then
            local contents = file.Read(SYSTEM_SAVE_PATH, "DATA")
            local data = util.JSONToTable(contents or "")
            if istable(data) then
                EngineeringSystems = data
                return
            end
        end

        EngineeringSystems = GetDefaultSystems()
        file.CreateDir("shrp_powersystem")
        file.Write(SYSTEM_SAVE_PATH, util.TableToJSON(EngineeringSystems, true))
    end

    local function SaveEngineeringSystems()
        if not EngineeringSystems then return end
        file.CreateDir("shrp_powersystem")
        file.Write(SYSTEM_SAVE_PATH, util.TableToJSON(EngineeringSystems, true))
    end

    LoadEngineeringSystems()

    local RelaySystemClasses = {
        Sensors = "relay_sensors",
        Engines = "relay_engineering",
        Weapons = "relay_weapons",
        Communications = "relay_communications",
        Lighting = "relay_lighting"
    }

    -- Expected number of relays per system. Missing or destroyed relays reduce
    -- the maximum capacity proportionally (e.g. 1 of 2 sensor relays down = 50%).
    local RelayExpectedCounts = {
        Sensors        = 2,
        Weapons        = 4,
        Communications = 2,
        Lighting       = 8
    }

    local function GetRelayCapacity(system)
        local class    = RelaySystemClasses[system]
        local expected = RelayExpectedCounts[system]

        if not class then
            return 100
        end

        -- Systems without a defined relay count use the old average-health logic.
        if not expected then
            local relays = ents.FindByClass(class)
            if #relays == 0 then return 100 end
            local totalHealth, count = 0, 0
            for _, ent in ipairs(relays) do
                if IsValid(ent) then
                    local maxHealth = ent.MaxHealth or 100
                    totalHealth = totalHealth + math.Clamp(ent:Health() / maxHealth * 100, 0, 100)
                    count = count + 1
                end
            end
            return count > 0 and math.max(0, totalHealth / count) or 100
        end

        -- Sum up the health contribution of every found relay. Missing relays
        -- (fewer placed than expected) contribute 0, reducing capacity further.
        local totalHealth = 0
        for _, ent in ipairs(ents.FindByClass(class)) do
            if IsValid(ent) then
                local maxHealth = ent.MaxHealth or 100
                totalHealth = totalHealth + math.Clamp(ent:Health() / maxHealth * 100, 0, 100)
            end
        end

        return math.max(0, totalHealth / expected)
    end

    local function BuildEngineeringPacket()
        local packet = {}
        for system, data in pairs(EngineeringSystems) do
            packet[system] = {
                power = data.power,
                enabled = data.enabled,
                max = math.ceil(GetRelayCapacity(system))
            }
        end
        return packet
    end

    net.Receive("eng_request", function(len, ply)
        net.Start("eng_open")
        net.WriteTable(BuildEngineeringPacket())
        net.Send(ply)
    end)

    net.Receive("eng_update", function(len, ply)
        local system = net.ReadString()
        local power = net.ReadFloat()
        local enabled = net.ReadBool()

        if EngineeringSystems[system] and isnumber(power) and type(enabled) == "boolean" then
            local maxPower = GetRelayCapacity(system)
            EngineeringSystems[system].enabled = enabled
            EngineeringSystems[system].power = enabled and math.Clamp(power, 0, maxPower) or 0
            SaveEngineeringSystems()
        end
    end)

    net.Receive("relay_repair_submit", function(len, ply)
        local ent = net.ReadEntity()
        local success = net.ReadBool()

        if not IsValid(ent) or not ent:IsValid() or not ent:IsDamaged() or not success then
            return
        end

        if ent:GetClass():StartWith("relay_") then
            ent:Repair()
            ply:ChatPrint("Relay repaired successfully.")
        end
    end)

else
    net.Receive("eng_open", function()
        local values = net.ReadTable()
        if not istable(values) then return end

        local frame = vgui.Create("DFrame")
        frame:SetSize(560, 460)
        frame:Center()
        frame:SetTitle("")
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)

        frame.Paint = function(self, w, h)
            draw.RoundedBox(12, 0, 0, w, h, Color(15, 18, 26, 240))
            draw.RoundedBoxEx(12, 0, 0, w, 60, Color(10, 120, 210, 220), true, true, false, false)
            draw.SimpleText("MASTER POWER CONTROL", "Trebuchet24", w * 0.5, 24, Color(230, 240, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("ENGINEERING GRID", "DermaDefaultBold", 20, 72, Color(160, 210, 255, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            surface.SetDrawColor(Color(40, 80, 120, 150))
            for i = 1, 5 do
                local rowY = 100 + (i - 1) * 55
                surface.DrawOutlinedRect(18, rowY, w - 36, 50)
            end
        end

        local y = 100
        local rowHeight = 50

        local function CreateSystem(name)
            local data = values[name] or {power = 0, enabled = false, max = 100}
            data.max = math.max(0, data.max or 100)
            data.power = math.min(data.power or 0, data.max)

            local label = vgui.Create("DLabel", frame)
            label:SetPos(30, y + 10)
            label:SetSize(180, 30)
            label:SetText(name)
            label:SetFont("DermaLarge")
            label:SetTextColor(Color(200, 220, 255))

            local slider = vgui.Create("DNumSlider", frame)
            slider:SetPos(180, y)
            slider:SetSize(280, rowHeight)
            slider:SetText("")
            slider:SetMin(0)
            slider:SetMax(data.max)
            slider:SetDecimals(0)
            slider:SetValue(data.power)
            slider:SetEnabled(data.enabled)

            local maxLabel = vgui.Create("DLabel", frame)
            maxLabel:SetPos(180, y + 30)
            maxLabel:SetSize(280, 18)
            maxLabel:SetText("Max " .. data.max .. "%")
            maxLabel:SetFont("DermaDefault")
            maxLabel:SetTextColor(Color(180, 200, 255))

            local toggle = vgui.Create("DButton", frame)
            toggle:SetPos(475, y + 7)
            toggle:SetSize(70, 36)
            toggle:SetText(data.enabled and "ONLINE" or "OFFLINE")

            local function UpdateToggleAppearance()
                if data.enabled then
                    toggle:SetText("ONLINE")
                    toggle:SetTextColor(Color(20, 200, 90))
                    toggle:SetColor(Color(30, 40, 50))
                else
                    toggle:SetText("OFFLINE")
                    toggle:SetTextColor(Color(255, 105, 105))
                    toggle:SetColor(Color(30, 40, 50))
                end
            end

            UpdateToggleAppearance()

            slider.OnValueChanged = function(self, val)
                if not data.enabled then return end
                val = math.Clamp(val, 0, self:GetMax())
                data.power = val
                self:SetValue(val)
                net.Start("eng_update")
                net.WriteString(name)
                net.WriteFloat(val)
                net.WriteBool(true)
                net.SendToServer()
            end

            toggle.DoClick = function()
                data.enabled = not data.enabled
                if data.enabled then
                    slider:SetEnabled(true)
                    slider:SetValue(math.max(data.power, 1))
                else
                    slider:SetEnabled(false)
                    slider:SetValue(0)
                    data.power = 0
                end
                UpdateToggleAppearance()
                net.Start("eng_update")
                net.WriteString(name)
                net.WriteFloat(data.power)
                net.WriteBool(data.enabled)
                net.SendToServer()
            end

            y = y + rowHeight + 5
        end

        CreateSystem("Sensors")
        CreateSystem("Engines")
        CreateSystem("Weapons")
        CreateSystem("Communications")
        CreateSystem("Lighting")
    end)

    net.Receive("relay_repair_open", function()
        local ent = net.ReadEntity()
        local systemName = net.ReadString()
        if not IsValid(ent) then return end

        local frame = vgui.Create("DFrame")
        frame:SetSize(420, 360)
        frame:Center()
        frame:SetTitle("Relay Repair: " .. systemName)
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)

        frame.Paint = function(self, w, h)
            draw.RoundedBox(12, 0, 0, w, h, Color(18, 22, 32, 240))
            draw.RoundedBox(12, 0, 0, w, 48, Color(0, 120, 180, 220))
        end

        local colors = {"Red", "Green", "Blue", "Yellow"}
        local colorMap = {
            Red = Color(200, 80, 80),
            Green = Color(80, 200, 80),
            Blue = Color(80, 120, 220),
            Yellow = Color(220, 200, 80)
        }

        local sequence = {}
        local currentStep = 1
        local round = 1
        local waitingForInput = false
        local maxRounds = 5

        local statusLabel = vgui.Create("DLabel", frame)
        statusLabel:SetPos(20, 50)
        statusLabel:SetSize(380, 24)
        statusLabel:SetFont("DermaDefaultBold")
        statusLabel:SetTextColor(Color(220, 220, 255))
        statusLabel:SetText("Watch the sequence.")

        local function SetStatus(text)
            if IsValid(statusLabel) then
                statusLabel:SetText(text)
            end
        end

        local buttons = {}
        local function CreateColorButton(name, x)
            local btn = vgui.Create("DButton", frame)
            btn:SetPos(x, 90)
            btn:SetSize(90, 90)
            btn:SetText(name)
            btn:SetTextColor(Color(255, 255, 255))
            btn.Active = false
            btn:SetDisabled(true)
            btn.Paint = function(self, w, h)
                local base = colorMap[name]
                local bg = self.Active and Color(255, 255, 255) or base
                draw.RoundedBox(8, 0, 0, w, h, bg)
                draw.SimpleText(name, "DermaDefaultBold", w * 0.5, h * 0.5, self.Active and Color(0, 0, 0) or Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            btn.DoClick = function()
                if not waitingForInput then return end
                if sequence[currentStep] == name then
                    currentStep = currentStep + 1
                    if currentStep > #sequence then
                        if round >= maxRounds then
                            SetStatus("Sequence complete! Relay repaired.")
                            net.Start("relay_repair_submit")
                            net.WriteEntity(ent)
                            net.WriteBool(true)
                            net.SendToServer()
                            timer.Simple(1, function()
                                if IsValid(frame) then
                                    frame:Close()
                                end
                            end)
                            return
                        end

                        round = round + 1
                        SetStatus("Correct! Prepare for round " .. round .. ".")
                        waitingForInput = false
                        currentStep = 1
                        timer.Simple(1.2, function()
                            if IsValid(frame) then
                                table.insert(sequence, colors[math.random(#colors)])
                                PlaySequence()
                            end
                        end)
                        return
                    end
                    SetStatus("Correct! Step " .. currentStep .. " / " .. #sequence)
                else
                    SetStatus("Wrong sequence. Repair failed.")
                    waitingForInput = false
                    for _, b in pairs(buttons) do
                        b:SetDisabled(true)
                    end
                    timer.Simple(1.5, function()
                        if IsValid(frame) then
                            frame:Close()
                        end
                    end)
                end
            end

            buttons[name] = btn
        end

        CreateColorButton("Red", 30)
        CreateColorButton("Green", 130)
        CreateColorButton("Blue", 230)
        CreateColorButton("Yellow", 330)

        local function SetButtonsEnabled(enabled)
            for _, btn in pairs(buttons) do
                btn:SetDisabled(not enabled)
            end
        end

        local function FlashButton(name)
            if not IsValid(buttons[name]) then return end
            local btn = buttons[name]
            btn.Active = true
            btn:SetDisabled(true)
            timer.Simple(0.5, function()
                if not IsValid(btn) then return end
                btn.Active = false
            end)
        end

        function PlaySequence()
            SetButtonsEnabled(false)
            SetStatus("Watch the sequence.")
            waitingForInput = false
            local delay = 0

            for i, colorName in ipairs(sequence) do
                timer.Simple(delay, function()
                    if not IsValid(frame) then return end
                    FlashButton(colorName)
                end)
                delay = delay + 0.8
            end

            timer.Simple(delay, function()
                if not IsValid(frame) then return end
                SetStatus("Repeat the sequence.")
                waitingForInput = true
                currentStep = 1
                SetButtonsEnabled(true)
            end)
        end

        table.insert(sequence, colors[math.random(#colors)])
        PlaySequence()
    end)
end