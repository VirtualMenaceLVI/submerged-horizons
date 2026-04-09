/*
    Addon id: 6caa0056-2e1c-4a99-9ba2-8bb2fe3a0232
    Version: v1.5.7 (stable)
*/

local CharacterCreatorNationality = 1
local CharacterCreatorSaveSexe = CharacterCreator.GetSentence("male")
local CharacterCreatorModelCreate = CharacterCreator.Models[1][1]
local CharacterCreatorMaterials = Material( "materials/CharacterCreatorPlus.png" ) 

local function ClothesModeCompatibility(Frame, id)
	if CharacterCreator.CompatibilityClothesMod then 
		if not istable(CharacterCreatorTab[id]) or not istable(CharacterCreatorTab[id][ "CharacterCreatorClothing" ]) then return end 

		local infos = CharacterCreatorTab[id][ "CharacterCreatorClothing" ]
		local datas 
		if infos.sex == 1 then
			datas = CLOTHESMOD.Male.ListDefaultPM[infos.model]
		else
			datas = CLOTHESMOD.Female.ListDefaultPM[infos.model]
		end
		Frame:SetModel( infos.model )
		 
		local tindex = datas.bodygroupstop[infos.bodygroups.top].tee
		local pindex = datas.bodygroupsbottom[infos.bodygroups.pant].pant
		local eindex = datas.eyes
		local bodygroups = {
			datas.bodygroupstop[infos.bodygroups.top].group,
			datas.bodygroupsbottom[infos.bodygroups.pant].group
		}
		local skin = infos.skin
		local ent = Frame.Entity
		local pcolor = infos.playerColor
		local tops = infos.teetexture.basetexture
		local pants = infos.panttexture.basetexture
		ent:SetSkin( skin )
		for k, v in pairs( bodygroups ) do
			ent:SetBodygroup( v[1], v[2] )
		end
		for k, v in pairs( tindex ) do
			ent:SetSubMaterial( v, tops )
		end
		for k, v in pairs( pindex ) do
			ent:SetSubMaterial( v, pants )
		end

		ent.GetPlayerColor = function() return pcolor end
			
		for k, v in pairs( infos.eyestexture ) do
			
			local matr = v["r"]
			local matl = v["l"]
			local indexr = eindex["r"]
			local indexl = eindex["l"]
			ent:SetSubMaterial( indexr, matr )
			ent:SetSubMaterial( indexl, matl )
		end
	end 
end 

function CharacterCreator.MenuSpawn(CHCBool)
	RunConsoleCommand("stopsound")
	if CharacterCreator.MusicMenuActivate then 
		sound.PlayURL( CharacterCreator.MusicMenu, "", 
		function( station )
			if IsValid( station ) then
				station:Play()
				station:SetVolume(CharacterCreator.MusicMenuVolume)
			end 
		end )
	end 
	local CharacterCreatorRemoveConfirmation1 = nil
	local CharacterCreatorRemoveConfirmation2 = nil
	local CharacterCreatorRemoveConfirmation3 = nil
	local CharacterCreatorIdSave = nil

	if IsValid(CharacterFrameBaseParent) then CharacterFrameBaseParent:Remove() end 

	CharacterFrameBaseParent = vgui.Create("DFrame")
	CharacterFrameBaseParent:SetSize(ScrW()*1, ScrH()*1)
	CharacterFrameBaseParent:SetPos(0,0)
	CharacterFrameBaseParent:ShowCloseButton(false)
	CharacterFrameBaseParent:SetDraggable(false)
	CharacterFrameBaseParent:SetTitle("")
	CharacterFrameBaseParent:MakePopup()
	gui.EnableScreenClicker(true)
	CharacterFrameBaseParent.Paint = function(self,w,h) end 

	local CharacterCreatorFrameBlack = vgui.Create( "DPanel", CharacterFrameBaseParent )
	CharacterCreatorFrameBlack:SetSize( ScrW()*1, ScrH()*1 )
	CharacterCreatorFrameBlack:SetPos(0,0)
	CharacterCreatorFrameBlack:SetBackgroundColor( CharacterCreator.Colors["black"] )

	local CharacterCreatorImage = vgui.Create( "Material", CharacterCreatorFrameBlack )
	CharacterCreatorImage:SetPos( 0, 0 )
	CharacterCreatorImage:SetSize( ScrW()*1, ScrH()*1 )
	CharacterCreatorImage:SetMaterial( CharacterCreator.BackImage )
	CharacterCreatorImage.AutoSize = false

	local CharacterCreatorMenuSpawn = vgui.Create("DPanel", CharacterFrameBaseParent)
	CharacterCreatorMenuSpawn:SetSize(ScrW()*1, ScrH()*1)
	CharacterCreatorMenuSpawn:SetPos(0,0)
	CharacterCreatorMenuSpawn.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black160"])
		draw.DrawText(CharacterCreator.GetSentence("welcomeOnTheServer"), "chc_kobralost_2",ScrW()*0.035, ScrH()*0.23, CharacterCreator.Colors["white"], TEXT_ALIGN_LEFT)
		draw.DrawText(CharacterCreator.GetSentence("startAdventure"), "chc_kobralost_1",ScrW()*0.034, ScrH()*0.16, CharacterCreator.Colors["white"], TEXT_ALIGN_LEFT)
	end 

	local CharacterCreatorEntete = vgui.Create("DPanel", CharacterFrameBaseParent)
	CharacterCreatorEntete:SetSize(ScrW()*0.95, ScrH()*0.1)
	CharacterCreatorEntete:SetPos(ScrW()*0.03,ScrH()*0.03)
	CharacterCreatorEntete.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black140"])
		surface.SetDrawColor(CharacterCreator.Colors["black180"])
		surface.DrawOutlinedRect( 0, 0, w, h )
	end

	local CharacterCreatorModel = vgui.Create( "DModelPanel", CharacterFrameBaseParent )
	CharacterCreatorModel:SetPos(  ScrW() * 0.7, ScrH() * 0.2 )
	CharacterCreatorModel:SetSize( ScrW() * 0.2, ScrH() * 0.7 )
	CharacterCreatorModel:SetFOV( 6.4 )
	CharacterCreatorModel:SetCamPos( Vector( 310, 100, 45 ) )
	CharacterCreatorModel:SetLookAt( Vector( 0, 0, 36 ) )
	CharacterCreatorModel:SetModel( CharacterCreatorModelCreate )
	function CharacterCreatorModel:LayoutEntity( ent ) end
	local CharacterCreatorModelEnt = CharacterCreatorModel:GetEntity()
	CharacterCreatorModelEnt:SetupBones()

	if LocalPlayer().TSGetTrainingInfo && LocalPlayer():TSGetTrainingInfo() then
		local boneUpdate = {}
		for _, training in ipairs(Diablos.TS.TrainingsChangingBone) do
			boneUpdate[training] = {level = Diablos.TS:GetTrainingLevel(training, LocalPlayer()), reset = false}
		end
		Diablos.TS:RefreshBones(CharacterCreatorModelEnt, boneUpdate)
	end

	for i=1,3 do 
		local CharacterCreatorButton = vgui.Create("DButton", CharacterFrameBaseParent)
		CharacterCreatorButton:SetText("\n \n "..CharacterCreator.GetSentence("createCharacter"))
		CharacterCreatorButton:SetFont("chc_kobralost_2")
		CharacterCreatorButton:SetTextColor(CharacterCreator.Colors["white"])
		CharacterCreatorButton:SetSize(ScrW()*0.2, ScrH()*0.5)
		if i == 1 then
			if LocalPlayer():GetNWString("CharacterCreator1") == "Player1Create" then 
				CharacterCreatorButton:Remove()
				local CharacterCreatorDPanelInfo1 = vgui.Create("DPanel", CharacterFrameBaseParent)
				CharacterCreatorDPanelInfo1:SetPos(ScrW()*0.03, ScrH()*0.3)
				CharacterCreatorDPanelInfo1:SetSize(ScrW()*0.2, ScrH()*0.5)
				CharacterCreatorDPanelInfo1.Paint = function(self,w,h)
					draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
					if isstring(CharacterCreatorTab[1]["CharacterCreatorName"]) then 
						draw.DrawText(CharacterCreatorTab[1]["CharacterCreatorName"], "chc_kobralost_2",CharacterCreatorDPanelInfo1:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
					else 
						draw.DrawText("NILL NILL", "chc_kobralost_2",CharacterCreatorDPanelInfo1:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
					end 
				end 
				if CharacterCreator.PlayerCanDeleteCharacter then 
					local CharacterCreatorRemove = vgui.Create("DButton", CharacterCreatorDPanelInfo1)
					CharacterCreatorRemove:SetPos(CharacterCreatorDPanelInfo1:GetWide()*0.91, 0 ) 
					CharacterCreatorRemove:SetSize(ScrW()*0.02, ScrH()*0.03)
					CharacterCreatorRemove:SetText("")
					CharacterCreatorRemove:SetImage( "icon16/status_busy.png" )
					CharacterCreatorRemove.Paint = function() end 
					CharacterCreatorRemove.DoClick = function()
						CharacterCreatorRemove:SetImage( "icon16/accept.png" )
						timer.Simple(0.1, function()
							CharacterCreatorRemoveConfirmation1 = 1 
						end ) 
						if CharacterCreatorRemoveConfirmation1 == 1 then
							net.Start("CharacterCreator:DeleteCharacterClient")
							net.WriteInt(i, 8)
							net.SendToServer()
							CharacterFrameBaseParent:Remove()
						end 
					end 
				end 
				local CharacterCreatorModelLoad1 = vgui.Create( "DModelPanel", CharacterFrameBaseParent )
				CharacterCreatorModelLoad1:SetPos(ScrW()*0.03, ScrH()*0.32)
				CharacterCreatorModelLoad1:SetSize(ScrW()*0.2, ScrH()*0.5)
				CharacterCreatorModelLoad1:SetFOV( 12 )
				CharacterCreatorModelLoad1:SetCamPos( Vector( 310, 10, 45 ) )
				CharacterCreatorModelLoad1:SetLookAt( Vector( 0, 0, 36 ) )
				if not CharacterCreator.CharacterJobModelNotSave[CharacterCreatorTab[1][ "CharacterCreatorSaveJob" ]] then
					if isstring(CharacterCreatorTab[1]["CharacterCreatorModel"]) then 
						CharacterCreatorModelLoad1:SetModel( CharacterCreatorTab[1]["CharacterCreatorModel"] )
						CharacterCreatorModelLoad1.Entity:SetBodygroup(1, CharacterCreatorTab[1][ "CharacterCreatorTorseId" ])
						CharacterCreatorModelLoad1.Entity:SetBodygroup(2, CharacterCreatorTab[1][ "CharacterCreatorGlovesId" ])
						CharacterCreatorModelLoad1.Entity:SetBodygroup(3, CharacterCreatorTab[1][ "CharacterCreatorTrousersId" ])
						CharacterCreatorModelLoad1.Entity:SetBodygroup(5, CharacterCreatorTab[1][ "CharacterCreatorHeadId" ])
						if CharacterCreator.CompatibilityClothesMod then 
							ClothesModeCompatibility(CharacterCreatorModelLoad1, 1)
						end 
					else 
						CharacterCreatorModelLoad1:SetModel( CharacterCreatorModelCreate )
					end 
				else
					if isstring(CharacterCreatorTab[1]["CharacterCreatorModelJob"]) then 
				 		CharacterCreatorModelLoad1:SetModel( CharacterCreatorTab[1]["CharacterCreatorModelJob"] )
					else
						CharacterCreatorModelLoad1:SetModel( CharacterCreatorModelCreate )
					end 
				end 
				function CharacterCreatorModelLoad1:LayoutEntity( ent ) end
				
				if Diablos && Diablos.TS then
					local CharacterCreatorModelEnt1 = CharacterCreatorModelLoad1:GetEntity()
					CharacterCreatorModelEnt1:SetupBones()

					local trainingData = CharacterCreatorTab[1]["CharacterCreatorDiablosTraining"]
					if trainingData then
						trainingData = trainingData.Trainings
						local boneUpdate = {}
						for _, training in ipairs(Diablos.TS.TrainingsChangingBone) do
							if trainingData[training] then
								local curLevel = Diablos.TS:GetTrainingLevel(training, trainingData[training].xp)
								boneUpdate[training] = {level = curLevel, reset = false}
							end
						end
						Diablos.TS:RefreshBones(CharacterCreatorModelEnt1, boneUpdate)
					end
				end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 15478a1827bdd0ab07064f24626a05e7e8fa2b4b1e33baa627f3f8cb0b843238

				CharacterCreatorModelLoad1.DoClick = function()
					CharacterCreatorIdSave = 1
					if not CharacterCreator.CharacterJobModelNotSave[CharacterCreatorTab[1][ "CharacterCreatorSaveJob" ]] then
						if isstring(CharacterCreatorTab[1]["CharacterCreatorModel"]) then 
							CharacterCreatorModel:SetModel( CharacterCreatorTab[1]["CharacterCreatorModel"] )
							CharacterCreatorModel.Entity:SetBodygroup(1, CharacterCreatorTab[1][ "CharacterCreatorTorseId" ])
							CharacterCreatorModel.Entity:SetBodygroup(2, CharacterCreatorTab[1][ "CharacterCreatorGlovesId" ])
							CharacterCreatorModel.Entity:SetBodygroup(3, CharacterCreatorTab[1][ "CharacterCreatorTrousersId" ])
							CharacterCreatorModel.Entity:SetBodygroup(5, CharacterCreatorTab[1][ "CharacterCreatorHeadId" ])
							if CharacterCreator.CompatibilityClothesMod then 
								ClothesModeCompatibility(CharacterCreatorModel, 1)
							end 

							if Diablos && Diablos.TS then
								CharacterCreatorModel.Entity:SetupBones()
								local trainingData = CharacterCreatorTab[1]["CharacterCreatorDiablosTraining"]
								if trainingData then
									trainingData = trainingData.Trainings
									local boneUpdate = {}
									for _, training in ipairs(Diablos.TS.TrainingsChangingBone) do
										if trainingData[training] then
											local curLevel = Diablos.TS:GetTrainingLevel(training, trainingData[training].xp)
											boneUpdate[training] = {level = curLevel, reset = false}
										end
									end
									Diablos.TS:RefreshBones(CharacterCreatorModel.Entity, boneUpdate)
								end
							end

						else 
							CharacterCreatorModel:SetModel( CharacterCreatorModelCreate )
						end 
					else
					 	if isstring(CharacterCreatorTab[1]["CharacterCreatorModelJob"]) then 
				 			CharacterCreatorModel:SetModel( CharacterCreatorTab[1]["CharacterCreatorModelJob"] )
						else
							CharacterCreatorModelLoad1:SetModel( CharacterCreatorModelCreate )
						end 
					end 
					CharacterCreatorDPanelInfo1.Paint = function(self,w,h)
						if CharacterCreatorIdSave == 1 then 
							draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
							if isstring(CharacterCreatorTab[1]["CharacterCreatorName"]) then 
								draw.DrawText(CharacterCreatorTab[1]["CharacterCreatorName"], "chc_kobralost_2",CharacterCreatorDPanelInfo1:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
							else 
								draw.DrawText("NILL NILL", "chc_kobralost_2",CharacterCreatorDPanelInfo1:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
							end 
							surface.SetDrawColor(CharacterCreator.Colors["whitegray"])
							surface.DrawOutlinedRect( 0, 0, w, h )
						else 
							draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
							if isstring(CharacterCreatorTab[1]["CharacterCreatorName"]) then 
								draw.DrawText(CharacterCreatorTab[1]["CharacterCreatorName"], "chc_kobralost_2",CharacterCreatorDPanelInfo1:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
							else 
								draw.DrawText("NILL NILL", "chc_kobralost_2",CharacterCreatorDPanelInfo1:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
							end 
						end
					end 
				end  
			else 
				CharacterCreatorButton:SetPos(ScrW()*0.03*i, ScrH()*0.3)
				CharacterCreatorButton.DoClick = function()
					if not CharacterCreator.CompatibilityClothesMod then 
						CharacterFrameBaseParent:Remove()	
						CharacterCreator.CreateCharacter(i)
						surface.PlaySound( "UI/buttonclick.wav" )
					else 
						CharacterFrameBaseParent:Remove()	
						CM_OpenNewCharacterGUI()
						local CharacterCreatorTableEmpty = {}
						net.Start("CharacterCreator:SaveFirst")
						net.WriteTable(CharacterCreatorTableEmpty)
						net.WriteInt(i, 8)
						net.SendToServer()
						net.Start("CharacterCreator:SaveCharacter")
						net.WriteInt(i, 8)
						net.SendToServer()
					end 
				end 
				CharacterCreatorButton.Paint = function(self,w,h)
					if self:IsHovered() then	
						draw.RoundedBox(10, 0, 0, w, h, CharacterCreator.Colors["blackgray240"])
						surface.SetDrawColor( CharacterCreator.Colors["white"] )	
						surface.SetMaterial( CharacterCreatorMaterials ) 
						surface.DrawTexturedRect( ScrW()*0.082, ScrH()*0.15, 75, 75 )
					else
						draw.RoundedBox(10, 0, 0, w, h, CharacterCreator.Colors["black180"])
						surface.SetDrawColor( CharacterCreator.Colors["white"] )	
						surface.SetMaterial( CharacterCreatorMaterials ) 
						surface.DrawTexturedRect( ScrW()*0.082, ScrH()*0.15, 75, 75 )
					end 
				end 				
			end 
		elseif i == 2 then
			if LocalPlayer():GetNWString("CharacterCreator2") == "Player2Create" then 
				CharacterCreatorButton:Remove()
				local CharacterCreatorDPanelInfo2 = vgui.Create("DPanel", CharacterFrameBaseParent)
				CharacterCreatorDPanelInfo2:SetPos(ScrW()*0.234, ScrH()*0.3)
				CharacterCreatorDPanelInfo2:SetSize(ScrW()*0.2, ScrH()*0.5)
				CharacterCreatorDPanelInfo2.Paint = function(self,w,h)
					draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
					if isstring(CharacterCreatorTab[2]["CharacterCreatorName"]) then 
						draw.DrawText(CharacterCreatorTab[2]["CharacterCreatorName"], "chc_kobralost_2",CharacterCreatorDPanelInfo2:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
					else 
						draw.DrawText("NILL NILL", "chc_kobralost_2",CharacterCreatorDPanelInfo2:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
					end 
				end 	
				if CharacterCreator.PlayerCanDeleteCharacter then 
					local CharacterCreatorRemove = vgui.Create("DButton", CharacterCreatorDPanelInfo2)
					CharacterCreatorRemove:SetPos(CharacterCreatorDPanelInfo2:GetWide()*0.91, 0 ) 
					CharacterCreatorRemove:SetSize(ScrW()*0.02, ScrH()*0.03)
					CharacterCreatorRemove:SetText("")
					CharacterCreatorRemove:SetImage( "icon16/status_busy.png" )
					CharacterCreatorRemove.Paint = function() end 
					CharacterCreatorRemove.DoClick = function()
						CharacterCreatorRemove:SetImage( "icon16/accept.png" )
						timer.Simple(0.1, function()
							CharacterCreatorRemoveConfirmation2 = 1 
						end ) 
						if CharacterCreatorRemoveConfirmation2 == 1 then
							net.Start("CharacterCreator:DeleteCharacterClient")
							net.WriteInt(i, 8)
							net.SendToServer()
							CharacterFrameBaseParent:Remove()
						end 
					end 
				end 
				local CharacterCreatorModelLoad2 = vgui.Create( "DModelPanel", CharacterFrameBaseParent )
				CharacterCreatorModelLoad2:SetPos(ScrW()*0.234, ScrH()*0.32)
				CharacterCreatorModelLoad2:SetSize(ScrW()*0.2, ScrH()*0.5)
				CharacterCreatorModelLoad2:SetFOV( 12 )
				CharacterCreatorModelLoad2:SetCamPos( Vector( 310, 10, 45 ) )
				CharacterCreatorModelLoad2:SetLookAt( Vector( 0, 0, 36 ) )
				if not CharacterCreator.CharacterJobModelNotSave[CharacterCreatorTab[2][ "CharacterCreatorSaveJob" ]] then
					if isstring(CharacterCreatorTab[2]["CharacterCreatorModel"]) then 
						CharacterCreatorModelLoad2:SetModel( CharacterCreatorTab[2]["CharacterCreatorModel"] )
						CharacterCreatorModelLoad2.Entity:SetBodygroup(1, CharacterCreatorTab[2][ "CharacterCreatorTorseId" ])
						CharacterCreatorModelLoad2.Entity:SetBodygroup(2, CharacterCreatorTab[2][ "CharacterCreatorGlovesId" ])
						CharacterCreatorModelLoad2.Entity:SetBodygroup(3, CharacterCreatorTab[2][ "CharacterCreatorTrousersId" ])
						CharacterCreatorModelLoad2.Entity:SetBodygroup(5, CharacterCreatorTab[2][ "CharacterCreatorHeadId" ])
						if CharacterCreator.CompatibilityClothesMod then 
							ClothesModeCompatibility(CharacterCreatorModelLoad2, 2)
						end 
					else 
						CharacterCreatorModelLoad2:SetModel( CharacterCreatorModelCreate )
					end 
				else 
					if isstring(CharacterCreatorTab[2]["CharacterCreatorModelJob"]) then
						CharacterCreatorModelLoad2:SetModel( CharacterCreatorTab[2][ "CharacterCreatorModelJob" ] )
					else
						CharacterCreatorModelLoad2:SetModel( CharacterCreatorModelCreate )
					end 
				end 
				function CharacterCreatorModelLoad2:LayoutEntity( ent ) end

				if Diablos && Diablos.TS then
					local CharacterCreatorModelEnt2 = CharacterCreatorModelLoad2:GetEntity()
					CharacterCreatorModelEnt2:SetupBones()

					local trainingData = CharacterCreatorTab[2]["CharacterCreatorDiablosTraining"]
					if trainingData then
						trainingData = trainingData.Trainings
						local boneUpdate = {}
						for _, training in ipairs(Diablos.TS.TrainingsChangingBone) do
							if trainingData[training] then
								local curLevel = Diablos.TS:GetTrainingLevel(training, trainingData[training].xp)
								boneUpdate[training] = {level = curLevel, reset = false}
							end
						end
						Diablos.TS:RefreshBones(CharacterCreatorModelEnt2, boneUpdate)
					end
				end

				CharacterCreatorModelLoad2.DoClick = function()
					CharacterCreatorIdSave = 2
					if not CharacterCreator.CharacterJobModelNotSave[CharacterCreatorTab[2][ "CharacterCreatorSaveJob" ]] then
						if isstring(CharacterCreatorTab[2]["CharacterCreatorModel"]) then 
							CharacterCreatorModel:SetModel( CharacterCreatorTab[2]["CharacterCreatorModel"] )
							CharacterCreatorModel.Entity:SetBodygroup(1, CharacterCreatorTab[2][ "CharacterCreatorTorseId" ])
							CharacterCreatorModel.Entity:SetBodygroup(2, CharacterCreatorTab[2][ "CharacterCreatorGlovesId" ])
							CharacterCreatorModel.Entity:SetBodygroup(3, CharacterCreatorTab[2][ "CharacterCreatorTrousersId" ])
							CharacterCreatorModel.Entity:SetBodygroup(5, CharacterCreatorTab[2][ "CharacterCreatorHeadId" ])
							if CharacterCreator.CompatibilityClothesMod then 
								ClothesModeCompatibility(CharacterCreatorModel, 2)
							end 

							if Diablos && Diablos.TS then
								CharacterCreatorModel.Entity:SetupBones()
								local trainingData = CharacterCreatorTab[2]["CharacterCreatorDiablosTraining"]
								if trainingData then
									trainingData = trainingData.Trainings
									local boneUpdate = {}
									for _, training in ipairs(Diablos.TS.TrainingsChangingBone) do
										if trainingData[training] then
											local curLevel = Diablos.TS:GetTrainingLevel(training, trainingData[training].xp)
											boneUpdate[training] = {level = curLevel, reset = false}
										end
									end
									Diablos.TS:RefreshBones(CharacterCreatorModel.Entity, boneUpdate)
								end
							end
						else 
							CharacterCreatorModel:SetModel( CharacterCreatorModelCreate )
						end
					else  
						if isstring(CharacterCreatorTab[2]["CharacterCreatorModelJob"]) then
							CharacterCreatorModel:SetModel( CharacterCreatorTab[2]["CharacterCreatorModelJob"] )
						else
							CharacterCreatorModelLoad2:SetModel( CharacterCreatorModelCreate )
						end
					end 
					CharacterCreatorDPanelInfo2.Paint = function(self,w,h)
						if CharacterCreatorIdSave == 2 then 
							draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
							if isstring(CharacterCreatorTab[2]["CharacterCreatorName"]) then 
								draw.DrawText(CharacterCreatorTab[2]["CharacterCreatorName"], "chc_kobralost_2",CharacterCreatorDPanelInfo2:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
							else 
								draw.DrawText("NILL NILL", "chc_kobralost_2",CharacterCreatorDPanelInfo2:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
							end 
							surface.SetDrawColor(CharacterCreator.Colors["whitegray"])
							surface.DrawOutlinedRect( 0, 0, w, h )
						else 
							draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
							if isstring(CharacterCreatorTab[2]["CharacterCreatorName"]) then 
								draw.DrawText(CharacterCreatorTab[2]["CharacterCreatorName"], "chc_kobralost_2",CharacterCreatorDPanelInfo2:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
							else 
								draw.DrawText("NILL NILL", "chc_kobralost_2",CharacterCreatorDPanelInfo2:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
							end 
						end 
					end 
				end 
			else 
				CharacterCreatorButton:SetPos(ScrW()*0.234, ScrH()*0.3)
				CharacterCreatorButton.DoClick = function()
					if CharacterCreator.Character2VIP then 
						if not CharacterCreator.Character2VIPRank[LocalPlayer():GetUserGroup()] then surface.PlaySound( "buttons/combine_button1.wav" ) return end 
					end 
					if not CharacterCreator.CompatibilityClothesMod then 
						CharacterFrameBaseParent:Remove()	
						CharacterCreator.CreateCharacter(i)
						surface.PlaySound( "UI/buttonclick.wav" )
					else 
						local CharacterCreatorTableEmpty = {}
						CharacterFrameBaseParent:Remove()	
						CM_OpenNewCharacterGUI()
						net.Start("CharacterCreator:SaveFirst")
						net.WriteTable(CharacterCreatorTableEmpty)
						net.WriteInt(i, 8)
						net.SendToServer()
						net.Start("CharacterCreator:SaveCharacter")
						net.WriteInt(i, 8)
						net.SendToServer()
					end 
				end 
				CharacterCreatorButton.Paint = function(self, w,h )
					if self:IsHovered() then	
						draw.RoundedBox(10, 0, 0, w, h, CharacterCreator.Colors["blackgray240"])
						surface.SetDrawColor( CharacterCreator.Colors["white"] )	
						surface.SetMaterial( CharacterCreatorMaterials ) 
						surface.DrawTexturedRect( ScrW()*0.082, ScrH()*0.15, 75, 75 )
					else
						draw.RoundedBox(10, 0, 0, w, h, CharacterCreator.Colors["black180"])
						surface.SetDrawColor( CharacterCreator.Colors["white"] )	
						surface.SetMaterial( CharacterCreatorMaterials ) 
						surface.DrawTexturedRect( ScrW()*0.082, ScrH()*0.15, 75, 75 )
					end 
				end 				
			end  
		elseif i == 3 then
			if LocalPlayer():GetNWString("CharacterCreator3") == "Player3Create" then 
				CharacterCreatorButton:Remove()
				local CharacterCreatorDPanelInfo3 = vgui.Create("DPanel", CharacterFrameBaseParent)
				CharacterCreatorDPanelInfo3:SetPos(ScrW()*0.438, ScrH()*0.3)
				CharacterCreatorDPanelInfo3:SetSize(ScrW()*0.2, ScrH()*0.5)
				CharacterCreatorDPanelInfo3.Paint = function(self,w,h)
					draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
					if isstring(CharacterCreatorTab[3]["CharacterCreatorName"]) then 
						draw.DrawText(CharacterCreatorTab[3]["CharacterCreatorName"], "chc_kobralost_2",CharacterCreatorDPanelInfo3:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
					else 
						draw.DrawText("NILL NILL", "chc_kobralost_2",CharacterCreatorDPanelInfo3:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
					end 
				end 
				if CharacterCreator.PlayerCanDeleteCharacter then 
					local CharacterCreatorRemove = vgui.Create("DButton", CharacterCreatorDPanelInfo3)
					CharacterCreatorRemove:SetPos(CharacterCreatorDPanelInfo3:GetWide()*0.91, 0 ) 
					CharacterCreatorRemove:SetSize(ScrW()*0.02, ScrH()*0.03)
					CharacterCreatorRemove:SetText("")
					CharacterCreatorRemove:SetImage( "icon16/status_busy.png" )
					CharacterCreatorRemove.Paint = function() end 
					CharacterCreatorRemove.DoClick = function()
						CharacterCreatorRemove:SetImage( "icon16/accept.png" )
						timer.Simple(0.1, function()
							CharacterCreatorRemoveConfirmation3 = 1 
						end ) 
						if CharacterCreatorRemoveConfirmation3 == 1 then
							net.Start("CharacterCreator:DeleteCharacterClient")
							net.WriteInt(i, 8)
							net.SendToServer()
							CharacterFrameBaseParent:Remove()
						end
					end 
				end 
				local CharacterCreatorModelLoad3 = vgui.Create( "DModelPanel", CharacterFrameBaseParent )
				CharacterCreatorModelLoad3:SetPos(ScrW()*0.438, ScrH()*0.32)
				CharacterCreatorModelLoad3:SetSize(ScrW()*0.2, ScrH()*0.5)
				CharacterCreatorModelLoad3:SetFOV( 12 )
				CharacterCreatorModelLoad3:SetCamPos( Vector( 310, 10, 45 ) )
				CharacterCreatorModelLoad3:SetLookAt( Vector( 0, 0, 36 ) )
				if not CharacterCreator.CharacterJobModelNotSave[CharacterCreatorTab[3][ "CharacterCreatorSaveJob" ]] then
					if isstring(CharacterCreatorTab[3]["CharacterCreatorModel"])  then 
						CharacterCreatorModelLoad3:SetModel( CharacterCreatorTab[3]["CharacterCreatorModel"] )
						CharacterCreatorModelLoad3.Entity:SetBodygroup(1, CharacterCreatorTab[3][ "CharacterCreatorTorseId" ])
						CharacterCreatorModelLoad3.Entity:SetBodygroup(2, CharacterCreatorTab[3][ "CharacterCreatorGlovesId" ])
						CharacterCreatorModelLoad3.Entity:SetBodygroup(3, CharacterCreatorTab[3][ "CharacterCreatorTrousersId" ])
						CharacterCreatorModelLoad3.Entity:SetBodygroup(5, CharacterCreatorTab[3][ "CharacterCreatorHeadId" ])
						if CharacterCreator.CompatibilityClothesMod then 
							ClothesModeCompatibility(CharacterCreatorModelLoad3, 3)
						end 
					else 
						CharacterCreatorModelLoad3:SetModel( CharacterCreatorModelCreate )
					end 
				else 
					if isstring(CharacterCreatorTab[3]["CharacterCreatorModelJob"])  then 
						CharacterCreatorModelLoad3:SetModel( CharacterCreatorTab[3][ "CharacterCreatorModelJob" ] )
					else
						CharacterCreatorModelLoad3:SetModel( CharacterCreatorModelCreate )
					end
				end 
				function CharacterCreatorModelLoad3:LayoutEntity( ent ) end

				if Diablos && Diablos.TS then
					local CharacterCreatorModelEnt3 = CharacterCreatorModelLoad3:GetEntity()
					CharacterCreatorModelEnt3:SetupBones()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- d90b40d7d178e5adda34201e534657c97e623b5b60bb31ab0498b85eaf4bace5

					local trainingData = CharacterCreatorTab[3]["CharacterCreatorDiablosTraining"]
					if trainingData then
						trainingData = trainingData.Trainings
						local boneUpdate = {}
						for _, training in ipairs(Diablos.TS.TrainingsChangingBone) do
							if trainingData[training] then
								local curLevel = Diablos.TS:GetTrainingLevel(training, trainingData[training].xp)
								boneUpdate[training] = {level = curLevel, reset = false}
							end
						end
						Diablos.TS:RefreshBones(CharacterCreatorModelEnt3, boneUpdate)
					end
				end

				CharacterCreatorModelLoad3.DoClick = function()
					CharacterCreatorIdSave = 3
					if not CharacterCreator.CharacterJobModelNotSave[CharacterCreatorTab[3][ "CharacterCreatorSaveJob" ]] then
						if isstring(CharacterCreatorTab[3]["CharacterCreatorModel"]) then 
							CharacterCreatorModel:SetModel( CharacterCreatorTab[3]["CharacterCreatorModel"] )
							CharacterCreatorModel.Entity:SetBodygroup(1, CharacterCreatorTab[3][ "CharacterCreatorTorseId" ])
							CharacterCreatorModel.Entity:SetBodygroup(2, CharacterCreatorTab[3][ "CharacterCreatorGlovesId" ])
							CharacterCreatorModel.Entity:SetBodygroup(3, CharacterCreatorTab[3][ "CharacterCreatorTrousersId" ])
							CharacterCreatorModel.Entity:SetBodygroup(5, CharacterCreatorTab[3][ "CharacterCreatorHeadId" ])
							if CharacterCreator.CompatibilityClothesMod then 
								ClothesModeCompatibility(CharacterCreatorModel, 3)
							end 
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a45b4a0371527980aa45a614f82b3b1b5c437fbaab42e40b73e1d1d0309ff781

							if Diablos && Diablos.TS then
								CharacterCreatorModel.Entity:SetupBones()
								local trainingData = CharacterCreatorTab[3]["CharacterCreatorDiablosTraining"]
								if trainingData then
									trainingData = trainingData.Trainings
									local boneUpdate = {}
									for _, training in ipairs(Diablos.TS.TrainingsChangingBone) do
										if trainingData[training] then
											local curLevel = Diablos.TS:GetTrainingLevel(training, trainingData[training].xp)
											boneUpdate[training] = {level = curLevel, reset = false}
										end
									end
									Diablos.TS:RefreshBones(CharacterCreatorModel.Entity, boneUpdate)
								end
							end
						else 
							CharacterCreatorModel:SetModel( CharacterCreatorModelCreate )
						end 
					else 
						if isstring(CharacterCreatorTab[3]["CharacterCreatorModelJob"])  then 
							CharacterCreatorModel:SetModel( CharacterCreatorTab[3]["CharacterCreatorModelJob"] )
						else
							CharacterCreatorModelLoad3:SetModel( CharacterCreatorModelCreate )
						end
					end
					CharacterCreatorDPanelInfo3.Paint = function(self,w,h)
						if CharacterCreatorIdSave == 3 then 
							draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
							if isstring(CharacterCreatorTab[3]["CharacterCreatorName"]) then 
								draw.DrawText(CharacterCreatorTab[3]["CharacterCreatorName"], "chc_kobralost_2",CharacterCreatorDPanelInfo3:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
							else 
								draw.DrawText("NILL NILL", "chc_kobralost_2",CharacterCreatorDPanelInfo3:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
							end 
							surface.SetDrawColor(CharacterCreator.Colors["whitegray"])
							surface.DrawOutlinedRect( 0, 0, w, h )
						else 
							draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
							if isstring(CharacterCreatorTab[3]["CharacterCreatorName"]) then 
								draw.DrawText(CharacterCreatorTab[3]["CharacterCreatorName"], "chc_kobralost_2",CharacterCreatorDPanelInfo3:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
							else 
								draw.DrawText("NILL NILL", "chc_kobralost_2",CharacterCreatorDPanelInfo3:GetWide()/2, ScrH()*0.03, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER)
							end 
						end
					end 
				end 			
			else 	
				CharacterCreatorButton:SetPos(ScrW()*0.438, ScrH()*0.3)
				CharacterCreatorButton.DoClick = function()	
					if CharacterCreator.Character3VIP then 
						if not CharacterCreator.Character3VIPRank[LocalPlayer():GetUserGroup()] then surface.PlaySound( "buttons/combine_button1.wav" ) return end 
					end 
					if not CharacterCreator.CompatibilityClothesMod then 
						CharacterFrameBaseParent:Remove()	
						CharacterCreator.CreateCharacter(i)
						surface.PlaySound( "UI/buttonclick.wav" )
					else 
						local CharacterCreatorTableEmpty = {}
						CharacterFrameBaseParent:Remove()
						net.Start("CharacterCreator:SaveFirst")
						net.WriteTable(CharacterCreatorTableEmpty)
						net.WriteInt(i, 8)
						net.SendToServer()
						net.Start("CharacterCreator:SaveCharacter")
						net.WriteInt(i, 8)
						net.SendToServer()
						CM_OpenNewCharacterGUI()
					end 
				end
				CharacterCreatorButton.Paint = function(self, w,h )
					if self:IsHovered() then	
						draw.RoundedBox(10, 0, 0, w, h, CharacterCreator.Colors["blackgray240"])
						surface.SetDrawColor(CharacterCreator.Colors["white"])	
						surface.SetMaterial( CharacterCreatorMaterials ) 
						surface.DrawTexturedRect( ScrW()*0.082, ScrH()*0.15, 75, 75 )
					else
						draw.RoundedBox(10, 0, 0, w, h, CharacterCreator.Colors["black180"])
						surface.SetDrawColor(CharacterCreator.Colors["white"])	
						surface.SetMaterial( CharacterCreatorMaterials ) 
						surface.DrawTexturedRect( ScrW()*0.082, ScrH()*0.15, 75, 75 )
					end 
				end 
			end
		end 
	end  
	local CharacterCreatorPlaceText = vgui.Create("DPanel", CharacterFrameBaseParent)
	CharacterCreatorPlaceText:SetSize(ScrW()*0.405, ScrH()*0.16)
	CharacterCreatorPlaceText:SetPos(ScrW()*0.03, ScrH()*0.83)
	CharacterCreatorPlaceText.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h/3, CharacterCreator.Colors["black210"])
		draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
		draw.DrawText(CharacterCreator.GetSentence("welcomeOn").." "..CharacterCreator.NameServer, "chc_kobralost_2",ScrW()*0.01, ScrH()*0.005, CharacterCreator.Colors["white"], TEXT_ALIGN_LEFT)
	end 

	local CharacterCreatorText = vgui.Create( "DLabel", CharacterCreatorPlaceText )
	CharacterCreatorText:SetPos( ScrW()*0.01, ScrH()*0.06 )
	CharacterCreatorText:SetSize( ScrW()*0.40, ScrH()*0.1 )
	CharacterCreatorText:SetFont( "chc_kobralost_4" )
	CharacterCreatorText:SetText( CharacterCreator.Description )	
	CharacterCreatorText:SetTextColor(CharacterCreator.Colors["white150"])
	CharacterCreatorText:SetContentAlignment( 7 ) 
	CharacterCreatorText:SetWrap( true )

	local CharacterCreatorDscrollPanel = vgui.Create("DScrollPanel", CharacterFrameBaseParent)
	CharacterCreatorDscrollPanel:SetSize(ScrW()*0.7, ScrH()*0.1)
	CharacterCreatorDscrollPanel:SetPos(ScrW()*0.03,ScrH()*0.03)
	CharacterCreatorDscrollPanel.Paint = function(self,w,h) end 

	CharacterCreator.FrameButton = {}
	for k,v in pairs(CharacterCreator.Bouttons) do 

		CharacterCreator.FrameButton[k] = vgui.Create("DPanel", CharacterCreatorDscrollPanel)
		CharacterCreator.FrameButton[k]:SetSize(ScrW()*0.14, ScrH()*0.1)
		CharacterCreator.FrameButton[k]:Dock(LEFT)
		CharacterCreator.FrameButton[k]:DockMargin(0, 0, 4, 0)
		CharacterCreator.FrameButton[k].Paint = function(self,w,h) end 
		local CharacterCreatorButtonInfo = vgui.Create("DButton", CharacterCreator.FrameButton[k] )
		CharacterCreatorButtonInfo:SetText(v.NameButton)
		CharacterCreatorButtonInfo:SetFont("chc_kobralost_2")
		CharacterCreatorButtonInfo:SetTextColor(CharacterCreator.Colors["white"])
		CharacterCreatorButtonInfo:SetSize(ScrW()*0.14, ScrH()*0.1)
		CharacterCreatorButtonInfo.Paint = function(self,w,h)	
			if self:IsHovered() then		
				draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["blackgray240"])
			else
				draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black110"])
			end 
		end 
		CharacterCreatorButtonInfo.DoClick = function()
			gui.OpenURL(v.UrlButton)
			surface.PlaySound( "UI/buttonclick.wav" )
		end 
	end

	local CharacterCreatorButtonQuit = vgui.Create("DButton", CharacterCreatorEntete )
	CharacterCreatorButtonQuit:SetFont("chc_kobralost_2")
	CharacterCreatorButtonQuit:SetTextColor(CharacterCreator.Colors["white"])
	CharacterCreatorButtonQuit:SetSize(ScrW()*0.12, ScrH()*0.1)
	CharacterCreatorButtonQuit:SetPos(ScrW()*0.83, 0)
	CharacterCreatorButtonQuit:SetText(CharacterCreator.GetSentence("leave"))
	CharacterCreatorButtonQuit.Paint = function(self,w,h)
		surface.SetDrawColor(CharacterCreator.Colors["gray"])
		surface.DrawOutlinedRect( 0, 0, w, h )
		if self:IsHovered() then		
			draw.RoundedBox(4, 0, 0, w, h, CharacterCreator.Colors["blackgray240"])
		else
			draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black160"])
		end 
	end 
	CharacterCreatorButtonQuit.DoClick = function()
		surface.PlaySound( "buttons/combine_button1.wav" )
		timer.Simple(0.1, function()
			if IsValid(CharacterCreatorButtonQuit) then 
				CharacterCreatorButtonQuit:SetText(CharacterCreator.GetSentence("confirm"))
			end 
		end ) 
		if CharacterCreatorButtonQuit:GetText() == CharacterCreator.GetSentence("confirm") then 
			if not CHCBool then 
				RunConsoleCommand("disconnect")
			else 
				CharacterFrameBaseParent:Remove()
				gui.EnableScreenClicker(false)
			end 
		end 
	end 
	local CharacterCreatorButtonAccept = vgui.Create("DButton", CharacterFrameBaseParent)
	CharacterCreatorButtonAccept:SetSize(ScrW()*0.2, ScrH()*0.1)
	CharacterCreatorButtonAccept:SetPos(ScrW()*0.44, ScrH()*0.83)
	CharacterCreatorButtonAccept:SetText(CharacterCreator.GetSentence("play"))
	CharacterCreatorButtonAccept:SetFont("chc_kobralost_9")
	CharacterCreatorButtonAccept:SetTextColor(CharacterCreator.Colors["white"])
	CharacterCreatorButtonAccept.DoClick = function()
		if CharacterCreatorIdSave == 1 or CharacterCreatorIdSave == 2 or CharacterCreatorIdSave == 3 then 

			net.Start("CharacterCreator:LoadCharacter")
			net.WriteInt(CharacterCreatorIdSave, 8)
			net.SendToServer()

			net.Start("CharacterCreator:SaveCharacter")
			net.WriteInt(CharacterCreatorIdSave, 8)
			net.SendToServer()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e7470ef06f6b9f4cb7eb859aac9e04a5e1ab282313d4b3d8c10765ed2d3173a9

			gui.EnableScreenClicker(false)
			RunConsoleCommand("stopsound")
			CharacterFrameBaseParent:Remove()

			timer.Simple(0.2, function()
				LocalPlayer():ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 255 ), 8, 1.5 )
			end ) 
		else 
			surface.PlaySound( "buttons/combine_button1.wav" )
		end 
	end 
	CharacterCreatorButtonAccept.Paint = function(self,w,h)		
		draw.RoundedBox(10, 0, 0, w, h, CharacterCreator.Colors["black180"])
	end
end 

local function RandomLetters()
    local Letters = "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z"
    local TableL = string.Explode(",", Letters) 
    local String = TableL[math.random( 1, 26 )]
    return String 
end 

local function RandomNumber()
	local Number = math.random(0, 9)
	return Number 
end 

local function CheckCharacter(String)
	local TableLetters = CharacterCreator.LettersAllowed
	local Accept = false 
	for k, v in pairs(TableLetters) do 
		if v == string.upper(String) then 
			Accept = true 
		end 
	end 
	return Accept 
end 

function CharacterCreator.CreateCharacter(id)

	CharacterCreatorSexe = 1
	CharacterCreatorHeadId = 0 
	CharacterCreatorTorseId = 0 
	CharacterCreatorGlovesId = 0 
	CharacterCreatorTrousersId = 0 

	local CharacterFrameBaseParent = vgui.Create("DFrame")
	CharacterFrameBaseParent:SetSize(ScrW()*1, ScrH()*1)
	CharacterFrameBaseParent:SetPos(0,0)
	CharacterFrameBaseParent:ShowCloseButton(true)
	CharacterFrameBaseParent:SetDraggable(false)
	CharacterFrameBaseParent:SetTitle("")
	CharacterFrameBaseParent:MakePopup()
	gui.EnableScreenClicker(true)
	CharacterFrameBaseParent.Paint = function(self,w,h) end 

	local CharacterCreatorFrameBlack = vgui.Create( "DPanel", CharacterFrameBaseParent )
	CharacterCreatorFrameBlack:SetSize( ScrW()*1, ScrH()*1 )
	CharacterCreatorFrameBlack:SetPos(0,0)
	CharacterCreatorFrameBlack:SetBackgroundColor( CharacterCreator.Colors["black"] )

	local CharacterCreatorImage = vgui.Create( "Material", CharacterCreatorFrameBlack )
	CharacterCreatorImage:SetPos( 0, 0 )
	CharacterCreatorImage:SetSize( ScrW()*1, ScrH()*1 )
	CharacterCreatorImage:SetMaterial( CharacterCreator.BackImage )
	CharacterCreatorImage.AutoSize = false

	local CharacterCreatorMenuSpawn = vgui.Create("DPanel", CharacterFrameBaseParent)
	CharacterCreatorMenuSpawn:SetSize(ScrW()*1, ScrH()*1)
	CharacterCreatorMenuSpawn:SetPos(0,0)
	CharacterCreatorMenuSpawn.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black160"])
		draw.DrawText(CharacterCreator.GetSentence("createCharacterTutorial"), "chc_kobralost_2",ScrW()*0.035, ScrH()*0.23, CharacterCreator.Colors["white"], TEXT_ALIGN_LEFT)
		draw.DrawText(CharacterCreator.GetSentence("createCharacter2"), "chc_kobralost_1",ScrW()*0.034, ScrH()*0.16, CharacterCreator.Colors["white"], TEXT_ALIGN_LEFT)
	end 

	local CharacterCreatorEntete = vgui.Create("DPanel", CharacterFrameBaseParent)
	CharacterCreatorEntete:SetSize(ScrW()*0.95, ScrH()*0.1)
	CharacterCreatorEntete:SetPos(ScrW()*0.03,ScrH()*0.03)
	CharacterCreatorEntete.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black140"])
		surface.SetDrawColor(CharacterCreator.Colors["black180"])
		surface.DrawOutlinedRect( 0, 0, w, h )
	end

	local CharacterCreatorPanelSex = vgui.Create("DPanel", CharacterFrameBaseParent)
	CharacterCreatorPanelSex:SetPos(ScrW()*0.035, ScrH()*0.4)
	CharacterCreatorPanelSex:SetSize(ScrW()*0.21, ScrH()*0.08)
	CharacterCreatorPanelSex.Paint = function(self,w,h)
		surface.SetDrawColor(CharacterCreator.Colors["black180"])
		surface.DrawOutlinedRect( 0, 0, w, h )
		draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
		if CharacterCreatorSexe == 1 then 
			draw.DrawText(CharacterCreator.GetSentence("yourSexMale"), "chc_kobralost_9",CharacterCreatorPanelSex:GetWide()/2, CharacterCreatorPanelSex:GetTall()*0.2508, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		elseif CharacterCreatorSexe == 2 then 
			draw.DrawText(CharacterCreator.GetSentence("yourSexFemale"), "chc_kobralost_9",CharacterCreatorPanelSex:GetWide()/2, CharacterCreatorPanelSex:GetTall()*0.2508, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end 
	end 

	local CharacterCreatorPanelNationality = vgui.Create("DPanel", CharacterFrameBaseParent)
	CharacterCreatorPanelNationality:SetPos(ScrW()*0.035, ScrH()*0.51)
	CharacterCreatorPanelNationality:SetSize(ScrW()*0.21, ScrH()*0.08)
	CharacterCreatorPanelNationality.Paint = function(self,w,h)
		surface.SetDrawColor(CharacterCreator.Colors["black180"])
		surface.DrawOutlinedRect( 0, 0, w, h )
		draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
		draw.DrawText(CharacterCreator.GetSentence("nationality").." : "..CharacterCreator.Nationality[CharacterCreatorNationality],  "chc_kobralost_9",CharacterCreatorPanelNationality:GetWide()/2, CharacterCreatorPanelNationality:GetTall()*0.25, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP) 
	end 

	local CharacterCreatorPanelMoney = vgui.Create("DPanel", CharacterFrameBaseParent)
	CharacterCreatorPanelMoney:SetPos(ScrW()*0.035, ScrH()*0.62)
	CharacterCreatorPanelMoney:SetSize(ScrW()*0.21, ScrH()*0.08)
	CharacterCreatorPanelMoney.Paint = function(self,w,h)
		surface.SetDrawColor(CharacterCreator.Colors["black180"])
		surface.DrawOutlinedRect( 0, 0, w, h )
		draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
		draw.DrawText(CharacterCreator.GetSentence("money").." : "..DarkRP.formatMoney(CharacterCreator.MoneyOnStartCharacter), "chc_kobralost_9",CharacterCreatorPanelMoney:GetWide()/2, CharacterCreatorPanelMoney:GetTall()*0.25, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end 

	if CharacterCreator.CanChooseJob then 
		CharacterCreatorPanelJob = vgui.Create("DComboBox", CharacterFrameBaseParent)
		CharacterCreatorPanelJob:SetPos(ScrW()*0.035, ScrH()*0.72)
		CharacterCreatorPanelJob:SetSize(ScrW()*0.21, ScrH()*0.08)
		CharacterCreatorPanelJob:SetFont("chc_kobralost_9")
		CharacterCreatorPanelJob:SetTextColor(color_white)
		CharacterCreatorPanelJob:SetContentAlignment(5)
		CharacterCreatorPanelJob:SetValue(CharacterCreator.JobCanChoose[1])
		CharacterCreatorPanelJob.Paint = function(self,w,h)
			surface.SetDrawColor(CharacterCreator.Colors["black180"])
			surface.DrawOutlinedRect( 0, 0, w, h )
			draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
		end 
		for k,v in pairs(CharacterCreator.JobCanChoose) do 
			CharacterCreatorPanelJob:AddChoice(v)
		end 
	else 
		CharacterCreatorPanelJob = vgui.Create("DPanel", CharacterFrameBaseParent)
		CharacterCreatorPanelJob:SetPos(ScrW()*0.035, ScrH()*0.72)
		CharacterCreatorPanelJob:SetSize(ScrW()*0.21, ScrH()*0.08)
		CharacterCreatorPanelJob.Paint = function(self,w,h)
			surface.SetDrawColor(CharacterCreator.Colors["black180"])
			surface.DrawOutlinedRect( 0, 0, w, h )
			draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
			if LocalPlayer():getDarkRPVar("job") != nil then
				draw.DrawText(CharacterCreator.GetSentence("job").." : "..LocalPlayer():getDarkRPVar("job"), "chc_kobralost_9",CharacterCreatorPanelJob:GetWide()/2, CharacterCreatorPanelJob:GetTall()*0.25, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			else 
				draw.DrawText(CharacterCreator.GetSentence("job").." : Nill", "chc_kobralost_9",CharacterCreatorPanelJob:GetWide()/2, CharacterCreatorPanelJob:GetTall()*0.25, CharacterCreator.Colors["white"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end
		end 
	end 

	local CharacterCreatorDscrollPanel = vgui.Create("DScrollPanel", CharacterFrameBaseParent)
	CharacterCreatorDscrollPanel:SetSize(ScrW()*0.7, ScrH()*0.1)
	CharacterCreatorDscrollPanel:SetPos(ScrW()*0.03,ScrH()*0.03)
	CharacterCreatorDscrollPanel.Paint = function(self,w,h) end 
	CharacterCreatorModelChoose = true 
	CharacterCreator.FrameButton = {}
	for k,v in pairs(CharacterCreator.Bouttons) do 
		CharacterCreator.FrameButton[k] = vgui.Create("DPanel", CharacterCreatorDscrollPanel)
		CharacterCreator.FrameButton[k]:SetSize(ScrW()*0.14, ScrH()*0.1)
		CharacterCreator.FrameButton[k]:Dock(LEFT)
		CharacterCreator.FrameButton[k]:DockMargin(0, 0, 4, 0)
		CharacterCreator.FrameButton[k].Paint = function(self,w,h) end

		local CharacterCreatorButtonInfo = vgui.Create("DButton", CharacterCreator.FrameButton[k] )
		CharacterCreatorButtonInfo:SetText(v.NameButton)
		CharacterCreatorButtonInfo:SetFont("chc_kobralost_2")
		CharacterCreatorButtonInfo:SetTextColor(CharacterCreator.Colors["white"])
		CharacterCreatorButtonInfo:SetSize(ScrW()*0.14, ScrH()*0.1)
		CharacterCreatorButtonInfo.Paint = function(self,w,h)	
			if self:IsHovered() then		
				draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["blackgray240"])
			else
				draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black110"])
			end 
		end 
		CharacterCreatorButtonInfo.DoClick = function()
			gui.OpenURL(v.UrlButton)
			surface.PlaySound( "UI/buttonclick.wav" )
		end 
	end

	local CharacterCreatorButtonQuit = vgui.Create("DButton", CharacterCreatorEntete )
	CharacterCreatorButtonQuit:SetFont("chc_kobralost_2")
	CharacterCreatorButtonQuit:SetTextColor(CharacterCreator.Colors["white"])
	CharacterCreatorButtonQuit:SetSize(ScrW()*0.12, ScrH()*0.1)
	CharacterCreatorButtonQuit:SetPos(ScrW()*0.83, 0)
	CharacterCreatorButtonQuit:SetText(CharacterCreator.GetSentence("leave"))
	CharacterCreatorButtonQuit.Paint = function(self,w,h)
		surface.SetDrawColor(CharacterCreator.Colors["gray"])
		surface.DrawOutlinedRect( 0, 0, w, h )
		if self:IsHovered() then		
			draw.RoundedBox(4, 0, 0, w, h, CharacterCreator.Colors["blackgray240"])
		else
			draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black160"])
		end 
	end 
	CharacterCreatorButtonQuit.DoClick = function()
		surface.PlaySound( "buttons/combine_button1.wav" )
		timer.Simple(0.1, function()
			CharacterCreatorButtonQuit:SetText(CharacterCreator.GetSentence("confirm"))
		end ) 
		if CharacterCreatorButtonQuit:GetText() == CharacterCreator.GetSentence("confirm") then 
			RunConsoleCommand("disconnect")
		end 
	end 

	local CharacterCreatorDtextEntryName = vgui.Create( "DTextEntry", CharacterFrameBaseParent ) 
	CharacterCreatorDtextEntryName:SetPos( ScrW()*0.035, ScrH()*0.3 )
	CharacterCreatorDtextEntryName:SetSize( ScrW()*0.21, ScrH()*0.08 )
	CharacterCreatorDtextEntryName:SetText( " "..CharacterCreator.GetSentence("firstName") )
	CharacterCreatorDtextEntryName:SetFont("chc_kobralost_2")
	CharacterCreatorDtextEntryName:SetDrawLanguageID( false )
	if CharacterCreator.CompatibilityClothesMod then 
		local CharacterCreatorRandomName = table.Random(CharacterCreator.CharacterName)
		CharacterCreatorDtextEntryName:SetEditable ( false ) 
		CharacterCreatorDtextEntryName:SetText(CharacterCreatorRandomName)
	else 
		CharacterCreatorDtextEntryName:SetEditable ( true ) 
	end 
	CharacterCreatorDtextEntryName.AllowInput = function( self, stringValue )
		if not CheckCharacter(stringValue) then 
			return true
		end 
		if string.len(CharacterCreatorDtextEntryName:GetValue()) > CharacterCreator.MaxCaractersName then 
			return true 
		end 
	end

	local String = ""
	if CharacterCreator.RandomName then 
		CharacterCreatorDtextEntryName:SetEditable ( false ) 
		for k,v in pairs(CharacterCreator.RandomNameConfiguration) do 
			if v == 1 then 
				String = String..RandomLetters()
			elseif v == 2 then 
				String = String..RandomNumber()
			else 
				String = String..""
			end 	
		end 
		CharacterCreatorDtextEntryName:SetText(String)
	end 

	if CharacterCreator.PrefixName then 
		CharacterCreatorDtextEntryName:SetEditable ( false ) 
		CharacterCreatorDtextEntryName:SetText(CharacterCreator.PrefixNameConfiguration)
	end 

	CharacterCreatorDtextEntryName:SetEnterAllowed( false )
	CharacterCreatorDtextEntryName.OnGetFocus = function(self) CharacterCreatorDtextEntryName:SetText("") end 
	CharacterCreatorDtextEntryName.OnLoseFocus = function(self)
		if CharacterCreatorDtextEntryName:GetText() == "" then  
			CharacterCreatorDtextEntryName:SetText(" "..CharacterCreator.GetSentence("firstName"))
		end
	end 
	CharacterCreatorDtextEntryName.Paint = function(self,w,h)
		surface.SetDrawColor(CharacterCreator.Colors["black"])
		surface.DrawOutlinedRect( 0, 0, w, h )
		draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
		self:DrawTextEntryText(CharacterCreator.Colors["white"], CharacterCreator.Colors["white"], CharacterCreator.Colors["white"])
	end
	
	local CharacterCreatorDtextEntrySurName = vgui.Create( "DTextEntry", CharacterFrameBaseParent ) 
	CharacterCreatorDtextEntrySurName:SetPos( ScrW()*0.26, ScrH()*0.3 )
	CharacterCreatorDtextEntrySurName:SetSize( ScrW()*0.21, ScrH()*0.08 )
	CharacterCreatorDtextEntrySurName:SetText( " "..CharacterCreator.GetSentence("surName") )
	CharacterCreatorDtextEntrySurName:SetFont("chc_kobralost_2")
	CharacterCreatorDtextEntrySurName:SetDrawLanguageID( false )
	CharacterCreatorDtextEntrySurName.AllowInput = function( self, stringValue )
		if not CheckCharacter(stringValue) then 
			return true
		end 
		if string.len(CharacterCreatorDtextEntrySurName:GetValue()) > CharacterCreator.MaxCaractersSurname then 
			return true 
		end 
	end
	if CharacterCreator.CompatibilityClothesMod then 
		local CharacterCreatorRandomSurName = table.Random(CharacterCreator.CharacterSurName)
		CharacterCreatorDtextEntrySurName:SetEditable ( false ) 
		CharacterCreatorDtextEntrySurName:SetText(CharacterCreatorRandomSurName)
	else 
		CharacterCreatorDtextEntrySurName:SetEditable ( true ) 
	end 
	CharacterCreatorDtextEntrySurName:SetEnterAllowed( false )
	CharacterCreatorDtextEntrySurName.OnGetFocus = function(self) CharacterCreatorDtextEntrySurName:SetText("") end 
	CharacterCreatorDtextEntrySurName.OnLoseFocus = function(self)
		if CharacterCreatorDtextEntrySurName:GetText() == "" then  
			CharacterCreatorDtextEntrySurName:SetText(" "..CharacterCreator.GetSentence("surName"))
		end
	end 
	CharacterCreatorDtextEntrySurName.Paint = function(self,w,h)
		surface.SetDrawColor(CharacterCreator.Colors["black"])
		surface.DrawOutlinedRect( 0, 0, w, h )	
		draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
		self:DrawTextEntryText(CharacterCreator.Colors["white"], CharacterCreator.Colors["white"], CharacterCreator.Colors["white"])
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 15478a1827bdd0ab07064f24626a05e7e8fa2b4b1e33baa627f3f8cb0b843238

	local CharacterCreatorModel = vgui.Create( "DModelPanel", CharacterFrameBaseParent )
	CharacterCreatorModel:SetPos(  ScrW() * 0.7, ScrH() * 0.2 )
	CharacterCreatorModel:SetSize( ScrW() * 0.2, ScrH() * 0.7 )
	CharacterCreatorModel:SetFOV( 6.4 )
	CharacterCreatorModel:SetCamPos( Vector( 310, 100, 45 ) )
	CharacterCreatorModel:SetLookAt( Vector( 0, 0, 36 ) )
	CharacterCreatorModel:SetModel( CharacterCreatorModelCreate )
	function CharacterCreatorModel:LayoutEntity( ent ) end

	if not CharacterCreator.CharacterDisableBodyGroup then 
		local CharacterCreatorButtonHeadNext = vgui.Create("DButton", CharacterFrameBaseParent)
		CharacterCreatorButtonHeadNext:SetPos(  ScrW() * 0.88, ScrH() * 0.23 )
		CharacterCreatorButtonHeadNext:SetSize(ScrW()*0.021, ScrH()*0.05)
		CharacterCreatorButtonHeadNext:SetText("⧁")
		CharacterCreatorButtonHeadNext:SetFont("chc_kobralost_3")
		CharacterCreatorButtonHeadNext.DoClick = function()
			local ent = CharacterCreatorModel.Entity
			if CharacterCreatorHeadId < ent:GetBodygroupCount(5) then 
				CharacterCreatorHeadId = CharacterCreatorHeadId + 1 
			elseif CharacterCreatorHeadId > ent:GetBodygroupCount(5) - 1 then 
				CharacterCreatorHeadId = 0 
			end 
			ent:SetBodygroup( 5, CharacterCreatorHeadId )
		end 
		CharacterCreatorButtonHeadNext:SetTextColor(CharacterCreator.Colors["white"])
		CharacterCreatorButtonHeadNext.Paint = function() end 

		local CharacterCreatorButtonTorseBext = vgui.Create("DButton", CharacterFrameBaseParent)
		CharacterCreatorButtonTorseBext:SetPos(  ScrW() * 0.88, ScrH() * 0.4 )
		CharacterCreatorButtonTorseBext:SetSize(ScrW()*0.021, ScrH()*0.05)
		CharacterCreatorButtonTorseBext:SetText("⧁")
		CharacterCreatorButtonTorseBext:SetFont("chc_kobralost_3")
		CharacterCreatorButtonTorseBext.DoClick = function()
			local ent = CharacterCreatorModel.Entity
			if CharacterCreatorTorseId < ent:GetBodygroupCount(1) then 
				CharacterCreatorTorseId = CharacterCreatorTorseId + 1 
			elseif CharacterCreatorTorseId > ent:GetBodygroupCount(1) - 1 then 
				CharacterCreatorTorseId = 0 
			end 
			ent:SetBodygroup( 1, CharacterCreatorTorseId )
		end 
		CharacterCreatorButtonTorseBext:SetTextColor(CharacterCreator.Colors["white"])
		CharacterCreatorButtonTorseBext.Paint = function() end 

		local CharacterCreatorButtonGlovesNext = vgui.Create("DButton", CharacterFrameBaseParent)
		CharacterCreatorButtonGlovesNext:SetPos(  ScrW() * 0.88, ScrH() * 0.7 )
		CharacterCreatorButtonGlovesNext:SetSize(ScrW()*0.021, ScrH()*0.15)
		CharacterCreatorButtonGlovesNext:SetText("⧁")
		CharacterCreatorButtonGlovesNext:SetFont("chc_kobralost_3")
		CharacterCreatorButtonGlovesNext.DoClick = function()
			local ent = CharacterCreatorModel.Entity
			if CharacterCreatorGlovesId < ent:GetBodygroupCount(2) then 
				CharacterCreatorGlovesId = CharacterCreatorGlovesId + 1 
			elseif CharacterCreatorGlovesId > ent:GetBodygroupCount(2) - 1 then 
				CharacterCreatorGlovesId = 0 
			end 
			ent:SetBodygroup( 2, CharacterCreatorGlovesId )
		end 
		CharacterCreatorButtonGlovesNext:SetTextColor(CharacterCreator.Colors["white"])
		CharacterCreatorButtonGlovesNext.Paint = function() end 

		local CharacterCreatorButtonTrousersNext = vgui.Create("DButton", CharacterFrameBaseParent)
		CharacterCreatorButtonTrousersNext:SetPos(  ScrW() * 0.88, ScrH() * 0.52 )
		CharacterCreatorButtonTrousersNext:SetSize(ScrW()*0.021, ScrH()*0.15)
		CharacterCreatorButtonTrousersNext:SetText("⧁")
		CharacterCreatorButtonTrousersNext:SetFont("chc_kobralost_3")
		CharacterCreatorButtonTrousersNext.DoClick = function()
			local ent = CharacterCreatorModel.Entity
			if CharacterCreatorTrousersId < ent:GetBodygroupCount(3) then 
				CharacterCreatorTrousersId = CharacterCreatorTrousersId + 1 
			elseif CharacterCreatorTrousersId > ent:GetBodygroupCount(3) - 1 then 
				CharacterCreatorTrousersId = 0 
			end 
			ent:SetBodygroup( 3, CharacterCreatorTrousersId )
		end 
		CharacterCreatorButtonTrousersNext:SetTextColor(CharacterCreator.Colors["white"])
		CharacterCreatorButtonTrousersNext.Paint = function() end 

		local CharacterCreatorButtonHeadBefore = vgui.Create("DButton", CharacterFrameBaseParent)
		CharacterCreatorButtonHeadBefore:SetPos(  ScrW() * 0.69, ScrH() * 0.23 )
		CharacterCreatorButtonHeadBefore:SetSize(ScrW()*0.021, ScrH()*0.05)
		CharacterCreatorButtonHeadBefore:SetText("⧀")
		CharacterCreatorButtonHeadBefore:SetFont("chc_kobralost_3")
		CharacterCreatorButtonHeadBefore.DoClick = function()
			local ent = CharacterCreatorModel.Entity
			if CharacterCreatorHeadId != 0 then 
				CharacterCreatorHeadId = CharacterCreatorHeadId - 1 
			elseif CharacterCreatorHeadId == 0 then 
				CharacterCreatorHeadId = ent:GetBodygroupCount(5)
			end 
			ent:SetBodygroup( 5, CharacterCreatorHeadId )
		end 
		CharacterCreatorButtonHeadBefore:SetTextColor(CharacterCreator.Colors["white"])
		CharacterCreatorButtonHeadBefore.Paint = function() end 

		local CharacterCreatorButtonTorseBefore = vgui.Create("DButton", CharacterFrameBaseParent)
		CharacterCreatorButtonTorseBefore:SetPos(  ScrW() * 0.69, ScrH() * 0.4 )
		CharacterCreatorButtonTorseBefore:SetSize(ScrW()*0.021, ScrH()*0.05)
		CharacterCreatorButtonTorseBefore:SetText("⧀")
		CharacterCreatorButtonTorseBefore:SetFont("chc_kobralost_3")
		CharacterCreatorButtonTorseBefore.DoClick = function()
			local ent = CharacterCreatorModel.Entity
			if CharacterCreatorTorseId != 0 then 
				CharacterCreatorTorseId = CharacterCreatorTorseId - 1
			elseif CharacterCreatorTorseId == 0 then 
				CharacterCreatorTorseId = ent:GetBodygroupCount(1) 
			end 
			ent:SetBodygroup( 1, CharacterCreatorTorseId )
		end 
		CharacterCreatorButtonTorseBefore:SetTextColor(CharacterCreator.Colors["white"])
		CharacterCreatorButtonTorseBefore.Paint = function() end 

		local CharacterCreatorButtonGlovesBefore = vgui.Create("DButton", CharacterFrameBaseParent)
		CharacterCreatorButtonGlovesBefore:SetPos(  ScrW() * 0.69, ScrH() * 0.7 )
		CharacterCreatorButtonGlovesBefore:SetSize(ScrW()*0.021, ScrH()*0.15)
		CharacterCreatorButtonGlovesBefore:SetText("⧀")
		CharacterCreatorButtonGlovesBefore:SetFont("chc_kobralost_3")
		CharacterCreatorButtonGlovesBefore.DoClick = function()
			local ent = CharacterCreatorModel.Entity
			if CharacterCreatorGlovesId != 0 then 
				CharacterCreatorGlovesId = CharacterCreatorGlovesId - 1 
			elseif CharacterCreatorGlovesId == 0 then 
				CharacterCreatorGlovesId = ent:GetBodygroupCount(2) 
			end 
			ent:SetBodygroup( 2, CharacterCreatorGlovesId )
		end 
		CharacterCreatorButtonGlovesBefore:SetTextColor(CharacterCreator.Colors["white"])
		CharacterCreatorButtonGlovesBefore.Paint = function() end 

		local CharacterCreatorButtonTrousersBefore = vgui.Create("DButton", CharacterFrameBaseParent)
		CharacterCreatorButtonTrousersBefore:SetPos(  ScrW() * 0.69, ScrH() * 0.52 )
		CharacterCreatorButtonTrousersBefore:SetSize(ScrW()*0.021, ScrH()*0.15)
		CharacterCreatorButtonTrousersBefore:SetText("⧀")
		CharacterCreatorButtonTrousersBefore:SetFont("chc_kobralost_3")
		CharacterCreatorButtonTrousersBefore.DoClick = function()
			local ent = CharacterCreatorModel.Entity
			if CharacterCreatorTrousersId != 0 then 
				CharacterCreatorTrousersId = CharacterCreatorTrousersId - 1 
			elseif CharacterCreatorTrousersId == 0 then 
				CharacterCreatorTrousersId = ent:GetBodygroupCount(3)  
			end 
			ent:SetBodygroup( 3, CharacterCreatorTrousersId )
		end 
		CharacterCreatorButtonTrousersBefore:SetTextColor(CharacterCreator.Colors["white"])
		CharacterCreatorButtonTrousersBefore.Paint = function() end 
	end 

	local CharacterCreatorScrollModel = vgui.Create( "DScrollPanel", CharacterFrameBaseParent )
	CharacterCreatorScrollModel:SetPos( ScrW()*0.26, ScrH()*0.4 )
	CharacterCreatorScrollModel:SetSize( CharacterCreatorDtextEntrySurName:GetWide(), ScrH()*0.4 )
	CharacterCreatorScrollModel.Paint = function(self,w,h)
		surface.SetDrawColor(CharacterCreator.Colors["black"])
		surface.DrawOutlinedRect( 0, 0, w, h )
		draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["black180"])
	end 

	local KobraCharacterCreatorModel = vgui.Create( "DIconLayout", CharacterCreatorScrollModel )
	KobraCharacterCreatorModel:Dock(FILL)
	KobraCharacterCreatorModel:SetSpaceY( 5 )
	KobraCharacterCreatorModel:SetSpaceX( 5 )

	for k, v in pairs(CharacterCreator.Models[1]) do 
		local CharacterCreatorListItem = KobraCharacterCreatorModel:Add( "SpawnIcon" ) 
		CharacterCreatorListItem:SetSize( ScrW()*0.04, ScrH()*0.07 )
		CharacterCreatorListItem:SetModel(v)
		CharacterCreatorListItem.DoClick = function()
			CharacterCreatorModel:SetModel( v )
			CharacterCreatorModelCreate = v
			CharacterCreatorModelChoose = true  
		end 
	end

	if not CharacterCreator.DisableSex then 
		local CharacterCreatorButton1 = vgui.Create("DButton", CharacterFrameBaseParent)
		CharacterCreatorButton1:SetFont("chc_kobralost_9")
		CharacterCreatorButton1:SetTextColor(CharacterCreator.Colors["white"])
		CharacterCreatorButton1:SetSize(ScrW()*0.02, ScrH()*0.05)
		CharacterCreatorButton1:SetPos(ScrW()*0.035, ScrH()*0.4132)
		CharacterCreatorButton1:SetText("◄")
		CharacterCreatorButton1.DoClick = function()	
			KobraCharacterCreatorModel:Clear()
			if CharacterCreatorSexe == 2 then 
				CharacterCreatorSexe = 1
			elseif CharacterCreatorSexe == 1 then 
				CharacterCreatorSexe = 2
			end 

			for k, v in pairs(CharacterCreator.Models[CharacterCreatorSexe]) do 
				local CharacterCreatorListItem = KobraCharacterCreatorModel:Add( "SpawnIcon" ) 
				CharacterCreatorListItem:SetSize( ScrW()*0.04, ScrH()*0.07 )
				CharacterCreatorListItem:SetModel(v)
				CharacterCreatorListItem.DoClick = function()
					CharacterCreatorModel:SetModel( v )
					CharacterCreatorModelCreate = v
					CharacterCreatorModelChoose = true 
				end 
			end
			surface.PlaySound( "UI/buttonclick.wav" ) 
		end
		CharacterCreatorButton1.Paint = function(self, w,h ) end

		local CharacterCreatorButton2 = vgui.Create("DButton", CharacterFrameBaseParent)
		CharacterCreatorButton2:SetFont("chc_kobralost_9")
		CharacterCreatorButton2:SetTextColor(CharacterCreator.Colors["white"])
		CharacterCreatorButton2:SetSize(ScrW()*0.02, ScrH()*0.05)
		CharacterCreatorButton2:SetPos(ScrW()*0.223, ScrH()*0.4132)
		CharacterCreatorButton2:SetText("►")
		CharacterCreatorButton2.DoClick = function()	
			KobraCharacterCreatorModel:Clear()
			if CharacterCreatorSexe == 1 then 
				CharacterCreatorSexe = CharacterCreatorSexe + 1 
			elseif CharacterCreatorSexe == 2 then 
				CharacterCreatorSexe = 1
			end	
			for k, v in pairs(CharacterCreator.Models[CharacterCreatorSexe]) do 
				local CharacterCreatorListItem = KobraCharacterCreatorModel:Add( "SpawnIcon" ) 
				CharacterCreatorListItem:SetSize( ScrW()*0.04, ScrH()*0.07 )
				CharacterCreatorListItem:SetModel(v)
				CharacterCreatorListItem.DoClick = function()
					CharacterCreatorModel:SetModel( v )
					CharacterCreatorModelCreate = v
					CharacterCreatorModelChoose = true 
				end 
			end
			surface.PlaySound( "UI/buttonclick.wav" ) 
		end 
		CharacterCreatorButton2.Paint = function(self, w,h ) end
	end 

	if not CharacterCreator.DisableNationality then 
		local CharacterCreatorButton3 = vgui.Create("DButton", CharacterFrameBaseParent)
		CharacterCreatorButton3:SetFont("chc_kobralost_9")
		CharacterCreatorButton3:SetTextColor(CharacterCreator.Colors["white"])
		CharacterCreatorButton3:SetSize(ScrW()*0.02, ScrH()*0.05)
		CharacterCreatorButton3:SetPos(ScrW()*0.035, ScrH()*0.522)
		CharacterCreatorButton3:SetText("◄")
		CharacterCreatorButton3.DoClick = function()
			if CharacterCreatorNationality > (table.Count(CharacterCreator.Nationality)) - 1  then 
				CharacterCreatorNationality = CharacterCreatorNationality - 1
			elseif CharacterCreatorNationality == 1 then 
				CharacterCreatorNationality = table.Count(CharacterCreator.Nationality)
			end  		
			surface.PlaySound( "UI/buttonclick.wav" )
		end 
		CharacterCreatorButton3.Paint = function(self, w,h ) end

		local CharacterCreatorButton4 = vgui.Create("DButton", CharacterFrameBaseParent)
		CharacterCreatorButton4:SetFont("chc_kobralost_9")
		CharacterCreatorButton4:SetTextColor(CharacterCreator.Colors["white"])
		CharacterCreatorButton4:SetSize(ScrW()*0.02, ScrH()*0.05)
		CharacterCreatorButton4:SetPos(ScrW()*0.223, ScrH()*0.522)
		CharacterCreatorButton4:SetText("►")
		CharacterCreatorButton4.DoClick = function()	
			if CharacterCreatorNationality != table.Count(CharacterCreator.Nationality) then 
				CharacterCreatorNationality = CharacterCreatorNationality + 1 
			elseif CharacterCreatorNationality == table.Count(CharacterCreator.Nationality) then 
				CharacterCreatorNationality = 1 
			end 		
			surface.PlaySound( "UI/buttonclick.wav" )
		end 
		CharacterCreatorButton4.Paint = function(self, w,h ) end  
	end 

	local CharacterCreatorButtonBefore = vgui.Create("DButton", CharacterFrameBaseParent)
	CharacterCreatorButtonBefore:SetSize(ScrW()*0.21, ScrH()*0.1)
	CharacterCreatorButtonBefore:SetPos(ScrW()*0.26, ScrH()*0.83)
	CharacterCreatorButtonBefore:SetText(CharacterCreator.GetSentence("back"))
	CharacterCreatorButtonBefore:SetFont("chc_kobralost_5")
	CharacterCreatorButtonBefore:SetTextColor(CharacterCreator.Colors["white"])
	CharacterCreatorButtonBefore.Paint = function(self,w,h)
		draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["red"])
		surface.SetDrawColor(CharacterCreator.Colors["black"])
		surface.DrawOutlinedRect( 0, 0, w, h )
	end 
	CharacterCreatorButtonBefore.DoClick = function()
		CharacterFrameBaseParent:Remove()
		CharacterCreator.MenuSpawn()
		surface.PlaySound( "UI/buttonclick.wav" )
	end

	local CharacterCreatorButtonAccept2 = vgui.Create("DButton", CharacterFrameBaseParent)
	CharacterCreatorButtonAccept2:SetSize(ScrW()*0.21, ScrH()*0.1)
	CharacterCreatorButtonAccept2:SetPos(ScrW()*0.035, ScrH()*0.83)
	CharacterCreatorButtonAccept2:SetText(CharacterCreator.GetSentence("create"))
	CharacterCreatorButtonAccept2:SetFont("chc_kobralost_5")
	CharacterCreatorButtonAccept2:SetTextColor(CharacterCreator.Colors["white"])
	CharacterCreatorButtonAccept2.Paint = function(self,w,h)
		draw.RoundedBox(0, 0, 0, w, h, CharacterCreator.Colors["green"])
		surface.SetDrawColor(CharacterCreator.Colors["black"])
		surface.DrawOutlinedRect( 0, 0, w, h )
	end 

	local CharacterCreatorButtonRandom = vgui.Create("DButton", CharacterFrameBaseParent)
	CharacterCreatorButtonRandom:SetSize(ScrW()*0.04, ScrH()*0.03)
	CharacterCreatorButtonRandom:SetPos(ScrW()*0.458, ScrH()*0.27)
	CharacterCreatorButtonRandom:SetImage("icon16/page_white_swoosh.png")
	CharacterCreatorButtonRandom:SetText("")
	CharacterCreatorButtonRandom.Paint = function() end 
	CharacterCreatorButtonRandom.DoClick = function()
		local CharacterCreatorRandomName = table.Random(CharacterCreator.CharacterName)
		local CharacterCreatorRandomSurName = table.Random(CharacterCreator.CharacterSurName)
		if not CharacterCreator.RandomName then 
			CharacterCreatorDtextEntryName:SetText(CharacterCreatorRandomName)
		end 
		CharacterCreatorDtextEntrySurName:SetText(CharacterCreatorRandomSurName)
	end 

	CharacterCreatorButtonAccept2.DoClick = function()
		if CharacterCreatorDtextEntryName:GetText() == " "..CharacterCreator.GetSentence("firstName") or CharacterCreatorDtextEntrySurName:GetText() == " "..CharacterCreator.GetSentence("surName") then surface.PlaySound( "buttons/combine_button1.wav" ) return false else 
			if CharacterCreatorSaveSexe == 2 then 
				local CharacterCreatorSaveSexe = CharacterCreator.GetSentence("feminine")
			end 
			local CharacterCreatorTable = {
				CharacterCreatorName = CharacterCreatorDtextEntryName:GetValue():gsub("^%l", string.upper).." "..CharacterCreatorDtextEntrySurName:GetValue():gsub("^%l", string.upper),
				CharacterCreatorSaveNationality = CharacterCreator.Nationality[CharacterCreatorNationality], 
				CharacterCreatorModel = CharacterCreatorModelCreate, 
				CharacterCreatorSaveSexe = CharacterCreatorSaveSexe,
				CharacterCreatorHeadId = CharacterCreatorHeadId,
				CharacterCreatorTorseId = CharacterCreatorTorseId, 
				CharacterCreatorGlovesId = CharacterCreatorGlovesId,
				CharacterCreatorTrousersId = CharacterCreatorTrousersId, 
			}	
			if CharacterCreatorModelChoose == true then
				RunConsoleCommand("stopsound")
				if CharacterCreator.MusicCreatedActivate then 
					sound.PlayURL( CharacterCreator.MusicCreated, "", 
					function( station )
						if IsValid( station ) then
							station:Play()
							station:SetVolume(CharacterCreator.MusicCreatedVolume)
						end 
					end )
				end 
				CharacterCreatorModelChoose = false 
				net.Start("CharacterCreator:SaveFirst")
				net.WriteTable(CharacterCreatorTable)
				net.WriteInt(id, 8)
				net.WriteString(CharacterCreatorPanelJob:GetValue())
				net.SendToServer()
				CharacterFrameBaseParent:SlideUp(0.7)
				surface.PlaySound( "UI/buttonclick.wav" )
				timer.Simple(0.1, function()
					net.Start("CharacterCreator:SaveCharacter")
					net.WriteInt(id, 8)
					net.SendToServer()
				end ) 
				timer.Simple(0.3, function()
					net.Start("CharacterCreator:LoadCharacter")
					net.WriteInt(id, 8)
					net.SendToServer()
				end )
				gui.EnableScreenClicker(false)
				timer.Simple(0.5, function()
					LocalPlayer():ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 255 ), 10, 0.5 )
				end ) 
			else 
				surface.PlaySound( "buttons/combine_button1.wav" )
			end 
		end  
	end
end

hook.Add("OnPlayerChangedTeam", "CharacterCreator:OnPlayerChangedTeam", function(ply)
	net.Start("CharacterCreator:ChangeTeam")
	net.SendToServer()
end)

net.Receive("CharacterCreator:InformationClient", function() 
	CharacterCreatorTab = net.ReadTable()
	local Bool = net.ReadBool()

	if Bool then 
		CharacterCreator.MenuSpawn(true)
	end 
end ) 

net.Receive("CharacterCreator:OpenMenu", function()
	-- Bool == Leave the Server when you click on the leave button or leave the menu
	local Bool = net.ReadBool()
	CharacterCreator.MenuSpawn(Bool)
end )
net.Receive("CharacterCreator:UpdateStatut", CharacterCreatorUpdateStatut)

net.Receive("CharacterCreator:ClothesSend", function()
	local Table = net.ReadTable() or {}

	CLOTHESMOD.PlayerInfos = {}
	CLOTHESMOD.PlayerInfos[LocalPlayer():SteamID64()] = Table["Clothing"]

	CLOTHESMOD.PlayerTops = {}
	CLOTHESMOD.PlayerTops[LocalPlayer():SteamID64()] = Table["Tops"]

	CLOTHESMOD.PlayerBottoms = {}
	CLOTHESMOD.PlayerBottoms[LocalPlayer():SteamID64()] = Table["Bottoms"]
end )

Kobralost = Kobralost or {}
Kobralost.NotifyTable = Kobralost.NotifyTable or {}

function CharacterCreator.Notify(msg, time)
    Kobralost.NotifyTable[#Kobralost.NotifyTable + 1] = {
        ["Message"] = msg,
        ["Time"] = CurTime() + time, 
        ["Color1"] = CharacterCreator.Colors["black41200"], 
        ["Color2"] = CharacterCreator.Colors["blue41200"], 
        ["Material"] = "boss.png", 
        ["Font"] = "chc_notify_font",
    }
end 

hook.Add("DrawOverlay", "RDO:DrawOverlay", function()
    if Kobralost.NotifyTable && #Kobralost.NotifyTable > 0 then 
        for k,v in pairs(Kobralost.NotifyTable) do 
            if not isnumber(v.RLerp) then v.RLerp = -(ScrW()*0.25 + #v.Message*ScrW()*0.0057) end 

            if v.Time > CurTime() then 
                v.RLerp = math.Round(Lerp(3*FrameTime(), v.RLerp, ScrW()*0.03))
            else 
                v.RLerp = math.Round(Lerp(3*FrameTime(), v.RLerp, -(ScrW()*0.25 + #v.Message*ScrW()*0.0057+ScrW()*0.032)))
                if v.RLerp < -(ScrW()*0.1 + #v.Message*ScrW()*0.0057+ScrW()*0.032) then Kobralost.NotifyTable[k] = nil Kobralost.NotifyTable = table.ClearKeys( Kobralost.NotifyTable ) end 
            end 
            
            draw.RoundedBox(4, v.RLerp, (ScrH()*0.055*k)-ScrH()*0.038, #v.Message*ScrW()*0.0055+ScrW()*0.032, ScrH()*0.043, v.Color1)
            draw.RoundedBox(4, v.RLerp, (ScrH()*0.055*k)-ScrH()*0.038, ScrH()*0.043, ScrH()*0.043, v.Color2)

            surface.SetDrawColor( CharacterCreator.Colors["white240"] )
            surface.SetMaterial(Material(v.Material))
		    surface.DrawTexturedRect( v.RLerp + ScrW()*0.001, (ScrH()*0.055*k)-ScrH()*0.0365, ScrH()*0.04, ScrH()*0.04 )

            draw.SimpleText(v.Message, v.Font, v.RLerp+ScrW()*0.03, (ScrH()*0.055*k) + ScrH()*0.043/2-ScrH()*0.038, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end 
    end 
end ) 

net.Receive("CharacterCreator:Notify", function()
    local TableNotify = net.ReadTable()
    CharacterCreator.Notify(TableNotify["message"], TableNotify["time"])
end) 
