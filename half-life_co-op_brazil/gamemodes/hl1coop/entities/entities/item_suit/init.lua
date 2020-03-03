AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Model = Model("models/w_suit.mdl")
ENT.SoundBell = Sound("fvox/bell.wav")

function ENT:Initialize()
	if !self:IsInWorld() then
		self:Remove()
	end
	self:SetModel(self.Model)
	self:SetMoveType(MOVETYPE_FLYGRAVITY)
	self:SetSolid(SOLID_NONE)

	self:SetTrigger(true)
	self:UseTriggerBounds(true, 12)
	self.Pickable = true
end

function ENT:Touch(ent)
	if IsValid(ent) then
		if ent:IsPlayer() and ent:Alive() and self.Pickable then
			self:Pickup(ent)
		end
	end
end

function ENT:Pickup(ply)
	if !ply:IsSuitEquipped() then
		ply:EquipSuit()
		ply:EmitSound(self.SoundBell, 75, 100 + math.random(0, 5), .7, CHAN_ITEM)
		timer.Simple(1, function()
			if IsValid(ply) and ply:Alive() then
				ply:EmitSound("fvox/hev_logon.wav", 50, 100 + math.random(0, 5), 0.3, CHAN_VOICE)
			end
		end)
		
		if self.Respawnable then
			self:RespawnItem(2)
		else
			self:Remove()
		end
		self.Pickable = false
		
		hook.Run("OnSuitPickup", ply)
	end
end