include("shared.lua")

function ENT:Initialize()
	self:SetRenderBounds(self:GetCollisionBounds())
end

function ENT:Draw()
	if self:GetRenderBounds() != self:GetCollisionBounds() then
		self:SetRenderBounds(self:GetCollisionBounds())
	end
	self:DrawModel()
end