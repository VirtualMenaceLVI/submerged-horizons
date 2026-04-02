if SERVER then
    AddCSLuaFile()
end

if SERVER then
    util.AddNetworkString("comms_open_panel")
    util.AddNetworkString("comms_request_hail_player")
    util.AddNetworkString("comms_request_hail_all")
    util.AddNetworkString("comms_hail_incoming")
    util.AddNetworkString("comms_hail_started")
    util.AddNetworkString("comms_hail_ended")
end

SHRPComms = SHRPComms or {}
SHRPComms.ActiveCalls = SHRPComms.ActiveCalls or {}
SHRPComms.CallByPlayer = SHRPComms.CallByPlayer or {}
SHRPComms.PendingHails = SHRPComms.PendingHails or {}
SHRPComms.PendingByInitiator = SHRPComms.PendingByInitiator or {}
SHRPComms.NextCallID = SHRPComms.NextCallID or 0

function SHRPComms.GetCommunicationsRelayPercent()
    local relays = ents.FindByClass("relay_communications")
    if #relays == 0 then
        return 0
    end

    local total, count = 0, 0
    for _, ent in ipairs(relays) do
        if IsValid(ent) then
            local health = ent:Health()
            local maxHealth = ent.MaxHealth or 100
            total = total + math.Clamp(health / maxHealth * 100, 0, 100)
            count = count + 1
        end
    end

    if count == 0 then
        return 0
    end

    return math.max(0, total / count)
end

function SHRPComms.IsPlayerBusy(ply)
    if not IsValid(ply) or not ply:IsPlayer() then
        return true
    end

    local sid = ply:SteamID()
    return SHRPComms.CallByPlayer[sid] ~= nil or SHRPComms.PendingHails[sid] ~= nil or SHRPComms.PendingByInitiator[sid] ~= nil
end

function SHRPComms.RemovePendingHailFor(targetSid)
    if not targetSid then
        return
    end

    local pending = SHRPComms.PendingHails[targetSid]
    if not pending then
        return
    end

    local initSid = pending.initiator and pending.initiator:SteamID()
    if initSid then
        SHRPComms.PendingByInitiator[initSid] = nil
    end
    SHRPComms.PendingHails[targetSid] = nil
end

function SHRPComms.CreatePendingHail(initiator, target)
    if not IsValid(initiator) or not IsValid(target) then
        return false
    end

    if SHRPComms.IsPlayerBusy(initiator) or SHRPComms.IsPlayerBusy(target) then
        return false
    end

    if SHRPComms.GetCommunicationsRelayPercent() < 25 then
        return false
    end

    local pending = {
        initiator = initiator,
        target = target,
        created = CurTime(),
        type = "private"
    }

    SHRPComms.PendingHails[target:SteamID()] = pending
    SHRPComms.PendingByInitiator[initiator:SteamID()] = pending

    net.Start("comms_hail_incoming")
    net.WriteString(initiator:Nick())
    net.Send(target)

    initiator:ChatPrint("Hailing " .. target:Nick() .. ". They must use a communications console to accept.")
    return true
end

function SHRPComms.CreatePrivateCall(initiator, target)
    if not IsValid(initiator) or not IsValid(target) then
        return nil
    end

    SHRPComms.NextCallID = SHRPComms.NextCallID + 1
    local call = {
        id = SHRPComms.NextCallID,
        initiator = initiator,
        participants = {initiator, target},
        type = "private"
    }

    SHRPComms.ActiveCalls[call.id] = call
    SHRPComms.CallByPlayer[initiator:SteamID()] = call
    SHRPComms.CallByPlayer[target:SteamID()] = call

    for _, ply in ipairs(call.participants) do
        if IsValid(ply) then
            net.Start("comms_hail_started")
            net.WriteString("private")
            net.WriteString(initiator:Nick())
            net.WriteString(target:Nick())
            net.Send(ply)
        end
    end

    initiator:ChatPrint("Private comms established with " .. target:Nick() .. ".")
    target:ChatPrint("Private comms established with " .. initiator:Nick() .. ".")
    return call
end

function SHRPComms.CreateGroupCall(initiator)
    if not IsValid(initiator) then
        return nil
    end

    SHRPComms.NextCallID = SHRPComms.NextCallID + 1
    local participants = {}
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            table.insert(participants, ply)
        end
    end

    local call = {
        id = SHRPComms.NextCallID,
        initiator = initiator,
        participants = participants,
        type = "all"
    }

    SHRPComms.ActiveCalls[call.id] = call
    for _, ply in ipairs(participants) do
        SHRPComms.CallByPlayer[ply:SteamID()] = call
        net.Start("comms_hail_started")
        net.WriteString("all")
        net.WriteString(initiator:Nick())
        net.WriteString("")
        net.Send(ply)
    end

    initiator:ChatPrint("All-personnel intercom active.")
    return call
end

function SHRPComms.EndCall(call)
    if not call or not SHRPComms.ActiveCalls[call.id] then
        return
    end

    for _, ply in ipairs(call.participants) do
        if IsValid(ply) and SHRPComms.CallByPlayer[ply:SteamID()] == call then
            SHRPComms.CallByPlayer[ply:SteamID()] = nil
            net.Start("comms_hail_ended")
            net.WriteString(call.type)
            net.WriteString(call.initiator and call.initiator:Nick() or "")
            net.Send(ply)
        end
    end

    SHRPComms.ActiveCalls[call.id] = nil
end

function SHRPComms.AcceptPendingHail(target)
    local pending = SHRPComms.PendingHails[target:SteamID()]
    if not pending or not IsValid(pending.initiator) or not IsValid(target) then
        SHRPComms.RemovePendingHailFor(target:SteamID())
        return false
    end

    SHRPComms.RemovePendingHailFor(target:SteamID())
    return SHRPComms.CreatePrivateCall(pending.initiator, target)
end

function SHRPComms.RemovePlayerFromComms(ply)
    if not IsValid(ply) then
        return
    end

    local sid = ply:SteamID()
    local activeCall = SHRPComms.CallByPlayer[sid]
    if activeCall then
        SHRPComms.EndCall(activeCall)
    end

    if SHRPComms.PendingHails[sid] then
        SHRPComms.RemovePendingHailFor(sid)
    end

    local pending = SHRPComms.PendingByInitiator[sid]
    if pending then
        SHRPComms.RemovePendingHailFor(pending.target:SteamID())
    end
end

function SHRPComms.CanUseComms(ply)
    return IsValid(ply) and ply:IsPlayer() and SHRPComms.GetCommunicationsRelayPercent() >= 25
end

if SERVER then
    net.Receive("comms_request_hail_player", function(len, ply)
        local target = net.ReadEntity()
        if not IsValid(target) or not target:IsPlayer() or target == ply then
            return
        end

        if not SHRPComms.CanUseComms(ply) then
            ply:ChatPrint("Communications relays are too weak to complete the hail.")
            return
        end

        if SHRPComms.IsPlayerBusy(ply) then
            ply:ChatPrint("You are already on a communications request or call.")
            return
        end

        if SHRPComms.IsPlayerBusy(target) then
            ply:ChatPrint(target:Nick() .. " is already on a call or awaiting a hail.")
            return
        end

        SHRPComms.CreatePendingHail(ply, target)
    end)

    net.Receive("comms_request_hail_all", function(len, ply)
        if not SHRPComms.CanUseComms(ply) then
            ply:ChatPrint("Communications relays are too weak to complete the hail.")
            return
        end

        if SHRPComms.IsPlayerBusy(ply) then
            ply:ChatPrint("You are already on a communications request or call.")
            return
        end

        SHRPComms.CreateGroupCall(ply)
    end)

    hook.Add("PlayerDisconnected", "SHRPCommsCleanup", function(ply)
        SHRPComms.RemovePlayerFromComms(ply)
    end)

    hook.Add("PlayerCanHearPlayersVoice", "SHRPCommsVoiceControl", function(listener, talker)
        local listenerCall = SHRPComms.CallByPlayer[listener:SteamID()]
        local talkerCall = SHRPComms.CallByPlayer[talker:SteamID()]
        if listenerCall or talkerCall then
            if listenerCall == talkerCall then
                return true
            end
            return false
        end
    end)
end

if CLIENT then
    local pendingHail = {}
    local activeComm = nil

    net.Receive("comms_open_panel", function()
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Communications Console")
        frame:SetSize(420, 220)
        frame:Center()
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)

        frame.Paint = function(self, w, h)
            draw.RoundedBox(12, 0, 0, w, h, Color(18, 22, 32, 245))
            draw.RoundedBox(12, 0, 0, w, 40, Color(10, 110, 175, 220))
            draw.SimpleText("COMMUNICATIONS PANEL", "DermaDefaultBold", 14, 12, Color(230, 240, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local info = vgui.Create("DLabel", frame)
        info:SetPos(20, 50)
        info:SetSize(380, 20)
        info:SetText("Use this console to hail a player or all personnel.")
        info:SetTextColor(Color(215, 225, 235))
        info:SetFont("DermaDefault")

        local hailPlayer = vgui.Create("DButton", frame)
        hailPlayer:SetPos(20, 80)
        hailPlayer:SetSize(380, 32)
        hailPlayer:SetText("Hail Player")
        hailPlayer.DoClick = function()
            local playersFrame = vgui.Create("DFrame")
            playersFrame:SetTitle("Select Target")
            playersFrame:SetSize(300, 320)
            playersFrame:Center()
            playersFrame:MakePopup()
            playersFrame:SetDraggable(true)
            playersFrame:ShowCloseButton(true)

            local y = 40
            for _, ply in ipairs(player.GetAll()) do
                if ply ~= LocalPlayer() then
                    local btn = vgui.Create("DButton", playersFrame)
                    btn:SetPos(20, y)
                    btn:SetSize(260, 28)
                    btn:SetText(ply:Nick())
                    btn.DoClick = function()
                        net.Start("comms_request_hail_player")
                        net.WriteEntity(ply)
                        net.SendToServer()
                        playersFrame:Close()
                        frame:Close()
                    end
                    y = y + 34
                end
            end
        end

        local hailAll = vgui.Create("DButton", frame)
        hailAll:SetPos(20, 120)
        hailAll:SetSize(380, 32)
        hailAll:SetText("Hail All Personnel")
        hailAll.DoClick = function()
            net.Start("comms_request_hail_all")
            net.SendToServer()
            frame:Close()
        end

        local deckButton = vgui.Create("DButton", frame)
        deckButton:SetPos(20, 160)
        deckButton:SetSize(380, 32)
        deckButton:SetText("Deck-by-Deck Hail (Disabled)")
        deckButton:SetEnabled(false)
    end)

    net.Receive("comms_hail_incoming", function()
        local from = net.ReadString()
        pendingHail = {
            from = from,
            expires = CurTime() + 12
        }
        surface.PlaySound("buttons/button17.wav")
        chat.AddText(Color(150, 220, 255), "Incoming hail from ", Color(255, 255, 255), from, Color(150, 220, 255), ". Use a communications console to accept.")
    end)

    net.Receive("comms_hail_started", function()
        local typ = net.ReadString()
        local initiator = net.ReadString()
        local targetName = net.ReadString()

        if typ == "private" then
            if initiator == LocalPlayer():Nick() then
                activeComm = {type = typ, label = "Private comms with " .. targetName}
            else
                activeComm = {type = typ, label = "Private comms with " .. initiator}
            end
            chat.AddText(Color(100, 255, 120), "Private communications established.")
        else
            activeComm = {type = typ, label = "All-personnel intercom from " .. initiator}
            chat.AddText(Color(100, 255, 120), "All-personnel intercom active.")
        end
    end)

    net.Receive("comms_hail_ended", function()
        activeComm = nil
        local typ = net.ReadString()
        local initiator = net.ReadString()
        if typ == "all" then
            chat.AddText(Color(255, 150, 150), "Intercom ended by " .. initiator .. ".")
        else
            chat.AddText(Color(255, 150, 150), "Private comms ended.")
        end
    end)

    hook.Add("HUDPaint", "SHRPCommsHUD", function()
        if pendingHail.from and CurTime() < pendingHail.expires then
            draw.RoundedBox(8, 8, ScrH() - 68, 320, 32, Color(15, 20, 30, 220))
            draw.SimpleText("You are being hailed by: " .. pendingHail.from, "DermaDefaultBold", 16, ScrH() - 54, Color(170, 220, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        if activeComm then
            draw.RoundedBox(8, 8, ScrH() - 108, 340, 32, Color(15, 20, 30, 220))
            draw.SimpleText(activeComm.label, "DermaDefaultBold", 16, ScrH() - 94, Color(120, 255, 160), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end)
end
