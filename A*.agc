
//~ remstart
function AStar(ID, Tank ref as tankType[])
	currentCost as Float
	do
		currentNode = Tank[ID].node
		Tank[ID].parentNode.insert(currentNode)
		if Tank[ID].OpenList.length > 0
			for i = 0 to Tank[ID].OpenList.length
				if Tank[ID].OpenList[i] = currentNode
					Tank[ID].OpenList.remove(i)
					Tank[ID].ClosedList.insert(currentNode)
					exit
				endif
			next i
		endif
		if currentNode = Tank[ID].goalNode then exit

		for i = 0 to 7
			adjacentNode = offset[i] + currentNode

			if (mapTable[adjacentNode].terrain <> Impassable)

				if not OnLists(ID,adjacentNode,Tank)

					mapTable[adjacentNode].heuristic = Heuristic( Tank[ID].goalNode,adjacentNode )
					if (mapTable[adjacentNode].heuristic < currentCost) or (adjacentNode = Tank[ID].goalNode)
						Tank[ID].OpenList.insert(adjacentNode)
						Tank[ID].node = adjacentNode
						currentCost = mapTable[adjacentNode].heuristic
						terrainCost = mapTable[adjacentNode].cost
					endif
				endif
			else
				Tank[ID].ClosedList.insert(adjacentNode)
			endif
		next i

		if Tank[ID].team = AITeam			  `limit AI-AStar to one turn
			inc Tank[ID].moves,terrainCost
			if Tank[ID].moves >= Tank[ID].movesAllowed then exit
		endif
		inc Tank[ID].totalTerrainCost,terrainCost `used to track current move range
	loop
endfunction
//~ remend


remstart  this mirrors book version
function AStar(ID, Tank ref as tankType[])
	lowCost as Float
	totalCost as Float
	Tank[ID].OpenList.insert(Tank[ID].node)				`add the starting node to the open list

	while Tank[ID].OpenList.length <> Empty				`while the open list is not empty
		currentNode = Tank[ID].node						`current node = node from open list with the lowest cost
		Tank[ID].parentNode.insert(currentNode)
		lowCost = Unset

		if currentNode = Tank[ID].goalNode				`if current node = goal node then path complete
			exit
		else
			if Tank[ID].team = AITeam   	  			`limit AI-AStar to one turn
				inc Tank[ID].moves,terrainCost
				if Tank[ID].moves >= Tank[ID].movesAllowed then exit
			endif

			Tank[ID].ClosedList.insert(currentNode)		`move current node to the closed list
			for i = 0 to Tank[ID].OpenList.length
				if Tank[ID].OpenList[i] = currentNode
					Tank[ID].OpenList.remove(i)
					exit
				endif
			next i
			for i = 0 to 7								`examine each node adjacent to the current node
				adjacentNode = offset[i] + currentNode

				if not OnLists(ID,adjacentNode,Tank)	`if it isn't on the open list and isn't on the closed list

					if (mapTable[adjacentNode].terrain <> Impassable)	`and it isn't an obstacle then

						Tank[ID].OpenList.insert(adjacentNode)			`move it to open list and calculate cost

						mapTable[adjacentNode].heuristic = Heuristic(Tank[ID].goalNode,adjacentNode)

						nextCost# = mapTable[adjacentNode].heuristic + totalCost
						lastCost# = lowCost + totalCost
						if (nextCost# < lastCost#) or (adjacentNode = Tank[ID].goalNode)
							Tank[ID].node = adjacentNode
							lowCost = mapTable[adjacentNode].heuristic
							terrainCost = mapTable[adjacentNode].cost
						endif
					endif
				endif
			next i
			if lowCost <> Unset
				inc totalCost,lowCost 			  		  	`used to track cost from start
				inc Tank[ID].totalTerrainCost,terrainCost 	`used to track current move range
			endif
		endif
	endwhile
endfunction
remend



remstart
add the starting node to the open list
while the open list is not empty
{
	current node = node from open list with the lowest cost
	if current node = goal node then
		path complete
	else
		move current node to the closed list
		examine each node adjacent to the current node
		for each adjacent node
			if it isn't on the open list
			and isn't on the closed list
			and it isn't an obstacle then
			move it to open list and calculate cost
}


function AStar( ID, Tank ref as tankType[] ) //Wikipedia version; took map cost out of Heuristic function
    adjacentCost = Unset
    repeat
        if Tank[ID].node = Tank[ID].goalNode then exit

        if Tank[ID].OpenList.length > Empty
          for i = 0 to Tank[ID].OpenList.length
            if Tank[ID].OpenList[i] = Tank[ID].node
              Tank[ID].OpenList.remove(i)
              Tank[ID].ClosedList.insert(Tank[ID].node)
              exit
            endif
          next i
        endif

        for i = 0 to 7
		  adjacentNode = offset[i] + Tank[ID].node

          if (mapTable[adjacentNode].terrain = Impassable)
              Tank[ID].ClosedList.insert(adjacentNode)
              continue
          endif
          if OnList( adjacentNode, Tank[ID].ClosedList ) then continue

          mapTable[Tank[ID].node].heuristic = mapTable[Tank[ID].node].cost + Heuristic( Tank[ID].node,adjacentNode )

          if not OnList( adjacentNode, Tank[ID].OpenList )
              	Tank[ID].OpenList.insert(adjacentNode)
          elseif mapTable[Tank[ID].node].heuristic >= adjacentCost
                continue
          endif

          Tank[ID].parentNode.insert(Tank[ID].node)
          Tank[ID].node = adjacentNode
          adjacentCost = mapTable[Tank[ID].node].heuristic
          inc Tank[ID].totalTerrainCost,mapTable[adjacentNode].cost
        next i
    until Tank[ID].OpenList.length = -1
endfunction

function OnList( node, NodeList as integer[] ) `find on open or closed lists
    	List as integer[]
    	List = NodeList : NodeList.sort()
    	if List.find(node) <> -1
    		exitfunction True
    	else
    		exitfunction False
    	endif
endfunction False
remend




remstart  book version


add the starting node to the open list
while the open list is not empty
{
	current node = node from open list with the lowest cost
	if current node = goal node then
		path complete
	else
		move current node to the closed list
		examine each node adjacent to the current node
		for each adjacent node
			if it isn't on the open list
			and isn't on the closed list
			and it isn't an obstacle then
			move it to open list and calculate cost
}


function AStar(ID, Tank ref as tankType[])
	lowCost as Float
	totalCost as Float
	Tank[ID].OpenList.insert(Tank[ID].node)				`add the starting node to the open list

	while Tank[ID].OpenList.length <> Empty				`while the open list is not empty
		currentNode = Tank[ID].node						`current node = node from open list with the lowest cost
		Tank[ID].parentNode.insert(currentNode)
		lowCost = Unset

		if currentNode = Tank[ID].goalNode				`if current node = goal node then path complete
			exit
		else
			if Tank[ID].team = AITeam   	  			`limit AI-AStar to one turn
				inc Tank[ID].moves,terrainCost
				if Tank[ID].moves >= Tank[ID].movesAllowed then exit
			endif

			Tank[ID].ClosedList.insert(currentNode)		`move current node to the closed list
			for i = 0 to Tank[ID].OpenList.length
				if Tank[ID].OpenList[i] = currentNode
					Tank[ID].OpenList.remove(i)
					exit
				endif
			next i
			for i = 0 to 7								`examine each node adjacent to the current node
				adjacentNode = offset[i] + currentNode

				if not OnLists(ID,adjacentNode,Tank)	`if it isn't on the open list and isn't on the closed list

					if (mapTable[adjacentNode].terrain <> Impassable)	`and it isn't an obstacle then

						Tank[ID].OpenList.insert(adjacentNode)			`move it to open list and calculate cost

						mapTable[adjacentNode].heuristic = Heuristic(Tank[ID].goalNode,adjacentNode)

						nextCost# = mapTable[adjacentNode].heuristic + totalCost
						lastCost# = lowCost + totalCost
						if (nextCost# < lastCost#) or (adjacentNode = Tank[ID].goalNode)
							Tank[ID].node = adjacentNode
							lowCost = mapTable[adjacentNode].heuristic
							terrainCost = mapTable[adjacentNode].cost
						endif
					endif
				endif
			next i
			if lowCost <> Unset
				inc totalCost,lowCost 			  		  	`used to track cost from start
				inc Tank[ID].totalTerrainCost,terrainCost 	`used to track current move range
			endif
		endif
	endwhile
endfunction
remend
