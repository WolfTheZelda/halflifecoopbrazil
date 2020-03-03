AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetTrigger(true)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionBounds(Vector(-self.Radius, -self.Radius, -self.Radius), Vector(self.Radius, self.Radius, self.Radius))
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:SetNotSolid(true)
	
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
	
end

function ENT:SetNPC(class)
	self.NPCClass = class
end

function ENT:SetMinPlayers(num)
	num = num or 3
	self.MinPlayers = num
end

function ENT:SetRadius(num)
	num = num or 255
	self.Radius = num
end

function ENT:EnableEffect(b)
	self.SpawnEffect = b
end

function ENT:SpawnNPC()
	if player.GetCount() >= self.MinPlayers then
		local npc = ents.Create(self.NPCClass)
		if IsValid(npc) then
			npc:SetPos(self:GetPos())
			npc:SetAngles(self:GetAngles())
			npc:Spawn()
			
			self:SpawnEffects()
		end
	end
end

function ENT:SpawnEffects()
	if self.SpawnEffect then
		self:EmitSound("debris/beamstart7.wav", 80, 100)
		local effect = EffectData()
		effect:SetOrigin(self:GetPos())
		util.Effect("hl1_monsterspawn", effect)
	end
end

function ENT:Touch(ent)
	if !self.Touched and ent:IsPlayer() then
		self.Touched = true
		self:SpawnNPC()
		self:Remove()
	end
end