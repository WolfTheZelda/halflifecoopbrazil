local function RemoveShittyHooks()

	hook.Remove("EntityEmitSound", "HLSNPCs_ReplaceSounds") -- breaks startup screen
	hook.Remove("OnEntityCreated", "HLSNPCs_MinigunFix") -- same
	hook.Remove("KeyPress", "HLSNPCs_PlayerFollow") -- breaks c_ models

	hook.Remove("Initialize", "lf_playermodel_force_hook2")
	
	hook.Remove("Move", "CW_Move") -- breaks movement
	
	hook.Remove("Move", "pac_custom_movement") -- breaks startup screen camera
	if CLIENT then
		hook.Remove("CalcView", "QuakeBobbing") -- duplicate of current CalcView
		hook.Remove("CalcViewModelView", "QuakeGunBobbing") -- same but CalcViewModelView
		hook.Remove("CalcView", "MyCalcView")
		hook.Remove("Think", "GlowToolRender") -- breaks startup screen
		hook.Remove("InitPostEntity", "PGL_lootSystem")
		hook.Remove("HUDPaint", "HP_lootSystem") -- breaks startup screen
		hook.Remove("HUDPaint", "DropWeapon_BindNag")
	else
		hook.Remove("Think", "Splode") -- breaks explosions
		hook.Remove("Think", "CheckForENVExplosion") -- same
		hook.Remove("Think", "SPSThink")
		hook.Remove("EntityTakeDamage", "SPSOnDamage")
		hook.Remove("GetFallDamage", "SPSFallDamage")
		hook.Remove("PlayerInitialSpawn", "SPSUpdateOnSpawnInitial")
		hook.Remove("PlayerSpawn", "SPSUpdateOnSpawn")
		hook.Remove("PlayerSpawn", "walkspawnspeed")
		hook.Remove("PlayerSpawn", "PlayerSpawn")
		hook.Remove("KeyPress", "KeyPress")
		hook.Remove("DoPlayerDeath", "DropWeapon_DoPlayerDeath")
	end
	
end

RemoveShittyHooks()
timer.Simple(1, function()
	RemoveShittyHooks()
end)

if CLIENT then return end

local shit = {
	["167545348"] = true,
}
local nextcheck = RealTime()
function GM:CheckForShittyAddons()
	if nextcheck and nextcheck <= RealTime() then
		for k, v in pairs(engine.GetAddons()) do
			if shit[v.wsid] and v.mounted then
				PrintMessage(HUD_PRINTTALK, "Warning! Game-breaking addon detected: "..v.title.." ("..v.wsid..")")
			end
		end
		nextcheck = RealTime() + 2
	end
end