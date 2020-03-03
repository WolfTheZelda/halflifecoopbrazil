AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("HL1SpeakerSentence")

local ANNOUNCE_MINUTES_MIN = 0.25	 
local ANNOUNCE_MINUTES_MAX = 2.25

ENT.Presets = {
	[1] = {"C1A0_", 22},
	[2] = {"C1A1_", 11},
	[3] = {"C1A2_", 11},
	[4] = {"C1A3_", 10},
	[5] = {"C1A4_", 8},
	[6] = {"C2A1_", 8},
	[7] = {"C2A2_", 7},
	[8] = {"C2A3_"},
	[9] = {"C2A4_", 12},
	[10] = {"C2A5_"},
	[11] = {"C3A1_", 9},
	[12] = {"C3A2_", 7}
}

function ENT:KeyValue(k, v)
	--print(k, v)
	if k == "preset" then
		self.m_preset = tonumber(v)
	end
	if k == "message" then
		self.message = v
	end
	if k == "delaymin" then
	end
	if k == "delaymax" then
	end
	if k == "radius" then
	end
end

function ENT:Initialize()
	if game.SinglePlayer() then
		for k, v in pairs(ents.FindByClass("speaker")) do
			if k != 1 then -- leaving only one speaker on a map
				v:Remove()
			end
		end
	end

	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)

	if !self:HasSpawnFlags(1) then
		// set first announcement time for random n second
		self:NextThink(CurTime() + math.Rand(5.0, 15.0))
	end
	
	if self.m_preset > 0 and self.Presets[self.m_preset] then
		self.SentenceName = self.Presets[self.m_preset][1]
		self.SentenceCount = self.Presets[self.m_preset][2]
	elseif self.message then
		self.SentenceName = string.Split(self.message, " ")
	end
end

function ENT:Think()
	if GetGlobalBool("FirstLoad") then
		self:NextThink(CurTime() + 30)
		return true
	end
	
	local flvolume = self:Health() * 0.1
	local flattenuation = 0.3
	local flags = 0
	local pitch = 100
	
	--if string.StartWith(self.SentenceName, "!") then
	if self.SentenceCount then		
		// make random announcement from sentence group
		local rand = math.random(0, self.SentenceCount)
		--net.Start("HL1SpeakerSentence")
		--net.WriteString(self.SentenceName..rand)
		--net.WriteFloat(flvolume)
		--net.Broadcast()
		EmitSentence(self.SentenceName..rand, self:GetPos(), self:EntIndex(), CHAN_VOICE, flvolume, 0, flags, pitch)
		GAMEMODE:SendCaption("!BMAS_"..self.SentenceName..rand, self:GetPos())
		self:NextThink(CurTime() + math.Rand(ANNOUNCE_MINUTES_MIN * 60.0, ANNOUNCE_MINUTES_MAX * 60.0))
	end

	return true
end

function ENT:TurnOff()
	self:NextThink(0)
end

function ENT:AcceptInput(inputName, activator, called, data)
end