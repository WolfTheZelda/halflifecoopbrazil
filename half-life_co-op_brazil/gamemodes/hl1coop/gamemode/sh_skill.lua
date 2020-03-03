SKILL_LEVEL = {
	[1] = "Easy",
	[2] = "Normal",
	[3] = "Hard",
	[4] = "Very Hard",
	[666] = "Insane"
}

function GM:GetSkillLevel()
	return GetGlobalInt("Skill")
end

if CLIENT then return end

local skill_cvar = CreateConVar("hl1_coop_sv_skill", 2, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Skill level")

local SkillConVarsEasy = {
	["sk_hl1barney_health"] = "35",
	["sk_hl1headcrab_health"] = "5",
	["sk_headcrab_dmg_bite"] = "10",
	["sk_hl1zombie_health"] = "50",
	["sk_hl1zombie_dmg_one_slash"] = "10",
	["sk_hl1zombie_dmg_both_slash"] = "25",
	["sk_islave_health"] = "30",
	["sk_islave_dmg_claw"] = "8",
	["sk_islave_dmg_clawrake"] = "25",
	["sk_islave_dmg_zap"] = "10",
	["sk_bullsquid_health"] = "40",
	["sk_bullsquid_dmg_bite"] = "15",
	["sk_bullsquid_dmg_whip"] = "25",
	["sk_bullsquid_dmg_spit"] = "10",
	["sk_hgrunt_health"] = "50",
	["sk_hgrunt_kick"] = "5",
	["sk_hgrunt_pellets"] = "3",
	["sk_hgrunt_gspeed"] = "400",
	["sk_hl1ichthyosaur_health"] = "200",
	["sk_ichthyosaur_shake"] = "20",
	["sk_gargantua_health"] = "800",
	["sk_gargantua_dmg_slash"] = "10",
	["sk_gargantua_dmg_fire"] = "3",
	["sk_gargantua_dmg_stomp"] = "50",
	["sk_snark_health"] = "2",
	["sk_snark_dmg_bite"] = "10",
	["sk_snark_dmg_pop"] = "5",
	["sk_nihilanth_health"] = "1500", --old value: 800
	["sk_nihilanth_zap"] = "30",
	["sk_agrunt_health"] = "60",
	["sk_agrunt_dmg_punch"] = "10",
	["sk_controller_health"] = "60",
	["sk_controller_dmgzap"] = "15",
	["sk_controller_speedball"] = "650",
	["sk_controller_dmgball"] = "3",
	["sk_hassassin_health"] = "30",
	["sk_turret_health"] = "50",
	["sk_miniturret_health"] = "40",
	["sk_sentry_health"] = "40",
	["sk_leech_health"] = "2",
	["sk_leech_dmg_bite"] = "2",
	["sk_bigmomma_health_factor"] = "1.0",
	["sk_bigmomma_dmg_slash"] = "50",
	["sk_bigmomma_dmg_blast"] = "100",
	["sk_bigmomma_radius_blast"] = "250",
	--["sk_npc_dmg_hornet"] = "4",
	--["sk_npc_dmg_9mm"] = "5",
	--["sk_npc_dmg_9mmAR_bullet"] = "3",
	--["sk_npc_dmg_12mm_bullet"] = "8",
	["sk_suitcharger"] = "75",
	["sk_battery"] = "15",
	["sk_healthcharger"] = "50",
	["sk_healthkit"] = "15",
	["sk_scientist_heal"] = "25",
	["sk_barnacle_bite"] = "10",
	["sk_apache_health"] = "150",
	["sk_houndeye_health"] = "20",
}

local SkillConVarsNormal = {
	["sk_hl1barney_health"] = "35",
	["sk_hl1headcrab_health"] = "10",
	["sk_headcrab_dmg_bite"] = "10",
	["sk_hl1zombie_health"] = "50",
	["sk_hl1zombie_dmg_one_slash"] = "20",
	["sk_hl1zombie_dmg_both_slash"] = "40",
	["sk_islave_health"] = "30",
	["sk_islave_dmg_claw"] = "10",
	["sk_islave_dmg_clawrake"] = "25",
	["sk_islave_dmg_zap"] = "10",
	["sk_bullsquid_health"] = "40",
	["sk_bullsquid_dmg_bite"] = "25",
	["sk_bullsquid_dmg_whip"] = "35",
	["sk_bullsquid_dmg_spit"] = "10",
	["sk_hgrunt_health"] = "50",
	["sk_hgrunt_kick"] = "10",
	["sk_hgrunt_pellets"] = "5",
	["sk_hgrunt_gspeed"] = "600",
	["sk_hl1ichthyosaur_health"] = "200",
	["sk_ichthyosaur_shake"] = "35",
	["sk_gargantua_health"] = "800",
	["sk_gargantua_dmg_slash"] = "30",
	["sk_gargantua_dmg_fire"] = "5",
	["sk_gargantua_dmg_stomp"] = "100",
	["sk_snark_health"] = "2",
	["sk_snark_dmg_bite"] = "10",
	["sk_snark_dmg_pop"] = "5",
	["sk_nihilanth_health"] = "2000", --old value: 800
	["sk_nihilanth_zap"] = "30",
	["sk_agrunt_health"] = "90",
	["sk_agrunt_dmg_punch"] = "20",
	["sk_controller_health"] = "60",
	["sk_controller_dmgzap"] = "25",
	["sk_controller_speedball"] = "800",
	["sk_controller_dmgball"] = "4",
	["sk_hassassin_health"] = "50",
	["sk_turret_health"] = "50",
	["sk_miniturret_health"] = "40",
	["sk_sentry_health"] = "40",
	["sk_leech_health"] = "2",
	["sk_leech_dmg_bite"] = "2",
	["sk_bigmomma_health_factor"] = "1.5",
	["sk_bigmomma_dmg_slash"] = "60",
	["sk_bigmomma_dmg_blast"] = "120",
	["sk_bigmomma_radius_blast"] = "250",
	--["sk_npc_dmg_hornet"] = "5",
	--["sk_npc_dmg_9mm"] = "5",
	--["sk_npc_dmg_9mmAR_bullet"] = "4",
	--["sk_npc_dmg_12mm_bullet"] = "10",
	["sk_suitcharger"] = "50",
	["sk_battery"] = "15",
	["sk_healthcharger"] = "40",
	["sk_healthkit"] = "15",
	["sk_scientist_heal"] = "25",
	["sk_barnacle_bite"] = "15",
	["sk_apache_health"] = "250",
	["sk_houndeye_health"] = "20",
}

local SkillConVarsHard = {
	["sk_hl1barney_health"] = "35",
	["sk_hl1headcrab_health"] = "20",
	["sk_headcrab_dmg_bite"] = "10",
	["sk_hl1zombie_health"] = "100",
	["sk_hl1zombie_dmg_one_slash"] = "20",
	["sk_hl1zombie_dmg_both_slash"] = "40",
	["sk_islave_health"] = "60",
	["sk_islave_dmg_claw"] = "10",
	["sk_islave_dmg_clawrake"] = "25",
	["sk_islave_dmg_zap"] = "15",
	["sk_bullsquid_health"] = "120",
	["sk_bullsquid_dmg_bite"] = "25",
	["sk_bullsquid_dmg_whip"] = "35",
	["sk_bullsquid_dmg_spit"] = "15",
	["sk_hgrunt_health"] = "80",
	["sk_hgrunt_kick"] = "10",
	["sk_hgrunt_pellets"] = "6",
	["sk_hgrunt_gspeed"] = "800",
	["sk_hl1ichthyosaur_health"] = "400",
	["sk_ichthyosaur_shake"] = "50",
	["sk_gargantua_health"] = "1000",
	["sk_gargantua_dmg_slash"] = "30",
	["sk_gargantua_dmg_fire"] = "5",
	["sk_gargantua_dmg_stomp"] = "100",
	["sk_snark_health"] = "2",
	["sk_snark_dmg_bite"] = "10",
	["sk_snark_dmg_pop"] = "5",
	["sk_nihilanth_health"] = "3000", --old value: 1000
	["sk_nihilanth_zap"] = "50",
	["sk_agrunt_health"] = "120",
	["sk_agrunt_dmg_punch"] = "20",
	["sk_controller_health"] = "100",
	["sk_controller_dmgzap"] = "35",
	["sk_controller_speedball"] = "1000",
	["sk_controller_dmgball"] = "5",
	["sk_hassassin_health"] = "50",
	["sk_turret_health"] = "60",
	["sk_miniturret_health"] = "50",
	["sk_sentry_health"] = "50",
	["sk_leech_health"] = "2",
	["sk_leech_dmg_bite"] = "2",
	["sk_bigmomma_health_factor"] = "2",
	["sk_bigmomma_dmg_slash"] = "70",
	["sk_bigmomma_dmg_blast"] = "160",
	["sk_bigmomma_radius_blast"] = "275",
	--["sk_npc_dmg_hornet"] = "8",
	--["sk_npc_dmg_9mm"] = "8",
	--["sk_npc_dmg_9mmAR_bullet"] = "5",
	--["sk_npc_dmg_12mm_bullet"] = "10",
	["sk_suitcharger"] = "35",
	["sk_battery"] = "10",
	["sk_healthcharger"] = "25",
	["sk_healthkit"] = "10",
	["sk_scientist_heal"] = "25",
	["sk_barnacle_bite"] = "20",
	["sk_apache_health"] = "400",
	["sk_houndeye_health"] = "30",
}

local SkillConVarsVeryHard = {
	["sk_hl1barney_health"] = "40",
	["sk_hl1headcrab_health"] = "40",
	["sk_headcrab_dmg_bite"] = "30",
	["sk_hl1zombie_health"] = "150",
	["sk_hl1zombie_dmg_one_slash"] = "40",
	["sk_hl1zombie_dmg_both_slash"] = "80",
	["sk_islave_health"] = "120",
	["sk_islave_dmg_claw"] = "20",
	["sk_islave_dmg_clawrake"] = "50",
	["sk_islave_dmg_zap"] = "30",
	["sk_bullsquid_health"] = "180",
	["sk_bullsquid_dmg_bite"] = "40",
	["sk_bullsquid_dmg_whip"] = "60",
	["sk_bullsquid_dmg_spit"] = "15",
	["sk_hgrunt_health"] = "140",
	["sk_hgrunt_kick"] = "10",
	["sk_hgrunt_pellets"] = "6",
	["sk_hgrunt_gspeed"] = "800",
	["sk_hl1ichthyosaur_health"] = "500",
	["sk_ichthyosaur_shake"] = "70",
	["sk_gargantua_health"] = "1500",
	["sk_gargantua_dmg_slash"] = "30",
	["sk_gargantua_dmg_fire"] = "5",
	["sk_gargantua_dmg_stomp"] = "100",
	["sk_snark_health"] = "2",
	["sk_snark_dmg_bite"] = "10",
	["sk_snark_dmg_pop"] = "5",
	["sk_nihilanth_health"] = "6000",
	["sk_nihilanth_zap"] = "50",
	["sk_agrunt_health"] = "160",
	["sk_agrunt_dmg_punch"] = "20",
	["sk_controller_health"] = "140",
	["sk_controller_dmgzap"] = "50",
	["sk_controller_speedball"] = "1500",
	["sk_controller_dmgball"] = "10",
	["sk_hassassin_health"] = "80",
	["sk_turret_health"] = "90",
	["sk_miniturret_health"] = "80",
	["sk_sentry_health"] = "80",
	["sk_leech_health"] = "2",
	["sk_leech_dmg_bite"] = "2",
	["sk_bigmomma_health_factor"] = "4",
	["sk_bigmomma_dmg_slash"] = "70",
	["sk_bigmomma_dmg_blast"] = "160",
	["sk_bigmomma_radius_blast"] = "275",
	--["sk_npc_dmg_hornet"] = "8",
	--["sk_npc_dmg_9mm"] = "8",
	--["sk_npc_dmg_9mmAR_bullet"] = "5",
	--["sk_npc_dmg_12mm_bullet"] = "10",
	["sk_suitcharger"] = "30",
	["sk_battery"] = "10",
	["sk_healthcharger"] = "20",
	["sk_healthkit"] = "10",
	["sk_scientist_heal"] = "25",
	["sk_barnacle_bite"] = "40",
	["sk_apache_health"] = "600",
	["sk_houndeye_health"] = "40",
}

local SkillConVarsInsane = {
	["sk_hl1barney_health"] = "40",
	["sk_hl1headcrab_health"] = "80",
	["sk_headcrab_dmg_bite"] = "50",
	["sk_hl1zombie_health"] = "300",
	["sk_hl1zombie_dmg_one_slash"] = "50",
	["sk_hl1zombie_dmg_both_slash"] = "90",
	["sk_islave_health"] = "150",
	["sk_islave_dmg_claw"] = "30",
	["sk_islave_dmg_clawrake"] = "60",
	["sk_islave_dmg_zap"] = "40",
	["sk_bullsquid_health"] = "250",
	["sk_bullsquid_dmg_bite"] = "40",
	["sk_bullsquid_dmg_whip"] = "60",
	["sk_bullsquid_dmg_spit"] = "15",
	["sk_hgrunt_health"] = "220",
	["sk_hgrunt_kick"] = "10",
	["sk_hgrunt_pellets"] = "6",
	["sk_hgrunt_gspeed"] = "1800",
	["sk_hl1ichthyosaur_health"] = "700",
	["sk_ichthyosaur_shake"] = "90",
	["sk_gargantua_health"] = "2000",
	["sk_gargantua_dmg_slash"] = "50",
	["sk_gargantua_dmg_fire"] = "10",
	["sk_gargantua_dmg_stomp"] = "150",
	["sk_snark_health"] = "2",
	["sk_snark_dmg_bite"] = "10",
	["sk_snark_dmg_pop"] = "5",
	["sk_nihilanth_health"] = "12000",
	["sk_nihilanth_zap"] = "50",
	["sk_agrunt_health"] = "200",
	["sk_agrunt_dmg_punch"] = "20",
	["sk_controller_health"] = "140",
	["sk_controller_dmgzap"] = "60",
	["sk_controller_speedball"] = "1500",
	["sk_controller_dmgball"] = "20",
	["sk_hassassin_health"] = "110",
	["sk_turret_health"] = "110",
	["sk_miniturret_health"] = "100",
	["sk_sentry_health"] = "100",
	["sk_leech_health"] = "4",
	["sk_leech_dmg_bite"] = "5",
	["sk_bigmomma_health_factor"] = "8",
	["sk_bigmomma_dmg_slash"] = "70",
	["sk_bigmomma_dmg_blast"] = "160",
	["sk_bigmomma_radius_blast"] = "275",
	--["sk_npc_dmg_hornet"] = "8",
	--["sk_npc_dmg_9mm"] = "8",
	--["sk_npc_dmg_9mmAR_bullet"] = "5",
	--["sk_npc_dmg_12mm_bullet"] = "10",
	["sk_suitcharger"] = "25",
	["sk_battery"] = "5",
	["sk_healthcharger"] = "15",
	["sk_healthkit"] = "5",
	["sk_scientist_heal"] = "25",
	["sk_barnacle_bite"] = "50",
	["sk_apache_health"] = "1000",
	["sk_houndeye_health"] = "60",
}

-- missing/broken HP convars
--[[GM.NPCHealthConVar = {
	["monster_alien_slave"] = "sk_islave_health",
	["monster_human_grunt"] = "sk_hgrunt_health",
	["monster_alien_grunt"] = "sk_agrunt_health",
	["monster_bullchicken"] = "sk_bullsquid_health",
	["monster_zombie"] = "sk_zombie_health",
	["monster_barney"] = "sk_barney_health",
}]]

function GM:GetSkillTable(num)
	num = num or self:GetSkillLevel()
	local skillTable = SkillConVarsNormal
	if num == 1 then
		skillTable = SkillConVarsEasy
	elseif num == 2 then
		skillTable = SkillConVarsNormal
	elseif num == 3 then
		skillTable = SkillConVarsHard
	elseif num == 4 then
		skillTable = SkillConVarsVeryHard
	elseif num == 666 then
		skillTable = SkillConVarsInsane
	end
	return skillTable
end
	
--[[function GM:GetSkillLevel()
	local cvarNum = skill_cvar:GetInt()
	return SKILL_LEVEL[cvarNum] and cvarNum or cvars.Number("skill")
end]]--

function GM:SetSkillLevel(num)
	num = num or skill_cvar:GetInt()
	local skillOld = self:GetSkillLevel()
	local skillLevel = SKILL_LEVEL[num]
	if skillLevel then
		if num != 666 then
			PrintMessage(HUD_PRINTTALK, "Difficulty has been set to "..skillLevel)
		else
			PrintMessage(HUD_PRINTTALK, "Difficulty has been set to INSANE, WHAT'S WRONG WITH YOU?!")
		end
	else
		return
	end
	local skillTable = self:GetSkillTable(num)
	
	RunConsoleCommand("skill", num)
	
	if skillTable then
		for k, v in pairs(skillTable) do
			if !ConVarExists(k) then
				CreateConVar(k, v)
			end
			RunConsoleCommand(k, v)
		end
	end
	
	SetGlobalInt("Skill", num)
	
	timer.Simple(1, function()
		self:AdjustNPCHealth(skillOld)
	end)
end

cvars.AddChangeCallback("hl1_coop_sv_skill", function(name, value_old, value_new)
	local num = tonumber(value_new)
	if SKILL_LEVEL[num] then
		GAMEMODE:SetSkillLevel(num)
	elseif num > 4 then
		RunConsoleCommand(name, 4)
	end
end)