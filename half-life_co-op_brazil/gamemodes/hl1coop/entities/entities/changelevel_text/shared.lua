AddCSLuaFile()

ENT.Type = "anim"
ENT.Author = "Upset"
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Text")
end


if CLIENT then
	function ENT:DoDrawText()
		draw.DrawText(self:GetText(), "DermaDefault", 1, 1, Color(0, 0, 0, 150), TEXT_ALIGN_CENTER) 
		draw.DrawText(self:GetText(), "DermaDefault", 0, 0, Color(255, 220, 50, 255), TEXT_ALIGN_CENTER)
	end

	function ENT:Draw()
		local ang = self:GetAngles()--LocalPlayer():EyeAngles()
		local rot = math.sin(CurTime() * 6) + ang[2] --* .6
		cam.Start3D2D(self:GetPos() + Vector(6,0,0), Angle(0, rot + 90, 90), 1)
			self:DoDrawText()
		cam.End3D2D()
		cam.Start3D2D(self:GetPos() - Vector(6,0,0), Angle(0, rot - 90, 90), 1)
			self:DoDrawText()
		cam.End3D2D()
		--render.DrawLine(self:GetPos(),self:GetPos()+Vector(0,200,0), Color(255,255,255,255))
	end
else
	function ENT:Initialize()
		self:SetSolid(SOLID_NONE)
		self:DrawShadow(false)
	end
end