//~ type GameType
	//~ image as integer	//Image ID
	//~ mainspr as integer	//ID of sprite for main image
	//~ zoomfactor as float	//Magnification factor
//~ endtype

//~ function GetUserInput()
	//~ result = GetRawTouchCount(1)
//~ endfunction result

global zoomFactor as float

function HandleUserInput(in as integer)
	xoffset as float
	yoffset as float

	select in
		case 1: `Scroll
			//*** Calculate new scroll position ***
			post = GetRawFirstTouchEvent(0)
			xoffset = GetViewOffsetX()+(GetRawTouchLastX(post)-GetRawTouchCurrentX(post))/zoomFactor
			yoffset = GetViewOffsetY()+(GetRawTouchLastY(post)-GetRawTouchCurrentY(post))/zoomFactor

			//*** Adjust screen offset ***
			SetViewOffset(xoffset,yoffset)
		endcase
		case 2:
			y1 as float
			y2 as float
			distance as float
			new_distance as float
			difference as float

			//*** Get last y coord for each touch ***
			p1 = GetRawFirstTouchEvent(1)
			p2 = GetRawNextTouchEvent()
			y1 = GetRawTouchLastY(p1)
			y2 = GetRawTouchLastY(p2)

			//*** Calculate distance between the two points ***
			distance = Abs(y1 - y2)

			//*** Get new distance apart, compare with original and adjust zoom accordingly **
			new_distance = Abs(GetRawTouchCurrentY(p1)-GetRawTouchCurrentY(p2))
			difference = Abs(new_distance/distance)
			zoomFactor = zoomFactor * difference
			SetViewZoom(zoomFactor)
		endcase
	endselect
endfunction
