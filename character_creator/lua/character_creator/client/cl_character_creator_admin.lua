/*
    Addon id: 6caa0056-2e1c-4a99-9ba2-8bb2fe3a0232
    Version: v1.5.7 (stable)
*/


function CharacterCreator.AdminMenu(v)
    if CharacterCreator.RankToOpenAdmin[LocalPlayer():GetUserGroup()] then 
        local CharacterCreatorFrame = vgui.Create( "DFrame" )
        CharacterCreatorFrame:SetSize( ScrW() * 0.23, ScrH() * 0.36 )
        CharacterCreatorFrame:Center()
        CharacterCreatorFrame:SetTitle( "" )
        CharacterCreatorFrame:MakePopup()
        CharacterCreatorFrame:SetDraggable( true )
        CharacterCreatorFrame:ShowCloseButton( false )
        CharacterCreatorFrame.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, CharacterCreator.Colors["gray235"] )
            draw.RoundedBox( 0, 0, 0, w, ScrH() * 0.037, CharacterCreator.Colors["black240"] )
            draw.SimpleText( "Character Creator - Admin", "chc_kobralost_2", ScrW() * 0.203, ScrH() * 0, CharacterCreator.Colors["white"], TEXT_ALIGN_RIGHT )
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d90b40d7d178e5adda34201e534657c97e623b5b60bb31ab0498b85eaf4bace5
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d90b40d7d178e5adda34201e534657c97e623b5b60bb31ab0498b85eaf4bace5

        local CharacterCreatorClose = vgui.Create( "DButton", CharacterCreatorFrame )
        CharacterCreatorClose:SetSize( ScrW() * 0.02, ScrH() * 0.035 )
        CharacterCreatorClose:SetPos( CharacterCreatorFrame:GetWide() * 0.92, 0 )
        CharacterCreatorClose:SetText( "X" )
        CharacterCreatorClose:SetTextColor( CharacterCreator.Colors["white"] )
        CharacterCreatorClose:SetFont( "chc_kobralost_2" )
        CharacterCreatorClose.Paint = function( self, w, h ) end
        CharacterCreatorClose.DoClick = function()
            CharacterCreatorFrame:Remove()
        end

        local CharacterCreatorDCombox = vgui.Create( "DComboBox", CharacterCreatorFrame )
        CharacterCreatorDCombox:SetSize( ScrW() * 0.2, ScrH() * 0.05 )
        CharacterCreatorDCombox:SetPos( ScrW() * 0.016, ScrH() * 0.057 )
        CharacterCreatorDCombox:SetValue( CharacterCreator.GetSentence("chooseCharacter") )

        if v:GetNWString("CharacterCreator1") == "Player1Create" then 
            CharacterCreatorDCombox:AddChoice("Character #1")
        end 
        if v:GetNWString("CharacterCreator2") == "Player2Create" then 
            CharacterCreatorDCombox:AddChoice("Character #2")
        end 
        if v:GetNWString("CharacterCreator3") == "Player3Create" then 
            CharacterCreatorDCombox:AddChoice("Character #3")
        end 
        CharacterCreatorDCombox:SetTextColor( CharacterCreator.Colors["white"] )
        CharacterCreatorDCombox:SetFont( "chc_kobralost_2" )
        CharacterCreatorDCombox:SetContentAlignment( 5 )
        CharacterCreatorDCombox.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, CharacterCreator.Colors["black190"] )
            surface.SetDrawColor(CharacterCreator.Colors["white50"])
            surface.DrawOutlinedRect( 0, 0, ScrW() * 0.2, ScrH() * 0.05 )
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 15478a1827bdd0ab07064f24626a05e7e8fa2b4b1e33baa627f3f8cb0b843238

        local CharacterCreatorName = vgui.Create( "DTextEntry", CharacterCreatorFrame )
        CharacterCreatorName:SetSize( ScrW() * 0.2, ScrH() * 0.05 )
        CharacterCreatorName:SetPos( ScrW() * 0.016, ScrH() * 0.115 )
        CharacterCreatorName:SetText( CharacterCreator.GetSentence("noDataFounded") )
        CharacterCreatorName:SetTextColor( CharacterCreator.Colors["white"] )
        CharacterCreatorName:SetFont( "chc_kobralost_2" )
        CharacterCreatorName:SetDrawLanguageID( false )
        CharacterCreatorName:SetEditable(false)
    	CharacterCreatorName.Paint = function(self,w,h)
    		draw.RoundedBox( 0, 0, 0, w, h, CharacterCreator.Colors["black190"] )
            surface.SetDrawColor(CharacterCreator.Colors["white50"])
            surface.DrawOutlinedRect( 0, 0, ScrW() * 0.2, ScrH() * 0.05 )
            self:DrawTextEntryText(CharacterCreator.Colors["white"], CharacterCreator.Colors["gray"], CharacterCreator.Colors["white"])
    	end

        local CharacterCreatorMoney = vgui.Create( "DTextEntry", CharacterCreatorFrame )
        CharacterCreatorMoney:SetSize( ScrW() * 0.2, ScrH() * 0.05 )
        CharacterCreatorMoney:SetPos( ScrW() * 0.016, ScrH() * 0.173 )
        CharacterCreatorMoney:SetText( CharacterCreator.GetSentence("noDataFounded") )
        CharacterCreatorMoney:SetTextColor( CharacterCreator.Colors["white"] )
        CharacterCreatorMoney:SetFont( "chc_kobralost_2" )
        CharacterCreatorMoney:SetDrawLanguageID( false )
        CharacterCreatorMoney:SetEditable(false)
        CharacterCreatorMoney.Paint = function(self,w,h)
    		draw.RoundedBox( 0, 0, 0, w, h, CharacterCreator.Colors["black190"] )
            surface.SetDrawColor(CharacterCreator.Colors["white50"])
            surface.DrawOutlinedRect( 0, 0, ScrW() * 0.2, ScrH() * 0.05 )
            self:DrawTextEntryText(CharacterCreator.Colors["white"], CharacterCreator.Colors["gray"], CharacterCreator.Colors["white"])
    	end
        net.Receive("CharacterCreator:CharacterAdmin", function(len, ply)
            local CharacterCreatorTable = net.ReadTable()
            CharacterCreatorName:SetText( CharacterCreatorTable["CharacterCreatorName"] )
            CharacterCreatorMoney:SetText( CharacterCreatorTable["CharacterCreatorSaveMoney"] )
        end ) 

        CharacterCreatorDCombox.OnSelect = function( self, index, value )
            CharacterCreatorMoney:SetEditable(true)
            CharacterCreatorName:SetEditable(true)
            net.Start("CharacterCreator:CharacterAdmin")
            net.WriteBool(false)
            net.WriteString("CharacterCreator:RecupData")
            net.WriteString(value)
            net.WriteEntity(v)
            net.SendToServer()
        end

        local CharacterCreatorUpdate = vgui.Create( "DButton", CharacterCreatorFrame )
        CharacterCreatorUpdate:SetSize( ScrW() * 0.2, ScrH() * 0.05 )
        CharacterCreatorUpdate:SetPos( ScrW() * 0.016, ScrH() * 0.23 )
        CharacterCreatorUpdate:SetText( CharacterCreator.GetSentence("update") )
        CharacterCreatorUpdate:SetTextColor( CharacterCreator.Colors["white"] )
        CharacterCreatorUpdate:SetFont( "chc_kobralost_2" )
        CharacterCreatorUpdate:SetContentAlignment( 5 )
        CharacterCreatorUpdate.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, CharacterCreator.Colors["green"] )
            surface.SetDrawColor(CharacterCreator.Colors["white50"])
            surface.DrawOutlinedRect( 0, 0, ScrW() * 0.2, ScrH() * 0.05 )
        end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 15478a1827bdd0ab07064f24626a05e7e8fa2b4b1e33baa627f3f8cb0b843238

        CharacterCreatorUpdate.DoClick = function()
        	local CharacterCreatorMoney = tonumber(CharacterCreatorMoney:GetValue())
        	if not isnumber(CharacterCreatorMoney) then return end 
        	net.Start("CharacterCreator:CharacterAdmin")
        	net.WriteBool(true)
        	net.WriteString(CharacterCreatorDCombox:GetValue())
        	net.WriteString(CharacterCreatorName:GetValue())
        	net.WriteEntity(v)
        	net.WriteInt(CharacterCreatorMoney, 32)
        	net.SendToServer()
        	CharacterCreatorFrame:Remove()
        end 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e7470ef06f6b9f4cb7eb859aac9e04a5e1ab282313d4b3d8c10765ed2d3173a9

        local CharacterCreatorSuppr = vgui.Create( "DButton", CharacterCreatorFrame )
        CharacterCreatorSuppr:SetSize( ScrW() * 0.2, ScrH() * 0.05 )
        CharacterCreatorSuppr:SetPos( ScrW() * 0.016, ScrH() * 0.289 )
        CharacterCreatorSuppr:SetText( CharacterCreator.GetSentence("delete") )
        CharacterCreatorSuppr:SetTextColor( CharacterCreator.Colors["white"] )
        CharacterCreatorSuppr:SetFont( "chc_kobralost_2" )
        CharacterCreatorSuppr:SetContentAlignment( 5 )
        CharacterCreatorSuppr.Paint = function( self, w, h )
            draw.RoundedBox( 0, 0, 0, w, h, CharacterCreator.Colors["red"] )
            surface.SetDrawColor(CharacterCreator.Colors["white50"])
            surface.DrawOutlinedRect( 0, 0, ScrW() * 0.2, ScrH() * 0.05 )
        end
        CharacterCreatorSuppr.DoClick = function()
            net.Start("CharacterCreator:CharacterAdmin")
            net.WriteBool(false)
            net.WriteString("CharacterCreator:RemoveData")
            net.WriteString(CharacterCreatorDCombox:GetValue())
            net.WriteEntity(v)
            net.SendToServer()
            CharacterCreatorFrame:Remove()
        end 
    end
end

net.Receive("CharacterCreator:MenuAdminOpen", function(len, ply) 
    local CharacterCreatorEntity = net.ReadEntity()
    CharacterCreator.AdminMenu(CharacterCreatorEntity)
end)
