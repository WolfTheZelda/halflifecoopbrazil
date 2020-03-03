GM.BlockSpawnpointCreation = {
	["hls03amrl"] = true
}

GM.StartingWeapons = {"weapon_crowbar", "weapon_glock", "weapon_shotgun", "weapon_handgrenade"}

function GM:CreateViewPoints()
	self:CreateViewPointEntity(Vector(440, 1170, 135), Angle(15, -140, 0))
end

local tele1pos = Vector(255, 1630, 50)
local tele2pos = Vector(-1070, -1500, 1280)
local elev_tele1pos = Vector(1280, -956, -80)
local elev_tele2pos = Vector(64, -1125, 670)

function GM:CreateMapCheckpoints()
	self:CreateCheckpointTrigger(Vector(1455, -1176, 482), Vector(1297, -1016, 383), Vector(1350, -1470, 520), Angle(0, -90, 0), {tele1pos, elev_tele1pos}, "weapon_mp5")
end

local doorClip

function GM:CreateMapEventCheckpoints(ent, activator)
	if ent:GetName() == "c1a3c_collapse_mm" then
		local pos = Vector(-590, -1555, 770)
		local ang = Angle(0, 180, 0)
		self:Checkpoint(pos, ang, {tele1pos, tele2pos, elev_tele2pos}, activator, "weapon_mp5")
	end
	if ent:GetName() == "c1a3_security01" then
		self:RemovePreviousCheckpoint({elev_tele1pos, elev_tele2pos, tele2pos})
		if IsValid(doorClip) then doorClip:Remove() end
	end
end

function GM:OperateMapEvents(ent, input, caller, activator)
	if ent:GetClass() == "scripted_sentence" and ent:GetName() == "c1a3deadtalk" then
		local sci = ents.FindByName("c1a3lucky")[1]
		timer.Simple(1, function()
			if IsValid(sci) then
				for _, grunt in pairs(ents.FindInSphere(Vector(1440, -904, -128), 8)) do
					if grunt:IsNPC() and grunt:GetClass() == "monster_human_grunt" then
						grunt:UpdateEnemyMemory(sci, sci:GetPos())
					end
				end
			end
		end)
	end
	if ent:GetClass() == "path_track" and ent:GetName() == "lift02c" and input == "InPass" then
		local pos = Vector(175, -870, 1290)
		local ang = Angle(0, 180, 0)
		self:Checkpoint(pos, ang, {tele1pos, elev_tele2pos}, activator, "weapon_mp5")
	end
	
	if IsValid(caller) and caller:GetClass() == "trigger_once" and ent:GetClass() == "func_door" and ent:GetName() == "sl10_door" and input == "Close" then
		ent:Fire("Open")
	end
end

function GM:ModifyMapEntities()
	self:CreateCoopSpawnpoints(Vector(60, 1520, 5), Angle())
	
	self:CreateWeaponEntity("weapon_shotgun", Vector(-677, -3001, 700), Angle(0, 145, 0))
	self:CreateWeaponEntity("weapon_shotgun", Vector(-2148, -2304, 1320), Angle(0, -20, 0))
	self:CreateWeaponEntity("weapon_mp5", Vector(-2154, -2341, 1320), Angle(0, -20, 0))
	self:CreateWeaponEntity("weapon_handgrenade", Vector(-2160, -2376, 1320), Angle(0, 10, 0))
	
	if !self:GetSpeedrunMode() then
		doorClip = ents.Create("hl1_clip")
		if IsValid(doorClip) then
			doorClip:Spawn()
			doorClip:SetCollisionGroup(COLLISION_GROUP_DOOR_BLOCKER)
			doorClip:SetCollisionBoundsWS(Vector(172, 1184, 0), Vector(163, 1248, 96))
		end
	end
	
	for k, v in pairs(ents.FindByName("c1a3_explosion*")) do
		if v:GetClass() == "env_explosion" then
			v.ActivatedByTrigger = true
		end
	end
	
	self:CreateFallTrigger(Vector(304, -1770, 129), Vector(-304, -2360, 156))
	self:CreateFallTrigger(Vector(591, 55, -664), Vector(352, -184, -633)) -- elevator shaft
	self:CreateFallTrigger(Vector(-2448, -1143, 20), Vector(-2576, -1015, 210)) -- fan
end

function GM:OnEntCreated(ent)
	if ent:GetClass() == "monster_mortar" then
		timer.Simple(0, function()
			if IsValid(ent) then
				ent:SetOwner(NULL)
			end
		end)
	end
end