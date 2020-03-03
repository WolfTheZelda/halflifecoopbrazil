AddCSLuaFile("cl_envmapfix.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_menus.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_spec.lua")
AddCSLuaFile("cl_view.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_chatsounds.lua")
AddCSLuaFile("sh_entity.lua")
AddCSLuaFile("sh_player.lua")
AddCSLuaFile("sh_skill.lua")
AddCSLuaFile("sh_crackmode.lua")
AddCSLuaFile("gsrchud.lua")
AddCSLuaFile("hl1_music.lua")
AddCSLuaFile("hl1_soundscripts.lua")
AddCSLuaFile("conflictfix.lua")

local lang_files = file.Find(GM.FolderName.."/gamemode/lang/*", "LUA")
for k, v in pairs(lang_files) do
	AddCSLuaFile("lang/"..v)
end

include("shared.lua")
include("sv_entreplace.lua")
include("sv_spec.lua")
include("sv_vote.lua")
include("sv_resource.lua")

util.AddNetworkString("HL1DeathMenu")
util.AddNetworkString("HL1StartMenu")
util.AddNetworkString("HL1ChapterPreStart")
util.AddNetworkString("HL1ChapterStart")
util.AddNetworkString("HL1GameIntro")
util.AddNetworkString("HL1GameOver")
util.AddNetworkString("HL1Music")
util.AddNetworkString("ScreenMessageScore")
util.AddNetworkString("TextMessageCenter")
util.AddNetworkString("PlayerHasFullyLoaded")
util.AddNetworkString("PlayerWaitBool")
util.AddNetworkString("SetLongJumpClient")
util.AddNetworkString("PlayClientSound")
util.AddNetworkString("GibPlayer")
util.AddNetworkString("SendConnectingPlayers")
util.AddNetworkString("ShowScreenHint")
util.AddNetworkString("ShowScreenHintTop")
util.AddNetworkString("ShowTeleportHint")
util.AddNetworkString("ShowMapRecords")
util.AddNetworkString("ChatMessage")
util.AddNetworkString("UpdatePlayerPositions")
util.AddNetworkString("SetGlobalBoolFix")
util.AddNetworkString("SetGlobalFloatFix")
util.AddNetworkString("SetPlayerModel")
util.AddNetworkString("ApplyViewModelHands")
util.AddNetworkString("ShowCaption")
util.AddNetworkString("RagdollGib")
util.AddNetworkString("LastCheckpointPos")
util.AddNetworkString("RunServerCommand")

net.Receive("RunServerCommand", function(len, ply)
	if IsValid(ply) and ply:IsPlayer() and ply:IsSuperAdmin() then
		RunConsoleCommand(net.ReadString(), net.ReadString())
	end
end)

net.Receive("PlayerHasFullyLoaded", function(len, ply)
	ply.afkTime = 0
	ply:SetNWInt("Status", PLAYER_NOTREADY)
	
	local userid = ply:UserID()
	
	if GAMEMODE.ConnectingPlayers then
		if table.HasValue(GAMEMODE.ConnectingPlayers, userid) then
			table.RemoveByValue(GAMEMODE.ConnectingPlayers, userid)
			
			net.Start("SendConnectingPlayers")
			net.WriteTable(GAMEMODE.ConnectingPlayers)
			net.Broadcast()
		end
	end
end)

net.Receive("SetPlayerModel", function(len, ply)
	if cvars.Bool("hl1_coop_sv_custommodels", false) then
		if IsValid(ply) and ply:Alive() then
			ply:SetModel(net.ReadString())
			ply:SetupHands()
		end
	else
		ply:PrintMessage(HUD_PRINTCONSOLE, "Cannot set a model due to server settings")
	end
end)

CreateConVar("_hl1coop_debug", 0, FCVAR_ARCHIVE)
CreateConVar("hl1_coop_friendlyfire", 0, FCVAR_NOTIFY, "Friendly fire in Coop")
--CreateConVar("hl1_coop_limitedrespawns", 1, FCVAR_NOTIFY, "Limited continues")
local cvar_speedrun = CreateConVar("hl1_coop_speedrunmode", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
local cvar_survival = CreateConVar("hl1_coop_sv_survival", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
local cvar_crack = CreateConVar("hl1_coop_crackmode", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
cvar_afktime = CreateConVar("hl1_coop_sv_afktime", 300, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Move AFK player to spectators after the time in seconds")
local cvar_gainnpchp = CreateConVar("hl1_coop_sv_gainnpchealth", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Enable increasing NPC health depending on player count")
local cvar_plygib = CreateConVar("hl1_coop_sv_playergib", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Allow player gibbing on high damage")
cvar_medkit = CreateConVar("hl1_coop_sv_medkit", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Give medkit in non-survival mode")
local cvar_firstmap = CreateConVar("hl1_coop_sv_firstmap", "", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The map that will load after game end, e.g. the lobby")
cvar_fixnihilanth = CreateConVar("hl1_coop_sv_fixnihilanth", 1)
--cvar_airaccelerate = CreateConVar("hl1_coop_sv_airaccelerate", 10, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Air accelerate")

GM.WeaponRespawnTime = .5
GM.ReturnToReadyScreenTime = 120 -- when no players on server, it automatically returns to ready screen

MAX_DROPPED_WEAPONS = 10

-- TODO: move to certain map file
GM.StartingAmmo = {
	["hls07amrl"] = {2, "MP5_Grenade"},
	["hls07bmrl"] = {2, "MP5_Grenade"},
	["hls08amrl"] = {2, "MP5_Grenade"},
	["hls11amrl"] = {2, "MP5_Grenade"},
	["hls11bmrl"] = {2, "MP5_Grenade"},
	["hls11cmrl"] = {2, "MP5_Grenade"},
	["hls12amrl"] = {2, "MP5_Grenade"},
	["hls13amrl"] = {2, "MP5_Grenade"},
	["hls14amrl"] = {2, "MP5_Grenade"},
	["hls14bmrl"] = {2, "MP5_Grenade"},
	["hls14cmrl"] = {2, "MP5_Grenade"},
}

concommand.Add("unload", function(ply)
	if IsValid(ply) then
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) then
			if wep.Unload then
				wep:Unload()
			end
		end
	end
end)

concommand.Add("unstuck", function(ply)
	if IsValid(ply) and ply:IsStuck() then
		ply:Unstuck()
	end
end)

local medicSnd = Sound("fgrunt/medic.wav")
concommand.Add("callmedic", function(ply)
	local ragdoll = ply:GetRagdollEntity()
	if (GAMEMODE:GetSurvivalMode() or cvar_medkit:GetBool()) and IsValid(ply) and (ply:Alive() or IsValid(ragdoll)) and ply:Team() == TEAM_COOP and (!ply.CallMedicTime or ply.CallMedicTime <= CurTime()) then
		if !ply:Alive() and IsValid(ragdoll) then
			EmitSound(medicSnd, ragdoll:GetPos(), ragdoll:EntIndex(), CHAN_VOICE, 1, 100, 1, 100 + math.random(-5, 5))
		else
			ply:EmitSound(medicSnd, 80, 100 + math.random(-5, 5), 1, CHAN_VOICE)
		end
		ply.CallMedicTime = CurTime() + 3
		ply:SetNWFloat("CallMedicTime", ply.CallMedicTime)
	end
end)

function GM:GlobalTextMessageCenter(msg, delay)
	net.Start("TextMessageCenter")
	net.WriteString(msg)
	net.WriteFloat(delay)
	net.Broadcast()
end

function ChatMessage(msg, t)
	t = t or 1
	net.Start("ChatMessage")
	net.WriteString(msg)
	net.WriteUInt(t, 4)
	net.Broadcast()
end

function debugPrint(...)
	if cvars.Bool("_hl1coop_debug") then
		print(...)
	end
end

function GM:Initialize()
	RunConsoleCommand("sv_sticktoground", "0")
	RunConsoleCommand("sv_airaccelerate", "20")
	RunConsoleCommand("sv_gravity", "800")
	if !game.SinglePlayer() then RunConsoleCommand("ai_use_think_optimizations", "0") end
	RunConsoleCommand("ai_serverragdolls", "0")
	RunConsoleCommand("hl1_sv_loadout", "0")
	RunConsoleCommand("hl1_sv_clampammo", "1")
	RunConsoleCommand("hl1_sk_plr_dmg_mp5_bullet", "8")
	
	timer.Simple(0, function()
		self:SetSkillLevel()
	end)
end

function GM:CreateCoopSpawnpoints(pos, ang, amount)
	--local info_player_start = ents.FindByClass("info_player_start")[1]
	--ang = self:IsCoop() and IsValid(info_player_start) and info_player_start:GetAngles() or ang
	amount = amount or game.MaxPlayers()
	local transSpawnPointFirst = ents.Create("info_player_coop")
	if IsValid(transSpawnPointFirst) then
		local tr = util.TraceHull({
			start = pos,
			endpos = pos + Vector(0,0,72),
			filter = player.GetAll(),
			mask = MASK_PLAYERSOLID,
			mins = Vector(-16, -16, 0),
			maxs = Vector(16, 16, 0)
		})
		if tr.Hit then
			pos = pos + (pos - tr.HitPos)
		end
		transSpawnPointFirst:SetPos(pos)
		transSpawnPointFirst:SetAngles(ang)
		transSpawnPointFirst:Spawn()
		if !transSpawnPointFirst:IsInWorld() then
			transSpawnPointFirst:Remove()
		end
		--print(transSpawnPointFirst, transSpawnPointFirst:GetPos(), transSpawnPointFirst:OBBMins())
	end
	if self:IsCoop() and IsValid(transSpawnPointFirst) then
		for i = 2, amount do
			local vecrand = VectorRand() * i * 20
			vecrand[3] = 0
			local tr = util.TraceHull({
				start = pos,
				endpos = pos + vecrand,
				filter = player.GetAll(),
				mask = MASK_PLAYERSOLID,
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 72)
			})
			local transSpawnPoint = ents.Create("info_player_coop")
			if IsValid(transSpawnPoint) then
				transSpawnPoint:SetPos(tr.HitPos)
				transSpawnPoint:SetAngles(ang)
				transSpawnPoint:Spawn()
				if !transSpawnPoint:IsInWorld() then
					transSpawnPoint:Remove()
				else
					debugPrint("Created spawnpoint", transSpawnPoint, transSpawnPoint:GetPos())
				end
			end
		end
	end
end

function GM:RemoveCoopSpawnpoints()
	local t = ents.FindByClass("info_player_coop")
	table.Add(t, ents.FindByClass("info_player_start"))
	for k, v in pairs(t) do
		v:Remove()
		debugPrint(v, "removed")
	end
end

GM.replaceEntsInBoxes = {
	["item_ammo_pistol"] = "weapon_glock",
	["item_ammo_pistol_large"] = "ammo_9mmclip",
	["item_ammo_smg1"] = "weapon_mp5",
	["item_ammo_smg1_large"] = "ammo_9mmAR",
	["item_ammo_ar2"] = "ammo_ARgrenades",
	["item_ammo_ar2_large"] = "weapon_shotgun",
	["item_box_buckshot"] = "ammo_buckshot",
	["item_flare_round"] = "weapon_crossbow",
	["item_box_flare_rounds"] = "ammo_crossbow",
	["item_rpg_round"] = "weapon_357",
	["unused (item_smg1_grenade) 13"] = "ammo_357",
	["item_box_sniper_rounds"] = "weapon_rpg",
	["unused (???) 15"] = "ammo_rpgclip",
	["weapon_stunstick"] = "ammo_gaussclip",
	["unused (weapon_ar1) 17"] = "weapon_handgrenade",
	["weapon_ar2"] = "weapon_tripmine",
	["unused (???) 19"] = "weapon_satchel",
	["weapon_rpg"] = "weapon_snark",
	["weapon_smg1"] = "weapon_hornetgun",
	["weapon_9mmar"] = "weapon_mp5",
	["weapon_9mmhandgun"] = "weapon_glock"
}

function GM:InitPostEntity(restart)
	if !restart and self:IsCoop() then
		self:SetGlobalBool("FirstLoad", true)
	end
	
	if !self.TransitionTable then
		local datafile = "hl1_coop/transition_data.txt"
		local data = file.Read(datafile)
		if data then
			self.TransitionTable = util.JSONToTable(data)
			file.Write(datafile, "")
		end
	end
	if self.TransitionTable then
		local t = self.TransitionTable
		
		self.TransitionMapName = t[1]
		local mapname = self.TransitionMapName
		local landmarkname = t[2]
		local lastmap = t[3]
		local pos = t[4]
		local ang = t[5]

		if mapname == game.GetMap() then
			SetGlobalBool("FirstLoad", false)
			if (!self.BlockSpawnpointCreation or !self.BlockSpawnpointCreation[lastmap]) and pos and ang then
				ang[1] = 0
				ang[3] = 0
				for k, v in pairs(ents.FindByClass("info_landmark")) do
					if v:GetSaveTable().m_iName == landmarkname then
						self:CreateCoopSpawnpoints(v:GetPos() + pos, ang)
					end
				end
			end
		end
	end
	
	if !self.LastPlayersTable then
		local datafile = "hl1_coop/transition_players_"..game.GetMap()..".txt"
		local tData = file.Read(datafile)
		if tData then
			self.LastPlayersTable = util.JSONToTable(tData)			
			file.Write(datafile, "")
		end
		if self:IsCoop() and self.LastPlayersTable then
			if !self.ConnectingPlayers then
				self.ConnectingPlayers = {}
			end
			for k, v in pairs(self.LastPlayersTable) do
				if self.ConnectingPlayers then
					table.insert(self.ConnectingPlayers, v.id)
				end
			end
		end
	end
	if !self.SkipFirstWaiting and self.ConnectingPlayers and #self.ConnectingPlayers > 0 and !GetGlobalBool("FirstLoad") then
		SetGlobalBool("FirstWaiting", true)
		SetGlobalFloat("FirstWaitingTime", SysTime() + 60)
		self.SkipFirstWaiting = true
		
		local entremove = ents.FindByClass("logic_auto")
		table.Add(entremove, ents.FindByClass("trigger_auto"))
		table.Add(entremove, ents.FindByClass("trigger_once"))
		table.Add(entremove, ents.FindByClass("trigger_multiple"))
		table.Add(entremove, ents.FindByClass("multi_manager"))
		table.Add(entremove, ents.FindByClass("monster_*"))
		for k, v in pairs(entremove) do
			v:Remove()
		end
	end
	
	-- remove items on first map in chapter
	--[[if self:IsCoop() or game.MapLoadType() != "transition" then
		timer.Simple(.2, function()
			local removeStuff = {}
			table.Add(removeStuff, ents.FindByClass("weapon_*"))
			table.Add(removeStuff, ents.FindByClass("item_*"))
			table.Add(removeStuff, ents.FindByClass("ammo_*"))
			for k, v in pairs(removeStuff) do
				if !v:CreatedByMap() and !IsValid(v:GetOwner()) and !v.dontRemove then
					print("Removed " .. v:GetClass(), v:GetPos())
					v:Remove()
				end
			end
		end)
	end]]--
	for k, v in pairs(ents.FindByName("player_spawn_template")) do
		v:Remove()
	end
	
	-- fix for spawning items from breakables
	local breakables = {}
	table.Add(breakables, ents.FindByClass("func_breakable"))
	table.Add(breakables, ents.FindByClass("func_physbox"))
	for k, v in pairs(breakables) do
		local repl = self.replaceEntsInBoxes[v:GetSaveTable().m_iszSpawnObject]
		if repl then
			v:SetSaveValue("m_iszSpawnObject", repl)
		end
	end

	hook.Run("FixMapEntities")
	hook.Run("CreateMapCheckpoints")
	if self:IsCoop() then
		hook.Run("ModifyMapEntities")
		hook.Run("CreateViewPoints")
		hook.Run("CreateExtraEnemies")
		
		-- fades work bad in multiplayer
		for k, v in pairs(ents.FindByClass("env_fade")) do
			if !self.EnvFadeWhitelist or !self.EnvFadeWhitelist[v:GetName()] then
				v:Remove()
			end
		end
	end
	if self:GetSurvivalMode() then
		hook.Run("CreateSurvivalEntities")
	end
	
	if game.SinglePlayer() then
		if cvar_speedrun:GetBool() and !self:GetSpeedrunMode() then
			self:SetSpeedrunMode(true, 2)
		end
		if cvar_survival:GetBool() and !self:GetSurvivalMode() then
			self:SetSurvivalMode(true)
		end
		if cvar_crack:GetBool() and !self:GetCrackMode() then
			self:SetCrackMode(true)
			self:RestartMap()
		end
	end
end

function GM:CreateWeaponEntity(class, pos, ang, respawnable)
	pos = pos or Vector()
	ang = ang or Angle()
	respawnable = respawnable or true
	local wep = ents.Create(class)
	if IsValid(wep) then
		wep:SetPos(pos)
		wep:SetAngles(ang)
		if respawnable then
			wep.rRespawnable = respawnable
		end
		wep:Spawn()
	end
end

function GM:CreatePickupEntity(class, pos, ang, respawnable)
	respawnable = respawnable or true
	local ent = ents.Create(class)
	if IsValid(ent) then
		ent:SetPos(pos)
		ent:SetAngles(ang)
		if respawnable then
			ent.Respawnable = respawnable
		end
		ent:Spawn()
	end
end

function GM:CreatePlayerClip(mins, maxs)
	local plyClip = ents.Create("hl1_playerclip")
	if IsValid(plyClip) then
		plyClip:Spawn()
		plyClip:SetCollisionBoundsWS(mins, maxs)
	end
end

function GM:CreateFallTrigger(mins, maxs)
	local fTrig = ents.Create("hl1_trigger_func")
	if IsValid(fTrig) then
		fTrig.TouchFunction = function(ply)
			ply.KilledByFall = true
		end
		fTrig:Spawn()
		fTrig:SetCollisionBoundsWS(mins, maxs)
	end
end

WAIT_NOMOVE, WAIT_FREEZE, WAIT_LOCK, WAIT_FREE = 0, 1, 2, 3

function GM:CreateWaitTrigger(mins, maxs, t, hev, endfunc, trigtype, finaltrig)
	if game.MaxPlayers() < 2 then return end
	local wTrig = ents.Create("hl1_trigger_wait")
	if IsValid(wTrig) then
		if hev then
			wTrig.HEVRequire = true
		end
		wTrig:SetTimer(t)
		if endfunc then
			wTrig.EndFunction = endfunc
		end
		if trigtype then
			wTrig.WaitType = trigtype
		end
		if finaltrig then
			wTrig.FinalTrigger = true
		end
		wTrig:Spawn()
		wTrig:SetCollisionBoundsWS(mins, maxs)
		
		return wTrig
	end
end

function GM:CreateTeleport(pos, dest, ang, weptable)
	local ent = ents.Create("hl1_teleport")
	if IsValid(ent) then
		ent:SetPos(pos)
		ent:SetDestination(dest, ang)
		if weptable then
			ent:SetWeaponTable(weptable)
		end
		ent:Spawn()
	end
end

function GM:RemovePreviousCheckpoint(except)
	local t = ents.FindByClass("hl1_teleport")
	for k, v in pairs(t) do
		if istable(except) then
			if !table.HasValue(except, v:GetPos()) then
				v:Remove()
			end
		else
			if v:GetPos() != except then
				v:Remove()
			end
		end
	end
end

function GM:RemoveSurvivalEntities()
	if !cvar_medkit:GetBool() then
		for k, v in pairs(ents.FindByClass("weapon_healthkit")) do
			v:Remove()
		end
	end
end

function GM:ReviveDeadPlayers(pos, ang, weptable)
	for k, v in pairs(team.GetPlayers(TEAM_COOP)) do
		if v:IsDeadInSurvival() then
			v.KilledByFall = nil
			hook.Call("PlayerLoadout", GAMEMODE, v)
			v:Spawn()
			local vecrand = VectorRand() * 96
			vecrand[3] = 0
			local tr = util.TraceHull({
				start = pos,
				endpos = pos + vecrand,
				filter = v,
				mask = MASK_PLAYERSOLID_BRUSHONLY,
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 72)
			})
			local spawnPos = tr.HitPos
			local tr1 = util.TraceLine({
				start = spawnPos,
				endpos = spawnPos - Vector(0,0,64),
				filter = v,
				mask = MASK_PLAYERSOLID_BRUSHONLY
			})
			if !tr1.Hit then
				spawnPos = tr.StartPos
			end
			local findTrig = ents.FindInBox(tr1.StartPos, tr1.HitPos)
			for _, ent in pairs(findTrig) do
				if ent:GetClass() == "trigger_hurt" then
					spawnPos = tr.StartPos
				end
			end
			v:TeleportToCheckpoint(spawnPos, ang, weptable)
			if v.wboxEnt and IsValid(v.wboxEnt) then
				v.wboxEnt:SetOwner(NULL)
			end
		end
	end
end

function GM:Checkpoint(dest, ang, telePos, ply, weptable, delay)
	self:RemovePreviousCheckpoint()
	-- some shitty code below
	if delay then
		timer.Simple(delay, function()
			if istable(telePos) then
				for k, v in pairs(telePos) do
					self:CreateTeleport(v, dest, ang, weptable)
				end
			else
				self:CreateTeleport(telePos, dest, ang, weptable)
			end
		end)
	else
		if istable(telePos) then
			for k, v in pairs(telePos) do
				self:CreateTeleport(v, dest, ang, weptable)
			end
		else
			self:CreateTeleport(telePos, dest, ang, weptable)
		end
	end
	if IsValid(ply) and ply:IsPlayer() then
		ChatMessage(ply:Nick().." ".."#game_checkpointpl", 2)
	else
		ChatMessage("#game_checkpoint", 2)
	end
	
	self:SendTeleportHint()
	
	if self:GetSurvivalMode() then
		timer.Simple(1, function()
			if self:GetActivePlayersNumber() > 0 then
				self:ReviveDeadPlayers(dest, ang, weptable)
			end
		end)
	end
	
	LAST_CHECKPOINT = {Pos = dest, Ang = ang, Weptable = weptable}
	net.Start("LastCheckpointPos")
	net.WriteVector(dest)
	net.Broadcast()
	
	for k, v in pairs(self:GetActivePlayersTable()) do
		--print(v, dest:Distance(v:GetPos()))
		if v:GetScore() >= PRICE_LAST_CHECKPOINT and dest:Distance(v:GetPos()) > LAST_CHECKPOINT_MINDISTANCE then
			v:SendScreenHint(5)
			v.CanTeleportTime = CurTime() + 15
			v:SendLua("LocalPlayer().CanTeleportTime = CurTime() + 15")
		end
	end
	
	hook.Run("OnCheckpoint", dest, ang, ply, weptable)
end

function GM:SendTeleportHint(ply)
	local teleTable = {} 
	for k, v in pairs(ents.FindByClass("hl1_teleport")) do
		table.insert(teleTable, v:GetPos())
	end
	net.Start("ShowTeleportHint")
	net.WriteTable(teleTable)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

function GM:CreateCheckpointTrigger(mins, maxs, dest, destang, telePos, weptable, passfunc)
	local cpTrig = ents.Create("hl1_trigger_checkpoint")
	if IsValid(cpTrig) then
		cpTrig:SetCheckpointData(dest, destang, telePos, weptable)
		if passfunc then
			cpTrig.PassFunction = passfunc
		end
		cpTrig:Spawn()
		cpTrig:SetCollisionBoundsWS(mins, maxs)
		return cpTrig
	end
end

function GM:PlayerHasFinishedMap(ply)
	if cvars.Bool("sv_cheats") or self:GetCrackMode() then return end
	local fTime = CurTime() - GetGlobalFloat("SpeedrunModeTime")
	if fTime > 0 and !ply.HasFinishedMap then
		ply.HasFinishedMap = true
		local Time = string.FormattedTime(fTime, "%02i:%02i.%02i")
		local bestTime = nil
		
		local datafile = "hl1_coop/map_records_"..game.GetMap()..".txt"
		local data = file.Read(datafile)
		if data then
			self.MapRecords = util.JSONToTable(data)
		end
		
		if !self.MapRecords then
			self.MapRecords = {}
		end
		
		if self.MapRecords then
			local plyid = ply:SteamID64()
			for k, v in pairs(self.MapRecords) do
				if v.steamid == plyid then
					if v.maptime < fTime then
						bestTime = v.maptime
					else
						table.remove(self.MapRecords, k)
					end
				end
			end
			if !bestTime then
				table.insert(self.MapRecords, {nick = ply:Nick(), steamid = plyid, maptime = fTime})
			end
			--PrintTable(self.MapRecords)
			file.CreateDir("hl1_coop")
			file.Write(datafile, util.TableToJSON(self.MapRecords))
			
			--[[net.Start("ShowMapRecords")
			net.WriteTable(self.MapRecords)
			net.Send(ply)]]--
		end
		
		bestTime = bestTime and ", personal best: "..string.FormattedTime(bestTime, "%02i:%02i.%02i") or ""
		ChatMessage(ply:Nick().." has finished the map in "..Time..bestTime)
	end
end

function GM:SendCaption(sentence, pos)
	if GetGlobalBool("FirstLoad") then return end
	local startWith = string.StartWith
	if startWith(sentence, "!") or startWith(sentence, "NPC_Scientist") or startWith(sentence, "barney/") or startWith(sentence, "scientist/") or startWith(sentence, "hgrunt/") or startWith(sentence, "nihilanth/") then
		net.Start("ShowCaption")
		net.WriteString(sentence)
		net.SendPAS(pos)
		--print(sentence)
	end
end

function GM:AcceptInput(ent, input, activator, caller, value)
	if IsValid(caller) and caller:GetClass() == "trigger_once" then
		hook.Run("CreateMapEventCheckpoints", ent, activator, input, caller)
		--print(ent, ent:GetName(), input, activator, caller, caller:GetName())
	end
	if ent:GetClass() == "env_explosion" and input == "Explode" and IsValid(activator) and activator:IsPlayer() and !ent.ActivatedByTrigger and (!IsValid(caller) or !caller:IsTrigger()) then
		ent:SetOwner(activator)
	end
	hook.Run("OperateMapEvents", ent, input, caller, activator)
	--print(ent, ent:GetName(), input, activator, caller)
	if ent:GetClass() == "ambient_generic" and input == "PlaySound" then
		local message = ent:GetSaveTable().message
		--print(message, ent, ent:GetName())
		self:SendCaption(message, ent:GetPos())
	end
	if ent:GetClass() == "scripted_sentence" and input == "BeginSentence" then
		local active = ent:GetSaveTable().m_active
		if active then
			local sndpos = ent:GetPos()
			local sentence = ent:GetKeyValues().sentence
			local entityname = ent:GetKeyValues().entity
			local speaker = ents.FindByName(entityname)[1]
			if IsValid(speaker) and speaker:Health() > 0 then
				sndpos = speaker:WorldSpaceCenter()
			elseif !string.StartWith(entityname, "monster_") then
				active = false
			end
			--print(ent, ent:GetName(), sentence, speaker, entityname)
			--[[if string.StartWith(ent:GetName(), "globalspeaker") then
				local sentenceName = string.Replace(sentence, "!", "")
				for k, v in pairs(ents.FindByClass("speaker")) do
					EmitSentence(sentenceName, v:GetPos(), v:EntIndex(), CHAN_VOICE, .3, 0, 0, 100)
				end
				sentence = "!BMAS_"..sentenceName
			end]]--
			if active then
				self:SendCaption(sentence, sndpos)
			end
		end
	end
	if self:GetCrackMode() then
		hook.Run("CrackModeAcceptInput", ent, input, caller, activator)
	end
end

function GM:RestartMap()
	hook.Run("PreMapRestart")
	self:PlayGlobalMusic("") -- stops the music
	game.CleanUpMap()
	self:InitPostEntity(true)
	self:SetGlobalFloat("WaitTime", 0)
	hook.Run("OnMapRestart")
	if GetGlobalBool("EndTitles") then
		self:SetGlobalBool("EndTitles", false)
	end
	
	hook.Run("CheckForShittyAddons")
end

function GM:GetFallDamage(ply, flFallSpeed)
	local skill = self:GetSkillLevel() > 3 and self:GetSkillLevel() or 0
	local PLAYER_FATAL_FALL_SPEED = 1024
	local PLAYER_MAX_SAFE_FALL_SPEED = 580
	local DAMAGE_FOR_FALL_SPEED = 100 / ( PLAYER_FATAL_FALL_SPEED - PLAYER_MAX_SAFE_FALL_SPEED ) + skill
	
	return (flFallSpeed - PLAYER_MAX_SAFE_FALL_SPEED) * DAMAGE_FOR_FALL_SPEED
end

function GM:PlayerInitialSpawn(ply)
	if GetGlobalBool("FirstLoad") and ply:Team() != TEAM_COOP then
		ply:SetTeam(TEAM_UNASSIGNED)
		--self:PlayerSpawnAsSpectator(ply)
	
		if self.ConnectingPlayers then
			net.Start("SendConnectingPlayers")
			net.WriteTable(self.ConnectingPlayers)
			net.Send(ply)
		end
		return
	end
	ply.FirstSpawn = true
	ply:SetupMovementParams()
	ply:AllowFlashlight(true)
	ply:SetCustomCollisionCheck(true)
	hook.Call("PlayerLoadout", GAMEMODE, ply, false)
	ply:SetTeam(TEAM_COOP)
	
	if GetGlobalBool("FirstWaiting") then
		timer.Simple(0, function()
			if IsValid(ply) then
				ply:Freeze(true)
			end
		end)
	end
	
	if !GetGlobalBool("FirstLoad") and self.TransitionMapName == game.GetMap() then
		if self.LastPlayersTable then
			for k, v in pairs(self.LastPlayersTable) do
				if v.id == ply:UserID() and v.steamid == ply:SteamID64() then
					if !ply.SpawnedAsSpectator and v.spec then
						ply:SetTeam(TEAM_SPECTATOR)
						self:PlayerSpawnAsSpectator(ply)
						ply.SpawnedAsSpectator = true
						v.spec = false
						return
					end
					if v.alive then
						timer.Simple(.1, function()
							if IsValid(ply) then
								if v.weptable then
									for wepclass, w in pairs(v.weptable) do
										if ply:HasWeapon(wepclass) then
											if w.ammotype then
												ply:SetAmmo(w.ammocount, w.ammotype)
											end
											if w.ammotypeS then
												ply:SetAmmo(w.ammocountS, w.ammotypeS)
											end
											if w.clip then
												local weapon = ply:GetWeapon(wepclass)
												if IsValid(weapon) then
													weapon:SetClip1(w.clip)
												end
											end
										end
									end
								end
								if v.hp > 0 then ply:SetHealth(v.hp) end
								ply:SetArmor(v.armor)
								if v.wep then
									ply:SelectWeapon(v.wep)
								end
							end
						end)
					end
					return
				end
			end
		end
	end
	if self:IsCoop() and !ply:IsBot() and !ply.SpawnedAsSpectator and ply:GetNWInt("Status") == 0 then
		ply:SetTeam(TEAM_SPECTATOR)
		self:PlayerSpawnAsSpectator(ply)
		ply.SpawnedAsSpectator = true
	end
end

function GM:PlayerSpawnAsSpectator(ply, noteam)
	if ply:Team() == TEAM_COOP then
		ply:DropWeaponBox(true)
		if ply:IsFrozen() then
			ply:Freeze(false)
		end
	end
	ply:SetViewEntity()
	self:StopPlayerChase(ply)
	ply:KillSilent()
	ply:StripWeapons()
	ply.DeathEnt = nil
	ply.DeathPos = nil
	ply.DeathAng = nil
	ply.DeathDuck = nil
	ply.HasFinishedMap = nil
	ply:SetWaitBool(false)
	if ply.wboxEnt and IsValid(ply.wboxEnt) then
		ply.wboxEnt:SetOwner(NULL)
	end

	if !noteam then
		local ent = ents.FindByClass("point_viewcontrol")
		ent = ent[math.random(1, #ent)]
		if IsValid(ent) then
			ply:SetPos(ent:GetPos())
			ply:SetEyeAngles(ent:GetAngles())
		end

		if ply:Team() != TEAM_UNASSIGNED then
			ply:SetTeam(TEAM_SPECTATOR)
		end
		if !IsValid(ply:GetObserverTarget()) then
			ply:SetObserverMode(OBS_MODE_FIXED)
		end
		local ragdoll = ply:GetRagdollEntity()
		if IsValid(ragdoll) then
			ragdoll:Remove()
		end
		
		hook.Run("VotePlayerJoinedSpectators", ply)
	end
end

function GM:PlayerSpawn(ply)
	if GetGlobalBool("FirstWaiting") then
		ply:Freeze(true)
	end

	ply:SetViewEntity()
	if ply:Team() != TEAM_COOP then
		self:PlayerSpawnAsSpectator(ply)
		return
	end

	if !self:GetSurvivalMode() then
		if ply.DeathEnt and IsValid(ply.DeathEnt) then
			ply:SetPos(ply.DeathEnt:GetPos() + ply.DeathPos)
			ply:SetEyeAngles(ply.DeathAng)
		elseif ply.DeathPos and ply.DeathAng then
			ply:SetPos(ply.DeathPos)
			ply:SetEyeAngles(ply.DeathAng)
		end
		if ply.DeathDuck then
			ply:ConCommand("+duck")
			timer.Simple(.1, function()
				ply:ConCommand("-duck")
			end)
		end
	end
	
	hook.Run("OnPlayerSpawn", ply)

	ply:UnSpectate()
	ply:SetupMovementParams()
	hook.Call("PlayerSetModel", GAMEMODE, ply)
	local teamcol = team.GetColor(ply:Team())
	ply:SetPlayerColor(Vector(teamcol.r / 255, teamcol.g / 255, teamcol.b / 255))
	ply:SetupHands()
	
	if !ply.FirstSpawn and !self:GetSurvivalMode() then
		ply.SpawnProtectionTime = CurTime() + 2
		ply:SendLua("LocalPlayer().SpawnProtectionTime = CurTime() + 2")
	end
	ply.FirstSpawn = false
	
	timer.Simple(1, function()
		if ply:IsStuck() then
			ply:Unstuck()
		end
	end)
	
	self:SendTeleportHint(ply)
	
	ply.DiedInSurvival = nil
end

function GM:PlayerTick(ply, mv)
	if GetGlobalBool("FirstLoad") and ply:GetNWInt("Status") == PLAYER_NOTREADY and !ply:IsListenServerHost() then
		if ply.afkTime then
			if player.GetCount() > 1 and UnreadyKickTimeoutStarted then
				if ply.afkTime == 0 then
					ply.afkTime = SysTime()
				elseif (SysTime() - ply.afkTime) >= self.KickUnreadyPlayerTime then
					//PrintMessage(HUD_PRINTTALK, ply:Nick().." has been kicked for unactivity")
					ply:Kick("Kicked due to unactivity")
				end
			else
				ply.afkTime = 0
			end
		end
	end
	
	if !game.SinglePlayer() and cvar_afktime:GetBool() and !GetGlobalBool("FirstLoad") and ply.afkTime and !ply:IsBot() then
		if GetGlobalBool("FirstWaiting") or GetGlobalBool("EndTitles") or player.GetCount() <= 1 or ply:Team() != TEAM_COOP or !ply:Alive() or ply:IsFlagSet(FL_ATCONTROLS) or ply:IsFrozen() or ply.afkTime == 0 or (self.NewChapterDelay and self.NewChapterDelay > CurTime()) then
			ply.afkTime = SysTime()
		end
		if SysTime() - ply.afkTime >= cvar_afktime:GetFloat() then
			self:PlayerSpawnAsSpectator(ply)
			ChatMessage(ply:Nick().." ".."#game_afkspec")
		end
	end
	
	if ply:Alive() and ply:WaterLevel() > 2 then
		if !ply.Drowning then ply.Drowning = CurTime() + 15 end
		if ply.Drowning and ply.Drowning < CurTime() then
			ply.Drowning = CurTime() + 1.5
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(5)
			dmginfo:SetDamageType(DMG_DROWN)
			dmginfo:SetAttacker(game.GetWorld())
			dmginfo:SetInflictor(game.GetWorld())
			dmginfo:SetDamageForce(Vector(0,0,10))
			ply:TakeDamageInfo(dmginfo)
			--[[if !ply.DrownDamage then ply.DrownDamage = 0 end
			if ply.DrownDamage then ply.DrownDamage = ply.DrownDamage + 5 end]]
		end
	elseif ply.Drowning then
		ply.Drowning = nil
	end
	--[[if ply:Alive() and ply:WaterLevel() < 2 and !ply.Drowning and ply.DrownDamage then
		if ply.DrownDamage > 0 then
			if !ply.DrownDamageTime then ply.DrownDamageTime = CurTime() + 3 end
			if ply.DrownDamageTime and ply.DrownDamageTime < CurTime() then
				ply.DrownDamageTime = CurTime() + 3
				local recoverHealth = 5
				if ply:Health() + recoverHealth > ply:GetMaxHealth() then
					recoverHealth = ply:GetMaxHealth() - ply:Health()
				end
				ply:SetHealth(ply:Health() + recoverHealth)
				ply.DrownDamage = ply.DrownDamage - recoverHealth
				if ply:Health() >= ply:GetMaxHealth() then
					ply.DrownDamage = nil
					ply.DrownDamageTime = nil
				end
			end
		end
	end]]
end

function GM:PostPlayerDeath(ply)
	if self:GetSurvivalMode() and ply:Team() == TEAM_COOP then
		local plyNum = self:GetActivePlayersNumber()
		if plyNum == 1 then
			timer.Simple(1, function()
				if self:GetActivePlayersNumber() == 1 then
					local lastPly = self:GetActivePlayersTable()[1]
					if IsValid(lastPly) and lastPly:Alive() then
						lastPly:SendScreenHintTop("#notify_onlyyouleft")
						for k, v in pairs(team.GetPlayers(TEAM_COOP)) do
							if !v:Alive() then
								v:SendScreenHintTop(lastPly:Nick().." ".."#notify_lastalive")
							end
						end
					end
				end
			end)
		end
		if plyNum == 0 then
			self:GameOver()
		end
	end
end

function GM:CreateNPCSpawner(class, pl, pos, ang, radius, effect)
	local ent = ents.Create("hl1_monster_maker")
	if IsValid(ent) then
		ent:SetNPC(class)
		ent:SetMinPlayers(pl)
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:SetRadius(radius)
		ent:EnableEffect(effect)
		ent:Spawn()
	end
end

function GM:GameStart()
	local delay = 3
	if cvar_speedrun:GetBool() then
		self:SetSpeedrunMode(true, delay)
	end
	if cvar_survival:GetBool() then
		self:SetSurvivalMode(true)
	end
	if cvar_crack:GetBool() then
		self:SetCrackMode(true)
	end
	self:RestartMap()
	for k, pl in pairs(player.GetAll()) do
		if pl:Team() != TEAM_SPECTATOR then
			self:PlayerInitialSpawn(pl)
			pl:Spawn()
		end
		net.Start("HL1ChapterStart")
		net.WriteFloat(delay)
		net.Send(pl)
	end
	self.NewChapterDelay = CurTime() + delay
end

function GM:GameRestart()
	for k, v in pairs(player.GetAll()) do
		v.DeathEnt = nil
		v.DeathPos = nil
		v.DeathAng = nil
		v.DeathDuck = nil
		v.HasFinishedMap = nil
		v.KilledByFall = nil
		v.canTakeDamage = nil
		v.LastWeaponsTable = nil
		v:SetScore(0)
		v:SetFrags(0)
		v:SetDeaths(0)
		v:StripAmmo()
		v:StripWeapons()
		v:Freeze(false)
		v:SetWaitBool(false)
		v:SetLongJumpBool(false)
		v:ConCommand("-duck")
	end
	self:GameStart()
end

function GM:GameOver(skipfade, reason)
	for k, v in pairs(player.GetAll()) do
		v:Freeze(true)
	end
	if !skipfade then
		reason = reason or ""
		net.Start("HL1GameOver")
		net.WriteString(reason)
		net.Broadcast()
	end
	timer.Simple(4, function()
		self:GameRestart()
	end)
end	

cvars.AddChangeCallback("hl1_coop_speedrunmode", function(name, value_old, value_new)
	value_new = tonumber(value_new)
	if value_new == 1 then
		if !GetGlobalBool("FirstLoad") then
			GAMEMODE:GameRestart()
		end
	elseif value_new == 0 then
		GAMEMODE:SetSpeedrunMode(false)
	end
end)

function GM:SetSurvivalMode(b, t)
	if self.DisallowSurvivalMode then return end
	t = t or 30
	if b then
		if self:GetSurvivalMode() then
			self:SetGlobalBool("SurvivalMode", false)
		end
		PrintMessage(HUD_PRINTTALK, "Survival mode starts in "..t.." seconds")
		self.SurvivalModeTime = RealTime() + t
	else
		self:SetGlobalBool("SurvivalMode", false)
		self.SurvivalModeTime = nil
		PrintMessage(HUD_PRINTTALK, "Survival mode is disabled")
		self:RemoveSurvivalEntities()
	end
end

cvars.AddChangeCallback("hl1_coop_sv_survival", function(name, value_old, value_new)
	value_new = tonumber(value_new)
	if value_new == 1 then
		if !GetGlobalBool("FirstLoad") then
			GAMEMODE:SetSurvivalMode(true, 10)
		end
	elseif value_new == 0 then
		GAMEMODE:SetSurvivalMode(false)
	end
end)

function GM:ResetSpeedrunTimer(delay)
	delay = delay or 0
	if self:GetSpeedrunMode() then
		self:SetGlobalFloat("SpeedrunModeTime", CurTime() + delay)
	end
end

function GM:SetSpeedrunMode(b, t)
	t = t or 0
	if b then
		self:SetGlobalBool("SpeedrunMode", true)
		self:SetGlobalFloat("SpeedrunModeTime", CurTime() + t)
		PrintMessage(HUD_PRINTTALK, "Speedrun mode is enabled!")
	else
		self:SetGlobalBool("SpeedrunMode", false)
		PrintMessage(HUD_PRINTTALK, "Speedrun mode is disabled")
	end
end

cvars.AddChangeCallback("hl1_coop_crackmode", function(name, value_old, value_new)
	value_new = tonumber(value_new)
	if value_new == 1 then
		if !GetGlobalBool("FirstLoad") then
			GAMEMODE:GameRestart()
		end
	elseif value_new == 0 then
		GAMEMODE:SetCrackMode(false)
	end
end)

function GM:SetCrackMode(b)
	if b then
		self:SetGlobalBool("CrackMode", true)
		PrintMessage(HUD_PRINTTALK, "Crack mode is enabled!")
		if math.random(0, 100) == 0 then
			self:SetGlobalBool("ScreamLife", true)
			PrintMessage(HUD_PRINTTALK, "AAAAAAAAAAAAAAAAAAAAAAAAAAAHHHHH")
		end
	else
		self:SetGlobalBool("CrackMode", false)
		self:SetGlobalBool("ScreamLife", false)
		if self.LastPlayersTable then
			for k, v in pairs(self.LastPlayersTable) do
				v.weptable = nil
			end
		end
		PrintMessage(HUD_PRINTTALK, "Crack mode is disabled")
		if !GetGlobalBool("FirstLoad") then
			GAMEMODE:GameRestart()
		end
	end
end

concommand.Add("allready", function(ply)
	if IsValid(ply) and !ply:IsAdmin() then return end
	for k, v in pairs(player.GetAll()) do
		v:ConCommand("_hl1_coop_ready")
	end
end)

function GM:Think()
	-- checking if plys are ready
	if GetGlobalBool("FirstLoad") then
		if self.ConnectingPlayers and !self.ConnectingTimeout then
			self.ConnectingTimeout = CurTime() + 60
		end
		if self.ConnectingPlayers and #self.ConnectingPlayers == 0 or self.ConnectingTimeout and self.ConnectingTimeout <= CurTime() or !self.ConnectingPlayers then
			local allReady = true
			for k, v in pairs(player.GetAll()) do
				if !v:IsBot() and v:GetNWInt("Status") != PLAYER_READY then
					allReady = false
					break
				end
			end
			if player.GetCount() > 0 and allReady then
				self:SetGlobalBool("FirstLoad", false)
				self:GlobalTextMessageCenter("#game_starting", 1.75)
				self.SkipFirstWaiting = true
				net.Start("HL1ChapterPreStart")
				net.Broadcast()
				timer.Simple(2, function()
					if game.GetMap() == "hls01amrl" then
						-- ShowIntro
						net.Start("HL1GameIntro")
						net.Broadcast()
						timer.Simple(6, function()
							hook.Run("GameStart")
						end)
					else
						hook.Run("GameStart")
					end
				end)
			end
		end
	end
	
	if GetGlobalBool("FirstWaiting") then
		if self.ConnectingPlayers and (GetGlobalFloat("FirstWaitingTime") <= SysTime() or #self.ConnectingPlayers <= 0) then
			if self:GetActivePlayersNumber() > 0 then
				-- TODO: dont create timer if player count is 1
				if !timer.Exists("GameStartAfterWaiting") then
					timer.Create("GameStartAfterWaiting", 3, 1, function()
						local delay = 0
						if self:IsFirstMapInChapter() then
							delay = 3
						end
						if cvar_speedrun:GetBool() then
							self:SetSpeedrunMode(true, delay)
						end
						if cvar_survival:GetBool() then
							self:SetSurvivalMode(true)
						end
						if cvar_crack:GetBool() then
							self:SetCrackMode(true)
						end
						self:RestartMap()
						if self:IsFirstMapInChapter() then
							net.Start("HL1ChapterStart")
							net.WriteFloat(delay)
							net.Broadcast()
							self.NewChapterDelay = CurTime() + delay
						end
						for k, v in pairs(player.GetAll()) do
							v:Freeze(false)
						end
						self.ConnectingPlayers = nil
						self:SetGlobalBool("FirstWaiting", false)
					end)
				end
			else
				print("No players detected. Returning to Ready Screen.")
				hook.Run("ReturnToReadyScreen")
			end
		end
	end
	
	hook.Run("VoteThink")
	
	hook.Run("NPCThinkInit")
	
	if self.RestartTime and self.RestartTime <= RealTime() then
		self.RestartTime = nil
		if player.GetCount() == 0 then
			hook.Run("ReturnToReadyScreen")
		end
	end
	
	if self.SurvivalModeTime and self.SurvivalModeTime <= RealTime() then
		self.SurvivalModeTime = nil
		if self:GetActivePlayersNumber(true) > 0 then
			self:SetGlobalBool("SurvivalMode", true)
			PrintMessage(HUD_PRINTTALK, "Survival mode is enabled!")
			for k, v in pairs(team.GetPlayers(TEAM_COOP)) do
				if v:Alive() then
					v:Give("weapon_healthkit")
				end
			end
			hook.Run("CreateSurvivalEntities")
		else
			PrintMessage(HUD_PRINTTALK, "No (alive) players were detected. Trying again.")
			self:SetSurvivalMode(true)
		end
	end
end

function GM:SetGlobalBool(name, b)
	SetGlobalBool(name, b)
	-- sometimes it does not set on client, so we do this
	net.Start("SetGlobalBoolFix")
	net.WriteString(name)
	net.WriteBool(b)
	net.Broadcast()
end

function GM:SetGlobalFloat(name, fl)
	SetGlobalFloat(name, fl)
	net.Start("SetGlobalFloatFix")
	net.WriteString(name)
	net.WriteFloat(fl)
	net.Broadcast()
end
	
function GM:NPCThinkInit()
	if player.GetCount() > 1 then
		for _, npc in ipairs(ents.FindByClass("monster_*")) do
			if npc:IsNPC() then
				hook.Run("NPCThink", npc)
			end
		end
	end
end

function GM:NPCThink(npc)
	if (npc:GetClass() == "monster_scientist" or npc:GetClass() == "monster_barney") and npc:GetNPCState() == NPC_STATE_SCRIPT then
		local blockEnt = npc:GetBlockingEntity()
		if IsValid(blockEnt) and blockEnt:IsPlayer() then
			local tr = util.TraceHull({
				start = npc:GetPos(),
				endpos = npc:GetPos() + npc:GetForward() * 16,
				filter = npc,
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 72)
			})
			local trEnt = tr.Entity
			if IsValid(trEnt) and trEnt:IsPlayer() and trEnt:GetMoveType() == MOVETYPE_WALK then
				debugPrint(trEnt:GetName().." is blocking "..npc:GetClass().." at "..tostring(tr.HitPos))
				local dir = npc:GetRight()
				local tr_d = util.QuickTrace(trEnt:GetPos(), dir * 60, npc)
				if tr_d.Hit then
					dir = -dir
				end
				if trEnt:KeyDown(IN_USE) then
					trEnt:ConCommand("-use")
				end
				trEnt:SetLocalVelocity(dir * 500)
			end
		end
	end
	if GetConVarNumber("ai_use_think_optimizations") > 0 and !self.npcLagFixDisabled and GetConVarNumber("ai_ignoreplayers") <= 0 and !self.npcLagFixClassBlacklist[npc:GetClass()] and npc:GetNPCState() != NPC_STATE_SCRIPT and !IsValid(npc:GetEnemy()) then
		for _, pl in ipairs(player.GetAll()) do
			if pl:Alive() and npc:Disposition(pl) == D_HT and pl:Visible(npc) then
				npc:SetEnemy(pl)
				if IsValid(npc:GetEnemy()) and (!self.npcLagFixBlacklist or !self.npcLagFixBlacklist[npc:GetName()]) then
					npc:SetSaveValue("m_IdealNPCState", 3)
				end
			end
		end
	end
	
	if self:GetCrackMode() then
		hook.Run("CrackModeNPCThink", npc)
	end
end

function GM:CreateViewPointEntity(pos, ang)
	local ent = ents.Create("point_viewcontrol")
	if IsValid(ent) then
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()
	end
end

function GM:ReturnToReadyScreen()
	self:SetGlobalBool("FirstWaiting", false)
	self:SetGlobalBool("FirstLoad", true)
	if cvar_crack:GetBool() then
		cvar_crack:SetBool(false)
	end
	if player.GetCount() > 0 then
		for k, v in pairs(player.GetAll()) do
			v.afkTime = 0
			v:SetNWInt("Status", PLAYER_NOTREADY)
			v:SetTeam(TEAM_UNASSIGNED)
			self:PlayerSpawnAsSpectator(v)
		end
		timer.Simple(.1, function()
			net.Start("HL1StartMenu")
			net.Broadcast()
		end)
	end
end

GM.npcLagFixClassBlacklist = {
	["monster_barnacle"] = true,
	["monster_barney_dead"] = true,
	["monster_cockroach"] = true,
	["monster_flyer"] = true,
	["monster_flyer_flock"] = true,
	["monster_furniture"] = true,
	["monster_generic"] = true,
	["monster_gman"] = true,
	["monster_hevsuit_dead"] = true,
	["monster_hgrunt_dead"] = true,
	["monster_leech"] = true,
	["monster_scientist"] = true,
	["monster_scientist_dead"] = true,
	["monster_sitting_scientist"] = true,
	["monster_snark"] = true,
	["monster_nihilanth"] = true,
}

GM.NPCHealthMultiplierBlacklist = {
	["aitesthull"] = true,
	["controller_head_ball"] = true,
	["cycler"] = true,
	["monster_barnacle"] = true,
	["monster_barney_dead"] = true,
	["monster_cockroach"] = true,
	["monster_flyer"] = true,
	["monster_flyer_flock"] = true,
	["monster_furniture"] = true,
	["monster_generic"] = true,
	["monster_gman"] = true,
	["monster_hevsuit_dead"] = true,
	["monster_hgrunt_dead"] = true,
	["monster_leech"] = true,
	["monster_scientist"] = true,
	["monster_scientist_dead"] = true,
	["monster_sitting_scientist"] = true,
	["monster_snark"] = true,
	["hornet"] = true,
	["controller_energy_ball"] = true,
	["nihilanth_energy_ball"] = true,
	["monster_nihilanth"] = true,
}

function GM:NPCHealthMultiplier()
	local plyNum = self:GetActivePlayersNumber()
	if cvar_gainnpchp:GetBool() and plyNum > 2 then
		local div = 2.7
		local maxValue = 4
		return math.Clamp(math.Round(plyNum / div, 1), 1, maxValue)
	end
	return 1
end

function GM:ShowSpare1(ply)
	if !ply.thirdpersonEnabled then
		ply.thirdpersonEnabled = true
		ply:SendLua("LocalPlayer().thirdpersonEnabled = true")
	else
		ply.thirdpersonEnabled = false
		ply:SendLua("LocalPlayer().thirdpersonEnabled = false")
	end
end

function GM:ShowSpare2(ply)
	ply:SendLua("GAMEMODE:OpenQuickMenu()")
end

function GM:PlayerDroppedWeapon(ply, wep)
	if IsValid(ply) and ply:IsPlayer() and ply:Alive() then
		if wep:Clip1() == -1 then
			local ammotype = wep:GetPrimaryAmmoType()
			wep.DroppedAmmo = ply:GetAmmoCount(ammotype)
			ply:SetAmmo(0, ammotype)
		end
		wep.WasDropped = true
		if !ply.DroppedWeapons then
			ply.DroppedWeapons = {}
		end
		if ply.DroppedWeapons then
			for k, v in pairs(ply.DroppedWeapons) do
				if !IsEntity(v[1]) or !IsValid(v[1]) or v[1] == wep then
					ply.DroppedWeapons[k] = nil
				end
			end
			table.insert(ply.DroppedWeapons, {wep, wep.EquipTime})
		end
	end
end

local throwableWeapons = {["weapon_handgrenade"] = true, ["weapon_satchel"] = true, ["weapon_tripmine"] = true, ["weapon_snark"] = true}

function GM:PlayerCanPickupWeapon(ply, wep)
	if ply:HasWeapon(wep:GetClass()) then
		local ammotype = wep:GetPrimaryAmmoType()
		if ammotype == -1 then
			return false
		end
		if self:IsCoop() and !throwableWeapons[wep:GetClass()] and wep.rRespawnable then return false end
		if wep:IsScripted() then
			local maxAmmoPrimary = wep.Primary.MaxAmmo
			local maxAmmoMul = ply.HL1MaxAmmoMultiplier
			if maxAmmoMul then
				if maxAmmoPrimary then
					maxAmmoPrimary = math.Round(maxAmmoPrimary * maxAmmoMul)
				end
			end
			if maxAmmoPrimary and ply:GetAmmoCount(ammotype) >= maxAmmoPrimary then
				return false
			end
		end
		--[[if wep.Secondary.MaxAmmo and ply:GetAmmoCount(wep:GetSecondaryAmmoType()) >= wep.Secondary.MaxAmmo then
			return false
		end]]--
		if wep.DroppedAmmo then
			if wep.DroppedAmmo <= 0 then
				return false
			end
			ply:SetAmmo(ply:GetAmmoCount(ammotype) - wep.Primary.DefaultClip + wep.DroppedAmmo, ammotype)
		end
	end
	return true
end

function GM:WeaponEquip(wep, ply)
	local ammotype = wep:GetPrimaryAmmoType()
	if wep.DroppedAmmo then
		local dropammo = wep.DroppedAmmo
		local ammo = dropammo - wep.Primary.DefaultClip
		if ammo > 0 then
			ply:GiveAmmo(ammo, ammotype, true)
		end
		local ammocount = ply:GetAmmoCount(ammotype)
		if dropammo <= 0 then
			timer.Simple(0, function()
				if IsValid(ply) then
					ply:SetAmmo(ammocount, ammotype)
				end
			end)
		elseif dropammo < wep.Primary.DefaultClip and ammocount < dropammo then
			timer.Simple(0, function()
				if IsValid(ply) then
					ply:SetAmmo(dropammo, ammotype)
				end
			end)			
		end
		wep.DroppedAmmo = nil
	end
	if !wep.WasDropped and ammotype != -1 then
		wep.EquipTime = CurTime()
		if ply.DroppedWeapons then
			local preventDupe
			for k, v in pairs(ply.DroppedWeapons) do
				local dropwep, equiptime = v[1], v[2]
				if IsValid(dropwep) and dropwep:GetClass() == wep:GetClass() and equiptime + 15 > CurTime() then
					preventDupe = true
				end
			end
			if preventDupe then
				wep:SetClip1(0)
			end
		end
	end
end

function GM:PlayerSwitchFlashlight(ply, enabled)
	return ply:IsSuitEquipped()
end

function GM:PlayerShouldTakeDamage(ply, attacker)
	if !cvars.Bool("hl1_coop_friendlyfire") and attacker:IsPlayer() and attacker:Team() == ply:Team() and attacker != ply then
		return false
	end
	return true
end

function GM:CanPlayerSuicide(ply)
	return ply:Team() != TEAM_SPECTATOR and ply:Team() != TEAM_UNASSIGNED and !ply:IsFlagSet(FL_GODMODE)
end

function GM:PlayerDeathThink(pl)
	if pl:Team() == TEAM_SPECTATOR or pl:Team() == TEAM_UNASSIGNED then
		return
	end

	if ( pl.NextSpawnTime && pl.NextSpawnTime > CurTime() ) then return end

	if ( pl:KeyPressed( IN_ATTACK ) || pl:KeyPressed( IN_ATTACK2 ) || pl:KeyPressed( IN_JUMP ) ) then

		if self:GetSurvivalMode() then
			if !pl.DiedInSurvival then
				pl:TextMessageCenter("#game_surv_norespawns", 3)
				if pl.wboxEnt and IsValid(pl.wboxEnt) then
					pl.wboxEnt:SetOwner(NULL)
					pl.wboxEnt = nil
				end
				self:StopPlayerChase(pl)
				pl.DiedInSurvival = true
			end
		else
			if pl:IsBot() then
				pl:Spawn()
			else
				if GetGlobalBool("DisablePlayerRespawn") then
					pl:Spectate(OBS_MODE_ROAMING)
				else
					if pl.KilledByFall or noRespawnOptions then
						pl:ConCommand("_hl1_coop_respawn 2")
					else
						net.Start("HL1DeathMenu")
						net.Send(pl)
					end
				end
			end
		end

	end

end

function GM:StorePlayerAmmunition(ply)
	local weptable = ply:GetWeapons()
	if table.Count(weptable) > 0 then
		local weapons = {}
		for k, v in pairs(weptable) do
			if v:IsScripted() then
				local ammotype = v:GetPrimaryAmmoType()
				local ammotypeS = v:GetSecondaryAmmoType()
				table.insert(weapons, {v:GetClass(), ammotype, ply:GetAmmoCount(ammotype), ammotypeS, ply:GetAmmoCount(ammotypeS), v:Clip1()})
			end
		end
		return weapons
	end
end

function GM:StorePlayerAmmunitionNew(ply)
	local weptable = ply:GetWeapons()
	if weptable then
		local weapons = {}
		for k, v in pairs(weptable) do
			local clip = v:Clip1()
			clip = clip > -1 and clip or nil
			local ammotype = v:GetPrimaryAmmoType()
			ammotype = ammotype > -1 and ammotype or nil
			local ammotypeS = v:GetSecondaryAmmoType()
			ammotypeS = ammotypeS > -1 and ammotypeS or nil
			local ammocount = ammotype and ply:GetAmmoCount(ammotype)
			local ammocountS = ammotypeS and ply:GetAmmoCount(ammotypeS)
			
			local wepclass = v:GetClass()
			if throwableWeapons[wepclass] and ammocount and ammocount > 0 or !throwableWeapons[wepclass] then
				weapons[wepclass] = {ammotype = ammotype, ammotypeS = ammotypeS, clip = clip, ammocount = ammocount, ammocountS = ammocountS}
			end
		end
		return weapons
	end
end

function GM:GetPlayerAmmo(ply)
	local plyam = self:StorePlayerAmmunitionNew(ply)
	if plyam then
		local ammo = {}
		for wepclass, v in pairs(plyam) do
			if v.ammotype then
				ammo[game.GetAmmoName(v.ammotype)] = ply:GetAmmoCount(v.ammotype)
			end
			if v.ammotypeS then
				ammo[game.GetAmmoName(v.ammotypeS)] = ply:GetAmmoCount(v.ammotypeS)
			end
		end
		return ammo
	end
end

GibSound = Sound("common/bodysplat.wav")

function GM:GibEntity(ent, amount, force)
	amount = amount or 16
	force = force or Vector()
	net.Start("GibPlayer")
	net.WriteVector(ent:GetPos())
	net.WriteVector(force)
	net.WriteUInt(amount, 8)
	net.Broadcast()
	ent:EmitSound(GibSound, 85, math.random(90, 110))
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
	if cvar_plygib:GetBool() and (ply:Health() <= -40 or dmginfo:IsDamageType(DMG_ALWAYSGIB)) then
		self:GibEntity(ply, 40, dmginfo:GetDamageForce() / 128)
	else
		ply:CreateRagdoll()
	end
	
	ply:AddDeaths( 1 )
	
	if ( attacker:IsValid() && attacker:IsPlayer() ) then
	
		if attacker == ply or attacker:Team() == ply:Team() then			
			attacker:AddScore(-100)
		else
			attacker:AddFrags(1)
		end
	
	end

end

local movingEntRespawnTable = {
	["func_door"] = true,
	["func_platrot"] = true,
	["func_train"] = true,
	["func_tracktrain"] = true,
	["func_trackchange"] = true,
	["func_rotating"] = true,
}

function GM:PlayerDeath(victim, inflictor, attacker)
	if !IsValid(victim) then return end

	victim.NextSpawnTime = CurTime() + 1
	
	if IsValid(attacker) and attacker:GetClass() == "trigger_hurt" then attacker = victim end
	
	if !IsValid(inflictor) and IsValid(attacker) then
		inflictor = attacker
	end
	
	-- Convert the inflictor to the weapon that they're holding if we can.
	-- This can be right or wrong with NPCs since combine can be holding a
	-- pistol but kill you by hitting you with their arm.
	if IsValid(inflictor) and inflictor == attacker and (inflictor:IsPlayer() or inflictor:IsNPC()) then
		inflictor = inflictor:GetActiveWeapon()
		if !IsValid(inflictor) then inflictor = attacker end
	end
	
	hook.Run("OnPlayerDeath", victim, inflictor, attacker)
	
	if victim.KilledByFall then
		if !self.DisableFullRespawn then
			victim.LastWeaponsTable = self:StorePlayerAmmunition(victim)
		end
	else
		local ground = victim:GetGroundEntity()
		if !IsValid(ground) then
			local tr = util.QuickTrace(victim:GetPos(), Vector(0,0,-48), victim)
			ground = tr.Entity
		end
		if IsValid(ground) and movingEntRespawnTable[ground:GetClass()] then
			victim.DeathEnt = ground
			victim.DeathPos = victim:GetPos() - ground:GetPos()
		else
			victim.DeathEnt = nil
			victim.DeathPos = victim:GetPos()
		end
		
		victim.DeathAng = victim:EyeAngles()
		victim.DeathDuck = victim:Crouching()
		
		victim:DropWeaponBox()
	end
	
	if attacker == victim then
		net.Start( "PlayerKilledSelf" )
			net.WriteEntity( victim )
		net.Broadcast()

		MsgAll( attacker:Nick() .. " suicided!\n" )
	
		return
	end

	if attacker:IsPlayer() then

		net.Start( "PlayerKilledByPlayer" )

			net.WriteEntity( victim )
			net.WriteString( inflictor:GetClass() )
			net.WriteEntity( attacker )

		net.Broadcast()

		MsgAll( attacker:Nick() .. " killed " .. victim:Nick() .. " using " .. inflictor:GetClass() .. "\n" )

		return
	end

	net.Start( "PlayerKilled" )

		net.WriteEntity( victim )
		net.WriteString( inflictor:GetClass() )
		net.WriteString( attacker:GetClass() )

	net.Broadcast()

	MsgAll( victim:Nick() .. " was killed by " .. attacker:GetClass() .. "\n" )
end

function GM:PlayClientSound(snd, ply)
	net.Start("PlayClientSound")
	net.WriteString(snd)
	net.Send(ply)
end

function GM:PlayGlobalSound(snd)
	net.Start("PlayClientSound")
	net.WriteString(snd)
	net.Broadcast()
end

function GM:PlayGlobalMusic(snd)
	net.Start("HL1Music")
	net.WriteString(snd)
	net.Broadcast()
end

concommand.Add("_hl1_coop_ready", function(ply, cmd, args, argStr)
	if !ply or !IsValid(ply) or !GetGlobalBool("FirstLoad") or ply:GetNWInt("Status") == PLAYER_READY then return end
	ply:SetNWInt("Status", PLAYER_READY)
	GAMEMODE:PlayGlobalSound("buttons/button14.wav")
	
	if !UnreadyKickTimeoutStarted then
		UnreadyKickTimeoutStarted = true
	end
end)

function GM:RespawnFunc(ply, rtype)
	if !ply or !IsValid(ply) or ply:Alive() or self:GetSurvivalMode() then return end
	if rtype == 1 then
		if !ply.KilledByFall then
			local respawnPrice = PRICE_RESPAWN_HERE
			if ply:GetScore() >= respawnPrice then
				ply:AddScore(-respawnPrice)
				ply:Spawn()
				ply:SetHealth(25)
				hook.Call("PlayerLoadout", self, ply, true) -- crowbar & pistol		
			else
				ply:PrintMessage(HUD_PRINTCONSOLE, "Not enough score!")
			end
		end
	else
		ply:ResetVars()
		if rtype == 3 and !self.DisableFullRespawn then
			local respawnPrice = PRICE_RESPAWN_FULL
			if ply:GetScore() >= respawnPrice then
				ply:AddScore(-respawnPrice)
				hook.Call("PlayerLoadout", self, ply)
			else
				ply:PrintMessage(HUD_PRINTCONSOLE, "Not enough score!")
				return
			end
		else
			hook.Call("PlayerLoadout", self, ply, true) -- crowbar & pistol
		end
		ply:Spawn()
		if IsValid(ply.wboxEnt) then
			ply.wboxEnt:SetOwner(NULL)
			ply.wboxEnt = nil
		end
	end
end

concommand.Add("_hl1_coop_respawn", function(ply, cmd, args, argStr)
	local arg = tonumber(args[1])
	GAMEMODE:RespawnFunc(ply, arg)
end)

/*concommand.Add("_hl1_coop_getmystuffback", function(ply, cmd)
	if !ply or !IsValid(ply) or !ply:Alive() or GAMEMODE:GetSpeedrunMode() then return end
	if ply.wboxEnt and IsValid(ply.wboxEnt) then
		local price = PRICE_GETMYSTUFFBACK
		if ply:GetScore() >= price then
			ply.wboxEnt:SetPos(ply:GetPos())
			ply.wboxEnt = nil
			ply:AddScore(-price)	
		else
			ply:ChatMessage("Not enough score!")
		end
	else
		ply:ChatMessage("Your stuff has not been found")
	end
end)*/

function GM:PlayerLoadout(ply, light)
	if ply.LastWeaponsTable then
		for k, v in pairs(ply.LastWeaponsTable) do
			local wepclass, ammotype, ammocountP, ammotypeS, ammocountS, clip = v[1], v[2], v[3], v[4], v[5], v[6]
			ply:Give(wepclass)
			local wep = ply:GetWeapon(wepclass)
			if IsValid(wep) then
				if clip > -1 and wep.Primary.ClipSize > -1 then
					wep:SetClip1(clip)
				end
			end
		end
		ply.LastWeaponsTable = nil
		return
	end
	local t = self.StartingWeapons
	if (light or t == nil) and t != false then
		ply:Give("weapon_glock")
		ply:Give("weapon_crowbar")
		ply:GiveAmmo(17, "9mmRound", true)
		local add_weps = self.StartingWeaponsLight
		if add_weps then
			for k, v in pairs(add_weps) do
				ply:Give(v)
			end
		end
	elseif t then
		if istable(t) then
			for k, v in pairs(t) do
				ply:Give(v)
				local wep = ply:GetWeapon(v)
				if IsValid(wep) and wep:IsWeapon() then
					local amount = wep.Primary.DefaultClip
					if amount > 0 and wep.Primary.Ammo != "Hornet" then
						ply:GiveAmmo(amount, wep:GetPrimaryAmmoType(), true)
					end
				end
			end
		else
			ply:Give(t)
		end
		local ammo_t = self.StartingAmmo[game.GetMap()]
		if ammo_t then
			ply:GiveAmmo(ammo_t[1], ammo_t[2], true)
			--print(ammo_t[1], ammo_t[2])
		end
	end
	if self:GetSurvivalMode() or cvar_medkit:GetBool() and !self.DisallowSurvivalMode then
		ply:Give("weapon_healthkit")
	end
	if self:GetSurvivalMode() then
		local wepsSurv = self.StartingWeaponsSurvival
		if wepsSurv then
			if istable(wepsSurv) then
				for k, v in pairs(wepsSurv) do
					ply:Give(v)
				end
			else
				ply:Give(wepsSurv)
			end
		end
	end
	
	-- select best weapon	
	timer.Simple(.1, function()
		if IsValid(ply) then
			local weps = ply:GetWeapons()
			if weps then
				local bestweight = -10
				local selectedwep
				for k, v in pairs(ply:GetWeapons()) do
					if IsValid(v) and v:GetWeight() > bestweight and (v:Clip1() == -1 and v:Ammo1() > 0 or v:Clip1() > 0) then
						bestweight = v:GetWeight()
						selectedwep = v
					end
				end
				if IsValid(selectedwep) then
					ply:SelectWeapon(selectedwep:GetClass())
				end
			end
			
			-- trying to fix invisible/incorrect viewmodel
			--[[local actwep = ply:GetActiveWeapon()
			if IsValid(actwep) then
				local vm = ply:GetViewModel()
				local wepmodel = actwep:GetWeaponViewModel()
				if IsValid(vm) then
					if vm:GetModel() != wepmodel then
						vm:SetWeaponModel(wepmodel)
						actwep:SendWeaponAnim(ACT_VM_DRAW)
					end
				end
			end]]--
		end
	end)	
end

local sci_pmodels = {
	"models/player/hl1/scientist_einstien.mdl",
	"models/player/hl1/scientist_luther.mdl",
	"models/player/hl1/scientist_slick.mdl",
	"models/player/hl1/scientist_walter.mdl"
}

function GM:PlayerSetModel(ply)
	if cvars.Bool("hl1_coop_sv_custommodels") then
		local cl_playermodel = ply:GetInfo("hl1_coop_cl_playermodel")
		local modelname = player_manager.TranslatePlayerModel(cl_playermodel)
		util.PrecacheModel(modelname)
		ply:SetModel(modelname)
	else
		if ply:IsSuitEquipped() then
			ply:SetModel("models/player/hl1/helmet.mdl")
		else
			ply:SetModel(sci_pmodels[math.random(1, 4)])
		end
	end
end

function GM:PlayerSelectSpawn(pl, rand)
	if !IsTableOfEntitiesValid(self.SpawnPoints) or self.SpawnPoints and #self.SpawnPoints == 0 then
		local coopSPs = ents.FindByClass("info_player_coop")
		if #coopSPs > 0 then
			self.SpawnPoints = coopSPs
		else
			self.SpawnPoints = ents.FindByClass( "info_player_start" )
			self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_deathmatch" ) )
		end
	end
	
	--PrintTable(self.SpawnPoints)

	if !self:IsCoop() then
		for k, v in pairs( self.SpawnPoints ) do
			-- If any of the spawnpoints have a MASTER flag then only use that one.
			-- This is needed for single player maps.
			if ( v:HasSpawnFlags( 1 ) && hook.Call( "IsSpawnpointSuitable", GAMEMODE, pl, v, true ) ) then
				return v
			else
				return self.SpawnPoints[1]
			end
		end
	else
		if !rand then
			for k, v in pairs(self.SpawnPoints) do
				if self:IsSpawnpointSuitable(pl, v) then
					return v
				end
			end
		end
		return self.SpawnPoints[math.random(1, #self.SpawnPoints)]
	end

end

function GM:IsSpawnpointSuitable(pl, spawnpointent, bMakeSuitable)

	local Pos = spawnpointent:GetPos()

	-- Note that we're searching the default hull size here for a player in the way of our spawning.
	-- This seems pretty rough, seeing as our player's hull could be different.. but it should do the job
	-- (HL2DM kills everything within a 128 unit radius)
	local Ents = ents.FindInBox( Pos + Vector( -16, -16, 0 ), Pos + Vector( 16, 16, 64 ) )

	if ( pl:Team() == TEAM_SPECTATOR ) then return true end

	local Blockers = 0

	for k, v in pairs( Ents ) do
		if ( IsValid( v ) && v != pl && v:GetClass() == "player" && v:Alive() ) then

			Blockers = Blockers + 1

		end
	end

	if ( bMakeSuitable ) then return true end
	if ( Blockers > 0 ) then return false end
	return true

end

gameevent.Listen("player_connect")
hook.Add("player_connect", "ConnectionTableAdd", function(data)
	if data.bot != 1 then
		if !GAMEMODE.ConnectingPlayers then
			GAMEMODE.ConnectingPlayers = {}
		end
		if GAMEMODE.ConnectingPlayers then
			table.insert(GAMEMODE.ConnectingPlayers, data.userid)
			
			net.Start("SendConnectingPlayers")
			net.WriteTable(GAMEMODE.ConnectingPlayers)
			net.Broadcast()
		end
		--ChatMessage(data.name .. " ("..data.userid..") has connected to the server", 0)
	end
end)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "ConnectionTableRemove", function(data)
	if data.bot != 1 then
		if GAMEMODE.ConnectingPlayers and table.HasValue(GAMEMODE.ConnectingPlayers, data.userid) then
			table.RemoveByValue(GAMEMODE.ConnectingPlayers, data.userid)
			
			net.Start("SendConnectingPlayers")
			net.WriteTable(GAMEMODE.ConnectingPlayers)
			net.Broadcast()
		end
		--ChatMessage(data.name .. " ("..data.userid..") has left the server", 0)
	end
end)

function GM:AdjustNPCHealth(prevSkill)
	--local prevSkillTable = self:GetSkillTable(prevSkill)
	for _, npc in ipairs(ents.FindByClass("monster_*")) do
		if npc:IsNPC() and !self.NPCHealthMultiplierBlacklist[npc:GetClass()] then
			--local hpCvar = self.NPCHealthConVar[npc:GetClass()]
			--local maxHealth = hpCvar and cvars.Number(hpCvar) or npc:GetMaxHealth()
			local maxHealth = npc:GetMaxHealth()
			if maxHealth > 0 then
				local maxHealthMul = math.floor(maxHealth * self:NPCHealthMultiplier())
				if self.ImportantNPCs and (!self.ImportantHealthBlacklist or !self.ImportantHealthBlacklist[npc:GetName()]) then
					for k, v in pairs(self.ImportantNPCs) do
						if npc:GetName() == v then
							maxHealthMul = maxHealthMul * IMPORTANT_NPC_HP_SCALE
						end
					end
				end
				local hp = npc:Health()
				if hp > maxHealthMul then
					debugPrint("lowering npc hp:", npc, "hp: "..hp, "max: "..maxHealthMul)
					npc:SetHealth(maxHealthMul)
				end
			end
		end
	end
	for k, v in pairs(ents.FindByClass("info_bigmomma")) do
		local healthkeyDef = v.healthDefault
		if healthkeyDef then
			v:SetKeyValue("health", healthkeyDef * cvars.Number("sk_bigmomma_health_factor", 1) * self:NPCHealthMultiplier())
		end
	end
end

function GM:PlayerDisconnected(ply)
	local name = ply:Nick()
	local id = ply:UserID()
	
	ply:DropWeaponBox()
	if self:GetSurvivalMode() and ply:Team() == TEAM_COOP and ply:Alive() and self:GetActivePlayersNumber() <= 1 and player.GetCount() > 1 then
		self:GameOver()
	end
	
	timer.Simple(1, function()
		self:AdjustNPCHealth()
	end)
	
	if self:IsCoop() and !GetGlobalBool("FirstLoad") and player.GetCount() < 2 then
		local t = self.ReturnToReadyScreenTime
		self.RestartTime = RealTime() + t
		print("No players detected. Returning to Ready Screen in "..t.." seconds.")
	end
	
	self:StopPlayerChase(ply)
		
	hook.Run("VotePlayerDisconnected", ply)
end

function GM:StopPlayerChase(ply)	
	for k, v in pairs(player.GetHumans()) do
		if v != ply then
			if v:GetViewEntity() == ply then
				v:SetViewEntity()
			end
			local obsTarget = v:GetObserverTarget()
			if IsValid(obsTarget) and obsTarget == ply then
				v:SpectateEntity(table.Random(self:GetActivePlayersTable()))
			end
		end
	end
end

function GM:PlayerSay(ply, text, team)
	hook.Run("PlayerSayChatsound", ply, text, team)
	return text
end

net.Receive("UpdatePlayerPositions", function(len, ply)
	if IsValid(ply) then
		ply.ShowPlayerDist = RealTime() + net.ReadFloat()
	end
end)
function GM:SetupPlayerVisibility(ply, viewent)
	if (!IsValid(viewent) or viewent == ply) and ply.ShowPlayerDist and ply.ShowPlayerDist > RealTime() then
		for k, v in pairs(self:GetActivePlayersTable()) do
			AddOriginToPVS(v:GetPos())
		end
	end
	local specply = ply:GetObserverTarget()
	if IsValid(specply) then
		ply:SetPos(specply:GetPos())
	end
	if IsValid(viewent) and viewent:IsPlayer() and viewent != ply then
		AddOriginToPVS(viewent:GetPos())
	end
end

function GM:OnDamagedByExplosion(ply, dmginfo)
	return true
end

GM.NPCScorePrice = {
	["monster_scientist"] = -20,
	["monster_sitting_scientist"] = -20,
	["monster_barney"] = -10,

	["monster_cockroach"] = 1,
	["monster_leech"] = 1,
	["monster_babycrab"] = 5,
	["monster_headcrab"] = 10,
	["monster_sentry"] = 15,
	["monster_zombie"] = 20,
	["monster_houndeye"] = 20,
	["monster_miniturret"] = 20,
	["monster_turret"] = 30,
	["monster_alien_slave"] = 30,
	["monster_alien_controller"] = 30,
	["monster_bullchicken"] = 30,
	["monster_human_grunt"] = 50,
	["monster_ichthyosaur"] = 60,
	["monster_alien_grunt"] = 70,
	["monster_human_assassin"] = 80,
	["monster_gargantua"] = 250,
	["hornet"] = 0,
	["monster_snark"] = 0,
	["monster_bigmomma"] = 0,
	["monster_nihilanth"] = 0,
	["monster_generic"] = 0,
}

GM.NPCsNiceNames = {
	["monster_barney"] = "Security Guard",
	["monster_scientist"] = "Scientist",
}

function GM:OnNPCKilled(npc, attacker, inflictor)
	if !IsValid(inflictor) then inflictor = attacker end
	if IsValid(inflictor) and inflictor == attacker and (inflictor:IsPlayer() or inflictor:IsNPC()) then
		local actwep = inflictor:GetActiveWeapon()
		if IsValid(actwep) then
			inflictor = actwep
		end
	end

	if attacker:IsPlayer() then
		local ePrice = self.NPCScorePrice[npc:GetClass()]
		if ePrice then
			attacker:AddScore(ePrice)
		else
			attacker:AddScore(10)
		end
		MsgC(Color(255, 255, 255), attacker:Nick() .. " killed " .. npc:GetClass() .. " with " .. inflictor:GetClass() .. "\n")
	end
	
	if self.ImportantNPCs then
		if self.ImportantNPCsSpecial then
			local hasAliveNPCs
			for _, name in pairs(self.ImportantNPCs) do
				for k, v in pairs(ents.FindByName(name)) do
					if npc != v and v:Health() > 0 then
						hasAliveNPCs = true
					end
				end
			end
			if !hasAliveNPCs then
				self:GameOver(false, "All scientists are dead")
			end
		else
			for _, name in pairs(self.ImportantNPCs) do
				if npc:GetName() == name then
					local nicename = self.NPCsNiceNames[npc:GetClass()]
					local reason
					if nicename then
						reason = "The "..nicename.." has been killed"
					end
					self:GameOver(false, reason)
				end
			end
		end
	end
	
	if self:GetCrackMode() then
		hook.Run("CrackModeNPCKilled", npc, attacker, inflictor)
	end
end

monsterDeadTable = {
	["monster_barney_dead"] = true,
	["monster_hevsuit_dead"] = true,
	["monster_hgrunt_dead"] = true,
	["monster_scientist_dead"] = true,
}

local scoreForDamage = {
	["monster_apache"] = true,
	["monster_osprey"] = true,
}

function GM:EntityTakeDamage(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	if IsValid(attacker) and attacker:IsPlayer() and IsValid(inflictor) and inflictor:GetClass() == "monster_mortar" and !IsValid(inflictor:GetOwner()) then
		dmginfo:SetAttacker(inflictor)
	end
-- remove after gmod update
	if (ent:Health() <= dmginfo:GetDamage() or dmginfo:IsDamageType(DMG_CLUB)) and IsValid(inflictor) and (ent:GetClass() == "monster_cockroach" or ent:GetClass() == "monster_barnacle") then
		if VERSION < 190624 then
			local attaker = inflictor:IsPlayer() and inflictor or inflictor:GetOwner()
			if IsValid(attaker) then
				self:OnNPCKilled(ent, attacker, inflictor)
			end
		end
	end
	
	if self.ImportantNPCs and self:IsCoop() and ent:IsNPC() then
		local attacker = dmginfo:GetAttacker()
		if IsValid(attacker) and attacker:IsPlayer() then
			for k, v in pairs(self.ImportantNPCs) do
				if ent:GetName() == v then
					return true
				end
			end
		end
	end
	if ent:GetName() == "tank_break_explob" then
		local attacker = dmginfo:GetAttacker()
		if IsValid(attacker) and attacker:IsPlayer() then
			attacker:AddScore(math.floor(dmginfo:GetDamage() / 1.5))
		end
	end
		
	--[[if ent:IsNPC() and ent:GetClass() == "nihilanth_energy_ball" then
		print(ent, dmginfo:GetAttacker(), dmginfo:GetDamage())
		return true
	end]]--
	
	
	if ent:IsPlayer() then
		if !ent:IsBot() and (!ent.canTakeDamage and dmginfo:GetDamage() < 100 or self.NewChapterDelay and self.NewChapterDelay + 2 > CurTime()) or GetGlobalBool("FirstWaiting") then
			return true
		end
		
		local attacker = dmginfo:GetAttacker()
		if ent.SpawnProtectionTime and ent.SpawnProtectionTime >= CurTime() and IsValid(attacker) and (attacker:GetClass() != "trigger_hurt" or dmginfo:GetDamage() < 100) then return true end
		if IsValid(attacker) and attacker:GetClass() == "trigger_hurt" and dmginfo:IsDamageType(16) then
			if ent:Armor() > 0 then
				ent:SetArmor(math.Clamp(ent:Armor() - dmginfo:GetDamage(), 0, 100))
			end
			return true
		end
	end
	
	if ent:IsNPC() then
		if scoreForDamage[ent:GetClass()] then
			local attacker = dmginfo:GetAttacker()
			if IsValid(attacker) and attacker:IsPlayer() then
				attacker:AddScore(math.floor(dmginfo:GetDamage() / 2.5))
			end
		end
		if ent:GetClass() == "monster_gman" then
			ent:SetHealth(ent:Health() - dmginfo:GetDamage())
			if ent:Health() < -140 then
				ent:Remove()
				self:GibEntity(ent)
			end
		end
		if ent:GetClass() == "monster_nihilanth" then
			local attacker = dmginfo:GetAttacker()
			if cvar_fixnihilanth:GetBool() then
				local inflictor = dmginfo:GetInflictor()
				if !dmginfo:IsBulletDamage() or IsValid(inflictor) and !inflictor:IsPlayer() then
					local m_irritation = ent:GetInternalVariable("m_irritation")
					if m_irritation and m_irritation >= 2 then
						local dmgpos = dmginfo:GetDamagePosition()
						local tr = util.TraceLine({
							start = dmgpos + Vector(0,0,128),
							endpos = dmgpos - Vector(0,0,128),
							filter = {attacker, inflictor}
						})
						if !(tr.HitBox == 3 and tr.HitGroup == 2) then
							dmginfo:ScaleDamage(0)
						end
					end
				end
			end
			if ent:Health() > 1 then
				if IsValid(attacker) and attacker:IsPlayer() then
					attacker:AddScore(math.floor(dmginfo:GetDamage() / 6))
				end
			elseif ent:GetInternalVariable("m_lifeState") > 0 then
				ent:SetNotSolid(true)
			end
		end
		if ent:GetClass() == "monster_bigmomma" then
			if dmginfo:IsDamageType(DMG_BLAST) then
				local dmgpos = dmginfo:GetDamagePosition()
				local entpos = ent:WorldSpaceCenter()
				local dist = dmgpos:Distance(entpos) - 20
				dist = math.max(dist / 32, 1)
				local dmg = dmginfo:GetInflictor().dmg
				dmg = dmg or 100
				dmginfo:SetDamagePosition(dmgpos)
				dmginfo:SetDamage(dmg / dist)
				--print(dmginfo:GetDamage())
			end
			if ent:Health() > 1 then
				local attacker = dmginfo:GetAttacker()
				if IsValid(attacker) and attacker:IsPlayer() then
					attacker:AddScore(math.floor(dmginfo:GetDamage() / 16))
				end
			end
		end
	end
	
	if monsterDeadTable[ent:GetClass()] then
		ent:SetHealth(ent:Health() - dmginfo:GetDamage())
		if ent:Health() <= -40 then
			self:GibEntity(ent)
			ent:Remove()
		end
	end
end

function GM:OnEntityExplosion(ent, pos, radius, dmg)
	if self:GetCrackMode() then
		hook.Run("CrackModeEntityExplosion", ent, pos, radius, dmg)
	end
	if cvars.Bool("ai_serverragdolls") then return end
	net.Start("RagdollGib")
	net.WriteVector(pos)
	net.WriteFloat(dmg)
	net.WriteFloat(radius)
	net.SendPVS(pos)
end

function GM:FixCollisionBounds(ent, class, mins, maxs)
	-- use in OnEntityCreated
	if ent:GetClass() == class then
		timer.Simple(0, function()
			if IsValid(ent) then
				ent:SetCollisionBounds(mins, maxs)
			end
		end)
	end
end

concommand.Add("hl1_coop_give", function(ply, cmd, args)
	if !IsValid(ply) or !ply:IsAdmin() or !ply:Alive() then return end
	local wep = args[1]
	if wep then
		if ply:HasWeapon(wep) then
			wep = ply:GetWeapon(wep)
			if IsValid(wep) and wep:IsScripted() then
				local ammoType = wep:GetPrimaryAmmoType()
				if ammoType > -1 then
					ply:GiveAmmo(wep.Primary.DefaultClip, ammoType)
				end
			end
		else
			ply:Give(wep)
		end
	end
end)

concommand.Add("hl1_coop_impulse101", function(ply, cmd, args)

	if ply and IsValid(ply) and (!ply:IsSuperAdmin() or !ply:Alive()) then return end
	
	if args[1] then
		for k, v in pairs(player.GetAll()) do
			if v:Nick():lower() == args[1]:lower() then
				ply = v
				break
			end
		end
	end

	if !IsValid(ply) then return end
	
	local weps = {
		"weapon_crowbar",
		"weapon_glock",
		"weapon_357",
		"weapon_mp5",
		"weapon_shotgun",
		"weapon_crossbow",
		"weapon_rpg",
		"weapon_gauss",
		"weapon_egon",
		"weapon_hornetgun",
		"weapon_handgrenade",
		"weapon_satchel",
		"weapon_tripmine",
		"weapon_snark"
	}
	
	for _, wep in pairs(weps) do
		ply:Give(wep)
		local entWep = ply:GetWeapon(wep)
		if IsValid(entWep) and entWep.Primary.MaxAmmo then ply:GiveAmmo(math.min(entWep.Primary.MaxAmmo - ply:GetAmmoCount(entWep:GetPrimaryAmmoType()), entWep.Primary.DefaultClip), entWep:GetPrimaryAmmoType()) end
		--if entWep.Secondary.MaxAmmo then ply:GiveAmmo(math.min(entWep.Secondary.MaxAmmo - ply:GetAmmoCount(entWep:GetSecondaryAmmoType()), entWep.Secondary.DefaultClip), entWep:GetSecondaryAmmoType()) end
	end
	if ply:IsSuitEquipped() then
		if ply:Armor() < 100 then
			ply:Give("item_battery")
		end
	else
		ply:Give("item_suit")
	end
	ply:Give("ammo_ARgrenades")

end)

concommand.Add("game_restart", function(ply, cmd, args)
	if IsValid(ply) and !ply:IsAdmin() then return end
	GAMEMODE:GameRestart()
end)

function GM:StartEndTitles()
	self:SetGlobalBool("EndTitles", true)
	self:SetGlobalFloat("EndTitlesTime", CurTime())
	for k, v in pairs(player.GetAll()) do
		v:Freeze(true)
	end
	local endTime = 110
	local restartTime = 10
	if !self:IsCoop() then
		endTime = endTime + restartTime
	end
	timer.Simple(endTime, function()
		if GetGlobalBool("EndTitles") then
			if self:IsCoop() then
				PrintMessage(HUD_PRINTTALK, "Restart in "..restartTime.." seconds")
				timer.Simple(restartTime, function()
					self:LoadFirstMap()
				end)
			else
				RunConsoleCommand("disconnect")
			end
		end
	end)
end

function GM:LoadFirstMap()
	local map = ""
	local cvar = cvar_firstmap:GetString()
	if cvar and string.len(cvar) > 0 then
		map = cvar
	else
		local t = {}
		for chapter, maptable in pairs(GAMEMODE.Chapters) do
			table.insert(t, maptable[1])
		end
		table.sort(t, function(a, b) return a < b end)
		map = t[1]
	end
	RunConsoleCommand("changelevel", map)
	self:TransitPlayers(map)
end

function GM:TransitPlayers(maptochange, leveltransition)
	local tPlys = {}
	if leveltransition then
		for k, v in pairs(player.GetHumans()) do
			local actwep = v:GetActiveWeapon()
			local wepclass = IsValid(actwep) and actwep:GetClass()
			table.insert(tPlys, {id = v:UserID(), steamid = v:SteamID64(), nick = v:Nick(), hp = v:Health(), armor = v:Armor(), wep = wepclass, alive = v:Alive(), spec = v:Team() == TEAM_SPECTATOR, weptable = self:StorePlayerAmmunitionNew(v)})
		end
	else
		for k, v in pairs(team.GetPlayers(TEAM_COOP)) do
			if !v:IsBot() then
				table.insert(tPlys, {id = v:UserID(), steamid = v:SteamID64(), nick = v:Nick()})
			end
		end
	end
	if tPlys then
		file.CreateDir("hl1_coop")
		file.Write("hl1_coop/transition_players_"..maptochange..".txt", util.TableToJSON(tPlys))
	end
end

function GM:ShowHelp(ply)
    ply:ConCommand("vote_yes")
end

function GM:ShowTeam(ply)
	ply:ConCommand("vote_no")
end

concommand.Add("dropweapon", function(ply)
	if IsValid(ply) and ply:Alive() then
		local actwep = ply:GetActiveWeapon()
		if IsValid(actwep) then	
			if ply.DroppedWeapons then
				local count = 0
				for k, v in pairs(ply.DroppedWeapons) do
					local dropwep = v[1]
					if IsValid(dropwep) and dropwep:GetClass() == actwep:GetClass() and !IsValid(dropwep:GetOwner()) then
						count = count + 1
					end
				end
				if count >= MAX_DROPPED_WEAPONS then return end
			end
			if actwep:IsScripted() then
				actwep:Holster()
			end
			if SERVER then ply:DropWeapon(actwep) end
		end
	end
end, nil, nil, FCVAR_CLIENTCMD_CAN_EXECUTE)

concommand.Add("dropammo", function(ply)
	if IsValid(ply) and ply:Alive() then
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep:IsScripted() then
			local ammotype = wep:GetPrimaryAmmoType()
			local ammo = ply:GetAmmoCount(ammotype)
			if ammo > 0 and wep.AmmoEnt then
				local num = wep.Primary.DefaultClip
				if ammo < num then
					num = ammo
				end
				if SERVER then
					local ammoent = ents.Create(wep.AmmoEnt)
					if !IsValid(ammoent) then return end
					local pos = ply:WorldSpaceCenter()
					local ang = ply:EyeAngles():Forward()
					local tr = util.TraceHull({
						start = pos,
						endpos = pos + ang * 60,
						filter = {ammoent, ply},
						mins = Vector(-8, -8, 0),
						maxs = Vector(8, 8, 8)
					})
					if tr.HitWorld then return end
					ammoent:SetPos(tr.HitPos)
					--ammoent:SetAngles(Angle(0, ply:EyeAngles()[2], 0))
					ammoent:SetVelocity(ang * 100)
					ammoent:Spawn()
					ammoent.AmmoAmount = num
				end
				ply:SetAmmo(ammo - num, ammotype)
			end
		end
	end
end, nil, nil, FCVAR_CLIENTCMD_CAN_EXECUTE)

concommand.Add("chase", function(ply, cmd, args, argStr)
	if !IsValid(ply) then return end
	local arg = tonumber(args[1])
	if !arg then ply:ChasePlayer() return end
	local pl = Player(arg)
	if IsValid(pl) and pl != ply and pl:Team() == TEAM_COOP then
		ply:ChasePlayer(pl)
	else
		ply:ChasePlayer()
	end
end, nil, nil, FCVAR_CLIENTCMD_CAN_EXECUTE)

concommand.Add("lastcheckpoint", function(ply, cmd, args, argStr)
	if !IsValid(ply) or !ply:Alive() or ply:IsFrozen() or ply:IsSpectator() then return end
	if !LAST_CHECKPOINT then
		ply:PrintMessage(HUD_PRINTCONSOLE, "No checkpoint was found")
		return
	end
	if ply.CanTeleportTime and ply.CanTeleportTime > CurTime() and LAST_CHECKPOINT.Pos:Distance(ply:GetPos()) > LAST_CHECKPOINT_MINDISTANCE then
		local price = PRICE_LAST_CHECKPOINT
		if ply:GetScore() < price then
			ply:PrintMessage(HUD_PRINTCONSOLE, "Not enough score!")
			return
		end
		ply:TeleportToCheckpoint(LAST_CHECKPOINT.Pos, LAST_CHECKPOINT.Ang, LAST_CHECKPOINT.Weptable)
		ply:AddScore(-price)
	end
end, nil, nil, FCVAR_CLIENTCMD_CAN_EXECUTE)

function GM:ChangeLevel(map, delay)
	if map then
		delay = delay or 3
		local plytable = player.GetAll()
		for _, pl in pairs(plytable) do
			pl:Lock()
		end
		self:GlobalTextMessageCenter("Changing level...", delay)
		timer.Simple(delay, function()
			RunConsoleCommand("changelevel", map)
			for _, pl in pairs(plytable) do
				pl:UnLock()
			end
		end)
	end
end