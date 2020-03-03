GM.BlockSpawnpointCreation = {
	["hls07bmrl"] = true
}

GM.StartingWeapons = {"weapon_crowbar", "weapon_glock", "weapon_shotgun", "weapon_handgrenade", "weapon_mp5", "weapon_357", "weapon_satchel", "weapon_tripmine"}

GM.ImportantNPCs = {"Frank"}

GM.npcLagFixBlacklist = {
	["icky"] = true
}

function GM:CreateViewPoints()
	self:CreateViewPointEntity(Vector(127, 2064, 580), Angle(10, -145, 0))
end

local computers
function GM:CreateMapCheckpoints()
	local tele1pos = Vector(-132, 1913, 520)
	local tele2pos = Vector(240, -730, 550)
	local tele3pos = Vector(1565, 2715, -150)
	self:CreateCheckpointTrigger(Vector(2667, 727, -177), Vector(2801, 845, -23), Vector(2555, 280, -170), Angle(0, 180, 0), {tele1pos, tele2pos})
	computers = self:CreateCheckpointTrigger(Vector(-60, 2170, 92), Vector(-106, 2292, 230), Vector(-430, 2125, 190), Angle(0, 125, 0), {tele1pos, tele2pos, tele3pos})
end

function GM:ModifyMapEntities()
	self:CreateCoopSpawnpoints(Vector(-400, 2200, 505), Angle(0, -45, 0))
	
	self:CreateWeaponEntity("weapon_357", Vector(1735, 2108, -125), Angle(0, 145, 0))
	self:CreateWeaponEntity("weapon_shotgun", Vector(-655, 2162, 228), Angle(0, -50, 0))

	local triggertele = NULL
	local triggeronce = NULL
	local triggerchange = NULL
	for k, v in pairs(ents.FindByName("gotodrag")) do
		v:SetTrigger(false)
		triggerchange = v
	end
	for k, v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "ambush_teleport" then
			v:Fire("Disable")
			triggertele = v
			for _, t in pairs(ents.FindInSphere(v:GetPos(), 16)) do
				if t:GetClass() == "trigger_once" then
					t:Fire("Disable")
					triggeronce = t
				end
			end
		end
	end
	local mins, maxs = Vector(-5483, -18, 240), Vector(-5811, 476, 456)
	local func = function()
		if IsValid(triggeronce) then triggeronce:Fire("Enable") end
		if IsValid(triggertele) then triggertele:Fire("Enable") end
		if IsValid(triggerchange) then triggerchange:SetTrigger(true) end
	end
	self:CreateWaitTrigger(mins, maxs, 50, false, func, WAIT_FREEZE, true)
	
	local fTrig = ents.Create("hl1_trigger_func")
	if IsValid(fTrig) then
		fTrig.TouchFunction = function(ply)
			ply:ScreenFade(SCREENFADE.IN, Color(0,0,0,255), 1, 15)
			ply:Freeze(true)
		end
		fTrig:Spawn()
		fTrig:SetCollisionBoundsWS(Vector(-5861, 412, 220), Vector(-6148, 61, 426))
	end
end

local renameTrain
function GM:OnEntCreated(ent)
	if !renameTrain then
		for _, trainEnt in pairs(ents.FindByName("crashtrain")) do
			trainEnt:SetSaveValue("globalname", "pieceofshit3")
			renameTrain = true
		end
	end
end

function GM:OperateMapEvents(ent, input, caller, activator)
	if ent:GetClass() == "path_track" and ent:GetName() == "breaktrigger" and input == "InPass" then
		self:RemoveCoopSpawnpoints()
		self:CreateCoopSpawnpoints(Vector(468, -409, 510), Angle(0, -160, 0))
	end
	if ent:GetClass() == "func_door" and ent:GetName() == "glassdoor" and input == "Open" then
		self.ImportantNPCs = nil
	end
	if ent:GetClass() == "multi_manager" and ent:GetName() == "sharkcagemm" and input == "Trigger" then
		if IsValid(computers) then computers.WepTable = "weapon_crossbow" end
	end
end

function GM:CreateExtraEnemies()
	self:CreateNPCSpawner("monster_human_assassin", 4, Vector(-4427, 968, 264), Angle(0, -90, 0), 1500, false)
end

function GM:PreMapRestart()
	renameTrain = nil
end

function GM:OnMapRestart()
	self.ImportantNPCs = {"Frank"}
	if IsValid(computers) then computers.WepTable = nil end
end