
remstart


AI.AGC
if (NearestPlayer <> Unset) and (AITank[ID].NearestPlayer <> Nearestplayer)
	AITank[ID].NearestPlayer = Nearestplayer
	AITank[ID].goalNode = PlayerTank[NearestPlayer].parentNode[PlayerTank[NearestPlayer].index]
	exitfunction True
elseIf (AITank[ID].parentNode[AITank[ID].index] = AITank[ID].goalNode) or (AITank[ID].route = NoPath)
	Patrol(ID)
	exitfunction True
endif

if AITank[i].parentNode[AITank[i].index] = AITank[i].goalNode
	if not GoalChange(i) then Patrol(i)
	AITank[i].route = PlanMove(i,AITank)
endif

ALLOWS RE-ACQUIRING OF TARGET????
if nextmove = AITank[i].goalNode then AITank[i].NearestPlayer = Unset

`from beginning of AITarget
AITank[i].NearestPlayer = FindEnemy(i)
		
`OLD PATROL
function PlanMove(ID, Tank ref as tankType[])
	DecisionTree(ID,AITank[ID].x,AITank[ID].y,AITank[ID].NearestPlayer)
	ResetPath(ID,AITank)
	AITank[ID].route = AStar(ID,AITank)
endfunction AITank[ID].route

function Patrol(ID)
	v = patrolVectors[Random2(0,7)]		`Random starting vector
	for j = PatrolRadius to 1 step -1	`Linear search
		for i = 0 to 7					`Circular search
			dir = patrolVectors[v+i]	`Advance to next vector
			x = patrolScanX[dir] * j
			y = patrolScanY[dir] * j
			x2 = MinMax(NodeSize,MapWidth +NodeSize,AITank[ID].x + x)
			y2 = MinMAx(NodeSize,MapHeight+NodeSize,AITank[ID].y + y)
			node = CalcNodeFromScreen(x2,y2)
			if (mapTable[node].terrain <> Impassable) // and (mapTable[node].team = Unoccupied)
				AITank[ID].goalNode = node
				exitfunction
			endif
		next i
	next j
endfunction

function TrafficJam(ID)
	for i = 0 to 7
		node = AITank[ID].parentNode[AITank[ID].index] + patrolScan[ i ]
		node = MinMax(1,OpenMapSize,node)
		if (mapTable[node].terrain <> Impassable) and (mapTable[node].team = Unoccupied) //TURN OFF OCCUPY CHECK????
			AITank[ID].goalNode = node
			exitfunction
		endif
	next i
endfunction

function TrafficCop(ID,Tank ref as tankType[])
	node = CalcNodeFromScreen( Tank[ID].x, Tank[ID].y )
	for i = 0 to 7
		adjacentNode = offset[i] + node
		if LegalMove(adjacentNode,Tank[ID].team) then Tank[ID].goalNode = adjacentNode
	next i
endfunction





			If shortestRange <= DepotRange
				AITank[ID].goalNode = goalNode
				exitfunction 		`go to nearest depot
			endif

FindEnemy(i,AITank[i].x,AITank[i].y)
TrafficCop(i,AITank)
Patrol( i )

DecisionTree(i,x1,y1,AITank[i].NearestPlayer)
ResetPath(i,AITank)
AITank[i].route = AStar(i,AITank)

	ORIGINAL FINDENEMY ROUTINE:

	ShortestDistance = Unset
	AITank[i].NearestPlayer = Unset

	for j = 0 to PlayerLast
		if not PlayerTank[j].alive then continue
		xa = x1 - AITank[i].FOWOffset
		ya = y1 - AITank[i].FOWOffset
		xb = x1 + AITank[i].FOWOffset
		yb = y1 + AITank[i].FOWOffset

		if GetSpriteInBox( PlayerTank[j].bodyID,xa,ya,xb,yb )
			//~ if not GetSpriteVisible(AITank[i].bodyID)
				//~ SetSpriteVisible(AITank[i].bodyID,On)
				//~ SetSpriteVisible(AITank[i].turretID,On)
			//~ endif
			vd = VectorDistance(x1,y1,PlayerTank[j].x,PlayerTank[j].y)
			if vd < ShortestDistance
				ShortestDistance = vd
				AITank[i].NearestPlayer = j
			endif
		endif
	next j

	function Patrol(ID)
		AITank[ID].goalNode = AITank[ID].parentNode[AITank[ID].index]
		node = AITank[ID].goalNode
		direction = offset[Random2(0,7)]
		for i = 1 to AITank[ID].movesAllowed
			inc node,direction
			if LegalMove(node,AITank[ID].team) then AITank[ID].goalNode = node else exit
		next i
	endfunction

	function Patrol(ID)
		repeat
			randomColumn = Random2(1,OpenColumns)
			randomRow = Random2(1,OpenRows)
			AITank[ID].goalNode = CalcNode(randomColumn,randomRow)
		until mapTable[AITank[ID].goalNode].terrain <> Impassable
	endfunction

	//LATEST
	function Patrol(ID)
		do
			randomColumn = Random2(1,OpenColumns)
			randomRow = Random2(1,OpenRows)
			AITank[ID].goalNode = CalcNode(randomColumn,randomRow)
			for i = AITank[ID].goalNode to MapSize-1
				if mapTable[AITank[ID].goalNode].terrain <> Impassable then exitfunction
			next i
		loop
	endfunction

		function Patrol(ID)
			currentNode = CalcNodeFromScreen( AITank[ID].x,AITank[ID].y )
			AITank[ID].goalNode = currentNode

			range = PatrolRange * Columns
			startNode = Min(1,currentNode-PatrolRange)
			startNode = Min(1,startNode-range)

			endNode = Max(MapSize,currentNode+PatrolRange)
			endNode = Max(MapSize,endNode+range)

			r = trunc(endNode/Columns) - trunc(startNode/Columns)
			c = mod(endNode,Columns) - mod(startNode,Columns)

			for i = 0 to r-1
				inc startNode,i*Columns

				for j = 0 to c-1
					n = startNode + j
					if mapTable[n].terrain <> Impassable
						AITank[ID].goalNode = n
						exitfunction
					endif
				next j
			next i
		endfunction

	Old Patrol:
	if AITank[ID].y >= bottomRow then AITank[ID].patrolDirection = FirstRow
	if AITank[ID].y <= topRow then AITank[ID].patrolDirection = OpenRows
	AITank[ID].goalNode = CalcNode(floor(AITank[ID].x/NodeSize),AITank[ID].patrolDirection)

	if highWeight < mapTable[Tank[ID].parentNode[i]].heuristic
		highWeight = mapTable[Tank[ID].parentNode[i]].heuristic
		bestPosition = i
		if Randomize(1,10) = 1 then exitfunction bestPosition	`adds random element
	endif



	if c.spect = Undefined  `greyscale
		grey = 255 * c.lumin
		c.r = grey : c.g = grey : c.b = grey
		exitfunction
    endif

	if node1 <> node2	`only if moved

	mapTable[Tank[ID].parentNode[Tank[ID].index  ]].team = Unoccupied
	mapTable[Tank[ID].parentNode[Tank[ID].index+1]].team = Tank[ID].team

	if Tank[ID].team = PlayerTeam
		f1 = SetTween(x1,y1,x2,y2,0,0,Tank[ID].FOW,TweenLinear(),.2)
	else
		ClearSpriteShapes( Tank[ID].FOW )
		AddSpriteShapeCircle( Tank[ID].FOW,x2,y2,Tank[ID].FOWoffset )
	endif

	x1 = AITank[i].x - AITank[i].FOWOffset
	y1 = AITank[i].y - AITank[i].FOWOffset
	x2 = AITank[i].x + AITank[i].FOWOffset
	y2 = AITank[i].y + AITank[i].FOWOffset
	for j = 0 to PlayerLast
		if PlayerTank[j].alive and ( GetSpriteInBox(PlayerTank[j].bodyID, x1,y1,x2,y2) ) then HealthBar(i,AITank)
	next j

	`Decision Order(next move)
	`1 Repair Depot
	`2 Nearest Player Base
	`3 Nearest Player
	`4 Patrol

	AITank[i].goalNode = RandomGoal(i)

	Text(FiringText,"firing",MaxWidth/2,830,64,64,64,26,255,1)

	if AIDepotNode.length <> -1 then RepairDepot(i,AITank,AIDepot,AITank[i].maximumHealth ) `at depot?

	if AITank[i].index <= bestPosition
		AIFOW(i) : Move(i,AITank) : AIFOW(i) : Sync()
	else
		exit
	endif

	if (AIDepotNode.length <> -1) and (AITank[ID].health <= AITank[ID].minimumHealth)  `any depots and unhealthy?
		shortestRange = Unset
		for i = 0 to AIDepotNode.length
			distance = VectorDistance( x1,y1, mapTable[AIDepotNode[i]].x, mapTable[AIDepotNode[i]].y )
			if distance < shortestRange
				shortestRange = distance
				AITank[ID].goalNode = AIDepotNode[i]
			endif
		next i
		If shortestRange < DepotRange then exitfunction `go to nearest depot, already have goal
	endif

	if PlayerTank[NearestPlayer].alive
		if AITank[i].vehicle = HeavyTank
			WeaponSelect(i,AITank,heavyLaser,heavyLaserRange,heavyLaserDamage)
		else
			WeaponSelect(i,AITank,laser,laserRange,laserDamage)
		endif

		if VectorDistance(x1,y1,PlayerTank[NearestPlayer].x,PlayerTank[NearestPlayer].y) <= cannonRange
			if AITank[i].vehicle = HeavyTank
				WeaponSelect(i,AITank,heavyCannon,heavyCannonRange,heavyCannonDamage)
			else
				WeaponSelect(i,AITank,cannon,cannonRange,cannonDamage)
			endif
		elseif AITank[i].missiles and (Randomize(1,10) > 5)
			dec AITank[i].missiles
			WeaponSelect(i,AITank,missile,missileRange,missileDamage)
		endif
		AITank[i].target = NearestPlayer
		Fire( AITank,PlayerTank,i,NearestPlayer )
	else
		AITank[i].target = Undefined
	endif


	function RandomGoal(ID)
		if Randomize(1,10) > 3
			x = mapTable[ AITank[ID].parentNode[AITank[ID].index] ].nodeX + Randomize(-AITank[ID].movesAllowed,AITank[ID].movesAllowed )
			y = mapTable[ AITank[ID].parentNode[AITank[ID].index] ].nodeY + Randomize(-AITank[ID].movesAllowed,AITank[ID].movesAllowed )
			x = MinMax(0,Columns-1,x)
			y = MinMax(0,Rows-1,y)
			g = CalcNode(x,y)
		endif
	endfunction g

	index = hit-SpriteConSeries

	if PlayerDepotNode.length <> -1 then RepairDepot(i,PlayerTank,PlayerDepot,PlayerTank[i].maximumHealth)

	function Hilite(node)
		x = mapTable[node].x-NodeOffset
		y = mapTable[node].y-NodeOffset
		DrawBox( x,y,x+NodeSize,y+NodeSize,0,0,255,255,1 )
	endfunction

	r = (Tank[ID].maximumHealth - Tank[ID].health) * 255
	g = (Tank[ID].health / Tank[ID].maximumHealth) * 255
	#insert  "Setup.agc"

    height# = ceil((BarHeight * Tank[ID].health) * Tank[ID].scale)

		if GetTextExists(1) then DeleteText(1)	` "firing"

		AITank visibility - Initialize and AIFOW

		HEALTH BARS NOT ALWAYS REAPPEARING - Bug in AGK?
		BUG IN WEAPON SWITCHING !!!!!! - target and target line remain on screen
		CAMOUFLAGE NOT ALWAYS GOING AWAY!!!!!!!
		BLOCKED PLAYER TANKS DON'T COMPLETE MOVEMENT?
		Tanks overlapping in squares?

	r = Randomize(0,10)	`chance to miss
	inc r, mapTable[ Defender[defID].parentNode[Defender[defID].index] ].cost+1 `adjust for terrain
	DeleteText(FiringText)
	if r <= 10  `hit?
		Text(HitText,"Hit!",MaxWidth/2,830,64,64,64,26,255,1)

		damage = Attacker[attID].damage*100
		damage = Min(10,Randomize(damage-15,damage+15)) `+/-15%
		dec Defender[defID].health,damage/100.0

		VictoryConditions(defID,Defender)
		HealthBar(defID,Defender)
	else
		Text(HitText,"Miss!",MaxWidth/2,830,64,64,64,26,255,1)
	endif
	Attacker[attID].target = Undefined
	Sync()
	Delay(.25)
	DeleteText(HitText)

	Tank[ID].FOWDummy = CreateDummySprite() `the actual FOW limit
	SetSpritePhysicsOn(Tank[ID].FOWDummy,1)
	x1 = mapTable[Tank[ID].node].x - Tank[ID].FOWOffset
	y1 = mapTable[Tank[ID].node].y - Tank[ID].FOWOffset
	x2 = mapTable[Tank[ID].node].x + Tank[ID].FOWOffset
	y2 = mapTable[Tank[ID].node].y + Tank[ID].FOWOffset
	AddSpriteShapeBox( Tank[ID].FOWDummy,x1,y1,x2,y2,0 )

	Tank[ID].FOWSize = Tank[ID].FOWSize - NodeOffset
	Tank[ID].FOWSize = Tank[ID].FOWSize - NodeOffset
	Tank[ID].FOWOffset = floor( Tank[ID].FOWSize/2 )

	function CalcScreenToNodeXY(xy)		 //screen x or y coordinate
		xy = Floor(xy/NodeSize)
	endfunction xy						 //node x or y coordinate

	PlayerTank[0].node = CalcNode( 7,1 )	`starting node
	PlayerTank[1].node = CalcNode( 10,1 )	`starting node
	PlayerTank[2].node = CalcNode( 13,1 )	`starting node

	AITank[i].node = CalcNode( Randomize(30,45),(i*5)+Randomize(1,5) ) `starting node

	function SetNumeralSprite( spriteID,filename$ )
		LoadImage( spriteID,filename$ )
		CreateSprite( spriteID,spriteID )
		SetSpriteVisible( spriteID,Off )
		SetSpriteSize( spriteID,13,15 )
	endfunction
	global NumSprite as integer[missileCount]

	for i = 0 to missileCount : NumSprite[i]=NumeralSeries+i : next i
	SetNumeralSprite(NumSprite[0],"Zero0.png")
	SetNumeralSprite(NumSprite[1],"One1.png")
	SetNumeralSprite(NumSprite[2],"Two2.png")
	SetNumeralSprite(NumSprite[3],"Three3.png")
	SetNumeralSprite(NumSprite[4],"Four4.png")
	SetNumeralSprite(NumSprite[5],"Five5.png")
	SetNumeralSprite(NumSprite[6],"Six6.png")
	SetNumeralSprite(NumSprite[7],"Seven7.png")
	SetNumeralSprite(NumSprite[8],"Eight8.png")
	SetNumeralSprite(NumSprite[9],"Nine9.png")
	for i = 0 to missileCount : SetSpritePosition(NumSprite[i],NumX,NumY) : next i
	SetSpriteVisible(NumSprite[9],On )

	Gill = LoadImage("GILL.png")
	SetTextDefaultFontImage(Gill)

	global PlayerBaseNode as integer
	global AIBaseNode as integer

	SetVirtualButtonVisible( CancelButton,Off )
	SetVirtualButtonActive( CancelButton,Off )
	SetVirtualButtonVisible( AcceptButton,Off )
	SetVirtualButtonActive( AcceptButton,Off )


	`strings
	global Light$ as string[6]
	global Medium$ as string[6]
	global Heavy$ as string[6]
	global Battery$ as string[6]
	Light$[0] = "LIGHT TANK"
	Light$[1] = "Armor: light"
	Light$[2] = "Weapons: medium laser; medium damage, unlimited range"
	Light$[3] = "Move Range: long"
	Light$[4] = ""
	Light$[5] = ""
	Medium$[0] = "MEDIUM TANK"
	Medium$[1] = "Armor: medium"
	Medium$[2] = "Weapon: medium laser; medium damage, unlimited range"
	Medium$[3] = "Weapon: medium cannon; medium damage, range 3"
	Medium$[4] = "Move Range: medium"
	Medium$[5] = ""
	Heavy$[0] = "HEAVY TANK"
	Heavy$[1] = "Armor: heavy"
	Heavy$[2] = "Weapon: heavy laser; heavy damage, unlimited range"
	Heavy$[3] = "Weapon: heavy cannon; heavy damage, range 3"
	Heavy$[4] = "Move Range: short"
	Heavy$[5] = ""
	Battery$[0] = "BATTERY"
	Battery$[1] = "Armor: very light"
	Battery$[2] = "Weapons: missiles; very heavy damage, unlimited range"
	Battery$[3] = "Move Range: long"
	Battery$[4] = ""
	Battery$[5] = ""

	function ToolTip(button,box,tip$)
		SetEditBoxText(box,tip$)
		ResetTimer()
		repeat
			if Timer() > 1 then SetEditBoxVisible(box,On)
			Sync()
		until GetVirtualButtonReleased(button)
		SetEditBoxVisible(box,Off)
	endfunction

	global cannonBox as integer
	global cannon$ as string
	global heavyCannon$ as String
	cannon$ = " MEDIUM CANNON: Range(3), Damage(2.5), Ammo(--)"
	heavyCannon$ = " HEAVY CANNON: Range(3), Damage(3.5), Ammo(--)"
	cannonBox = CreateEditBox()
	SetEditBoxFontImage( cannonBox, 0 )
	SetEditBoxSize( cannonBox,660,30 )
	SetEditBoxBackgroundColor( cannonBox,128,128,128,128 )
	SetEditBoxTextSize( cannonBox,32 )
	SetEditBoxTextColor( cannonBox,0,0,0 )
	SetEditBoxText( cannonBox, cannon$ )
	SetEditBoxPosition( cannonBox, NodeSize+10,(NodeSize*OpenRows)-10 )
	SetEditBoxActive( cannonBox, 0 )
	SetEditBoxFocus( cannonBox, 0 )
	SetEditBoxVisible( cannonBox, 0 )

	global missileBox as integer
	global missile$ as String
	missile$ = " MISSILE: Range(--), Damage(4), Ammo(3)"
	missileBox = CreateEditBox()
	SetEditBoxFontImage( missileBox, 0 )
	SetEditBoxSize( missileBox,540,30 )
	SetEditBoxBackgroundColor( missileBox,128,128,128,128 )
	SetEditBoxTextSize( missileBox,36 )
	SetEditBoxTextColor( missileBox,0,0,0 )
	SetEditBoxText( missileBox, missile$ )
	SetEditBoxPosition( missileBox, NodeSize+10,(NodeSize*OpenRows)-10 )
	SetEditBoxActive( missileBox, 0 )
	SetEditBoxFocus( missileBox, 0 )
	SetEditBoxVisible( missileBox, 0 )

	global laserBox as integer
	global laser$ as string
	global heavyLaser$ as String
	laser$ = " MEDIUM LASER: Range(--), Damage(1), Ammo(--)"
	heavyLaser$ = " HEAVY LASER: Range(--), Damage(2.5), Ammo(--)"
	laserBox = CreateEditBox()
	SetEditBoxFontImage( laserBox, 0 )
	SetEditBoxSize( laserBox,635,30 )
	SetEditBoxBackgroundColor( laserBox,128,128,128,128 )
	SetEditBoxTextSize( laserBox,36 )
	SetEditBoxTextColor( laserBox,0,0,0 )
	SetEditBoxText( laserBox, laser$ )
	SetEditBoxPosition( laserBox, NodeSize+10,(NodeSize*OpenRows)-10 )
	SetEditBoxActive( laserBox, 0 )
	SetEditBoxFocus( laserBox, 0 )
	SetEditBoxVisible( laserBox, 0 )

	if GetVirtualButtonState(CannonButton) then ToolTip(CannonButton,cannonBox,cannon$)
	if GetVirtualButtonState(HeavyCannonButton) then ToolTip(HeavyCannonButton,cannonBox,heavyCannon$)
	if GetVirtualButtonState(MissileButton) then ToolTip(MissileButton,missileBox,missile$)
	if GetVirtualButtonState(LaserButton) then ToolTip(LaserButton,laserBox,laser$)
	if GetVirtualButtonState(HeavyLaserButton) then ToolTip(HeavyLaserButton,laserBox,heavyLaser$)


	Initialize SpriteCons
	Initialize Setttings Grid

	SplashScreen Loop
		Setup Splash screen
		ResetDefaults()??
		Get button input
			if cancel then put up Yes/No alert
				if yes then exit game
			if settings then put up Settings dialog
			if accept then
				delete all images, buttons and sprites
				exit and start game

	SettingsDialog
		Setup Dialog sprite display
		Turn off Splash Screen
		Turn of Settings button
		if first time in, init Setup Grid and sprites???

		Compose Loop
			if forces ready then Review Forces

			else
				Put up cancel alert
				if Yes
					forces are ready
					ResetDefaults ??
					exit loop
				if No, continue loop

		if forces ready end loop
		DeleteAllSprites()???
		Turn on settings button and Splash screen

	SetupGrid
		for all units, assign image ID and unit ID to the grid, and clone sprites into position

	Compose
		Move sprites into position with mouse
		Exit when accept button pressed

	ForcesReview
		Reset Player and AICount
		Get unit counts and exit when forces ready

	GridCheck
		Assign unit to grid cell and position sprite
remend




remstart
	INITIALIZE

	type targetType
		x as integer	`screen coordinates
		y as integer
		id as integer
		//~ //shooterID as integer
	endtype

	global target as targetType[TotalCount]

	function CalcScreenToNodeXY(xy)		 //screen x or y coordinate
		xy = Floor(xy/NodeSize)
	endfunction xy						 //node x or y coordinate

	function CalcNodeX(node)
		x = node-(trunc(node/Columns)*Columns)
	endfunction x   					 //node x coordinate

	function CalcNodeY(node)
		y = trunc(node/Columns)
	endfunction y  						 //node y coordinate

	function CalcX(node)
		x = ((node-(trunc(node/Columns)*Columns)) * NodeSize) + NodeOffset
	endfunction x						 //screen x coordinate

	function CalcY(node)
		y = (trunc(node/Columns) * NodeSize) + NodeOffset
	endfunction y						 //screen y coordinate

	mapTable[i].x = ((i-(trunc(i/Columns)*Columns)) * NodeSize) + NodeOffset
	mapTable[i].y = (trunc(i/Columns) * NodeSize) + NodeOffset

	x = CalcX(Tank[i].node)
	y = CalcY(Tank[i].node)

	SetSpriteCategoryBits(Tank[i].bodyID,NoBlock)
	SetSpriteCategoryBits(Tank[i].turretID,NoBlock)
	SetSpriteShapeBox( Tank[i].bodyID, x, y, x+width-1, y+height-1, 0 )
	SetSpriteShapeBox( Tank[i].turretID, x, y, x+width-1, y+height-1, 0 )
	SetSpriteCategoryBits(Fire1,NoBlock)

	#constant EMP 3
	#constant EMPdamage 0
	#constant EMProunds 0
	global EMPrange as integer
	EMPrange = nodeSize * 3

	targeted as integer

	for r = 0 to Rows-1
		for c = 0 to Columns-1
			i=(r*Columns)+c		//index
			mapTable[i].terrain = val(chr(ReadByte( MapFile )))
			mapTable[i].occupied = False
		next c
	next r

	directional grid
	-1,-1	0,-1	1,-1
	-1, 0	0, 0	1, 0
	-1, 1	0, 1	1, 1

	global offset as integer[8]=[north,northwest,east,southwest,south,southeast,west,northeast]
	global offset as integer[8]=[48,  47, -1, -49, -48, -47,   1,  49]
	offsets
	 47	 48	 49
	  1	  0	 -1
	-49	-48	-47

	50	51	52
	98	99	99
	149	150	151

	angles from current location (0)
	315	   0   45
	270	   0   90
	225  180  135

	Tank[i].bodyAngle = 0
	Tank[i].turretAngle = 180
	mapTable[i].x = c	//node coordinates
	mapTable[i].y = r


	MAIN

	function Line( x1, y1, x2, y2, thickness, r,g,b,a )
		line = createSprite(0)
		setSpriteColor(line, r,g,b,a)
	    length = sqrt(Pow((x1-x2),2) + Pow((y1-y2),2))
	    setSpriteSize(line, length, thickness)
	    setSpriteOffset(line, 0, thickness/2)
	    setSpritePositionByOffset(line, x1, y1)
	    a# = atanfull(x2-x1, y2-y1)-90
	    setSpriteAngle(line, a#)
	endfunction

	r = (GetSpriteWidth(Tank[i].FOW)/2)-NodeSize
	Text(0,"TURN "+str(turns),MaxWidth-NodeSize,MaxHeight-NodeSize,0,0,0,16,255,2)

	function MoveInRange(ID,x1,y1,x2,y2) `screen coordinates
		XDist = abs(Floor(x1/NodeSize)-Floor(x2/NodeSize))
		YDist = abs(Floor(y1/NodeSize)-Floor(y2/NodeSize))
		if (XDist > Tank[ID].movesAllowed) or (YDist > Tank[ID].movesAllowed) then reach=False else reach=True
	endfunction reach

	If not MoveInRange(Player,x1,y1,px,py)
		SetSpriteColor( hilite,0,0,0,255 )
	else
		SetSpriteColor( hilite,255,255,255,255 )
	endif
	f1 = SetTween(x1,y1,x1,y1,360,0,FOW,TweenLinear(),3)
	PlayTweens( f1, FOW )
	Sync()

	If MoveInRange(Player,GetSpriteX(Tank[Player].bodyImageID),GetSpriteY(Tank[Player].bodyImageID),GetSpriteX(hilite),GetSpriteY(hilite))
		SetSpriteColor(hilite,255,255,255,255)
	endif

	index=Tank[Player].index
	moves=Tank[Player].moves
	turn=Tank[Player].turn
	ResetPath(Player)
	AStar(Player)
	Tank[Player].turn=turn
	Tank[Player].moves=moves
	Tank[Player].index=index

	Rotate Turret:
	targetAngle# = atan2((y1-(target.y+NodeOffset)),(x1-(target.x+NodeOffset)))-90

	MissileFire:
	targetAngle# = atan2((y1-(y2+NodeOffset)),(x1-(x2+NodeOffset)))-90

	case EMP
	endcase

	x1 = CalcX(Tank[Player].parentNode[Tank[Player].index])
	y1 = CalcY(Tank[Player].parentNode[Tank[Player].index])

	px = CalcX(Tank[Player].parentNode[Tank[Player].index])
	py = CalcY(Tank[Player].parentNode[Tank[Player].index])

	x1 = CalcX( Tank[Player].parentNode[index] )
	y1 = CalcY( Tank[Player].parentNode[index] )

	global turretAngle# as float
	global targetAngle# as float
	global arc# as float

	print(turretAngle#)
	print(targetAngle#)
	print(arc#)

	sqrt((x1-x2)^2 + (y1-y2)^2)

	for j = 0 to PlayerLast
		if PlayerTank[j].alive and GetSpriteInCircle(PlayerTank[j].bodyID, AITank[i].x,AITank[i].y, FOWoffset) then visible = True
	next j
	if visible
		SetSpriteVisible(AITank[i].bodyID,On)
		SetSpriteVisible(AITank[i].turretID,On)
	else
		SetSpriteVisible(AITank[i].bodyID,Off)
		SetSpriteVisible(AITank[i].turretID,Off)
	endif


	PATH
	if ID <> Player
		SetSpritePosition(FOW,x2-FOWoffset,y2-FOWoffset)
		SetSpriteVisible(FOW,On)
	else
		ClearSpriteShapes( AIFOW )
		AddSpriteShapeCircle( AIFOW,x2,y2,FOWoffset )
	endif
	if ID <> Player
		Tank[ID].goalNode = Tank[Player].parentNode[Tank[Player].index]
	endif


	MISCELLANEOUS
	if (ID <> Player) and (Randomize(1,10) > 5) then dec h,mapTable[currentNode].terrain `random move factor(50%)

	function Heuristic(goalNode,currentNode) //alternate code
		x = abs(CalcNodeX(goalNode) - CalcNodeX(currentNode))
		y = abs(CalcNodeY(goalNode) - CalcNodeY(currentNode))
		heuristic = sqrt(Pow(x,2)+Pow(y,2)) //+ mapTable[currentNode].terrain
	endfunction heuristic

	function Range(value,change,min,max,less,more)
		if value > max
			value = max
			change = less
		elseif value < min
			value = min
			change = more
		endif
	endfunction

	global TopRowDummy as integer
	global BottomRowDummy as integer
	TopRowDummy = CreateDummySprite()
	BottomRowDummy = CreateDummySprite()
	SetSpriteCategoryBits(TopRowDummy,NoBlock)
	SetSpriteCategoryBits(BottomRowDummy,NoBlock)
	SetSpritePhysicsOn(TopRowDummy,1)
	SetSpritePhysicsOn(BottomRowDummy,1)
	AddSpriteShapeBox(TopRowDummy,NodeSize,NodeSize,OpenColumns*NodeSize,NodeSize,0)
	AddSpriteShapeBox(BottomRowDummy,NodeSize,OpenRows*NodeSize,OpenColumns*NodeSize,NodeSize,0)

	if GetSpriteCollision( AITank[ID].bodyID,TopRowDummy )
		AITank[ID].goalNode = CalcNode( floor(AITank[ID].x/NodeSize),OpenRows )
	elseif GetSpriteCollision( AITank[ID].bodyID,BottomRowDummy )
		AITank[ID].goalNode = CalcNode( floor(AITank[ID].x/NodeSize),FirstRow )
	endif

	Text(0,"TURN
	Text(1,"Hit!",
	Text(1,"moving"
	Text(1,"Miss!"
	Text(1,"firing"
	2,"LOS BLOCKED"
	3,"out of range"
	4,"out of ammo"
	function GameOver(message$)
	Text(5,message$,MaxWidth/2,830,0,0,0,26,255,1)

	#constant FieldSeries 1
	#constant PlayerTankSeries 50
	#constant PlayerCoverSeries 500

	#constant AITankSeries 75
	#constant AICoverSeries 550

	#constant InterfaceSeries 100
	#constant TargetSeries 150
	#constant WeaponSeries 200
	#constant MissileSeries 225
	#constant ExplodeSeries 250
	#constant FOWseries 300
	#constant NumeralSeries 350
	#constant PlayerHealthSeries 400
	#constant AIHealthSeries 450
	#constant DummySeries 1000
	#constant FOWsize 600
	#constant FOWoffset 300

	`tool tips
	#constant CannonQ 8
	#constant MissileQ 9
	#constant LaserQ 10

	global QuestionImage as integer
	global QuestionImageDown as integer
	questionImage = InterfaceSeries + 75
	questionImageDown = InterfaceSeries + 76

	global cx as integer
	global mx as integer
	global lx as integer
	global qy as integer
	#constant QMarkSize 24

	cx = buttSize+NodeSize + 10
	qy = buttY + 13
	LoadButton(CannonQ,QuestionImage,QuestionImageDown,"Question.png","QuestionDown.png",cx,qy,QMarkSize)
	mx = cx + 105
	LoadButton(MissileQ,QuestionImage,QuestionImageDown,"Question.png","QuestionDown.png",mx,qy,QMarkSize)
	lx = mx + 105
	LoadButton(LaserQ,QuestionImage,QuestionImageDown,"Question.png","QuestionDown.png",lx,qy,QMarkSize)

	GetInput

	if mapTable[node].team <> Unoccupied
		if mapTable[node].team = PlayerTeam
			PlaySound(ClickSound)
			SetSpriteVisible(PlayerTank[i].hilite,Off)
			PlayerTank[i].goalNode = PlayerTank[i].parentNode[PlayerTank[i].index]
			ResetPath(i,PlayerTank)
			AStar(i,PlayerTank)
		elseif GetSpriteInCircle(square,PlayerTank[i].x,PlayerTank[i].y,FOWoffset)
			PlayerAim(i,PlayerTank[i].x,PlayerTank[i].y)
		elseif mapTable[node].terrain <> Impassable
			SetMove(i,node)
		endif

	function SetMove(ID,node)
		PlayerTank[ID].goalNode = node
		if PlayerTank[ID].moveTarget then mapTable[PlayerTank[ID].moveTarget].moveTarget = False  `clear previous target

		mapTable[node].moveTarget = True
		SetSpriteVisible(square,Off)
		SetSpriteVisible(PlayerTank[ID].hilite,On)
		SetSpritePositionByOffset( PlayerTank[ID].hilite, mapTable[PlayerTank[ID].goalNode].x, mapTable[PlayerTank[ID].goalNode].y )
		PlayerTank[ID].goalNode = node
		ResetPath(ID,PlayerTank)
		AStar(ID,PlayerTank)

		If PlayerTank[ID].totalCost > PlayerTank[ID].movesAllowed `goal in range?
			SetSpriteColor( PlayerTank[i].hilite,255,0,0,255 )
		else
			SetSpriteColor( PlayerTank[i].hilite,255,255,255,255 )
		endif

		PlayerTank[ID].moveTarget = node	`record last target
	endfunction


	type buttonType
		ID as integer
		x as integer
		y as integer
		Image as integer
		ImageDown as integer
		size as integer
	endtype

	global TurnButton as buttonType
	global BangButton as buttonType
	global CannonButton as buttonType
	global MissileButton as buttonType
	global LaserButton as buttonType
	global NextButton as buttonType
	global TargetButton as buttonType
	global QuitButton as buttonType
	global YesButton as buttonType
	global NoButton as buttonType
	global HeavyCannonButton as buttonType
	global HeavyLaserButton as buttonType

	for i = 1 to 12

	next i

	#constant laserDamage .1
	#constant heavyLaserDamage .25
	#constant cannonDamage .25
	#constant heavyCannonDamage .35
	#constant missileDamage .4

remend

