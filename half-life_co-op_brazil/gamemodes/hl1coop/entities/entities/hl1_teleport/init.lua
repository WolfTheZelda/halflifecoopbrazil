AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.SoundSpawn = Sound("debris/beamstart7.wav")
ENT.SoundEnter = Sound("ambience/alienlaser1.wav")

function ENT:Initialize()
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	self:SetTrigger(true)
	self:UseTriggerBounds(true, 8)
	
	self:DrawShadow(false)
	
	local sprite = ents.Create("env_sprite")
	sprite:SetKeyValue("rendercolor", "50 255 155")
	sprite:SetKeyValue("spriteProxySize", "2")
	sprite:SetKeyValue("HDRColorScale", "1")
	sprite:SetKeyValue("renderfx", "4")
	sprite:SetKeyValue("rendermode", "9")
	sprite:SetKeyValue("renderamt", "255")
	sprite:SetKeyValue("model", "sprites/enter1.vmt")
	sprite:SetKeyValue("scale", ".64")
	sprite:SetKeyValue("framerate", "24")
	sprite:SetParent(self)
	sprite:SetPos(self:GetPos())
	sprite:Spawn()
	
	self:EmitSound(self.SoundSpawn, 60, 100)
end

function ENT:SetDestination(pos, ang)
	self.Destination = pos
	self.DestinationAng = ang
end

function ENT:SetWeaponTable(t)
	if t then
		self.Weapons = t
	end
end

function ENT:Touch(ent)
	if ent:IsPlayer() then
		ent:TeleportToCheckpoint(self.Destination, self.DestinationAng, self.Weapons)
		self:EmitSound(self.SoundEnter, 70, 55)
	end
end