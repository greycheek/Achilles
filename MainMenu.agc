

function MainMenu()
	Setup()
	t as integer[2]
	t = PatrolMech(t)
	do
		if GetPointerPressed()	`poke the mech
			if GetSpriteinCircle(MechGuy[0].bodyID,GetPointerX(),GetPointerY(),NodeSize/2)
				PlaySound( BoingSound,vol )
				Halt(t[0],t[1],t[2])
				MechGuy[0].x = GetSpriteXByOffset(MechGuy[0].turretID)
				MechGuy[0].y = GetSpriteYByOffset(MechGuy[0].turretID)
				x2 = Random2(0,MaxWidth)
				y2 = Random2(0,MaxHeight)
				RotateTurret(0,MechGuy,x2,y2)
				ResetTimer()
			endif
		endif
		if not GetTweenSpritePlaying( t[0],MechGuy[0].bodyID ) then t = PatrolMech(t)
		UpdateAllTweens( GetFrameTime() )
		Sync()
		if GetVirtualButtonReleased( InfoButt.ID ) or GetRawKeyPressed( 0x49 ) `I
			PlaySound( ClickSound,vol )
			ButtonState(acceptButt.ID,Off)
			ButtonState(cancelButt.ID,Off)
			ButtonState(settingsButt.ID,Off)
			ButtonState(StatButt.ID,Off)
			ShowInfoTables()
			ButtonState(acceptButt.ID,On)
			ButtonState(cancelButt.ID,On)
			ButtonState(settingsButt.ID,On)
			ButtonState(StatButt.ID,On)
			continue
		endif
		if GetVirtualButtonReleased( StatButt.ID ) or GetRawKeyPressed( 0x54 ) `T
			PlaySound( ClickSound,vol )
			margin = 15 * dev.scale
			SetupSprite( AlertBackGround,AlertBackGround,"Yes-NoBkgnd.png",mapSlotDialog.x,mapSlotDialog.y,mapSlotDialog.w,mapSlotDialog.h,0,On,0 )
			SetSpriteActive( AlertBackGround,On )
			SetSpriteVisible( AlertBackGround,On )
			SetVirtualButtonPosition( acceptButt.ID,mapSlotDialog.cancel.x-margin,mapSlotDialog.cancel.y )
			x = mapSlotDialog.x + margin
			y = mapSlotDialog.y + margin
			TSize = 30*dev.scale
			Text(StatText,"PLAYER STATISTICS",x,y,0,0,0,TSize,255,0,On) : inc y,TSize+(10*dev.scale)
			TSize = 24*dev.scale
			Text(StatText+1,"Longest Game:  "+str(Stats.rounds)+" turns",x,y,0,0,0,TSize,255,0,Off) : inc y,TSize
			Text(StatText+2,"Bases Lost:  "+str(Stats.basesLost),x,y,0,0,0,TSize,255,0,Off) : inc y,TSize
			Text(StatText+3,"Bases Captured:  "+str(Stats.basesCaptured),x,y,0,0,0,TSize,255,0,Off) : inc y,TSize
			Text(StatText+4,"Units Lost:  "+str(Stats.unitsLost),x,y,0,0,0,TSize,255,0,Off) : inc y,TSize
			Text(StatText+5,"Units Created:  "+str(Stats.unitsCreated),x,y,0,0,0,TSize,255,0,Off) : inc y,TSize
			Text(StatText+6,"Enemies Destroyed:  "+str(Stats.unitsDestroyed),x,y,0,0,0,TSize,255,0,Off)
			repeat
				Sync()
			until GetVirtualButtonPressed( acceptButt.ID )
			WaitForButtonRelease( acceptButt.ID )
			for i = 0 to 6 : DeleteText(StatText+i) : next i
			SetSpriteActive( AlertBackGround,Off )
			SetSpriteVisible( AlertBackGround,Off )
			SetVirtualButtonPosition( acceptButt.ID,acceptButt.x,acceptButt.y )
			continue
		endif
		Update( GetUpdateTime() )
		if GetVirtualButtonReleased( cancelButt.ID ) or GetRawKeyPressed( 0x51 ) `Q
			if Confirm( "Quit?",QuitText )
				WriteStats()
				end
			else
				continue
			endif
		endif
		Update( GetUpdateTime() )
		if GetVirtualButtonReleased( acceptButt.ID ) or GetRawKeyPressed( Enter )
			PlaySound( ClickSound,vol )
			GameSetup()
			exitfunction
		endif
		Update( GetUpdateTime() )
		if GetVirtualButtonReleased( settingsButt.ID ) or GetRawKeyPressed( 0x53 ) `S
			PlaySound( ClickSound,vol )
			ButtonState(InfoButt.ID,Off)
			AlertButtons( acceptButt.x,acceptButt.y,cancelButt.x,cancelButt.y,dev.buttSize,acceptButt.ID,cancelButt.ID )
			SetSpriteVisible( Logo,Off )
			SetSpriteActive( Logo,Off )
			SetSpriteDepth( Logo,10 )
			SettingsDialog()
			SetSpriteVisible( Logo,On )
			SetSpriteActive( Logo, On )
			SetSpriteDepth( Logo,0 )
			ButtonState(InfoButt.ID,On)
		endif
	loop
endfunction

function WriteStats()
	StatFile = OpenToWrite( "stats" )
	if turns > Stats.rounds then WriteInteger( StatFile,turns ) else WriteInteger( StatFile,Stats.rounds )
	WriteInteger( StatFile,Stats.basesLost )
	WriteInteger( StatFile,Stats.basesCaptured )
	WriteInteger( StatFile,Stats.unitsLost )
	WriteInteger( StatFile,Stats.unitsCreated )
	WriteInteger( StatFile,Stats.unitsDestroyed )
	CloseFile( StatFile )
endfunction

function Halt(ID1,ID2,ID3)
	StopTweenSprite( ID1,MechGuy[0].bodyID )
	StopTweenSprite( ID2,MechGuy[0].turretID )
	StopTweenSprite( ID3,MechGuy[1].bodyID )
	StopSprite( MechGuy[0].bodyID )
	StopSprite( MechGuy[0].turretID )
	StopSprite( MechGuy[1].bodyID )
endfunction

function AlertButtons( x1,y1,x2,y2,size,accept,cancel )
	PlaySound( ClickSound,vol )
	SetVirtualButtonSize( accept,size )
	SetVirtualButtonSize( cancel,size )
	SetVirtualButtonPosition( accept,x1,y1 )
	SetVirtualButtonPosition( cancel,x2,y2 )
endfunction

function PatrolMech(t ref as integer[])
	dir as integer[8]
	x2 = Random2(0,MaxWidth)
	y2 = Random2(0,MaxHeight)
	t# = Timer()
	if (t# >= 1.5) and (t# <= 1.65) then RotateTurret(0,MechGuy,x2,y2)	`look again
	if t# < 3 then exitfunction t	`still looking

	select Randomize(1,15)  `random action
		case 10 : MechGuy[0].route = Random2(0,7) : endcase	`new direction
		case 12		`stop and look
			Halt(t[0],t[1],t[2])
			RotateTurret(0,MechGuy,x2,y2)
			ResetTimer()
			exitfunction t
		endcase
		case 14,15  `fire
			Halt(t[0],t[1],t[2])
			if Random(0,1)
				if  VectorDistance( MechGuy[0].x,MechGuy[0].y,x2,y2 ) > ( NodeSize*3 )
					RotateTurret(0,MechGuy,x2,y2)
					LaserFire( MechGuy[0].x,MechGuy[0].y,x2,y2,heavyLaser,1.25,2,1,MechGuy[0].scale )
				endif
			endif
			exitfunction t
		endcase
	endselect

	RightEdge = MaxWidth-buffer
	BottomEdge = MaxHeight-buffer
	x1 = MechGuy[0].x
	y1 = MechGuy[0].y
	x2 = MinMax( buffer,RightEdge,x1 + turnX[MechGuy[0].route] )
	y2 = MinMax( buffer,MapHeight,y1 + turnY[MechGuy[0].route] )

	if OutOfBounds(x1,y1,buffer,RightEdge,buffer,MapHeight)
		Halt(t[0],t[1],t[2])

		if not Random2(0,2)
			x = x1 : y = y1
			if x1 <= buffer then x = RightEdge
			if y1 <= buffer then y = BottomEdge
			if x1 >= RightEdge then x = buffer
			if y1 >= MapHeight then y = buffer
			CannonFire( x,y,x1,y1,336,240 )
			SetSpriteVisible( MechGuy[1].bodyID,Off )
			BlowItUp( 0,MechGuy )

			x1 = MiddleX
			y1 = MiddleY-((GetSpriteWidth(OpenIris))/2)+NodeOffset
			SetSpritePositionByOffset( MechGuy[0].bodyID,x1,y1 )
			SetSpritePositionByOffset( MechGuy[0].turretID,x1,y1 )
			SetSpritePositionByOffset( MechGuy[1].bodyID,x1+shadowOffset,y1+shadowOffset )
			SetSpriteVisible( MechGuy[0].bodyID,On )
			SetSpriteVisible( MechGuy[0].turretID,On )

			colors = CreateTweenSprite( 2 )
			SetTweenSpriteRed( colors,0,255,TweenLinear() )
			SetTweenSpriteGreen( colors,0,32,TweenLinear() )
			SetTweenSpriteBlue( colors,0,16,TweenLinear() )
			grow = CreateTweenSprite( 3 )
			SetTweenSpriteSizeX( grow,1,buffer,TweenEaseOut1() )
			SetTweenSpriteSizeY( grow,1,buffer,TweenEaseOut1() )

			PlaySprite( OpenIris,28,0 )
			SetSpriteVisible( IrisGlow,On )
			PlayTweenSprite( colors,IrisGlow,0 )
			PlayTweenSprite( grow,MechGuy[0].bodyID,0 )
			PlayTweenSprite( grow,MechGuy[0].turretID,0 )
			PlaySound( SpawnSound,vol )
			rampUp = True
			while GetSpritePlaying( OpenIris )
				if (GetSpriteCurrentFrame( OpenIris ) >= 50) and rampUp
					StopTweenSprite( colors,IrisGlow )
					SetTweenSpriteRed( colors,255,0,TweenLinear() )
					SetTweenSpriteGreen( colors,32,0,TweenLinear() )
					SetTweenSpriteBlue( colors,16,0,TweenLinear() )
					PlayTweenSprite( colors,IrisGlow,0 )
					rampUp = False
				endif
				UpdateAllTweens(getframetime())
				Sync()
			endwhile
			SetSpriteVisible( IrisGlow,Off )
			SetSpriteVisible( MechGuy[1].bodyID,On )
		endif

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
	t[0] = SetTween(x1,y1,x2,y2,b#,tankArc#,  MechGuy[0].bodyID,  TweenLinear(),MechGuy[0].speed)
	t[1] = SetTween(x1,y1,x2,y2,t#,turretArc#,MechGuy[0].turretID,TweenLinear(),MechGuy[0].speed)
	t[2] = SetTween(x1+shadowOffset,y1+shadowOffset,x2+shadowOffset,y2+shadowOffset,b#,tankArc#,MechGuy[1].bodyID,TweenLinear(),MechGuy[1].speed)

	PlaySprite( MechGuy[0].bodyID,20,0 )
	PlaySprite( MechGuy[1].bodyID,20,0 )
	MechGuy[0].x = x2 : MechGuy[1].x = x2+shadowOffset
	MechGuy[0].y = y2 : MechGuy[1].y = y2+shadowOffset
endfunction t

function AlertDialog( text,state,x,y,w,h )
	If state = Off
		//~ PlaySound( ClickSound,vol )
		DeleteText( text )
		DeleteSprite( AlertBackGround )
	else
		SetTextVisible( text,state )
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
	//~ for i = 1 to SpriteConUnits
		//~ SetSpriteActive( SpriteCon[i].ID,state )
		//~ SetSpriteVisible( SpriteCon[i].ID,state )
	//~ next i
	if state
		Text(MusicText,"Music",MusicScale.tx,MusicScale.ty,0,0,0,30,255,0,Off)
		SetTextDepth(MusicText,1)
		Text(SoundText,"Sound",SoundScale.tx,SoundScale.ty,0,0,0,30,255,0,Off)
		SetTextDepth(SoundText,1)
		Text(ProdUnitText,"Production Units/Base",MusicScale.x,Button5.y-(dev.buttSize*1.1),0,0,0,30,255,0,Off)
		SetTextDepth(ProdUnitText,1)
		Text(ONOFFText,"Random Events",ONOFF.tx,ONOFF.ty,0,0,0,30,255,0,Off)
		SetTextDepth(ONOFFText,1)
	else
		DeleteText(MusicText)
		DeleteText(SoundText)
		DeleteText(ProdUnitText)
		DeleteText(ONOFFText)
	endif
endfunction

function DisplaySettings(state)
	FlipState = not state
	//~ SetTextColorAlpha( VersionText,FlipState*255 )
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

	SetSpriteActive( OpenIris,FlipState )
	SetSpriteVisible( OpenIris,FlipState )
	SetSpriteActive( IrisGlow,FlipState )
	SetSpriteVisible( IrisGlow,FlipState )

	SetSpriteVisible( MechGuy[0].bodyID,FlipState )
	SetSpriteVisible( MechGuy[0].turretID,FlipState )
	SetSpriteVisible( MechGuy[1].bodyID,FlipState )

	SetVirtualButtonVisible( StatButt.ID,FlipState )
	SetVirtualButtonVisible( settingsButt.ID,FlipState )
	SetVirtualButtonVisible( cancelButt.ID,FlipState )
	SetVirtualButtonVisible( mapButt.ID,state )
	SetVirtualButtonActive( StatButt.ID,FlipState )
	SetVirtualButtonActive( settingsButt.ID,FlipState )
	SetVirtualButtonActive( cancelButt.ID,FlipState )
	SetVirtualButtonActive( mapButt.ID,state )

	SetVirtualButtonVisible( Button5.ID,state )
	SetVirtualButtonVisible( Button10.ID,state )
	SetVirtualButtonVisible( Button15.ID,state )
	SetVirtualButtonVisible( Button20.ID,state )
	SetVirtualButtonVisible( Button25.ID,state )

	SetVirtualButtonActive( Button5.ID,state )
	SetVirtualButtonActive( Button10.ID,state )
	SetVirtualButtonActive( Button15.ID,state )
	SetVirtualButtonActive( Button20.ID,state )
	SetVirtualButtonActive( Button25.ID,state )

	SetVirtualButtonVisible( ONOFF.ID,state )
	SetVirtualButtonActive( ONOFF.ID,state )

	SetProductionButtons(BaseProdValue)
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

	SetVirtualButtonVisible( mapButt.ID,state )
	SetVirtualButtonVisible( diceButt.ID, not state )
	SetVirtualButtonVisible( diskButt.ID, not state )
	SetVirtualButtonVisible( ImpassButt.ID, not state )
	SetVirtualButtonVisible( WaterButt.ID, not state )

	SetVirtualButtonActive( mapButt.ID,state )
	SetVirtualButtonActive( diceButt.ID, not state )
	SetVirtualButtonActive( diskButt.ID, not state )
	SetVirtualButtonActive( ImpassButt.ID, not state )
	SetVirtualButtonActive( WaterButt.ID, not state )

	SetVirtualButtonVisible( Button5.ID,state )
	SetVirtualButtonVisible( Button10.ID,state )
	SetVirtualButtonVisible( Button15.ID,state )
	SetVirtualButtonVisible( Button20.ID,state )
	SetVirtualButtonVisible( Button25.ID,state )

	SetVirtualButtonActive( Button5.ID,state )
	SetVirtualButtonActive( Button10.ID,state )
	SetVirtualButtonActive( Button15.ID,state )
	SetVirtualButtonActive( Button20.ID,state )
	SetVirtualButtonActive( Button25.ID,state )

	SetVirtualButtonVisible( ONOFF.ID,state )
	SetVirtualButtonActive( ONOFF.ID,state )

	SetProductionButtons(BaseProdValue)
	CreateGrid(state)
endfunction

function SettingsDialog()
	t as integer[SpriteConUnits]
	x = MiddleX-((SpriteConSize-25)/2)
	DisplaySettings( On )
	StopMusicOGG( MusicSound )
	for i = 1 to SpriteConUnits	`enter one at a time
		PlaySound( EnterSound,vol )
		t[i] = CreateTweenSprite( .1 )
		SetTweenSpriteY( t[i], MaxHeight, (i*(SpriteConSize-10))-30, TweenEaseOut2() )
		PlayTweenSprite( t[i], SpriteCon[i].ID, .05 )
		SetSpriteActive( SpriteCon[i].ID, On )
		SetSpriteVisible( SpriteCon[i].ID, On )
		SetSpritePosition( SpriteCon[i].ID, x, MaxHeight )
		PlayTweens( t[i], SpriteCon[i].ID )
	next i
	repeat
		Compose()
	until ForcesReady()
	PlaySound( ClickSound,vol )
	PlayMusicOGG( MusicSound, 1 )
	SpriteConState( Off )
	DisplaySettings( Off )
endfunction

function SpriteConState( state )
	for i = 1 to SpriteConUnits
		SetSpriteActive( SpriteCon[i].ID,state )
		SetSpriteVisible( SpriteCon[i].ID,state )
	next i
endfunction

function ChangeColor( grid as gridType[], c as ColorSpec )
	for i = 0 to Cells-1
		if GetSpriteExists( grid[i].ID ) then SetSpriteColor( grid[i].ID, c.r, c.g, c.b, c.a  )
	next i
endfunction

function SliderInput( Slide ref as sliderType, Scale as sliderType )
	ScaleMax = Scale.x + Scale.w - Slide.w
	SetRawMouseVisible( Off )
	while GetPointerState()
		Slide.x = MinMax( Scale.x,ScaleMax,GetPointerX()-SliderOffset )
		SetSpriteX( Slide.ID,Slide.x )
		Sync()
	endwhile
	SetRawMouseVisible( On )
	x# = Slide.X - Scale.x
	select Slide.ID
		case SoundSlide.ID,MusicSlide.ID : x# = (x#/Scale.w)*100 : endcase
	endselect
endfunction x#

function Compose()
	repeat
		if GetPointerState()
			x = GetPointerX()
			y = GetPointery()
			hit = GetSpriteHit(x,y)
			select hit
				case SpriteCon[1].ID,SpriteCon[2].ID,SpriteCon[3].ID,SpriteCon[4].ID,SpriteCon[5].ID,SpriteCon[6].ID,SpriteCon[7].ID
					ShowUnitStats(hit-SpriteConSeries,True,MiddleY+250,30,dev.textSize)
					SetRawMouseVisible( Off )
					clone = CloneSprite( hit )
					while GetPointerState()
						SetSpritePositionByOffset( clone,GetPointerX(),GetPointerY() )
						Sync()
					endwhile
					ShowUnitStats( Null,Null,Null,Null,Null )
					SetSpriteSize( clone,SpriteConSize,SpriteConSize )

					for i = 1 to 7
						if hit = SpriteCon[i].ID  `identify vehicle type
							GridCheck( clone,i ) : exit
						endif
					next i
								SetRawMouseVisible( On )
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
					vol = SliderInput(SoundSlide,SoundScale)
					SoundVolume()
				endcase
				case MusicSlide.ID
					m = SliderInput(MusicSlide,MusicScale)
					SetMusicVolumeOGG(MusicSound,m)
				endcase
				case AIGrid[0].ID,AIGrid[1].ID,AIGrid[2].ID,AIGrid[3].ID,AIGrid[4].ID,AIGrid[5].ID,AIGrid[6].ID,AIGrid[7].ID `removes existing SpriteCons
					RemoveSpriteCon( hit,x,y )
				endcase
				case PlayerGrid[0].ID,PlayerGrid[1].ID,PlayerGrid[2].ID,PlayerGrid[3].ID,PlayerGrid[4].ID,PlayerGrid[5].ID,PlayerGrid[6].ID,PlayerGrid[7].ID
					RemoveSpriteCon( hit,x,y )
				endcase
			endselect
		endif

		if GetVirtualButtonReleased(Button5.ID)
			SetProductionButtons(5)
		elseif GetVirtualButtonReleased(Button10.ID)
			SetProductionButtons(10)
		elseif GetVirtualButtonReleased(Button15.ID)
			SetProductionButtons(15)
		elseif GetVirtualButtonReleased(Button20.ID)
			SetProductionButtons(20)
		elseif GetVirtualButtonReleased(Button25.ID)
			SetProductionButtons(25)
		elseif GetVirtualButtonReleased(ONOFF.ID)
			PlaySound(ClickSound,vol)
			if Events
				Events = Off
				SetVirtualButtonImageUp(ONOFF.ID,ONOFF.UP)
			else
				Events = On
				SetVirtualButtonImageUp(ONOFF.ID,ONOFF.DN)
			endif
		endif

		Sync()
		if GetRawKeyPressed( Enter ) then exitfunction

		`Map Generation
		if GetVirtualButtonReleased( mapButt.ID ) or GetRawKeyPressed( 0x4D ) `M

			ReDisplaySettings( Off )
			SpriteConState( Off )
			StopMusicOGG( MusicSound )
			PlaySound( ClickSound,vol )
			if mapImpass then SetVirtualButtonImageUp(ImpassButt.ID,ImpassButt.DN) else SetVirtualButtonImageUp(ImpassButt.ID,ImpassButt.UP)
			if mapWater	 then SetVirtualButtonImageUp(WaterButt.ID,WaterButt.DN) else SetVirtualButtonImageUp(WaterButt.ID,WaterButt.UP)

			do
				if GetPointerState()
					x = GetPointerX()
					y = GetPointery()
					slideHit = GetSpriteHitGroup(SliderGroup,x,y)
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

				if GetVirtualButtonReleased( ImpassButt.ID )
					PlaySound( ClickSound,vol )
					if mapImpass
						mapImpass=0 : SetVirtualButtonImageUp( ImpassButt.ID,ImpassButt.UP )
					else
						mapImpass=ImpassOn : SetVirtualButtonImageUp( ImpassButt.ID,ImpassButt.DN )
					endif
				endif
				if GetVirtualButtonReleased( WaterButt.ID )
					PlaySound( ClickSound,vol )
					if mapWater
						mapWater=0 : SetVirtualButtonImageUp( WaterButt.ID,WaterButt.UP )
					else
						mapWater=WaterOn : SetVirtualButtonImageUp( WaterButt.ID,WaterButt.DN )
					endif
				endif
				if GetVirtualButtonReleased( diskButt.ID ) or GetRawKeyPressed( 0x46 ) then MapSlotDialog() `F
				if GetVirtualButtonReleased( diceButt.ID ) or GetRawKeyPressed( 0x52 ) `R
					PlaySound( ClickSound,vol )
					ResetMap()
					GenerateTerrain()
				endif
				if GetVirtualButtonReleased( acceptButt.ID ) or GetRawKeyPressed( Enter )
					PlaySound( ClickSound,vol )
					exit
				endif

			loop

			ReDisplaySettings( On )
			SpriteConState( On )
		endif

	until GetVirtualButtonPressed( acceptButt.ID )
	WaitForButtonRelease( acceptButt.ID )
endfunction

function SetProductionButtons( Units )
	PlaySound( ClickSound,vol )
	SetVirtualButtonImageUp( Button5.ID,Button5.UP )
	SetVirtualButtonImageUp( Button10.ID,Button10.UP )
	SetVirtualButtonImageUp( Button15.ID,Button15.UP )
	SetVirtualButtonImageUp( Button20.ID,Button20.UP )
	SetVirtualButtonImageUp( Button25.ID,Button25.UP )
	BaseProdValue = Units
	select BaseProdValue
		case 5  : SetVirtualButtonImageUp( Button5.ID,Button5.DN ) : endcase
		case 10 : SetVirtualButtonImageUp( Button10.ID,Button10.DN ) : endcase
		case 15 : SetVirtualButtonImageUp( Button15.ID,Button15.DN ) : endcase
		case 20 : SetVirtualButtonImageUp( Button20.ID,Button20.DN ) : endcase
		case 25 : SetVirtualButtonImageUp( Button25.ID,Button25.DN ) : endcase
	endselect
endfunction

function MapSlotDialog()
	PlaySound( ClickSound,vol )
	map$ = ""
	TSize = (32*dev.scale)
	Text( MapText,"Map Save Slots",mapSlotDialog.x+20,mapSlotDialog.y+20,50,50,50,TSize,255,0,Off )
	SetVirtualButtonPosition( cancelButt.ID,mapSlotDialog.cancel.x,mapSlotDialog.cancel.y )
	ButtonState( cancelButt.ID,On )
	AlertDialog( MapText,On,mapSlotDialog.x,mapSlotDialog.y,mapSlotDialog.w,mapSlotDialog.h )
	MapSLOTButtons( On )

	for i = 1 to 4
		m$ = "map"+str(i)
		if GetFileExists( m$ )
			select m$
				case "map1" : SetVirtualButtonAlpha( SLOT1.ID,FullAlpha ) : endcase
				case "map2" : SetVirtualButtonAlpha( SLOT2.ID,FullAlpha ) : endcase
				case "map3" : SetVirtualButtonAlpha( SLOT3.ID,FullAlpha ) : endcase
				case "map4" : SetVirtualButtonAlpha( SLOT4.ID,FullAlpha ) : endcase
			endselect
		else
			select m$
				case "map1" : SetVirtualButtonAlpha( SLOT1.ID,HalfAlpha ) : endcase
				case "map2" : SetVirtualButtonAlpha( SLOT2.ID,HalfAlpha ) : endcase
				case "map3" : SetVirtualButtonAlpha( SLOT3.ID,HalfAlpha ) : endcase
				case "map4" : SetVirtualButtonAlpha( SLOT4.ID,HalfAlpha ) : endcase
			endselect
		endif
	next i
	do
		Sync()
		if GetVirtualButtonReleased( SLOT1.ID ) then map$ = "map1"
		if GetVirtualButtonReleased( SLOT2.ID ) then map$ = "map2"
		if GetVirtualButtonReleased( SLOT3.ID ) then map$ = "map3"
		if GetVirtualButtonReleased( SLOT4.ID ) then map$ = "map4"
		if map$ <> ""
			SetVirtualButtonVisible( SLOT1.ID,Off )
			SetVirtualButtonVisible( SLOT2.ID,Off )
			SetVirtualButtonVisible( SLOT3.ID,Off )
			SetVirtualButtonVisible( SLOT4.ID,Off )
			LoadSaveDialog( map$ )
			exit
		endif
		if GetVirtualButtonReleased( cancelButt.ID )
			PlaySound( ClickSound,vol )
			exit
		endif
	loop
	//~ PlaySound( ClickSound,vol )
	AlertDialog( MapText,Off,mapSlotDialog.x,mapSlotDialog.y,mapSlotDialog.w,mapSlotDialog.h )
	MapSLOTButtons( Off )
	ButtonState( cancelButt.ID,Off )
	SetVirtualButtonPosition( cancelButt.ID,cancelButt.x,cancelButt.y )
endfunction

function LoadSaveDialog( map$ )
	PlaySound( ClickSound,vol )
	TSize = (32*dev.scale)
	Text( MapText,"Map Save Slots",alertDialog.x+(TSize*.85),alertDialog.y+(TSize*.6),50,50,50,TSize,255,0,Off )
	SetVirtualButtonPosition( cancelButt.ID,mapSaveDialog.cancel.x,mapSaveDialog.cancel.y )
	AlertDialog( MapText,On,alertDialog.x,alertDialog.y,alertDialog.w,alertDialog.h )
	MapLoadSaveButtons( On )
	if GetFileExists( map$ )
		SetVirtualButtonActive( LOADBUTT.ID,On )
		SetVirtualButtonAlpha( LOADBUTT.ID,255 )
	else
		SetVirtualButtonActive( LOADBUTT.ID,Off )
		SetVirtualButtonAlpha( LOADBUTT.ID,128 )
	endif
	do
		Sync()
		if GetVirtualButtonReleased( cancelButt.ID )
			PlaySound( ClickSound,vol )
			exit
		elseif GetVirtualButtonReleased( LOADBUTT.ID )
			LoadMap( map$ )
			exit
		elseif GetVirtualButtonReleased( SAVEBUTT.ID )
			if SaveMap( map$ ) then exit
		endif
	loop
	MapLoadSaveButtons( Off )
	AlertDialog( MapText,Off,alertDialog.x,alertDialog.y,alertDialog.w,alertDialog.h )
	ButtonState( cancelButt.ID,Off )
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
				case Trees      : DrawTerrain( node,TreeSprite,treeDummy ) : endcase
				case Rough		: DrawTerrain( node,RoughSprite,RoughDummy ) : endcase
				case Impassable : DrawTerrain( node,Impass,impassDummy ) : endcase
				case Water		: DrawTerrain( node,AcquaSprite,waterDummy ) : endcase
			endselect
		endif
	next i
	`SETTINGS
	LoadForce( MapFile )
	BaseProdValue = ReadInteger( MapFile )
	SetProductionButtons(BaseProdValue)
			Events = ReadInteger( MapFile )
			if Events then SetVirtualButtonImageUp( ONOFF.ID,ONOFF.DN ) else SetVirtualButtonImageUp( ONOFF.ID,ONOFF.UP )

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
		SetVirtualButtonVisible( LOADBUTT.ID,Off )
		SetVirtualButtonVisible( SAVEBUTT.ID,Off )
		SetTextColorAlpha( MapText,0 )	`turns the text off; SetTextVisible() doesn't work
		if Confirm("Overwrite?",ConfirmText)
			SetVirtualButtonActive( LOADBUTT.ID,On )
			SetVirtualButtonAlpha( LOADBUTT.ID,255 )
		else
			SetVirtualButtonSize( alertDialog.cancel.ID,alertDialog.cancel.w )
			SetVirtualButtonPosition( alertDialog.cancel.ID,alertDialog.cancel.x,alertDialog.cancel.y )
			SetTextColorAlpha( MapText,FullAlpha )
			AlertDialog( MapText,On,alertDialog.x,alertDialog.y,alertDialog.w,alertDialog.h )
			SetVirtualButtonSize( cancelButt.ID,alertDialog.cancel.w )
			SetVirtualButtonPosition( cancelButt.ID,alertDialog.accept.x,alertDialog.accept.y )
			MapLoadSaveButtons( On )
			exitfunction False
		endif
	endif
	file = OpenToWrite( map$ )
	`save map
	for i = 0 to MapSize-1 : WriteInteger( file, mapTable[i].terrain ) : next i
	`save settings
	WriteInteger( file,pickAI.r ) : WriteInteger( file,pickAI.g ) : WriteInteger( file,pickAI.b ) : WriteInteger( file,pickAI.a )
	WriteInteger( file,pickPL.r ) : WriteInteger( file,pickPL.g ) : WriteInteger( file,pickPL.b ) : WriteInteger( file,pickPL.a )
	for i = 0 to Cells-1 : WriteInteger( file,AIGrid[i].vehicle ) : next i
	for i = 0 to Cells-1 : WriteInteger( file,PlayerGrid[i].vehicle ) : next i
	WriteInteger( file,BaseProdValue )
	WriteInteger( file,Events )
	CloseFile( file )
endfunction True

function Confirm( message$,textID )
	TSize = 36*dev.scale
	Text( textID,message$,alertDialog.x+(TSize*.85),alertDialog.y+(TSize*.6),50,50,50,TSize,255,0,Off )
	AlertDialog( textID,On,alertDialog.x,alertDialog.y,alertDialog.w,alertDialog.h )
	AlertButtons( alertDialog.accept.x,alertDialog.accept.y,alertDialog.cancel.x,alertDialog.cancel.y,alertDialog.accept.w,acceptButt.ID,cancelButt.ID )
	do
		Sync()
		if GetVirtualButtonPressed( acceptButt.ID ) or GetRawKeyState( Enter ) or GetRawKeyPressed( 0x59 ) `Y
			confirmation = True
			WaitForButtonRelease( acceptButt.ID )
			exit
		endif
		if GetVirtualButtonPressed( cancelButt.ID ) or GetRawKeyReleased( 0x4E ) `N
			confirmation = False
			WaitForButtonRelease( cancelButt.ID )
			exit
		endif
	loop
	AlertDialog( textID,Off,alertDialog.x,alertDialog.y,alertDialog.w,alertDialog.h )
	AlertButtons( acceptButt.x,acceptButt.y,cancelButt.x,cancelButt.y,cancelButt.w,acceptButt.ID,cancelButt.ID )
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
	ButtonState( SLOT1.ID,state )
	ButtonState( SLOT2.ID,state )
	ButtonState( SLOT3.ID,state )
	ButtonState( SLOT4.ID,state )
	ButtonState( cancelButt.ID,state )
endfunction

function MapLoadSaveButtons( state )
	ButtonState( LOADBUTT.ID,state )
	ButtonState( SAVEBUTT.ID,state )
	ButtonState( cancelButt.ID,state )
endfunction

function ButtonState( button,state )
	SetVirtualButtonVisible( button,state )
	SetVirtualButtonActive( button,state )
endfunction

function ButtonActivation( state )
	//~ SetVirtualButtonActive(acceptButt.ID,state)
	//~ SetVirtualButtonActive(cancelButt.ID,state)
	SetVirtualButtonActive(LOADBUTT.ID,state)
	SetVirtualButtonActive(SAVEBUTT.ID,state)
	SetVirtualButtonActive(SLOT1.ID,state)
	SetVirtualButtonActive(SLOT2.ID,state)
	SetVirtualButtonActive(SLOT3.ID,state)
	SetVirtualButtonActive(SLOT4.ID,state)
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

	PlayerProdUnits = (PlayerBaseCount+1)*BaseProdValue
	AIProdUnits = (AIBaseCount+1)*BaseProdValue

	SetSpriteVisible( TurnCount,On )
	DeleteText( VersionText )
	DeleteSprite( MechGuy[0].bodyID )
	DeleteSprite( MechGuy[1].bodyID )
	DeleteSprite( MechGuy[0].turretID )
	DeleteSprite( Logo )
	DeleteSprite( OpenIris )
	DeleteSprite( IrisGlow )
	SetSpriteActive( Dialog,Off )
	SetSpriteActive( Splash,Off )
	SetSpriteVisible( Dialog,Off )
	SetSpriteVisible( Splash,Off )
	SetSpriteVisible( field,On )
	for i = 0 to Cells-1
		if GetSpriteExists(AIGrid[i].ID) then DeleteSprite(AIGrid[i].ID)
		if GetSpriteExists(PlayerGrid[i].ID) then DeleteSprite(PlayerGrid[i].ID)
	next i
	SetVirtualButtonVisible( settingsButt.ID,Off )
	SetVirtualButtonActive( settingsButt.ID,Off )
	SetVirtualButtonVisible( StatButt.ID,Off )
	SetVirtualButtonActive( StatButt.ID,Off )
		ButtonActivation(Off)

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

	AlertButtons( alertDialog.accept.x,alertDialog.accept.y,alertDialog.cancel.x,alertDialog.cancel.y,alertDialog.accept.w,alertDialog.accept.ID,alertDialog.cancel.ID )
	LoadButton(CannonButt.ID,CannonButt.UP,CannonButt.DN,"Cannon.png","CannonDown.png",CannonButt.x,CannonButt.y,CannonButt.w,Off)
	LoadButton(HeavyCannonButt.ID,HeavyCannonButt.UP,HeavyCannonButt.DN,"HeavyCannon.png","HeavyCannonDown.png",HeavyCannonButt.x,HeavyCannonButt.y,HeavyCannonButt.w,Off)
	LoadButton(MissileButt.ID,MissileButt.UP,MissileButt.DN,"Rocket.png","RocketDown.png",MissileButt.x,MissileButt.y,MissileButt.w,Off)
	LoadButton(LaserButt.ID,LaserButt.UP,LaserButt.DN,"Laser.png","LaserDown.png",LaserButt.x,LaserButt.y,LaserButt.w,Off)
	LoadButton(HeavyLaserButt.ID,HeavyLaserButt.UP,HeavyLaserButt.DN,"HeavyLaser.png","HeavyLaserDown.png",HeavyLaserButt.x,HeavyLaserButt.y,HeavyLaserButt.w,Off)
	LoadButton(EMPButt.ID,EMPButt.UP,EMPButt.DN,"EMPButton.png","EMPButtonDown.png",EMPButt.x,EMPButt.y,EMPButt.w,Off)
	LoadButton(MineButt.ID,MineButt.UP,MineButt.DN,"MineButton.png","MineButtonDown.png",MineButt.x,MineButt.y,MineButt.w,Off)
	LoadButton(DisruptButt.ID,DisruptButt.UP,DisruptButt.DN,"DisruptorButtonUp.png","DisruptorButtonDown.png",DisruptButt.x,DisruptButt.y,DisruptButt.w,Off)
	LoadButton(BulletButt.ID,BulletButt.DN,BulletButt.DN,"BulletButton.png","BulletButton.png",BulletButt.x,BulletButt.y,BulletButt.w,Off)

	turns = 1
	ShowInfo( On )
endfunction

remstart
		SetTweenSpriteX( t[i], x, x, TweenEaseOut2() )

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
