if SERVER then AddCSLuaFile() end

-- Tool for making scannable objects
TOOL.Category = "SHRP"
TOOL.Name = "Scanner Tool"
TOOL.Command = nil
TOOL.ConfigName = ""

if CLIENT then
    language.Add("Tool.scanner_tool.name", "Scanner Tool")
    language.Add("Tool.scanner_tool.desc", "Make objects scannable with custom name and result.")
    language.Add("Tool.scanner_tool.0", "Left-click to select object, right-click to set properties.")
end

function TOOL:LeftClick(trace)
    if CLIENT then return true end
    local ent = trace.Entity
    if not IsValid(ent) then return false end
    self:SetObject(1, ent, trace.HitPos, trace.HitNormal, 0, 0)
    return true
end

function TOOL:RightClick(trace)
    if CLIENT then return true end
    local ent = self:GetEnt(1)
    if not IsValid(ent) then return false end

    -- Open menu to set name and result
    local ply = self:GetOwner()
    net.Start("sensors_open_set_scan")
    net.WriteEntity(ent)
    net.Send(ply)
    return true
end