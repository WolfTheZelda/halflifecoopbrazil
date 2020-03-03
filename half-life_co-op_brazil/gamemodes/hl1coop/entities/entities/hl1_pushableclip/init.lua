AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	
	self:SetCustomCollisionCheck(true)
	self:CollisionRulesChanged()
end

function ENT:ShouldCollide(ent)
	if IsValid(ent) and ent:GetClass() == "func_pushable" then
		return false
	end

    return true
end