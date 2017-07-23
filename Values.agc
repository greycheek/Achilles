
`constants
remstart
remend

`general
#constant Unset 100000
#constant Minimum 0
#constant NotFound .1
#constant body 0
#constant turret 1
#constant Goal 1
#constant Complete 1

#constant TurnText 0
#constant HitText 1
#constant MovingText 2
#constant FiringText 4
#constant LOSText 5
#constant OutofRangeText 6
#constant OutofAmmoText 7
#constant GameOverText 8
#constant QuitText 9
#constant SettingsText 10
#constant AlertText 11
#constant VersionText 12
#constant WeaponText 100

`nodes
#constant Columns 32
#constant OpenColumns 30
#constant Rows 20
#constant OpenRows 16

#constant NodeSize 45 		`MaxWidth / NodeColumns
#constant NodeOffset 22		`Half of NodeSize
#constant BarWidth 3		`Health Bar
#constant BarHeight 45
#constant MapSize 640		`Rows * Columns
#constant MapWidth 1350
#constant MapHeight 720
#constant FirstRow 1

`terrain
#constant Impassable 9
#constant AIDepot 8
#constant PlayerDepot 7
#constant AIBase 4
#constant PlayerBase 3
#constant Trees 2
#constant Clear 1

global cost as integer[10]
for i = 0 to 9 : cost[i]=Clear : next i
cost[2]=Trees
cost[9]=Impassable


`patrol zone
global topRow as integer
global bottomRow as integer
global baseZone as integer
baseZone = MaxWidth/3
topRow = NodeSize * 2
bottomRow = OpenRows * NodeSize

`sounds
#constant ClickSound 2
#constant TankSound 3
#constant BangSound 4
#constant ExplodeSound 5
#constant RocketSound 6
#constant LaserSound 7

`player tank glow
#constant Brighter 10
#constant Brightest 255
#constant Darker -10
#constant GlowMax 255
#constant GlowMin 0

`weapons
#constant cannon 0
#constant cannonDamage .25
#constant cannonRounds 0
global cannonRange as integer
cannonRange = nodeSize * 4

#constant laser 1
#constant laserDamage .1
#constant laserRounds 0
global laserRange as integer
laserRange = mapWidth + mapHeight
global smokeImage as integer
smokeImage=loadimage("Smoke4a.png")

#constant missile 2
#constant missileDamage .4
#constant missileRounds 9
#constant missileCount 9
global missileRange as integer
missileRange = mapWidth + mapHeight

#constant heavyCannon 3
#constant heavyCannonDamage .35
#constant heavyCannonRounds 0
global heavyCannonRange as integer
heavyCannonRange = cannonRange

#constant heavyLaser 4
#constant heavyLaserDamage .25
#constant heavyLaserRounds 0
global heavyLaserRange as integer
heavyLaserRange = mapWidth + mapHeight


`tanks
type tankType
	OpenList as integer[]
	ClosedList as integer[]
	parentNode as integer[]

	X as integer
	y as integer
	node as integer
	goalNode as integer

	alive as integer
	target as integer
	moveTarget as integer
	speed as Integer
	index as integer
	moves as integer
	movesAllowed as integer
	totalCost as integer
	team as integer
	line as integer
	hilite as integer
	bullsEye as integer
	cover as integer
	vehicle as integer
	weapon as integer
	range as integer
	missiles as integer
	patrolDirection as integer

	FOW as integer
	FOWSize as integer
	FOWOffset as integer
	FOWDummy as integer
	bodyID as integer
	turretID as integer
	healthID as integer
	bodyImageID as integer
	turretImageID as integer
	healthBarImageID as integer

	bodyW as Float
	bodyH as Float
	turretW as Float
	turretH as Float
	scale as Float
	health as Float
	minimumHealth as Float
	maximumHealth as Float
	damage as Float

	body$ as String
	turret$ as String
endtype

			type unitCostType
				Light as integer
				Batt as integer
				Medium as integer
				Heavy as integer
			endtype

			unitCost as unitCostType
			unitCost.Light = 10
			unitCost.Batt = 20
			unitCost.Medium = 20
			unitCost.Heavy = 30


#constant AI %0000000000000010
#constant Player %0000000000000100
			#constant CoverAlpha 100
#constant Unoccupied 0
#constant PlayerTeam 1
#constant AITeam 2

#constant HeavyHealthMax 1
#constant MediumHealthMax .75
#constant LightHealthMax .5
#constant BatteryHealthMax .33

global AISurviving as integer
global PlayerSurviving as integer
AISurviving = AICount
PlayerSurviving = PlayerCount


global PlayerLast as integer
global AIPlayerLast as integer
PlayerLast = PlayerCount-1
AIPlayerLast = AICount-1

global AITank as tankType[]
global PlayerTank as tankType[]
AITank.length = AICount
PlayerTank.length = PlayerCount


global DepotRange as integer
DepotRange = MaxWidth / 4
global PlayerDepotNode as integer[]
global AIDepotNode as integer[]


`map
type mapType
	x as integer	`screen coordinates
	y as integer
	nodeX as integer
	nodeY as integer
	team as integer
	cost as integer
	terrain as integer
	heuristic as integer
	moveTarget as integer
endtype
global mapTable as mapType[MapSize]
global treeDummy as integer
global PlayerBaseNode as integer
global AIBaseNode as integer

			global PlayerBases as integer
			global AIBases as integer

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
		case PlayerBase
			PlayerBaseNode = i

					inc PlayerBases
		endcase
		case AIBase
			AIBaseNode = i

					inc AIBases
		endcase
		case PlayerDepot
			PlayerDepotNode.insert(i)
		endcase
		case AIDepot
			AIDepotNode.insert(i)
		endcase
		case Trees
			x = mapTable[i].x-NodeOffset
			y = mapTable[i].y-NodeOffset
			AddSpriteShapeBox(treeDummy,x,y,x+NodeSize-1,y+NodeSize-1,0)
		endcase
	endselect
next i
CloseFile( MapFile )


`interface
#constant TurnButton 1
#constant BangButton 2
#constant CannonButton 3
#constant MissileButton 4
#constant LaserButton 5
#constant NextButton 6
#constant TargetButton 7
#constant QuitButton 8
//~ #constant YesButton 9
//~ #constant NoButton 10
#constant HeavyCannonButton 11
#constant HeavyLaserButton 12

global turnImage as integer
global turnImageDown as integer
global cannonImage as integer
global cannonImageDown as integer
global laserImage as integer
global laserImageDown as integer
global missileImage as integer
global missileImageDown as integer
global nextImage as integer
global nextImagedown as integer
global targetImage as integer
global targetImageDown as integer
global heavyCannonImage as integer
global heavyCannonImageDown as integer
global heavyLaserImage as integer
global heavyLaserImageDown as integer

turnImage = InterfaceSeries+1
turnImageDown = InterfaceSeries+2
cannonImage = InterfaceSeries+3
cannonImageDown = InterfaceSeries+4
laserImage = InterfaceSeries+5
laserImageDown = InterfaceSeries+6
missileImage = InterfaceSeries+7
missileImageDown = InterfaceSeries+8
nextImage = InterfaceSeries+9
nextImageDown = InterfaceSeries+10
targetImage = InterfaceSeries+11
targetImageDown = InterfaceSeries+12
heavyCannonImage = InterfaceSeries+13
heavyCannonImageDown = InterfaceSeries+14
heavyLaserImage = InterfaceSeries+15
heavyLaserImageDown = InterfaceSeries+16

global square as integer
square = InterfaceSeries+17
LoadImage(square,"Square.png")
CreateSprite( square,square )
SetSpriteOffset(square, NodeOffset, NodeOffset)
SetSpriteSize(square, NodeSize, NodeSize)
SetSpriteTransparency( square, 1 )
SetSpriteVisible( square, 0 )

quitImage = InterfaceSeries+18
quitImageDown = InterfaceSeries+19
//~ YesImage = InterfaceSeries+20
//~ YesImageDown = InterfaceSeries+21
//~ NoImage = InterfaceSeries+22
//~ NoImageDown = InterfaceSeries+23
//~ global AlertBackGround as integer
//~ AlertBackGround = InterfaceSeries+24
SetupSprite( AlertBackGround,AlertBackGround,"Yes-NoBkgnd.png", MiddleX-212,MiddleY-200,425,312,0,Off,0 )

global buttX as integer
global buttY as integer

buttSize = 64
buttX = buttSize+4
buttY = MaxHeight-buttSize
LoadButton(TurnButton,turnImage,turnImageDown,"Button.png","ButtonDown.png",MaxWidth-buttSize-4,buttY,buttSize,On)
LoadButton(NextButton,nextImage,nextImageDown,"Next.png","NextDown.png",MaxWidth-(buttSize*2)-43,buttY,buttSize,On)
LoadButton(TargetButton,targetImage,targetImageDown,"TargetButton.png","TargetButtonDown.png",MaxWidth-(buttSize*3)-83,buttY,buttSize,On)
LoadButton(QuitButton,quitImage,quitImageDown,"Quit.png","QuitDown.png",MaxWidth-(buttSize*4)-123,buttY,buttSize,On)
LoadButton(YesButton,YesImage,YesImageDown,"Yes.png","YesDown.png",MiddleX+NodeSize+13,MiddleY+100,buttSize,Off)
LoadButton(NoButton,NoImage,NoImageDown,"No.png","NoDown.png",MiddleX-NodeSize-13,MiddleY+100,buttSize,Off)

LoadButton(CannonButton,cannonImage,cannonImageDown,"Cannon.png","CannonDown.png",buttX,buttY,buttSize,On)
LoadButton(HeavyCannonButton,heavyCannonImage,heavyCannonImageDown,"HeavyCannon.png","HeavyCannonDown.png",buttX,buttY,buttSize,On)
LoadButton(MissileButton,missileImage,missileImageDown,"Rocket.png","RocketDown.png",buttX,buttY,buttSize,On)
LoadButton(LaserButton,laserImage,laserImageDown,"Laser.png","LaserDown.png",buttSize*2.5,buttY,buttSize,On)
LoadButton(HeavyLaserButton,heavyLaserImage,heavyLaserImageDown,"HeavyLaser.png","HeavyLaserDown.png",buttSize*2.5,buttY,buttSize,On)

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

function SetNumeralSprite( spriteID,filename$ )
	LoadImage( spriteID,filename$ )
	CreateSprite( spriteID,spriteID )
	SetSpriteVisible( spriteID,Off )
	SetSpriteSize( spriteID,13,15 )
endfunction
global NumSprite as integer[missileCount]
global NumY as integer
global NumX as integer
NumX = buttX + (buttSize/2) + 4
NumY = buttY-40
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

`node vectors
#constant south 	-32
#constant southeast -31
#constant west 		  1
#constant northeast  33
#constant north 	 32
#constant northwest  31
#constant east 		 -1
#constant southwest -33

global turns as integer = 0	: Turn() `turn counter
global offset as integer[8]=[north,northwest,east,southwest,south,southeast,west,northeast]
global angle  as integer[8]=[0,45,90,135,180,225,270,315]
global DLS as integer
DLS = NodeSize*sqrt(2) `Diagonal Length of Square


remstart

`board
field = FieldSeries
LoadImage(field,"Achilles45.png")
CreateSprite(field,field)
SetSpriteDepth ( field, 12 )
SetSpriteSize(field,1440,900)
//~ //~
`sounds
LoadSound(BangSound,"bang2.wav")
LoadSound(ClickSound,"buttonclick.wav")
LoadSoundOGG(TankSound,"Rumble2.ogg")
LoadSound(ExplodeSound,"explode.wav")
LoadSound(RocketSound,"rocket.wav" )
LoadSoundOGG(LaserSound,"laser3.ogg" )
//~ //~
`sprites
global Fire1 = WeaponSeries
LoadImage(Fire1,"Energy.png")
CreateSprite( Fire1,Fire1 )
SetSpriteTransparency( Fire1, 1 )
SetSpriteVisible( Fire1, 0 )
SetSpriteDepth ( Fire1, 0 )
SetSpriteAnimation( Fire1,128,128,8 )
SetSpriteSize(Fire1, 64, 64)
//~ //~
global Missile1 = MissileSeries
LoadImage(Missile1,"MissileSheet.png")
CreateSprite( Missile1,Missile1 )
SetSpriteTransparency( Missile1, 1 )
SetSpriteVisible( Missile1, 0 )
SetSpriteDepth ( Missile1, 0 )
SetSpriteAnimation( Missile1,9,40,4 )
SetSpriteSize(Missile1,12,43 )
//~ //~
global Explode1 = ExplodeSeries
LoadImage(Explode1,"red_strip16.png")
CreateSprite( Explode1,Explode1 )
SetSpriteTransparency( Explode1, 1 )
SetSpriteVisible( Explode1, 0 )
SetSpriteDepth ( Explode1, 0 )
SetSpriteAnimation( Explode1,128,128,32 )
SetSpriteSize(Explode1, 64, 64)


remend


