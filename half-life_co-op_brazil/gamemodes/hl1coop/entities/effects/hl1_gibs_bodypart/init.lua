
function EFFECT:Init(data)
	self.GibModelType = data:GetMaterialIndex()
	local GibModel = "models/gibs/hghl1.mdl"
	self.BloodType = "Blood"
	self.LifeTime = CurTime() + 10
	self.emitter = ParticleEmitter(self:GetPos())
	if self.GibModelType == 1 then
		GibModel = "models/gibs/aghl1.mdl"
		self.BloodType = "YellowBlood"
	end
	self:SetModel(GibModel)
	self:SetBodygroup(0, math.random(0, self:GetBodygroupCount(0)))
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:PhysicsInit( SOLID_VPHYSICS )

	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	self:SetCollisionBounds( Vector( -128 -128, -128 ), Vector( 128, 128, 128 ) )

	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then
		phys:SetMaterial("bloodyflesh")
		phys:Wake()
		phys:SetAngles( Angle( math.Rand(0,360), math.Rand(0,360), math.Rand(0,360) ) )
		phys:AddAngleVelocity(VectorRand() * math.Rand(0, 100))
		phys:SetVelocity( data:GetNormal() + VectorRand() * math.Rand( 100, 300 ) )
	end
end

function EFFECT:Think()
	return self.LifeTime > CurTime()
end

function EFFECT:Render()
	local alpha = math.Clamp(255 * (self.LifeTime - CurTime()), 0, 255)
	self:SetColor(Color(255, 255, 255, alpha))
	self:DrawModel()
	--if !cvars.Bool("hl1_cl_particles") then return end
	local FT = FrameTime()
	if self.GibModelType != 1 and FT < .01 and self:GetVelocity():Length() > 100 then
		local BloodPos = self:GetPos() + VectorRand()*4
		local LightColor = render.GetLightColor( BloodPos ) * 255
		LightColor[1] = math.Clamp( LightColor[1], 70, 255 )

		if self.emitter:IsValid() then
			local particle = self.emitter:Add( "effects/blood_core", BloodPos )
			particle:SetDieTime( math.Rand( .5, 1 ) )
			particle:SetStartAlpha( math.Rand(200, 255) )
			particle:SetStartSize( math.Rand( 4, 8 ) )
			particle:SetEndSize( math.Rand( 20, 60 ) )
			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetColor( LightColor[1], 0, 0 )
		end
	end
end

function EFFECT:PhysicsCollide(data, physobj)
	local start = data.HitPos + data.HitNormal
	local endpos = data.HitPos - data.HitNormal

	if data.Speed > 32 and data.DeltaTime > .2 then
		util.Decal(self.BloodType, start, endpos)
	end
end