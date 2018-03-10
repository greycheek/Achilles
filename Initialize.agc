
function ForceComposition( ID, Tank ref as tankType[], Grid as gridType[] )
	for i = 0 to Cells-1
		if Grid[i].imageID
			Tank[ID].vehicle = Grid[i].vehicle
			if Tank[ID].vehicle = Question then Tank[ID].vehicle = Random2(1,4)
			VehicleImage( ID,Tank )
			inc ID
		endif
	next i
endfunction

function VehicleImage( ID, Tank ref as tankType[] )
	select Tank[ID].vehicle
		case HoverCraft
			Tank[ID].body$ = "HovercraftSS.png"
			Tank[ID].turret$ = "HOVERTURRET.png"
		endcase
		case MediumTank
			Tank[ID].body$ = "GENMEDIUM300.png"
			Tank[ID].turret$ = "MEDIUMTURRET.png"
		endcase
		case HeavyTank
			Tank[ID].body$ = "GENHEAVY300.png"
			Tank[ID].turret$ = "HEAVYTURRET.png"
		endcase
		case Battery
			Tank[ID].body$ = "GENMISSILE300.png"
			Tank[ID].turret$ = "MISSILETURRET.png"
		endcase
		case Mech
			Tank[ID].body$ = "MechAtlas.png"
			Tank[ID].turret$ = "MechTurret.png"
		endcase
		case Engineer
			Tank[ID].body$ = "EngineerIV.png"
			Tank[ID].turret$ = "EngineerTurret.png"
		endcase
	endselect
endfunction

function Initialize()
	`FORCES
	ForceComposition(0,AITank,AIGrid)
	ForceComposition(0,PlayerTank,PlayerGrid)

	`PLAYER FORCE
	zone = floor((OpenRows/PlayerCount))
	for i = 0 to PlayerLast
		//~ randomColumn = Random2(1,10)
		z = (i*zone)+1
		randomRow = Random2(z,z+zone-1)
		PlayerTank[i].node = CalcNode( 1,randomRow ) `starting node

		mapTable[PlayerTank[i].node].team = PlayerTeam

			if PlayerTank[i].parentNode.length = -1
				PlayerTank[i].parentNode.insert(PlayerTank[i].node)
			else
				PlayerTank[i].parentNode[0] = PlayerTank[i].node
			endif
			PlayerTank[i].goalNode = PlayerTank[i].node

		PlayerTank[i].cover = PlayercoverSeries+i
		PlayerTank[i].team = PlayerTeam

		PlayerTank[i].bodyID = PlayerTankSeries+i
		PlayerTank[i].turretID = PlayerTurretSeries+i
		PlayerTank[i].bodyImageID = PlayerTank[i].bodyID
		PlayerTank[i].turretImageID = PlayerTank[i].turretID
		PlayerTank[i].healthID = PlayerHealthSeries+i
		PlayerTank[i].healthBarImageID = PlayerTank[i].healthID

		PlayerTank[i].hilite = HiliteSeries+i
		LoadImage(PlayerTank[i].hilite,"hilite45.png")
		CreateSprite( PlayerTank[i].hilite,PlayerTank[i].hilite )
		SetSpriteOffset(PlayerTank[i].hilite, NodeOffset, NodeOffset)
		SetSpriteSize(PlayerTank[i].hilite, NodeSize, NodeSize)
		SetSpriteTransparency( PlayerTank[i].hilite, 1 )
		SetSpriteVisible( PlayerTank[i].hilite, 0 )

		PlayerTank[i].bullsEye = TargetSeries+i
		LoadImage(PlayerTank[i].bullsEye,"bullsEye.png")
		CreateSprite( PlayerTank[i].bullsEye,PlayerTank[i].bullsEye )
		SetSpriteOffset(PlayerTank[i].bullsEye, NodeOffset, NodeOffset)
		SetSpriteSize(PlayerTank[i].bullsEye, NodeSize, NodeSize)
		SetSpriteTransparency( PlayerTank[i].bullsEye, 1 )
		SetSpriteVisible( PlayerTank[i].bullsEye, 0 )
		SetSpriteDepth( PlayerTank[i].bullsEye,0 )

		TankSetup(i,PlayerTank,pickPL)
						//~ SetSpriteVisible(PlayerTank[i].cover,Off)

		PlayerTank[i].FOW = FOWseries+i
		LoadImage(PlayerTank[i].FOW,"FOW.png")
		CreateSprite( PlayerTank[i].FOW,PlayerTank[i].FOW )
		SetSpriteDepth ( PlayerTank[i].FOW, 11 )
		SetSpriteTransparency( PlayerTank[i].FOW,1 )
		SetSpriteColor( PlayerTank[i].FOW,255,255,255,35)
		SetSpriteScissor( PlayerTank[i].FOW,NodeSize,NodeSize,MaxWidth-NodeSize,MaxHeight-(NodeSize*3) )
				SetSpriteCategoryBits(PlayerTank[i].FOW,NoBlock)


		SetSpriteSize( PlayerTank[i].FOW, PlayerTank[i].FOWSize, PlayerTank[i].FOWSize )

		SetSpriteGroup( PlayerTank[i].bodyID,PlayerTankGroup )
		SetSpriteGroup( PlayerTank[i].turretID,PlayerTankGroup )

		SetSpritePosition(PlayerTank[i].FOW, mapTable[PlayerTank[i].node].x-PlayerTank[i].FOWoffset, mapTable[PlayerTank[i].node].y-PlayerTank[i].FOWoffset)
		SetSpriteVisible(PlayerTank[i].FOW,Off)
		SetSpriteAngle(PlayerTank[i].bodyID,90)
		SetSpriteAngle(PlayerTank[i].turretID,90)

		Produce(i,PlayerTank,5,0,Null,pickPL)
	next i

	`AI FORCE
	zone = floor((OpenRows/AICount))
	topZone = floor(AiCount/2)
	for i = 0 to AIPlayerLast
		randomColumn = Random2(20,OpenColumns) : z = (i*zone)+1
		randomRow = Random2(z,z+zone-1)
		AITank[i].node = CalcNode( OpenColumns,randomRow ) `starting node

			if AITank[i].parentNode.length = -1
				AITank[i].parentNode.insert(AITank[i].node)
			else
				AITank[i].parentNode[0] = AITank[i].node
			endif
			AITank[i].goalNode = AITank[i].node

		AITank[i].team = AITeam
		mapTable[AITank[i].node].team = AITeam

		AITank[i].bodyID = AITankSeries+i
		AITank[i].turretID = AITurretSeries+i
		AITank[i].cover = AICoverSeries+i
		AITank[i].bodyImageID = AITank[i].bodyID
		AITank[i].turretImageID = AITank[i].turretID
		AITank[i].healthID = AIHealthSeries+i
		AITank[i].healthBarImageID = AITank[i].healthID

		TankSetup(i,AITank,pickAI)

		if AITank[i].vehicle <> Hovercraft then AITank[i].route = AStar(i,AITank)
					SetSpriteVisible(AITank[i].bodyID,Off)
					SetSpriteVisible(AITank[i].turretID,Off)
					SetSpriteVisible(AITank[i].stunMarker,Off)
		//~ SetSpriteVisible(AITank[i].healthID,Off) `keep off
		SetSpriteAngle(AITank[i].bodyID,270)
		SetSpriteAngle(AITank[i].turretID,270)
	next i
endfunction

function TankSetup(ID,Tank ref as tankType[],pick as ColorSpec)
	select Tank[ID].vehicle
		case HeavyTank
			Tank[ID].speed = .4
			Tank[ID].sound = TankSound
			Tank[ID].volume = vol
			Tank[ID].weapon = heavyCannon
			Tank[ID].range = heavyCannonRange
			Tank[ID].damage = heavyCannonDamage
			Tank[ID].rounds = True					`set to non-zero value
			Tank[ID].movesAllowed = 3
			Tank[ID].health = HeavyHealthMax
			Tank[ID].minimumHealth = HeavyHealthMax *.33
			Tank[ID].maximumHealth = HeavyHealthMax
		endcase
		case MediumTank
			Tank[ID].speed = .3
			Tank[ID].sound = TankSound
			Tank[ID].volume = vol
			Tank[ID].weapon = cannon
			Tank[ID].range = cannonRange
			Tank[ID].damage = cannonDamage
			Tank[ID].rounds = True
			Tank[ID].movesAllowed = 5
			Tank[ID].health = MediumHealthMax
			Tank[ID].minimumHealth = MediumHealthMax *.33
			Tank[ID].maximumHealth = MediumHealthMax
		endcase
		case HoverCraft
			Tank[ID].speed = .5
			Tank[ID].sound = EngineSound
			Tank[ID].volume = EngineVolume
			Tank[ID].weapon = machineGun
			Tank[ID].range = machineGunRange
			Tank[ID].damage = machineGunDamage
			Tank[ID].rounds = True
			Tank[ID].movesAllowed = FlyRadius
			Tank[ID].health = LightHealthMax
			Tank[ID].minimumHealth = LightHealthMax *.33
			Tank[ID].maximumHealth = LightHealthMax
		endcase
		case Battery
			Tank[ID].speed = .3
			Tank[ID].sound = TankSound
			Tank[ID].volume = vol
			Tank[ID].weapon = missile
			Tank[ID].range = missileRange
			Tank[ID].damage = missileDamage
			Tank[ID].rounds = 9
			Tank[ID].movesAllowed = 6
			Tank[ID].health = BatteryHealthMax
			Tank[ID].minimumHealth = BatteryHealthMax *.33
			Tank[ID].maximumHealth = BatteryHealthMax
		endcase
		case Mech
			Tank[ID].speed = .4
			Tank[ID].sound = MechSound
			Tank[ID].volume = MechVolume
			Tank[ID].weapon = disruptor
			Tank[ID].range = disruptorRange
			Tank[ID].damage = disruptorDamage
			Tank[ID].rounds = 5
			Tank[ID].movesAllowed = 4
			Tank[ID].health = MediumHealthMax
			Tank[ID].minimumHealth = MediumHealthMax *.33
			Tank[ID].maximumHealth = MediumHealthMax
		endcase
		case Engineer
			Tank[ID].speed = .2
			Tank[ID].sound = EngineerSound
			Tank[ID].volume = EngineerVolume
			Tank[ID].weapon = Undefined
			Tank[ID].range = empRange
			Tank[ID].damage = empDamage
			Tank[ID].rounds = 4
			Tank[ID].movesAllowed = 4
			Tank[ID].health = EngineerHealthMax
			Tank[ID].minimumHealth = EngineerHealthMax *.33
			Tank[ID].maximumHealth = EngineerHealthMax
		endcase
	endselect

	Tank[ID].missiles = Tank[ID].rounds
	Tank[ID].mines = Tank[ID].rounds
	Tank[ID].charges = Tank[ID].rounds
	Tank[ID].index = 0
	Tank[ID].moves = 0
	Tank[ID].alive = True
	Tank[ID].x = mapTable[Tank[ID].node].x
	Tank[ID].y = mapTable[Tank[ID].node].y
	Tank[ID].target = Undefined
	Tank[ID].stunned = Null

	Tank[ID].OpenList.insert(Tank[ID].node)
	Tank[ID].NearestPlayer = Unset
	Tank[ID].bodyW=NodeSize
	Tank[ID].bodyH=NodeSize
	Tank[ID].turretW=NodeSize
	Tank[ID].turretH=NodeSize
	Tank[ID].scale = 1

	Tank[ID].FOWOffset = ( NodeSize * Tank[ID].movesAllowed ) + ( NodeSize / 2 )
	Tank[ID].FOWSize = Tank[ID].FOWOffset * 2

	Tank[ID].stunMarker = CloneSprite( StunSeries )

	LoadImage(Tank[ID].cover,"TreeSpray.png")	`vehicle cover
	CreateSprite(Tank[ID].cover,Tank[ID].cover )
	SetSpriteColorAlpha(Tank[ID].cover,CoverAlpha )
	SetSpriteDepth(Tank[ID].cover,1 )
	SetSpriteSize(Tank[ID].cover,NodeSize*.75,NodeSize*.75 )
	SetSpriteVisible(Tank[ID].cover,Off)

	LoadImage(Tank[ID].bodyImageID, Tank[ID].body$)
	LoadImage(Tank[ID].turretImageID, Tank[ID].turret$)
	LoadImage(Tank[ID].healthBarImageID,"health3.png")

	CreateSprite(Tank[ID].bodyID, Tank[ID].bodyImageID)
	SetSpritePhysicsOn(Tank[ID].bodyID,1)
	SetSpritePhysicsOn(Tank[ID].turretID,1)
	SetSpriteCategoryBits( Tank[ID].bodyID,NoBlock )
	SetSpriteCategoryBits( Tank[ID].turretID,NoBlock )
	CreateSprite(Tank[ID].turretID, Tank[ID].turretImageID)
	CreateSprite(Tank[ID].healthID, Tank[ID].healthBarImageID)
	SetSpriteCategoryBits(Tank[ID].healthID,NoBlock)
	SetSpriteVisible(Tank[ID].healthID,Off)

	SetSpriteSize(Tank[ID].bodyID, Tank[ID].bodyW*Tank[ID].scale, Tank[ID].bodyH*Tank[ID].scale)
	SetSpriteSize(Tank[ID].turretID, Tank[ID].turretW*Tank[ID].scale, Tank[ID].turretH*Tank[ID].scale)

	SetSpriteOffset(Tank[ID].bodyID, NodeOffset, NodeOffset)
	SetSpriteOffset(Tank[ID].turretID, NodeOffset, NodeOffset)

			SetSpriteShapeBox(Tank[ID].bodyID,-NodeOffset,-NodeOffset,NodeOffset,NodeOffset,0)
			SetSpriteShapeBox(Tank[ID].turretID,-NodeOffset,-NodeOffset,NodeOffset,NodeOffset,0)

	SetSpriteDepth(Tank[ID].healthID,1)
	SetSpriteDepth(Tank[ID].turretID,3)
	SetSpriteDepth(Tank[ID].bodyID,3)
	SetSpriteColor(Tank[ID].bodyID,pick.r,pick.g,pick.b,pick.a)

	SetSpritePositionByOffset(Tank[ID].bodyID, Tank[ID].x, Tank[ID].y)
	SetSpritePositionByOffset(Tank[ID].turretID, Tank[ID].x, Tank[ID].y)

	select Tank[ID].Vehicle
		case HoverCraft
			SetSpriteAnimation( Tank[ID].bodyID,246,273,40 )
			PlaySprite( Tank[ID].bodyID,14,0,1,1 )
			SetSpriteDepth( Tank[ID].turretID,2 )
			SetSpriteDepth( Tank[ID].bodyID,2 )
		endcase
		case Mech 	  : SetSpriteAnimation( Tank[ID].bodyID,357,321,15 ) : endcase
		case Engineer : SetSpriteAnimation( Tank[ID].bodyID,200,200,16 ) : endcase
	endselect
endfunction

function CalcNode(x#,y#)	`node coordinates
	node = (x# + (Columns * y#))
endfunction node

function CalcNodeFromScreen(x#,y#)	`screen coordinates
	node = floor(x#/NodeSize) + (floor(y#/NodeSize)*Columns)
endfunction node

remstart
	SetSpriteVisible(AITank[i].cover,Off)
	Patrol(i)
remend

