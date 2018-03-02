
//ACHILLES v0.9 ~ Created 3/14/16 by Bob Tedesco Jr
//Two ways to win - base capture, or eliminate all enemy units

remstart
	ISSUES/REVISIONS
	--- BETTER AI DECISIONS?
			PLACEMENT RELATIVE TO ENEMY
			VERY REPETITIVE MOVEMENT PATTERNS??
	--- SPRITECONS  BEHAVING STRANGELY - STICK TO SCREEN - UNITS NOT SELECTED SHOW UP IN GAME (MEDIUM TANK?)

	--- LOS STILL GETTING BLOCKED !!!!!!
	--- FIRING ON INVISIBLE UNIT GENERATES "NOT IN LOS" MESSAGE
	--- WHAT IS THAT GREY LINE ON THE RIGHT SIDE OF THE SCREEN?
	--- WHEN BASE IS A MOVE TARGET, IT IS NO LONGER SELECTABLE

	MAY NOT BE A PROBLEM:
	--- MINES STILL PLACED AFTER ENGINEER DIES!!!!
			mines explode when unit is destroyed at base?!

	FIXED?
	--- TURN OFF BUTTONS AT END OF TURN
	--- INVISIBLE UNITS OUT OF FOW ??????!!!!!
			REMOVED AIFOW FROM AIOPS
			SEE FINDENEMY - FIXED? - PLACE THIS CALL SOMEWHERE ELSE?
	--- AI ENGINEER EMP RANGE IS BASED ON MOVES ALLOWED???
			made empRange and movesAlowwed equal (4)
	--- SLUGGISH BUTTON REACTION ON iOS
	--- MINE PLACEMENT IN FRIENDLY BASES - CHECK DETONATION AS RELATES TO BASE CAPTURE
	--- TARGET NODES CONTAINING TREES BLOCK LOS
	--- INITIAL VIEW OF ZOOMED INFO SCREEN SEEMS TO HAVE NO OR INCORRECT BOUNDARIES
		CHECK MOUSESCROLL

	FUTURE
		getspriteincircle vs getspriteinbox??
		Vary water, impass, tree and rough tilehs
		Implement Swarm
		Accumulated experience
		Multiplayer
		Races/Factions?
	    AI DIFFICULTY LEVEL
	    Load/Save games
remend

`--AITank visibility - Initialize and AIFOW
`--LOS -- Mod at end of PlayerOps

//~ ASCII()
//~ SoundCheck()

SetVirtualResolution( MaxWidth,MaxHeight )
SetWindowSize( MaxWidth,MaxHeight,1,1 )
MaximizeWindow()
SetWindowPosition( 0,0 )
SetOrientationAllowed( 0, 0, 1, 1 )
UseNewDefaultFonts(On)
//~ ACHILLESFONT = LoadFont( "PTSans.ttc" )
ACHILLESFONT = LoadFont( "Helvetica.ttc" )
ACHILLESFONT = LoadFont( "MyriadPro-Cond.otf" )


SetPhysicsWallTop(Off)
SetPhysicsWallBottom(Off)
SetPhysicsWallLeft(Off)
SetPhysicsWallRight(Off)
if dev.device = "windows" then video$ = "Greycheek.wmv" else video$ = "Greycheek_4.mp4"

if  LoadVideo( video$ )
	PlayVideo()
	ResetTimer()
	while GetVideoPlaying()
		if (Timer()>=4.5) or GetPointerState() or GetRawKeyPressed(Enter) then StopVideo()
		Sync()
	endwhile
	DeleteVideo()
endif

#insert "Labels.agc"
#include "Settings.agc"
#include "MainMenu.agc"
#include "Initialize.agc"
#include "Players.agc"
#include "AI.agc"
#include "Path.agc"
#include "Miscellaneous.agc"

//~ SheetTest()
//~ WaterTest()
//~ SwarmTest()
//~ ParticleTest()
//~ DisruptorTest()
//~ BlockProduction() : end
//~ testing()


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
	if Events then EventCheck()
	inc PlayerProdUnits,(PlayerBaseCount+1) * BaseProdValue * reinforce
	inc AIProdUnits,(AIBaseCount+1) * BaseProdValue * reinforce
	inc turns
	ShowInfo(On)
	Sync()
endfunction

function Blockage(ID,Tank as tankType[],x1,y1,x2,y2) `blocked movement
	PlaySound(DeActivateSound,vol)
	SetSpritePositionByOffset(prohibit,x2,y2)
	SetSpriteVisible(prohibit,On)
	SetSpriteActive(prohibit,On)
	SetSpritePositionByOffset(redSquare,x1,y1)
	SetSpriteVisible(redSquare,On)
	SetSpriteActive(redSquare,On)
	cover = GetSpriteVisible(Tank[ID].cover)
	if cover then SetSpriteVisible(Tank[ID].cover,Off)
	ResetTimer()
	repeat
		DrawLine(x1,y1,x2,y2,laserFull,laserFull)
		Sync()
	until Timer() > 1.5
	SetSpriteVisible(prohibit,Off)
	SetSpriteActive(prohibit,Off)
	SetSpriteVisible(redSquare,Off)
	SetSpriteActive(redSquare,Off)
	if cover then SetSpriteVisible(Tank[ID].cover,On)
endfunction

function EventCheck()
	reinforce = 1
	weather = 1
	casualties = Null
	Event$ = RandomEvent[ Random2(0,EventNum-1) ]
	//~ Event$ = Sabotage$
	select Event$
		case Weather$
			PlaySound( LightningSound,vol )
			weather = .5
			EventDialog( Weather$,"Movement halved",WeatherFile$ )
		endcase
		case Interdiction$
			PlaySound( InterdictSound,vol )
			casualties = 1
			EventDialog( Interdiction$,"Production halted",InterdictionFile$ )
		endcase
		case Reinforcement$
			PlaySound( RenforcementsSound,vol )
			reinforce = 2
			EventDialog( Reinforcement$,"Production doubled",ReinforcementFile$ )
		endcase
		case Supply$
			PlaySound( LoganSound,vol )
			EventDialog( Supply$,"All units repaired",SupplyFile$ )
			for i = 0 to PlayerLast
				if PlayerTank[i].alive then Repair( i,PlayerTank,PlayerDepotNode,PlayerTank[i].maximumHealth )
			next i
			for i = 0 to AIPlayerLast
				if AITank[i].alive then Repair( i,AITank,AIDepotNode,AITank[i].maximumHealth )
			next i
		endcase
		case Sabotage$
			if (PlayerSurviving > 1) and Random2(0,1)
				RandomKill( PlayerTank,PlayerLast )
			elseif AISurviving > 1
				RandomKill( AITank,AIPlayerLast )
			endif
		endcase
	endselect
endfunction

function RandomKill( Tank as tanktype[],last )
	unit as integer[]
	Zoom(1,0,0,On,1)
	dragMode = False
	PlaySound( SaboSound,vol )
	EventDialog( Sabotage$,"One unit destroyed",SabotageFile$ )
	for i = 0 to last
		if Tank[i].alive then unit.insert(i)
	next i
	ID = unit[Random2(0,unit.length)]
	KillTank( ID,Tank )
endfunction

function EventDialog( t1$,t2$,i$ )
	Zoom( 1,0,0,On,1 )
	dragMode = False
	TSize = 32 * dev.scale
	t1 = CreateText( t1$ )
	t2 = CreateText( t2$ )
	SetText( t1,alertDialog.x,alertDialog.y+TSize,255,25,25,TSize,255,0,Off )
	SetText( t2,alertDialog.x,alertDialog.y+(TSize*2),50,50,50,TSize,255,0,Off )
	AlertDialog( t1,On,alertDialog.x-TSize,alertDialog.y,alertDialog.w+(TSize*2),alertDialog.h )
	SetVirtualButtonPosition( cancelButt.ID,alertDialog.accept.x+TSize,alertDialog.accept.y )

	thumbnailImage = LoadImage( i$ )
	thumbnail = CreateSprite( thumbnailImage )
	thumbnailSize = 90 * (dev.scale*1.15)
	SetSpriteTransparency( thumbnail,1 )
	SetSpriteVisible( thumbnail,0 )
	SetSpriteDepth ( thumbnail,0 )
	SetSpriteSize( thumbnail,thumbnailSize,thumbnailSize )
	SetSpritePosition( thumbnail,alertDialog.x,alertDialog.y+alertDialog.h-(thumbnailSize*1.5) )
	SetSpriteVisible( thumbnail,On )

	repeat
		Sync()
	until GetVirtualButtonPressed( cancelButt.ID ) or GetRawKeyState( Enter )
	WaitForButtonRelease( cancelButt.ID )
	PlaySound( ClickSound,vol )
	SetVirtualButtonPosition( cancelButt.ID,cancelButt.X,cancelButt.Y )
	AlertDialog( t1,Off,alertDialog.x,alertDialog.y,alertDialog.w,alertDialog.h )
	DeleteText( t2 )
	DeleteSprite( thumbnail )
endfunction

function SetFOWbox( ID, Tank as tankType[] )
	box.x1 = Min(NodeSize,Tank[ID].x - (floor(Tank[ID].FOWOffset*weather)))
	box.y1 = Min(NodeSize,Tank[ID].y - (floor(Tank[ID].FOWOffset*weather)))
	box.x2 = Max(MapWidth,Tank[ID].x + (floor(Tank[ID].FOWOffset*weather)))
	box.y2 = Max(MapHeight,Tank[ID].y + (floor(Tank[ID].FOWOffset*weather)))
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
		FOWSize = (Tank[ID].FOWSize / ( NodeSize / rate )) + 1
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
				growShift = growth/2
				SetSpriteSize(Tank[ID].FOW,growth,growth)
				SetSpritePosition(Tank[ID].FOW, mapTable[Tank[ID].node].x - growShift, mapTable[Tank[ID].node].y - growShift )
			endif
			Sync()
		next i
		if generateFOW
			for i = 0 to AIPlayerLast
				if AITank[i].alive
					if GetSpriteInCircle(AITank[i].bodyID,PlayerTank[ID].x,PlayerTank[ID].y,PlayerTank[ID].FOWOffset-NodeSize) then RevealAIUnit(i)
				endif
			next i
		endif
		PlaySprite(Iris,frames,0,IrisFrames,1)
		Delay(.5)
		SetSpriteVisible(baseID,On)
		SetSpriteVisible(Iris,Off)
		SetSpriteDepth(Iris,0)
	endif
	HealthBar(ID,Tank)
endfunction

function RevealAIUnit(ID)
	SetSpriteVisible(AITank[ID].bodyID,On)
	SetSpriteVisible(AITank[ID].turretID,On)

	if mapTable[ AITank[ID].parentNode[AITank[ID].index] ].terrain = Trees
		SetSpriteVisible(AITank[ID].cover,On)
		SetSpritePositionByOffset(AITank[ID].cover,AITank[ID].x,AITank[ID].y)
	endif
	if AITank[ID].stunned then SetSpriteVisible(AITank[ID].stunMarker,On)
	HealthBar(ID,AITank)
endfunction


function LOSblocked(x1,y1,x2,y2)
	if PhysicsRayCastCategory(Block,x1,y1,x2,y2)
		node1 = CalcNodeFromScreen(x1,y1)
		node2 = CalcNodeFromScreen(x2,y2)
		select node1-node2   `adjacent nodes are always in LOS
			case south,southeast,west,northeast,north,northwest,east,southwest : exitfunction False : endcase
		endselect

		x = GetRayCastX()
		y = GetRayCastY()
		nodeHit = CalcNodeFromScreen(x,y)
		if nodeHit = node2 then exitfunction False   `not blocked if Trees at the target node

		exitfunction True
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
			CannonFire(Attacker[attID].x,Attacker[attID].y,Defender[defID].x,Defender[defID].y,96,48)
		endcase
		case missile
			MissileFire(Attacker[attID].x,Attacker[attID].y,Defender[defID].x,Defender[defID].Y)
		endcase
		case laser,heavyLaser
			RotateTurret(attID,Attacker,Defender[defID].x,Defender[defID].y)
			LaserFire(Attacker[attID].x,Attacker[attID].y,Defender[defID].x,Defender[defID].y,Attacker[attID].weapon,1.25,2,0,Attacker[attID].scale )
		endcase
		case machineGun
			RotateTurret(attID,Attacker,Defender[defID].x,Defender[defID].y)
			Ballistics(Attacker[attID].x,Attacker[attID].y,Defender[defID].x,Defender[defID].y)
		endcase
		case disruptor
			RotateTurret(attID,Attacker,Defender[defID].x,Defender[defID].y)
			Disrupt( attID,defID,Attacker,Defender )
			EndAttack( attID,defID,Attacker,Defender )
			exitfunction
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
	EndAttack( attID,defID,Attacker,Defender )
endfunction

function EndAttack( attID, defID, Attacker ref as tankType[], Defender ref as tankType[] )
	UnitSurvival()
	HealthBar(defID,Defender)
	Attacker[attID].target = Undefined
	Sync()
endfunction

function ShowInfoTables()
	ButtonState( XButt.ID,On )
	ButtonState( ArrowRightButt.ID,On )
	ButtonState( InfoButt.ID,Off )
	i1 = CreateSprite( InstructionImage1 )
	SetSpriteDepth(i1,0)
	SetSpriteSize( i1,MaxWidth,MaxHeight )
	SetSpritePosition(i1,0,0)
	i2 = CreateSprite( InstructionImage2 )
	SetSpriteDepth(i2,0)
	SetSpriteSize( i2,MaxWidth,MaxHeight )
	SetSpritePosition(i2,0,0)
	SetSpriteVisible(i2,Off)
	SetSpriteVisible(i1,On)
	repeat
		ZoomScroll()
		Sync()
		if GetVirtualButtonReleased( ArrowRightButt.ID ) or GetRawKeyPressed( RightArrow )
			PlaySound( ClickSound,vol )
			if GetSpriteVisible(i1)
				SetSpriteVisible(i1,Off)
				SetSpriteVisible(i2,On)
			else
				SetSpriteVisible(i2,Off)
				SetSpriteVisible(i1,On)
			endif
		endif
	until GetVirtualButtonReleased( XButt.ID ) or GetRawKeyPressed( Enter )
	PlaySound( ClickSound,vol )
	Zoom(1,0,0,On,1)
	DeleteSprite(i1)
	DeleteSprite(i2)
	ButtonState( InfoButt.ID,On )
	ButtonState( XButt.ID,Off )
	ButtonState( ArrowRightButt.ID,Off )
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
	SetSpritePositionByOffset( mapTable[node].mineSprite,Tank[ID].x,Tank[ID].y )
	PlaySprite( mapTable[node].mineSprite,14 )
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
		SetSpriteActive( MineExplode,On )
		SetSpritePositionByOffset( MineExplode,Tank[ID].x,Tank[ID].y )
		PlaySprite( MineExplode,12,0 )
		while GetSpritePlaying( MineExplode )
			Sync()
		endwhile
		SetSpriteVisible( MineExplode,Off )
		SetSpriteActive( MineExplode,Off )

		maptable[node].mineSprite = Null
		maptable[node].minetype = Null
		damage# = mineDamage * 100
		damage# = Min( 10,Randomize(damage#-15,damage#+15) ) `+/-15%
		dec Tank[ID].health,damage#/100.0
		if Tank[ID].health <= 0 then KillTank(ID,Tank)
		if AISurviving = 0 then GameOver( VictoryText,0,0,0,"VICTORY",VictorySound )
		if PlayerSurviving = 0 then GameOver( DefeatText,255,255,255,"DEFEAT",DefeatSound )
		exitfunction True
	endif
endfunction False

function Repair(ID,Tank ref as tankType[],depotNode as depotType[],healthMax as float )
	brightness as integer
	offset as integer
	if GetSpriteVisible(Tank[ID].bodyID)
		if (Tank[ID].health < healthMax) or (Tank[ID].missiles < Tank[ID].rounds) or (Tank[ID].mines < Tank[ID].rounds) or (Tank[ID].charges < Tank[ID].rounds)
			PlaySound( HealSound,vol )

			cross = CreateSprite( PlayerDepotNode[0].spriteID )

			fullScale = ceil(DepotSize*2.5)
			halfway = fullScale/2
			alpha = FullAlpha
			brightness = (FullAlpha/fullScale)*2
			SetSpriteDepth(cross,0)
			SetSpriteColor(cross,255,255,255,FullAlpha)
			SetSpriteColorAlpha(Tank[ID].bodyID,128)
			SetSpriteColorAlpha(Tank[ID].turretID,128)
			for i = 1 to fullScale
				if i > halfway then dec alpha,brightness
				offset = ceil(i/2)
				SetSpriteSize(cross,i,i)
				SetSpriteColorAlpha(cross,alpha)
				SetSpritePosition(cross,Tank[ID].x-offset,Tank[ID].y-offset)
				Sync()
			next i
			DeleteSprite(cross)
			SetSpriteColorAlpha(Tank[ID].bodyID,FullAlpha)
			SetSpriteColorAlpha(Tank[ID].turretID,FullAlpha)
		endif
	endif
	Tank[ID].health = healthMax
	Tank[ID].missiles = Tank[ID].rounds
	Tank[ID].mines = Tank[ID].rounds
	Tank[ID].charges = Tank[ID].rounds
	if Tank[ID].team = PlayerTeam then WeaponButtons(ID,Tank[ID].vehicle)
	if not GetSpriteVisible(Tank[ID].bodyID) then exitfunction
	HealthBar(ID,Tank)
endfunction

function Heal(ID,Tank ref as tankType[],depotNode as depotType[],depot,healthMax as float)
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

function CaptureBase( capturedIndex, newBaseIndex, pick ref as ColorSpec, attBase ref as baseType[], defBase ref as baseType[], base, group )
	DeleteSprite( defBase[capturedIndex].spriteID )

	BaseSetup( newBaseIndex,defBase[capturedIndex].spriteID,defBase[capturedIndex].node,base,attBase,group )
	PlaySound( BuildBaseSound,vol )

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

function UnitSurvival()
	for i = 0 to AICount
		if not AITank[i].alive then continue
		if AITank[i].health <= 0
			KillTank(i,AITank)
			if AISurviving = 0 then GameOver( VictoryText,0,0,0,"VICTORY",VictorySound )
		endif
	next i
	for i = 0 to PlayerCount
		if not PlayerTank[i].alive then continue
		if PlayerTank[i].health <= 0
			KillTank(i,PlayerTank)
			if PlayerSurviving = 0 then GameOver( DefeatText,255,255,255,"DEFEAT",DefeatSound )
		endif
	next i
endfunction

function PlayerBaseCapture()
	for i = 0 to AICount
		if not AITank[i].alive then continue
		for j = 0 to PlayerBaseCount
			if AITank[i].parentNode[AITank[i].index] = PlayerBases[j].node
				SetSpriteVisible(AITank[i].bodyID,On)
				SetSpriteVisible(AITank[i].turretID,On)
				dec PlayerBaseCount
				inc AIBaseCount
						inc Stats.basesLost
				AIBases.length = AIBases.length + 1
				CaptureBase( j,AIBases.length,pickAI,AIBases,PlayerBases,AIBase,AIBaseGroup )
				if PlayerBaseCount = -1 then GameOver( DefeatText,255,255,255,"DEFEAT",DefeatSound )
				exit
			endif
		next j
	next i
endfunction

function AIBaseCapture()
	for i = 0 to PlayerCount
		if not PlayerTank[i].alive then continue
		for j = 0 to AIBaseCount
			if PlayerTank[i].parentNode[PlayerTank[i].index] = AIBases[j].node
				dec AIBaseCount
				inc PlayerBaseCount
						inc Stats.basesCaptured
				PlayerBases.length = PlayerBases.length + 1
				CaptureBase( j,PlayerBases.length,pickPL,PlayerBases,AIBases,PlayerBase,BaseGroup )
				if AIBaseCount = -1 then GameOver( VictoryText,0,0,0,"VICTORY",VictorySound )
				exit
			endif
		next j
	next i
endfunction


function GameOver( textID,r,g,b,message$,sound )
	#constant startSize 750
	#constant endSize 100
	#constant beginSpacing 300
	#constant endSpacing 0
	fountain as integer

	PlaySound( sound,vol )
	DeleteVirtualButton(acceptButt.ID)
	DeleteVirtualButton(cancelButt.ID)
	DeleteVirtualButton(InfoButt.ID)
	DeleteAllText()
	ft# = GetFrameTime()
	y2 = MapHeight/2
	y1 = y2-(startSize/2)

	Text( textID,message$,MiddleX,y2,r,g,b,startSize,255,1,Off )
	//~ SetTextFont( textID,ACHILLESFONT )
	tt = TweenText( textID,Null,Null,y1,y2,Null,Null,startSize,endSize,beginSpacing,endSpacing,3,Null,TweenEaseIn1(),On )

	if GetMouseExists() then SetRawMouseVisible( On )
	repeat
		if GetTweenExists( tt )
			if GetTweenTextPlaying( tt,textID )
				UpdateAllTweens( ft# )
			else
				DeleteTween( tt )
				DeleteAllSprites()
				SetupSprite(field,field,"AchillesBoardClear.png",0,0,MaxWidth,MaxHeight,12,On,0)
				fountain = True
				if message$ = "VICTORY"
					part = VictoryParticles()
					advance# = .2
				else
					part = DefeatParticles()
					advance# = .05
				endif
			endif
		endif
		if fountain then UpdateParticles( part,advance# )
		Sync()
	until GetPointerPressed()
	if GetParticlesExists( part ) then DeleteParticles( part )
	Main() `restart Achilles
endfunction

function VictoryParticles()
	part = CreateParticles( MiddleX,(MapHeight/2)+50 )
	SetParticlesImage( part, starImage )
	SetParticlesRotationRange( part, 0, 270 )
	SetParticlesVelocityRange( part,3,1 )
	SetParticlesFrequency( part,10 )
	SetParticlesDepth( part,1 )
	SetParticlesLife( part,15 )
	SetParticlesSize( part,90 )
	AddParticlesScaleKeyFrame( part,  0, 2.00 )
	AddParticlesScaleKeyFrame( part,  8, 1.00 )
	AddParticlesScaleKeyFrame( part, 16,  .10 )
endfunction part

function DefeatParticles()
	part = CreateParticles( MiddleX,(MapHeight/2)+50 )
	DefeatImage = LoadImage("DefeatImage.png")
	SetParticlesImage( part, DefeatImage )
	SetParticlesVelocityRange( part,1.5,3)
	SetParticlesFrequency( part,5 )
	SetParticlesDepth( part,1 )
	SetParticlesLife( part,15 )
	SetParticlesSize( part,90 )
	SetParticlesAngle( part, 360 )
	SetParticlesRotationRangeRad( part, 0, .33 )
	AddParticlesScaleKeyFrame( part,  0, 1.0 )
	AddParticlesScaleKeyFrame( part,  8, 2.5 )
	AddParticlesScaleKeyFrame( part, 16, 5.0 )
	AddParticlesColorKeyFrame( part,  0, 255, 255, 255, 255 )
	AddParticlesColorKeyFrame( part,  8, 255, 255, 255, 128 )
	AddParticlesColorKeyFrame( part, 16, 255, 255, 255, 0 )
endfunction part

function BlowItUp( ID,Tank as tankType[] )
	PlaySound( ExplodeSound,vol )
	SetSpriteVisible( Tank[ID].bodyID,Off )
	SetSpriteVisible( Tank[ID].turretID,Off )
	SetSpriteVisible( Tank[ID].healthID,Off )
	smoke1 = CreateParticles( Tank[ID].x,Tank[ID].y )
	AddParticlesScaleKeyFrame( smoke1,  0, 1.0 )
	AddParticlesScaleKeyFrame( smoke1,  8, 2.5 )
	AddParticlesScaleKeyFrame( smoke1, 16, 5.0 )
	AddParticlesColorKeyFrame( smoke1, 0, 255, 255, 255, 255 )
	AddParticlesColorKeyFrame( smoke1, 8, 255, 255, 255, 128 )
	AddParticlesColorKeyFrame( smoke1, 16, 255, 255, 255, 0 )
	SetParticlesFrequency( smoke1, 16 )
	SetParticlesLife( smoke1, 1 )
	SetParticlesSize( smoke1, 60 )
	SetParticlesImage( smoke1, smokeImage )
	SetParticlesDirection( smoke1, 25, 50 )
	SetParticlesDepth( smoke1, 0 )
	SetParticlesVelocityRange( smoke1, 1, 2 )
	SetParticlesAngle( smoke1, 360 )
	SetParticlesRotationRangeRad( smoke1, 0, .33 )
	Sync()
	Explosion( Tank[ID].x,Tank[ID].y,Explode4,ExplodingSound,12 )
	SetParticlesVisible( smoke1,0 )
endfunction

function KillTank( defID,Tank ref as tankType[] )
			SetSpriteVisible( Tank[defID].bodyID, On )
	BlowItUp( defID,Tank )
	DeleteSprite( Tank[defID].healthID )
	DeleteSprite( Tank[defID].bodyID )
	DeleteSprite( Tank[defID].turretID )
	DeleteSprite( Tank[defID].stunMarker )
	DeleteSprite( Tank[defID].cover )

	if Tank[defID].team = PlayerTeam
		DeleteSprite( Tank[defID].FOW )
		DeleteSprite( Tank[defID].hilite )
		dec PlayerSurviving
			inc Stats.unitsLost
	else
		dec AISurviving
			inc Stats.unitsDestroyed
	endif
	mapTable[Tank[defID].moveTarget].moveTarget = False  `clear target  if Tank[defID].moveTarget then

	//~ if mapTable[Tank[defID].parentNode[Tank[defID].index]].terrain = Trees then SetSpriteVisible(Tank[defID].cover,0)
	mapTable[Tank[defID].parentNode[Tank[defID].index]].team = Unoccupied
	Tank[defID].alive = False
endfunction

function Explosion( x,y,ID,sound,fps )
	PlaySound( sound,vol )
	SetSpriteVisible( ID,On )
	SetSpriteActive( ID,On )
	SetSpritePositionByOffset( ID,x,y )
	PlaySprite( ID,fps,0 )
	repeat
		Sync()
	until not GetSpritePlaying( ID )
	SetSpriteVisible( ID,Off )
	SetSpriteActive( ID,Off )
endfunction

function ActivateEMP( ID, Tank ref as tankType[] )
	#constant AlphaPlus 325
	SetSpriteVisible( EMP1,On )
	for i = 1 to 5
		if mod(i,2) then PlaySound( EMPSound,vol )  `every other wave
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

function Ballistics( x1,y1,x2,y2 )
	#constant bulletMax 9
	Bullets as integer[bulletMax]
	t as integer[bulletMax]
	PlaySound( MachineGunSound,vol )
	for i = 0 to bulletMax
		Bullets[i] = CloneSprite( Bullet1 )
		SetSpriteSize( Bullets[i],NodeSize*2,NodeSize*2.25 )
		SetSpriteVisible( Bullets[i],On )
		SetSpritePositionByOffset( Bullets[i], x1, y1 )
		a = GetSpriteAngle( Bullets[i] )
		t[i] = SetTween( x1,y1,x2,y2,a,a,Bullets[i],TweenLinear(),i*.01 )
		Delay(.01)
		UpdateAllTweens(getframetime())
	next i
	PlayTweens( t[bulletMax],Bullets[bulletMax] )
	for i = 0 to bulletMax : SetSpriteVisible( Bullets[i],Off ) : next i
	Explosion( x2,y2,Explode3,ExplodeSound,22 )
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

function Disrupt( attID, defID, Attacker ref as tankType[], Defender ref as tankType[] )
	PlaySound( DisruptorSound )
	SetSpritePositionByOffset( DisruptSprite,Attacker[attID].x,Attacker[attID].y )
	SetSpriteVisible( DisruptSprite,On )
	SetSpriteAngle( DisruptSprite,GetSpriteAngle( Attacker[attID].turretID ) )
	PlaySprite( DisruptSprite,90 )
	Delay( 1 )
	for i = 0 to Defender.length `check for defender caaualties
		if Defender[i].alive
			if GetSpriteInCircle( Defender[i].bodyID, Defender[defID].x, Defender[defID].y, disruptorRadius )
				damage# = maptable[Defender[i].parentNode[Defender[i].index]].modifier
				damage# = (damage# * Attacker[attID].damage) * 100
				damage# = Min(10,Randomize(damage#-15,damage#+15)) `+/-15%
				dec Defender[i].health,damage#/100.0
			endif
		endif
	next i
	for i = 0 to Attacker.length `check for attacker caaualties
		if Attacker[i].alive
			if Attacker[attID].bodyID = Attacker[i].bodyID then continue
			if GetSpriteInCircle( Attacker[i].bodyID, Defender[defID].x, Defender[defID].y, disruptorRadius )
				damage# = maptable[Attacker[i].parentNode[Attacker[i].index]].modifier
				damage# = (damage# * Attacker[attID].damage) * 100
				damage# = Min(10,Randomize(damage#-15,damage#+15)) `+/-15%
				dec Attacker[i].health,damage#/100.0
			endif
		endif
	next i
	SetSpriteVisible( DisruptSprite,Off )
	StopSprite( DisruptSprite )
endfunction

function Wake( ID, Tank as tankType[] )
	SetSpriteColor(Tank[ID].turretID,255,255,255,255)
	SetSpriteVisible( Tank[ID].stunMarker, Off )
	StopSprite( Tank[ID].stunMarker )
endfunction

function CannonFire( x1,y1,x2,y2,start,finish )
	PlaySound( BangSound,vol )
	SetSpriteVisible( Fire1,On )
	SetSpritePositionByOffset( Fire1,x1,y1 )
	a = GetSpriteAngle( Fire1 )
	t = SetTween( x1,y1,x2,y2,a,a,Fire1,TweenEaseIn2(),.5)
	SetTweenSpriteSizeX( t,start,finish,TweenEaseIn2() )
	SetTweenSpriteSizeY( t,start,finish,TweenEaseIn2() )
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

function LaserFire( x1,y1,x2,y2,weapon,t1#,t2#,interrupt,scale )
	scale = (NodeSize*scale) / 3
	star = CreateSprite(laserStarImage)
	SetSpritePositionByOffset(star,x1,y1)
	SetSpriteSize(star,scale,scale)
	SetSpriteDepth(star,0)
	SetSpriteVisible(star,On)

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
	beam = True
	repeat
		if interrupt
			if GetVirtualButtonState(InfoButt.ID)
				exit
			elseif GetVirtualButtonState(cancelButt.ID)
				exit
			elseif GetVirtualButtonState(acceptButt.ID)
				exit
			elseif GetVirtualButtonState(settingsButt.ID)
				exit
			endif
		endif
		if Timer() <= t1#  `1.25
			DrawLine(x1,y1,x2,y2,laserFull,laserOut) : Sync()
			DrawLine(x1,y1,x2,y2,laserFull,laserOut) : Sync()
			DrawLine(x1,y1,x2,y2,laserFull,laserFull) : Sync()
			DrawLine(x1,y1,x2,y2,laserFull,laserFade) : Sync()
		elseif beam = True
			beam = False
			SetSpriteVisible( star,Off )
		endif
		SetParticlesFrequency( laser1, count )
		SetParticlesVisible( laser1,1 )
		Sync()
		dec count,5
	until Timer() >= t2#  `2
	DeleteSprite( star )
	DeleteParticles( laser1 )
endfunction

function Hover( ID,Tank as tankType[],node )
	if GetSpriteCurrentFrame( Tank[ID].bodyID ) <> 1
		PlaySprite( Tank[ID].bodyID,50,0,Closing,FullyClosed )
		repeat
			Sync()
		until GetSpriteCurrentFrame( Tank[ID].bodyID ) = FullyClosed
		s# = GetSpriteScaleX( Tank[ID].bodyID )
		for i# = s# to 1 step -.01	`Land
			SetSpriteScaleByOffset(Tank[ID].bodyID,i#,i#)
			SetSpriteScaleByOffset(Tank[ID].turretID,i#,i#)
			Sync()
		next i#
		PlaySprite( Tank[ID].bodyID,FullyClosed,0,1,1 )
	endif
		if (mapTable[node].terrain = Trees) and GetSpriteVisible(Tank[ID].bodyID)	`position tanks under cover
			SetSpritePositionByOffset(Tank[ID].cover,Tank[ID].x,Tank[ID].y)
			SetSpriteVisible(Tank[ID].cover,1)
		endif
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
	VictoryImage = LoadImage("VictoryImage.png")
	DefeatImage = LoadImage("DefeatImage.png")

	SetParticlesImage( part, DefeatImage )
	SetParticlesVelocityRange( part,1,2)
	SetParticlesFrequency( part,2 )
	SetParticlesDepth( part,1 )
	SetParticlesLife( part,3 )
	SetParticlesSize( part,40 )
	SetParticlesAngle( part, 360 )
	SetParticlesRotationRangeRad( part, 0, .33 )
	AddParticlesScaleKeyFrame( part,  0, 1.0 )
	AddParticlesScaleKeyFrame( part,  8, 2.5 )
	AddParticlesScaleKeyFrame( part, 16, 5.0 )
	AddParticlesColorKeyFrame( part, 0, 255, 255, 255, 255 )
	AddParticlesColorKeyFrame( part, 8, 255, 255, 255, 128 )
	AddParticlesColorKeyFrame( part, 16, 255, 255, 255, 0 )
	//~ SetParticlesImage( part, VictoryImage )
	//~ SetParticlesRotationRange( part, 0, 270 )
	//~ SetParticlesVelocityRange( part,3,1 )
	//~ SetParticlesFrequency( part,10 )
	//~ SetParticlesDepth( part,1 )
	//~ SetParticlesLife( part,15 )
	//~ SetParticlesSize( part,90 )
	//~ AddParticlesScaleKeyFrame( part,  0, 2.00 )
	//~ AddParticlesScaleKeyFrame( part,  8, 1.00 )
	//~ AddParticlesScaleKeyFrame( part, 16,  .10 )
	//~ AddParticlesScaleKeyFrame( part, 24,  .25 )

	repeat
		Sync()
		UpdateParticles( part,.05 )
		//~ UpdateParticles( part,.2 )
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

function SheetTest()
	SetClearColor( 0,0,0 )
	ClearScreen()
	S = LoadImage("shiftcan.png")
	CreateSprite(S,S)
	SetSpriteDepth(S,1)
	//~ SetSpriteSize(S,124,140)
	SetSpritePosition(S,MiddleX,MiddleY)
	SetSpriteVisible(S,On)
	SetSpriteAnimation(S,128,144,71)
	PlaySprite(S)
	repeat
		Sync()
	until GetPointerPressed()
	end
endfunction

function DisruptorTest()
	PlaySound( DisruptorSound,vol )
	SetClearColor( 0,64,8 )
	ClearScreen()
	DisruptSprite = LoadImage( "DISRUPTION_SS.png" )
	CreateSprite( DisruptSprite,DisruptSprite )
	SetSpriteTransparency( DisruptSprite,1 )
	SetSpriteVisible( DisruptSprite,On )
	SetSpriteDepth ( DisruptSprite,0 )
	SetSpriteSize( DisruptSprite,180,128.5 )
	SetSpriteOffset( DisruptSprite,90,128.5 )
	SetSpriteAnimation( DisruptSprite,500,250,8 )
	SetSpritePosition( DisruptSprite,200,200 )
	PlaySprite( DisruptSprite,60 )
	repeat
		Sync()
	until GetPointerPressed()
	end
endfunction

function testing()
	PlaySound( ExplodingSound,vol )
	repeat
		Sync()
	until GetPointerPressed()
	end
endfunction

function SoundCheck()
	c = 0
	if GetFileExists( "bang2.wav") then inc c
	if GetFileExists( "HoverbikeEnd.wav" ) then inc c
	if GetFileExists( "PlasticClick.wav" ) then inc c
	if GetFileExists( "DeactivateBeep.ogg" ) then inc c
	if GetFileExists( "Defeat.wav" ) then inc c
	if GetFileExists( "DISRUPTOR.ogg" ) then inc c
	if GetFileExists( "EMP.ogg" ) then inc c
	if GetFileExists( "MotorClose_01_01.ogg" ) then inc c
	if GetFileExists( "Jet2_01.ogg" ) then inc c
	if GetFileExists( "PickUpHeavy.wav" ) then inc c
	if GetFileExists( "EdgeHit2.ogg" ) then inc c
	if GetFileExists( "explode.wav" ) then inc c
	if GetFileExists( "HealGlassy.wav" ) then inc c
	if GetFileExists( "BeamElectro_01.wav" ) then inc c
	if GetFileExists( "Interdict.ogg" ) then inc c
	if GetFileExists( "laser3.ogg" ) then inc c
	if GetFileExists( "LightningBolt.ogg" ) then inc c
	if GetFileExists( "Locked On_01.ogg" ) then inc c
	if GetFileExists( "Logan.ogg" ) then inc c
	if GetFileExists( "MachineGun.ogg" ) then inc c
	if GetFileExists( "WalkerStompLow.ogg" ) then inc c
	if GetFileExists( "ExplosionPlain.wav" ) then inc c
	if GetFileExists( "TripodDestroyed.wav" ) then inc c
	if GetFileExists( "Evil Incoming_01.ogg" ) then inc c
	if GetFileExists( "reinforcements.ogg" ) then inc c
	if GetFileExists( "rocket.ogg" ) then inc c
	if GetFileExists( "ExitOpenAztec.wav" ) then inc c
	if GetFileExists( "LevelOnSinister.wav" ) then inc c
	if GetFileExists( "Rumble2.ogg" ) then inc c
	if GetFileExists( "Target Acquired_01.ogg" ) then inc c
	if GetFileExists( "MagicReveal.wav" ) then inc c
	if GetFileExists( "YesSirProcessed_01.ogg" ) then inc c
	if GetFileExists( "CopyProcessed_01.ogg" ) then inc c
	if GetFileExists( "AcknowlegedProcessed_01.ogg" ) then inc c
	if GetFileExists( "OnMyWayProcessed_01.ogg" ) then inc c
	if GetFileExists( "rogerthatProcess.ogg" ) then inc c
	if GetFileExists( "Ok_01.ogg" ) then inc c
	if GetFileExists( "Silent.ogg" ) then inc c
	SetPrintColor(255,255,255)

	repeat
		print(c)
		sync()
	until GetPointerState()
	end
endfunction


remstart

function LOSblocked(x1,y1,x2,y2)
	if PhysicsRayCastCategory(Block,x1,y1,x2,y2)
		if VectorDistance(x1,y1,x2,y2) > DLS then exitfunction True else exitfunction False  `adjacent nodes are always in LOS
	endif
endfunction False

FROM KillTank, after BlowItUP:
	PlaySound( ExplodeSound,vol )
	SetSpriteVisible( Tank[defID].bodyID,Off )
	SetSpriteVisible( Tank[defID].turretID,Off )
	SetSpriteVisible( Tank[defID].healthID,Off )
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

	Explosion( Tank[defID].x,Tank[defID].y,Explode2,ExplodingSound,48 )

	AFTER: 	DeleteSprite( Tank[defID].cover )
	SetParticlesVisible( smoke1,0 )

ISSUES
			BASE PROTECT - DONT LEAVE A BASE WHEN THREATENED

FIXED?
	--- CHECK ALL VECTORDISTANCE ROUTINES FOR FIRING
		PLAYERAIM MODIFIED
	---	AITANKS NOT APPEARING??
	--- TEST MOVEINPUT ON iOS
	--- ZOOMMED MOVEMENT DOESNT WORK!!!!!!!???????
	--- ENSURE MECHGUY CAN BE SHOT AT FROM LEFT AND RIGHT SIDES OF SCREEN
	--- MAP SAVE SLOT DIALOG BUG ON SAVE CANCEL!!!!
	--- HOVERCRAFT ARE FIRING THROUGH WALLS!!! - was because ResetMap needed to have CategoryBits set.
	--- GAME IS FREEZING! - CAUSE BY MINE EXPLOSION!
	--- SELECTING A MOVEMENT SQUARE GENERATES "OUT OF REACH" MESSAGE
	--- BASE CAPTURE
	--- PLAYER and AI TANKS ARE SOMETIMES STUCK - BLOCKAGE BY OTHER TANKS? -- RESET MOVEMENT WHEN BLOCKED?
			--See PlayerOps and AIOps
			--Implement visual blockage indicator

		--- SABOTAGE EVENT NOT WORKING??!!
		--- DIALOG BOX AFTER ZOOMING OUT - ZOOM BEHAVE STRANGELY; TURN/PRODUCTION INFO GOES AWAY!!!
		--- SHOOTING OUT OF TREES IS SOMETIMES BLOCKED!!
		--- UNITS CAN SELECT TARGETS IN TREES!!  - RELATED TO DLS??
		--- LASERS (MISSILES?) FIRE OUT OF RANGE!!!
		--- "SetTextVisible( MapText,state )" IN MAIN MENU > ALERT DIALOG??
		--- MAJOR HOVERCRAFT MOVEMENT BUG!!!! - CAN MOVE ON TOP OF ONE ANOTHER - MOVEMENT DOESN'T CANCEL??????
		--- SOME SPRITECONS DONT CHANGE COLOR?!
		--- HEALTH BARS NOT RESETTING AFTER DEPOT VISIT????!

		--- SET STARTING BASEPRODVALUE
		--- UPDATE SETTINGS SCREEN TO REFLECT BASEPRODVALUE
		--- SET LOAD/SAVE TO STORE BASE PRODUCTION VALUE
		--- BASE PRODUCTION IS STILL FUCKED UP !!!!!!
		--- AI NOT CAPTURING BASES????!!!!
		--- CROOKED HOVERCRAFT TURRET ANGLES
		--- CAN SET TO 0 BASES/DEPOTS!!!\
		--- LOS STILL BLOCKED!! -MAKE SURE TO NOBLOCK ALL SPRITES
		--- TANKS PRODUCED IN THE UPPER LEFT OF THE BOARD!!!!!!!!!!!!!!?????????????
		--- UNITS CAN STILL FIRE AND MOVE WHEN STUNNED!!!!! -- HAS TO DO WITH THE ORDER OF STUN COUNTDOWN FOR PLAYER ?
		--- FIX CANCEL & ACCEPT BUTTON POSITION
		--- MAX BASES/DEPOTS SHOULD BE 6 NOT 5

		---BASECOUNTS ARE CAUSING BASE CAPTURE/END GAME PROBLEMS!!!!!! - review PlayerBaseCount and AIBaseCount routines
			ARRAY INDEX OUT OF BOUNDS!!!!
			TRY INSERTING NEWLY CAPTURED BASES INTO ATTACKER ARRAY, AND DELETE FROM DEFENDER
		---LOS STILL BLOCKED??!! Make NoBlock = 1 ??? --BASES BLOCKING LOS??
		---REVERT MECH TO PAYING TERRAIN COSTS
		---iOS - BASES AND DEPOTS DON'T LINE UP DURING RANDOM MAP GENERATION
		---FOW SPRITE FAILED TO TURN OFF!!!!
		---UNITS SHOULD NOT GO AFTER MORE POWERFUL UNITS
		---TEST HOVERCRAFT ON MINES
		---AI HOVERCRAFT IS GETTING STUCK because nearestplayer node is occupied
		---HOVERCRAFT NOT VISITING DEPOTS
		---BRING HOVERCRAFT TO FRONT WHILE FLYING
		---SPEED UP AI MOVE
		---WHEN UNITS EMERGE FROM BASE, SHOW HIDDEN UNITS
		---LASER TANK FOW NOT ALIGNED TO NEAREST NODE?
		---ARRAY OUT OF BOUNDS LINE 576?
		---LOS STILL IMPROPERLY BLOCKED!!
		---BETTER ASTAR?? - UNITS GET IN EACH OTHERS WAY - reset ASTAR
		---STUNNED UNITS CAN FIRE!!!!
		---SPONTANEOUS AI TANK DESTRUCTION!! - HAS TO DO WITH VICTORY CONDITIONS!
		---REPAIR AT DEPOT WHEN NO DAMAGE??
		---SPONTANEOUS AI TANK DESTRUCTION!!
		---IMPLEMENT "OUT OF REACH" WARNING FOR MOVE TO OCCUPIED NODE
			AI MOVE TARGETS INVOLVED??

		---DEAD SPOTS ON SCREEN??
		---MYSTERIOUS LOS BLOCKAGE??!!
		---BASES APPEARING OUT OF NOWHERE?
		---RESTRICT MOVES TO FOW SPRITE BOUNDARY
		---GREY OUT MAP SLOT SAVE BUTTONS
		---TOO MANY BUTTON STATUS FUNCTIONS
		---AI BASE SHOWED UP ON PLAYER SIDE IN RANDOM MAP GENERATION (ONLY HAPPENS WHILE RUNNING AND GENERATED AFTER AN ABANDONED GAME)
		---SELECTING A MOVEMENT SQUARE TWICE GENERATES "OUT OF REACH" MESSAGE
		---TREES NO LONGER BLOCKED!!!!!!!!!
		---PRODUCTION UNIT TOTALS TAKEN AWAY WHEN BASE CAPTURED!!!
		---UNITS NOT SELECTABLE!!!!!!
		---PHANTOM BASE/UNIT SPAWN??????------
		---LOS IMPROPERLY BLOCKED!!!!!
		---HEAVILY DAMAGED AI TANKS DON'T VISIT DEPOTS
		---AI RELUCTANT TO FIRE; MAKING POOR MOVE DECISIONS (dont remove "nearestplayer" from goalset?)

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

