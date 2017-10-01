remstart

	ACHILLES v0.9 ~ Created 3/14/16 by Bob Tedesco Jr
	Two ways to win - base capture, or eliminate all enemy units

	ISSUES/REVISIONS
		---BETTER ASTAR?? -- AITANKS STUCK BEHIND WALLS

		---IMPLEMENT SWARM
		---BETTER AI BASE PROTECT?
		---BETTER AI ENGINEER PROTECTION
		---GREY OUT MAP SLOT SAVE BUTTONS

		---IMPLEMENT "OUT OF REACH" WARNING FOR MOVE TO OCCUPIED NODE

		---RESTRICT MOVES TO LOS SPRITE BOUNDARY

	FIXED?
		---MYSTERIOUS LOS BLOCKAGE??!!
		---TANKS UNSELECTABLE or DEAD SPOTS ON SCREEN??
		---BASES APPEARING OUT OF NOWHERE?
		---AI BASE SHOWED UP ON PLAYER SIDE IN RANDOM MAP GENERATION (ONLY HAPPENS WHILE RUNNING AND GENERATED AFTER AN ABANDONED GAME)
		---SELECTING A MOVEMENT SQUARE TWICE GENERATES "OUT OF REACH" MESSAGE
		---TREES NO LONGER BLOCKED!!!!!!!!!
		---PRODUCTION UNIT TOTALS TAKEN AWAY WHEN BASE CAPTURED!!!
		---UNITS NOT SELECTABLE!!!!!!
		---PHANTOM BASE/UNIT SPAWN??????------
		---LOS IMPROPERLY BLOCKED!!!!!
		---HEAVILY DAMAGED AI TANKS DON'T VISIT DEPOTS
		---AI RELUCTANT TO FIRE; MAKING POOR MOVE DECISIONS (dont remove "nearestplayer" from goalset?)

	FUTURE
		Accumulated experience
		Multiplayer
		Races/Factions?

		---AITank visibility - Initialize and AIFOW
		---LOS -- Mod at end of PlayerOps
remend

SetVirtualResolution( MaxWidth,MaxHeight )
SetDisplayAspect( AspectRatio )
SetWindowSize( MaxWidth,MaxHeight,1,1 )
MaximizeWindow()
SetWindowPosition( 0,0 )
SetOrientationAllowed( 0, 0, 1, 1 )
//~ LoadFont( Gill,"GillSans.ttf" )
LoadFont( Avenir,"Avenir Next.ttc" )
UseNewDefaultFonts( On )

#insert "Labels.agc"
#include "Settings.agc"
#include "MainMenu.agc"
#include "Initialize.agc"
#include "Players.agc"
#include "AI.agc"
#include "Path.agc"
#include "Miscellaneous.agc"


//~ WaterTest()
//~ SwarmTest()
//~ ParticleTest()


Main()

function Main()
	MainMenu()
	Initialize()
	do
		PlayerOps()
		AIOps()
		Turn()
	loop
endfunction



`COMMON FUNCTIONS

function Turn()
	inc turns
	inc PlayerProdUnits,(PlayerBaseCount+1)*BaseProdValue
	inc AIProdUnits,(AIBaseCount+1)*BaseProdValue
	ShowInfo(On)
	Sync()
endfunction

function LegalMove(node,team)
	if (node < 0) and (node > MapSize)
		legal = False
	elseif mapTable[node].terrain >= Impassable
		legal = False
	elseif mapTable[node].base <> Empty
		legal = True
	elseif mapTable[node].team //(team = PlayerTeam) and
		legal = False
	else
		legal = True
	endif
endfunction legal

function WeaponSelect(ID,Tank ref as tankType[],w,r,d#)
	Tank[ID].weapon = w
	Tank[ID].range  = r
	Tank[ID].damage = d#
	if Tank[ID].team = PlayerTeam
		PlaySound(ClickSound,vol)
		WeaponButtons(ID,Tank[ID].vehicle)
	endif
endfunction

function Produce( ID, Tank ref as tankType[], rate, baseProduct, baseID, c as ColorSpec )
	if baseProduct
		SetSpriteVisible(Tank[ID].bodyID,Off)
		SetSpriteVisible(Tank[ID].turretID,Off)
		SetSpriteVisible(Tank[ID].healthID,Off)
		SetSpriteVisible(baseID,On)
		Delay(.3)
		PlaySound(SpawnSound,vol)
		SetSpritePositionByOffset(Iris,Tank[ID].x+2,Tank[ID].y-1)
		SetSpriteColor(Iris, c.r, c.g, c.b, c.a)
		SetSpriteVisible(Iris,On)
		frames = IrisFrames*1.5
		PlaySprite(Iris,frames,0)
		repeat
			Sync()
		until GetSpriteCurrentFrame(Iris) >= (frames/2)
		SetSpriteDepth(Iris,3)
		SetSpriteVisible(baseID,Off)
	elseif mapTable[Tank[ID].node].terrain = Trees
		SetSpritePositionByOffset(Tank[ID].cover,Tank[ID].x,Tank[ID].y)
		SetSpriteVisible(Tank[ID].cover,On)
	endif
	generateFOW = baseproduct and (Tank[ID].team = PlayerTeam)
	if generateFOW
		SetSpriteVisible(Tank[ID].FOW,On)
		FOWSize = Tank[ID].FOWSize / ( NodeSize / rate )
		SetSpriteSize(Tank[ID].FOWSize,FOWSize,FOWSize)
		SetSpriteSize(Tank[ID].FOWSize,FOWSize,FOWSize)
	endif
	SetSpriteVisible(Tank[ID].bodyID,On)
	SetSpriteVisible(Tank[ID].turretID,On)
	SetSpritePositionByOffset(Tank[ID].bodyID,Tank[ID].x,Tank[ID].y)
	SetSpritePositionByOffset(Tank[ID].turretID,Tank[ID].x,Tank[ID].y)
	if baseproduct
		for i = 1 to NodeSize step rate
			SetSpriteSize(Tank[ID].bodyID,i,i)
			SetSpriteSize(Tank[ID].turretID,i,i)
			if generateFOW
				growth = FOWSize * i
				growthShift = growth / 2
				SetSpriteSize(Tank[ID].FOW,growth,growth)
				SetSpritePosition(Tank[ID].FOW, mapTable[Tank[ID].node].x - growthShift, mapTable[Tank[ID].node].y - growthShift)
			endif
			Sync()
		next i
		PlaySprite(Iris,frames,0,IrisFrames,1)
		Delay(.5)
		SetSpriteVisible(baseID,On)
		SetSpriteVisible(Iris,Off)
		SetSpriteDepth(Iris,0)
	endif
	HealthBar(ID,Tank)
endfunction

function LOSblocked(x1,y1,x2,y2)
	if PhysicsRayCastGroup(blockGroup,x1,y1,x2,y2)
		if VectorDistance(x1,y1,x2,y2) > DLS then exitfunction True else exitfunction False  `adjacent nodes are always in LOS
	endif
endfunction False

function RotateTurret(ID,Tank ref as tankType[],x2,y2)
	x1 = Tank[ID].x
	y1 = Tank[ID].y
	turretAngle# = GetSpriteAngle( Tank[ID].turretID )
	targetAngle# = atan2( y1-y2,x1-x2 )-90
	arc# = SetTurnArc(turretAngle#,targetAngle#)
	t1 = SetTween( x1,y1,x1,y1,turretAngle#,arc#,Tank[ID].turretID,TweenLinear(),.25 )
	PlayTweens( t1, Tank[ID].turretID )
endfunction

function Fire( Attacker ref as tankType[], Defender ref as tankType[], attID, defID )
	damage# as float
	select Attacker[attID].weapon
		case cannon,heavyCannon
			RotateTurret(attID,Attacker,Defender[defID].x,Defender[defID].y)
			CannonFire(Attacker[attID].x,Attacker[attID].y,Defender[defID].x,Defender[defID].y)
		endcase
		case missile
			MissileFire(Attacker[attID].x,Attacker[attID].y,Defender[defID].x,Defender[defID].Y)
		endcase
		case laser,heavyLaser
			RotateTurret(attID,Attacker,Defender[defID].x,Defender[defID].y)
			LaserFire(Attacker[attID].x,Attacker[attID].y,Defender[defID].x,Defender[defID].y,Attacker[attID].weapon,1.25,2,0)
		endcase
		case emp
			ActivateEMP( attID,Attacker )
			exitfunction
		endcase
		case mine
			node = CalcNodeFromScreen(Attacker[attID].x,Attacker[attID].y)
			if mapTable[node].mineType = Null then LayMine(attID,Attacker,node)
			exitfunction
		endcase
		case Undefined : exitfunction : endcase
	endselect

	damage# = maptable[Defender[defID].parentNode[Defender[defID].index]].modifier

	damage# = (damage# * Attacker[attID].damage) * 100
	damage# = Min(10,Randomize(damage#-15,damage#+15)) `+/-15%
	dec Defender[defID].health,damage#/100.0

	VictoryConditions(defID,Defender)
	HealthBar(defID,Defender)
	Attacker[attID].target = Undefined
	Sync()
endfunction

function LayMine(ID,Tank ref as tankType[],node)
	if Tank[ID].team = PlayerTeam
		ShowMine( ID,Tank,node )
	else
		mapTable[node].mineSprite = CreateDummySprite()
		SetSpriteDepth( mapTable[node].mineSprite,1 )
		maptable[node].mineType = AITeam
	endif
	dec Tank[ID].mines
endfunction

function ShowMine(ID,Tank as tankType[],node)
	mapTable[node].mineSprite = CloneSprite( Mine1 )
	PlaySound( MineSound,vol )
	maptable[node].mineType = PlayerTeam
	SetSpriteVisible( mapTable[node].mineSprite,On )
	SetSpriteDepth( mapTable[node].mineSprite,1 )
	SetSpritePositionByOffset( mapTable[node].mineSprite,Tank[ID].x+1,Tank[ID].y-3 )
	PlaySprite( mapTable[node].mineSprite,20 )
endfunction

function MineField(ID, Tank ref as tankType[])
	node = CalcNodeFromScreen( Tank[ID].x,Tank[ID].y )
	if maptable[node].mineType and ( mapTable[node].mineType <> Tank[ID].team )
		PlaySound( MineBangSound,vol )
		if mapTable[node].mineType = AITeam
			ShowMine( ID,Tank,node )
			SetSpriteDepth( mapTable[node].mineSprite,0 )
			Delay( 1 )
		else
			SetSpriteDepth( mapTable[node].mineSprite,0 )
		endif
		DeleteSprite( maptable[node].mineSprite )

		SetSpriteVisible( MineExplode,On )
		SetSpritePositionByOffset( MineExplode,Tank[ID].x,Tank[ID].y )
		PlaySprite( MineExplode,12,0 )
		while GetSpritePlaying( MineExplode )
			Sync()
		endwhile
		SetSpriteVisible( MineExplode,Off )

		maptable[node].mineSprite = Null
		maptable[node].minetype = Null
		damage# = mineDamage * 100
		damage# = Min( 10,Randomize(damage#-15,damage#+15) ) `+/-15%
		dec Tank[ID].health,damage#/100.0
				VictoryConditions( ID,Tank )
		exitfunction True
	endif
endfunction False

function RepairDepot(ID,Tank ref as tankType[],depotNode as depotType[],depot,healthMax as float )
	brightness as integer
	offset as integer
	if maptable[Tank[ID].parentNode[Tank[ID].index]].terrain = depot
		if GetSpriteVisible(Tank[ID].bodyID)
			if (Tank[ID].health < healthMax) or (Tank[ID].missiles < Tank[ID].rounds) or (Tank[ID].mines < Tank[ID].rounds) or (Tank[ID].charges < Tank[ID].rounds)
				PlaySound( HealSound,vol )
				depotID = depotNode[ maptable[Tank[ID].parentNode[Tank[ID].index]].depotID ].spriteID
				fullScale = ceil(DepotSize*2.5)
				halfway = fullScale/2
				alpha = FullAlpha
				brightness = (FullAlpha/fullScale)*2
				SetSpriteDepth(depotID,0)
				r = GetSpriteColorRed(depotID) : g = GetSpriteColorGreen(depotID) : b = GetSpriteColorBlue(depotID)
				SetSpriteColor(depotID,255,255,255,FullAlpha)
				SetSpriteColorAlpha(Tank[ID].bodyID,128)
				SetSpriteColorAlpha(Tank[ID].turretID,128)
				for i = 1 to fullScale
					if i > halfway then dec alpha,brightness
					offset = ceil(i/2)
					SetSpriteSize(depotID,i,i)
					SetSpriteColorAlpha(depotID,alpha)
					SetSpritePosition(depotID,Tank[ID].x-offset,Tank[ID].y-offset)
					Sync()
				next i
				SetSpritePosition(depotID,Tank[ID].x-depotOffset,Tank[ID].y-depotOffset)
				SetSpriteSize(depotID,DepotSize,DepotSize)
				SetSpriteDepth(depotID,DepotDepth)
				SetSpriteColor(depotID,r,g,b,FullAlpha)
				SetSpriteColorAlpha(Tank[ID].bodyID,FullAlpha)
				SetSpriteColorAlpha(Tank[ID].turretID,FullAlpha)
			endif
		endif
		Tank[ID].health = healthMax
		Tank[ID].missiles = Tank[ID].rounds
		Tank[ID].mines = Tank[ID].rounds
		Tank[ID].charges = Tank[ID].rounds
		if Tank[ID].team = PlayerTeam
			WeaponButtons(ID,Tank[ID].vehicle)
			HealthBar(ID,Tank)
		endif
	endif
endfunction

function HealthBar(ID,Tank ref as tankType[])
	width = BarWidth * Tank[ID].scale
    health# = Tank[ID].health / Tank[ID].maximumHealth
	height# = Min(BarWidth,(health# * BarHeight) * Tank[ID].scale)
	c = ( Tank[ID].health / Tank[ID].maximumHealth ) * 255
	if c < 255
		if c > 160
			c = 160
		elseif c
			c = 0
		endif
	endif
	SetSpriteColor( Tank[ID].healthID,c,c,c,255 )
    SetSpriteSize(Tank[ID].healthID, width, height#)
	SetSpritePosition(Tank[ID].healthID,Tank[ID].x-NodeOffset,Tank[ID].y-NodeOffset+BarOffset)
	SetSpriteVisible(Tank[ID].healthID, On)
	Sync()
endfunction

function CaptureBase( capturedIndex, pick ref as ColorSpec, attBase ref as baseType[], defBase ref as baseType[], base, group )
	DeleteSprite( defBase[capturedIndex].spriteID )
	newBaseIndex = BaseSetup( defBase[capturedIndex].spriteID,defBase[capturedIndex].node,base,attBase,group )
	PlaySound( BuildBaseSound )

	SetSpritePositionByOffset( BaseHalo,mapTable[defBase[capturedIndex].node].x,mapTable[defBase[capturedIndex].node].y )
	SetSpriteVisible( BaseHalo,On )

	for i = 255 to 0 step -15
		SetSpriteColor( attBase[newBaseIndex].spriteID,i,i,i,i )
		Sync()
	next i
	for i = 0 to pick.a step 15
		SetSpriteColor( attBase[newBaseIndex].spriteID,pick.r,pick.g,pick.b,i )
		Sync()
	next i
	SetSpriteColor( attBase[newBaseIndex].spriteID,pick.r,pick.g,pick.b,i )
	Sync()
	defBase.remove( capturedIndex )
								//~ AIBaseCount = AIBases.length
								//~ PlayerBaseCount = PlayerBases.length
	SetSpriteVisible( BaseHalo,Off )
endfunction

function VictoryConditions( ID,Tank ref as tankType[] )
	//~ if not Tank[ID].alive then exitfunction
	if Tank[ID].health <= 0
		KillTank(ID,Tank)
		if Tank[ID].team = PlayerTeam
			if PlayerSurviving = 0 then GameOver( DefeatText,255,0,0,0,0,0,"DEFEAT",DefeatSound ) `all tanks destroyed?
		elseif Tank[ID].team = AITeam `not necessary
			if AISurviving = 0 then GameOver( VictoryText,0,0,0,255,255,255,"VICTORY",VictorySound ) `create victory & defeat sounds
		endif
	else
		if Tank[ID].team = PlayerTeam
			for i = 0 to AIBaseCount
				if Tank[ID].parentNode[Tank[ID].index] = AIBases[i].node
					dec AIBaseCount
					inc PlayerBaseCount
					CaptureBase( i,pickPL,PlayerBases,AIBases,PlayerBase,BaseGroup )
					if AIBaseCount = -1 then GameOver( VictoryText,0,0,0,255,255,255,"VICTORY",VictorySound )
								AIBaseCount = AIBases.length
								PlayerBaseCount = PlayerBases.length
				endif
			next i
		else
			for i = 0 to PlayerBaseCount
				if Tank[ID].parentNode[Tank[ID].index] = PlayerBases[i].node
					SetSpriteVisible(Tank[ID].bodyID,On)
					SetSpriteVisible(Tank[ID].turretID,On)
					dec PlayerBaseCount
					inc AIBaseCount
					CaptureBase( i,pickAI,AIBases,PlayerBases,AIBase,AIBaseGroup )
					if PlayerBaseCount = -1 then GameOver( DefeatText,150,0,0,0,0,0,"DEFEAT",DefeatSound )
								AIBaseCount = AIBases.length
								PlayerBaseCount = PlayerBases.length
				endif
			next i
		endif
	endif
endfunction

function GameOver( textID,r,g,b,Pr,Pg,Pb,message$,sound )
	#constant startSize 750
	#constant endSize 100
	#constant beginSpacing 300
	#constant endSpacing 0
	part as integer

	PlaySound( sound )
	DeleteVirtualButton(AcceptButton)
	DeleteVirtualButton(QuitButton)
	DeleteAllText()
	ft# = GetFrameTime()
	y2 = MapHeight/2
	y1 = y2-(startSize/2)

	Text( textID,message$,MiddleX,y2,r,g,b,startSize,255,1 )
	SetTextFont( textID,Avenir )
	tt = TweenText( textID,Null,Null,y1,y2,Null,Null,startSize,endSize,beginSpacing,endSpacing,3,Null,TweenEaseIn1() )

	if GetMouseExists() then SetRawMouseVisible( On )
	repeat
		if GetTweenExists( tt )
			if GetTweenTextPlaying( tt,textID )
				UpdateAllTweens( ft# )
			else
				DeleteTween( tt )
				DeleteAllSprites()
				SetupSprite(field,field,"AchillesBoardClear.png",0,0,MaxWidth,MaxHeight,12,On,0)
				part = Particles( MiddleX,y2+(endSize/2),Pr,Pg,Pb )
			endif
		endif
		if GetParticlesExists( part ) then UpdateParticles( part,.25 )
		Sync()
	until GetPointerPressed()
	if GetParticlesExists( part ) then DeleteParticles( part )
	Main() `restart Achilles
endfunction

function Particles( x,y,r,g,b )
	part = CreateParticles( x,y )
	AddParticlesScaleKeyFrame( part,1,.33 )
	AddParticlesColorKeyFrame( part,0,r,g,b,96 )
	SetParticlesLife( part,20 )
	SetParticlesSize( part,12 )
	SetParticlesDepth( part,1 )
	SetParticlesVelocityRange( part,1.25,1)
	SetParticlesFrequency( part,1000 )
endfunction part

function KillTank( defID,Tank ref as tankType[] )
	PlaySound( ExplodeSound,vol )
	smoke1 = CreateParticles( Tank[defID].x,Tank[defID].y )
	AddParticlesScaleKeyFrame( smoke1, .5, .5 )
	AddParticlesColorKeyFrame( smoke1, 0, 255, 255, 255, 96 )
	AddParticlesColorKeyFrame( smoke1, .25, 255, 128, 0, 96 )
	AddParticlesColorKeyFrame( smoke1, .5, 255, 0, 0, 96 )
	AddParticlesColorKeyFrame( smoke1, .75, 0, 0, 0, 96 )
	SetParticlesFrequency( smoke1, 75 )
	SetParticlesLife( smoke1, 1 )
	SetParticlesSize( smoke1, 42 )
	SetParticlesImage( smoke1, whiteSmokeImage )
	SetParticlesDirection( smoke1, 25, 50 )
	SetParticlesDepth( smoke1, 0 )
	SetParticlesVelocityRange( smoke1, .5, .75 )

	DeleteSprite( Tank[defID].healthID )
	DeleteSprite( Tank[defID].bodyID )
	DeleteSprite( Tank[defID].turretID )
	DeleteSprite( Tank[defID].stunMarker )
	Explosion( Tank[defID].x,Tank[defID].y,Explode2,ExplodingSound,48 )
	SetParticlesVisible( smoke1,0 )

	if Tank[defID].team = PlayerTeam
		DeleteSprite(Tank[defID].FOW)
				//~ DeleteSprite(Tank[defID].FOWDummy)
		DeleteSprite( Tank[defID].hilite )
		dec PlayerSurviving
	else
		dec AISurviving
	endif
	if Tank[defID].moveTarget then mapTable[Tank[defID].moveTarget].moveTarget = False  `clear target

	if mapTable[Tank[defID].parentNode[Tank[defID].index]].terrain = Trees then SetSpriteVisible(Tank[defID].cover,0)
	mapTable[Tank[defID].parentNode[Tank[defID].index]].team = Unoccupied
	Tank[defID].alive = False
endfunction

function Explosion( x,y,ID,sound,fps )
	PlaySound( sound,vol )
	SetSpriteVisible( ID,On )
	SetSpritePositionByOffset( ID,x,y )
	PlaySprite( ID,fps,0 )
	repeat
		Sync()
	until not GetSpritePlaying( ID )
	SetSpriteVisible( ID,Off )
endfunction

function ActivateEMP( ID, Tank ref as tankType[] )
	#constant AlphaPlus 325
	SetSpriteVisible( EMP1,On )
	for i = 1 to 5
		if mod(i,2) then PlaySound( EMPSound )  `every other wave
		for j = NodeSize to empRange step 30
			shift = j/2
			SetSpritePosition( EMP1,Tank[ID].x-shift,Tank[ID].y-shift )
			SetSpriteColorAlpha( EMP1,AlphaPlus-j )
			SetSpriteSize( EMP1,j,j )
			Sync()
		next j
	next i
	SetSpriteVisible( EMP1,Off )
	Stun( ID, Tank, AITank, AIPlayerLast )
	Stun( ID, Tank, PlayerTank, PlayerLast )
	dec Tank[ID].charges
endfunction

function Stun( ID, Tank as TankType[], Defender ref as tankType[], lastUnit )
	for i = 0 to lastUnit
		if Defender[i].alive
			if Tank[ID].bodyID = Defender[i].bodyID then continue
			if GetSpriteInCircle( Defender[i].bodyID, Tank[ID].x, Tank[ID].y, Tank[ID].FOWoffset-NodeSize )
				if Defender[i].team = PlayerTeam then CancelMove( i,Defender )
				inc Defender[i].stunned
				PlaySprite( Defender[i].stunMarker,15,1 )
				SetSpriteVisible( Defender[i].stunMarker, On )
				SetSpritePositionByOffset( Defender[i].stunMarker, Defender[i].x, Defender[i].y )
				Sync()
			endif
		endif
	next i
endfunction

function Wake( ID, Tank as tankType[] )
	SetSpriteColor(Tank[ID].turretID,255,255,255,255)
	SetSpriteVisible( Tank[ID].stunMarker, Off )
	StopSprite( Tank[ID].stunMarker )
endfunction

function CannonFire( x1,y1,x2,y2 )
	PlaySound( BangSound,vol )
	SetSpriteVisible( Fire1,On )
	SetSpritePositionByOffset( Fire1, x1, y1 )
	a = GetSpriteAngle( Fire1 )
	t = SetTween( x1,y1,x2,y2,a,a,Fire1,TweenEaseIn2(),.5)
	SetTweenSpriteSizeX( t, 96, 48, TweenEaseIn2() )
	SetTweenSpriteSizeY( t, 96, 48, TweenEaseIn2() )
	PlaySprite( Fire1, 16, 1 )
	PlayTweens( t, Fire1 )
	SetSpriteVisible( Fire1,Off )
	Explosion( x2,y2,Explode1,ExplodeSound,24 )
endfunction

function MissileFire( x1,y1,x2,y2 )
	PlaySound( RocketSound,vol )
	SetSpriteVisible( missile1,On )
	SetSpritePositionByOffset( missile1, x1, y1 )
	missileAngle# = GetSpriteAngle( missile1 )
	targetAngle# = atan2(y1-y2,x1-x2)-90
	arc# = SetTurnArc(missileAngle#,targetAngle#)
	t = SetTween( x1,y1,x2,y2,missileAngle#,arc#,missile1,TweenEaseIn2(),.5)
	PlaySprite( missile1, 16, 1 )
	PlayTweens( t, missile1 )
	SetSpriteVisible( missile1,Off )
	Explosion( x2,y2,Explode1,ExplodeSound,24 )
endfunction

function LaserFire( x1,y1,x2,y2,weapon,t1#,t2#,interrupt )
	if weapon = laser then ls = PlaySound( LaserSound,vol ) else ls = PlaySound( HeavyLaserSound,vol )
	SetSoundInstanceRate( ls, 1 )
	laser1=CreateParticles( x2, y2 )
	AddParticlesColorKeyFrame( laser1,1.5,192,0,0,255 )
	AddParticlesColorKeyFrame( laser1,1.75,192,192,0,255 )
	SetParticlesColorInterpolation( laser1,1 )
	SetParticlesLife( laser1, .5 )
	SetParticlesSize( laser1, 24 )
	SetParticlesVelocityRange( laser1, .1, .75 )
	SetParticlesImage( laser1, whiteSmokeImage )
	SetParticlesDirection ( laser1, 25, 50 )
	SetParticlesDepth( laser1, 0 )
	ResetTimer()
	count = 60
	repeat
		if interrupt
			cancel = GetVirtualButtonState( QuitButton )
			accept = GetVirtualButtonState( AcceptButton )
			settings = GetVirtualButtonState( SettingsButton )
			if cancel or settings or accept then exit
		endif
		if Timer() <= t1#  `1.25
			DrawLine(x1,y1,x2,y2,laserFull,laserOut) : Sync()
			DrawLine(x1,y1,x2,y2,laserFull,laserOut) : Sync()
			DrawLine(x1,y1,x2,y2,laserFull,laserFull) : Sync()
			DrawLine(x1,y1,x2,y2,laserFull,laserFade) : Sync()
		endif
		SetParticlesFrequency( laser1, count )
		SetParticlesVisible( laser1,1 )
		Sync()
		dec count,5
	until Timer() >= t2#  `2
	SetParticlesVisible( laser1,0 )
endfunction

function SetTween( x1,y1,x2,y2,a1#,a2#,sprite,mode,speed#  )
	t = CreateTweenSprite( speed# )
	SetTweenSpriteXByOffset( t, x1, x2, mode )
	SetTweenSpriteYByOffset( t, y1, y2, mode )
	SetTweenSpriteAngle( t, a1#, a2#, mode )
	PlayTweenSprite( t, sprite, 0 )
endfunction t

function PlayTweens( tween, sprite )
	while GetTweenSpritePlaying( tween, sprite )
		UpdateAllTweens(getframetime())
		Sync()
	endwhile
endfunction

function ParticleTest()
	part = CreateParticles( MiddleX,(MapHeight/2)+50 )
	AddParticlesScaleKeyFrame( part,1,.33 )
	AddParticlesColorKeyFrame( part,0,255,255,255,96 )
	SetParticlesVelocityRange( part,1.25,1)
	SetParticlesFrequency( part,1000 )
	SetParticlesDepth( part,1 )
	SetParticlesLife( part,20 )
	SetParticlesSize( part,12 )
	repeat
		Sync()
		UpdateParticles( part,.25 )
	until GetPointerPressed()
	end
endfunction

function SwarmTest()
	ns = NodeSize*1
	SetClearColor( 0,64,8 )
	ClearScreen()
	S = LoadImage("SWARMSS.png")
	CreateSprite(S,S)
	SetSpriteDepth(S,1)
	SetSpriteSize(S,ns,ns)
	SetSpritePosition(S,MiddleX,MiddleY)
	SetSpriteVisible(S,On)
	SetSpriteAnimation(S,292.5,292.5,42)
	PlaySprite(S,42)
	repeat
		Sync()
	until GetPointerPressed()
	end
endfunction

remstart

GAMEOVER WITH SPINNER
function GameOver( textID,spinID,r,g,b,spinR,spinG,spinB,message$,sound )
	#constant startSize 750
	#constant endSize 100
	#constant beginSpacing 300
	#constant endSpacing 0
	#constant spinDiameter 341.33
	#constant spinW 576
	#constant spinH 256

	PlaySound( sound )
	DeleteVirtualButton(AcceptButton)
	DeleteVirtualButton(QuitButton)
	DeleteAllText()
	ft# = GetFrameTime()
	y2 = MapHeight/2
	y1 = y2-(startSize/2)

	Text( textID,message$,MiddleX,y2,r,g,b,startSize,255,1 )
	SetTextFont( textID,Avenir )
	tt = TweenText( textID,Null,Null,y1,y2,Null,Null,startSize,endSize,beginSpacing,endSpacing,3,Null,TweenEaseIn1() )

	if GetMouseExists() then SetRawMouseVisible( On )
	repeat
		if GetTweenExists( tt )
			if GetTweenTextPlaying( tt,textID )
				UpdateAllTweens( ft# )
			else
				DeleteTween( tt )
				DeleteAllSprites()
				SetupSprite(field,field,"AchillesBoardClear.png",0,0,MaxWidth,MaxHeight,12,On,0)
				SetupSprite(spinID,spinID,"SpinnerSS.png",MiddleX-(spinW/2),y2-(spinH/2)+(endSize/2),spinW,spinH,0,On,0)
				SetSpriteColor( spinID,spinR,spinG,spinB,255 )
				SetSpriteAnimation( spinID,spinDiameter,spinDiameter,32 )
				PlaySprite( spinID,16 )
			endif
		elseif not GetSpriteVisible( VictorySpinner )
			SetSpriteVisible( VictorySpinner,On )
		endif
		Sync()
	until GetPointerPressed()
	Main() `restart Achilles
endfunction

function WaterTest()
	f = LoadImage("AchillesBoardClear.png")
	CreateSprite(f,f)
	SetSpriteDepth(f,1)
	SetSpriteSize(f,MaxWidth,MaxHeight)
	SetSpriteVisible(f,On)

	bw = LoadImage("BlueWaterSS.png")
	CreateSprite(bw,bw)
	SetSpriteDepth(bw,0 )
	SetSpritePosition(bw,270,270)
	SetSpriteAnimation(bw,90,90,60)
	SetSpriteSize(bw,45,45)
	PlaySprite(bw,30)
	bw2 = CloneSprite(bw)
	SetSpritePosition(bw2,315,270)
	bw3 = CloneSprite(bw)
	SetSpritePosition(bw3,270,315)
	bw4 = CloneSprite(bw)
	SetSpritePosition(bw4,315,315)
	repeat
		Sync()
	until GetPointerPressed()
	end
endfunction


function GameOver( textID,message$,r,g,b,sound )
	#constant startSize 750
	#constant endSize 100
	#constant beginSpacing 300
	#constant endSpacing 0

	y2 = MapHeight/2
	y1 = y2-(startSize/2)
	PlaySound( sound )
	Text( textID,message$,MiddleX,y2,r,g,b,startSize,255,1 )
	SetTextFont( textID,Impact )
	TweenText( textID,Null,Null,y1,y2,Null,Null,startSize,endSize,beginSpacing,endSpacing,3,Null,TweenEaseIn1() )
	ft# = GetFrameTime()
	if GetMouseExists() then SetRawMouseVisible( On )
	repeat
		UpdateAllTweens( ft# )
		Sync()
	until GetPointerPressed()
	Main() `restart Achilles
endfunction

	function SetTweenText( a1,a2,text,intMode,speed# )
		tt = CreateTweenText( speed# )
		SetTweenTextAlpha( tt,a1,a2,intMode )
		PlayTweenText( tt,text,0 )
	endfunction tt

	FIXED?
		----IMPLEMENT AI BASE DEFENSE - SEE GOAL CHANGE
		----AI MUST BE MORE AGGRESSIVE IN CAPTURING BASES!!!!!!!!!!

		----zoom offset not set coming out of base production screen
		----BASE OWNERSHIP NOT PROPERLY CHANGING HANDS!!!!!--------ARRAY MANAGEMENT PROBLEM???
		----BASE CAPTURE NOT ALWAYS WORKING?
		----MAKE FIRING CONTINGENT UPON VISIBILITY - WHERE DO TANKS EMERGE FROM FOW??? ----
		ELIMINATE MOVEMENT MARKERS IF TANK IS STUNNED
		BASE PRODUCTION AND ZOOM BACK AND FORTH NOT WORKING PROPERLY IN IOS
		Set limit on the number of units that can be produced
		---STUNMARKERS DON'T ALWAYS APPEAR!!!
		---PROBLEM WITH AI BASE CAPTURE WHEN PLAYER TANKS ARE NEAR BASE
		---When AI Spawns, attempt to acquire target????

		THESE PROBLEMS APPEAR TO BE RELATED TO THE SETTINGS DIALOG:
		---TANKS ARE NOT GOING AWAY IN BASE PRODUCTION SCREEN
		---NEW ENGINEERS AT BASES NOT SELECTABLE??????
remend

