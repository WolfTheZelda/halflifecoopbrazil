AddCSLuaFile()

GM.DisableFullRespawn = true

if CLIENT then return end

GM.StartingWeapons = false
GM.DisallowSurvivalMode = true
GM.npcLagFixDisabled = true

function GM:CreateViewPoints()
	self:CreateViewPointEntity(Vector(1900, 3325, 915), Angle(10, 45, 0))
	self:CreateViewPointEntity(Vector(1380, 3100, 926), Angle(5, -50, 0))
	self:CreateViewPointEntity(Vector(-350, 4246, 840), Angle(15, 45, 0))
	self:CreateViewPointEntity(Vector(-590, 4682, 830), Angle(10, -140, 0))
	
	if GetGlobalBool("FirstLoad") then
		local seqnames = {
			["introwalkerguy1mm"] = true,
			["gizmoscistart"] = true,
			["relax_ssss"] = true,
			["enterbarney1"] = true,
			["GmanSeeYou"] = true,
			["start1"] = true,
			["machine1"] = true,
		}
		for k, v in pairs(ents.FindByClass("scripted_sequence")) do
			if seqnames[v:GetName()] then
				v:Fire("BeginSequence")
			end
		end
	end
end

local function CreateSuitEntity(pos, ang)
	local suit = ents.Create("item_suit")
	if IsValid(suit) then
		suit:SetPos(pos)
		suit:SetAngles(ang)
		suit.dontRemove = true
		suit.Respawnable = true
		suit:Spawn()
	end
end

function GM:ModifyMapEntities()
	self:CreateCoopSpawnpoints(Vector(2554, 3534, 780), Angle(0, 180, 0))
	if game.MaxPlayers() > 1 then
		CreateSuitEntity(Vector(-1550, 4304, 746), Angle())
	end
	if game.MaxPlayers() > 2 then
		CreateSuitEntity(Vector(-1550, 4048, 746), Angle())
	end
	self:CreateWaitTrigger(Vector(-295, 2530, 728), Vector(-391, 2396, 872), 40, true)
	self:CreateWaitTrigger(Vector(610, 1168, -144), Vector(418, 928, 0), 30)
	self:CreateWaitTrigger(Vector(1398, -360, -217), Vector(1271, -48, -360), 30)

	if GetGlobalBool("FirstLoad") then
		for k, v in pairs(ents.FindByClass("logic_auto")) do
			v:Remove()
		end
	end
	
	local fTrig = ents.Create("hl1_trigger_func")
	if IsValid(fTrig) then
		fTrig.TouchFunction = function(ply)
			ply:ScreenFade(SCREENFADE.IN, Color(0,0,0,255), 1, 14)
		end
		fTrig:Spawn()
		fTrig:SetCollisionBoundsWS(Vector(3400, 4631, -3563), Vector(3304, 4788, -3456))
	end
end

function GM:OperateMapEvents(ent, input, caller)	
	if IsValid(ent) and ent:GetClass() == "func_door" and ent:GetName() == "tldoor" and input == "Open" and self:IsCoop() then
		ent:SetNotSolid(true)
	end
	if ent:GetClass() == "multi_manager" and ent:GetName() == "probe_arm_mm" and input == "Trigger" then
		local pushClip = ents.Create("hl1_pushableclip")
		if IsValid(pushClip) then
			pushClip:Spawn()
			pushClip:SetCollisionBoundsWS(Vector(1365, 664, -384), Vector(1340, 576, -300))
		end
	end
	--[[if ent:GetClass() == "scripted_sequence" and ent:GetName() == "argument" and caller:GetClass() == "trigger_once" then
		local sci = ents.FindByName("arguments")[1]
		local gman = ents.FindByName("argumentg")[1]
	end]]--
end

local tele1pos = Vector(1900, 3330, 830)
local tele2pos = Vector(1060, 420, -95)
local tele3pos = Vector(1401, -145, -310)

function GM:CreateMapCheckpoints()
	self:CreateCheckpointTrigger(Vector(491, 2524, -144), Vector(501, 2400, -32), Vector(572, 2466, -140), Angle(), tele1pos, "item_suit")
end

function GM:CreateMapEventCheckpoints(ent, activator, input)
	if ent:GetName() == "test_lab_entry_door" and input == "Close" then
		self:Checkpoint(Vector(1665, -100, -340), Angle(0, 90, 0), {tele1pos, tele2pos, tele3pos}, activator, "item_suit")
		for k, v in pairs(ents.FindByClass("speaker")) do
			v:TurnOff()
		end
	end
	if ent:GetName() == "portal_begin_mm" then
		self:RemoveCoopSpawnpoints()
		self:CreateCoopSpawnpoints(Vector(1665, 180, -350), Angle(0, 90, 0))
		self.GiveSuitOnSpawn = true
	end
end

function GM:OnPlayerSpawn(ply)
	if !self.GiveSuitOnSpawn then
		ply:RemoveSuit()
	end
end

function GM:OnSuitPickup(ply)
	if !cvars.Bool("hl1_coop_sv_custommodels") then
		ply:SetModel("models/player/hl1/helmet.mdl")
	end
	for k, v in pairs(ents.FindByName("hevmastered")) do
		v:Fire("Enable")
	end
end

function GM:OnMapRestart()
	self.GiveSuitOnSpawn = false
end