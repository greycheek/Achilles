
function BaseColor()
	`BASE & DEPOT COLOR
	for i = 0 to PlayerBaseCount  : SetSpriteColor(PlayerBases[i].spriteID,pickPL.r,pickPL.g,pickPL.b,pickPL.a) : next i
	for i = 0 to AIBaseCount      : SetSpriteColor(AIBases[i].spriteID,pickAI.r,pickAI.g,pickAI.b,pickAI.a) : next i
	for i = 0 to PlayerDepotCount : SetSpriteColor(PlayerDepotNode[i].spriteID,pickPL.r,pickPL.g,pickPL.b,pickPL.a) : next i
	for i = 0 to AIDepotCount     : SetSpriteColor(AIDepotNode[i].spriteID,pickAI.r,pickAI.g,pickAI.b,pickAI.a) : next i
endfunction

function BaseSetup( spriteID, node, base, baseRef ref as baseType[],group )
	baseRef.length = baseRef.length + 1
	ID = baseRef.length
	baseRef[ID].node = node
	baseRef[ID].spriteID = spriteID
	maptable[node].base = base
	mapTable[node].terrain = base
	//~ mapTable[node].team = team

	LoadImage( baseRef[ID].spriteID,"HEXBASE.png" )
	CreateSprite( baseRef[ID].spriteID,baseRef[ID].spriteID )
	//~ SetSpritePhysicsOn( baseRef[ID].spriteID, On )
	SetSpriteTransparency( baseRef[ID].spriteID, On )
	SetSpriteVisible( baseRef[ID].spriteID, On )
	SetSpriteSize( baseRef[ID].spriteID, NodeSize,NodeSize )
	SetSpriteDepth( baseRef[ID].spriteID,5 )
	SetSpriteGroup( baseRef[ID].spriteID, group )
	SetSpritePositionByOffset( baseRef[ID].spriteID,mapTable[node].x,mapTable[node].y )

	baseRef[ID].zoneID = CreateDummySprite()
	SetSpriteDepth( baseRef[ID].zoneID,4 )
	SetSpritePhysicsOn( baseRef[ID].zoneID,1 )
	SetSpriteShapeBox( baseRef[ID].zoneID, mapTable[node].x-zoneX, mapTable[node].y-zoneY, mapTable[node].x+zoneX, mapTable[node].y+zoneY,0 )
endfunction ID

function DepotSetup( node, depot, depotNode ref as depotType[],series )
	depotNode.length = depotNode.length + 1
	ID = depotNode.length
	depotNode[ID].node = node
	depotNode[ID].spriteID = series+depotNode.length-1
	mapTable[node].depotID = ID
	maptable[node].base = depot
	mapTable[node].terrain = depot
	//~ mapTable[node].team = team

	LoadImage( depotNode[ID].spriteID,"REDCROSS.png" )
	CreateSprite( depotNode[ID].spriteID,depotNode[ID].spriteID )
	SetSpriteTransparency( depotNode[ID].spriteID, On )
	SetSpriteVisible( depotNode[ID].spriteID, On )
	SetSpriteSize( depotNode[ID].spriteID, DepotSize, DepotSize )
	SetSpriteDepth( depotNode[ID].spriteID,DepotDepth )
	SetSpritePositionByOffset( depotNode[ID].spriteID, mapTable[node].x, mapTable[node].y )
endfunction

function GenerateBases()
	one = Random2( 0,1 )
	for i = 0 to Sectors-1
		node1 = PlayerSectorNodes[i,Random2(0,SectorNodes-1)]
		node2 = AISectorNodes[i,Random2(0,SectorNodes-1)]
		select i	`guarantee a depot and base in either sector 1 or 4
			case 1 : if one then SetBases(node1,node2)  else SetDepots(node1,node2) : endcase
			case 4 : if one then SetDepots(node1,node2) else SetBases(node1,node2)  : endcase
			case default : SetRandomly(node1,node2) : endcase
		endselect
	next i
	AIBaseCount = AIBases.length
	PlayerBaseCount = PlayerBases.length
	AIDepotCount = AIDepotNode.length
	PlayerDepotCount = PlayerDepotNode.length
	AIProdUnits = (AIBaseCount+1) * BaseProdValue
	PlayerProdUnits = (PlayerBaseCount+1) * BaseProdValue
endfunction

function SetBases(node1,node2)
	BaseSetup( PlayerBaseSeries+PlayerBases.length-1,node1,PlayerBase,PlayerBases,BaseGroup )
	BaseSetup( AIBaseSeries+AIBases.length-1,node2,AIBase,AIBases,AIBaseGroup )
endfunction

function SetDepots(node1,node2)
	DepotSetup( node1,PlayerDepot,PlayerDepotNode,PlayerDepotSeries )
	DepotSetup( node2,AIDepot,AIDepotNode,AIDepotSeries )
endfunction

function SetRandomly(node1,node2)
	select Random2( 1,4 )
		case 1 : SetBases(node1,node2) : endcase
		case 2 : SetDepots(node1,node2) : endcase
		case 3,4 : endcase	`no base or depot
	endselect
endfunction

function GenerateImpassables()
	SetSpriteVisible(Impass,On)
	for q = 0 to 3	`4 quadrants
		shape = Random2(0,ShapeCount-1) `pick a random shape
		startNode = Quad[q] + Random2(0,quadWidth-ShapeSize)  `random x position

		for r = 0 to ShapeSize-1
			shapeLine = r * ShapeSize
			rowNode = startNode + (r * Columns)

			for c = 0 to ShapeSize-1
				columnNode = rowNode+c
				if mapTable[columnNode].base <> Empty then continue

				if Shapes[ shape,shapeLine+c ] = Impassable
					mapTable[columnNode].terrain = Impassable
					SetSpritePositionByOffset(Impass,mapTable[columnNode].x,mapTable[columnNode].y)
					DrawSprite( Impass )
					x = mapTable[columnNode].x-NodeOffset
					y = mapTable[columnNode].y-NodeOffset
					AddSpriteShapeBox(impassDummy,x,y,x+NodeSize-1,y+NodeSize-1,0)
				endif
			next c
		next r
	next q
	SetSpriteVisible(Impass,Off)
endfunction

function GenerateTrees()
	SetSpriteVisible(TreeSprite,On)
	odds = Cells * 2
	for i = 0 to MapSize-1
		if ( mapTable[i].terrain <> Impassable ) and ( mapTable[i].team = Unoccupied ) and ( mapTable[i].base = Empty )
			treeOdds = odds
			for j = 0 to Cells-1
				if mapTable[i+offset[j]].terrain = Trees then dec treeOdds,3  `increase tree chance; generate clumps
			next j
			if treeOdds = odds then inc treeOdds,15	`decrease tree chance if surrounded by Clear
			if Random2(0,treeOdds) <= 3	 `Tree?
				mapTable[i].terrain = Trees
				maptable[i].cost = cost[mapTable[i].terrain]
				maptable[i].modifier = TRM[mapTable[i].terrain]
				SetSpritePositionByOffset( TreeSprite,mapTable[i].x,mapTable[i].y )
				DrawSprite( TreeSprite )
				x = mapTable[i].x-NodeOffset
				y = mapTable[i].y-NodeOffset
				AddSpriteShapeBox(treeDummy,x,y,x+NodeSize-1,y+NodeSize-1,0)
			endif
		endif
	next i
	SetSpriteVisible(TreeSprite,Off)
endfunction

function ReGenerateMap()
	for i = 0 to AIBaseCount : DeleteSprite(AIBases[i].spriteID) : next i
	for i = 0 to PlayerBaseCount : DeleteSprite(PlayerBases[i].spriteID) : next i
	for i = 0 to AIDepotCount : DeleteSprite(AIDepotNode[i].spriteID) : next i
	for i = 0 to PlayerDepotCount : DeleteSprite(PlayerDepotNode[i].spriteID) : next i

	SetSpriteVisible(TreeSprite,Off)
	SetSpriteVisible(Impass,Off)
	DeleteImage(field)
	DeleteSprite(field)
	mapTable = holdTable  `reset mapTable
	PlayerBases.length = Empty
	AIBases.length = Empty
	PlayerDepotNode.length = Empty
	AIDepotNode.length = Empty
endfunction

function GenerateTerrain()
	LoadImage(field,"AchillesBoardClear.png")
	CreateSprite(field,field)
	SetSpriteDepth(field,12)
	SetSpriteSize(field,MaxWidth,MaxHeight)

	SetDisplayAspect(-1)  `set current device aspect ratio
	DrawSprite(field)
	SetRenderToImage(field,0)
	GenerateBases()
	GenerateImpassables()
	GenerateTrees()
	BaseColor()
	SetDisplayAspect(AspectRatio)  `back to map aspect ratio
	SetRenderToScreen()
endfunction

function GenerateMap()
	MapFile = OpenToRead( "AchillesBoardClear.txt" )
	for i = 0 to MapSize-1
		mapTable[i].nodeX = i-(trunc(i/Columns)*Columns)
		mapTable[i].nodeY = trunc(i/Columns)
		mapTable[i].x = (mapTable[i].nodeX * NodeSize) + NodeOffset
		mapTable[i].y = (mapTable[i].nodeY * NodeSize) + NodeOffset
		mapTable[i].terrain = val(chr(ReadByte( MapFile )))
		maptable[i].cost = cost[mapTable[i].terrain]
		maptable[i].modifier = TRM[mapTable[i].terrain]
		mapTable[i].base = Empty
		mapTable[i].team = Unoccupied
	next i
	CloseFile( MapFile )
	holdTable = mapTable	`store mapTable

	LoadImage(Iris,"IRIS.png")
	CreateSprite( Iris,Iris )
	SetSpriteTransparency( Iris, 1 )
	SetSpriteVisible( Iris, 0 )
	SetSpriteDepth ( Iris, 0 )
	SetSpriteSize(Iris, 40,46)
	SetSpriteAnimation(Iris,40,46,IrisFrames)
	SetSpriteOffset(Iris,NodeOffset,NodeOffset)

	impassDummy = CreateDummySprite()
	treeDummy = CreateDummySprite()
	SetSpriteCategoryBits(treeDummy,Block)
	SetSpritePhysicsOn(treeDummy,1)
	SetSpriteCategoryBits(impassDummy,Block) // || ImpassBlock)
	SetSpritePhysicsOn(impassDummy,1)

	LoadImage(TreeSprite,"TreeTop290.png")
	CreateSprite(TreeSprite,TreeSprite )
	SetSpriteTransparency(TreeSprite,1)
	SetSpriteDepth(TreeSprite,1)
	SetSpriteSize(TreeSprite,NodeSize,NodeSize)
	SetSpriteOffset(TreeSprite,NodeOffset,NodeOffset)
	SetSpriteVisible(TreeSprite,Off)

	LoadImage(Impass,"Pylon.png")
	CreateSprite(Impass,Impass )
	SetSpriteTransparency(Impass,1)
	SetSpriteDepth(Impass,1)
	SetSpriteSize(Impass,NodeSize,NodeSize)
	SetSpriteOffset(Impass,NodeOffset,NodeOffset)
	SetSpriteVisible(Impass,Off)

	BaseHalo = BaseHaloSeries
	LoadImage(BaseHalo,"BaseHalo.png")
	CreateSprite(BaseHalo,BaseHalo)
	SetSpriteTransparency(BaseHalo,1)
	SetSpriteColorAlpha(BaseHalo,128)
	SetSpriteDepth(BaseHalo,7)
	SetSpriteSize(BaseHalo,NodeSize*2,NodeSize*2)
	SetSpriteOffset(BaseHalo,NodeOffset*2,NodeOffset*2)
	SetSpriteVisible(BaseHalo,Off)

	field = FieldSeries
	GenerateTerrain()
endfunction

function Setup()
   `RESET

	DeleteAllSprites()
	DeleteAllText()
	DeleteAllImages()
	smokeImage=loadimage("Smoke4a.png")
	whiteSmokeImage=loadimage("Smoke5.png")
	DeleteVirtualButton(AcceptButton)
	DeleteVirtualButton(QuitButton)
	DeleteVirtualButton(AcceptFlipButton)
	DeleteVirtualButton(QuitFlipButton)
	DeleteVirtualButton(SettingsButton)
	DeleteVirtualButton(CannonButton)
	DeleteVirtualButton(MissileButton)
	DeleteVirtualButton(LaserButton)
	DeleteVirtualButton(HeavyLaserButton)
	DeleteVirtualButton(HeavyCannonButton)
	DeleteVirtualButton(MineButton)
	DeleteVirtualButton(EMPButton)
	dim AIgrid[Cells] as gridType
	dim PlayerGrid[Cells] as gridType
	dim SpriteCon[SpriteConUnits] as dialogTankType
	SpriteCon.length = SpriteConUnits + 1
	SpriteConSize = CellWidth
	Clones.length = Empty
	AICount = DefaultAI
	PlayerCount = DefaultPlayer
	vol = 50
	SoundVolume()
	SetMusicVolumeOGG( MusicSound,vol )

	pickAI.r = 255
	pickAI.g = 33
	pickAI.b = 52
	pickAI.a = 255
	pickAI.satur = .13
	pickAI.spect = 548
	pickAI.value = SpectrumW

	pickPL.r = 255
	pickPL.g = 255
	pickPL.b = 255
	pickPL.a = 255
	pickPL.satur = 1
	pickPL.spect = SpectrumW
	pickPL.value = SpectrumW

   `MECH GUY

	MechGuy[0].x = MiddleX
	MechGuy[0].y = MiddleY
	MechGuy[0].route = Random2(0,7)

	LoadImage(MechGuy[0].bodyID,"MechAtlas3.png")
	CreateSprite(MechGuy[0].bodyID,MechGuy[0].bodyID )
	SetSpriteDepth(MechGuy[0].bodyID,1 )
	SetSpriteSize(MechGuy[0].bodyID,buffer,buffer )
	SetSpriteOffset(MechGuy[0].bodyID,NodeSize,NodeSize)
	SetSpritePositionByOffset(MechGuy[0].bodyID,MechGuy[0].x,MechGuy[0].y)
	SetSpriteAnimation(MechGuy[0].bodyID,60,62,15)
	SetSpriteAngle(MechGuy[0].bodyID,90)

	LoadImage(MechGuy[0].turretID,"MechTurret.png")
	CreateSprite(MechGuy[0].turretID,MechGuy[0].turretID )
	SetSpriteDepth(MechGuy[0].turretID,1 )
	SetSpriteSize(MechGuy[0].turretID,buffer,buffer )
	SetSpriteOffset(MechGuy[0].turretID,NodeSize,NodeSize)
	SetSpritePositionByOffset(MechGuy[0].turretID,MechGuy[0].x,MechGuy[0].y)
	SetSpriteAngle(MechGuy[0].turretID,90)

   `INTERFACE

	LoadImage(square,"Square.png")
	CreateSprite( square,square )
	SetSpriteOffset(square, NodeOffset, NodeOffset)
	SetSpriteSize(square, NodeSize, NodeSize)
	SetSpriteTransparency( square, 1 )
	SetSpriteVisible( square, 0 )

	LoadImage( ProductionUnits,"Units.png" )
	CreateSprite( ProductionUnits,ProductionUnits )
	SetSpriteSize( ProductionUnits,28,28 )
	SetSpriteTransparency( ProductionUnits, 1 )
	SetSpritePosition( ProductionUnits,MiddleX+UnitX+15,MaxHeight-UnitY)
	SetSpriteColor( ProductionUnits,255,255,255,255 )

	LoadImage( TurnCount,"Turn.png")
	CreateSprite( TurnCount,TurnCount )
	SetSpriteSize( TurnCount,30,30 )
	SetSpriteTransparency( TurnCount, 1 )
	SetSpriteDepth( TurnCount,0 )
	SetSpritePosition( TurnCount,MiddleX+UnitX+17,MaxHeight-(UnitY/1.6) )
	SetSpriteColor( TurnCount,255,255,255,255 )

	ShowInfo( Off )

   `SPRITES Misc

	LoadImage(Fire1,"Energy.png")
	CreateSprite( Fire1,Fire1 )
	SetSpriteTransparency( Fire1, 1 )
	SetSpriteVisible( Fire1, 0 )
	SetSpriteDepth ( Fire1, 0 )
	SetSpriteAnimation( Fire1,128,128,8 )
	SetSpriteSize(Fire1, 64, 64)

	LoadImage( Mine1,"Mine.png" )
	CreateSprite( Mine1,Mine1 )
	SetSpriteTransparency( Mine1, 1 )
	SetSpriteVisible( Mine1, 0 )
	SetSpriteDepth ( Mine1, 0 )
	SetSpriteAnimation( Mine1,75,75,35 )
	SetSpriteSize( Mine1, NodeSize, NodeSize )

	LoadImage( StunSeries,"Stunned.png" )
	CreateSprite( StunSeries,StunSeries )
	SetSpriteVisible( StunSeries, Off )
	SetSpriteDepth ( StunSeries, 3 )
	SetSpriteAnimation( StunSeries,45,45,30 )
	SetSpriteSize( StunSeries, NodeSize, NodeSize )

	LoadImage( MineExplode,"whitestrip12.png" )
	CreateSprite(  MineExplode, MineExplode )
	SetSpriteTransparency(  MineExplode, 1 )
	SetSpriteVisible(  MineExplode, 0 )
	SetSpriteDepth (  MineExplode, 0 )
	SetSpriteAnimation(  MineExplode,100,100,12 )
	SetSpriteSize(  MineExplode, NodeSize*3, NodeSize*3 )

	LoadImage(Missile1,"MissileSheet.png")
	CreateSprite( Missile1,Missile1 )
	SetSpriteTransparency( Missile1, 1 )
	SetSpriteVisible( Missile1, 0 )
	SetSpriteDepth ( Missile1, 0 )
	SetSpriteAnimation( Missile1,9,40,4 )
	SetSpriteSize(Missile1,12,43 )

	Explode1 = ExplodeSeries + 1
	LoadImage( Explode1,"red_strip16.png")
	CreateSprite( Explode1,Explode1 )
	SetSpriteTransparency( Explode1, 1 )
	SetSpriteVisible( Explode1, 0 )
	SetSpriteDepth ( Explode1, 0 )
	SetSpriteAnimation( Explode1,128,128,32 )
	SetSpriteSize( Explode1,128,128)

	Explode2 = ExplodeSeries + 2
	LoadImage( Explode2,"ExplodeSheet.png")
	CreateSprite( Explode2,Explode2 )
	SetSpriteTransparency( Explode2, 1 )
	SetSpriteVisible( Explode2, 0 )
	SetSpriteDepth ( Explode2, 0 )
	SetSpriteAnimation( Explode2,109,81,32 )
	SetSpriteSize( Explode2,75,60 )

   `SPLASHSCREEN

	buttStep# = ( dev.buttX2 - dev.ButtX1 ) * .8
	buttOffset# = dev.buttSize * .2
	bx# = dev.buttX1 + buttOffset#
	by# = buttY - ( buttOffset# / dev.scale )
	gap# = 1 + ( .75 / dev.scale )

	SetupSprite( Splash,Splash,"SplashScreen.png",0,0,MaxWidth,MaxHeight,2,On,0 )
	SetupSprite( Dialog,Dialog,"Dialog2.png",0,0,MaxWidth,MaxHeight,1,Off,0 )
	SetupSprite( BaseDialog,BaseDialog,"BaseDialog.png",0,0,MaxWidth,MaxHeight,1,Off,2 )

	LoadButton(AcceptButton,AcceptImage,AcceptImageDown,"Accept.png","AcceptDown.png",YesNoX3a,by#,dev.buttSize,On)
	LoadButton(QuitButton,CancelImage,CancelImageDown,"Cancel.png","CancelDown.png",YesNoX3b,by#,dev.buttSize,On)
	LoadButton(SettingsButton,SettingsImage,SettingsImageDown,"SettingsButton.png","SettingsButtonDown.png",YesNoX3c,by#,dev.buttSize,On)
	LoadButton(AcceptFlipButton,AcceptFlipImage,AcceptFlipImageDown,"AcceptFlip.png","AcceptFlipDown.png",YesNoX3a,by#,dev.buttSize,On)
	LoadButton(QuitFlipButton,CancelFlipImage,CancelFlipImageDown,"CancelFlip.png","CancelFlipDown.png",YesNoX3b,by#,dev.buttSize,On)

   `MAP GENERATOR SCREEN

	LoadButton(MapButton,MapButtonImage,MapButtonImageDown,"Globe.png","GlobeDown.png",YesNoX3b,by#,dev.buttSize,On)
	LoadButton(MapFlipButton,MapFlipButtonImage,MapFlipButtonImageDown,"GlobeFlip.png","GlobeFlipDown.png",YesNoX3b,by#,dev.buttSize,On)

	LoadButton(L1,L1image,LD1image,"l1.png","ld1.png",bx#,by#,dev.buttSize,On) : inc bx#,buttStep#
	LoadButton(L2,L2image,LD2image,"l2.png","ld2.png",bx#,by#,dev.buttSize,On) : inc bx#,buttStep#
	LoadButton(L3,L3image,LD3image,"l3.png","ld3.png",bx#,by#,dev.buttSize,On) : inc bx#,buttStep#
	LoadButton(L4,L4image,LD4image,"l4.png","ld4.png",bx#,by#,dev.buttSize,On) : inc bx#,buttStep#
	LoadButton(L5,L5image,LD5image,"l5.png","ld5.png",bx#,by#,dev.buttSize,On) : inc bx#,buttStep#*gap#

	LoadButton(S1,S1image,SD1image,"s1.png","sd1.png",bx#,by#,dev.buttSize,On) : inc bx#,buttStep#
	LoadButton(S2,S2image,SD2image,"s2.png","sd2.png",bx#,by#,dev.buttSize,On) : inc bx#,buttStep#
	LoadButton(S3,S3image,SD3image,"s3.png","sd3.png",bx#,by#,dev.buttSize,On) : inc bx#,buttStep#
	LoadButton(S4,S4image,SD4image,"s4.png","sd4.png",bx#,by#,dev.buttSize,On) : inc bx#,buttStep#
	LoadButton(S5,S5image,SD5image,"s5.png","sd5.png",bx#,by#,dev.buttSize,On)

	MapLSButtons( Off )
	SetVirtualButtonVisible( MapButton,Off )
	SetVirtualButtonVisible( MapFlipButton,Off )
	ButtonStatus(Off, AcceptFlipButton, QuitFlipButton)

   `FORCE SELECTION

   `volume and sound sliders

	LoadImage( MusicScale.ID,"Scale2.png" )
	CreateSprite( MusicScale.ID,MusicScale.ID )
	SetSpriteSize( MusicScale.ID,MusicScale.w,MusicScale.h )
	SetSpriteTransparency( MusicScale.ID,1 )
	SetSpriteVisible( MusicScale.ID,0 )
	SetSpritePosition( MusicScale.ID,MusicScale.x,MusicScale.y )
	SetSpriteDepth( MusicScale.ID,1 )

	CloneSprite( SoundScale.ID,MusicScale.ID )
	SetSpritePosition( SoundScale.ID,SoundScale.x,SoundScale.y )

	LoadImage( MusicSlide.ID,"Slider2.png" )
	CreateSprite( MusicSlide.ID,MusicSlide.ID )
	SetSpriteSize( MusicSlide.ID,MusicSlide.w,MusicSlide.h  )
	SetSpriteTransparency( MusicSlide.ID,1 )
	SetSpriteVisible( MusicSlide.ID,0 )
	SetSpritePosition( MusicSlide.ID,MusicSlide.x,MusicSlide.y )
	SetSpriteDepth( MusicSlide.ID,0 )

	CloneSprite( SoundSlide.ID,MusicSlide.ID )
	SetSpritePosition( SoundSlide.ID,SoundSlide.x,SoundSlide.y )


	AISpectrumSprite = CreateDummySprite()
	AIValueSprite = CreateDummySprite()
	PlayerSpectrumSprite = CreateDummySprite()
	PlayerValueSprite = CreateDummySprite()

	SetSpriteShapeBox(AISpectrumSprite,AISide,cy1,AISide+SpectrumW,cy1+SpectrumH,0)
	SetSpriteShapeBox(AIValueSprite,AISide,cy2,AISide+SpectrumW,cy2+ValueH,0)
	SetSpriteShapeBox(PlayerSpectrumSprite,PlayerSide,cy1,PlayerSide+SpectrumW,cy1+SpectrumH,0)
	SetSpriteShapeBox(PlayerValueSprite,PlayerSide,cy2,PlayerSide+SpectrumW,cy2+ValueH,0)

	SetSpriteDepth(AISpectrumSprite,0)
	SetSpriteDepth(AIValueSprite,0)
	SetSpriteDepth(PlayerSpectrumSprite,0)
	SetSpriteDepth(PlayerValueSprite,0)

	SetSpritePhysicsOn(AISpectrumSprite,1)
	SetSpritePhysicsOn(AIValueSprite,1)
	SetSpritePhysicsOn(PlayerSpectrumSprite,1)
	SetSpritePhysicsOn(PlayerValueSprite,1)


	SpriteCon[LightTank].image$ = "GENLIGHT.png"
	SpriteCon[MediumTank].image$ = "GENMEDIUM.png"
	SpriteCon[HeavyTank].image$ = "GENHEAVY.png"
	SpriteCon[Battery].image$ = "GENMISSILE.png"
	SpriteCon[Mech].image$ = "Mech.png"
	SpriteCon[Engineer].image$ = "Engineer.png"
	SpriteCon[Question].image$ = "Random.png"

	SpriteConSize = SpriteConSize*.85
	for i = 1 to SpriteConUnits
		SpriteCon[i].ID = i + SpriteConSeries
		SpriteCon[i].imageID = SpriteCon[i].ID
		SetupSprite( SpriteCon[i].ID, SpriteCon[i].imageID, SpriteCon[i].image$,0,0,SpriteConSize,SpriteConSize,0,Off,CellOffset )
		SetSpritePosition( SpriteCon[i].ID, MiddleX-56,(i*(SpriteConSize+20))-60 )
		SetSpritePhysicsOn( SpriteCon[i].ID, 1 )
		SetSpriteDepth( SpriteCon[i].ID, 0 )
		SetSpriteGroup( SpriteCon[i].ID, SpriteConGroup )
	next i
	SpriteConSize = SpriteConSize*1.3
	for i = 0 to 1
		y = Row1+(i*157)
		for j = 0 to 3
			ID = j+(i*4)
			xa = AISide+(j*145)
			xb = PlayerSide+(j*145)
			AIgrid[ID].x1 = xa
			Aigrid[ID].y1 = y
			AIgrid[ID].x2 = xa + CellWidth-1
			Aigrid[ID].y2 = y + CellHeight-1
			PlayerGrid[ID].x1 = xb
			PlayerGrid[ID].y1 = y
			PlayerGrid[ID].x2 = xb + CellWidth-1
			PlayerGrid[ID].y2 = y + CellHeight-1

			AIgrid[ID].imageID = Null
			AIgrid[ID].ID = Null
			PlayerGrid[ID].imageID = Null
			PlayerGrid[ID].ID = Null
		next j
	next i
	for i = 0 to UnitTypes-1
		clone1 = CloneSprite( SpriteCon[i+1].ID )
		AIgrid[i].imageID = GetSpriteImageID( clone1 )
		AIgrid[i].ID = clone1
		SetSpritePosition( clone1,AIgrid[i].x1,AIgrid[i].y1 )
		SetSpriteSize( clone1,SpriteConSize,SpriteConSize )
		SetSpriteColor(  clone1, pickAI.r, pickAI.g, pickAI.b, pickAI.a )

		clone2 = CloneSprite( SpriteCon[i+1].ID )
		PlayerGrid[i].imageID = AIgrid[i].imageID
		PlayerGrid[i].ID = clone2
		SetSpritePosition( clone2,PlayerGrid[i].x1,PlayerGrid[i].y1 )
		SetSpriteSize( clone2,SpriteConSize,SpriteConSize )
		SetSpriteColor(  clone2, pickPL.r, pickPL.g, pickPL.b, pickPL.a )
	next i
	Text(VersionText,"v0.9",MaxWidth-90,70,72,72,72,32,255,2)
	PlayMusicOGG( MusicSound, 1 )

	GenerateMap()
endfunction

remstart

remend

