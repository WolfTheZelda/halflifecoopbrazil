net.Receive("HL1DeathMenu", function()
	GAMEMODE:OpenDeathMenu()
end)

net.Receive("HL1StartMenu", function()
	GAMEMODE:OpenStartMenu()
end)

net.Receive("ShowMapRecords", function()
	GAMEMODE:OpenMapRecords(net.ReadTable())
end)

surface.CreateFont("MenuFont", {
	font = "Trebuchet MS",
	extended = true,
	size = ScrH() / 18,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("MenuFontSmall", {
	font = "Trebuchet MS",
	extended = true,
	size = ScrH() / 24,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("HintPanel", {
	font	= "Trebuchet MS",
	extended = true,
	size	= 18,
	weight	= 800,
})

surface.CreateFont("MenuHint", {
	font	= "Trebuchet MS",
	size	= ScrW() / 58,
	weight	= 800,
	shadow	= true
})

surface.CreateFont("HL1Coop_PlayerFrame", {
	font	= "Trebuchet MS",
	size	= 24,
	weight	= 800,
	shadow	= true
})

local warn_cvar = CreateClientConVar("hl1_coop_cl_nocontentwarning", 0, true)

function GM:OpenMountMenu()
	if warn_cvar:GetBool() then return end
	local menu = vgui.Create("DFrame")
	menu:SetSize(512, 290)
	menu:SetPos(ScrW() / 2 - menu:GetWide() / 2, ScrH() / 2 - menu:GetTall() / 2)
	menu:SetTitle("Mounting error")
	menu:SetDraggable(true)
	menu:SetVisible(true)
	menu:ShowCloseButton(true)
	menu:SetBackgroundBlur(true)
	menu:MakePopup()

	local title = vgui.Create("DLabel", menu)
	title:SetFont("Trebuchet24")
	title:SetText("It seems like you haven't mounted Half-Life: Source")
	title:SizeToContents()
	title:SetPos(20, 30)
	
	local text = vgui.Create("DLabel", menu)
	text:SetFont("Trebuchet18")
	text:SetText("Half-Life: Source is required to play this gamemode.\nIf you don't own it, try downloading these content packs.\nPlease ignore all required addons on their workshop page, you won't need those.")
	text:SizeToContents()
	text:SetPos(20, 70)
	local textPosX, textPosY = text:GetPos()
	
	local btn_y = textPosY + text:GetTall() + 20
	
	local button_textures = vgui.Create("DButton", menu)
	button_textures:SetText("Textures")
	button_textures:SetSize(128, 40)
	button_textures:SetPos(40, btn_y)
	button_textures.DoClick = function()
		gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=1416249216")
	end
	local button_mdl = vgui.Create("DButton", menu)
	button_mdl:SetText("Models")
	button_mdl:SetSize(128, 40)
	button_mdl:SetPos(menu:GetWide() / 2 - button_mdl:GetWide() / 2, btn_y)
	button_mdl.DoClick = function()
		gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=1416243998")
	end
	local button_snds = vgui.Create("DButton", menu)
	button_snds:SetText("Sounds")
	button_snds:SetSize(128, 40)
	button_snds:SetPos(menu:GetWide() - button_snds:GetWide() - 40, btn_y)
	button_snds.DoClick = function()
		gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=1416247138")
	end
	
	local note = vgui.Create("DLabel", menu)
	note:SetFont("Trebuchet18")
	note:SetText("Note: you must restart the game after downloading these.")
	note:SizeToContents()
	note:SetPos(20, btn_y + button_textures:GetTall() + 20)
	local noteX, noteY = note:GetPos()
	
	local ip = game.GetIPAddress()
	if ip != "loopback" then
		local note_ip = vgui.Create("DLabel", menu)
		note_ip:SetFont("Trebuchet18")
		note_ip:SetText("You can copy IP of the server by pressing this button: ")
		note_ip:SizeToContents()
		note_ip:SetPos(noteX, noteY + note:GetTall() + 6)
		local note_ipX, note_ipY = note_ip:GetPos()
		local button_copyip = vgui.Create("DButton", menu)
		button_copyip:SetText("Copy IP")
		button_copyip:SetSize(80, 20)
		button_copyip:SetPos(note_ipX + note_ip:GetWide(), note_ipY)
		button_copyip.DoClick = function()
			SetClipboardText(ip)
		end
	end	
	
	local checkb = vgui.Create("DCheckBoxLabel", menu)
	checkb:SetText("Do not show this again")
	checkb:SetConVar("hl1_coop_cl_nocontentwarning")
	checkb:SizeToContents()
	checkb:SetPos(20, menu:GetTall() - 28)
end

local music

function GM:OpenStartMenu()
	if IsValid(self.StartMenu) and self.StartMenu:IsVisible() then
		return
	end

	local ply = LocalPlayer()
	if IsValid(ply) then
		music = CreateSound(ply, "music/Prospero04.mp3")
		if music and !music:IsPlaying() then
			music:SetSoundLevel(0)
			music:PlayEx(.5, 100)
		end
	end

	self.StartMenu = vgui.Create("DPanel")
	local menu = self.StartMenu
	menu:SetSize(512, 64 + math.min((32 + 1) * game.MaxPlayers(), 512))
	menu:SetPos(ScrW() / 2 - menu:GetWide() / 2, ScrH() / 2 - menu:GetTall() / 2)
	menu:SetBackgroundColor(Color(120, 60, 0, 180))
	menu:MakePopup()
	menu:SetMouseInputEnabled(true)
	menu:SetKeyboardInputEnabled(false)
	
	local margin = 25
	
	function menu:PaintOver(w, h)
		surface.SetDrawColor(20, 20, 20, 180)
		surface.DrawRect(0, 0, w, margin)
		draw.SimpleText("Welcome to the "..GAMEMODE.Name.."!", "Trebuchet24", w / 2, 0, Color(255,200,50,255), TEXT_ALIGN_CENTER) 
		--if !ply:IsAdmin() and !ply:GetNWBool("Ready") and ply.afkTime and (RealTime() - ply.afkTime) >= GAMEMODE.KickUnreadyPlayerTime - 10 then
			--draw.DrawText("You were marked as AFK\nand will be kicked soon", "Trebuchet18", w - 95, 80, Color(255,200,50,255), TEXT_ALIGN_CENTER)
		--end
	end
	
	local DScrollPanel = vgui.Create("DScrollPanel", menu)
	DScrollPanel:SetSize(menu:GetWide() / 1.5, menu:GetTall() - 64)
	DScrollPanel:SetPos(margin, menu:GetTall() / 2 - DScrollPanel:GetTall() / 2 + margin / 2)
	local plyTable = {}
	local ConnectingTimeout = CurTime() + 30

	function DScrollPanel:Think()
		for k, pl in pairs(player.GetAll()) do
			if GAMEMODE.ConnectingPlayers then
				if !self.Unconnected then
					self.Unconnected = {}
				end
				if self.Unconnected then
					for k, v in pairs(GAMEMODE.ConnectingPlayers) do
						if LocalPlayer():UserID() != v then
							if !IsValid(self.Unconnected[v]) then
								self.Unconnected[v] = DScrollPanel:Add("DPanel")
								self.Unconnected[v]:Dock(TOP)
								self.Unconnected[v]:DockMargin(0, 0, 0, 1)
								self.Unconnected[v]:SetSize(DScrollPanel:GetWide(), 32)
								self.Unconnected[v]:SetBackgroundColor(Color(40, 40, 40, 180))
								
								self.Unconnected[v].Nick = vgui.Create("DLabel", self.Unconnected[v])
								self.Unconnected[v].Nick:SetFont("HL1Coop_PlayerFrame")
								self.Unconnected[v].Nick:SetText(lang.menu_connectingpl.." ("..v..")")
								self.Unconnected[v].Nick:SizeToContents()
								self.Unconnected[v].Nick:SetPos(8, self.Unconnected[v]:GetTall() / 2 - self.Unconnected[v].Nick:GetTall() / 2 + 1)
							elseif pl:UserID() == v then
								self.Unconnected[v]:Hide()
							end
						end
					end
				end
			end
			if !IsValid(pl.PlyReady) then
				pl.PlyReady = DScrollPanel:Add("DPanel")
				pl.PlyReady:Dock(TOP)
				pl.PlyReady:DockMargin(0, 0, 0, 1)
				pl.PlyReady:SetSize(DScrollPanel:GetWide(), 32)
				pl.PlyReady:SetBackgroundColor(Color(40, 40, 40, 180))
				
				pl.PlyReady.Avatar = vgui.Create("AvatarImage", pl.PlyReady)
				pl.PlyReady.Avatar:SetSize(32, 32)
				pl.PlyReady.Avatar:SetPlayer(pl, 32)
				
				pl.PlyReady.Nick = vgui.Create("DLabel", pl.PlyReady)
				pl.PlyReady.Nick:SetFont("HL1Coop_PlayerFrame")
				pl.PlyReady.Nick:SetText(pl:Nick())
				pl.PlyReady.Nick:SetSize(200, pl.PlyReady:GetTall())
				pl.PlyReady.Nick:SetPos(pl.PlyReady.Avatar:GetWide() + 8, 1)
				
				pl.PlyReady.Status = vgui.Create("DLabel", pl.PlyReady)
				pl.PlyReady.Status:SetFont("HL1Coop_PlayerFrame")
				pl.PlyReady.Status:SetSize(pl.PlyReady:GetSize())
				
				function pl.PlyReady:AnimationThink(w, h)
					if pl == LocalPlayer() then
						local highlight = math.sin(RealTime()) * 30 + 30
						self:SetBackgroundColor(Color(40 + highlight * 1.25, 40 + highlight * 1.5, 40 + highlight / 2, 180))
					end
				end
				
				local toTable = {pl, pl.PlyReady}
				if !table.HasValue(plyTable, toTable) then
					table.insert(plyTable, toTable)
				end
			else
				local text, col = lang.menu_connecting, Color(255, 200, 40, 255)
				if pl:GetNWInt("Status") == PLAYER_READY then
					text, col = lang.menu_ready, Color(40, 255, 40, 255)
				elseif pl:GetNWInt("Status") == PLAYER_NOTREADY then
					text, col = lang.menu_notready, Color(255, 40, 40, 255)
				end
				if pl:IsBot() then
					text = lang.menu_bot
				end
				if pl.PlyReady.Status:GetText() != text then
					pl.PlyReady.Status:SetText(text)
					pl.PlyReady.Status:SetTextColor(col)
					pl.PlyReady.Status:SizeToContents()
					pl.PlyReady.Status:SetPos(pl.PlyReady:GetWide() - pl.PlyReady.Status:GetWide() - 8, pl.PlyReady:GetTall() / 2 - pl.PlyReady.Status:GetTall() / 2 + 1)
				end
				if pl.PlyReady.Nick:GetText() != pl:Nick() then
					pl.PlyReady.Nick:SetText(pl:Nick())
				end
			end
		end
		if GAMEMODE.ConnectingPlayers and self.Unconnected then
			for id, label in pairs(self.Unconnected) do
				if IsValid(label) and (!table.HasValue(GAMEMODE.ConnectingPlayers, id)) then
					label:Remove()
				end
			end
		end
		for k, v in pairs(plyTable) do
			if !IsValid(v[1]) then v[2]:Remove() end
		end
		if IsValid(menu) and !GetGlobalBool("FirstLoad") then
			if music and music:IsPlaying() then music:FadeOut(1.5) end
			menu:Remove()
		end
	end
	function DScrollPanel:Paint(w, h)
		surface.SetDrawColor(20, 20, 20, 100)
		surface.DrawRect(0, 0, w, h)
	end
	
	local button_rdy = vgui.Create("DButton", menu)
	button_rdy:SetText(lang.menu_imready)
	button_rdy:SetSize(100, 40)
	button_rdy:SetPos(menu:GetWide() - 22 - button_rdy:GetWide(), menu:GetTall() / 2 - button_rdy:GetTall() / 2 + margin / 2)
	button_rdy.DoClick = function()
		button_rdy:SetDisabled(true)
		button_rdy:SetText("")
		RunConsoleCommand("_hl1_coop_ready")
	end
	function button_rdy:Paint(w,h)
		if !self:GetDisabled() then
			surface.SetDrawColor(255, 255, 200, 255)
			surface.DrawRect(0, 0, w, h)
		else --if player.GetCount() > 1 then
			draw.DrawText(lang.menu_waitingpl, "HudHintTextLarge", w / 2, 0, Color(255,255,255,255), TEXT_ALIGN_CENTER) 
		end
	end
	
	local hint_panel = vgui.Create("DPanel", menu)
	hint_panel:SetSize(menu:GetWide(), 32)
	local menuX, menuY = menu:GetPos()
	hint_panel:SetBackgroundColor(Color(40, 20, 0, 180))
	hint_panel:SetAlpha(0)
	hint_panel:MakePopup()
	hint_panel:SetMouseInputEnabled(false)
	hint_panel:SetKeyboardInputEnabled(false)
	
	local hint_table = {
		lang.menuhint_showdist,
		lang.menuhint_thirdperson,
		lang.menuhint_dropweapon,
		lang.menuhint_callmedic,
		lang.menuhint_callvote,
		lang.menuhint_chase,
		lang.menuhint_scorereq,
		lang.menuhint_npchealth,
	}
	local randomhint = hint_table[math.random(1, #hint_table)]
	local seenhint_table = {}
	table.insert(seenhint_table, randomhint)
	
	local hint_text = vgui.Create("DLabel", hint_panel)
	hint_text:SetFont("HintPanel")
	hint_text:SetText(lang.menu_hint..": "..randomhint)
	hint_text:SizeToContents()
	hint_text:SetPos(hint_panel:GetWide() / 2 - hint_text:GetWide() / 2, hint_panel:GetTall() / 2 - hint_text:GetTall() / 2)
	
	local hintalpha = 0
	local hinttime = RealTime() + 15 -- first hint appearing
	local hintendtime = hinttime + 6
	local hintpos = menuY + menu:GetTall() - hint_panel:GetTall()
	local hintepos = menuY + menu:GetTall() + 4
	
	function hint_panel:AnimationThink()
		if hinttime <= RealTime() then
			hintalpha = Lerp(FrameTime() * 2, hintalpha, 255)
			hintpos = Lerp(FrameTime() * 4, hintpos, hintepos)
			self:SetPos(menuX, hintpos)
		end
		if hintendtime <= RealTime() then
			hinttime = RealTime() + 5
			hintalpha = Lerp(FrameTime() * 2, hintalpha, 0)
			if hintalpha < .001 then
				hinttime = RealTime() + 4
				hintendtime = hinttime + 6
				hintpos = menuY + menu:GetTall() - hint_panel:GetTall()
				
				if #seenhint_table == #hint_table then
					table.Empty(seenhint_table)
				end
				
				for i = 0, 50 do
					randomhint = hint_table[math.random(1, #hint_table)]
					if !table.HasValue(seenhint_table, randomhint) then
						table.insert(seenhint_table, randomhint)
						break
					end
				end
				hint_text:SetText(lang.menu_hint..": "..randomhint)
				hint_text:SizeToContents()
				hint_text:SetPos(self:GetWide() / 2 - hint_text:GetWide() / 2, self:GetTall() / 2 - hint_text:GetTall() / 2)
			end
		end
		self:SetAlpha(hintalpha)
	end
	
	if cvars.String("hl1_coop_cl_lang") == "" and ScrW() > 800 then
		-- TODO: add settings panel (language, subtitles)
	end
end

function GM:OpenDeathMenu()
	local plyscore = LocalPlayer():GetScore() or 0
	local respawncost = PRICE_RESPAWN_HERE
	local fullrespawncost = PRICE_RESPAWN_FULL

	if plyscore < respawncost then
		RunConsoleCommand("_hl1_coop_respawn", 2)
		return
	end
	
	if IsValid(self.DeathMenu) and self.DeathMenu:IsVisible() then
		return
	end

	self.DeathMenu = vgui.Create("DFrame")
	local menu = self.DeathMenu
	menu:SetSize(630, 128)
	menu:SetPos(ScrW() / 2 - menu:GetWide() / 2, ScrH() / 2 - menu:GetTall() / 2)
	menu:SetTitle("")
	menu:SetVisible(true)
	menu:SetBackgroundBlur(true)
	menu:ShowCloseButton(true)
	menu:MakePopup()
	menu.startTime = SysTime()
	function menu:Paint(w, h)
		Derma_DrawBackgroundBlur(self, self.startTime)
		surface.SetDrawColor(80, 60, 40, 230)
		surface.DrawRect(0, 0, w, 25)
		surface.SetDrawColor(120, 60, 0, 180)
		surface.DrawRect(0, 25, w, h-25)
		draw.SimpleText(lang.deathmenu_title, "Trebuchet24", w / 2, 0, Color(255,200,50,255), TEXT_ALIGN_CENTER)
	end

	local helptext = vgui.Create("DLabel", menu)
	helptext:SetFont("Trebuchet24")
	helptext:SetText(lang.deathmenu_subtitle)
	helptext:SizeToContents()
	helptext:SetPos(20, 30)

	local scoreText = vgui.Create("DLabel", menu)
	scoreText:SetFont("Trebuchet24")
	scoreText:SetText(lang.score..": "..plyscore)
	scoreText:SetTextColor(Color(255, 250, 100, 255))
	scoreText:SizeToContents()
	scoreText:SetPos(menu:GetWide() - scoreText:GetWide() - 20, 30)
	
	local buttonSize = 180
	local function AddOption(price, text, command, align, disabled)
		local button = vgui.Create("DButton", menu)
		button:SetText(text)
		button:SizeToContents()
		button:SetSize(buttonSize, menu:GetTall() / 4)
		local x, y = menu:GetWide() / 2 - button:GetWide() / 2, menu:GetTall() - 40
		if align == 1 then
			x, y = 20, menu:GetTall() - 40
		elseif align == 3 then
			x, y = menu:GetWide() - buttonSize - 20, menu:GetTall() - 40
		end
		button:SetPos(x, y)
		if plyscore < price or disabled then
			button:SetEnabled(false)
		end
		button.DoClick = function()
			RunConsoleCommand("_hl1_coop_respawn", command)
			menu:Close()
		end
		function button:Paint(w,h)
			if !self:GetDisabled() then
				surface.SetDrawColor(255, 255, 200, 255)
				surface.DrawRect(0, 0, w, h)
			else
				surface.SetDrawColor(150, 150, 120, 180)
				surface.DrawRect(0, 0, w, h) 
			end
		end
		local warn = vgui.Create("DLabel", menu)
		warn:SetFont("Trebuchet18")
		if price == 0 then
			warn:SetText(lang.free)
		else
			warn:SetText(lang.costs..": "..price)
		end
		warn:SizeToContents()
		local button_x, button_y = button:GetPos()
		warn:SetPos(button_x + 2, button_y - warn:GetTall() - 1)
	end
	
	AddOption(fullrespawncost, lang.deathmenu_option1, 3, 1, self.DisableFullRespawn)
	AddOption(respawncost, lang.deathmenu_option2, 1, 2)
	AddOption(0, lang.deathmenu_option3, 2, 3)
end

function GM:OpenMapRecords()
	local openTime = RealTime() + 30
	local recordsWidth, recordsHeight = ScrW() / 1.65, ScrH() / 1.4

	local menu = vgui.Create("DFrame")
	menu:SetSize(recordsWidth, recordsHeight)
	menu:SetPos(ScrW() / 2 - recordsWidth / 2, ScrH() / 2 - recordsHeight / 2)
	menu:SetTitle("Map records")
	menu:SetDraggable(true)
	menu:SetVisible(true)
	menu:ShowCloseButton(true)
	menu:MakePopup()
	function menu:Paint(w,h)
		local alpha = math.Clamp((30 + (RealTime() - openTime)) * 150, 0, 180)
		surface.SetDrawColor(0, 0, 0, alpha)
		surface.DrawRect(0, 0, w, h)
	end

	local list = vgui.Create("DListLayout", menu)		
end

local sndMenu1 = Sound("common/launch_upmenu1.wav")
local sndMenu2 = Sound("common/launch_glow1.wav")
local sndMenu3 = Sound("common/launch_select2.wav")
local sndMenu4 = Sound("common/launch_dnmenu1.wav")

local menuframeColor = Color(20, 20, 20, 200)
local menuTextCol = Color(255, 200, 0, 180)
local menuTextSelected = Color(255, 255, 0, 255)
local buttoncolorDisabled = Color(50, 50, 50, 160)

function GM:OpenLanguageMenu(short)
	if IsValid(self.langSettings) and self.langSettings:IsVisible() then
		self.langSettings:Remove()
		return
	end
	
	short = short or GetGlobalBool("FirstLoad")
	
	self.langSettings = vgui.Create("DPanel")
	local langSettings = self.langSettings
	local height = short and ScrH() / 4 or ScrH() / 1.75
	langSettings:SetSize(ScrW() / 3.5, height * 2)
	local langSettingsW, langSettingsH = langSettings:GetSize()
	langSettings:SetPos(ScrW() / 2 - langSettingsW / 2, ScrH() / 2 - langSettingsH / 2)
	langSettings:SetBackgroundColor(menuframeColor)
	langSettings:MakePopup()
	langSettings.startTime = SysTime()
	
	local menuTitle = vgui.Create("DLabel", langSettings)
	menuTitle:SetFont("MenuFont")
	menuTitle:SetText("Language select")
	menuTitle:SizeToContents()
	menuTitle:SetPos(20, 5)
	menuTitle:SetColor(menuTextCol)
	
	local function CreateOptions()
		if short then return end
		
		local langSettings = self.langSettings
		if !IsValid(langSettings) then return end
		
		local menu = {
			{lang.menu_disconnect, function() RunConsoleCommand("disconnect") end, true},
			{lang.menu_spectate, function() langSettings:Remove() if LocalPlayer():Team() != TEAM_SPECTATOR then RunConsoleCommand("hl1_coop_spectate") end end},
			{lang.menu_joingame, function() langSettings:Remove() if LocalPlayer():Team() == TEAM_SPECTATOR then RunConsoleCommand("hl1_coop_spectate") end end},
		}
		
		local menuEntryPos = langSettings:GetTall() - 20
		
		for k, v in pairs(menu) do
			menuEntryPos = menuEntryPos - langSettings:GetTall() / 12
			k = vgui.Create("DLabel", langSettings)
			k:SetFont("MenuFont")
			k:SetText(v[1])
			k:SetTextColor(menuTextCol)
			k:SizeToContents()
			k:SetPos(langSettings:GetWide() / 2 - k:GetWide() / 2, menuEntryPos)
			--if cvars.String("hl1_coop_cl_lang") == "" and !v[3] then
				--k:SetMouseInputEnabled(false)
				--k:SetTextColor(buttoncolorDisabled)
			--else
				k:SetMouseInputEnabled(true)
			--end
		
			function k:OnCursorEntered()
				surface.PlaySound(sndMenu2)
				k:SetTextColor(menuTextSelected)
			end
			function k:OnCursorExited()
				k:SetTextColor(menuTextCol)
			end
			function k:DoClick()
				surface.PlaySound(sndMenu3)
				v[2]()
			end
			function k:RefreshText()
				k:Remove()
			end
		end
	end
	
	local function AddFlag(cvar, name, icon, panel, pos)
		panel = vgui.Create("DImageButton", langSettings)
		panel:SetSize(langSettings:GetWide() / 5, langSettings:GetWide() / 8)
		local posx, posy
		if pos == 1 then
			posx, posy = langSettings:GetWide() - panel:GetWide() - langSettings:GetWide() / 5, langSettings:GetTall() / 6
		else
			posx, posy = langSettings:GetWide() / 5, langSettings:GetTall() / 6
		end
		if pos == 2 then
			posx, posy = langSettings:GetWide() / 5, langSettings:GetTall() / 2
		end
		panel:SetPos(posx, posy + menuTitle:GetTall() + 5)
		panel:SetImage(icon)
		function panel:OnCursorEntered()
			langSettings.highlightItem = self
		end
		function panel:OnCursorExited()
			langSettings.highlightItem = nil
		end
		function panel:DoClick()
			RunConsoleCommand("hl1_coop_cl_lang", cvar)
			if short then
				langSettings:Remove()
			else
				langSettings.clickedItem = self
				for k, v in pairs(langSettings:GetChildren()) do
					if v:GetName() == "DLabel" then
						if v.RefreshText then
							v:RefreshText()
						end
					end
				end
				timer.Simple(0, function()
					CreateOptions()
				end)
			end
		end
		local title = vgui.Create("DLabel", langSettings)
		title:SetFont("MenuFontSmall")
		title:SetText(name)
		title:SizeToContents()
		local title_x, title_y = panel:GetPos()
		title:SetPos(title_x + panel:GetWide() / 2 - title:GetWide() / 2, panel:GetTall() + title_y + 15)
		
		if cvars.String("hl1_coop_cl_lang") == cvar then
			langSettings.clickedItem = panel
		end
	end
	
	AddFlag("en", "English", "flags16/gb.png", flag_en)
	AddFlag("ru", "Русский", "flags16/ru.png", flag_ru, 1)
	AddFlag("br", "Português", "flags16/br.png", flag_br, 2)
	
	function langSettings:Paint(w, h)
		Derma_DrawBackgroundBlur(self, self.startTime)
		local sine = math.sin(RealTime()) * 10 + 20
		surface.SetDrawColor(sine + 5, sine, 20, 250)
		surface.DrawRect(0, 0, w, h)
	
		if self.highlightItem and IsValid(self.highlightItem) and self.highlightItem:IsVisible() then
			local x, y = self.highlightItem:GetPos()
			local fw, fh = self.highlightItem:GetWide() + 40, self.highlightItem:GetTall() + 40
			surface.SetDrawColor(150, 150, 150, 60)
			surface.DrawRect(x - 20, y - 20, fw, fh)
		end
		if self.clickedItem and IsValid(self.clickedItem) and self.clickedItem:IsVisible() then
			local x, y = self.clickedItem:GetPos()
			local fw, fh = self.clickedItem:GetWide() + 40, self.clickedItem:GetTall() + 40
			surface.SetDrawColor(180, 170, 150, 100)
			surface.DrawRect(x - 20, y - 20, fw, fh)
		end
	end
	CreateOptions()
	
	function langSettings:OnRemove()
		if GetGlobalBool("FirstLoad") and LocalPlayer():Team() != TEAM_COOP then
			timer.Simple(0, function()
				GAMEMODE:OpenStartMenu()
			end)
		end
	end
end

function GM:QuickMenuOptions()
	local ply = LocalPlayer()
	local options = {
		--{"Call medic", function() RunConsoleCommand("callmedic") end, function() return ply:Team() == TEAM_COOP and ply:GetNWFloat("CallMedicTime") <= CurTime() end},
		{lang.quickmenu_dropweapon, function() RunConsoleCommand("dropweapon") end, function() return IsValid(ply:GetActiveWeapon()) end},
		{lang.quickmenu_dropammo, function() RunConsoleCommand("dropammo") end, function() local wep = ply:GetActiveWeapon() return IsValid(wep) and wep:IsScripted() and wep.AmmoEnt and wep:Ammo1() > 0 end},
		{lang.quickmenu_unload, function() RunConsoleCommand("unload") end, function() local wep = ply:GetActiveWeapon() return IsValid(wep) and wep.Unload and wep.UnloadTime and wep:Clip1() > 0 end},
		{lang.quickmenu_tocheckpoint, function() RunConsoleCommand("lastcheckpoint") end, function() return ply:Alive() and ply:GetScore() >= PRICE_LAST_CHECKPOINT and ply.CanTeleportTime and ply.CanTeleportTime > CurTime() and LAST_CHECKPOINT and LAST_CHECKPOINT:Distance(ply:GetPos()) > LAST_CHECKPOINT_MINDISTANCE and CanReachNearestTeleport() end},
		{lang.quickmenu_unstuck, function() RunConsoleCommand("unstuck") end, function() return ply:IsStuck() end},
	}
	return options
end

function GM:OpenQuickMenu()
	local ply = LocalPlayer()
	if ply:Team() != TEAM_COOP then return end

	if IsValid(self.quickMenu) and self.quickMenu:IsVisible() then
		self.quickMenu:Remove()
		return
	end
	local options = self:QuickMenuOptions()
	
	self.quickMenu = vgui.Create("DPanel")
	local quickMenu = self.quickMenu
	quickMenu:SetSize(ScrW() / 6, #options * ScrH() / 21 + 36)
	local quickMenuW, quickMenuH = quickMenu:GetSize()
	local quickMenuX, quickMenuY = -quickMenuW, ScrH() / 2 - quickMenuH / 2
	quickMenu:SetPos(quickMenuX, quickMenuY)
	quickMenu:SetBackgroundColor(menuframeColor)
	quickMenu:MakePopup()
	quickMenu.AnimType = 1
	
	function quickMenu:OnKeyCodePressed(key)
		if input.LookupKeyBinding(key) == "gm_showspare2" then
			quickMenu:DoHideAnim()
		end
	end
	
	function quickMenu:DoStartAnim()
		self.AnimType = 1
	end
	function quickMenu:DoHideAnim()
		self.AnimType = 2
		self:SetMouseInputEnabled(false)
		self:SetKeyboardInputEnabled(false)
	end

	local maxwidth = quickMenu:GetWide()
	for k, v in pairs(options) do
		surface.SetFont("MenuFontSmall")
		local tw, th = surface.GetTextSize(v[1])
		tw = tw + 44
		if tw > quickMenuW then
			quickMenuW = tw
		end
		
		local l = vgui.Create("DLabel", quickMenu)
		l:Dock(TOP)
		l:DockMargin(20, 20, 0, -16)
		l:SetTextColor(menuTextCol)
		l:SetFont("MenuFontSmall")
		l:SetText(v[1])
		l:SizeToContents()
		local textwidth = l:GetWide() + 20
		if textwidth > maxwidth then
			maxwidth = textwidth + 30
		end
		if !v[3] or v[3]() then
			l:SetMouseInputEnabled(true)
			function l:OnCursorEntered()
				surface.PlaySound(sndMenu2)
				self:SetTextColor(menuTextSelected)
			end
			function l:OnCursorExited()
				self:SetTextColor(menuTextCol)
			end
			function l:DoClick()
				surface.PlaySound(sndMenu3)
				quickMenu:DoHideAnim()
				v[2]()
			end
		else
			l:SetTextColor(buttoncolorDisabled)
		end
	end
	quickMenu:SetWide(maxwidth)
	
	function quickMenu:AnimationThink()	
		local FT = FrameTime()
		if game.SinglePlayer() then
			FT = FT + .01
		end
		if self.AnimType == 1 then
			quickMenuX = Lerp(FT*8, quickMenuX, 0)
			self:SetPos(quickMenuX, quickMenuY)
			if quickMenuX >= -0.1 then
				self.AnimType = nil
			end
		elseif self.AnimType == 2 then
			quickMenuX = math.Approach(quickMenuX, -quickMenuW, FT*3000)
			self:SetPos(quickMenuX, quickMenuY)
			if quickMenuX <= -quickMenuW then
				self:Remove()
			end
		end
	end
end

concommand.Add("swepmenu", function()
	GAMEMODE:OpenSWEPMenu()
end)

function GM:OpenSWEPMenu()
	if IsValid(self.SWEPMenu) and self.SWEPMenu:IsVisible() then
		self.SWEPMenu:Remove()
		return
	end
	
	if !LocalPlayer():IsAdmin() then return end
	
	self.SWEPMenu = vgui.Create("DPanel")
	local menu = self.SWEPMenu
	menu:SetSize(ScrW() / 1.5, ScrH() / 1.3)
	local menuW, menuH = menu:GetSize()
	menu:SetPos(ScrW() / 2 - menuW / 2, ScrH() / 2 - menuH / 2)
	menu:SetBackgroundColor(menuframeColor)
	menu:MakePopup()
	
	local menuTitle = vgui.Create("DLabel", menu)
	menuTitle:SetFont("MenuFont")
	menuTitle:SetText("SWEPs")
	menuTitle:SizeToContents()
	menuTitle:SetPos(20, 10)
	menuTitle:SetColor(menuTextCol)
	
	local menuBackground = vgui.Create("DScrollPanel", menu)
	menuBackground:SetSize(menuW - 40, menuH / 1.4)
	menuBackground:SetPos(20, menuTitle:GetTall() + 20)
	menuBackground:SetPaintBackground(true)
	menuBackground:SetBackgroundColor(Color(100, 100, 100, 180))
	local menuBackgroundW, menuBackgroundH = menuBackground:GetSize()
	local wepList = vgui.Create("DIconLayout", menuBackground)
	wepList:SetSize(menuBackgroundW, menuBackgroundH)
	wepList:SetPos(menuBackgroundW / 40, menuBackgroundH / 40)
	wepList:SetSpaceY(5)
	wepList:SetSpaceX(5)
	
	local sweps = weapons.GetList()
	for k, swep in SortedPairsByMemberValue(sweps, "ClassName") do
		local class
		local img, img_png = ""
		if swep.Spawnable then
			class = swep.ClassName
			img, img_png = "vgui/entities/"..class, "entities/"..class..".png"
		end
		if class and !string.StartWith(class, "weapon_hl1_") then
			local ListItem = wepList:Add("DImageButton")
			ListItem:SetSize(wepList:GetWide() / 7.725, wepList:GetWide() / 7.725)
			ListItem:SetImage(img, img_png)
			ListItem:SetText(class)
			ListItem.DoClick = function()
				local ply = LocalPlayer()
				if ply:Alive() then
					RunConsoleCommand("hl1_coop_give", class)
					timer.Simple(.1, function()
						if ply:HasWeapon(class) then
							local wep = ply:GetWeapon(class)
							if IsValid(wep) then
								if class == "weapon_vfirethrower" then
									wep.ViewModelOffset = {
										PosForward = 9,
										PosRight = 3,
										PosUp = -16.5,
		
										AngForward = 0,
										AngRight = 1,
										AngUp = 1.5
									}
								end
								input.SelectWeapon(wep)
							end
						end
					end)
				end
			end
			ListItem.PaintOver = function(ListItem, w, h)
				draw.SimpleText(ListItem:GetText(), "default", w / 2, h - 8, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end
	end
	
	local closeButton = vgui.Create("DLabel", menu)
	closeButton:SetFont("MenuFont")
	closeButton:SetText(lang.menu_close)
	closeButton:SizeToContents()
	closeButton:SetPos(menuW / 2 - closeButton:GetWide() / 2, menuH - closeButton:GetTall() - 32)
	closeButton:SetMouseInputEnabled(true)
	function closeButton:DoClick()
		menu:Remove()
	end
end

GM.Menu = {}

function GM:OpenMainMenu()
	--showGameUI = false
	
	if IsValid(self.langSettings) and self.langSettings:IsVisible() then
		self.langSettings:Remove()
		return
	end	
	if IsValid(self.quickMenu) and self.quickMenu:IsVisible() then
		self.quickMenu:Remove()
		return
	end
	
	if self.Menu.MainMenuFrame and self.Menu.MainMenuFrame:IsVisible() then
		self:CloseMenus()
		return
	end
	
	if game.SinglePlayer() then
		RunConsoleCommand("pause")
	end
	
	local menu = {
		{lang.menu_resumegame, function() self.Menu.MainMenuFrame:DoEndAnim() end},
		{lang.menu_callvote, function() self:VoteMenu() end},
		{lang.menu_configuration, function() self.Menu.MainMenuFrame:DoHideAnim() self:OpenPlayerSettings() end},
		{lang.menu_playermodel, function() self.Menu.MainMenuFrame:DoEndAnim() self:ModelSelectionMenu() end, function() if !GetGlobalBool("hl1_coop_sv_custommodels", false) then return false end end},
		{lang.menu_langselect, function() self.Menu.MainMenuFrame:DoEndAnim() self:OpenLanguageMenu(true) end},
		{lang.menu_steamgroup, function() gui.OpenURL("https://steamcommunity.com/groups/hl1coop") end},
		--{lang.menu_workshoppage, function() gui.OpenURL("http://steamcommunity.com/sharedfiles/filedetails/?id=") end},
		{lang.menu_spectate, function() self.Menu.MainMenuFrame:DoEndAnim() RunConsoleCommand("hl1_coop_spectate") end, function() if GetGlobalBool("FirstLoad") then return false end if LocalPlayer():Team() == TEAM_SPECTATOR then return lang.menu_joingame end end},
		{lang.menu_disconnect, function() RunConsoleCommand("disconnect") end},
		{lang.menu_quit, function() self.Menu.MainMenuFrame:DoHideAnim() self:QuitDialog() end},
		
		{"Admin settings", function() self.Menu.MainMenuFrame:DoHideAnim() self:OpenServerSettings() end, adminonly = true},
		
		{lang.menu_legacymenu, function() self:CloseMenus() gui.ActivateGameUI() end}
	}

	self.Menu.MainMenuFrame = vgui.Create("DPanel")
	self.Menu.MainMenuFrame:SetPos(ScrW() / 16, 0)
	self.Menu.MainMenuFrame:SetSize(ScrW() / 3.5, ScrH())
	self.Menu.MainMenuFrame:SetBackgroundColor(menuframeColor)
	self.Menu.MainMenuFrame:MakePopup()
	local menuW, menuH = self.Menu.MainMenuFrame:GetSize()
	local menuX, menuY = self.Menu.MainMenuFrame:GetPos()
	local menuStart = 0 - menuW
	function self.Menu.MainMenuFrame:DoStartAnim()
		surface.PlaySound(sndMenu1)
		self.AnimType = 1
	end
	function self.Menu.MainMenuFrame:DoEndAnim()
		menuStart = -menuW
		surface.PlaySound(sndMenu4)
		self.AnimType = 2
		if IsValid(GAMEMODE.Menu.voteMenu) and GAMEMODE.Menu.voteMenu:IsVisible() then GAMEMODE.Menu.voteMenu:DoHideAnim() end
		self:SetMouseInputEnabled(false)
		self:SetKeyboardInputEnabled(false)
		if game.SinglePlayer() then
			RunConsoleCommand("unpause")
		end
	end
	function self.Menu.MainMenuFrame:DoHideAnim()
		menuStart = 40 - menuW
		surface.PlaySound(sndMenu4)
		self.AnimType = 3
		if IsValid(GAMEMODE.Menu.voteMenu) and GAMEMODE.Menu.voteMenu:IsVisible() then GAMEMODE.Menu.voteMenu:DoHideAnim() end
	end
	function self.Menu.MainMenuFrame:Popup()
		self.Hidden = false
		menuX = ScrW() / 16
		self:DoStartAnim()
	end
	function self.Menu.MainMenuFrame:AnimationThink()
		local FT = FrameTime()
		if game.SinglePlayer() then
			FT = FT + .01
		end
		if self.AnimType == 1 then
			menuStart = Lerp(FT*8, menuStart, menuX)
			self:SetPos(math.ceil(menuStart))
			if self:GetPos() == menuX then
				self.AnimType = nil
			end
		elseif self.AnimType == 2 then
			menuX = math.Approach(menuX, menuStart, FT*3000)
			self:SetPos(menuX)
			if self:GetPos() == menuStart then
				menuStart = menuX
				GAMEMODE:CloseMenus()
				self.AnimType = nil
			end
		elseif self.AnimType == 3 then
			menuX = Lerp(FT*8, menuX, menuStart)
			self:SetPos(math.floor(menuX))
			if self:GetPos() == menuStart then
				menuStart = menuX
				self.Hidden = true
				self.AnimType = nil
			end
		end
	end
	function self.Menu.MainMenuFrame:OnCursorEntered()
		if self.Hidden and (!self.NextAnim or self.NextAnim <= RealTime()) then
			self.AnimType = 1
			menuX = 150 - menuW
			self.NextAnim = RealTime() + .1
		end
	end
	function self.Menu.MainMenuFrame:OnCursorExited()
		if self.Hidden then
			self.AnimType = 3
			menuStart = 40 - menuW
			self.NextAnim = RealTime() + .1
		end
	end
	function self.Menu.MainMenuFrame:OnMousePressed(key)
		if self.Hidden and key == MOUSE_FIRST then
			GAMEMODE:CloseSubMenus()
			self:Popup()
		end
	end
	self.Menu.MainMenuFrame:DoStartAnim()
	
	local hl1cooplogo = vgui.Create("DImage", self.Menu.MainMenuFrame)
	hl1cooplogo:SetSize(menuH / 3, menuH / 7)
	local hl1cooplogoW, hl1cooplogoH = hl1cooplogo:GetSize()
	hl1cooplogo:SetPos(menuW / 2 - hl1cooplogoW / 2, 20)
	hl1cooplogo:SetImage("hl1coop_logo.png", "gui/contenticon-hovered.png")
	
	local menuEntryPos = ScrH() / 6
	
	for k, v in pairs(menu) do
		local invisible
		if !LocalPlayer():IsSuperAdmin() and v.adminonly then
			invisible = true
		end
		local namefunc = v[3]
		local disabled
		if namefunc and namefunc() == false then
			disabled = true
		end
		menuEntryPos = menuEntryPos + menuH / 16
		k = vgui.Create("DLabel", self.Menu.MainMenuFrame)
		k:SetPos(menuW / 8, menuEntryPos)
		k:SetFont("MenuFont")
		k:SetText(v[1])
		if namefunc and namefunc() then
			k:SetText(namefunc())
		end
		k:SetTextColor(menuTextCol)
		k:SizeToContents()
		k:SetMouseInputEnabled(true)
		if disabled then
			k:SetMouseInputEnabled(false)
			k:SetTextColor(buttoncolorDisabled)
		elseif invisible then
			k:SetMouseInputEnabled(false)
			k:SetTextColor(Color(0,0,0,0))
		else
			k.OnCursorEntered = function()
				surface.PlaySound(sndMenu2)
				k:SetTextColor(menuTextSelected)
			end
			k.OnCursorExited = function()
				k:SetTextColor(menuTextCol)
			end
			function k:DoClick()
				surface.PlaySound(sndMenu3)
				v[2]()
			end
			function k:Think()
				if GAMEMODE.Menu.MainMenuFrame.Hidden then
					k:SetMouseInputEnabled(false)
				elseif !k:IsMouseInputEnabled() then
					k:SetMouseInputEnabled(true)
				end
			end
		end
	end
end

function GM:OpenPlayerSettings()
	local settingscvars = {
		{"DCheckBoxLabel", lang.configmenu_halos, "hl1_coop_cl_drawhalos", 1},
		{"DCheckBoxLabel", lang.configmenu_hints, "hl1_coop_cl_showhints", 1},
		{"DCheckBoxLabel", lang.configmenu_score, "hl1_coop_cl_showscore", 1},
		{"DCheckBoxLabel", lang.configmenu_subtitles, "hl1_coop_cl_subtitles", 1},
		{"DCheckBoxLabel", lang.configmenu_chatsnds, "hl1_coop_cl_chatsounds", 1},
		{"DCheckBoxLabel", lang.configmenu_firelight, "hl1_cl_firelight", 1},
		{"DCheckBoxLabel", lang.configmenu_chair, "hl1_cl_crosshair", 1},
		{"DNumSlider", lang.configmenu_chairscale, "hl1_cl_crosshair_scale", 1, 2, 1, 2},
		{"DNumSlider", lang.configmenu_vmfov, "hl1_cl_viewmodelfov", 90, 0, 70, 120},
		{"DNumSlider", lang.configmenu_bobstyle.." (HL1, WON,\nRealistic, HL:S)", "hl1_coop_cl_bobstyle", 1, 0, 1, 4},
		{"DCheckBoxLabel", lang.configmenu_custombob, "hl1_coop_cl_bobcustom", 1},
		{"DCheckBoxLabel", lang.configmenu_viewbob, "hl1_cl_viewbob", 1},
		{"DNumSlider", "bob", "hl1_cl_bob", 0.01, 2, 0, .1},
		{"DNumSlider", "bobcycle", "hl1_cl_bobcycle", 0.8, 1, 0.3, 1},
		{"DNumSlider", "bobup", "hl1_cl_bobup", 0.5, 1, 0, 1},
		{"DNumSlider", "rollangle", "hl1_cl_rollangle", 2, 0, 0, 5},
		{"DNumSlider", "rollspeed", "hl1_cl_rollspeed", 200, 0, 0, 400},
	}
	local hudsettings = {
		{"DCheckBoxLabel", lang.configmenu_gsrchud, "hl1_coop_cl_disablehud", 0},
		{"DComboBox", "[GSRCHUD] "..lang.configmenu_theme, "gsrchud_theme"},
		{"DCheckBoxLabel", "[GSRCHUD] "..lang.configmenu_dscreen, "gsrchud_death_screen_enabled", 1},
		{"DCheckBoxLabel", "[GSRCHUD] "..lang.configmenu_skipempty, "gsrchud_skip_empty_weapons", 1},
		{"DNumSlider", "[GSRCHUD] "..lang.configmenu_scale, "gsrchud_scale", 1, 1, 1, 4},
	}
	
	self.Menu.plySettings = vgui.Create("DPanel")
	local plySettings = self.Menu.plySettings
	plySettings:SetSize(math.max(ScrW() / 3, 300), ScrH() / 1.2)
	local plySettingsW, plySettingsH = plySettings:GetSize()
	plySettings:SetPos(ScrW() / 2 - plySettingsW / 2, ScrH() / 2 - plySettingsH / 2)
	plySettings:SetBackgroundColor(menuframeColor)
	plySettings:MakePopup()
	
	local menuTitle = vgui.Create("DLabel", plySettings)
	menuTitle:SetFont("MenuFont")
	menuTitle:SetText(lang.menu_configuration)
	menuTitle:SizeToContents()
	menuTitle:SetPos(20, 10)
	menuTitle:SetColor(menuTextCol)
	
	local backgr = vgui.Create("DScrollPanel", plySettings)
	backgr:SetSize(plySettingsW - 20, plySettingsH - 130)
	backgr:SetPos(plySettingsW / 2 - backgr:GetWide() / 2, menuTitle:GetTall() + 20)
	backgr:SetPaintBackground(true)
	backgr:SetBackgroundColor(Color(100, 100, 100, 180))
	
	for k, v in pairs(settingscvars) do
		local k = vgui.Create(v[1], backgr)
		k:SetText(v[2])
		k:SetConVar(v[3])
		if v[1] == "DNumSlider" then
			k:SetDecimals(v[5])
			k:SetMinMax(v[6], v[7])
		end
		k:Dock(TOP)
		k:DockMargin( 20, 12, 20, 0 )
	end
	if GSRCHUD then
		for k, v in pairs(hudsettings) do
			local k = vgui.Create(v[1], backgr)
			if v[1] != "DComboBox" then
				k:SetText(v[2])
				k:SetConVar(v[3])
				if v[1] == "DNumSlider" then
					k:SetDecimals(v[5])
					k:SetMinMax(v[6], v[7])
				end
			else
				k:SetValue(v[2])
				if v[3] == "gsrchud_theme" then
					for theme, _ in pairs(GSRCHUD:GetThemes()) do
						k:AddChoice(theme)
					end
				end
				function k:OnSelect(index, value, data)
					RunConsoleCommand(v[3], value)
				end
			end
			k:Dock(TOP)
			k:DockMargin( 20, 12, 20, 0 )
		end
	end
	
	local def = vgui.Create("DLabel", plySettings)
	def:SetFont("MenuFont")
	def:SetText(lang.configmenu_default)
	def:SizeToContents()
	def:SetPos(plySettingsW / 2 - def:GetWide() / 2, plySettingsH - def:GetTall() - 10)
	def:SetTextColor(menuTextCol)
	def:SetMouseInputEnabled(true)
	function def:DoClick()
		surface.PlaySound(sndMenu3)
		for k, v in pairs(settingscvars) do
			RunConsoleCommand(v[3], v[4])
		end
		if GSRCHUD then
			for k, v in pairs(hudsettings) do
				if v[1] != "DComboBox" then
					RunConsoleCommand(v[3], v[4])
				else
					if v[3] == "gsrchud_theme" then
						RunConsoleCommand(v[3], GSRCHUD.DefaultConfig.DefaultTheme)
					end
				end
			end
		end
	end
	function def:OnCursorEntered()
		surface.PlaySound(sndMenu2)
		self:SetTextColor(menuTextSelected)
	end
	function def:OnCursorExited()
		self:SetTextColor(menuTextCol)
	end
end

function GM:QuitDialog()
	self.Menu.quitMenu = vgui.Create("DPanel")
	local quitMenu = self.Menu.quitMenu
	quitMenu:SetSize(ScrW() / 3, ScrH() / 5)
	local quitMenuW, quitMenuH = quitMenu:GetSize()
	quitMenu:SetPos(ScrW() / 2 - quitMenuW / 2, ScrH() / 2 - quitMenuH / 2)
	quitMenu:SetBackgroundColor(menuframeColor)
	quitMenu:MakePopup()
	
	local text = vgui.Create("DLabel", quitMenu)
	text:SetFont("MenuFont")
	text:SetText(lang.quit_sure)
	text:SizeToContents()
	quitMenu:SetSize(text:GetWide() + ScrW() / 24, quitMenuH)
	local quitMenuW, quitMenuH = quitMenu:GetSize()
	quitMenu:SetPos(ScrW() / 2 - quitMenuW / 2, ScrH() / 2 - quitMenuH / 2)
	text:SetPos(quitMenuW / 2 - text:GetWide() / 2, 20)
	--text:SetTextColor(menuTextCol)
	
	local button_yes = vgui.Create("DLabel", quitMenu)
	button_yes:SetFont("MenuFont")
	button_yes:SetText(lang.yes)
	button_yes:SizeToContents()
	button_yes:SetPos(quitMenuW / 2 - button_yes:GetWide() - 70, quitMenuH / 1.1 - button_yes:GetTall())
	button_yes:SetTextColor(menuTextCol)
	button_yes:SetMouseInputEnabled(true)
	function button_yes:DoClick()
		RunConsoleCommand("gamemenucommand", "quit")
	end
	function button_yes:OnCursorEntered()
		surface.PlaySound(sndMenu2)
		self:SetTextColor(menuTextSelected)
	end
	function button_yes:OnCursorExited()
		self:SetTextColor(menuTextCol)
	end
	
	local button_no = vgui.Create("DLabel", quitMenu)
	button_no:SetFont("MenuFont")
	button_no:SetText(lang.no)
	button_no:SizeToContents()
	button_no:SetPos(quitMenuW / 2 + 70, quitMenuH / 1.1 - button_no:GetTall())
	button_no:SetTextColor(menuTextCol)
	button_no:SetMouseInputEnabled(true)
	function button_no:DoClick()
		surface.PlaySound(sndMenu3)
		GAMEMODE:CloseSubMenus()
		GAMEMODE.Menu.MainMenuFrame:Popup()
	end
	function button_no:OnCursorEntered()
		surface.PlaySound(sndMenu2)
		self:SetTextColor(menuTextSelected)
	end
	function button_no:OnCursorExited()
		self:SetTextColor(menuTextCol)
	end
end

local t_selected = Material("gui/contenticon-hovered.png")

function GM:VoteMenuOptions()
	local votes = {
		{lang.votemenu_mapvote, function() self.Menu.MainMenuFrame:DoHideAnim() self:OpenMapVote() end},
		{lang.votemenu_kick, function() self.Menu.MainMenuFrame:DoHideAnim() self:OpenKickVote() end},
		{lang.votemenu_restart, function() self.Menu.MainMenuFrame:DoEndAnim() RunConsoleCommand("hl1_coop_callvote", "restart") end},
		{lang.votemenu_speedrun, function() self.Menu.MainMenuFrame:DoEndAnim() RunConsoleCommand("hl1_coop_callvote", "speedrunmode") end, "Speedrun mode which features:\n- Bunnyhop script\n- Speed indicator\n- No wait triggers\n- Allowed shortcuts\n- Players can't pickup other's weaponbox\n- Unlimited func_pushable velocity\n- Map records\n\nCauses map restart after activation"},
		{lang.votemenu_survival, function() self.Menu.MainMenuFrame:DoEndAnim() RunConsoleCommand("hl1_coop_callvote", "survivalmode") end, "Survival mode:\n- No respawns until someone reaches checkpoint\n- Map restarts if no alive players left\n- Medkit weapon available"},
		{"Crack mode", function() self.Menu.MainMenuFrame:DoEndAnim() RunConsoleCommand("hl1_coop_callvote", "crackmode") end, "Crack mode:\nEverything is fucked up"},
		{lang.votemenu_skill1, function() self.Menu.MainMenuFrame:DoEndAnim() RunConsoleCommand("hl1_coop_callvote", "skill", 1) end},
		{lang.votemenu_skill2, function() self.Menu.MainMenuFrame:DoEndAnim() RunConsoleCommand("hl1_coop_callvote", "skill", 2) end},
		{lang.votemenu_skill3, function() self.Menu.MainMenuFrame:DoEndAnim() RunConsoleCommand("hl1_coop_callvote", "skill", 3) end},
		{"Skip tripmine room", function() self.Menu.MainMenuFrame:DoEndAnim() RunConsoleCommand("hl1_coop_callvote", "skiptripmines") end, available = function() return game.GetMap() == "hls11cmrl" end},
	}
	return votes
end

function GM:VoteMenu()
	if IsValid(self.Menu.voteMenu) and self.Menu.voteMenu:IsVisible() then
		self.Menu.voteMenu:DoHideAnim()
		return
	end
	
	local votes = self:VoteMenuOptions()
	
	self.Menu.voteMenu = vgui.Create("DPanel", self.Menu.MainMenuFrame)
	local voteMenu = self.Menu.voteMenu
	local mainMenuPosX, mainMenuPosY = self.Menu.MainMenuFrame:GetPos()
	local voteOptionCount = #votes
	for k, v in pairs(votes) do
		if v.available and !v.available() then
			voteOptionCount = voteOptionCount - 1
		end
	end
	voteMenu:SetSize(self.Menu.MainMenuFrame:GetWide() - 88, voteOptionCount * ScrH() / 16.5 + 36)
	local voteMenuStart = 0
	local voteMenuW, voteMenuH = voteMenu:GetSize()
	voteMenu:SetBackgroundColor(menuframeColor)
	voteMenu:MakePopup()
	voteMenu.AnimType = 1
	
	function voteMenu:DoStartAnim()
		self.AnimType = 1
	end
	function voteMenu:DoHideAnim()
		self.AnimType = 2
	end

	for k, v in pairs(votes) do
		if v.available and !v.available() then
			continue
		end
		surface.SetFont("MenuFont")
		local tw, th = surface.GetTextSize(v[1])
		tw = tw + 44
		if tw > voteMenuW then
			voteMenuW = tw
		end
		
		local l = vgui.Create("DLabel", voteMenu)
		l:Dock(TOP)
		l:DockMargin(20, 20, 0, -16)
		l:SetTextColor()
		l:SetFont("MenuFont")
		l:SetText(v[1])
		l:SizeToContents()
		l:SetMouseInputEnabled(true)
		function l:OnCursorEntered()
			surface.PlaySound(sndMenu2)
			self:SetTextColor(Color(255,255,255,255))
			
			if v[3] then
				local x, y = self:GetPos()
				local vx, vy = voteMenu:GetPos()
				self.hint = vgui.Create("DLabel", voteMenu)
				self.hint:SetPos(vx + voteMenuW + x, vy + y + 8)
				self.hint:SetTextColor(Color(255,255,230,255))
				self.hint:SetFont("MenuHint")
				self.hint:SetText(v[3])
				self.hint:SizeToContents()
				self.hint:MakePopup()
			end
		end
		function l:OnCursorExited()
			self:SetTextColor()
			
			if IsValid(self.hint) then
				self.hint:Remove()
			end
		end
		function l:DoClick()
			surface.PlaySound(sndMenu3)
			v[2]()
		end
	end
	
	function voteMenu:AnimationThink()
		mainMenuPosX, mainMenuPosY = GAMEMODE.Menu.MainMenuFrame:GetPos()
		self:SetPos(mainMenuPosX + GAMEMODE.Menu.MainMenuFrame:GetWide(), ScrH() / 3 - voteMenuH / 6)
	
		local FT = FrameTime()
		if game.SinglePlayer() then
			FT = FT + .01
		end
		if self.AnimType == 1 then
			voteMenuStart = Lerp(FT*8, voteMenuStart, voteMenuW)
			self:SetWidth(voteMenuStart)
			if self:GetWide() == voteMenuW - 1 then
				self.AnimType = nil
			end
		elseif self.AnimType == 2 then
			voteMenuStart = Lerp(FT*16, voteMenuStart, 0)
			self:SetWidth(voteMenuStart)
			if self:GetWide() == 0 then
				self:Remove()
			end
		end
	end
end
	
function GM:OpenMapVote()
	self.Menu.voteMenu = vgui.Create("DPanel")
	local mapVoteMenu = self.Menu.voteMenu
	mapVoteMenu:SetSize(ScrW() / 1.5, ScrH() / 1.3)
	local mapVoteMenuW, mapVoteMenuH = mapVoteMenu:GetSize()
	mapVoteMenu:SetPos(ScrW() / 2 - mapVoteMenuW / 2, ScrH() / 2 - mapVoteMenuH / 2)
	mapVoteMenu:SetBackgroundColor(menuframeColor)
	mapVoteMenu:MakePopup()
	
	local menuTitle = vgui.Create("DLabel", mapVoteMenu)
	menuTitle:SetFont("MenuFont")
	menuTitle:SetText(lang.votemenu_mapvote)
	menuTitle:SizeToContents()
	menuTitle:SetPos(20, 10)
	menuTitle:SetColor(menuTextCol)
	
	local voteMap = vgui.Create("DScrollPanel", mapVoteMenu)
	voteMap:SetSize(mapVoteMenuW - 40, mapVoteMenuH / 1.5)
	voteMap:SetPos(20, menuTitle:GetTall() + 20)
	voteMap:SetPaintBackground(true)
	voteMap:SetBackgroundColor(Color(100, 100, 100, 180))
	local voteMapW, voteMapH = voteMap:GetSize()
	local mapList = vgui.Create("DIconLayout", voteMap)
	mapList:SetSize(voteMapW, voteMapH)
	mapList:SetPos(voteMapW / 40, voteMapW / 40)
	mapList:SetSpaceY(5)
	mapList:SetSpaceX(5)
	
	local maps = file.Find("maps/*.bsp", "GAME")
	for k, map in pairs(maps) do
		map = string.StripExtension(map)
		if string.find(map, "hls") then
			local ListItem = mapList:Add("DImageButton")
			ListItem:SetSize(mapList:GetWide() / 7.725, mapList:GetWide() / 7.725)
			ListItem:SetImage("maps/thumb/"..map..".png")
			ListItem:SetText(map)
			ListItem.DoClick = function()
				voteMap.SelectedMap = map
			end
			ListItem.PaintOver = function(ListItem, w, h)
				draw.SimpleText(ListItem:GetText(), "default", w / 2, h - 8, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				if voteMap.SelectedMap == map then
					surface.SetDrawColor(255,255,255,255)
					surface.SetMaterial(t_selected)
					surface.DrawTexturedRect(-2, -2, w+4, h+4)
				end
			end
		end
	end
	
	local VmapButton = vgui.Create("DLabel", mapVoteMenu)
	VmapButton:SetFont("MenuFont")
	VmapButton:SetText(lang.votemenu_mapvote_call)
	VmapButton:SizeToContents()
	VmapButton:SetPos(mapVoteMenuW / 2 - VmapButton:GetWide() / 2, mapVoteMenuH - VmapButton:GetTall() - 32)
	VmapButton:SetMouseInputEnabled(true)
	function VmapButton:DoClick()
		if voteMap.SelectedMap then
			RunConsoleCommand("hl1_coop_callvote", "map", voteMap.SelectedMap)
			GAMEMODE:CloseMenus()
		end
	end
end

function GM:OpenKickVote()
	self.Menu.voteMenu = vgui.Create("DPanel")
	local voteKickMenu = self.Menu.voteMenu
	voteKickMenu:SetSize(ScrW() / 3, ScrH() / 1.3)
	local voteKickMenuW, voteKickMenuH = voteKickMenu:GetSize()
	voteKickMenu:SetPos(ScrW() / 2 - voteKickMenuW / 2, ScrH() / 2 - voteKickMenuH / 2)
	voteKickMenu:SetBackgroundColor(menuframeColor)
	voteKickMenu:MakePopup()
	
	local menuTitle = vgui.Create("DLabel", voteKickMenu)
	menuTitle:SetFont("MenuFont")
	menuTitle:SetText(lang.votemenu_kick)
	menuTitle:SizeToContents()
	menuTitle:SetPos(20, 10)
	menuTitle:SetColor(menuTextCol)

	local players = player.GetAll()
	
	local voteKick = vgui.Create("DPanel", voteKickMenu)
	local voteKickX, voteKickY = 20, menuTitle:GetTall() + 20
	voteKick:SetPos(voteKickX, voteKickY)
	voteKick:SetSize(voteKickMenuW - voteKickX*2, voteKickMenuH - voteKickY - 100)
	voteKick:SetBackgroundColor(Color(100, 100, 100, 180))
	
	local plyList = vgui.Create("DScrollPanel", voteKick)
	plyList:SetPos(25, 25)
	plyList:SetSize(voteKick:GetWide() - 50, voteKick:GetTall() - 50)
	
	local ppos = 0
	for k, ply in pairs(players) do
		k = vgui.Create("DLabel", plyList)
		k:SetPos(0, ppos)
		ppos = ppos + 30
		k:SetFont("DermaLarge")
		k:SetText(ply:Nick())
		//k:SetTextColor(v.col)
		k:SizeToContents()
		k:SetMouseInputEnabled(true)
		function k:DoClick()
			plyList.SelectedPlayer = ply
		end
		k.PaintOver = function(k, w, h)
			if plyList.SelectedPlayer == ply then
				surface.SetDrawColor(255,255,255,255)
				surface.SetMaterial(t_selected)
				surface.DrawTexturedRect(0, 0, w, h)
			end
		end
	end
	
	local kickButton = vgui.Create("DLabel", voteKickMenu)
	kickButton:SetFont("MenuFont")
	kickButton:SetText(lang.votemenu_kick_call)
	kickButton:SizeToContents()
	kickButton:SetPos(voteKickMenu:GetWide() / 2 - kickButton:GetWide() / 2, voteKickMenu:GetTall() - kickButton:GetTall() - 32)
	kickButton:SetMouseInputEnabled(true)
	function kickButton:DoClick()
		if plyList.SelectedPlayer and IsValid(plyList.SelectedPlayer) then
			RunConsoleCommand("hl1_coop_callvote", "kick", plyList.SelectedPlayer:Nick())
			GAMEMODE:CloseMenus()
		end
	end
end

function GM:ModelSelectionMenu()
	if IsValid(self.plyModelMenu) and self.plyModelMenu:IsVisible() then
		self:SetPlayerModelView(false)
		self.plyModelMenu:Remove()
		return
	end
	
	local ply = LocalPlayer()

	if ply.PreviewModel then
		ply.PreviewModel = nil
	end
	
	self:SetPlayerModelView(true)
	self.plyModelMenu = vgui.Create("DPanel")
	local plyModel = self.plyModelMenu
	plyModel:SetSize(ScrW() / 2, ScrH() / 1.3)
	local plyModelW, plyModelH = plyModel:GetSize()
	local x, y = ScrW() / 1.4 - plyModelW / 2, ScrH() / 2 - plyModelH / 2
	plyModel:SetPos(ScrW(), y)
	plyModel:MoveTo(x, y, 1)
	plyModel:SetBackgroundColor(menuframeColor)
	plyModel:MakePopup()
	
	local menuTitle = vgui.Create("DLabel", plyModel)
	menuTitle:SetFont("MenuFont")
	menuTitle:SetText(lang.menu_playermodel)
	menuTitle:SizeToContents()
	menuTitle:SetPos(20, 10)
	menuTitle:SetColor(menuTextCol)
	
	local backgr = vgui.Create("DScrollPanel", plyModel)
	backgr:SetSize(plyModelW - 20, plyModelH - 170)
	backgr:SetPos(plyModelW / 2 - backgr:GetWide() / 2, menuTitle:GetTall() + 40)
	backgr:SetPaintBackground(true)
	backgr:SetBackgroundColor(Color(100, 100, 100, 180))
	
	local List = vgui.Create("DIconLayout", backgr)
	List:Dock(FILL)
	List:SetSpaceY(5)
	List:SetSpaceX(5)

	for name, model in SortedPairs(player_manager.AllValidModels()) do
		local mpanel = List:Add("DPanel") 
		mpanel:SetSize(64, 64)
		mpanel:SetBackgroundColor(Color(160, 90, 0, 150))
		local mdl = vgui.Create("SpawnIcon", mpanel)
		mdl:Dock( FILL )
		mdl:SetModel(model)
		function mdl:DoClick()
			surface.PlaySound(sndMenu2)
			ply.PreviewModel = model
		end
	end
	
	local button_gap = 100
	
	local applyb = vgui.Create("DLabel", plyModel)
	applyb:SetFont("MenuFont")
	applyb:SetText(lang.menu_apply)
	applyb:SizeToContents()
	applyb:SetPos(plyModelW / 2 - applyb:GetWide() / 2 - button_gap, plyModelH - applyb:GetTall() - 10)
	applyb:SetTextColor(menuTextCol)
	applyb:SetMouseInputEnabled(true)
	function applyb:DoClick()
		surface.PlaySound(sndMenu3)
		local model = ply.PreviewModel
		if model then
			RunConsoleCommand("hl1_coop_cl_playermodel", player_manager.TranslateToPlayerModelName(model))
			net.Start("SetPlayerModel")
			net.WriteString(model)
			net.SendToServer()
		end
		GAMEMODE:ModelSelectionMenu()
	end
	function applyb:OnCursorEntered()
		surface.PlaySound(sndMenu2)
		self:SetTextColor(menuTextSelected)
	end
	function applyb:OnCursorExited()
		self:SetTextColor(menuTextCol)
	end
	
	local closeb = vgui.Create("DLabel", plyModel)
	closeb:SetFont("MenuFont")
	closeb:SetText(lang.menu_cancel)
	closeb:SizeToContents()
	closeb:SetPos(plyModelW / 2 - closeb:GetWide() / 2 + button_gap, plyModelH - closeb:GetTall() - 10)
	closeb:SetTextColor(menuTextCol)
	closeb:SetMouseInputEnabled(true)
	function closeb:DoClick()
		surface.PlaySound(sndMenu3)
		GAMEMODE:ModelSelectionMenu()
	end
	function closeb:OnCursorEntered()
		surface.PlaySound(sndMenu2)
		self:SetTextColor(menuTextSelected)
	end
	function closeb:OnCursorExited()
		self:SetTextColor(menuTextCol)
	end
end

local function RunServerCommand(cvar, args)
	if !LocalPlayer():IsSuperAdmin() then return end
	net.Start("RunServerCommand")
	net.WriteString(cvar)
	if args then
		net.WriteString(args)
	end
	net.SendToServer()
end

local adminsettingscvars = {
	{"DLabel", "Allow custom playermodels", "hl1_coop_sv_custommodels", 0},
	{"DLabel", "Allow chatsounds", "hl1_coop_sv_chatsounds", 1},
	{"DLabel", "Allow player gibbing", "hl1_coop_sv_playergib", 1},
	{"DLabel", "Allow voting", "hl1_coop_sv_vote_enable", 1},
	{"DLabel", "Allow voting for spectators", "hl1_coop_sv_vote_allowspectators", 0},
	{"DLabel", "Disallow players to pick up other's weaponbox", "hl1_coop_sv_wboxstay", 0},
	{"DLabel", "NPC health depends on player count", "hl1_coop_sv_gainnpchealth", 1},
	{"DLabel", "Give medkit in non-survival mode", "hl1_coop_sv_medkit", 0},
	{"DLabel", "Speedrun mode (activating causes map restart)", "hl1_coop_speedrunmode", 0},
	{"DLabel", "Survival mode", "hl1_coop_sv_survival", 0},
	{"DLabel", "Crack mode (pls dont)", "hl1_coop_crackmode", 0},
	{"DNumSlider", "Skill level", "hl1_coop_sv_skill", 2, 0, 1, 4},
	{"DLabel", "Weapon MP rules", "hl1_sv_mprules", 0},
	{"DLabel", "Unlimited ammo", "hl1_sv_unlimitedammo", 0},
	{"DButton", "Cancel active vote", "vote_cancel"},
	{"DButton", "Restart map", "game_restart"},
	{"DButton", "Impulse 101", "hl1_coop_impulse101"},
	{"DButton", "Open SWEP menu", "swepmenu"},
}

function GM:OpenServerSettings()
	if !LocalPlayer():IsSuperAdmin() then return end
	self.Menu.adminSettings = vgui.Create("DPanel")
	local plySettings = self.Menu.adminSettings
	plySettings:SetSize(math.max(ScrW() / 3, 400), ScrH() / 1.65 + 200)
	local plySettingsW, plySettingsH = plySettings:GetSize()
	plySettings:SetPos(ScrW() / 2 - plySettingsW / 2, ScrH() / 2 - plySettingsH / 2)
	plySettings:SetBackgroundColor(menuframeColor)
	plySettings:MakePopup()
	
	local menuTitle = vgui.Create("DLabel", plySettings)
	menuTitle:SetFont("MenuFont")
	menuTitle:SetText("Admin menu")
	menuTitle:SizeToContents()
	menuTitle:SetPos(20, 10)
	menuTitle:SetColor(menuTextCol)
	
	local backgr = vgui.Create("DScrollPanel", plySettings)
	backgr:SetSize(plySettingsW - 20, plySettingsH - 130)
	backgr:SetPos(plySettingsW / 2 - backgr:GetWide() / 2, menuTitle:GetTall() + 20)
	backgr:SetPaintBackground(true)
	backgr:SetBackgroundColor(Color(100, 100, 100, 180))
	
	for k, v in pairs(adminsettingscvars) do
		local k = vgui.Create(v[1], backgr)
		k:SetText(v[2])
		if v[1] == "DNumSlider" then
			k:SetDecimals(v[5])
			k:SetMinMax(v[6], v[7])
			k:SetValue(GAMEMODE:GetSkillLevel())
			function k:OnValueChanged(value)
				RunServerCommand(v[3], math.Round(value))
			end
		elseif v[1] == "DButton" then
			function k:DoClick()
				GAMEMODE:CloseMenus()
				RunConsoleCommand(v[3])
			end
		else
			k:SetMouseInputEnabled(true)
			local bDisable = vgui.Create("DButton", k)
			bDisable:SetText("Disable")
			bDisable:Dock(RIGHT)
			function bDisable:DoClick()
				RunServerCommand(v[3], "0")
			end
			local bEnable = vgui.Create("DButton", k)
			bEnable:SetText("Enable")
			bEnable:Dock(RIGHT)
			function bEnable:DoClick()
				RunServerCommand(v[3], "1")
			end
		end
		k:Dock(TOP)
		k:DockMargin(20, 12, 20, 0)
	end
	
	local def = vgui.Create("DLabel", plySettings)
	def:SetFont("MenuFont")
	def:SetText("Default All")
	def:SizeToContents()
	def:SetPos(plySettingsW / 2 - def:GetWide() / 2, plySettingsH - def:GetTall() - 10)
	def:SetTextColor(menuTextCol)
	def:SetMouseInputEnabled(true)
	function def:DoClick()
		surface.PlaySound(sndMenu3)
		for k, v in pairs(adminsettingscvars) do
			if v[1] != "DButton" and v[4] then
				RunServerCommand(v[3], v[4])
			end
		end
	end
	function def:OnCursorEntered()
		surface.PlaySound(sndMenu2)
		self:SetTextColor(menuTextSelected)
	end
	function def:OnCursorExited()
		self:SetTextColor(menuTextCol)
	end
end

function GM:CloseMenus()
	if game.SinglePlayer() and self.Menu.MainMenuFrame and self.Menu.MainMenuFrame:IsVisible() then
		RunConsoleCommand("unpause")
	end
	for k, v in pairs(self.Menu) do
		if IsValid(v) then
			v:Remove()
		end
	end
end

function GM:CloseSubMenus()
	for k, v in pairs(self.Menu) do
		if IsValid(v) and v != self.Menu.MainMenuFrame then
			v:Remove()
		end
	end
end

function GM:PreRender()
	if gui.IsGameUIVisible() and self.Menu.MainMenuFrame and self.Menu.MainMenuFrame:IsVisible() then
		self:CloseMenus()
	end
	if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then
		--if !showGameUI then
			gui.HideGameUI()
			self:OpenMainMenu()
			return true
		--end
	--else
		--showGameUI = false
	end
end