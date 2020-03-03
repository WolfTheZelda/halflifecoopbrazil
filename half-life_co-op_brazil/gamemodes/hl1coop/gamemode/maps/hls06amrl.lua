GM.StartingWeapons = {"weapon_crowbar", "weapon_glock", "weapon_shotgun", "weapon_handgrenade", "weapon_mp5", "weapon_357", "weapon_tripmine"}

function GM:CreateViewPoints()
	self:CreateViewPointEntity(Vector(-451, -325, 171), Angle(4, 30, 0))
end

function GM:CreateMapEventCheckpoints(ent, activator)
	if ent:GetName() == "grunt_run1_seq" then
		self:Checkpoint(Vector(1213, 1080, 5), Angle(0, -155, 0), Vector(207, -456, 50), activator)
	end
end

local plyClip

function GM:ModifyMapEntities()
	self:CreateWeaponEntity("weapon_mp5", Vector(-110, -756, 40), Angle(0, 145, 0))
	
	for k, v in pairs(ents.FindByName("tracks10")) do
		v:Remove()
	end

	for k, v in pairs(ents.FindByClass("trigger_auto")) do
		if v:GetKeyValues().globalstate == "c2a1_train_power" then
			v:Remove()
		end
	end
	
	if !self:GetSpeedrunMode() then
		plyClip = ents.Create("hl1_playerclip")
		if IsValid(plyClip) then
			plyClip:Spawn()
			plyClip:SetCollisionBoundsWS(Vector(1280, -705, 0), Vector(896, -775, 256))
		end
	end
end

local hasPlayed
function GM:OperateMapEvents(ent, input, caller, activator)
	if ent:GetClass() == "logic_relay" and ent:GetName() == "logic_relay_open_gate" and input == "Trigger" then
		self:RemovePreviousCheckpoint()
	end
	if ent:GetClass() == "logic_relay" and ent:GetName() == "transformer_gr/red" and input == "Trigger" then
		for k, v in pairs(self:GetActivePlayersTable()) do
			if v != activator then
				v:SendScreenHintTop("#notify_power")
			end
		end
	end
	if ent:GetClass() == "func_wall_toggle" and ent:GetName() == "crate_barrier_w" and input == "Kill" then
		if IsValid(plyClip) then plyClip:Remove() end
	end
	if !hasPlayed and ent:GetClass() == "ambient_generic" and input == "PlaySound" and ent:GetName() == "poweroff_wav" then
		local message = string.Replace(ent:GetSaveTable().message, "!", "!BMAS_")
		self:SendCaption(message, ent:GetPos())
		hasPlayed = true
	end
end