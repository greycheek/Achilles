
function BaseColor()
	for i = 0 to PlayerBaseCount  : SetSpriteColor(PlayerBases[i].spriteID,pickPL.r,pickPL.g,pickPL.b,pickPL.a) : next i
	for i = 0 to AIBaseCount      : SetSpriteColor(AIBases[i].spriteID,pickAI.r,pickAI.g,pickAI.b,pickAI.a) : next i
	for i = 0 to PlayerDepotCount : SetSpriteColor(PlayerDepotNode[i].spriteID,pickPL.r,pickPL.g,pickPL.b,pickPL.a) : next i
	for i = 0 to AIDepotCount     : SetSpriteColor(AIDepotNode[i].spriteID,pickAI.r,pickAI.g,pickAI.b,pickAI.a) : next i
endfunction

function BaseSetup( ID, spriteID, node, base, baseRef ref as baseType[], group )
	baseRef[ID].node = node
	baseRef[ID].spriteID = spriteID
	x = mapTable[node].x
	y = mapTable[node].y
	baseRef[ID].x1 = x-zoneRadius
	baseRef[ID].y1 = y-zoneRadius
	baseRef[ID].x2 = x+zoneRadius
	baseRef[ID].y2 = y+zoneRadius

	maptable[node].base = base
	mapTable[node].terrain = base

	LoadImage( baseRef[ID].spriteID,"HEXBASE.png" )
	CreateSprite( baseRef[ID].spriteID,baseRef[ID].spriteID )
	SetSpriteTransparency( baseRef[ID].spriteID, On )
	SetSpriteVisible( baseRef[ID].spriteID, On )
	SetSpriteSize( baseRef[ID].spriteID, NodeSize,NodeSize )
	SetSpriteDepth( baseRef[ID].spriteID,5 )
	SetSpriteGroup( baseRef[ID].spriteID, group )
	//~ SetSpriteOffset( baseRef[ID].spriteID,NodeOffset,NodeOffset )
	SetSpritePositionByOffset( baseRef[ID].spriteID,x,y )
	SetSpriteCategoryBits( baseRef[ID].spriteID,NoBlock )
	SetSpritePhysicsOn( baseRef[ID].spriteID,1 )
	AddSpriteShapeBox( baseRef[ID].spriteID,x,y,x+NodeSize-1,y+NodeSize-1,0 )
endfunction ID

function DepotSetup( ID, spriteID, node, depot, depotNode ref as depotType[], group )
	depotNode[ID].node = node
	depotNode[ID].spriteID = spriteID
	mapTable[node].depotID = ID
	maptable[node].base = depot
	mapTable[node].terrain = depot
	x = mapTable[node].x
	y = mapTable[node].y
	//~ mapTable[node].team = team

	LoadImage( depotNode[ID].spriteID,"REDCROSS.png" )
	CreateSprite( depotNode[ID].spriteID,depotNode[ID].spriteID )
	SetSpriteTransparency( depotNode[ID].spriteID, On )
	SetSpriteVisible( depotNode[ID].spriteID, On )
	SetSpriteSize( depotNode[ID].spriteID, DepotSize, DepotSize )
	SetSpriteDepth( depotNode[ID].spriteID,DepotDepth )
	SetSpriteGroup( depotNode[ID].spriteID,group )
	//~ SetSpriteOffset( depotNode[ID].spriteID,NodeOffset,NodeOffset )
	SetSpritePositionByOffset( depotNode[ID].spriteID,x,y )
	SetSpriteCategoryBits( depotNode[ID].spriteID,NoBlock )
	SetSpritePhysicsOn( depotNode[ID].spriteID,1 )
	AddSpriteShapeBox( depotNode[ID].spriteID,x,y,x+NodeSize-1,y+NodeSize-1,0 )
endfunction

function Placement( baseSector ref as integer[], Nodes as integer[][] )
	do
		s = Random2( 0,Sectors-1 )
		if baseSector.find(s) = -1	`sector not already chosen?
			baseSector.insertsorted(s)
			repeat
				node = Nodes[ s, Random2(0,SectorNodes-1) ]
			until (mapTable[node].terrain < Impassable) and (maptable[node].base = Empty)
			exit
		endif
	loop
endfunction node

function GenerateBases()
	PlayerBaseSector as integer[]
	PlayerDepotSector as integer[]
	AIBaseSector as integer[]
	AIDepotSector as integer[]

	SetDisplayAspect(AspectRatio)  `map aspect ratio
	for i = 1 to Sectors
		if baseQTY <= scaleLength[i]
			AIBases.length = i : exit
		endif
	next i
	for i = 1 to Sectors
		if depotQTY <= scaleLength[i]
			AIDepotNode.length = i : exit
		endif
	next i
	PlayerBases.length = AIBases.length
	PlayerDepotNode.length = AIDepotNode.length

	AIBaseCount = AIBases.length
	PlayerBaseCount = PlayerBases.length
	AIDepotCount = AIDepotNode.length
	PlayerDepotCount = PlayerDepotNode.length
	AIProdUnits = (AIBaseCount+1) * BaseProdValue
	PlayerProdUnits = (PlayerBaseCount+1) * BaseProdValue

	for i = 0 to PlayerBaseCount-1
		node = Placement( PlayerBaseSector,PlayerSectorNodes )
		BaseSetup( i,PlayerBaseSeries+i,node,PlayerBase,PlayerBases,BaseGroup )
	next i
	for i = 0 to PlayerDepotCount-1
		node = Placement( PlayerDepotSector,PlayerSectorNodes )
		DepotSetup( i,PlayerDepotSeries+i,node,PlayerDepot,PlayerDepotNode,depotGroup )
	next i
	for i = 0 to AIBaseCount-1
		node = Placement( AIBaseSector,AISectorNodes )
		BaseSetup( i,AIBaseSeries+i,node,AIBase,AIBases,AIBaseGroup )
	next i
	for i = 0 to AIDepotCount-1
		node = Placement( AIDepotSector,AISectorNodes )
		DepotSetup( i,AIDepotSeries+i,node,AIDepot,AIDepotNode,AIdepotGroup )
	next i
	SetDisplayAspect(-1)  `device aspect ratio
endfunction

function GenerateImpassables()
	shapeTypes = mapImpass + mapWater
	SetSpriteVisible(Impass,On)
	SetSpriteVisible(AcquaSprite,On)
	for s = 0 to 1 `2 halves of the screen
		shape = Random2(0,ShapeCount-1) `pick a random shape
		depth = Random2(0,OpenRows-ShapeHeight) * Columns
		startNode = Semi[s] + Random2(0,SemiWidth-ShapeWidth) + depth

		for r = 0 to ShapeHeight-1
			shapeLine = r * ShapeWidth
			rowNode = startNode + (r * Columns)

			for c = 0 to ShapeWidth-1
				columnNode = rowNode+c
				if mapTable[columnNode].base <> Empty then continue
				x = mapTable[columnNode].x-NodeOffset
				y = mapTable[columnNode].y-NodeOffset

				select Shapes[ shapeTypes,shape,shapeLine+c ]
					case Impassable
						mapTable[columnNode].terrain = Impassable
						SetSpritePositionByOffset( Impass,mapTable[columnNode].x,mapTable[columnNode].y )
						DrawSprite( Impass )
						AddSpriteShapeBox( impassDummy,x,y,x+NodeSize-1,y+NodeSize-1,0 )
					endcase
					case Water
						mapTable[columnNode].terrain = Water
						SetSpritePositionByOffset( AcquaSprite,mapTable[columnNode].x,mapTable[columnNode].y )
						DrawSprite( AcquaSprite )
						AddSpriteShapeBox( waterDummy,x,y,x+NodeSize-1,y+NodeSize-1,0 )
					endcase
				endselect
			next c
		next r
	next s
	SetSpriteVisible(Impass,Off)
	SetSpriteVisible(AcquaSprite,Off)
endfunction

function GenerateMapFeature( i,feature,featureSprite,dummy,sliderQTY#,clumpModifier# )
	if ( mapTable[i].terrain = Clear ) and ( mapTable[i].team = Unoccupied ) and ( mapTable[i].base = Empty )
		for j = 0 to Cells-1
			k = Max( MapSize-1,i+offset[j] )
			if mapTable[k].terrain = feature then inc sliderQTY#,clumpModifier#  `increase chances; generate clumps
		next j
		if Random2 ( 0,RoughScale.w ) <= sliderQTY#	 `add feature?
			mapTable[i].terrain = feature
			maptable[i].cost = cost[mapTable[i].terrain]
			maptable[i].modifier = TRM[mapTable[i].terrain]
			SetSpritePositionByOffset( featureSprite,mapTable[i].x,mapTable[i].y )
			DrawSprite( featureSprite )
			x = mapTable[i].x-NodeOffset
			y = mapTable[i].y-NodeOffset
			AddSpriteShapeBox(dummy,x,y,x+NodeSize-1,y+NodeSize-1,0)
		endif
	endif
endfunction

function ResetMap()
	for i = 0 to AIBaseCount : DeleteSprite(AIBases[i].spriteID) : next i
	for i = 0 to PlayerBaseCount : DeleteSprite(PlayerBases[i].spriteID) : next i
	for i = 0 to AIDepotCount : DeleteSprite(AIDepotNode[i].spriteID) : next i
	for i = 0 to PlayerDepotCount : DeleteSprite(PlayerDepotNode[i].spriteID) : next i

	SetSpriteVisible(TreeSprite,Off)
	SetSpriteVisible(Impass,Off)
	SetSpriteVisible(AcquaSprite,Off)
	DeleteImage(field)
	DeleteSprite(field)
	mapTable = holdTable  `reset mapTable
	PlayerBases.length = Empty
	AIBases.length = Empty
	PlayerDepotNode.length = Empty
	AIDepotNode.length = Empty
endfunction

function GenerateTerrain()
	//~ SetClearColor(0,0,0)
	//~ ClearScreen()
	SetDisplayAspect(-1)  `set device aspect ratio
	LoadImage(field,"AchillesBoardClear.png")
	CreateSprite(field,field)
	SetSpriteDepth(field,12)
	SetSpriteSize(field,MaxWidth,MaxHeight)
	DrawSprite(field)
	SetRenderToImage(field,0)

	GenerateImpassables()
	SetRenderToScreen()
	GenerateBases()
	SetRenderToImage(field,0)

	treeClumpMod# = ceil( treeQty*.15)
	roughClumpMod# = ceil( roughQty*.15)

	SetSpriteVisible( TreeSprite,On )
	SetSpriteVisible( RoughSprite,On )
	for i = FirstCell to MapSize-1
		if Random2(1,100) > 50
			GenerateMapFeature( i,Trees,TreeSprite,treeDummy,treeQty,treeClumpMod# )
		else
			GenerateMapFeature( i,Rough,RoughSprite,roughDummy,roughQty,roughClumpMod# )
		endif
	next i
	SetSpriteVisible( TreeSprite,Off )
	SetSpriteVisible( RoughSprite,Off )

	BaseColor()
	SetRenderToScreen()
	SetDisplayAspect(AspectRatio)  `back to map aspect ratio
endfunction

function GenerateMap()

	MapFile = OpenToRead( "AchillesBoardClear.txt" )
	for i = 0 to MapSize-1
		mapTable[i].nodeX = i-(trunc(i/Columns)*Columns)
		mapTable[i].nodeY = trunc(i/Columns)
		mapTable[i].x = (mapTable[i].nodeX * NodeSize) + NodeOffset
		mapTable[i].y = (mapTable[i].nodeY * NodeSize) + NodeOffset
		mapTable[i].terrain = val(chr(ReadByte( MapFile ))) `base 16 format
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
	roughDummy = CreateDummySprite()
	waterDummy = CreateDummySprite()
	SetSpritePhysicsOn( impassDummy,1 )
	SetSpritePhysicsOn( treeDummy,1 )
	SetSpritePhysicsOn( roughDummy,1 )
	SetSpritePhysicsOn( waterDummy,1 )
	SetSpriteCategoryBits( impassDummy,Block )
	SetSpriteCategoryBits( treeDummy,Block )
	SetSpriteCategoryBits( roughDummy,NoBlock )
	SetSpriteCategoryBits( waterDummy,NoBlock )


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

	LoadImage(AcquaSprite,"Water.png")
	CreateSprite(AcquaSprite,AcquaSprite)
	SetSpriteTransparency(AcquaSprite,Off)
	SetSpriteDepth(AcquaSprite,1)
	SetSpriteSize(AcquaSprite,NodeSize,NodeSize)
	SetSpriteVisible(AcquaSprite,Off)

	LoadImage(RoughSprite,"Rough4.png")
	CreateSprite(RoughSprite,RoughSprite)
	SetSpriteTransparency(RoughSprite,On)
	SetSpriteDepth(RoughSprite,1)
	SetSpriteSize(RoughSprite,NodeSize,NodeSize)
	SetSpriteVisible(RoughSprite,Off)

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

	DeleteAllButtons()

	dim AIgrid[Cells] as gridType
	dim PlayerGrid[Cells] as gridType
	dim SpriteCon[SpriteConUnits] as dialogTankType
	SpriteCon.length = SpriteConUnits + 1
	SpriteConSize = CellWidth
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

	LoadImage( Mine1,"MineSS.png" )
	CreateSprite( Mine1,Mine1 )
	SetSpriteTransparency( Mine1, 1 )
	SetSpriteVisible( Mine1, 0 )
	SetSpriteDepth ( Mine1, 0 )
	SetSpriteAnimation( Mine1,90,90,14 )
	SetSpriteSize( Mine1, NodeSize, NodeSize )

	DisruptSprite = LoadImage( "DisruptorSS.png" )
	CreateSprite( DisruptSprite,DisruptSprite )
	SetSpriteTransparency( DisruptSprite,1 )
	SetSpriteVisible( DisruptSprite,Off )
	SetSpriteDepth ( DisruptSprite,0 )
	SetSpriteSize( DisruptSprite,180,128.5 )
	SetSpriteOffset( DisruptSprite,90,128.5 )
	SetSpriteAnimation( DisruptSprite,360,257,8 )

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

	LoadImage( Missile1,"MissileSheet.png" )
	CreateSprite( Missile1,Missile1 )
	SetSpriteTransparency( Missile1, 1 )
	SetSpriteVisible( Missile1, 0 )
	SetSpriteDepth ( Missile1, 0 )
	SetSpriteAnimation( Missile1,9,40,4 )
	SetSpriteSize( Missile1,12,43 )

	LoadImage( Bullet1,"Bullet.png" )
	CreateSprite( Bullet1,Bullet1 )
	SetSpriteTransparency( Bullet1, 1 )
	SetSpriteVisible( Bullet1, 0 )
	SetSpriteDepth ( Bullet1, 0 )

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

	Explode3 = ExplodeSeries + 3
	LoadImage( Explode3,"shiphit_strip11.png")
	CreateSprite( Explode3,Explode3 )
	SetSpriteTransparency( Explode3, 1 )
	SetSpriteVisible( Explode3, 0 )
	SetSpriteDepth ( Explode3, 0 )
	SetSpriteAnimation( Explode3,64,48,11 )
	SetSpriteSize( Explode3,96,72 )

   `SPLASHSCREEN

	buttStep# = ( dev.buttX2 - dev.ButtX1 ) * .8
	buttOffset# = dev.buttSize * .2
	bx# = dev.buttX1 + buttOffset#
	by# = buttY - ( buttOffset# / dev.scale )
	gap# = 1 + ( .75 / dev.scale )

	SetupSprite( Splash,Splash,"Achilles3D.png",0,0,MaxWidth,MaxHeight,2,On,0 )
	SetupSprite( Dialog,Dialog,"Dialog2.png",0,0,MaxWidth,MaxHeight,1,Off,0 )
	SetupSprite( BaseDialog,BaseDialog,"BaseDialog.png",0,0,MaxWidth,MaxHeight,1,Off,2 )

	LoadButton(AcceptButton,AcceptImage,AcceptImageDown,"CheckUp.png","CheckDown.png",YesNoX3a,by#,dev.buttSize,On)
	LoadButton(QuitButton,CancelImage,CancelImageDown,"CancelUp.png","CancelDown2.png",YesNoX3b,by#,dev.buttSize,On)
	LoadButton(SettingsButton,SettingsImage,SettingsImageDown,"SettingsButton.png","SettingsButtonDown.png",YesNoX3c,by#,dev.buttSize,On)
	LoadButton(AcceptFlipButton,AcceptFlipImage,AcceptFlipImageDown,"CheckUp.png","CheckDown.png",YesNoX3a,by#,dev.buttSize,On)
	LoadButton(QuitFlipButton,CancelFlipImage,CancelFlipImageDown,"CancelFlip.png","CancelFlipDown.png",YesNoX3b,by#,dev.buttSize,On)


   `MAP GENERATOR SCREEN

	bs# = 80*dev.scale
	margin = bs#*1.33
	tx1# = YesNoX1+(bs#)
	tx2# = tx1#+margin
	ty1# = MiddleY*1.03

	LoadButton(LOADBUTT,LOADBUTTimage,LOADBUTTDOWNimage,"LOADUP.png","LOADDOWN.png",tx1#,ty1#,bs#,On)
	LoadButton(SAVEBUTT,SAVEBUTTimage,SAVEBUTTDOWNimage,"SAVEUP.png","SAVEDOWN.png",tx2#,ty1#,bs#,On)

	LoadButton(MapSaveFlipButton,MapSaveFlipButtonImage,MapSaveFlipButtonImageDown,"DiskUp.png","DiskDown.png",YesNoX3b,by#,dev.buttSize,On)
	LoadButton(RandomizeFlipButton,RandomizeFlipButtonImage,RandomizeFlipButtonImageDown,"RandomizeUp.png","RandomizeDown.png",YesNoX3c,by#,dev.buttSize,On)
	LoadButton(MapButton,MapButtonImage,MapButtonImageDown,"Globe.png","GlobeDown.png",YesNoX3b,by#,dev.buttSize,On)
	//~ LoadButton(MapFlipButton,MapFlipButtonImage,MapFlipButtonImageDown,"GlobeFlip.png","GlobeFlipDown.png",YesNoX3b,by#,dev.buttSize,On)

	LoadButton(ImpassButton,ImpassButtonImage,ImpassButtonImageDown,"ImpassUp.png","ImpassDown.png",dev.buttX1,by#,dev.buttSize,On)
	LoadButton(WaterButton,WaterButtonImage,WaterButtonImageDown,"WaterUp.png","WaterDown.png",dev.buttX2*.9,by#,dev.buttSize,On)

	bs# = dev.buttSize
	margin = bs#*1.3
	tx1# = MiddleX-(bs#*2.12)
	tx2# = tx1#+margin
	tx3# = tx2#+margin
	tx4# = tx3#+margin

	LoadButton(SLOT1,SLOT1image,SLOTDOWN1image,"SLOT1small.png","SLOT1DOWNsmall.png",tx1#,ty1#,bs#,On)
	LoadButton(SLOT2,SLOT2image,SLOTDOWN2image,"SLOT2small.png","SLOT2DOWNsmall.png",tx2#,ty1#,bs#,On)
	LoadButton(SLOT3,SLOT3image,SLOTDOWN3image,"SLOT3small.png","SLOT3DOWNsmall.png",tx3#,ty1#,bs#,On)
	LoadButton(SLOT4,SLOT4image,SLOTDOWN4image,"SLOT4small.png","SLOT4DOWNsmall.png",tx4#,ty1#,bs#,On)

	`is this necessary??
	SetVirtualButtonVisible( LOADBUTT,Off )
	SetVirtualButtonVisible( SAVEBUTT,Off )
	SetVirtualButtonVisible( SLOT1,Off )
	SetVirtualButtonVisible( SLOT2,Off )
	SetVirtualButtonVisible( SLOT3,Off )
	SetVirtualButtonVisible( SLOT4,Off )
	SetVirtualButtonVisible( MapSaveFlipButton,Off )
	SetVirtualButtonVisible( RandomizeFlipButton,Off )
	SetVirtualButtonVisible( MapButton,Off )
	SetVirtualButtonVisible( MapFlipButton,Off )
	SetVirtualButtonVisible( ImpassButton,Off )
	SetVirtualButtonVisible( WaterButton,Off )

	ButtonState( AcceptFlipButton,Off )
	ButtonState( QuitFlipButton,Off )

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

	LoadImage( RoughScale.ID,"RoughScale2.png" )
	CreateSprite( RoughScale.ID,RoughScale.ID )
	SetSpriteSize( RoughScale.ID,RoughScale.w,RoughScale.h )
	SetSpriteTransparency( RoughScale.ID,1 )
	SetSpriteVisible( RoughScale.ID,0 )
	SetSpritePosition( RoughScale.ID,RoughScale.x,RoughScale.y )
	SetSpriteDepth( RoughScale.ID,1 )

	LoadImage( RoughSlide.ID,"RoughSlider.png" )
	CreateSprite( RoughSlide.ID,RoughSlide.ID )
	SetSpriteSize( RoughSlide.ID,RoughSlide.w,RoughSlide.h )
	SetSpriteTransparency( RoughSlide.ID,1 )
	SetSpriteVisible( RoughSlide.ID,0 )
	SetSpritePosition( RoughSlide.ID,RoughSlide.x,RoughSlide.y )
	SetSpriteDepth( RoughSlide.ID,0 )

	LoadImage( TreeScale.ID,"TreesScale2.png" )
	CreateSprite( TreeScale.ID,TreeScale.ID )
	SetSpriteSize( TreeScale.ID,TreeScale.w,TreeScale.h )
	SetSpriteTransparency( TreeScale.ID,1 )
	SetSpriteVisible( TreeScale.ID,0 )
	SetSpritePosition( TreeScale.ID,TreeScale.x,TreeScale.y )
	SetSpriteDepth( TreeScale.ID,1 )

	LoadImage( TreeSlide.ID,"TreesSlider.png" )
	CreateSprite( TreeSlide.ID,TreeSlide.ID )
	SetSpriteSize( TreeSlide.ID,TreeSlide.w,TreeSlide.h )
	SetSpriteTransparency( TreeSlide.ID,1 )
	SetSpriteVisible( TreeSlide.ID,0 )
	SetSpritePosition( TreeSlide.ID,TreeSlide.x,TreeSlide.y )
	SetSpriteDepth( TreeSlide.ID,0 )

	LoadImage( BaseScale.ID,"BaseScale2.png" )
	CreateSprite( BaseScale.ID,BaseScale.ID )
	SetSpriteSize( BaseScale.ID,BaseScale.w,BaseScale.h )
	SetSpriteTransparency( BaseScale.ID,1 )
	SetSpriteVisible( BaseScale.ID,0 )
	SetSpritePosition( BaseScale.ID,BaseScale.x,BaseScale.y )
	SetSpriteDepth( BaseScale.ID,1 )

	LoadImage( BaseSlide.ID,"BaseSlider.png" )
	CreateSprite( BaseSlide.ID,BaseSlide.ID )
	SetSpriteSize( BaseSlide.ID,BaseSlide.w,BaseSlide.h )
	SetSpriteTransparency( BaseSlide.ID,1 )
	SetSpriteVisible( BaseSlide.ID,0 )
	SetSpritePosition( BaseSlide.ID,BaseSlide.x,BaseSlide.y )
	SetSpriteDepth( BaseSlide.ID,0 )

	LoadImage( DepotScale.ID,"DepotScale2.png" )
	CreateSprite( DepotScale.ID,DepotScale.ID )
	SetSpriteSize( DepotScale.ID,DepotScale.w,DepotScale.h )
	SetSpriteTransparency( DepotScale.ID,1 )
	SetSpriteVisible( DepotScale.ID,0 )
	SetSpritePosition( DepotScale.ID,DepotScale.x,DepotScale.y )
	SetSpriteDepth( DepotScale.ID,1 )

	LoadImage( DepotSlide.ID,"DepotSlider.png" )
	CreateSprite( DepotSlide.ID,DepotSlide.ID )
	SetSpriteSize( DepotSlide.ID,DepotSlide.w,DepotSlide.h )
	SetSpriteTransparency( DepotSlide.ID,1 )
	SetSpriteVisible( DepotSlide.ID,0 )
	SetSpritePosition( DepotSlide.ID,DepotSlide.x,DepotSlide.y )
	SetSpriteDepth( DepotSlide.ID,0 )

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


	SpriteCon[HoverCraft].image$ = "GENHOVER.png"
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
			AIgrid[ID].vehicle = Null

			PlayerGrid[ID].imageID = Null
			PlayerGrid[ID].ID = Null
			PlayerGrid[ID].vehicle = Null
		next j
	next i
	for i = 0 to UnitTypes-1
		vehicle=i+1
		clone1 = CloneSprite( SpriteCon[vehicle].ID )
		AIgrid[i].imageID = GetSpriteImageID( clone1 )
		AIgrid[i].ID = clone1
		AIgrid[i].vehicle = vehicle
		SetSpritePosition( clone1,AIgrid[i].x1,AIgrid[i].y1 )
		SetSpriteSize( clone1,SpriteConSize,SpriteConSize )
		SetSpriteColor(  clone1,pickAI.r,pickAI.g,pickAI.b,pickAI.a )

		clone2 = CloneSprite( SpriteCon[vehicle].ID )
		PlayerGrid[i].imageID = AIgrid[i].imageID
		PlayerGrid[i].ID = clone2
		PlayerGrid[i].vehicle = vehicle
		SetSpritePosition( clone2,PlayerGrid[i].x1,PlayerGrid[i].y1 )
		SetSpriteSize( clone2,SpriteConSize,SpriteConSize )
		SetSpriteColor(  clone2,pickPL.r,pickPL.g,pickPL.b,pickPL.a )
	next i
	Text(VersionText,"v0.9",MaxWidth-90,70,72,72,72,32,255,2)
	PlayMusicOGG( MusicSound, 1 )

	GenerateMap()
endfunction

function DeleteAllButtons()
	DeleteVirtualButton(AcceptFlipButton)
	DeleteVirtualButton(QuitFlipButton)
	DeleteVirtualButton(LOADBUTT)
	DeleteVirtualButton(SAVEBUTT)
	DeleteVirtualButton(SLOT1)
	DeleteVirtualButton(SLOT2)
	DeleteVirtualButton(SLOT3)
	DeleteVirtualButton(SLOT4)
	DeleteVirtualButton(AcceptButton)
	DeleteVirtualButton(QuitButton)
	DeleteVirtualButton(SettingsButton)
	DeleteVirtualButton(MapSaveFlipButton)
	DeleteVirtualButton(RandomizeFlipButton)
	DeleteVirtualButton(MapButton)
	DeleteVirtualButton(MapFlipButton)
	DeleteVirtualButton(CannonButton)
	DeleteVirtualButton(HeavyCannonButton)
	DeleteVirtualButton(MissileButton)
	DeleteVirtualButton(LaserButton)
	DeleteVirtualButton(HeavyLaserButton)
	DeleteVirtualButton(EMPButton)
	DeleteVirtualButton(MineButton)
	DeleteVirtualButton(DisruptButton)
	DeleteVirtualButton(BulletButton)
	DeleteVirtualButton(ImpassButton)
	DeleteVirtualButton(WaterButton)
endfunction


remstart

function SetBases(node1,node2)
	BaseSetup( PlayerBaseSeries+PlayerBases.length-1,node1,PlayerBase,PlayerBases,BaseGroup )
	BaseSetup( AIBaseSeries+AIBases.length-1,node2,AIBase,AIBases,AIBaseGroup )
endfunction

function SetDepots(node1,node2)
	DepotSetup( node1,PlayerDepot,PlayerDepotNode,PlayerDepotSeries,depotGroup )
	DepotSetup( node2,AIDepot,AIDepotNode,AIDepotSeries,AIDepotGroup )
endfunction

function SetRandomly(node1,node2)
	select Random2( 1,4 )
		case 1 : SetBases(node1,node2) : endcase
		case 2 : SetDepots(node1,node2) : endcase
		case 3,4 : endcase	`no base or depot
	endselect
endfunction

	SetSpriteShape( impassDummy,2 )
	SetSpriteShape( treeDummy,2 )
	SetSpriteShape( roughDummy,2 )
	SetSpriteShape( waterDummy,2 )

from Setup()
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

	baseRef[ID].zoneID = CreateDummySprite()
	SetSpriteDepth( baseRef[ID].zoneID,4 )
	SetSpritePhysicsOn( baseRef[ID].zoneID,1 )
	SetSpriteShapeBox( baseRef[ID].zoneID, mapTable[node].x-zoneRadius, mapTable[node].y-zoneRadius, mapTable[node].x+zoneRadius, mapTable[node].y+zoneRadius,0 )

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

remend

