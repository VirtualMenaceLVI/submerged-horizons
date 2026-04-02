if SERVER then

    util.AddNetworkString("eng_open")
    util.AddNetworkString("eng_update")
    util.AddNetworkString("eng_request")

    -- Persistent system values
    EngineeringSystems = EngineeringSystems or {
        Sensors = 50,
        Engines = 50,
        Weapons = 50,
        Communications = 50,
        Lighting = 50,
        Enabled = true
    }

    -- Send values when GUI opens
    net.Receive("eng_request", function(len, ply)
        net.Start("eng_open")
        net.WriteTable(EngineeringSystems)
        net.Send(ply)
    end)

    -- Update values
    net.Receive("eng_update", function(len, ply)

        local system = net.ReadString()
        local value = net.ReadFloat()

        if EngineeringSystems[system] ~= nil then
            EngineeringSystems[system] = value
        end

        if system == "Enabled" then
            EngineeringSystems.Enabled = net.ReadBool()
        end
    end)

end


if CLIENT then

    local values = {}

    concommand.Add("open_engineering", function()

        net.Start("eng_request")
        net.SendToServer()

    end)

    net.Receive("eng_open", function()

        values = net.ReadTable()

        local frame = vgui.Create("DFrame")
        frame:SetSize(450, 400)
        frame:Center()
        frame:SetTitle("ENGINEERING CONTROL")
        frame:MakePopup()

        frame.Paint = function(self,w,h)
            draw.RoundedBox(6,0,0,w,h,Color(20,25,35))
            draw.RoundedBox(6,0,0,w,30,Color(0,120,180))
        end

        local y = 40

        local function CreateSlider(name)

            local slider = vgui.Create("DNumSlider", frame)
            slider:SetPos(20, y)
            slider:SetSize(410, 40)

            slider:SetText(name)
            slider:SetMin(0)
            slider:SetMax(100)
            slider:SetDecimals(0)
            slider:SetValue(values[name] or 50)

            slider.OnValueChanged = function(self,val)

                net.Start("eng_update")
                net.WriteString(name)
                net.WriteFloat(val)
                net.SendToServer()

            end

            y = y + 50
        end


        CreateSlider("Sensors")
        CreateSlider("Engines")
        CreateSlider("Weapons")
        CreateSlider("Communications")
        CreateSlider("Lighting")


        local toggle = vgui.Create("DButton", frame)
        toggle:SetPos(20, y + 10)
        toggle:SetSize(410, 40)

        toggle:SetText("MASTER SYSTEM TOGGLE")

        toggle.DoClick = function()

            values.Enabled = not values.Enabled

            net.Start("eng_update")
            net.WriteString("Enabled")
            net.WriteBool(values.Enabled)
            net.SendToServer()

        end

    end)

end
