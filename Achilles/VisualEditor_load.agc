

function VisualEditor_LoadProject ( fileName as string )
	
	// load a project
	if GetFileExists ( fileName ) = 0
		Message ( "Error - project file cannot be opened" )
		end
	endif
	
	file = OpenToRead ( fileName )

	while ( FileEOF ( file ) = 0 )
		VisualEditor_File [ VisualEditor_File.length ] = chr ( ReadByte ( file ) )
		VisualEditor_File.length = VisualEditor_File.length + 1
	endwhile

	CloseFile ( file )

	char as string = ""
	a as string = ""
	b as string = ""
	c as string = "" 
	
	a = chr ( 13 )
	b = chr ( 9 )
	c = chr ( 10 )

	foundStartText = 0

	for i = 1 to VisualEditor_File.length
		
		char = VisualEditor_File [ i ]
		
		if i < VisualEditor_File.length - 5
			c1$ = VisualEditor_File [ i + 0 ]
			c2$ = VisualEditor_File [ i + 1 ]
			c3$ = VisualEditor_File [ i + 2 ]
			c4$ = VisualEditor_File [ i + 3 ]
			c5$ = VisualEditor_File [ i + 4 ]
			c6$ = VisualEditor_File [ i + 5 ]
			
			if c1$ = "<" and c2$ = "t" and c3$ = "e" and c4$ = "x" and c5$ = "t" and c6$ = ">"
				foundStartText = 1
			endif
		endif
		
		if foundStartText = 1 and i < VisualEditor_File.length - 1
			c1$ = VisualEditor_File [ i + 0 ]
			c2$ = VisualEditor_File [ i + 1 ]
			
			if c1$ = "<" and c2$ = "/"
				foundStartText = 0
			endif
		endif
		
		if foundStartText = 0
			if char <> a and char <> b and char <> c
				VisualEditor_Characters [ VisualEditor_Characters.length ] = char
				VisualEditor_Characters.length = VisualEditor_Characters.length + 1		
			endif
		else
			VisualEditor_Characters [ VisualEditor_Characters.length ] = char
			VisualEditor_Characters.length = VisualEditor_Characters.length + 1		
		endif
	next i
	
	VisualEditor_Characters.length = VisualEditor_Characters.length - 1
	
	// read in the data from the file
	while 1
		if VisualEditor_IsBlock ( )
			VisualEditor_ParseBlock ( )
		endif
		
		if VisualEditor_FileIndex >= VisualEditor_Characters.length - 1
			exit
		endif
	endwhile
	
	VisualEditor_Entities.length = VisualEditor_Entities.length - 1
	
	VisualEditor_File.length = 0
	VisualEditor_Characters.length = 0
	
endfunction

function VisualEditor_IsBlock ( )
	if VisualEditor_Characters [ VisualEditor_FileIndex ] = '<' 
		VisualEditor_FileIndex = VisualEditor_FileIndex + 1
		exitfunction 1
	endif
endfunction 0

function VisualEditor_ParseBlock ( )
	name as string = ""
	name = VisualEditor_GetName ( )
	
	if VisualEditor_CheckBlock ( name ) = 0
		VisualEditor_Skip ( )
	endif
endfunction

function VisualEditor_GetName ( )
	// get name of block
	name as string = ""
	
	while 1
		// break on end or get name
		if ( VisualEditor_Characters [ VisualEditor_FileIndex ] = '>' )
			exit
		else
			name = name + VisualEditor_Characters [ VisualEditor_FileIndex ]
		endif
		
		// increment index
		VisualEditor_FileIndex = VisualEditor_FileIndex + 1
	endwhile

	// skip end >
	VisualEditor_FileIndex = VisualEditor_FileIndex + 1
endfunction name

function VisualEditor_CheckBlock ( name as string )
	// found entity, so look for properties
	
	// look for a match first
	for i = 1 to VisualEditor_Pairs.length
		if name = VisualEditor_Pairs [ i, 1 ]
			VisualEditor_ParseSubBlock ( name, VisualEditor_Pairs [ i, 2 ] )
			exitfunction 1
		endif
	next i
endfunction 0

function VisualEditor_Skip ( )
	// loop round
	while 1
		// deal with the end block
		if ( VisualEditor_IsEndBlock ( ) )
			// skip end of block
			while 1
				if VisualEditor_Characters [ VisualEditor_FileIndex ] = '>'
					VisualEditor_FileIndex = VisualEditor_FileIndex + 1
					exitfunction
				endif
				
				VisualEditor_FileIndex = VisualEditor_FileIndex + 1
			endwhile
		elseif ( VisualEditor_IsBlock ( ) )
			// we have found a block so parse this
			VisualEditor_ParseBlock ( )
		else
			// actual data, just skip it as we don't care about
			VisualEditor_FileIndex = VisualEditor_FileIndex + 1
		endif		
	endwhile
endfunction

function VisualEditor_IsEndBlock ( )
	// is this the end block
	if VisualEditor_Characters [ VisualEditor_FileIndex ] = '<' and VisualEditor_Characters [ VisualEditor_FileIndex + 1 ] = '/'
		exitfunction 1
	endif
endfunction 0

function VisualEditor_ParseSubBlock ( parent as string, name as string )
	while 1
		// break on end
		if VisualEditor_IsEndBlock ( )
			exit
		elseif VisualEditor_IsBlock ( )
			subName as string = ""
			subName = VisualEditor_GetName ( )

			if subName = name
				// entity pairs with properties, make a new one
				if parent = "entity" and subName = "properties"
					
					// set some default values
					VisualEditor_Entities [ VisualEditor_Entities.length ].red = 255
					VisualEditor_Entities [ VisualEditor_Entities.length ].green = 255
					VisualEditor_Entities [ VisualEditor_Entities.length ].blue = 255
					VisualEditor_Entities [ VisualEditor_Entities.length ].alpha = 255
					
					VisualEditor_Entities [ VisualEditor_Entities.length ].visible = 1
					
					VisualEditor_ParseSubBlockData ( parent, subName )
					VisualEditor_Entities.length = VisualEditor_Entities.length + 1
				endif
				
				if parent = "project" and subName = "settings"
					VisualEditor_ParseSubBlockData ( parent, subName )
				endif
			else
				VisualEditor_Skip ( )
			endif
		else
			// some data, don't care what it is
			VisualEditor_SkipData ( )
		endif
	endwhile

	// skip the end part
	VisualEditor_SkipEnd ( )
endfunction

function VisualEditor_SkipData ( )
	// skip data associated with block
	data as string = ""
	data = VisualEditor_GetData ( )
endfunction 

function VisualEditor_GetData ( )
	// get data from block
	data as string = ""

	// loop round
	while 1
		// wait until we hit something or copy data
		if VisualEditor_Characters [ VisualEditor_FileIndex ] = '<'
			exit
		else
			data = data + VisualEditor_Characters [ VisualEditor_FileIndex ]
		endif
		
		// increment index
		VisualEditor_FileIndex = VisualEditor_FileIndex + 1
	endwhile
endfunction data

function VisualEditor_SkipEnd ( )
	// skip end of block
	while 1
		if VisualEditor_Characters [ VisualEditor_FileIndex ] = '>'
			VisualEditor_FileIndex = VisualEditor_FileIndex + 1
			exit
		endif
			
		VisualEditor_FileIndex = VisualEditor_FileIndex + 1
	endwhile
endfunction

function VisualEditor_ParseSubBlockData ( parent as string, child as string )
	while 1
		if VisualEditor_IsEndBlock ( )
			exit
		elseif VisualEditor_IsBlock ( )
			name as string = ""
			name = VisualEditor_GetName ( )
			
			// entity and properties
			if parent = "entity" and child = "properties"
				if VisualEditor_ParseEntityData ( name ) <> 1
					VisualEditor_Skip ( )
				endif
			endif
			
			if parent = "project" and child = "settings"
				if VisualEditor_ParseSettingsData ( name ) <> 1
					VisualEditor_Skip ( )
				endif
			endif
		else
			// don't know what it is so skip it
			VisualEditor_SkipData ( )
		endif
	endwhile

	// skip the end
	VisualEditor_SkipEnd ( )
endfunction

function VisualEditor_ParseSettingsData ( name as string )
	
	// we have found an entity, look through all supported data, if we find
	// a match then store the data in the entities array
	
	// need to split this into different kinds of entities so we can parse
	// edit boxes, text, virtual buttons etc. individually
	
	dim tags$ [ ] = [ "", "width", "height", "orientation", "custom res", "scene colours" ]

	
	for i = 1 to tags$.length
		if name = tags$ [ i ]
			
			data as string = ""
			data = VisualEditor_StepThrough ( )
			
			if name = "width" then VisualEditor_BaseWidth = val ( data )
			if name = "height" then VisualEditor_BaseHeight = val ( data )
			if name = "custom res" then VisualEditor_CustomResolutions = data
			if name = "scene colours" then VisualEditor_SceneColours = data
			
			if name = "orientation"
				if data = "Portrait"
					SetOrientationAllowed ( 1, 1, 0, 0 )
				elseif data = "Landscape"
					SetOrientationAllowed ( 0, 0, 1, 1 )
				else
					SetOrientationAllowed ( 1, 1, 1, 1 )
				endif
			endif
			
			exitfunction 1
		endif
	next i
endfunction 0

function VisualEditor_ParseEntityData ( name as string )
	
	// we have found an entity, look through all supported data, if we find
	// a match then store the data in the entities array
	
	// need to split this into different kinds of entities so we can parse
	// edit boxes, text, virtual buttons etc. individually
	
	dim tags$ [ ] = [ "", "collision", "type", "name", "scene", "image", "x", "y", "size x", "size y", "scale x",
						"scale y", "offset x", "offset y", "angle", "depth", "visible", "red", "green", "blue", "alpha", "text", "text size", "alignment",
						"active", "physics", "fliph", "flipv", "alignment", "dynamic res", "font", "fixed",
						"edit size", "edit colour red", "edit colour green", "edit colour blue",
						"edit background red", "edit background green", "edit background blue", "edit background alpha",
						"edit border red", "edit border green", "edit border blue", "edit border alpha", "edit border size",
						"edit max characters", "edit max lines", "edit multi line", "edit password", "edit cursor red",
						"edit cursor green", "edit cursor blue", "edit cursor width", "edit cursor wrap" ]
	
	for i = 1 to tags$.length
		if name = tags$ [ i ]
			
			data as string = ""
			data = VisualEditor_StepThrough ( )
			
			if name = "type" then VisualEditor_Entities [ VisualEditor_Entities.length ].sType = data
			if name = "name" then VisualEditor_Entities [ VisualEditor_Entities.length ].sName = data
			if name = "font" then VisualEditor_Entities [ VisualEditor_Entities.length ].sFont = data
			if name = "scene" then VisualEditor_Entities [ VisualEditor_Entities.length ].scene = val ( data )
			if name = "visible" then VisualEditor_Entities [ VisualEditor_Entities.length ].visible = val ( data )
			if name = "fliph" then VisualEditor_Entities [ VisualEditor_Entities.length ].flipH = val ( data )	 
			if name = "flipv" then VisualEditor_Entities [ VisualEditor_Entities.length ].flipV = val ( data )	 
			if name = "x" then VisualEditor_Entities [ VisualEditor_Entities.length ].x = val ( data )
			if name = "y" then VisualEditor_Entities [ VisualEditor_Entities.length ].y = val ( data )
			if name = "image" then  VisualEditor_Entities [ VisualEditor_Entities.length ].sImage = ReplaceString ( data, "media/", "", 1 )
			if name = "size x" then VisualEditor_Entities [ VisualEditor_Entities.length ].sizeX = val ( data )
			if name = "size y" then VisualEditor_Entities [ VisualEditor_Entities.length ].sizeY = val ( data )
			if name = "scale x" then VisualEditor_Entities [ VisualEditor_Entities.length ].scaleX = val ( data )
			if name = "scale y" then VisualEditor_Entities [ VisualEditor_Entities.length ].scaleY = val ( data )
			if name = "offset x" then VisualEditor_Entities [ VisualEditor_Entities.length ].offsetX = val ( data )
			if name = "offset y" then VisualEditor_Entities [ VisualEditor_Entities.length ].offsetY = val ( data )
			if name = "angle" then VisualEditor_Entities [ VisualEditor_Entities.length ].angle = val ( data )
			if name = "fixed" then VisualEditor_Entities [ VisualEditor_Entities.length ].fixed = val ( data )
			if name = "text" then VisualEditor_Entities [ VisualEditor_Entities.length ].sText = data
			if name = "depth" then VisualEditor_Entities [ VisualEditor_Entities.length ].depth = val ( data )
			if name = "red" then VisualEditor_Entities [ VisualEditor_Entities.length ].red = val ( data )
			if name = "green" then VisualEditor_Entities [ VisualEditor_Entities.length ].green = val ( data )
			if name = "blue" then VisualEditor_Entities [ VisualEditor_Entities.length ].blue = val ( data )
			if name = "alpha" then VisualEditor_Entities [ VisualEditor_Entities.length ].alpha = val ( data )
			if name = "alignment" then VisualEditor_Entities [ VisualEditor_Entities.length ].alignment = val ( data )
			if name = "text size" then VisualEditor_Entities [ VisualEditor_Entities.length ].textSize = val ( data )
			if name = "collision" then VisualEditor_Entities [ VisualEditor_Entities.length ].collision = val ( data )
			if name = "active" then VisualEditor_Entities [ VisualEditor_Entities.length ].active = val ( data )
			if name = "physics" then VisualEditor_Entities [ VisualEditor_Entities.length ].physics = val ( data )
			if name = "dynamic res" then VisualEditor_Entities [ VisualEditor_Entities.length ].dynamicRes = data
			if name = "edit size" then VisualEditor_Entities [ VisualEditor_Entities.length ].editSize = val ( data )
			if name = "edit colour red" then VisualEditor_Entities [ VisualEditor_Entities.length ].editColourRed = val ( data )
			if name = "edit colour green" then VisualEditor_Entities [ VisualEditor_Entities.length ].editColourGreen = val ( data )
			if name = "edit colour blue" then VisualEditor_Entities [ VisualEditor_Entities.length ].editColourBlue = val ( data )
			if name = "edit background red" then VisualEditor_Entities [ VisualEditor_Entities.length ].editBackgroundRed = val ( data )
			if name = "edit background green" then VisualEditor_Entities [ VisualEditor_Entities.length ].editBackgroundGreen = val ( data )
			if name = "edit background blue" then VisualEditor_Entities [ VisualEditor_Entities.length ].editBackgroundBlue = val ( data )
			if name = "edit background alpha" then VisualEditor_Entities [ VisualEditor_Entities.length ].editBackgroundAlpha = val ( data )
			if name = "edit border red" then VisualEditor_Entities [ VisualEditor_Entities.length ].editBorderRed = val ( data )
			if name = "edit border green" then VisualEditor_Entities [ VisualEditor_Entities.length ].editBorderGreen = val ( data )
			if name = "edit border blue" then VisualEditor_Entities [ VisualEditor_Entities.length ].editBorderBlue = val ( data )
			if name = "edit border alpha" then VisualEditor_Entities [ VisualEditor_Entities.length ].editBorderAlpha = val ( data )
			if name = "edit border size" then VisualEditor_Entities [ VisualEditor_Entities.length ].editBorderSize = val ( data )
			if name = "edit max characters" then VisualEditor_Entities [ VisualEditor_Entities.length ].editMaxCharacters = val ( data )
			if name = "edit max lines" then VisualEditor_Entities [ VisualEditor_Entities.length ].editMaxLines = val ( data )
			if name = "edit multi line" then VisualEditor_Entities [ VisualEditor_Entities.length ].editMultiLine = val ( data )
			if name = "edit password" then VisualEditor_Entities [ VisualEditor_Entities.length ].editPassword = val ( data )
			if name = "edit cursor red" then VisualEditor_Entities [ VisualEditor_Entities.length ].editCursorRed = val ( data )
			if name = "edit cursor green" then VisualEditor_Entities [ VisualEditor_Entities.length ].editCursorGreen = val ( data )
			if name = "edit cursor blue" then VisualEditor_Entities [ VisualEditor_Entities.length ].editCursorBlue = val ( data )
			if name = "edit cursor width" then VisualEditor_Entities [ VisualEditor_Entities.length ].editCursorWidth = val ( data )
			if name = "edit cursor wrap" then VisualEditor_Entities [ VisualEditor_Entities.length ].editCursorWrap = val ( data )
			
			exitfunction 1
		endif
	next i
endfunction 0

function VisualEditor_StepThrough ( )
	ret as string = ""

	// loop round, break out on end block, parse other block
	// if needed and then get the actual data
	while 1
		if ( VisualEditor_IsEndBlock ( ) )
			exit
		elseif ( VisualEditor_IsBlock ( ) )
			VisualEditor_ParseBlock ( )
		else
			ret = VisualEditor_GetData ( )
		endif
	endwhile

	VisualEditor_SkipEnd ( )
endfunction ret


