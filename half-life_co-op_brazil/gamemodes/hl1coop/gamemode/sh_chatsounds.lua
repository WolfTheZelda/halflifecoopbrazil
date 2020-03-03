local chatsounds = {
	--common
	["hello"] = {"barney/hellonicesuit.wav", "scientist/hello.wav", "scientist/hellothere.wav"},
	["go"] = {true, "barney/letsgo.wav", "scientist/letsgo.wav"},
	["let's go"] = {"barney/letsgo.wav", "scientist/letsgo.wav"},
	
	--barney
	
	["step off buddy"] = "barney/ba_stepoff.wav",
	["bad feeling"] = "barney/badfeeling.wav",
	["beer"] = "barney/ba_later.wav",
	["be quiet"] = "barney/bequiet.wav",
	["die"] = {true, "barney/diebloodsucker.wav"},
	["die you"] = "barney/diebloodsucker.wav",
	["don't ask me"] = "barney/dontaskme.wav",
	["eat this"] = "barney/c1a4_ba_octo4.wav",
	["hard to say"] = "barney/hardtosay.wav",
	["hello sir"] = "barney/howyoudoing.wav",
	["maybe"] = "barney/maybe.wav",
	["nope"] = "barney/nope.wav",
	["yup"] = "barney/yup.wav",
	["no sir"] = "barney/nosir.wav",
	["yes sir"] = "barney/yessir.wav",
	["no way"] = "barney/noway.wav",
	["stop"] = "barney/donthurtem.wav",
	["got one"] = "barney/ba_gotone.wav",
	["got another one"] = "barney/ba_another.wav",
	["you talk too much"] = "barney/youtalkmuch.wav",
	["cya"] = {true, "barney/seeya.wav"},
	["see ya"] = "barney/seeya.wav",
	["see later"] = "barney/seeya.wav",
	["what the hell"] = "barney/whatisthat.wav",
	["get here"] = "barney/c2a4_ba_steril.wav",
	["get in here"] = "barney/c2a4_ba_steril.wav",
	["stand back"] = "barney/standback.wav",
	["what is going on"] = "barney/whatsgoingon.wav",
	["what's going on"] = "barney/whatsgoingon.wav",
	["heeeey aaaaaah"] = "barney/c1a4_ba_octo3.wav",
	["can we do this later"] = "barney/ba_raincheck.wav",
	["that was close"] = "barney/ba_close.wav",
	
	--sci
	
	["hello there"] = "scientist/hellothere.wav",
	["hello?"] = {true, "scientist/hello2.wav"},
	["alright"] = "scientist/alright.wav",
	["all right"] = "scientist/alright.wav",
	["as i expected"] = "scientist/asexpected.wav",
	["ahem"] = "scientist/c1a0_sci_stall.wav",
	["cough"] = "scientist/cough.wav",
	["fool"] = "scientist/c3a2_sci_fool.wav",
	["ah freeman"] = "scientist/ahfreeman.wav",
	["freeman"] = "scientist/freeman.wav",
	["idk"] = "scientist/dontknow.wav",
	["i don't know"] = "scientist/dontknow.wav",
	["i really don't know"] = "scientist/dontknow.wav",
	["good to see"] = "scientist/goodtoseeyou.wav",
	["get out"] = "scientist/c1a2_sci_1zomb.wav",
	["run man"] = "scientist/c1a2_sci_1zomb.wav",
	["hungry"] = "scientist/hungryyet.wav",
	["i believe so"] = "scientist/ibelieveso.wav",
	["i don't think so"] = "scientist/idontthinkso.wav",
	["i hear something"] = "scientist/ihearsomething.wav",
	["i'll wait"] = "scientist/illwait.wav",
	["you can't be serious"] = "scientist/cantbeserious.wav",
	["donuts"] = "scientist/donuteater.wav",
	["coffee cup"] = "scientist/seencup.wav",
	["glasses"] = "scientist/hideglasses.wav",
	["ties"] = "scientist/weartie.wav",
	["blood samples"] = "scientist/bloodsample.wav",
	["another headcrab"] = "scientist/seeheadcrab.wav",
	["odd"] = "scientist/thatsodd.wav",
	["ridiculous"] = "scientist/ridiculous.wav",
	["asking me"] = "scientist/whyaskme.wav",
	["stop asking"] = "scientist/stopasking.wav",
	["grant money"] = "scientist/nogrant.wav",
	["how interesting"] = "scientist/howinteresting.wav",
	["look at that"] = "scientist/howinteresting.wav",
	["did you hear that"] = "scientist/didyouhear.wav",
	["not certain"] = "scientist/notcertain.wav",
	["i have no doubt"] = "scientist/nodoubt.wav",
	["i'm not sure"] = "scientist/notsure.wav",
	["i'm sure"] = "scientist/imsure.wav",
	["i'm leaving"] = "scientist/sorryimleaving.wav",
	["let me help"] = "scientist/letmehelp.wav",
	["you are leaving"] = "scientist/leavingme.wav",
	["completely wrong"] = "scientist/completelywrong.wav",
	["don't go that way"] = "scientist/dontgothere.wav",
	["perhaps"] = "scientist/perhaps.wav",
	["positively"] = "scientist/positively.wav",
	["theoretically"] = "scientist/theoretically.wav",
	["inconclusive"] = "scientist/inconclusive.wav",
	["absolutely"] = "scientist/absolutely.wav",
	["absolutely not"] = "scientist/absolutelynot.wav",
	["greetings"] = {"scientist/greetings.wav", "scientist/greetings2.wav"},
	["no"] = {true, "scientist/noo.wav"},
	["noo"] = {true, "scientist/nooo.wav"},
	["nooo"] = "scientist/c1a2_sci_5zomb.wav",
	["noooo"] = {"scientist/sci_fear13.wav", "scientist/scream10.wav", "scientist/sci_pain10.wav"},
	["nooooo"] = "scientist/sci_pain2.wav",
	["no please"] = "scientist/noplease.wav",
	["get back"] = "scientist/sci_fear14.wav",
	["stay back gordon"] = "scientist/c1a0_sci_stayback.wav",
	["oh no"] = {"scientist/sci_fear6.wav", "scientist/startle5.wav", "scientist/startle6.wav", "scientist/startle7.wav", "scientist/startle8.wav", "scientist/startle9.wav"},
	["stap"] = {"scientist/sci_pain3.wav", "scientist/scream11.wav", "scientist/scream12.wav"},
	["stahp"] = "scientist/sci_pain3.wav",
	["staph"] = "scientist/sci_pain3.wav",
	["darg"] = "scientist/sci_pain1.wav",
	["oh my"] = {true, "scientist/sci_fear11.wav"},
	["doomed"] = "scientist/c1a3_sci_silo2a.wav",
	["i predicted this"] = "scientist/ipredictedthis.wav",
	["i'll stay here"] = "scientist/istay.wav",
	["lead the way"] = "scientist/leadtheway.wav",
	["let's try this"] = "scientist/letstrythis.wav",
	["ofc"] = "scientist/ofcourse.wav",
	["of course"] = "scientist/ofcourse.wav",
	["of course not"] = "scientist/ofcoursenot.wav",
	["ofc not"] = "scientist/ofcoursenot.wav",
	["yes"] = {"scientist/yes.wav", "scientist/yes2.wav", "scientist/yes3.wav", "scientist/yees.wav"},
	["yes ok"] = "scientist/yesok.wav",
	["lower your voice"] = "scientist/lowervoice.wav",
	["shut up"] = {"scientist/shutup.wav", "scientist/shutup2.wav"},
	["over here"] = {"scientist/overhere.wav", "scientist/c3a2_sci_1glu.wav"},
	["sneeze"] = "scientist/sneeze.wav",
	["right"] = "scientist/right.wav",
	["put that down"] = "scientist/c2a4_sci_2tau.wav",
	["it's ready"] = "scientist/c3a2_sci_portopen.wav",
	["go now"] = "scientist/c3a2_sci_portopen.wav",
	["a fellow scientist"] = "scientist/afellowsci.wav",
	["wait a minute"] = "scientist/letyouin.wav",
	["i'll let you in"] = "scientist/letyouin.wav",
	["what are you doing"] = "scientist/whatyoudoing.wav",
	["argh"] = {"scientist/sci_die1.wav", "scientist/sci_die2.wav", "scientist/sci_die3.wav", "scientist/sci_die4.wav", "scientist/sci_dragoff.wav"},
	["oh dear"] = "scientist/sci_fear7.wav",
	["my goodness"] = "scientist/sci_fear12.wav",
	["ok let's get out"] = "scientist/okgetout.wav",
	["who can say"] = "scientist/whocansay.wav",
	["looks nominal"] = "scientist/allnominal.wav",
	["i hope you know what you are doing"] = "scientist/okihope.wav",
	["you repeat yourself"] = "scientist/repeat.wav",
	["status report"] = "scientist/statusreport.wav",
	["peculiar odor"] = "scientist/peculiarodor.wav",
	["stench"] = "scientist/stench.wav",
	["this should help"] = "scientist/thiswillhelp.wav",
	["something you should see"] = "scientist/ushouldsee.wav",
	["what to do next"] = "scientist/whatnext.wav",
	["who is responsible"] = "scientist/whoresponsible.wav",
	["why you leaving"] = "scientist/whyleavehere.wav",
	["you look terrible"] = {"scientist/youlookbad.wav", "scientist/youlookbad2.wav"}, 
	["you need medic"] = "scientist/youneedmedic.wav",
	["you have been wounded"] = "scientist/youwounded.wav",
	["uaah"] = "scientist/sci_fear4.wav",
	["gnuuh"] = "scientist/sci_fear5.wav",
	["whooh"] = "scientist/sci_fear1.wav",
	["whah"] = "scientist/sci_pain4.wav",
	["agh"] = "scientist/sci_pain5.wav",
	["ooh"] = "scientist/sci_fear3.wav",
	["oooh"] = "scientist/sci_fear2.wav",
	["ah ah ah"] = "scientist/scream07.wav",
	["ah aah"] = "scientist/scream22.wav",
	["aah agh"] = "scientist/scream03.wav",
	["ahh"] = {true, "scientist/startle1.wav"},
	["aah"] = "scientist/scream17.wav",
	["aaah"] = "scientist/scream09.wav",
	["aaaah"] = "scientist/scream20.wav",
	["aa"] = {"scientist/scream18.wav", "scientist/scream19.wav", "scientist/scream16.wav"},
	["aaa"] = "scientist/scream15.wav",
	["aaaa"] = {"scientist/scream14.wav", "scientist/sci_fear8.wav"},
	["aaaaa"] = "scientist/scream25.wav",
	["aaaaaa"] = "scientist/scream01.wav",
	["aaaaaaa"] = {"scientist/scream02.wav", "scientist/scream06.wav"},
	["aaaaaaaa"] = "scientist/scream05.wav",
	["don't worry"] = "hl1chatsounds/dontworry.wav",
	["hurry up"] = "hl1chatsounds/hurryup.wav",
	["excellent"] = {true, "hl1chatsounds/excellent.wav"},
	["you fool"] = "hl1chatsounds/youfool.wav",
	["who are you"] = "hl1chatsounds/whoareyou.wav",
	["sooo"] = "hl1chatsounds/sooo.wav",
	["fascinating"] = {true, "hl1chatsounds/fascinating.wav"},
	["madness"] = {true, "hl1chatsounds/madness.wav"},
	["this is madness"] = "hl1chatsounds/madness.wav",
	["well"] = {true, "hl1chatsounds/well.wav", "hl1chatsounds/well1.wav", "hl1chatsounds/well2.wav"},
	["nobody tell gabe"] = "hl1chatsounds/donttellgabe.wav",
	
	--hgrunt
	
	["bogies"] = "hgrunt/bogies.wav",
	["bogies!"] = "hgrunt/bogies!.wav",
	["shit"] = "hgrunt/shit.wav",
	["shit!"] = "hgrunt/shit!.wav",
	["hahaha"] = "hgrunt/c2a3_hg_laugh.wav",
	["lol"] = {true, "hgrunt/c2a3_hg_laugh.wav"},
	
	--gman
	
	["time to choose"] = {"gman/gman_choose1.wav", "gman/gman_choose2.wav"},
	
	--holo
	["fantastic"] = "holo/tr_holo_fantastic.wav",
	["nice job"] = "holo/tr_holo_nicejob.wav",
	["great work"] = "hl1chatsounds/greatwork.wav",
	
	--misc
	["hi"] = {true, "vox/high.wav"},
	["ok"] = {true, "vox/ok.wav"},
	["ding"] = {true, "plats/elevbell1.wav"},
	--["cricket"] = "ambience/cricket.wav",
	["mmmm"] = "hl1chatsounds/mmmm.wav",
	
	--op4/tfc
	["ass"] = {true, "fgrunt/ass.wav"},
	["medic"] = {true, "fgrunt/medic.wav", "speech/saveme1.wav", "speech/saveme2.wav"},
	
	-- hl alpha
	["beat"] = {true, "hl1chatsounds/hoot5.wav"},
	["jazz"] = {true, "hl1chatsounds/hoot6.wav"},
}
	
local repltable = {
	["dont"] = "don't",
	["cant"] = "can't",
	["its"] = "it's",
	["lets"] = "let's",
	["whats"] = "what's",
	["im"] = "i'm",
	["ill"] = "i'll",
	["you're"] = "you are",
	["you've"] = "you have",
}

local function ReplaceAp(str)
	for k, v in pairs(string.Split(str, " ")) do
		if repltable[v] then
			str = string.Replace(str, v, repltable[v])
		end
	end
	return str
end

if CLIENT then

	local cvar_cl_chatsounds = CreateClientConVar("hl1_coop_cl_chatsounds", 1, true, false, "Enable chatsounds for client")

	net.Receive("PlayChatsound", function()
		if cvar_cl_chatsounds:GetBool() and IsValid(LocalPlayer()) then
			LocalPlayer():EmitSound(net.ReadString(), 0, net.ReadUInt(9), .5)
		end
	end)
	
	concommand.Add("chatsoundlist", function(ply)
		for k, v in SortedPairs(chatsounds) do
			ply:PrintMessage(HUD_PRINTCONSOLE, k.."\n")
		end
	end)
	
	local phrases = {}
	local chosenPhrase
	function GM:StartChat(isTeam)
		chosenPhrase = 0
	end
	function GM:ChatTextChanged(text)
		if phrases and !table.HasValue(phrases, text) then
			chosenPhrase = 0
			phrases = nil
		end
	end
	
	function GM:OnChatTab(text)
		text = string.TrimRight(text)
		if string.len(text) > 0 then
			local str = ReplaceAp(string.lower(text))
			
			--[[local LastWord
			for word in string.gmatch( str, "[^ ]+" ) do
				LastWord = word
			end]]--
			
			if !phrases then
				phrases = {}
			end
			if phrases then
				if #phrases == 0 then
					for k, v in SortedPairs(chatsounds) do
						local strfind = string.find(k, str, 1, true)
						if strfind == 1 then
							if !table.HasValue(phrases, k) then
								table.insert(phrases, k)
							end
						end
					end
				end
				if #phrases > 0 then
					if chosenPhrase == 0 or chosenPhrase == #phrases then
						chosenPhrase = 1
						if #phrases > 1 and phrases[chosenPhrase] == str then
							chosenPhrase = chosenPhrase + 1
						end
					else
						chosenPhrase = chosenPhrase + 1
					end

					if chosenPhrase then
						return phrases[chosenPhrase]
					end
				end
			end
		end
		
		return text
	end

else

	local cvar_sv_chatsounds = CreateConVar("hl1_coop_sv_chatsounds", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
	util.AddNetworkString("PlayChatsound")

	function GM:PlayerSayChatsound(ply, text, team)
		if cvar_sv_chatsounds:GetBool() then
			if (ply:Alive() or ply:Team() == TEAM_UNASSIGNED) and (!ply.NextChatsoundTime or ply.NextChatsoundTime <= CurTime()) then
				local sound = nil
				local pitch = math.random(93, 110)
				local str = ReplaceAp(string.lower(text))
				local spos, epos = string.find(str, "%(%d*%)")
				if spos and epos then
					local pnumber = string.sub(str, spos + 1, epos - 1)
					if pnumber and string.len(pnumber) > 0 then
						pitch = tonumber(pnumber)
						if ply:IsAdmin() then
							pitch = math.Clamp(pitch, 10, 255)
						else
							pitch = math.Clamp(pitch, 70, 130)
						end
					end
					str = string.Replace(str, string.sub(str, spos, epos, ""))
				end
				str = string.Trim(str)
				if chatsounds[str] then
					sound = chatsounds[str]
					if istable(sound) then
						if sound[1] == true then
							sound = sound[math.random(2, #sound)]
						else
							sound = sound[math.random(1, #sound)]
						end
					end
				else
					for k, v in SortedPairs(chatsounds, true) do
						if string.find(str, k) then
							if istable(v) then
								if v[1] == true then
									continue
								end
								v = v[math.random(1, #v)]
							end
							sound = v
							break
						end
					end
				end
				
				if sound then
					net.Start("PlayChatsound")
					net.WriteString(sound)
					net.WriteUInt(pitch, 9)
					net.Broadcast()
					if !game.SinglePlayer() then
						ply.NextChatsoundTime = CurTime() + 2
					end
				end
			end
		end
	end

end