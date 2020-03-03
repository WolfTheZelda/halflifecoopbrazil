AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetTrigger(true)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:SetNotSolid(true)
	if !self.WaitTimer then
		self.WaitTimer = 30
	end
	if !self.WaitType then
		self.WaitType = WAIT_NOMOVE
	end
	self.PlyTable = {}
end

function ENT:SetTimer(t)
	self.WaitTimer = t
end

function ENT:OnRemove()
	self:ClearPlayerFlags()
end

function ENT:ClearPlayerFlags()
	if self.PlyTable then
		for k, v in pairs(self.PlyTable) do
			if IsValid(v) then
				if self.WaitType != WAIT_FREE then
					if v:IsFrozen() then
						v:UnLock()
						v:Freeze(false)
					end
					v:RemoveFlags(FL_ATCONTROLS)
					v:RemoveFlags(FL_GODMODE)
					v:RemoveFlags(FL_NOTARGET)
					v:SetColor(Color(255, 255, 255, 255))
					v:SetRenderMode(RENDERMODE_NORMAL)
					if v:IsChasing() then
						v:ChasePlayer() -- stops chasing
					end
				end
				v:SetWaitBool(false)
			end
		end
	end
end

function ENT:Deactivate()
	self:ClearPlayerFlags()
	if self.PlyTable then
		table.remove(self.PlyTable)
	end
	GAMEMODE:SetGlobalFloat("WaitTime", 0)
	
	if self.EndFunction then
		self.EndFunction()
	end
	
	if self.HEVRequire or self.FinalTrigger and GAMEMODE:GetSpeedrunMode() then
		self.Inactive = true
	else
		self:Remove()
	end
end

function ENT:Reset()
	self.RemoveTimer = nil
	GAMEMODE:SetGlobalFloat("WaitTime", 0)
end

function ENT:Think()
	if self.Inactive then return end
	if self.RemoveTimer then
		if self.EndFunction and self.PlyTable then
			for k, v in pairs(self.PlyTable) do
				if !IsValid(v) or v:Team() != TEAM_COOP then
					table.RemoveByValue(self.PlyTable, v)
				end
			end
		end
		if self.RemoveTimer <= CurTime() or #self.PlyTable == GAMEMODE:GetActivePlayersNumber() then
			self:Deactivate()
		end
		if self.EndFunction and #self.PlyTable <= 0 then
			self:Reset()
		end
	end
end

function ENT:StartTouch(ent)
	if self.FinalTrigger and ent:IsPlayer() and ent:Alive() and GAMEMODE:GetSpeedrunMode() then
		GAMEMODE:PlayerHasFinishedMap(ent)
	end
end

function ENT:Touch(ent)
	if ent:IsPlayer() and ent:Alive() then
		if self.HEVRequire and !ent:IsSuitEquipped() then
			ent:TextMessageCenter("#game_getsuit", 1)
			ent:SetVelocity(self:GetForward() * -1000)
			return
		end
		if self.Inactive then return end
		if !self.FinalTrigger and GAMEMODE:GetSpeedrunMode() or GAMEMODE:GetActivePlayersNumber() < 2 then
			self:Deactivate()
			return
		end
		if !table.HasValue(self.PlyTable, ent) then
			table.insert(self.PlyTable, ent)
			if self.WaitType != WAIT_FREE then
				if self.WaitType == WAIT_NOMOVE then
					ent:AddFlags(FL_ATCONTROLS)
				elseif self.WaitType == WAIT_FREEZE then
					ent:Freeze(true)
				elseif self.WaitType == WAIT_LOCK then
					ent:Lock()
				end
				ent:AddFlags(FL_GODMODE)
				ent:AddFlags(FL_NOTARGET)
				ent:SetColor(Color(150, 150, 150, 150))
				ent:SetRenderMode(RENDERMODE_TRANSALPHA)
			end
			ent:SetWaitBool(true)
		end
		if !self.RemoveTimer then
			self.RemoveTimer = CurTime() + self.WaitTimer
			GAMEMODE:SetGlobalFloat("WaitTime", CurTime() + self.WaitTimer)
		end
	end
end