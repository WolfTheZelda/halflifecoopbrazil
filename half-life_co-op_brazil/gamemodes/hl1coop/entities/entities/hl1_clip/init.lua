AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
end