local WeaponReplaceTable = {
	["weapon_crowbar"] = "hl1coop_weprepl_crowbar",
	["weapon_glock"] = "hl1coop_weprepl_glock",
	["weapon_357"] = "hl1coop_weprepl_357",
	["weapon_mp5"] = "hl1coop_weprepl_mp5",
	["weapon_shotgun"] = "hl1coop_weprepl_shotgun",
	["weapon_crossbow"] = "hl1coop_weprepl_crossbow",
	["weapon_rpg"] = "hl1coop_weprepl_rpg",
	["weapon_gauss"] = "hl1coop_weprepl_gauss",
	["weapon_egon"] = "hl1coop_weprepl_egon",
	["weapon_hornetgun"] = "hl1coop_weprepl_hornetgun",
	["weapon_handgrenade"] = "hl1coop_weprepl_handgrenade",
	["weapon_satchel"] = "hl1coop_weprepl_satchel",
	["weapon_tripmine"] = "hl1coop_weprepl_tripmine",
	["weapon_snark"] = "hl1coop_weprepl_snark"
}
for k, v in pairs(WeaponReplaceTable) do
	CreateConVar(v, "", FCVAR_ARCHIVE)
end
concommand.Add("hl1coop_weprepl_reset", function(ply)
	if IsValid(ply) and !ply:IsAdmin() then return end
	for k, v in pairs(WeaponReplaceTable) do
		RunConsoleCommand(v, "")
	end
end)
local AmmoReplaceTable = {
	["ammo_9mmar"] = "hl1coop_ammorepl_mp5clip",
	["ammo_9mmclip"] = "hl1coop_ammorepl_glock",
	["ammo_357"] = "hl1coop_ammorepl_357",
	["ammo_argrenades"] = "hl1coop_ammorepl_mp5grenades",
	["ammo_buckshot"] = "hl1coop_ammorepl_shotgun",
	["ammo_crossbow"] = "hl1coop_ammorepl_crossbow",
	["ammo_gaussclip"] = "hl1coop_ammorepl_gauss",
	["ammo_glockclip"] = "hl1coop_ammorepl_glock",
	["ammo_mp5clip"] = "hl1coop_ammorepl_mp5clip",
	["ammo_mp5grenades"] = "hl1coop_ammorepl_mp5grenades",
	["ammo_rpgclip"] = "hl1coop_ammorepl_rpg"
}
for k, v in pairs(AmmoReplaceTable) do
	CreateConVar(v, "", FCVAR_ARCHIVE)
end
concommand.Add("hl1coop_ammorepl_reset", function(ply)
	if IsValid(ply) and !ply:IsAdmin() then return end
	for k, v in pairs(AmmoReplaceTable) do
		RunConsoleCommand(v, "")
	end
end)
local NPCReplaceTable = {
	["monster_scientist"] = "hl1coop_npcrepl_scientist",
	["monster_barney"] = "hl1coop_npcrepl_barney",
	["monster_babycrab"] = "hl1coop_npcrepl_babycrab",
	["monster_headcrab"] = "hl1coop_npcrepl_headcrab",
	["monster_zombie"] = "hl1coop_npcrepl_zombie",
	["monster_houndeye"] = "hl1coop_npcrepl_houndeye",
	["monster_sentry"] = "hl1coop_npcrepl_sentry",
	["monster_bullchicken"] = "hl1coop_npcrepl_bullsquid",
	["monster_alien_slave"] = "hl1coop_npcrepl_slave",
	["monster_alien_controller"] = "hl1coop_npcrepl_controller",
	["monster_alien_grunt"] = "hl1coop_npcrepl_agrunt",
	["monster_gargantua"] = "hl1coop_npcrepl_garg",
	["monster_human_grunt"] = "hl1coop_npcrepl_hgrunt",
	["monster_human_assassin"] = "hl1coop_npcrepl_assassin",
	["monster_gman"] = "hl1coop_npcrepl_gman",
	["monster_cockroach"] = "hl1coop_npcrepl_cockroach",
	["monster_apache"] = "hl1coop_npcrepl_apache",
	["monster_osprey"] = "hl1coop_npcrepl_osprey"
}
for k, v in pairs(NPCReplaceTable) do
	CreateConVar(v, "", FCVAR_ARCHIVE)
end
concommand.Add("hl1coop_npcrepl_reset", function(ply)
	if IsValid(ply) and !ply:IsAdmin() then return end
	for k, v in pairs(NPCReplaceTable) do
		RunConsoleCommand(v, "")
	end
end)
local npcWeapons = {
	["npc_barney"] = {"weapon_glock", "weapon_mp5"},
	["npc_combine_s"] = {"weapon_mp5", "weapon_shotgun"},
	["npc_metropolice"] = {"weapon_glock", "weapon_mp5"},
	["npc_citizen"] = {"weapon_shotgun", "weapon_mp5"},
	["npc_vj_bmsfri_secruity"] = {"weapon_glock"},
	["npc_vj_bmssold_marines"] = {"weapon_mp5", "weapon_shotgun"},
}

function GM:EntityReplace(ent)
	if ent:IsWeapon() then
		local cvar = WeaponReplaceTable[ent:GetClass()]
		if cvar then cvar = cvars.String(cvar) end
		if cvar and string.len(cvar) > 0 then
			local t = string.Explode(" ", cvar, false)
			cvar = table.Random(t)
			if cvar != ent:GetClass() then
				timer.Simple(0, function()
					if IsValid(ent) then
						local pos, ang, vel, owner = ent:GetPos(), ent:GetAngles(), ent:GetVelocity(), ent:GetOwner()
						ent:Remove()
						ent = ents.Create(cvar)
						if IsValid(ent) then
							ent:SetPos(pos)
							ent:SetAngles(ang)
							ent:SetOwner(owner)
							ent:Spawn()
							local phys = ent:GetPhysicsObject()
							if IsValid(phys) then
								phys:SetVelocity(vel)
							end
						else
							print("Cannot replace a weapon to unknown entity class "..cvar.."!")
						end
					end
				end)
			end
		end
	end
	if string.StartWith(ent:GetClass(), "ammo_") then
		local cvar = AmmoReplaceTable[ent:GetClass()]
		if cvar then cvar = cvars.String(cvar) end
		if cvar and string.len(cvar) > 0 and cvar != ent:GetClass() then
			timer.Simple(0, function()
				if IsValid(ent) then
					local pos, ang, vel, owner = ent:GetPos(), ent:GetAngles(), ent:GetVelocity(), ent:GetOwner()
					local rEnt = ents.Create(cvar)
					if IsValid(rEnt) then
						ent:Remove()
						rEnt:SetPos(pos)
						rEnt:SetAngles(ang)
						rEnt:SetOwner(owner)
						rEnt:Spawn()
						local phys = rEnt:GetPhysicsObject()
						if IsValid(phys) then
							phys:SetVelocity(vel)
						else
							ent:SetVelocity(vel)
						end
					else
						ent.AmmoType = cvar
					end
				end
			end)
		end
	end
	if ent:IsNPC() then
		local cvar = NPCReplaceTable[ent:GetClass()]
		if cvar then cvar = cvars.String(cvar) end
		if cvar and string.len(cvar) > 0 then
			local t = string.Explode(" ", cvar, false)
			cvar = table.Random(t)
			if cvar != ent:GetClass() then
				ent.ReplacedByConVar = true
				timer.Simple(0, function()
					if IsValid(ent) and ent.ReplacedByConVar then
						local pos, ang, vel, name, hp = ent:GetPos(), ent:GetAngles(), ent:GetVelocity(), ent:GetName(), ent:Health()
						local anyply = player.GetAll()[1]
						local rlship = IsValid(anyply) and ent:Disposition(anyply)
						ent:Remove()
						ent = ents.Create(cvar)
						if IsValid(ent) then
							ent.ReplacedByConVar = nil
							if rlship then
								if rlship == 1 then
									rlship = "D_HT"
								elseif rlship == 2 then
									rlship = "D_FR"
								elseif rlship == 3 then
									rlship = "D_LI"
								else
									rlship = "D_NU"
								end
								ent:AddRelationship("player "..rlship)
							end
							ent:SetPos(pos)
							ent:SetAngles(ang)
							ent:SetName(name)
							local equipment = npcWeapons[ent:GetClass()]
							if equipment then
								ent:SetKeyValue("additionalequipment", table.Random(equipment))
							end
							ent:Spawn()
							ent:Activate()
							ent:SetVelocity(vel)
							if ent:Health() == 0 then
								ent:SetHealth(hp)
							end
						else
							print("Cannot replace an NPC to unknown entity class "..cvar.."!")
						end
					end
				end)
			end
		end
		
		--randomizer
		--[[local NPC_Friendly = {
			["monster_scientist"] = true,
			["monster_barney"] = true
		}
		local NPC_Enemy = {
			["monster_babycrab"] = true,
			["monster_headcrab"] = true,
			["monster_zombie"] = true,
			["monster_houndeye"] = true,
			["monster_sentry"] = true,
			["monster_bullchicken"] = true,
			["monster_alien_slave"] = true,
			["monster_alien_controller"] = true,
			["monster_alien_grunt"] = true,
			["monster_gargantua"] = true,
			["monster_human_grunt"] = true,
			["monster_human_assassin"] = true,
			["monster_cockroach"] = true,
		}
		if NPC_Friendly[ent:GetClass()] then
			local _, npc = table.Random(NPC_Friendly)
			if ent:GetClass() != npc then
				timer.Simple(0, function()
					if IsValid(ent) and !ent.Replaced then
						local pos, ang, name = ent:GetPos(), ent:GetAngles(), ent:GetName()
						ent:Remove()
						ent = ents.Create(npc)
						if IsValid(ent) then
							ent:SetPos(pos)
							ent:SetAngles(ang)
							ent:SetName(name)
							ent:Spawn()
							ent.Replaced = true
						end
					end
				end)
			end
		end]]
	end
end