
function ShowInfo( shown )
	DeleteText( TurnText )
	DeleteText( UnitText )
	SetSpriteVisible( TurnCount,shown )
	SetSpriteVisible( ProductionUnits,shown )
	if shown
		Text(TurnText,str(turns),MiddleX+UnitX+6,MaxHeight-(UnitY/1.5),255,255,255,36,255,2)
		Text(UnitText,str(PlayerProdUnits),MiddleX+UnitX+4,MaxHeight-UnitY-3,255,255,255,36,255,2)
	endif
endfunction

function BaseProduction( node )
	ShowInfo( Off )
	zoomFactor = 1
	SetViewZoom( zoomFactor )
	SetViewOffset( 0,0 )
	SetSpriteActive( BaseDialog,On )
	SetSpriteVisible( BaseDialog,On )
	SetSpriteDepth( BaseDialog, 0 )

	SetVirtualButtonVisible( CannonButton,Off )
	SetVirtualButtonVisible( MissileButton,Off )
	SetVirtualButtonVisible( LaserButton,Off )
	SetVirtualButtonVisible( HeavyLaserButton,Off )
	SetVirtualButtonVisible( HeavyCannonButton,Off )
	SetVirtualButtonVisible( MineButton,Off )
	SetVirtualButtonVisible( EMPButton,Off )
	ButtonStatus( On, AcceptFlipButton, QuitFlipButton )
	ButtonStatus( Off, AcceptButton, QuitButton )
	AlertButtons( YesNoX3a, YesNoY3, YesNoX3b, YesNoY3, dev.buttSize, AcceptFlipButton, QuitFlipButton )

	for i = 1 to SpriteConUnits-1
		SetSpriteActive( SpriteCon[i].ID,On )
		SetSpriteVisible( SpriteCon[i].ID,On )
		SetSpriteSize( SpriteCon[i].ID,SpriteConSize,SpriteConSize )
		SetSpritePosition( SpriteCon[i].ID, AISide+((i-1)*145),row1 )
		SetSpriteColor( SpriteCon[i].ID,128,128,128,255 )
		SetSpriteGroup( SpriteCon[i].ID,SpriteConBaseGroup )
	next i
	Text(ProductionText,"Available Production Units: "+str(PlayerProdUnits),AISide,row1-50,0,0,0,dev.textSize,255,0)
	SetTextBold(ProductionText,On)

	vehicle = Undefined
	lastIndex = Null
	index = Null
	repeat
		if GetPointerState()
			hit = GetSpriteHitGroup( SpriteConBaseGroup,GetPointerX(),GetPointerY() )
			if  hit
				index = hit-SpriteConSeries
				if index <> lastIndex
					PlaySound( ClickSound,vol )
					SetSpriteColor( SpriteCon[lastIndex].ID,128,128,128,255 )
					SetSpriteColor( SpriteCon[index].ID,255,255,255,255 )
					lastIndex = index
					units = PlayerProdUnits-unitCost[index]
					Stats(index,True,MiddleY-100,30,dev.textSize)
					if units < 0
						Text(IllegalText,"Not enough production Units",MaxWidth-AISide,row1-50,0,0,0,dev.textSize,255,2)
						SetTextBold(IllegalText,On)
						SetTextString( ProductionText, "Available Production Units: "+str(PlayerProdUnits) )
						vehicle = Undefined
					else
						SetTextString( ProductionText, "Available Production Units: "+str(units) )
						DeleteText(IllegalText)
						vehicle = index
					endif
					SetTextBold(ProductionText,On)
				endif
			endif
		endif
		Sync()
		accept = GetVirtualButtonPressed( AcceptFlipButton )
		quit = GetVirtualButtonPressed( QuitFlipButton )
	until accept or quit
	DeleteText(IllegalText)
	ID = Undefined
	if accept
		WaitForButtonRelease( AcceptFlipbutton )
		if vehicle = index
			PlayerProdUnits = units
			ID = Spawn( vehicle,node )
			WeaponButtons( ID,PlayerTank[ID].vehicle )
		endif
	else
		WaitForButtonRelease( QuitFlipButton )
	endif

	ButtonStatus( Off, AcceptFlipButton, QuitFlipButton )
	ButtonStatus( On, AcceptButton, QuitButton )
	AlertButtons( YesNoX4a, YesNoY4, YesNoX4b, YesNoY4, dev.buttSize, AcceptButton, QuitButton )
	SetSpriteActive( BaseDialog,Off )
	SetSpriteVisible( BaseDialog,Off )
	for i = 1 to SpriteConUnits-1
		SetSpriteActive( SpriteCon[i].ID,Off )
		SetSpriteVisible( SpriteCon[i].ID,Off )
	next i
	Stats(Null,Null,Null,Null,Null)
	DeleteText( ProductionText )

	Zoom(1,0,0,On,1)
	ShowInfo(On)
endfunction ID

function Markers( state )
	for i = 0 to PlayerLast
		SetSpriteVisible(PlayerTank[i].healthID,state)
		if PlayerTank[i].target <> Undefined
			if GetSpriteVisible(PlayerTank[i].bullsEye)
				SetSpriteVisible(PlayerTank[i].bullsEye,Off)
			else
				SetSpriteVisible(PlayerTank[i].bullsEye,On)
			endif
		endif
	next i
	for i = 0 to AIPlayerLast
		If GetSpriteVisible(AITank[i].healthID) then SetSpriteVisible(AITank[i].healthID,state)
		if AITank[i].target <> Undefined
			if GetSpriteVisible(AITank[i].bullsEye)
				SetSpriteVisible(AITank[i].bullsEye,Off)
			else
				SetSpriteVisible(AITank[i].bullsEye,On)
			endif
		endif
	next i
endfunction

function Spawn( vehicle,node )
	inc PlayerCount
	inc PlayerLast
	inc PlayerSurviving
	ID = PlayerLast
	PlayerTank.length = PlayerCount

	PlayerTank[ID].vehicle = vehicle
	PlayerTank[ID].node = node
	VehicleImage( ID,PlayerTank )

	mapTable[PlayerTank[ID].node].team = PlayerTeam

	PlayerTank[ID].goalNode = PlayerTank[ID].node
	PlayerTank[ID].parentNode.insert(PlayerTank[ID].node)
	PlayerTank[ID].team = PlayerTeam

	PlayerTank[ID].cover = PlayerCoverSeries + PlayerCount
	PlayerTank[ID].bodyID = PlayerTankSeries + PlayerCount
	PlayerTank[ID].turretID = PlayerTurretSeries + PlayerCount
	PlayerTank[ID].bodyImageID = PlayerTank[ID].bodyID
	PlayerTank[ID].turretImageID = PlayerTank[ID].turretID
	PlayerTank[ID].healthID = PlayerHealthSeries + PlayerCount
	PlayerTank[ID].healthBarImageID = PlayerTank[ID].healthID

	PlayerTank[ID].hilite = HiliteSeries + PlayerCount
	LoadImage(PlayerTank[ID].hilite,"hilite45.png")
	CreateSprite( PlayerTank[ID].hilite,PlayerTank[ID].hilite )
	SetSpriteOffset(PlayerTank[ID].hilite, NodeOffset, NodeOffset)
	SetSpriteSize(PlayerTank[ID].hilite, NodeSize, NodeSize)
	SetSpriteTransparency( PlayerTank[ID].hilite, 1 )
	SetSpriteVisible( PlayerTank[ID].hilite, 0 )

	PlayerTank[ID].bullsEye = TargetSeries + PlayerCount
	LoadImage(PlayerTank[ID].bullsEye,"bullsEye.png")
	CreateSprite( PlayerTank[ID].bullsEye,PlayerTank[ID].bullsEye )
	SetSpriteOffset(PlayerTank[ID].bullsEye, NodeOffset, NodeOffset)
	SetSpriteSize(PlayerTank[ID].bullsEye, NodeSize, NodeSize)
	SetSpriteTransparency( PlayerTank[ID].bullsEye, 1 )
	SetSpriteVisible( PlayerTank[ID].bullsEye, 0 )
	SetSpriteDepth( PlayerTank[ID].bullsEye, 0 )

	TankSetup(ID,PlayerTank,pickPL)

	PlayerTank[ID].FOW = FOWseries + PlayerCount
	LoadImage(PlayerTank[ID].FOW,"FOW.png")
	CreateSprite(PlayerTank[ID].FOW,PlayerTank[ID].FOW)
	SetSpriteDepth(PlayerTank[ID].FOW, 11)
	SetSpriteTransparency( PlayerTank[ID].FOW,1 )
	SetSpriteColor( PlayerTank[ID].FOW,255,255,255,35)
	SetSpriteScissor(PlayerTank[ID].FOW,NodeSize,NodeSize,MaxWidth-NodeSize,MaxHeight-(NodeSize*3))
	SetSpriteVisible(PlayerTank[ID].FOW,Off)

	SetSpriteGroup(PlayerTank[ID].bodyID, PlayerTankGroup)
	SetSpriteGroup(PlayerTank[ID].turretID, PlayerTankGroup)
	SetSpriteAngle(PlayerTank[ID].bodyID,90)
	SetSpriteAngle(PlayerTank[ID].turretID,90)
endfunction ID

function Stats(unit,postStats,y,yOffset,textSize)
	if GetTextExists( StatText )
		for j = 0 to UnitTypes+1 : DeleteText(StatText+j) : next j
	endif
	if postStats
		Text(StatText,type$[unit,0],65,y,0,0,0,textSize,255,0)
		SetTextBold(StatText,On)
		Text(StatText+1,cost$[unit,0],65,y+yOffset,0,0,0,textSize,255,0)
		Text(StatText+2,armor$[unit,0],65,y+(yOffset*2),0,0,0,textSize,255,0)
		Text(StatText+3,movement$[unit,0],65,y+(yOffset*3),0,0,0,textSize,255,0)
		Text(StatText+4,weapon$[unit,0],65,y+(yOffset*4),0,0,0,textSize,255,0)
		select unit
			case MediumTank,HeavyTank,Mech
				Text(StatText+5,weapon$[unit,1],65,y+(yOffset*5),0,0,0,textSize,255,0)
			endcase
			case Engineer
				Text(StatText+5,weapon$[unit,1],65,y+(yOffset*5),0,0,0,textSize,255,0)
				Text(StatText+6,weapon$[unit,2],65,y+(yOffset*6),0,0,0,textSize,255,0)
			endcase
		endselect
	endif
endfunction

function WeaponButtons(ID,vehicle)
	DeleteText( NumeralText  )
	DeleteText( NumeralText2 )
	select vehicle
		case Undefined
			SetVirtualButtonVisible( CannonButton, Off )
			SetVirtualButtonActive( CannonButton, Off )
			SetVirtualButtonVisible( LaserButton, Off )
			SetVirtualButtonActive( LaserButton, Off )
			SetVirtualButtonVisible( MissileButton, Off )
			SetVirtualButtonActive( MissileButton, Off )
			SetVirtualButtonVisible( HeavyCannonButton, Off )
			SetVirtualButtonActive( HeavyCannonButton, Off )
			SetVirtualButtonVisible( HeavyLaserButton, Off )
			SetVirtualButtonActive( HeavyLaserButton, Off )
			SetVirtualButtonVisible( MineButton, Off )
			SetVirtualButtonActive( MineButton, Off )
			SetVirtualButtonVisible( EMPButton, Off )
			SetVirtualButtonActive( EMPButton, Off )
			exitfunction
		endcase
		case HeavyTank
			SetVirtualButtonVisible( CannonButton, Off )
			SetVirtualButtonActive( CannonButton, Off )
			SetVirtualButtonVisible( LaserButton, Off )
			SetVirtualButtonActive( LaserButton, Off )
			SetVirtualButtonVisible( MissileButton, Off )
			SetVirtualButtonActive( MissileButton, Off )
			SetVirtualButtonVisible( HeavyCannonButton, On )
			SetVirtualButtonActive( HeavyCannonButton, On )
			SetVirtualButtonPosition( HeavyLaserButton, dev.buttX2, buttY )
			SetVirtualButtonVisible( HeavyLaserButton, On )
			SetVirtualButtonActive( HeavyLaserButton, On )
			SetVirtualButtonImageUp( HeavyCannonButton, heavyCannonImage )
			SetVirtualButtonImageUp( HeavyLaserButton, heavyLaserImage )
			SetVirtualButtonVisible( MineButton, Off )
			SetVirtualButtonActive( MineButton, Off )
			SetVirtualButtonVisible( EMPButton, Off )
			SetVirtualButtonActive( EMPButton, Off )
		endcase
		case MediumTank
			SetVirtualButtonVisible( HeavyCannonButton, Off )
			SetVirtualButtonActive( HeavyCannonButton, Off )
			SetVirtualButtonVisible( HeavyLaserButton, Off )
			SetVirtualButtonActive( HeavyLaserButton, Off )
			SetVirtualButtonVisible( MissileButton, Off )
			SetVirtualButtonActive( MissileButton, Off )
			SetVirtualButtonVisible( CannonButton, On )
			SetVirtualButtonActive( CannonButton, On )
			SetVirtualButtonPosition( LaserButton, dev.buttX2, buttY )
			SetVirtualButtonVisible( LaserButton, On)
			SetVirtualButtonActive( LaserButton, On )
			SetVirtualButtonImageUp( CannonButton, cannonImage )
			SetVirtualButtonImageUp( LaserButton, laserImage )
			SetVirtualButtonVisible( MineButton, Off )
			SetVirtualButtonActive( MineButton, Off )
			SetVirtualButtonVisible( EMPButton, Off )
			SetVirtualButtonActive( EMPButton, Off )
		endcase
		case LightTank
			SetVirtualButtonVisible( HeavyCannonButton, Off )
			SetVirtualButtonActive( HeavyCannonButton, Off )
			SetVirtualButtonVisible( HeavyLaserButton, Off )
			SetVirtualButtonActive( HeavyLaserButton, Off )
			SetVirtualButtonVisible( CannonButton, Off )
			SetVirtualButtonActive( CannonButton, Off )
			SetVirtualButtonVisible( MissileButton, Off )
			SetVirtualButtonActive( MissileButton, Off )
			SetVirtualButtonPosition( LaserButton, dev.buttX1, buttY )
			SetVirtualButtonVisible( LaserButton, On)
			SetVirtualButtonActive( LaserButton, On )
			SetVirtualButtonImageUp( LaserButton, laserImage )
			SetVirtualButtonVisible( MineButton, Off )
			SetVirtualButtonActive( MineButton, Off )
			SetVirtualButtonVisible( EMPButton, Off )
			SetVirtualButtonActive( EMPButton, Off )
		endcase
		case Battery
			SetVirtualButtonVisible( HeavyCannonButton, Off )
			SetVirtualButtonActive( HeavyCannonButton, Off )
			SetVirtualButtonVisible( HeavyLaserButton, Off )
			SetVirtualButtonActive( HeavyLaserButton, Off )
			SetVirtualButtonVisible( CannonButton, Off )
			SetVirtualButtonActive( CannonButton, Off )
			SetVirtualButtonVisible( LaserButton, Off)
			SetVirtualButtonActive( LaserButton, Off )
			SetVirtualButtonVisible( MissileButton, On )
			SetVirtualButtonActive( MissileButton, On )
			SetVirtualButtonImageUp( MissileButton, missileImage )
			SetVirtualButtonVisible( MineButton, Off )
			SetVirtualButtonActive( MineButton, Off )
			SetVirtualButtonVisible( EMPButton, Off )
			SetVirtualButtonActive( EMPButton, Off )
			Text(NumeralText,str(PlayerTank[ID].missiles),NumX,NumY,255,255,255,30,255,0)
		endcase
		case Mech
			SetVirtualButtonVisible( HeavyCannonButton, Off )
			SetVirtualButtonActive( HeavyCannonButton, Off )
			SetVirtualButtonVisible( HeavyLaserButton, On )
			SetVirtualButtonActive( HeavyLaserButton, On )
			SetVirtualButtonVisible( CannonButton, Off )
			SetVirtualButtonActive( CannonButton, Off )
			SetVirtualButtonVisible( LaserButton, Off)
			SetVirtualButtonActive( LaserButton, Off )
			SetVirtualButtonVisible( MissileButton, On )
			SetVirtualButtonActive( MissileButton, On )
			SetVirtualButtonImageUp( MissileButton, missileImage )
			SetVirtualButtonImageUp( HeavyLaserButton, heavyLaserImage )
			SetVirtualButtonVisible( MineButton, Off )
			SetVirtualButtonActive( MineButton, Off )
			SetVirtualButtonVisible( EMPButton, Off )
			SetVirtualButtonActive( EMPButton, Off )
			Text(NumeralText,str(PlayerTank[ID].missiles),NumX,NumY,255,255,255,30,255,0)
		endcase
		case Engineer
			SetVirtualButtonVisible( HeavyCannonButton, Off )
			SetVirtualButtonActive( HeavyCannonButton, Off )
			SetVirtualButtonVisible( HeavyLaserButton, Off )
			SetVirtualButtonActive( HeavyLaserButton, Off )
			SetVirtualButtonVisible( CannonButton, Off )
			SetVirtualButtonActive( CannonButton, Off )
			SetVirtualButtonVisible( LaserButton, Off)
			SetVirtualButtonActive( LaserButton, Off )
			SetVirtualButtonVisible( MissileButton, Off )
			SetVirtualButtonActive( MissileButton, Off )
			SetVirtualButtonVisible( MineButton, On )
			SetVirtualButtonActive( MineButton, On )
			SetVirtualButtonVisible( EMPButton, On )
			SetVirtualButtonActive( EMPButton, On )
			SetVirtualButtonImageUp( MineButton, MineImage )
			SetVirtualButtonImageUp( EMPButton, EMPImage )
			Text(NumeralText,str(PlayerTank[ID].mines),NumX,NumY,255,255,255,30,255,0)
			Text(NumeralText2,str(PlayerTank[ID].charges),NumX1,NumY,255,255,255,30,255,0)
		endcase
	endselect
	select PlayerTank[ID].weapon
		case cannon 	 : SetVirtualButtonImageUp( CannonButton,cannonImageDown ) : endcase
		case heavyCannon : SetVirtualButtonImageUp( HeavyCannonButton,heavyCannonImageDown ) : endcase
		case laser 		 : SetVirtualButtonImageUp( LaserButton,laserImageDown ) : endcase
		case heavyLaser  : SetVirtualButtonImageUp( HeavyLaserButton,heavyLaserImageDown ) : endcase
		case missile
			if PlayerTank[ID].missiles
				SetVirtualButtonImageUp( MissileButton,missileImageDown )
			else
				SetVirtualButtonImageUp( MissileButton,missileImage )
			endif
		endcase
		case mine
			if PlayerTank[ID].mines
				SetVirtualButtonImageUp( MineButton,MineImageDown )
			else
				SetVirtualButtonImageUp( MineButton,MineImage )
			endif
		endcase
		case emp
			if PlayerTank[ID].charges
				SetVirtualButtonImageUp( EMPButton,EMPImageDown )
			else
				SetVirtualButtonImageUp( EMPButton,EMPImage )
			endif
		endcase
		case Undefined : SetVirtualButtonImageUp( MineButton,MineImage ) : SetVirtualButtonImageUp( EMPButton,EMPImage ) : endcase
	endselect
endfunction


function MoveInput(ID,x1,y1)
	lineStart = MakeColor( 255,255,255 )
	lineEnd = MakeColor( 0,100,0 )
	shift = GetViewZoom() * NodeOffset
	SetSpriteVisible(square,On)
	SetRawMouseVisible(Off)
	while GetPointerState()
		px = ScreenToWorldX(GetPointerX())
		py = ScreenToWorldY(GetPointerY())
		if px + py = 0
			px = GetSpriteXByOffset(PlayerTank[ID].bodyImageID)
			py = GetSpriteYByOffset(PlayerTank[ID].bodyImageID)
		endif
		x2 = (px/NodeSize)*NodeSize
		y2 = (py/NodeSize)*NodeSize
		x2 = MinMax(NodeSize,MapWidth,x2)
		y2 = MinMax(NodeSize,MapHeight,y2)

		SetSpritePosition(square,x2,y2)
		DrawLine(x1,y1,WorldToScreenX(x2)+shift,WorldToScreenY(y2)+shift,lineStart,lineEnd)
		Sync()
	endwhile
	SetRawMouseVisible(On)
	node = CalcNode( Floor(x2/NodeSize),Floor(y2/NodeSize) )
endfunction node


function WeaponInput(ID)
	if GetVirtualButtonState(CannonButton) //or GetRawKeyPressed(0x43) `C
		if RangeCheck(ID,cannonRange)
			WeaponSelect(ID,PlayerTank,cannon,cannonRange,cannonDamage)
			WaitForButtonRelease(CannonButton)
		endif
	elseif GetVirtualButtonState(HeavyCannonButton) //or GetRawKeyPressed(0x43) `C
		if RangeCheck(ID,heavyCannonRange)
			WeaponSelect(ID,PlayerTank,heavyCannon,heavyCannonRange,heavyCannonDamage)
			WaitForButtonRelease(HeavyCannonButton)
		endif
	elseif GetVirtualButtonState(MissileButton) //or GetRawKeyPressed(0x4D) `M
		if PlayerTank[ID].missiles > 0
			WeaponSelect(ID,PlayerTank,missile,missileRange,missileDamage)
			WaitForButtonRelease(MissileButton)
		endif
	elseif GetVirtualButtonState(LaserButton) //or GetRawKeyPressed(0x4c) `L
		WeaponSelect(ID,PlayerTank,laser,laserRange,laserDamage)
		WaitForButtonRelease(LaserButton)

	elseif GetVirtualButtonState(HeavyLaserButton) //or GetRawKeyPressed(0x4c) `L
		WeaponSelect(ID,PlayerTank,heavyLaser,heavyLaserRange,heavyLaserDamage)
		WaitForButtonRelease(HeavyLaserButton)

	elseif GetVirtualButtonState(MineButton)
		if PlayerTank[ID].weapon = mine   `toggle
			WeaponSelect(ID,PlayerTank,Undefined,mineRange,mineDamage)
		else
			WeaponSelect(ID,PlayerTank,mine,mineRange,mineDamage)
		endif
		WaitForButtonRelease(MineButton)

	elseif GetVirtualButtonState(EMPButton)
		if PlayerTank[ID].weapon = emp   `toggle
			WeaponSelect(ID,PlayerTank,Undefined,empRange,empDamage)
		else
			WeaponSelect(ID,PlayerTank,emp,empRange,empDamage)
		endif
		WaitForButtonRelease(EMPButton)
	endif
endfunction

function RangeCheck(ID,range)
	if PlayerTank[ID].target <> Undefined
		if VectorDistance(PlayerTank[ID].x,PlayerTank[ID].y, AITank[PlayerTank[ID].target].x,AITank[PlayerTank[ID].target].y) > range
			DisplayError(OutofRangeText,"out of range")
			exitfunction False
		endif
	endif
endfunction True

function CancelFire(ID)
	PlaySound( ClickSound,vol )
	SetSpriteVisible(PlayerTank[ID].bullsEye,Off)
	DeleteSprite( PlayerTank[ID].line )
	PlayerTank[ID].target = Undefined
endfunction

function CancelMove( ID,Tank ref as tankType[] )
	SetSpriteVisible(square,Off)
	SetSpriteVisible(Tank[ID].hilite,Off)
	Tank[ID].goalNode = Tank[ID].parentNode[Tank[ID].index]
	ResetPath(ID,Tank)
	AStar(ID,Tank)
	MaxAlpha(ID)
	if Tank[ID].moveTarget then mapTable[Tank[ID].moveTarget].moveTarget = False
endfunction

function BadMove()
	PlaySound( ErrorSound,vol )
	DisplayError( OutofRangeText,"out of reach" )
endfunction

function GetInput()
	selection = Undefined
    alpha = Brightest
    glow = Brighter
	WeaponButtons( Null,Undefined )
	ID as integer

	do
		if selection <> Undefined then WeaponInput(ID)
		if GetVirtualButtonState(AcceptButton) or GetRawKeyState(Enter)
			PlaySound( ClickSound,vol )
			MaxAlpha(ID)
			exit
		elseif GetVirtualButtonState(QuitButton) or GetRawKeyState(0x51) `Q
			Zoom(1,0,0,On,1)
			if GetVirtualButtonState(QuitButton) then WaitForButtonRelease(QuitButton)
			PlaySound( ClickSound,vol )
			EndGame()
		elseif GetPointerState()
			x = MinMax(0,MaxWidth-1,ScreenToWorldX(GetPointerX()))	`MinMax, temporary fix for out of bounds erros
			y = MinMax(0,MaxHeight-1,ScreenToWorldY(GetPointerY()))
				pointerNode = CalcNode( floor(x/NodeSize),floor(y/NodeSize) )

			baseID = GetSpriteHitGroup( BaseGroup,x,y )
			if GetSpriteHitGroup( PlayerTankGroup,x,y )
				for i = 0 to PlayerLast
					if GetSpriteHitTest( PlayerTank[i].bodyID,x,y )
						if selection = i
							PlaySound( ClickSound,vol )
							CancelMove( ID,PlayerTank )
							selection = Undefined
							WeaponButtons(Null,Undefined)
							SetSpriteVisible(PlayerTank[i].FOW,Off)

						elseif PlayerTank[i].stunned
							continue
						else
							MaxAlpha(ID)
							SetSpriteVisible(PlayerTank[ID].FOW,Off)

							ID = i
							selection = i
							WeaponButtons( ID,PlayerTank[ID].vehicle )

							SetSpriteVisible(PlayerTank[ID].FOW,On)
						endif
						WaitForPointerRelease()
						exit
					endif
				next i
			elseif baseID and (selection = Undefined) and ( mapTable[pointerNode].moveTarget = False )
				Markers(Off)
				selection = BaseProduction( pointerNode )
				if selection <> Undefined
					ID = selection
					WeaponButtons( ID,PlayerTank[ID].vehicle )
					Produce( ID,PlayerTank,1,1,baseID,pickPL )
				else
					WeaponButtons( Null,Undefined )
				endif
				Markers(On)
			elseif selection <> Undefined
				if y < ( MapHeight+NodeSize ) `stay within map height
					TankAlpha(PlayerTank[ID].bodyID,PlayerTank[ID].turretID,Brightest)

					node = MoveInput(ID,WorldToScreenX(PlayerTank[ID].x),WorldToScreenY(PlayerTank[ID].y))

					if mapTable[node].team <> Unoccupied
						if (PlayerTank[ID].target = Undefined) and (mapTable[node].team = AITeam) and (PlayerTank[ID].vehicle <> Engineer)
							PlayerAim(ID,PlayerTank[ID].x,PlayerTank[ID].y)
						else
							CancelFire(ID)
						endif
						SetSpriteVisible(square,Off)
					elseif mapTable[node].moveTarget
						BadMove()
						CancelMove( ID,PlayerTank )

					elseif mapTable[node].terrain <> Impassable
						PlayerTank[ID].goalNode = node
						ResetPath(ID,PlayerTank)
						if AStar(ID,PlayerTank) > InReach     `node out of range
							BadMove()
							CancelMove( ID,PlayerTank )
						else
							PlaySound(orders[Randomize(0,OrderSounds)])

							if PlayerTank[ID].moveTarget then mapTable[PlayerTank[ID].moveTarget].moveTarget = False  `clear previous target
							mapTable[node].moveTarget = True
							PlaySound( ClickSound,vol )
							SetSpriteVisible(square,Off)
							SetSpriteVisible(PlayerTank[ID].hilite,On)
							SetSpriteColor(PlayerTank[ID].hilite,255,255,255,255 )
							SetSpritePositionByOffset( PlayerTank[ID].hilite, mapTable[PlayerTank[ID].goalNode].x, mapTable[PlayerTank[ID].goalNode].y )
							MaxAlpha(ID)
							selection = Undefined
							WeaponButtons( Null,Undefined )
							PlayerTank[ID].moveTarget = node  `record last target
											SetSpriteVisible(PlayerTank[ID].FOW,Off)
						endif
					else
						BadMove()
						SetSpriteVisible(square,Off)
					endif
					Sync()
				endif
			endif
		endif

		select dev.device
			case "windows","mac"
				MouseScroll()
				if selection = Undefined then PressToZoom()
			endcase
			case "ios","android" : PinchToZoom() : endcase
		endselect
		if zoomFactor > 1 then ShowInfo(Off) else ShowInfo(On)
		if selection <> Undefined
			inc alpha,glow
			if alpha > GlowMax
				alpha = GlowMax : glow = Darker
			elseif alpha < GlowMin
				alpha = GlowMin : glow = Brighter
			endif
			SetSpriteColorAlpha( PlayerTank[ID].bodyID,alpha )
			SetSpriteColorAlpha( PlayerTank[ID].turretID,alpha )
			SetSpriteColorAlpha( PlayerTank[ID].hilite,alpha )
			SetSpriteColorAlpha( PlayerTank[ID].bullsEye,alpha )
			SetSpriteColorAlpha( PlayerTank[ID].cover,alpha )
					//~ SetSpriteColorAlpha( PlayerTank[ID].FOW,alpha/10 )
		endif
		Sync()
	loop
	SetSpriteVisible(PlayerTank[ID].FOW,Off)
	//~ SetViewOffset(vx#,vy#)
	Zoom(1,0,0,On,1) `TURN THIS OFF FOR CONTINUOS ZOOM OPERATION
endfunction

function Zoom(z,vx#,vy#,state,scale)
	SetViewZoom(z)
	SetViewOffset(vx#,vy#)
	SetTextVisible(NumeralText,state)
endfunction

function MaxAlpha(ID)
	SetSpriteColorAlpha( PlayerTank[ID].hilite,Brightest )
	SetSpriteColorAlpha( PlayerTank[ID].bullsEye,Brightest )
	SetSpriteColorAlpha( PlayerTank[ID].cover,CoverAlpha )
	TankAlpha(PlayerTank[ID].bodyID,PlayerTank[ID].turretID,GlowMax)
endfunction

function EndGame()
	startOver = False
	Zoom(1,0,0,On,1)
	TSize = 36*dev.scale
	Text( QuitText,"Back to Menu?",YesNoX1+TSize,YesNoY1+TSize,50,50,50,TSize,255,0 )
	ButtonStatus( On, AcceptFlipButton, QuitFlipButton )
	AlertButtons( YesNoX2a, YesNoY2, YesNoX2b, YesNoY2, dev.buttSize, AcceptFlipButton, QuitFlipButton )
	AlertDialog( QuitText,On )
	repeat
		if GetVirtualButtonPressed( AcceptFlipButton )
			WaitForButtonRelease( AcceptFlipButton )
			startOver = True : exit
		endif
		if GetRawKeyPressed( Enter )
			startOver = True : exit
		endif
		if GetRawKeyPressed( 0x59 ) `Y
			startOver = True : exit
		endif
		Sync()
	until GetVirtualButtonState( QuitFlipButton ) or GetRawKeyPressed( 0x4E ) `N
	if startOver then Main() `RESTART ACHILLES

	ButtonStatus( Off, AcceptFlipButton, QuitFlipButton )
	AlertDialog( QuitText,Off )
endfunction

function TargetLine(x1, y1, x2, y2, thickness, Tank ref as tankType[],ID)
	Tank[ID].line = createSprite(0)
	setSpriteColor(Tank[ID].line, 255,255,255,255)
    length = sqrt(Pow((x1-x2),2) + Pow((y1-y2),2))
    setSpriteSize(Tank[ID].line, length, thickness)
    setSpriteOffset(Tank[ID].line, 0, thickness/2)
    setSpritePositionByOffset(Tank[ID].line, x1, y1)
    a# = atanfull(x2-x1,y2-y1)-90
    setSpriteAngle(Tank[ID].line,a#)
endfunction

function PlayerAim(ID,x1,y1)
	px = ScreenToWorldX(GetPointerX())
	py = ScreenToWorldY(GetPointerY())
	rx = ((px/NodeSize)*NodeSize) + NodeOffset
	ry = ((py/NodeSize)*NodeSize) + NodeOffset
	node = CalcNode( Floor(px/NodeSize),Floor(py/NodeSize) )

	for i = 0 to AIPlayerLast
		if not AITank[i].alive then continue
		//~ PlayerTank[ID].target = Undefined

		if LOSblocked(x1,y1,rx,ry)
			DisplayError( LOSText,"LOS blocked" )
			exitfunction
		endif
		if (node = AITank[i].parentNode[AITank[i].index])

			if GetSpriteVisible( AITank[i].bodyID ) `VISIBILITY CHECK
				select PlayerTank[ID].weapon
					case cannon,heavyCannon
						if VectorDistance(x1,y1,rx,ry) > PlayerTank[ID].range
							DisplayError(OutofRangeText,"out of range")
							exitfunction
						endif
					endcase
					case missile
						if PlayerTank[ID].missiles <= 0
							DisplayError(OutofAmmoText,"out of ammo")
							exitfunction
						endif
					endcase
				endselect
				PlaySound( ClickSound,vol )
				select Random2(0,2)
					case 1 : PlaySound( TargetSound,vol ) : endcase
					case 2 : PlaySound( LockOnSound,vol ) : endcase
				endselect
				PlayerTank[ID].target = i
				SetRawMouseVisible(Off)
				SetSpritePositionByOffset(PlayerTank[ID].bullsEye,rx,ry)
				SetSpriteVisible(PlayerTank[ID].bullsEye,On)
				TankAlpha(PlayerTank[ID].bodyID,PlayerTank[ID].turretID,GlowMax)
				if GetSpriteExists(PlayerTank[ID].line) then DeleteSprite(PlayerTank[ID].line)
				TargetLine( PlayerTank[ID].x,PlayerTank[ID].y,AITank[PlayerTank[ID].target].x,AITank[PlayerTank[ID].target].y,1,PlayerTank,ID )
				exit
			else
				exitfunction
			endif

		endif
	next i
	SetRawMouseVisible(On)
endfunction

function FirePhase()
	for i = 0 to PlayerLast

		if PlayerTank[i].alive and (not PlayerTank[i].stunned)
			StopSprite(PlayerTank[i].stunMarker )
			SetSpriteVisible( PlayerTank[i].stunMarker, Off )

			select PlayerTank[i].weapon
				case emp
					if PlayerTank[i].charges
						WeaponButtons(i,PlayerTank[i].vehicle)
						Fire( PlayerTank,AITank,i,Null )
					else
						SetVirtualButtonImageUp(EMPButton,EMPImage)
					endif
				endcase
				case mine
					if PlayerTank[i].mines
						WeaponButtons(i,PlayerTank[i].vehicle)
						Fire( PlayerTank,AITank,i,Null )
					else
						SetVirtualButtonImageUp(mineButton,mineImage)
					endif
				endcase
				case default
					if PlayerTank[i].target <> Undefined
						WeaponButtons(i,PlayerTank[i].vehicle)
						SetSpriteVisible( PlayerTank[i].bullsEye,Off )
						DeleteSprite( PlayerTank[i].line )

						TankAlpha(PlayerTank[i].bodyID,PlayerTank[i].turretID,Brightest)

						If AITank[PlayerTank[i].target].alive
							if PlayerTank[i].weapon = missile
								if PlayerTank[i].missiles
									dec PlayerTank[i].missiles
									WeaponButtons(i,PlayerTank[i].vehicle)
									Fire( PlayerTank,AITank,i,PlayerTank[i].target )
								else
									SetVirtualButtonImageUp(missileButton,missileImage)
								endif
							else
								Fire( PlayerTank,AITank,i,PlayerTank[i].target )
							endif
						else
							CancelFire(i)
						endif
					endif
				endcase
			endselect
			TankAlpha(PlayerTank[i].bodyID,PlayerTank[i].turretID,Brightest)
			if GetSpriteVisible( PlayerTank[i].hilite ) then SetSpriteColorAlpha( PlayerTank[i].hilite,Brightest )
		endif
	next i
endfunction

function PlayerOps()
	GetInput()
	FirePhase()
	SetRawMouseVisible(Off)

	for i = 0 to PlayerLast
		if not PlayerTank[i].alive then continue
		if PlayerTank[i].stunned
			dec PlayerTank[i].stunned
			continue
		endif

		WeaponButtons( Null,Undefined )
		do
			if PlayerTank[i].parentNode[PlayerTank[i].index] = PlayerTank[i].goalNode
				SetSpriteVisible(PlayerTank[i].hilite,Off)
				mapTable[nextMove].moveTarget = False : exit
			endif
			if PlayerTank[i].parentNode.length - PlayerTank[i].index
				nextMove = PlayerTank[i].parentNode[PlayerTank[i].index+1]

				if mapTable[nextMove].team then exit

				SetSpriteVisible(PlayerTank[i].healthID,Off)
				Move(i,PlayerTank,PlayerTank[i].parentNode[PlayerTank[i].index],nextMove)
				//~ PlayerFOW(i)
				if MineField( i,PlayerTank ) and (not PlayerTank[i].alive) then exit
			else
				exit
			endif
			Sync()
		loop

		if PlayerTank[i].alive
			HealthBar(i,PlayerTank)
			PlayerTank[i].moves = 0	  `Reset for next turn
			RepairDepot(i,PlayerTank,PlayerDepotNode,PlayerDepot,PlayerTank[i].maximumHealth) `at depot?
			VictoryConditions(i,PlayerTank)
		endif
	next i
endfunction

function TankAlpha( bodyID, turretID, alpha )
	SetSpriteColorAlpha( bodyID, alpha )
	SetSpriteColorAlpha( turretID, alpha )
	Sync()
endfunction

function DisplayError(ID,error$)
	Text(ID,error$,MiddleX,MiddleY,255,255,255,36,255,1)
	PlaySound(ErrorSound,vol)
	Sync()
	Delay(.66)
	DeleteText(ID)
	Sync()
endfunction

remstart

remend

