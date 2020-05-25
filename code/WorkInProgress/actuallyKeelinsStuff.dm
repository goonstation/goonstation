//This file contains stuff that is still *mostly* my code.

#define LINEMODE_SEGMENT 1
#define LINEMODE_STRETCH 2
#define LINEMODE_MOVE 3
/*
Proc: drawLine
Arguments:
	source: The source atom where the beam begins.
	target: The target atom where the beam ends.
	render_source_line: The name of the rendersource to use for the line segments.
						If you do not have one prepared, you can pass in the name of an icon state in lines2.dmi and one will be created for you. The name will be *iconstate
						You can also pass in a list with rendersource names instead. They will be treated as above but the proc will pick randomly from the list.
	render_source_cap: The name of the rendersource to use for the line cap.
						If you do not have one prepared, you can pass in the name of an icon state in lines2.dmi and one will be created for you. The name will be *iconstate
						You can also pass in a list with rendersource names instead. They will be treated as above but the proc will pick randomly from the list.
	src_off_x: X offset applied to the source location of the beam.
	src_off_y: Y offset applied to the source location of the beam.
	trg_off_x: X offset applied to the target location of the beam.
	trg_off_y: Y offset applied to the target location of the beam.
	mode: If set to LINEMODE_SEGMENT, the proc will use multiple beam segments to reach the full length. The last segment might still be squished.
		  If set to LINEMODE_STRETCH, the beam segment will be stretched to the full length of the beam.
		  TBI: If set to LINEMODE_MOVE, one full sized segment will travel from source to target, repeatedly.
	getCrossed: If set to 1, we will return a list of crossed turfs in our /datum/lineResult 's crossed var.
	adjustTiles: If 1, will attempt to correct the list of crossed turfs based on the offsets passed into the proc.
				 If 0, will ignore the offsets and just go from source to target.
Returns:
	An instance of /datum/lineResult. See below drawLine.
		lineImage contains the finished line image. You will still need to output it for it to be visible. addGlobalImage is an option.
		By default the image is attached to source. You can change this by setting the image's loc to something else.
		crossed contains a list of crossed turfs if getCrossed was set to 1.
*/
/proc/drawLine(var/atom/source, var/atom/target, var/render_source_line = null, var/render_source_cap = null, var/src_off_x=0, var/src_off_y=0, var/trg_off_x=0, var/trg_off_y=0, var/mode = LINEMODE_STRETCH, var/getCrossed = 1, var/adjustTiles=1)
	if(render_source_line == null) return
	var/datum/lineResult/result = new()

	if(!islist(render_source_line))
		if(!getGlobalRenderSource((copytext(render_source_line,1,2) == "*" ? render_source_line : "*[render_source_line]")))
			if(copytext(render_source_line,1,2) == "*") render_source_line = copytext(render_source_line,2,0)
			addGlobalRenderSource(image('icons/effects/lines2.dmi',null, render_source_line), "*[render_source_line]")
		if(copytext(render_source_line,1,2) != "*") render_source_line = "*[render_source_line]"
	else
		for(var/X in render_source_line)
			var/current = X
			if(!getGlobalRenderSource((copytext(current,1,2) == "*" ? current : "*[current]")))
				if(copytext(current,1,2) == "*") current = copytext(current,2,0)
				addGlobalRenderSource(image('icons/effects/lines2.dmi',null, current), "*[current]")
			if(copytext(X,1,2) != "*")
				current = "*[current]"
			render_source_line -= X
			render_source_line += current

	if(!islist(render_source_cap))
		if(render_source_cap != null && !getGlobalRenderSource((copytext(render_source_cap,1,2) == "*" ? render_source_cap : "*[render_source_cap]")))
			if(copytext(render_source_cap,1,2) == "*") render_source_cap = copytext(render_source_cap,2,0)
			addGlobalRenderSource(image('icons/effects/lines2.dmi',null, render_source_cap), "*[render_source_cap]")
		if(copytext(render_source_cap,1,2) != "*") render_source_cap = "*[render_source_cap]"
	else
		for(var/X in render_source_cap)
			var/current = X
			if(!getGlobalRenderSource((copytext(current,1,2) == "*" ? current : "*[current]")))
				if(copytext(current,1,2) == "*") current = copytext(current,2,0)
				addGlobalRenderSource(image('icons/effects/lines2.dmi',null, current), "*[current]")
			if(copytext(X,1,2) != "*")
				current = "*[current]"
			render_source_cap -= X
			render_source_cap += current

	var/iconWidth = 64
	var/dx = ((target.x * world.icon_size) + trg_off_x) - ((source.x * world.icon_size) + src_off_x)
	var/dy = ((target.y * world.icon_size) + trg_off_y) - ((source.y * world.icon_size) + src_off_y)
	var/dist = sqrt(dx*dx + dy*dy)
	var/angle = -arctan(dx, dy)
	var/scale = (dist / iconWidth)

	if(getCrossed)
		var/sourceX = source.x
		var/sourceY = source.y
		var/targetX = target.x
		var/targetY = target.y
		if(adjustTiles) //Not sure this works on negative offsets - which direction do we round? Need ceil for neg numbers?
			sourceX += (src_off_x >= 0 ? round(src_off_x / world.icon_size) : round(src_off_x / world.icon_size, 1))
			sourceY += (src_off_y >= 0 ? round(src_off_y / world.icon_size) : round(src_off_y / world.icon_size, 1))
			targetX += (trg_off_x >= 0 ? round(trg_off_x / world.icon_size) : round(trg_off_x / world.icon_size, 1))
			targetY += (trg_off_y >= 0 ? round(trg_off_y / world.icon_size) : round(trg_off_y / world.icon_size, 1))
		result.crossed = raytrace(source, target)

	 //Have to move it around due to internal canvas size or something. sigh.
	if(mode == LINEMODE_STRETCH)
		var/matrix/M = UNLINT(matrix().Scale(scale,1).Translate(-(dist/2),0).Turn(angle).Translate(src_off_x,src_off_y))
		var/image/I = image(null,source)
		I.appearance_flags = KEEP_APART  //Required for some odd reason.
		I.filters += filter(type="layer", render_source = (islist(render_source_line) ? pick(render_source_line) : render_source_line), transform=M)
		if(render_source_cap != null)
			var/matrix/M2 = UNLINT(matrix().Translate(-(iconWidth / 2),0).Turn(angle).Translate(src_off_x,src_off_y))
			I.filters += filter(type="layer", render_source = (islist(render_source_cap) ? pick(render_source_cap) : render_source_cap), transform=M2)
		I.transform = UNLINT(matrix().Turn(-angle).Translate((dist),0).Turn(angle))
		result.lineImage = I
	else if(mode == LINEMODE_SEGMENT)
		var/image/composite = image(null,source)
		composite.appearance_flags = KEEP_APART //Required for some odd reason.
		if(scale >= 1)
			var/fullSized = round(scale)
			var/remainder = scale - fullSized
			for(var/i=0,i<fullSized,i++)
				var/matrix/M = UNLINT(matrix().Translate((i*iconWidth) + (iconWidth / 2) - dist,0).Turn(angle).Translate(src_off_x,src_off_y))
				composite.filters += filter(type="layer", render_source = (islist(render_source_line) ? pick(render_source_line) : render_source_line), transform=M)
			var/matrix/M = UNLINT(matrix().Scale(remainder,1).Translate(fullSized*iconWidth + ((iconWidth / 2)*remainder) - dist,0).Turn(angle).Translate(src_off_x,src_off_y))
			composite.filters += filter(type="layer", render_source = (islist(render_source_line) ? pick(render_source_line) : render_source_line), transform=M)
			if(render_source_cap != null)
				var/matrix/M2 = UNLINT(matrix().Translate((fullSized*iconWidth) + (iconWidth / 2) - dist - (iconWidth - (iconWidth * remainder)),0).Turn(angle).Translate(src_off_x,src_off_y))
				composite.filters += filter(type="layer", render_source = (islist(render_source_cap) ? pick(render_source_cap) : render_source_cap), transform=M2)
			composite.transform = UNLINT(matrix().Turn(-angle).Translate((dist),0).Turn(angle))
		else
			var/remainder = scale
			var/matrix/M = UNLINT(matrix().Scale(remainder,1).Translate((iconWidth / 2) * remainder - dist,0).Turn(angle).Translate(src_off_x,src_off_y))
			composite.filters += filter(type="layer", render_source = (islist(render_source_line) ? pick(render_source_line) : render_source_line), transform=M)
			if(render_source_cap != null)
				var/matrix/M2 = UNLINT(matrix().Translate((iconWidth / 2) - dist - (iconWidth - (iconWidth * remainder)),0).Turn(angle).Translate(src_off_x,src_off_y))
				composite.filters += filter(type="layer", render_source = (islist(render_source_cap) ? pick(render_source_cap) : render_source_cap), transform=M2)
			composite.transform = UNLINT(matrix().Turn(-angle).Translate((dist),0).Turn(angle))
		result.lineImage = composite
	return result

/datum/lineResult
	var/image/lineImage = null
	var/list/crossed = null

//Gets a line of turfs between the two atoms. Doesn't miss tiles, like bresenham.
//Adapted from http://playtechs.blogspot.com/2007/03/raytracing-on-grid.html
/proc/raytrace(var/atom/source, var/atom/target)
	var/x0 = source.x
	var/y0 = source.y
	var/x1 = target.x
	var/y1 = target.y
	var/list/crossed = list()
	var/dx = abs(x1 - x0)
	var/dy = abs(y1 - y0)
	var/x = x0
	var/y = y0
	var/n=(1+dx+dy)
	var/x_inc = ((x1 > x0) ? 1 : -1)
	var/y_inc = ((y1 > y0) ? 1 : -1)
	var/error = dx - dy
	dx *= 2
	dy *= 2
	while(n>0)
		crossed += get_turf(locate(x, y, source.z))
		if(error > 0)
			x += x_inc
			error -= dy
		else if(error < 0)
			y += y_inc
			error += dx
		else if(error == 0) //Skip over direct vertex crossings. More accurate.
			x += x_inc
			y += y_inc
			error -= dy
			error += dx
			n--
		n--
	return crossed

/proc/testLine()
	var/atom/source = get_turf(usr)
	var/atom/target = get_turf(pick(oview(5)))
	var/datum/lineResult/R = drawLine(source, target, list("elec1","elec2","elec3"), "eleccap")
	var/globalImageKey = "linetest[rand(0,INFINITY)]"
	R.lineImage.color = "#4b8aff"
	addGlobalImage(R.lineImage, globalImageKey)
	// for(var/atom/A in R.crossed)
	// 	A.color = "#32a867"
	sleep(7 SECONDS)
	removeGlobalImage(globalImageKey)
	return

/proc/weirdAura(var/atom/A)
	var/obj/O = new(A.loc)
	var/image/rayComp = image(null,O)

	A.render_target = "/ref[A]"

	rayComp.render_source = A.render_target
	rayComp.appearance_flags = KEEP_TOGETHER
	rayComp.filters += filter(type="rays", size=96, density=8, factor=1)
	animate(rayComp.filters[rayComp.filters.len], offset=1000, time = 6000, loop = -1)
	rayComp.filters += filter(type="alpha", render_source = "floor_plane")
	rayComp.filters += filter(type="alpha", render_source = "game_plane")

	rayComp.transform = matrix().Scale(1.2,1.2)
	rayComp.color = "#ffbdf1"
	addGlobalImage(rayComp, A.render_target + "-warp1")
	return

/proc/testShroud()
	var/obj/screen/S = new(usr)
	var/image/I = image('icons/effects/160x160.dmi',S,"tearmed")
	I.render_target = "*test"
	S.screen_loc = "CENTER"
	S.mouse_opacity = 1
	S.filters += filter(type="layer", render_source = "floor_plane")
	S.filters += filter(type="layer", render_source = "game_plane")
	S.filters += filter(type="layer", render_source = "*hidden_game_plane")
	S.filters += filter(type="color", color=list(0.2,0.05,0.05, 0.1,0.3,0.2, 0.1,0.1,0.4, 0,0,0)) //Alpha method preserves interaction but you can use object outside your range and alpha gets destroyed
	S.filters += filter(type="alpha", render_source="*test")										//Going with this because i only need visibility
	//S.plane = PLANE_LIGHTING - 1  //If we want lighting
	usr << I
	usr.client.screen += S
	S.appearance_flags = KEEP_TOGETHER
	for(var/atom/movable/MO in orange(2, usr))
		if(istype(MO, /obj/overlay/tile_effect/)) continue
		MO.plane = PLANE_HIDDENGAME

	return

/proc/testEffectRgb(var/atom/A)
	A.render_target = "\ref[A]"
	var/f

	var/obj/O = A//new(A.loc)
	O.appearance_flags = KEEP_APART

	var/image/red = image(null,O)
	red.render_source = A.render_target
	red.filters += filter(type="color", color=list(1,0,0, 0,0,0, 0,0,0, 0,0,0))
	red.filters += filter(type="ripple", x=0, y=0, size=rand()*2.5+1, repeat=rand()*2.5+1, radius=0)
	red.render_target = "*" + A.render_target + "-red"
	f = red.filters[red.filters.len]
	animate(f, size=f:size, time=0, loop=-1, radius=0, flags=ANIMATION_PARALLEL)
	animate(size=0, radius=rand()*10+10, time=rand()*20+10)
	red.appearance_flags = KEEP_APART
	addGlobalImage(red, red.render_target)

	var/image/green = image(null,O)
	green.render_source = A.render_target
	green.filters += filter(type="color", color=list(0,0,0, 0,1,0, 0,0,0, 0,0,0))
	green.filters +=  filter(type="ripple", x=0, y=0, size=rand()*2.5+1, repeat=rand()*2.5+1, radius=0)
	green.render_target = "*" + A.render_target + "-green"
	f = green.filters[green.filters.len]
	animate(f, size=f:size, time=0, loop=-1, radius=0, flags=ANIMATION_PARALLEL)
	animate(size=0, radius=rand()*10+10, time=rand()*20+10)
	green.appearance_flags = KEEP_APART
	addGlobalImage(green, green.render_target)

	var/image/blue = image(null,O)
	blue.render_source = A.render_target
	blue.filters += filter(type="color", color=list(0,0,0, 0,0,0, 0,0,1, 0,0,0))
	blue.filters += filter(type="ripple", x=0, y=0, size=rand()*2.5+1, repeat=rand()*2.5+1, radius=0)
	blue.render_target = "*" + A.render_target + "-blue"
	f = blue.filters[blue.filters.len]
	animate(f, size=f:size, time=0, loop=-1, radius=0, flags=ANIMATION_PARALLEL)
	animate(size=0, radius=rand()*10+10, time=rand()*20+10)
	blue.appearance_flags = KEEP_APART
	addGlobalImage(blue, blue.render_target)

	var/image/composite = image(null,O)
	//composite.render_target = "*" + A.render_target + "-composite"
	composite.filters += filter(type="layer", render_source = red.render_target, blend_mode = BLEND_ADD)
	composite.filters += filter(type="layer", render_source = green.render_target, blend_mode = BLEND_ADD)
	composite.filters += filter(type="layer", render_source = blue.render_target, blend_mode = BLEND_ADD)
	composite.override = 1
	composite.appearance_flags = KEEP_TOGETHER
	addGlobalImage(composite, A.render_target + "-rgbeffect")

	//A.filters += filter(type="layer", render_source = composite.render_target)

	return

var/list/electiles = list()

/proc/electile(numb as num)
	for(var/X in electiles)
		del(X)
	for(var/turf/T in view())
		var/obj/overlay/O = new(T)
		O.icon = icon('icons/effects/electile.dmi')
		O.icon_state = "v[numb][pick("a","b","c")]"
		electiles.Add(O)

/proc/testburning()
	for(var/i=0, i<5, i++)
		var/atom/A = null
		while(A == null || istype(A, /obj/overlay) || isturf(A) || A.invisibility)
			A = pick(view(usr, 5))
		A.setStatus("burning", 60 SECONDS)
	return


//http://www.byond.com/forum/post/2522992
/obj/testportal
	name = "BLAH"
	vis_flags = VIS_HIDE
	appearance_flags = KEEP_TOGETHER

	proc/setup()
		plane = FLOAT_PLANE
		layer = FLOAT_LAYER

		var/image/compImage = image('icons/effects/effects.dmi',src,"null")
		compImage.render_target = "*portaltrg"

		var/turf/trgTurf = locate(src.x+1, src.y, src.z)
		compImage.vis_contents += trgTurf
		compImage.appearance_flags = KEEP_TOGETHER

		var/image/alphaMask = image('icons/effects/effects.dmi',src,"portaltest")
		alphaMask.render_target = "*portalmask"

		compImage.filters += filter(type="alpha", render_source="*portalmask")

		src.underlays += alphaMask
		src.underlays += compImage

		src.filters += filter(type="layer", render_source="*portaltrg")

	New()
		SPAWN_DBG(50) setup()

/atom/proc/cabinetGlassIcon(var/atom/A, var/targetWidth = 12, var/targetHeight= 10, var/iconSize = 32)
	var/icon/I = icon(A.icon, A.icon_state)
	var/list/results = getIconBounds(I, A.icon_state)
	I.Shift(SOUTH, results["bottom"]-1, 1)
	I.Shift(WEST, results["left"]-1, 1)
	var/sizeX = results["top"] - results["bottom"]
	var/sizeY = results["right"] - results["left"]
	var/factorX = targetWidth / sizeX
	var/factorY = targetHeight / sizeY
	var/scalingFactor = -1
	if(factorX < factorY)
		scalingFactor = factorX
	else if (factorY < factorX)
		scalingFactor = factorY
	else if (factorX == factorY)
		scalingFactor = factorX
	if(scalingFactor < 1)
		I.Scale(iconSize*scalingFactor, iconSize*scalingFactor)
		I.Shift(EAST,((sizeX * scalingFactor) / 2) / 2)

	var/icon/backGlass = icon('icons/obj/furniture/cabinet.dmi', "slot_empty")
	var/icon/glass = icon('icons/obj/furniture/cabinet.dmi', "slot_transparent")
	I.Blend(backGlass, ICON_UNDERLAY)
	I.Blend(glass, ICON_OVERLAY)

	return I

/proc/getIconBounds(var/icon/I, var/icon_state)
	var/list/results = list("bottom" = INFINITY, "left" = INFINITY, "top" = 0, "right" = 0)
	for(var/x=1, x<=I.Width(), x++)
		for(var/y=1, y<=I.Height(), y++)
			var/pixel = I.GetPixel(x, y, null)
			if(pixel != null)
				if(y < results["bottom"]) results["bottom"] = y
				if(y > results["top"]) results["top"] = y
				if(x < results["left"]) results["left"] = x
				if(x > results["right"]) results["right"] = x

	return results

/obj/decal/cleanable/markerdrawing
	name = "marker doodles"
	desc = "someone drew something here"
	var/list/arteests = list()

/obj/item/permmarker
	name = "Permanent Marker"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "marker"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	color = "#0099ff"

	var/drawing = 0
	var/mouseDown = 0
	var/datum/gunTarget/target = null
	var/startingLoc = null
	var/obj/decal/cleanable/markerdrawing/currentDecal = null
	var/icon/currentIcon = null
	var/lastx = -1
	var/lasty = -1
	var/obj/decal/cleanable/markerdrawing/lastDecal = null

	onMouseDrag(src_object,atom/over_object,src_location,over_location,src_control,over_control,params)
		if(target == null) target = new()
		if(!over_object || !istype(over_object, /atom)) return
		target.params = params2list(params)
		target.target = over_object
		target.user = usr
		if(over_object.loc != startingLoc && over_object != startingLoc) return
		if(currentDecal != null)
			draw()

	onMouseDown(atom/object,location,control,params)
		if(object == src || (!isturf(object.loc) && !isturf(object))) return
		if(!object || !istype(object, /atom)) return
		if(target == null) target = new()
		target.params = params2list(params)
		target.target = object
		target.user = usr
		startingLoc = get_turf(object)
		mouseDown = 1
		var/obj/decal/cleanable/markerdrawing/M = (locate(/obj/decal/cleanable/markerdrawing) in startingLoc)
		if(M != null)
			currentDecal = M
			currentIcon = icon(M.icon)
			currentDecal.icon = currentIcon
		else
			currentDecal = make_cleanable(/obj/decal/cleanable/markerdrawing,startingLoc)
			currentIcon = icon('icons/effects/effects.dmi', "nothing")
			currentDecal.icon = currentIcon
		if(!currentDecal.arteests.Find(usr))
			currentDecal.arteests.Add(usr)
		draw()

	onMouseUp(object,location,control,params)
		mouseDown = 0

	proc/draw()
		if(currentDecal != null && currentIcon != null && target != null)
			var/pox = text2num(target.params["icon-x"])
			var/poy = text2num(target.params["icon-y"])

			/* not working
			if(lastx != -1 && lasty != -1 && lastDecal == currentDecal)
				if(abs(lastx - pox) > 1 || abs(lasty - poy) > 1)
					while(lastx != pox && lasty != poy)
						if(lastx < pox) lastx++
						if(lastx > pox) lastx--
						if(lasty < poy) lasty++
						if(lasty > poy) lasty--
						currentIcon.DrawBox(color,lastx,lasty)
			*/

			currentIcon.DrawBox(color,pox,poy)
			lastx = pox
			lasty = poy
			lastDecal = currentDecal

		currentDecal.icon = currentIcon
		return

	attack_self(mob/user as mob)
		var/col = (input(user, "Choose a color", "Permanent Marker") as color)
		color = col
		return

/proc/testMapLoad()
	var/mapPath = input(usr, "Enter map path:", "", "assets/maps/prefabs/wizard_tower.dmm")
	var/loaded = file2text(mapPath)

	if(loaded)
		boutput(usr, "<span class='alert'>GRABBED '[mapPath]' FROM LOCAL FILESYSTEM</span>")
	else
		boutput(usr, "<span class='alert'>COULDNT LOAD '[mapPath]'</span>")
		return

	var/trgX = input(usr, "Enter target X:", "", 1) as num
	var/trgY = input(usr, "Enter target Y:", "", 1) as num
	var/trgZ = input(usr, "Enter target Z:", "", 1) as num

	if(trgX && trgY && trgZ)
		var/startTime = world.timeofday
		var/dmm_suite/D = new/dmm_suite()
		if(loaded && lentext(loaded))
			usr.loc = locate(trgX,trgY,trgZ)
			D.read_map(loaded,trgX,trgY,trgZ)
			boutput(usr, "<span class='alert'>LOADED '[mapPath]' IN [((world.timeofday - startTime)/10)] SEC</span>")
		else
			boutput(usr, "<span class='alert'>COULDNT LOAD '[mapPath]'</span>")
	return

/proc/endoftheworldasweknowit()
	var/list/L = list()
	for(var/turf/T in world)
		if(T.type == /turf/space) continue
		if(T.z == 1)
			L.Add(T)

	var/turf/TLast = pick(L)
	L.Remove(TLast)

	while(L.len >= 1)
		var/turf/TA = pick(L)
		L.Remove(TA)
		TLast.vis_contents += TLast
		TLast = TA

/proc/endoftheworldasweknowit2()
	var/list/L = list()
	for(var/turf/T in world)
		if(T.type == /turf/space) continue
		if(T.z == 1)
			L.Add(T)

	while(L.len >= 1)
		var/turf/TA = pick(L)
		L.Remove(TA)
		var/turf/TB = pick(L)
		L.Remove(TB)
		TA.vis_contents += TB

/proc/fixthisshitplease()
	for(var/turf/T in world)
		if(T.z == 1)
			T.vis_contents.Cut()

/obj/fancyportal
	name = ""
	mouse_opacity = 0
	desc = ""
	density = 1
	opacity = 0
	anchored = 1
	var/targetX = 2
	var/targetY = 2
	var/targetZ = 2
	var/target_tag = null
	var/datum/light/light

	New()
		light = new /datum/light/point
		light.set_color(0.3, 0.6, 0.8)
		light.set_brightness(0.5)
		light.attach(src)
		light.enable()
		SPAWN_DBG(0.6 SECONDS)
			if (target_tag)
				var/atom/target = locate(target_tag)
				if(target)
					targetX = target.x
					targetY = target.y
					targetZ = target.z
					updateVis()
		updateVis()
		..()

	proc/setTarget(var/atom/A)
		if (A)
			targetX = A.x
			targetY = A.y
			targetZ = A.z
			updateVis()
		return

	onVarChanged(variable, oldval, newval)
		. = 0
		switch(variable)
			if ("targetZ")
				updateVis()
			if ("targetY")
				updateVis()
			if ("targetY")
				updateVis()

	proc/updateVis()
		src.overlays.Cut()
		vis_contents = list()
		vis_contents += locate(targetX, targetY, targetZ)

		var/icon/mask = null
		mask = icon('icons/effects/effects.dmi',"portalcutout")
		mask.Blend(getFlatIcon(src.loc), ICON_MULTIPLY)
		var/image/finished = image(mask,"",layer = 13)
		src.overlays += image('icons/effects/effects.dmi',"portalshade",layer = 12)
		src.overlays += image('icons/effects/effects.dmi',"portal",layer = 13)
		src.overlays += finished
		return

	Bumped(atom/movable/AM)
		var/turf/T = locate(targetX, targetY, targetZ)
		if(T)
			AM.set_loc(T)
		else
			src.visible_message("<span style='color: red; font-weight: bold'>The portal collapses in on itself!</span>")
			var/obj/sparks = unpool(/obj/effects/sparks)
			sparks.set_loc(get_turf(src))
			SPAWN_DBG(2 SECONDS) if (sparks) pool(sparks)
			qdel(src)
		return

	/*
	Crossed(atom/movable/AM as mob|obj)
		var/turf/T = locate(targetX, targetY, targetZ)
		if(T)
			AM.set_loc(T)
		else
			src.visible_message("<span style='color: red; font-weight: bold'>The portal collapses in on itself!</span>")
			var/obj/sparks = unpool(/obj/effects/sparks)
			sparks.set_loc(get_turf(src))
			SPAWN_DBG(2 SECONDS) if (sparks) pool(sparks)
			qdel(src)
		return
	*/

/obj/hole
	name = ""
	mouse_opacity = 1
	desc = ""
	density = 0
	opacity = 0
	anchored = 1
	var/targetZ = 2

	onVarChanged(variable, oldval, newval)
		. = 0
		switch(variable)
			if ("targetZ")
				updateVis()
	New()
		updateVis()
		for(var/obj/hole/H in range(1, src.loc))
			H.updateVis()
		..()

	proc/updateVis()
		src.overlays.Cut()
		vis_contents = list()

		vis_contents += locate(src.x, src.y, src.targetZ)
		var/turf/T = locate(src.x, src.y+1, src.z)
		if(T)
			if(istype(T, /turf/simulated) && !(locate(/obj/hole) in T))
				src.overlays += image('icons/effects/effects.dmi',icon_state = "dark", layer=11)
				src.overlays += image('icons/effects/effects.dmi',icon_state = "wallfade", layer=12)
			else
				src.overlays += image('icons/effects/effects.dmi',icon_state = "dark", layer=11)
		return

	Crossed(atom/movable/AM as mob|obj)
		if (isobserver(AM))
			return
		AM.set_loc(locate(src.x, src.y, src.targetZ))
		if(ismob(AM))
			boutput(AM, "You fall into the hole ...")
		return

/proc/fuckthestationuphorribly()
	//var/startTime = world.timeofday

	var/list/areas = list()

	var/list/ignoreAreas = list(/area/station/solar,/area/station/catwalk,/area/wizard_station,/area/syndicate_station,/area/listeningpost,/area/station/hallway,/area/station/com_dish,/area/shuttle,/area/station/maintenance,/area/ghostdrone_factory,/area/abandonedship,/area/supply,/area/mining/magnet)

	outer:
		for(var/area/A as area in world) //Might want to do this manually instead.
			if(A.type == /area)
				continue

			for(var/X in ignoreAreas)
				if(istype(A, X))
					continue outer

			var/count = 0

			for(var/turf/T in A)
				if(T.z != 1)
					continue outer
				count++

			if(count <= 5)
				continue

			if(A && A.z == 1) //Basically, if the area has a turf on z1 ... Doesn't work as described in byond documentation. So we have to do it the slow way ...
				areas.Add(A)

	while(areas.len >= 2)
		var/area/one = pick(areas)
		areas.Remove(one)
		var/area/two = pick(areas)
		areas.Remove(two)

		if(one && two)
			swapareaobjects(one, two)

	//boutput(world, "Done ([round((world.timeofday - startTime) / 10)] secs)")

	return

/proc/swapareaobjects(var/area/one, var/area/two)
	var/list/oneContents = one.contents.Copy()
	var/list/twoContents = two.contents.Copy()
	var/list/oneAccess = list()
	var/list/twoAccess = list()

	var/list/oneTurfs = list()
	var/list/twoTurfs = list()

	for(var/atom/T in oneContents)
		if(istype(T, /obj/machinery/door))
			var/obj/machinery/door/D = T
			if(D.req_access && D.req_access.len)
				oneAccess |= D.req_access

		if(isturf(T))
			if(!T.density)
				oneTurfs.Add(T)

	for(var/atom/T in twoContents)
		if(istype(T, /obj/machinery/door))
			var/obj/machinery/door/D = T
			if(D.req_access && D.req_access.len)
				twoAccess |= D.req_access

		if(isturf(T))
			if(!T.density)
				twoTurfs.Add(T)

	if(!twoTurfs.len || !oneTurfs.len)
		return

	var/list/oneTurfsExpend = oneTurfs.Copy()
	var/list/twoTurfsExpend = twoTurfs.Copy()

	var/list/ignoreTypes = list(/obj/machinery/disposal,/obj/cable,/obj/machinery/power,/obj/machinery/light,/obj/disposalpipe,/obj/grille,/obj/window,/obj/machinery/door,/obj/machinery/atmospherics,/obj/overlay/tile_effect)

	var/oneName = ""
	var/twoName = ""
	if(one && two)
		oneName = one.name
		twoName = two.name
		one.name = getInterpolatedName(oneName, twoName, (rand(3,7) / 10))
		two.name = getInterpolatedName(twoName, oneName, (rand(3,7) / 10))
		oneName = one.name
		twoName = two.name

	oneOuter:
		for(var/obj/O in oneContents)
			if(O.invisibility && !istype(O, /obj/landmark)) continue oneOuter

			if(istype(O, /obj/machinery/door))
				var/obj/machinery/door/D = O
				//D.req_access = twoAccess.Copy()
				D.req_access = list()
				D.name = oneName

			if(istype(O,/obj/machinery/power/apc))
				O.name = "[oneName] APC"

			for(var/T in ignoreTypes)
				if(istype(O, T)) continue oneOuter

			if(twoTurfsExpend.len > 0)
				var/turf/T = pick(twoTurfsExpend)
				twoTurfsExpend.Remove(T)
				O.set_loc(T)
			else
				O.set_loc(pick(twoTurfs))

	twoOuter:
		for(var/obj/O in twoContents)
			if(O.invisibility && !istype(O, /obj/landmark)) continue twoOuter

			if(istype(O, /obj/machinery/door))
				var/obj/machinery/door/D = O
				//D.req_access = oneAccess.Copy()
				D.req_access = list()
				D.name = twoName

			if(istype(O,/obj/machinery/power/apc))
				O.name = "[twoName] APC"

			for(var/T in ignoreTypes)
				if(istype(O, T)) continue twoOuter

			if(oneTurfsExpend.len > 0)
				var/turf/T = pick(oneTurfsExpend)
				oneTurfsExpend.Remove(T)
				O.set_loc(T)
			else
				O.set_loc(pick(oneTurfs))

	return

/obj/decal/valterak
	name = "skeleton"
	desc = "You can see a skeleton down there. It seems to be holding some sort of key."
	icon = 'icons/misc/exploration.dmi'
	icon_state = "valterak"
	anchored = 1
	density = 0
	opacity = 0

/obj/decal/valterakWhip
	name = "???"
	desc = "Upon closer inspection these seem to be the burnt remnants of a whip. How they are still there or even recognizable is beyond you."
	icon = 'icons/misc/exploration.dmi'
	icon_state = "vwhip"
	anchored = 1
	density = 0
	opacity = 0

/datum/admins/proc/camtest()
	set category = "Debug"
	set name = "Test Cinematic camera"
	set desc="Test Cinematic camera"

	var/mob/M = usr
	var/datum/targetable/cincam/R = new()
	M.targeting_ability = R
	M.update_cursor()

/datum/targetable/cincam
	target_anything = 1
	targeted = 1
	max_range = 3000

	castcheck(var/mob/M)
		if (M.client && M.client.holder)
			return 1

	handleCast(var/atom/selected)
		var/mob/M = usr
		var/dur = (get_dist(selected, M)*5)
		var/ease = pick(LINEAR_EASING,SINE_EASING,CIRCULAR_EASING,QUAD_EASING,CUBIC_EASING,BOUNCE_EASING,ELASTIC_EASING,BACK_EASING)
		boutput(world, "dur [dur] , ease : [ease] , dist : [get_dist(selected, M)] , selected : [selected]")
		cinLookAt(M, selected, dur, ease, 1, 1, 1)
		sleep(dur+3)
		cinShake(M,20,0.5,0,32,ease,1,1,1)
		sleep(max(0.5*2,0) * 20)
		return 1

/proc/cinShake(var/mob/source, var/steps = 20, var/length = 2, var/delay = 0, var/strength = 32, var/anim_easing = LINEAR_EASING, var/remove_source = 0, var/freeze_source = 1, var/persist = 0)
	if(!source || !source.client) return

	var/mob/cinematicCamera/C

	if(istype(source.loc, /mob/cinematicCamera))
		source = source.loc

	if(!istype(source, /mob/cinematicCamera))
		C =	new/mob/cinematicCamera(get_turf(source))
		C.start(source, remove_source, freeze_source)
		sleep(0.3 SECONDS)
	else
		C = source

	C.shake(steps, length, delay, strength, anim_easing)

	if(!persist)
		SPAWN_DBG(max(length*2,delay) * steps)
			C.stop()

	return

/proc/cinLookAt(var/mob/source, var/atom/target, var/duration = 1, var/easing = LINEAR_EASING, var/remove_source = 0, var/freeze_source = 1, var/persist = 0)
	if(!source || !source.client || !target) return

	var/mob/cinematicCamera/C

	if(istype(source.loc, /mob/cinematicCamera))
		source = source.loc

	if(!istype(source, /mob/cinematicCamera))
		C =	new/mob/cinematicCamera(get_turf(source))
		C.start(source, remove_source, freeze_source)
		sleep(0.3 SECONDS)
	else
		C = source

	C.lookAt(target, duration, easing)

	if(!persist)
		SPAWN_DBG(duration)
			C.stop()

	return

/mob/cinematicCamera
	var/mob/source
	var/atom/source_loc
	var/remove_source = 0 //Remove the source mob while camera is active?
	var/freeze_source = 1 //Attempt to make source mob immovable and invincible during cam?
	nodamage = 1
	canmove = 0
	invisibility = 101
	density = 0
	anchored = 1

	proc/shake(var/steps = 20, var/length = 1, var/delay = 0, var/strength = 32, var/anim_easing = LINEAR_EASING)
		SPAWN_DBG(0)
			for(var/i=0, i<steps, i++)
				var/off_x = (rand(0, strength) * (prob(50) ? -1:1))
				var/off_y = (rand(0, strength) * (prob(50) ? -1:1))
				animate(src.client, pixel_x = off_x, pixel_y = off_y, easing = anim_easing, time=length, flags = ANIMATION_PARALLEL | ANIMATION_RELATIVE)
				animate(pixel_x = off_x*-1, pixel_y = off_y*-1, easing = anim_easing, time = length) //Relative to itself?! might have to do off * -1 instead of 0
				sleep(max(length*2,delay))
		return

	proc/lookAt(var/atom/target, var/duration = 10, var/anim_easing = LINEAR_EASING)
		if(!source || !src.client || !target) return

		var/offset_x = (target.x * 32) - ((src.x * 32) + src.client.pixel_x)
		var/offset_y = (target.y * 32) - ((src.y * 32) + src.client.pixel_y)
		animate(src.client, pixel_x = offset_x, pixel_y = offset_y, easing = anim_easing, time = duration, flags = ANIMATION_PARALLEL)
		return

	proc/start(var/mob/source_mob, var/remove, var/freeze)
		if(source_mob == src) return
		if(source_mob && source_mob.client)
			source = source_mob
			remove_source = remove
			freeze_source = freeze
			source_loc = source.loc
			client = source.client
			if(remove_source)
				source.loc = src
			if(freeze_source)
				source.nodamage = 1
				source.canmove = 0
				source.anchored = 1
		return

	proc/stop()
		source.loc = source_loc
		source.client = client
		source.client.pixel_x = 0
		source.client.pixel_y = 0
		if(freeze_source)
			source.nodamage = 0
			source.canmove = 1
			source.anchored = 0

		del(src)
		return


	New()
		..()

/*
/atom/verb/keelinTest()
	set src in view()
	animate(src, pixel_y = 32, time = 10, loop=-1, flags = ANIMATION_PARALLEL)
	animate(pixel_y = 0, time = 10)

	animate(src, pixel_y = 32, time = 20, loop=-1, flags = ANIMATION_PARALLEL)
	animate(pixel_y = 0, time = 20)
	//src.setTexture("damaged", BLEND_MULTIPLY, "damaged")
	//src.setTexture("shiny", BLEND_ADD, "shiny")
*/
//
/obj/wormhole
	name = "nascent wormhole"
	desc = "a small baby wormhole"
	anchored = 1
	density = 0
	icon = 'icons/effects/64x64.dmi'
	icon_state = "whole-nascent"
	pixel_x = -16
	pixel_y = -16
	blend_mode = 2
	New()
		SPAWN_DBG(10 SECONDS)
			name = "growing wormhole"
			desc = "a slowly growing wormhole"
			icon_state = "whole-growing"
			blend_mode = 2
		SPAWN_DBG(20 SECONDS)
			name = "stable wormhole"
			desc = "a wormhole leading who-knows-where"
			icon_state = "whole"
			blend_mode = 1
		SPAWN_DBG(30 SECONDS)
			name = "massive wormhole"
			desc = "a huge wormhole leading to unknown space"
			icon_state = "whole-massive"
			blend_mode = 1
		SPAWN_DBG(40 SECONDS)
			name = "unstable wormhole"
			desc = "an unstable wormhole, about to collapse"
			icon_state = "whole-unstable"
			blend_mode = 1
		SPAWN_DBG(50 SECONDS)
			qdel(src)
		..()

/obj/meleeeffect
	name = ""
	desc = ""
	icon = 'icons/effects/meleeeffects.dmi'
	icon_state = "sabre"
	anchored = 1
	layer = EFFECTS_LAYER_1

	New()
		SPAWN_DBG(2 SECONDS)
			qdel(src)
		..()

	spear
		icon_state = "spear"

	dagger
		icon_state = "dagger"
		pixel_x = -32
		pixel_y = -32

	drill
		icon = 'icons/effects/effects.dmi'
		icon_state = "drill"

	pick
		icon = 'icons/effects/effects.dmi'
		icon_state = "pick"

	hammer
		icon = 'icons/effects/effects.dmi'
		icon_state = "hammer"

	blaster
		icon = 'icons/effects/effects.dmi'
		icon_state = "blaster"

	conc
		icon = 'icons/effects/effects.dmi'
		icon_state = "conc"

	blasterline
		icon = 'icons/effects/effects.dmi'
		icon_state = "glowyline"

/obj/meleeeffect/spearimage
	name = ""
	desc = ""
	icon = null
	icon_state = "sabre"
	anchored = 1
	New(var/obj/item/experimental/melee/spear/S,var/atom/location)
		src.loc = location
		var/image/I = image(S)
		I.appearance_flags = 0
		src.overlays += image(S)
		SPAWN_DBG(0.5 SECONDS)
			qdel(src)
		..()

/obj/item/experimental/ranged
	name = "test"
	desc = ""
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "sword1-W"
	inhand_image_icon = 'icons/mob/inhand/hand_cswords.dmi'
	item_state = "sword1-W"
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	var/obj/beam_dummy/beam
	var/turf/last = null

	onMouseDrag(src_object,atom/over_object,src_location,over_location,src_control,over_control,params)
		var/list/parameters = params2list(params)
		if(ismob(over_object.loc) || istype(over_object, /obj/screen)) return
		if(parameters["left"])
			//animate_shake(over_object)
			if(beam)
				if(last != get_turf(over_object))
					last = get_turf(over_object)
					beam.loc = get_turf(src)
					animate(beam, transform=beam.transform, time=1)//, flags=ANIMATION_LINEAR_TRANSFORM)
					animate(transform=getLineMatrix(get_turf(src),get_turf(over_object)), time= max(7-get_dist(get_turf(src),get_turf(over_object)), 2))
		return

	onMouseDown(atom/target,location,control,params)
		var/list/parameters = params2list(params)
		if(ismob(target.loc) || istype(target, /obj/screen)) return
		if(parameters["left"])
			if(beam)
				qdel(beam)
				beam = null
			beam = new (get_turf(src))
			beam.icon_state = "beam"
			beam.transform = getLineMatrix(get_turf(src),get_turf(target))
		return

	onMouseUp(atom/target,location,control,params)
		var/list/parameters = params2list(params)
		if(parameters["left"])
			if(beam)
				qdel(beam)
				beam = null
			return
		return

/obj/item/experimental/melee/hammertwotest
	name = "crappy test hammer"
	desc = "a shitty 2-handed hammer. attacks slowly but does great damage"
	icon_state = "hammer"
	item_state = "hammer"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	two_handed = 1
	click_delay = 30
	force = 50

/obj/item/experimental/melee
	name = "melee weapon"
	desc = ""
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "sword1-W"
	inhand_image_icon = 'icons/mob/inhand/hand_cswords.dmi'
	item_state = "sword1-W"
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, var/reach)
		return doAttack(user, target, reach ? target : null)

	proc/doAttack(var/mob/user, var/atom/target, var/atom/exclude = null)
		var/direction = getAttackDir(user, target)
		var/list/attacked = list()
		if(exclude) attacked.Add(exclude)

		for(var/turf/T in getAffectedTiles(user,target,direction) )
			for(var/atom/A in T)
				if(A in attacked) continue
				if((ismob(A) || A.density || istype(A, /obj/critter)) && !istype(A, /obj/table))
					A.attackby(src, user)
		showEffect(user,target,direction)
		return

	proc/getAffectedTiles(var/mob/user, var/atom/target, var/direction)
		return list()

	proc/showEffect(var/mob/user, var/atom/target, var/direction)
		return

	proc/getAttackDir(var/mob/user, var/atom/target)
		var/attackDir = get_dir(user, target)
		if(attackDir == NORTHEAST || attackDir == NORTHWEST || attackDir == SOUTHEAST || attackDir == SOUTHWEST)
			attackDir = (prob(50) ? turn(attackDir, 45) : turn(attackDir, -45))
		return attackDir

/datum/action/bar/private/icon/daggerStab
	id = "daggerStab"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED | INTERRUPT_ACTION
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "cdagger"
	var/obj/item/experimental/melee/dagger/dagger
	var/mob/user
	var/atom/target
	var/list/seen = list()
	var/progress = 0.01
	duration = -1
	icon_y_off = 29

	New(var/obj/item/experimental/melee/dagger/D, var/mob/U, var/atom/T)
		if(!D || !U || !T)
			interrupt(INTERRUPT_ALWAYS)
		else
			dagger = D
			user = U
			target = T

	onStart()
		..()
		target.add_fingerprint(user)

	onInterrupt(var/flag)
		..()

	onEnd()
		..()
		if(get_dist(user, target) > 1 || target == null || user == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(dagger)
			if(dagger == user.equipped())
				dagger.stab(user, target, progress)
				return

	onUpdate()
		if(get_dist(user, target) > 1 || target == null || user == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(dagger)
			if(dagger != user.equipped())
				interrupt(INTERRUPT_ALWAYS)
				return

		progress = min(progress + 0.1, 1)

		bar.color = "#0000FF"
		bar.transform = matrix(progress, 1, MATRIX_SCALE)
		bar.pixel_x = -nround( ((30 - (30 * progress)) / 2) )

		if(progress == 1)
			state = ACTIONSTATE_FINISH
			return

		for(var/mob/O in AIviewers(owner))
			if(!seen.Find(O))
				var/canSee = 0
				switch(get_dist(O, user))
					if(0 to 1)
						if(O.dir == turn(user.dir, 180)) //Only visible if looking directly at them in close range.
							canSee = 1
					if(2)
						if(get_dir(O, user) == O.dir) //If you're looking in their direction at 2 tiles away you'll see it.
							canSee = 1
					else continue
				if(canSee)
					seen.Add(O)
					O.show_message("<span class='alert'><B>[user] raises \the [dagger] menacingly!!!</B></span>", 1)


/obj/item/experimental/melee/dagger
	name = "Dagger"
	desc = "A dagger. Perfect for back-stabbing. Only good for back-stabbing, actually."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "cdagger"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "dagger"
	hitsound = null
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT | SUPPRESSATTACK
	force = 1
	var/datum/action/bar/private/icon/daggerStab/stabAction

	onMouseDown(atom/target,location,control,params)
		var/mob/user = usr
		var/list/parameters = params2list(params)
		if(ismob(target.loc) || istype(target, /obj/screen)) return
		if(parameters["left"])
			var/attackDir =  getAttackDir(user, target)
			user.dir = attackDir
			stabAction = new(src, user, get_step(user, attackDir))
			actions.start(stabAction, user)
		return

	onMouseUp(atom/target,location,control,params)
		var/list/parameters = params2list(params)
		if(parameters["left"])
			if(stabAction)
				//stabAction.target = get_step(usr, getAttackDir(usr, target))
				stabAction.state = ACTIONSTATE_FINISH
		return

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, var/reach)
		return 1

	proc/stab(var/mob/attacker, var/atom/stabbed, var/stabStrength)
		var/turf/T = get_turf(stabbed)
		doAttack(attacker, T, null, stabStrength)

	doAttack(var/mob/user, var/atom/target, var/atom/exclude = null, var/stabStrength = 0)
		var/list/attacked = list()
		if(exclude) attacked.Add(exclude)

		var/stabbyness = (stabStrength == 1 ? 200 : round(90 * stabStrength))
		var/bloody = (stabStrength == 1)
		var/hitmob = 0

		flags &= ~SUPPRESSATTACK
		for(var/atom/A in get_turf(target))
			if(A in attacked) continue
			attacked.Add(A)
			if((ismob(A) || A.density || istype(A, /obj/critter)) && !istype(A, /obj/table))
				force = stabbyness

				if(ismob(A) && get_dist(A, user) == 1 && (A.dir == user.dir || A:lying)) //It's a person and they are facing away from us. Bonus damage.
					force = round(stabbyness * 2)
					bloody = 1

				if((isobj(A) && !istype(A, /obj/critter)) || isturf(A)) //Cant stab objects or turfs well.
					force = round(stabbyness * 0.15)

				if(ismob(A))//Shitty hack because attackby uses spawn on mobs. Meaning force etc will reset before the attack executes, thus doing 0 damage.
					src.attack(A, user, user.zone_sel && user.zone_sel.selecting ? user.zone_sel.selecting : null)
					if(bloody)
						bleed(A, 5, 5, get_turf(target))
						bleed(A, 5, 2, get_step(target,get_dir(user, target)))
						bleed(A, 5, 1, get_step(get_step(target,get_dir(user, target)),get_dir(user, target)))
						//blood_slash(A, 5, get_step(target,get_dir(user, target)), get_dir(user, target), 4)
					hitmob = 1
				else
					A.attackby(src, user)

		if(bloody && hitmob)
			playsound(target, 'sound/impact_sounds/Blade_Small_Bloody.ogg', 100, 0)
		else
			playsound(target, 'sound/impact_sounds/Blade_Small.ogg', 100, 0)

		flags |= SUPPRESSATTACK
		force = initial(force)

		showEffect(user,target,user.dir, stabStrength)

		return

	showEffect(var/mob/user, var/atom/target, var/direction, var/stabStrength = 0)
		var/obj/meleeeffect/dagger/M
		M = new/obj/meleeeffect/dagger(target)
		M.dir = direction
		M.color = (stabStrength < 1 ? "#FFFFFF" : "#FF4444")

/obj/item/experimental/melee/spear
	name = "Spear"
	desc = "A primitive spear with a long reach."
	force = 10
	throwforce = 20
	color = "#ffffff"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "spear"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "staff_crystal"
	var/datum/material/shaft = null
	var/datum/material/head = null
	var/image/shaftImg = null
	var/image/headImg = null
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
	hit_type = DAMAGE_STAB

	New()
		setShaftMaterial(getMaterial("bohrum"))
		setHeadMaterial(getMaterial("telecrystal"))
		buildOverlays()
		setName()

		..()

		src.setItemSpecial(/datum/item_special/rangestab)

	doAttack(var/mob/user, var/atom/target, var/atom/exclude = null)
		return //nah

	attack_self(mob/user as mob)
		if (istype(user.loc, /obj/vehicle/segway))
			var/obj/vehicle/segway/S = user.loc
			if (S.joustingTool == src) // already raised as a lance, lower it
				user.visible_message("[user] lowers the lance.", "You lower the spear.")
				S.joustingTool = null
			else // Lances up!
				user.visible_message("[user] raises a lance!", "You raise the lance into jousting position.")
				S.joustingTool = src

	proc/setShaftMaterial(var/datum/material/M)
		shaft = M
		if(shaft)
			src.color = shaft.color
			src.alpha = shaft.alpha
		setName()
		return

	proc/setHeadMaterial(var/datum/material/M)
		head = M
		setMaterial(M)
		if(shaft)
			src.color = shaft.color
			src.alpha = shaft.alpha
		if(src.material && src.material.hasProperty("hard"))
			src.force = round(src.material.getProperty("hard") / 5)
			src.throwforce = round(src.material.getProperty("hard") / 3)
		setName()
		return

	proc/buildOverlays()
		overlays.Cut()
		if(shaft)
			var/image/imgShaft = image('icons/obj/items/weapons.dmi',icon_state = "spear")
			imgShaft.color = shaft.color
			imgShaft.alpha = shaft.alpha
			imgShaft.appearance_flags = RESET_ALPHA | RESET_COLOR
			overlays += imgShaft
			shaftImg = imgShaft
		if(head)
			var/image/imgHead = image('icons/obj/items/weapons.dmi',icon_state = "spearhead")
			imgHead.color = head.color
			imgHead.alpha = head.alpha
			imgHead.appearance_flags = RESET_ALPHA | RESET_COLOR
			overlays += imgHead
			headImg = imgHead
		return

	proc/setName()
		if(shaft && head)
			name = "[head.name]-tipped [shaft.name] Spear"
		else if (shaft && !head)
			name = "[shaft.name] Spear"
		else if (!shaft && head)
			name = "[head.name]-tipped Spear"
		else
			name = "Spear"
		return

	getAffectedTiles(var/mob/user, var/atom/target, var/direction)
		var/list/affected = list()
		switch(direction)
			if(NORTH)
				for(var/i=1, i<=3, i++)
					var/turf/T = locate(user.x, user.y+i, user.z)
					affected += T
					var/stop = 0
					for(var/atom/movable/M in T)
						if(M.density)
							stop = 1
							break
					if(T.density || stop)
						break
			if(EAST)
				for(var/i=1, i<=3, i++)
					var/turf/T = locate(user.x+i, user.y, user.z)
					affected += T
					var/stop = 0
					for(var/atom/movable/M in T)
						if(M.density)
							stop = 1
							break
					if(T.density || stop)
						break
			if(SOUTH)
				for(var/i=1, i<=3, i++)
					var/turf/T = locate(user.x, user.y-i, user.z)
					affected += T
					var/stop = 0
					for(var/atom/movable/M in T)
						if(M.density)
							stop = 1
							break
					if(T.density || stop)
						break
			if(WEST)
				for(var/i=1, i<=3, i++)
					var/turf/T = locate(user.x-i, user.y, user.z)
					affected += T
					var/stop = 0
					for(var/atom/movable/M in T)
						if(M.density)
							stop = 1
							break
					if(T.density || stop)
						break
		return affected
//
	showEffect(var/mob/user, var/atom/target, var/direction)
		var/partred   = GetRedPart(src.color) / 255
		var/partgreen = GetGreenPart(src.color) / 255
		var/partblue  = GetBluePart(src.color) / 255

		var/color_new = list(partred*2.5,0.30,0.30, 0.30,partgreen*2.5,0.30, 0.30,0.30,partblue*2.5, 0,0,0)
		var/atom/effectLoc = null
		var/obj/meleeeffect/spear/M
		//var/obj/meleeeffect/spearimage/I
		switch(direction)
			if(NORTH)
				effectLoc = locate(user.x, user.y + 1, user.z)
				/*
				I = new(src, effectLoc)
				I.dir = direction
				animate(I, pixel_y = 96, time = 6, alpha= 0)
				*/
				M = new/obj/meleeeffect/spear(effectLoc)
				M.pixel_x = -32
				M.dir = direction
				M.color = color_new
				animate(M, pixel_y = 32, time = 10, alpha= 175)
			if(EAST)
				effectLoc = locate(user.x + 1, user.y, user.z)
				/*
				I = new(src, effectLoc)
				I.dir = direction
				animate(I, pixel_x = 96, time = 6, alpha= 0)
				*/
				M = new/obj/meleeeffect/spear(effectLoc)
				M.pixel_y = -32
				M.dir = direction
				M.color = color_new
				animate(M, pixel_x = 32, time = 10, alpha= 175)
			if(SOUTH)
				effectLoc = locate(user.x, user.y - 3, user.z)
				/*
				I = new(src, locate(user.x, user.y - 1, user.z))
				I.dir = direction
				animate(I, pixel_y = -96, time = 6, alpha= 0)
				*/
				M = new/obj/meleeeffect/spear(effectLoc)
				M.pixel_x = -32
				M.dir = direction
				M.color = color_new
				animate(M, pixel_y = -32, time = 10, alpha= 175)
			if(WEST)
				effectLoc = locate(user.x - 3, user.y, user.z)
				/*
				I = new(src, locate(user.x - 1, user.y, user.z))
				I.dir = direction
				animate(I, pixel_x = -96, time = 6, alpha= 0)
				*/
				M = new/obj/meleeeffect/spear(effectLoc)
				M.pixel_y = -32
				M.dir = direction
				M.color = color_new
				animate(M, pixel_x = -32, time = 10, alpha= 175)

/obj/item/experimental/melee/sabre
	name = "Energy sabre"
	desc = ""
	force = 20
	color = "#3399ff"
	hitsound = 'sound/impact_sounds/Energy_Hit_1.ogg'

	getAffectedTiles(var/mob/user, var/atom/target, var/direction)
		var/list/affected = list()
		switch(direction)
			if(NORTH)
				affected += locate(user.x, user.y+1, user.z)
				affected += locate(user.x-1, user.y+1, user.z)
				affected += locate(user.x+1, user.y+1, user.z)
			if(EAST)
				affected += locate(user.x+1, user.y, user.z)
				affected += locate(user.x+1, user.y+1, user.z)
				affected += locate(user.x+1, user.y-1, user.z)
			if(SOUTH)
				affected += locate(user.x, user.y-1, user.z)
				affected += locate(user.x+1, user.y-1, user.z)
				affected += locate(user.x-1, user.y-1, user.z)
			if(WEST)
				affected += locate(user.x-1, user.y, user.z)
				affected += locate(user.x-1, user.y+1, user.z)
				affected += locate(user.x-1, user.y-1, user.z)
		return affected

	showEffect(var/mob/user, var/atom/target, var/direction)
		var/partred   = GetRedPart(src.color) / 255
		var/partgreen = GetGreenPart(src.color) / 255
		var/partblue  = GetBluePart(src.color) / 255

		var/color_new = list(partred*2.5,0.30,0.30, 0.30,partgreen*2.5,0.30, 0.30,0.30,partblue*2.5, 0,0,0)
		var/atom/effectLoc = null
		var/obj/meleeeffect/M
		switch(direction)
			if(NORTH)
				effectLoc = locate(user.x, user.y + 1, user.z)
				M = new/obj/meleeeffect(effectLoc)
				M.pixel_x = -32
				M.dir = direction
				M.color = color_new
			if(EAST)
				effectLoc = locate(user.x + 1, user.y, user.z)
				M = new/obj/meleeeffect(effectLoc)
				M.pixel_y = -32
				M.dir = direction
				M.color = color_new
			if(SOUTH)
				effectLoc = locate(user.x, user.y - 3, user.z)
				M = new/obj/meleeeffect(effectLoc)
				M.pixel_x = -32
				M.dir = direction
				M.color = color_new
			if(WEST)
				effectLoc = locate(user.x - 3, user.y, user.z)
				M = new/obj/meleeeffect(effectLoc)
				M.pixel_y = -32
				M.dir = direction
				M.color = color_new

/obj/floorpillstatue
	name = "Statue of Dr.Floorpills"
	desc = "A statue of the most radioactive man alive. Technically alive. Sort of."
	var/broken = 0
	icon ='icons/obj/objects.dmi'
	icon_state = "statuefloorpills"
	density = 1

	New()
		setMaterial(getMaterial("slag"))
		name = "Statue of Dr.Floorpills"

	attack_hand(mob/user as mob)
		boutput(user, "[src] feels oddly warm ...")
		user.changeStatus("radiation", 50)
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if(prob(8) && (!broken))
			for(var/i=0, i<5, i++)
				new/obj/item/material_piece/slag(src.loc)

			src.visible_message("<span class='alert'><B>[src] breaks into pieces!</B></span>")
			icon_state = "statuefloorpills0"

			broken = 1

		return ..()

/proc/mass_proc_arg()
	var/type = text2path(input(usr,"Type", "", "/obj"))
	var/procpath = text2path(input(usr,"ProcPath", "", "/proc"))
	var/argn = text2num(input(usr,"NumArgs", "", 1))

	var/list/argslist = list()
	for(var/i=0;i<argn;i++)
		var/argname = input(usr,"ArgName", "", "")
		var/argtype = input(usr, "ArgType") in list ("text", "num", "*this*")
		var/argval = null
		switch(argtype)
			if("text")
				argval = input(usr, "text", "", "")
			if("num")
				argval = text2num(input(usr, "num", "", 1))
			if("*this*")
				argval = "*this*"
		argslist[argname] = argval

	var/list/paths = list()
	paths = typesof(type)

	for(var/atom/X in world)
		if(paths.Find(X.type))
			var/list/argcopy = argslist.Copy()
			for(var/r in argcopy)
				if(argcopy[r] == "*this*")
					argcopy[r] = X
			call(procpath)(arglist(argcopy))

/datum/admins/proc/pixelexplosion()
	set category = "Debug"
	set name = "Pixel animation mode"
	set desc="Enter pixel animation mode"
	alert("Due to me being a lazy fuck you have to close & reopen your client to exit this mode. ITS A DEBUG THING OKAY")
	pixelmagic()

/datum/targetable/pixelpicker
	target_anything = 1
	targeted = 1
	max_range = 3000

	castcheck(var/mob/M)
		if (M.client && M.client.holder)
			return 1

	handleCast(var/atom/selected)
		dothepixelthing(selected)
		var/mob/M = usr
		var/datum/targetable/pixelpicker/R = new()
		M.targeting_ability = R
		M.update_cursor()
		return 1

/proc/pixelmagic()
	var/mob/M = usr
	var/datum/targetable/pixelpicker/R = new()
	M.targeting_ability = R
	M.update_cursor()

/proc/dothepixelthing(var/atom/A)
	var/list/pixels = list()
	var/icon/I = icon(A.icon, A.icon_state, A.dir)
	var/atom/movable/AT = A.loc
	playsound(AT, 'sound/effects/ExplosionFirey.ogg', 75, 1)
	for(var/y = 1, y <= I.Height(), y++)
		for(var/x = 1, x <= I.Width(), x++)
			var/color = I.GetPixel(x, y)
			if(color != null)
				var/actX = A.pixel_x + x - 1
				var/actY = A.pixel_y + y - 1
				var/obj/apixel/P = unpool(/obj/apixel)
				P.loc = A.loc
				P.pixel_x = actX
				P.pixel_y = actY
				P.color = color
				P.layer = 15
				animate_explode_pixel(P)
				pixels += P

	qdel(A)
	SPAWN_DBG(7 SECONDS)
		for(var/datum/D in pixels)
			pool(D)

	return

/obj/apixel
	name = ""
	desc = "this is a single pixel. wow."
	icon = 'icons/effects/1x1.dmi'
	icon_state = "pixel"
	anchored = 1
	density = 0
	opacity = 0

	unpooled()
		color = "#ffffff"
		pixel_x = 0
		pixel_y = 0
		alpha = 255
		transform = matrix()
		..()

/obj/item/craftedmelee/spear
	name = "spear"
	desc = "it's an improvised spear."
	icon = null

	New()
		..()
		src.setItemSpecial(/datum/item_special/rangestab)
		BLOCK_ROD

	rebuild()
		..()
		name = "[core.name]-[head.name] spear"
		desc = "It's an improvised spear. The handle is made from \a [core.name] and the head is \a [head.name]."
		//literally turning the used items into the parts of the spear. Im not sure what i will use this for.
		core.icon = icon('icons/obj/crafting.dmi',"spearbody")
		head.icon = icon('icons/obj/crafting.dmi',"spearhead")

		core.pixel_x = 0
		core.pixel_y = 0

		head.pixel_x = 0
		head.pixel_y = 0

		src.overlays.Cut()
		src.overlays.Add(image(icon = core,loc = src, layer = HUD_LAYER+2)) //This will cause the item to draw above the ui even when its on the ground. That's crap
		src.overlays.Add(image(icon = head,loc = src, layer = HUD_LAYER+2)) //But if i don't set it the item disappears under the inventory slots because it's purely overlays. :gonk:

		src.setMaterial(head.material, appearance = 0, setname = 0)
		return

	attack(mob/M as mob, mob/user as mob) //TBI
		return ..(M,user)

/obj/item/craftedmelee
	name = "melee weapon"
	desc = "this appears to be an improvised melee weapon."
	var/obj/item/core = null
	var/obj/item/head = null

	proc/rebuild() //will rebuild the icon and properties of the weapon based on its materials.
		return

/obj/item/craftedcrap
	name = "???"
	real_name = "???"
	desc = "this appears to be a taped-together mess of random crap."
	var/obj/item/item1 = null
	var/obj/item/item2 = null

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name][name_suffix(null, 1)]"

	proc/rebuild() //will rebuild the icon and properties of the weapon based on its materials.
		var/icon/crapicon = icon(item1.icon, item1.icon_state)
		crapicon.Blend(icon(item2.icon, item2.icon_state), ICON_OVERLAY)
		icon = crapicon
		setTexture(pick("tape1", "tape2"), ICON_OVERLAY , "tape")
		var/part1 = copytext(item1.name, 1, round(length(item1.name) / 2))
		var/part2 = copytext(item2.name, round(length(item2.name) / 2), 0)
		name = "[part1][part2]"
		real_name = name
		UpdateName()
		desc = "Someone taped together \a [item1.name] and \a [item2.name]. Great."
		return

	attack(mob/M as mob, mob/user as mob, def_zone)
		if(!item1 || !item2)
			src.fall_apart()
			return

		var/r = rand(0,100)

		if (r <= 70)
			if(r < 35)
				return item1.attack(M, user, def_zone)
			else
				return item2.attack(M, user, def_zone)
		else
			if(r < 90)
				SPAWN_DBG(0)
					item1.attack(M, user, def_zone)
					item2.attack(M, user, def_zone)
				return
			else
				src.fall_apart(user)
				return

	attack_self(mob/user as mob)
		if(!item1 || !item2)
			src.fall_apart()
			return

		var/r = rand(0,100)

		if (r <= 60)
			if(r < 30)
				return item1.attack_self(user)
			else
				return item2.attack_self(user)
		else
			if(r <= 80)
				SPAWN_DBG(0)
					item1.attack_self(user)
					item2.attack_self(user)
				return
			else
				src.fall_apart(user)
				return

	proc/fall_apart(var/mob/holder)
		boutput(holder,"[src] bursts apart in your hand!")
		if (prob(70) && item1)
			holder.attackby(item1, holder)
		if (prob(70) && item2)
			holder.attackby(item2, holder)
		if (item1)
			item1.set_loc(get_turf(src))
		if (item2)
			item2.set_loc(get_turf(src))
		qdel(src)


/proc/makeshittyweapon()
	var/path1
	var/path2
	var/sel1 = alert("Select item 1 type",,"Random","Enter Path")
	switch(sel1)
		if("Random")
			path1 = pick(typesof(/obj/item))
		else
			path1 = text2path(input(usr,"Enter Path:","path","/obj/item") as text)

	var/sel2 = alert("Select item 2 type",,"Random","Enter Path")
	switch(sel2)
		if("Random")
			path2 = pick(typesof(/obj/item))
		else
			path2 = text2path(input(usr,"Enter Path:","path","/obj/item") as text)

	if(!ispath(path1) || !ispath(path2)) return

	var/obj/item/item1 = new path1(usr.loc)
	var/obj/item/item2 = new path2(usr.loc)
	var/obj/item/craftedcrap/tube = new/obj/item/craftedcrap(usr.loc)
	tube.item1 = item1
	tube.item2 = item2
	item1.set_loc(tube)
	item2.set_loc(tube)
	tube.rebuild()
	return tube

/obj/item/ghostboard
	name = "Ouija board"
	desc = "A wooden board that allows for communication with spirits and such things. Or that's what the company that makes them claims, at least."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "lboard"
	inhand_image_icon = 'icons/mob/inhand/hand_books.dmi'
	item_state = "ouijaboard"
	w_class = 3.0
	var/ready = 1
	var/list/users = list()
	var/use_delay = 30

	New()
		. = ..()
		START_TRACKING
		BLOCK_BOOK

	disposing()
		. = ..()
		STOP_TRACKING

	Click(location,control,params)
		if(isobserver(usr) || iswraith(usr))

			if(!users.Find(usr))
				users[usr] = 0

			if((world.time - users[usr]) >= use_delay)
				var/list/words = list()
				for(var/i=0, i<rand(5, 10), i++)
					var/picked = pick(strings("ouija_board.txt", "ouija_board_words"))
					if(!words.Find(picked)) words.Add(picked)

				if(words.len)
					var/selected = input(usr, "Select a word:", src.name) as null|anything in words
					if(!selected) return

					if((world.time - users[usr]) < use_delay)
						usr.show_text("Please wait a moment before using the board again.", "red")
						return

					users[usr] = world.time

					SPAWN_DBG(0)
						if(src && selected)
							animate_float(src, 1, 5, 1)
							for (var/mob/O in observersviewers(7, src))
								O.show_message("<B><span class='notice'>The board spells out a message ... \"[selected]\"</span></B>", 1)
#ifdef HALLOWEEN
							if (istype(usr.abilityHolder, /datum/abilityHolder/ghost_observer))
								var/datum/abilityHolder/ghost_observer/GH = usr.abilityHolder
								GH.change_points(50)
#endif
			else
				usr.show_text("Please wait a moment before using the board again.", "red")
		else
			return ..(location,control,params)

/proc/fartes()
	for(var/imageToLoad in flist("images/"))
		usr << browse_rsc(file("images/[imageToLoad]"))
		boutput(world, "[imageToLoad] - [file("images/[imageToLoad]")]")
	return

/obj/largetest
	name = "test"
	desc = ""
	anchored = 1
	density = 1
	opacity = 0
	icon = 'icons/misc/512x512.dmi'
	icon_state = "0,0"

/obj/peninscription
	name = "mysterious inscription"
	desc = "It's some form of inscription. It reads 'nij ud-bi-ta la-ba-jal-la: ki-sikil tur ur dam-ma-na-ka ce nu-ub-dur-re'. There is a small pictogram below it."
	anchored = 1
	density = 0
	opacity = 0
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "pen"

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W,/obj/item/device/key))
			boutput(user, "[W] disappears suddenly as you bring it close to the inscription ... huh")
			del(W)
		if(istype(W,/obj/item/pen))
			boutput(user, "A terrible noise fills the air as the inscription seemingly rejects [W].")
			playsound(src.loc, "hellhorn_12.ogg", 100, 1)
		return

/obj/burning_barrel
	name = "burning barrel"
	desc = "cozy."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "barrel1"
	density = 1
	anchored = 1
	opacity = 0

	var/datum/particleSystem/barrelSmoke/particles
	var/datum/light/light

	New()
		particles = particleMaster.SpawnSystem(new /datum/particleSystem/barrelSmoke(src))
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(1)
		light.set_color(0.5, 0.3, 0)
		light.enable()

		..()

	disposing()
		particleMaster.RemoveSystem(/datum/particleSystem/barrelSmoke, src)
		..()

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/clothing/mask/cigarette))
			var/obj/item/clothing/mask/cigarette/C = W
			if(!C.on)
				C.light(user, "<span class='alert'>[user] lights the [C] with [src]. That seems appropriate.</span>")

/*

/obj/hh_portal_exit
	icon = 'icons/misc/exploration.dmi'
	icon_state = "riftexit"
	name = "???"
	desc = ""
	anchored = 1
	density = 1
	opacity = 0

	Bumped(atom/movable/AM)
		if(!ismob(AM)) return
		var/mob/M = AM

		if(M.adventure_variables.hh_energy < 3)
			boutput(M, "<span class='alert'>You can't seem to pass through the energy ... </span>")
			return

		var/mob/dead/hhghost/H = new(AM.loc)
		H.client = M.client
		H.original = M
		M.set_loc(H)

		AM = H

		var/area/srcar = AM.loc.loc
		srcar.Exited(AM)

		var/obj/target = locate(/obj/landmark/hh_exit)

		if (!istype(target))
			return

		var/turf/trg_turf = target.loc

		var/area/trgar = trg_turf.loc
		trgar.Entered(AM, AM.loc)

		AM.set_loc(trg_turf)

/obj/hh_portal_entry
	icon = 'icons/misc/exploration.dmi'
	icon_state = "atear"
	name = "???"
	desc = ""
	anchored = 1
	density = 1
	opacity = 0

	Bumped(atom/movable/AM)
		if(!AM.reagents) return
		if(!ismob(AM)) return

		if(AM.reagents.has_reagent("anima") && !AM.reagents.has_reagent("anima", 10))
			boutput(AM, "<span class='alert'>The portal briefly glows as you get near but quickly dulls again. It seems like you have done SOMETHING correctly but it isn't quite enough.</span>")
			return

		if(!AM.reagents.has_reagent("anima"))
			boutput(AM, "<span class='alert'>The strange energy in front of you becomes solid as you approach ...</span>")
			return

		AM.reagents.del_reagent("anima")

		var/area/srcar = AM.loc.loc
		srcar.Exited(AM)

		var/obj/target = locate(/obj/landmark/hh_entry)

		if (!istype(target))
			return

		var/turf/trg_turf = target.loc

		var/area/trgar = trg_turf.loc
		trgar.Entered(AM, AM.loc)

		AM.set_loc(trg_turf)

		return

/obj/landmark/hh_exit
	name = "hh_exit"
	//tag = "hh_exit"

/obj/landmark/hh_entry
	name = "hh_entry"
	//tag = "hh_entry"

/obj/hh_sfrag
	name = "soul fragment"
	desc = "a small portion of someones life energies ..."
	icon = 'icons/misc/exploration.dmi'
	icon_state = "empty"
	anchored = 1
	density = 0
	opacity = 0
	invisibility = 100
	var/image/oimage = null
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

	New()
		oimage = image('icons/misc/exploration.dmi',src,"sfrag")
		orbicons.Add(oimage)
		return ..()

	disposing()
		orbicons.Remove(oimage)
		del(oimage)
		..()

	HasEntered(atom/A)
		if(!istype(A,/mob/dead/hhghost)) return
		var/mob/dead/hhghost/M = A
		M.adventure_variables.hh_soul += 1
		particleMaster.SpawnSystem(new /datum/particleSystem/elecburst(M))

		if(M.adventure_variables.hh_soul > 15)
			M.original.set_loc(src.loc)
			M.original.client = M.client
			del(M)

		del(src)
		return

/obj/hh_energyorb
	name = "scintilating energy"
	desc = "..."
	icon = 'icons/misc/exploration.dmi'
	icon_state = "eorb"
	anchored = 1
	density = 0
	opacity = 0
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

	HasEntered(atom/A)
		if(!ismob(A) || !isliving(A)) return
		qdel(src)
		var/mob/living/M = A
		M.adventure_variables.hh_energy += 1
		particleMaster.SpawnSystem(new /datum/particleSystem/energysp(M))
		return

*/

/obj/decal/nothing
	name = "nothing"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "blank"
	anchored = 1
	density = 0
	opacity = 0
	plane = PLANE_LIGHTING - 1

/obj/decal/nothingplug
	name = "nothing"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "blank-plug"
	anchored = 1
	density = 0
	opacity = 0
	plane = PLANE_LIGHTING - 1

/obj/decal/hfireplug
	name = "fire"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "hfireplug"
	anchored = 1
	density = 0
	opacity = 0

/obj/decal/hfire
	name = "fire"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "hfire"
	anchored = 1
	density = 0
	opacity = 0

/obj/decal/tileswish
	name = "nothing"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "tileswish"
	anchored = 1
	density = 0
	opacity = 0

/obj/decal/swirlthing
	name = "vortex"
	desc = "a swirling blue vortex"
	icon = 'icons/effects/effects.dmi'
	icon_state = "swirlthing"
	anchored = 1
	density = 0
	opacity = 0

/obj/item/teslacannon
	desc = "An experimental piece of syndicate technology."
	name = "Tesla cannon"
	icon = 'icons/obj/items/gun.dmi'
	icon_state = "teslacannon"
	item_state = "gun"
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = 1.0
	var/firing = 0

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		shoot(target, user)
		return

	proc/shoot(var/atom/target, var/mob/user)
		if(firing) return
		firing = 1
		user.canmove = 0
		var/turf/current = get_turf(user)
		var/turf/trg_loc = get_turf(target)
		var/list/sounds = list('sound/effects/elec_bigzap.ogg','sound/effects/elec_bzzz.ogg','sound/effects/electric_shock.ogg')
		while(current != trg_loc)
			playsound(get_turf(user), pick(sounds), 15, 1)
			current = get_step(current, get_dir(current, trg_loc))
			user.dir = get_dir(user, current)
			var/obj/beam_dummy/B = showLine(get_turf(user), current, "lght", 5)
			var/list/affected = B.affected
			for(var/turf/T in affected)
				animate_flash_color_fill(T,"#aaddff",1,5)
				for(var/mob/M in T)
					M.changeStatus("weakened", 2 SECONDS)
					random_burn_damage(M, 10)

				if(istype(T, /turf/simulated/floor))
					if(!T:broken)
						if(T:burnt)
							T:break_tile()
						else
							T:burn_tile()
			SPAWN_DBG(0.6 SECONDS) qdel(B)
			sleep(0.3 SECONDS)
		sleep(0.1 SECONDS)

		user.canmove = 1
		firing = 0
		return


//Fix portal creation for areas and such.
//Test with explosion proc
/obj/proctrigger		  //Oh boy. This thing calls a proc of or on an object when an object enter it's tile. It's a bit difficult to explain, best not touch this.
	name = "ProcTrigger"
	desc = "If you see this and you're not an admin then that's sorta bad."
	density = 0
	anchored = 1
	opacity = 0
	invisibility = 100
	icon = 'icons/effects/ULIcons.dmi'
	icon_state = "7-3-0"
	var
		procName = null   //Name of the proc being called.
		procTarget = null //Owner of the proc being called.
		list/turf/procArgs = list()
		procCooldown = 0
		canTrigger = 1

	proc/copy_to(var/turf/T)
		if(!T) return
		var/obj/proctrigger/P = new/obj/proctrigger(T)
		P.procName = src.procName
		P.procTarget = src.procTarget
		P.procArgs = src.procArgs.Copy()
		P.procCooldown = src.procCooldown
		return

	MouseDrop(over_object,src_location,over_location,src_control,over_control,params)
		var/turf/trgTurf = get_turf(over_object)
		if(istype(trgTurf))
			switch(alert("Do you want to create a copy of the trigger on this tile?",,"Yes","No"))
				if("Yes")
					copy_to(trgTurf)
					boutput(usr, "<span class='success'>*** All done ***</span>")
				if("No")
					return
		return

	Crossed(atom/movable/O)
		if(!canTrigger) return
		canTrigger = 0
		SPAWN_DBG(procCooldown) canTrigger = 1

		if(length(procName))
			var/list/modList = list()

			for(var/x in procArgs)
				if(x == "***trigger***")
					modList += O
				else
					modList += x

			if (procTarget)
				if(procTarget == "***trigger***")
					if(hascall(O, procName))
						call(O,procName)(arglist(modList))
				else
					if(hascall(procTarget, procName))
						call(procTarget,procName)(arglist(modList))
			else
				call(procName)(arglist(modList))
		return

	Click()
		if(!usr.client.holder) return //basic admin check
		var/target = null

		switch(alert("Proc owned by obj?",,"Yes","No"))
			if("Yes")
				switch(alert("Proc owned by triggering object?",,"Yes","No"))
					if("Yes")
						target = "***trigger***"
					if("No")
						target = input("Select target:","Target",null) as obj|mob|area|turf in world
			if("No")
				target = null

		var/procname = input("Procpath","path:", null) as text
		var/argnum = input("Number of arguments:","Number", 0) as num
		var/list/listargs = list()

		for(var/i=0, i<argnum, i++)
			var/class = input("Type of Argument #[i]","Variable Type", null) in list("text","num","type","reference","mob reference", "icon","file", "*triggering object*","cancel")
			switch(class)
				if("-cancel-")
					return

				if("*triggering object*")
					listargs += "***trigger***"

				if("text")
					listargs += input("Enter new text:","Text",null) as text

				if("num")
					listargs += input("Enter new number:","Num", 0) as num

				if("type")
					listargs += input("Enter type:","Type", null) in typesof(/obj,/mob,/area,/turf)

				if("reference")
					listargs += input("Select reference:","Reference", null) as mob|obj|turf|area in world

				if("mob reference")
					listargs += input("Select reference:","Reference", null) as mob in world

				if("file")
					listargs += input("Pick file:","File", null) as file

				if("icon")
					listargs += input("Pick icon:","Icon", null) as icon

		procArgs = listargs
		procName = procname
		procTarget = target
		boutput(usr, "<span class='success'>*** All done ***</span>")

		return

	ex_act()
		return

/obj/objspawner			   //Thing that continously spawns objects. For event's or something. I wouldn't use this on the actual map. It's not very efficient.
	name = "ObjSpawner"
	desc = "If you see this and you're not an admin then that's sorta bad."
	icon = 'icons/misc/mark.dmi'
	icon_state = "rup"
	density = 0
	anchored = 1
	opacity = 0
	invisibility = 100
	var/spawn_rate = 100 	   //Time before a new object spaws after the previous is gone.
	var/spawn_check_rate = 10  //How often we check if we need to spawn something.
	var/spawn_type = null	   //Type to spawn

	proc/runIt()
		if(istext(spawn_type))
			spawn_type = text2path(spawn_type)
		if(ispath(spawn_type))
			if(!(locate(spawn_type) in src.loc))
				sleep(spawn_rate)
				new spawn_type(src.loc)
		SPAWN_DBG(spawn_check_rate)
			runIt()
		return

	Click()
		if(!usr.client.holder) return //basic admin check
		var/nSpawn = input(usr, "Select spawn type") in typesof(/obj)
		var/nCheck = input(usr, "Spawn check delay") as num
		var/nRate = input(usr, "Spawn check delay") as num
		if(nSpawn && nCheck && nRate)
			spawn_rate = nRate
			spawn_check_rate = nCheck
			spawn_type = nSpawn
			boutput(usr, "<span class='success'>*** All done ***</span>")
		return

	New()
		SPAWN_DBG(0) runIt()
		return ..()

	ex_act()
		return

/proc/gobuzz()
	if(buzztile)
		usr.loc = buzztile
	return

/obj/item/beamtest
	desc = "beamtest thingamobob"
	name = "beamtest thingamobob"
	icon = 'icons/obj/items/alchemy.dmi'
	icon_state = "pstone"
	item_state = "injector"
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = 1.0

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		var/obj/beam_dummy/B = showLine(get_turf(src), get_turf(target), "beam", 10)
		sleep(3 SECONDS)
		qdel(B)
		return

/obj/beam_dummy
	name = "beam"
	desc = ""
	icon = 'icons/effects/lines.dmi'
	icon_state = "lght"
	density = 0
	anchored = 1
	opacity = 0
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	pixel_y = -16
	var/list/affected = list() //List of crossed tiles.
	var/origin_angle = -1
	var/atom/origin = null
	var/atom/target = null

/obj/fireworksbox
	name = "Box of Fireworks"
	desc = "The Label simply reads : \"Firwerks fun is having total family. Made in Spacechina\""
	density = 0
	anchored = 0
	opacity = 0
	icon = 'icons/obj/objects.dmi'
	icon_state = "fireworksbox"
	var/fireworking = 0

	attack_hand(mob/user as mob)
		if(fireworking) return
		fireworking = 1
		boutput(user, "<span class='alert'>The fireworks go off as soon as you touch the box. This is some high quality stuff.</span>")
		anchored = 1

		SPAWN_DBG(0)
			for(var/i=0, i<rand(30,40), i++)
				particleMaster.SpawnSystem(new /datum/particleSystem/fireworks(src.loc))
				sleep(rand(2, 15))

			for(var/mob/O in oviewers(world.view, src))
				O.show_message("<span class='notice'>The box of fireworks magically disappears.</span>", 1)

			qdel(src)
		return

/obj/candle_light_2spoopy
	icon = 'icons/obj/items/alchemy.dmi'
	icon_state = "candle"
	name = "spooky candle"
	desc = "It's a big candle. It's also floating."
	density = 0
	anchored = 1
	opacity = 0
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.set_brightness(0.7)
		light.set_color(0.5, 0.3, 0)
		light.attach(src)
		light.enable()

		var/spoopydegrees = rand(5, 20)

		SPAWN_DBG(rand(1,10))
			animate(src, pixel_y = 32, transform = matrix(spoopydegrees, MATRIX_ROTATE), time = 20, loop = -1, easing = SINE_EASING)
			animate(pixel_y = 0, transform = matrix(-1 * spoopydegrees, MATRIX_ROTATE), time = 20, loop = -1, easing = SINE_EASING)


//Really sorry about the shitty code below. I couldn't be arsed to do it properly.
/obj/candle_light
	icon = 'icons/obj/items/alchemy.dmi'
	icon_state = "candle"
	name = "candle"
	desc = "It's a big candle"
	density = 0
	anchored = 1
	opacity = 0

	var/datum/light/point/light

	New()
		..()
		light = new
		light.set_brightness(0.7)
		light.set_color(1, 0.6, 0)
		light.set_height(0.75)
		light.attach(src)
		light.enable()

//alchemy circle and related to biodome.dm

/obj/line_obj/elec
	name = "electricity"
	desc = ""
	anchored = 1
	density = 0
	opacity = 0

/obj/elec_trg_dummy
	name = ""
	desc = ""
	anchored = 1
	density = 0
	opacity = 0
	invisibility = 99
/*
/obj/item/rpg_rocket_shuttle
	name = "MPRT rocket"
	desc = "A rocket-propelled grenade with a HEAT warhead."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "rpg_rocket"
	item_state = "chips"
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 5.0
	flags = FPRINT | TABLEPASS | CONDUCT
	var/state = 0
	var/yo = null
	var/xo = null
	var/current = null

	New()
		..()

	proc
		explode()
			var/turf/T = get_turf(src.loc)

			if(T)
				//explosion(src, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, var/lagreducer = 0)
				explosion(src, T, -1, -1, 1, 2)
			qdel(src)

	process()
		if ((!( src.current ) || src.loc == src.current))
			src.current = locate(min(max(src.x + src.xo, 1), world.maxx), min(max(src.y + src.yo, 1), world.maxy), src.z)
		if ((src.x == 1 || src.x == world.maxx || src.y == 1 || src.y == world.maxy))
			//SN src = null
			qdel(src)
			return
		step_towards(src, src.current)
		SPAWN_DBG( 1 )
			process()
			return
		return

	Bump(atom/movable/AM as mob|obj)
		if(!state)
			..()
			return
		explode()

/obj/shuttle_cannon
	name = "Shuttle Cannon"
	desc = "Pew Pew"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "shuttlecannonthing"
	anchored = 1
	density = 1
	var/ready = 1

	verb/enter()
		set src in view(1)
		set name = "Enter"

		if(src.contents.len)
			boutput(usr, "Someone is already using this.")
			return

		usr.client.view = 11
		usr.see_in_dark = 11

		usr.set_loc(src)

	verb/exit()
		set src in view(1)
		set name = "Exit"

		if(!(usr in src.contents))
			boutput(usr, "You are not using this.")
			return

		usr.client.view = world.view
		usr.see_in_dark = initial(usr.see_in_dark)

		usr.set_loc(src.loc)

	relaymove(mob/user, direction)
		if(!ready) return
		ready = 0
		if(direction == turn(src.dir, 180))
			ready = 1
			return
		var/turf/fire_target_tile = get_step(get_step(get_step(get_step(src, src.dir), src.dir), direction), direction)

		SPAWN_DBG(1 DECI SECOND)
			playsound(src, "sound/weapons/rocket.ogg", 50, 1)

			var/obj/item/rpg_rocket/R = new

			R.set_loc(get_step(src, src.dir))
			R.set_density(1)
			R.state = 1
			R.current = fire_target_tile
			R.yo = fire_target_tile.y - src.y
			R.xo = fire_target_tile.x - src.x

			R.process()

		SPAWN_DBG(2.5 SECONDS) ready = 1
*/

/obj/movable_area_controller
	name = "controller"
	desc = "Don't move this thing or you're gonna have a bad time."
	icon = 'icons/obj/objects.dmi'
	icon_state = "stool"
	anchored = 1
	density = 0
	var/areasize = ""
	var/moving = 0
	var/usable = 0

	verb/setup_area()
		set src in view(1)
		set name = "Setup"
		src.verbs -= /obj/movable_area_controller/verb/setup_area

		var/width = input(usr,"Width:","Setup",7) as num
		var/height = input(usr,"Height:","Setup",5) as num

		areasize = "[width]x[height]"

		for(var/turf/T in range(areasize, src))
			if(!isturf(T)) continue
			new/turf/unsimulated/floor(T)

		usable = 1

	verb/enter()
		set src in view(1)
		set name = "Enter"

		if(src.contents.len)
			boutput(usr, "Someone is already using this.")
			return

		usr.client.view = 12
		usr.see_in_dark = 12

		src.overlays += usr
		usr.set_loc(src)

	verb/exit()
		set src in view(1)
		set name = "Exit"

		if(!(usr in src.contents))
			boutput(usr, "You are not using this.")
			return

		usr.client.view = world.view
		usr.see_in_dark = initial(usr.see_in_dark)

		src.overlays.Cut()
		usr.set_loc(src.loc)

	relaymove(mob/user, direction)
		if(moving || !usable) return
		moving = 1

		var/turf/new_loc = get_step(src, direction)

		var/list/oldareaturfs = new/list()
		var/list/newareaturfs = new/list()

		var/list/objects_to_move = new/list()

		for(var/turf/T in range(areasize, src))
			if(!isturf(T)) continue
			oldareaturfs += T
			for(var/atom/movable/A in T)
				objects_to_move += A

		for(var/turf/T in range(areasize, new_loc))
			if(!isturf(T)) continue
			newareaturfs += T

		if(newareaturfs.len < oldareaturfs.len) //Out of bounds. Fucking byond.
			moving = 0
			return

		//Oh man. Dont ask what im doing here. It's Craaaazy
		var/list/commonturfs = oldareaturfs & newareaturfs

		var/list/newturfs = newareaturfs ^ commonturfs
		var/list/discardedturfs = oldareaturfs ^ commonturfs

		for(var/turf/T in newturfs)
			if(!movable_area_check(T))
				moving = 0
				return

		for(var/turf/T in newturfs)
			T.movable_area_prev_type = T.type
			for(var/atom/movable/A in T)
				A.set_loc(get_step(A.loc, direction))

		for(var/turf/T in newareaturfs)
			if(!isturf(T)) continue
			var/turf/prev_turf = get_step(T, turn(direction, 180))
			T.movable_area_next_type = prev_turf.type

		for(var/turf/T in newareaturfs)
			if(!isturf(T)) continue

			var/oldtype = T.movable_area_prev_type

			var/turf/tnew = new T.movable_area_next_type (T)

			tnew.movable_area_prev_type = oldtype

		for(var/turf/T in discardedturfs)
			if(!isturf(T)) continue
			if(T.movable_area_prev_type != null)
				new T.movable_area_prev_type (T)
			else
				new/turf/space(T)

		for(var/atom/movable/A in objects_to_move)
			A.animate_movement = 0
			A.set_loc(get_step(A.loc, direction))

		moving = 0

/proc/infestation_custom()
	var/turf/T = get_turf(usr)
	var/typepathstr = input(usr, "Typepath:")
	var/num_spread = input(usr, "Max spreads (-1 for infinite):") as num
	var/num_delay = input(usr, "Delay between spread in sec:") as num
	var/num_gens = input(usr, "Max Generations per spawn (-1 for infinite):") as num
	var/typepath = text2path(typepathstr)

	if(!ispath(typepath)) return

	var/atom/A = new typepath (T)

	var/list/active_spread = new/list()

	active_spread += A
	active_spread[A] = num_gens

	SPAWN_DBG(0)
		while(num_spread > 0 || num_spread == -1)
			for(var/atom/curr in active_spread)
				var/can_spread = null
				for(var/dir in cardinal)
					var/atom/next = get_turf(get_step(curr,dir))
					if(is_free(next) && !istype(next, typepath) && !locate(typepath) in next)
						can_spread = next
				if(can_spread == null)
					if(active_spread[curr] > 0 || active_spread[curr] == -1)
						if(active_spread[curr] > 0) active_spread[curr]--
					else
						active_spread -= curr
				else
					var/atom/newspawn = new typepath (can_spread)
					active_spread += newspawn
					active_spread[newspawn] = num_gens
			sleep(10 * num_delay)
			if(num_spread > 0) num_spread--
			LAGCHECK(LAG_LOW)


/proc/is_free(var/atom/A)
	if(!A) return
	if(A.density) return 0
	for(var/atom/curr in A)
		if(curr.density) return 0
	if(istype(A, /turf/space)) return 0
	return 1

/obj/dfissure_to
	name = "dimensional fissure"
	desc = "a rip in time and space"
	opacity = 0
	density = 1
	anchored = 1
	icon = 'icons/obj/adventurezones/void.dmi'
	icon_state = "fissure"

	Bumped(atom/movable/AM)
		var/area/srcar = AM.loc.loc
		srcar.Exited(AM)

		var/obj/source = locate(/obj/dfissure_from)
		if (!istype(source))
			qdel(src)
			return
		var/turf/trg = source.loc

		var/area/trgar = trg.loc
		trgar.Entered(AM, AM.loc)

		AM.set_loc(trg)

/obj/dfissure_from
	name = "dimensional fissure"
	desc = "a rip in time and space"
	opacity = 0
	density = 1
	anchored = 1
	icon = 'icons/obj/adventurezones/void.dmi'
	icon_state = "fissure"

	Bumped(atom/movable/AM)
		var/area/srcar = AM.loc.loc
		srcar.Exited(AM)

		var/obj/source = locate(/obj/dfissure_to)
		if (!istype(source))
			boutput(AM, "<span class='combat'>You try to squeeze into the hole in space-time, but it's really dense right now!  Weird!  Who knew holes in reality could be so strange?!</span>")
			return
		var/turf/trg = source.loc

		var/area/trgar = trg.loc
		trgar.Entered(AM, AM.loc)

		AM.set_loc(trg)

//void turfs to void.dm

/proc/zombies()
	var/list/eligible = new/list()

	for(var/mob/living/carbon/human/H in mobs)
		if(H.z == 1 && !isdead(H) && H.client)
			eligible.Add(H)

	var/mob/living/carbon/human/picked1
	if(eligible.len > 0)
		picked1 = pick(eligible)
		eligible -= picked1

	var/mob/living/carbon/human/picked2
	if(eligible.len > 0)
		picked2 = pick(eligible)

	if(picked1)
		picked1.zombify()

	if(picked2)
		picked2.zombify()

	for(var/turf/T in wormholeturfs)
		if(prob(3))
			new/obj/item/plank(T)
			new/obj/item/plank(T)
		else if(prob(1) && prob(40))
			new/obj/item/gun/kinetic/spes(T)
			new/obj/item/ammo/bullets/a12(T)
			new/obj/item/ammo/bullets/a12(T)

		else if(prob(1) && prob(40))
			new/obj/item/gun/kinetic/flaregun(T)
			new/obj/item/ammo/bullets/flare(T)
			new/obj/item/ammo/bullets/flare(T)

/mob/living/carbon/human/proc/zombify()
	var/datum/ailment_data/disease/ZOM = contract_disease(/datum/ailment/disease/necrotic_degeneration, null, null, 1)
	if (!istype(ZOM,/datum/ailment/disease/))
		return
	ZOM.stage = 5
	boutput(src, "<span class='alert'>########################################</span>")
	boutput(src, "<span class='alert'>You have turned into a zombie.</span>")
	boutput(src, "<span class='alert'>To infect other players, you must knock</span>")
	boutput(src, "<span class='alert'>them down and then attack them with your</span>")
	boutput(src, "<span class='alert'>bare hands and the harm intent.</span>")
	boutput(src, "<span class='alert'>########################################</span>")

/obj/item/boomerang
	name = "Boomerang"
	desc = "A Boomerang."
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "boomerang"

	density = 0
	opacity = 0
	anchored = 1
	contraband = 4

	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "boomerang"
	item_state = "boomerang"

	//throwforce = 10
	throw_range = 10
	throw_speed = 1
	throw_return = 1

	var/prob_clonk = 0

	New()
		..()
		BLOCK_LARGE

	throw_begin(atom/target)
		icon_state = "boomerang1"
		playsound(src.loc, "rustle", 50, 1)
		return ..(target)

	throw_impact(atom/hit_atom)
		icon_state = "boomerang"
		if(hit_atom == usr)
			if(prob(prob_clonk))
				var/mob/living/carbon/human/user = usr
				user.visible_message("<span class='alert'><B>[user] fumbles the catch and is clonked on the head!</B></span>")
				playsound(user.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
				user.changeStatus("stunned", 50)
				user.changeStatus("weakened", 3 SECONDS)
				user.changeStatus("paralysis", 2 SECONDS)
				user.force_laydown_standup()
			else
				src.attack_hand(usr)
			return
		else
			if(ishuman(hit_atom))
				var/mob/living/carbon/human/user = usr
				var/safari = (istype(user.w_uniform, /obj/item/clothing/under/gimmick/safari) && istype(user.head, /obj/item/clothing/head/safari))
				if(safari)
					var/mob/living/carbon/human/H = hit_atom
					H.changeStatus("stunned", 4 SECONDS)
					H.changeStatus("weakened", 2 SECONDS)
					H.force_laydown_standup()
					//H.paralysis++
					playsound(H.loc, "swing_hit", 50, 1)

				prob_clonk = min(prob_clonk + 5, 40)
				SPAWN_DBG(2 SECONDS)
					prob_clonk = max(prob_clonk - 5, 0)

		return ..(hit_atom)

/proc/mod_color(var/atom/A)
	set category = null
	set name = "Modify Icon"
	set popup_menu = 0
	var/list/options = list("Tint", "Invert Colors", "Change Alpha")
	var/input = input(usr,"Select mode:","Mode") in options
	switch(input)
		if("Tint")
			var/r = input(usr,"Enter Value:","RED") as num
			if (!r)
				return

			var/g = input(usr,"Enter Value:","GREEN") as num
			if (!g)
				return

			var/b = input(usr,"Enter Value:","BLUE") as num
			if (!b)
				return

			A.color = rgb(r,g,b)

		if("Invert Colors")
			var/icon/newicon = icon(A.icon)
			newicon.MapColors(-1,0,0, 0,-1,0, 0,0,-1, 1,1,1)
			A.icon = newicon

		if( "Change Alpha")
			var/a = input(usr,"Enter Value:","ALPHA (multiplicative 0-255)") as num
			if (a)
				A.alpha = a

/datum/targetable/portalpickerOrigin
	target_anything = 1
	targeted = 1
	max_range = 3000
	var/obj/fancyportal/P = null
	var/atom/target = null

	castcheck(var/mob/M)
		if (M.client && M.client.holder)
			return 1

	handleCast(var/atom/selected)
		var/alert = alert("Is the target '[selected]' ok?",,"Yes","No","Exit")
		if (alert == "Yes")
			P = new/obj/fancyportal(get_turf(selected))
			P.setTarget(target)
			var/targetThing = isturf(target) ? "" : "[target] in "
			targetThing += get_area(target)
			logTheThing("admin", usr, null, "created a portal at [showCoords(selected.x, selected.y, selected.z)] ([get_area(selected)]) pointing to [showCoords(target.x, target.y, target.z)] ([targetThing])")
			logTheThing("diary", usr, null, "created a portal at [selected.x], [selected.y], [selected.z] ([get_area(selected)]) pointing to [target.x], [target.y], [target.z] ([targetThing])", "admin")
			message_admins("[key_name(usr)] created a portal at [showCoords(selected.x, selected.y, selected.z)] ([get_area(selected)]) pointing to [showCoords(target.x, target.y, target.z)] ([targetThing])")
		else if (alert == "No")
			var/mob/M = usr
			if (istype(M))
				var/datum/targetable/portalpickerOrigin/R = new()
				M.targeting_ability = R
				M.update_cursor()
				R.target = selected
				return
		else
			return

/datum/targetable/portalpickerTarget
	target_anything = 1
	targeted = 1
	max_range = 3000

	castcheck(var/mob/M)
		if (M.client && M.client.holder)
			return 1

	handleCast(var/atom/selected)
		var/mob/M = usr
		if (istype(M))
			var/extra = isturf(selected) ? "" : "\n\nYou selected a non-turf and so people will teleport INSIDE the target. This may bug people out so be sure you want to do this."
			var/alert = alert("Is the target '[selected]' ok?[extra]",,"Yes","No","Exit")
			if (alert == "Yes")
				var/datum/targetable/portalpickerOrigin/R = new()
				alert("Click on where you want your portal to be placed",,"Ok")
				M.targeting_ability = R
				M.update_cursor()
				R.target = selected
				return
			else if (alert == "No")
				var/datum/targetable/portalpickerTarget/R = new()
				M.targeting_ability = R
				M.update_cursor()
			else
				return

/client/proc/create_portal()
	set category = null
	set name = "Create Portal"
	set popup_menu = 0

	admin_only

	var/mob/M = src.mob
	if (istype(M))
		alert("Click on where you want your portal to end up at",,"Ok")
		var/datum/targetable/portalpickerTarget/R = new()
		M.targeting_ability = R
		M.update_cursor()
		return

/obj/perm_portal
	icon = 'icons/misc/old_or_unused.dmi'
	icon_state = "portal1"
	anchored = 1
	density = 1
	opacity = 0
	var/atom/target = null
	var/target_tag = null
	var/datum/light/light

	New()
		..()
		light = new /datum/light/point
		light.set_color(0.3, 0.6, 0.8)
		light.set_brightness(0.5)
		light.attach(src)
		light.enable()
		SPAWN_DBG(0.6 SECONDS)
			if (target_tag)
				target = locate(target_tag)

	Bumped(atom/movable/AM)
		if(target && istype(target))
			AM.set_loc(target)
		else
			src.visible_message("<span style='color: red; font-weight: bold'>The portal collapses in on itself!</span>")
			var/obj/sparks = unpool(/obj/effects/sparks)
			sparks.set_loc(get_turf(src))
			SPAWN_DBG(2 SECONDS) if (sparks) pool(sparks)
			qdel(src)


////////////////////////////////////////////////////////////////////////////////////////
/* var/list/raisinlist = new/list()

/proc/for_no_raisin(var/mob/M, text)
	if(findtext(text,"for no raisin"))
		if(M.client)
			if(!(M.client in raisinlist) && isliving(M))
				boutput(M, "<span class='alert'>A raisin mysteriously materializes right next to your feet...</span>")
				new/obj/item/reagent_containers/food/snacks/raisin(get_turf(M))
				raisinlist += M.client
	return

/obj/item/reagent_containers/food/snacks/raisin
	name = "raisin"
	desc = "A single raisin..."
	icon_state = "raisin"
	amount = 1
	heal_amt = 5

	attack(mob/M as mob, mob/user as mob, def_zone)
		if(ishuman(M))
			if(M == user)
				M.nutrition += src.heal_amt * 10
				M.poo += 1
				src.heal(M)
				playsound(M.loc,"sound/items/eatfood.ogg", rand(10,50), 1)
				boutput(user, "<span class='alert'>You eat the raisin and shed a single tear as you realise that you now have no raisin.</span>")
				qdel(src)
				return 1
			else
				for(var/mob/O in viewers(world.view, user))
					O.show_message("<span class='alert'>[user] attempts to feed [M] [src].</span>", 1)
				if(!do_mob(user, M)) return
				for(var/mob/O in viewers(world.view, user))
					O.show_message("<span class='alert'>[user] feeds [M] [src].</span>", 1)
				src.amount--
				M.nutrition += src.heal_amt * 10
				M.poo += 1
				src.heal(M)
				playsound(M.loc, "sound/items/eatfood.ogg", rand(10,50), 1)
				boutput(user, "<span class='alert'>[M] eats the raisin.</span>")
				qdel(src)
				return 1
		return 0 */

/obj/fire_foam
	name = "Fire fighting foam"
	desc = "It's foam."
	opacity = 0
	density = 0
	anchored = 1
	icon = 'icons/effects/fire.dmi'
	icon_state = "foam"
	animate_movement = SLIDE_STEPS
	mouse_opacity = 0
	var/my_dir=1

	Move(NewLoc,Dir=0)
		..(NewLoc,Dir)
		src.dir = my_dir

	unpooled(var/poolname)
		..()
		SPAWN_DBG(1 DECI SECOND)
			var/atom/myloc = loc
			if(myloc && !istype(myloc,/turf/space))
				my_dir = pick(alldirs)
				src.dir = my_dir

/obj/shifting_wall
	name = "r wall"
	desc = ""
	opacity = 1
	density = 1
	anchored = 1

	icon = 'icons/turf/walls.dmi'
	icon_state = "r_wall"

	New()
		update()

	proc/update()
		var/list/possible = new/list()

		for(var/A in cardinal)
			var/turf/current = get_step(src,A)
			if(current.density) continue
			if(is_blocked_turf(current)) continue
			possible +=  current

		if(!possible.len)
			SPAWN_DBG(3 SECONDS) update()
			return

		var/turf/picked = pick(possible)
		if(src.loc.invisibility) src.loc.invisibility = 0
		src.set_loc(picked)
		SPAWN_DBG(0.5 SECONDS) picked.invisibility = 100

		SPAWN_DBG(rand(50,80)) update()

/obj/shifting_wall/sneaky

	var/sightrange = 8

	proc/find_suitable_tiles()
		var/list/possible = new/list()

		for(var/A in cardinal)
			var/turf/current = get_step(src,A)
			if(current.density) continue
			if(is_blocked_turf(current)) continue
			if(someone_can_see(current)) continue
			possible +=  current

		return possible

	proc/someone_can_see(var/atom/A)
		for(var/mob/living/L in view(sightrange,A))
			if(!L.sight_check(1)) continue
			if(A in view(sightrange,L)) return 1
		return 0

	proc/someone_can_see_me()
		for(var/mob/living/L in view(sightrange,src))
			if(L.sight_check(1)) continue
			if(src in view(sightrange,L)) return 1
		return 0

	update()
		if(someone_can_see_me()) //Award for the most readable code GOES TO THIS LINE.
			SPAWN_DBG(rand(50,80)) update()
			return

		var/list/possible = find_suitable_tiles()

		if(!possible.len)
			SPAWN_DBG(3 SECONDS) update()
			return

		var/turf/picked = pick(possible)
		if(src.loc.invisibility) src.loc.invisibility = 0
		if(src.loc.opacity) src.loc.opacity = 0

		src.set_loc(picked)

		SPAWN_DBG(0.5 SECONDS)
			picked.invisibility = 100
			picked.opacity = 1

		SPAWN_DBG(rand(50,80)) update()


/obj/pool
	name = "pool"
	density = 1
	anchored = 1
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pool"
	flags = FPRINT | ALWAYS_SOLID_FLUID | IS_PERSPECTIVE_FLUID
	event_handler_flags = USE_CANPASS

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if (mover && mover.throwing)
			return 1
		return ..()

/obj/pool/ladder
	name = "pool ladder"
	anchored = 1
	density = 0
	dir = 8
	icon = 'icons/obj/fluid.dmi'
	icon_state = "ladder"

/obj/pool/perspective
	name = "pool"
	density = 1
	anchored = 1
	icon = 'icons/obj/fluid.dmi'
	icon_state = "pool"

/obj/pool_springboard
	name = "springboard"
	density = 0
	anchored = 1
	layer = EFFECTS_LAYER_UNDER_2
	pixel_x = -16
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "springboard"
	var/in_use = 0
	var/suiciding = 0
	var/deadly = 0

	attackby(obj/item/W as obj, mob/user as mob)
		return attack_hand(user)

	MouseDrop_T(atom/target, mob/user)
		if (get_dist(user,src) < 1 && target == user)
			src.attack_hand(user)

	attack_hand(mob/user as mob)
		if(in_use)
			boutput(user, "<span class='alert'>Its already in use - wait a bit.</span>")
			return
		else
			in_use = 1
			user.transforming = 1
			var/range = pick(25;1,2,3)
			var/turf/target = src.loc
			for(var/i = 0, i<range, i++)
				if(!suiciding && !deadly) target = get_step(target,WEST)
				else target = get_step(target,EAST)
			if(!suiciding && !deadly) user.dir = WEST
			else user.dir = EAST
			user.pixel_y = 15
			user.layer = EFFECTS_LAYER_UNDER_1
			user.set_loc(src.loc)
			user.buckled = src
			sleep(0.3 SECONDS)
			user.pixel_x = -3
			sleep(0.3 SECONDS)
			user.pixel_x = -6
			sleep(0.3 SECONDS)
			user.pixel_x = -9
			sleep(0.3 SECONDS)
			user.pixel_x = -12
			playsound(user, "sound/effects/spring.ogg", 60, 1)
			sleep(0.3 SECONDS)
			user.pixel_y = 25
			sleep(0.5 SECONDS)
			user.pixel_y = 15
			playsound(user, "sound/effects/spring.ogg", 60, 1)
			sleep(0.5 SECONDS)
			user.pixel_y = 25
			user.start_chair_flip_targeting(extrarange = 2)
			sleep(0.5 SECONDS)
			user.pixel_y = 15
			playsound(user, "sound/effects/spring.ogg", 60, 1)
			sleep(0.5 SECONDS)
			user.pixel_y = 25
			playsound(user, "sound/effects/brrp.ogg", 15, 1)
			sleep(0.2 SECONDS)
			if(range == 1) boutput(user, "<span class='alert'>You slip...</span>")
			user.layer = MOB_LAYER
			user.buckled = null
			if (user.targeting_ability == user.chair_flip_ability) //we havent chair flipped, just do normal jump
				user.throw_at(target, 5, 1)
				user:changeStatus("weakened", 2 SECONDS)
			user.end_chair_flip_targeting()
			if(suiciding || deadly)
				src.visible_message("<span class='alert'><b>[user.name] dives headfirst at the [target.name]!</b></span>")
				SPAWN_DBG(0.3 SECONDS) //give them time to land
					if (user)
						user.TakeDamage("head", 200, 0)
						user.updatehealth()
						playsound(src.loc, "sound/impact_sounds/Generic_Snap_1.ogg", 50, 1)
			user.pixel_y = 0
			user.pixel_x = 0
			playsound(user, "sound/impact_sounds/Liquid_Hit_Big_1.ogg", 60, 1)
			in_use = 0
			suiciding = 0
			user.transforming = 0

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			return 0
		if (in_use)
			return 0
		suiciding = 1 //reset in attack_hand() at the same time as in_use
		attack_hand(user)

		SPAWN_DBG(50 SECONDS)
			if (src)
				src.suiciding = 0
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

//1.5 would be 50% slower, 2.0 would be 100% slower etc.
var/const/lag_average_size = 20			 //Number of samples the average is based on.

var/lag_string = "Yes"//"none"

var/average_tenth = 1
var/list/lag_list = new/list()

/proc/add_and_average(var/value)
	lag_list.Insert(1,value)
	if(lag_list.len > lag_average_size) lag_list.Cut(lag_average_size+1,0)
	var/tempnum = 0
	for(var/a in lag_list)
		tempnum += a
	if(lag_list.len >= lag_average_size) average_tenth = (tempnum / lag_list.len)

	switch( ((average_tenth * world.cpu) / 100) )
		if(0 to 0.100)
			lag_string = "Minimal"
		if(0.101 to 0.180)
			lag_string = "Normal"
		if(0.181 to 0.350)
			lag_string = "High"
		if(0.351 to 0.500)
			lag_string = "Very High"
		if(0.501 to INFINITY)
			lag_string = "Oh Sh*t"

/proc/lag_loop()
	var/before = world.timeofday
	sleep(0.1 SECONDS)
	add_and_average( (world.timeofday - before) )
	SPAWN_DBG(0.5 SECONDS) lag_loop()

/proc/get_lag_average()
	boutput(usr, "<span class='success'>[average_tenth] at [lag_list.len] samples.</span>")


/obj/mirror
	//Expect those to be laggy as fuck.
	name = "Mirror"
	desc = "Its a mirror."
	density = 0
	anchored = 1
	pixel_y = 32
	var/icon/base
	var/broken = 0
	var/health = 3
	var/list/spooky = new/list()
	var/spooked = 0
	var/spooking = 0
	event_handler_flags = USE_HASENTERED

	proc/hear_once(var/mob/M)
		if(broken) return
		if(!(M in spooky))
			spooky += M
			spooky[M] = 1
		else
			spooky[M]++
		if(spooky[M] >= 3)
			do_it(M)

	proc/do_it(var/mob/M)
		if(spooking || broken) return
		spooking = 1
		break_it()
		playsound(src, "sound/impact_sounds/Glass_Shatter_3.ogg", 75, 0)
		M:transforming = 1
		sleep(3 SECONDS)
		var/obj/screen/creepy = new /obj/screen()
		creepy.name = "GARHLGHARLHGARHGL"
		creepy.icon = 'icons/creepy.png'
		creepy.screen_loc = "SOUTH,WEST"
		creepy.mouse_opacity = 0
		if(!M) return
		var/client/the_client = M.client
		creepy.add_to_client(the_client)
		playsound(src, "sound/effects/ghost2.ogg", 100, 0)
		sleep(0.5 SECONDS)
		if(!M)
			the_client.screen -= creepy
			return
		M:gib()
		sleep(0.5 SECONDS)
		the_client.screen -= creepy
		sleep(3 SECONDS)

	New()
		build_base()
		update()

	HasEntered(atom/A)
		if(ismob(A)) rebuild_icon()
		return

	attackby(obj/item/W as obj, mob/user as mob)
		..()

		if(W.force <= 1 || broken)
			playsound(src, "sound/impact_sounds/Generic_Stab_1.ogg", 25, 0)
			return

		health--
		if(health <= 0)
			break_it()
			boutput(user, "<span class='alert'>You break the mirror ...</span>")
			playsound(src, "sound/impact_sounds/Glass_Shatter_3.ogg", 75, 0)
		else
			playsound(src, "sound/impact_sounds/Glass_Hit_1.ogg", 75, 0)

	ex_act()
		playsound(src, "sound/impact_sounds/Glass_Shatter_3.ogg", 75, 0)
		break_it()

	hitby(atom/movable/AM as mob|obj)
		playsound(src, "sound/impact_sounds/Glass_Shatter_3.ogg", 75, 0)
		break_it()

	proc

		break_it()
			if(broken) return
			broken = 1
			build_base()
			rebuild_icon()
			new /obj/item/raw_material/shard/glass( src.loc )
			new /obj/item/raw_material/shard/plasmacrystal( src.loc )

		build_base()
			var/turf/T = src.loc
			var/icon/composite = icon(T.icon, T.icon_state, T.dir)
			composite.Flip(NORTH)
			composite.Blend(icon('icons/misc/old_or_unused.dmi', "mirror"), ICON_OVERLAY)
			if(broken) composite.Blend(icon('icons/misc/old_or_unused.dmi', "mirror_broken"), ICON_OVERLAY)
			composite.Crop(7,8,26,31)
			composite.Crop(1,1,32,32)
			composite.Shift(NORTH,7)
			composite.Shift(EAST,6)
			base = composite

		rebuild_icon()

			src.icon = base
			pixel_y = 0
			var/turf/T = src.loc
			var/icon/composite = icon(T.icon, T.icon_state, T.dir)
			composite.Flip(NORTH)
			var/the_dir

			for(var/atom/C in T)
				var/icon/curr

				if(hasvar(C, "body_standing"))
					if(!C:lying)
						if(C.dir == NORTH || C.dir == SOUTH)
							the_dir = turn(C.dir,180)
							curr = icon(C:body_standing, dir=turn(C.dir,180))
						else
							the_dir = C.dir
							curr = icon(C:body_standing, dir=C.dir)
					else
						continue
				else
					if(C.dir == NORTH || C.dir == SOUTH)
						the_dir = turn(C.dir,180)
						curr = icon(C.icon, C.icon_state, turn(C.dir,180))
					else
						the_dir = C.dir
						curr = icon(C.icon, C.icon_state, C.dir)

				if(!curr || C.invisibility) continue

				composite.Blend(curr, ICON_OVERLAY)

				for(var/O in C.overlays)
					var/image/I = O
					var/icon/II = icon(I.icon, I.icon_state, the_dir)
					composite.Blend(II, ICON_OVERLAY)

			composite.Blend(icon('icons/misc/old_or_unused.dmi', "mirror"), ICON_OVERLAY)
			if(broken) composite.Blend(icon('icons/misc/old_or_unused.dmi', "mirror_broken"), ICON_OVERLAY)
			composite.Crop(7,8,26,31)
			composite.Crop(1,1,32,32) //UNCROP - http://www.youtube.com/watch?v=KUFkb0d1kbU
			composite.Shift(NORTH,7)
			composite.Shift(EAST,6)

			src.icon = composite
			pixel_y = 32

		update()
			rebuild_icon()
			SPAWN_DBG(0.5 SECONDS) update()

/obj/spook
	var/active = 0
	invisibility = 100
	anchored = 1
	density = 0
	icon = 'icons/misc/hstation.dmi'
	icon_state = "null"
	desc = "What ... what is this?"
	name = "apparition"
	var/turf/startloc

	New()
		startloc = get_turf(src)
		loop()
		return ..()

	proc/loop()

		if(active)
			SPAWN_DBG(3 SECONDS) loop()
			return


		for(var/mob/living/L in hearers(world.view, src))
			if(prob(20)) spook(L)
			break

		SPAWN_DBG(2 SECONDS) loop()

	proc/spook(var/mob/living/L)
		if (narrator_mode)
			playsound(L, 'sound/vox/ghost.ogg', 5, 0)
		else
			playsound(L, 'sound/effects/ghost.ogg', 5, 0)
		sleep(0.3 SECONDS)
		active = 1
		walk_towards(src,L,3)
		src.invisibility = 0
		flick("apparition",src)
		sleep(1.5 SECONDS)
		src.invisibility = 100
		src.set_loc(startloc)
		walk(src,0)
		SPAWN_DBG(10 SECONDS) active = 0


/datum/engibox_mode
	var/name = ""
	var/desc = ""
	var/requires_input = 0
	var/saved_var = null
	proc/used(atom/user, atom/target)
		return

/datum/engibox_mode/spawmmetal
	name = "Spawn 100 Metal"
	desc = "Spawns 100 Metal sheets."
	used(atom/user, atom/target)
		var/obj/item/sheet/steel/M = new/obj/item/sheet/steel(get_turf(target))
		M.amount = 100
		return

/datum/engibox_mode/spawmglass
	name = "Spawn 100 Glass"
	desc = "Spawns 100 Metal sheets."
	used(atom/user, atom/target)
		var/obj/item/sheet/glass/M = new/obj/item/sheet/glass(get_turf(target))
		M.amount = 100
		return

/datum/engibox_mode/spawmtool
	name = "Spawn Toolbox"
	desc = "Spawns a Toolbox."
	used(atom/user, atom/target)
		new/obj/item/storage/toolbox/mechanical(get_turf(target))
		return

/datum/engibox_mode/construct
	name = "Construct"
	desc = "Construct walls and floor."
	used(atom/user, atom/target)
		if(istype(target, /turf/space))
			target:ReplaceWithFloor()
			return
		if(istype(target, /turf/simulated/floor))
			target:ReplaceWithWall()
			return
		if(istype(target, /turf/simulated/wall))
			target:ReplaceWithRWall()
			return
		return

/datum/engibox_mode/deconstruct
	name = "Deconstruct"
	desc = "Deconstruct walls and floor."
	used(atom/user, atom/target)
		if(istype(target, /turf/simulated/floor))
			target:ReplaceWithSpace()
			return
		if(istype(target, /turf/simulated/wall))
			target:ReplaceWithFloor()
			return
		return

/datum/engibox_mode/remove
	name = "Remove Objects"
	desc = "Removes Objects you placed."
	used(atom/user, atom/target)
		if(isobj(target)) qdel(target)
		return

/datum/engibox_mode/setid
	name = "Link Objects"
	desc = "Allows you to link buttons & machines by setting their group-id. Objects need to be in the same group to affect each other (i.e. a door and a button)."
	requires_input = 1
	used(atom/user, atom/target)
		if(hasvar(target,"id"))
			target:id = saved_var
			boutput(usr, "<span class='notice'>Done.</span>")
		else
			boutput(usr, "<span class='alert'>Not a linkabled object.</span>")
		return

/datum/engibox_mode/reqacc
	name = "Set Required Access"
	desc = "Allows you to set the required Access-level of most objects."
	used(atom/user, atom/target)
		if(istype(target, /obj/machinery/door))
			if(hasvar(target, "req_access"))
				target:req_access = get_access(input(usr) in get_all_jobs() + "Club member")
				boutput(usr, "<span class='notice'>Done.</span>")
			else
				boutput(usr, "<span class='alert'>Invalid object.</span>")
		return

/datum/engibox_mode/spawnid
	name = "Spawn ID card"
	desc = "Allows you to spawn an id card with a certain access level."
	used(atom/user, atom/target)
		var/obj/item/card/id/blank_deluxe/D = new/obj/item/card/id/blank_deluxe(get_turf(target))
		D.access = get_access(input(usr) in get_all_jobs() + "Club member")
		return

/datum/engibox_mode/fwall
	name = "Construct False Wall"
	desc = "Construct a False Wall."
	used(atom/user, atom/target)
		var/turf/targ = get_turf(target)
		new/turf/simulated/wall/false_wall(targ)
		return

/datum/engibox_mode/airlock
	name = "Place Airlock"
	desc = "Places an Airlock."
	used(atom/user, atom/target)
		new/obj/machinery/door/airlock(get_turf(target))
		return

/datum/engibox_mode/airlockglass
	name = "Place glass Airlock"
	desc = "Places a glass Airlock."
	used(atom/user, atom/target)
		new/obj/machinery/door/airlock/glass(get_turf(target))
		return

/datum/engibox_mode/light
	name = "Place Light"
	desc = "Places a Light - facing the direction you are facing."
	used(atom/user, atom/target)
		var/obj/machinery/light/small/L = new/obj/machinery/light/small(get_turf(target))
		L.dir = user:dir
		L.on = 1
		L.update()
		return

/datum/engibox_mode/buttonpod
	name = "Place Button"
	desc = "Places a Button that can control mass-drivers & pod-doors."
	used(atom/user, atom/target)
		var/obj/machinery/driver_button/L = new/obj/machinery/driver_button(get_turf(target))
		L.dir = user:dir
		return

/datum/engibox_mode/buttonconvey
	name = "Place Conveyor switch"
	desc = "Places a Conveyor switch that can control a conveyor belt."
	used(atom/user, atom/target)
		var/obj/machinery/conveyor_switch/L = new/obj/machinery/conveyor_switch(get_turf(target))
		L.dir = user:dir
		return

/datum/engibox_mode/conveyor
	name = "Place Conveyor belt"
	desc = "Places a Conveyor belt - facing the direction you are facing."
	used(atom/user, atom/target)
		var/obj/machinery/conveyor/L = new/obj/machinery/conveyor(get_turf(target))
		L.dir = user:dir
		L.basedir = L.dir
		return

/datum/engibox_mode/poddoor
	name = "Place Pod-Door"
	desc = "Places a Pod-Door."
	used(atom/user, atom/target)
		var/obj/machinery/door/poddoor/L = new/obj/machinery/door/poddoor(get_turf(target))
		L.dir = user:dir
		return

/datum/engibox_mode/driver
	name = "Place Mass-Driver"
	desc = "Places a Mass-Driver - facing the direction you are facing."
	used(atom/user, atom/target)
		var/obj/machinery/mass_driver/L = new/obj/machinery/mass_driver(get_turf(target))
		L.dir = user:dir
		return

/datum/engibox_mode/cam
	name = "Place Security Camera"
	desc = "Places a Security Camera - using your direction."
	used(atom/user, atom/target)
		var/obj/machinery/camera/L = new/obj/machinery/camera(get_turf(target))
		L.dir = user:dir
		return

/datum/engibox_mode/window
	name = "Place Window"
	desc = "Places a reinforced window."
	used(atom/user, atom/target)
		if (map_settings)
			new map_settings.rwindows (get_turf(target))
		else
			new /obj/window/reinforced(get_turf(target))
		return

/datum/engibox_mode/grille
	name = "Place Grille"
	desc = "Places a Grille."
	used(atom/user, atom/target)
		var/obj/grille/L = new/obj/grille/steel(get_turf(target))
		L.dir = user:dir
		return

/datum/engibox_mode/table
	name = "Place Reinforced Table"
	desc = "Places a Reinforced Table."
	used(atom/user, atom/target)
		var/obj/table/reinforced/L = new/obj/table/reinforced(get_turf(target))
		L.dir = user:dir
		return

/datum/engibox_mode/paint
	name = "Spawn paint can"
	desc = "Spawn a paint can."
	used(atom/user, atom/target)
		var/col_new = input(user) as color
		if(col_new)
			var/obj/item/paint_can/P = new/obj/item/paint_can(get_turf(target))
			P.paint_color = col_new
			P.generate_icon()
			P.uses = 9999
		return

/datum/engibox_mode/replicate
	name = "Replicate Object"
	desc = "Allows you to replicate objects. First use selects Object to clone, further clicks place copies. Un- or Re-select mode to clear set object."
	var/obj_path = null
	used(atom/user, atom/target)
		if(obj_path)
			var/atom/A = new obj_path(get_turf(target))
			boutput(usr, "<span class='notice'>Placed: [A.name]</span>")
		else
			obj_path = target.type
			boutput(usr, "<span class='notice'>Now replicating: [target.name]s</span>")
		return

/datum/engibox_mode/transmute
	name = "Change material"
	desc = "Changes the material of the targeted object."
	var/mat_id = "gold"
	used(atom/user, atom/target)
		target.setMaterial(getMaterial(mat_id))
		return

/datum/engibox_mode/density
	name = "Toggle density"
	desc = "Toggles the density of an object."
	used(atom/user, atom/target)
		target.set_density(!target.density)
		boutput(usr, "<span class='notice'>Target density now: [target.density]</span>")
		return

/datum/engibox_mode/opacity
	name = "Toggle opacity"
	desc = "Toggles the opacity of an object."
	used(atom/user, atom/target)
		target.opacity = !target.opacity
		boutput(usr, "<span class='notice'>Target opacity now: [target.opacity]</span>")
		return

/obj/item/engibox
	name = "Engineer-in-a-box"
	desc = "The concentrated power of a whole team of engineers. In a box."
	icon = 'icons/obj/items/storage.dmi'
	icon_state = "engi"
	var/list/modes = new/list()
	var/datum/engibox_mode/active_mode = null
	var/ckey_lock = null
	var/z_level_lock = 0
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = 1.0
	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(ckey_lock && usr.ckey != ckey_lock)
			boutput(user, "<span class='alert'>You are not authorized to use this item.</span>")
			return
		if(get_dist(target,user) > 1)
			boutput(user, "<span class='alert'>You are too far away.</span>")
			return
		if(target == loc) return
		var/turf/T = get_turf(src)
		if(z_level_lock && T.z != z_level_lock)
			boutput(user, "<span class='alert'>\The [src] is not authorized to be used outside official NanoTrasen stations.</span>")
			return
		if(active_mode)
			active_mode.used(user, target)
		return

	attack()
		return

	attack_self(mob/user as mob)
		if(ckey_lock && usr.ckey != ckey_lock)
			boutput(user, "<span class='alert'>You are not authorized to use this item.</span>")
			return
		var/dat = "Engie-box modes:<BR><BR>"
		for(var/datum/engibox_mode/D in modes)
			dat += "<A href='?src=\ref[src];set_mode=\ref[D]'>[D.name]</A> [active_mode == D ? "<<<" : ""]<BR>"
			dat += "[D.desc]<BR><BR>"
		user.Browse(dat, "window=engibox;can_minimize=0;can_resize=0;size=250x600")
		onclose(user, "window=engibox")
		return

	Topic(href, href_list)
		if(usr.stat || usr.restrained()) return
		if(!in_range(src, usr)) return
		src.add_dialog(usr)
		if (href_list["set_mode"])
			active_mode = locate(href_list["set_mode"]) in modes

			if(active_mode.requires_input)
				active_mode.saved_var = input(usr,"Enter ID","ID","MyId") as text
				if(!active_mode.saved_var || isnull(active_mode.saved_var)) active_mode = null

			if(istype(active_mode,/datum/engibox_mode/transmute)) //You only have yourself to blame for this. This shitty code is the fault of whoever changed this!!!
				active_mode:mat_id = input(usr,"Select material","material","gold") in list("gold", "steel", "mauxite", "pharosium","cobryl","bohrum","cerenkite","syreline","glass","molitz","claretine","erebite","plasmastone","plasmaglass","quartz","uqill","telecrystal","miraclium","starstone","flesh","char","koshmarite","viscerite","beeswax","latex","synthrubber","synthblubber","wendigohide","cotton","fibrilith")

			if(istype(active_mode,/datum/engibox_mode/replicate))
				active_mode:obj_path = null

			src.attack_self(usr)
			return
		src.attack_self(usr)
		src.add_fingerprint(usr)
		return

	New()
		for(var/D in typesof(/datum/engibox_mode) - /datum/engibox_mode)
			modes += new D

/obj/item/engibox/station_locked
	z_level_lock = 1 // 1 = station z level

/obj/signpost
	icon = 'icons/misc/old_or_unused.dmi'
	icon_state = "signpost"
	anchored = 1
	density = 1

	attackby(obj/item/W as obj, mob/user as mob)
		return attack_hand(user)

	attack_hand(mob/user as mob)
		switch(alert("Travel back to ss13?",,"Yes","No"))
			if("Yes")
				user.loc.loc.Exited(user)
				user.set_loc(pick(latejoin))
			if("No")
				return

/area/beach
	name = "Keelin's private beach"
	icon_state = "null"
	luminosity = 1
	force_fullbright = 1
	requires_power = 0
	sound_loop = 'sound/ambience/loop/Shore.ogg'
	sound_loop_vol = 100

	New()
		..()
		SPAWN_DBG(1 SECOND)
			process()

	proc/process()
		while(current_state < GAME_STATE_FINISHED)
			sleep(10 SECONDS)
			if (current_state == GAME_STATE_PLAYING)
				if(!played_fx_2)
					sound_fx_2 = pick('sound/ambience/nature/Seagulls1.ogg','sound/ambience/nature/Seagulls2.ogg','sound/ambience/nature/Seagulls3.ogg')
					for(var/mob/M in src)
						if (M.client)
							M.client.playAmbience(src, AMBIENCE_FX_2, 50)

/obj/item/beach_ball
	icon = 'icons/misc/beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	item_state = "clown"
	density = 0
	anchored = 0
	w_class = 1.0
	force = 0.0
	throwforce = 0.0
	throw_speed = 1
	throw_range = 20
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		user.drop_item()
		src.throw_at(target, throw_range, throw_speed)

/* Camera test stuff

/mob/living/intangible/aicamera
	icon = 'icons/mob/ai.dmi'
	icon_state = "a-eye"
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	density = 0
	canmove = 1
	blinded = 0
	anchored = 1
	name = "camera view"
	var/list/blockers
	//debug stuff
	var/high_range = 1

	is_spacefaring()
		return 1

	movement_delay()
		if (src.client && src.client.check_key(KEY_RUN))
			return 0.4
		else
			return 0.75

/mob/living/intangible/aicamera/New()
	. = ..()
	src.invisibility = 0
	src.sight = SEE_THRU
	src.see_invisible = 0

/obj/ai_static
	name = "static"
	alpha = 0
	anchored = 1
	density = 0
	opacity = 0
	icon = 'icons/mob/hud_common.dmi'
	icon_state = "static"
	screen_loc = "NORTH,WEST to SOUTH,EAST"
	layer = 50
	plane = 100
	mouse_opacity = 1
	var/blocking = 0

	MouseEntered(location,control,params)
		if(usr && usr.client)
			usr.client.show_popup_menus = 0
		return ..()

	MouseExited(location,control,params)
		if(usr && usr.client)
			usr.client.show_popup_menus = 1
		return ..()

	MouseDrop_T()
		if(usr && usr.client && blocking)
			usr.client.show_popup_menus = 0
		return ..()


/mob/living/intangible/aicamera/proc/updateLOS()
	if(!src.client) return

	var/low_left_x = (src.x - src.client.view)
	low_left_x = max(low_left_x, 1)
	low_left_x = min(low_left_x, world.maxx)

	var/low_left_y = (src.y - src.client.view)
	low_left_y = max(low_left_y, 1)
	low_left_y = min(low_left_y, world.maxy)

	var/up_right_x = (src.x + src.client.view)
	up_right_x = max(up_right_x, 1)
	up_right_x = min(up_right_x, world.maxx)

	var/up_right_y = (src.y + src.client.view)
	up_right_y = max(up_right_y, 1)
	up_right_y = min(up_right_y, world.maxy)

	var/list/visible = list()
	var/list/view_turfs	= block(locate(low_left_x, low_left_y, src.z), locate(up_right_x, up_right_y, src.z))

	if(high_range)
	//Uses all cameras within viewrange + camera range, significantly slower
		for(var/obj/machinery/camera/C in cameras)
			if(C.z != src.z || get_dist(src, C) > (src.client.view + CAM_RANGE)) continue
			visible = (visible | view(CAM_RANGE, C))
	else
	//Alternate version, uses only cameras on screen.
		for(var/turf/T in view_turfs)
			var/obj/machinery/camera/C = (locate(/obj/machinery/camera) in T)
			if(C)
				visible = (visible | view(CAM_RANGE, C))

	for(var/turf/TC in view_turfs)
		var/curr_x = (client.view + 1) - (src.x - TC.x)
		var/curr_y = (client.view + 1) - (src.y - TC.y)

		var/obj/ai_static/S = (blockers[curr_x][curr_y])
		if(S)
			if(!(TC in visible))
				S.mouse_opacity = 2
				S.blocking = 1
				if(S.alpha != 255)
					animate(S, alpha=255, time=2)
				//S.alpha = 255
			else
				S.mouse_opacity = 0
				S.blocking = 0
				if(S.alpha != 0)
					animate(S, alpha=0, time=2)
				//S.alpha = 0

/mob/living/intangible/aicamera/disposing()
	..()
	return

/mob/living/intangible/aicamera/Login()
	..()
	if(!src.client)
		return

	var/sight_range = ((src.client.view * 2) + 1)
	blockers = new/list(sight_range, sight_range)
	for(var/x = 1, x <= sight_range, x++)
		for(var/y = 1, y <= sight_range, y++)
			var/obj/ai_static/S = new()
			S.screen_loc = "[x],[y]"
			S.alpha = 0
			blockers[x][y] = S
			src.client.screen += S

	//client.show_popup_menus = 0
	return

/mob/living/intangible/aicamera/Logout()
	..()
	blockers = null
	//client.show_popup_menus = 1
	return

/mob/living/intangible/aicamera/Life(datum/controller/process/mobs/parent)
	..(parent)
	updateLOS()
	return

/mob/living/intangible/aicamera/Move(var/turf/NewLoc, direct)
	..(NewLoc, direct)
	updateLOS()
	return
	*/
