
if CLIENT then

	SWEP.PrintName			= "Medkit"
	SWEP.Author				= "Upset"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 1
	SWEP.WepSelectIcon		= surface.GetTextureID("icons/coop/medkit")
else
	
	util.AddNetworkString("HL1MedkitRevivePlayer")
	util.AddNetworkString("HL1MedkitAnim")

end

game.AddAmmoType({name = "medkit", maxcarry = 100})
if CLIENT then language.Add("medkit_ammo", "Medkit") end

SWEP.Base 				= "weapon_hl1_base"
SWEP.Weight				= 10
SWEP.HoldType			= "slam"
SWEP.UseHands			= true

SWEP.Category			= "Half-Life"
SWEP.Spawnable			= true

SWEP.PlayerModel		= Model("models/weapons/coop/p_medkit.mdl")
SWEP.EntModel			= Model("models/w_medkit.mdl")

SWEP.CModel				= Model("models/weapons/coop/c_medkit.mdl")
SWEP.VModel				= Model("models/weapons/coop/v_medkit.mdl")

SWEP.ViewModel			= SWEP.VModel
SWEP.WorldModel			= SWEP.PlayerModel

SWEP.Primary.Sound			= Sound("HealthKit.Touch")
SWEP.Primary.Damage			= 7
SWEP.Primary.Recoil			= 0
SWEP.Primary.RecoilRandom	= {0, 2}
SWEP.Primary.Delay			= 1
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.MaxAmmo		= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "medkit"

SWEP.Secondary.Delay		= 2
SWEP.Secondary.Automatic	= false

SWEP.SoundDeny				= Sound("WallHealth.Deny")
SWEP.HealAmount				= 20

function SWEP:SpecialDT()
	self:NetworkVar("Float", 2, "RechargeTime")
end

function SWEP:SpecialDeploy()
	if SERVER and IsValid(self.Owner) then
		timer.Simple(1, function()
			if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() and self.Owner:GetActiveWeapon() == self then
				self.Owner:SendScreenHint(4)
			end
		end)
	end
end

function SWEP:SpecialHolster()
	if self:rgAmmo() <= 0 then
		self.Owner:SetAmmo(1, self.Primary.Ammo)
	end
end

function SWEP:PrimaryAttack()
	if self:rgAmmo() <= 0 then return end
	
	if SERVER then self.Owner:LagCompensation(true) end
	local tr = util.TraceHull({
		start = self.Owner:GetShootPos(),
		endpos = self.Owner:GetShootPos() + self.Owner:GetForward() * 40,
		filter = self.Owner,
	})
	if SERVER then self.Owner:LagCompensation(false) end

	if tr.Hit and IsValid(tr.Entity) and (tr.Entity:IsPlayer() and tr.Entity:Health() < tr.Entity:GetMaxHealth() or tr.Entity:GetClass() == "func_healthcharger" and self:rgAmmo() < self.Primary.MaxAmmo) then
		self:SetRechargeTime(CurTime() + 1.5)
		if tr.Entity:GetClass() == "func_healthcharger" then
			if SERVER then
				tr.Entity:Use(self, self, 0, 0)
			end
			self:SetNextPrimaryFire(CurTime() + .1)
			self:SetNextSecondaryFire(CurTime() + .1)
			return
		end
		local heal = math.min(tr.Entity:GetMaxHealth() - tr.Entity:Health(), self.HealAmount)
		if self:rgAmmo() < heal then
			heal = self:rgAmmo()
		end
		self:TakeClipPrimary(heal)
		tr.Entity:SetHealth(tr.Entity:Health() + heal)
		self:WeaponSound()
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		self:SetWeaponIdleTime(CurTime() + math.Rand(10, 15))
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	else
		self:WeaponSound(self.SoundDeny)
		self:SetNextPrimaryFire(CurTime() + .5)
		self:SetNextSecondaryFire(CurTime() + .5)
	end
end

function SWEP:FindDeadPlayer()
	local ply = NULL
	local pos = Vector()
	local ragdoll = NULL
	
	local Ents = ents.FindInBox(self.Owner:WorldSpaceAABB())
	for k, v in pairs(Ents) do
		if v:IsRagdoll() then
			local owner = v:GetRagdollOwner()
			if IsValid(owner) and owner:IsPlayer() and !owner:Alive() then
				ply = owner
				pos = v:GetPos()
				ragdoll = v
				break
			end
		end
	end
	
	return ply, pos, ragdoll
end

function SWEP:SecondaryAttack()
	if self:rgAmmo() <= 0 then return end
	
	local ply, pos, ragdoll = self:FindDeadPlayer()
	
	if self:rgAmmo() >= 50 and IsValid(ply) then
		if IsFirstTimePredicted() then
			timer.Create("MedkitRevive", 2, 1, function()
				if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() and self.Owner:KeyDown(IN_ATTACK2) then
					local ply1, pos1 = self:FindDeadPlayer()
					if IsValid(ply) and IsValid(ply1) and ply1 == ply then
						net.Start("HL1MedkitRevivePlayer")
						net.WriteEntity(ply)
						net.WriteEntity(self)
						net.WriteVector(pos)
						net.SendToServer()
						return
					end
				end
			end)
			net.Start("HL1MedkitAnim")
			net.WriteEntity(self)
			net.SendToServer()
		end
	else
		self:WeaponSound(self.SoundDeny)
	end
	
	self:SetNextPrimaryFire(CurTime() + 1)
	self:SetNextSecondaryFire(CurTime() + 1)
end

function SWEP:SpecialThink()
	if self:Ammo1() < self.Primary.MaxAmmo and self:GetRechargeTime() < CurTime() then
		self.Owner:SetAmmo(self:Ammo1() + 1, self.Primary.Ammo)
		self:SetRechargeTime(self:GetRechargeTime() + 1)
	end
end

function SWEP:WeaponIdle()
	local iAnim
	local flRand = util.SharedRandom("flRand", 0, 1)
	if flRand <= 0.75 then
		iAnim = ACT_VM_IDLE
	else
		iAnim = ACT_VM_FIDGET
	end		
	self:SendWeaponAnim(iAnim)
	self:SetWeaponIdleTime(CurTime() + 6)
end

if SERVER then

net.Receive("HL1MedkitAnim", function(len, ply)
	local wep = net.ReadEntity()
	if IsValid(wep) then
		wep:EmitSound("items/suitchargeok1.wav", 80, 120, .3)
		wep:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		wep:SetWeaponIdleTime(CurTime() + 2)
	end
end)

net.Receive("HL1MedkitRevivePlayer", function(len, ply)
	local pl = net.ReadEntity()
	local wep = net.ReadEntity()
	local pos = net.ReadVector()
	if IsValid(pl) and pl:IsPlayer() and !pl:Alive() and pl:Team() == TEAM_COOP then
		--if pl:IsDeadInSurvival() then -- or medkit is allowed
			hook.Call("PlayerLoadout", GAMEMODE, pl, true)
		--end
		pl:Spawn()
	
		local tr = util.TraceHull({
			start = ply:GetPos(),
			endpos = pos,
			filter = {ply, pl},
			mins = Vector(-16, -16, 0),
			maxs = Vector(16, 16, 72)
		})
		pos = tr.HitPos
		
		if GAMEMODE.FindPosNearPlayer and !ply:GetCustomCollisionCheck() then
			tr = util.TraceHull({
				start = pos,
				endpos = pos,
				filter = pl,
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 72)
			})
			if IsValid(tr.Entity) and tr.Entity:IsPlayer() then
				local randompos = GAMEMODE:FindPosNearPlayer(ply, 64, pl)
				if randompos then
					pos = randompos
				end
			end
		end
		
		pl:SetPos(pos)
		pl:SetHealth(25)
		pl:SetArmor(0)
		pl:EmitSound("Weapon_Gauss.Zap1")
		
		if IsValid(wep) then
			wep:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			wep:SetRechargeTime(CurTime() + 3)
			wep:TakeClipPrimary(50)
			wep:SetNextPrimaryFire(CurTime() + wep.Secondary.Delay)
			wep:SetNextSecondaryFire(CurTime() + wep.Secondary.Delay)
			wep:SetWeaponIdleTime(CurTime() + 2)
		end
	end
end)

end