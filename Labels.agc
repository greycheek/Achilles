

`SCREEN/MAP
#constant Columns 32	 `nodes
#constant OpenColumns 30
#constant Rows 20
#constant OpenRows 16
#constant FirstRow 1
#constant MapSize 640	 `Rows*Columns

global OpenMapSize as float
OpenMapSize = OpenRows*OpenColumns

global MaxWidth as float = 1440  `map size as designed
global MaxHeight as float = 900
global MiddleX as float
global MiddleY as float
global AspectRatio as float
global MapWidth as float
global MapHeight as float
global NodeSize as integer
global NodeOffset as integer

AspectRatio = MaxWidth/MaxHeight
NodeSize = MaxWidth/Columns
NodeOffset = NodeSize/2
MapWidth = OpenColumns*NodeSize
MapHeight = OpenRows*NodeSize
MiddleX = MaxWidth/2
MiddleY = MapHeight/2

`VECTORS
#constant south 	-32
#constant southeast -31
#constant west 		  1
#constant northeast  33
#constant north 	 32
#constant northwest  31
#constant east 		 -1
#constant southwest -33

`FORCE GRID
#constant Cells 8
#constant CellColumns 4
#constant DefaultAI 6
#constant DefaultPlayer 6
#constant DefaultTanks 5
#constant CellWidth 112
#constant CellHeight 112
#constant CellOffset 56
#constant Mullion 25
#constant AISide 67
#constant PlayerSide 817
#constant Row1 96
#constant Row2 253

`BUTTONS
#constant SettingsButton 1
#constant CannonButton 2
#constant MissileButton 3
#constant LaserButton 4
#constant QuitButton 5
#constant AcceptButton 6
#constant HeavyLaserButton 7
#constant HeavyCannonButton 8
#constant EMPButton 9
#constant MineButton 10
#constant JoyButton 11

`GENERAL
#constant Unset 100000
#constant Empty -1
#constant Minimum 0
#constant NotFound .1
#constant body 0
#constant turret 1
#constant Goal 1
#constant Complete 1
#constant PatrolRadius 7
#constant BarWidth 3	 `Health Bar


global DLS as integer
DLS = NodeSize*sqrt(2) `Diagonal Length of Square
#constant DLSneg -64
#constant DLSpos 64
#constant NodeNeg -45
#constant NodePos 45

`DON'T NEED FOR OLD PATROL
global patrolScan as integer[16]=[-32,-31,1,33,32,31,-1,-33,-32,-31,1,33,32,31,-1,-33]	 `starting at 12:00 and going clockwise(twice)

global turnX as integer[8]=[0,NodePos,NodePos,NodePos,0,NodeNeg,NodeNeg,NodeNeg]	 `starting at 12:00 and going clockwise
global turnY as integer[8]=[NodeNeg,NodeNeg,0,NodePos,NodePos,NodePos,0,NodeNeg]

global turns as integer = 0
global offset as integer[8]=[north,northwest,east,southwest,south,southeast,west,northeast]
global angle  as integer[8]=[0,45,90,135,180,225,270,315]

`TEXT
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
#constant ProductionText 13
#constant UnitText 14
#constant IllegalText 15
#constant NumeralText 16
#constant NumeralText2 17
#constant MusicText 18
#constant SoundText 19
#constant Gill 50
#constant WeaponText 100
#constant StatText 200

`SPRITES
#constant PlayerTankGroup 1
#constant AITankGroup 2
#constant BaseGroup 3
#constant AIBaseGroup 4
#constant SpriteConGroup 5
#constant SpriteConBaseGroup 6
#constant SpriteConUnits 7

#constant LightTank 1
#constant MediumTank 2
#constant HeavyTank 3
#constant Battery 4
#constant Mech 5
#constant Engineer 6
#constant Question 7
#constant UnitTypes 6

#constant BaseIris 23
#constant BlankSprite 24
#constant FieldSeries 25
#constant BaseDialog 50
#constant Dialog 100
#constant Splash 102
#constant InterfaceSeries 103
#constant WeaponSeries 200
#constant MissileSeries 201
#constant ExplodeSeries 202

#constant HiliteSeries 250
#constant PlayerHealthSeries 300
#constant AIHealthSeries 350
#constant PlayerCoverSeries 400
#constant AICoverSeries 450
#constant PlayerTankSeries 500
#constant AITankSeries 550
#constant FOWseries 600
#constant SpriteConSeries 650
#constant PlayerTurretSeries 700
#constant AITurretSeries 750
#constant TargetSeries 800
#constant PlayerBaseSeries 850
#constant AIBaseSeries 875
#constant BaseHaloSeries 900
#constant PlayerDepotSeries 950
#constant AIDepotSeries 1000
#constant MechGuySeries 1050
#constant MineSeries 1100
#constant EMPSeries 1500
#constant StunSeries 1600
#constant TerrainSeries1 1700
#constant TerrainSeries2 1701

`SOUNDS
global ClickSound
global OKSound
global GameOverSound
global TankSound
global BangSound
global BuildBaseSound
global ExplodeSound
global RocketSound
global LaserSound
global HeavyLaserSound
global SpawnSound
global MechSound
global HealSound
global ErrorSound
global ExplodingSound
global MusicSound
global EMPSound
global MineSound
global MineBangSound
global YesSirSound
global CopySound
Global AcknowledgedSound
global OnMyWaySound
global RogerThatSound
global TargetSound
global LockOnSound
global Silence

BangSound = LoadSound("bang2.wav")
BuildBaseSound = LoadSound( "HoverbikeEnd.wav" )
ExplodeSound = LoadSound("explode.wav")
ClickSound = LoadSound("PlasticClick.wav")
SpawnSound = LoadSound("LevelOnSinister.wav")
MineSound = LoadSound("TripodDestroyed.wav")
MineBangSound = LoadSound("ExplosionPlain.wav")
HeavyLaserSound = LoadSound( "BeamElectro_01.wav" )
MechSound = LoadSound("MotorClose_01.wav")
HealSound = LoadSound("HealGlassy.wav")
GameOverSound = LoadSound( "GameOverRobot.wav" )

EMPSound = LoadSoundOGG("EMP.ogg")
TankSound = LoadSoundOGG("Rumble2.ogg")
ErrorSound = LoadSoundOGG("EdgeHit2.ogg")
RocketSound = LoadSoundOGG("rocket.ogg" )
ExplodingSound = LoadSoundOGG("Exploding.ogg")
LaserSound = LoadSoundOGG( "laser3.ogg" )
MusicSound = LoadMusicOGG( "Evil Incoming_01.ogg" )
RogerThatSound = LoadSoundOGG( "rogerthatProcess.ogg" )
YesSirSound = LoadSoundOGG( "YesSirProcessed_01.ogg" )
CopySound = LoadSoundOGG( "CopyProcessed_01.ogg" )
AcknowledgedSound = LoadSoundOGG( "AcknowlegedProcessed_01.ogg" )
OnMyWaySound = LoadSoundOGG( "OnMyWayProcessed_01.ogg" )
OKSound = LoadSoundOGG( "Ok_01.ogg" )
TargetSound = LoadSoundOGG("Target Acquired_01.ogg" )
LockOnSound = LoadSoundOGG( "Locked On_01.ogg" )
Silence = LoadSoundOGG( "Silent.ogg" )

global vol as integer = 50
global orders as integer[7] `OrderSounds + 1
#constant OrderSounds 6
orders[0] = YesSirSound
orders[1] = CopySound
orders[2] = AcknowledgedSound
orders[3] = OnMyWaySound
orders[4] = RogerThatSound
orders[5] = OKSound
orders[6] = Silence

function SoundVolume()
	SetSoundInstanceVolume( BangSound, vol )
	SetSoundInstanceVolume( BuildBaseSound, vol )
	SetSoundInstanceVolume( ExplodeSound, vol )
	SetSoundInstanceVolume( ClickSound, vol )
	SetSoundInstanceVolume( SpawnSound, vol )
	SetSoundInstanceVolume( EMPSound, vol )
	SetSoundInstanceVolume( MineSound, vol )
	SetSoundInstanceVolume( MineBangSound, vol )
	SetSoundInstanceVolume( HeavyLaserSound, vol )
	SetSoundInstanceVolume( MechSound, vol )
	SetSoundInstanceVolume( HealSound, vol )
	SetSoundInstanceVolume( TankSound, vol )
	SetSoundInstanceVolume( ErrorSound, vol )
	SetSoundInstanceVolume( RocketSound, vol )
	SetSoundInstanceVolume( ExplodingSound, vol )
	SetSoundInstanceVolume( LaserSound, vol )
	SetSoundInstanceVolume( TargetSound, vol )
	SetSoundInstanceVolume( LockOnSound, vol )
	for i = 0 to OrderSounds
		SetSoundInstanceRate( orders[i],.5 )
		SetSoundInstanceVolume( orders[i],vol )
	next i
endfunction


`STRINGS

global type$ as string[9,1]	 `# of UnitTypes + 3
global armor$ as string[9,1]
global weapon$ as string[9,2]
global movement$ as string[9,1]
global cost$ as string[9,1]

type$[1,0] = "LASER TANK"
type$[2,0] = "MEDIUM TANK"
type$[3,0] = "HEAVY TANK"
type$[4,0] = "BATTERY"
type$[5,0] = "MECH"
type$[6,0] = "ENGINEER"

armor$[1,0] = "ARMOR  50%"
armor$[2,0] = "ARMOR  75%"
armor$[3,0] = "ARMOR  100%"
armor$[4,0] = "ARMOR  33%"
armor$[5,0] = "ARMOR  75%"
armor$[6,0] = "ARMOR  10%"

weapon$[1,0] = "MEDIUM LASER  range --, damage 10%, rounds --"
weapon$[2,0] = "MEDIUM LASER  range --, damage 10%, rounds --"
weapon$[2,1] = "MEDIUM CANNON  range 3, damage 25%, rounds --"
weapon$[3,0] = "HEAVY LASER  range --, damage 25%, rounds --"
weapon$[3,1] = "HEAVY CANNON  range 3, damage 35%, rounds --"
weapon$[4,0] = "MISSILES  range --, damage 40%, rounds 10"
weapon$[5,0] = "MISSILES  range --, damage 40%, rounds 5"
weapon$[5,1] = "HEAVY LASER  range --, damage 25%, rounds --"
weapon$[6,0] = "MINES  range 0, damage 40%, rounds 4"
weapon$[6,1] = "EMP  range 3, damage **, rounds 4"
weapon$[6,2] = "** disables enemy & friendly units for 1 turn"

movement$[1,0] = "MOVES  8"
movement$[2,0] = "MOVES  5"
movement$[3,0] = "MOVES  3"
movement$[4,0] = "MOVES  7"
movement$[5,0] = "MOVES  4"
movement$[6,0] = "MOVES  3"

cost$[1,0] = "UNIT COST  50"
cost$[2,0] = "UNIT COST  100"
cost$[3,0] = "UNIT COST  200"
cost$[4,0] = "UNIT COST  250"
cost$[5,0] = "UNIT COST  300"
cost$[6,0] = "UNIT COST  200"


`TANKS

global BarHeight as integer
BarHeight = NodeSize * .75
global BarOffset as integer
BarOffset = floor((NodeSize-BarHeight)/2)

global PlayerCount as integer
global AICount as integer

global alpha as integer
global glow as integer

`patrol zone
global topRow as integer
global bottomRow as integer
topRow = NodeSize * 2
bottomRow = OpenRows * NodeSize

`depots
type depotType
	spriteID as integer
	node as integer
endtype
global DepotRange as integer
DepotRange = MaxWidth / 2
global PlayerDepotNode as depotType[]
global AIDepotNode as depotType[]

`player tank glow
#constant Brighter 9
#constant Brightest 255
#constant Darker -9
#constant GlowMax 255
#constant GlowMin 0

`weapons
#constant cannon 0
#constant cannonDamage .25
global cannonRange as integer
cannonRange = nodeSize * 4

#constant laser 1
#constant laserDamage .1
global laserRange as integer
//~ laserRange = nodeSize * 8
laserRange = Unset
global smokeImage as integer
global whiteSmokeImage as integer

#constant missile 2
#constant missileDamage .4
global missileRange as integer
missileRange = nodeSize * 8

#constant heavyCannon 3
#constant heavyCannonDamage .35
global heavyCannonRange as integer
heavyCannonRange = cannonRange

#constant heavyLaser 4
#constant heavyLaserDamage .25
global heavyLaserRange as integer
//~ heavyLaserRange = nodeSize * 8
heavyLaserRange = Unset

#constant mine 5
#constant mineDamage .4
global mineRange as integer = 0

#constant emp 6
#constant empDamage 0
global empRange as integer
empRange = nodeSize * 5


type tankType
	OpenList as integer[]
	ClosedList as integer[]
	parentNode as integer[]

	X as integer
	y as integer
	node as integer
	goalNode as integer

	alive as integer
	stunMarker as integer
	stunned as integer
	target as integer
	moveTarget as integer
	index as integer
	moves as integer
	movesAllowed as integer
	route as integer
	totalTerrainCost as integer

	team as integer
	line as integer
	hilite as integer
	bullsEye as integer
	cover as integer
	vehicle as integer
	weapon as integer
	rounds as integer
	range as integer
	missiles as integer
	mines as integer
	charges as integer
	//~ patrolDirection as integer
	nearestPlayer as integer
	sound as integer
	volume as integer

	FOW as integer
	FOWSize as integer
	FOWOffset as integer
	bodyID as integer
	turretID as integer
	healthID as integer
	bodyImageID as integer
	turretImageID as integer
	healthBarImageID as integer

	speed as Float
	bodyW as Float
	bodyH as Float
	turretW as Float
	turretH as Float
	scale as Float
	health as Float
	minimumHealth as Float
	maximumHealth as Float
	damage as Float
	costFromStart as Float

	body$ as String
	turret$ as String
endtype


global unitCost as integer[unitTypes]
unitCost[LightTank] = 50
unitCost[MediumTank] = 100
unitCost[HeavyTank] = 200
unitCost[Battery] = 250
unitCost[Mech] = 300
unitCost[Engineer] = 200

#constant AI %0000000000000010
#constant Player %0000000000000100
#constant CoverAlpha 175
#constant Unoccupied 0
#constant PlayerTeam 1
#constant AITeam 2

#constant HeavyHealthMax 1
#constant MediumHealthMax .75
#constant LightHealthMax .5
#constant BatteryHealthMax .33
#constant EngineerHealthMax .1

global AISurviving as integer
global PlayerSurviving as integer

global PlayerLast as integer
global AIPlayerLast as integer


global AITank as tankType[]
global PlayerTank as tankType[]
global MechGuy as tankType[2]
global buffer
MechGuy[0].bodyID = MechGuySeries
MechGuy[0].turretID = MechGuySeries + 1
MechGuy[0].speed = .5
MechGuy[0].scale = 2
buffer = MechGuy[0].scale * NodeSize

#constant BaseProdValue 5
global PlayerProdUnits as integer
global AIProdUnits as integer
global BaseHalo as integer


`--TERRAIN--

#constant Impassable 0
#constant AIDepot 6
#constant PlayerDepot 2
#constant AIBase 5
#constant PlayerBase 4

#constant DepotSize 22
#constant DepotDepth 3

global depotOffset as integer
depotOffset = NodeOffset/2


`RANDOM MAP STUFF
#constant ShapeCount 42
#constant ShapeGrid 49
#constant ShapeSize 7
#constant OpenNodeCount 392
global Quad as integer[4]
global Shapes as integer[ShapeCount,ShapeGrid]
global MaxMapX
global MaxMapY
global TreeSprite = TerrainSeries1
global Impass = TerrainSeries2
global midWidth
global midDepth
MaxMapX  = OpenColumns * NodeSize
MaxMapY  = OpenRows * NodeSize
midWidth = (Columns/2)-2
midDepth = (ShapeSize*Columns)+(Columns*2)

Quad[0] = Columns + 2		  `upper left
Quad[1] = Quad[0] + midWidth  `upper right
Quad[2] = Quad[0] + midDepth  `lower left
Quad[3] = Quad[1] + midDepth  `lower right

`create impass shape array
ImpassFile = OpenToRead("7x7x42.txt")
for i = 0 to ShapeCount-1
	for j = 0 to ShapeGrid-1
		Shapes[i,j] = val(chr(ReadByte(ImpassFile)))
	next j
next i
CloseFile(ImpassFile)


`RANDOM BASES/DEPOTS
#constant Sectors 6
#constant SectorNodes 32
#constant SectorWidth 4
#constant SectorHeight 8
global PlayerSectorNodes as integer[Sectors,SectorNodes]
global AISectorNodes as integer[Sectors,SectorNodes]
global PlayerSectorOrigin as integer[Sectors] = [34,38,42,290,294,298]
global AISectorOrigin as integer[Sectors] = [50,54,58,306,310,314]

for s = 0 to Sectors-1
	i = 0
	for r = 0 to SectorHeight-1
		row = r * Columns
		for c = 0 to SectorWidth-1
			PlayerSectorNodes[s,i] = PlayerSectorOrigin[s] + row
			AISectorNodes[s,i] = AISectorOrigin[s] + row
			inc row : inc i
		next c
	next r
next s


`TERRAIN MOVEMENT MODIFIER
#constant Trees 3
#constant Clear 1
global cost as integer[10]
`map terrain to cost
for i = 0 to 9 : cost[i]=Clear : next i
cost[0]=Impassable
cost[3]=Trees

`TERRAIN DAMAGE MODIFIER
#constant TreeMod .5
#constant ClearMod 1
global TRM as Float[10]
`map terrain to damage modifier
for i = 0 to 9 : TRM[i]=ClearMod : next i
TRM[3]=TreeMod


global Iris = BaseIris
global IrisFrames = 62

`map
type mapType
	x as integer	`screen coordinates
	y as integer
		base as integer
	nodeX as integer
	nodeY as integer
	team as integer
	cost as integer
	mineSprite as integer
	mineType as integer
	terrain as integer
	moveTarget as integer
	depotID as integer
	heuristic as Float
	modifier as Float
endtype
global mapTable as mapType[MapSize]
global treeDummy as integer
global impassDummy as integer

type baseType
	node as integer
	spriteID as integer
	zoneID as integer
endtype
global AIBaseCount as integer
global PlayerBaseCount as integer
global PlayerBases as baseType[]
global AIBases as baseType[]

`--INTERFACE--

global NumY as integer
global NumX as integer
global NumX1 as integer

type deviceType
	scale
	buttSize
	textSize
	buttX1
	buttX2
	YesNoX4a
	device as string
endtype
global dev as deviceType

dev.device = GetDeviceBaseName()
select dev.device
	case "windows","mac"
		dev.buttSize = 64
		dev.textSize = 28
		dev.scale = 1
		dev.buttX1 = dev.buttSize + 8
		dev.buttX2 = dev.buttSize * 2.7
		dev.YesNoX4a = MaxWidth-dev.buttSize - 6
		NumX = dev.buttSize*1.7
		NumX1 = NumX*1.93
	endcase
	case "ios","android","blackberry"
		if FindString( GetDeviceType(),"ipad" )
			dev.buttSize = 64
			dev.textSize = 28
			dev.scale = 1
			dev.buttX1 = dev.buttSize + 8
			dev.buttX2 = dev.buttSize * 2.7
			dev.YesNoX4a = MaxWidth-dev.buttSize - 6
			NumX = dev.buttSize*1.7
			NumX1 = NumX*1.93
		else
			dev.buttSize = 80
			dev.textSize = 32
			dev.scale = 2
			dev.buttX1 = dev.buttSize - 4
			dev.buttX2 = dev.buttSize * 2.6
			dev.YesNoX4a = MaxWidth-dev.buttSize + 6
			NumX = dev.buttSize*1.5
			NumX1 = NumX*2.1
		endif
	endcase
endselect

global buttY as integer
buttY = MaxHeight - 65
NumY = buttY - (dev.ButtSize/1.5)

global AlertW
global AlertH

global YesNoX1
global YesNoY1

global YesNoX2a
global YesNoX2b
global YesNoY2

global YesNoX3a
global YesNoX3b
global YesNoX3c
global YesNoY3
global YesNoY3a

global YesNoX4a
global YesNoX4b
global YesNoY4

AlertW = 300*dev.scale
AlertH = 250*dev.scale

YesNoX1  = MiddleX-(AlertW/2)								`alert dialog
YesNoY1  = MiddleY-(AlertH/3)

YesNoX2a = (YesNoX1+AlertW)-dev.buttSize-10					`base production
YesNoX2b = (YesNoX1+AlertW)-(dev.buttSize*2)-20
YesNoY2  = (YesNoY1+AlertH)-dev.buttSize-(dev.scale*10)

YesNoX3a = MaxWidth-(dev.buttSize*1.5)						`splash screen
YesNoX3b = MaxWidth-(dev.buttSize*2.75)
YesNoX3c = MaxWidth-(dev.buttSize*4)
YesNoY3  = buttY-50
YesNoY3a = buttY-dev.buttSize+50

YesNoX4a = dev.YesNoX4a										`main game screen
YesNoX4b = MaxWidth-dev.buttX2+20
YesNoY4  = buttY

global turnImage as integer
global turnImageDown as integer
global cannonImage as integer
global cannonImageDown as integer
global laserImage as integer
global laserImageDown as integer
global missileImage as integer
global missileImageDown as integer
global heavyCannonImage as integer
global heavyCannonImageDown as integer
global heavyLaserImage as integer
global heavyLaserImageDown as integer
global EMPImage
global EMPImageDown
global MineImage
global MineImageDown
global quitImage as integer
global quitImageDown as integer
global CancelImage as integer
global CancelImageDown as integer
global AcceptImage as integer
global AcceptImageDown as integer
global SettingsImage as integer
global SettingsImageDown as integer
global ProductionUnits as integer
global TurnCount as integer
global JoyButtonImage as integer
global JoyButtonDownImage as integer
global Joystick as integer
global JoyArrows as integer


turnImage = InterfaceSeries+1
turnImageDown = InterfaceSeries+2
cannonImage = InterfaceSeries+3
cannonImageDown = InterfaceSeries+4
laserImage = InterfaceSeries+5
laserImageDown = InterfaceSeries+6
missileImage = InterfaceSeries+7
missileImageDown = InterfaceSeries+8
heavyCannonImage = InterfaceSeries+9
heavyCannonImageDown = InterfaceSeries+10
heavyLaserImage = InterfaceSeries+11
heavyLaserImageDown = InterfaceSeries+12


global laserFull as integer
global laserOut  as integer
global laserFade as integer
laserFull = MakeColor( 255, 255, 255 )
laserOut  = Makecolor( 0, 0, 0 )
laserFade = Makecolor( 128, 128, 128 )


global square as integer
square = InterfaceSeries+13

quitImage = InterfaceSeries+14
quitImageDown = InterfaceSeries+15

global AlertBackGround as integer
AlertBackGround = InterfaceSeries+16

CancelImage = InterfaceSeries+17
CancelImageDown = InterfaceSeries+18
AcceptImage = InterfaceSeries+19
AcceptImageDown = InterfaceSeries+20
SettingsImage = InterfaceSeries+21
SettingsImageDown = InterfaceSeries+22
ProductionUnits = InterfaceSeries+23
TurnCount = InterfaceSeries+24
JoyButtonImage = InterfaceSeries+25
JoyButtonDownImage = InterfaceSeries+26
Joystick = InterfaceSeries+27
JoyArrows = InterfaceSeries+28

MineImage = InterfaceSeries+29
MineImageDown = InterfaceSeries+30
EMPImage = InterfaceSeries+31
EMPImageDown = InterfaceSeries+32

type sliderType
	ID
	x
	y
	tx
	ty
	w
	h
endtype

global MusicSlide as sliderType
global SoundSlide as sliderType
global MusicScale as sliderType
global SoundScale as sliderType

MusicSlide.ID = InterfaceSeries+33
SoundSlide.ID = InterfaceSeries+34
MusicScale.ID = InterfaceSeries+35
SoundScale.ID = InterfaceSeries+36

MusicScale.x = MiddleX+95
MusicScale.y = MiddleY+260
MusicScale.w = 556
MusicScale.h = 24
MusicScale.tx = MusicScale.x
MusicScale.ty = MusicScale.y+MusicScale.h

SoundScale.x = MusicScale.x
SoundScale.y = MusicScale.y+90
SoundScale.w = MusicScale.w
SoundScale.h = MusicScale.h
SoundScale.tx = MusicScale.x
SoundScale.ty = SoundScale.y+SoundScale.h

MusicSlide.w = 80
MusicSlide.h = 80
MusicSlide.x = MusicScale.x+(MusicScale.w/2)-(MusicSlide.w/2)
MusicSlide.y = MusicScale.y-(MusicSlide.h/4)

SoundSlide.w = MusicSlide.w
SoundSlide.h = MusicSlide.h
SoundSlide.x = MusicSlide.x
SoundSlide.y = MusicSlide.y+90

#constant UnitX 130
#constant UnitY 100

`SPRITES Misc

global Fire1 = WeaponSeries
global Missile1 = MissileSeries

global MineExplode = MineSeries
global Mine1
Mine1 = MineSeries + 1

global EMP1
EMP1 = EMPSeries


global field as integer  `board
global Explode1 as integer
global Explode2 as integer
`SPLASHSCREEN

#constant SpectrumW 556
#constant SpectrumH 100
#constant ValueH 50
#constant cy1 410
#constant cy2 528

global pickAI as ColorSpec
global pickPL as ColorSpec
global AISpectrumSprite as integer
global PlayerSpectrumSprite as integer
global AIValueSprite as integer
global PlayerValueSprite as integer

type dialogTankType
	ID as integer
	image$ as String
	imageID as integer
endtype

type gridType
	ID as integer
	imageID as integer
	x1 as integer
	y1 as integer
	x2 as integer
	y2 as integer
endtype

global SpriteConSize as integer = 112
global Clones as integer[]

remstart
global OpenNodes as integer[4,OpenQuadNodes]

for q = 0 to 3
	index = 0
	for r = 0 to QuadRows-1
		rowTotal = r*Columns
		for c = 0 to QuadColumns-1
			OpenNodes[q,index] = Quad[q]+rowTotal+c
			inc index
		next c
	next r
next q
#constant OpenQuadNodes 98	`OpenNodeCount/4

`DON'T NEED FOR NEW PATROL
global patrolVectors as integer[16] = [0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7
`OLD PATROLSCAN
global patrolScanX as integer[8]=[0,DLSpos,NodePos,DLSpos,0,DLSneg,NodeNeg,DLSneg]	 `starting at 12:00 and going clockwise
global patrolScanY as integer[8]=[NodeNeg,DLSneg,0,DLSpos,NodePos,DLSpos,0,DLSneg]
remend
