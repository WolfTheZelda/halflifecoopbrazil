local function RestoreRagdoll()
	local ragdoll = LocalPlayer():GetRagdollEntity()
	if IsValid(ragdoll) and ragdoll:GetNoDraw() then
		ragdoll:SetNoDraw(false)
		timer.Simple(0, function()
			if IsValid(ragdoll) and ragdoll:GetNoDraw() then
				ragdoll:SetNoDraw(false)
			end
		end)
	end
end

local function SetSpectateMode(mode)
	net.Start("SetSpectateMode")
	net.WriteUInt(mode, 4)
	net.SendToServer()
end

local function SpectatePlayer(ply)
	net.Start("SetSpectatePlayer")
	net.WriteEntity(ply)
	net.SendToServer()
	RestoreRagdoll()
end

local current = 0

function GM:SpectatorKeyPress(ply, key)
	local plyTable = team.GetPlayers(TEAM_COOP)
	local obsMode = ply:GetObserverMode()
	local obsTarget = ply:GetObserverTarget()
	
	if IsValid(obsTarget) and obsTarget != plyTable[current] then
		local plyKey = table.KeyFromValue(plyTable, obsTarget)
		if plyKey then
			current = plyKey
		else
			current = 0
		end
	end

	if key == IN_ATTACK then
		for i = 1, #plyTable do
			current = current + 1
			if current > #plyTable then
				current = 1
			end
			local specply = plyTable[current]
			if IsValid(specply) and specply:Alive() then break end
		end
		if plyTable[current] then
			SpectatePlayer(plyTable[current])
		end
	elseif key == IN_ATTACK2 then
		for i = 1, #plyTable do
			current = current - 1
			if current < 1 then
				current = #plyTable
			end
			local specply = plyTable[current]
			if IsValid(specply) and specply:Alive() then break end
		end
		if plyTable[current] then
			SpectatePlayer(plyTable[current])
		end
	elseif key == IN_JUMP and IsValid(obsTarget) then
		if obsMode == OBS_MODE_CHASE then
			SetSpectateMode(OBS_MODE_IN_EYE)
		else
			SetSpectateMode(OBS_MODE_CHASE)
		end
	end
end