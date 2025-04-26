//This file contains stuff that is still *mostly* my code.

/*
Proc: drawLineImg
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
		     -LINEMODE_STRETCH has an existing issue where BYOND will partially clip the line sprites in certain situations.
			  If set to LINEMODE_STRETCH_NOCLIP, it will attempt to bypass this by not using filter transforms, though this has its' own downsides scaling caps.

		  TBI: If set to LINEMODE_MOVE, one full sized segment will travel from source to target, repeatedly.
	getCrossed: If set to 1, we will return a list of crossed turfs in our /datum/lineResult 's crossed var.
	adjustTiles: If 1, will attempt to correct the list of crossed turfs based on the offsets passed into the proc.
				 If 0, will ignore the offsets and just go from source to target.
Returns:
	An instance of /datum/lineResult. See below drawLineImg.
		lineImage contains the finished line image. You will still need to output it for it to be visible. addGlobalImage is an option.
		By default the image is attached to source. You can change this by setting the image's loc to something else.
		crossed contains a list of crossed turfs if getCrossed was set to 1.
*/
/proc/drawLineImg(var/atom/source, var/atom/target, var/render_source_line = null, var/render_source_cap = null, var/src_off_x=0, var/src_off_y=0, var/trg_off_x=0, var/trg_off_y=0, var/mode = LINEMODE_STRETCH, var/getCrossed = 1, var/adjustTiles=1, var/applyTransform = TRUE)
	if(render_source_line == null) return
	var/datum/lineResult/result = new()

	if(mode != LINEMODE_SIMPLE && mode != LINEMODE_SIMPLE_REVERSED)
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
		var/matrix/final_matrix = UNLINT(matrix().Turn(-angle).Translate((dist),0).Turn(angle))
		result.transform = final_matrix
		if (applyTransform)
			I.transform = final_matrix
		result.lineImage = I

	else if(mode == LINEMODE_STRETCH_NO_CLIP)
		// This mode is mostly the same as LINEMODE_STRETCH, but does the transformation outside of filters.
		// This prevents some weird issues that cause LINEMODE_STRETCH to cut off the sprite at certain pixel offsets, but
		// makes it difficult to have caps at both ends of a line.

		//Matrix M scales down our 64 pixel line to whatever length was calculated earlier, then moves it into place.
		var/matrix/M = UNLINT(matrix().Scale(scale,1).Translate((dist/2),0).Turn(angle).Translate(src_off_x,src_off_y))
		result.transform = M
		var/image/I = image(null,source)
		I.appearance_flags = KEEP_APART  //Required for some odd reason.
		I.filters += filter(type="layer", render_source = (islist(render_source_line) ? pick(render_source_line) : render_source_line))
		if(render_source_cap != null)
			//And to avoid resizing caps, we pre-emptively upscale the source cap, so that it looks the same.
			//This probably breaks dual-ended caps.
			var/matrix/M2 = UNLINT(matrix().Scale(1/scale,1).Translate(-((1/scale)-1)*32,0))
			I.filters += filter(type="layer", render_source = (islist(render_source_cap) ? pick(render_source_cap) : render_source_cap), transform=M2)
		if (applyTransform)
			I.transform = M
		result.lineImage = I
	else if(mode == LINEMODE_SIMPLE)
		var/image/I = image(null,source)
		I.icon = 'icons/effects/lines2.dmi'
		I.icon_state = islist(render_source_line) ? pick(render_source_line) : render_source_line
		var/matrix/M = UNLINT(matrix().Scale(scale,1).Translate(dist/2,0).Turn(angle).Translate(src_off_x - iconWidth / 4,src_off_y))
		result.transform = M
		if (applyTransform)
			I.transform = M
		result.lineImage = I
	else if(mode == LINEMODE_SIMPLE_REVERSED)
		var/image/I = image(null,source)
		I.icon = 'icons/effects/lines2.dmi'
		I.icon_state = islist(render_source_line) ? pick(render_source_line) : render_source_line
		var/matrix/M = UNLINT(matrix().Scale(scale,1).Translate(-dist/2,0).Turn(180 + angle).Translate(src_off_x - iconWidth / 4,src_off_y))
		result.transform = M
		if (applyTransform)
			I.transform = M
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
	/// The resulting transform applied to the line, null in the case of LINEMODE_SEGMENT because there's no single transform there.
	var/matrix/transform = null

//Gets a line of turfs between the two atoms. Doesn't miss tiles, like bresenham.
//Adapted from http://playtechs.blogspot.com/2007/03/raytracing-on-grid.html
/proc/raytrace(var/atom/source, var/atom/target)
	. = list()
	var/x0 = source.x
	var/y0 = source.y
	var/x1 = target.x
	var/y1 = target.y
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
		. += get_turf(locate(x, y, source.z))
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

/proc/testLine()
	var/atom/source = get_turf(usr)
	var/atom/target = get_turf(pick(oview(5)))
	var/datum/lineResult/R = drawLineImg(source, target, list("elec1","elec2","elec3"), "eleccap")
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
	var/atom/movable/screen/S = new(usr)
	var/image/I = image('icons/effects/160x160.dmi',S,"tearmed")
	I.render_target = "*test"
	S.screen_loc = "CENTER"
	S.mouse_opacity = 1
	S.filters += filter(type="layer", render_source = "floor_plane")
	S.filters += filter(type="layer", render_source = "game_plane")
	S.filters += filter(type="layer", render_source = "*hidden_game_plane")
	S.filters += filter(type="color", color=list(0.2,0.05,0.05, 0.1,0.3,0.2, 0.1,0.1,0.4, 0,0,0)) //Alpha method preserves interaction but you can use object outside your range and alpha gets destroyed
	S.filters += filter(type="alpha", render_source="*test")										//Going with this because i only need visibility
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

		add_filter("layer", 1, layering_filter(render_source="*portaltrg"))

	New()
		..()
		SPAWN(50) setup()

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

/datum/gunTarget
	var/params = null
	var/target = null
	var/user = 0

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
		if (!islist(target.params)) target.params = params2list(params)
		target.target = over_object
		target.user = usr
		if(over_object.loc != startingLoc && over_object != startingLoc) return
		if(currentDecal != null)
			draw()

	onMouseDown(atom/object,location,control,params)
		if(object == src || (!isturf(object.loc) && !isturf(object))) return
		if(!object || !istype(object, /atom)) return
		if(target == null) target = new()
		if (!islist(target.params)) target.params = params2list(params)
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
		boutput(usr, SPAN_ALERT("GRABBED '[mapPath]' FROM LOCAL FILESYSTEM"))
	else
		boutput(usr, SPAN_ALERT("COULDNT LOAD '[mapPath]'"))
		return

	var/trgX = input(usr, "Enter target X:", "", 1) as num
	var/trgY = input(usr, "Enter target Y:", "", 1) as num
	var/trgZ = input(usr, "Enter target Z:", "", 1) as num

	if(trgX && trgY && trgZ)
		var/startTime = world.timeofday
		var/dmm_suite/D = new/dmm_suite()
		if(loaded && length(loaded))
			usr.set_loc(locate(trgX,trgY,trgZ))
			D.read_map(loaded,trgX,trgY,trgZ)
			boutput(usr, SPAN_ALERT("LOADED '[mapPath]' IN [((world.timeofday - startTime)/10)] SEC"))
		else
			boutput(usr, SPAN_ALERT("COULDNT LOAD '[mapPath]'"))
	return

/proc/endoftheworldasweknowit()
	var/list/L = list()
	for(var/turf/T in world)
		if(T.type == /turf/space) continue
		if(T.z == 1)
			L.Add(T)

	var/turf/TLast = pick(L)
	L.Remove(TLast)

	while(length(L) >= 1)
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

	while(length(L) >= 1)
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
	anchored = ANCHORED
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
		SPAWN(0.6 SECONDS)
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
		. = ..()
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
			var/obj/sparks = new /obj/effects/sparks
			sparks.set_loc(get_turf(src))
			SPAWN(2 SECONDS) if (sparks) qdel(sparks)
			qdel(src)
		return

	/*
	Crossed(atom/movable/AM as mob|obj)
		var/turf/T = locate(targetX, targetY, targetZ)
		if(T)
			AM.set_loc(T)
		else
			src.visible_message("<span style='color: red; font-weight: bold'>The portal collapses in on itself!</span>")
			var/obj/sparks = new /obj/effects/sparks
			sparks.set_loc(get_turf(src))
			SPAWN(2 SECONDS) if (sparks) qdel(sparks)
			qdel(src)
		return
	*/

/obj/hole
	name = ""
	mouse_opacity = 1
	desc = ""
	density = 0
	opacity = 0
	anchored = ANCHORED
	var/targetZ = 2

	onVarChanged(variable, oldval, newval)
		. = ..()
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
		..()
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
			if(area_space_nopower(A))
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

			if(A?.z == 1) //Basically, if the area has a turf on z1 ... Doesn't work as described in byond documentation. So we have to do it the slow way ...
				areas.Add(A)

	while(length(areas) >= 2)
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
			if(D.req_access && length(D.req_access))
				oneAccess |= D.req_access

		if(isturf(T))
			if(!T.density)
				oneTurfs.Add(T)

	for(var/atom/T in twoContents)
		if(istype(T, /obj/machinery/door))
			var/obj/machinery/door/D = T
			if(D.req_access && length(D.req_access))
				twoAccess |= D.req_access

		if(isturf(T))
			if(!T.density)
				twoTurfs.Add(T)

	if(!twoTurfs.len || !length(oneTurfs))
		return

	var/list/oneTurfsExpend = oneTurfs.Copy()
	var/list/twoTurfsExpend = twoTurfs.Copy()

	var/list/ignoreTypes = list(/obj/machinery/disposal,/obj/cable,/obj/machinery/power,/obj/machinery/light,/obj/disposalpipe,/obj/mesh/grille,/obj/window,/obj/machinery/door,/obj/machinery/atmospherics,/obj/overlay/tile_effect)

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

			if(length(twoTurfsExpend) > 0)
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

			if(length(oneTurfsExpend) > 0)
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
	anchored = ANCHORED
	density = 0
	opacity = 0

/obj/decal/valterakWhip
	name = "???"
	desc = "Upon closer inspection these seem to be the burnt remnants of a whip. How they are still there or even recognizable is beyond you."
	icon = 'icons/misc/exploration.dmi'
	icon_state = "vwhip"
	anchored = ANCHORED
	density = 0
	opacity = 0

/datum/admins/proc/camtest()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Test Cinematic camera"
	set desc="Test Cinematic camera"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
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
		var/dur = (GET_DIST(selected, M)*5)
		var/ease = pick(LINEAR_EASING,SINE_EASING,CIRCULAR_EASING,QUAD_EASING,CUBIC_EASING,BOUNCE_EASING,ELASTIC_EASING,BACK_EASING)
		boutput(world, "dur [dur] , ease : [ease] , dist : [GET_DIST(selected, M)] , selected : [selected]")
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
		SPAWN(max(length*2,delay) * steps)
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
		SPAWN(duration)
			C.stop()

	return

/mob/cinematicCamera
	var/mob/source
	var/atom/source_loc
	var/remove_source = 0 //Remove the source mob while camera is active?
	var/freeze_source = 1 //Attempt to make source mob immovable and invincible during cam?
	nodamage = 1
	canmove = 0
	invisibility = INVIS_ALWAYS
	density = 0
	anchored = ANCHORED

	proc/shake(var/steps = 20, var/length = 1, var/delay = 0, var/strength = 32, var/anim_easing = LINEAR_EASING)
		SPAWN(0)
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
		if(source_mob?.client)
			source = source_mob
			remove_source = remove
			freeze_source = freeze
			source_loc = source.loc
			client = source.client
			if(remove_source)
				source.set_loc(src)
			if(freeze_source)
				source.nodamage = 1
				source.canmove = 0
				source.anchored = ANCHORED
		return

	proc/stop()
		source.set_loc(source_loc)
		source.client = client
		source.client.pixel_x = 0
		source.client.pixel_y = 0
		if(freeze_source)
			source.nodamage = 0
			source.canmove = 1
			source.anchored = UNANCHORED

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
	anchored = ANCHORED
	density = 0
	icon = 'icons/effects/64x64.dmi'
	icon_state = "whole-nascent"
	pixel_x = -16
	pixel_y = -16
	blend_mode = 2
	New()
		SPAWN(10 SECONDS)
			name = "growing wormhole"
			desc = "a slowly growing wormhole"
			icon_state = "whole-growing"
			blend_mode = 2
		SPAWN(20 SECONDS)
			name = "stable wormhole"
			desc = "a wormhole leading who-knows-where"
			icon_state = "whole"
			blend_mode = 1
		SPAWN(30 SECONDS)
			name = "massive wormhole"
			desc = "a huge wormhole leading to unknown space"
			icon_state = "whole-massive"
			blend_mode = 1
		SPAWN(40 SECONDS)
			name = "unstable wormhole"
			desc = "an unstable wormhole, about to collapse"
			icon_state = "whole-unstable"
			blend_mode = 1
		SPAWN(50 SECONDS)
			qdel(src)
		..()

/obj/effect/melee
	name = ""
	desc = ""
	icon = 'icons/effects/meleeeffects.dmi'
	icon_state = "sabre"
	anchored = ANCHORED
	layer = EFFECTS_LAYER_1

	New()
		SPAWN(2 SECONDS)
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

/obj/effect/melee/spearimage
	name = ""
	desc = ""
	icon = null
	icon_state = "sabre"
	anchored = ANCHORED
	New(var/obj/item/experimental/melee/spear/S,var/atom/location)
		src.set_loc(location)
		var/image/I = image(S)
		I.appearance_flags = 0
		src.overlays += image(S)
		SPAWN(0.5 SECONDS)
			qdel(src)
		..()

/obj/item/experimental/ranged
	name = "test"
	desc = ""
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "sword1-W"
	inhand_image_icon = 'icons/mob/inhand/hand_cswords.dmi'
	item_state = "sword1-W"
	flags = EXTRADELAY | TABLEPASS | CONDUCT
	var/obj/beam_dummy/beam
	var/turf/last = null

	onMouseDrag(src_object,atom/over_object,src_location,over_location,src_control,over_control,params)
		var/list/parameters = params2list(params)
		if(ismob(over_object.loc) || istype(over_object, /atom/movable/screen)) return
		if(parameters["left"])
			//animate_shake(over_object)
			if(beam)
				if(last != get_turf(over_object))
					last = get_turf(over_object)
					beam.set_loc(get_turf(src))
					animate(beam, transform=beam.transform, time=1)//, flags=ANIMATION_LINEAR_TRANSFORM)
					animate(transform=getLineMatrix(get_turf(src),get_turf(over_object)), time= max(7-GET_DIST(get_turf(src),get_turf(over_object)), 2))
		return

	onMouseDown(atom/target,location,control,params)
		var/list/parameters = params2list(params)
		if(ismob(target.loc) || istype(target, /atom/movable/screen)) return
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
	flags = EXTRADELAY | TABLEPASS | CONDUCT

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
					A.Attackby(src, user)
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
		..()
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
		if(BOUNDS_DIST(user, target) > 0 || target == null || user == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if(dagger)
			if(dagger == user.equipped())
				dagger.stab(user, target, progress)
				return

	onUpdate()
		if(BOUNDS_DIST(user, target) > 0 || target == null || user == null)
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
				switch(GET_DIST(O, user))
					if(0 to 1)
						if(O.dir == turn(user.dir, 180)) //Only visible if looking directly at them in close range.
							canSee = 1
					if(2)
						if(get_dir(O, user) == O.dir) //If you're looking in their direction at 2 tiles away you'll see it.
							canSee = 1
					else continue
				if(canSee)
					seen.Add(O)
					O.show_message(SPAN_ALERT("<B>[user] raises \the [dagger] menacingly!!!</B>"), 1)


/obj/item/experimental/melee/dagger
	name = "Dagger"
	desc = "A dagger. Perfect for back-stabbing. Only good for back-stabbing, actually."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "cdagger"
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "dagger"
	hitsound = null
	flags = EXTRADELAY | TABLEPASS | CONDUCT | SUPPRESSATTACK
	force = 1
	var/datum/action/bar/private/icon/daggerStab/stabAction

	onMouseDown(atom/target,location,control,params)
		var/mob/user = usr
		var/list/parameters = params2list(params)
		if(ismob(target.loc) || istype(target, /atom/movable/screen)) return
		if(parameters["left"])
			var/attackDir =  getAttackDir(user, target)
			user.set_dir(attackDir)
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

				if(ismob(A) && GET_DIST(A, user) == 1 && (A.dir == user.dir || A:lying)) //It's a person and they are facing away from us. Bonus damage.
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
					A.Attackby(src, user)

		if(bloody && hitmob)
			playsound(target, 'sound/impact_sounds/Blade_Small_Bloody.ogg', 100, FALSE)
		else
			playsound(target, 'sound/impact_sounds/Blade_Small.ogg', 100, FALSE)

		flags |= SUPPRESSATTACK
		force = initial(force)

		showEffect(user,target,user.dir, stabStrength)

		return

	showEffect(var/mob/user, var/atom/target, var/direction, var/stabStrength = 0)
		var/obj/effect/melee/dagger/M
		M = new/obj/effect/melee/dagger(target)
		M.set_dir(direction)
		M.color = (stabStrength < 1 ? "#FFFFFF" : "#FF4444")

/obj/item/experimental/melee/spear
	name = "Spear"
	desc = "An ancient solution to the ancient problem of wanting to stab somebody, but not wanting them to be able to stab you back."
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
	var/prefix = null
	hitsound = 'sound/impact_sounds/Flesh_Cut_1.ogg'
	hit_type = DAMAGE_STAB

	New()
		setHeadMaterial(getMaterial("telecrystal"))
		setShaftMaterial(getMaterial("bohrum"))
		buildOverlays()

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
		SetPrefix()
		if(shaft)
			src.color = shaft.getColor()
			src.alpha = shaft.getAlpha()
		return

	proc/setHeadMaterial(var/datum/material/M)
		head = M
		SetPrefix()
		setMaterial(M, setname = 0)
		if(shaft)
			src.color = shaft.getColor()
			src.alpha = shaft.getAlpha()
		if(src.material && src.material.hasProperty("hard"))
			src.force = round(src.material.getProperty("hard") * 2)
			src.throwforce = round(src.material.getProperty("hard") * 3)
		return

	proc/SetPrefix()
		src.remove_prefixes(prefix)
		prefix = ""
		if(head)
			prefix += "[head.getName()]-tipped[shaft?" ":""]"
		if (shaft)
			prefix += "[shaft.getName()]"
		src.name_prefix(prefix)
		src.UpdateName()

	proc/buildOverlays()
		overlays.Cut()
		if(shaft)
			var/image/imgShaft = image('icons/obj/items/weapons.dmi',icon_state = "spear")
			imgShaft.color = shaft.getColor()
			imgShaft.alpha = shaft.getAlpha()
			imgShaft.appearance_flags = RESET_ALPHA | RESET_COLOR
			overlays += imgShaft
			shaftImg = imgShaft
		if(head)
			var/image/imgHead = image('icons/obj/items/weapons.dmi',icon_state = "spearhead")
			imgHead.color = head.getColor()
			imgHead.alpha = head.getAlpha()
			imgHead.appearance_flags = RESET_ALPHA | RESET_COLOR
			overlays += imgHead
			headImg = imgHead
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
		var/obj/effect/melee/spear/M

		switch(direction)
			if(NORTH)
				effectLoc = locate(user.x, user.y + 1, user.z)
				/*
				I = new(src, effectLoc)
				I.set_dir(direction)
				animate(I, pixel_y = 96, time = 6, alpha= 0)
				*/
				M = new/obj/effect/melee/spear(effectLoc)
				M.pixel_x = -32
				M.set_dir(direction)
				M.color = color_new
				animate(M, pixel_y = 32, time = 10, alpha= 175)
			if(EAST)
				effectLoc = locate(user.x + 1, user.y, user.z)
				/*
				I = new(src, effectLoc)
				I.set_dir(direction)
				animate(I, pixel_x = 96, time = 6, alpha= 0)
				*/
				M = new/obj/effect/melee/spear(effectLoc)
				M.pixel_y = -32
				M.set_dir(direction)
				M.color = color_new
				animate(M, pixel_x = 32, time = 10, alpha= 175)
			if(SOUTH)
				effectLoc = locate(user.x, user.y - 3, user.z)
				/*
				I = new(src, locate(user.x, user.y - 1, user.z))
				I.set_dir(direction)
				animate(I, pixel_y = -96, time = 6, alpha= 0)
				*/
				M = new/obj/effect/melee/spear(effectLoc)
				M.pixel_x = -32
				M.set_dir(direction)
				M.color = color_new
				animate(M, pixel_y = -32, time = 10, alpha= 175)
			if(WEST)
				effectLoc = locate(user.x - 3, user.y, user.z)
				/*
				I = new(src, locate(user.x - 1, user.y, user.z))
				I.set_dir(direction)
				animate(I, pixel_x = -96, time = 6, alpha= 0)
				*/
				M = new/obj/effect/melee/spear(effectLoc)
				M.pixel_y = -32
				M.set_dir(direction)
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

		var/color_new = list(partred*2.5,0.30,0.30, 0.30,partgreen*2.5,0.30, 0.30,0.3,partblue*2.5, 0,0,0)
		var/atom/effectLoc = null
		var/obj/effect/melee/M
		switch(direction)
			if(NORTH)
				effectLoc = locate(user.x, user.y + 1, user.z)
				M = new/obj/effect/melee(effectLoc)
				M.pixel_x = -32
				M.set_dir(direction)
				M.color = color_new
			if(EAST)
				effectLoc = locate(user.x + 1, user.y, user.z)
				M = new/obj/effect/melee(effectLoc)
				M.pixel_y = -32
				M.set_dir(direction)
				M.color = color_new
			if(SOUTH)
				effectLoc = locate(user.x, user.y - 3, user.z)
				M = new/obj/effect/melee(effectLoc)
				M.pixel_x = -32
				M.set_dir(direction)
				M.color = color_new
			if(WEST)
				effectLoc = locate(user.x - 3, user.y, user.z)
				M = new/obj/effect/melee(effectLoc)
				M.pixel_y = -32
				M.set_dir(direction)
				M.color = color_new

/obj/floorpillstatue
	name = "Statue of Dr.Floorpills"
	desc = "A statue of the most radioactive man alive. Technically alive. Sort of."
	var/broken = 0
	icon ='icons/obj/objects.dmi'
	icon_state = "statuefloorpills"
	density = 1
	default_material = "slag"

	New()
		..()
		AddComponent(/datum/component/radioactive,20,FALSE,FALSE)
		name = "Statue of Dr.Floorpills"

	attack_hand(mob/user)
		boutput(user, "[src] feels oddly warm...")
		return

	attackby(obj/item/W, mob/user)
		if(prob(8) && (!broken))
			for(var/i=0, i<5, i++)
				new/obj/item/material_piece/slag(src.loc)

			src.visible_message(SPAN_ALERT("<B>[src] breaks into pieces!</B>"))
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
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Pixel explosion mode"
	set desc = "Makes everything you click on explode into pixels."
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	if (istype(usr.targeting_ability, /datum/targetable/pixelpicker))
		var/datum/targetable/pixelpicker/pixel_picker = usr.targeting_ability
		usr.targeting_ability = null
		qdel(pixel_picker)
		usr.update_cursor()
		boutput(usr, "Pixel explosion mode toggled off.")
	else
		var/mode = alert(usr, "Explode or pixelate?", "", "Explode", "Pixelate", "Cancel")
		if (!mode || mode == "Cancel")
			return
		pixelmagic(mode == "Explode")
		boutput(usr, "Clicking things will now [mode == "Explode" ? "explode them into pixels" : "turn them into individual pixel items"]")

/datum/targetable/pixelpicker
	target_anything = 1
	targeted = 1
	max_range = 3000
	var/explode = TRUE

	castcheck(var/mob/M)
		if (M.client && M.client.holder)
			return 1

	handleCast(var/atom/selected)
		if(src.explode)
			dothepixelthing(selected)
		else
			dothepixelthing(selected, /obj/item/apixel, FALSE)
		var/mob/M = usr
		var/datum/targetable/pixelpicker/R = new()
		R.explode = src.explode
		M.targeting_ability = R
		M.update_cursor()
		return 1

/proc/pixelmagic(explode=TRUE)
	var/mob/M = usr
	var/datum/targetable/pixelpicker/R = new()
	R.explode = explode
	M.targeting_ability = R
	M.update_cursor()

/proc/dothepixelthing(var/atom/movable/A, pixel_type=/obj/apixel, explode=TRUE)
	if (isturf(A)) //deleting turfs is bad!
		return

	if(istype(A, /obj/item/apixel) || istype(A, /obj/apixel))
		return

	//large objects + pixel explosion effects = world ending amounts of lag
	if (A.bound_width > 32 || A.bound_height > 32)
		return

	if (ismob(A)) //deleting mobs crashes them - lets transfer their client to a ghost first
		var/mob/M = A
		M.ghostize()

	var/list/pixels = list()
	var/icon/I = getFlatIcon(A)
	var/atom/movable/AT = A.loc

	if(explode)
		playsound(AT, 'sound/effects/ExplosionFirey.ogg', 75, TRUE)
	for(var/y = 1, y <= I.Height(), y++)
		for(var/x = 1, x <= I.Width(), x++)
			var/color = I.GetPixel(x, y)
			if(color != null)
				var/actX = A.pixel_x + x - 1 - 16
				var/actY = A.pixel_y + y - 1 - 16
				var/obj/P = new pixel_type(A.loc, A)
				P.pixel_x = actX
				P.pixel_y = actY
				P.color = color
				P.layer = 15
				if(explode)
					animate_explode_pixel(P)
				pixels += P

	qdel(A)
	if(explode)
		SPAWN(7 SECONDS)
			for(var/datum/D in pixels)
				qdel(D)

/obj/apixel
	name = ""
	desc = "this is a single pixel. wow."
	icon = 'icons/effects/1x1.dmi'
	icon_state = "pixel"
	anchored = ANCHORED
	density = 0
	opacity = 0
	pixel_z = 16
	pixel_w = 16

/obj/item/apixel
	name = ""
	desc = "This is a single pixel. Wow."
	icon = 'icons/effects/1x1.dmi'
	icon_state = "pixel"
	pixel_z = 16
	pixel_w = 16
	var/got_renamed = FALSE

	New(loc, atom/original)
		..(loc)
		src.name = original.name
		src.desc = "This is a single pixel of [original.name]. Wow."

	pickup(mob/user)
		. = ..()
		icon = 'icons/effects/white.dmi'
		if(!got_renamed)
			got_renamed = TRUE
			name = "pixel of [name]"

	dropped(mob/user)
		. = ..()
		src.icon = initial(icon)

/obj/item/craftedmelee/spear
	name = "spear"
	desc = "it's an improvised spear."
	icon = null

	New()
		..()
		src.setItemSpecial(/datum/item_special/rangestab)
		BLOCK_SETUP(BLOCK_ROD)

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

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		return ..(target,user)

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

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if(!item1 || !item2)
			src.fall_apart()
			return

		var/r = rand(0,100)

		if (r <= 70)
			if(r < 35)
				return item1.attack(target, user, def_zone)
			else
				return item2.attack(target, user, def_zone)
		else
			if(r < 90)
				SPAWN(0)
					item1.attack(target, user, def_zone)
					item2.attack(target, user, def_zone)
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
				return item1.AttackSelf(user)
			else
				return item2.AttackSelf(user)
		else
			if(r <= 80)
				SPAWN(0)
					item1.AttackSelf(user)
					item2.AttackSelf(user)
				return
			else
				src.fall_apart(user)
				return

	proc/fall_apart(var/mob/holder)
		boutput(holder,"[src] bursts apart in your hand!")
		if (prob(70) && item1)
			holder.Attackby(item1, holder)
		if (prob(70) && item2)
			holder.Attackby(item2, holder)
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

/obj/largetest
	name = "test"
	desc = ""
	anchored = ANCHORED
	density = 1
	opacity = 0
	icon = 'icons/misc/512x512.dmi'
	icon_state = "0,0"

/obj/peninscription
	name = "mysterious inscription"
	desc = "It's some form of inscription. It reads 'nij ud-bi-ta la-ba-jal-la: ki-sikil tur ur dam-ma-na-ka ce nu-ub-dur-re'. There is a small pictogram below it."
	anchored = ANCHORED
	density = 0
	opacity = 0
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "pen"

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/device/key))
			boutput(user, "[W] disappears suddenly as you bring it close to the inscription ... huh")
			del(W)
		if(istype(W,/obj/item/pen))
			boutput(user, "A terrible noise fills the air as the inscription seemingly rejects [W].")
			playsound(src.loc, "hellhorn_12.ogg", 100, 1)
		return

/obj/decal/nothing
	name = "nothing"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "blank"
	anchored = ANCHORED_ALWAYS
	density = 0
	opacity = 0
	plane = PLANE_ABOVE_LIGHTING

/obj/decal/nothingplug
	name = "nothing"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "blank-plug"
	anchored = ANCHORED
	density = 0
	opacity = 0
	plane = PLANE_ABOVE_LIGHTING

/obj/decal/hfireplug
	name = "fire"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "hfireplug"
	anchored = ANCHORED
	density = 0
	opacity = 0

/obj/decal/hfire
	name = "fire"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "hfire"
	anchored = ANCHORED
	density = 0
	opacity = 0

/obj/decal/tileswish
	name = "nothing"
	icon = 'icons/obj/decals/misc.dmi'
	icon_state = "tileswish"
	anchored = ANCHORED
	density = 0
	opacity = 0

/obj/decal/swirlthing
	name = "vortex"
	desc = "a swirling blue vortex"
	icon = 'icons/effects/effects.dmi'
	icon_state = "swirlthing"
	anchored = ANCHORED
	density = 0
	opacity = 0

/obj/item/teslacannon
	desc = "An experimental piece of syndicate technology."
	name = "Tesla cannon"
	icon = 'icons/obj/items/guns/energy.dmi'
	icon_state = "teslacannon"
	item_state = "gun"
	flags = EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_TINY
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
			playsound(user, pick(sounds), 15, 1)
			current = get_step(current, get_dir(current, trg_loc))
			user.set_dir(get_dir(user, current))
			var/obj/beam_dummy/B = showLine(get_turf(user), current, "lght", 5)
			var/list/affected = B.affected
			for(var/turf/T in affected)
				animate_flash_color_fill(T,"#aaddff",1,5)
				for(var/mob/M in T)
					M.changeStatus("knockdown", 2 SECONDS)
					random_burn_damage(M, 10)

				if(istype(T, /turf/simulated/floor))
					if(!T:broken)
						if(T:burnt)
							T:break_tile()
						else
							T:burn_tile()
			SPAWN(0.6 SECONDS) qdel(B)
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
	anchored = ANCHORED
	opacity = 0
	invisibility = INVIS_ALWAYS_ISH
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

	mouse_drop(over_object,src_location,over_location,src_control,over_control,params)
		var/turf/trgTurf = get_turf(over_object)
		if(istype(trgTurf))
			switch(alert("Do you want to create a copy of the trigger on this tile?",,"Yes","No"))
				if("Yes")
					copy_to(trgTurf)
					boutput(usr, SPAN_SUCCESS("*** All done ***"))
				if("No")
					return
		return

	Crossed(atom/movable/O)
		..()
		if(!canTrigger) return
		canTrigger = 0
		SPAWN(procCooldown) canTrigger = 1

		if(length(procName))
			var/list/modList = list()

			for(var/x in procArgs)
				if(x == "*triggering object*")
					modList += O
				else
					modList += x

			if (procTarget)
				if(procTarget == "*triggering object*")
					if(hascall(O, procName))
						call(O,procName)(arglist(modList))
				else
					if(hascall(procTarget, procName))
						call(procTarget,procName)(arglist(modList))
			else
				call(procName)(arglist(modList))
		return

	Click()
		USR_ADMIN_ONLY
		var/target = null

		switch(alert("Proc owned by obj?",,"Yes","No"))
			if("Yes")
				switch(alert("Proc owned by triggering object?",,"Yes","No"))
					if("Yes")
						target = "*triggering object*"
					if("No")
						target = input("Select target:","Target",null) as obj|mob|area|turf in world
			if("No")
				target = null

		var/procname = input("Procpath","path:", null) as text
		var/list/listargs = usr.client.get_proccall_arglist(custom_options = list("*triggering object*"))

		procArgs = listargs
		procName = procname
		procTarget = target
		boutput(usr, SPAN_SUCCESS("*** All done ***"))

		return

	ex_act()
		return

/obj/objspawner			   //Thing that continously spawns objects. For event's or something. I wouldn't use this on the actual map. It's not very efficient.
	name = "ObjSpawner"
	desc = "If you see this and you're not an admin then that's sorta bad."
	icon = 'icons/misc/mark.dmi'
	icon_state = "rup"
	density = 0
	anchored = ANCHORED
	opacity = 0
	invisibility = INVIS_ALWAYS_ISH
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
		SPAWN(spawn_check_rate)
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
			boutput(usr, SPAN_SUCCESS("*** All done ***"))
		return

	New()
		SPAWN(0) runIt()
		return ..()

	ex_act()
		return

/proc/gobuzz()
	if(buzztile)
		usr.set_loc(buzztile)
	return

/obj/item/beamtest
	desc = "beamtest thingamobob"
	name = "beamtest thingamobob"
	icon = 'icons/obj/items/alchemy.dmi'
	icon_state = "pstone"
	item_state = "injector"
	flags = EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_TINY

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
	anchored = ANCHORED
	opacity = 0
	layer = NOLIGHT_EFFECTS_LAYER_BASE
	pixel_y = -16
	var/list/affected = list() //List of crossed tiles.
	var/origin_angle = -1
	var/atom/origin = null
	var/atom/target = null

/obj/candle_light_2spoopy
	icon = 'icons/obj/items/alchemy.dmi'
	icon_state = "candle"
	name = "spooky candle"
	desc = "It's a big candle. It's also floating."
	density = 0
	anchored = ANCHORED
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

		SPAWN(rand(1,10))
			animate(src, pixel_y = 32, transform = matrix(spoopydegrees, MATRIX_ROTATE), time = 20, loop = -1, easing = SINE_EASING)
			animate(pixel_y = 0, transform = matrix(-1 * spoopydegrees, MATRIX_ROTATE), time = 20, loop = -1, easing = SINE_EASING)


//Really sorry about the shitty code below. I couldn't be arsed to do it properly.
/obj/candle_light
	icon = 'icons/obj/items/alchemy.dmi'
	icon_state = "candle"
	name = "candle"
	desc = "It's a big candle"
	density = 0
	anchored = ANCHORED
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
	plane = PLANE_ABOVE_LIGHTING
	desc = ""
	anchored = ANCHORED
	density = 0
	opacity = 0
	mouse_opacity = 0

/obj/elec_trg_dummy
	name = ""
	desc = ""
	anchored = ANCHORED
	density = 0
	opacity = 0
	invisibility = INVIS_ALWAYS_ISH
	mouse_opacity = 0
/*
/obj/item/rpg_rocket_shuttle
	name = "MPRT rocket"
	desc = "A rocket-propelled grenade with a HEAT warhead."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "rpg_rocket"
	item_state = "chips"
	w_class = W_CLASS_NORMAL
	throw_speed = 2
	throw_range = 10
	force = 5
	flags = TABLEPASS | CONDUCT
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
			src.current = locate(clamp(src.x + src.xo, 1, world.maxx), clamp(src.y + src.yo, 1, world.maxy), src.z)
		if ((src.x == 1 || src.x == world.maxx || src.y == 1 || src.y == world.maxy))
			qdel(src)
			return
		step_towards(src, src.current)
		SPAWN( 1 )
			process()
			return
		return

	bump(atom/movable/AM as mob|obj)
		if(!state)
			..()
			return
		explode()

/obj/shuttle_cannon
	name = "Shuttle Cannon"
	desc = "Pew Pew"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "shuttlecannonthing"
	anchored = ANCHORED
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

		SPAWN(1 DECI SECOND)
			playsound(src, 'sound/weapons/rocket.ogg', 50, TRUE)

			var/obj/item/rpg_rocket/R = new

			R.set_loc(get_step(src, src.dir))
			R.set_density(1)
			R.state = 1
			R.current = fire_target_tile
			R.yo = fire_target_tile.y - src.y
			R.xo = fire_target_tile.x - src.x

			R.process()

		SPAWN(2.5 SECONDS) ready = 1
*/

/obj/movable_area_controller
	name = "controller"
	desc = "Don't move this thing or you're gonna have a bad time."
	icon = 'icons/obj/objects.dmi'
	icon_state = "stool"
	anchored = ANCHORED
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

		if(length(newareaturfs) < oldareaturfs.len) //Out of bounds. Fucking byond.
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
				T.ReplaceWithSpaceForce()

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

	SPAWN(0)
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
	desc = "A rip in time and space."
	opacity = 0
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/adventurezones/void.dmi'
	icon_state = "fissure"

	Bumped(atom/movable/AM)
		var/obj/source = locate(/obj/dfissure_from)
		if (!istype(source))
			qdel(src)
			return
		var/turf/trg = source.loc
		AM.set_loc(trg)

	New()
		. = ..()
		START_TRACKING

	disposing()
		STOP_TRACKING
		. = ..()

/obj/dfissure_from
	name = "dimensional fissure"
	desc = "A rip in time and space."
	opacity = 0
	density = 1
	anchored = ANCHORED
	icon = 'icons/obj/adventurezones/void.dmi'
	icon_state = "fissure"

	Bumped(atom/movable/AM)
		var/obj/source = locate(/obj/dfissure_to)
		if (!istype(source))
			boutput(AM, SPAN_COMBAT("You try to squeeze into the hole in space-time, but it's really dense right now!  Weird!  Who knew holes in reality could be so strange?!"))
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
	if(length(eligible) > 0)
		picked1 = pick(eligible)
		eligible -= picked1

	var/mob/living/carbon/human/picked2
	if(length(eligible) > 0)
		picked2 = pick(eligible)

	picked1?.zombify()

	picked2?.zombify()

	for(var/turf/T in random_floor_turfs)
		if(prob(3))
			new/obj/item/sheet/wood(T)
			new/obj/item/sheet/wood(T)
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
	boutput(src, SPAN_ALERT("########################################"))
	boutput(src, SPAN_ALERT("You have turned into a zombie."))
	boutput(src, SPAN_ALERT("To infect other players, you must knock"))
	boutput(src, SPAN_ALERT("them down and then attack them with your"))
	boutput(src, SPAN_ALERT("bare hands and the harm intent."))
	boutput(src, SPAN_ALERT("########################################"))

/obj/item/boomerang
	name = "Boomerang"
	desc = "A Boomerang."
	inhand_image_icon = 'icons/mob/inhand/hand_weapons.dmi'
	item_state = "boomerang"

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
		BLOCK_SETUP(BLOCK_LARGE)

	throw_begin(atom/target)
		icon_state = "boomerang1"
		playsound(src.loc, "rustle", 50, 1)
		return ..(target)

	throw_impact(atom/hit_atom, datum/thrown_thing/thr)
		icon_state = "boomerang"
		if(ishuman(thr.user))
			var/mob/living/carbon/human/user = thr.user
			if(hit_atom == user)
				if(prob(prob_clonk))
					user.visible_message(SPAN_ALERT("<B>[user] fumbles the catch and is clonked on the head!</B>"))
					playsound(user.loc, 'sound/impact_sounds/Flesh_Break_1.ogg', 50, 1)
					user.changeStatus("stunned", 5 SECONDS)
					user.changeStatus("knockdown", 3 SECONDS)
					user.changeStatus("unconscious", 2 SECONDS)
					user.force_laydown_standup()
				else
					src.Attackhand(user)
				return
			else
				if(ishuman(hit_atom))
					var/mob/living/carbon/human/H = hit_atom
					if(istype(user?.w_uniform, /obj/item/clothing/under/gimmick/safari) && istype(user?.head, /obj/item/clothing/head/safari))
						H.changeStatus("stunned", 4 SECONDS)
						H.changeStatus("knockdown", 2 SECONDS)
						H.force_laydown_standup()
						//H.paralysis++
						playsound(H.loc, "swing_hit", 50, 1)

					prob_clonk = min(prob_clonk + 5, 40)
					SPAWN(2 SECONDS)
						prob_clonk = max(prob_clonk - 5, 0)

			return ..(hit_atom)

/proc/mod_color(var/atom/A)
	SET_ADMIN_CAT(ADMIN_CAT_UNUSED)
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
			targetThing += "[get_area(target)]"
			logTheThing(LOG_ADMIN, usr, "created a portal at [log_loc(selected)] ([get_area(selected)]) pointing to [log_loc(target)] ([targetThing])")
			logTheThing(LOG_DIARY, usr, "created a portal at [selected.x], [selected.y], [selected.z] ([get_area(selected)]) pointing to [target.x], [target.y], [target.z] ([targetThing])", "admin")
			message_admins("[key_name(usr)] created a portal at [log_loc(selected)] ([get_area(selected)]) pointing to [log_loc(target)] ([targetThing])")
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
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Create Portal"
	set popup_menu = 0

	ADMIN_ONLY
	SHOW_VERB_DESC

	var/mob/M = src.mob
	if (istype(M))
		alert("Click on where you want your portal to end up at",,"Ok")
		var/datum/targetable/portalpickerTarget/R = new()
		M.targeting_ability = R
		M.update_cursor()
		return

/obj/laser_sink/perm_portal //this path is FINE, shut UP
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	anchored = ANCHORED
	density = 1
	opacity = 0
	var/atom/target = null
	var/target_tag = null
	var/datum/light/light

	var/obj/linked_laser/out_laser = null

	New()
		..()
		light = new /datum/light/point
		light.set_color(0.3, 0.6, 0.8)
		light.set_brightness(1)
		light.attach(src)
		light.enable()
		SPAWN(0.6 SECONDS)
			if (target_tag)
				target = locate(target_tag)

	incident(obj/linked_laser/laser)
		if (src.in_laser) //no infinite loops allowed
			return FALSE
		src.in_laser = laser
		src.out_laser = laser.copy_laser(get_turf(target), laser.dir)
		laser.next = src.out_laser
		src.out_laser.try_propagate()
		return TRUE

	exident(obj/linked_laser/laser)
		qdel(src.out_laser)
		src.out_laser = null
		..()

	Bumped(atom/movable/AM)
		if(target && istype(target))
			if(ismob(AM))
				logTheThing(LOG_STATION, AM, "entered [src] at [log_loc(src)] and teleported to [log_loc(target)]")
			if (istype(AM, /obj/critter/gunbot/drone)) //stop teleporting the damn y-drone!
				var/obj/critter/gunbot/drone/drone = AM
				logTheThing(LOG_STATION, drone, "entered [src] at [log_loc(src)] and teleported to [log_loc(target)] while chasing [key_name(drone.target)]")
			AM.set_loc(target)
		else
			src.visible_message("<span style='color: red; font-weight: bold'>The portal collapses in on itself!</span>")
			var/obj/sparks = new /obj/effects/sparks
			sparks.set_loc(get_turf(src))
			SPAWN(2 SECONDS) if (sparks) qdel(sparks)
			qdel(src)

	attack_hand(var/mob/M)
		..()
		if (get_turf(M) == get_turf(src) && !ON_COOLDOWN(M, "portal_click", 1 SECOND))
			src.Bumped(M)

	ex_act()
		return

	Click(location, control, params)
		if (isobserver(usr))
			usr.set_loc(src.target)
			return
		..()

////////////////////////////////////////////////////////////////////////////////////////
/* var/list/raisinlist = new/list()

/proc/for_no_raisin(var/mob/M, text)
	if(findtext(text,"for no raisin"))
		if(M.client)
			if(!(M.client in raisinlist) && isliving(M))
				boutput(M, SPAN_ALERT("A raisin mysteriously materializes right next to your feet..."))
				new/obj/item/reagent_containers/food/snacks/raisin(get_turf(M))
				raisinlist += M.client
	return

/obj/item/reagent_containers/food/snacks/raisin
	name = "raisin"
	desc = "A single raisin..."
	icon_state = "raisin"
	amount = 1
	heal_amt = 5

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if(ishuman(target))
			if(target == user)
				target.nutrition += src.heal_amt * 10
				target.poo += 1
				src.heal(target)
				playsound(target.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
				boutput(user, SPAN_ALERT("You eat the raisin and shed a single tear as you realise that you now have no raisin."))
				qdel(src)
				return 1
			else
				for(var/mob/O in viewers(world.view, user))
					O.show_message(SPAN_ALERT("[user] attempts to feed [target] [src]."), 1)
				if(!do_mob(user, target)) return
				for(var/mob/O in viewers(world.view, user))
					O.show_message(SPAN_ALERT("[user] feeds [target] [src]."), 1)
				src.amount--
				target.nutrition += src.heal_amt * 10
				target.poo += 1
				src.heal(target)
				playsound(target.loc, 'sound/items/eatfood.ogg', rand(10,50), 1)
				boutput(user, SPAN_ALERT("[target] eats the raisin."))
				qdel(src)
				return 1
		return 0 */


//1.5 would be 50% slower, 2.0 would be 100% slower etc.
var/const/lag_average_size = 20			 //Number of samples the average is based on.

var/lag_string = "Yes"//"none"

var/average_tenth = 1
var/list/lag_list = new/list()

/proc/add_and_average(var/value)
	lag_list.Insert(1,value)
	if(length(lag_list) > lag_average_size) lag_list.Cut(lag_average_size+1,0)
	var/tempnum = 0
	for(var/a in lag_list)
		tempnum += a
	if(length(lag_list) >= lag_average_size) average_tenth = (tempnum / lag_list.len)

	switch( ((average_tenth * world.cpu) / 100) )
		if(0 to 0.1)
			lag_string = "Minimal"
		if(0.101 to 0.18)
			lag_string = "Normal"
		if(0.181 to 0.35)
			lag_string = "High"
		if(0.351 to 0.5)
			lag_string = "Very High"
		if(0.501 to INFINITY)
			lag_string = "Oh Sh*t"

/proc/lag_loop()
	var/before = world.timeofday
	sleep(0.1 SECONDS)
	add_and_average( (world.timeofday - before) )
	SPAWN(0.5 SECONDS) lag_loop()

/proc/get_lag_average()
	boutput(usr, SPAN_SUCCESS("[average_tenth] at [lag_list.len] samples."))


/obj/item/spook
	var/active = 0
	invisibility = INVIS_ALWAYS_ISH
	anchored = ANCHORED
	density = 0
	icon = 'icons/misc/hstation.dmi'
	icon_state = "null"
	desc = "What ... what is this?"
	name = "apparition"
	var/turf/startloc

	New()
		startloc = get_turf(src)
		processing_items.Add(src)
		. = ..()

	disposing()
		processing_items.Remove(src)
		. = ..()

	process()
		if(!active)
			for(var/mob/living/L in hearers(world.view, src))
				if(prob(20))
					SPAWN(0)
						spook(L)
				break

	proc/spook(var/mob/living/L)
		playsound(L, 'sound/effects/ghost.ogg', 5, FALSE)
		sleep(0.3 SECONDS)
		active = 1
		walk_towards(src,L,3)
		src.invisibility = INVIS_NONE
		FLICK("apparition",src)
		sleep(1.5 SECONDS)
		src.invisibility = INVIS_ALWAYS_ISH
		src.set_loc(startloc)
		walk(src,0)
		SPAWN(10 SECONDS)
			active = 0

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
			boutput(usr, SPAN_NOTICE("Done."))
		else
			boutput(usr, SPAN_ALERT("Not a linkabled object."))
		return

/datum/engibox_mode/reqacc
	name = "Set Required Access"
	desc = "Allows you to set the required Access-level of most objects."
	used(atom/user, atom/target)
		if(istype(target, /obj/machinery/door))
			if(hasvar(target, "req_access"))
				target:req_access = get_access(input(usr) in get_all_jobs() + "Club member")
				boutput(usr, SPAN_NOTICE("Done."))
			else
				boutput(usr, SPAN_ALERT("Invalid object."))
		return

/datum/engibox_mode/spawnid
	name = "Spawn ID card"
	desc = "Allows you to spawn an id card with a certain access level."
	used(atom/user, atom/target)
		var/obj/item/card/id/gold/D = new/obj/item/card/id/gold(get_turf(target))
		D.access = get_access(input(usr) in get_all_jobs() + "Club member")
		D.registered = "Member"
		D.assignment = "Member"
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
		L.set_dir(user:dir)
		L.on = 1
		L.update()
		return

/datum/engibox_mode/buttonpod
	name = "Place Button"
	desc = "Places a Button that can control mass-drivers & pod-doors."
	used(atom/user, atom/target)
		var/obj/machinery/activation_button/driver_button/L = new(get_turf(target))
		L.set_dir(user:dir)
		return

/datum/engibox_mode/buttonconvey
	name = "Place Conveyor switch"
	desc = "Places a Conveyor switch that can control a conveyor belt."
	used(atom/user, atom/target)
		var/obj/machinery/conveyor_switch/L = new/obj/machinery/conveyor_switch(get_turf(target))
		L.set_dir(user:dir)
		return

/datum/engibox_mode/conveyor
	name = "Place Conveyor belt"
	desc = "Places a Conveyor belt - facing the direction you are facing."
	used(atom/user, atom/target)
		var/obj/machinery/conveyor/L = new/obj/machinery/conveyor(get_turf(target))
		L.dir_in = user.dir
		L.dir_out = turn(user.dir, 180)
		return

/datum/engibox_mode/poddoor
	name = "Place Pod-Door"
	desc = "Places a Pod-Door."
	used(atom/user, atom/target)
		var/obj/machinery/door/poddoor/L = new/obj/machinery/door/poddoor(get_turf(target))
		L.set_dir(user:dir)
		return

/datum/engibox_mode/driver
	name = "Place Mass-Driver"
	desc = "Places a Mass-Driver - facing the direction you are facing."
	used(atom/user, atom/target)
		var/obj/machinery/mass_driver/L = new/obj/machinery/mass_driver(get_turf(target))
		L.set_dir(user:dir)
		return

/datum/engibox_mode/cam
	name = "Place Security Camera"
	desc = "Places a Security Camera - using your direction."
	used(atom/user, atom/target)
		var/obj/machinery/camera/L = new/obj/machinery/camera(get_turf(target))
		L.set_dir(user:dir)
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
		var/obj/mesh/grille/L = new/obj/mesh/grille/steel(get_turf(target))
		L.set_dir(user:dir)
		return

/datum/engibox_mode/table
	name = "Place Reinforced Table"
	desc = "Places a Reinforced Table."
	used(atom/user, atom/target)
		var/obj/table/reinforced/L = new/obj/table/reinforced(get_turf(target))
		L.set_dir(user:dir)
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
			boutput(usr, SPAN_NOTICE("Placed: [A.name]"))
		else
			obj_path = target.type
			boutput(usr, SPAN_NOTICE("Now replicating: [target.name]s"))
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
		boutput(usr, SPAN_NOTICE("Target density now: [target.density]"))
		return

/datum/engibox_mode/opacity
	name = "Toggle opacity"
	desc = "Toggles the opacity of an object."
	used(atom/user, atom/target)
		target.set_opacity(!target.opacity)
		boutput(usr, SPAN_NOTICE("Target opacity now: [target.opacity]"))
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
	flags = EXTRADELAY | TABLEPASS | CONDUCT
	w_class = W_CLASS_TINY
	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(ckey_lock && user.ckey != ckey_lock)
			boutput(user, SPAN_ALERT("You are not authorized to use this item."))
			return
		if(BOUNDS_DIST(target, user) > 0)
			boutput(user, SPAN_ALERT("You are too far away."))
			return
		if(target == loc) return
		var/turf/T = get_turf(src)
		if(z_level_lock && T.z != z_level_lock)
			boutput(user, SPAN_ALERT("\The [src] is not authorized to be used outside official NanoTrasen stations."))
			return
		active_mode?.used(user, target)
		return

	attack()
		return

	attack_self(mob/user as mob)
		if(ckey_lock && user.ckey != ckey_lock)
			boutput(user, SPAN_ALERT("You are not authorized to use this item."))
			return
		var/dat = "Engie-box modes:<BR><BR>"
		for(var/datum/engibox_mode/D in modes)
			dat += "<A href='byond://?src=\ref[src];set_mode=\ref[D]'>[D.name]</A> [active_mode == D ? "<<<" : ""]<BR>"
			dat += "[D.desc]<BR><BR>"
		user.Browse(dat, "window=engibox;can_minimize=0;can_resize=0;size=250x600")
		onclose(user, "window=engibox")
		return

	Topic(href, href_list)
		if(usr.stat || usr.restrained()) return
		if(!in_interact_range(src, usr)) return
		src.add_dialog(usr)
		if (href_list["set_mode"])
			active_mode = locate(href_list["set_mode"]) in modes

			if(active_mode.requires_input)
				active_mode.saved_var = input(usr,"Enter ID","ID","MyId") as text
				if(!active_mode.saved_var || isnull(active_mode.saved_var)) active_mode = null

			if(istype(active_mode,/datum/engibox_mode/transmute)) //You only have yourself to blame for this. This shitty code is the fault of whoever changed this!!!
				active_mode:mat_id = input(usr,"Select material","material","gold") in list("gold", "steel", "mauxite", "pharosium","cobryl","bohrum","cerenkite","syreline","glass","molitz","claretine","erebite","plasmastone","plasmaglass","quartz","uqill","telecrystal","miraclium","starstone","flesh","char","koshmarite","viscerite","beeswax","latex","synthrubber","synthblubber","brullbarhide","cotton","fibrilith")

			if(istype(active_mode,/datum/engibox_mode/replicate))
				active_mode:obj_path = null

			src.AttackSelf(usr)
			return
		src.AttackSelf(usr)
		src.add_fingerprint(usr)
		return

	New()
		..()
		for(var/D in typesof(/datum/engibox_mode) - /datum/engibox_mode)
			modes += new D

/obj/item/engibox/station_locked
	z_level_lock = 1 // 1 = station z level

/obj/signpost
	icon = 'icons/misc/old_or_unused.dmi'
	icon_state = "signpost"
	anchored = ANCHORED
	density = 1

	attackby(obj/item/W, mob/user)
		return attack_hand(user)

	attack_hand(mob/user)
		switch(alert("Travel back to ss13?",,"Yes","No"))
			if("Yes")
				user.set_loc(pick_landmark(LANDMARK_LATEJOIN))
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
		SPAWN(1 SECOND)
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
