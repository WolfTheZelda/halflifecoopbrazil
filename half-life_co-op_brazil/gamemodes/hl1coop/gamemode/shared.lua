DeriveGamemode("base")
include("sh_chatsounds.lua")
include("sh_entity.lua")
include("sh_player.lua")
include("sh_skill.lua")
include("hl1_music.lua")
include("hl1_soundscripts.lua")
include("conflictfix.lua")
include("sh_crackmode.lua")

local files, dirs = file.Find(GM.FolderName.."/gamemode/maps/*", "LUA")
for k, v in pairs(files) do
	if game.GetMap() == string.StripExtension(v) then
		include("maps/"..v)
		break
	end
end

GM.Name = "Half-Life Co-op"
GM.Author = "Upset"
GM.Email = "themostupset@gmail.com"
GM.Version = "1.3.9"
GM.Changelog = [[- Added more chatsounds
- Fixes for the latest GMod branch]]
GM.Cooperative = true
GM.KickUnreadyPlayerTime = 60

PLAYER_NOTREADY = 1
PLAYER_READY = 2

PRICE_RESPAWN_HERE = 100
PRICE_RESPAWN_FULL = 500
PRICE_LAST_CHECKPOINT = 50

LAST_CHECKPOINT_MINDISTANCE = 1500

IMPORTANT_NPC_HP_SCALE = 4

local hl1_coop_sv_custommodels = CreateConVar("hl1_coop_sv_custommodels", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, "Allow custom player models")
SetGlobalBool("hl1_coop_sv_custommodels", hl1_coop_sv_custommodels:GetBool())
cvars.AddChangeCallback("hl1_coop_sv_custommodels", function(name, value_old, value_new)
	local b = tobool(value_new)
	SetGlobalBool("hl1_coop_sv_custommodels", b)
end)

player_manager.AddValidModel("Helmet (HLS)", "models/player/hl1/helmet.mdl")
player_manager.AddValidModel("Scientist (Einstein)(HLS)", "models/player/hl1/scientist_einstien.mdl")
player_manager.AddValidModel("Scientist (Luther)(HLS)", "models/player/hl1/scientist_luther.mdl")
player_manager.AddValidModel("Scientist (Slick)(HLS)", "models/player/hl1/scientist_slick.mdl")
player_manager.AddValidModel("Scientist (Walter)(HLS)", "models/player/hl1/scientist_walter.mdl")

GM.Chapters = {
	["Anomalous Materials"] = {"hls01amrl"},
	["Unforeseen Consequences"] = {"hls02amrl"},
	["Office Complex"] = {"hls03amrl"},
	["We've Got Hostiles"] = {"hls04amrl"},
	["Blast Pit"] = {"hls05amrl", "hls05bmrl", "hls05cmrl"},
	["Power Up"] = {"hls06amrl"},
	["On A Rail"] = {"hls07amrl", "hls07bmrl"},
	["Apprehension"] = {"hls08amrl"},
	["Residue Processing"] = {"hls09amrl"},
	["Questionable Ethics"] = {"hls10amrl"},
	["Surface Tension"] = {"hls11amrl", "hls11bmrl", "hls11cmrl"},
	["Forget About Freeman!"] = {"hls12amrl"},
	["Lambda Core"] = {"hls13amrl"},
	["Xen"] = {"hls14amrl"},
	["Interloper"] = {"hls14bmrl"},
	["Nihilanth"] = {"hls14cmrl"}
}

function GM:GetChapterName(map)
	map = map or game.GetMap()
	for chapter, maptable in pairs(self.Chapters) do
		if table.HasValue(maptable, map) then
			return chapter
		end
	end
end

function GM:IsFirstMapInChapter(map)
	map = map or game.GetMap()
	for chapter, maptable in pairs(self.Chapters) do
		if maptable[1] == map then
			return true
		end
	end
end

function GM:IsCoop()
	return self.Cooperative and !game.SinglePlayer()
end

function GM:GetSurvivalMode()
	return GetGlobalBool("SurvivalMode")
end
	
function GM:GetSpeedrunMode()
	return GetGlobalBool("SpeedrunMode")
end

function GM:GetCrackMode()
	return GetGlobalBool("CrackMode")
end

function GM:PlayerNoClip(ply, b)
	if ply:GetObserverMode() == OBS_MODE_ROAMING then return false end
	if !b then return true end

	return cvars.Bool("sv_cheats")
end

function GM:GetActivePlayersNumber(alive)
	if self:GetSurvivalMode() or GetGlobalBool("DisablePlayerRespawn") or alive then
		return #self:GetActivePlayersTable(alive)
	else
		return team.NumPlayers(TEAM_COOP)
	end
end

function GM:GetActivePlayersTable(alive)
	if self:GetSurvivalMode() or GetGlobalBool("DisablePlayerRespawn") or alive then
		local t = {}
		for _, pl in pairs(team.GetPlayers(TEAM_COOP)) do
			if pl:Alive() then
				table.insert(t, pl)
			end
		end
		return t
	else
		return team.GetPlayers(TEAM_COOP)
	end
end

GM.GibModels = {
	["models/gibs/hgibs.mdl"] = "models/gibs/hghl1.mdl",
	["models/gibs/agibs.mdl"] = "models/gibs/aghl1.mdl"
}

for _, model in pairs(GM.GibModels) do
	util.PrecacheModel(model)
end

function GM:OnEntityCreated(ent)
	if ent:IsPlayer() then
		ent:InstallDataTable()
		ent:SetupDataTables()
	end
	if (ent:GetClass() == "gib" or ent:GetClass() == "class C_BaseAnimating") and self.GibModels[ent:GetModel()] then
		--ent:PhysicsDestroy()
		ent:SetModel(self.GibModels[ent:GetModel()])
		if CLIENT then
			if ent:GetBodygroup(0) == 0 or ent:GetBodygroup(0) == 1 then
				ent:SetBodygroup(0, math.random(0, ent:GetBodygroupCount(0)))
			end
		end
	end
	if SERVER then
		if IsValid(ent) then
			if ent:IsNPC() then
				if self:IsCoop() then
					if self.ImportantNPCs then
						timer.Simple(0, function()
							if IsValid(ent) and (!self.ImportantHealthBlacklist or !self.ImportantHealthBlacklist[ent:GetName()]) then
								for k, v in pairs(self.ImportantNPCs) do
									if ent:GetName() == v then
										ent:SetHealth(ent:Health() * IMPORTANT_NPC_HP_SCALE)
									end
								end
							end
						end)
					end
					if ent:GetClass() == "hornet" then
						timer.Simple(0, function()
							if IsValid(ent) then
								local owner = ent:GetOwner()
								if IsValid(owner) and owner:IsPlayer() then
									ent:AddRelationship("player D_NU 1")
								end
							end
						end)
					end
				end
				if string.StartWith(ent:GetClass(), "monster_") then
					ent:SetSaveValue("m_fBoneCacheFlags", 1) -- instead of sv_pvsskipanimation 0
				end
				if ent:GetClass() == "monster_barnacle" then
					timer.Simple(0, function()
						if IsValid(ent) then
							local fixent = ents.Create("hl1_barnacle_fix")
							if IsValid(fixent) then
								fixent:SetPos(ent:GetPos() - Vector(0, 0, 1))
								fixent:SetParent(ent)
								fixent:Spawn()
							end
						end
					end)
				end
				self:FixCollisionBounds(ent, "monster_houndeye", Vector(-16, -16, 0), Vector(16, 16, 40))
				self:FixCollisionBounds(ent, "monster_bigmomma", Vector(-24, -24, 0), Vector(24, 24, 130))
				self:FixCollisionBounds(ent, "monster_apache", Vector(-256, -256, -64), Vector(256, 256, 100))
				if monsterDeadTable and monsterDeadTable[ent:GetClass()] then
					timer.Simple(0, function()
						if IsValid(ent) then
							ent:SetSaveValue("m_takedamage", 1)
							ent:SetSolid(SOLID_BBOX)
							ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
							ent:SetPos(ent:GetPos() + Vector(0,0,1))
						end
					end)
				end
				if !self.NPCHealthMultiplierBlacklist[ent:GetClass()] then
					ent:SetLagCompensated(true)
					timer.Simple(0, function()
						if IsValid(ent) then
							--[[local hpCvar = self.NPCHealthConVar[ent:GetClass()]
							if hpCvar then
								ent:SetHealth(cvars.Number(hpCvar, ent:Health()))
							end]]
							if ent:GetClass() == "monster_bigmomma" then
								ent:SetHealth(ent:Health() * cvars.Number("sk_bigmomma_health_factor", 1))
							end							
							ent:SetHealth(ent:Health() * self:NPCHealthMultiplier())
							debugPrint(ent, "health: "..ent:Health(), "mul: "..self:NPCHealthMultiplier())
						end
					end)
				end
			end
	
			if ent:GetClass() == "item_sodacan" then
				timer.Simple(.5, function()
					if IsValid(ent) then
						ent:SetCollisionBounds(Vector(-10, -10, 0), Vector(10, 10, 8))
					end
				end)
			end
		
			-- fix physics for spawning ents from breakables
			if ent:IsWeapon() and ent:IsScripted() then
				for k, v in pairs(self.replaceEntsInBoxes) do
					if ent:GetClass() == v then
						timer.Simple(0, function()
							if IsValid(ent) and ent:GetMoveType() == MOVETYPE_VPHYSICS then
								ent:Initialize()
							end
						end)
					end
				end
			end			
			hook.Run("EntityReplace", ent)
			
			if self:GetCrackMode() then
				timer.Simple(0, function()
					if IsValid(ent) then
						hook.Run("CrackModeEntCreated", ent)
					end
				end)
			end
		end
		hook.Run("OnEntCreated", ent)
	end
end

function GM:CreateTeams()

	if GAMEMODE.Deathmatch then
		TEAM_DEATHMATCH = 1
		team.SetUp( TEAM_DEATHMATCH, "DM Player", Color( 0, 0, 255 ) )
		team.SetSpawnPoint( TEAM_DEATHMATCH, "info_player_deathmatch" )
	else
		TEAM_COOP = 1
		team.SetUp( TEAM_COOP, "Coop Mate", Color( 255, 150, 0 ) )
		team.SetSpawnPoint( TEAM_COOP, "info_player_coop" )
	end
	team.SetSpawnPoint( TEAM_SPECTATOR, "worldspawn" )

end

function GM:ShouldCollide(ent1, ent2)
	--TODO: fix player bullets when friendlyfire is enabled
	if IsValid(ent1) and IsValid(ent2) and ent1:IsPlayer() and (ent2:IsPlayer() or IsValid(ent2:GetOwner()) and ent2:GetOwner():IsPlayer() and ent2:GetOwner():Team() == ent1:Team()) then return false end

	if ent1.ShouldCollide and ent1:ShouldCollide(ent2) or ent2.ShouldCollide and ent2:ShouldCollide(ent1) then return false end
	
	return true
end

local movekeys = {
	[IN_ATTACK] = true,
	[IN_ATTACK2] = true,
	[IN_BACK] = true,
	[IN_DUCK] = true,
	[IN_FORWARD] = true,
	[IN_JUMP] = true,
	[IN_LEFT] = true,
	[IN_MOVELEFT] = true,
	[IN_MOVERIGHT] = true,
	[IN_RIGHT] = true
}

function GM:KeyPress(ply, key)
	if SERVER and !GetGlobalBool("FirstLoad") and !GetGlobalBool("FirstWaiting") and ply:Team() == TEAM_COOP then
		if movekeys[key] then
			if !ply.canTakeDamage then
				ply.canTakeDamage = true
			end
		end
		if cvar_afktime:GetBool() then
			ply.afkTime = SysTime()
		end
	end
	if CLIENT and IsFirstTimePredicted() and ply:IsSpectator() then
		hook.Run("SpectatorKeyPress", ply, key)
	end
end

function GM:OnPlayerHitGround(ply, bInWater, bOnFloater, flFallSpeed)

	-- Apply damage and play collision sound here
	-- then return true to disable the default action
	--MsgN( ply, bInWater, bOnFloater, flFallSpeed )
	--return true

end

function GM:CalcMainActivity( ply, velocity )

	ply.CalcIdeal = ACT_MP_STAND_IDLE
	ply.CalcSeqOverride = -1

	self:HandlePlayerLanding( ply, velocity, ply.m_bWasOnGround )
	
	-- workaround by ZehMatt
	if SERVER then
		ply:SetNW2Vector("ActAbsVelocity", velocity)
	else
		if ply != LocalPlayer() then
			velocity = ply:GetNW2Vector("ActAbsVelocity", velocity)
		end
	end

	if ( self:HandlePlayerNoClipping( ply, velocity ) ||
		self:HandlePlayerDriving( ply ) ||
		self:HandlePlayerVaulting( ply, velocity ) ||
		self:HandlePlayerJumping( ply, velocity ) ||
		self:HandlePlayerSwimming( ply, velocity ) ||
		self:HandlePlayerDucking( ply, velocity ) ) then

	else

		local len2d = velocity:Length2DSqr()
		if ( len2d > 22500 ) then ply.CalcIdeal = ACT_MP_RUN elseif ( len2d > 0.25 ) then ply.CalcIdeal = ACT_MP_WALK end

	end

	ply.m_bWasOnGround = ply:IsOnGround()
	ply.m_bWasNoclipping = ( ply:GetMoveType() == MOVETYPE_NOCLIP && !ply:InVehicle() )

	return ply.CalcIdeal, ply.CalcSeqOverride

end

function GM:PlayerStepSoundTime( ply, iType, bWalking )

	local fStepTime = 350
	local fMaxSpeed = ply:GetMaxSpeed()
	local dir = ply:GetVelocity():GetNormalized():Dot(ply:GetForward())

	if ( iType == STEPSOUNDTIME_NORMAL || iType == STEPSOUNDTIME_WATER_FOOT ) then
		
		if ( fMaxSpeed <= 100 ) then
			fStepTime = 450
			if dir < 0 then
				fStepTime = fStepTime / 1.25
			end
		elseif ( fMaxSpeed <= 300 ) then
			fStepTime = 350
		else
			fStepTime = 320
		end
	
	elseif ( iType == STEPSOUNDTIME_ON_LADDER ) then
	
		fStepTime = 450
	
	elseif ( iType == STEPSOUNDTIME_WATER_KNEE ) then
	
		fStepTime = 600
	
	end
	
	-- Step slower if crouching
	if ( ply:Crouching() ) then
		fStepTime = fStepTime + 50
	end
	
	return fStepTime
	
end

function GM:UpdateAnimation( ply, velocity, maxseqgroundspeed )

	local len = velocity:Length()
	local movement = 1.0

	if ( len > 300 ) then
		movement = ( len / maxseqgroundspeed / 1.75 )
	elseif ( len <= 300 ) then
		movement = ( len / maxseqgroundspeed / 1.2)
	end

	local rate = math.min( movement, 2 )
	
	if ply:Crouching() then
		rate = 1.35
	end

	-- if we're under water we want to constantly be swimming..
	if ( ply:WaterLevel() >= 2 ) then
		rate = math.max( rate, 0.5 )
	elseif ( !ply:IsOnGround() && len >= 1000 ) then
		rate = 0.1
	end

	ply:SetPlaybackRate( rate )

	if ( CLIENT ) then
		GAMEMODE:GrabEarAnimation( ply )
		GAMEMODE:MouthMoveAnimation( ply )
	end

end

function GM:SetupMove(ply, move, cmd)
	if ply:Alive() and ply:GetMoveType() == MOVETYPE_WALK and !ply:OnGround() and ply:WaterLevel() < 1 then
		local plyTable = player.GetAll()
		local tr = util.TraceHull({
			start = move:GetOrigin(),
			endpos = move:GetOrigin(),
			filter = plyTable, -- is it ok to do this
			mask = MASK_PLAYERSOLID,
			mins = Vector(-16, -16, 0),
			maxs = Vector(16, 16, 72)
		})
		if !tr.Hit then
			if !ply:Crouching() and cmd:KeyDown(IN_DUCK) then
				tr = util.TraceHull({
					start = move:GetOrigin(),
					endpos = move:GetOrigin() - Vector(0,0,16),
					filter = plyTable,
					mask = MASK_PLAYERSOLID,
					mins = Vector(-16, -16, 0),
					maxs = Vector(16, 16, 72)
				})
				move:SetOrigin(tr.HitPos)
				if tr.Hit then
					move:SetOrigin(move:GetOrigin() - Vector(0,0,16))
				end
			end
			if ply:Crouching() and move:KeyReleased(IN_DUCK) then
				tr = util.TraceHull({
					start = move:GetOrigin(),
					endpos = move:GetOrigin() + Vector(0,0,16),
					filter = plyTable,
					mask = MASK_PLAYERSOLID,
					mins = Vector(-16, -16, 0),
					maxs = Vector(16, 16, 72)
				})
				move:SetOrigin(tr.HitPos)
			end
		end
	end

	-- barnacle
	if ply:GetMoveType() == 4 then
		ply:SetMoveType(MOVETYPE_NONE)
		move:SetVelocity(Vector(0,0,0))
	end

	if self.NewChapterDelay and self.NewChapterDelay > CurTime() then
		move:SetMaxClientSpeed(0.1)
	end
	
	if ply:OnGround() and move:KeyDown(IN_USE) then
		local vel = move:GetVelocity()
		vel.x = vel.x / 64
		vel.y = vel.y / 64
		move:SetVelocity(vel)
	end
	
	if ply:GetNW2Bool("LongJump") and !ply:Crouching() and move:GetMaxClientSpeed() >= 1 then
		if move:KeyPressed(IN_DUCK) then
			ply.LongJumpTime = CurTime() + .25
		end
		if ply.LongJumpTime and ply.LongJumpTime > CurTime() and move:KeyPressed(IN_JUMP) and move:GetForwardSpeed() > 10 and ply:OnGround() then
			local vel = ply:GetForward()
			local newvel = vel * 550
			move:SetVelocity(newvel)
			ply:SetViewPunchAngles(Angle(3.5, 0, 0))
		end
	end
end

--[[function GM:FinishMove(ply, mv)
	if GetGlobalBool("FirstLoad") and ply:Team() == TEAM_UNASSIGNED then
		return true
	end
end]]

local lastMusicEnt
function GM:EntityEmitSound(t)
	if SERVER then
		local ent = t.Entity
		local name = t.OriginalSoundName
		if string.StartWith(name, "HL1_Music") then
			if !IsValid(lastMusicEnt) or lastMusicEnt != ent then
				self:PlayGlobalMusic(name)
			end
			lastMusicEnt = ent
			return false
		end

		if ent:IsNPC() then
			self:SendCaption(name, ent:GetPos())
		end		
	end
	
	if self:GetCrackMode() then
		return hook.Run("CrackModeEmitSound", t)
	end
end

local entUseBlacklist = {
	["gib"] = true,
	["hl1_playerclip"] = true
}
local entUseFix = {
	["func_tank"] = true,
	["func_tankmortar"] = true
}

function GM:FindUseEntity(ply, ent)
	if !IsValid(ent) then
		local tr = util.TraceHull({
			start = ply:EyePos(),
			endpos = ply:EyePos() + ply:GetAimVector() * 64,
			filter = ply,
			mask = MASK_SHOT_HULL,
			mins = Vector(-16, -16, -16),
			maxs = Vector(16, 16, 16)
		})
		if IsValid(tr.Entity) and entUseFix[tr.Entity:GetClass()] then
			ent = tr.Entity
		end
	end
	if IsValid(ent) and ent.MaxUseDistance then
		local dist = ent:GetPos():DistToSqr(ply:EyePos())
		if dist > ent.MaxUseDistance then
			ent = NULL
		end
	end
	if ply:KeyPressed(IN_USE) then
		if IsValid(ent) and !entUseBlacklist[ent:GetClass()] then
			ply:EmitSound("common/wpn_select.wav", 60, 100, .5)
			if self.NPCUseFix and ent:IsNPC() and self.NPCUseFix[ent:GetName()] then
				return -- prevents script breaking
			end
		else
			ply:EmitSound("player/suit_denydevice.wav", 60, 100, .5)
		end
	end
	return ent
end

local bulletFixEnts = {
	["func_tank"] = true,
	["monster_sentry"] = true,
	["monster_miniturret"] = true,
	["monster_turret"] = true,
}

function GM:EntityFireBullets(ent, data)
	if bulletFixEnts[ent:GetClass()] then
		data.HullSize = 1
		return true
	end
	if SERVER and cvar_fixnihilanth:GetBool() then
		data.Callback = function(attacker, tr, dmginfo)
			local trEnt = tr.Entity
			if IsValid(trEnt) and trEnt:GetClass() == "monster_nihilanth" then
				local m_irritation = trEnt:GetInternalVariable("m_irritation")
				if m_irritation and m_irritation >= 2 then
					if !(tr.HitBox == 3 and tr.HitGroup == 2) then
						dmginfo:ScaleDamage(0)
					end
				end
			end
		end
		return true
	end
end

function GM:PlayerPostThink(ply)
	if SERVER and ply:IsFlagSet(FL_ONTRAIN) then
		local m_iPos = ply:GetInternalVariable("m_iTrain")
		local nw = ply:GetNW2Int("m_iTrain")
		if nw != m_iPos and m_iPos <= 5 then
			ply:SetNW2Int("m_iTrain", m_iPos)
		end
	end
end

local defaultHands = {
	["models/player/hl1/helmet.mdl"] = true,
	["models/player/hl1/player.mdl"] = true,
	["models/player/hl1/holo.mdl"] = true
}

function GM:ApplyViewModelHands(ply, wep)
	ply = ply or LocalPlayer()
	wep = wep or IsValid(ply) and ply:GetActiveWeapon()
	if IsValid(wep) and (wep.CModel and wep.VModel or wep.CModelSatchel and wep.CModelRadio and wep.VModelSatchel and wep.VModelRadio) then
		local modelname = ply:GetModel() == "models/player.mdl" and player_manager.TranslatePlayerModel(ply:GetInfo("hl1_coop_cl_playermodel")) or ply:GetModel()
		if GetGlobalBool("hl1_coop_sv_custommodels", false) and !defaultHands[modelname] then
			if wep.CModelSatchel and wep.CModelRadio then
				wep.ModelSatchelView = wep.CModelSatchel
				wep.ModelRadioView = wep.CModelRadio
				if wep.ViewModel == wep.VModelSatchel then
					wep.ViewModel = wep.CModelSatchel
				end
			else
				wep.ViewModel = wep.CModel
			end
			wep.UseHands = true
		else
			if wep.VModelSatchel and wep.VModelRadio then
				wep.ModelSatchelView = wep.VModelSatchel
				wep.ModelRadioView = wep.VModelRadio
				if wep.ViewModel == wep.CModelSatchel then
					wep.ViewModel = wep.VModelSatchel
				end
			else
				wep.ViewModel = wep.VModel
			end
			wep.UseHands = false
		end
		if !IsValid(ply:GetActiveWeapon()) then
			local vm = ply:GetViewModel()
			if IsValid(vm) and vm:GetModel() != wep.ViewModel then
				vm:SetModel(wep.ViewModel)
			end
		end
	end
end

function GM:PlayerSwitchWeapon(ply, oldWep, newWep)
	if ply.UseEntity and IsValid(ply.UseEntity) then
		return true
	end
	if newWep:IsScripted() then
		if SERVER then
			net.Start("ApplyViewModelHands")
			net.WriteEntity(newWep)
			net.Send(ply)
			timer.Simple(1, function()
				if IsValid(newWep) and ply:GetActiveWeapon() == newWep then
					net.Start("ApplyViewModelHands")
					net.WriteEntity(newWep)
					net.Send(ply)
				end
			end)
			if !IsValid(oldWep) and newWep.Primary.ClipSize == -1 then
				timer.Simple(0, function()
					if IsValid(newWep) and ply:GetActiveWeapon() == newWep then
						newWep:CallOnClient("Deploy")
						newWep:Deploy()
					end
				end)
			end
		end
		self:ApplyViewModelHands(ply, newWep)
		
		if self:GetCrackMode() then
			hook.Run("CrackModeWeaponSwitch", newWep)
		end
	end

end