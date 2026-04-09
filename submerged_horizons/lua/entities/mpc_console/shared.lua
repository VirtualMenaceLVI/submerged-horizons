ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "MPC Console"
ENT.Author = "Submerged Horizons"
ENT.Category = "Submerged Horizons"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_OPAQUE

local function GetDefaultSystems()
    return {
        Sensors = {power = 100, enabled = true},
        Engines = {power = 100, enabled = true},
        Weapons = {power = 100, enabled = true},
        Communications = {power = 100, enabled = true},
        Lighting = {power = 75, enabled = true}
    }
end

if SERVER then
    AddCSLuaFile()

    function ENT:Initialize()
        self:SetModel("models/props_lab/servers.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(true)
        self:SetUseType(SIMPLE_USE)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
        end
    end

    function ENT:SpawnFunction(ply, tr)
        if not tr.Hit then return end

        local ent = ents.Create("mpc_console")
        ent:SetPos(tr.HitPos + tr.HitNormal * 16)
        ent:SetAngles(Angle(0, ply:EyeAngles().y - 90, 0))
        ent:Spawn()
        ent:Activate()

        return ent
    end

    function ENT:Use(activator)
        if not IsValid(activator) or not activator:IsPlayer() then return end
        if not activator:Alive() then return end

        local systems = EngineeringSystems
        if not istable(systems) then
            systems = GetDefaultSystems()
        end

        net.Start("eng_open")
        net.WriteTable(systems)
        net.Send(activator)
    end
else
    function ENT:Draw()
        self:DrawModel()

        local ang = self:GetAngles()
        ang:RotateAroundAxis(ang:Up(), 90)
        ang:RotateAroundAxis(ang:Forward(), 90)

        local pos = self:GetPos() + self:GetUp() * 12 + self:GetForward() * 8

        cam.Start3D2D(pos, ang, 0.08)
            draw.RoundedBox(8, -90, -45, 180, 90, Color(10, 20, 36, 230))
            draw.SimpleText("MPC CONSOLE", "DermaLarge", 0, -24, Color(120, 210, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("PRESS E TO ACCESS", "DermaDefaultBold", 0, 10, Color(170, 210, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end
