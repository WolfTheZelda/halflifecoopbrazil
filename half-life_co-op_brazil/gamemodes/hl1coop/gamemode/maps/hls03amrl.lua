AddCSLuaFile()

GM.DisableFullRespawn = true

if CLIENT then return end

GM.BlockSpawnpointCreation = {
	["hls02amrl"] = true
}

GM.StartingWeapons = {"weapon_crowbar", "weapon_glock", "weapon_handgrenade"}

GM.npcLagFixBlacklist = {
	["ripzombie"] = true,
	["dueling_zombie"] = true,
	["jumperz"] = true
}

function GM:CreateViewPoints()
	self:CreateViewPointEntity(Vector(2510, -600, -500), Angle(5, -150, 0))
end

function GM:FixMapEntities()
	for k, v in pairs(ents.FindByName("turretpwr1")) do
		v:SetPos(v:GetPos() - Vector(0,0,1))
	end
end

function GM:ModifyMapEntities()
	self:CreateCoopSpawnpoints(Vector(2319, -1009, -570), Angle(0, 90, 0))
	
	local hintDoors
	if !self:GetSpeedrunMode() then
		hintDoors = ents.Create("hl1_hint")
		if IsValid(hintDoors) then
			hintDoors:SetPos(Vector(908, -864, -476))
			hintDoors:SetAngles(Angle(0,90,90))
			hintDoors:SetText("#hint_doors")
			hintDoors:Spawn()
		end
	end
	
	local fTrig = ents.Create("hl1_trigger_func")
	if IsValid(fTrig) then
		fTrig.TouchFunction = function()
			if !self:GetSpeedrunMode() then
				fTrig:Remove()
				if IsValid(hintDoors) then hintDoors:Remove() end
				for k, v in pairs(ents.FindByClass("func_door")) do
					if v:GetName() == "noopen2" or v:GetName() == "noopen3" then
						v:Remove()
					end
				end
				for k, v in pairs(ents.FindByClass("func_door_rotating")) do
					if v:GetName() == "halldoor1" or v:GetName() == "halldoor2" then
						v:Fire("Open")
					end
				end
			end
		end
		fTrig:Spawn()
		fTrig:SetCollisionBoundsWS(Vector(747, -771, -576), Vector(343, -955, -566))
	end
	
	self:CreateFallTrigger(Vector(-1064, -488, -512), Vector(-801, -776, -436))
end

function GM:OperateMapEvents(ent, input)
	if ent:GetClass() == "trigger_multiple" and ent:GetName() == "spawninlift" then
		ent:Remove()
	end
end

function GM:CreateMapEventCheckpoints(ent, activator)
	local tele1pos = Vector(2240, -785, -530)
	if ent:GetName() == "from2a" then
		self:Checkpoint(Vector(500, 870, 70), Angle(0, -90, 0), tele1pos, activator, "weapon_shotgun")
	end
end