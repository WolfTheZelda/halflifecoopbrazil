AddCSLuaFile()

GM.DisableFullRespawn = true

if CLIENT then return end

GM.StartingWeapons = false

GM.npcLagFixBlacklist = {
	["headcrab_crab1"] = true,
	["headcrab_crab2"] = true
}

function GM:CreateViewPoints()
	self:CreateViewPointEntity(Vector(-1655, 542, -1582), Angle(0, 90, 0))
end

local tele1pos = Vector(2240, -480, -310)
local tele2pos = Vector(1175, 2110, 780)
local tele3pos = Vector(5740, 1100, 880)
local tele4pos = Vector(5344, 2583, -1655)

function GM:CreateMapEventCheckpoints(ent, activator)
	if ent:GetName() == "airamm" then
		local weptable = {"weapon_crowbar", "weapon_glock"}
		self:Checkpoint(Vector(2915, 1820, 810), Angle(0, -90, 0), {tele1pos, tele2pos}, activator, weptable)
	end
	if ent:GetName() == "2teleport_mm1" then
		local weptable = {"weapon_crowbar", "weapon_glock"}
		self:Checkpoint(Vector(5580, 2815, -1700), Angle(0, 180, 0), {tele1pos, tele2pos, tele3pos}, activator, weptable)
	end
end

function GM:CreateMapCheckpoints()
	self:CreateCheckpointTrigger(Vector(902, 1944, 721), Vector(569, 2280, 626), Vector(1035, 2114, 730), Angle(), tele1pos, "weapon_crowbar")
	self:CreateCheckpointTrigger(Vector(4544, 5534, -2010), Vector(4480, 5520, -1920), Vector(4612, 5478, -2016), Angle(0, 150, 0), {tele1pos, tele2pos, tele3pos, tele4pos}, {"weapon_crowbar", "weapon_glock"})
end

local function NPCMoveTo(npc, vec)
	npc:SetSaveValue("m_vecLastPosition", vec)
	npc:SetSchedule(SCHED_FORCED_GO)
end

local waitTrig

function GM:OperateMapEvents(ent, input, caller)
	if ent:GetClass() == "func_door" and ent:GetName() == "retinal_scanner_door" and input == "Open" then
		local sci = ents.FindByName("console_guy")[1]
		if IsValid(sci) and sci:IsNPC() then
			sci:SetCondition(17)
			timer.Simple(.1, function()
				if IsValid(sci) then
					NPCMoveTo(sci, Vector(608, -305, -144))
				end
			end)
		end
	end
	if ent:GetClass() == "func_door_rotating" and ent:GetName() == "retinal_scanner_door_up" and input == "Open" then
		local sci = ents.FindByName("sitting_scientist12")[1]
		if IsValid(sci) and sci:IsNPC() then
			sci:SetCondition(17)
			timer.Simple(.1, function()
				if IsValid(sci) then
					NPCMoveTo(sci, Vector(3082, 992, 952))
				end
			end)
		end
	end
	if IsValid(waitTrig) and ent:GetClass() == "func_button" and ent:GetName() == "elebutton1" and IsValid(caller) and caller:GetClass() == "func_door" and input == "Unlock" then
		ent:Fire("Lock")
	end
	if ent:GetClass() == "func_door" and ent:GetName() == "startele1" and input == "Close" then
		local box = ents.FindInBox(Vector(3960, 5499, -1712), Vector(3836, 5495, -1616))
		for k, v in pairs(box) do
			if v:IsPlayer() then
				v:SetVelocity(Vector(0, -500, 0))
			end
		end
	end
end

function GM:FixMapEntities()
	for k, v in pairs(ents.FindByClass("monster_generic")) do
		if v:GetModel() == "models/barney.mdl" then
			v:SetModel("models/hl1bar.mdl")
		end
	end
	
	for k, v in pairs(ents.FindByName("crate*")) do
		if v:GetClass() == "func_physbox" then
			local phys = v:GetPhysicsObject()
			if IsValid(phys) then
				phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
				if self:GetSkillLevel() <= 1 then
					phys:EnableMotion(false)
				end
			end
		end
	end
	
	local pushClip = ents.Create("hl1_pushableclip")
	if IsValid(pushClip) then
		pushClip:Spawn()
		pushClip:SetCollisionBoundsWS(Vector(4828, 768, 768), Vector(4996, 812, 925))
	end
	
	local fTrig = ents.Create("hl1_trigger_func")
	if IsValid(fTrig) then
		function fTrig:StartTouch(ent)
			if ent:GetClass() == "monster_scientist" and ent:GetName() == "OHDEAR" then
				ent:SetNoDraw(true)
				ent:SetNotSolid(true)
				timer.Simple(.7, function()
					if IsValid(ent) then
						GAMEMODE:GibEntity(ent, 36, Vector(0, 0, 1300))
						ent:Remove()
					end
				end)
			end
		end
		fTrig:Spawn()
		fTrig:SetCollisionBoundsWS(Vector(829, 2196, -816), Vector(626, 2012, -680))
	end
end

function GM:ModifyMapEntities() -- this hook runs in coop only
	self:CreateCoopSpawnpoints(Vector(1708, 262, -380), Angle())
	
	self:CreatePickupEntity("item_battery", Vector(5581, 2678, -1480), Angle(0, 145, 0))
	self:CreatePickupEntity("item_battery", Vector(5597, 2691, -1480), Angle(0, 100, 0))
	for i = 0, 6 do
		self:CreatePickupEntity("item_battery", Vector(2704 - i * 32, 4151, -2000), Angle())
	end
	
	local func = function()
		for k, v in pairs(ents.FindByName("elebutton1")) do
			if v:GetClass() == "func_button" then
				v:Fire("Unlock")
			end
		end
	end
	waitTrig = self:CreateWaitTrigger(Vector(4023, 5232, -1712), Vector(3768, 5465, -1569), 60, false, func, WAIT_FREE, true)
	
	self:CreateFallTrigger(Vector(4960, 2752, -236), Vector(3054, 3600, -279))
	self:CreateFallTrigger(Vector(4576, 3927, -2288), Vector(5232, 3335, -2215)) -- bullsquid
	self:CreateFallTrigger(Vector(4672, 5231, -3824), Vector(5472, 6191, -3790)) -- crates
end

function GM:CreateExtraEnemies()
	self:CreateNPCSpawner("monster_zombie", 3, Vector(-380, 2670, 750), Angle(0, -90, 0), 550, false)
	self:CreateNPCSpawner("monster_zombie", 2, Vector(228, 4000, 750), Angle(), 400, false)
	self:CreateNPCSpawner("monster_zombie", 2, Vector(-170, 4030, 740), Angle(), 150, false)
	self:CreateNPCSpawner("monster_zombie", 2, Vector(2512, 3320, 780), Angle(0, 135, 0), 520, false)
	self:CreateNPCSpawner("monster_zombie", 3, Vector(2645, 3020, 780), Angle(0, 120, 0), 800, false)
	self:CreateNPCSpawner("monster_zombie", 2, Vector(5240, 730, 580), Angle(0, 180, 0), 720, false)
	self:CreateNPCSpawner("monster_zombie", 3, Vector(4900, 911, 580), Angle(0, -90, 0), 280, false)
	--self:CreateNPCSpawner("monster_headcrab", 1, Vector(5400, 600, 770), Angle(0, 180, 0), 550, false)
	--self:CreateNPCSpawner("monster_headcrab", 1, Vector(5350, 535, 770), Angle(0, 180, 0), 530, false)
	--self:CreateNPCSpawner("monster_headcrab", 1, Vector(5386, 498, 770), Angle(0, 180, 0), 670, false)
	--self:CreateNPCSpawner("monster_headcrab", 1, Vector(5528, 490, 770), Angle(0, 180, 0), 680, false)
	--self:CreateNPCSpawner("monster_houndeye", 1, Vector(5740, 1100, 832), Angle(0, -90, 0), 350, true)
end

function GM:CreateSurvivalEntities()
	self:CreateWeaponEntity("weapon_healthkit", Vector(2115, -409, -321), Angle(0, -65, 0))
	--self:CreateWeaponEntity("weapon_healthkit", Vector(550, -314, -108), Angle(0, -25, 0))
end

function GM:OnCheckpoint(pos, ang, ply, weptable)
	self.StartingWeaponsSurvival = "weapon_crowbar"
end

function GM:OnMapRestart()
	self.StartingWeaponsSurvival = nil
end