local cvar = CreateClientConVar("hl1_coop_cl_fixmapspecular", 1, true, false, "Remove most of unnecessary/weird-looking envmaps for map textures\nRequires map restart")

concommand.Add("removeenvmap", function()
	local texture = LocalPlayer():GetEyeTrace().HitTexture
	local mat = Material(texture)
	mat:SetUndefined("$envmap")
	mat:Recompute()
	print(texture)
	SetClipboardText(texture)
end)

cvars.AddChangeCallback("hl1_coop_cl_fixmapspecular", function(name, value_old, value_new)
	local b = tobool(value_new)
	if b then
		GAMEMODE:FixMapSpecular()
	else
		print("Settings will be applied after map restart")
	end
end)

function GM:FixMapSpecular()
	if cvar:GetBool() then
		local list = {
			"halflife/c1a0_labflre",
			"HALFLIFE/C1A0_LABW4",
			"HALFLIFE/C1A0_LABW5",
			"HALFLIFE/C1A0_LABW6",
			"HALFLIFE/C1A0_LABW7",
			"HALFLIFE/C1A0_LABW8",
			"HALFLIFE/C1A0_LABFLRD",
			"HALFLIFE/C1A0B_DR4",
			"HALFLIFE/C1A0B_DR4B",
			"halflife/c1a1_flr1",
			"HALFLIFE/C1A1_FLR2B",
			"HALFLIFE/C1A1_FLR2C",
			"HALFLIFE/C1A1DOOREDGE",
			"HALFLIFE/LAB1_B4",
			"HALFLIFE/LAB1_BRD8",
			"HALFLIFE/LAB1_BRD10",
			"HALFLIFE/LAB1_COMP10A",
			"HALFLIFE/LAB1_COMP10F",
			"HALFLIFE/LAB1_DOOR2A",
			"HALFLIFE/LAB1_DOOR2B",
			"HALFLIFE/LAB1_STAIR2A",
			"HALFLIFE/-0FIFTIES_F02",
			"HALFLIFE/-0FIFTIES_F03B",
			"HALFLIFE/FIFTIES_CEIL03",
			"HALFLIFE/FIFTIES_CMP1B",
			"HALFLIFE/FIFTIES_CMP1C",
			"HALFLIFE/FIFTIES_CMP3A2",
			"HALFLIFE/FIFTIES_CMP3B",
			"HALFLIFE/FIFTIES_CMP4B",
			"HALFLIFE/FIFTIES_CMP4E",
			"HALFLIFE/FIFTIES_CMP5",
			"HALFLIFE/FIFTIES_FLR03",
			"HALFLIFE/FIFTIES_FLR5",
			"HALFLIFE/TABLE2",
			"HALFLIFE/GENERIC015S",
			"HALFLIFE/GENERIC015U",
			"HALFLIFE/GENERIC015V",
			"HALFLIFE/GENERIC116",
			"HALFLIFE/GENERIC89A",
			"HALFLIFE/GENERIC028C",
			"HALFLIFE/OUT_VNT",
			"HALFLIFE/OUT_W8DR1",
			"HALFLIFE/ELEV1",
			"HALFLIFE/ELEV1_TRIM",
			"HALFLIFE/ELEV2_DR",
			"HALFLIFE/-0C2A4_VAT1",
			"HALFLIFE/GENERIC105",
			"HALFLIFE/GENERIC105A",
			"HALFLIFE/GENERIC106",
			"HALFLIFE/GENERIC106A",
			"HALFLIFE/FIFTIES_CMP3C",
			"HALFLIFE/NWBARREL",
		}
		for k, v in pairs(list) do
			local mat = Material(v)
			if !mat:IsError() then
				mat:SetUndefined("$envmap")
				mat:Recompute()
			end
		end
	end
end