
`SCREEN/MAP
#constant Columns 32	 `nodes
#constant FirstCell = 33
#constant OpenColumns 30
#constant Rows 20
#constant OpenRows 16
#constant FirstRow 1
#constant MapSize 640	 `Rows*Columns

global OpenMapSize as float
global LiveArea as float
LiveArea = Columns * ( OpenRows + 1 )
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
global ScreenWidth as integer
global ScreenHeight as integer

ScreenWidth = GetDeviceWidth()
ScreenHeight = GetDeviceHeight()

AspectRatio = MaxWidth/MaxHeight
NodeSize = MaxWidth/Columns
NodeOffset = NodeSize/2
MapWidth = OpenColumns*NodeSize
MapHeight = OpenRows*NodeSize
MiddleX = MaxWidth/2
MiddleY = MapHeight/2

global zoneRadius as integer
#constant FlyRadius 8
#constant PatrolRadius 8
zoneRadius = FlyRadius * NodeSize

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

`GENERAL
#constant Unset 100000
#constant Empty -1
#constant Minimum 0
#constant NotFound .1
#constant body 0
#constant turret 1
#constant Goal 1
#constant Complete 1
#constant BarWidth 3	 `Health Bar

#constant Supply$ = "Supply Boost!"		     `all units repaired and re-armed
#constant Reinforcement$ = "Reinforcements!" `production units doubled
#constant Weather$ = "Severe Weather!"		 `movement halved
#constant Interdiction$ = "Interdiction!"	 `production halted
#constant Sabotage$ = "Sabotage!"			 `eliminate one random unit
#constant EventNum 21

global casualties as integer = Null
global reinforce as integer = 1
global weather as float = 1

global Events as integer = On
global Event$ as string = ""
global RandomEvent as string[EventNum]
RandomEvent[0] = Supply$
RandomEvent[1] = Reinforcement$
RandomEvent[2] = Weather$
RandomEvent[3] = Interdiction$
RandomEvent[4] = Sabotage$


global DLS as integer
DLS = NodeSize*sqrt(2) `Diagonal Length of Square
#constant DLSneg -64
#constant DLSpos 64
#constant NodeNeg -45
#constant NodePos 45

`starting at 12:00 and going clockwise
global patrolScanX as integer[16]=[0,DLSpos,NodePos,DLSpos,0,DLSneg,NodeNeg,DLSneg,0,DLSpos,NodePos,DLSpos,0,DLSneg,NodeNeg,DLSneg]
global patrolScanY as integer[16]=[NodeNeg,DLSneg,0,DLSpos,NodePos,DLSpos,0,DLSneg,NodeNeg,DLSneg,0,DLSpos,NodePos,DLSpos,0,DLSneg]


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
#constant VictoryText 20
#constant DefeatText 21
#constant LimitText 22
#constant ConfirmText 23
#constant MapText 24
#constant ProdUnitText 25
#constant ONOFFText 26

#constant Gill 50
#constant Avenir 60
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

`Hovercraft
#constant FullyOpen 21
#constant Closing 22
#constant FullyClosed 40

#constant blockGroup 9
#constant depotGroup 10
#constant AIdepotGroup 11

#constant HoverCraft 1
#constant Battery 2
#constant MediumTank 3
#constant HeavyTank 4
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

#constant BulletSeries 240
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
#constant AIDepotSeries 975

#constant MechGuySeries 1050
#constant MineSeries 1100
#constant EMPSeries 1500
#constant StunSeries 1600
#constant TerrainSeries1 1700
#constant TerrainSeries2 1701
#constant TerrainSeries3 1703
#constant TerrainSeries4 1704

global AcquaSprite as integer = TerrainSeries3
global RoughSprite as integer = TerrainSeries4

type boxType
	x1
	y1
	x2
	y2
endtype

global Box as boxType	`for FOW Offset


`SOUNDS
global AcknowledgedSound
global BangSound
global BuildBaseSound
global ClickSound
global CopySound
global DeActivateSound
global DefeatSound
global DisruptorSound
global EMPSound
global EngineerSound
global EngineSound
global EnterSound
global ErrorSound
global ExplodeSound
global ExplodingSound
global HealSound
global HeavyLaserSound
global InterdictSound
global LaserSound
global LightningSound
global LockOnSound
global LoganSound
global MachineGunSound
global MechSound
global MineBangSound
global MineSound
global MusicSound
global OKSound
global OnMyWaySound
global RenforcementsSound
global RocketSound
global RogerThatSound
global SaboSound
global Silence
global SpawnSound
global TankSound
global TargetSound
global VictorySound
global YesSirSound

BangSound = LoadSound("bang2.wav")
BuildBaseSound = LoadSound( "HoverbikeEnd.wav" )
ClickSound = LoadSound("PlasticClick.wav")
DeActivateSound = LoadSoundOGG( "DeactivateBeep.ogg" )
DefeatSound = LoadSound("Defeat.wav")
DisruptorSound = LoadSoundOGG("DISRUPTOR.ogg")
EMPSound = LoadSoundOGG("EMP.ogg")
EngineerSound = LoadSoundOGG("MotorClose_01_01.ogg")
EngineSound = LoadSoundOGG( "Jet2_01.ogg" )
EnterSound = LoadSound("PickUpHeavy.wav")
ErrorSound = LoadSoundOGG("EdgeHit2.ogg")
ExplodeSound = LoadSound("explode.wav")
ExplodingSound = LoadSoundOGG("Exploding.ogg")
HealSound = LoadSound("HealGlassy.wav")
HeavyLaserSound = LoadSound( "BeamElectro_01.wav" )
InterdictSound = LoadSoundOGG("Interdict.ogg")
LaserSound = LoadSoundOGG( "laser3.ogg" )
LightningSound = LoadSoundOGG("LightningBolt.ogg")
LockOnSound = LoadSoundOGG( "Locked On_01.ogg" )
LoganSound = LoadSoundOGG("Logan.ogg" )
MachineGunSound = LoadSoundOGG( "MachineGun.ogg" )
MechSound = LoadSoundOGG("WalkerStompLow.ogg")
MineBangSound = LoadSound("ExplosionPlain.wav")
MineSound = LoadSound("TripodDestroyed.wav")
MusicSound = LoadMusicOGG( "Evil Incoming_01.ogg" )
RenforcementsSound = LoadSoundOGG("reinforcements.ogg")
RocketSound = LoadSoundOGG("rocket.ogg" )
SaboSound = LoadSound("ExitOpenAztec.wav")
SpawnSound = LoadSound("LevelOnSinister.wav")
TankSound = LoadSoundOGG("Rumble2.ogg")
TargetSound = LoadSoundOGG("Target Acquired_01.ogg" )
VictorySound = LoadSound("MagicReveal.wav")

YesSirSound = LoadSoundOGG( "YesSirProcessed_01.ogg" )
CopySound = LoadSoundOGG( "CopyProcessed_01.ogg" )
AcknowledgedSound = LoadSoundOGG( "AcknowlegedProcessed_01.ogg" )
OnMyWaySound = LoadSoundOGG( "OnMyWayProcessed_01.ogg" )
RogerThatSound = LoadSoundOGG( "rogerthatProcess.ogg" )
OKSound = LoadSoundOGG( "Ok_01.ogg" )
Silence = LoadSoundOGG( "Silent.ogg" )

global vol as integer = 100
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
	SetSoundInstanceVolume( ClickSound, vol )
	SetSoundInstanceVolume( DeActivateSound, vol )
	SetSoundInstanceVolume( DefeatSound, vol )
	SetSoundInstanceVolume( DisruptorSound, vol )
	SetSoundInstanceVolume( EMPSound, vol )
	SetSoundInstanceVolume( EngineerSound, vol )
	SetSoundInstanceVolume( EngineSound, vol )
	SetSoundInstanceVolume( EnterSound, vol )
	SetSoundInstanceVolume( ErrorSound, vol )
	SetSoundInstanceVolume( ExplodeSound, vol )
	SetSoundInstanceVolume( ExplodingSound, vol )
	SetSoundInstanceVolume( HealSound, vol )
	SetSoundInstanceVolume( HeavyLaserSound, vol )
	SetSoundInstanceVolume( InterdictSound, vol )
	SetSoundInstanceVolume( LaserSound, vol )
	SetSoundInstanceVolume( LightningSound, vol )
	SetSoundInstanceVolume( LockOnSound, vol )
	SetSoundInstanceVolume( LoganSound, vol )
	SetSoundInstanceVolume( MachineGunSound, vol )
	SetSoundInstanceVolume( MechSound, vol )
	SetSoundInstanceVolume( MineBangSound, vol )
	SetSoundInstanceVolume( MineSound, vol )
	SetSoundInstanceVolume( MusicSound, vol )
	SetSoundInstanceVolume( RenforcementsSound, vol )
	SetSoundInstanceVolume( RocketSound, vol )
	SetSoundInstanceVolume( SaboSound, vol )
	SetSoundInstanceVolume( SpawnSound, vol )
	SetSoundInstanceVolume( TankSound, vol )
	SetSoundInstanceVolume( TargetSound, vol )
	SetSoundInstanceVolume( VictorySound, vol )
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

type$[1,0] = "HOVERCRAFT"
type$[2,0] = "BATTERY"
type$[3,0] = "MEDIUM TANK"
type$[4,0] = "HEAVY TANK"
type$[5,0] = "MECH"
type$[6,0] = "ENGINEER"

armor$[1,0] = "ARMOR  66%"	`50%, now Light = 33%, doubled
armor$[2,0] = "ARMOR  100%"	`33%, now Battery = 50%, doubled
armor$[3,0] = "ARMOR  150%"	`75%, doubled
armor$[4,0] = "ARMOR  200%"	`100%, doubled
armor$[5,0] = "ARMOR  150%"	`75%, doubled
armor$[6,0] = "ARMOR  20%"	`10%, doubled


weapon$[1,0] = "BALLISTIC WEAPON  range 4, damage 10%, rounds --"
weapon$[2,0] = "MISSILES  range --, damage 40%, rounds 10"
weapon$[3,0] = "LASER  range --, damage 10%, rounds --"
weapon$[3,1] = "CANNON  range 4, damage 25%, rounds --"
weapon$[4,0] = "HEAVY LASER  range --, damage 25%, rounds --"
weapon$[4,1] = "HEAVY CANNON  range 4, damage 35%, rounds --"
weapon$[5,0] = "MISSILES  range --, damage 40%, rounds 5"
weapon$[5,1] = "DISRUPTOR  range 4, damage 40%**, rounds --"
weapon$[5,2] = "** affects all enemy & friendly units in range"
weapon$[6,0] = "MINES  range 0, damage 40%, rounds 4"
weapon$[6,1] = "EMP  range 3, damage **, rounds 4"
weapon$[6,2] = "** disables enemy & friendly units for 1 turn"

movement$[1,0] = "MOVES  8, NO TERRAIN MOVEMENT PENALTY"
movement$[2,0] = "MOVES  7, PENALTY: Rough -1, Trees -2"
movement$[3,0] = "MOVES  5, PENALTY: Rough -1, Trees -2"
movement$[4,0] = "MOVES  3, PENALTY: Rough -1, Trees -2"
movement$[5,0] = "MOVES  4, PENALTY: Rough -1, Trees -2"
movement$[6,0] = "MOVES  3, NO TERRAIN MOVEMENT PENALTY"

cost$[1,0] = "UNIT COST  100"
cost$[2,0] = "UNIT COST  250"
cost$[3,0] = "UNIT COST  100"
cost$[4,0] = "UNIT COST  200"
cost$[5,0] = "UNIT COST  300"
cost$[6,0] = "UNIT COST  150"


`TANKS

#constant UnitLimit 10

global BarHeight as integer
BarHeight = NodeSize * .75
global BarOffset as integer
BarOffset = floor((NodeSize-BarHeight)/2)

global PlayerCount as integer
global AICount as integer

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

global PlayerDepotCount as integer
global AIDepotCount as integer


`player tank glow
#constant Brighter 9
#constant Brightest 255
#constant Darker -9
#constant GlowMax 255
#constant GlowMin 0
global alpha as integer
global glow as integer

`weapons
#constant cannon 0
#constant cannonDamage .25
global cannonRange as integer
cannonRange = nodeSize * 4

#constant laser 1
#constant laserDamage .1
global laserRange as integer
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
heavyLaserRange = Unset

#constant mine 5
#constant mineDamage .4
global mineRange as integer = 0

#constant emp 6
#constant empDamage 0
global empRange as integer
empRange = nodeSize * 5

#constant disruptor 7
#constant disruptorDamage .4
global disruptorRange as integer
global disruptorRadius as float
disruptorRange = nodeSize * 3
disruptorRadius = disruptorRange/2

#constant machineGun 8
#constant machineGunDamage .1
global machineGunRange as integer
machineGunRange = cannonRange


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
unitCost[HoverCraft] = 100
unitCost[Battery] = 250
unitCost[MediumTank] = 100
unitCost[HeavyTank] = 200
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
#constant LightHealthMax .33	`.5
#constant BatteryHealthMax .5	`.33
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

#constant BaseProdMin 5
global BaseProdValue as integer = BaseProdMin

global PlayerProdUnits as integer
global AIProdUnits as integer
global BaseHalo as integer


`--TERRAIN--
#constant Clear 1
#constant Rough 2
#constant Trees 3
#constant AIBase 4
#constant AIDepot 5
#constant PlayerDepot 6
#constant PlayerBase 7
#constant Impassable 8
#constant Water 9

#constant DepotSize 33
#constant DepotDepth 3

global depotOffset as integer
depotOffset = NodeOffset/2


`RANDOM MAP STUFF
#constant ImpassOn 1
#constant WaterOn 2
#constant ShapeFile 4
#constant ShapeCount 26
#constant ShapeGrid 98
#constant ShapeWidth 7
#constant ShapeHeight 14
#constant OpenNodeCount 392

global Semi as integer[2]
global Shapes as integer[Shapefile,ShapeCount,ShapeGrid]
global MaxMapX
global MaxMapY
global TreeSprite = TerrainSeries1
global Impass = TerrainSeries2
global SemiWidth
global mapImpass as integer = ImpassOn
global mapWater as integer = WaterOn
MaxMapX = OpenColumns * NodeSize
MaxMapY = OpenRows * NodeSize
SemiWidth = (Columns/2)-4

Semi[0] = Columns + 2		  	  `upper left
Semi[1] = Semi[0] + SemiWidth + 3  `upper right

`create impass shape array

for i = 1 to ShapeFile
	select i	`case 0 is zero'ed out
		case 1 : ImpassFile = OpenToRead("Impass7x14x26.txt") : endcase
		case 2 : ImpassFile = OpenToRead("Water7x14x26.txt")  : endcase
		case 3 : ImpassFile = OpenToRead("All7x14x26.txt")    : endcase
	endselect
	for j = 0 to ShapeCount-1
		for k = 0 to ShapeGrid-1 : Shapes[i,j,k] = val(chr(ReadByte(ImpassFile))) : next k
	next j
	CloseFile(ImpassFile)
next i


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
global cost as integer[10]
`map terrain to cost
for i = 0 to 9 : cost[i]=Clear : next i	`1

cost[Rough] = Rough + 1	`3
cost[Trees] = Trees		`3
cost[Impassable] = Impassable
cost[Water] = Water

`TERRAIN DAMAGE MODIFIER
#constant TreeMod .5
		#constant BaseMod .5
#constant ClearMod 1
#constant RoughMod 1.5

global TRM as Float[10]
`map terrain to damage modifier
for i = 0 to 9 : TRM[i]=ClearMod : next i
TRM[Rough]=RoughMod
TRM[Trees]=TreeMod
		TRM[AIBase]=BaseMod
		TRM[PlayerBase]=BaseMod

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
global holdTable as mapType[MapSize]

global treeDummy as integer
global impassDummy as integer
global roughDummy as integer
global waterDummy as integer
global cross as integer


type baseType
	x1
	y1
	x2
	y2
	node
	spriteID
endtype
global AIBaseCount as integer
global PlayerBaseCount as integer

global PlayerBases as baseType[]
global AIBases as baseType[]


`--INTERFACE--

global NumY
global NumX
global NumX1
global UnitX
global UnitY as integer = 105
global AlertW
global AlertH

type deviceType
	scale
	buttSize
	textSize
	slidescaleW
	slidescaleH
	slidescaleX
	slidescaleY
	device as string
endtype
global dev as deviceType

type buttonType
	ID
	UP
	DN
	x as float
	y as float
	w as float
	h as float
	tx as float
	ty as float
endtype

global acceptButt as buttonType
global cancelButt as buttonType
global settingsButt as buttonType
global mapButt as buttonType
global diceButt as buttonType
global diskButt as buttonType
global LOADBUTT as buttonType
global SAVEBUTT as buttonType
global SLOT1 as buttonType
global SLOT2 as buttonType
global SLOT3 as buttonType
global SLOT4 as buttonType
global CannonButt as buttonType
global MissileButt as buttonType
global LaserButt as buttonType
global HeavyLaserButt as buttonType
global HeavyCannonButt as buttonType
global EMPButt as buttonType
global MineButt as buttonType
global DisruptButt as buttonType
global BulletButt as buttonType
global ImpassButt as buttonType
global WaterButt as buttonType
global InfoButt as buttonType
global XButt as buttonType
global ArrowRightButt as buttonType
global Button5 as buttonType
global Button10 as buttonType
global Button15 as buttonType
global Button20 as buttonType
global Button25 as buttonType
global ONOFF as buttonType

type alertType
	ID
	x
	y
	w
	h
	accept as buttonType
	cancel  as buttonType
endtype

global alertDialog as alertType
global mapSaveDialog as alertType
global mapSlotDialog as alertType
global AlertBackGround

dev.device = GetDeviceBaseName()
select dev.device
	case "windows","mac"
		dev.buttSize = 64
		dev.textSize = 28
		dev.scale = 1
		dev.slidescaleW = 240
		dev.slidescaleH = dev.buttSize
		dev.slidescaleX = MapWidth - (dev.buttSize * 2.6) - dev.slidescaleW
		dev.slidescaleY = MapHeight + NodeSize + 30
		acceptButt.x = MaxWidth-dev.buttSize
		acceptButt.y = MaxHeight - 65
		UnitX = 450
		NumX = dev.buttSize*1.7
		NumX1 = NumX*1.93
		NumY = acceptButt.y - (dev.ButtSize/1.5)
		SLOT1.w = dev.buttSize
	endcase
	case "ios","android"
		if FindString( GetDeviceType(),"ipad" )	`add Android tablets
			dev.buttSize = 64
			dev.textSize = 28
			dev.scale = 1
			dev.slidescaleW = 240
			dev.slidescaleH = dev.buttSize
			dev.slidescaleX = MapWidth - (dev.buttSize * 2.6) - dev.slidescaleW
			dev.slidescaleY = MapHeight + NodeSize + 30
			acceptButt.x = MaxWidth-dev.buttSize
			acceptButt.y = MaxHeight - 65
			UnitX = 450
			NumX = dev.buttSize*1.7
			NumX1 = NumX*1.93
			NumY = acceptButt.y - (dev.ButtSize/1.5)
			SLOT1.w = dev.buttSize
		else
			dev.buttSize = 80
			dev.textSize = 32
			dev.scale = 2
			dev.slidescaleW = 222
			dev.slidescaleH = dev.buttSize
			dev.slidescaleX = MapWidth - (dev.buttSize * 2.75) - dev.slidescaleW
			dev.slidescaleY = MapHeight + NodeSize + 30
			acceptButt.x = MaxWidth-(dev.buttSize*.9)
			acceptButt.y = MaxHeight - 55
			UnitX = 415
			NumX = dev.buttSize*1.5
			NumX1 = NumX*2.1
			NumY = acceptButt.y - (dev.ButtSize/1.5)
			SLOT1.w = dev.buttSize * 1.5
		endif
	endcase
endselect

`DIALOGS

alertDialog.ID = InterfaceSeries
alertDialog.w = 275*dev.scale
alertDialog.h = 275*dev.scale
alertDialog.x = MiddleX-(alertDialog.w/2)
alertDialog.y = MiddleY-(alertDialog.h/3)

alertDialog.accept.x = (alertDialog.x+alertDialog.w)-dev.buttSize-10
alertDialog.accept.y = (alertDialog.y+alertDialog.h)-dev.buttSize-(dev.scale*10)
alertDialog.accept.w = dev.buttSize
alertDialog.accept.h = dev.buttSize
alertDialog.cancel.x = alertDialog.x + alertDialog.w - (alertDialog.accept.w*2) - 20
alertDialog.cancel.y = alertDialog.accept.y
alertDialog.cancel.w = dev.buttSize
alertDialog.cancel.h = dev.buttSize

mapSlotDialog.ID = InterfaceSeries+1
mapSlotDialog.w = alertDialog.w * 1.5
mapSlotDialog.h = alertDialog.h
mapSlotDialog.x = MiddleX-(mapSlotDialog.w/2)
mapSlotDialog.y = MiddleY-(mapSlotDialog.h/3)
mapSlotDialog.cancel.w = dev.buttSize
mapSlotDialog.cancel.h = dev.buttSize
mapSlotDialog.cancel.x = mapSlotDialog.x + mapSlotDialog.w - mapSlotDialog.cancel.w
mapSlotDialog.cancel.y = alertDialog.cancel.y

mapSaveDialog.ID = InterfaceSeries+2
mapSaveDialog.w = alertDialog.w
mapSaveDialog.h = alertDialog.h
mapSaveDialog.x = alertDialog.x
mapSaveDialog.y = alertDialog.y
mapSaveDialog.cancel.w = dev.buttSize
mapSaveDialog.cancel.h = dev.buttSize
mapSaveDialog.cancel.x = alertDialog.x + alertDialog.w - mapSaveDialog.cancel.w
mapSaveDialog.cancel.y = alertDialog.cancel.y

AlertBackGround = InterfaceSeries+3


`BUTTONS

`full screen buttons
acceptButt.ID = 1
acceptButt.w = dev.buttSize
acceptButt.h = dev.buttSize

cancelButt.ID = 2
cancelButt.x = acceptButt.x-(dev.buttSize*1.15)
cancelButt.y = acceptButt.y
cancelButt.w = dev.buttSize
cancelButt.h = dev.buttSize

settingsButt.ID = 3
settingsButt.x = cancelButt.x-(dev.buttSize*1.15)
settingsButt.y = acceptButt.y
settingsButt.w = dev.buttSize
settingsButt.h = dev.buttSize

mapButt.ID = 4
mapButt.x = cancelButt.x
mapButt.y = acceptButt.y
mapButt.w = dev.buttSize
mapButt.h = dev.buttSize

diskButt.ID = 5
diskButt.x = cancelButt.x
diskButt.y = acceptButt.y
diskButt.w = dev.buttSize
diskButt.h = dev.buttSize

diceButt.ID = 6
diceButt.x = settingsButt.x
diceButt.y = acceptButt.y
diceButt.w = dev.buttSize
diceButt.h = dev.buttSize

`Dialog Buttons
LOADBUTT.ID = 7
LOADBUTT.w = 80*dev.scale
LOADBUTT.h = LOADBUTT.w
LOADBUTT.x = alertDialog.x + LOADBUTT.w
LOADBUTT.y = MiddleY*1.03

SAVEBUTT.ID = 8
SAVEBUTT.w = LOADBUTT.w
SAVEBUTT.h = SAVEBUTT.w
SAVEBUTT.x = LOADBUTT.x + (LOADBUTT.w * 1.33)
SAVEBUTT.y = LOADBUTT.y

margin = SLOT1.w*1.3
SLOT1.ID = 9
SLOT1.h = SLOT1.w
SLOT1.x = MiddleX-(SLOT1.w*2.12)
SLOT1.y = LOADBUTT.y

SLOT2.ID = 10
SLOT2.w = SLOT1.w
SLOT2.h = SLOT1.h
SLOT2.x = SLOT1.x + margin
SLOT2.y = SLOT1.y

SLOT3.ID = 11
SLOT3.w = SLOT1.w
SLOT3.h = SLOT1.h
SLOT3.x = SLOT2.x + margin
SLOT3.y = SLOT1.y

SLOT4.ID = 12
SLOT4.w = SLOT1.w
SLOT4.h = SLOT1.h
SLOT4.x = SLOT3.x + margin
SLOT4.y = SLOT1.y

`Weapon and Map buttons
CannonButt.ID = 13
CannonButt.x = NodeSize * 1.5
CannonButt.y = MaxHeight - 65
CannonButt.w = dev.buttSize

MissileButt.ID = 14
MissileButt.x = CannonButt.x
MissileButt.y = CannonButt.y
MissileButt.w = dev.buttSize

LaserButt.ID = 15
LaserButt.x = CannonButt.x + (CannonButt.w*1.4)
LaserButt.y = CannonButt.y
LaserButt.w = dev.buttSize

HeavyLaserButt.ID = 16
HeavyLaserButt.x = CannonButt.x + (CannonButt.w*1.4)
HeavyLaserButt.y = CannonButt.y
HeavyLaserButt.w = dev.buttSize

HeavyCannonButt.ID = 17
HeavyCannonButt.x = CannonButt.x
HeavyCannonButt.y = CannonButt.y
HeavyCannonButt.w = dev.buttSize

EMPButt.ID = 18
EMPButt.x = CannonButt.x + (CannonButt.w*1.65)
EMPButt.y = CannonButt.y
EMPButt.w = dev.buttSize

MineButt.ID = 19
MineButt.x = CannonButt.x
MineButt.y = CannonButt.y
MineButt.w = dev.buttSize

DisruptButt.ID = 20
DisruptButt.x = CannonButt.x + (CannonButt.w*1.65)
DisruptButt.y = CannonButt.y
DisruptButt.w = dev.buttSize

BulletButt.ID = 21
BulletButt.x = CannonButt.x
BulletButt.y = CannonButt.y
BulletButt.w = dev.buttSize

ImpassButt.ID = 22
ImpassButt.x = NodeSize * 1.5
ImpassButt.y = acceptButt.y
ImpassButt.w = dev.buttSize
ImpassButt.h = dev.buttSize

WaterButt.ID = 23
WaterButt.x = ImpassButt.x + (dev.buttSize * 1.15)
WaterButt.y = acceptButt.y
WaterButt.w = dev.buttSize
WaterButt.h = dev.buttSize

InfoButt.ID = 24
InfoButt.x = MiddleX
InfoButt.h = 52
InfoButt.y = acceptButt.y + ((dev.buttSize-InfoButt.h)/2)
InfoButt.w = dev.buttSize

XButt.ID = 25
XButt.x = MaxWidth-dev.buttSize
XButt.y = dev.buttSize*1.25
XButt.w = dev.buttSize*.85

ArrowRightButt.ID = 26
ArrowRightButt.x = XButt.x - dev.buttSize
ArrowRightButt.y = XButt.y
ArrowRightButt.w = XButt.w

Button5.ID = 27
Button10.ID = 28
Button15.ID = 29
Button20.ID = 30
Button25.ID = 31

ONOFF.ID = 32


`button images
cancelButt.UP = InterfaceSeries+4
cancelButt.DN = InterfaceSeries+5
acceptButt.UP = InterfaceSeries+6
acceptButt.DN = InterfaceSeries+7

settingsButt.UP = InterfaceSeries+8
settingsButt.DN = InterfaceSeries+9
mapButt.UP = InterfaceSeries+10
mapButt.DN = InterfaceSeries+11
diceButt.UP = InterfaceSeries+12
diceButt.DN = InterfaceSeries+13
diskButt.UP = InterfaceSeries+14
diskButt.DN = InterfaceSeries+15

MineButt.UP = InterfaceSeries+16
MineButt.DN = InterfaceSeries+17
EMPButt.UP = InterfaceSeries+18
EMPButt.DN = InterfaceSeries+19

CannonButt.UP = InterfaceSeries+20
CannonButt.DN = InterfaceSeries+21
MissileButt.UP = InterfaceSeries+22
MissileButt.DN = InterfaceSeries+23
LaserButt.UP = InterfaceSeries+24
LaserButt.DN = InterfaceSeries+25
HeavyLaserButt.UP = InterfaceSeries+26
HeavyLaserButt.DN = InterfaceSeries+27
HeavyCannonButt.UP = InterfaceSeries+28
HeavyCannonButt.DN = InterfaceSeries+29
DisruptButt.UP = InterfaceSeries+30
DisruptButt.DN = InterfaceSeries+31

BulletButt.DN = InterfaceSeries+32

LOADBUTT.UP = InterfaceSeries+33
LOADBUTT.DN = InterfaceSeries+34
SAVEBUTT.UP = InterfaceSeries+35
SAVEBUTT.DN = InterfaceSeries+36

SLOT1.UP = InterfaceSeries+37
SLOT1.DN = InterfaceSeries+38
SLOT2.UP = InterfaceSeries+39
SLOT2.DN = InterfaceSeries+40
SLOT3.UP = InterfaceSeries+41
SLOT3.DN = InterfaceSeries+42
SLOT4.UP = InterfaceSeries+43
SLOT4.DN = InterfaceSeries+44

ImpassButt.UP = InterfaceSeries+45
ImpassButt.DN = InterfaceSeries+46
WaterButt.UP = InterfaceSeries+47
WaterButt.DN = InterfaceSeries+48

VictoryImage = InterfaceSeries+49
DefeatImage = InterfaceSeries+50


`Other
global laserFull
global laserOut
global laserFade
laserFull = MakeColor( 255, 255, 255 )
laserOut  = Makecolor( 0, 0, 0 )
laserFade = Makecolor( 128, 128, 128 )

global ProductionUnits
global TurnCount
global turnImage
global turnImageDown
global square
global prohibit
global prohibitImage
global redSquare
global redSquareImage

ProductionUnits = InterfaceSeries+51
TurnCount = InterfaceSeries+52
square = InterfaceSeries+53

global VictoryImage
global DefeatImage
global starImage
global laserStarImage

type sliderType
	ID
	x as Float
	y as Float
	tx as Float
	ty as Float
	s1 as Float
	s2 as Float
	s3 as Float
	s4 as Float
	w
	h
endtype

#constant SliderGroup 16

global MusicSlide as sliderType
global SoundSlide as sliderType
global MusicScale as sliderType
global SoundScale as sliderType

global RoughSlide as sliderType
global TreeSlide as sliderType
global BaseSlide as sliderType
global DepotSlide as sliderType

global RoughScale as sliderType
global TreeScale as sliderType
global BaseScale as sliderType
global DepotScale as sliderType


MusicSlide.ID = InterfaceSeries+54
SoundSlide.ID = InterfaceSeries+55
MusicScale.ID = InterfaceSeries+56
SoundScale.ID = InterfaceSeries+57

RoughSlide.ID = InterfaceSeries+58
TreeSlide.ID = InterfaceSeries+59
BaseSlide.ID = InterfaceSeries+60
DepotSlide.ID = InterfaceSeries+61

RoughScale.ID = InterfaceSeries+62
TreeScale.ID = InterfaceSeries+63
BaseScale.ID = InterfaceSeries+64
DepotScale.ID = InterfaceSeries+65

InfoButt.UP = InterfaceSeries+66
InfoButt.DN = InterfaceSeries+67

XButt.UP = InterfaceSeries+68
XButt.DN = InterfaceSeries+69

ArrowRightButt.UP = InterfaceSeries+70
ArrowRightButt.DN = InterfaceSeries+71

ArrowRightButt.UP = InterfaceSeries+72
ArrowRightButt.DN = InterfaceSeries+73

Button5.UP = InterfaceSeries+74
Button5.DN = InterfaceSeries+75
Button10.UP = InterfaceSeries+76
Button10.DN = InterfaceSeries+77
Button15.UP = InterfaceSeries+78
Button15.DN = InterfaceSeries+79
Button20.UP = InterfaceSeries+80
Button20.DN = InterfaceSeries+81
Button25.UP = InterfaceSeries+82
Button25.DN = InterfaceSeries+83

ONOFF.UP = InterfaceSeries+84
ONOFF.DN = InterfaceSeries+85



MusicScale.x = MiddleX+95
MusicScale.y = MiddleY+260
MusicScale.w = 260
MusicScale.h = 25
MusicScale.tx = MusicScale.x
MusicScale.ty = MusicScale.y-(MusicScale.h*1.25)

SoundScale.x = MusicScale.x + MusicScale.w + 35
SoundScale.y = MusicScale.y
SoundScale.w = MusicScale.w
SoundScale.h = MusicScale.h
SoundScale.tx = SoundScale.x
SoundScale.ty = MusicScale.ty

MusicSlide.w = 70
MusicSlide.h = 70
MusicSlide.x = MusicScale.x+(MusicScale.w/2)-(MusicSlide.w/2)
MusicSlide.y = MusicScale.y-(MusicSlide.h/3)

SoundSlide.w = MusicSlide.w
SoundSlide.h = MusicSlide.h
SoundSlide.x = SoundScale.x+(SoundScale.w/2)-(SoundSlide.w/2)
SoundSlide.y = MusicSlide.y

`Terrain Sliders
RoughScale.w = dev.slidescaleW
RoughScale.h = dev.slidescaleH
RoughScale.x = dev.slidescaleX
RoughScale.y = dev.slidescaleY

TreeScale.x = RoughScale.x - (RoughScale.w * 1.05)
TreeScale.y = RoughScale.y
TreeScale.w = RoughScale.w
TreeScale.h = RoughScale.h

BaseScale.x = TreeScale.x - (RoughScale.w * 1.05)
BaseScale.y = RoughScale.y
BaseScale.w = RoughScale.w
BaseScale.h = RoughScale.h

DepotScale.x = BaseScale.x - (RoughScale.w * 1.05)
DepotScale.y = RoughScale.y
DepotScale.w = RoughScale.w
DepotScale.h = RoughScale.h


RoughSlide.w = 35 + (dev.scale * 15)

global SliderOffset as Float
SliderOffset = RoughSlide.w/2
HalfScale# = (RoughScale.w/2)-SliderOffset

RoughSlide.h = 35 + (dev.scale * 15)
RoughSlide.x = RoughScale.x + HalfScale#
RoughSlide.y = RoughScale.y + ((RoughScale.h - RoughSlide.h)/2)

TreeSlide.w = RoughSlide.w
TreeSlide.h = RoughSlide.h
TreeSlide.x = TreeScale.x + HalfScale#
TreeSlide.y = RoughSlide.y

BaseSlide.w = RoughSlide.w
BaseSlide.h = RoughSlide.h
BaseSlide.x = BaseScale.x + HalfScale#
BaseSlide.y = RoughSlide.y

DepotSlide.w = RoughSlide.w
DepotSlide.h = RoughSlide.h
DepotSlide.x = DepotScale.x + HalfScale#
DepotSlide.y = RoughSlide.y

global scaleLength as Float[]
scaleLength.length = Sectors
segment# = (RoughScale.w-SliderOffset) / Sectors
for i = 0 to Sectors-1 : scaleLength[i] = segment#*(i+1) : next i


Button5.x = MiddleX+125
Button5.y = SoundScale.y+(SoundSlide.h*1.9)
Button5.w = dev.buttSize
Button5.h = dev.buttSize

Button10.x = Button5.x + (dev.buttSize*1.3)
Button10.y = Button5.y
Button10.w = dev.buttSize
Button10.h = dev.buttSize

Button15.x = Button10.x + (dev.buttSize*1.3)
Button15.y = Button5.y
Button15.w = dev.buttSize
Button15.h = dev.buttSize

Button20.x = Button15.x + (dev.buttSize*1.3)
Button20.y = Button5.y
Button20.w = dev.buttSize
Button20.h = dev.buttSize

Button25.x = Button20.x + (dev.buttSize*1.3)
Button25.y = Button5.y
Button25.w = dev.buttSize
Button25.h = dev.buttSize

ONOFF.w = dev.buttSize
ONOFF.h = dev.buttSize
ONOFF.x = Button5.x
ONOFF.y = Button25.y + (Button25.h*1.3)
ONOFF.tx = ONOFF.x + (ONOFF.w/1.5)
ONOFF.ty = ONOFF.y - (ONOFF.h/2.5)


global baseQTY as float
global depotQTY as float
global roughQTY as float
global treeQTY as float

baseQTY = HalfScale#
depotQTY = HalfScale#
roughQTY = HalfScale#
treeQTY = HalfScale#


`SPRITES Misc

global Fire1 = WeaponSeries
global Missile1 = MissileSeries
global Bullet1 = BulletSeries
global EMP1 = EMPSeries

global MineExplode = MineSeries
global Mine1
Mine1 = MineSeries + 1

global DisruptSprite `= DisruptorSeries
global Logo

global field as integer  `board
global Explode1 as integer
global Explode2 as integer
global Explode3 as integer

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
	vehicle as integer
	x1 as integer
	y1 as integer
	x2 as integer
	y2 as integer
endtype

global SpriteConSize as integer = 112

remstart
BangSound = LoadSound("bang2.wav")
BuildBaseSound = LoadSound( "HoverbikeEnd.wav" )
ExplodeSound = LoadSound("explode.wav")
ClickSound = LoadSound("PlasticClick.wav")
SpawnSound = LoadSound("LevelOnSinister.wav")
MineSound = LoadSound("TripodDestroyed.wav")
MineBangSound = LoadSound("ExplosionPlain.wav")
HeavyLaserSound = LoadSound( "BeamElectro_01.wav" )
EngineerSound = LoadSound("MotorClose_01.wav")
HealSound = LoadSound("HealGlassy.wav")
VictorySound = LoadSound("MagicReveal.wav")
SaboSound = LoadSound("ExitOpenAztec.wav")
DefeatSound = LoadSound("Defeat.wav")
EnterSound = LoadSound("PickUpHeavy.wav")

DisruptorSound = LoadSoundOGG("DISRUPTOR.ogg")
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
EngineSound = LoadSoundOGG( "Jet2_01.ogg" )
MachineGunSound = LoadSoundOGG( "MachineGun.ogg" )
LightningSound = LoadSoundOGG("LightningBolt.ogg")
LoganSound = LoadSoundOGG("Logan.ogg" )
RenforcementsSound = LoadSoundOGG("reinforcements.ogg")
InterdictSound = LoadSoundOGG("Interdict.ogg")
MechSound = LoadSoundOGG("WalkerStomp.ogg")

`DON'T NEED FOR OLD PATROL
global patrolScan as integer[16]=[-32,-31,1,33,32,31,-1,-33,-32,-31,1,33,32,31,-1,-33]	 `starting at 12:00 and going clockwise(twice)
		`OLD PATROLSCAN
		global patrolVectors as integer[16] = [0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7]
		global patrolScanX as integer[8]=[0,DLSpos,NodePos,DLSpos,0,DLSneg,NodeNeg,DLSneg]	 `starting at 12:00 and going clockwise
		global patrolScanY as integer[8]=[NodeNeg,DLSneg,0,DLSpos,NodePos,DLSpos,0,DLSneg]

remend
