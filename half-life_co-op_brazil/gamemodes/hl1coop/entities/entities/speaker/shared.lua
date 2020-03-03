ENT.Type = "point"
ENT.Author = "Upset"
ENT.Spawnable = false

if CLIENT then

net.Receive("HL1SpeakerSentence", function()
	local sentence, volume = net.ReadString(), net.ReadFloat()
	local ply = LocalPlayer()
	if !IsValid(ply) then return end
	EmitSentence(sentence, ply:GetPos(), ply:EntIndex(), CHAN_VOICE, volume, 45)
	GAMEMODE:ShowCaption("!BMAS_"..sentence)
end)

end