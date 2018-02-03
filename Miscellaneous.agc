
remstart
	Input Output
	 A B
	 0 0    0
	 1 0    1
	 0 1    1
	 1 1    0
 remend

#constant True = 1
#constant False = 0
#constant Read = 1
#constant Write = 0
#constant On 1
#constant Off 0
#constant Space 32
#constant Tab 9
#constant Enter 13
#constant RightArrow 39
#constant Null 0
#constant Undefined -1
#constant FullAlpha 255
#constant HalfAlpha 128
#constant NoBlock %1000000000000000
#constant Block	  %0000000000000100
#constant Null$ ""

global zoomFactor as float = 1.0
global lastX as float
global lastY as float
global minX as float
global maxX as float
global minY as float
global maxY as float
global newX as float = 0
global newY as float = 0
global xoffset as float = 0
global yoffset as float = 0
global dragMode as integer



function ASCII()
	repeat
		k = GetRawLastKey()
		print(k)
		sync()
	until k = Space
endfunction

function PinchToZoom()
	select GetRawTouchCount(1)
		case 1:  `Scroll; calculate new scroll position
			if zoomFactor > 1  `only scroll if zoomed-in
				ScrollLimits()
				post = GetRawFirstTouchEvent(0)
				xoffset = MinMax( minX,maxX,GetViewOffsetX()+ScreenToWorldX(GetRawTouchLastX(post))-ScreenToWorldX(GetRawTouchCurrentX(post)) )
				yoffset = MinMax( minY,maxY,GetViewOffsetY()+ScreenToWorldY(GetRawTouchLastY(post))-ScreenToWorldY(GetRawTouchCurrentY(post)) )
				SetViewOffset( xoffset,yoffset )
			else
				SetViewOffset( 0,0 )  `reset scroll
			endif
		endcase
		case 2:	`Zoom
			//*** Get last y coord for each touch ***
			t1 = GetRawFirstTouchEvent(1)
			t2 = GetRawNextTouchEvent()
			y1# = GetRawTouchLastY(t1)
			y2# = GetRawTouchLastY(t2)

			//*** Calculate distance between the two points ***
			distance# = Abs(y1# - y2#)

			//*** Get new distance apart, compare with original and adjust zoom accordingly **
			newDistance# = Abs(GetRawTouchCurrentY(t1)-GetRawTouchCurrentY(t2))
			difference# = Abs(newDistance#/distance#)
			zoomFactor = MinMax(1,4,zoomFactor*difference#) `minimum 100%, maximum 500%
			if zoomFactor = 1 then SetViewOffset(0,0) `reset scroll
			SetViewZoom( zoomFactor )
		endcase
	endselect
endfunction

function PresstoZoom()
	if GetRawKeyReleased(190) or GetRawKeyReleased(187)  // ">" or "="
		zoomFactor = Max(4,zoomFactor+.5)
	elseif GetRawKeyReleased(188) or GetRawKeyReleased(189)  // "<" or "-"
		zoomFactor = Min(1,zoomFactor-.5)
		if zoomFactor = 1 then SetViewOffset(0,0) `reset scroll
	else
		exitfunction
	endif
	SetViewZoom( zoomFactor )
	CalcScroll(lastX+newX-ScreenToWorldX(GetPointerX()),lastY+newY-ScreenToWorldY(GetPointerY()))
endfunction

function MouseScroll()
	if zoomFactor > 1 `only scroll if zoomed-in
		if GetPointerPressed()
			newX = ScreenToWorldX(GetPointerX())
			newY = ScreenToWorldY(GetPointerY())
			dragMode = True
		endif
		if GetPointerReleased() then dragMode = False
		if dragMode then CalcScroll(lastX+newX-ScreenToWorldX(GetPointerX()),lastY+newY-ScreenToWorldY(GetPointerY()))
	endif
endfunction

function CalcScroll(x,y)
	ScrollLimits()
	xoffset = MinMax( minX,maxX,x )
	yoffset = MinMax( minY,maxY,y )
	SetViewOffset( xoffset,yoffset )
	lastX = xoffset
	lastY = yoffset
endfunction

function ScrollLimits()
	zoom# = zoomFactor - 1.0
	ZFx2# = zoomFactor * 2.0
	minX = -zoom# * MaxWidth  / ZFx2# `should zoom * MaxWidth/MaxHeight be in ( )??
	maxX =  zoom# * MaxWidth  / ZFx2#
	minY = -zoom# * MaxHeight / ZFx2#
	maxY =  zoom# * MaxHeight / ZFx2#
endfunction

function KeyScroll()
	if zoomFactor > 1 `only scroll if zoomed-in
		nodeStep = NodeSize/zoomFactor

		if GetRawKeyState(37)     `KEY_LEFT
			dec newX,nodeStep
		elseif GetRawKeyState(39) `KEY_RIGHT
			inc newX,nodeStep
		elseif GetRawKeyState(38) `KEY_UP
			dec newY,nodeStep
		elseif GetRawKeyState(40) `KEY_DOWN
			inc newY,nodeStep
		else
			exitfunction
		endif
		CalcKeyScroll()
	else
		lastX = xoffset
		lastY = yoffset
	endif
endfunction

function OutOfBounds(x,y,x1,x2,y1,y2)
	if x <= x1 then exitfunction True
	if x >= x2 then exitfunction True
	if y <= y1 then exitfunction True
	if y >= y2 then exitfunction True
endfunction False

function CalcKeyScroll()
	ScrollLimits()
	//*** Calculate new scroll position ***
	xoffset = MinMax( minX,maxX,lastX+newX )
	yoffset = MinMax( minY,maxY,lastY+newY )
	SetViewOffset( xoffset,yoffset )
endfunction

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

function SetText(ID,x,y,r,g,b,size,alpha,align)
	SetTextAlignment(ID,align)
	SetTextSize(ID,size)
	SetTextPosition(ID,x,y)
	SetTextSpacing(ID,1)
	SetTextDepth(ID,0)
	SetTextColor(ID,r,g,b,alpha)
endfunction

function TweenText( textID,x1,x2,y1,y2,alpha1,alpha2,size1,size2,space1,space2,speed#,delay#,mode )
	tt = CreateTweenText( speed# )
	if alpha1 <> alpha2 then SetTweenTextAlpha( tt,alpha1,alpha2,mode )
	if size1 <> size2 then SetTweenTextSize( tt,size1,size2,mode )
	if space1 <> space2 then SetTweenTextSpacing( tt,space1,space2,mode )
	if x1 <> x2	then SetTweenTextX( tt,x1,x2,mode )
	if y1 <> y2	then SetTweenTextY( tt,y1,y2,mode )
	PlayTweenText( tt,textID,delay# )
endfunction tt

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

function Heuristic(goalNode,currentNode,team,vehicle)
	g# = CreateVector3( mapTable[goalNode].nodeX, mapTable[goalNode].nodeY,0 )
	c# = CreateVector3( mapTable[currentNode].nodeX, mapTable[currentNode].nodeY,0 )
	h# = GetVector3Distance( g#,c# )
		if (vehicle = Mech) or (vehicle = Engineer)
			if team = PlayerTeam `Player Mechs and Engineers not penalised for terrain
				inc h#,Clear
				exitfunction h#
			endif
		endif
	if (team = PlayerTeam) or (mapTable[currentNode].terrain <> Trees)
		inc h#,mapTable[currentNode].cost
	else  `reduce heuristic by Tree cost to help AI defensive position
		dec h#,mapTable[currentNode].cost : h# = Min(0,h#)
	endif
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
FROM CalcKeyScroll()
	zoom# =  zoomFactor - 1.0
	ZFx2# =  zoomFactor * 2.0
	minX# = -zoom# * MaxWidth  / ZFx2# `should zoom * MaxWidth/MaxHeight be in ( )??
	maxX# =  zoom# * MaxWidth  / ZFx2#
	minY# = -zoom# * MaxHeight / ZFx2#
	maxY# =  zoom# * MaxHeight / ZFx2#
remend

