local cvar_bobstyle = CreateClientConVar("hl1_coop_cl_bobstyle", 1)
local cvar_bobcustom = CreateClientConVar("hl1_coop_cl_bobcustom", 1)

local VIEWBOB_HL1 = 1
local VIEWBOB_WON = 2
local VIEWBOB_REALISTIC = 3
local VIEWBOB_HLS = 4

function GM:CalcBob(ply)
	if !IsValid(ply) then return 0 end
	local cl_bob = cvars.Number("hl1_cl_bob", 0.01)
	local cl_bobcycle = math.max(cvars.Number("hl1_cl_bobcycle", 0.8), 0.1)
	local cl_bobup = cvars.Number("hl1_cl_bobup", 0.5)
	
	if ply:ShouldDrawLocalPlayer() or ply:GetMoveType() == MOVETYPE_NOCLIP then return 0 end

	local cltime = CurTime()
	local cycle = cltime - math.floor(cltime/cl_bobcycle)*cl_bobcycle
	cycle = cycle / cl_bobcycle
	if (cycle < cl_bobup) then
		cycle = math.pi * cycle / cl_bobup
	else
		cycle = math.pi + math.pi*(cycle-cl_bobup)/(1.0 - cl_bobup)
	end

	local velocity = ply:GetVelocity()

	local bob = math.sqrt(velocity[1]*velocity[1] + velocity[2]*velocity[2]) * cl_bob
	bob = bob*0.3 + bob*0.7*math.sin(cycle)
	if (bob > 4) then
		bob = 4
	elseif (bob < -7) then
		bob = -7
	end
	
	return bob
end

local bob = 0
local lasttime = CurTime()
local bobtime = 0

function GM:CalcBobWON(ply)
	if !IsValid(ply) then return 0 end
	local cl_bob = cvars.Number("hl1_cl_bob", 0.01)
	local cl_bobcycle = math.max(cvars.Number("hl1_cl_bobcycle", 0.8), 0.1)
	local cl_bobup = cvars.Number("hl1_cl_bobup", 0.5)

	if (!ply:OnGround() || CurTime() == lasttime) then
		return bob
	end

	lasttime = CurTime()

	local FT = FrameTime()
	if !game.SinglePlayer() then
		if IsFirstTimePredicted() then
			bobtime = bobtime + FT
		end
	else
		bobtime = bobtime + FT		
	end
	local cycle = bobtime - math.floor(bobtime / cl_bobcycle) * cl_bobcycle
	cycle = cycle / cl_bobcycle
	
	if (cycle < cl_bobup) then
		cycle = math.pi * cycle / cl_bobup
	else
		cycle = math.pi + math.pi*(cycle-cl_bobup)/(1.0 - cl_bobup)
	end

	local vel = ply:GetVelocity()
	bob = math.sqrt(vel[1]*vel[1] + vel[2]*vel[2]) * cl_bob
	bob = bob*0.3 + bob*0.7*math.sin(cycle)
	bob = math.Clamp(bob, -7, 4)

	return bob
end

local ModelSelect
local ModelSelectPos = Vector()
local ModelSelectAng = Angle()

function GM:CalcView(ply, pos, ang, fov)
	if GetGlobalBool("FirstLoad") then
		local ispeed = CurTime() * 1
		local iscale = 1
		local iyaw_cycle = 2
		local iroll_cycle = 0.5
		local ipitch_cycle = 1
		local iyaw_level = 0.3
		local iroll_level = 0.1
		local ipitch_level = 0.3
		ang[1] = ang[1] + iscale * math.sin(ispeed * ipitch_cycle) * ipitch_level
		ang[2] = ang[2] + iscale * math.sin(ispeed * iyaw_cycle) * iyaw_level
		ang[3] = ang[3] + iscale * math.sin(ispeed * iroll_cycle) * iroll_level
		
		local view = {}
		view.origin = pos
		view.angles = ang
		view.fov = 75
		view.drawviewer = false

		return view
	end

	local punchangle = ply.punchangle
	if punchangle then
		ang[1] = ang[1] + punchangle[1]
		HL1_DropPunchAngle(FrameTime(), punchangle)
	end
	
	local viewent = ply:GetViewEntity()
	if IsValid(viewent) and viewent:IsPlayer() and viewent != ply then
		local view = {}

		view.origin = viewent:EyePos()
		view.angles = viewent:EyeAngles()
		view.fov = fov
		view.drawviewer = true

		return view
	end
	
	if ModelSelect and ply:Alive() then
		if ply.PreviewModel then
			ply:SetModel(ply.PreviewModel)
		end
		local camAng = Angle(0, ang[2] + 140, 0)
		if ModelSelectAng:IsZero() then
			ModelSelectAng = ang
		end
		ModelSelectAng = LerpAngle(FrameTime() * 2, ModelSelectAng, camAng)
		ang = ModelSelectAng
		local camRight = 50 - ScrW() / 88
		local tr = util.TraceHull({
			start = pos,
			endpos = pos - ang:Forward() * 50 - ang:Up() * 25 + ang:Right() * camRight,
			filter = ply,
			mins = Vector(-5, -5, -5),
			maxs = Vector(5, 5, 5),
			mask = MASK_PLAYERSOLID_BRUSHONLY
		})
		if tr.Fraction < .9 then
			local fixang = ang - tr.HitPos:Angle()
			fixang[3] = 0
			LocalPlayer():SetEyeAngles(fixang)
		end
		if ModelSelectPos:IsZero() then
			ModelSelectPos = tr.StartPos
		end
		ModelSelectPos = LerpVector(FrameTime() * 2, ModelSelectPos, tr.HitPos)
	
		local view = {}

		view.origin = ModelSelectPos
		view.angles = ang
		view.fov = fov
		view.drawviewer = true

		return view
	end
	
	local thirdperson = ply.thirdpersonEnabled
	local wep = ply:GetActiveWeapon()
	local wepzoom = IsValid(wep) and wep.Base == "weapon_hl1_base" and wep:GetInZoom()
	if thirdperson and !wepzoom then
		local startpos = pos --ply:GetPos() + Vector(0,0,64)
		local tr = util.TraceHull({
			start = startpos,
			endpos = startpos + ang:Forward() * -80 + ang:Up() * 15,
			filter = ply,
			mins = Vector(-5, -5, -5),
			maxs = Vector(5, 5, 5),
			mask = MASK_PLAYERSOLID_BRUSHONLY
		})

		if tr.Fraction > .25 then
			pos = tr.HitPos
		
			local view = {}

			view.origin = pos
			view.angles = ang
			view.fov = fov
			view.drawviewer = true

			return view
		end
	end
	
	local specply = ply:GetObserverTarget()
	if IsValid(specply) and ply:GetObserverMode() == OBS_MODE_IN_EYE then
		ply = specply
	end
	
	if cvar_bobcustom:GetBool() then
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep:IsScripted() and wep.Base != "weapon_hl1_base" then
			if wep.CalcView then
				pos, ang, fov = wep:CalcView(ply, pos, ang, fov)
				local view = {}
				view.origin = pos
				view.angles = ang
				view.fov = fov
				view.drawviewer = false
				return view
			elseif wep.GetViewModelPosition and (wep.BobScale == 0 or wep.SwayScale == 0) then
				local view = {}
				view.origin = pos
				view.angles = ang
				view.fov = fov
				view.drawviewer = false
				return view
			end
		end
	end
	
	if ply:IsValid() and ply:Alive() and !ply:InVehicle() and !ply:ShouldDrawLocalPlayer() then
		if cvar_bobstyle:GetInt() != VIEWBOB_HLS then
			if cvar_bobstyle:GetInt() == VIEWBOB_REALISTIC then
				local vel = ply:GetVelocity():Length2D()
		
				local cl_bobmodel_side = .05
				local cl_bobmodel_up = .03
				local cl_bobmodel_speed = 8.25

				local xyspeed = math.Clamp(vel, 0, 800)
				local s = CurTime() * cl_bobmodel_speed
				local bspeed = xyspeed * 0.01

				local bob = bspeed * cl_bobmodel_side * math.sin (s)
				ang:RotateAroundAxis(ang:Up(), -bob)
				bob = bspeed * cl_bobmodel_up * math.cos (s * 2)
				ang:RotateAroundAxis(ang:Right(), -bob)
				ang.r = ang.r - bob
				
				--[[if self.viewang then
					ang:RotateAroundAxis(ang:Up()*.1, -self.viewang[2])
					ang:RotateAroundAxis(ang:Right()*.1, self.viewang[1])
					ang:RotateAroundAxis(ang:Forward()*.1, -self.viewang[3])
				end]]--
			else
				local sign
				
				local cl_rollangle = cvars.Number("hl1_cl_rollangle", 2)
				local cl_rollspeed = cvars.Number("hl1_cl_rollspeed", 200)
				
				local side = ply:GetVelocity():Dot(ply:EyeAngles():Right())
				if side < 0 then
					sign = -1
				else
					sign = 1
				end
				side = math.abs(side)
				
				local value = cl_rollangle
				
				if (side < cl_rollspeed) then
					side = side * value / cl_rollspeed
				else
					side = value
				end
				
				local bob
				if cvar_bobstyle:GetInt() == VIEWBOB_WON then
					bob = self:CalcBobWON(ply)
				else
					bob = self:CalcBob(ply)
				end
				
				if cvars.Bool("hl1_cl_viewbob", true) then
					pos[3] = pos[3] + bob
				end
				ang.r = ang.r + side * sign
			end
		end
	end
	
	local view = {}

	view.origin = pos
	view.angles = ang
	view.fov = fov
	view.drawviewer = false

	return view
end

local swayangles = Angle()
local ground = 0
function GM:CalcViewModelView(wep, vm, oldPos, oldAng, pos, ang)
	if wep:IsScripted() and (wep.Base == "cw_base" or wep.Base == "cw_grenade_base") then
		return pos - ang:Forward() * 32
	end
	if cvar_bobcustom:GetBool() and wep:IsScripted() and wep.Base != "weapon_hl1_base" then
		if wep.CalcViewModelView then
			return wep:CalcViewModelView(vm, oldPos, oldAng, pos, ang)
		elseif wep.GetViewModelPosition and (wep.BobScale == 0 or wep.SwayScale == 0) then
			return wep:GetViewModelPosition(pos, ang)
		end
	end

	local ply = LocalPlayer()
	local specply = ply:GetObserverTarget()
	if IsValid(specply) then
		ply = specply
	end
	if cvar_bobstyle:GetInt() == VIEWBOB_HLS then
		oldPos = pos
		oldAng = ang
	elseif cvar_bobstyle:GetInt() == VIEWBOB_REALISTIC then
		local sign
	
		local cl_rollangle = 2
		local cl_rollspeed = 200
		
		local side = ply:GetVelocity():Dot(ply:EyeAngles():Right())
		if side < 0 then
			sign = -1
		else
			sign = 1
		end	
		side = math.abs(side)
		
		if (side < cl_rollspeed) then
			side = side * cl_rollangle / cl_rollspeed
		else
			side = cl_rollangle
		end

		local vel = ply:GetVelocity():Length2D()
		
		local cl_bobmodel_side = .09
		local cl_bobmodel_up = -.045
		local cl_bobmodel_speed = 8.25
		local cl_viewmodel_fov = IsValid(wep) and wep.ViewModelFOV or 90
		local cl_viewmodel_scale = cl_viewmodel_fov / 90
		local swayscale = cl_viewmodel_fov / 450
		local idlescale = .5

		local xyspeed = math.Clamp(vel, 0, 400)
		local s = CurTime() * cl_bobmodel_speed
		local bspeed = xyspeed * 0.01
		local wepbob_side = bspeed * cl_bobmodel_side * cl_viewmodel_scale * math.sin (s)
		local wepbob_up = bspeed * cl_bobmodel_up * cl_viewmodel_scale * math.cos (s * 2)
		
		if !ply:OnGround() then
			ground = Lerp(FrameTime()*7, ground, .01)
			wepbob_side = wepbob_side * ground
			wepbob_up = wepbob_up * ground
		else
			ground = Lerp(FrameTime()*14, ground, 1)
			wepbob_side = wepbob_side * ground
			wepbob_up = wepbob_up * ground
		end
		
		//sway
		local modelindex = vm:ViewModelIndex()
		if !game.SinglePlayer() and IsFirstTimePredicted() or game.SinglePlayer() or IsValid(specply) then
			swayangles = LerpAngle(FrameTime()*10, swayangles, oldAng)
		end	
		local sway = oldAng - swayangles	
		if wep.ViewModelFlip or modelindex == 1 and wep.ViewModelFlip1 then
			oldAng:RotateAroundAxis(oldAng:Up() * swayscale, sway[2])
			oldAng:RotateAroundAxis(oldAng:Forward() * swayscale/2, sway[2])
		else
			oldAng:RotateAroundAxis(oldAng:Up() * swayscale, -sway[2])
			oldAng:RotateAroundAxis(oldAng:Forward() * swayscale/2, -sway[2])
		end
		oldAng:RotateAroundAxis(oldAng:Right() * swayscale, sway[1])
		
		//bob
		if modelindex == 0 then
			oldPos = oldPos + wepbob_side * oldAng:Right()
		else
			oldPos = oldPos - wepbob_side * oldAng:Right()
		end
		oldAng:RotateAroundAxis(oldAng:Up(), -wepbob_side*2)
		oldPos[3] = oldPos[3] + wepbob_up
		oldAng.r = oldAng.r - wepbob_up + side * sign
		oldAng:RotateAroundAxis(oldAng:Right(), -wepbob_up*6)
		
		//idle drift
		oldAng = oldAng + Angle(math.sin(CurTime()*2)*idlescale, math.sin(CurTime())*idlescale, math.sin(CurTime()*1.5)*idlescale+.5)
		
		oldPos = oldPos - oldAng:Forward() * bspeed*.2 - oldAng:Up() * bspeed*.05
	else
		local bob
		if cvar_bobstyle:GetInt() == VIEWBOB_WON then
			bob = self:CalcBobWON(ply)
		else
			bob = self:CalcBob(ply)
		end
		
		oldPos = oldPos + oldAng:Forward() * bob * .4 - Vector(0, 0, 1)
		if cvars.Bool("hl1_cl_viewbob", true) then
			oldPos[3] = oldPos[3] + bob
		end

		if cvar_bobstyle:GetInt() == VIEWBOB_WON then
			oldAng.p = oldAng.p - bob * 0.3
			oldAng.y = oldAng.y - bob * 0.5
			oldAng.r = oldAng.r - bob * 1.0
		end
	end
	
	if wep.ViewModelOffset then 
		oldPos = oldPos + oldAng:Forward() * wep.ViewModelOffset.PosForward + oldAng:Right() * wep.ViewModelOffset.PosRight + oldAng:Up() * wep.ViewModelOffset.PosUp
		oldAng:RotateAroundAxis(oldAng:Forward(), wep.ViewModelOffset.AngForward)
		oldAng:RotateAroundAxis(oldAng:Right(), wep.ViewModelOffset.AngRight)
		oldAng:RotateAroundAxis(oldAng:Up(), wep.ViewModelOffset.AngUp)
	end
	if wep.HideWhenEmpty and wep.rgAmmo and wep:rgAmmo() <= 0 then -- hide when no ammo left
		oldPos = wep:ViewModelHide(oldPos, oldAng, vm)
	end
	if wep.SetViewModelFOV then
		wep:SetViewModelFOV()
	end

	return oldPos, oldAng
end

function GM:SetPlayerModelView(b)
	if b then
		if !LocalPlayer():Alive() then return end
		ModelSelect = true
		ModelSelectPos = Vector()
		ModelSelectAng = Angle()
	else
		ModelSelect = false
	end
end