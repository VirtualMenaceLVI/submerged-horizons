if SERVER then AddCSLuaFile() end

-- ─────────────────────────────────────────────────────────────────────────────
-- SHRP Scanner Tool  –  marks any entity as scannable by the Hand Scanner
-- ─────────────────────────────────────────────────────────────────────────────
TOOL.Category   = "SHRP"
TOOL.Name       = "Scanner Tool"
TOOL.Command    = nil
TOOL.ConfigName = ""

if CLIENT then
    language.Add("Tool.scanner_tool.name", "Scanner Tool")
    language.Add("Tool.scanner_tool.desc",
        "Mark any prop as scannable. Left-click to inspect; right-click to set / edit scan data.")
    language.Add("Tool.scanner_tool.0",
        "Left-click to inspect scan data. Right-click to assign or edit scan data.")
end

-- ── Left-click: inspect current scan data ────────────────────────────────────
function TOOL:LeftClick(trace)
    if SERVER then return true end
    local ent = trace.Entity
    if not IsValid(ent) then return false end

    local name   = ent:GetNWString("ScanName",   "")
    local result = ent:GetNWString("ScanResult", "")
    if name == "" then
        chat.AddText(Color(200, 200, 200), "[Scanner Tool] This object is not yet scannable.")
    else
        chat.AddText(
            Color(100, 210, 255), "[Scanner Tool] ",
            Color(255, 255, 255), "Name: ", Color(200, 230, 255), name,
            Color(255, 255, 255), "  |  Result: ", Color(180, 220, 190), result
        )
    end
    return true
end

-- ── Right-click: open edit UI ─────────────────────────────────────────────────
function TOOL:RightClick(trace)
    if SERVER then return true end
    local ent = trace.Entity
    if not IsValid(ent) then return false end

    -- Avoid opening duplicate frames
    if IsValid(SHRPSensors._ScannerToolFrame) then SHRPSensors._ScannerToolFrame:Close() end

    local existingName   = ent:GetNWString("ScanName",   "")
    local existingResult = ent:GetNWString("ScanResult", "")

    local frame = vgui.Create("DFrame")
    SHRPSensors._ScannerToolFrame = frame
    frame:SetTitle("Set Scan Data  –  " .. ent:GetClass())
    frame:SetSize(400, 240)
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)

    frame.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(10, 16, 26, 252))
        draw.RoundedBox(10, 0, 0, w, 38, Color(0, 130, 80, 220))
        draw.SimpleText(
            "SCANNER TOOL  –  Set Scannable Data",
            "DermaDefaultBold", w * 0.5, 19,
            Color(180, 255, 215), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
        )
    end

    local lName = vgui.Create("DLabel", frame)
    lName:SetPos(14, 46); lName:SetSize(372, 20); lName:SetText("Scan Name:")
    lName:SetTextColor(Color(180, 210, 240))

    local eName = vgui.Create("DTextEntry", frame)
    eName:SetPos(14, 66); eName:SetSize(372, 22)
    eName:SetPlaceholderText("e.g. Unknown Vessel, Bio-reading, Anomaly…")
    eName:SetValue(existingName)

    local lResult = vgui.Create("DLabel", frame)
    lResult:SetPos(14, 96); lResult:SetSize(372, 20); lResult:SetText("Scan Result:")
    lResult:SetTextColor(Color(180, 210, 240))

    local eResult = vgui.Create("DTextEntry", frame)
    eResult:SetPos(14, 116); eResult:SetSize(372, 64)
    eResult:SetMultiline(true)
    eResult:SetPlaceholderText("Describe what is detected when scanned…")
    eResult:SetValue(existingResult)

    local bSave = vgui.Create("DButton", frame)
    bSave:SetPos(14, 192); bSave:SetSize(180, 30)
    bSave:SetText("Save")
    bSave:SetFont("DermaDefaultBold")
    bSave.DoClick = function()
        local n, r = eName:GetValue(), eResult:GetValue()
        if n == "" then
            chat.AddText(Color(255, 120, 120), "[Scanner Tool] Name cannot be empty.")
            return
        end
        net.Start("sensors_set_scannable")
        net.WriteEntity(ent)
        net.WriteString(n)
        net.WriteString(r)
        net.SendToServer()
        frame:Close()
    end

    local bClear = vgui.Create("DButton", frame)
    bClear:SetPos(206, 192); bClear:SetSize(180, 30)
    bClear:SetText("Clear (make unscannable)")
    bClear.DoClick = function()
        net.Start("sensors_set_scannable")
        net.WriteEntity(ent)
        net.WriteString("")
        net.WriteString("")
        net.SendToServer()
        frame:Close()
    end

    return true
end

-- ── Tool panel (left-side info box) ──────────────────────────────────────────
if CLIENT then
    function TOOL.BuildCPanel(panel)
        panel:AddControl("Header", {
            Description = "Use this tool to make any prop scannable by the Hand Scanner.\n\n" ..
                          "• Left-click  – Inspect current scan data\n" ..
                          "• Right-click – Set or edit scan name & result"
        })
    end
end