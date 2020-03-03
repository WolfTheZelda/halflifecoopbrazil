GM.BlockSpawnpointCreation = {
	["hls05amrl"] = true
}

GM.StartingWeapons = {"weapon_crowbar", "weapon_glock", "weapon_shotgun", "weapon_handgrenade", "weapon_mp5"}

local tele1pos = Vector(-445, -2620, -955)
local tele2pos = Vector(-3558, -228, -1130)
local tele3pos = Vector(-856, 818, -1350)

function GM:CreateMapEventCheckpoints(ent, activator)
	if ent:GetName() == "c1a4i_tentacle_sci" then
		self:Checkpoint(Vector(8078, 11243, 70), Angle(0, 103, 0), tele1pos, activator)
	end
end

function GM:CreateMapCheckpoints()
	self:CreateCheckpointTrigger(Vector(8399, 11005, -2954), Vector(8879, 11086, -2804), Vector(8340, 10775, -3470), Angle(), {tele1pos, tele2pos, tele3pos})
end

function GM:ModifyMapEntities()
	self:CreateCoopSpawnpoints(Vector(-630, -3535, -990), Angle(0, 90, 0))
	
	self:CreateWeaponEntity("weapon_shotgun", Vector(8660, 11078, 300), Angle(0, 145, 0))
	self:CreateWeaponEntity("weapon_mp5", Vector(8570, 11060, 300), Angle(0, 145, 0))
	self:CreatePickupEntity("item_battery",Vector(8732, 11051, 300), Angle())
	self:CreatePickupEntity("item_battery", Vector(8700, 11051, 300), Angle())
	self:CreatePickupEntity("item_battery", Vector(8668, 11051, 300), Angle())
	self:CreatePickupEntity("item_healthkit", Vector(8620, 11055, 300), Angle(0, 145, 0))
	
	for k, v in pairs(ents.FindByName("tent_barney2")) do
		v:Remove()
	end

	self:CreateFallTrigger(Vector(702, 61, -2418), Vector(-1959, -2615, -2360))
	self:CreateFallTrigger(Vector(-3648, -1402, -5388), Vector(-3239, -1813, -5360)) -- fan
end

local oxy
local fuel

function GM:OperateMapEvents(ent, input, caller, activator)
	if ent:GetClass() == "multi_manager" and ent:GetName() == "init_rocket_fire" and input == "Trigger" then
		self:Checkpoint(Vector(7973, 11450, 70), Angle(), {tele1pos, tele2pos, tele3pos})
	end
	if ent:GetClass() == "logic_relay" and input == "Trigger" then
		if ent:GetName() == "OxyAuto1" then
			oxy = true
		end
		if ent:GetName() == "FuelAuto1" then
			fuel = true
		end
		if oxy and fuel then
			for k, v in pairs(self:GetActivePlayersTable()) do
				if v != activator then
					v:SendScreenHintTop("#notify_oxyfuel")
				end
			end
			oxy = nil
			fuel = nil
		end
	end
	if ent:GetClass() == "env_texturetoggle" and ent:GetName() == "power_indicator_toggle" and input == "IncrementTextureIndex" then
		for k, v in pairs(self:GetActivePlayersTable()) do
			if v != activator then
				v:SendScreenHintTop("#notify_power")
			end
		end
	end
end

function GM:OnMapRestart()
	oxy = nil
	fuel = nil
end