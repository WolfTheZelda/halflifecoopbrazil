AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.StartSound = Sound("items/medshot4.wav")
ENT.ChargeSound = Sound("items/medcharge4.wav")
ENT.DenySound = Sound("items/medshotno1.wav")

ENT.PointAdd = 1
ENT.ChargeDelay = .1
ENT.RestoreTime = 30
ENT.SkillCVar = "sk_healthcharger"

function ENT:IsUsable(ply)
	return !self.Disabled and (ply:Health() < ply:GetMaxHealth() or !ply:IsPlayer()) and self.MaxCharge > 0
end

function ENT:PlyCharge(ent)
	if ent:IsPlayer() then
		ent:SetHealth(ent:Health() + self.PointAdd)
	elseif ent:IsWeapon() then
		ent.Owner:SetAmmo(ent:Ammo1() + self.PointAdd, ent.Primary.Ammo)
	end
end