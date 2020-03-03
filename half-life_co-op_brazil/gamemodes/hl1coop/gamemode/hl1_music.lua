local tracks = {
	["HL1_Music.track_2"] = "music/Half-Life01.mp3",
	["HL1_Music.track_3"] = "music/Prospero01_0.mp3",
	["HL1_Music.track_4"] = "music/Half-Life12.mp3",
	["HL1_Music.track_5"] = "music/Half-Life07.mp3",
	["HL1_Music.track_6"] = "music/Half-Life10.mp3",
	["HL1_Music.track_7"] = "music/Suspense01.mp3",
	["HL1_Music.track_8"] = "music/Suspense03.mp3",
	["HL1_Music.track_9"] = "music/Half-Life09.mp3",
	["HL1_Music.track_10"] = "music/Half-Life02.mp3",
	["HL1_Music.track_11"] = "music/Half-Life13.mp3",
	["HL1_Music.track_12"] = "music/Half-Life04.mp3",
	["HL1_Music.track_13"] = "music/Half-Life15.mp3",
	["HL1_Music.track_14"] = "music/Half-Life14.mp3",
	["HL1_Music.track_15"] = "music/Half-Life16.mp3",
	["HL1_Music.track_16"] = "music/Suspense02.mp3",
	["HL1_Music.track_17"] = "music/Half-Life03.mp3",
	["HL1_Music.track_18"] = "music/Half-Life08.mp3",
	["HL1_Music.track_19"] = "music/Prospero02.mp3",
	["HL1_Music.track_20"] = "music/Half-Life05.mp3",
	["HL1_Music.track_21"] = "music/Prospero04.mp3",
	["HL1_Music.track_22"] = "music/Half-Life11.mp3",
	["HL1_Music.track_23"] = "music/Half-Life06.mp3",
	["HL1_Music.track_24"] = "music/Prospero03.mp3",
	["HL1_Music.track_25"] = "music/Half-Life17.mp3",
	["HL1_Music.track_26"] = "music/Prospero05.mp3",
	["HL1_Music.track_27"] = "music/Suspense05.mp3",
	["HL1_Music.track_28"] = "music/Suspense07.mp3",
	["HL1_Music.track_3_0"] = "music/Prospero01_0.mp3",
	["HL1_Music.track_3_a"] = "music/Prospero01_a.mp3",
	["HL1_Music.track_3_b"] = "music/Prospero01_b.mp3",
	["HL1_Music.track_3_c"] = "music/Prospero01_c.mp3",
	["HL1_Music.track_3_d"] = "music/Prospero01_d.mp3"
}

for k,v in pairs(tracks) do
	sound.Add({
		name = k,
		channel = CHAN_STATIC,
		volume = 1,
		level = 0,
		pitch = 100,
		sound = v
	})
	util.PrecacheSound(v)
end