AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.WaitTimer = 60

ENT.RestrictedTransitions = {
	-- left is a map to change, right is a landmark name
	-- this is how we detect certain triggers
	{"c1a0", "c1a0toc1a0d"},
	{"c1a0d", "c1a0dtoa"},
	{"c1a0a", "c1a0atob"},
	{"c1a0b", "c1a0btoe"},
	{"c1a1", "c1a1"},
	{"c1a1a", "c1a1atof"},
	--{"c1a1g", "c1a1ftoc1a1g"},
	{"c1a1f", "c1a1b"},
	{"c1a1b", "c1a1bc"},
	{"c1a2", "one"},
	{"c1a2a", "ab"},
	{"c1a2b", "freezer"},
	{"c1a2c", "vents"},
	{"c1a3", "lm_c1a3_0d"},
	{"c1a3d", "lm_c1a3_da"},
	--missing due to crashes
	{"c1a3", "c1a3toc1a4"},
	{"c1a4d", "c1a4dtoc1a4e"},
	{"c1a4e", "c1a4dtoe"},
	{"c1a4i", "c1a4itoc1a4g"},
	{"c1a4g", "c1a4gtoc2a1"},
	{"c1a4j", "c1a4-c2a1"},
	{"c2a1", "c2a1-c2a2"},
	{"c2a2", "c2a2c2a2a"},
	{"c2a2a", "c2a2ac2a2b1"},
	{"c2a2b1", "c2a2b1c2a2c"},
	{"c2a2c", "c2a2cc2a2d"},
	{"c2a2d", "c2a2dc2a2e"},
	{"c2a2e", "c2a2ec2a2f"},
	{"c2a2f", "c2a2fc2a2g"},
	{"c2a2f", "c2a2fc2a2g2"},
	{"c2a2g", "c2a2/3"},
	{"c2a3", "c2a3/a"},
	{"c2a3a", "c2a3a/b"},
	{"c2a3b", "c2a3b/c"},
	{"c2a3c", "c2a3cd"},
	{"c2a4", "lm1"},
	{"c2a4a", "lm2"},
	{"c2a4b", "lm1"},
	{"c2a4c", "lm2"},
	{"c2a4d", "lm1"},
	{"c2a4f", "lm4"},
	{"c2a4e", "c2a4e-c2a4g"},
	{"c2a4g", "c2a4gc2a5"},
	{"c2a5", "c2a5-c2a5w"},
	{"c2a5x", "c2a5a"},
	{"c2a5a", "c2a5b"},
	{"c2a5b", "c2a5_c"},
	{"c2a5c", "c2a5d"},
	{"c2a5d", "c2a5e"},
	{"c2a5e", "c2a5e/f"},
	{"c2a5f", "c2a5ftog"},
	{"c2a5g", "c2a5g/c3a1"},
	{"c3a1", "a1a1a"},
	{"c3a1a", "a1a2"},
	{"c3a1b", "c3a1c3a2"},
	{"c3a2e", "c3a2e"},
	{"c3a2", "c3a2f"},
	{"c3a2b", "c3a2_bc"},
	{"c3a2c", "c3a2_cd"},
	
	{"hls01amrl", "hls02atohls01a"},
	{"hls02amrl", "hls02atohl03amrl"},
	{"hls03amrl", "hls03amrltohls04amrl"},
	{"hls04amrl", "hls04amrltohls05amrl", true},
	{"hls05amrl", "hls05amrltohls05bmrl"},
	{"hls05bmrl", "hls05bmrltohls06amrl"},
	{"hls06amrl", "hls06amrltohls07amrl"},
	{"hls07amrl", "hls07amrltohls07bmrl"},
	{"hls07bmrl", "hls07bmrltohls08amrl"},
	{"hls08amrl", "hls08amrltohls09amrl"},
	{"hls09amrl", "hls09amrltohls10amrl"},
	{"hls10amrl", "hls10amrltohls11amrl"},
	{"hls11amrl", "hls11amrltohls11bmrl"},
	{"hls11bmrl", "hls11bmrltohls11cmrl"},
	{"hls11cmrl", "hls11cmrltohls12amrl"},
	{"hls12amrl", "hls12amrltohls13amrl"},
}
--TODO: move to certain map file
ENT.PlayerWaitBlacklist = {
	["hls05bmrl"] = true
}
	
function ENT:CheckTransition()
	if GAMEMODE:IsCoop() then
		for k, v in pairs(self.RestrictedTransitions) do
			if v[1] == self.MapToChange and v[2] == self.landmark then
				if v[3] then self.DontClip = true end
				return true
			end
		end
	end
end

function ENT:KeyValue(k, v)
	--print(k, v)
	if k == "landmark" then
		self.landmark = v
	end
	if k == "map" then
		self.MapToChange = v
	end
end

function ENT:Initialize()
	self:SetSolid(SOLID_BBOX)
    self:SetTrigger(true)
	if !game.SinglePlayer() then self.EnableDelay = CurTime() + 10 end

	if GAMEMODE:IsCoop() then
		self.PlyTable = {}
		if self:CheckTransition() then
			if !self.DontClip then
				local plyClip = ents.Create("hl1_playerclip")
				if IsValid(plyClip) then
					plyClip:Spawn()
					plyClip:SetCollisionBoundsWS(self:GetCollisionBounds())
					function plyClip:StartTouch(ent)
						if ent:IsPlayer() and ent:Alive() then
							ent:TextMessageCenter("#game_wrongway", 1)
						end
					end
				end
			end
			return
		end
		local tr = util.QuickTrace(self:WorldSpaceCenter(), Vector(0,200,0), self)
		local entText = ents.Create("changelevel_text")
		if IsValid(entText) then
			entText:SetPos(self:WorldSpaceCenter())
			local trang = tr.Hit and Angle() or Angle(0,90,0)
			entText:SetAngles(trang)
			entText:SetText("MAP CHANGE")
			entText:Spawn()
		end
	end
end

function ENT:SetMapToChange(m)
	self.MapToChange = m
end

function ENT:CanTrigger(ply)
	if self:CheckTransition() then return false end -- dont allow to return back in coop
	if self.EnableDelay and self.EnableDelay > CurTime() then
		if ply and IsValid(ply) then
			ply:ChatPrint("Trigger can be used again in "..math.Round(self.EnableDelay - CurTime()).." seconds")
		end
		return false
	end
	return true
end

function ENT:SaveTransitionData(map, landmark, curmap, pos, ang)
	local dataTable = {
		map,
		landmark,
		curmap,
		pos,
		ang
	}
	file.CreateDir("hl1_coop")
	file.Write("hl1_coop/transition_data.txt", util.TableToJSON(dataTable))
end

function ENT:DoMapChange(ply)
	if !self:CanTrigger(ply) then return end
	if self.MapToChange then
		if ply and IsValid(ply) then
			for k, v in pairs(ents.FindInPVS(ply:GetPos())) do
				if v:GetClass() == "info_landmark" and v:GetName() == self.landmark then
					local fisrtPos = self.FirstPlayerPos or ply:GetPos()
					local fisrtAng = self.FirstPlayerAng or ply:EyeAngles()
					local pos = fisrtPos - v:GetPos()
					local ang = fisrtAng
					self:SaveTransitionData(self.MapToChange, self.landmark, game.GetMap(), pos, ang)
				end
			end
		else
			self:SaveTransitionData(self.MapToChange, self.landmark, game.GetMap())
		end
		GAMEMODE:TransitPlayers(self.MapToChange, true)
		RunConsoleCommand("changelevel", self.MapToChange)
	else
		print("No map is set to change to")
	end
end

function ENT:Reset()
	self.ChangeTimer = nil
	self.FirstPlayerPos = nil
	self.FirstPlayerAng = nil
	GAMEMODE:SetGlobalFloat("WaitTime", 0)
end

function ENT:Think()
	if self.ChangeTimer then
		if self.PlyTable then
			for k, v in pairs(self.PlyTable) do
				if !IsValid(v) or v:Team() != TEAM_COOP then
					table.RemoveByValue(self.PlyTable, v)
				end
			end
		end
		if (self.ChangeTimer <= CurTime() or #self.PlyTable == GAMEMODE:GetActivePlayersNumber()) then
			self:DoMapChange(self.PlyTable[1])
		end
		if #self.PlyTable <= 0 then
			self:Reset()
		end
	end
end

function ENT:OnRemove()
	if self.PlyTable then
		for k, v in pairs(self.PlyTable) do
			if IsValid(v) then
				v:Freeze(false)
				v:RemoveFlags(FL_GODMODE)
				v:RemoveFlags(FL_NOTARGET)
				v:SetColor(Color(255, 255, 255, 255))
				v:SetRenderMode(RENDERMODE_NORMAL)
				v:SetWaitBool(false)
			end
		end
	end
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() and ent:Alive() then
		if !self:CanTrigger(ent) then return end
		if GAMEMODE:GetSpeedrunMode() then
			GAMEMODE:PlayerHasFinishedMap(ent)
		end
		if self.FadeEffect then
			local fadehold = self.ChangeTimer and self.ChangeTimer - CurTime() or self.WaitTimer
			ent:ScreenFade(SCREENFADE.OUT, Color(0,0,0,255), 1, fadehold)
		end
	end
end

function ENT:Touch(ent)
	if IsValid(ent) and ent:IsPlayer() and ent:Alive() then
		if GAMEMODE:IsCoop() and !self.PlayerWaitBlacklist[self.MapToChange] and GAMEMODE:GetActivePlayersNumber() > 1 then
			if !self:CanTrigger(ent) then return end
			if !table.HasValue(self.PlyTable, ent) then
				table.insert(self.PlyTable, ent)
				if !self.FirstPlayerPos and !self.FirstPlayerAng then
					self.FirstPlayerPos = ent:GetPos()
					self.FirstPlayerAng = ent:EyeAngles()
				end
				ent:Freeze(true)
				ent:AddFlags(FL_GODMODE)
				ent:AddFlags(FL_NOTARGET)
				ent:SetColor(Color(150, 150, 150, 150))
				ent:SetRenderMode(RENDERMODE_TRANSALPHA)
				ent:SetWaitBool(true)
			end
			if !self.ChangeTimer then
				self.ChangeTimer = CurTime() + self.WaitTimer
				GAMEMODE:SetGlobalFloat("WaitTime", CurTime() + self.WaitTimer)
			end
		else
			self:DoMapChange(ent)
		end
	end
end

function ENT:AcceptInput(inputName, activator, called, data)
	if self.ChangeTimer and self.ChangeTimer > CurTime() then return end
	
	local player
	for _, ent in pairs(ents.FindByName(self.landmark)) do
		if ent:GetClass() == "info_landmark" then
			for k, v in pairs(ents.FindInPVS(ent)) do
				if v:IsPlayer() and v:Alive() then
					player = v
					break
				end
			end
		end
	end

	if game.SinglePlayer() and Entity(1):IsPlayer() and !Entity(1):Alive() then return end
	if player and IsValid(player) and player:IsPlayer() then
		self.FirstPlayerPos = player:GetPos()
		self.FirstPlayerAng = player:EyeAngles()
	end
	self:DoMapChange(player)
end