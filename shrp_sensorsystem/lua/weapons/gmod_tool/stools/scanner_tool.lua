if SERVER then AddCSLuaFile() end

-- ─────────────────────────────────────────────────────────────────────────────
-- SHRP Scanner Tool  –  marks any entity as scannable by the Hand Scanner
-- ─────────────────────────────────────────────────────────────────────────────
TOOL.Category   = "SHRP"
TOOL.Name       = "Scanner Tool"
TOOL.Command    = nil
TOOL.ConfigName = ""

-- Client-side storage for the values entered in the tool panel
local _scanToolName   = ""
local _scanToolResult = ""

if CLIENT then
    language.Add("Tool.scanner_tool.name", "Scanner Tool")
    language.Add("Tool.scanner_tool.desc",
        "Mark any prop as scannable. Left-click to inspect; right-click to apply the scan name and result from the tool panel.")
    language.Add("Tool.scanner_tool.0",
        "Left-click to inspect scan data. Right-click to apply scan data from the tool panel to the entity.")
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

-- ── Right-click: apply scan data from the tool panel to the entity ────────────
function TOOL:RightClick(trace)
    if SERVER then return true end
    local ent = trace.Entity
    if not IsValid(ent) then return false end

    if _scanToolName == "" then
        chat.AddText(Color(255, 160, 60), "[Scanner Tool] Enter a Scan Name in the tool panel first.")
        return false
    end

    net.Start("sensors_set_scannable")
    net.WriteEntity(ent)
    net.WriteString(_scanToolName)
    net.WriteString(_scanToolResult)
    net.SendToServer()

    chat.AddText(
        Color(100, 210, 255), "[Scanner Tool] ",
        Color(255, 255, 255), "Applied scan data to ",
        Color(200, 230, 255), ent:GetClass()
    )
    return true
end

-- ── Tool panel (left-side tool menu) ─────────────────────────────────────────
if CLIENT then
    function TOOL.BuildCPanel(panel)
        panel:AddControl("Header", {
            Description = "Use this tool to make any prop scannable by the Hand Scanner.\n\n" ..
                          "• Left-click  – Inspect current scan data\n" ..
                          "• Right-click – Apply the name and result below to the entity"
        })

        -- Scan Name label
        local lName = vgui.Create("DLabel", panel)
        lName:SetText("Scan Name:")
        lName:SetTextColor(Color(180, 210, 240))
        lName:SetTall(20)
        panel:AddItem(lName)

        -- Scan Name text entry
        local eName = vgui.Create("DTextEntry", panel)
        eName:SetTall(22)
        eName:SetPlaceholderText("e.g. Unknown Vessel, Bio-reading, Anomaly…")
        eName.OnChange = function(self)
            _scanToolName = self:GetValue()
        end
        panel:AddItem(eName)

        -- Scan Result label
        local lResult = vgui.Create("DLabel", panel)
        lResult:SetText("Scan Result:")
        lResult:SetTextColor(Color(180, 210, 240))
        lResult:SetTall(20)
        panel:AddItem(lResult)

        -- Scan Result text entry (multiline)
        local eResult = vgui.Create("DTextEntry", panel)
        eResult:SetTall(72)
        eResult:SetMultiline(true)
        eResult:SetPlaceholderText("Describe what is detected when scanned…")
        eResult.OnChange = function(self)
            _scanToolResult = self:GetValue()
        end
        panel:AddItem(eResult)

        -- Clear button
        local bClear = vgui.Create("DButton", panel)
        bClear:SetTall(26)
        bClear:SetText("Clear (right-click entity to make unscannable)")
        bClear.DoClick = function()
            eName:SetValue("")
            eResult:SetValue("")
            _scanToolName   = ""
            _scanToolResult = ""
        end
        panel:AddItem(bClear)
    end
end