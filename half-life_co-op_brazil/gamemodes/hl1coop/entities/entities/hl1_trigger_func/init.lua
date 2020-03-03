AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetTrigger(true)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:SetNotSolid(true)
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() and ent:Alive() then
		if self.TouchFunction then
			self.TouchFunction(ent)
		end
	end
end