AddCSLuaFile()

ENT.Type = "anim"
ENT.Spawnable = false

if CLIENT then return end

function ENT:Initialize()
	local ent = ents.Create(self.EntClass)
	if IsValid(ent) then
		ent:SetPos(self:GetPos())
		ent:SetAngles(self:GetAngles())
		ent:SetOwner(self:GetOwner())
		ent:Spawn()
	end
	self:Remove()
end