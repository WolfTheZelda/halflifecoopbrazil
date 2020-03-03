ENT.Type = "anim"
ENT.Author = "Upset"
ENT.Spawnable = false

if CLIENT then
	function ENT:Initialize()
		self:SetRenderBoundsWS(self:GetCollisionBounds())
	end
	function ENT:Draw()
		if GetConVarNumber("sv_cheats") != 1 or !cvar_showtriggers:GetBool() then return end
		local pos, ang = self:GetPos(), self:GetAngles()
		local mins, maxs = self:GetCollisionBounds()
		render.SetColorMaterial()
		render.DrawBox(pos, ang, mins, maxs, Color(255,180,50,100))
		render.DrawWireframeBox(pos, ang, mins, maxs, Color(255,200,100,200))
	end
end