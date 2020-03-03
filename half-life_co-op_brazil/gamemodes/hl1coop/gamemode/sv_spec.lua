util.AddNetworkString("SetSpectateMode")
util.AddNetworkString("SetSpectatePlayer")

net.Receive("SetSpectateMode", function(len, ply)
	if IsValid(ply) and ply:IsSpectator() then
		local obsTarget = ply:GetObserverTarget()
		if IsValid(obsTarget) and obsTarget:IsPlayer() and obsTarget:IsSpectator() then
			ply:UnSpectate()
		end
		ply:Spectate(net.ReadUInt(4))
	end
end)

net.Receive("SetSpectatePlayer", function(len, ply)
	if IsValid(ply) and ply:IsSpectator() then
		local ent = net.ReadEntity()
		if IsValid(ent) and ent:IsPlayer() and !ent:IsSpectator() then
			ply:SpectateEntity(ent)
			ply:SetupHands(ent)
			local obsMode = ply:GetObserverMode()
			if obsMode != OBS_MODE_CHASE and obsMode != OBS_MODE_IN_EYE then
				ply:Spectate(OBS_MODE_CHASE)
			end
		else
			ply:UnSpectate()
		end
	end
end)

concommand.Add("hl1_coop_spectate", function(ply)
	if !ply or !IsValid(ply) or ply:Team() == TEAM_UNASSIGNED or !GAMEMODE:IsCoop() then return end
	if ply.TeamChangeTime and ply.TeamChangeTime > CurTime() then
		ply:PrintMessage(HUD_PRINTTALK, "You can switch teams again in "..math.ceil(ply.TeamChangeTime - CurTime()).."s")
		return
	end
	if ply:Team() == TEAM_SPECTATOR then
		ply.TeamChangeTime = CurTime() + 3
		if GAMEMODE:GetSurvivalMode() and team.NumPlayers(TEAM_COOP) == 0 then
			GAMEMODE:GameRestart()
		end
		ply:SetTeam(TEAM_COOP)
		if GAMEMODE:GetSurvivalMode() or !ply:CanJoinGame() then return end
		ply:UnSpectate()
		if ply.SpawnedAsSpectator then
			ply.SpawnedAsSpectator = nil
			GAMEMODE:PlayerInitialSpawn(ply)
		else
			hook.Call("PlayerLoadout", GAMEMODE, ply, true)
		end
		ply:Spawn()
		if ply.LastHealth and ply.LastArmor then
			ply:SetHealth(ply.LastHealth)
			ply:SetArmor(ply.LastArmor)
		end
	else
		ply.TeamChangeTime = CurTime() + 3
		if ply:Alive() and ply:Health() > 0 then
			ply.LastHealth = ply:Health()
			ply.LastArmor = ply:Armor()
		else
			ply.LastHealth = nil
			ply.LastArmor = nil
		end
		GAMEMODE:PlayerSpawnAsSpectator(ply)
	end
end)