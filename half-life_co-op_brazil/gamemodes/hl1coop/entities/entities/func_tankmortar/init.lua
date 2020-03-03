AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Usable = true
ENT.FireSound = "ambience/biggun3.wav"

function ENT:KeyValue( k, v )
	if k == "model" then
		self.Model = v
	end
	if k == "targetname" then
		self.targetname = v
	end
	if k == "OnFire" then
		--print("sound: " .. v)
	end
	if k == "firerate" then
		self.fireRate = v
	end
	if k == "firespread" then
		self.spread = v + 1
	end
	if k == "persistence" then
		self.persist = v
	end		
	if k == "barrel" then
		self.BarrelPos = tonumber(v)
	end
	if k == "iMagnitude" then
		self.impulse = v
	end
	if k == "control_volume" then
		self.ControlTrigger = v
	end
	--print(k,v)
end

function ENT:Initialize()
	self:SetModel(self.Model)

	self:SetNotSolid(false)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_PUSH)
	//self:SetUseType(SIMPLE_USE)
	self:SetNoDraw(false)
	
	if self.targetname then
		for k, v in pairs(ents.FindByClass("func_tank")) do
			if v:GetName() == self.targetname then
				self:SetParent(v)
			end
		end
	end

	local parentEnt = self:GetParent()
	if IsValid(parentEnt) then
		self:SetAngles(parentEnt:GetAngles())
		self.Usable = false
	end
	--self:SetUseType(ONOFF_USE)
	self.NextUseTime = CurTime()
	self.NextAttack = CurTime()
	
	self.StartAngle = self:GetAngles()

	if !self.fireRate then
		self.fireRate = 1
	end
end

function ENT:IsUserInTrigger(ply)
	local inTrigger
	if self.ControlTrigger then
		for k, v in pairs(ents.FindInBox(ply:WorldSpaceAABB())) do
			if v:IsTrigger() and v:GetName() == self.ControlTrigger then
				inTrigger = true
				break
			end
		end
		if !inTrigger then return false end
	end
	return true
end

function ENT:StartUsing(ply)
	if !self:IsUserInTrigger(ply) then return end
	self.Attacker = ply
	self.lastwep = ply:GetActiveWeapon()
	if IsValid(self.lastwep) then
		self.lastwep:SendWeaponAnim(ACT_VM_HOLSTER)
	end
	ply:SetActiveWeapon(NULL)
	ply:DrawViewModel(false)
	ply.UseEntity = self
	self:EmitSound("items/clipinsert1.wav", 80, 150)
	self.InUse = true
end

function ENT:StopUsing(ply)
	if self.Attacker and IsValid(self.Attacker) then
		self.Attacker:SetActiveWeapon(self.lastwep)
		if IsValid(self.lastwep) then
			self.lastwep:SendWeaponAnim(ACT_VM_DRAW)
		end
		self.Attacker.UseEntity = NULL
		self.Attacker:DrawViewModel(true)
	end
	self.Attacker = nil
	self.InUse = false
end

function ENT:Use(activator, caller, useType, value)
	if !self.Usable then return end
	if self.Attacker and caller != self.Attacker then return end
	if self.NextUseTime <= CurTime() then
		if !self.InUse then
			self:StartUsing(caller)
		else
			self:StopUsing()
		end
		self.NextUseTime = CurTime() + 1
	end
end

function ENT:Think()
	local owner = self.Attacker
	if IsValid(owner) then
		if !IsValid(owner) or !self:IsUserInTrigger(owner) or !owner:Alive() or owner:KeyPressed(IN_USE) then
			self:StopUsing()
			return
		end
	
		local ang = owner:EyeAngles()
		ang[1] = math.ApproachAngle(self:GetAngles()[1], ang[1], FrameTime()*128)
		ang[1] = math.Clamp(ang[1], self.StartAngle[1] -3, self.StartAngle[1] + 3)
		ang[2] = math.ApproachAngle(self:GetAngles()[2], ang[2], FrameTime()*128)
		ang[2] = math.Clamp(ang[2], self.StartAngle[2] -25, self.StartAngle[2] + 25)
		ang[3] = 0
		self:SetAngles(ang)

		if owner:KeyDown(IN_ATTACK) then
			local aimvec = self:GetForward()
			local tr = util.TraceLine({
				start = owner:GetShootPos(),
				endpos = owner:GetShootPos() + aimvec * 4096,
				filter = {self, owner},
				mask = MASK_SHOT
			})
			self:DoFire(owner, tr)
		end
	elseif IsValid(self:GetParent()) and GetConVarNumber("ai_disabled") <= 0 and GetConVarNumber("ai_ignoreplayers") <= 0 then
		local parentEnt = self:GetParent()
		local target = parentEnt:GetSaveTable().m_hFuncTankTarget
		local startPos = self:GetPos() + self:GetForward() * self.BarrelPos
		if IsValid(target) then
			local targetPos = target:BodyTarget(startPos)
			local ang = (targetPos - self:GetPos()):Angle()
			ang:Normalize()
			ang = ang[1]
			ang = math.Clamp(ang, -4, 5)
			ang = math.ApproachAngle(self:GetLocalAngles()[1], ang, FrameTime() * 25)
			self:SetLocalAngles(Angle(ang, 0, 0))
	
			local tr = util.TraceHull({
				start = startPos,
				endpos = targetPos + self:GetForward() * 300,
				filter = {self, parentEnt},
				mins = Vector(-3, -3, -3),
				maxs = Vector(3, 3, 3)
			})

			if tr.Hit and tr.Entity:IsPlayer() then
				local dist = tr.StartPos:Distance(tr.HitPos) / 80
				local rand = VectorRand() * dist
				tr = util.TraceHull({
					start = tr.StartPos,
					endpos = tr.HitPos + rand,
					filter = {self, parentEnt},
					mins = Vector(-3, -3, -3),
					maxs = Vector(3, 3, 3)
				})
				self:DoFire(parentEnt, tr)
			else
				self:FindNewTarget(startPos, parentEnt)
			end
		else
			self:FindNewTarget(startPos, parentEnt)
		end
	end
	self:NextThink(CurTime() + .1)
	return true
end

function ENT:FindNewTarget(pos, parentEnt)
	--if player.GetCount() <= 1 and !self.FixTankEntity then return end
	for k, v in pairs(ents.FindInPVS(pos)) do
		if v:IsPlayer() and v:Alive() and (v:Visible(self) or v:Visible(parentEnt)) then
			parentEnt:SetSaveValue("m_hFuncTankTarget", v)
			parentEnt:SetSaveValue("m_hTarget", v)
			return
		end
	end
	self.NextAttack = CurTime() + self.persist
end

function ENT:DoMuzzleflash()
	local fx = EffectData()
	fx:SetEntity(self)
	fx:SetOrigin(self:GetPos() + self:GetForward() * self.BarrelPos)
	fx:SetNormal(self:GetForward())
	fx:SetScale(50)
	util.Effect("hl1_mflash", fx)
	util.Effect("hl1_mflash_smoke", fx)
end

function ENT:DoFire(owner, tr)
	if self.NextAttack and self.NextAttack > CurTime() then return end
	self.NextAttack = CurTime() + (1/self.fireRate)
	self:DoMuzzleflash()
	self:EmitSound(self.FireSound, 400, 100)

	util.BlastDamage(self, owner, tr.HitPos, 400, self.impulse)
	local efpos = tr.HitPos
	if tr.HitNormal:Length() == 0 then
		efpos = efpos + Vector(0,0,128)
	end
	self:ExplosionEffects(efpos, tr.HitNormal, 63)
	hook.Run("OnEntityExplosion", self, tr.HitPos, 350, self.impulse)
end