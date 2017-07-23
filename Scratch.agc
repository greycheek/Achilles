
remstart
#constant Columns 32	 `nodes
#constant OpenColumns 30
#constant Rows 20
#constant OpenRows 16



#constant SectorWidth 4
#constant SectorHeight 8
#constant Sectors 6
#constant BaseSectors 32

global PlayerSectorNodes as integer[6,32]
global AISectorNodes as integer[6,32]

global PlayerOrigin as integer[6]
global AIOrigin as integer[6]

PlayerOrigin[0] = 34
PlayerOrigin[1] = 38
PlayerOrigin[2] = 42
PlayerOrigin[3] = 290
PlayerOrigin[4] = 294
PlayerOrigin[5] = 298
AIOrigin[0] = 50
AIOrigin[1] = 54
AIOrigin[2] = 58
AIOrigin[3] = 306
AIOrigin[4] = 310
AIOrigin[5] = 314

for s = 0 to Sectors-1
	for r = 0 to SectorHeight-1
		rows = r * Columns
		nextRow = r * SectorWidth
		for c = 0 to SectorWidth-1
			PlayerSectorNodes[s,nextRow+c] = PlayerOrigin[s]+rows+c
			AISectorNodes[s,nextRow+c] = AIOrigin[s]+rows+c
		next c
	next r
next s


function GenerateBases()
	PlayerBases.length = -1
	AIBases.length = -1

	for i = 0 to Sectors-1
		select i
			case 0
				node = Random2( PlayerSectorNodes[0,0],PlayerSectorNodes[0,BaseSectors-1] )
				BaseSetup( node,PlayerBase,PlayerBases,PlayerBaseSeries,BaseGroup )
			endcase
			case 1,2,4,5
				node = Random2( PlayerSectorNodes[i,0],PlayerSectorNodes[i,BaseSectors-1] )
				if not Random2(0,3)
					BaseSetup( node,PlayerBase,PlayerBases,PlayerBaseSeries,BaseGroup )
				else
					DepotSetup( node,PlayerBase,PlayerBases,PlayerBaseSeries,BaseGroup )
				endif
			endcase
			case 3
				node = Random2( PlayerSectorNodes[3,0],PlayerSectorNodes[3,BaseSectors-1] )
				DepotSetup( node,PlayerBase,PlayerBases,PlayerBaseSeries,BaseGroup )
			endcase
		endselect
	next i

	for i = 0 to Sectors-1
		select i
			case 0
				node = Random2( AISectorNodes[0,0],AISectorNodes[0,BaseSectors-1] )
				BaseSetup( node,AIBase,AIBases,AIBaseSeries,AIBaseGroup )
			endcase
			case 1,2,4,5
				node = Random2( AISectorNodes[i,0],AISectorNodes[i,BaseSectors-1] )
				if not Random2(0,3)
					BaseSetup( node,AIBase,AIBases,AIBaseSeries,AIBaseGroup )
				else
					DepotSetup( node,AIDepot,AIDepotNode,AIDepotSeries )
				endif
			endcase
			case 3
				node = Random2( AISectorNodes[3,0],AISectorNodes[3,BaseSectors-1] )
				DepotSetup( node,AIDepot,AIDepotNode,AIDepotSeries )
			endcase
		endselect
	next i

	AIBaseCount = AIBases.length
	PlayerBaseCount = PlayerBases.length
	AIProdUnits = (AIBaseCount+1) * BaseProdValue
	PlayerProdUnits = (PlayerBaseCount+1) * BaseProdValue
endfunction

remend

#constant Shapes 32
#constant ShapeGrid 64
#constant ShapeSize 8
#constant ShapeCells 2048
#constant OpenNodeCount 392

global OpenCells as integer[OpenNodeCount]
global Shapes as integer[32,64]
global MaxX
global MaxY

MaxX = OpenColumns * NodeSize
MaxY = OpenRows * NodeSize

`calculate array of open area nodes
Quad = (Columns*2)+2	`66; map boundary + buffer zone
for i = 0 to OpenColumns-3
	rowTotal = i*Columns
	for j = 0 to OpenRows-3
		columnTotal = rowTotal+j
		OpenCells[columnTotal] = startnode+columnTotal
	next j
next i

`create impass shape array
ImpassFile = OpenToRead("8x8x32.txt")
for i = 0 to Shapes-1
	for j = 0 to ShapeGrid-1
		Shapes[i,j] = val(chr(ReadByte(ImpassFile)))
	next j
next i
CloseFile(ImpassFile)


function GenerateMap()
	node as integer = 0

	`Trees
	for i = 2 to OpenRows-1
		for j = 2 to OpenColumns-1
			n = node + j
			if not Random2(0,3) then mapTable[n].terrain = Trees
		next j
		inc node,Columns
	 next i

	`Impassables
	maxShapes = Random2[5,15]
	for i = 0 to maxShapes
		SetImpass( OpenCells[Random2(0,OpenNodeCount-1)] )
	next i
endfunction


function SetImpass(Quad)
	r = Random2[0,Shapes-1] `pick a random shape
	for i = 0 to ShapeSize-1
		nextRow  = i * Columns
		nextLine = i * ShapeSize

		if mapTable[Quad + nextRow].y > MaxY then exitfunction

		for j = 0 to ShapeSize-1
			nextNode = Quad + nextRow + j
			if mapTable[nextNode].y > MaxX then exit
			mapTable[nextNode].terrain = Shapes[ r,j+nextLine ]
		next j
	next i
endfunction




#constant InReach 1
#constant OutOfReach 2
#constant NoPath 3

function Patrol(ID)
	range = AITank[ID].range/NodeSize
	x = floor(AITank[ID].x/NodeSize)
	y = floor(AITank[ID].y/NodeSize)
	nodeMin = CalcNode( x - range, y - range )
	nodeMax = CalcNode( x + range, y + range )
	nodeMin = Max(1,nodeMin)
	nodeMax = Min(OpenMapSize,nodeMax)
	for i = nodeMin to nodeMax
		if mapTable[i].terrain <> Impassable
			AITank[ID].goalNode = i
			exitfunction
		endif
	next i
endfunction




			function Djikstra(	ID, Tank ref as tankType[] )
				reach = Null
				currentNode = Tank[ID].node
				terrainCost = Undefined
				for i = 0 to MapSize-1 : mapTable[i].heuristic = Unset : next i	`clear board
				do
					for i = 0 to 7
						adjacentNode = offset[i] + currentNode

						if not OnList(adjacentNode,Tank[ID].ClosedList)
							heuristic = Heuristic( Tank[ID].goalNode,adjacentNode ) + mapTable[adjacentNode].cost

							if heuristic < mapTable[adjacentNode].heuristic
								mapTable[adjacentNode].heuristic = heuristic
								terrainCost = mapTable[adjacentNode].cost
								lowestCostNode = adjacentNode
							endif
						endif
					next i
					Tank[ID].ClosedList.insert(currentNode)
					Tank[ID].node = lowestCostNode
					currentNode = Tank[ID].node
					Tank[ID].parentNode.insert(Tank[ID].node)

					if Tank[ID].node = Tank[ID].goalNode then exitfunction InReach
					inc Tank[ID].totalTerrainCost,terrainCost
					if Tank[ID].totalTerrainCost > Tank[ID].movesAllowed then exitfunction OutOfReach
				loop
			endfunction reach

function Djikstra(	ID, Tank ref as tankType[] )
	reach = Null
	currentNode = Tank[ID].node
	terrainCost = Undefined
	for i = 0 to MapSize-1 : mapTable[i].heuristic = Unset : next i	`clear board
	do
		for i = 0 to 7
			adjacentNode = offset[i] + currentNode

			if not OnList(adjacentNode,Tank[ID].ClosedList)
				heuristic = Heuristic( Tank[ID].goalNode,adjacentNode ) + mapTable[adjacentNode].cost

				if heuristic < mapTable[adjacentNode].heuristic
					mapTable[adjacentNode].heuristic = heuristic
					terrainCost = mapTable[adjacentNode].cost
					lowestCostNode = adjacentNode
				endif
			endif
		next i
		Tank[ID].ClosedList.insert(currentNode)
		Tank[ID].node = lowestCostNode
		currentNode = Tank[ID].node
		Tank[ID].parentNode.insert(Tank[ID].node)

		if Tank[ID].node = Tank[ID].goalNode then exitfunction InReach
		inc Tank[ID].totalTerrainCost,terrainCost
		if Tank[ID].totalTerrainCost > Tank[ID].movesAllowed then exitfunction OutOfReach
	loop
endfunction reach


remstart

	function OnList( node, nodeList as integer[] ) `find on open or closed lists
		list as integer[]
		list = nodeList
		nodeList.sort()
		if list.find(node) <> -1 then exitfunction True
	endfunction False

rewrite like this:

	2 2 2 2 2
	2 1 1 1 2
	2 1 0 1 2
	2 1 1 1 2
	2 2 2 2 2

function LegalMove(node)
	inBounds = (node >= 0) and (node <= MapSize)
	pathClear = (mapTable[node].terrain <> Impassable) and (mapTable[node].team = Null)
	legal = inBounds and pathClear
endfunction legal

			function Scan( ID, Tank ref as tankType[] ) 	`cell by cell values for entire map
				index = -northwest
				counter = 0
				ring = ((index/-northwest)*8)-1
				repeat
					node = MinMax(0,MapSize-1,index+Tank[ID].node)
					for i = 0 to ring
									node = offset[i] + currentNode
						if not mapTable[node].cost
							mapTable[node].heuristic = Impassable
						else
							mapTable[node].heuristic = (ring/8)+mapTable[node].cost
						endif
						inc counter
					next i
					ring = ((index/-northwest)*8)-1
					inc index,-northwest
				until counter >= MapSize
			endfunction

			function AStar(	ID, Tank ref as tankType[] )	`really a flood fill search
				result = InReach
				Scan( ID,Tank )
				do
					currentCost = Unset
					currentNode = Tank[ID].node
					terrainCost = Undefined
					for i = 0 to 7
						adjacentNode = offset[i] + currentNode

						if mapTable[adjacentNode].heuristic	<> Impassable
							if (mapTable[adjacentNode].heuristic < currentCost) or (adjacentNode = Tank[ID].goalNode)
								Tank[ID].node = adjacentNode
								currentCost = mapTable[adjacentNode].heuristic
								terrainCost = mapTable[adjacentNode].cost
							endif
						endif
					next i
					if terrainCost = Undefined then exitfunction OutOfReach

					inc Tank[ID].totalTerrainCost,terrainCost
					if Tank[ID].totalTerrainCost > Tank[ID].movesAllowed then exitfunction OutOfReach

					Tank[ID].parentNode.insert(Tank[ID].node)

					if Tank[ID].node = Tank[ID].goalNode then exitfunction result
				loop
			endfunction result

remend


function Scan( goalNode ) 	`cell by cell heuristic for entire map
	for i = 0 to MapSize-1
		If LegalMove(i)
			mapTable[i].heuristic = Heuristic(goalNode,i) + mapTable[i].cost
		else
			mapTable[i].heuristic = Impassable
		endif
	next i
endfunction

function AStar(	ID, Tank ref as tankType[] )	`really a flood fill search
	result = InReach
	terrainCost = Undefined
	Scan( Tank[ID].goalNode )
	do
		currentCost as Float = Unset
		currentNode = Tank[ID].node
		for i = 0 to 7
			adjacentNode = offset[i] + currentNode

			if mapTable[adjacentNode].heuristic	<> Impassable	`not impassable?
				if (mapTable[adjacentNode].heuristic < currentCost) or (adjacentNode = Tank[ID].goalNode)
					Tank[ID].node = adjacentNode
					currentCost = mapTable[adjacentNode].heuristic
					terrainCost = mapTable[adjacentNode].cost
				endif
			endif
		next i
		inc Tank[ID].totalTerrainCost,terrainCost
		if Tank[ID].totalTerrainCost > Tank[ID].movesAllowed then result = OutOfReach
		Tank[ID].parentNode.insert(Tank[ID].node)
		if Tank[ID].node = Tank[ID].goalNode then exitfunction result
	loop
endfunction result



function AStar( ID, Tank ref as tankType[] )
	result as integer = Null
	do
		if Tank[ID].node = Tank[ID].goalNode then exitfunction InReach
		currentNode = Tank[ID].node
		terrainCost = FindPath(ID,Tank,currentNode)
		if terrainCost = Undefined
			exitfunction NoPath
		else
			inc Tank[ID].totalTerrainCost,terrainCost
			if Tank[ID].totalTerrainCost > Tank[ID].movesAllowed
				Tank[ID].node = currentnode
				exitfunction OutOfReach
			endif
		endif
		Tank[ID].parentNode.insert(Tank[ID].node)
		Tank[ID].ClosedList.insert(Tank[ID].node)
		for i = 0 to Tank[ID].OpenList.length
			if Tank[ID].OpenList[i] = Tank[ID].node
				Tank[ID].OpenList.remove(i) : exit
			endif
		next i
	loop
endfunction result

function FindPath( ID, Tank ref as tankType[], currentNode )
	terrainCost = Undefined
	currentCost as Float = Unset
	heuristic as Float
	for i = 0 to 7
		adjacentNode = offset[i] + currentNode

		if LegalMove(adjacentNode)
			heuristic = Heuristic( Tank[ID].goalNode,adjacentNode )

			if (not OnLists(ID,adjacentNode,Tank)) or (terrainCost = Undefined)
				if (heuristic < currentCost) or (adjacentNode = Tank[ID].goalNode)
					Tank[ID].OpenList.insert(adjacentNode)
					Tank[ID].node = adjacentNode
					currentCost = heuristic
					terrainCost = mapTable[adjacentNode].cost
					if adjacentNode = Tank[ID].goalNode then exit
				else
					Tank[ID].ClosedList.insert(adjacentNode)
				endif
			endif
		else
			Tank[ID].ClosedList.insert(adjacentNode)
		endif
	next i
endfunction terrainCost


function OnLists( ID, node, Tank ref as tankType[] ) `find on open or closed lists
	found = False
	OpenList as integer[]
	ClosedList as integer[]
	OpenList = Tank[ID].OpenList : OpenList.sort()
	ClosedList = Tank[ID].ClosedList : ClosedList.sort()
	if OpenList.find(node) <> -1
		found = True
	elseif ClosedList.find(node) <> -1
		found = True
	endif
endfunction found

function ResetPath(ID,Tank ref as tankType[])
	Tank[ID].node = Tank[ID].parentNode[Tank[ID].index]
	Tank[ID].OpenList.length = Empty
	Tank[ID].ClosedList.length = Empty
	Tank[ID].parentNode.length = Empty
	Tank[ID].parentNode.insert(Tank[ID].node)
	Tank[ID].totalTerrainCost = 0
	Tank[ID].index = 0
	Tank[ID].moves = 0
endfunction




function DepotSetup( index, depotNode ref as integer[] )
	depotNode.length = depotNode.length + 1
	ID = baseRef.length
	depotNode[ID].node = index
	depotNode[ID].spriteID = series+baseRef.length-1
	LoadImage( baseRef[ID].spriteID,"HEXBASE.png" )
	CreateSprite( baseRef[ID].spriteID,baseRef[ID].spriteID )
	SetSpritePhysicsOn( baseRef[ID].spriteID, On )
	SetSpriteTransparency( baseRef[ID].spriteID, On )
	SetSpriteVisible( baseRef[ID].spriteID, On )
	SetSpriteSize(baseRef[ID].spriteID, 39, 45)
	SetSpriteDepth( baseRef[ID].spriteID,3 )
	SetSpriteGroup( baseRef[ID].spriteID, group )
endfunction

treeDummy = CreateDummySprite()
SetSpriteCategoryBits(treeDummy,Block)
SetSpritePhysicsOn(treeDummy,1)
MapFile = OpenToRead( "Achilles45.txt" )
for i = 0 to MapSize-1
	mapTable[i].nodeX = i-(trunc(i/Columns)*Columns)
	mapTable[i].nodeY = trunc(i/Columns)
	mapTable[i].x = (mapTable[i].nodeX * NodeSize) + NodeOffset
	mapTable[i].y = (mapTable[i].nodeY * NodeSize) + NodeOffset
	mapTable[i].terrain = val(chr(ReadByte( MapFile )))
	maptable[i].cost = cost[mapTable[i].terrain]
	mapTable[i].team = Unoccupied
	mapTable[i].moveTarget = False

	select mapTable[i].terrain
		case PlayerBase  : BaseSetup(i,PlayerBases,PlayerBaseSeries,BaseGroup) : endcase
		case AIBase		 : BaseSetup(i,AIBases,AIBaseSeries,AIBaseGroup) : endcase
		case PlayerDepot : DepotSetup( i, PlayerDepotNode ) : endcase
		case AIDepot     : DepotSetup( i, AIDepotNode ) : endcase
		case Trees
			x = mapTable[i].x-NodeOffset
			y = mapTable[i].y-NodeOffset
			AddSpriteShapeBox(treeDummy,x,y,x+NodeSize-1,y+NodeSize-1,0)
		endcase
	endselect
next i



	STANDARD TABBED UNIT SELECTION
	function GetInput()
		do
			for i = 0 to PlayerLast
				if not PlayerTank[i].alive then continue
			    alpha = Brightest
			    glow = Brighter
			 	WeaponButtons(i,PlayerTank[i].vehicle)
				repeat
					WeaponInput(i)
					if GetPointerState()

						if GetPointerY() < (MapHeight+NodeSize) `stay within map height
							TankAlpha(PlayerTank[i].bodyID,PlayerTank[i].turretID,Brightest)

							node = MoveInput(i,PlayerTank[i].x,PlayerTank[i].y)

							x1 = PlayerTank[i].x - PlayerTank[i].FOWOffset
							y1 = PlayerTank[i].y - PlayerTank[i].FOWOffset
							x2 = PlayerTank[i].x + PlayerTank[i].FOWOffset
							y2 = PlayerTank[i].y + PlayerTank[i].FOWOffset
							if GetSpriteInBox( square,x1,y1,x2,y2 )

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
									SetSpritePositionByOffset( PlayerTank[i].hilite, mapTable[PlayerTank[i].goalNode].x, mapTable[PlayerTank[i].goalNode].y )
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
							else
								SetSpriteVisible(square,Off)
							endif
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

					turnEnd = GetVirtualButtonPressed(AcceptButton) or GetRawKeyPressed(Enter)
					nextTank = GetVirtualButtonPressed(NextButton) or GetRawKeyPressed(Space) or GetRawKeyPressed(Tab)
					if GetVirtualButtonReleased(QuitButton) or GetRawKeyPressed(0x51) then EndGame() `Q
				until turnEnd or nextTank

				PlaySound( ClickSound )
				SetSpriteColorAlpha( PlayerTank[i].hilite,Brightest )
				SetSpriteColorAlpha( PlayerTank[i].bullsEye,Brightest )
				SetSpriteColorAlpha( PlayerTank[i].cover,CoverAlpha )
				TankAlpha(PlayerTank[i].bodyID,PlayerTank[i].turretID,GlowMax)

				if turnEnd then exitfunction
			next i
		loop
	endfunction




function GetInput()
	ID = 0
    alpha = Brightest
    glow = Brighter
	WeaponButtons( ID,PlayerTank[ID].vehicle )
	repeat
		WeaponInput(ID)
		if GetVirtualButtonState(AcceptButton) or GetRawKeyState(Enter)
			PlaySound( ClickSound )
			MaxAlpha(ID)
			endTurn = True
		elseif GetVirtualButtonState(QuitButton) or GetRawKeyState(0x51) `Q
			if GetVirtualButtonState(QuitButton) then WaitForButtonRelease(QuitButton)
			PlaySound( ClickSound )
			EndGame()
		elseif GetPointerState()
			x = GetPointerX()
			y = GetPointerY()
			if GetSpriteHitGroup( PlayerTankGroup,x,y )
				for i = 0 to PlayerLast
					if GetSpriteHitTest( PlayerTank[i].bodyID,x,y )
						PlaySound(ClickSound)
						if ID = i
							SetSpriteVisible(PlayerTank[ID].hilite,Off)
							PlayerTank[ID].goalNode = PlayerTank[ID].parentNode[PlayerTank[ID].index]
							ResetPath(ID,PlayerTank)
							AStar(ID,PlayerTank)
							ID = Undefined
						else
							MaxAlpha(ID)
							ID = i
							WeaponButtons( ID,PlayerTank[ID].vehicle )
						endif
						WaitForPointerRelease()
						exit
					endif
				next i
			elseif GetSpriteHitGroup( BaseGroup,x,y ) and (ID <> Undefined )
				BaseProduction( ID,CalcNode( floor(x/NodeSize),floor(y/NodeSize) ) )
			else
				if y < ( MapHeight+NodeSize ) `stay within map height
					TankAlpha(PlayerTank[ID].bodyID,PlayerTank[ID].turretID,Brightest)

					node = MoveInput(ID,PlayerTank[ID].x,PlayerTank[ID].y)

					x1 = PlayerTank[ID].x - PlayerTank[ID].FOWOffset
					y1 = PlayerTank[ID].y - PlayerTank[ID].FOWOffset
					x2 = PlayerTank[ID].x + PlayerTank[ID].FOWOffset
					y2 = PlayerTank[ID].y + PlayerTank[ID].FOWOffset

					if GetSpriteInBox( square,x1,y1,x2,y2 )
						if mapTable[node].team <> Unoccupied
							if (PlayerTank[i].target = Undefined) and (mapTable[node].team = AITeam)
								PlayerAim(ID,PlayerTank[ID].x,PlayerTank[ID].y)
							else
								CancelFire(ID)
							endif
							SetSpriteVisible(square,Off)
						elseif mapTable[node].moveTarget
							PlaySound(ErrorSound)
							SetSpriteVisible(square,Off)
						elseif mapTable[node].terrain <> Impassable
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
								SetSpriteColor( PlayerTank[ID].hilite,255,0,0,255 )
							else
								SetSpriteColor( PlayerTank[ID].hilite,255,255,255,255 )
							endif

							PlayerTank[ID].moveTarget = node	`record last target
						endif
						Sync()
					else
						SetSpriteVisible(square,Off)
					endif
				endif
			endif
		endif
		inc alpha,glow
		if alpha > GlowMax
			alpha = GlowMax : glow = Darker
		elseif alpha < GlowMin
			alpha = GlowMin : glow = Brighter
		endif
		if ID <> Undefined
 			TankAlpha(PlayerTank[ID].bodyID,PlayerTank[ID].turretID,alpha)
			if GetSpriteVisible( PlayerTank[ID].hilite ) then SetSpriteColorAlpha( PlayerTank[ID].hilite,alpha )
			if GetSpriteVisible( PlayerTank[ID].bullsEye ) then SetSpriteColorAlpha( PlayerTank[ID].bullsEye,alpha )
			if GetSpriteVisible( PlayerTank[ID].cover ) then SetSpriteColorAlpha( PlayerTank[ID].cover,alpha )
			Sync()
		endif
	until endTurn
endfunction






remend
