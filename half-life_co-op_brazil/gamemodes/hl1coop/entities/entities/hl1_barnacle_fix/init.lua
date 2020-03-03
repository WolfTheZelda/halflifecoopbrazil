AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:TongueTouchEnt()	
	local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = self.ParentEnt:GetPos() - Vector(0, 0, 2048),
		filter = {self, self.ParentEnt},
		mask = MASK_SOLID_BRUSHONLY
	})
	
	local length = math.abs(self.ParentEnt:GetPos()[3] - tr.HitPos[3])
	// Pull it up a tad
	length = length - 16
	
	return tr, length
end

function ENT:Initialize()
	self:SetNoDraw(true)
	self:SetSolid(SOLID_NONE)
	self.ParentEnt = self:GetParent()
	self.tongueAdj = self.ParentEnt:GetInternalVariable("m_flTongueAdj")
end

function ENT:Think()
	if self.ParentEnt:Health() <= 0 then self:Remove() return end
	
	local enemy = self.ParentEnt:GetEnemy()
	if IsValid(enemy) and enemy:IsPlayer() and enemy:Alive() then
		local m_fLiftingPrey = self.ParentEnt:GetSaveTable().m_fLiftingPrey
		if !m_fLiftingPrey then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(cvars.Number("sk_barnacle_bite", 15))
			dmginfo:SetAttacker(self.ParentEnt)
			dmginfo:SetInflictor(self.ParentEnt)
			dmginfo:SetDamageType(DMG_ALWAYSGIB)
			enemy:TakeDamageInfo(dmginfo)
		end
	end

	if self.tongueAdj then
		self.ParentEnt:SetSaveValue("m_flTongueAdj", self.tongueAdj + math.random(-1, 1))
	end
	
	self:NextThink(CurTime() + 1)
	return true
end