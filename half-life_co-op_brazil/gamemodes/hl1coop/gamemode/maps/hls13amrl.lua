GM.StartingWeapons = {"weapon_crowbar", "weapon_glock", "weapon_357", "weapon_mp5", "weapon_shotgun", "weapon_crossbow", "weapon_rpg", "weapon_gauss", "weapon_hornetgun", "weapon_handgrenade", "weapon_satchel", "weapon_tripmine", "weapon_snark"}

local importantNPCtable = {"scientist_c3a2", "thesci", "thegun", "theb", "c3a2_portsci"}
GM.ImportantNPCs = importantNPCtable
GM.ImportantHealthBlacklist = {["theb"] = true}
GM.NPCUseFix = {["scientist_c3a2"] = true, ["thesci"] = true}

function GM:CreateViewPoints()
	self:CreateViewPointEntity(Vector(625, 600, 220), Angle(5, 140, 0))
end

function GM:ModifyMapEntities()
	self:CreateWeaponEntity("weapon_crossbow", Vector(-355, 1018, 232), Angle(0, 185, 0))
	self:CreateWeaponEntity("weapon_mp5", Vector(-1615, 1870, -1010), Angle(0, 192, 0))
	self:CreateWeaponEntity("weapon_rpg", Vector(126, 1049, -780), Angle(0, 80, 0))
	self:CreateWeaponEntity("weapon_357", Vector(444, -719, -798), Angle(0, 20, 0))
	self:CreateWeaponEntity("weapon_mp5", Vector(1891, 2498, 1230), Angle(0, 30, 0))
	self:CreateWeaponEntity("weapon_shotgun", Vector(1744, 1160, 800), Angle(0, -105, 0))
	
	for k, v in pairs(ents.FindByName("c3a2d_door3")) do
		v:SetNotSolid(true)
		v:SetNoDraw(true)
	end
	
	for _, ent in pairs(ents.FindByClass("trigger_changelevel")) do
		ent.FadeEffect = true -- saving your eyes
	end
end

local tele1pos = Vector(1890, 800, 180)
local tele2pos = Vector(-818, 1055, 310)
local tele3pos = Vector(-862, 2150, -745)
local tele4pos = Vector(2978, 2426, 1212)

function GM:CreateMapEventCheckpoints(ent, activator)
	if ent:GetName() == "argue" then
		self:Checkpoint(Vector(-860, 930, -795), Angle(0, 45, 0), {tele1pos, tele2pos}, activator, "weapon_egon")
	end
	--[[if ent:GetName() == "c3a2spawn_mm" then
		self:Checkpoint(Vector(3540, 2910, 1165), Angle(0, 180, 0), {tele1pos, tele2pos}, activator, "weapon_egon")
	end]]--
	if ent:GetName() == "c3a2_rumbles1" then
		self:Checkpoint(Vector(3665, 705, 2445), Angle(0, 180, 0), {tele1pos, tele2pos, tele3pos, tele4pos}, activator, "weapon_egon")
	end
	if ent:GetName() == "music_track_19" then
		self:RemoveCoopSpawnpoints()
		self:CreateCoopSpawnpoints(Vector(3379, 1487, 2445), Angle(0, -30, 0))
		self:Checkpoint(Vector(3435, 1580, 2460), Angle(0, -90, 0), {tele1pos, tele2pos, tele3pos, tele4pos}, activator, "weapon_egon")
	end
end

function GM:CreateMapCheckpoints()
	self:CreateCheckpointTrigger(Vector(2352, 2734, 1280), Vector(2216, 2715, 1160), Vector(1985, 2508, 1160), Angle(0, 90, 0), {tele1pos, tele2pos, tele3pos}, "weapon_egon")
end

function GM:OperateMapEvents(ent, input, caller, activator)
	if ent:GetClass() == "func_door" and ent:GetName() == "retinal_scanner_door" and input == "Open" then
		table.RemoveByValue(self.ImportantNPCs, "scientist_c3a2")
	end
	if ent:GetClass() == "func_door" and ent:GetName() == "c3a2d_door2" and input == "Open" then
		table.RemoveByValue(self.ImportantNPCs, "thesci")
		table.RemoveByValue(self.ImportantNPCs, "theb")
	end
	--if ent:GetClass() == "trigger_multiple" and ent:GetName() == "badportal" and input == "Kill" then
	if ent:GetClass() == "scripted_sentence" and ent:GetName() == "c3a2_portaudio04" then
		local portsci = ents.FindByName("c3a2_portsci")[1]
		if IsValid(portsci) and portsci:Health() > 0 then
			table.RemoveByValue(self.ImportantNPCs, "c3a2_portsci")
			sound.Play("scientist/c3a2_sci_portopen.wav", Vector(2261, 1418, 2832), 0, 100, 1)
		end
	end

	if ent:GetClass() == "multi_manager" and input == "Trigger" then
		if ent:GetName() == "mm1" then
			for k, v in pairs(self:GetActivePlayersTable()) do
				if v != activator then
					v:SendScreenHintTop("#notify_pumpblue")
				end
			end
		end
		if ent:GetName() == "mm2" then
			for k, v in pairs(self:GetActivePlayersTable()) do
				if v != activator then
					v:SendScreenHintTop("#notify_pumporange")
				end
			end
		end
	end
	
	if ent:GetClass() == "trigger_hurt" and ent:GetName() == "c3a2d_alldead" and input == "Enable" then
		SetGlobalBool("DisablePlayerRespawn", true)
		if GetGlobalFloat("WaitTime") < CurTime() then
			timer.Simple(5, function()
				self:GameOver()
			end)
		end
	end
	
	if IsValid(caller) and caller:GetClass() == "trigger_once" and ent:GetName() == "heymaster" and input == "Trigger" then
		for k, v in pairs(ents.FindByClass("speaker")) do
			v:TurnOff()
		end
	end
end

function GM:OnMapRestart()
	self.ImportantNPCs = importantNPCtable
	SetGlobalBool("DisablePlayerRespawn", false)
end