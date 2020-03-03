function EFFECT:Init(data)
	self.LifeTime = CurTime() + 8
	self:SetModel("models/woodgibs.mdl")
	self:SetBodygroup(0, math.random(0, self:GetBodygroupCount(0)))
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:PhysicsInitBox(Vector( -2 -2, 0 ), Vector( 2, 2, 1 ))
	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then
		phys:SetMaterial("gmod_silent")
		phys:SetMass(.1)
		phys:Wake()
		phys:SetAngles( Angle( math.Rand(0,360), math.Rand(0,360), math.Rand(0,360) ) )
		phys:AddAngleVelocity(VectorRand() * math.Rand(-180, 180))
		phys:SetVelocity( data:GetNormal() * 60 + VectorRand() * math.Rand( 100, 250 ) )
	end
end

function EFFECT:Think()
	return self.LifeTime > CurTime()
end

function EFFECT:Render()
	local alpha = math.Clamp(255 * (self.LifeTime - CurTime()), 0, 255)
	self:SetColor(Color(255, 255, 255, alpha))
	self:DrawModel()
end