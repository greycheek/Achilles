
function AISpawn( vehicle,node )
	inc AICount
	inc AIPlayerLast
	inc AISurviving
	ID = AIPlayerLast
	AITank.length = AICount
	AITank[ID].vehicle = vehicle
	AITank[ID].node = node
	VehicleImage( ID,AITank )

	mapTable[AITank[ID].node].team = AITeam

	AITank[ID].goalNode = AITank[ID].node
	AITank[ID].parentNode.insert(AITank[ID].node)
	AITank[ID].team = AITeam
	AITank[ID].cover = AICoverSeries + AICount
	AITank[ID].bodyID = AITankSeries + AICount
	AITank[ID].turretID = AITurretSeries + AICount
	AITank[ID].bodyImageID = AITank[ID].bodyID
	AITank[ID].turretImageID = AITank[ID].turretID
	AITank[ID].healthID = AIHealthSeries + AICount
	AITank[ID].healthBarImageID = AITank[ID].healthID

	TankSetup(ID,AITank,pickAI)
	SetSpriteVisible(AITank[ID].bodyID,Off)
	SetSpriteVisible(AITank[ID].turretID,Off)
	SetSpriteVisible(AITank[ID].cover,Off)
	SetSpriteGroup(AITank[ID].bodyID, AITankGroup)
	SetSpriteGroup(AITank[ID].turretID, AITankGroup)
	SetSpriteAngle(AITank[ID].bodyID,270)
	SetSpriteAngle(AITank[ID].turretID,270)
	dec AIProdUnits,unitCost[vehicle]
endfunction ID

function AIBaseProduction()
	i = Random2(0,AIBaseCount)
	if AIProdUnits > 0
		if maptable[AIBases[i].node].team = Unoccupied
			randomUnitType = Random2( HoverCraft,Engineer )
			if ( AIProdUnits - unitCost[randomUnitType] ) >= 0
				ID = AISpawn( randomUnitType,AIBases[i].node )
				if AIFOW(ID) then Produce( ID,AITank,1,1,AIBases[i].spriteID,pickAI )
			endif
		endif
	endif
endfunction

function FindEnemy(ID)
	ShortestDistance = Unset
	NearestPlayer = Unset

	for j = 0 to PlayerLast
		if not PlayerTank[j].alive then continue
		SetFOWbox( ID,AITank )

		if GetSpriteInBox( PlayerTank[j].bodyID,box.x1,box.y1,box.x2,box.y2 )
			//~ if not GetSpriteVisible(AITank[ID].bodyID)
				//~ SetSpriteVisible(AITank[ID].bodyID,On)
				//~ SetSpriteVisible(AITank[ID].turretID,On)
			//~ endif
			vd = VectorDistance(AITank[ID].x,AITank[ID].y,PlayerTank[j].x,PlayerTank[j].y)
			if vd < ShortestDistance
				ShortestDistance = vd
				NearestPlayer = j
			endif
		endif
	next j
endfunction NearestPlayer

function AITarget()
	for i = 0 to AIPlayerLast
				AIFOW(i)
		if not AITank[i].alive then continue
		if not AITank[i].stunned
			StopSprite(AITank[i].stunMarker )
			SetSpriteVisible( AITank[i].stunMarker, Off )
		else
			continue
		endif

			AITank[i].NearestPlayer = FindEnemy(i)

		if AITank[i].NearestPlayer <> Unset
			x1 = AITank[i].x
			y1 = AITank[i].y
			if VectorDistance(x1,y1,PlayerTank[AITank[i].NearestPlayer].x,PlayerTank[AITank[i].NearestPlayer].y) <= AITank[i].range

				if PlayerTank[AITank[i].NearestPlayer].alive
					if AITank[i].vehicle = Engineer
						if Random2(0,1) and AITank[i].mines
							WeaponSelect(i,AITank,mine,empRange,mineDamage)
						elseif AITank[i].charges
							friendly = Null
							xa = AITank[i].x - empRange
							ya = AITank[i].y - empRange
							xb = AITank[i].x + empRange
							yb = AITank[i].y + empRange
							for j = 0 to AIPlayerLast
								if j = i then continue
								friendly = friendly or GetSpriteInBox( AITank[j].bodyID,xa,ya,xb,yb )
							next j
							if not friendly
								WeaponSelect( i,AITank,emp,empRange,empDamage )
								Fire( AITank,PlayerTank,i,Null )
							endif
							continue
						else
							continue
						endif
					elseif not LOSblocked(x1,y1,PlayerTank[AITank[i].NearestPlayer].x,PlayerTank[AITank[i].NearestPlayer].y)

						select AITank[i].vehicle
							case Battery
								if AITank[i].missiles
									dec AITank[i].missiles
									WeaponSelect(i,AITank,missile,missileRange,missileDamage)
								endif
							endcase
							case HoverCraft
								WeaponSelect(i,AITank,laser,laserRange,laserDamage)
							endcase
							case MediumTank
								if VectorDistance(x1,y1,PlayerTank[AITank[i].NearestPlayer].x,PlayerTank[AITank[i].NearestPlayer].y) <= cannonRange
									WeaponSelect(i,AITank,cannon,cannonRange,cannonDamage)
								else
									WeaponSelect(i,AITank,laser,laserRange,laserDamage)
								endif
							endcase
							case HeavyTank
								if VectorDistance(x1,y1,PlayerTank[AITank[i].NearestPlayer].x,PlayerTank[AITank[i].NearestPlayer].y) <= cannonRange
									WeaponSelect(i,AITank,heavyCannon,heavyCannonRange,heavyCannonDamage)
								else
									WeaponSelect(i,AITank,heavyLaser,heavyLaserRange,heavyLaserDamage)
								endif
							endcase
							case Mech
								if VectorDistance(x1,y1,PlayerTank[AITank[i].NearestPlayer].x,PlayerTank[AITank[i].NearestPlayer].y) <= disruptorRange
									WeaponSelect(I,AITank,disruptor,disruptorRange,disruptorDamage)
								elseif AITank[i].missiles
									dec AITank[i].missiles
									WeaponSelect(i,AITank,missile,missileRange,missileDamage)
								endif
							endcase
						endselect
					else
						continue
					endif
					AITank[i].target = AITank[i].NearestPlayer
					Fire( AITank,PlayerTank,i,AITank[i].NearestPlayer )
				else
					AITank[i].target = Undefined
				endif
			endif
		endif
	next i
endfunction

function AIFOW(ID)
	for i = 0 to PlayerLast
		if PlayerTank[i].alive and GetSpriteInCircle(AITank[ID].bodyID,PlayerTank[i].x,PlayerTank[i].y,PlayerTank[i].FOWOffset-NodeSize)
			RevealAIUnit(ID)
			exitfunction True
		endif
	next i
				//~ SetSpriteVisible(AITank[ID].bodyID,Off)
				//~ SetSpriteVisible(AITank[ID].turretID,Off)
				//~ SetSpriteVisible(AITank[ID].healthID,Off)
				//~ SetSpriteVisible(AITank[ID].stunMarker,Off)
				//~ SetSpriteVisible(AITank[ID].cover,Off)
endfunction False

function GoalSet(ID,vehicle)
	select vehicle
		case HeavyTank
			if VisitDepot(ID)  then exitfunction
			if AttackBase(ID)  then exitfunction
			if ProtectBase(ID) then exitfunction
			DefaultGoal(ID,1)
		endcase
		case MediumTank
			if VisitDepot(ID)  then exitfunction
			if AttackBase(ID)  then exitfunction
			if ProtectBase(ID) then exitfunction
			DefaultGoal(ID,1)
		endcase
		case HoverCraft
			if VisitDepot(ID)  then exitfunction
			if AttackBase(ID)  then exitfunction
			if ProtectBase(ID) then exitfunction
			DefaultGoal(ID,2)
		endcase
		case Battery
			if VisitDepot(ID) then exitfunction
			if AttackBase(ID) then exitfunction
			DefaultGoal(ID,3)
		endcase
		case Mech
			if VisitDepot(ID)  then exitfunction
			if AttackBase(ID)  then exitfunction
			if ProtectBase(ID) then exitfunction
			DefaultGoal(ID,1)
		endcase
		case Engineer
			if VisitDepot(ID) then exitfunction
			if AttackBase(ID) then exitfunction
			DefaultGoal(ID,3)
		endcase
	endselect
endfunction

function VisitDepot(ID)
	if AIDepotNode.length <> -1
		if (AITank[ID].health <= AITank[ID].minimumHealth) or (not AITank[ID].missiles) or (not AITank[ID].mines) or (not AITank[ID].charges)
			shortestRange = Unset
			for i = 0 to AIDepotNode.length

				if AITank[ID].vehicle = HoverCraft
					if not GetSpriteInCircle( AIDepotNode[i].spriteID, AITank[ID].x, AITank[ID].y, AITank[ID].FOWOffset-NodeSize )
						continue
					endif
				endif
				distance = VectorDistance( AITank[ID].x, AITank[ID].y, mapTable[AIDepotNode[i].node].x, mapTable[AIDepotNode[i].node].y )
				if distance < shortestRange
					shortestRange = distance
					targetDepot = AIDepotNode[i].node
				endif
			next i

			if shortestRange = Unset  `For Hovercraft - no depot in range
				Patrol(ID)
				exitfunction True
			endif

			AITank[ID].goalNode = targetDepot
			if AITank[ID].vehicle <> HoverCraft then AITank[ID].route = PlanMove(ID)
			//~ if AITank[ID].route = NoPath then NewGoal(ID)
			exitfunction True
		endif
	endif
endfunction False

function ProtectBase(ID)	`routine to select other than 1st base examined?
	for i = 0 to AIBaseCount	 `friendly base
		if mapTable[AIBases[i].node].team then continue `friendly tank already at base?
		for j = 0 to PlayerCount
			if  GetSpriteInBox( PlayerTank[j].bodyID, AIBases[i].x1, AIBases[i].y1, AIBases[i].x2, AIBases[i].y2 )

				if AITank[ID].vehicle = HoverCraft
					if not GetSpriteInCircle( AIBases[i].node,AITank[ID].x,AITank[ID].y,AITank[ID].FOWOffset-NodeSize )	`WAS PlayerTank[j].bodyID IN CIRCLE
						continue
					else
						AITank[ID].goalNode = AIBases[i].node
						exitfunction True
					endif
				else
					AITank[ID].goalNode = AIBases[i].node
					AITank[ID].route = PlanMove(ID)
					//~ if AITank[ID].route = NoPath then NewGoal(ID)
					exitfunction True
				endif
			endif
		next j
	next i
endfunction False

function AttackBase(ID)
	for i = 0 to PlayerBaseCount
		if  GetSpriteInCircle( PlayerBases[i].spriteID,AITank[ID].x,AITank[ID].y,AITank[ID].FOWOffset-NodeSize )
			if mapTable[PlayerBases[i].node].team = Unoccupied
				AITank[ID].goalNode = PlayerBases[i].node
				if AITank[ID].vehicle <> HoverCraft then AITank[ID].route = PlanMove(ID)
				//~ if AITank[ID].route = NoPath then NewGoal(ID)
				exitfunction True
			endif
		endif
	next i
endfunction False

function DefaultGoal(ID,standOff)
	if AITank[ID].vehicle = Hovercraft
		if AITank[ID].NearestPlayer <> Unset
			AITank[ID].goalNode = PlayerTank[AITank[ID].NearestPlayer].node
		else
			Patrol(ID)
		endif
		exitfunction
	endif

	if (AITank[ID].NearestPlayer <> Unset) //and (AITank[ID].NearestPlayer <> Nearestplayer)
		AITank[ID].goalNode = PlayerTank[AITank[ID].NearestPlayer].parentNode[PlayerTank[AITank[ID].NearestPlayer].index]

		AITank[ID].route = PlanMove(ID)
		if AITank[ID].parentNode.length > standOff
			for i = 0 to standOff : AITank[ID].parentNode.remove() : next i `stay at least 'standOff nodes + 1' away from enemy
			AITank[ID].goalNode = AITank[ID].parentNode[AITank[ID].parentNode.length]
		endif

	elseif (AITank[ID].parentNode[AITank[ID].index] = AITank[ID].goalNode) or (AITank[ID].route = NoPath)
		Patrol(ID)
		PlanMove(ID)
	endif
endfunction

function Patrol(ID)
	v = Random2( 0,7 )                  `Random start vector
	for j = AITank[ID].FOWOffset to 1 step -1   `Linear search	START INDEX WAS PATROLRADIUS
		for i = 0 to 7                  `Circular search
			nextNode=patrolScan[v+i]*j  `Next inward vector

			node = AITank[ID].parentNode[ AITank[ID].index ] + nextNode
			SetFOWbox( ID,AITank )
			x = mod(node,Columns) * NodeSize
			y = floor(node/Columns) * NodeSize
			if ( x > box.x2 ) or ( x < box.x1 ) then continue
			if ( y > box.y2 ) or ( y < box.y1 ) then continue

			if ( mapTable[node].terrain < Impassable ) //and (mapTable[node].team = Unoccupied)
				AITank[ID].goalNode = node
				exitfunction
			endif
		next i
	next j
endfunction

function PlanMove(ID)
	ResetPath(ID,AITank)
	AITank[ID].route = AStar(ID,AITank)
endfunction AITank[ID].route

function AIOps()
	if AISurviving < UnitLimit then AIBaseProduction()
	AITarget()
	Text(MovingText,"moving",MiddleX,MiddleY,255,255,255,36,255,1)
	tt = TweenText( MovingText,Null,Null,Null,Null,255,0,Null,Null,Null,Null,1,0,2 )

	for i = 0 to AIPlayerLast
		if not AITank[i].alive then continue
		if AITank[i].stunned
			dec AITank[i].stunned
			continue
		endif
		GoalSet(i,AITank[i].vehicle)
		AITank[i].totalTerrainCost = Null
		do
			if AITank[i].vehicle = Hovercraft
				if mapTable[AITank[i].goalNode].team = Unoccupied
					if AITank[i].node <> AITank[i].goalNode
						SetSpriteVisible(AITank[i].healthID,Off)
						Fly( i,AITank,AITank[i].node,AITank[i].goalNode )
						MineField( i,AITank )
					endif
				endif
				exit
			elseif AITank[i].index < AITank[i].parentNode.length
				SetSpriteVisible(AITank[i].healthID,Off)

				nextMove = AITank[i].parentNode[AITank[i].index+1]

				if mapTable[nextMove].team = Unoccupied
					if AITank[i].totalTerrainCost >= AITank[i].movesAllowed
						exit
					elseif AITank[i].parentNode[AITank[i].index] = AITank[i].goalNode `is this necessary?
						exit
					else
						Move( i,AITank,AITank[i].parentNode[AITank[i].index],nextMove )
						if MineField( i,AITank ) then exit
					endif
				else
					AITank[i].route = PlanMove(i)
					exit
				endif
			else
				exit
			endif
			if not GetTweenTextPlaying( tt,MovingText ) then tt = TweenText( MovingText,Null,Null,Null,Null,255,0,Null,Null,Null,Null,1,0,2 )
		loop
		PlayerBaseCapture()
		AIFOW(i)
		if GetSpriteVisible( AITank[i].bodyID )
			if AITank[i].Vehicle = Hovercraft then Hover( i,AITank )
		endif
	next i
	DeleteText(MovingText)
	for i = 0 to AIPlayerLast
		if not AITank[i].alive then continue
		RepairDepot( i,AITank,AIDepotNode,AIDepot,AITank[i].maximumHealth ) `at depot?
		AIFOW(i)
	next i
	SetRawMouseVisible(On)
endfunction


remstart
FROM FIND ENEMY
		xa = AITank[ID].x - AITank[ID].FOWOffset
		ya = AITank[ID].y - AITank[ID].FOWOffset
		xb = AITank[ID].x + AITank[ID].FOWOffset
		yb = AITank[ID].y + AITank[ID].FOWOffset

			if AITank[ID].vehicle = Hovercraft
				v# = VectorDistance( AITank[ID].x,AITAnk[ID].y,mapTable[AITank[ID].goalNode].x,mapTable[AITank[ID].goalNode].x )
				if v# > AITank[ID].FOWOffset
				endif
			endif

from AIFOW
		SetSpriteVisible(AITank[ID].bodyID,On)
		SetSpriteVisible(AITank[ID].turretID,On)

		if mapTable[ AITank[ID].parentNode[AITank[ID].index] ].terrain = Trees
			SetSpriteVisible(AITank[ID].cover,On)
			SetSpritePositionByOffset(AITank[ID].cover,AITank[ID].x,AITank[ID].y)
		endif
		if AITank[ID].stunned then SetSpriteVisible(AITank[ID].stunMarker,On)
		HealthBar(ID,AITank)

from ProtectBase and VisitDepot and AttackBase:
				AITank[ID].NearestPlayer = Unset

old version:
function BestTacticalPosition(ID,Tank ref as tankType[])
	pathLength = Tank[ID].parentNode.length-1
	bestPosition = pathlength
	highWeight = 0
	if pathLength > 0
		for i = pathLength to Tank[ID].index step -1
			if mapTable[Tank[ID].parentNode[i]].cost > highweight
				highWeight = mapTable[Tank[ID].parentNode[i]].cost
				bestPosition = i
			endif
		next i
	endif
endfunction bestPosition

remend

