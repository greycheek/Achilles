
remstart

remend

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

function Patrol(ID)
	v = Random2(0,7)					  `Random starting vector
	for j = PatrolRadius to 1 step -1	  `Linear search
		for i = 0 to 7					  `Circular search
			node = AITank[ID].parentNode[AITank[ID].index] + (patrolScan[ v+i ] * j)  `Advance to next node vector
			node = MinMax(1,OpenMapSize,node)
			if (mapTable[node].terrain <> Impassable) //and (mapTable[node].team = Unoccupied) //TURN OFF OCCUPY CHECK????
				AITank[ID].goalNode = node
				exitfunction
			endif
		next i
	next j
endfunction

function AIBaseProduction()
	i = Random2(0,AIBaseCount)
	if AIProdUnits > 0
		if maptable[AIBases[i].node].team = Unoccupied
			randomUnitType = Random2( LightTank,Engineer )
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
		xa = AITank[ID].x - AITank[ID].FOWOffset
		ya = AITank[ID].y - AITank[ID].FOWOffset
		xb = AITank[ID].x + AITank[ID].FOWOffset
		yb = AITank[ID].y + AITank[ID].FOWOffset

		if GetSpriteInBox( PlayerTank[j].bodyID,xa,ya,xb,yb )
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
							case LightTank
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
								if AITank[i].missiles
									dec AITank[i].missiles
									WeaponSelect(i,AITank,missile,missileRange,missileDamage)
								else
									WeaponSelect(i,AITank,heavyLaser,heavyLaserRange,heavyLaserDamage)
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
			SetSpriteVisible(AITank[ID].bodyID,On)
			SetSpriteVisible(AITank[ID].turretID,On)

						if mapTable[ AITank[ID].parentNode[AITank[ID].index] ].terrain = Trees
							SetSpriteVisible(AITank[ID].cover,On)
							SetSpritePositionByOffset(AITank[ID].cover,AITank[ID].x,AITank[ID].y)
						endif
			if AITank[ID].stunned then SetSpriteVisible(AITank[ID].stunMarker,On)
			HealthBar(ID,AITank)
			exitfunction True
		endif
	next i
						SetSpriteVisible(AITank[ID].bodyID,Off)
						SetSpriteVisible(AITank[ID].turretID,Off)
						SetSpriteVisible(AITank[ID].healthID,Off)
						SetSpriteVisible(AITank[ID].stunMarker,Off)
endfunction False

function GoalSet(ID,vehicle)
	select vehicle
		case HeavyTank
			if VisitDepot(ID)  then exitfunction
			if ProtectBase(ID) then exitfunction
			if AttackBase(ID)  then exitfunction
			DefaultGoal(ID,1)
		endcase
		case MediumTank
			if VisitDepot(ID)  then exitfunction
			if ProtectBase(ID) then exitfunction
			if AttackBase(ID)  then exitfunction
			DefaultGoal(ID,1)
		endcase
		case LightTank
			if VisitDepot(ID)  then exitfunction
			if ProtectBase(ID) then exitfunction
			if AttackBase(ID)  then exitfunction
			DefaultGoal(ID,2)
		endcase
		case Battery
			if VisitDepot(ID) then exitfunction
			if AttackBase(ID) then exitfunction
			DefaultGoal(ID,3)
		endcase
		case Mech
			if VisitDepot(ID)  then exitfunction
			if ProtectBase(ID) then exitfunction
			if AttackBase(ID)  then exitfunction
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
				distance = VectorDistance( AITank[ID].x,AITank[ID].y, mapTable[AIDepotNode[i].node].x, mapTable[AIDepotNode[i].node].y )
				if distance < shortestRange
					shortestRange = distance
					AITank[ID].goalNode = AIDepotNode[i].node
					//~ AITank[ID].NearestPlayer = Unset
					AITank[ID].route = PlanMove(ID,AITank)
					exitfunction True
				endif
			next i
			//~ AITank[ID].NearestPlayer = Unset
			//~ AITank[ID].route = PlanMove(ID,AITank)
		endif
	endif
endfunction False

function ProtectBase(ID)
	if AIBaseCount < 2
		for i = 0 to AIBaseCount	 `friendly base
			if mapTable[AIBases[i].node].team then continue `friendly tank already at base?
			for j = 0 to PlayerCount
				if  GetSpriteCollision( AIBases[i].zoneID, PlayerTank[j].bodyID )
					AITank[ID].goalNode = AIBases[i].node
					//~ AITank[ID].NearestPlayer = Unset
					AITank[ID].route = PlanMove(ID,AITank)
					exitfunction True
				endif
			next j
		next i
	endif
endfunction False

function AttackBase(ID)
	for i = 0 to PlayerBaseCount
		if  GetSpriteCollision( PlayerBases[i].zoneID, AITank[ID].bodyID ) and ( mapTable[PlayerBases[i].node].team = Unoccupied )
			AITank[ID].goalNode = PlayerBases[i].node
			//~ AITank[ID].NearestPlayer = Unset
			AITank[ID].route = PlanMove(ID,AITank)
			exitfunction True
		endif
	next i
endfunction False

function DefaultGoal(ID,standOff)
	NearestPlayer = FindEnemy(ID)
	if (NearestPlayer <> Unset) //and (AITank[ID].NearestPlayer <> Nearestplayer)
		AITank[ID].NearestPlayer = Nearestplayer
		AITank[ID].goalNode = PlayerTank[NearestPlayer].parentNode[PlayerTank[NearestPlayer].index]

		AITank[ID].route = PlanMove(ID,AITank)
		if AITank[ID].parentNode.length > standOff
			for i = 0 to standOff : AITank[ID].parentNode.remove() : next i `stay at least 'standOff nodes + 1' away from enemy
			AITank[ID].goalNode = AITank[ID].parentNode[AITank[ID].parentNode.length]
		endif
	elseif (AITank[ID].parentNode[AITank[ID].index] = AITank[ID].goalNode) or (AITank[ID].route = NoPath)
		Patrol(ID)
		AITank[ID].route = PlanMove(ID,AITank)
	endif
endfunction


function PlanMove(ID, Tank ref as tankType[])
	ResetPath(ID,AITank)
	AITank[ID].route = AStar(ID,AITank)
endfunction AITank[ID].route


function AIOps()
	AIBaseProduction()
	AITarget()
	Text(MovingText,"moving",MiddleX,MiddleY,255,255,255,36,255,1)
	tt = SetTweenText( 255,0,MovingText,2,1 )

	for i = 0 to AIPlayerLast
		if not AITank[i].alive then continue
		if AITank[i].stunned
			dec AITank[i].stunned
			continue
		endif
		GoalSet(i,AITank[i].vehicle)

		AITank[i].totalTerrainCost = Null

		//~ bestPosition = BestTacticalPosition(i,AITank)
		do
			if AITank[i].index < AITank[i].parentNode.length
				SetSpriteVisible(AITank[i].healthID,Off)

				nextMove = AITank[i].parentNode[AITank[i].index+1]

				if mapTable[nextMove].team = Unoccupied

					//~ if (mapTable[AITank[i].goalNode].terrain = AIDepot) or (AITank[i].index <= bestPosition)
						//~ AIFOW(i)

						if AITank[i].totalTerrainCost >= AITank[i].movesAllowed
							//~ AITank[i].route = PlanMove(i,AITank)
							exit
						elseif AITank[i].parentNode[AITank[i].index] = AITank[i].goalNode
							exit
						else
							Move( i, AITank, AITank[i].parentNode[AITank[i].index], nextMove )
							if MineField( i,AITank ) and (not AITank[i].alive) then exit
						endif
					//~ else
						//~ exit
					//~ endif
				else
					AITank[i].route = PlanMove(i,AITank)
					exit
				endif
			else
				exit
			endif
			if not GetTweenTextPlaying( tt,MovingText ) then tt = SetTweenText( 255,0,MovingText,2,1 )
		loop
		AIFOW(i)
	next i
	DeleteText(MovingText)
	for i = 0 to AIPlayerLast
		if not AITank[i].alive then continue
		RepairDepot( i,AITank,AIDepotNode,AIDepot,AITank[i].maximumHealth ) `at depot?
		VictoryConditions( i,AITank )
		AIFOW(i)
	next i
	SetRawMouseVisible(On)
endfunction


remstart
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

