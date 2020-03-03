
surface.CreateFont( "HL1Coop_ScoreboardDefault", {
	font	= "Helvetica",
	size	= 22,
	weight	= 0
} )

surface.CreateFont( "HL1Coop_ScoreboardDefaultTitle", {
	font	= "Roboto",
	size	= 26,
	weight	= 0
} )

surface.CreateFont( "HL1Coop_ScoreboardInfoText", {
	font	= "Helvetica",
	size	= 20,
	weight	= 0
} )

--
-- This defines a new panel type for the player row. The player row is given a player
-- and then from that point on it pretty much looks after itself. It updates player info
-- in the think function, and removes itself when the player leaves the server.
--
local PLAYER_LINE = {}
function PLAYER_LINE:Init()

	self.AvatarButton = self:Add( "DButton" )
	self.AvatarButton:Dock( LEFT )
	self.AvatarButton:SetSize( 32, 32 )
	self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

	self.Avatar = vgui.Create( "AvatarImage", self.AvatarButton )
	self.Avatar:SetSize( 32, 32 )
	self.Avatar:SetMouseInputEnabled( false )

	self.Name = self:Add( "DLabel" )
	self.Name:Dock( FILL )
	self.Name:SetFont( "HL1Coop_ScoreboardDefault" )
	self.Name:SetTextColor( Color( 70, 70, 70 ) )
	self.Name:DockMargin( 8, 0, 0, 0 )

	self.Mute = self:Add( "DImageButton" )
	self.Mute:SetSize( 32, 32 )
	self.Mute:Dock( RIGHT )

	self.Ping = self:Add( "DLabel" )
	self.Ping:Dock( RIGHT )
	self.Ping:SetWidth( 50 )
	self.Ping:SetFont( "HL1Coop_ScoreboardDefault" )
	self.Ping:SetTextColor( Color( 93, 93, 93 ) )
	self.Ping:SetContentAlignment( 5 )
	
	self.Health = self:Add( "DLabel" )
	self.Health:Dock( RIGHT )
	self.Health:SetWidth( 100 )
	self.Health:SetFont( "HL1Coop_ScoreboardDefault" )
	self.Health:SetTextColor( Color( 93, 93, 93 ) )
	self.Health:SetContentAlignment( 5 )

	self.Deaths = self:Add( "DLabel" )
	self.Deaths:Dock( RIGHT )
	self.Deaths:SetWidth( 80 )
	self.Deaths:SetFont( "HL1Coop_ScoreboardDefault" )
	self.Deaths:SetTextColor( Color( 93, 93, 93 ) )
	self.Deaths:SetContentAlignment( 5 )

	self.Score = self:Add( "DLabel" )
	self.Score:Dock( RIGHT )
	self.Score:SetWidth( 100 )
	self.Score:SetFont( "HL1Coop_ScoreboardDefault" )
	self.Score:SetTextColor( Color( 93, 93, 93 ) )
	self.Score:SetContentAlignment( 5 )

	self:Dock( TOP )
	//self:DockPadding( 3, 0, 3, 0 )
	self:SetHeight( 32 )
	self:DockMargin( 2, 0, 2, 2 )

end

function PLAYER_LINE:Setup(pl)

	self.Player = pl

	self.Avatar:SetPlayer( pl )

	self:Think( self )

	--local friend = self.Player:GetFriendStatus()
	--MsgN( pl, " Friend: ", friend )

end

function PLAYER_LINE:Think()

	if ( !IsValid( self.Player ) ) then
		self:SetZPos( 9999 ) -- Causes a rebuild
		self:Remove()
		return
	end

	if ( self.PName == nil || self.PName != self.Player:Nick() ) then
		self.PName = self.Player:Nick()
		self.Name:SetText( self.PName )
	end
	
	if ( self.NumScore == nil || self.NumScore != self.Player:GetScore() ) then
		self.NumScore = self.Player:GetScore()
		self.Score:SetText( self.NumScore )
	end

	if ( self.NumDeaths == nil || self.NumDeaths != self.Player:Deaths() ) then
		self.NumDeaths = self.Player:Deaths()
		self.Deaths:SetText( self.NumDeaths )
	end
	
	if ( self.NumHealth == nil || self.NumHealth != self.Player:Health() ) then
		self.NumHealth = self.Player:Health()
		self.Health:SetText( self.NumHealth )
	end

	if ( self.NumPing == nil || self.NumPing != self.Player:Ping() ) then
		self.NumPing = self.Player:Ping()
		self.Ping:SetText( self.NumPing )
	end

	--
	-- Change the icon of the mute button based on state
	--
	if ( self.Muted == nil || self.Muted != self.Player:IsMuted() ) then

		self.Muted = self.Player:IsMuted()
		if ( self.Muted ) then
			self.Mute:SetImage( "icon32/muted.png" )
		else
			self.Mute:SetImage( "icon32/unmuted.png" )
		end

		self.Mute.DoClick = function() self.Player:SetMuted( !self.Muted ) end

	end

	--
	-- Connecting players go at the very bottom
	--
	if ( self.Player:Team() == TEAM_CONNECTING ) then
		self:SetZPos( 2000 + self.Player:EntIndex() )
		return
	end

	--
	-- This is what sorts the list. The panels are docked in the z order,
	-- so if we set the z order according to kills they'll be ordered that way!
	-- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
	--
	self:SetZPos(-self.NumScore / 10 + self.Player:Team())

end

function PLAYER_LINE:Paint(w, h)

	if ( !IsValid( self.Player ) ) then
		return
	end

	--
	-- We draw our background a different colour based on the status of the player
	--
	
	local nickW, nickH = self.Name:GetTextSize()

	if self.Player:Team() == TEAM_CONNECTING then
		surface.SetDrawColor(Color(200, 200, 200, 50))
	elseif !self.Player:Alive() then
		if self.Player:Team() == TEAM_SPECTATOR then
			surface.SetDrawColor(Color(120, 120, 120, 80))
		else
			surface.SetDrawColor(Color(250, 200, 200, 100))
		end
	else
		local teamCol = team.GetColor(self.Player:Team())
		surface.SetDrawColor(Color(teamCol.r, teamCol.g, teamCol.b, 230))
	end
	surface.DrawRect(0, 0, w, h) 
	surface.SetDrawColor(Color(0, 0, 0, 200))
	surface.DrawOutlinedRect(0, 0, w, h)
	
	local ply = LocalPlayer()
	
	if self.Player == ply then
		local highlight = math.sin(RealTime() * 2) * 70 + 130
		surface.SetDrawColor(Color(255, 220, 50, highlight))
		surface.DrawRect(0, 0, w, h) 
		--draw.RoundedBox( 4, self.Avatar:GetWide() + 4, nickH / 3, nickW+8, h/1.5, Color( 100, 255, 255, 80 ) )
	end
	
	local viewent = ply:GetViewEntity()
	local obs = ply:GetObserverTarget()
	if viewent != ply and viewent == self.Player or IsValid(obs) and obs == self.Player then
		local sine = math.sin(RealTime() * 6) * 100 + 150
		surface.SetDrawColor(Color(200, 255, 200, sine))
		surface.DrawOutlinedRect(0, 0, w, h) 
	end
	
	if ply:CanChasePlayer() and self.Highlight then
		surface.SetDrawColor(Color(200, 200, 200, 100))
		surface.DrawRect(0, 0, w, h) 
	end
	
end

function PLAYER_LINE:OnCursorEntered()
	self.Highlight = true
end

function PLAYER_LINE:OnCursorExited()
	self.Highlight = false
end

function PLAYER_LINE:OnMousePressed(key)
	if LocalPlayer():CanChasePlayer() and key == MOUSE_FIRST then
		RunConsoleCommand("chase", self.Player:UserID())
	end
end

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
vgui.Register( "Scoreboard_PlayerLine", PLAYER_LINE, "DPanel" )

--
-- Here we define a new panel table for the scoreboard. It basically consists
-- of a header and a scrollpanel - into which the player lines are placed.
--
local SCOREBOARD = {}
function SCOREBOARD:Init()

	self.Header = self:Add( "Panel" )
	self.Header:Dock( TOP )
	self.Header:SetHeight( 100 )

	self.Name = self.Header:Add( "DLabel" )
	self.Name:SetFont( "HL1Coop_ScoreboardDefaultTitle" )
	self.Name:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.Name:Dock( TOP )
	self.Name:SetHeight( 40 )
	self.Name:SetContentAlignment( 5 )
	self.Name:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )
	
	self.Logo = self.Header:Add("DImage")
	self.Logo:Dock( LEFT )
	self.Logo:DockMargin( 20, -1, 0, 0 )
	self.Logo:SetWidth( 150 )
	self.Logo:SetImage("hl1coop_logo.png")
	
	self.Map = self.Header:Add( "DLabel" )
	self.Map:SetFont( "HL1Coop_ScoreboardInfoText" )
	self.Map:SetTextColor( Color( 240, 240, 230, 200 ) )
	self.Map:Dock( RIGHT )
	self.Map:DockMargin( 30, 5, 0, 0 )
	self.Map:SetHeight( 55 )
	self.Map:SetContentAlignment( 6 )
	self.Map:SetExpensiveShadow( 1, Color( 0, 0, 0, 150 ) )
	
	self.ModeInfo = self.Header:Add( "DLabel" )
	self.ModeInfo:SetFont( "HL1Coop_ScoreboardInfoText" )
	self.ModeInfo:SetTextColor( Color( 240, 240, 230, 200 ) )
	self.ModeInfo:Dock( TOP )
	self.ModeInfo:DockMargin( 0, 5, 20, 0 )
	self.ModeInfo:SetHeight( 55 )
	self.ModeInfo:SetContentAlignment( 6 )
	self.ModeInfo:SetExpensiveShadow( 1, Color( 0, 0, 0, 150 ) )
	
	self.TitleScore = self:Add( "DLabel" )
	self.TitleScore:SetFont( "HL1Coop_ScoreboardDefaultTitle" )
	self.TitleScore:SetText( "Score" )
	self.TitleScore:SetTextColor( Color( 255, 240, 0, 255 ) )
	self.TitleScore:Dock(TOP)
	self.TitleScore:DockMargin( 0, 0, 290, -32 )
	self.TitleScore:SetHeight( 32 )
	self.TitleScore:SetContentAlignment( 6 )
	self.TitleScore:SetExpensiveShadow( 2, Color( 0, 0, 0, 180 ) )
	
	self.TitleDeaths = self:Add( "DLabel" )
	self.TitleDeaths:SetFont( "HL1Coop_ScoreboardDefaultTitle" )
	self.TitleDeaths:SetText( "Deaths" )
	self.TitleDeaths:SetTextColor( Color( 255, 240, 0, 255 ) )
	self.TitleDeaths:Dock(TOP)
	self.TitleDeaths:DockMargin( 0, 0, 195, -32 )
	self.TitleDeaths:SetHeight( 32 )
	self.TitleDeaths:SetContentAlignment( 6 )
	self.TitleDeaths:SetExpensiveShadow( 2, Color( 0, 0, 0, 180 ) )
	
	self.TitleHealth = self:Add( "DLabel" )
	self.TitleHealth:SetFont( "HL1Coop_ScoreboardDefaultTitle" )
	self.TitleHealth:SetText( "Health" )
	self.TitleHealth:SetTextColor( Color( 255, 240, 0, 255 ) )
	self.TitleHealth:Dock(TOP)
	self.TitleHealth:DockMargin( 0, 0, 105, -32 )
	self.TitleHealth:SetHeight( 32 )
	self.TitleHealth:SetContentAlignment( 6 )
	self.TitleHealth:SetExpensiveShadow( 2, Color( 0, 0, 0, 180 ) )
	
	self.TitlePing = self:Add( "DLabel" )
	self.TitlePing:SetFont( "HL1Coop_ScoreboardDefaultTitle" )
	self.TitlePing:SetText( "Ping" )
	self.TitlePing:SetTextColor( Color( 255, 240, 0, 255 ) )
	self.TitlePing:Dock(TOP)
	self.TitlePing:DockMargin( 0, 0, 40, 0 )
	self.TitlePing:SetHeight( 32 )
	self.TitlePing:SetContentAlignment( 6 )
	self.TitlePing:SetExpensiveShadow( 2, Color( 0, 0, 0, 180 ) )

	self.Scores = self:Add( "DScrollPanel" )
	self.Scores:Dock( FILL )
	self.Scores:DockMargin( 0, 8, 0, 0 )
end

function SCOREBOARD:PerformLayout()

	self:SetSize( 800, ScrH() - 200 )
	self:SetPos( ScrW() / 2 - self:GetWide() / 2, 100 )

end

function SCOREBOARD:Paint(w, h)

	--draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 200 ) )

end

function SCOREBOARD:Think(w, h)

	self.Name:SetText( GetHostName() )
	local skill = SKILL_LEVEL[GAMEMODE:GetSkillLevel()] or "0"
	self.Map:SetText( "Map: "..game.GetMap().."\nSkill: "..skill)
	self.Map:SizeToContents()
	local bSurvivalMode = GAMEMODE:GetSurvivalMode()
	local bSpeedrunMode = GAMEMODE:GetSpeedrunMode()
	local strSurvivalMode = bSurvivalMode and "Survival Mode" or ""
	local strSpeedrunMode = bSpeedrunMode and "Speedrun Mode" or ""
	local n = bSurvivalMode and bSpeedrunMode and "\n" or ""
	self.ModeInfo:SetText(strSurvivalMode..n..strSpeedrunMode)

	--
	-- Loop through each player, and if one doesn't have a score entry - create it.
	--
	local plyrs = player.GetAll()
	for id, pl in pairs( plyrs ) do

		if !IsValid( pl.ScoreEntry ) then
			pl.ScoreEntry = vgui.CreateFromTable( PLAYER_LINE, pl.ScoreEntry )
			pl.ScoreEntry:Setup( pl )
			
			self.Scores:AddItem( pl.ScoreEntry )
			
			pl.CurTeam = pl:Team()
		elseif pl.CurTeam > 0 and pl.CurTeam != pl:Team() then
			pl.ScoreEntry:Remove()
		end

	end

end

vgui.Register( "Scoreboard", SCOREBOARD, "EditablePanel" )

--[[---------------------------------------------------------
	Name: gamemode:ScoreboardShow( )
	Desc: Sets the scoreboard to visible
-----------------------------------------------------------]]
function GM:ScoreboardShow()

	if ( !IsValid( g_Scoreboard ) ) then
		g_Scoreboard = vgui.Create("Scoreboard")
	end

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Show()
		g_Scoreboard:MakePopup()
		g_Scoreboard:SetKeyboardInputEnabled( false )
	end

end

--[[---------------------------------------------------------
	Name: gamemode:ScoreboardHide( )
	Desc: Hides the scoreboard
-----------------------------------------------------------]]
function GM:ScoreboardHide()

	if ( IsValid( g_Scoreboard ) ) then
		--g_Scoreboard:Remove()
		g_Scoreboard:Hide()
	end

end

--[[---------------------------------------------------------
	Name: gamemode:HUDDrawScoreBoard( )
	Desc: If you prefer to draw your scoreboard the stupid way (without vgui)
-----------------------------------------------------------]]
function GM:HUDDrawScoreBoard()
end
