
#constant True = 1
#constant False = 0
#constant On 1
#constant Off 0
#constant Space 32
#constant Tab 9
#constant Enter 13
#constant Null 0
#constant Undefined -1
#constant FullAlpha 255
#constant NoBlock %0000000000000010
#constant Block	  %0000000010000000		`#constant Block	  %0000000000000100


type ColorSpec
    r
    g
    b
    a
    satur as float `saturation
    spect as float `hue
    value as float
    lumin as float `calculated value
endtype

function CalcColor( c ref as ColorSpec, grid as gridType[] )
	c.lumin = c.value/SpectrumW
	percent# = (c.spect/SpectrumW) * 100
    hue = floor(percent# / 16.66667)
    p# = (percent# - (hue * 16.66667)) / 16.66667
    select hue
        case 0
            c.r = 255 * c.lumin
            c.g = (p# * 255) * c.lumin
            c.b = (255 * c.satur) * c.lumin
            if c.r > c.g  then  inc c.g,(c.r - c.g)*c.satur  else  inc c.r,(c.g - c.r)*c.satur
        endcase
        case 1
            c.r = (255 - (255 * p#)) * c.lumin
            c.g = 255 * c.lumin
            c.b = (255 * c.satur) * c.lumin
			if c.r > c.g  then  inc c.g,(c.r - c.g)*c.satur  else  inc c.r,(c.g - c.r)*c.satur
        endcase
        case 2
            c.r = (255 * c.satur) * c.lumin
            c.g = 255 * c.lumin
            c.b = (p# * 255) * c.lumin
			if c.g > c.b  then  inc c.b,(c.g - c.b)*c.satur  else  inc c.g,(c.b - c.g)*c.satur
		endcase
        case 3
            c.r = (255 * c.satur) * c.lumin
            c.g = (255 - (255 * p#)) * c.lumin
            c.b = 255 * c.lumin
			if c.g > c.b  then  inc c.b,(c.g - c.b)*c.satur  else  inc c.g,(c.b - c.g)*c.satur
        endcase
        case 4
            c.r = (p# * 255) * c.lumin
            c.g = (255 * c.satur) * c.lumin
            c.b = 255 * c.lumin
			if c.r > c.b  then  inc c.b,(c.r - c.b)*c.satur  else  inc c.r,(c.b - c.r)*c.satur
        endcase
        case 5
            c.r = 255 * c.lumin
            c.g = (255 * c.satur) * c.lumin
            c.b = (255 - (255 * p#)) * c.lumin
			if c.r > c.b  then  inc c.b,(c.r - c.b)*c.satur  else  inc c.r,(c.b - c.r)*c.satur
        endcase
    endselect
    ChangeColor( grid,c )
endfunction


`returns largest value
function Min(minimum#, number#)
	if number# < minimum# then number# = minimum#
endfunction number#

`returns smallest value
function Max(maximum#, number#)
	if number# > maximum# then number# = maximum#
endfunction number#

`returns value within range
function MinMax(minimum#,maximum#,number#)
	if number# < minimum#
		number# = minimum#
	elseif number# > maximum#
		number# = maximum#
	endif
endfunction number#

function SetupSprite(ID,imageID,filename$,x,y,width,height,depth,state,offset)
	LoadImage( ID,filename$ )
	CreateSprite( ID,imageID )
	SetSpriteDepth ( ID,depth )
	SetSpriteSize( ID,width,height )
	SetSpritePosition( ID,x,y )
	SetSpriteOffset( ID,offset,offset )
	SetSpriteActive( ID,state )
	SetSpriteVisible( ID,state )
endfunction

function SetNewSprite(imageID,filename$,x,y,width,height,depth,state,offset)
	ID = CreateSprite( imageID )
	LoadImage( ID,filename$ )
	SetSpriteDepth ( ID,depth )
	SetSpriteSize( ID,width,height )
	SetSpritePosition( ID,x,y )
	SetSpriteOffset( ID,offset,offset )
	SetSpriteActive( ID,state )
	SetSpriteVisible( ID,state )
endfunction ID

function Text(ID,text$,x,y,r,g,b,size,alpha,align)
	CreateText(ID,text$)
	SetTextAlignment(ID,align)
	SetTextSize(ID,size)
	SetTextPosition(ID,x,y)
	SetTextSpacing(ID,1)
	SetTextDepth(ID,0)
	SetTextColor(ID,r,g,b,alpha)
endfunction

function LoadButton(buttonID,imageUpID,imageDownID,fileUp$,fileDown$,x,y,s,state)
	LoadImage(imageUpID,fileUp$)
	LoadImage(imageDownID,fileDown$)
	AddVirtualButton(buttonID,x,y,s)
	SetVirtualButtonImageUp(buttonID,imageUpID)
	SetVirtualButtonImageDown(buttonID,imageDownID)
	SetVirtualButtonAlpha(buttonID,Brightest)
	SetVirtualButtonVisible(buttonID,state)
	SetVirtualButtonActive(buttonID,state)
endfunction

function WaitForButtonRelease(butt)
	repeat
		Sync()
	until GetVirtualButtonReleased( butt )
endfunction

function WaitForPointerRelease()
	repeat
		Sync()
	until GetPointerReleased()
endfunction

function Delay(seconds#)
	ResetTimer()
	repeat
		Sync()
	until Timer() >= seconds#
endfunction

function Heuristic(goalNode,currentNode,team)
	g# = CreateVector3( mapTable[goalNode].nodeX, mapTable[goalNode].nodeY,0 )
	c# = CreateVector3( mapTable[currentNode].nodeX, mapTable[currentNode].nodeY,0 )
	h# = GetVector3Distance( g#,c# )
	if team = PlayerTeam then inc h#,mapTable[currentNode].cost
endfunction h#

function VectorDistance( x1,y1,x2,y2 )
	one = CreateVector3( x1,y1,0 )
	two = CreateVector3( x2,y2,0 )
	dis = GetVector3Distance( one,two )
endfunction dis

function Randomize(min,max)
	seed = val(right(GetCurrentTime(),2))
	SetRandomSeed2(seed)
	rand = Random2(min,max)
endfunction rand

function DrawGrid(r,c,size,rgb)	`rows, columns, node size, color
	for i = 1 to r-1
		pos=i*size
		DrawLine( 0,pos,MaxWidth,pos,rgb,rgb,rgb )
	next i
	for i = 1 to c-1
		pos=i*size
		DrawLine( pos,0,pos,MaxHeight,rgb,rgb,rgb )
	next i
endfunction

function ReadDataFromString(s$,delimiter$,dataArray ref as integer[]) `takes empty array
	for i = 1 to len(s$)
		dataArray.insert(val(GetStringToken2(s$,delimiter$,i)))
	next i
endfunction dataArray.length



remstart
//~ #constant ImpassBlock %0000000000010000
//~ #constant TreeBlock   %0000000000001000
remend

