EFFECT.matBeam = Material("hl1/sprites/xbeam1")

EFFECT.matPortal = CreateMaterial( "monstermaker_portal", "UnlitGeneric", {
	["$basetexture"] = "sprites/fexplo1",
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1,
	["$additive"] = 1
})
local matPortalExists = file.Exists("materials/sprites/fexplo1.vtf", "GAME")

EFFECT.matFlare = CreateMaterial( "monstermaker_flare", "UnlitGeneric", {
	["$basetexture"] = "sprites/xflare1",
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1,
	["$additive"] = 1
})
local matFlareExists = file.Exists("materials/sprites/xflare1.vtf", "GAME")

function EFFECT:Init(data)
	self.Origin = data:GetOrigin()
	self.Scale = data:GetScale()
	self.DieTime = CurTime() + 1.1
	self.Time = 0
	self.HitTable = {}
	
	for i = 0, 5 do
		local tr = util.TraceLine({
			start = self.Origin,
			endpos = self.Origin + VectorRand() * 256,
			filter = self,
			mask = MASK_SOLID_BRUSHONLY
		})
		
		if tr.Hit then
			table.insert(self.HitTable, tr.HitPos)
		end
	end

	/*local norm = data:GetNormal()
	local emitter = ParticleEmitter(pos)
	local col = math.random(0, 30)

		for i = 0,30 do
			local particle = emitter:Add("particle/particle_smokegrenade", pos)
			particle:SetVelocity(Vector(0,0,300) + VectorRand() * 60)
			particle:SetAirResistance(100)
			particle:SetGravity(Vector(0, 0, 60) + VectorRand() * 150)
			particle:SetDieTime(math.Rand(1.5, 3))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(0)
			particle:SetEndSize(math.Rand(60, 120))
			particle:SetRoll(math.Rand(-90, 90))
			particle:SetRollDelta(math.Rand(-1, 1))
			particle:SetColor(col, col, col)
		end

	emitter:Finish()*/
	
	if !self.matPortal:IsError() and matPortalExists and !self.matFlare:IsError() and matFlareExists then
		self.Animated = true
	end
end

function EFFECT:Think()
	self.Time = self.Time + FrameTime()
	return self.DieTime > CurTime()
end

function EFFECT:Render()
	local spritePos = self.Origin - EyeVector() * 16
	render.SetMaterial(self.matPortal)
	if self.Animated then
		self.matPortal:SetInt("$frame", math.Clamp(math.floor(self.Time*16), 0, 18))
	end
	render.DrawSprite(spritePos, self.Scale*2, self.Scale, Color(77, 210, 130, 255))
	
	render.SetMaterial(self.matFlare)
	if self.Animated then
		self.matFlare:SetInt("$frame", math.Clamp(math.floor(self.Time*16), 0, 19))
	end
	render.DrawSprite(spritePos, self.Scale*1.5, self.Scale, Color(184, 250, 214, 255))
	
	local texWidth = 6
	local texScroll = CurTime() * 10
	render.SetMaterial(self.matBeam)
	for k, v in pairs(self.HitTable) do
		local alpha = (self.DieTime - CurTime()) * 255
		local color = Color(50, 255, 0, alpha)
		local norm = (v - self.Origin):GetNormalized()
		local rand = VectorRand() * 4
		render.StartBeam(6)
			render.AddBeam(self.Origin, texWidth, texScroll, color)
			render.AddBeam(self.Origin + norm * 20 + rand, texWidth, texScroll, color)
			render.AddBeam(self.Origin + norm * 40 + rand, texWidth, texScroll, color)
			render.AddBeam(self.Origin + norm * 60 + rand, texWidth, texScroll, color)
			render.AddBeam(self.Origin + norm * 80 + rand, texWidth, texScroll, color)
			render.AddBeam(v, texWidth, texScroll, color)
		render.EndBeam()
	end
end