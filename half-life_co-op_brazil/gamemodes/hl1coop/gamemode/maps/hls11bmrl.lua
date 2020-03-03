GM.BlockSpawnpointCreation = {
	["hls11amrl"] = true
}

GM.StartingWeapons = {"weapon_crowbar", "weapon_glock", "weapon_357", "weapon_mp5", "weapon_shotgun", "weapon_crossbow", "weapon_rpg", "weapon_gauss", "weapon_handgrenade", "weapon_satchel", "weapon_tripmine", "weapon_snark"}

function GM:CreateViewPoints()
	self:CreateViewPointEntity(Vector(52, 735, -110), Angle(0, -92, 0))
end

function GM:CreateMapCheckpoints()
	self:CreateCheckpointTrigger(Vector(-1984, 2656, -208), Vector(-2256, 2208, 128), Vector(-2108, 2433, -200), Angle(0, -180, 0), Vector(35, -46, 55))
end

function GM:ModifyMapEntities()
	self:CreateCoopSpawnpoints(Vector(45, 560, -156), Angle(0, -90, 0))
	
	self:CreateWeaponEntity("weapon_handgrenade", Vector(779, -616, 90))
	self:CreateWeaponEntity("weapon_shotgun", Vector(-1056, 2160, -87.5), Angle(0,90,0))
	self:CreateWeaponEntity("weapon_mp5", Vector(-1125, 2172, -87.5), Angle(0,10,0))
	self:CreateWeaponEntity("weapon_handgrenade", Vector(-1984, 2208, -200))
	
	for k, v in pairs(ents.FindByClass("func_tank*")) do
		if v:GetName() == "brad_turret" or v:GetName() == "sniper1" or v:GetName() == "sniper2" then
			local cEnt = ents.Create("func_tank_controller")
			if IsValid(cEnt) then
				cEnt:SetParent(v)
				cEnt:SetPos(v:GetPos())
				cEnt:Spawn()
				if v:GetName() == "brad_turret" then
					cEnt.Explosive = true
				end
			end
		end
	end
	
	for k, v in pairs(ents.FindInSphere(Vector(359, 804, -120), 8)) do
		if v:GetClass() == "trigger_once" then
			v:Remove()
		end
	end
	
	if !GetGlobalBool("FirstWaiting") then
		local fTrig = ents.Create("hl1_trigger_func")
		if IsValid(fTrig) then
			fTrig.TouchFunction = function()
				local music = ents.FindByName("music_track_10")[1]
				if IsValid(music) and music:GetClass() == "ambient_generic" then
					music:Fire("PlaySound")
				end
				fTrig:Remove()
			end
			fTrig:Spawn()
			fTrig:SetCollisionBoundsWS(Vector(11, 413, -160), Vector(233, 362, -37))
		end
	end
	
	if !self:GetSpeedrunMode() then
		local plyClip_f = ents.Create("hl1_playerclip")
		if IsValid(plyClip_f) then
			plyClip_f:Spawn()
			plyClip_f:SetCollisionBoundsWS(Vector(-3076, 1472, -63), Vector(-3060, 1888, 40))
		end
		local plyClip_1 = ents.Create("hl1_playerclip")
		if IsValid(plyClip_1) then
			plyClip_1:Spawn()
			plyClip_1:SetCollisionBoundsWS(Vector(-3056, 1471, 192), Vector(-3070, 1248, 400))
		end
		local plyClip_2 = ents.Create("hl1_playerclip")
		if IsValid(plyClip_2) then
			plyClip_2:Spawn()
			plyClip_2:SetCollisionBoundsWS(Vector(-3070, 1248, 400), Vector(-2525, 1216, 192))
		end
		
		local plyClip_f_remove = ents.Create("hl1_trigger_func")
		if IsValid(plyClip_f_remove) then
			plyClip_f_remove.TouchFunction = function()
				if IsValid(plyClip_f) then
					plyClip_f:Remove()
				end
				plyClip_f_remove:Remove()
			end
			plyClip_f_remove:Spawn()
			plyClip_f_remove:SetCollisionBoundsWS(Vector(-3737, 1376, -208), Vector(-3819, 1664, 73))
		end
	end
end

function GM:OnEntCreated(ent)
	if ent:GetClass() == "rpg_missile" then
		--PrintTable(ent:GetSaveTable().m_hOwnerEntity:GetSaveTable())
		ent:SetNoDraw(true)
		timer.Simple(0, function()
			if IsValid(ent) then
				ent:StopSound("Missile.Ignite")
				ent:SetModel("models/rpgrocket.mdl")
				local replaceent = ents.Create("ent_hl1_rpg_rocket")
				if IsValid(replaceent) then
					replaceent:SetPos(ent:GetPos())
					replaceent:SetAngles(ent:GetAngles() - Angle(0,3,0))
					replaceent:SetOwner(ent:GetOwner())
					replaceent:Spawn()
				end
				ent:Remove()
			end
		end)
	end
end