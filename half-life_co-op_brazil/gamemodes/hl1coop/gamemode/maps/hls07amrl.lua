GM.StartingWeapons = {"weapon_crowbar", "weapon_glock", "weapon_shotgun", "weapon_handgrenade", "weapon_mp5", "weapon_357", "weapon_tripmine"}

function GM:CreateViewPoints()
	self:CreateViewPointEntity(Vector(-1495, -2935, -1240), Angle(4, 120, 0))
end

local tele1pos = Vector(-1620, -2165, -1300)
local tele2pos = Vector(3228, -591, -1740)
local tele3pos = Vector(-980, -635, -1635)
local tele4pos = Vector(-1540, -1352, -710)
local tele5pos = Vector(-2783, -104, -1035) -- rocksound1
local tele6pos = Vector(-2712, -4781, -1030) -- vorts

function GM:CreateMapCheckpoints()
	self:CreateCheckpointTrigger(Vector(-1787, -1321, -1712), Vector(-1612, -1351, -1552), Vector(-1470, -1482, -1435), Angle(0,-90,0), {tele1pos, tele2pos, tele3pos}) -- track & grunts elevator
	self:CreateCheckpointTrigger(Vector(-2556, -4742, -1110), Vector(-2348, -4548, -956), Vector(-2745, -5811, -1080), Angle(0,90,0), {tele1pos, tele2pos, tele3pos, tele4pos, tele5pos}) -- vorts
	self:CreateCheckpointTrigger(Vector(-6316, -4311, -1082), Vector(-6492, -4285, -927), Vector(-6570, -4356, -1084), Angle(0,-45,0), {tele1pos, tele2pos, tele3pos, tele4pos, tele5pos, tele6pos}) -- func_tank
end

function GM:CreateMapEventCheckpoints(ent, activator)
	if ent:GetName() == "ambience_screams1" then
		local pos = Vector(2185, -865, -1760)
		local ang = Angle(0, 135, 0)
		self:Checkpoint(pos, ang, tele1pos, activator)
	end
	if ent:GetName() == "rocksound1" then
		local pos = Vector(-2550, 445, -1070)
		local ang = Angle(0, -90, 0)
		self:Checkpoint(pos, ang, {tele1pos, tele2pos, tele3pos, tele4pos}, activator)
	end
end

function GM:ModifyMapEntities()
	self:CreateWeaponEntity("weapon_shotgun", Vector(3176, -2705, -1553), Angle(0, 145, 0))
	self:CreateWeaponEntity("weapon_handgrenade", Vector(-543, -3884, -750), Angle(0, 160, 0))
	self:CreateWeaponEntity("weapon_shotgun", Vector(-581, -3679, -510), Angle(0, -84, 0))
	
	for k, v in pairs(ents.FindByName("tracks08")) do
		v:Remove()
	end
	for k, v in pairs(ents.FindByName("rocket_for_player1")) do
		v:Remove()
	end
	for k, v in pairs(ents.FindByName("timetrain3")) do
		v:Remove()
	end
	
	for k, v in pairs(ents.FindByClass("func_tank*")) do
		if v:GetName() == "siloguardgun" or v:GetName() == "siloguardgun2" or v:GetName() == "trackguardrocket" then
			local cEnt = ents.Create("func_tank_controller")
			if IsValid(cEnt) then
				cEnt:SetParent(v)
				cEnt:SetPos(v:GetPos())
				cEnt:Spawn()
				if v:GetName() == "trackguardrocket" then
					cEnt.Explosive = true
				end
			end
		end
	end
end

local renameTrain
function GM:OnEntCreated(ent)
	if !renameTrain then
		for _, trainEnt in pairs(ents.FindByName("train")) do
			trainEnt:SetSaveValue("globalname", "pieceofshit")
			renameTrain = true
		end
	end
	
	if ent:GetClass() == "rpg_missile" then
		ent:SetNoDraw(true)
		timer.Simple(0, function()
			if IsValid(ent) then
				ent:StopSound("Missile.Ignite")
				ent:SetModel("models/rpgrocket.mdl")
				local replaceent = ents.Create("ent_hl1_rpg_rocket")
				if IsValid(replaceent) then
					replaceent:SetPos(ent:GetPos() - Vector(0,0,16))
					replaceent:SetAngles(ent:GetAngles())
					replaceent:SetOwner(ent:GetOwner())
					replaceent:Spawn()
				end
				ent:Remove()
			end
		end)
	end
end

function GM:PreMapRestart()
	renameTrain = nil
end