
#constant InReach 1
#constant OutOfReach 2
#constant NoPath 3

function AStar( ID, Tank ref as tankType[] )
	result as integer = Null
	do
		if Tank[ID].node = Tank[ID].goalNode then exitfunction InReach
		currentNode = Tank[ID].node
		terrainCost = FindPath(ID,Tank,currentNode)

		if terrainCost = Undefined
			exitfunction NoPath
		elseif Tank[ID].team = PlayerTeam
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

	heuristic as Float
	lowestHeuristic as Float = Unset
	adjacentHeuristic as Float
	lowestAdjacentHeuristic as Float

	for i = 0 to 7
		adjacentNode = offset[i] + currentNode

		if LegalMove(adjacentNode,Tank[ID].team)
			adjacentHeuristic = Heuristic(currentNode,adjacentNode,Tank[ID].team,Tank[ID].vehicle)
			heuristic = Heuristic(Tank[ID].goalNode,adjacentNode,Tank[ID].team,Tank[ID].vehicle) + adjacentHeuristic + Tank[ID].costFromStart

			if not OnLists(ID,adjacentNode,Tank)
				if (heuristic < lowestHeuristic) or (adjacentNode = Tank[ID].goalNode)

					lowestHeuristic = heuristic
					lowestAdjacentHeuristic = adjacentHeuristic
					if (Tank[ID].vehicle = Mech) or (Tank[ID].vehicle = Engineer) `not penalized for rough or trees
											terrainCost = Clear
					else
						terrainCost = mapTable[adjacentNode].cost
					endif

					Tank[ID].OpenList.insert(adjacentNode)
					Tank[ID].node = adjacentNode
					if adjacentNode = Tank[ID].goalNode then exitfunction terrainCost
				endif
			endif
		else
			Tank[ID].ClosedList.insert(adjacentNode)
		endif
	next i
	inc Tank[id].costFromStart,lowestAdjacentHeuristic
endfunction terrainCost

function OnList( node, nodeList as integer[] ) `find on open or closed lists
	list as integer[]
	list = nodeList
	list.sort()
	if list.find(node) <> -1 then exitfunction True
endfunction False

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
	Tank[ID].ClosedList.insert(Tank[ID].node)
	Tank[ID].parentNode.length = Empty
	Tank[ID].parentNode.insert(Tank[ID].node)
	Tank[ID].totalTerrainCost = 0
	Tank[ID].index = 0
	Tank[ID].moves = 0
	Tank[ID].costFromStart = 0
endfunction

function Move(ID,Tank ref as tankType[],node1,node2)
	x1 = Tank[ID].x
	y1 = Tank[ID].y
	x2 = mapTable[node2].x
	y2 = mapTable[node2].y
	b# = GetSpriteAngle( Tank[ID].bodyID )
	t# = GetSpriteAngle( Tank[ID].turretID )
	offsetValue = node1-node2
	for i = 0 to 7
		if offset[i] = offsetValue
			a# = angle[i] : exit
		endif
	next i
	tankArc# = SetTurnArc(b#,a#)
	turretArc# = SetTurnArc(t#,a#)

	if not GetSpriteVisible( Tank[ID].bodyID )
		speed# = .01  `speed up invisible AI moves
	else
		speed# = Tank[ID].speed
		SetSoundInstanceRate( PlaySound( Tank[ID].sound,Tank[ID].volume ),3.5 )	 `sound for visible units
	endif
	if Tank[ID].team = PlayerTeam then SetTween(x1,y1,x2,y2,0,0,Tank[ID].FOW,TweenLinear(),speed#)
	t1 = SetTween(x1,y1,x2,y2,b#,tankArc#,  Tank[ID].bodyID,  TweenLinear(),speed#)
	t2 = SetTween(x1,y1,x2,y2,t#,turretArc#,Tank[ID].turretID,TweenLinear(),speed#)

	select Tank[ID].Vehicle
		case HoverCraft
			if GetSpriteCurrentFrame( Tank[ID].bodyID ) = 1
				sx# = 1
				sy# = 1
				PlaySprite( Tank[ID].bodyID,40,0,1,21 )
				repeat
					SetSpriteScaleByOffset(Tank[ID].bodyID,sx#,sy#)
					SetSpriteScaleByOffset(Tank[ID].turretID,sx#,sy#)
					Sync()
					inc sx#,.01
					inc sy#,.01
				until GetSpriteCurrentFrame( Tank[ID].bodyID ) = 21
			endif
		endcase
		case Mech	  : PlaySprite( Tank[ID].bodyID,20,0 ) : endcase
		case Engineer : if not GetSpritePlaying( Tank[ID].bodyID ) then PlaySprite( Tank[ID].bodyID,80,0 ) : endcase
	endselect

	PlayTweens( t1, Tank[ID].bodyID )
	Tank[ID].x = x2
	Tank[ID].y = y2
	Deploy(ID,Tank,node1,node2)
	inc Tank[ID].index
	inc Tank[ID].totalTerrainCost,mapTable[node2].cost
endfunction

function Deploy(ID,Tank ref as tankType[],node1,node2)
	mapTable[node1].team = Unoccupied
	mapTable[node2].team = Tank[ID].team
	if mapTable[node1].terrain = Trees then SetSpriteVisible(Tank[ID].cover,0)
	if (mapTable[node2].terrain = Trees) and GetSpriteVisible(Tank[ID].bodyID)	`position tanks under cover
		SetSpritePositionByOffset(Tank[ID].cover,Tank[ID].x,Tank[ID].y)
		SetSpriteVisible(Tank[ID].cover,1)
	endif
endfunction

function SetTurnArc(a1#,a2#)
	arc# = a2# - a1#
	if arc# >  180 then dec arc#,360
	if arc# < -180 then inc arc#,360
	inc arc#,a1#
endfunction arc#

function ShowNode(node,cost) `debug
	Delay(100000)
	x = mapTable[node].x-NodeOffset
	y = mapTable[node].y-NodeOffset
	DrawBox( x,y,x+NodeSize,y+NodeSize,0,0,0,0,1)
	print(cost)
	Sync()
endfunction

remstart

remend


