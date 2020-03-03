AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetTrigger(true)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:SetNotSolid(true)
end

function ENT:SetCheckpointData(dest, destang, telePos, weptable)
	self.Destination	= dest
	self.DestinationAng = destang
	self.TelePos		= telePos
	self.WepTable		= weptable
end

function ENT:Touch(ent)
	if !self.HasTouched and ent:IsPlayer() and ent:Alive() then
		self.HasTouched = true
		if self.PassFunction then
			self.PassFunction()
		end
		GAMEMODE:Checkpoint(self.Destination, self.DestinationAng, self.TelePos, ent, self.WepTable)
		self:Remove()
	end
end