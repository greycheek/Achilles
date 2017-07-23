

`constants

`general
#constant MaxWidth 1440
#constant MaxHeight 900
SetVirtualResolution( MaxWidth, MaxHeight )
SetWindowTitle( "Achilles" )
SetWindowSize( MaxWidth, MaxHeight, 0 )
SetWindowPosition( 0,0 )
SetOrientationAllowed( 1, 1, 1, 1 )
SetTextDefaultFontImage(LoadImage("GILL.png"))
`nodes
#constant Columns 48
#constant OpenColumns 46
#constant Rows 30
#constant OpenRows 25
#constant NodeSize 30  		`MaxWidth / NodeColumns
#constant NodeOffset 15		`Half of NodeSize
#constant BarWidth 2		`Health Bar
#constant BarHeight 28
#constant MapSize 1440		`Rows * Columns
#constant MapWidth 1380
#constant MapHeight 750
`terrain
#constant Impassable 9
#constant Base 3
#constant Trees 2
#constant Clear 1
`sprites
#constant FieldSeries 1
#constant DummySeries 50
#constant InterfaceSeries 200
`sounds
#constant ErrorSound 1
#constant ClickSound 2
`map
type mapType
	x as integer	`screen coordinates
	y as integer
	nodeX as integer
	nodeY as integer
	team as integer
	terrain as integer
	heuristic as integer
	moveTarget as integer
endtype
global mapTable as mapType[MapSize]
global treeDummy as integer
treeDummy = CreateDummySprite()
SetSpriteCategoryBits(treeDummy,Block)
SetSpritePhysicsOn(treeDummy,1)
MapFile = OpenToRead( "map.txt" )
for i = 0 to MapSize-1
	mapTable[i].nodeX = i-(trunc(i/Columns)*Columns)
	mapTable[i].nodeY = trunc(i/Columns)
	mapTable[i].x = (mapTable[i].nodeX * NodeSize) + NodeOffset
	mapTable[i].y = (mapTable[i].nodeY * NodeSize) + NodeOffset
	//~ mapTable[i].terrain = val(chr(ReadByte( MapFile )))
	//~ mapTable[i].team = Unoccupied
	//~ mapTable[i].moveTarget = False
	//~ if mapTable[i].terrain = Trees
		//~ x = mapTable[i].x-NodeOffset
		//~ y = mapTable[i].y-NodeOffset
		//~ AddSpriteShapeBox(treeDummy,x,y,x+NodeSize-1,y+NodeSize-1,0)
	//~ endif
next i
CloseFile( MapFile )

`interface
#constant TreeButton 1
#constant BaseButton 2
#constant ClearButton 3
#constant BarrierButton 4
#constant WaterButton 5
#constant ExportButton 4
#constant ImportButton 5
global TreeImage as integer
global TreeImageDown as integer
global BaseImage as integer
global BaseImageDown as integer
global ClearImage as integer
global ClearImageDown as integer
global BarrierImage as integer
global BarrierImageDown as integer
global WaterImage as integer
global WaterImagedown as integer
global ExportImage as integer
global ExportImageDown as integer
global ImportImage as integer
global ImportImageDown as integer
TreeImage = InterfaceSeries+1
TreeImageDown = InterfaceSeries+2
BaseImage = InterfaceSeries+3
BaseImageDown = InterfaceSeries+4
ClearImage = InterfaceSeries+5
ClearImageDown = InterfaceSeries+6
BarrierImage = InterfaceSeries+7
BarrierImageDown = InterfaceSeries+8
WaterImage = InterfaceSeries+9
WaterImagedown = InterfaceSeries+10
ExportImage = InterfaceSeries+11
ExportImageDown = InterfaceSeries+12
ImportImage = InterfaceSeries+13
ImportImageDown = InterfaceSeries+14
global buttSize as integer
global buttY as integer
buttSize = 64
buttY = MaxHeight-buttSize

LoadButton(TurnButton,turnImage,turnImageDown,"Button.png","ButtonDown.png",MaxWidth-buttSize+4,buttY,buttSize)
LoadButton(NextButton,nextImage,nextImageDown,"Next.png","NextDown.png",MaxWidth-(buttSize*2)-35,buttY,buttSize)
LoadButton(TargetButton,targetImage,targetImageDown,"TargetButton.png","TargetButtonDown.png",MaxWidth-(buttSize*3)-75,buttY,buttSize)
LoadButton(CannonButton,cannonImage,cannonImageDown,"Cannon.png","CannonDown.png",buttSize-4,buttY,buttSize)
LoadButton(MissileButton,missileImage,missileImageDown,"Rocket.png","RocketDown.png",(buttSize-4)*2.75,buttY,buttSize)
LoadButton(LaserButton,laserImage,laserImageDown,"Laser.png","LaserDown.png",(buttSize-4)*4.5,buttY,buttSize)

global square as integer
square = InterfaceSeries+13
LoadImage(square,"Square.png")
CreateSprite( square,square )
SetSpriteOffset(square, NodeOffset, NodeOffset)
SetSpriteSize(square, NodeSize, NodeSize)
SetSpriteTransparency( square, 1 )
SetSpriteVisible( square, 0 )

`board
field = FieldSeries
LoadImage(field,"Achilles30.png")
CreateSprite(field,field)
SetSpriteDepth ( field, 12 )
SetSpriteSize(field,1440,900)
`sounds
LoadSound(ErrorSound,"EdgeHit.wav")
LoadSound(ClickSound,"buttonclick.wav")


function GetInput()
	do
		for i = 0 to PlayerLast
			if not PlayerTank[i].alive then continue
		    alpha = Brightest
		    glow = Brighter
		 	WeaponButtons(i)
			repeat
				WeaponInput(i)
				if GetRawMouseLeftPressed()
					if GetPointerY() < (MapHeight+NodeSize) `stay within map height
						TankAlpha(PlayerTank[i].bodyID,PlayerTank[i].turretID,Brightest)

						node = MoveInput(i,PlayerTank[i].x,PlayerTank[i].y)

						if mapTable[node].team <> Unoccupied
							if mapTable[node].team = PlayerTeam
								PlaySound(ClickSound)
								SetSpriteVisible(PlayerTank[i].hilite,Off)
								PlayerTank[i].goalNode = PlayerTank[i].parentNode[PlayerTank[i].index]
								ResetPath(i,PlayerTank)
								AStar(i,PlayerTank)
							else
								PlayerAim(i,PlayerTank[i].x,PlayerTank[i].y)
							endif
							SetSpriteVisible(square,Off)
						elseif mapTable[node].moveTarget
							PlaySound(ErrorSound)
							SetSpriteVisible(square,Off)
						elseif mapTable[node].terrain <> Impassable
							PlayerTank[i].goalNode = node
							if PlayerTank[i].moveTarget then mapTable[PlayerTank[i].moveTarget].moveTarget = False  `clear previous target

							mapTable[node].moveTarget = True
							SetSpriteVisible(square,Off)
							SetSpriteVisible(PlayerTank[i].hilite,On)
							SetSpritePositionByOffset(PlayerTank[i].hilite, mapTable[PlayerTank[i].goalNode].x, mapTable[PlayerTank[i].goalNode].y )
							PlayerTank[i].goalNode = node
							ResetPath(i,PlayerTank)
							AStar(i,PlayerTank)
							If PlayerTank[i].totalCost > PlayerTank[i].movesAllowed `goal in range?
								SetSpriteColor( PlayerTank[i].hilite,255,0,0,255 )
							else
								SetSpriteColor( PlayerTank[i].hilite,255,255,255,255 )
							endif
							PlayerTank[i].moveTarget = node	`record last target
						endif
						Sync()
					endif
				endif
				if GetRawKeyPressed(0x1B) or GetVirtualButtonPressed(targetButton) then CancelFire(i) `escape key; cancel firing
				inc alpha,glow
				if alpha > GlowMax
					alpha = GlowMax
					glow = Darker
				elseif alpha < GlowMin
					alpha = GlowMin
					glow = Brighter
				endif
				TankAlpha(PlayerTank[i].bodyID,PlayerTank[i].turretID,alpha)
				if GetSpriteVisible( PlayerTank[i].hilite ) then SetSpriteColorAlpha( PlayerTank[i].hilite,alpha )
				if GetSpriteVisible( PlayerTank[i].bullsEye ) then SetSpriteColorAlpha( PlayerTank[i].bullsEye,alpha )
				if GetSpriteVisible( PlayerTank[i].cover ) then SetSpriteColorAlpha( PlayerTank[i].cover,alpha )

				turnEnd = GetVirtualButtonPressed(TurnButton) or GetRawKeyPressed(Enter)
				nextTank = GetVirtualButtonPressed(NextButton) or GetRawKeyPressed(Space) or GetRawKeyPressed(Tab)
			until turnEnd or nextTank

			PlaySound(ClickSound)
			SetSpriteColorAlpha( PlayerTank[i].hilite,Brightest )
			SetSpriteColorAlpha( PlayerTank[i].bullsEye,Brightest )
			SetSpriteColorAlpha( PlayerTank[i].cover,Brightest )
			TankAlpha(PlayerTank[i].bodyID,PlayerTank[i].turretID,GlowMax)

			if turnEnd then exitfunction
		next i
	loop
endfunction
remstart

remend

