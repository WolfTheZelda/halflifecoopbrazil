local cvar_voteEnable = CreateConVar("hl1_coop_sv_vote_enable", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Allow voting on server")
local cvar_voteSpec = CreateConVar("hl1_coop_sv_vote_allowspectators", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Allow spectators to vote")
local cvar_voteTime = CreateConVar("hl1_coop_sv_vote_time", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY})

local sndVoteStart = "ambient/alarms/warningbell1.wav"
local sndVotePassed = "friends/friend_join.wav"
local sndVoteFailed = "buttons/button10.wav"
local sndVote = "buttons/blip1.wav"

local voteTypes = {
	["map"] = "<mapname>",
	["kick"] = "<nickname>",
	["kickid"] = "<userid>",
	["skill"] = "<number 1-4>",
	["restart"] = "",
	["speedrunmode"] = "",
	["survivalmode"] = "",
	["crackmode"] = "",
	["skiptripmines"] = ""
}

local voteExecuteDelay = 3
local voteExecuteTime = 0

local function VoteEnd(result, nomsg)
	if result == 1 then
		local voteType = GetGlobalString("VoteType")
		if voteType == "map" then
			timer.Simple(voteExecuteDelay, function()
				local maptochange = GetGlobalString("VoteName")
				RunConsoleCommand("changelevel", maptochange)
				GAMEMODE:TransitPlayers(maptochange)
			end)
		elseif voteType == "kick" then
			timer.Simple(voteExecuteDelay, function()
				RunConsoleCommand("kick", GetGlobalString("VoteName"))
			end)
		elseif voteType == "kickid" then
			timer.Simple(voteExecuteDelay, function()
				game.KickID(GetGlobalString("VoteName"), "Kicked by vote")
			end)
		elseif voteType == "skill" then
			timer.Simple(voteExecuteDelay, function()
				RunConsoleCommand("hl1_coop_sv_skill", GetGlobalString("VoteName"))
			end)
		elseif voteType == "speedrunmode" then
			timer.Simple(voteExecuteDelay, function()
				RunConsoleCommand("hl1_coop_speedrunmode", GetGlobalString("VoteName"))
			end)
		elseif voteType == "survivalmode" then
			timer.Simple(voteExecuteDelay, function()
				RunConsoleCommand("hl1_coop_sv_survival", GetGlobalString("VoteName"))
			end)
		elseif voteType == "crackmode" then
			timer.Simple(voteExecuteDelay, function()
				RunConsoleCommand("hl1_coop_crackmode", GetGlobalString("VoteName"))
			end)
		elseif voteType == "restart" then
			timer.Simple(voteExecuteDelay, function()
				GAMEMODE:GameRestart()
			end)
		elseif voteType == "skiptripmines" then
			timer.Simple(voteExecuteDelay, function()
				SkipTripmines()
			end)
		end
		if !nomsg then ChatMessage("#vote_votepassed", 3) end
		net.Start("PlayClientSound")
		net.WriteString(sndVotePassed)
		net.Broadcast()
		voteExecuteTime = CurTime() + voteExecuteDelay
	else
		if !nomsg then ChatMessage("#vote_votefailed", 3) end
		net.Start("PlayClientSound")
		net.WriteString(sndVoteFailed)
		net.Broadcast()
	end
	GAMEMODE:SetGlobalBool("Vote", false)
	for k, v in pairs(player.GetAll()) do
		v.voteOption = nil
	end
end

local function VoteCancel(ply)
	if IsValid(ply) and !ply:IsAdmin() then return end
	if !GetGlobalBool("Vote") then
		if IsValid(ply) then
			ply:ChatMessage("#vote_noactivevote", 3)
		else
			print("No vote in progress")
		end
		return
	end
	VoteEnd(0, true)
	if IsValid(ply) then
		ChatMessage(ply:Nick() .. " " .. "#vote_plyvetoed", 3)
	else
		ChatMessage("#vote_canceled", 3)
	end
end

local nextCheck = RealTime()
function GM:VoteThink()	
	if GetGlobalBool("Vote") then
		if nextCheck and nextCheck <= RealTime() then
			local plyCount = (cvar_voteSpec:GetBool() or GetGlobalBool("FirstLoad")) and player.GetCount() or team.NumPlayers(TEAM_COOP)
			if plyCount == 0 then
				VoteCancel()
				return
			end
			local yes, no = GetGlobalInt("VoteNumYes"), GetGlobalInt("VoteNumNo")
			local total = yes + no
			if (GetGlobalFloat("VoteTime") - CurTime()) <= 0 then
				if yes > no and total > 1 then
					VoteEnd(1)
				else				
					VoteEnd()
				end
			elseif yes > math.floor(plyCount / 2) then			
				VoteEnd(1)
			elseif no >= yes and no >= math.ceil(plyCount / 2) then
				VoteEnd()
			end
			
			nextCheck = RealTime() + .5
		end
	end
end

local function RemovePlayerVote(ply)
	local vote = ply.voteOption
	if vote then
		if vote == 1 then
			SetGlobalInt("VoteNumYes", GetGlobalInt("VoteNumYes") - 1)
		else
			SetGlobalInt("VoteNumNo", GetGlobalInt("VoteNumNo") - 1)
		end
		ply.voteOption = nil
	end
end

function GM:VotePlayerJoinedSpectators(ply)
	if GetGlobalBool("Vote") and !cvar_voteSpec:GetBool() then
		RemovePlayerVote(ply)
	end
end

function GM:VotePlayerDisconnected(ply)
	if GetGlobalBool("Vote") then
		RemovePlayerVote(ply)
		
		local voteType = GetGlobalString("VoteType")
		local voteName = GetGlobalString("VoteName")
		if voteType == "kick" then
			if ply:Nick() == voteName then
				local ip = ply:IPAddress()
				RunConsoleCommand("addip", 1, ip)
				VoteEnd(0, true)
			end
		elseif voteType == "kickid" then
			if ply == Player(voteName) then
				local ip = ply:IPAddress()
				RunConsoleCommand("addip", 1, ip)
				VoteEnd(0, true)
			end
		end
	end
end

local function PrintHelpText(ply)
	ply:PrintMessage(HUD_PRINTTALK, "Usage:")
	for k, v in SortedPairs(voteTypes) do
		ply:PrintMessage(HUD_PRINTTALK, k.." "..v)
	end
end

concommand.Add("hl1_coop_callvote", function(ply, cmd, args)
	if GetGlobalBool("FirstWaiting") then return end
	if !cvar_voteEnable:GetBool() then
		ply:ChatMessage("#vote_votedisabled", 3)
		return
	end
	if !cvar_voteSpec:GetBool() then -- if spectators cannot vote
		if ply:Team() == TEAM_SPECTATOR then
			ply:ChatMessage("#vote_speccantcall", 3)
			return
		end
		if !GetGlobalBool("FirstLoad") and team.NumPlayers(TEAM_COOP) == 0 then
			ply:ChatMessage("#vote_cannotnow", 3)
			return
		end
	end
	if !ply:IsAdmin() and ply.NextVote and ply.NextVote > CurTime() then
		ply:ChatMessage("#vote_voteagain".." "..math.ceil(ply.NextVote - CurTime()).."s", 3)
		return
	end

	if voteTypes[args[1]] then
		if GetGlobalBool("Vote") or voteExecuteTime > CurTime() then
			ply:ChatMessage("#vote_alreadyactive", 3)
			return
		end
		
		if args[1] == "map" and args[2] then
			local mapcheck = file.Exists("maps/"..args[2]..".bsp", "GAME")
			if !mapcheck then
				ply:PrintMessage(HUD_PRINTTALK, "Not a valid map!")
				return
			end
			SetGlobalString("VoteName", args[2])
		elseif args[1] == "kick" and args[2] then
			local playercheck = player.GetAll()
			local notvalid
			for k, v in pairs(playercheck) do
				if string.lower(v:Nick()) != string.lower(args[2]) then
					notvalid = true
				else
					if v:IsSuperAdmin() or v:IsAdmin() then
						--ply:ChatMessage("Fuck you")
						return
					end
					notvalid = nil
					break
				end
			end
			if notvalid then
				ply:PrintMessage(HUD_PRINTTALK, "Not a valid player!")
				return
			else
				SetGlobalString("VoteName", args[2])
			end
		elseif args[1] == "kickid" and args[2] then
			local plyid = tonumber(args[2])
			local playercheck = Player(plyid)
			if IsValid(playercheck) then
				if playercheck:IsAdmin() then
					--ply:ChatMessage("Fuck you")
					return
				end
				SetGlobalString("VoteName", plyid)
			else
				ply:PrintMessage(HUD_PRINTTALK, "Not a valid player!")
				return
			end
		elseif args[1] == "skill" and args[2] then
			local skill = tonumber(args[2])
			if SKILL_LEVEL[skill] then
				if GAMEMODE:GetSkillLevel() == skill then
					ply:ChatMessage("#vote_skillalready".." "..skill, 3)
					return
				end
				SetGlobalString("VoteName", skill)
			else
				ply:PrintMessage(HUD_PRINTTALK, "Not a valid skill level!")
				return
			end
		elseif args[1] == "speedrunmode" then
			if cvars.Bool("hl1_coop_speedrunmode") then
				SetGlobalString("VoteName", "0")
			else
				SetGlobalString("VoteName", "1")
			end
		elseif args[1] == "survivalmode" then
			if cvars.Bool("hl1_coop_sv_survival") then
				SetGlobalString("VoteName", "0")
			else
				SetGlobalString("VoteName", "1")
			end
		elseif args[1] == "crackmode" then
			if cvars.Bool("hl1_coop_crackmode") then
				SetGlobalString("VoteName", "0")
			else
				SetGlobalString("VoteName", "1")
			end
		elseif args[1] == "restart" then
			if GetGlobalBool("FirstLoad") then
				ply:ChatMessage("#vote_cannotnow", 3)
				return
			end
			SetGlobalString("VoteName", "map")
		elseif args[1] == "skiptripmines" then
			if GetGlobalBool("FirstLoad") or game.GetMap() != "hls11cmrl" or TripminesSkipped() then
				return
			end
			SetGlobalString("VoteName", "")
		else
			PrintHelpText(ply)
			return
		end
		GAMEMODE:SetGlobalBool("Vote", true)
		ChatMessage(ply:Nick().." ".."#vote_plycalled", 3)
		SetGlobalString("VoteType", args[1])
		SetGlobalInt("VoteNumYes", 1)
		SetGlobalInt("VoteNumNo", 0)
		GAMEMODE:SetGlobalFloat("VoteTime", CurTime() + cvar_voteTime:GetFloat())
		print(ply:Nick().." called vote: "..GetGlobalString("VoteType").." "..GetGlobalString("VoteName"))
		ply.voteOption = 1
		ply.NextVote = CurTime() + 60
		
		if player.GetCount() > 1 then
			net.Start("PlayClientSound")
			net.WriteString(sndVoteStart)
			net.Broadcast()
		end
	else
		PrintHelpText(ply)
	end
end)

local function CVote(v, ply)
	if !GetGlobalBool("Vote") then
		ply:ChatMessage("#vote_noactivevote", 3)
		return
	end
	if !cvar_voteSpec:GetBool() and ply:Team() == TEAM_SPECTATOR then
		ply:ChatMessage("#vote_speccantvote", 3)
		return
	end
	if ply.voteOption then
		ply:ChatMessage("#vote_alreadycast", 3)
		return
	end
	ply.voteOption = v
	ply:ChatMessage("#vote_votecast", 3)
	if v == 1 then
		SetGlobalInt("VoteNumYes", GetGlobalInt("VoteNumYes") + 1)
	else
		SetGlobalInt("VoteNumNo", GetGlobalInt("VoteNumNo") + 1)
	end
	
	net.Start("PlayClientSound")
	net.WriteString(sndVote)
	net.Broadcast()
end

concommand.Add("vote_yes", function(ply)
	CVote(1, ply)
end)

concommand.Add("vote_no", function(ply)
	CVote(0, ply)
end)
	
concommand.Add("vote_cancel", function(ply)
	VoteCancel(ply)
end)