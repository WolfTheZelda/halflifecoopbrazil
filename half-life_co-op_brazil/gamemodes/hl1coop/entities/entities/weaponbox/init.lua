AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.AmmoNames = {
	["9mm"] = "9mmRound",
	["357"] = "357",
	["buckshot"] = "Buckshot",
	["bolts"] = "XBowBolt",
	["rockets"] = "RPG_Round",
	["uranium"] = "Uranium",
	["Hand Grenade"] = "Grenade",
	["Satchel Charge"] = "Satchel",
	["Trip Mine"] = "TripMine",
	["ARgrenades"] = "MP5_Grenade"
}

ENT.Throwable = {
	["Grenade"] = "weapon_handgrenade",
	["Satchel"] = "weapon_satchel",
	["TripMine"] = "weapon_tripmine",
	["Snark"] = "weapon_snark"
}

ENT.AmmoMaxValues = {
	["9mmRound"] = 250,
	["357"] = 36,
	["Buckshot"] = 125,
	["XBowBolt"] = 50,
	["RPG_Round"] = 5,
	["Uranium"] = 100,
	["Hornet"] = 8,
	["Grenade"] = 10,
	["Satchel"] = 5,
	["TripMine"] = 5,
	["Snark"] = 15,
	["MP5_Grenade"] = 10
}

ENT.AmmoBlacklist = {
	["Hornet"] = true,
	["medkit"] = true
}

function ENT:KeyValue(k, v)
	if !self.Ammo then
		self.Ammo = {}
	end
	if self.Ammo then
		local ammotype = self.AmmoNames[k]
		if ammotype then
			local ammoid = game.GetAmmoID(ammotype)
			table.insert(self.Ammo, ammoid, v)
		end
	end
end

function ENT:Initialize()
	if !self:IsInWorld() then
		self:Remove()
	end
	self:SetModel("models/w_weaponbox.mdl")
	self:SetMoveType(MOVETYPE_FLYGRAVITY)
	self:SetMoveCollide(MOVECOLLIDE_FLY_BOUNCE)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	self:SetTrigger(true)
	self:UseTriggerBounds(true, 24)
	
	self.Pickable = true
end

function ENT:SetWeaponTable(t)
	if !t then return end
	self.Weapons = t
	self.Ammo = {}
	for k, v in pairs(self.Weapons) do
		table.insert(self.Ammo, v[2], v[3])
		if v[4] > -1 then
			table.insert(self.Ammo, v[4], v[5])
		end
	end
end

function ENT:Pickup(ent)
	if IsValid(self:GetOwner()) and self:GetOwner() != ent then return end
	if self.Ammo then
		for k, v in pairs(self.Ammo) do
			if k > -1 then
				local ammoName = game.GetAmmoName(k)
				local inBlacklist = self.AmmoBlacklist[ammoName]
				if !inBlacklist then
					local maxValue = self.AmmoMaxValues[ammoName]
					local ammoCount = ent:GetAmmoCount(k)
					local giveamount = maxValue and math.min(maxValue - ammoCount, v) or tonumber(v)
					ent:GiveAmmo(giveamount, k)
					if maxValue and ammoCount > maxValue then
						ent:SetAmmo(maxValue, k)
					end
					local throwable = self.Throwable[ammoName]
					if throwable and giveamount > 0 then					
						ent:Give(throwable, true)
						local wep = ent:GetWeapon(throwable)
						if IsValid(wep) then
							wep:SetClip1(-1)
						end
					end
				end
			end
		end
	end
	if self.Weapons then
		for k, v in pairs(self.Weapons) do
			if v[1] == "weapon_healthkit" and !(GAMEMODE:GetSurvivalMode() or cvar_medkit:GetBool()) then continue end
			if !ent:HasWeapon(v[1]) then
				local throwable = table.HasValue(self.Throwable, v[1])
				if throwable and v[3] > 0 or !throwable then
					local noDefaultAmmo = true
					if self.AmmoBlacklist[game.GetAmmoName(v[2])] then
						noDefaultAmmo = false
					end
					ent:Give(v[1], noDefaultAmmo)
					local wep = ent:GetWeapon(v[1])
					if v[6] > -1 and wep.Primary.ClipSize > -1 then
						wep:SetClip1(v[6])
					else
						wep:SetClip1(-1)
					end
				end
			end
			--[[local wep = ent:GetWeapon(v[1])
			if IsValid(wep) then
				if wep.Primary.MaxAmmo and ent:GetAmmoCount(v[2]) > wep.Primary.MaxAmmo then
					ent:SetAmmo(wep.Primary.MaxAmmo, v[2])
				end
				if wep.Secondary.MaxAmmo and ent:GetAmmoCount(v[4]) > wep.Secondary.MaxAmmo then
					ent:SetAmmo(wep.Secondary.MaxAmmo, v[4])
				end
			end]]--
		end
	end
	
	ent:EmitSound("items/gunpickup2.wav", 85)
	self.Pickable = false
	if self:ItemShouldRespawn() then
		self:RespawnItem()
	else
		self:Remove()
	end
end