GM.StartingWeapons = {"weapon_crowbar", "weapon_glock", "weapon_shotgun", "weapon_handgrenade", "weapon_mp5"}

function GM:CreateViewPoints()
	self:CreateViewPointEntity(Vector(-1800, 3230, -430), Angle(20, -45, 0))
end

local tele1pos = Vector(-1440, 3050, -860)
local tele2pos = Vector(-870, 3175, -3350)

local skipTrain

function GM:CreateMapCheckpoints()
	self:CreateCheckpointTrigger(Vector(-1607, 2900, -2900), Vector(-1273, 3200, -2985), Vector(-1440, 3250, -3300), Angle(), tele1pos)
	
	local func = function()
		skipTrain = true
	end
	self:CreateCheckpointTrigger(Vector(-633, -1720, -3260), Vector(-671, -1576, -3145), Vector(-751, -1760, -3250), Angle(0,90,0), {tele1pos, tele2pos}, nil, func)
end

function GM:ModifyMapEntities()
	local button = NULL
	for k, v in pairs(ents.FindByName("liftbut1")) do
		if v:GetClass() == "func_button" then
			button = v
			v:Fire("Lock")
		end
	end
	local func = function()
		if IsValid(button) then button:Fire("Unlock") end
	end

	local mins, maxs = Vector(-816, -1026, -3296), Vector(-716, -944, -3226)
	local e_mins, e_maxs = Vector(-857, -1019, -3296), Vector(-635, -806, -3226)
	
	if self:GetSpeedrunMode() then
		mins, maxs = e_mins, e_maxs
	end
	
	local wt = self:CreateWaitTrigger(mins, maxs, 30, false, func, WAIT_FREE, true)
	if !self:GetSpeedrunMode() and IsValid(wt) then
		function wt:StartTouch(ent)
			if ent:IsPlayer() and ent:Alive() then
				wt:SetCollisionBoundsWS(e_mins, e_maxs)
			end
		end
	end
	
	for k, v in pairs(ents.FindByClass("trigger_push")) do
		v:Remove()
	end
	
	for k, v in pairs(ents.FindByClass("func_breakable")) do
		local globalname = v:GetInternalVariable("globalname")
		if globalname != "" and string.StartWith(globalname, "c1a4_breakable_") then
			v:SetSaveValue("globalname", "")
		end
	end
end

function GM:OperateMapEvents(ent, input, activator, caller, value)
	if self:IsCoop() and ent:GetClass() == "path_track" and ent:GetName() == "ridepath28" and input == "InPass" then
		if !skipTrain then
			self:Checkpoint(Vector(908, -3124, -3382), Angle(0, 160, 0), {tele1pos, tele2pos})
		end
		
		local train = caller
		train:SetNotSolid(true)
		timer.Simple(.4, function()
			if IsValid(train) then
				train:SetNotSolid(false)
			end
		end)
		local box = ents.FindInBox(Vector(783, -2969, -3364), Vector(564, -2890, -3320))
		for k, v in pairs(box) do
			if v:IsPlayer() then
				v:SetVelocity(Vector(-770, 0, 680))
			end
		end
	end
end

function GM:OnMapRestart()
	skipTrain = nil
end

function GM:CreateExtraEnemies()
	self:CreateNPCSpawner("monster_headcrab", 3, Vector(-289, -1649, -3245), Angle(0, 180, 0), 500, false)
	self:CreateNPCSpawner("monster_barnacle", 4, Vector(-565, -2005, -2957), Angle(0, 0, 0), 500, false)
	self:CreateNPCSpawner("monster_bullchicken", 5, Vector(-1549, -1224, -3408), Angle(0, 32, 0), 800, false)
end

local trainEnt
function GM:OnEntCreated(ent)
	if ent:GetClass() == "func_tracktrain" then
		timer.Simple(0, function()
			if IsValid(ent) and ent:GetName() == "twain" then
				trainEnt = ent
			end
		end)
	end
end
hook.Add("Think", "05TrainThink", function()
	if IsValid(trainEnt) then
		local vel = trainEnt:GetVelocity():Length2D()
		if vel >= 280 then
			local dmg = trainEnt:GetInternalVariable("dmg")
			local pos = trainEnt:GetPos()
			
			local trpos = pos + trainEnt:GetForward() * 50 + trainEnt:GetRight() * 80
			local tr = util.TraceHull({
				start = trpos,
				endpos = trpos,
				filter = trainEnt,
				mins = Vector(-16, -16, -32),
				maxs = Vector(16, 16, 16)
			})
			
			local trFpos = pos + trainEnt:GetForward() * 50
			local trF = util.TraceHull({
				start = trFpos,
				endpos = trFpos,
				filter = trainEnt,
				mins = Vector(-64, -64, -32),
				maxs = Vector(64, 64, 8)
			})
			
			local function TakeTrainDamage(ent)
				if IsValid(ent) and ent:IsNPC() and ent:Health() > 0 then
					local dmginfo = DamageInfo()
					dmginfo:SetDamage(dmg)
					dmginfo:SetAttacker(trainEnt)
					dmginfo:SetInflictor(trainEnt)
					dmginfo:SetDamageType(DMG_CRUSH)
					ent:TakeDamageInfo(dmginfo)
				end
			end
			
			TakeTrainDamage(tr.Entity)
			TakeTrainDamage(trF.Entity)
		end
	end
end)