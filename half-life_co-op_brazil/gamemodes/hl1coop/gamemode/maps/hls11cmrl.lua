GM.StartingWeapons = {"weapon_crowbar", "weapon_glock", "weapon_357", "weapon_mp5", "weapon_shotgun", "weapon_crossbow", "weapon_rpg", "weapon_gauss", "weapon_handgrenade", "weapon_satchel", "weapon_tripmine", "weapon_snark"}

function GM:CreateViewPoints()
	self:CreateViewPointEntity(Vector(-42, -765, -170), Angle(25, 120, 0))
end

--local tele1pos = Vector(-310, -260, -300)
local tele1pos = Vector(280, -20, -305)
local tele2pos = Vector(265, 605, -1105)
local tele3pos = Vector(2060, 2610, -1100)
local tele4pos = Vector(3523, 3088, -715)
local tele5pos = Vector(570, -3460, -620)
local tele6pos = Vector(1944, -2456, -685)

GM.ImportantNPCs = {"barney1"}

GM.EnvFadeWhitelist = {
	["leveldead_shake5f"] = true,
	["leveldead_fade"] = true
}

local barney_trigger

function GM:CreateMapCheckpoints()
	barney_trigger = self:CreateCheckpointTrigger(Vector(1955, 3542, -607), Vector(2018, 3594, -496), Vector(1985, 3295, -600), Angle(0, 45, 0), {tele1pos, tele2pos, tele3pos}, "weapon_hornetgun")
	
	local snark_func = function()
		if IsValid(barney_trigger) then barney_trigger:Remove() end
	end
	-- snark vent
	self:CreateCheckpointTrigger(Vector(245, -989, -413), Vector(237, -917, -355), Vector(520, -1960, -420), Angle(0, 90, 0), {tele1pos, tele2pos, tele3pos, tele4pos}, "weapon_hornetgun", snark_func)
end

local rocketsPassed
local rocketsPassedPos = Vector(400, 320, -1100)
local rocketsPassedAng = Angle(0, 180, 0)

local function CreateWeaponBlock()		
	-- TODO: fix gauss blast damage
	local blockWeapons = ents.Create("hl1_trigger_func")
	if IsValid(blockWeapons) then
		function blockWeapons:Touch(ent)
			if !ent:IsPlayer() then
				ent:Remove()
			end
		end
		blockWeapons:Spawn()
		blockWeapons:SetCollisionBoundsWS(Vector(153, 288, -513), Vector(328, 112, -543))
	end
end

function GM:CreateMapEventCheckpoints(ent, activator)
	if ent:GetName() == "chase_mm" then
		if !rocketsPassed then
			self:RemoveCoopSpawnpoints()
			self:Checkpoint(rocketsPassedPos, rocketsPassedAng, tele1pos, activator)
			self:CreateCoopSpawnpoints(rocketsPassedPos, rocketsPassedAng)
			CreateWeaponBlock()
			rocketsPassed = true
		end
	end
	if ent:GetName() == "bustmm" then
		if IsValid(barney_trigger) then barney_trigger:Remove() end
		self:Checkpoint(Vector(2990, -2946, -440), Angle(0,180,0), {tele1pos, tele2pos, tele3pos, tele4pos, tele5pos}, activator, "weapon_hornetgun")
	end
	if ent:GetName() == "radio1" then
		if IsValid(barney_trigger) then barney_trigger:Remove() end
		self:Checkpoint(Vector(-1290, 1350, -350), Angle(0,180,0), {tele1pos, tele2pos, tele3pos, tele4pos, tele5pos, tele6pos}, activator, "weapon_hornetgun")
	end
end

local tank_breakable
function GM:FixMapEntities()	
	for k, v in pairs(ents.FindByClass("func_breakable")) do
		if v:GetPos() == Vector(3307,4399,-788) then
			v:SetSaveValue("m_takedamage", 0)
			tank_breakable = v
		end
	end	
	for k, v in pairs(ents.FindByClass("ambient_generic")) do
		if v:GetName() == "brad_break_shakea" then
			v:SetSaveValue("message", "weapons/mortarhit.wav")
		end
	end
end

local expTrig
local barrels = {
	["can_expl1_mm"] = true,
	["can_expl2_mm"] = true,
	["can_expl3_mm"] = true
}

local function DeleteExplosionTrigger()
	local ent = ents.FindByName("leveldead_mm")[1]
	if IsValid(ent) then
		ent:Remove()
	end
	expTrig = true
end

function GM:OperateMapEvents(ent, input, caller, activator)
	if ent:GetClass() == "multi_manager" and ent:GetName() == "brad_mover_relay" and IsValid(tank_breakable) then
		tank_breakable:SetSaveValue("m_takedamage", 2)
	end
	if !expTrig and IsValid(activator) and (activator:IsPlayer() or activator:IsNPC()) and (ent:GetClass() == "logic_relay" and ent:GetName() == "leveldead_mm" and input == "Trigger" or barrels[ent:GetName()]) then
		expTrig = true
		local act_owner = activator:GetOwner()
		if IsValid(act_owner) and act_owner:IsPlayer() then
			activator = act_owner
		end
		local name = activator:IsPlayer() and activator:Nick() or activator:GetClass()
		ChatMessage(name.." ".."#game_explosiontrig", 2)
	end
	if ent:GetClass() == "env_shake" and ent:GetName() == "leveldead_shake1" then
		self:GameOver(true)
	end
	if ent:GetClass() == "func_door_rotating" and ent:GetName() == "barney_gate_open1" and input == "Open" then
		table.RemoveByValue(self.ImportantNPCs, "barney1")
	end
	
	if ent:GetClass() == "func_tankmortar" and ent:GetName() == "brad_cannon" and input == "Activate" then
		ent.targetname = "brad_turret"
		ent:Initialize()
		--ent.FixTankEntity = true
		ent.FireSound = "ambience/biggun1.wav"
	end
end

function GM:OnMapRestart()
	if !table.HasValue(self.ImportantNPCs, "barney1") then
		table.insert(self.ImportantNPCs, "barney1")
	end
	expTrig = nil
	if rocketsPassed then
		self:RemoveCoopSpawnpoints()
		self:CreateCoopSpawnpoints(rocketsPassedPos, rocketsPassedAng)
		CreateWeaponBlock()
		DeleteExplosionTrigger()
	end
end

function GM:ModifyMapEntities()
	self:CreateWeaponEntity("weapon_shotgun", Vector(-100, 2451, -1140), Angle(0, -120, 0))
	self:CreateWeaponEntity("weapon_rpg", Vector(-69, 2397, -1072), Angle(-70, -170, 0))
	self:CreateWeaponEntity("weapon_357", Vector(2536, 3820, -600), Angle(0, 50, 0))
	self:CreateWeaponEntity("weapon_crossbow", Vector(-170, -1814, -380), Angle(0, 100, 0))
	self:CreateWeaponEntity("weapon_rpg", Vector(876, -3024, -560), Angle(0, 94, 0))
	self:CreateWeaponEntity("weapon_mp5", Vector(3015, -2880, -420), Angle(0, 35, 0))
	self:CreateWeaponEntity("weapon_handgrenade", Vector(1443, -1730, -713), Angle())
	self:CreateWeaponEntity("weapon_satchel", Vector(2246, -2058, -690), Angle(0, 180, 0))
	self:CreateWeaponEntity("weapon_gauss", Vector(2435, -1070, -380), Angle(0, -90, 0))
	--self:CreateWeaponEntity("weapon_shotgun", Vector(376, -2760, -635), Angle(90, 0, 0))
	self:CreatePickupEntity("ammo_9mmclip", Vector(365, -2755, -650), Angle(0, -5, 0))
	
	for i = 0, 160, 40 do
		self:CreatePickupEntity("ammo_gaussclip", Vector(2091 + i, 2775, -580), Angle(0, 90, 0))
		self:CreatePickupEntity("ammo_gaussclip", Vector(2091 + i, 2647, -580), Angle(0, 90, 0))
	end
	self:CreateWeaponEntity("weapon_egon", Vector(2274, 2705, -580), Angle(0, 180, 0))
	for i = 0, 120, 30 do
		self:CreatePickupEntity("item_healthkit", Vector(2515, 2836 + i, -580), Angle(0, math.random(-26, 26), 0))
		self:CreatePickupEntity("item_battery", Vector(2147, 2831 + i, -580), Angle())
		self:CreatePickupEntity("ammo_argrenades", Vector(2195, 2831 + i, -580), Angle(0, math.random(-180, 180), 0))
	end
	
	-- moves players from spawn once rockets room is passed
	local fTrig = ents.Create("hl1_trigger_func")
	if IsValid(fTrig) then
		function fTrig:Touch(ent)
			if rocketsPassed and ent:IsPlayer() then
				ent:Spawn()
			end
		end
		fTrig:Spawn()
		fTrig:SetCollisionBoundsWS(Vector(-206, -781, -128), Vector(423, -386, -352))
	end
	-- deletes explosion trigger so it couldn't ruin level progress
	local deleteExplosion = ents.Create("hl1_trigger_func")
	if IsValid(deleteExplosion) then
		deleteExplosion.TouchFunction = function()
			DeleteExplosionTrigger()
			deleteExplosion:Remove()
		end
		deleteExplosion:Spawn()
		deleteExplosion:SetCollisionBoundsWS(Vector(1314, 2510, -1152), Vector(1296, 2287, -1002))
	end
	
	-- sets the name for tank so it can be detected in EntityTakeDamage hook
	for k, v in pairs(ents.FindInSphere(Vector(3311, 4399, -764), 16)) do
		if v:GetClass() == "func_breakable" and v:GetName() == "" then
			v:SetName("tank_break_explob")
		end
	end
	
	-- we dont need this in coop
	for k, v in pairs(ents.FindByClass("scripted_sequence")) do
		if v:GetName() == "watchout" or v:GetName() == "watchoutforthedoorsbarney" then
			v:Remove()
		end
	end
	
	for k, v in pairs(ents.FindByName("sniper1")) do
		if v:GetClass() == "func_tank" then
			local cEnt = ents.Create("func_tank_controller")
			if IsValid(cEnt) then
				cEnt:SetParent(v)
				cEnt:SetPos(v:GetPos())
				cEnt:Spawn()
			end
		end
	end
end

function SkipTripmines()
	if rocketsPassed then return end
	rocketsPassed = true
	GAMEMODE:GameRestart()
end

function TripminesSkipped()
	return rocketsPassed
end