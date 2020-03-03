ENT.Base = "ent_hl1_base"
ENT.Type = "anim"
ENT.Author = "Upset"
ENT.Spawnable = false

if CLIENT then
	function ENT:Initialize()
		self:SetRenderBounds(self:GetCollisionBounds())
	end
	
	function ENT:Draw()
		self:DrawModel()
		self:SetRenderBounds(self:GetCollisionBounds())
		--local targetDir = Entity(1):WorldSpaceCenter()
		--render.DrawLine(self:GetPos() + self:GetForward() * 270, targetDir + self:GetForward() * 300, Color(255,255,255,255), true)
	end
end