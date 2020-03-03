include("cl_envmapfix.lua")
include("cl_hud.lua")
include("cl_menus.lua")
include("cl_scoreboard.lua")
include("cl_spec.lua")
include("cl_view.lua")
include("shared.lua")
include("gsrchud.lua")

function GetKeyFromBind(bind, bind1)
	bind, bind1 = tostring(bind), tostring(bind1)
	local lookup = input.LookupBinding
	bind = lookup(bind) or lookup(bind1) or "NO KEY"
	return string.upper(bind)
end

include("lang/lang_en.lua")
local lang_cvar = CreateClientConVar("hl1_coop_cl_lang", "", true, true)
function GM:SetLanguage(newlang)
	if newlang != "" then
		local lang_file = self.FolderName.."/gamemode/lang/lang_"..newlang..".lua"
		if file.Exists(lang_file, "LUA") then
			include(lang_file)
		end
	end
end
cvars.AddChangeCallback("hl1_coop_cl_lang", function(cvar, old, new)
	GAMEMODE:SetLanguage(new)
end)
local lang_file = "lang/lang_"..lang_cvar:GetString()..".lua"
if file.Exists(GM.FolderName.."/gamemode/"..lang_file, "LUA") then
	include(lang_file)
end

function ConvertToLang(msg)
	if lang then
		local msg_t = string.Explode(" ", msg)
		if #msg_t > 0 then
			for i = 1, #msg_t do
				if string.StartWith(msg_t[i], "#") then
					msg_t[i] = string.Replace(msg_t[i], "#", "")
					if lang[msg_t[i]] then
						msg_t[i] = lang[msg_t[i]]
					end
				end
			end
			msg = table.concat(msg_t, " ")
		end
	end
	return msg
end

CreateClientConVar("hl1_coop_cl_drawhalos", 1, true, false, "Draw player halos")
CreateClientConVar("hl1_coop_cl_playermodel", "Helmet (HLS)", true, true, "Player model")
CreateClientConVar("hl1_coop_cl_showhints", 1, true, false, "Enable hints for noobs")
CreateClientConVar("hl1_coop_cl_subtitles", 1, true, false, "Enable subtitles")
cvar_showtriggers = CreateClientConVar("_hl1coop_showtriggers", 0, false, false)

net.Receive("PlayerWaitBool", function()
	net.ReadEntity().InWaitTrigger = net.ReadBool()
end)

net.Receive("SetLongJumpClient", function()
	local ply = LocalPlayer()
	local b = net.ReadBool()
	if !IsValid(ply) then
		timer.Simple(1, function()
			ply = LocalPlayer()
			if IsValid(ply) then
				ply.LongJump = b
			end
		end)
	else
		ply.LongJump = b
	end
end)

net.Receive("SetGlobalBoolFix", function()
	SetGlobalBool(net.ReadString(), net.ReadBool())
end)
net.Receive("SetGlobalFloatFix", function()
	SetGlobalFloat(net.ReadString(), net.ReadFloat())
end)

net.Receive("PlayClientSound", function()
	surface.PlaySound(net.ReadString())
end)

net.Receive("SendConnectingPlayers", function()
	GAMEMODE.ConnectingPlayers = net.ReadTable()
end)

net.Receive("ChatMessage", function()
	local text = net.ReadString()
	text = ConvertToLang(text)
	local Type = net.ReadUInt(4)
	local col = Color(255, 255, 255)
	if Type == 0 then
		col = Color(160, 255, 160)
	elseif Type == 2 then
		col = Color(255, 160, 0)
	elseif Type == 3 then
		col = Color(0, 200, 255)
	end
	chat.AddText(col, text)
end)

net.Receive("GibPlayer", function()
	local pos, force, amount = net.ReadVector(), net.ReadVector(), net.ReadUInt(8)
	GAMEMODE:GibEntity(pos, amount, force)
end)

net.Receive("LastCheckpointPos", function()
	LAST_CHECKPOINT = net.ReadVector()
end)

net.Receive("ApplyViewModelHands", function()
	local wep = net.ReadEntity()
	if IsValid(wep) then
		GAMEMODE:ApplyViewModelHands(LocalPlayer(), wep)
	else
		timer.Simple(.1, function()
			GAMEMODE:ApplyViewModelHands()
		end)
	end
end)

function GM:InitPostEntity()
	net.Start("PlayerHasFullyLoaded")
	net.SendToServer()
	--LocalPlayer().afkTime = RealTime()
	
	if game.SinglePlayer() and game.GetMap() == "hls01amrl" then
		self:GameIntro()
	end
	
	if self:IsCoop() then
		if lang_cvar:GetString() != "" then
			if GetGlobalBool("FirstLoad") and LocalPlayer():Team() != TEAM_COOP then
				self:OpenStartMenu()
			end
		else
			if !GetGlobalBool("EndTitles") or GetGlobalBool("FirstLoad") then
				self:OpenLanguageMenu()
			end
		end
	end
	
	if !IsMounted("hl1") then
		local addonsMounted = 0
		local addonsToCheck = {
			["1416249216"] = true, --textures
			["1416243998"] = true, --models
			["1416247138"] = true, --sounds
		}
		for k, v in pairs(engine.GetAddons()) do
			if addonsToCheck[v.wsid] and v.mounted then
				addonsMounted = addonsMounted + 1
			end
		end
		if addonsMounted != table.Count(addonsToCheck) then
			self:OpenMountMenu()
		end
	end
	
	hook.Run("FixMapSpecular")
end

function GM:CreateMove(cmd)
	local ply = LocalPlayer()

	if !ply:Alive() and ply:Team() != TEAM_SPECTATOR and ply:GetObserverMode() == OBS_MODE_NONE then cmd:ClearMovement() end
	
	if GetGlobalBool("SpeedrunMode") and ply:WaterLevel() < 3 and ply:Alive() and ply:GetMoveType() == MOVETYPE_WALK and !ply:InVehicle() then
		if bit.band(cmd:GetButtons(), IN_JUMP) != 0 then
			if !ply:IsOnGround() then
				cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_JUMP)))
			end
		end
	end

	if !GetGlobalBool("FirstWaiting") and !ply.HasSeenHint and ply:GetNW2Bool("LongJump") and cmd:GetButtons() == IN_FORWARD then
		timer.Simple(3, function()
			if IsValid(ply) and ply:GetNW2Bool("LongJump") then
				self:PlayerShowScreenHint(1, 8)
				ply.HasSeenHint = true
			end
		end)
	end
end

function GM:OnPlayerChat( ply, strText, bTeamOnly, bPlayerIsDead )

	local tab = {}

	if IsValid(ply) then
		if ply:Team() != TEAM_SPECTATOR then
			if bPlayerIsDead and !GetGlobalBool("FirstLoad") then
				table.insert( tab, Color( 255, 30, 40 ) )
				table.insert( tab, "*DEAD* " )
			end
		else
			table.insert( tab, Color( 220, 220, 220 ) )
			table.insert( tab, "[SPEC] " )
		end
	end

	if ( bTeamOnly ) then
		table.insert( tab, Color( 30, 160, 40 ) )
		table.insert( tab, "(TEAM) " )
	end

	if ( IsValid( ply ) ) then
		table.insert( tab, ply )
	else
		table.insert( tab, "Console" )
	end

	table.insert( tab, Color( 255, 255, 255 ) )
	table.insert( tab, ": " .. strText )

	chat.AddText( unpack(tab) )
	--surface.PlaySound( "common/menu2.wav" )

	return true

end

function GM:OnSpawnMenuOpen()
	RunConsoleCommand("lastinv")
end

function GM:OnContextMenuOpen()	
	local ply = LocalPlayer()
	if ply:GetViewEntity() != ply then
		RunConsoleCommand("chase")
	else
		RunConsoleCommand("showdist")
	end
end

local hudHide = {
	["CHudAmmo"] = true,
	["CHudBattery"] = true,
	["CHudHealth"] = true,
}
local hudAlwaysHide = {
	["CHUDQuickInfo"] = true,
	["CHudTrain"] = true,
	["CHudSuitPower"] = true,
}

function GM:HUDShouldDraw(name)
	local ply = LocalPlayer()
	if IsValid(ply) then
		if name == "CHudCrosshair" then return IsValid(ply:GetActiveWeapon())
		elseif name == "CHudDamageIndicator" then return ply:Team() != TEAM_SPECTATOR and ply:Team() != TEAM_UNASSIGNED
		elseif hudHide[name] then return !ply:IsChasing() end
	end
	return !hudAlwaysHide[name]
end

function GM:Think()
	if !self:GetCrackMode() then return end
	for _, npc in ipairs(ents.FindByClass("monster_*")) do
		if npc:IsNPC() then
			hook.Run("CrackModeNPCThink", npc)
		end
	end
end

function GM:GibEntity(pos, amount, force, gibtype)
	gibtype = gibtype or 0
	local effectdata = EffectData()
	effectdata:SetFlags(1)
	effectdata:SetOrigin(pos)
	effectdata:SetNormal(force)
	effectdata:SetScale(amount)
	effectdata:SetMaterialIndex(gibtype)
	util.Effect("hl1_gib_emitter", effectdata, true)
end

local gibModels = {
	["models/hl1bar.mdl"] = {0, 16},
	["models/hgrunt.mdl"] = {0, 16},
	["models/scientist.mdl"] = {0, 16},
	["models/hassassin.mdl"] = {0, 16},
	["models/zombie.mdl"] = {0, 16},
	["models/islave.mdl"] = {1, 16},
	["models/bullsquid.mdl"] = {1, 20},
	["models/controller.mdl"] = {1, 12},
	["models/houndeye.mdl"] = {1, 8},
	["models/hl1hcrab.mdl"] = {1, 2},
	["models/agrunt.mdl"] = {1, 26},
}

net.Receive("RagdollGib", function()
	local pos, dmg, radius = net.ReadVector(), net.ReadFloat(), net.ReadFloat()
	for k, v in pairs(ents.FindInSphere(pos, radius)) do
		if v:IsRagdoll() and !v:GetRagdollOwner():IsPlayer() then
			local ragdollPos = v:GetPos()
			
			local tr = util.TraceLine({
				start = pos,
				endpos = ragdollPos,
				filter = v,
				mask = MASK_SOLID_BRUSHONLY
			})
			
			if !tr.HitWorld then
				local dir = ragdollPos - pos
				local force = dmg / dir:Length()
				local phys = v:GetPhysicsObject()
				if IsValid(phys) then
					phys:Wake()
					phys:SetPos((ragdollPos + dir * force / 2) + Vector(0,0,30))
				end
				local gibType = gibModels[v:GetModel()]
				if gibType and force > 1 then
					v:Remove()
					GAMEMODE:GibEntity(ragdollPos, gibType[2], dir:GetNormalized(), gibType[1])
				end
			end
		end
	end
end)

function GM:PostPlayerDraw(ply)
	local pl = LocalPlayer()
	local actwep = pl:GetActiveWeapon()
	local medkitActive = IsValid(actwep) and actwep:GetClass() == "weapon_healthkit" and table.Count(pl:GetWeapons()) > 1
	if IsValid(ply) and ((!ShowPlayerDist or ShowPlayerDist < RealTime() and !medkitActive) or ply == pl) then
		local Time = ply:GetNWFloat("CallMedicTime") - CurTime()
		if Time > 0 then
			local pos = ply:GetPos()
			local ang = pl:EyeAngles()
			ang:RotateAroundAxis(ang:Forward(), 90)
			ang:RotateAroundAxis(ang:Right(), 90)
			local alert = math.Clamp(math.sin(RealTime() * 20) * 100, 0, 1)
			cam.Start3D2D(pos + Vector(0, 0, 82), Angle(0, ang.y, 90), .8)
				draw.DrawText("MEDIC!", "Trebuchet18", 0, 0, Color(255 * alert, 80 * alert, 0, 255), TEXT_ALIGN_CENTER)
			cam.End3D2D()
		end
	end
end

function GM:PlayerBindPress(ply, bind, pressed)
	if bind == "undo" or bind == "gmod_undo" then
		RunConsoleCommand("callmedic")
	end
end

net.Receive("HL1Music", function()
	local musicFile = net.ReadString()
	if string.len(musicFile) > 0 then
		GAMEMODE:PlayMusic(musicFile)
	else
		GAMEMODE:StopMusic()
	end
end)

local trackDuration = {
	["HL1_Music.track_2"] = 132,
	--["HL1_Music.track_3"] = 134,
	["HL1_Music.track_4"] = 62,
	["HL1_Music.track_5"] = 98,
	["HL1_Music.track_6"] = 102,
	["HL1_Music.track_7"] = 25,
	["HL1_Music.track_8"] = 11,
	["HL1_Music.track_9"] = 95,
	["HL1_Music.track_10"] = 107,
	["HL1_Music.track_11"] = 85,
	["HL1_Music.track_12"] = 130,
	["HL1_Music.track_13"] = 38,
	["HL1_Music.track_14"] = 75,
	["HL1_Music.track_15"] = 121,
	["HL1_Music.track_16"] = 18,
	["HL1_Music.track_17"] = 126,
	["HL1_Music.track_18"] = 102,
	["HL1_Music.track_19"] = 118,
	["HL1_Music.track_20"] = 87,
	["HL1_Music.track_21"] = 87,
	["HL1_Music.track_22"] = 83,
	["HL1_Music.track_23"] = 112,
	["HL1_Music.track_24"] = 79,
	["HL1_Music.track_25"] = 102,
	["HL1_Music.track_26"] = 40,
	["HL1_Music.track_27"] = 19,
	["HL1_Music.track_28"] = 8,
}

local music
local musicDuration
function GM:PlayMusic(musicFile)
	if musicFile then
		local fadeTime = 3.5
		if music and music:IsPlaying() then
			if musicDuration and musicDuration > SysTime() then
				music:FadeOut(fadeTime)
			else
				music:Stop()
			end
		end
		local ply = LocalPlayer()
		if IsValid(ply) then
			music = CreateSound(ply, musicFile)
		end
		if music then
			local dur = trackDuration[musicFile]
			music:PlayEx(cvars.Number("snd_musicvolume", 1), 100)
			if dur then musicDuration = SysTime() + dur - fadeTime end
		end
	end
end
function GM:StopMusic()
	if music and music:IsPlaying() then
		music:Stop()
	end
end

function CanReachNearestTeleport()
	local ply = LocalPlayer()
	local plypos = ply:GetPos()
	if telePosTable then
		table.sort(telePosTable, function(a,b) return a:DistToSqr(plypos) < b:DistToSqr(plypos) end)
		local tr = util.TraceLine({
			start = ply:EyePos(),
			endpos = telePosTable[1],
			filter = ply,
			mask = MASK_SOLID_BRUSHONLY
		})
		return tr.StartPos:Distance(tr.HitPos) >= 1000 or tr.Hit
	end
end

concommand.Add("hl1_coop_version", function()
	print(GAMEMODE.Name.." "..GAMEMODE.Version)
end)