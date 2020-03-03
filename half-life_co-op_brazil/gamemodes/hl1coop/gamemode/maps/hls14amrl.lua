GM.StartingWeapons = {"weapon_crowbar", "weapon_glock", "weapon_357", "weapon_mp5", "weapon_shotgun", "weapon_crossbow", "weapon_rpg", "weapon_gauss", "weapon_egon", "weapon_hornetgun", "weapon_handgrenade", "weapon_satchel", "weapon_tripmine", "weapon_snark"}
GM.StartingWeaponsLight = {"weapon_hornetgun"}

function GM:CreateViewPoints()
	self:CreateViewPointEntity(Vector(-13090, 9870, 750), Angle(4, 75, 0))
end

local tele1pos = Vector(-10784, 13612, 1630)
local tele2pos = Vector(5329, 8205, -725)
local tele3pos = Vector(-12650, -235, -3416)

function GM:CreateMapEventCheckpoints(ent, activator)
	if ent:GetName() == "c4a2_collapse" then
		self:Checkpoint(Vector(5218, 9104, -780), Angle(0, -170, 0), {tele1pos, tele2pos}, activator)
	end
end

function GM:CreateMapCheckpoints()
	self:CreateCheckpointTrigger(Vector(9601, 7949, -592), Vector(9715, 8143, -500), Vector(9434, 8805, -570), Angle(0, -120, 0), tele1pos) -- gonarch
	self:CreateCheckpointTrigger(Vector(-13103, -772, -3123), Vector(-12773, -1127, -3471), Vector(-12975, -1080, -3465), Angle(0, 65, 0), {tele1pos, tele2pos})
	self:CreateCheckpointTrigger(Vector(6499, -8204, -553), Vector(6803, -8419, -410), Vector(6660, -8288, -535), Angle(0, -90, 0), {tele1pos, tele2pos, tele3pos})
end

function GM:ModifyMapEntities()
	self:CreateWeaponEntity("weapon_shotgun", Vector(-12610, 11180, -87), Angle(0, -45, 0))
	self:CreateWeaponEntity("weapon_rpg", Vector(9471, 8052, -555), Angle(0, 45, 0))
	self:CreateWeaponEntity("weapon_357", Vector(5267, 7906, -746), Angle(0, 15, 0))
	self:CreateWeaponEntity("weapon_mp5", Vector(3486, 8995, -1002), Angle(0, -35, 0))
	self:CreateWeaponEntity("weapon_crossbow", Vector(-12213, 872, -3030), Angle(0, 55, 0))
	self:CreateWeaponEntity("weapon_357", Vector(-11862, 365, -3700), Angle(0, 45, 0))
	self:CreateWeaponEntity("weapon_357", Vector(6870, -8494, -506), Angle(0, 5, 0))
	self:CreateWeaponEntity("weapon_shotgun", Vector(6838, -8520, -498), Angle(0, 45, 0))
	self:CreateWeaponEntity("weapon_rpg", Vector(7347, -7568, -511), Angle(0, 45, 0))
	self:CreateWeaponEntity("weapon_mp5", Vector(7321, -7652, -511), Angle(0, 45, 0))
	
	for k, v in pairs(ents.FindByClass("func_tanklaser")) do
		local cEnt = ents.Create("func_tank_controller")
		if IsValid(cEnt) then
			cEnt:SetParent(v)
			cEnt:SetPos(v:GetPos() - Vector(0,0,16))
			cEnt:Spawn()
		end
	end

	for k, v in pairs(ents.FindByName("c4a1c")) do
		if v:GetClass() == "trigger_once" then
			v:Fire("Disable")
		end
	end
	local mins, maxs = Vector(4604, -5058, -473), Vector(4624, -5078, -369)
	local func = function()
		for k, v in pairs(ents.FindByName("c4a1c")) do
			if v:GetClass() == "trigger_once" then
				v:Fire("Enable")
			end
		end
	end
	self:CreateWaitTrigger(mins, maxs, 50, false, func, WAIT_FREEZE, true)
	
	for k, v in pairs(ents.FindByClass("info_bigmomma")) do
		local healthkey = v:GetKeyValues().health
		if healthkey and healthkey > 0 then
			if !v.healthDefault then
				v.healthDefault = healthkey
			end
			v:SetKeyValue("health", healthkey * cvars.Number("sk_bigmomma_health_factor", 1) * self:NPCHealthMultiplier())
		end
	end
	
	self:CreateFallTrigger(Vector(-9546, 14219, -1774), Vector(-14346, 9835, -2896))
	self:CreateFallTrigger(Vector(10636, 5485, -844), Vector(7188, 9389, -937)) -- gonarch 1
	self:CreateFallTrigger(Vector(2412, 9637, -1363), Vector(3356, 8293, -1130)) -- gonarch 2
	self:CreateFallTrigger(Vector(-14627, -2377, -3910), Vector(-10963, 1623, -4297)) -- interloper
	self:CreateFallTrigger(Vector(5325, -10048, -805), Vector(9005, -6112, -1105))
	self:CreateFallTrigger(Vector(3925, -6640, -1961), Vector(4445, -6464, -1845))
	self:CreateFallTrigger(Vector(3933, -7392, -1450), Vector(2061, -4704, -1654))
end

function GM:OnPlayerSpawn(ply)
	ply:SetLongJumpBool(true)
end