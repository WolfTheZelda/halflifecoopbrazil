AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.m_soundNames = {
	Sound("debris/pushbox1.wav"),
	Sound("debris/pushbox2.wav"),
	Sound("debris/pushbox3.wav")
}

ENT.pSpawnObjects =
{
	NULL,				// 0
	"item_battery",		// 1
	"item_healthkit",	// 2
	"weapon_glock",		// 3
	"ammo_9mmclip",		// 4
	"weapon_mp5",		// 5
	"ammo_9mmAR",		// 6
	"ammo_ARgrenades",	// 7
	"weapon_shotgun",	// 8
	"ammo_buckshot",	// 9
	"weapon_crossbow",	// 10
	"ammo_crossbow",	// 11
	"weapon_357",		// 12
	"ammo_357",			// 13
	"weapon_rpg",		// 14
	"ammo_rpgclip",		// 15
	"ammo_gaussclip",	// 16
	"weapon_handgrenade",// 17
	"weapon_tripmine",	// 18
	"weapon_satchel",	// 19
	"weapon_snark",		// 20
	"weapon_hornetgun",	// 21
}

ENT.pSoundsWood = {
	"debris/wood1.wav",
	"debris/wood2.wav",
	"debris/wood3.wav",
}
ENT.pSoundsWoodBreak = {
	"debris/bustcrate1.wav",
	"debris/bustcrate2.wav",
}

ENT.pSoundsFlesh = {
	"debris/flesh1.wav",
	"debris/flesh2.wav",
	"debris/flesh3.wav",
	"debris/flesh5.wav",
	"debris/flesh6.wav",
	"debris/flesh7.wav",
}
ENT.pSoundsFleshBreak = {
	"debris/bustflesh1.wav",
	"debris/bustflesh2.wav",
}

ENT.pSoundsMetal = {
	"debris/metal1.wav",
	"debris/metal2.wav",
	"debris/metal3.wav",
}
ENT.pSoundsMetalBreak = {
	"debris/bustmetal1.wav",
	"debris/bustmetal2.wav",
}

ENT.pSoundsConcrete = {
	"debris/concrete1.wav",
	"debris/concrete2.wav",
	"debris/concrete3.wav",
}
ENT.pSoundsConcreteBreak = {
	"debris/bustconcrete1.wav",
	"debris/bustconcrete2.wav",
}

ENT.pSoundsGlass = {
	"debris/glass1.wav",
	"debris/glass2.wav",
	"debris/glass3.wav",
}
ENT.pSoundsGlassBreak = {
	"debris/bustglass1.wav",
	"debris/bustglass2.wav",
}

function ENT:KeyValue( k, v )
	if k == "model" then
		self.Model = v
	end
	if k == "buoyancy" then
		self.skin = v
	end
	if k == "friction" then
		self.friction = v
	end
	
	if k == "spawnobject" then
		local num = tonumber(v)
		if num > 0 then
			self.spawnobject = self.pSpawnObjects[num + 1]
		end
	end
	--print(k,v)
end

function ENT:Initialize()
	self:SetModel(self.Model)
	local mins, maxs = self:GetCollisionBounds()

	self:SetMoveType(MOVETYPE_STEP)
	self:SetSolid(SOLID_BBOX)
	local s = 1
	mins, maxs = mins + Vector(s,s,.01), maxs - Vector(s,s,0)
	self:SetCollisionBounds(mins, maxs)
	
	self.friction = self:GetKeyValues().friction

	if self.friction > 399 then
		self.friction = 399
	end
	
	self.m_maxSpeed = 400 - self.friction
	self.friction = 0
	self:SetFriction(1)
	self:SetGravity(1)
	
	self:SetPos(self:GetPos() + Vector(0, 0, 1)) // Pick up off of the floor
	local tr = util.TraceEntity({
		start = self:GetPos(),
		endpos = self:GetPos(),
		filter = self
	}, self)
	if IsValid(tr.Entity) then
		tr = util.TraceLine({
			start = tr.HitPos,
			endpos = tr.Entity:GetPos(),
			filter = self
		})
		self:SetPos(self:GetPos() + tr.HitNormal / 10)
	else
		tr = util.TraceLine({
			start = self:GetPos() + self:OBBMaxs(),
			endpos = self:GetPos() + self:OBBMins(),
			filter = self
		})
		if tr.Hit then
			if tr.HitNormal:IsZero() then
				tr = util.TraceLine({
					start = self:GetPos() + self:OBBMins(),
					endpos = self:GetPos() + self:OBBMaxs(),
					filter = self
				})
			end			
			self:SetPos(self:GetPos() + tr.HitNormal / 10)
		end
	end
	
	if self.skin then
		self.skin = (self.skin * (maxs.x - mins.x) * (maxs.y - mins.y)) * 0.0005
	end
	self.m_soundTime = 0
	
	local MatType = Material(self:GetMaterials()[1]):GetString("$surfaceprop")
	if MatType == "wood" then
		self.HitSndTable = self.pSoundsWood
		self.BreakSndTable = self.pSoundsWoodBreak
		self.GibType = 2
	elseif MatType == "metal" then
		self.HitSndTable = self.pSoundsMetal
		self.BreakSndTable = self.pSoundsMetalBreak
		self.GibType = 3
	end
	
	if self.HitSndTable then
		for k, v in pairs(self.HitSndTable) do
			util.PrecacheSound(v)
		end
	end
	if self.BreakSndTable then
		for k, v in pairs(self.BreakSndTable) do
			util.PrecacheSound(v)
		end
	end
end

function ENT:Use(pActivator, pCaller, useType, value)
	--[[if !pActivator or !IsValid(pActivator) or !pActivator:IsPlayer() then
		if self:HasSpawnFlags(SF_PUSH_BREAKABLE) then
			self:Use(pActivator, pCaller, useType, value)
		end
		return
	end]]--
	if pActivator:GetVelocity() != Vector() then
		self:Move(pActivator, false)
	end
end

function ENT:Think()
	self:NextThink(CurTime())
	return true
end

function ENT:Touch(pOther)
	if pOther:GetClass() == "worldspawn" then
		return
	end
	local tr = util.TraceEntity({
		start = self:GetPos(),
		endpos = self:GetPos(),
		filter = self
	}, self)
	local gndEnt = self:GetGroundEntity()
	if IsValid(gndEnt) then
		local vel = gndEnt:GetVelocity()
		if vel:Length() > 0 then
			if tr.Hit and (!IsValid(self:GetParent()) or self:GetMoveType() != MOVETYPE_NONE) then
				debugPrint(tr.Entity, "is blocking", gndEnt, "with", self)
				self:SetMoveType(MOVETYPE_NONE)
				self:SetParent(gndEnt)
			end
		else
			if IsValid(self:GetParent()) or self:GetMoveType() != MOVETYPE_STEP then
				self:SetMoveType(MOVETYPE_STEP)
				self:SetParent()
			end
		end
	end
	if tr.Hit and pOther == tr.Entity then return end
	self:Move(pOther, true)
end

function ENT:MaxSpeed()
	return self.m_maxSpeed
end

function ENT:Move(pOther, push)
	local pevToucher = pOther
	local playerTouch = false
	local velocity = Vector()
	
	local gndEnt = self:GetGroundEntity()
	if IsValid(gndEnt) then
		local vel = gndEnt:GetVelocity()
		if vel:Length() == 0 and (IsValid(self:GetParent()) or self:GetMoveType() != MOVETYPE_STEP) then
			self:SetMoveType(MOVETYPE_STEP)
			self:SetParent()
		end
	end
	
	// Is entity standing on this pushable ?
	local groundEnt = pevToucher:GetGroundEntity()
	if pevToucher:OnGround() and IsValid(groundEnt) and (groundEnt == self or groundEnt:GetClass() == self:GetClass()) then
		// Only push if floating
		if self:WaterLevel() > 0 then
			velocity.z = velocity.z + pevToucher:GetVelocity().z * .1
			self:SetLocalVelocity(velocity)
		end
		return
	end
	
	if pOther:IsPlayer() then
		if push && !(pevToucher:KeyDown(bit.bor(IN_FORWARD, IN_USE))) then	// Don't push unless the player is pushing forward and NOT use (pull)
			local tr = self:GetTouchTrace()
			if IsValid(tr.Entity) and tr.Entity:IsPlayer() then
				tr.Entity:SetLocalVelocity(self:GetVelocity())
			end
			return
		end
		playerTouch = true
	end
	
	local factor
	
	if playerTouch then
		if !pevToucher:OnGround() then	// Don't push away from jumping/falling players unless in water
			if self:WaterLevel() < 1 then
				return
			else
				factor = .1
			end
		else
			factor = !push and GAMEMODE:IsCoop() and !GAMEMODE:GetSpeedrunMode() and .1375 or 1
		end
	else
		factor = 0.25
	end

	local velocity = self:GetVelocity()
	velocity.x = velocity.x + pevToucher:GetVelocity().x * factor
	velocity.y = velocity.y + pevToucher:GetVelocity().y * factor
	self:SetLocalVelocity(velocity)
	
	local length = velocity:Length()
	if push and (length > self:MaxSpeed()) then
		local velocity = self:GetVelocity()
		velocity.x = (velocity.x * self:MaxSpeed() / length )
		velocity.y = (velocity.y * self:MaxSpeed() / length )
		self:SetLocalVelocity(velocity)
	end
	if playerTouch then
		local toucherVelocity = Vector()
		local velocity = self:GetVelocity()
		toucherVelocity.x = velocity.x
		toucherVelocity.y = velocity.y
		if !GAMEMODE:IsCoop() or GAMEMODE:GetSpeedrunMode() then
			pevToucher:SetVelocity(toucherVelocity / 3)
		end
		if (CurTime() - self.m_soundTime) > 0.7 then
			self.m_soundTime = CurTime()
			self.m_lastSound = math.random(1, 3)
			if length > 0 and self:OnGround() then
				self:EmitSound(self.m_soundNames[self.m_lastSound], 80, 100, 0.5, CHAN_WEAPON)
			else
				//self:StopSound(self.m_soundNames[self.m_lastSound])
			end
		end
	end
end

function ENT:DamageSound()
	local pitch

	if math.random(0,2) > 0 then
		pitch = 100
	else
		pitch = 95 + math.random(0, 34)
	end
	
	local fvol = math.Rand(0.75, 1)
	
	if self.HitSndTable then
		self:EmitSound(self.HitSndTable[math.random(1,#self.HitSndTable)], 80, pitch, fvol, CHAN_VOICE)
	end
end
	
function ENT:OnTakeDamage(dmginfo)
	if self.entKilled then return end
	local pevInflictor, pevAttacker, flDamage, bitsDamageType = dmginfo:GetInflictor(), dmginfo:GetAttacker(), dmginfo:GetDamage(), dmginfo:GetDamageType()
	if self:GetKeyValues().spawnflags == 128 then
		// do the damage
		self:SetHealth(self:Health() - flDamage)
		if self:Health() <= 0 then
			self.entKilled = true
			self:Killed(dmginfo:GetDamageForce(), 16)
			self:Die()
			self:Remove()
			return
		end
		
		self:DamageSound()
	end
end

function ENT:Die()
	local pitch = 95 + math.random(0,29)
	if pitch > 97 && pitch < 103 then
		pitch = 100
	end
	
	// The more negative pev->health, the louder
	// the sound should be.

	local fvol = math.Rand(0.85, 1.0) + (math.abs(self:Health()) / 100.0)
	if fvol > 1.0 then
		fvol = 1.0
	end
	
	if self.BreakSndTable then
		self:EmitSound(self.BreakSndTable[math.random(1,2)], 80, pitch, fvol, CHAN_VOICE)
	end
	
	if self.spawnobject then
		local dropEnt = ents.Create(self.spawnobject)
		if IsValid(dropEnt) then
			dropEnt:SetPos(self:GetPos())
			dropEnt:Spawn()
		end
	end
end

function ENT:Killed(force, amount)
	local effectdata = EffectData()
	effectdata:SetFlags(self.GibType)
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetNormal(force)
	effectdata:SetScale(amount)
	util.Effect("hl1_gib_emitter", effectdata, true)
end