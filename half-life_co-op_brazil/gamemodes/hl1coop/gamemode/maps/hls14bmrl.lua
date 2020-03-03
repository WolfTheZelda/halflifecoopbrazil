GM.BlockSpawnpointCreation = {
	["hls14amrl"] = true
}

GM.StartingWeapons = {"weapon_crowbar", "weapon_glock", "weapon_357", "weapon_mp5", "weapon_shotgun", "weapon_crossbow", "weapon_rpg", "weapon_gauss", "weapon_egon", "weapon_hornetgun", "weapon_handgrenade", "weapon_satchel", "weapon_tripmine", "weapon_snark"}
GM.StartingWeaponsLight = {"weapon_hornetgun"}

function GM:CreateViewPoints()
	self:CreateViewPointEntity(Vector(-573, -2933, -500), Angle(8, 100, 0))
end

local tele1pos = Vector(-1742, -713, -840)
local tele2pos = Vector(1692, -937, -780)

function GM:CreateMapEventCheckpoints(ent, activator)
	if ent:GetName() == "sirens" then
		self:Checkpoint(Vector(846, -2463, -780), Angle(0, -90, 0), tele1pos, activator)
	end
	if ent:GetName() == "lasta" then
		self:Checkpoint(Vector(8613, -1674, 2106), Angle(0, -115, 0), {tele1pos, tele2pos}, activator)
	end
end

function GM:CreateMapCheckpoints()
	self:CreateCheckpointTrigger(Vector(1514, -497, -872), Vector(1475, -386, -945), Vector(1137, -441, -912), Angle(), tele1pos)
end

function GM:FixMapEntities()
	for k,v in pairs(ents.FindByClass("func_platrot")) do
		local fTrig = ents.Create("hl1_trigger_func")
		if IsValid(fTrig) then
			function fTrig:Touch(ent)
				if ent:GetClass() == "hornet" then
					ent:Remove()
				end
			end
			fTrig:SetPos(v:GetPos())
			fTrig:SetParent(v)
			fTrig:Spawn()
			fTrig:SetCollisionBounds(v:GetCollisionBounds())
		end
	end
end

function GM:ModifyMapEntities()
	self:CreateWeaponEntity("weapon_357", Vector(177, -3031, -946), Angle(0, 145, 0))
	self:CreateWeaponEntity("weapon_crossbow", Vector(980, -2222, -952), Angle(0, 165, 0))
	self:CreateWeaponEntity("weapon_357", Vector(2423, -837, -981), Angle(0, 165, 0))
	self:CreateWeaponEntity("weapon_rpg", Vector(823, 364, 32), Angle(0, 25, 0))

	local mins, maxs = Vector(8900, -4048, 1656), Vector(8881, -4067, 1756)
	for k, v in pairs(ents.FindInSphere(maxs, 16)) do
		if v:GetClass() == "trigger_once" then
			v:Fire("Disable")
		end
	end
	local func = function()
		for k, v in pairs(ents.FindInSphere(maxs, 16)) do
			if v:GetClass() == "trigger_once" then
				v:Fire("Enable")
			end
		end
	end
	self:CreateWaitTrigger(mins, maxs, 50, false, func, WAIT_LOCK, true)
	
	--self:CreateFallTrigger()
	self:CreateFallTrigger(Vector(3125, -49, -3008), Vector(1422, -796, -2902))
	self:CreateFallTrigger(Vector(-91, -288, -2178), Vector(1335, 981, -2256))
	self:CreateFallTrigger(Vector(9952, -4995, 244), Vector(6209, -995, -153))
end

function GM:OnPlayerSpawn(ply)
	ply:SetLongJumpBool(true)
end