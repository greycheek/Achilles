
function MainMenu()
	Setup()
	t1 = PatrolMech()
	do
		if not GetTweenSpritePlaying(t1,MechGuy[0].bodyID) then t1 = PatrolMech()
		UpdateAllTweens(getframetime())
		Sync()
		cancel = GetVirtualButtonReleased( QuitButton )
		accept = GetVirtualButtonReleased( AcceptButton )
		settings = GetVirtualButtonReleased( SettingsButton )
		Qkey = GetRawKeyPressed( 0x51 ) `Q
		EKey = GetRawKeyPressed( Enter )
		SKey = GetRawKeyPressed( 0x53 ) `S
		if cancel or Qkey
			if Confirm( "Quit?",QuitText ) then end
		elseif settings or SKey
			PlaySound( ClickSound,vol )
			AlertButtons( YesNoX3a,by#,YesNoX3b,by#,dev.buttSize,AcceptFlipButton,QuitFlipButton )
			SettingsDialog()
		elseif accept or EKey
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

function AlertDialog( text,state,x,y,w,h )
	If state = Off
		//~ PlaySound( ClickSound,vol )
		DeleteText( text )
		DeleteSprite( AlertBackGround )
	else
		SetTextVisible( MapText,state )
		SetupSprite( AlertBackGround,AlertBackGround,"Yes-NoBkgnd.png",x,y,w,h,0,Off,0 )
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
	SetVirtualButtonActive( SettingsButton,FlipState )
	SetVirtualButtonActive( AcceptButton,FlipState )
	SetVirtualButtonActive( QuitButton,FlipState )
	SetVirtualButtonActive( AcceptFlipButton,state )
	SetVirtualButtonActive( MapButton,state )

	CreateGrid(state)
endfunction

function ReDisplaySettings(state)
	SetSpriteActive( Dialog,state )
	SetSpriteVisible( Dialog,state )
	SetSpriteVisible( MusicSlide.ID,state )
	SetSpriteVisible( SoundSlide.ID,state )
	SetSpriteVisible( MusicScale.ID,state )
	SetSpriteVisible( SoundScale.ID,state )

	SetSpriteVisible( RoughScale.ID, not state )
	SetSpriteVisible( TreeScale.ID, not state  )
	SetSpriteVisible( RoughSlide.ID, not state  )
	SetSpriteVisible( TreeSlide.ID, not state  )
	SetSpriteVisible( BaseScale.ID, not state )
	SetSpriteVisible( DepotScale.ID, not state  )
	SetSpriteVisible( BaseSlide.ID, not state  )
	SetSpriteVisible( DepotSlide.ID, not state  )

	SetSpriteActive( MusicSlide.ID,state )
	SetSpriteActive( SoundSlide.ID,state )
	SetSpriteActive( MusicScale.ID,state )
	SetSpriteActive( SoundScale.ID,state )

	SetSpriteActive( RoughScale.ID, not state  )
	SetSpriteActive( TreeScale.ID, not state  )
	SetSpriteActive( RoughSlide.ID, not state  )
	SetSpriteActive( TreeSlide.ID, not state  )
	SetSpriteActive( BaseScale.ID, not state )
	SetSpriteActive( DepotScale.ID, not state  )
	SetSpriteActive( BaseSlide.ID, not state  )
	SetSpriteActive( DepotSlide.ID, not state  )

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
	SetVirtualButtonVisible( MapSaveFlipButton, not state )
	SetVirtualButtonVisible( RandomizeFlipButton, not state )
	SetVirtualButtonVisible( ImpassButton, not state )
	SetVirtualButtonVisible( WaterButton, not state )
	SetVirtualButtonActive( AcceptButton, not state )
	SetVirtualButtonActive( AcceptFlipButton,state )
	SetVirtualButtonActive( MapButton,state )
	SetVirtualButtonActive( MapFlipButton, not state )
	SetVirtualButtonActive( MapSaveFlipButton, not state )
	SetVirtualButtonActive( RandomizeFlipButton, not state )
	SetVirtualButtonActive( ImpassButton, not state )
	SetVirtualButtonActive( WaterButton, not state )
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

function SliderInput( Slide as sliderType, Scale as sliderType )
	ScaleMax = Scale.x+Scale.w-Slide.w
	SlideOffset = Slide.w/2
	SetRawMouseVisible( Off )
	while GetPointerState()
		px = GetPointerX()
		Slide.x = MinMax( Scale.x,ScaleMax,px-SlideOffset )
		SetSpriteX( Slide.ID,Slide.x )
		Sync()
	endwhile
	SetRawMouseVisible( On )
	px = MinMax( Scale.x,Scale.x+Scale.w,px )
	si# = px - Scale.x
	select Slide.ID
		case SoundSlide.ID, MusicSlide.ID
			si# = si# / SpectrumW
			si# = si# * 100
		endcase
	endselect
endfunction si#

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
					for i = 1 to 7
						if hit = SpriteCon[i].ID  `identify vehicle type
							GridCheck( clone,i ) : exit
						endif
					next i
				endcase
				case AISpectrumSprite
					pickAI.satur = abs(cy1-y)/100
					pickAI.spect = x-AISide
					CalcColor( pickAI,AIGrid )
					BaseColor()
				endcase
				case PlayerSpectrumSprite
					pickPL.satur = abs(cy1-y)/100
					pickPL.spect = x-PlayerSide
					CalcColor( pickPL,PlayerGrid )
					BaseColor()
				endcase
				case AIValueSprite
					pickAI.value = x-AISide
					CalcColor( pickAI,AIGrid )
					BaseColor()
				endcase
				case PlayerValueSprite
					pickPL.value = x-PlayerSide
					CalcColor( pickPL,PlayerGrid )
					BaseColor()
				endcase
				case SoundSlide.ID
					vol = SliderInput( SoundSlide,SoundScale )
					SoundVolume()
				endcase
				case MusicSlide.ID
					m = SliderInput(MusicSlide,MusicScale)
					SetMusicVolumeOGG( MusicSound,m )
				endcase
				case Dialog,Splash,MusicScale.ID,SoundScale.ID : endcase
				case default : RemoveSpriteCon( hit,x,y ) : endcase
			endselect
		endif
		Sync()
		if GetRawKeyPressed( Enter ) then exitfunction

		`Map Generation
		if GetVirtualButtonReleased( MapButton ) or GetRawKeyPressed( 0x4D ) `M

			PlaySound( ClickSound )
			if mapImpass then SetVirtualButtonImageUp(ImpassButton,ImpassButtonImageDown) else SetVirtualButtonImageUp(ImpassButton,ImpassButtonImage)
			if mapWater	 then SetVirtualButtonImageUp(WaterButton,WaterButtonImageDown)   else SetVirtualButtonImageUp(WaterButton,WaterButtonImage)

			ReDisplaySettings( Off )
			StopMusicOGG( MusicSound )
			do
				if GetPointerState()
					x = GetPointerX()
					y = GetPointery()
					slideHit = GetSpriteHit(x,y)
					if slideHit
						select slideHit
							case BaseSlide.ID  : baseQTY  = SliderInput(BaseSlide,BaseScale)   : endcase
							case DepotSlide.ID : depotQTY = SliderInput(DepotSlide,DepotScale) : endcase
							case RoughSlide.ID : roughQTY = SliderInput(RoughSlide,RoughScale) : endcase
							case TreeSlide.ID  : treeQTY  = SliderInput(TreeSlide,TreeScale)   : endcase
						endselect
					endif
				endif

				Sync()
				if GetVirtualButtonReleased( ImpassButton )
					PlaySound( ClickSound )
					if mapImpass
						mapImpass=0 : SetVirtualButtonImageUp( ImpassButton,ImpassButtonImage )
					else
						mapImpass=ImpassOn : SetVirtualButtonImageUp( ImpassButton,ImpassButtonImageDown )
					endif
				endif
				if GetVirtualButtonReleased( WaterButton )
					PlaySound( ClickSound )
					if mapWater
						mapWater=0 : SetVirtualButtonImageUp( WaterButton,WaterButtonImage )
					else
						mapWater=WaterOn : SetVirtualButtonImageUp( WaterButton,WaterButtonImageDown )
					endif
				endif
				if GetVirtualButtonReleased( MapSaveFlipButton ) or GetRawKeyPressed( 0x46 ) then MapSlotDialog() `F
				if GetVirtualButtonReleased( RandomizeFlipButton ) or GetRawKeyPressed( 0x52 ) `R
					PlaySound( ClickSound )
					ResetMap()
					GenerateTerrain()
				endif
				if GetVirtualButtonReleased( AcceptButton ) or GetRawKeyPressed( Enter )
					PlaySound( ClickSound )
					exit
				endif

			loop
			ReDisplaySettings( On )
			SetVirtualButtonPosition( AcceptFlipButton,YesNoX3a,by# )
		endif

	until GetVirtualButtonPressed( AcceptFlipButton )
	WaitForButtonRelease( AcceptFlipbutton )
endfunction


function MapSlotDialog()
	PlaySound( ClickSound,vol )
	map$ = ""
	x = MiddleX-(dev.buttSize*3)
	y = YesNoY1-(dev.buttSize/4)
	w = (MiddleX-x)*1.95
	h = AlertH+(dev.buttSize/2)
	TSize = (32*dev.scale)
	Text( MapText,"MAP SAVE SLOTS",x+20,YesNoY1,50,50,50,TSize,255,0 )
	SetVirtualButtonSize( QuitFlipButton,dev.buttSize )
	SetVirtualButtonPosition( QuitFlipButton,x+w-dev.buttSize,YesNoY2+(dev.ButtSize/3) )
	AlertDialog( MapText,On,x,y,w,h )
	MapSLOTButtons( On )

	for i = 1 to 4
		m$ = "map"+str(i)
		if GetFileExists( m$ )
			select m$
				case "map1" : SetVirtualButtonAlpha( SLOT1,FullAlpha ) : endcase
				case "map2" : SetVirtualButtonAlpha( SLOT2,FullAlpha ) : endcase
				case "map3" : SetVirtualButtonAlpha( SLOT3,FullAlpha ) : endcase
				case "map4" : SetVirtualButtonAlpha( SLOT4,FullAlpha ) : endcase
			endselect
		else
			select m$
				case "map1" : SetVirtualButtonAlpha( SLOT1,HalfAlpha ) : endcase
				case "map2" : SetVirtualButtonAlpha( SLOT2,HalfAlpha ) : endcase
				case "map3" : SetVirtualButtonAlpha( SLOT3,HalfAlpha ) : endcase
				case "map4" : SetVirtualButtonAlpha( SLOT4,HalfAlpha ) : endcase
			endselect
		endif
	next i
	do
		Sync()
		if GetVirtualButtonReleased( SLOT1 ) then map$ = "map1"
		if GetVirtualButtonReleased( SLOT2 ) then map$ = "map2"
		if GetVirtualButtonReleased( SLOT3 ) then map$ = "map3"
		if GetVirtualButtonReleased( SLOT4 ) then map$ = "map4"
		if map$ <> ""
			SetVirtualButtonVisible( SLOT1,Off )
			SetVirtualButtonVisible( SLOT2,Off )
			SetVirtualButtonVisible( SLOT3,Off )
			SetVirtualButtonVisible( SLOT4,Off )
			LoadSaveDialog( map$ )
			exit
		endif
		if GetVirtualButtonReleased( QuitFlipButton ) then exit
	loop
	PlaySound( ClickSound,vol )
	AlertDialog( MapText,Off,x,y,w,h )
	MapSLOTButtons( Off )
endfunction

function LoadSaveDialog( map$ )
	PlaySound( ClickSound,vol )
	TSize = (32*dev.scale)
	Text( MapText,"MAP SAVE SLOTS",YesNoX1+(TSize*.85),YesNoY1+(TSize*.6),50,50,50,TSize,255,0 )
	SetVirtualButtonSize( QuitFlipButton,dev.buttSize )
	SetVirtualButtonPosition( QuitFlipButton,YesNoX2a,YesNoY2 )
	SetVirtualButtonVisible( QuitFlipButton,On )
	AlertDialog( MapText,On,YesNoX1,YesNoY1,AlertW,AlertH )
	MapLoadSaveButtons( On )
	if GetFileExists( map$ )
		SetVirtualButtonActive( LOADBUTT,On )
		SetVirtualButtonAlpha( LOADBUTT,255 )
	else
		SetVirtualButtonActive( LOADBUTT,Off )
		SetVirtualButtonAlpha( LOADBUTT,128 )
	endif
	do
		Sync()
		if GetVirtualButtonReleased( QuitFlipButton )
			exit
		elseif GetVirtualButtonReleased( LOADBUTT )
			LoadMap( map$ ) : exit
		elseif GetVirtualButtonReleased( SAVEBUTT )
			if SaveMap( map$ ) then exit
		endif
	loop
	MapLoadSaveButtons( Off )
	AlertDialog( MapText,Off,YesNoX1,YesNoY1,AlertW,AlertH )
endfunction

function LoadMap( map$ )
	ResetMap()
	LoadImage(field,"AchillesBoardClear.png")
	CreateSprite(field,field)
	SetSpriteDepth(field,12)
	SetSpriteSize(field,MaxWidth,MaxHeight)

	//~ SetDisplayAspect(-1)  `set current device aspect ratio
	DrawSprite(field)
	SetRenderToImage(field,0)
	MapFile = OpenToRead( map$ )
	for i = 0 to MapSize-1
		mapTable[i].terrain = ReadInteger( MapFile )
		maptable[i].cost = cost[mapTable[i].terrain]
		maptable[i].modifier = TRM[mapTable[i].terrain]
		mapTable[i].base = mapTable[i].terrain
		mapTable[i].team = Unoccupied
		node = CalcNode( mapTable[i].nodeX,mapTable[i].nodeY )
		if node < LiveArea  `before button area
			select mapTable[i].terrain
				case PlayerBase
					PlayerBases.length = PlayerBases.length+1
					BaseSetup( PlayerBases.length,PlayerBaseSeries+PlayerBases.length,node,PlayerBase,PlayerBases,BaseGroup )
				endcase
				case AIBase
					AIBases.length = AIBases.length+1
					BaseSetup( AIBases.length,AIBaseSeries+AIBases.length,node,AIBase,AIBases,AIBaseGroup )
				endcase
				case PlayerDepot
					PlayerDepotNode.length = PlayerDepotNode.length+1
					DepotSetup(PlayerDepotNode.length,PlayerDepotSeries+PlayerDepotNode.length,node,PlayerDepot,PlayerDepotNode,depotGroup )
				endcase
				case AIDepot
					AIDepotNode.length = AIDepotNode.length+1
					DepotSetup( AIDepotNode.length,AIDepotSeries+AIDepotNode.length,node,AIDepot,AIDepotNode,AIdepotGroup )
				endcase
				case Trees       : DrawTerrain( node,TreeSprite,treeDummy ) : endcase
				case Rough		 : DrawTerrain( node,RoughSprite,RoughDummy ) : endcase
				case Impassable  : DrawTerrain( node,Impass,impassDummy ) : endcase
				case Water		 : DrawTerrain( node,AcquaSprite,waterDummy ) : endcase
			endselect
		endif
	next i
	LoadForce( MapFile )
	CloseFile( MapFile )
			//~ SetDisplayAspect(AspectRatio)  `back to map aspect ratio
	SetRenderToScreen()

	AIBaseCount = AIBases.length
	PlayerBaseCount = PlayerBases.length
	AIDepotCount = AIDepotNode.length
	PlayerDepotCount = PlayerDepotNode.length
	AIProdUnits = (AIBaseCount+1) * BaseProdValue
	PlayerProdUnits = (PlayerBaseCount+1) * BaseProdValue
	BaseColor()
endfunction

function SaveMap( map$ )
	if GetFileExists( map$ )
		SetVirtualButtonVisible( LOADBUTT,Off )
		SetVirtualButtonVisible( SAVEBUTT,Off )
		SetTextColorAlpha( MapText,0 )	`turns the text off; SetTextVisible() doesn't work
		if Confirm("Overwrite?",ConfirmText)
			SetVirtualButtonActive( LOADBUTT,On )
			SetVirtualButtonAlpha( LOADBUTT,255 )
		else
			SetVirtualButtonSize( QuitFlipButton,dev.buttSize )
			SetVirtualButtonPosition( QuitFlipButton,YesNoX2a,YesNoY2 )
			SetTextColorAlpha( MapText,FullAlpha )
			AlertDialog( MapText,On,YesNoX1,YesNoY1,AlertW,AlertH )
			WaitForButtonRelease( QuitFlipButton )
			MapLoadSaveButtons( On )
			exitfunction False
		endif
	endif
	file = OpenToWrite( map$ )
	`save map
	for i = 0 to MapSize-1 : WriteInteger( file, mapTable[i].terrain ) : next i
	`save force
	WriteInteger( file,pickAI.r ) : WriteInteger( file,pickAI.g ) : WriteInteger( file,pickAI.b ) : WriteInteger( file,pickAI.a )
	WriteInteger( file,pickPL.r ) : WriteInteger( file,pickPL.g ) : WriteInteger( file,pickPL.b ) : WriteInteger( file,pickPL.a )
	for i = 0 to Cells-1 : WriteInteger( file,AIGrid[i].vehicle ) : next i
	for i = 0 to Cells-1 : WriteInteger( file,PlayerGrid[i].vehicle ) : next i
	CloseFile( file )
endfunction True

function Confirm( message$,textID )
	TSize = 36*dev.scale
	Text( textID,message$,YesNoX1+(TSize*.85),YesNoY1+(TSize*.6),50,50,50,TSize,255,0 )
	ButtonState( AcceptFlipButton,On )
	ButtonState( QuitFlipButton,On )
	AlertButtons( YesNoX2a, YesNoY2, YesNoX2b, YesNoY2, dev.buttSize, AcceptFlipButton, QuitFlipButton )
	AlertDialog( textID,On,YesNoX1,YesNoY1,AlertW,AlertH )
	do
		Sync()
		if GetVirtualButtonPressed( AcceptFlipButton ) or GetRawKeyState( Enter ) or GetRawKeyPressed( 0x59 ) `Y
			confirmation = True : exit
		endif
		if GetVirtualButtonPressed( QuitFlipButton ) or GetRawKeyReleased( 0x4E ) `N
			confirmation = False : exit
		endif
	loop
	PlaySound( ClickSound,vol )
	ButtonState( AcceptFlipButton,Off )
	ButtonState( QuitFlipButton,Off )
	AlertDialog( textID,Off,YesNoX1,YesNoY1,AlertW,AlertH )
endfunction confirmation

function LoadForce( file )	`placed at end, after map data
	pickAI.r = ReadInteger( file ) : pickAI.g = ReadInteger( file ) : pickAI.b = ReadInteger( file ) : pickAI.a = ReadInteger( file )
	pickPL.r = ReadInteger( file ) : pickPL.g = ReadInteger( file ) : pickPL.b = ReadInteger( file ) : pickPL.a = ReadInteger( file )
	for i = 0 to Cells-1
		AIGrid[i].vehicle = ReadInteger( file )
		if GetSpriteExists( AIGrid[i].ID ) then DeleteSprite( AIGrid[i].ID )
		if AIGrid[i].vehicle
			AIGrid[i].ID = CloneSprite( SpriteCon[AIGrid[i].vehicle].ID )
			AIGrid[i].imageID = GetSpriteImageID( SpriteCon[AIGrid[i].vehicle].ID )
			SetSpriteSize( AIGrid[i].ID,SpriteConSize,SpriteConSize )
			SetSpritePosition( AIGrid[i].ID,AIGrid[i].x1,AIGrid[i].y1 )
			SetSpriteColor( AIGrid[i].ID,pickAI.r,pickAI.g,pickAI.b,pickAI.a )
		else
			AIgrid[i].imageID = Null
			AIgrid[i].ID = Null
		endif
	next i
	for i = 0 to Cells-1
		PlayerGrid[i].vehicle = ReadInteger( file )
		if GetSpriteExists( PlayerGrid[i].ID ) then DeleteSprite( PlayerGrid[i].ID )
		if PlayerGrid[i].vehicle
			PlayerGrid[i].ID = CloneSprite( SpriteCon[PlayerGrid[i].vehicle].ID )
			PlayerGrid[i].imageID = GetSpriteImageID( SpriteCon[PlayerGrid[i].vehicle].ID )
			SetSpriteSize( PlayerGrid[i].ID,SpriteConSize,SpriteConSize )
			SetSpritePosition( PlayerGrid[i].ID,PlayerGrid[i].x1,PlayerGrid[i].y1 )
			SetSpriteColor( PlayerGrid[i].ID,pickPL.r,pickPL.g,pickPL.b,pickPL.a )
		else
			PlayerGrid[i].imageID = Null
			PlayerGrid[i].ID = Null
		endif
	next i
endfunction

function DrawTerrain( node,terrain,dummy )
	SetSpriteScissor( terrain, NodeSize, NodeSize, MapWidth+NodeSize, MapHeight+NodeSize )
	SetSpriteVisible( terrain,On )
	SetSpritePositionByOffset( terrain,mapTable[node].x,mapTable[node].y )
	DrawSprite( terrain )
	x = mapTable[node].x-NodeOffset
	y = mapTable[node].y-NodeOffset
	AddSpriteShapeBox(dummy,x,y,x+NodeSize-1,y+NodeSize-1,0)
	SetSpriteVisible( terrain,Off )
endfunction


function MapSLOTButtons( state )
	ButtonState( SLOT1,state )
	ButtonState( SLOT2,state )
	ButtonState( SLOT3,state )
	ButtonState( SLOT4,state )
	ButtonState( QuitFlipButton,state )
endfunction

function MapLoadSaveButtons( state )
	ButtonState( LOADBUTT,state )
	ButtonState( SAVEBUTT,state )
	ButtonState( QuitFlipButton,state )
endfunction

function ButtonState( button,state )
	SetVirtualButtonVisible( button,state )
	SetVirtualButtonActive( button,state )
endfunction

function ButtonActivation( state )
	SetVirtualButtonActive(AcceptFlipButton,state)
	SetVirtualButtonActive(QuitFlipButton,state)
	SetVirtualButtonActive(LOADBUTT,state)
	SetVirtualButtonActive(SAVEBUTT,state)
	SetVirtualButtonActive(SLOT1,state)
	SetVirtualButtonActive(SLOT2,state)
	SetVirtualButtonActive(SLOT3,state)
	SetVirtualButtonActive(SLOT4,state)
endfunction

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

function GridCheck( ID,vehicle )
	for i = 0 to Cells-1
		if GetSpriteInBox( ID,AIGrid[i].x1,AIGrid[i].y1,AIGrid[i].x2,AIGrid[i].y2 )
			if AIgrid[i].imageID then DeleteSprite( AIgrid[i].ID )
			AIGrid[i].ID = ID
			AIGrid[i].imageID = GetSpriteImageID(ID)
			AIGrid[i].vehicle = vehicle
			SetSpritePosition( AIGrid[i].ID,AIGrid[i].x1,AIGrid[i].y1 )
			SetSpriteColor( AIGrid[i].ID,pickAI.r,pickAI.g,pickAI.b,pickAI.a )
			exitfunction
		endif
		if GetSpriteInBox( ID,PlayerGrid[i].x1,PlayerGrid[i].y1,PlayerGrid[i].x2,PlayerGrid[i].y2 )
			if PlayerGrid[i].imageID then DeleteSprite( PlayerGrid[i].ID )
			PlayerGrid[i].ID = ID
			PlayerGrid[i].imageID = GetSpriteImageID(ID)
			PlayerGrid[i].vehicle = vehicle
			SetSpritePosition( PlayerGrid[i].ID,PlayerGrid[i].x1,PlayerGrid[i].y1 )
			SetSpriteColor( PlayerGrid[i].ID,pickPL.r,pickPL.g,pickPL.b,pickPL.a )
			exitfunction
		endif
	next i
	DeleteSprite(ID)
endfunction

function RemoveSpriteCon( ID,x,y )
	DeleteSprite(ID)
	if x >= PlayerSide
		cell = CalcCell(x-PlayerSide,y)
		PlayerGrid[cell].ID = Null
		PlayerGrid[cell].imageID = Null
		PlayerGrid[cell].vehicle = Null
	else
		cell = CalcCell(x-AISide,y)
		AIGrid[cell].ID = Null
		AIGrid[cell].imageID = Null
		AIGrid[cell].vehicle = Null
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
	for i = 0 to Cells-1
		if GetSpriteExists(AIGrid[i].ID) then DeleteSprite(AIGrid[i].ID)
		if GetSpriteExists(PlayerGrid[i].ID) then DeleteSprite(PlayerGrid[i].ID)
	next i
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

	ButtonState( AcceptFlipButton,Off )
	ButtonState( QuitFlipButton,Off )
	AlertButtons( YesNoX4a, YesNoY4, YesNoX4b, YesNoY4, dev.buttSize, AcceptButton, QuitButton )
	LoadButton(CannonButton,cannonImage,cannonImageDown,"Cannon.png","CannonDown.png",dev.buttX1,buttY,dev.buttSize,Off)
	LoadButton(HeavyCannonButton,heavyCannonImage,heavyCannonImageDown,"HeavyCannon.png","HeavyCannonDown.png",dev.buttX1,buttY,dev.buttSize,Off)
	LoadButton(MissileButton,missileImage,missileImageDown,"Rocket.png","RocketDown.png",dev.buttX1,buttY,dev.buttSize,Off)
	LoadButton(LaserButton,laserImage,laserImageDown,"Laser.png","LaserDown.png",dev.buttX2,buttY,dev.buttSize,Off)
	LoadButton(HeavyLaserButton,heavyLaserImage,heavyLaserImageDown,"HeavyLaser.png","HeavyLaserDown.png",dev.buttX2,buttY,dev.buttSize,Off)
	LoadButton(EMPButton,EMPImage,EMPImageDown,"EMPButton.png","EMPButtonDown.png",dev.buttX2,buttY,dev.buttSize,Off)
	LoadButton(MineButton,MineImage,MineImageDown,"MineButton.png","MineButtonDown.png",dev.buttX1,buttY,dev.buttSize,Off)
	LoadButton(DisruptButton,disruptorImage,disruptorImageDown,"DisruptorButtonUp.png","DisruptorButtonDown.png",dev.buttX2,buttY,dev.buttSize,Off)
	LoadButton(BulletButton,BulletImage,BulletImage,"BulletButton.png","BulletButton.png",dev.buttX2,buttY,dev.buttSize,Off)

	turns = 1
	ShowInfo( On )
endfunction

remstart
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

		function ButtonStatus( state,accept,quit )
			SetVirtualButtonVisible( accept,state )
			SetVirtualButtonVisible( quit,state )
			SetVirtualButtonActive( accept,state )
			SetVirtualButtonActive( quit,state )
		endfunction

		function LSButtState( button,state,alpha )
			SetVirtualButtonActive( button,state )
			SetVirtualButtonAlpha( button,alpha )
		endfunction

		FROM MAINMENU: (substituted by Confirm(message$))
			PlaySound( ClickSound,vol )
			TSize = 36*dev.scale
			Text( QuitText,"Quit?",YesNoX1+TSize,YesNoY1+TSize,50,50,50,TSize,255,0 )
			ButtonStatus( On, AcceptFlipButton, QuitFlipButton )
			AlertButtons( YesNoX2a, YesNoY2, YesNoX2b, YesNoY2, dev.buttSize, AcceptFlipButton, QuitFlipButton )
			AlertDialog( QuitText,On,QuitFlipButton )
			do
				Sync()
				if GetVirtualButtonPressed( AcceptFlipButton ) or GetRawKeyState( Enter ) or GetRawKeyPressed( 0x59 ) then end  `Y
				if GetVirtualButtonPressed( QuitFlipButton ) //or GetRawKeyReleased( 0x4E ) `N
					ButtonStatus( Off, AcceptFlipButton, QuitFlipButton )
					AlertDialog( QuitText,Off,QuitFlipButton )
					exit
				endif
			loop

		for i = 0 to Clones.length : DeleteSprite( Clones[i] ) : next i
		Clones.length = -1
			PlayerGrid[i].x1 = ReadInteger( file ) : PlayerGrid[i].y1 = ReadInteger( file )
			PlayerGrid[i].x2 = ReadInteger( file ) : PlayerGrid[i].y2 = ReadInteger( file )
			AIGrid[i].x1 = ReadInteger( file ) : AIGrid[i].y1 = ReadInteger( file )
			AIGrid[i].x2 = ReadInteger( file ) : AIGrid[i].y2 = ReadInteger( file )
			WriteInteger( file,AIGrid[i].x1 ) : WriteInteger( file,AIGrid[i].y1 )
			WriteInteger( file,AIGrid[i].x2 ) : WriteInteger( file,AIGrid[i].y2 )
			WriteInteger( file,PlayerGrid[i].x1 ) : WriteInteger( file,PlayerGrid[i].y1 )
			WriteInteger( file,PlayerGrid[i].x2 ) : WriteInteger( file,PlayerGrid[i].y2 )

		if GetSpriteExists( AIGrid[i].ID )
			DeleteSprite(AIGrid[i].ID)
			AIGrid[i].ID = Null
			AIGrid[i].imageID = Null
			AIGrid[i].vehicle = Null
		endif

		if GetSpriteExists( PlayerGrid[i].ID )
			DeleteSprite(PlayerGrid[i].ID)
			PlayerGrid[i].ID = Null
			PlayerGrid[i].imageID = Null
			PlayerGrid[i].vehicle = Null
		endif

		for i = 0 to Cells-1
			AIGrid[i].ID = Null : AIGrid[i].vehicle = Null
			AIGrid[i].x1 = Null : AIGrid[i].y1 = Null : AIGrid[i].x2 = Null : AIGrid[i].y2 = Null
			PlayerGrid[i].ID = Null : PlayerGrid[i].vehicle = Null
			PlayerGrid[i].x1 = Null : PlayerGrid[i].y1 = Null : PlayerGrid[i].x2 = Null : PlayerGrid[i].y2 = Null
		next i

	AIProdUnits = AIBaseCount * BaseProdValue
	PlayerProdUnits = PlayerBaseCount * BaseProdValue
remend
