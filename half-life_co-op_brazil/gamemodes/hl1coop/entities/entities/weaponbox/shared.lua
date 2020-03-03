ENT.Type = "anim"
ENT.Base = "hl1_item_pickup_base"
ENT.PrintName = "HL1 Weapon Box"
ENT.Category = "Half-Life"
ENT.Author = "Upset"
ENT.Spawnable = false

if CLIENT then
	function ENT:Draw()
		if IsValid(self:GetOwner()) and self:GetOwner() != LocalPlayer() then
			render.SetBlend(.5)
		end
		self:DrawModel()
		render.SetBlend(1)
	end
end