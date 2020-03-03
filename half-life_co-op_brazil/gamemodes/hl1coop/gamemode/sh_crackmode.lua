local screamSnds = {
	"scientist/scream01.wav",
	"scientist/scream02.wav",
	"scientist/scream04.wav",
	"scientist/scream05.wav",
	"scientist/scream06.wav",
	"scientist/scream14.wav",
	"scientist/scream25.wav",
	"scientist/sci_pain1.wav",
	"scientist/sci_pain2.wav",
	"scientist/sci_pain3.wav",
	"scientist/sci_pain4.wav",
	"scientist/sci_pain5.wav",
}

function GM:CrackModeEmitSound(t)
	if GetGlobalBool("ScreamLife") then
		t.Pitch = math.Clamp(t.Pitch + math.random(-10, 15), 10, 255)
		t.SoundName = table.Random(screamSnds)
	else
		t.Pitch = math.Clamp(t.Pitch + math.random(-50, 120), 10, 255)
		if math.random(0, 40) == 0 then
			if IsValid(t.Entity) and !string.StartWith(t.Entity:GetClass(), "func_") then
				t.Pitch = math.random(80, 120)
			end
			t.SoundName = "scientist/scream0"..math.random(1,9)..".wav"
		elseif math.random(0, 50) == 0 then
			if IsValid(t.Entity) and !string.StartWith(t.Entity:GetClass(), "func_") then
				t.Pitch = math.random(70, 130)
			end
			t.SoundName = "scientist/scream"..math.random(10,25)..".wav"
		end
	end
	return true
end

function GM:CrackModeNPCThink(npc)
	if CLIENT then
		local boneJitter = npc:GetNWBool("BoneJitter")
		local boneRotate = npc:GetNWInt("BoneRotate")
		if boneJitter then
			local bonecount = npc:GetBoneCount()
			if bonecount > 0 then
				for i = 0, bonecount do
					npc:ManipulateBonePosition(i, VectorRand())
				end
			end
		end
		if boneRotate and boneRotate > 0 then
			npc:ManipulateBoneAngles(boneRotate, Angle(0, 0, CurTime() * 150 % 360))
		end
	end
end

function GM:CrackModeWeaponSwitch(wep)
	if IsValid(wep) then
		wep.Primary.Delay = util.SharedRandom("CM_wepPrimaryDelay", .05, .5)
		if wep.Primary.DelayHit then
			wep.Primary.DelayHit = util.SharedRandom("CM_wepPrimaryDelayHit", .05,.5)
		end
		wep.Secondary.Delay = util.SharedRandom("CM_wepSecondaryDelay", .05,1)
		wep.ReloadTime = util.SharedRandom("CM_wepReloadTime", .05,.4)
		wep.Primary.DamageCVar = ""
		wep.Secondary.DamageCVar = ""
		wep.Primary.Damage = math.random(0, 100)
		wep.Secondary.Damage = math.random(0, 300)
		if wep.Primary.ClipSize > 0 then
			wep.Primary.ClipSize = math.Round(util.SharedRandom("CM_wepPrimaryClipSize", 1, 100))
		end
		wep.Primary.Recoil = util.SharedRandom("CM_wepPrimaryRecoil", -20, 20)
		wep.Secondary.Recoil = util.SharedRandom("CM_wepSecondaryRecoil", -20, 20)
		wep.Primary.Cone = util.SharedRandom("CM_wepPrimaryCone", .01, .2)
		wep.Secondary.Cone = util.SharedRandom("CM_wepSecondaryCone", .01, .2)
	end
end

if SERVER then

	local funcEnts = {
		["func_door"] = true,
		["func_platrot"] = true,
		["func_train"] = true,
		["func_tracktrain"] = true,
		["func_rotating"] = true,
	}
	local funcEntsBlacklist = {
		["broken_airlock"] = true,
	}
	
	function GM:CrackModeEntCreated(ent)
		local bonecount = ent:GetBoneCount()
		if bonecount > 0 then
			if ent:GetClass() != "gmod_hands" then
				if math.random(0, 1) == 1 then
					for i = 0, bonecount do
						ent:ManipulateBoneScale(i, Vector(1,1,1) + VectorRand() * math.Rand(0,3))
					end
				end
				if math.random(0, 2) == 0 then
					for i = 0, bonecount do
						ent:ManipulateBoneScale(i, ent:GetManipulateBoneScale(i) * math.Rand(.3,2))
					end
				end
				if math.random(0, 1) == 0 then
					local rand = math.Rand(.3,3)
					for i = 0, bonecount do
						ent:ManipulateBoneScale(i, ent:GetManipulateBoneScale(i) * rand)
					end
				end
			end
			local r = math.random(0, 2)
			if r == 2 then
				ent:SetNWBool("BoneJitter", true)
			elseif r == 1 then
				local neck = ent:LookupBone("Bip02 Head")
				if neck then
					ent:ManipulateBonePosition(neck, VectorRand() * 10)
				end
			end
			if math.random(0, 1) == 1 then
				ent:SetNWInt("BoneRotate", math.random(1, bonecount))
			end
		end
		
		if math.random(0, 1) == 1 and !ent:IsTrigger() and (!IsValid(ent:GetParent()) or ent:GetParent():GetClass() != "hl1_teleport") and ent:GetColor().a != 0 then
			ent:SetColor(ColorRand(true))
		end
		
		if funcEnts[ent:GetClass()] and !funcEntsBlacklist[ent:GetName()] then
			local randomspeed = math.random(1, 1000)
			if ent:GetClass() == "func_tracktrain" then
				ent:SetKeyValue("startspeed", math.random(100, 1500))
			else
				timer.Simple(1, function()
					if IsValid(ent) then
						ent:SetKeyValue("speed", randomspeed)
					end
				end)
			end
		end
	end

	local hello = {
		"scientist/hello.wav",
		"scientist/hellothere.wav",
		"scientist/greetings.wav",
		"scientist/greetings2.wav"
	}
	
	local function SpawnGrenade(pos, force, delay)
		local gren = ents.Create("ent_hl1_grenade")
		if IsValid(gren) then
			gren:SetPos(pos)
			gren:Spawn()
			gren:ShootTimed(gren, force, delay)
			gren.IgnoreExpHook = true
			gren:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
		end
	end

	function GM:CrackModeEntityExplosion(ent, pos, radius, dmg)
		pos = pos + Vector(0,0,10)
		if math.random(0, 5) == 0 then
			local sci = ents.Create("monster_scientist")
			if IsValid(sci) then
				sci:SetPos(pos)
				local ang = AngleRand()
				ang[3] = 0
				sci:SetAngles(ang)
				sci:Spawn()
				timer.Simple(math.random(1,5), function()
					if IsValid(sci) then
						sci:EmitSound(table.Random(hello), 90, math.random(90, 110), 1, CHAN_VOICE)
					end
				end)
			end
		end
		if math.random(0,3) == 0 and !ent.IgnoreExpHook then
			for i = 0, math.random(3,30) do
				SpawnGrenade(pos, Vector(0,0,300) + VectorRand() * 300, math.Rand(2,3))
			end
		end
	end
	
	local expEnts = {
		["func_button"] = 5,
		["func_rot_button"] = 8,
		["func_healthcharger"] = 400,
		["func_recharge"] = 360,
		["func_pushable"] = 200,
		["monster_scientist"] = 300,
		["monster_barney"] = 400,
	}
	local ExplosionSounds = {
		Sound("hl1/weapons/explode3.wav"),
		Sound("hl1/weapons/explode4.wav"),
		Sound("hl1/weapons/explode5.wav")
	}
	local function DoExplosion(pos, scale, radius, ent)
		local explosion = EffectData()
		explosion:SetOrigin(pos + Vector(0,0,16))
		explosion:SetScale(scale)
		util.Effect("hl1_explosion", explosion, true, true)
		ent:EmitSound(ExplosionSounds[math.random(1,3)], 400, 100, 1, CHAN_AUTO)
		util.BlastDamage(ent, ent, pos, radius, 8 * scale)
	end
	function GM:CrackModeAcceptInput(ent, input, caller, activator)
		if expEnts[ent:GetClass()] and math.random(0, expEnts[ent:GetClass()]) == 0 then
			DoExplosion(ent:GetPos(), math.random(8, 16), 100, ent)
		end
	end
	
	function GM:CrackModeNPCKilled(npc, attacker, inflictor)
		if math.random(0, 10) == 0 then
			SpawnGrenade(npc:GetPos(), Vector(0,0,100) + VectorRand() * 200, 4)
		end
	end

end