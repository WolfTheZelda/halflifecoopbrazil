--[[
  Stuff for DyaMetR's GoldSrc HUD 
  You can get it here:
  https://steamcommunity.com/sharedfiles/filedetails/?id=1290525688
]]

local cvar_huddisable = CreateClientConVar("hl1_coop_cl_disablehud", 0, true, false, "Disable HL1 HUD")

if CLIENT and GSRCHUD then
	local function DrawHUD()
		local ply = LocalPlayer()
		if IsValid(ply) then
			return !cvar_huddisable:GetBool() and ply:Team() != TEAM_UNASSIGNED and (ply:GetObserverMode() == OBS_MODE_NONE or IsValid(ply:GetObserverTarget()))
		end
	end
	GSRCHUD:AddGamemodeOverride(GM.FolderName, DrawHUD)
	
	function GSRCHUD:IsDeathScreenEnabled()
		local ply = LocalPlayer()
		return self.DeathScreen:GetInt() > 0 and ply:Team() != TEAM_SPECTATOR and ply:GetObserverMode() == OBS_MODE_NONE and !IsValid(ply:GetObserverTarget()) and !ply:IsChasing()
	end

	-- Weapon icons
	GSRCHUD:AddWeaponIcon("weapon_crowbar", "hl1/icons/crowbar")
	GSRCHUD:AddWeaponIcon("weapon_glock", "hl1/icons/glock")
	GSRCHUD:AddWeaponIcon("weapon_357", "hl1/icons/357")
	GSRCHUD:AddWeaponIcon("weapon_mp5", "hl1/icons/mp5")
	GSRCHUD:AddWeaponIcon("weapon_shotgun", "hl1/icons/shotgun")
	GSRCHUD:AddWeaponIcon("weapon_crossbow", "hl1/icons/crossbow")
	GSRCHUD:AddWeaponIcon("weapon_rpg", "hl1/icons/rpg")
	GSRCHUD:AddWeaponIcon("weapon_gauss", "hl1/icons/gauss")
	GSRCHUD:AddWeaponIcon("weapon_egon", "hl1/icons/egon")
	GSRCHUD:AddWeaponIcon("weapon_hornetgun", "hl1/icons/hgun")
	GSRCHUD:AddWeaponIcon("weapon_handgrenade", "hl1/icons/grenade")
	GSRCHUD:AddWeaponIcon("weapon_satchel", "hl1/icons/satchel")
	GSRCHUD:AddWeaponIcon("weapon_tripmine", "hl1/icons/tripmine")
	GSRCHUD:AddWeaponIcon("weapon_snark", "hl1/icons/snark")

	GSRCHUD:AddWeaponIcon("weapon_healthkit", "icons/coop/medkit")
	local medkit_ammo_icon = surface.GetTextureID("icons/coop/medkit_ammo")
	GSRCHUD:AddCustomSprite("medkit_ammo", medkit_ammo_icon, 18, 18)
	GSRCHUD:AddAmmoIcon("medkit", "medkit_ammo")
	
	-- Small fix for weapon selector so it won't skip throwables
	local throwableWeapons = {["weapon_handgrenade"] = true, ["weapon_satchel"] = true, ["weapon_tripmine"] = true, ["weapon_snark"] = true}
	function GSRCHUD:HasAmmoForWeapon(weapon)
		if !weapon or !IsValid(weapon) or !weapon:IsWeapon() then return false end
		if throwableWeapons[weapon:GetClass()] then return true end
		local PrimaryType = weapon:GetPrimaryAmmoType() or 0
		local SecondaryType = weapon:GetSecondaryAmmoType() or 0
		if (PrimaryType <= 0 and SecondaryType <= 0) then return true end
		local clip = math.Clamp(weapon:Clip1(), 0, 1)
		local primary = math.Clamp(LocalPlayer():GetAmmoCount(weapon:GetPrimaryAmmoType()), 0, 1)
		local secondary = math.Clamp(LocalPlayer():GetAmmoCount(weapon:GetSecondaryAmmoType()), 0, 1)
		return (clip + primary + secondary) > 0
	end
end