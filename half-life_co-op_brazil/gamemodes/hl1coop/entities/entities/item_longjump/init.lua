AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.PickupSound = Sound("fvox/blip.wav")

function ENT:Initialize()
	if !self:IsInWorld() then
		self:Remove()
	end
	self:SetModel("models/w_longjump.mdl")
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
	if ply:IsSuitEquipped() and !ply:GetNW2Bool("LongJump") then
		ply:SetLongJumpBool(true)
		ply:EmitSound(self.PickupSound, 75, 100 + math.random(0, 3), .7, CHAN_ITEM)
		timer.Simple(.05, function()
			if IsValid(ply) and ply:Alive() then
				ply:EmitSound("fvox/blip.wav", 75, 150 + math.random(0, 3), .7, CHAN_ITEM)
			end
		end)
		timer.Simple(.5, function()
			if IsValid(ply) and ply:Alive() then
				ply:EmitSound("fvox/powermove_on.wav", 50, 100 + math.random(0, 5), 0.3, CHAN_VOICE)
				ply:SendScreenHint(1)
			end
		end)
		
		if self.Respawnable or GAMEMODE:IsCoop() then
			self:RespawnItem(2)
		else
			self:Remove()
		end
		self.Pickable = false
	end
end