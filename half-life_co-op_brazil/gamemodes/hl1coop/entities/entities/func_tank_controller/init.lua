AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetNoDraw(true)
	self:SetSolid(SOLID_NONE)
	self.ParentEnt = self:GetParent()
end

function ENT:Think()
	if IsValid(self.ParentEnt) and GetConVarNumber("ai_disabled") <= 0 and GetConVarNumber("ai_ignoreplayers") <= 0 then
		local target = self.ParentEnt:GetSaveTable().m_hTarget
		if self.Explosive and IsValid(target) then
			local dist = self:GetPos():DistToSqr(target:GetPos())
			if dist <= 80000 then
				target = NULL
				self:SetTarget(target)
			end
		end
		if !IsValid(target) or !target:Alive() or !target:Visible(self) and !target:Visible(self.ParentEnt) then
			self:FindNewTarget()
		end
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:FindNewTarget()
	local t = {}
	
	for k, v in pairs(ents.FindInPVS(self:GetPos())) do
		if v:IsPlayer() and v:Alive() and (v:Visible(self) or v:Visible(self.ParentEnt)) then
			local dist = self:GetPos():DistToSqr(v:GetPos())
			if self.Explosive and dist > 80000 or !self.Explosive then
				table.insert(t, {v, dist})
			end
		end
	end
	table.sort(t, function(a,b) return a[2] < b[2] end)
	
	t = t[1]
	if t then
		local target = t[1]
		if IsValid(target) then
			self:SetTarget(target)
		end
	end
end

function ENT:SetTarget(ent)
	self.ParentEnt:SetSaveValue("m_hTarget", ent)
end