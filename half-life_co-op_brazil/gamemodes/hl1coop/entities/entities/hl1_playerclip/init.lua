AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	
	self:SetCustomCollisionCheck(true)
	self:CollisionRulesChanged()
end

function ENT:ShouldCollide(ent)
	if IsValid(ent) and ent:IsPlayer() then
		return false
	end

    return true
end