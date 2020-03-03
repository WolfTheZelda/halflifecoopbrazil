GM.BlockSpawnpointCreation = {
	["hls09amrl"] = true
}

GM.StartingWeapons = {"weapon_crowbar", "weapon_glock", "weapon_357", "weapon_satchel"}

GM.ImportantNPCs = {"pyscho_sci1", "pyscho_sci2", "pyscho_sci3"}
GM.ImportantNPCsSpecial = true

function GM:CreateViewPoints()
	self:CreateViewPointEntity(Vector(2000, 700, 215), Angle(20, 50, 0))
end

function GM:CreateMapEventCheckpoints(ent, activator)
	local tele1pos = Vector(2500, 1300, 90)
	local tele2pos = Vector(-797, 28, 180)
	if ent:GetName() == "psycho_talk_mm" then
		local pos = Vector(-2945, 2190, -20)
		local ang = Angle(0, -90, 0)
		self:Checkpoint(pos, ang, {tele1pos, tele2pos}, activator, {"weapon_crossbow", "weapon_snark", "weapon_gauss"})
	end
end

function GM:OperateMapEvents(ent, input)
	if ent:GetClass() == "func_door" and ent:GetName() == "eyescandoors" and input == "Open" then
		if self.ImportantNPCs then
			self.ImportantNPCs = nil
		end
		self:RemovePreviousCheckpoint()
	end
end

function GM:ModifyMapEntities()
	local fTrig = ents.Create("hl1_trigger_func")
	if IsValid(fTrig) then
		fTrig.TouchFunction = function()
			local pos = Vector(296, -28, 4)
			local ang = Angle(0, 180, 0)
			self:RemoveCoopSpawnpoints()
			self:CreateCoopSpawnpoints(pos, ang)
			fTrig:Remove()
		end
		fTrig:Spawn()
		fTrig:SetCollisionBoundsWS(Vector(-640, -213, 129), Vector(-832, -294, 254))
	end
	
	local doorTrig = ents.Create("hl1_trigger_func")
	if IsValid(doorTrig) then
		doorTrig.TouchFunction = function()
			if !self:GetSpeedrunMode() then
				doorTrig:Remove()
				for k, v in pairs(ents.FindByClass("func_door")) do
					if v:GetName() == "ldoors1" then
						v:Fire("Unlock")
						v:Fire("Open")
						v:Fire("Lock")
					end
				end
			end
		end
		doorTrig:Spawn()
		doorTrig:SetCollisionBoundsWS(Vector(-2832, 448, 128), Vector(-2992, 464, 272))
	end
	
	if !self:GetSpeedrunMode() then
		local plyClip = ents.Create("hl1_playerclip")
		if IsValid(plyClip) then
			plyClip:Spawn()
			plyClip:SetCollisionBoundsWS(Vector(-1744, -720, 416), Vector(-1072, -704, 704))
		end
		local plyClip_s = ents.Create("hl1_playerclip")
		if IsValid(plyClip_s) then
			plyClip_s:Spawn()
			plyClip_s:SetCollisionBoundsWS(Vector(-1552, -860, 416), Vector(-1264, -880, 340))
		end
	end
end

function GM:OnMapRestart()
	if !self.ImportantNPCs then
		self.ImportantNPCs = {"pyscho_sci1", "pyscho_sci2", "pyscho_sci3"}
	end
end