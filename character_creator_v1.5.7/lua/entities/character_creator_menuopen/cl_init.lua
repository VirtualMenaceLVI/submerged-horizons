/*
    Addon id: 6caa0056-2e1c-4a99-9ba2-8bb2fe3a0232
    Version: v1.5.7 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199063103836
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a45b4a0371527980aa45a614f82b3b1b5c437fbaab42e40b73e1d1d0309ff781
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e7470ef06f6b9f4cb7eb859aac9e04a5e1ab282313d4b3d8c10765ed2d3173a9
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561199063103836
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e7470ef06f6b9f4cb7eb859aac9e04a5e1ab282313d4b3d8c10765ed2d3173a9

function ENT:Draw()
	self:DrawModel()
	local pos = self:GetPos()
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 0)
	ang:RotateAroundAxis(ang:Forward(), 85)	
	if LocalPlayer():GetPos():Distance(self:GetPos()) < 500 then
		cam.Start3D2D(pos + ang:Up()*0, Angle(0, LocalPlayer():EyeAngles().y-90, 90), 0.025)
		if (self:GetDTInt(1) == 0) then
			draw.SimpleTextOutlined(CharacterCreator.NpcName, "chc_font_pnj", 0, -3050, CharacterCreator.Colors["white"] , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0, CharacterCreator.Colors["white"] );		
		end
		cam.End3D2D()
	end 
end 
