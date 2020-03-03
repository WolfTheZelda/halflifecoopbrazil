
function EFFECT:Init(data)
	local Type = data:GetFlags()
	local GibModelType = data:GetMaterialIndex()
	local Pos = data:GetOrigin()
	local Force = data:GetNormal()
	local Normal = Force:GetNormalized()
	local GibAmount = data:GetScale()
	
	if Type == 1 then
		if GibModelType != 1 then
			for i = 0, 20 do
				local BloodPos = Pos + VectorRand()*i*4
				local LightColor = render.GetLightColor( BloodPos ) * 255
				LightColor[1] = math.Clamp( LightColor[1], 70, 255 )
				local emitter = ParticleEmitter( BloodPos )
					local particle = emitter:Add( "effects/blood_core", BloodPos )
					particle:SetVelocity( Force / 8 )
					particle:SetDieTime( math.Rand( 1, 2 ) )
					particle:SetStartAlpha( 255 )
					particle:SetStartSize( math.Rand( 16, 32 ) )
					particle:SetEndSize( math.Rand( 64, 200 ) )
					particle:SetRoll( math.Rand( 0, 360 ) )
					particle:SetColor( LightColor[1], 0, 0 )
				emitter:Finish()
				util.Decal( "Blood", Pos + VectorRand() * 80, Pos - VectorRand() * 80 )
			end
		end
		
		for i = 0, GibAmount do
			local effectdata = EffectData()
			effectdata:SetOrigin(Pos + i * Vector(0,0,1))
			effectdata:SetNormal(Force)
			effectdata:SetMaterialIndex(GibModelType)
			util.Effect("hl1_gibs_bodypart", effectdata)
		end
	elseif Type == 2 then
		for i = 0, 8 do
			local dustPos = Pos + VectorRand() * 20
			local emitter = ParticleEmitter( dustPos )
				local particle = emitter:Add( "particle/particle_smokegrenade", dustPos )
				particle:SetVelocity(VectorRand() * 10)
				particle:SetGravity(Vector(0, 0, 10) + VectorRand() * 40)
				particle:SetDieTime( math.Rand( 0, 1.5 ) )
				particle:SetStartAlpha( math.random(150, 255) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 10, 20 ) )
				particle:SetEndSize( math.Rand( 40, 70 ) )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta(math.Rand(-1, 1))
				particle:SetColor(40, 30, math.random(10, 30))
			emitter:Finish()
		end
		GibAmount = math.random(GibAmount - 6, GibAmount)
		if GibAmount <= 0 then
			GibAmount = 1
		end
		for i = 1, GibAmount do
			local effectdata = EffectData()
			effectdata:SetOrigin(Pos + i * Vector(0,0,1))
			effectdata:SetNormal(Force)
			util.Effect("hl1_gibs_wood", effectdata)
		end
	elseif Type == 3 then
		for i = 0, 4 do
			local dustPos = Pos + VectorRand() * 30
			local emitter = ParticleEmitter( dustPos )
				local particle = emitter:Add( "particle/particle_smokegrenade", dustPos )
				particle:SetVelocity(VectorRand() * 10)
				particle:SetGravity(Vector(0, 0, 10) + VectorRand() * 30)
				particle:SetDieTime( math.Rand( 0, 1 ) )
				particle:SetStartAlpha( math.random(200, 255) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( math.Rand( 10, 20 ) )
				particle:SetEndSize( math.Rand( 40, 70 ) )
				particle:SetRoll( math.Rand( 0, 360 ) )
				particle:SetRollDelta(math.Rand(-1, 1))
				particle:SetColor(40, 40, math.random(30, 50))
			emitter:Finish()
		end
		GibAmount = math.random(GibAmount - 6, GibAmount)
		if GibAmount <= 0 then
			GibAmount = 1
		end
		for i = 1, GibAmount do
			local effectdata = EffectData()
			effectdata:SetOrigin(Pos + i * Vector(0,0,1))
			effectdata:SetNormal(Force)
			util.Effect("hl1_gibs_metal", effectdata)
		end
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end