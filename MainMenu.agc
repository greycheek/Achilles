

function MainMenu()
	Setup()
	t1 = PatrolMech()
	do
		if not GetTweenSpritePlaying(t1,MechGuy[0].bodyID) then t1 = PatrolMech()
		UpdateAllTweens(getframetime())
		Sync()
		cancel = GetVirtualButtonPressed( QuitButton )
		accept = GetVirtualButtonReleased( AcceptButton )
		settings = GetVirtualButtonPressed( SettingsButton )
		Qkey = GetRawKeyPressed( 0x51 ) `Q
		if cancel or Qkey
			PlaySound( ClickSound,vol )
			TSize = 36*dev.scale
			Text( QuitText,"Quit?",YesNoX1+TSize,YesNoY1+TSize,50,50,50,TSize,255,0 )
			ButtonStatus( On, AcceptFlipButton, QuitFlipButton )
			AlertButtons( YesNoX2a, YesNoY2, YesNoX2b, YesNoY2, dev.buttSize, AcceptFlipButton, QuitFlipButton )
			AlertDialog( QuitText,On )
			do
				Sync()
				if GetVirtualButtonPressed( AcceptFlipButton ) or GetRawKeyState( Enter ) or GetRawKeyPressed( 0x59 ) then end  `Y
				if GetVirtualButtonPressed( QuitFlipButton ) //or GetRawKeyReleased( 0x4E ) `N
					ButtonStatus( Off, AcceptFlipButton, QuitFlipButton )
					AlertDialog( QuitText,Off )
					exit
				endif
			loop
		elseif settings
			PlaySound( ClickSound,vol )
			AlertButtons( YesNoX3a,YesNoY3a,YesNoX3b,YesNoY3a, dev.buttSize, AcceptFlipButton, QuitFlipButton )
			SettingsDialog()
		elseif accept
			PlaySound( ClickSound,vol )
			GameSetup()
			exitfunction
		endif
	loop
endfunction


function Halt(ID1,ID2)
	StopTweenSprite( ID1,MechGuy[0].bodyID )
	StopTweenSprite( ID2,MechGuy[0].turretID )
	StopSprite( MechGuy[0].bodyID )
endfunction

function AlertButtons( x1,y1,x2,y2,size,accept,quit )
	PlaySound( ClickSound,vol )
	SetVirtualButtonSize( accept,size )
	SetVirtualButtonSize( quit,size )
	SetVirtualButtonPosition( accept,x1,y1 )
	SetVirtualButtonPosition( quit,x2,y2 )
endfunction

function ButtonStatus( state,accept,quit )
	SetVirtualButtonVisible( accept,state )
	SetVirtualButtonVisible( quit,state )
	//~ SetVirtualButtonActive( accept,state )
	//~ SetVirtualButtonActive( quit,state )
endfunction

function PatrolMech()
	dir as integer[8]
	x2 = Random2(0,MaxWidth)
	y2 = Random2(0,MaxHeight)
	t# = Timer()
	if (t# >= 1.5) and (t# <= 1.65) then RotateTurret(0,MechGuy,x2,y2)	`look again
	if t# < 3 then exitfunction t1	`still looking

	select Randomize(1,15)  `random action
		case 10 : MechGuy[0].route = Random2(0,7) : endcase	`new direction
		case 12		`stop and look
			Halt(t1,t2)
			RotateTurret(0,MechGuy,x2,y2)
			ResetTimer()
			exitfunction t1
		endcase
		case 14,15  `fire
			Halt(t1,t2)
			if Random(0,1)
				RotateTurret(0,MechGuy,x2,y2)
				LaserFire( MechGuy[0].x,MechGuy[0].y,x2,y2,heavyLaser,1.25,2,1 )
			endif
			exitfunction t1
		endcase
	endselect

	x1 = MechGuy[0].x
	y1 = MechGuy[0].y
	x2 = MinMax( buffer,MapWidth,x1 + turnX[MechGuy[0].route] )
	y2 = MinMax( buffer,MapHeight,y1 + turnY[MechGuy[0].route] )

	if (x2=buffer) or (x2=MapWidth) or (y2=buffer) or (y2=MapHeight)  `screen edge?
		Halt(t1,t2)
		index = 0
		for i = 0 to 7
			if MechGuy[0].route <> i
				dir[index] = i
				inc index
			endif
		next i
		MechGuy[0].route = dir[ Random2(0,6) ]  `turn; 8-1=7 possible directions
		x2 = MinMax( buffer,MapWidth,x1 + turnX[MechGuy[0].route] )
		y2 = MinMax( buffer,MapHeight,y1 + turnY[MechGuy[0].route] )
	endif

	b# = GetSpriteAngle( MechGuy[0].bodyID )
	t# = GetSpriteAngle( MechGuy[0].turretID )
	offsetValue = CalcNodeFromScreen(x1,y1) - CalcNodeFromScreen(x2,y2)
	for i = 0 to 7
		if offset[i] = offsetValue
			a# = angle[i] : exit
		endif
	next i
	tankArc# = SetTurnArc(b#,a#)
	turretArc# = SetTurnArc(t#,a#)
	t1 = SetTween(x1,y1,x2,y2,b#,tankArc#,  MechGuy[0].bodyID,  TweenLinear(),MechGuy[0].speed)
	t2 = SetTween(x1,y1,x2,y2,t#,turretArc#,MechGuy[0].turretID,TweenLinear(),MechGuy[0].speed)

	PlaySprite( MechGuy[0].bodyID,20,0 )
	MechGuy[0].x = x2
	MechGuy[0].y = y2
endfunction t1

function AlertDialog( text,state )
	If state = Off
		DeleteText( text )
		DeleteSprite( AlertBackGround )
		WaitForButtonRelease( QuitFlipButton )
	else
		SetupSprite( AlertBackGround,AlertBackGround,"Yes-NoBkgnd.png",YesNoX1,YesNoY1,AlertW,AlertH,0,Off,0 )
	endif
	SetSpriteActive( AlertBackGround,state )
	SetSpriteVisible( AlertBackGround,state )
endfunction

function CreateGrid(state)
	for i = 0 to Cells-1
		SetSpriteActive( AIgrid[i].ID,state )
		SetSpriteVisible( AIgrid[i].ID,state )
		SetSpriteActive( PlayerGrid[i].ID,state )
		SetSpriteVisible( PlayerGrid[i].ID,state )
	next i
	for i = 1 to SpriteConUnits
		SetSpriteActive( SpriteCon[i].ID,state )
		SetSpriteVisible( SpriteCon[i].ID,state )
	next i
	if state
		Text(MusicText,"MUSIC",MusicScale.tx,MusicScale.ty,0,0,0,30,255,0)
		SetTextDepth(MusicText,1)
		Text(SoundText,"SOUND",SoundScale.tx,SoundScale.ty,0,0,0,30,255,0)
		SetTextDepth(SoundText,1)
	else
		DeleteText(MusicText)
		DeleteText(SoundText)
	endif
endfunction

function DisplaySettings(state)
	FlipState = not state
	SetTextColorAlpha( VersionText,FlipState*255 )
	SetSpriteActive( Dialog,state )
	SetSpriteVisible( Dialog,state )

	SetSpriteVisible( MusicSlide.ID,state )
	SetSpriteVisible( SoundSlide.ID,state )
	SetSpriteVisible( MusicScale.ID,state )
	SetSpriteVisible( SoundScale.ID,state )
	SetSpriteActive( MusicSlide.ID,state )
	SetSpriteActive( SoundSlide.ID,state )
	SetSpriteActive( MusicScale.ID,state )
	SetSpriteActive( SoundScale.ID,state )
	SetSpriteActive( AISpectrumSprite,state )
	SetSpriteActive( AIValueSprite,state )
	SetSpriteActive( PlayerSpectrumSprite,state )
	SetSpriteActive( PlayerValueSprite,state )

	SetSpriteActive( Splash,FlipState )
	SetSpriteVisible( Splash,FlipState )

	SetVirtualButtonVisible( SettingsButton,FlipState )
	SetVirtualButtonVisible( AcceptButton,FlipState )
	SetVirtualButtonVisible( QuitButton,FlipState )
	SetVirtualButtonVisible( AcceptFlipButton,state )
	SetVirtualButtonVisible( MapButton,state )

	CreateGrid(state)
endfunction

function ReDisplaySettings(state)
	SetSpriteActive( Dialog,state )
	SetSpriteVisible( Dialog,state )
	SetSpriteVisible( MusicSlide.ID,state )
	SetSpriteVisible( SoundSlide.ID,state )
	SetSpriteVisible( MusicScale.ID,state )
	SetSpriteVisible( SoundScale.ID,state )
	SetSpriteActive( MusicSlide.ID,state )
	SetSpriteActive( SoundSlide.ID,state )
	SetSpriteActive( MusicScale.ID,state )
	SetSpriteActive( SoundScale.ID,state )
	SetSpriteActive( AISpectrumSprite,state )
	SetSpriteActive( AIValueSprite,state )
	SetSpriteActive( PlayerSpectrumSprite,state )
	SetSpriteActive( PlayerValueSprite,state )
	SetSpriteVisible( MechGuy[0].bodyID,state )
	SetSpriteVisible( MechGuy[0].turretID,state )
	SetVirtualButtonVisible( AcceptButton, not state )
	SetVirtualButtonVisible( AcceptFlipButton,state )
	SetVirtualButtonVisible( MapButton,state )
	SetVirtualButtonVisible( MapFlipButton, not state )
	CreateGrid(state)
endfunction

function SettingsDialog()
	DisplaySettings(On)
	repeat
		Compose()
	until ForcesReady()
	PlaySound( ClickSound,vol )
	DisplaySettings(Off)
endfunction

function ChangeColor( grid as gridType[], c as ColorSpec )
	for i = 0 to Cells-1
		if GetSpriteExists( grid[i].ID ) then SetSpriteColor( grid[i].ID, c.r, c.g, c.b, c.a  )
	next i
endfunction


function Compose()
	repeat
		if GetPointerState()
			x = GetPointerX()
			y = GetPointery()
			hit = GetSpriteHit(x,y)
			select hit
				case SpriteCon[1].ID, SpriteCon[2].ID, SpriteCon[3].ID, SpriteCon[4].ID, SpriteCon[5].ID, SpriteCon[6].ID, SpriteCon[7].ID
					Stats(hit-SpriteConSeries,True,MiddleY+250,30,dev.textSize)
					SetRawMouseVisible( Off )
					clone = CloneSprite( hit )
					while GetPointerState()
						SetSpritePositionByOffset( clone,GetPointerX(),GetPointerY() )
						Sync()
					endwhile
					Stats( Null,Null,Null,Null,Null )
					SetSpriteSize( clone,SpriteConSize,SpriteConSize )
					SetRawMouseVisible( On )
					GridCheck( clone )
				endcase
				case AISpectrumSprite
					pickAI.satur = abs(cy1-y)/100
					pickAI.spect = x-AISide
					CalcColor( pickAI,AIGrid )
				endcase
				case PlayerSpectrumSprite
					pickPL.satur = abs(cy1-y)/100
					pickPL.spect = x-PlayerSide
					CalcColor( pickPL,PlayerGrid )
				endcase
				case AIValueSprite
					pickAI.value = x-AISide
					CalcColor( pickAI,AIGrid )
				endcase
				case PlayerValueSprite
					pickPL.value = x-PlayerSide
					CalcColor( pickPL,PlayerGrid )
				endcase
				case SoundSlide.ID
					vol = SliderInput( SoundSlide,SoundScale )
					SoundVolume()
				endcase
				case MusicSlide.ID : SetMusicVolumeOGG( MusicSound, SliderInput(MusicSlide,MusicScale) ) : endcase
				case Dialog,Splash,MusicScale.ID,SoundScale.ID : endcase
				case default : RemoveSpriteCon( hit,x,y ) : endcase
			endselect
		endif
		Sync()
		if GetRawKeyPressed( Enter ) then exitfunction

		`Map Generation
		if GetVirtualButtonReleased( MapButton )
			ReDisplaySettings( Off )
			MapLoadSaveButtons( On )
			StopMusicOGG( MusicSound )
			do
				Sync()
				if GetVirtualButtonReleased( AcceptButton ) then exit
				if GetVirtualButtonReleased( L1 ) then LoadMap( "map1" )
				if GetVirtualButtonReleased( S1 ) then SaveMap( "map1" ) : MapLoadSaveButtons( On )
				if GetVirtualButtonReleased( L2 ) then LoadMap( "map2" )
				if GetVirtualButtonReleased( S2 ) then SaveMap( "map2" ) : MapLoadSaveButtons( On )
				if GetVirtualButtonReleased( L3 ) then LoadMap( "map3" )
				if GetVirtualButtonReleased( S3 ) then SaveMap( "map3" ) : MapLoadSaveButtons( On )
				if GetVirtualButtonReleased( MapButton ) then ReGenerateMap()
			loop
			ReDisplaySettings( On )
			MapLoadSaveButtons( Off )
		endif

	until GetVirtualButtonPressed( AcceptFlipButton )
	WaitForButtonRelease( AcceptFlipbutton )
endfunction

function LoadMap( map$ )
	if GetFileExists( map$ )
		mapTable = holdTable  `reset mapTable
		MapFile = OpenToRead( map$ )
		for i = 0 to MapSize-1
			mapTable[i].terrain = ReadInteger( MapFile )
			maptable[i].cost = cost[mapTable[i].terrain]
			maptable[i].modifier = TRM[mapTable[i].terrain]
			mapTable[i].base = mapTable[i].terrain
			mapTable[i].team = Unoccupied
		next i
		CloseFile( MapFile )
		holdTable = mapTable  `store mapTable
	endif
endfunction

function SaveMap( map$ )
	MapFile = OpenToWrite( map$ )
	for i = 0 to MapSize-1 : WriteInteger( MapFile, mapTable[i].terrain ) : next i
	CloseFile( MapFile )
endfunction

function MapLoadSaveButtons( state )
	SetVirtualButtonVisible( L1,state )
	SetVirtualButtonVisible( L2,state )
	SetVirtualButtonVisible( L3,state )

	if GetFileExists( "map1" )
		SetVirtualButtonActive( L1,On )
		SetVirtualButtonAlpha( L1,255 )
	else
		SetVirtualButtonActive( L1,Off )
		SetVirtualButtonAlpha( L1,128 )
	endif
	if GetFileExists( "map2" )
		SetVirtualButtonActive( L2,On )
		SetVirtualButtonAlpha( L2,255 )
	else
		SetVirtualButtonActive( L2,Off )
		SetVirtualButtonAlpha( L2,128 )
	endif
	if GetFileExists( "map3" )
		SetVirtualButtonActive( L3,On )
		SetVirtualButtonAlpha( L3,255 )
	else
		SetVirtualButtonActive( L3,Off )
		SetVirtualButtonAlpha( L3,128 )
	endif

	SetVirtualButtonVisible( S1,state )
	SetVirtualButtonVisible( S2,state )
	SetVirtualButtonVisible( S3,state )
endfunction


function SliderInput( Slide as sliderType, Scale as sliderType )
	SetRawMouseVisible( Off )
	while GetPointerState()
		x = MinMax( Scale.x, Scale.x+Scale.w-Slide.w, GetPointerX() )
		SetSpritePosition( Slide.ID,x,Slide.y)
		Sync()
	endwhile
	SetRawMouseVisible( On )
	volume# = x - Scale.x
	volume# = volume# / SpectrumW
	volume# = volume# * 100
endfunction volume#

function ForcesReady()
	AICount = 0
	PlayerCount = 0
	for i = 0 to Cells-1
		if AIgrid[i].imageID then inc AICount
		if PlayerGrid[i].imageID then inc PlayerCount
	next i
	if (not PlayerCount) or (not AICount)
		DisplayError( SettingsText,"Each side must have at least one unit" )
		ready = False
	else
		ready = True
	endif
endfunction ready

function GridCheck(ID)
	for i = 0 to Cells-1
		if GetSpriteInBox( ID,AIgrid[i].x1, AIgrid[i].y1, AIgrid[i].x2, AIgrid[i].y2 )
			if AIgrid[i].imageID then DeleteSprite( AIgrid[i].ID )
			AIgrid[i].ID = ID
			AIgrid[i].imageID = GetSpriteImageID( ID )
			SetSpritePosition( ID,AIGrid[i].x1, AIGrid[i].y1 )
			SetSpriteColor( ID,pickAI.r, pickAI.g, pickAI.b, pickAI.a )
			Clones.insert(ID)
			exitfunction
		endif
		if GetSpriteInBox( ID,PlayerGrid[i].x1, PlayerGrid[i].y1, PlayerGrid[i].x2, PlayerGrid[i].y2 )
			if PlayerGrid[i].imageID then DeleteSprite( PlayerGrid[i].ID )
			PlayerGrid[i].ID = ID
			PlayerGrid[i].imageID = GetSpriteImageID( ID )
			SetSpritePosition( ID,PlayerGrid[i].x1, PlayerGrid[i].y1 )
			SetSpriteColor( ID,pickPL.r, pickPL.g, pickPL.b, pickPL.a )
			Clones.insert(ID)
			exitfunction
		endif
	next i
	DeleteSprite(ID)
endfunction

function RemoveSpriteCon(ID,x,y)
	DeleteSprite(ID)
	if x >= PlayerSide
		PlayerGrid[CalcCell(x-PlayerSide,y)].imageID = Null
	else
		AIgrid[CalcCell(x-AISide,y)].imageID = Null
	endif
endfunction

function CalcCell(x,y)
	cell as integer
	cell = Max(CellColumns-1,x/(CellWidth+Mullion))
	if y >= Row2 then inc cell,CellColumns
endfunction cell

function GameSetup()
	SetViewZoomMode( 1.0 )
	SetViewOffset( 0,0 )
	zoomFactor = 1

	SetSpriteVisible( TurnCount,On )
	DeleteText( VersionText )
	DeleteSprite( MechGuy[0].bodyID )
	DeleteSprite( MechGuy[0].turretID )
	SetSpriteActive( Dialog,Off )
	SetSpriteActive( Splash,Off )
	SetSpriteVisible( Dialog,Off )
	SetSpriteVisible( Splash,Off )
	SetSpriteVisible( field,On )
	for i = 0 to Clones.length : DeleteSprite(Clones[i]) : next i
	SetVirtualButtonVisible( SettingsButton,Off )
	SetVirtualButtonActive( SettingsButton,Off )
	StopMusicOGG( MusicSound )

	LoadImage( EMP1,"EMP.png" )
	CreateSprite( EMP1,EMP1 )
	SetSpriteTransparency( EMP1, 1 )
	SetSpriteVisible( EMP1, 0 )
	SetSpriteDepth ( EMP1, 0 )
	SetSpriteScissor( EMP1,NodeSize,NodeSize,MaxWidth-NodeSize,MaxHeight-(NodeSize*3) )

	AISurviving = AICount
	PlayerSurviving = PlayerCount
	PlayerLast = PlayerCount-1
	AIPlayerLast = AICount-1
	AITank.length = Empty
	PlayerTank.length = Empty
	AITank.length = AICount
	PlayerTank.length = PlayerCount

	ButtonStatus( Off, AcceptFlipButton, QuitFlipButton )
	AlertButtons( YesNoX4a, YesNoY4, YesNoX4b, YesNoY4, dev.buttSize, AcceptButton, QuitButton )
	LoadButton(CannonButton,cannonImage,cannonImageDown,"Cannon.png","CannonDown.png",dev.buttX1,buttY,dev.buttSize,Off)
	LoadButton(HeavyCannonButton,heavyCannonImage,heavyCannonImageDown,"HeavyCannon.png","HeavyCannonDown.png",dev.buttX1,buttY,dev.buttSize,Off)
	LoadButton(MissileButton,missileImage,missileImageDown,"Rocket.png","RocketDown.png",dev.buttX1,buttY,dev.buttSize,Off)
	LoadButton(LaserButton,laserImage,laserImageDown,"Laser.png","LaserDown.png",dev.buttX2,buttY,dev.buttSize,Off)
	LoadButton(HeavyLaserButton,heavyLaserImage,heavyLaserImageDown,"HeavyLaser.png","HeavyLaserDown.png",dev.buttX2,buttY,dev.buttSize,Off)
	LoadButton(EMPButton,EMPImage,EMPImageDown,"EMPButton.png","EMPButtonDown.png",dev.buttX2,buttY,dev.buttSize,Off)
	LoadButton(MineButton,MineImage,MineImageDown,"MineButton.png","MineButtonDown.png",dev.buttX1,buttY,dev.buttSize,Off)
	turns = 1
	ShowInfo( On )
endfunction

remstart
	AIProdUnits = AIBaseCount * BaseProdValue
	PlayerProdUnits = PlayerBaseCount * BaseProdValue
remend
