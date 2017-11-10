
function VisualEditor_SetupScenes ( )
	
	// go through all the entities and assign them to scenes
	
	for i = 1 to VisualEditor_Entities.length
		scene = VisualEditor_Entities [ i ].scene
		
		if scene > VisualEditor_Scenes.length
			VisualEditor_Scenes.Length = scene
		endif
		
		index = VisualEditor_Scenes [ scene ].entities.length
		
		select VisualEditor_Entities [ i ].sType
			case "sprite":
				VisualEditor_Scenes [ scene ].entities [ index ].kind = VISUAL_EDITOR_SPRITE 
			endcase
			
			case "text":
				VisualEditor_Scenes [ scene ].entities [ index ].kind = VISUAL_EDITOR_TEXT
			endcase
			
			case "editbox":
				VisualEditor_Scenes [ scene ].entities [ index ].kind = VISUAL_EDITOR_EDIT_BOX
			endcase
		endselect
		
		// store the index into the main entities array so we can access it later
		VisualEditor_Scenes [ scene ].entities [ index ].index = i
		
		VisualEditor_Scenes [ scene ].entities.length = VisualEditor_Scenes [ scene ].entities.length + 1
	next i
	
	for i = 1 to VisualEditor_Scenes.length
		if VisualEditor_Scenes [ i ].entities.length > 1
			VisualEditor_Scenes [ i ].entities.length = VisualEditor_Scenes [ i ].entities.length - 1	
		endif
	next i
	
	for i = 1 to VisualEditor_Scenes.length
		VisualEditor_Scenes [ i ].clearColourRed = 255
		VisualEditor_Scenes [ i ].clearColourGreen = 255
		VisualEditor_Scenes [ i ].clearColourBlue = 255
	next i
	
	count = CountStringTokens ( VisualEditor_SceneColours, " " )
	
	if mod ( count, 3 ) = 0
		index = 1
		scene = 1
		
		for i = 1 to count / 3
			
			VisualEditor_Scenes [ scene ].clearColourRed = val ( GetStringToken( VisualEditor_SceneColours, " ", index + 0 ) )
			VisualEditor_Scenes [ scene ].clearColourGreen = val ( GetStringToken( VisualEditor_SceneColours, " ", index + 1 ) )
			VisualEditor_Scenes [ scene ].clearColourBlue = val ( GetStringToken( VisualEditor_SceneColours, " ", index + 2 ) )
			
			index = index + 3
		next i
		
		scene = scene + 1
	endif
	
	// sort out any dynamic resolution information here
	for i = 1 to VisualEditor_Entities.length
		count = CountStringTokens ( VisualEditor_Entities [ i ].dynamicRes, " " )
	
		// stick this into an array for each entity
		// if this array length is greater than 0 then we look trhough it
		// width, height, x, y, size x, size y
	
		if mod ( count, 6 ) = 0
			index = 1
			
			for j = 1 to count / 6
				
				VisualEditor_Entities [ i ].overrides.length = VisualEditor_Entities [ i ].overrides.length + 1
				array = VisualEditor_Entities [ i ].overrides.length
				
				VisualEditor_Entities [ i ].overrides [ array ].width 	= val ( GetStringToken ( VisualEditor_Entities [ i ].dynamicRes, " ", index + 0 ) )
				VisualEditor_Entities [ i ].overrides [ array ].height 	= val ( GetStringToken ( VisualEditor_Entities [ i ].dynamicRes, " ", index + 1 ) )
				VisualEditor_Entities [ i ].overrides [ array ].x 		= val ( GetStringToken ( VisualEditor_Entities [ i ].dynamicRes, " ", index + 2 ) )
				VisualEditor_Entities [ i ].overrides [ array ].y 		= val ( GetStringToken ( VisualEditor_Entities [ i ].dynamicRes, " ", index + 3 ) )
				VisualEditor_Entities [ i ].overrides [ array ].sizeX 	= val ( GetStringToken ( VisualEditor_Entities [ i ].dynamicRes, " ", index + 4 ) )
				VisualEditor_Entities [ i ].overrides [ array ].sizeY 	= val ( GetStringToken ( VisualEditor_Entities [ i ].dynamicRes, " ", index + 5 ) )
				
				index = index + 6
			next j
		endif
	next i
	
	// run through all the entities and add their images to the image list
	for i = 1 to VisualEditor_Entities.length
		VisualEditor_FindImage ( VisualEditor_Entities [ i ].sImage )		
		VisualEditor_FindFont ( VisualEditor_Entities [ i ].sFont )
	next i
	
	if VisualEditor_Images.length > 1
		VisualEditor_Images.length = VisualEditor_Images.length - 1	
	endif

	VisualEditor_Manager.currentScene = 1
	VisualEditor_SetScene ( 1 )
	
endfunction

function VisualEditor_FindFont ( sFont as string )
	
	if sFont = ""
		exitfunction 0
	endif
	
	for i = 1 to VisualEditor_Fonts.length
		if VisualEditor_Fonts [ i ].sFile = sFont
			exitfunction 1
		endif
	next i
	
	VisualEditor_Fonts.length = VisualEditor_Fonts.length + 1
	
	VisualEditor_Fonts [ VisualEditor_Fonts.length ].sFile = sFont
	VisualEditor_Fonts [ VisualEditor_Fonts.length ].ID = -1
	
endfunction 0

function VisualEditor_LoadFont ( sFont as string )

	for i = 1 to VisualEditor_Fonts.length
		if VisualEditor_Fonts [ i ].sFile = sFont
			if VisualEditor_Fonts [ i ].ID = -1
				VisualEditor_Fonts [ i ].ID = LoadFont ( sFont )
			endif
			
			exitfunction VisualEditor_Fonts [ i ].ID
		endif
	next i

endfunction -1

function VisualEditor_FindImage ( sImage as string )
	
	for i = 1 to VisualEditor_Images.length
		if VisualEditor_Images [ i ].sImage = sImage
			exitfunction 1
		endif
	next i
	
	VisualEditor_Images [ VisualEditor_Images.length ].sImage = sImage
	VisualEditor_Images [ VisualEditor_Images.length ].ID = -1
	
	VisualEditor_Images.length = VisualEditor_Images.length + 1
	
endfunction 0

function VisualEditor_LoadImage ( sImage as string )

	// look for the image in the list
	// if it has no ID then it needs to be loaded
	// if it has already been loaded it will have an ID so return that

	for i = 1 to VisualEditor_Images.length
		if VisualEditor_Images [ i ].sImage = sImage
			if VisualEditor_Images [ i ].ID = -1
				VisualEditor_Images [ i ].ID = LoadImage ( sImage )
			endif
			
			exitfunction VisualEditor_Images [ i ].ID
		endif
	next i

endfunction -1

function VisualEditor_SetScene ( scene as integer )
	
	// find active scene, delete its contents, then load everything for the selected scene
	
	scene = scene - 1
	
	if scene < 0 or scene > VisualEditor_Scenes.length
		Message ( "The scene index passed into VisualEditor_SetScenes is out of bounds. This scene does not exist." )
		end
	endif
	
	VisualEditor_DeleteScene ( VisualEditor_Manager.currentScene + 1 )
	
	VisualEditor_Manager.currentScene = scene
	

	SetClearColor ( VisualEditor_Scenes [ scene ].clearColourRed, VisualEditor_Scenes [ scene ].clearColourGreen, VisualEditor_Scenes [ scene ].clearColourBlue )
	
	for i = 1 to VisualEditor_Scenes [ scene ].entities.length
		
		ID = 0
		index = VisualEditor_Scenes [ scene ].entities [ i ].index
		
		red = VisualEditor_Entities [ index ].red
		green = VisualEditor_Entities [ index ].green
		blue = VisualEditor_Entities [ index ].blue
		
		overrideIndex = 0
		
		for j = 1 to VisualEditor_Entities [ index ].overrides.length
			if VisualEditor_Width = VisualEditor_Entities [ index ].overrides [ j ].width
				if VisualEditor_Height = VisualEditor_Entities [ index ].overrides [ j ].height
					overrideIndex = j
					exit
				endif
			endif
		next j
	
		
		select VisualEditor_Scenes [ scene ].entities [ i ].kind
			case VISUAL_EDITOR_SPRITE:
				if VisualEditor_LoadAllMedia = 0 or VisualEditor_Scenes [ scene ].entities [ i ].created = 0
					image = VisualEditor_LoadImage ( VisualEditor_Entities [ index ].sImage )
					ID = CreateSprite ( image )
				else
					ID = VisualEditor_Scenes [ scene ].entities [ i ].ID
				endif
				
				SetSpritePosition ( ID, VisualEditor_Entities [ index ].x, VisualEditor_Entities [ index ].y )
				SetSpriteSize ( ID, VisualEditor_Entities [ index ].sizeX, VisualEditor_Entities [ index ].sizeY )
				SetSpriteScale ( ID, VisualEditor_Entities [ index ].scaleX, VisualEditor_Entities [ index ].scaleY )
				SetSpriteOffset ( ID, VisualEditor_Entities [ index ].offsetX, VisualEditor_Entities [ index ].offsetY )
				SetSpriteAngle ( ID, VisualEditor_Entities [ index ].angle )
				SetSpriteDepth ( ID, VisualEditor_Entities [ index ].depth )
				SetSpriteColor ( ID, red, green, blue, VisualEditor_Entities [ index ].alpha )
				SetSpriteShape ( ID, VisualEditor_Entities [ index ].collision )
				SetSpriteVisible ( ID, VisualEditor_Entities [ index ].visible ) 
				FixSpriteToScreen ( ID, VisualEditor_Entities [ index ].fixed )
				
				// switch to static if nothing has been set
				if VisualEditor_Entities [ index ].physics = 0
					VisualEditor_Entities [ index ].physics = 1
				endif
				
				SetSpritePhysicsOn ( ID, VisualEditor_Entities [ index ].physics )
				SetSpriteActive ( ID, VisualEditor_Entities [ index ].active )
				SetSpriteFlip ( ID, VisualEditor_Entities [ index ].flipH, VisualEditor_Entities [ index ].flipV )
				
				if overrideIndex = 0
					VisualEditor_UpdateForDifferentResolution ( ID, VISUAL_EDITOR_SPRITE )
				else
					SetSpritePosition ( ID, VisualEditor_Entities [ index ].overrides [ overrideIndex ].x, VisualEditor_Entities [ index ].overrides [ overrideIndex ].y )
					SetSpriteSize ( ID, VisualEditor_Entities [ index ].overrides [ overrideIndex ].sizeX, VisualEditor_Entities [ index ].overrides [ overrideIndex ].sizeY )
				endif
			endcase
			
			case VISUAL_EDITOR_TEXT:
				if VisualEditor_LoadAllMedia = 0 or VisualEditor_Scenes [ scene ].entities [ i ].created = 0
					ID = CreateText ( VisualEditor_Entities [ index ].sText )
				else
					ID = VisualEditor_Scenes [ scene ].entities [ i ].ID
				endif
				
				SetTextPosition ( ID, VisualEditor_Entities [ index ].x, VisualEditor_Entities [ index ].y )
				SetTextSize ( ID, VisualEditor_Entities [ index ].textSize )
				SetTextAlignment ( ID, VisualEditor_Entities [ index ].alignment )
				SetTextColor ( ID, red, green, blue, VisualEditor_Entities [ index ].alpha )
				SetTextDepth ( ID, VisualEditor_Entities [ index ].depth )
				SetTextAngle ( ID, VisualEditor_Entities [ index ].angle )
				SetTextVisible ( ID, VisualEditor_Entities [ index ].visible ) 
				FixTextToScreen ( ID, VisualEditor_Entities [ index ].fixed )
				
				if VisualEditor_Entities [ index ].sFont <> ""
					font = VisualEditor_LoadFont ( VisualEditor_Entities [ index ].sFont )
					SetTextfont ( ID, font )
				endif
				
				if overrideIndex = 0
					VisualEditor_UpdateForDifferentResolution ( ID, VISUAL_EDITOR_TEXT )
				else
					SetTextPosition ( ID, VisualEditor_Entities [ index ].overrides [ overrideIndex ].x, VisualEditor_Entities [ index ].overrides [ overrideIndex ].y )
					VisualEditor_UpdateTextSize ( ID, VisualEditor_Entities [ index ].overrides [ overrideIndex ].sizeX, VisualEditor_Entities [ index ].overrides [ overrideIndex ].sizeY )
				endif
			endcase
			
			case VISUAL_EDITOR_EDIT_BOX:
				if VisualEditor_LoadAllMedia = 0 or VisualEditor_Scenes [ scene ].entities [ i ].created = 0
					ID = CreateEditBox ( )
				else
					ID = VisualEditor_Scenes [ scene ].entities [ i ].ID
				endif
				
				SetEditBoxPosition ( ID, VisualEditor_Entities [ index ].x, VisualEditor_Entities [ index ].y )
				SetEditBoxSize ( ID, VisualEditor_Entities [ index ].sizeX, VisualEditor_Entities [ index ].sizeY )
				SetEditBoxText ( ID, VisualEditor_Entities [ index ].sText )
				SetEditBoxTextSize ( ID, VisualEditor_Entities [ index ].editSize )
				SetEditBoxTextColor ( ID, VisualEditor_Entities [ index ].editColourRed, VisualEditor_Entities [ index ].editColourGreen, VisualEditor_Entities [ index ].editColourBlue )
				SetEditBoxBackgroundColor ( ID, VisualEditor_Entities [ index ].editBackgroundRed, VisualEditor_Entities [ index ].editBackgroundGreen, VisualEditor_Entities [ index ].editBackgroundBlue, VisualEditor_Entities [ index ].editBackgroundAlpha )
				SetEditBoxBorderColor ( ID, VisualEditor_Entities [ index ].editBorderRed, VisualEditor_Entities [ index ].editBorderGreen, VisualEditor_Entities [ index ].editBorderBlue, VisualEditor_Entities [ index ].editBorderAlpha )
				SetEditBoxBorderSize ( ID, VisualEditor_Entities [ index ].editBorderSize )
				SetEditBoxMaxChars ( ID, VisualEditor_Entities [ index ].editMaxCharacters )
				SetEditBoxMaxLines ( ID, VisualEditor_Entities [ index ].editMaxLines )
				SetEditBoxMultiLine ( ID, VisualEditor_Entities [ index ].editMultiLine )
				SetEditBoxPasswordMode ( ID, VisualEditor_Entities [ index ].editPassword )
				SetEditBoxCursorColor ( ID, VisualEditor_Entities [ index ].editCursorRed, VisualEditor_Entities [ index ].editCursorGreen, VisualEditor_Entities [ index ].editCursorBlue )
				SetEditBoxCursorWidth ( ID, VisualEditor_Entities [ index ].editCursorWidth )
				SetEditBoxWrapMode ( ID, VisualEditor_Entities [ index ].editCursorWrap )
				SetEditBoxDepth ( ID, VisualEditor_Entities [ index ].depth )
				SetEditBoxVisible ( ID, VisualEditor_Entities [ index ].visible ) 
				FixEditBoxToScreen ( ID, VisualEditor_Entities [ index ].fixed )
				
				if overrideIndex = 0
					VisualEditor_UpdateForDifferentResolution ( ID, VISUAL_EDITOR_EDIT_BOX )
				else
					SetEditBoxPosition ( ID, VisualEditor_Entities [ index ].overrides [ overrideIndex ].x, VisualEditor_Entities [ index ].overrides [ overrideIndex ].y )
					SetEditBoxSize ( ID, VisualEditor_Entities [ index ].overrides [ overrideIndex ].sizeX, VisualEditor_Entities [ index ].overrides [ overrideIndex ].sizeY )
					SetEditBoxTextSize ( ID, VisualEditor_Entities [ index ].overrides [ overrideIndex ].sizeY - 2 )
					
				endif
			endcase
		endselect
		
		VisualEditor_Scenes [ scene ].entities [ i ].created = 1
		VisualEditor_Scenes [ scene ].entities [ i ].ID = ID
		
	next i
	
endfunction

function VisualEditor_DeleteScene ( scene as integer )
	
	scene = scene - 1
	
	if scene < 0 or scene > VisualEditor_Scenes.length
		Message ( "The scene index passed into VisualEditor_DeleteScene is out of bounds. This scene does not exist." )
		end
	endif
	
	for i = 1 to VisualEditor_Scenes [ scene ].entities.length
		
		index = VisualEditor_Scenes [ scene ].entities [ i ].index
		
		select VisualEditor_Scenes [ scene ].entities [ i ].kind
			case VISUAL_EDITOR_SPRITE:
				if VisualEditor_LoadAllMedia = 0
					DeleteSprite ( VisualEditor_Scenes [ scene ].entities [ i ].ID )
				else
					SetSpriteVisible ( VisualEditor_Scenes [ scene ].entities [ i ].ID, 0 )
				endif
			endcase
			
			case VISUAL_EDITOR_TEXT:
				if VisualEditor_LoadAllMedia = 0
					DeleteText ( VisualEditor_Scenes [ scene ].entities [ i ].ID )
				else
					SetTextVisible ( VisualEditor_Scenes [ scene ].entities [ i ].ID, 0 )
				endif
			endcase
			
			case VISUAL_EDITOR_EDIT_BOX:
				if VisualEditor_LoadAllMedia = 0
					DeleteEditBox ( VisualEditor_Scenes [ scene ].entities [ i ].ID )
				else
					SetEditBoxVisible ( VisualEditor_Scenes [ scene ].entities [ i ].ID, 0 )
				endif
			endcase
		endselect
		
		if VisualEditor_LoadAllMedia = 0
			VisualEditor_Scenes [ scene ].entities [ i ].ID = 0
		endif
	next i
	
	// wipe all the images in the list
	if VisualEditor_LoadAllMedia = 0
		for i = 1 to VisualEditor_Images.length
			if VisualEditor_Images [ i ].ID = -1
				DeleteImage ( VisualEditor_Images [ i ].ID )
				VisualEditor_Images [ i ].ID = -1
			endif
		next i
	endif
	
endfunction


function VisualEditor_GetScene ( )
	exitfunction VisualEditor_Manager.currentScene + 1
endfunction 0
