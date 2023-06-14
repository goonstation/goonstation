/obj/line_obj/railgun
	name = "Energy"
	desc = ""
	anchored = ANCHORED
	density = 0
	opacity = 0

/obj/railgun_trg_dummy
	name = ""
	desc = ""
	anchored = ANCHORED
	density = 0
	opacity = 0
	invisibility = INVIS_ALWAYS_ISH

/obj/item/railgun
	name = "Railgun"
	desc = "Bzooom"
	icon = 'icons/obj/items/gun.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon_state = "railgun"
	item_state = "gun"
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	health = 10
	w_class = W_CLASS_SMALL

	afterattack(atom/target as mob|obj|turf, mob/user as mob)
		if(target == user) return

		var/atom/target_r = target

		if(isturf(target))
			target_r = new/obj/railgun_trg_dummy(target)

		playsound(src, 'sound/weapons/railgun.ogg', 40, 1)

		var/list/affected = DrawLine(src.loc, target_r, /obj/line_obj/railgun ,'icons/obj/projectiles.dmi',"WholeRailG",1,1,"HalfStartRailG","HalfEndRailG",OBJ_LAYER,1)

		for(var/obj/O in affected)
			O.anchored = ANCHORED //Proc wont spawn the right object type so lets do that here.
			O.name = "Energy"
			var/turf/src_turf = O.loc
			for(var/atom/A in src_turf)
				if(A == O || A == user) continue
				A.meteorhit(O)
//			var/turf/T = O.loc
//			for(var/atom/A in T.contents)
//				boutput(src, "There is a [A.name] at this location.")
			SPAWN(0.5 SECONDS) qdel(O)

		if(istype(target_r, /obj/railgun_trg_dummy)) qdel(target_r)

		return

/*
proc/Preload360()  //This is mainly for overhead pixel movement games but often works in the majority.
	var/icon/Total_Icon = new('icons/effects/LghtLine.dmi')
	var/IS = "WholeLghtn"
	for(var/i = 0,i < 360,i++)
		var/icon/I = new('full.dmi')
		I.Turn(i+45)
		Total_Icon.Insert(I,"[IS][i]")
	IS = "HalfStartLghtn"
	for(var/i = 0,i < 360,i++)
		var/icon/I = new('halfstart.dmi')
		I.Turn(i+45)
		Total_Icon.Insert(I,"[IS][i]")
	IS = "HalfEndLghtn"
	for(var/i = 0,i < 360,i++)
		var/icon/I = new('halfend.dmi')
		I.Turn(i+45)
		Total_Icon.Insert(I,"[IS][i]")
	usr << ftp(Total_Icon,"PreloadedLine.dmi")
*/

//This is not my code. VVV

/*
The DrawLine proc in detail:




The Proc:

  DrawLine(Start,End,LineType,Icon,Whole_Icon_State,CenterOfIconStart,CenterOfIconEnd,HalfStart_Icon_State,HalfEnd_Icon_State,Layer,ExtraDetection,StartPx,StartPy,EndPx,EndPy,SpecStartPx,SpecStartPy)



The Arguments:

  Start
      -The /atom the line will start at.  CANNOT BE TURF.
  End
      -The /atom the line will end at.  CANNOT BE TURF.
  LineType
      -The object type path that the lines will be defined as.
      -Example value:  /obj/Line
  Icon
      -The icon that the lines will get their images from.
      -Note that you must make your .dmi file according to what you want as the Whole, HalfEnd, and HalfStart icon states.
  Whole_Icon_State
      -The icon state of the body of the lines.  Like in Line.dmi, this should be a 3x3 line that stretches diagonally (NW corner-SE corner) accross the icon.
      -Default value:  "", Reccomended value:  "Whole"
  CenterOfIconStart
      -1 if you want the line to be drawn into the center of it's starting position, 0 if you want it to start at the edge.
      -Default:  1
  CenterOfIconEnd
      -1 if you want the line to be drawn into the center of it's ending position, 0 if you want it to start at the edge.
      -Default:  1
  HalfStart_Icon_State
      -The icon_state of the line going into the center of the starting position.  Like in Line.dmi, this should be a 3x3 line that stretches diagonally from the NW corner to the 17 pixel_y mark.
      -Default and Reccomended Value:  "HalfStart"
  HalfEnd_Icon_State
      -The icon_state of the line going into the center of the ending position.  Like in Line.dmi, this should be a 3x3 line that stretches diagonally from the SE corner to the 17 pixel_y mark.
      -Default and Reccomended Value:  "HalfEnd"
  Layer
      -This is the layer you want the line objects to be created on.
      -Default:  OBJ_LAYER
  ExtraDetection
      -1 if you want it to add extra lines to the line list to account for areas where one line segment crosses 2 tiles.
      -(The reason this is in effect is so it detects all tiles the line goes into, instead of just ones where the entire line segment is within bounds.  Check scrnshot1.jpg and scrnshot2.jpg for examples.)
      -Reccomended:  1
      -Note that when you access the line list that is returned by the DrawLine proc, if you have Extra Detection on, if you are editing the images of lines, make sure to check if the line has an icon or not to determine if it is an extra detection line (which is invisible) or a regular line (which is visible).
  StartPx
      -Leave null unless you want pixel-based support.
      -If you want pixel-based support, set this to the object's Px loc var. (I refer to Px as a mob's x var multiplied by 32 and then having the lower-left corner of the object's bounding box's x added to it.)
      -Example:  M.Px
      -Example (with math):  M.x*32+M.BBLowerLeftx
      -Default value:  null
      -You can instead set a specific location instead of using an object and using it's bounding box.  This is shown in the demo.  Remember, however, that this library always needs a start and end object.
      -Example (without objects):  37*32+45
  StartPy
      -Leave null unless you want pixel-based support.
      -If you want pixel-based support, set this to the object's Py loc var. (I refer to Py as a mob's x var multiplied by 32 and then having the lower-left corner of the object's bounding box's y added to it.)
      -Example:  M.Py
      -Example (with math):  M.y*32+M.BBLowerLefty
      -Default value:  null
      -You can instead set a specific location instead of using an object and using it's bounding box.  This is shown in the demo.  Remember, however, that this library always needs a start and end object.
      -Example (without objects):  37*32+45
  EndPx
      -Leave null unless you want pixel-based support.
      -Like StartPx, but for the ending object instead of the starting object.
  EndPy
      -Leave null unless you want pixel-based support.
      -Like StartPy, but for the ending object instead of the starting object.
  SpecStartPx
      -In StartPx, you see 3 parts that are equated for the math.  M.x*32+M.BBLowerLeftx.  SpecStartPx is the third part that is added to StartPx; which is, in this case, M.BBLowerLeftx.
      -It is the Px equation without the tiles into the map counted in.
      -Can be anywhere from -16 to 16.
  SpecStartPy
      -In StartPy, you see 3 parts that are equated for the math.  M.y*32+M.BBLowerLefty.  SpecStartPy is the third part that is added to StartPy; which is, in this case, M.BBLowerLefty.
      -It is the Py equation without the tiles into the map counted in.
      -Can be anywhere from -16 to 16.


This proc returns a list of the line objects for your detection purposes.  As an example of how it's used, you can
loop through the line segments (a line segment is a 32x32 tile containing a piece of line or if not visible it's an
extra detection line), and check if any of the line segments' locs have say, a monster in their contents.  If so,
damage that monster.



Example of Proper Usage (Tile-based):

  src.LineList.Add(DrawLine(StartingObject,EndingObject,/obj/Line,'Line.dmi',"Whole",1,1,"HalfStart","HalfEnd",OBJ_LAYER,1))

You could then access the list to see what turfs/mobs/objs/etc. the line crossed like this:

  for(var/obj/Line/L in src.LineList)
      boutput(src, "The line crossed loc [L.x],[L.y]")
      var/turf/T = L.loc
      for(var/atom/A in T.contents)
          boutput(src, "There is a [A.name] at this location.")


*/

proc/Get_Angle(atom/ref, atom/target,startpx,startpy,endpx,endpy)
  if(!ref || !target) return 0
  var/dy
  var/dx
  if(startpx)
    dy = endpy - startpy
    dx = endpx - startpx
  else
    dy = target.y - ref.y
    dx = target.x - ref.x
  if(!dy)
    return (dx>=0) ? 90 : 270
  . = arctan(dx/dy)
  if(dy<0)
    . += 180
  else if(dx<0)
    .+=360


proc/DrawLine(atom/Start,atom/End,LineType,Icon,Whole_Icon_State = "",CenterOfIconStart=1,CenterOfIconEnd=1,HalfStart_Icon_State = "HalfStart",HalfEnd_Icon_State = "HalfEnd",Layer=OBJ_LAYER,ExtraDetection=1,startpx,startpy,endpx,endpy,startpx2,startpy2,PreloadedIcon=null)
	if(isturf(Start) || isturf(End))
		world.log << "DrawLine ERROR:  Cannot draw line with turf for starting or ending point.  Please use /obj points instead. S: [Start] | E: [End]"
		return
	if (!Start || !End)
		return
	var/list/LineList = list()
	var/Angle = Get_Angle(Start,End,startpx,startpy,endpx,endpy)
	var/icon/I
	if(!PreloadedIcon)
		I = new(Icon)
		I.Turn(Angle+45)
	else
		I = PreloadedIcon
	var/turf/CurrentLoc = line_ReturnNextTile(Start,Angle)
	if(!CurrentLoc)
		CurrentLoc = Start
	var/Nullspace = round(tan(90-Angle)*32)
	var/ReturnedDir = line_ReturnDir(Start,Angle,End,startpx,startpy,endpx,endpy)
	if(ReturnedDir == EAST||ReturnedDir == WEST)
		Nullspace = round(cot(90-Angle)*32)
	if(Angle == 180)
		Nullspace = 0  //Small bug workaround
	var/CoorCounter = Nullspace
	if(Start.loc != End.loc&&!(Start.loc in orange(1,End.loc)))
		while(CurrentLoc&&!(((ReturnedDir == NORTH||ReturnedDir == SOUTH)&&CurrentLoc.x == End.x)||((ReturnedDir == EAST||ReturnedDir == WEST)&&CurrentLoc.y == End.y)||(ReturnedDir == null&&CurrentLoc == End.loc)))
			var/obj/NewLine = new LineType
			if(!PreloadedIcon)
				NewLine.icon = I
				NewLine.icon_state = Whole_Icon_State
			else
				NewLine.icon = PreloadedIcon
				NewLine.icon_state = "[Whole_Icon_State][round(Angle)]"
			NewLine.layer = Layer
			if(CoorCounter >= 32)
				CoorCounter -= 32
				CurrentLoc = get_step(CurrentLoc,ReturnedDir)
			else if(CoorCounter <= -32)
				CoorCounter += 32
				CurrentLoc = get_step(CurrentLoc,ReturnedDir)
			if(!CurrentLoc)
				return
			line_PixelOffset(NewLine,ReturnedDir,Angle,CoorCounter,startpx2,startpy2)
			NewLine.set_loc(CurrentLoc)
			LineList.Add(NewLine)
			CoorCounter += Nullspace
			CurrentLoc = line_ReturnNextTile(CurrentLoc,Angle)
	if(CenterOfIconStart == 1)
		var/obj/NewLineStart = new LineType
		if(!PreloadedIcon)
			NewLineStart.icon = I
			NewLineStart.icon_state = HalfStart_Icon_State
		else
			NewLineStart.icon = PreloadedIcon
			NewLineStart.icon_state = "[HalfStart_Icon_State][round(Angle)]"
		NewLineStart.layer = Layer
		line_PixelOffset(NewLineStart,ReturnedDir,Angle,0,startpx2,startpy2)
		NewLineStart.set_loc(Start.loc)
		LineList.Add(NewLineStart)
	if(CenterOfIconEnd == 1)
		var/obj/NewLineEnd = new LineType
		if(!PreloadedIcon)
			NewLineEnd.icon = I
			NewLineEnd.icon_state = HalfEnd_Icon_State
		else
			NewLineEnd.icon = PreloadedIcon
			NewLineEnd.icon_state = "[HalfEnd_Icon_State][round(Angle)]"
		NewLineEnd.layer = Layer
		if(CoorCounter >= 32)
			CoorCounter -= 32
			CurrentLoc = get_step(CurrentLoc,ReturnedDir)
		else if(CoorCounter <= -32)
			CoorCounter += 32
			CurrentLoc = get_step(CurrentLoc,ReturnedDir)
		NewLineEnd.set_loc(CurrentLoc)
		line_PixelOffset(NewLineEnd,ReturnedDir,Angle,CoorCounter,startpx2,startpy2)
		LineList.Add(NewLineEnd)
	var/EndCount = length(LineList)
	for(var/obj/L in LineList)
		if(LineList.Find(L) > EndCount)
			break
		else
			if(L.pixel_y >= 17)
				if(ExtraDetection == 1&&L.pixel_y <= 21)
					var/obj/ExtraLine = new LineType
					ExtraLine.set_loc(L.loc)
					LineList.Add(ExtraLine)
				L.pixel_y -= 32
				L.y++
			if(L.pixel_y <= -17)
				if(ExtraDetection == 1&&L.pixel_y >= -21)
					var/obj/ExtraLine = new LineType
					ExtraLine.set_loc(L.loc)
					LineList.Add(ExtraLine)
				L.pixel_y += 32
				L.y--
			if(L.pixel_x >= 17)
				if(ExtraDetection == 1&&L.pixel_x <= 21)
					var/obj/ExtraLine = new LineType
					ExtraLine.set_loc(L.loc)
					LineList.Add(ExtraLine)
				L.pixel_x -= 32
				L.x++
			if(L.pixel_x <= -17)
				if(ExtraDetection == 1&&L.pixel_x >= -21)
					var/obj/ExtraLine = new LineType
					ExtraLine.set_loc(L.loc)
					LineList.Add(ExtraLine)
				L.pixel_x += 32
				L.x--
	return LineList





//This returns the next tile based on angle.
proc/line_ReturnNextTile(turf/Start,Angle)
	var/turf/ReturnedLoc
	var/RetDir = line_ReturnEfficDir(Angle)
	ReturnedLoc = get_step(Start,RetDir)
	return ReturnedLoc

//This proc returns a straight dir based on starting and ending points
//It is used in place of get_dir(), for get_dir() will return diagonals.
proc/line_ReturnDir(turf/Start,Angle,turf/End,startpx,startpy,endpx,endpy)
	var/ReturnedDir = null
	var/RetDir = line_ReturnEfficDir(Angle)
	switch(RetDir)
		if(NORTH)
			if(End.x > Start.x||(startpx&&startpx <= endpx))
				ReturnedDir = EAST
			else if(End.x < Start.x||(startpx&&startpx >= endpx))
				ReturnedDir = WEST
		if(EAST)
			if(End.y > Start.y||(startpy&&startpy <= endpy))
				ReturnedDir = NORTH
			else if(End.y < Start.y||(startpy&&startpy >= endpy))
				ReturnedDir = SOUTH
			else
				ReturnedDir = null
		if(SOUTH)
			if(End.x > Start.x||(startpx&&startpx <= endpx))
				ReturnedDir = EAST
			else if(End.x <= Start.x||(startpx&&startpx >= endpx))
				ReturnedDir = WEST
			else
				ReturnedDir = null
		if(WEST)
			if(End.y > Start.y||(startpy&&startpy <= endpy))
				ReturnedDir = NORTH
			else if(End.y < Start.y||(startpy&&startpy >= endpy))
				ReturnedDir = SOUTH
			else
				ReturnedDir = null
	return ReturnedDir

//This offsets the image based on quadrent and direction.
proc/line_PixelOffset(obj/NewLine,ReturnedDir,Angle,CoorCounter,startpx2=0,startpy2=0)
	if(ReturnedDir != null)
		switch(ReturnedDir)
			if(NORTH)
				if(Angle >= 225&&Angle < 315)
					NewLine.pixel_y = 0-CoorCounter+startpy2
					NewLine.pixel_x = startpx2
				else
					NewLine.pixel_y = CoorCounter+startpy2
					NewLine.pixel_x = startpx2
			if(SOUTH)
				if(Angle >= 225&&Angle < 315)
					NewLine.pixel_y = 0-CoorCounter+startpy2
					NewLine.pixel_x = startpx2
				else
					NewLine.pixel_y = CoorCounter+startpy2
					NewLine.pixel_x = startpx2
			if(EAST)
				NewLine.pixel_x = abs(CoorCounter)+startpx2
				NewLine.pixel_y = startpy2
			if(WEST)
				if(Angle >= 315)
					NewLine.pixel_x = CoorCounter+startpx2
					NewLine.pixel_y = startpy2
				else
					NewLine.pixel_x = 0-CoorCounter+startpx2
					NewLine.pixel_y = startpy2

//This returns a direction based on angle, to determine which straight should be used.
proc/line_ReturnEfficDir(Angle)
	var/ReturnedDir
	if((Angle >= 0&&Angle < 45)||Angle >= 315)
		ReturnedDir = NORTH
	else if(Angle >= 45&&Angle < 135)
		ReturnedDir = EAST
	else if(Angle >= 135&&Angle < 225)
		ReturnedDir = SOUTH
	else if(Angle >= 225&&Angle < 315)
		ReturnedDir = WEST
	return ReturnedDir



