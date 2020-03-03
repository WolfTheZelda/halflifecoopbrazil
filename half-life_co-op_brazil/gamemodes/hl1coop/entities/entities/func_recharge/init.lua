AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.StartSound = Sound("items/suitchargeok1.wav")
ENT.ChargeSound = Sound("items/suitcharge1.wav")
ENT.DenySound = Sound("items/suitchargeno1.wav")

ENT.PointAdd = 1
ENT.ChargeDelay = .1
ENT.RestoreTime = 30
ENT.SkillCVar = "sk_suitcharger"

function ENT:KeyValue(k, v)
	if k == "model" then
		self.Model = v
	end
end

function ENT:Initialize()
	self:SetModel(self.Model)

	self:SetNotSolid(false)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_PUSH)
	self:SetUseType(CONTINUOUS_USE)
	self:SetNoDraw(false)
	
	self.MaxCharge = cvars.Number(self.SkillCVar)
	self.flSoundTime = 0
	self.flChargeSoundTime = 0
	self.flChargeSoundStop = 0
	self:SetHealth(1000)
end

function ENT:SetTextureFrameIndex(num)
	self:SetKeyValue("texframeindex", num)
end

function ENT:Deny()
	if self.flSoundTime <= CurTime() then
		self:EmitSound(self.DenySound)
		self.flSoundTime = CurTime() + .62
	end
end	

function ENT:Off()
	self.Disabled = true
	self:SetTextureFrameIndex(1)
	self:Deny()
end

function ENT:On()
	self:SetTextureFrameIndex(0)
	self.Disabled = false
end

function ENT:IsUsable(ply)
	return !self.Disabled and ply:Armor() < 100 and self.MaxCharge > 0
end

function ENT:StartChargeSound()
	self.chargeSnd = CreateSound(self, self.ChargeSound)
	if self.chargeSnd then
		self.chargeSnd:Play()
	end
end

function ENT:StopChargeSound()
	self.StartUse = false
	if self.chargeSnd and self.chargeSnd:IsPlaying() then self.chargeSnd:Stop() end
end

function ENT:PlyCharge(ply)
	ply:SetArmor(ply:Armor() + self.PointAdd)
end

function ENT:Use(activator, caller, useType, value)
	if self.Broken then return end
	if !self.Disabled and self.MaxCharge <= 0 then
		self:Off()
	end
	if !activator.ChargerNextUse then
		activator.ChargerNextUse = 0
	end
	if activator.ChargerNextUse <= CurTime() and (activator:IsPlayer() and activator:IsSuitEquipped() or activator:IsWeapon()) then
		if self:IsUsable(activator) then
			if !self.StartUse then
				self:EmitSound(self.StartSound, 75, 100, 1, CHAN_ITEM)
				self.flChargeSoundTime = CurTime() + .5
				self.StartUse = true
			end
			if self.flChargeSoundTime > 0 and self.flChargeSoundTime <= CurTime() then
				self:StartChargeSound()
				self.flChargeSoundTime = 0
			end
			self:PlyCharge(activator)
			self.MaxCharge = self.MaxCharge - self.PointAdd
			activator.ChargerNextUse = CurTime() + self.ChargeDelay
			self.flChargeSoundStop = CurTime() + self.ChargeDelay + .05
		else
			self:Deny()
			return
		end
	end
end

function ENT:Think()
	if self.Broken then return end
	if !self.Restore and self.MaxCharge <= 0 then
		self.Restore = CurTime() + self.RestoreTime
	end
	if self.Restore and self.Restore <= CurTime() then
		self.MaxCharge = cvars.Number(self.SkillCVar)
		self:EmitSound(self.StartSound)
		self:On()
		self.Restore = nil
	end		
	
	if self.flChargeSoundStop and self.flChargeSoundStop < CurTime() then
		self:StopChargeSound()
		self.flChargeSoundStop = nil
	end
	self:NextThink(CurTime() + .1)
	return true
end

function ENT:OnTakeDamage(dmginfo)
	if self.Broken then return end
	local pevInflictor, pevAttacker, flDamage, bitsDamageType = dmginfo:GetInflictor(), dmginfo:GetAttacker(), dmginfo:GetDamage(), dmginfo:GetDamageType()
	
	self:SetHealth(self:Health() - flDamage)
	if self:Health() <= 0 then
		self.Broken = true
		self:Off()
		util.BlastDamage(self, pevAttacker, self:GetPos(), 64, 50)
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		util.Effect("Explosion", effectdata, true, true)
		return
	end

	local effectdata = EffectData()
	effectdata:SetOrigin(dmginfo:GetDamagePosition())
	if IsValid(pevAttacker) and pevAttacker:IsPlayer() then
		effectdata:SetNormal(-pevAttacker:GetForward())
	end
	effectdata:SetScale(1)
	effectdata:SetMagnitude(1)
	effectdata:SetRadius(2)
	util.Effect("Sparks", effectdata, true, true)
	self:EmitSound("ambient/energy/spark"..math.random(1,6)..".wav")
end