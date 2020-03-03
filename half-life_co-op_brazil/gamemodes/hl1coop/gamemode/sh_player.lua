local meta = FindMetaTable("Player")

function meta:SetupDataTables()
	self:NetworkVar("Int", 0, "Score")
end
	
function meta:CanChasePlayer()
	return !GetGlobalBool("FirstLoad") and !GetGlobalBool("FirstWaiting") and self:IsFrozen() --and self.InWaitTrigger
end

function meta:CanJoinGame()
	return true
end
	
function meta:IsChasing()
	local viewent = self:GetViewEntity()
	return IsValid(viewent) and viewent:IsPlayer() and viewent != self
end

function meta:IsSpectator()
	return self:Team() == TEAM_SPECTATOR or self:IsDeadInSurvival()
end

function meta:IsDeadInSurvival()
	return GAMEMODE:GetSurvivalMode() and !self:Alive() and self:Team() == TEAM_COOP
end
	
function meta:IsStuck()
	if !IsValid(self) or self:GetMoveType() == MOVETYPE_NOCLIP or !self:Alive() then return end
	local tr = util.TraceEntity({
		start = self:GetPos(), --+ Vector(0, 0, 1),
		endpos = self:GetPos(), --+ Vector(0, 0, 1),
		filter = player.GetAll(),
		mask = MASK_PLAYERSOLID
	}, self)
	local worldEntities = {
		["func_breakable"] = true,
		["func_pushable"] = true,
		["func_train"] = true,
		["func_trackchange"] = true,
		["func_tracktrain"] = true,
		["func_movelinear"] = true,
		["func_door"] = true,
		["func_door_rotating"] = true,
		["func_healthcharger"] = true,
		["func_recharge"] = true,
		["func_tank"] = true,
		["func_tankmortar"] = true,
		["func_rotating"] = true,
		["hl1_playerclip"] = true
	}
	--print(tr.Hit, tr.Entity, tr.HitWorld, self:OnGround())
	return tr.HitWorld or (IsValid(tr.Entity) and (worldEntities[tr.Entity:GetClass()] or tr.Entity:IsNPC()))
end

if SERVER then

	local cvar_wboxstay = CreateConVar("hl1_coop_sv_wboxstay", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Players cannot pickup other's weaponbox")

	function meta:SetupMovementParams()
		self:SetRunSpeed(160)
		self:SetWalkSpeed(320)
		local gravity = GetConVarNumber("sv_gravity")
		self:SetJumpPower(math.sqrt(2 * gravity * 45.0))
		self:SetCrouchedWalkSpeed(.4)
		self:SetDuckSpeed(.4)
		self:SetUnDuckSpeed(.15)
	end

	function meta:AddScore(n)
		if n != 0 then
			self:SetScore(self:GetScore() + n)
			self:SendScreenMessageScore(n)
		end
	end
	
	function meta:Unstuck()
		self:ChatPrint("You are stuck. Let's fix this.")
		timer.Simple(1, function()
			if self:IsStuck() then
				for i = 0, 5 do
					if self:IsStuck() then
						local tr = util.TraceLine({
							start = self:GetPos() + self:OBBMins(),
							endpos = self:GetPos() + self:OBBMaxs(),
							filter = self
						})
						local norm = tr.HitNormal
						if norm:IsZero() then
							tr = util.TraceLine({
								start = self:GetPos() + self:OBBMaxs(),
								endpos = self:GetPos() + self:OBBMins(),
								filter = self
							})
							norm = tr.HitNormal
						end
						if norm:IsZero() then
							norm = (tr.HitPos - self:GetPos()):GetNormalized()
						end
						self:SetPos(self:GetPos() + norm * 16)
						if i == 5 and self:IsStuck() then
							local spawnpoint = hook.Call("PlayerSelectSpawn", GAMEMODE, self, true)
							if IsValid(spawnpoint) then
								self:SetPos(spawnpoint:GetPos())
								self:SetEyeAngles(spawnpoint:GetAngles())
								self.canTakeDamage = nil
							else
								print("Cannot find spawnpoint!")
							end
						end
					else
						break
					end
				end
			else
				self:ChatPrint("Canceled!")
			end
		end)
	end
	
	function meta:DropWeaponBox(noowner)
		local wbox = ents.Create("weaponbox")
		if IsValid(wbox) then
			local weapons = GAMEMODE:StorePlayerAmmunition(self)
			if weapons then
				wbox:SetPos(self:GetPos())
				wbox:SetWeaponTable(weapons)
				if !noowner then
					wbox:SetOwner(self)
				end
				wbox:Spawn()
				
				if !GAMEMODE:GetSpeedrunMode() and !cvar_wboxstay:GetBool() then 
					self.wboxEnt = wbox
				end
				
				local glow = ents.Create("env_sprite")
				glow:SetKeyValue("rendercolor", "224 224 255")
				glow:SetKeyValue("GlowProxySize", "2")
				glow:SetKeyValue("HDRColorScale", "1")
				glow:SetKeyValue("renderfx", "15")
				glow:SetKeyValue("rendermode", "3")
				glow:SetKeyValue("renderamt", "64")
				glow:SetKeyValue("model", "sprites/animglow01.vmt")
				glow:SetKeyValue("scale", ".64")
				glow:SetParent(wbox)
				glow:SetPos(wbox:GetPos() + Vector(0,0,32))
				glow:Spawn()
			end
		end
	end

	function meta:SetWaitBool(b)
		net.Start("PlayerWaitBool")
		net.WriteEntity(self)
		net.WriteBool(b)
		net.Broadcast()
	end
	
	function meta:SetLongJumpBool(b)
		--[[self.LongJump = b
		net.Start("SetLongJumpClient")
		net.WriteBool(b)
		net.Send(self)]]--
		self:SetNW2Bool("LongJump", b)
	end
	
	function meta:ResetVars()
		self.DeathEnt = nil
		self.DeathPos = nil
		self.DeathAng = nil
		self.DeathDuck = nil
		self.KilledByFall = nil
		self:SetLongJumpBool(nil)
	end
	
	function meta:ChasePlayer(ply)
		local viewent = self:GetViewEntity()
		if IsValid(viewent) and viewent:GetClass() == "point_viewcontrol" then return end
		
		if self:CanChasePlayer() and IsValid(ply) and ply:IsPlayer() and ply:Alive() and !ply:IsFrozen() and ply != self and ply:GetViewEntity() == ply then
			self:SetViewEntity(ply)
			self:SendScreenHint(2)
		else
			self:SetViewEntity()		
		end
	end

	function meta:SendScreenMessageScore(msg)
		net.Start("ScreenMessageScore")
		net.WriteInt(msg, 32)
		net.Send(self)
	end
	
	function meta:TextMessageCenter(msg, delay)
		net.Start("TextMessageCenter")
		net.WriteString(msg)
		net.WriteFloat(delay)
		net.Send(self)
	end
	
	function meta:SendScreenHint(t, delay)
		delay = delay or 8
		net.Start("ShowScreenHint")
		net.WriteUInt(t, 5)
		net.WriteFloat(delay)
		net.Send(self)
	end
	
	function meta:SendScreenHintTop(text, delay)
		delay = delay or 8
		net.Start("ShowScreenHintTop")
		net.WriteString(text)
		net.WriteFloat(delay)
		net.Send(self)
	end

	function meta:ChatMessage(msg, t)
		t = t or 1
		net.Start("ChatMessage")
		net.WriteString(msg)
		net.WriteUInt(t, 4)
		net.Send(self)
	end
	
	local teleSound = Sound("debris/beamstart8.wav")

	function meta:TeleportToCheckpoint(dest, ang, weptable)
		self:SetPos(dest + Vector(0, 0, 8))
		if ang then
			self:SetEyeAngles(ang)
		end
		self:SetLocalVelocity(Vector(0,0,0))
		self:ScreenFade(SCREENFADE.IN, Color(0, 180, 0, 120), 1, 0)
		self:EmitSound(teleSound, 70, 100, .5)
		if weptable then
			if istable(weptable) then
				for k, v in pairs(weptable) do
					self:Give(v)
				end
			else
				if weptable == "item_suit" and self:IsSuitEquipped() then return end
				self:Give(weptable)
			end
		end
	end

end