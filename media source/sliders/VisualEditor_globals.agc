
#constant VISUAL_EDITOR_SPRITE 			1
#constant VISUAL_EDITOR_TEXT 			2
#constant VISUAL_EDITOR_EDIT_BOX 		3
#constant VISUAL_EDITOR_VIRTUAL_BUTTON 	4

#constant VISUAL_EDITOR_LOAD_FOR_SCENE 	0
#constant VISUAL_EDITOR_LOAD_ALL_MEDIA 	1

type tVisualEditor_Resolution
	width as integer
	height as integer
endtype

type tVisualEditor_Override
	width as integer
	height as integer
	x as float
	y as float
	sizeX as float
	sizeY as float
endtype

type tVisualEditor_SceneEntity
	ID as integer
	kind as integer
	index as integer
	created as integer
endtype

type tVisualEditor_Fonts
	sFile as string 
	ID as integer
endtype

type tVisualEditor_Image
	sImage as string
	ID as integer
endtype

type tVisualEditor_Manager
	currentScene as integer
endtype
	
type tVisualEditor_Scene
	entities as tVisualEditor_SceneEntity [ 1 ]
	
	clearColourRed as integer
	clearColourGreen as integer
	clearColourBlue as integer
endtype

type tVisualEditor_FileEntity
	sType as string
	sName as string
	sImage as string
	sText as string
	scene as integer
	sFont as string
	x as float
	y as float
	sizeX as float
	sizeY as float
	scaleX as float
	scaleY as float
	offsetX as float
	offsetY as float
	angle as float
	depth as integer
	visible as integer
	red as integer
	green as integer
	blue as integer
	alpha as integer
	alignment as integer
	textSize as float
	collision as integer
	active as integer
	physics as integer
	flipH as integer
	flipV as integer
	fixed as integer
	dynamicRes as string
	
	overrides as tVisualEditor_Override [ 0 ]
	
	// edit box properties
	editSize as float
	editColourRed as integer
	editColourGreen as integer
	editColourBlue as integer
	editBackgroundRed as integer
	editBackgroundGreen as integer
	editBackgroundBlue as integer
	editBackgroundAlpha as integer
	editBorderRed as integer
	editBorderGreen as integer
	editBorderBlue as integer
	editBorderAlpha as integer
	editBorderSize as float
	editMaxCharacters as integer
	editMaxLines as integer
	editMultiLine as integer
	editPassword as integer
	editCursorRed as integer
	editCursorGreen as integer
	editCursorBlue as integer
	editCursorWidth as float
	editCursorWrap as integer
endtype

function VisualEditor_Setup ( LoadAllMedia as integer )
	global VisualEditor_Pairs 		as string [ 2, 2 ]
	global VisualEditor_Scenes 		as tVisualEditor_Scene [ 1 ]
	global VisualEditor_Entities 	as tVisualEditor_FileEntity [ 1 ]
	global VisualEditor_File 		as string [ 1 ]
	global VisualEditor_Characters 	as string [ 1 ]
	global VisualEditor_Images      as tVisualEditor_Image [ 1 ]
	global VisualEditor_Resolutions as tVisualEditor_Resolution [ 1 ]
	global VisualEditor_Fonts 		as tVisualEditor_Fonts [ 0 ]
	
	global VisualEditor_CustomResolutions as string = ""
	global VisualEditor_SceneColours as string = ""
	global VisualEditor_Manager as tVisualEditor_Manager
	global VisualEditor_FileIndex = 1
	global VisualEditor_LoadAllMedia = 0
	
	global VisualEditor_Width = 0
	global VisualEditor_Height = 0
	
	global VisualEditor_BaseWidth = 0
	global VisualEditor_BaseHeight = 0

	global VisualEditor_OriginalWidth as float = 0.0
	global VisualEditor_OriginalHeight as float = 0.0
	global VisualEditor_TargetWidth as float = 0.0
	global VisualEditor_TargetHeight as float = 0.0
	global VisualEditor_BorderInPixels as float = 0.0
	global VisualEditor_BorderInPixelsY as float = 0.0
	
	VisualEditor_LoadAllMedia = LoadAllMedia
	
	VisualEditor_Pairs [ 1, 1 ] = "entity"
	VisualEditor_Pairs [ 1, 2 ] = "properties"
	
	VisualEditor_Pairs [ 2, 1 ] = "project"
	VisualEditor_Pairs [ 2, 2 ] = "settings"
	
	UseNewDefaultFonts ( 1 )
	SetClearColor ( 255, 255, 255 )
	SetPrintColor ( 0, 0, 0 )
	SetPrintSize ( 24 )
	SetScissor ( 0, 0, 0, 0 )
	
	
	// default resolutions - needs to be replaced by data from the project file
	VisualEditor_AddResolution ( 640, 960 )
	VisualEditor_AddResolution ( 768, 1024 )
	VisualEditor_AddResolution ( 720, 1280 )
	VisualEditor_AddResolution ( 1080, 1920 )
	VisualEditor_AddResolution ( 1200, 1920 )
	VisualEditor_AddResolution ( 1536, 2048 )
	VisualEditor_AddResolution ( 960, 640 )
	VisualEditor_AddResolution ( 1024, 768 )
	VisualEditor_AddResolution ( 1280, 720 )
	VisualEditor_AddResolution ( 1920, 1080 )
	VisualEditor_AddResolution ( 1920, 1200 )
	VisualEditor_AddResolution ( 2048, 1536 )
	
	VisualEditor_LoadProject ( "data.agkd" )
	VisualEditor_UpdateCustomResolutions ( )
	
	VisualEditor_Width = VisualEditor_BaseWidth
	VisualEditor_Height = VisualEditor_BaseHeight
	
	// need to find the closest resolution to the one we support
	VisualEditor_FindClosestResolution ( )
	
	// to override the resolution adjust the values here
	//VisualEditor_Width = 320
	//VisualEditor_Height = 480
	
	SetVirtualResolution ( VisualEditor_Width, VisualEditor_Height )
	SetWindowSize ( VisualEditor_Width, VisualEditor_Height, 0 )
	
	VisualEditor_GetNewResolution ( VisualEditor_Width, VisualEditor_Height )
	
	VisualEditor_SetupScenes ( )
endfunction

