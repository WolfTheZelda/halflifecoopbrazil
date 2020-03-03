GM.StartingWeapons = {"weapon_crowbar", "weapon_glock", "weapon_357", "weapon_mp5", "weapon_shotgun", "weapon_crossbow", "weapon_gauss", "weapon_handgrenade", "weapon_satchel", "weapon_tripmine", "weapon_snark"}

function GM:CreateViewPoints()
	self:CreateViewPointEntity(Vector(-9340, 3415, 1920), Angle(5, 150, 0))
end

function GM:CreateMapEventCheckpoints(ent, activator)
	local tele1pos = Vector(-8230, 4990, 1750)
	local tele2pos = Vector(-5460, -1032, 940)
	if ent:GetName() == "apache_maker_2" then
		local pos = Vector(-6485, 335, 580)
		local ang = Angle(0, -40, 0)
		self:Checkpoint(pos, ang, tele1pos, activator)
	end
	if ent:GetName() == "music_track_11" then
		local pos = Vector(1055, 610, 770)
		local ang = Angle(0, -90, 0)
		self:Checkpoint(pos, ang, {tele1pos, tele2pos}, activator)	
	end
end

function GM:ModifyMapEntities()
	self:CreateWeaponEntity("weapon_mp5", Vector(-6316, 1015, 567), Angle())
	self:CreateFallTrigger(Vector(-2716, 739, -1194), Vector(2090, -3872, -2003))
end

function GM:CreateExtraEnemies()
	self:CreateNPCSpawner("monster_ichthyosaur", 5, Vector(-11013, 5426, 555), Angle(0, -20, 0), 1300, false)
	self:CreateNPCSpawner("monster_ichthyosaur", 10, Vector(-11072, 4616, 371), Angle(0, 6, 0), 1300, false)
end

function GM:OperateMapEvents(ent, input, caller, activator)
	if IsValid(caller) and caller:IsTrigger() and caller:GetName() == "apache_activator_cliff" then
		caller:Remove()
	end
end