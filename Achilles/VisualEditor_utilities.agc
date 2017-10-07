

function VisualEditor_GetNameFromID ( ID as integer, kind as integer )

	for i = 0 to VisualEditor_Scenes.length
		for j = 0 to VisualEditor_Scenes [ i ].entities.length - 1
			index = VisualEditor_Scenes [ i ].entities [ j ].index
			
			if VisualEditor_Scenes [ i ].entities [ j ].ID = ID and VisualEditor_Scenes [ i ].entities [ j ].kind = kind
				exitfunction VisualEditor_Entities [ index ].sName
			endif
		next j
	next i
	
endfunction "" 

function VisualEditor_Get ( name as string, scene as integer, option as integer )
	
	scene = scene - 1
	
	if scene < 0 or scene > VisualEditor_Scenes.length
		Message ( "The scene index passed into VisualEditor_Get is out of bounds. This scene does not exist." )
		end
	endif
	
	for i = 1 to VisualEditor_Scenes [ scene ].entities.length
		index = VisualEditor_Scenes [ scene ].entities [ i ].index
		
		if VisualEditor_Entities [ index ].sName = name
			select option
				case 0:
					exitfunction VisualEditor_Scenes [ scene ].entities [ i ].ID
				endcase
				
				case 1:
					exitfunction VisualEditor_Scenes [ scene ].entities [ i ].kind
				endcase
			endselect
		endif
	next i
	
	Message ( "The entity " + name + " passed into VisualEditor_Get does not exist. Please note the scene index begins at 1." )
	end
endfunction 0

function VisualEditor_GetID ( name as string, scene as integer )
	exitfunction VisualEditor_Get ( name, scene, 0 )
endfunction 0

function VisualEditor_GetCurrentID ( name as string )
	exitfunction VisualEditor_Get ( name, VisualEditor_Manager.currentScene, 0 )
endfunction 0

function VisualEditor_GetKind ( name as string, scene as integer )
	exitfunction VisualEditor_Get ( name, scene, 1 )
endfunction 0

function VisualEditor_ShowDebug ( scene as integer, red as integer, green as integer, blue as integer )
	
	scene = scene - 1
	
	if scene < 0 or scene > VisualEditor_Scenes.length
		Message ( "The scene index passed into VisualEditor_ShowDebug is out of bounds. This scene does not exist." )
		end
	endif
	
	SetPrintColor ( red, green, blue )
	
	print ( "Total scenes = " + str ( VisualEditor_Scenes.length ) )
	print ( "" )
	
	print ( "Scene = " + str ( scene ) )
	print ( "Total entities = " + str ( VisualEditor_Scenes [ scene ].entities.length - 1 ) )
	
	for i = 1 to VisualEditor_Entities.length
		
		if VisualEditor_Entities [ i ].scene = scene
			print ( "Entity name = " + VisualEditor_Entities [ i ].sName + chr ( 9 ) + " Type = " + VisualEditor_Entities [ i ].sType )
		endif
	next i
	
endfunction

function VisualEditor_AddResolution ( width as integer, height as integer )
	
	index = VisualEditor_Resolutions.length
	
	VisualEditor_Resolutions [ index ].width = width
	VisualEditor_Resolutions [ index ].height = height
	
	VisualEditor_Resolutions.length = VisualEditor_Resolutions.length + 1
	
endfunction

function VisualEditor_UpdateCustomResolutions ( )
	
	VisualEditor_Resolutions.length = VisualEditor_Resolutions.length - 1
	
	if len ( VisualEditor_CustomResolutions ) = 0
		exitfunction
	endif
	
	
	count = CountStringTokens ( VisualEditor_CustomResolutions, " " )
	
	if mod ( count, 2 ) = 0
		index = 1
		
		for i = 1 to count / 2
			
			width$ = GetStringToken( VisualEditor_CustomResolutions, " ", index + 0 )
			height$ = GetStringToken( VisualEditor_CustomResolutions, " ", index + 1 )
			
			index = index + 2
			
			VisualEditor_AddResolution ( val ( width$ ), val ( height$ ) )
		next i
	endif
		
	VisualEditor_Resolutions.length = VisualEditor_Resolutions.length - 1
	
endfunction

function VisualEditor_FindClosestResolution ( )
	
	deviceWidth  = VisualEditor_BaseWidth
	deviceHeight = VisualEditor_BaseHeight
	
	closestWidth  = 0
	closestHeight = 0
	
	if lower ( GetDeviceBaseName ( ) ) <> "windows"
		deviceWidth  = GetDeviceWidth  ( )
		deviceHeight = GetDeviceHeight ( )
	endif
	
	for i = 1 to VisualEditor_Resolutions.length
		set = 0
		
		if VisualEditor_Resolutions [ i ].width <= deviceWidth and VisualEditor_Resolutions [ i ].height <= deviceHeight
			set = 1
		endif
		
		if set = 1 and VisualEditor_Resolutions [ i ].width >= closestWidth and VisualEditor_Resolutions [ i ].height >= closestHeight
			closestWidth  = VisualEditor_Resolutions [ i ].width
			closestHeight = VisualEditor_Resolutions [ i ].height
		endif
	next i
	
	VisualEditor_Width  = closestWidth
	VisualEditor_Height = closestHeight
endfunction

function VisualEditor_GetNewResolution ( newWidth#, newHeight# )
	VisualEditor_OriginalWidth = VisualEditor_BaseWidth
	VisualEditor_OriginalHeight = VisualEditor_BaseHeight

	VisualEditor_TargetWidth = 0.0
	VisualEditor_TargetHeight = 0.0

	width# = VisualEditor_OriginalWidth
	height# = VisualEditor_OriginalHeight

	size# = newWidth# / VisualEditor_OriginalWidth
	sizeX# = width# * size#
	sizeY# = height# * size#

	if sizeY# > newHeight#
		size# = newHeight# / VisualEditor_OriginalHeight
		sizeX# = width# * size#
		sizeY# = height# * size#
	endif

	VisualEditor_TargetWidth = sizeX#
	VisualEditor_TargetHeight = sizeY#

	canvasX# = newWidth#
	canvasY# = newHeight#
	
	aspect# = newHeight# / VisualEditor_TargetWidth
	sizeY# = canvasY# / aspect#
	height# = sizeY#
	offset# = ( canvasX# - sizeY# ) / 2.0
	pixelSize# = height# / VisualEditor_TargetWidth
	totalHeightInPixels# = canvasX# / pixelSize#
	VisualEditor_BorderInPixels = offset# / pixelSize#

	aspect# = newWidth# / VisualEditor_TargetHeight
	sizeY# = canvasX# / aspect#
	height# = sizeY#
	offset# = ( canvasY# - sizeY# ) / 2.0
	pixelSize# = height# /  VisualEditor_TargetHeight
	totalHeightInPixels# = canvasY# / pixelSize#
	VisualEditor_BorderInPixelsY = offset# / pixelSize#
endfunction


function VisualEditor_UpdateTextSize ( ID as integer, targetX as float, targetY as float )
	size# = VisualEditor_TargetWidth / VisualEditor_OriginalWidth
		
		sizeX# = targetX
		sizeY# = targetY
		
		currentSize# = 0.1
		
		SetTextSize ( ID, currentSize# )
		
		while 1
			width#  = GetTextTotalWidth ( ID )
			height# = GetTextTotalHeight ( ID )

			SetTextSize ( ID, currentSize# )

			if width# < sizeX#
				currentSize# = currentSize# + 0.1
			else
				exit
			endif
		endwhile
endfunction

function VisualEditor_UpdateForDifferentResolution ( ID as integer, kind as integer )
	
	if kind = VISUAL_EDITOR_TEXT
		size# = VisualEditor_TargetWidth / VisualEditor_OriginalWidth
		
		sizeX# = GetTextTotalWidth ( ID ) * size#
		sizeY# = GetTextTotalHeight ( ID ) * size#
		
		currentSize# = 0.1
		
		SetTextSize ( ID, currentSize# )
		
		while 1
			width#  = GetTextTotalWidth ( ID )
			height# = GetTextTotalHeight ( ID )

			SetTextSize ( ID, currentSize# )

			if width# < sizeX#
				currentSize# = currentSize# + 0.1
			else
				exit
			endif
		endwhile
		
		x# = GetTextX ( ID ) / VisualEditor_BaseWidth
		y# = GetTextY ( ID ) / VisualEditor_BaseHeight
		
		newPosX# = x# * VisualEditor_TargetWidth
		newPosY# = y# * VisualEditor_TargetHeight
		
		SetTextPosition ( ID, VisualEditor_BorderInPixels + newPosX#, VisualEditor_BorderInPixelsY + newPosY# )
	endif
	
	if kind = VISUAL_EDITOR_SPRITE
		size# = VisualEditor_TargetWidth / VisualEditor_OriginalWidth
		
		sizeX# = GetSpriteWidth ( ID ) * size#
		sizeY# = GetSpriteHeight ( ID ) * size#
		
		SetSpriteSize ( ID, sizeX#, sizeY# )
		
		x# = GetSpriteX ( ID ) / VisualEditor_BaseWidth
		y# = GetSpriteY ( ID ) / VisualEditor_BaseHeight
		
		newPosX# = x# * VisualEditor_TargetWidth
		newPosY# = y# * VisualEditor_TargetHeight
		
		SetSpritePosition ( ID, VisualEditor_BorderInPixels + newPosX#, VisualEditor_BorderInPixelsY + newPosY# )
	endif
	
	if kind = VISUAL_EDITOR_EDIT_BOX
		size# = VisualEditor_TargetWidth / VisualEditor_OriginalWidth
		
		sizeX# = GetEditBoxWidth ( ID ) * size#
		sizeY# = GetEditBoxHeight ( ID ) * size#
		
		SetEditBoxSize ( ID, sizeX#, sizeY# )
		SetEditBoxTextSize ( ID, sizeY# - 2 )
		
		x# = GetEditBoxX ( ID ) / VisualEditor_BaseWidth
		y# = GetEditBoxY ( ID ) / VisualEditor_BaseHeight
		
		newPosX# = x# * VisualEditor_TargetWidth
		newPosY# = y# * VisualEditor_TargetHeight
		
		SetEditBoxPosition ( ID, VisualEditor_BorderInPixels + newPosX#, VisualEditor_BorderInPixelsY + newPosY# )
	endif
endfunction

