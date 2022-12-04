/**
  * Returns the plural based on a number provided.
  *
  * @param number the number to base the judgement off of
  * @param es set this to true if your item's plural ends in "es"
  * @return the plural suffix based on numbers
  */
/proc/s_es(var/number as num, var/es = 0)
	if (isnull(number))
		return
	if (number == 1)
		return null
	else
		if (es)
			return "es"
		else
			return "s"

/**
  * Returns true if the char you feed it is uppercase.
  */
/proc/isUpper(var/test)
	if(length(test) > 1)
		test = copytext(test, 1, 2)
	return test == uppertext(test)

/**
  * Shows the calling client admins.txt
  */
/proc/showadminlist()
	usr.client.Export("##action=browse_file","config/admins.txt")

/**
  * Returns the line matrix from a start atom to an end atom, used in creating line objects
  */
/proc/getLineMatrix(var/atom/start, var/atom/end)
	var/angle = get_angle(start, end)

	var/lx = abs(start.x - end.x)
	var/ly = abs(start.y - end.y)
	var/beamlen = sqrt((lx * lx) + (ly * ly))

	var/matrix/retMatrix = matrix()
	retMatrix.Scale(1, beamlen / 2)
	retMatrix.Translate(1, (((beamlen/2) * 64) / 2))
	retMatrix.Turn(angle)

	return retMatrix

/**
  * Creates and shows a line object. Line object has an "affected" var that contains the cross tiles.
  */
/proc/showLine(var/atom/start, var/atom/end, s_icon_state = "lght", var/animate = 0, var/get_turfs=1)
	var/angle = get_angle(start, end)
	var/anglemod = (-(angle < 180 ? angle : angle - 360) + 90) //What the fuck am i looking at
	var/lx = abs(start.x - end.x)
	var/ly = abs(start.y - end.y)
	var/beamlen = sqrt((lx * lx) + (ly * ly))
	var/obj/beam_dummy/B = new/obj/beam_dummy(get_turf(start))

	if(get_turfs) B.affected = castRay(start, anglemod, beamlen)

	B.origin_angle = angle
	B.icon_state = s_icon_state
	B.origin = start
	B.target = end

	var/matrix/M
	if(animate)
		B.transform = matrix(turn(B.transform, angle), 1, 0.1, MATRIX_SCALE)
		var/matrix/second = matrix(1, beamlen / 2, MATRIX_SCALE)
		second.Translate(1, (((beamlen / 2) * 64) / 2))
		second.Turn(angle)
		animate(B, transform = second, time = animate, loop = 1, easing = LINEAR_EASING)
	else
		M = B.transform
		M.Scale(1, beamlen / 2)
		M.Translate(1, (((beamlen/2) * 64) / 2))
		M.Turn(angle)
		B.transform = M

	return B

var/global/obj/flashDummy

/proc/getFlashDummy()
	if (!flashDummy)
		flashDummy = new /obj(null)
		flashDummy.set_density(0)
		flashDummy.set_opacity(0)
		flashDummy.anchored = 1
		flashDummy.mouse_opacity = 0
	return flashDummy

/proc/arcFlashTurf(var/atom/from, var/turf/target, var/wattage, var/volume = 30)
	var/obj/O = getFlashDummy()
	O.set_loc(target)
	playsound(target, 'sound/effects/elec_bigzap.ogg', volume, 1)

	var/list/affected = DrawLine(from, O, /obj/line_obj/elec ,'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",OBJ_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

	for(var/obj/Q in affected)
		SPAWN(0.6 SECONDS) qdel(Q)

	for(var/mob/living/M in get_turf(target))
		M.shock(from, wattage, "chest", 1, 1)

	var/elecflashpower = 0
	if (wattage > 12000)
		elecflashpower = 6
	else if (wattage > 7500)
		elecflashpower = 5
	else if (wattage > 5000)
		elecflashpower = 4
	else if (wattage > 2500)
		elecflashpower = 3
	else if (wattage > 1200)
		elecflashpower = 2

	elecflash(target,power = elecflashpower)
	O.set_loc(null)

/proc/arcFlash(var/atom/from, var/atom/target, var/wattage, stun_coeff = 1)
	var/target_r = target
	if (isturf(target))
		var/obj/O = getFlashDummy()
		O.set_loc(target)
		target_r = O
	if(wattage && isliving(target)) //Grilles can reroute arcflashes
		for(var/obj/grille/L in range(target,1)) // check for nearby grilles
			var/arcprob = L.material?.getProperty("electrical") >= 6 ? 60 : 30
			if(!L.ruined && L.anchored)
				if (prob(arcprob) && L.get_connection()) // hopefully half the default is low enough
					target = L
					target_r = L
					continue

	playsound(target, 'sound/effects/elec_bigzap.ogg', 30, 1)

	var/list/affected = DrawLine(from, target_r, /obj/line_obj/elec ,'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",OBJ_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

	for(var/obj/O in affected)
		SPAWN(0.6 SECONDS) qdel(O)

	if(wattage && isliving(target)) //Probably unsafe.
		target:shock(from, wattage, "chest", stun_coeff, 1)
	if (isobj(target))
		if(wattage && istype(target, /obj/grille))
			var/obj/grille/G = target
			G.lightningrod(wattage)
	var/elecflashpower = 0
	if (wattage > 12000)
		elecflashpower = 6
	else if (wattage > 7500)
		elecflashpower = 5
	else if (wattage > 5000)
		elecflashpower = 4
	else if (wattage > 2500)
		elecflashpower = 3
	else if (wattage > 1200)
		elecflashpower = 2

	elecflash(target,power = elecflashpower)

proc/castRay(var/atom/A, var/Angle, var/Distance) //Adapted from some forum stuff. Takes some sort of bizzaro angles ?! Aahhhhh
	var/list/crossed = list()
	var/xPlus=cos(Angle)
	var/yPlus=sin(Angle)
	var/Runs=round(Distance+0.5)
	if(!isturf(A))
		if(isturf(A.loc))
			A=A.loc
		else
			return 0
	for(var/v=1 to Runs)
		set background = 1
		var/X=A.x+round((xPlus*v)+0.5)
		var/Y=A.y+round((yPlus*v)+0.5)
		var/turf/T=locate(X,Y,A.z)
		if(T)
			if(!(T in crossed)) crossed.Add(T)
	return crossed

/**
	* Returns the angle between two given atoms
	*/
proc/get_angle(atom/a, atom/b)
    .= arctan(b.y - a.y, b.x - a.x)

/turf/var/movable_area_next_type = null
/turf/var/movable_area_prev_type = null

/proc/get_steps(var/atom/ref, var/dir, var/numsteps)
	var/atom/res = null
	switch(dir)
		if(NORTH)
			res = locate(ref.x, ref.y+numsteps, ref.z)
		if(NORTHEAST)
			res = locate(ref.x+numsteps, ref.y+numsteps, ref.z)
		if(EAST)
			res = locate(ref.x+numsteps, ref.y, ref.z)
		if(SOUTHEAST)
			res = locate(ref.x+numsteps, ref.y-numsteps, ref.z)
		if(SOUTH)
			res = locate(ref.x, ref.y-numsteps, ref.z)
		if(SOUTHWEST)
			res = locate(ref.x-numsteps, ref.y-numsteps, ref.z)
		if(WEST)
			res = locate(ref.x-numsteps, ref.y, ref.z)
		if(NORTHWEST)
			res = locate(ref.x-numsteps, ref.y+numsteps, ref.z)
	return res
/*
/proc/get_steps(var/atom/ref, var/direction, var/numsteps)
	var/atom/curr = ref
	for(var/num=0, num<numsteps, num++)
		curr = get_step(curr, direction)
	return curr
*/

/proc/movable_area_check(var/atom/A)
	if(!A.loc) return 0
	if(!A) return 0
	if(A.x > world.maxx) return 0
	if(A.x < 1) return 0
	if(A.y > world.maxy) return 0
	if(A.y < 1) return 0
	if(A.density) return 0
	for(var/atom/curr in A)
		if(curr.density) return 0
	return 1

/proc/do_mob(var/mob/user , var/atom/target as turf|obj|mob, var/time = 30) //This is quite an ugly solution but i refuse to use the old request system.
	if(!user || !target) return 0
	. = 0
	var/user_loc = user.loc
	var/target_loc = target.loc
	var/holding = user.equipped()
	sleep(time)
	if (!user || !target)
		return 0
	if ( user.loc == user_loc && target.loc == target_loc && user.equipped() == holding && !is_incapacitated(user) && !user.lying )
		return 1

/proc/do_after(mob/M as mob, time as num)
	if (!ismob(M))
		return 0
	. = 0
	var/turf/T = M.loc
	var/atom/holding = M.equipped()
	sleep(time)
	if (M.loc == T && M.equipped() == holding && isalive(M) && !holding?.disposed)
		return 1

/proc/is_blocked_turf(var/turf/T)
	// drsingh for cannot read null.density
	if (!T) return 0
	if(T.density) return 1
	for(var/atom/A in T)
		if(A?.density)//&&A.anchored
			return 1
	return 0

//is_blocked_turf for flock
/proc/flock_is_blocked_turf(var/turf/T)
	if (!T) return FALSE
	if(T.density) return TRUE
	for(var/atom/A in T)
		if(A?.density && !isflockmob(A))//ignores flockdrones/flockbits
			return TRUE
	return FALSE

/proc/get_edge_cheap(var/atom/A, var/direction)
	. = A.loc
	switch(direction)
		if(NORTH)
			. = locate(A.x, world.maxy, A.z)
		if(NORTHEAST)
			. = locate(world.maxx, world.maxy, A.z)
		if(EAST)
			. = locate(world.maxx, A.y, A.z)
		if(SOUTHEAST)
			. = locate(world.maxx, 1, A.z)
		if(SOUTH)
			. = locate(A.x, 1, A.z)
		if(SOUTHWEST)
			. = locate(1, 1, A.z)
		if(WEST)
			. = locate(1, A.y, A.z)
		if(NORTHWEST)
			. = locate(1, world.maxy, A.z)


/proc/invertHTML(HTMLstring)

	if (!( istext(HTMLstring) ))
		CRASH("Given non-text argument!")
	else
		if (length(HTMLstring) != 7)
			CRASH("Given non-HTML argument!")
	var/textr = copytext(HTMLstring, 2, 4)
	var/textg = copytext(HTMLstring, 4, 6)
	var/textb = copytext(HTMLstring, 6, 8)
	var/r = hex2num(textr)
	var/g = hex2num(textg)
	var/b = hex2num(textb)
	textr = num2hex(255 - r, 2)
	textg = num2hex(255 - g, 2)
	textb = num2hex(255 - b, 2)
	if (length(textr) < 2)
		textr = text("0[]", textr)
	if (length(textg) < 2)
		textr = text("0[]", textg)
	if (length(textb) < 2)
		textr = text("0[]", textb)
	. = text("#[][][]", textr, textg, textb)

/proc/sanitize(var/t)
	var/index = findtext(t, "\n")
	while(index)
		t = copytext(t, 1, index) + "#" + copytext(t, index+1)
		index = findtext(t, "\n")

	index = findtext(t, "\t")
	while(index)
		t = copytext(t, 1, index) + "#" + copytext(t, index+1)
		index = findtext(t, "\t")
	return t // fuk.

/proc/strip_html(var/t,var/limit=MAX_MESSAGE_LEN, var/no_fucking_autoparse = 0)
	t = html_decode(copytext(t,1,limit))
	if (no_fucking_autoparse == 1)
		var/list/bad_characters = list("_", "'", "\"", "<", ">", ";", "[", "]", "{", "}", "|", "\\", "/")
		for(var/c in bad_characters)
			t = replacetext(t, c, "")

	// html_encode(t) will convert < and > to &lt; and &gt;
	// which will allow them to be used (safely) in messages
	t = html_encode(t)

	// var/index = findtext(t, "<")
	// while(index)
	// 	t = copytext(t, 1, index) + "&lt;" + copytext(t, index+1)
	// 	index = findtext(t, "<")
	// index = findtext(t, ">")
	// while(index)
	// 	t = copytext(t, 1, index) + "&gt;" + copytext(t, index+1)
	// 	index = findtext(t, ">")
	. = sanitize(t)

/proc/strip_html_tags(var/t,var/limit=MAX_MESSAGE_LEN)
	. = html_decode(copytext(t,1,limit))
	. = replacetext(., "<br>", "\n")
	. = replacetext(., regex("<\[^>\]*>", "gm"), "")

/proc/adminscrub(var/t,var/limit=MAX_MESSAGE_LEN)
	t = html_decode(copytext(t,1,limit))

	// html_encode(t) will convert < and > to &lt; and &gt;
	// which will allow them to be used (safely) in messages

	// var/index = findtext(t, "<")
	// while(index)
	// 	t = copytext(t, 1, index) + "&lt;" + copytext(t, index+1)
	// 	index = findtext(t, "<")
	// index = findtext(t, ">")
	// while(index)
	// 	t = copytext(t, 1, index) + "&gt;" + copytext(t, index+1)
	// 	index = findtext(t, ">")
	. = html_encode(t)

///Cleans up data passed in from network packets for display so it doesn't mess with formatting
/proc/tidy_net_data(var/t)
	. = isnum(t) ? t : strip_html(t)

/proc/map_numbers(var/x, var/in_min, var/in_max, var/out_min, var/out_max)
	. = ((x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min)

/proc/add_zero(text, desired_length)
	text = "[text]" // ensure it's a string
	if ((desired_length - length(text)) <= 0)
		return text
	return (num2text(0, desired_length - length(text), 10) + text)

/proc/add_lspace(t, u)
	// why????? because if you pass this a number,
	// then -- surprise -- length(t) is ZERO. because it's not text.
	// so step one is to just. do that.
	// *scream *scream *scream *scream *scream *scream *scream *scream *scream
	// *scream *scream *scream *scream *scream *scream *scream *scream *scream
	// *scream *scream *scream *scream *scream *scream *scream *scream *scream
	t = "[t]"
	while(length(t) < u)
		t = " [t]"
	. = t

/proc/add_tspace(t, u)
	t = "[t]"
	while(length(t) < u)
		t = "[t] "
	. = t

/proc/dd_file2list(file_path, separator, can_escape=0)
	if(separator == null)
		separator = "\n"
	if(isfile(file_path))
		. = file_path
	else
		. = file(file_path)
	. = file2text(.)
	if(can_escape)
		. = replacetext(., "\\[separator]", "") // To be complete we should also replace \\ with \ etc. but who cares
	. = splittext(., separator)

/proc/dd_hasprefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	. = findtext(text, prefix, start, end)

/proc/dd_hasPrefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	. = findtext(text, prefix, start, end) //was findtextEx

/proc/dd_hassuffix(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		. = findtext(text, suffix, start, null)

/proc/dd_hasSuffix(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		. = findtext(text, suffix, start, null) //was findtextEx

/**
 * Given a message, returns a list containing the radio prefix and the message,
 * so that the message can be manipulated seperately in various functions.
 */
/proc/separate_radio_prefix_and_message(var/message)
	var/prefix = null

	if (dd_hasprefix(message, ":lh") || dd_hasprefix(message, ":rh") || dd_hasprefix(message, ":in"))
		prefix = copytext(message, 1, 4)
		message = copytext(message, 4)
	else if (dd_hasprefix(message, ":"))
		prefix = copytext(message, 1, 3)
		message = copytext(message, 3)
	else if (dd_hasprefix(message, ";"))
		prefix = ";"
		message = copytext(message, 2)

	return list(prefix, message)

/proc/dd_centertext(message, length)
	. = length(message)
	if(. == length)
		.= message
	else if(. > length)
		.= copytext(message, 1, length + 1)
	else
		var/delta = length - .
		if(delta == 1)
			. = message + " "
		else if(delta % 2)
			. = " " + message
		delta--
		var/spaces = add_lspace("",delta/2-1)
		. = spaces + . + spaces

/proc/dd_limittext(message, length)
	var/size = length(message)
	if(size <= length)
		. = message
	else
		.= copytext(message, 1, length + 1)

/**
	* Returns the given degree converted to a text string in the form of a direction
	*/
/proc/angle2text(var/degree)
	. = dir2text(angle2dir(degree))

/proc/text_input(var/Message, var/Title, var/Default, var/length=MAX_MESSAGE_LEN)
	. = sanitize(tgui_input_text(usr, Message, Title, Default), length)

/proc/scrubbed_input(var/user, var/Message, var/Title, var/Default, var/length=MAX_MESSAGE_LEN)
	. = strip_html(tgui_input_text(user, Message, Title, Default), length)

/proc/LinkBlocked(turf/A, turf/B)
	if(A == null || B == null) return 1
	var/adir = get_dir(A,B)
	var/rdir = get_dir(B,A)
	if((adir & (NORTH|SOUTH)) && (adir & (EAST|WEST)))	//	diagonal
		var/iStep = get_step(A,adir&(NORTH|SOUTH))
		if(!LinkBlocked(A,iStep) && !LinkBlocked(iStep,B)) return 0

		var/pStep = get_step(A,adir&(EAST|WEST))
		if(!LinkBlocked(A,pStep) && !LinkBlocked(pStep,B)) return 0
		return 1

	if(DirBlocked(A,adir)) return 1
	if(DirBlocked(B,rdir)) return 1
	return 0


/proc/DirBlocked(turf/loc,var/dir)
	. = FALSE
	for(var/obj/window/D in loc)
		if(!D.density)
			continue
		if(D.dir == SOUTHWEST)	return TRUE
		if(D.dir == dir)				return TRUE

	for(var/obj/machinery/door/D in loc)
		if(!D.density)
			continue
		if(istype(D, /obj/machinery/door/window))
			if((dir & SOUTH) && (D.dir & (EAST|WEST)))		return TRUE
			if((dir & EAST ) && (D.dir & (NORTH|SOUTH)))	return TRUE
		else
			return TRUE	// it's a real, air blocking door

/proc/TurfBlockedNonWindow(turf/loc)
	. = FALSE
	for(var/obj/O in loc)
		if(O.density && !istype(O, /obj/window))
			return TRUE

/proc/getline(atom/M,atom/N)//Ultra-Fast Bresenham Line-Drawing Algorithm
	var/px=M.x		//starting x
	var/py=M.y
	. = list(locate(px,py,M.z))
	var/dx=N.x-px	//x distance
	var/dy=N.y-py
	var/dxabs=abs(dx)//Absolute value of x distance
	var/dyabs=abs(dy)
	var/sdx=sign(dx)	//Sign of x distance (+ or -)
	var/sdy=sign(dy)
	var/x=dxabs>>1	//Counters for steps taken, setting to distance/2
	var/y=dyabs>>1	//Bit-shifting makes me l33t.  It also makes getline() unnessecarrily fast.
	var/j			//Generic integer for counting
	if(dxabs>=dyabs)	//x distance is greater than y
		for(j=0;j<dxabs;j++)//It'll take dxabs steps to get there
			y+=dyabs
			if(y>=dxabs)	//Every dyabs steps, step once in y direction
				y-=dxabs
				py+=sdy
			px+=sdx		//Step on in x direction
			. += locate(px,py,M.z)//Add the turf to the list
	else
		for(j=0;j<dyabs;j++)
			x+=dxabs
			if(x>=dyabs)
				x-=dyabs
				px+=sdx
			py+=sdy
			. += locate(px,py,M.z)

//bnlah, same thing as above except instead of a list of turfs we return the first opaque turf
/proc/getlineopaqueblocked(atom/M,atom/N)//Ultra-Fast Bresenham Line-Drawing Algorithm
	var/px=M.x		//starting x
	var/py=M.y
	. = get_turf(N)
	var/dx=N.x-px	//x distance
	var/dy=N.y-py
	var/dxabs=abs(dx)//Absolute value of x distance
	var/dyabs=abs(dy)
	var/sdx=sign(dx)	//Sign of x distance (+ or -)
	var/sdy=sign(dy)
	var/x=dxabs>>1	//Counters for steps taken, setting to distance/2
	var/y=dyabs>>1	//Bit-shifting makes me l33t.  It also makes getline() unnessecarrily fast.
	var/j			//Generic integer for counting
	if(dxabs>=dyabs)	//x distance is greater than y
		for(j=0;j<dxabs;j++)//It'll take dxabs steps to get there
			y+=dyabs
			if(y>=dxabs)	//Every dyabs steps, step once in y direction
				y-=dxabs
				py+=sdy
			px+=sdx		//Step on in x direction
			var/turf/T = locate(px,py,M.z)//Add the turf to the list
			if(!T || T.opacity || T.opaque_atom_count)
				return T
	else
		for(j=0;j<dyabs;j++)
			x+=dxabs
			if(x>=dyabs)
				x-=dyabs
				px+=sdx
			py+=sdy
			var/turf/T = locate(px,py,M.z)
			if(!T || T.opacity || T.opaque_atom_count)
				return T

/proc/getstraightlinewalled(atom/M,vx,vy,include_origin = 1)//hacky fuck for l ighting
	if (!M) return null
	var/turf/T = null
	var/px=M.x		//starting x
	var/py=M.y
	if (include_origin)
		. = list(locate(px,py,M.z))
	else
		.= list()
	if (vx)
		var/step = vx > 0 ? 1 : -1
		vx = abs(vx)
		while(vx > 0)
			px += step
			vx -= 1
			T = locate(px,py,M.z)
			if (!T || T.opacity || T.opaque_atom_count > 0)
				break
			. += T
	else if (vy)
		var/step = vy > 0 ? 1 : -1
		vy = abs(vy)
		while(vy > 0)
			py += step
			vy -= 1
			T = locate(px,py,M.z)
			if (!T || T.opacity || T.opaque_atom_count > 0)
				break
			. += T

/**
	* Returns true if the given key is a guest key
	*/
/proc/IsGuestKey(key)
	. = copytext(key, 1, 7) == "Guest-"


/**
	* Returns f, ensured that it's a valid frequency
	*/
/proc/sanitize_frequency(var/f)
	. = round(f)
	. = clamp(., R_FREQ_MINIMUM, R_FREQ_MAXIMUM) // 144.1 -148.9
	. |= 1 // enforces the number being odd (rightmost bit being 1)

/proc/format_frequency(var/f)
	. = "[round(f / 10)].[f % 10]"

/proc/sortmobs()
	. = list()

	for_by_tcl(M, /mob/living/silicon/ai)
		. += M
		LAGCHECK(LAG_REALTIME)
	for(var/mob/living/intangible/aieye/M in mobs)
		. += M
		LAGCHECK(LAG_REALTIME)
	for(var/mob/living/silicon/robot/M in mobs)
		. += M
		LAGCHECK(LAG_REALTIME)
	for(var/mob/living/silicon/hivebot/M in mobs)
		. += M
		LAGCHECK(LAG_REALTIME)
	for(var/mob/living/silicon/hive_mainframe/M in mobs)
		. += M
		LAGCHECK(LAG_REALTIME)
	for(var/mob/living/carbon/human/M in mobs)
		. += M
		LAGCHECK(LAG_REALTIME)
	for(var/mob/living/critter/C in mobs)
		if(C.client)
			. += C
		LAGCHECK(LAG_REALTIME)
	for(var/mob/living/intangible/wraith/M in mobs)
		. += M
		LAGCHECK(LAG_REALTIME)
	for(var/mob/living/intangible/blob_overmind/M in mobs)
		. += M
		LAGCHECK(LAG_REALTIME)
	for(var/mob/dead/observer/M in mobs)
		. += M
		LAGCHECK(LAG_REALTIME)
	for(var/mob/dead/target_observer/M in mobs)
		. += M
		LAGCHECK(LAG_REALTIME)
	for(var/mob/new_player/M in mobs)
		. += M
		LAGCHECK(LAG_REALTIME)
	for(var/mob/living/silicon/ghostdrone/M in mobs)
		. += M
		LAGCHECK(LAG_REALTIME)
	for(var/mob/zoldorf/M in mobs)
		. += M
		LAGCHECK(LAG_REALTIME)
	for(var/mob/living/seanceghost/M in mobs)
		. += M
		LAGCHECK(LAG_REALTIME)

//Include details shows traitor status etc
//Admins replaces the src ref for links with a placeholder for message_admins
//Mentor just changes the private message link
/proc/key_name(var/whom, var/include_details = 1, var/admins = 1, var/mentor = 0, var/custom_href=null)
	var/mob/the_mob = null
	var/client/the_client = null
	var/the_key = ""
	var/last_ckey = null

	if (isnull(whom))
		return "*null*"
	else if (isclient(whom))
		the_client = whom
		the_mob = the_client.mob
		the_key = html_encode(the_client.key)
	else if (ismob(whom))
		the_mob = whom
		the_client = the_mob.client
		the_key = html_encode(the_mob.key)
		last_ckey = the_mob.last_ckey
	else if (istype(whom, /datum))
		if (ismind(whom))
			var/datum/mind/the_mind = whom
			the_mob = the_mind.current
			the_key = html_encode(the_mind.key)
			the_client = the_mind.current ? the_mind.current.client : null
			if (!the_client && the_key)
				for (var/client/C in clients)
					if (C.key == the_key || C.ckey == the_key)
						the_client = C
						break
		else
			var/datum/the_datum = whom
			return "*invalid:[the_datum.type]*"
	else //It's probably just a text string. We're ok with that.
		for (var/client/C in clients)
			if (C.key == whom || C.ckey == whom)
				the_client = C
				the_key = html_encode(C.key)
				if (C.mob)
					the_mob = C.mob
				break
			if (C.mob && C.mob.real_name == whom)
				the_client = C
				the_key = html_encode(C.key)
				the_mob = C.mob
				break

	var/text = ""

	if (!the_key)
		if(last_ckey)
			text += "*last ckey: [last_ckey]*"
		else
			text += "*no client*"
	else
		if (!isnull(the_mob))
			if(custom_href) text += "<a href=\"[custom_href]\">"
			else if(mentor) text += "<a href=\"byond://?action=mentor_msg&target=[the_mob.ckey]\">"
			else text += "<a href=\"byond://?action=priv_msg&target=[the_mob.ckey]\">"

		if (the_client)
			if (the_client.holder && the_client.stealth && !include_details)
				text += "Administrator"
			else if (the_client.holder && the_client.alt_key && !include_details)
				text += "[the_client.fakekey]"
			else
				text += "[the_key]"
		else
			text += "[the_key] *no client*"

		if (!isnull(the_mob))
			text += "</a>"

	//Show details for players
	if (include_details)
		if (!isnull(the_mob))
			text += "/"
			if (the_mob.real_name)
				text += html_encode(the_mob.real_name)
			else if (the_mob.name)
				text += html_encode(the_mob.name)
			text += " "
			if (the_client && !the_client.holder) //only show this stuff for non-admins because admins do a lot of shit while dead and it is unnecessary to show it
				if (checktraitor(the_mob))
					text += "\[<font color='red'>T</font>\] "
				if (isdead(the_mob))
					text += "\[DEAD\] "

			var/linkSrc
			if (admins)
				linkSrc = "%admin_ref%"
			else
				linkSrc = "\ref[usr.client.holder]"
			text += "<a href='byond://?src=[linkSrc]&action=adminplayeropts&targetckey=[the_mob.ckey]' class='popt'><i class='icon-info-sign'></i></a>"

	return text

// Registers the on-close verb for a browse window (client/verb/.windowclose)
// this will be called when the close-button of a window is pressed.
//
// This is usually only needed for devices that regularly update the browse window,
// e.g. canisters, timers, etc.
//
// windowid should be the specified window name
// e.g. code is	: user.Browse(text, "window=fred")
// then use 	: onclose(user, "fred")
//
// Optionally, specify the "ref" parameter as the controlled atom (usually src)
// to pass a "close=1" parameter to the atom's Topic() proc for special handling.
// Otherwise, the user mob's machine var will be reset directly.
//
/proc/onclose(mob/user, windowid, var/datum/ref=null)
	var/param = "null"
	if(ref)
		param = "\ref[ref]"

	if (user?.client)
		winset(user, windowid, "on-close=\".windowclose [param]\"")

	//boutput(world, "OnClose [user]: [windowid] : ["on-close=\".windowclose [param]\""]")


// the on-close client verb
// called when a browser popup window is closed after registering with proc/onclose()
// if a valid atom reference is supplied, call the atom's Topic() with "close=1"
// otherwise, just reset the client mob's machine var.
//
/client/verb/windowclose(var/atomref as text)
	set hidden = 1						// hide this verb from the user's panel
	set name = ".windowclose"			// no autocomplete on cmd line

	//boutput(world, "windowclose: [atomref]")
	if(atomref!="null")				// if passed a real atomref
		var/hsrc = locate(atomref)	// find the reffed atom
		var/href = "close=1"
		if(hsrc)
			//boutput(world, "[src] Topic [href] [hsrc]")
			usr = src.mob
			src.Topic(href, params2list(href), hsrc)	// this will direct to the atom's
			return										// Topic() proc via client.Topic()

	// no atomref specified (or not found)
	// so just reset the user mob's machine var
	if(src?.mob)
		src.mob.remove_dialogs()

// returns the turf located at the map edge in the specified direction relative to A
// used for mass driver
/proc/get_edge_target_turf(var/atom/A, var/direction)

	if (isnull(A))
		stack_trace("get_edge_target_turf called with null reference atom.")

	var/turf/target = locate(A.x, A.y, A.z)
	if (!target)
		return 0
		//since NORTHEAST == NORTH & EAST, etc, doing it this way allows for diagonal mass drivers in the future
		//and isn't really any more complicated

		// Note diagonal directions won't usually be accurate
	if(direction & NORTH)
		target = locate(target.x, world.maxy-1, target.z)
	if(direction & SOUTH)
		target = locate(target.x, 1, target.z)
	if(direction & EAST)
		target = locate(world.maxx-1, target.y, target.z)
	if(direction & WEST)
		target = locate(1, target.y, target.z)

	return target

// returns turf relative to A in given direction at set range
// result is bounded to map size
// note range is non-pythagorean
// used for disposal system
/proc/get_ranged_target_turf(var/atom/A, var/direction, var/range)

	if (isnull(A))
		stack_trace("get_ranged_target_turf called with null reference atom.")

	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = min(world.maxy, y + range)
	if(direction & SOUTH)
		y = max(1, y - range)
	if(direction & EAST)
		x = min(world.maxx, x + range)
	if(direction & WEST)
		x = max(1, x - range)

	return locate(x,y,A.z)


// returns turf relative to A offset in dx and dy tiles
// bound to map limits
/proc/get_offset_target_turf(var/atom/A, var/dx, var/dy)

	if (isnull(A))
		stack_trace("get_offset_target_turf called with null reference atom.")
	var/x = clamp(A.x + dx, 1, world.maxx)
	var/y = clamp(A.y + dy, 1, world.maxy)
	return locate(x,y,A.z)


/// Returns the turf facing the fab for cardinal directions (which should also be the user's turf),
///		but for diagonals it returns a neighbouring turf depending on where you click
/// Just in case you're attacking a corner diagonally. (made initially for lamp manufacturers, probably behaves funky above range 1)
proc/get_adjacent_floor(atom/W, mob/user, px, py)
	var/dir_temp = get_dir(user, W) //Our W is to the ___ of the user
	//These two expressions divide a 32*32 turf into diagonal halves
	var/diag1 = (px > py) //up-left vs down-right
	var/diag2 = ((px + py) > 32) //up-right vs down-left
	switch(dir_temp)
		if (NORTH)
			return get_turf(get_step(W,SOUTH))
		if (NORTHEAST)
			if (diag1)
				return get_turf(get_step(W,SOUTH))
			return get_turf(get_step(W,WEST))
		if (EAST)
			return get_turf(get_step(W,WEST))
		if (SOUTHEAST)
			if (diag2)
				return get_turf(get_step(W,NORTH))
			return get_turf(get_step(W,WEST))
		if (SOUTH)
			return get_turf(get_step(W,NORTH))
		if (SOUTHWEST)
			if (diag1)
				return get_turf(get_step(W,EAST))
			return get_turf(get_step(W,NORTH))
		if (WEST)
			return get_turf(get_step(W,EAST))
		if (NORTHWEST)
			if (diag2)
				return get_turf(get_step(W,EAST))
			return get_turf(get_step(W,SOUTH))


// extends pick() to associated lists
/proc/alist_pick(var/list/L)
	if(!L || !length(L))
		return null
	return L[pick(L)]

/proc/ran_zone(zone, probability)

	if (probability == null)
		probability = 90
	if (probability == 100)
		return zone
	switch(zone)
		if("chest")
			if (prob(probability))
				return "chest"
			else
				var/t = rand(1, 9)
				if (t < 3)
					return "head"
				else if (t < 6)
					return "l_arm"
				else if (t < 9)
					return "r_arm"
				else
					return "chest"

		if("head")
			if (prob(probability * 0.85))
				return "head"
			else
				return "chest"
		if("l_arm")
			if (prob(probability * 0.85))
				return "l_arm"
			else
				return "chest"
		if("r_arm")
			if (prob(probability * 0.85))
				return "r_arm"
			else
				return "chest"
		if("r_leg")
			if (prob(probability * 0.85))
				return "r_leg"
			else
				return "chest"
		if("l_leg")
			if (prob(probability * 0.85))
				return "l_leg"
			else
				return "chest"

	return


// Jesus fucking christ people has nobody heard of giving your variables useful names
// I mean seriously it doesnt take that much time and no you arent saving any space
// in the game by doing it. Christ on a stick this is awful. Who the hell uses n
// for a message in the first place I mean come on thats supposed to be the size of input
// you couldnt have gone for "msg" or something that makes 10 times more sense?!?
// In summary: aaaaaaaAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
// <3 Fire
// I'm preserving the above comment block, let it be known this proc used to use the variables "n", "pr", "te", "t", "p." I have fixed them. You're welcome.
// <3 FlamingLily
/proc/stars(input_text, probability)
	if(probability == null)
		probability = 25
	if(probability <= 0)
		return null
	else
		if (probability >= 100)
			return input_text
	var/output_text = ""
	var/input_length = length(input_text)
	var/cycle = 1
	while(cycle <= input_length)
		if ((copytext(input_text, cycle, cycle + 1) == " " || prob(probability)))
			output_text = text("[][]", output_text, copytext(input_text, cycle, cycle + 1))
		else
			output_text = text("[]*", output_text)
		cycle++
	return output_text

/proc/stutter(n)
	var/te = html_decode(n)
	var/t = ""
	n = length(n)
	var/p = null
	p = 1
	while(p <= n)
		var/n_letter = copytext(te, p, p + 1)
		if (prob(80))
			if (prob(10))
				n_letter = text("[n_letter][n_letter][n_letter][n_letter]")
			else
				if (prob(20))
					n_letter = text("[n_letter][n_letter][n_letter]")
				else
					if (prob(5))
						n_letter = null
					else
						n_letter = text("[n_letter][n_letter]")
		t = text("[t][n_letter]")
		p++
	return copytext(sanitize(t),1,MAX_MESSAGE_LEN)

/proc/shake_camera(mob/M, duration, strength=1, delay=0.2)
	SPAWN(1 DECI SECOND)
		if(!M || !M.client || M.shakecamera)
			return
		M.shakecamera = 1
		var/client/client = M.client

		for(var/i=0, i<duration, i++)
			var/off_x = (rand(0, strength) * (prob(50) ? -1:1))
			var/off_y = (rand(0, strength) * (prob(50) ? -1:1))
			if(client)
				animate(client, pixel_x = off_x, pixel_y = off_y, easing = LINEAR_EASING, time = 1, flags = ANIMATION_RELATIVE)
			animate(pixel_x = off_x*-1, pixel_y = off_y*-1, easing = LINEAR_EASING, time = 1, flags = ANIMATION_RELATIVE)
			sleep(delay)

		if (client)
			client.pixel_x = 0
			client.pixel_y = 0
			M.shakecamera = 0

/proc/findname(msg)
	for(var/mob/M in mobs)
		if (M.real_name == text("[msg]"))
			return 1
	return 0

/proc/get_cardinal_step_away(atom/start, atom/finish) //returns the position of a step from start away from finish, in one of the cardinal directions
	//returns only NORTH, SOUTH, EAST, or WEST
	var/dx = finish.x - start.x
	var/dy = finish.y - start.y
	if(abs(dy) > abs (dx)) //slope is above 1:1 (move horizontally in a tie)
		if(dy > 0)
			return get_step(start, SOUTH)
		else
			return get_step(start, NORTH)
	else
		if(dx > 0)
			return get_step(start, WEST)
		else
			return get_step(start, EAST)


/proc/parse_zone(zone)
	if (zone == "l_arm") return "left arm"
	else if (zone == "r_arm") return "right arm"
	else if (zone == "l_leg") return "left leg"
	else if (zone == "r_leg") return "right leg"
	else return zone

/proc/text2dir(direction)
	switch(uppertext(direction))
		if("NORTH")
			return NORTH
		if("N")
			return NORTH
		if("SOUTH")
			return SOUTH
		if("S")
			return SOUTH
		if("EAST")
			return EAST
		if("E")
			return EAST
		if("WEST")
			return WEST
		if("W")
			return WEST
		if("NORTHEAST")
			return NORTHEAST
		if("NE")
			return NORTHEAST
		if("NORTHWEST")
			return NORTHWEST
		if("NW")
			return NORTHWEST
		if("SOUTHEAST")
			return SOUTHEAST
		if("SE")
			return SOUTHEAST
		if("SOUTHWEST")
			return SOUTHWEST
		if("SW")
			return SOUTHWEST

/proc/dir2text(direction)
	switch(direction)
		if(0)
			return "center"
		if(NORTH)
			return "north"
		if(SOUTH)
			return "south"
		if(EAST)
			return "east"
		if(WEST)
			return "west"
		if(NORTHEAST)
			return "northeast"
		if(SOUTHEAST)
			return "southeast"
		if(NORTHWEST)
			return "northwest"
		if(SOUTHWEST)
			return "southwest"

// Marquesas: added an extra parameter to fix issue with changeling.
// Unfortunately, it has to be this extra parameter, otherwise the spawn(0) in the mob say will
// cause the mob's name to revert from the one it acquired for mimic voice.
/atom/proc/hear_talk(mob/M as mob, text, real_name, lang_id)
	if (src.open_to_sound)
		for(var/obj/O in src)
			O.hear_talk(M,text,real_name, lang_id)

/**
  * Returns true if given value is a hex value
  */
/proc/is_hex(hex)
	if (!( istext(hex) ))
		return FALSE
	return (findtext(hex, hex_regex) == 1)

/proc/format_username(var/playerName)
	if (!playerName)
		return "Unknown"

	var/list/name_temp = splittext(playerName, " ")
	if (!name_temp.len)
		playerName = "Unknown"
	else if (name_temp.len == 1)
		playerName = name_temp[1]
	else //Ex: John Smith becomes JSmith
		playerName = copytext( ( copytext(name_temp[1],1, 2) + name_temp[name_temp.len] ), 1, 16)

	. = lowertext(replacetext(playerName, "/", null))

/proc/engineering_notation(var/value=0 as num)
	if (!value)
		return "0 "

	var/suffix = ""
	var/power = round( log(10, value) / 3)
	switch (power)
		if (-8)
			suffix = "y"
		if (-7)
			suffix = "z"
		if (-6)
			suffix = "a"
		if (-5)
			suffix = "f"
		if (-4)
			suffix = "p"
		if (-3)
			suffix = "n"
		if (-2)
			suffix = "&#956;"
		if (-1)
			suffix = "m"
		if (1)
			suffix = "k"
		if (2)
			suffix = "M"
		if (3)
			suffix = "G"
		if (4)
			suffix = "T"
		if (5)
			suffix = "P"
		if (6)
			suffix = "E"
		if (7)
			suffix = "Z"
		if (8)
			suffix = "Y"

	value = round( (value / (10 ** (3 * power))), 0.001 )
	. = "[value] [suffix]"

/proc/obj_loc_chain(var/atom/movable/whose)
	. = list()
	if (isnull(whose) || isnull(whose.loc) || isturf(whose) || isarea(whose) || isturf(whose.loc))
		return
	var/atom/movable/M = whose
	while (ismob(M.loc) || isobj(M.loc))
		. += M.loc
		M = M.loc

/proc/all_hearers(var/range,var/centre)
	. = list()
	for(var/atom/A as anything in (view(range,centre) | hearers(range, centre))) //Why was this view(). Oh no, the invisible man hears naught 'cause the sound can't find his ears.
		if (ismob(A))
			. += A
		if (isobj(A) || ismob(A))
			if (istype(A, /obj/item/organ/head))	//Skeletons can hear from their heads!
				var/obj/item/organ/head/found_head = A
				if (found_head.head_type == HEAD_SKELETON && found_head.linked_human != null)
					var/mob/linked_mob = found_head.linked_human
					. += linked_mob
			for(var/mob/M in A.contents)
				var/can_hear = 0 //this check prevents observers from hearing their target's messages twice

				if (istype(M,/mob/dead/target_observer))
					var/mob/dead/target_observer/O = M
					if (A != O.target)
						can_hear = 1
				else
					can_hear = 1

				if (can_hear)
					. += M
	if(length(by_cat[TR_CAT_OMNIPRESENT_MOBS]))
		for(var/mob/M as anything in by_cat[TR_CAT_OMNIPRESENT_MOBS])
			if(get_step(M, 0)?.z == get_step(centre, 0)?.z)
				. |= M



/proc/all_viewers(var/range,var/centre)
	. = list()
	for (var/atom/A as anything in viewers(range,centre))
		if (ismob(A))
			. += A
		else if (isobj(A))
			for(var/mob/M in A.contents)
				. += M
	if(length(by_cat[TR_CAT_OMNIPRESENT_MOBS]))
		for(var/mob/M as anything in by_cat[TR_CAT_OMNIPRESENT_MOBS])
			if(get_step(M, 0)?.z == get_step(centre, 0)?.z)
				. |= M

/proc/all_range(var/range,var/centre) //above two are blocked by opaque objects
	. = list()
	for (var/atom/A as anything in range(range,centre))
		if (ismob(A))
			. += A
		else if (isobj(A))
			for(var/mob/M in A.contents)
				. += M

/proc/all_view(var/range,var/centre)
	. = view(range,centre)
	for(var/obj/O in .)
		for(var/mob/M in O.contents)
			. += M

/proc/weightedprob(choices[], weights[])
	if(!choices || !weights) return null

	//Build a range of weights
	var/max_num = 0
	for(var/X in weights) if(isnum(X)) max_num += X

	//Now roll in the range.
	var/weighted_num = rand(1,max_num)

	var/running_total, i

	//Loop through all possible choices
	for(i = 1; i <= choices.len; i++)
		if(i > weights.len) return null

		running_total += weights[i]

		//Once the current step is less than the roll,
		// we have our winner.
		if(weighted_num <= running_total)
			return choices[i]

/* Get the highest ancestor of this object in the tree that is an immediate child of
   a given ancestor.
   Usage:
   var/datum/fart/sassy/F = new
   get_top_parent(F, /datum) //returns a path to /datum/fart
   */
/proc/get_top_ancestor(var/datum/object, var/ancestor_of_ancestor=/datum)
	if(!object || !ancestor_of_ancestor)
		CRASH("Null value parameters in get top ancestor.")
	if(!ispath(ancestor_of_ancestor))
		CRASH("Non-Path ancestor of ancestor parameter supplied.")
	var/stringancestor = "[ancestor_of_ancestor]"
	var/stringtype = "[object.type]"
	var/ancestorposition = findtextEx(stringtype, stringancestor)
	if(!ancestorposition)
		return null
	var/parentstart = ancestorposition + length(stringancestor) + 1
	var/parentend = findtextEx(stringtype, "/", parentstart)
	var/stringtarget = copytext(stringtype, 1, parentend ? parentend : 0)
	. = text2path(stringtarget)

//Returns a list of minds that are some type of antagonist role
//This may be a stop gap until a better solution can be figured out
/proc/get_all_enemies()
	if(ticker?.mode && current_state >= GAME_STATE_PLAYING)
		var/datum/mind/enemies[] = new()
		var/datum/mind/someEnemies[] = new()

		//We gotta loop through the modes because someone thought it was a good idea to create new lists for all of them
		if (istype(ticker.mode, /datum/game_mode/revolution))
			someEnemies = ticker.mode:head_revolutionaries
			for(var/datum/mind/M in someEnemies)
				if (M.current)
					enemies += M
			someEnemies = ticker.mode:revolutionaries
			for(var/datum/mind/M in someEnemies)
				if (M.current)
					enemies += M
			someEnemies = ticker.mode:get_all_heads()
			for(var/datum/mind/M in someEnemies)
				if (M.current)
					enemies += M
		else if (istype(ticker.mode, /datum/game_mode/nuclear))
			someEnemies = ticker.mode:syndicates
			for(var/datum/mind/M in someEnemies)
				if (M.current)
					enemies += M
		else if (istype(ticker.mode, /datum/game_mode/spy))
			someEnemies = ticker.mode:spies
			for(var/datum/mind/M in someEnemies)
				if (M.current)
					enemies += M
			someEnemies = ticker.mode:leaders
			for(var/datum/mind/M in someEnemies)
				if (M.current)
					enemies += M
		else if (istype(ticker.mode, /datum/game_mode/gang))
			someEnemies = ticker.mode:leaders
			for(var/datum/mind/M in someEnemies)
				if (M.current)
					enemies += M
					for(var/datum/mind/G in M.gang.members) //This may be fucked. Dunno how these are stored.
						enemies += G

		//Lists we grab regardless of game type
		//Traitors list is populated during traitor or mixed rounds, however it is created along with the game_mode datum unlike the rest of the lists
		someEnemies = ticker.mode.traitors
		for(var/datum/mind/M in someEnemies)
			if (M.current)
				enemies += M

		//Sometimes admins assign traitors, this contains those dudes
		someEnemies = ticker.mode.Agimmicks
		for(var/datum/mind/M in someEnemies)
			if (M.current)
				enemies += M

		return enemies

	else
		return 0

/proc/GetRedPart(hex)
    hex = uppertext(hex)
    var/hi = text2ascii(hex, 2)
    var/lo = text2ascii(hex, 3)
    return ( ((hi >= 65 ? hi-55 : hi-48)<<4) | (lo >= 65 ? lo-55 : lo-48) )

/proc/GetGreenPart(hex)
    hex = uppertext(hex)
    var/hi = text2ascii(hex, 4)
    var/lo = text2ascii(hex, 5)
    return ( ((hi >= 65 ? hi-55 : hi-48)<<4) | (lo >= 65 ? lo-55 : lo-48) )

/proc/GetBluePart(hex)
    hex = uppertext(hex)
    var/hi = text2ascii(hex, 6)
    var/lo = text2ascii(hex, 7)
    return ( ((hi >= 65 ? hi-55 : hi-48)<<4) | (lo >= 65 ? lo-55 : lo-48) )

/proc/GetColors(hex)
    hex = uppertext(hex)
    var/hi1 = text2ascii(hex, 2)
    var/lo1 = text2ascii(hex, 3)
    var/hi2 = text2ascii(hex, 4)
    var/lo2 = text2ascii(hex, 5)
    var/hi3 = text2ascii(hex, 6)
    var/lo3 = text2ascii(hex, 7)
    return list(((hi1>= 65 ? hi1-55 : hi1-48)<<4) | (lo1 >= 65 ? lo1-55 : lo1-48),
        ((hi2 >= 65 ? hi2-55 : hi2-48)<<4) | (lo2 >= 65 ? lo2-55 : lo2-48),
        ((hi3 >= 65 ? hi3-55 : hi3-48)<<4) | (lo3 >= 65 ? lo3-55 : lo3-48))

//Shoves a jump to link or whatever in the thing :effort:
/proc/showCoords(x, y, z, plaintext, holder)
	var text
	if (plaintext)
		text += "[x], [y], [z]"
	else
		text += "<a href='?src=[holder ? "\ref[holder]" : "%admin_ref%"];action=jumptocoords;target=[x],[y],[z]' title='Jump to Coords'>[x],[y],[z]</a>"

	return text

// hi I'm haine -throws more crap onto the pile-
/proc/rand_deci(var/num1 = 1, var/num2 = 0, var/num3 = 2, var/num4 = 0)
// input num1.num2 and num3.num4 returns a random number between them
	var/output = text2num("[rand(num1, num2)].[rand(num3, num4)]")
	return output

var/list/easing_types = list(
"Linear/0" = LINEAR_EASING,
"Sine/1" = SINE_EASING,
"Circular/2" = CIRCULAR_EASING,
"Cubic/3" = CUBIC_EASING,
"Bounce/4" = BOUNCE_EASING,
"Elastic/5" = ELASTIC_EASING,
"Back/6" = BACK_EASING)

var/list/blend_types = list(
"Default/0" = BLEND_DEFAULT,
"Overlay/1" = BLEND_OVERLAY,
"Add/2" = BLEND_ADD,
"Subtract/3" = BLEND_SUBTRACT,
"Multipy/4" = BLEND_MULTIPLY)

var/hex_regex	= regex(@"^[0-9a-f]+$", "i")
var/color_regex = regex(@"^#[0-9a-f]{6}$", "i")

var/list/hex_chars = list("0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F")

var/list/all_functional_reagent_ids = list()

proc/get_all_functional_reagent_ids()
	for (var/datum/reagent/R as anything in filtered_concrete_typesof(/datum/reagent, /proc/filter_blacklisted_chem))
		all_functional_reagent_ids += initial(R.id)


proc/filter_blacklisted_chem(type)
	var/datum/reagent/fakeInstance = type
	return !initial(fakeInstance.random_chem_blacklisted)

proc/reagent_id_to_name(var/reagent_id)
	if (!reagent_id || !length(reagents_cache))
		return
	var/datum/reagent/R = reagents_cache[reagent_id]
	if (!R)
		return "nothing"
	else
		return R.name

proc/RarityClassRoll(var/scalemax = 100, var/mod = 0, var/list/category_boundaries)
	if (!isnum(scalemax) || scalemax <= 0)
		return 0
	if (!isnum(mod))
		return 0
	if (category_boundaries.len <= 0)
		return 0

	var/picker = rand(1,scalemax)
	picker += mod
	var/list_counter = length(category_boundaries)

	for (var/X in category_boundaries)
		if (!isnum(X))
			return 1
		if (picker >= X)
			return list_counter + 1
		list_counter--

	return 1

/proc/circular_range(var/atom/A,var/size)
	if (!A || !isnum(size) || size <= 0)
		return list()

	var/list/turfs = list()
	var/turf/center = get_turf(A)

	var/corner_range = round(size * 1.5)
	var/total_distance = 0
	var/current_range = 0

	while (current_range < size - 1)
		current_range++
		total_distance = 0
		for (var/turf/T in range(size,center))
			if (GET_DIST(T,center) == current_range)
				total_distance = abs(center.x - T.x) + abs(center.y - T.y) + (current_range / 2)
				if (total_distance > corner_range)
					continue
				turfs += T

	return turfs

/proc/get_fraction_of_percentage_and_whole(var/perc,var/whole)
	if (!isnum(perc) || !isnum(whole) || perc == 0 || whole == 0)
		return 0
	. = (perc / whole) * 100

/proc/get_percentage_of_fraction_and_whole(var/fraction,var/whole)
	if (!isnum(fraction) || !isnum(whole) || fraction == 0 || whole == 0)
		return 0
	. = (fraction * 100) / whole

/proc/get_whole_of_percentage_and_fraction(var/fraction,var/perc)
	if (!isnum(fraction) || !isnum(perc) || fraction == 0 || perc == 0)
		return 0
	. = (100 * fraction) / perc

/proc/get_damage_after_percentage_based_armor_reduction(var/armor,var/damage)
	if (!isnum(armor) || !isnum(damage) || damage <= 0)
		return 0
	// [13:22] <volundr> it would be ( (100 - armorpercentage) / 100 ) * damageamount
	armor = clamp(armor, 0, 100)
	. = ((100 - armor) / 100) * damage

/proc/get_filtered_atoms_in_touch_range(var/atom/center,var/filter)
	. = list()
	if (!center)
		return

	var/target_loc = get_turf(center)

	for(var/atom/A in range(1,target_loc))
		if (ispath(filter))
			if (istype(A,filter))
				. += A
		else
			. += A

	for(var/atom/B in center.contents)
		if (ispath(filter))
			if (istype(B,filter))
				. += B
		else
			. += B

/proc/is_valid_color_string(var/string)
	if (!istext(string))
		return 0
	. = (findtext(string, color_regex) == 1)

/proc/get_digit_from_number(var/number,var/slot)
	// note this works "backwards", so slot 1 of 52964 would be 4, not 5
	if(!isnum(number))
		return 0
	var/string = num2text(number)
	string = reverse_text(string)
	. = text2num(copytext(string,slot,slot+1))

/**
  * Returns the current timeofday in o'clock format
  */
/proc/o_clock_time()
	var/get_hour = text2num(time2text(world.timeofday, "hh"))
	var/final_hour = get_hour
	if (get_hour > 12)
		final_hour = (get_hour - 12)

	var/get_minutes = text2num(time2text(world.timeofday, "mm"))
	var/final_minutes = "[get_english_num(get_minutes)] minutes past "
	switch (get_minutes)
		if (0)
			final_minutes = ""
		if (1)
			final_minutes = "[get_english_num(get_minutes)] minute past "
		if (15)
			final_minutes = "quarter past "
		if (30)
			final_minutes = "half past "
		if (45)
			if (get_hour > 12)
				final_hour = (get_hour - 11)
			else
				final_hour = (get_hour + 1)
			final_minutes = "quarter 'til "

	var/the_time = "[final_minutes][get_english_num(final_hour)] o'clock"
	return the_time

/// Returns shift time as a string in hh:mm format. Call with TRUE to get time in hh:mm:ss format.
/proc/formattedShiftTime(var/doSeconds)
	var/elapsedSeconds = round(ticker.round_elapsed_ticks/10, 1)
	var/elapsedMinutes = round(elapsedSeconds / 60)
	var/elapsedHours = round(elapsedSeconds / 3600)
	var/t = ""
	if (!doSeconds)
		t = "[add_zero(elapsedHours, 2)]:[add_zero(elapsedMinutes % 60, 2)]"
	else
		t = "[add_zero(elapsedHours, 2)]:[add_zero(elapsedMinutes % 60, 2)]:[add_zero(elapsedSeconds % 60, 2)]"
	return t

/proc/antag_token_list() //List of all players redeeming antagonist tokens
	var/list/token_list = list()
	for(var/mob/new_player/player in mobs)
		if((player.client) && (player.ready) && ((player.client.using_antag_token)))
			token_list += player.mind
	if (!token_list.len)
		return 0
	else
		return token_list

/proc/strip_bad_characters(var/text)
	var/list/bad_characters = list("_", "'", "\"", "<", ">", ";", "[", "]", "{", "}", "|", "\\", "/")
	. = text
	for(var/c in bad_characters)
		. = replacetext(., c, " ")

var/list/english_num = list("0" = "zero", "1" = "one", "2" = "two", "3" = "three", "4" = "four", "5" = "five", "6" = "six", "7" = "seven", "8" = "eight", "9" = "nine",\
"10" = "ten", "11" = "eleven", "12" = "twelve", "13" = "thirteen", "14" = "fourteen", "15" = "fifteen", "16" = "sixteen", "17" = "seventeen", "18" = "eighteen", "19" = "nineteen",\
"20" = "twenty", "30" = "thirty", "40" = "forty", "50" = "fifty", "60" = "sixty", "70" = "seventy", "80" = "eighty", "90" = "ninety")

/proc/get_english_num(var/num, var/sep) // can only do up to 999,999 because of scientific notation kicking in after 6 digits
	if (!num || !length(english_num))
		return

	DEBUG_MESSAGE("<b>get_english_num receives num \"[num]\"</b>")

	if (istext(num))
		num = text2num(num)

	var/num_return = null

	if (num == 0) // 0
		num_return = "[english_num["[num]"]]"

	else if ((num >= 1) && (num <= 20)) // 1 to 20
		num_return = "[english_num["[num]"]]"

	else if ((num > 20) && (num < 100)) // 21 to 99
		var/tens = text2num(copytext("[num]", 1, 2)) * 10
		var/ones = text2num(copytext("[num]", 2))
		if (ones <= 0)
			num_return = "[english_num["[tens]"]]"
		else
			num_return = "[english_num["[tens]"]][sep ? sep : " "][english_num["[ones]"]]"

	else if ((num >= 100) && (num < 1000)) // 100 to 999
		var/hundreds = text2num(copytext("[num]", 1, 2))
		var/tens = text2num(copytext("[num]", 2))
		if (tens <= 0)
			num_return = "[english_num["[hundreds]"]] hundred"
		else
			num_return = "[english_num["[hundreds]"]] hundred and [get_english_num(tens)]"

	else if ((num >= 1000) && (num < 1000000)) // 1,000 to 999,999
		var/thousands = null
		var/hundreds = null

		switch (num)
			if (1000 to 9999)
				thousands = text2num(copytext("[num]", 1, 2))
				hundreds = text2num(copytext("[num]", 2))
			if (10000 to 999999)
				thousands = text2num(copytext("[num]", 1, 3))
				hundreds = text2num(copytext("[num]", 3))
			if (100000 to 999999)
				thousands = text2num(copytext("[num]", 1, 4))
				hundreds = text2num(copytext("[num]", 4))

		if (hundreds <= 0)
			num_return = "[get_english_num(thousands)] thousand"
		else if (hundreds < 100)
			num_return = "[get_english_num(thousands)] thousand and [get_english_num(hundreds)]"
		else
			num_return = "[get_english_num(thousands)] thousand, [get_english_num(hundreds)]"

	if (num_return)
		DEBUG_MESSAGE("<b>get_english_num returns num \"[num_return]\"</b>")
		return num_return

/proc/mutual_attach(var/atom/movable/A as obj|mob, var/atom/movable/B as obj|mob)
	if (!istype(A) || !istype(B))
		return
	if (A.anchored || B.anchored)
		A.anchored = 1
		B.anchored = 1

	if (!islist(A.attached_objs))
		A.attached_objs = list()
	if (!islist(B.attached_objs))
		B.attached_objs = list()

	A.attached_objs |= B
	B.attached_objs |= A

/proc/mutual_detach(var/atom/movable/A as obj|mob, var/atom/movable/B as obj|mob)
	if (!istype(A) || !istype(B))
		return
	A.anchored = initial(A.anchored)
	B.anchored = initial(B.anchored)
	if (islist(A.attached_objs) && A.attached_objs.Find(B))
		A.attached_objs.Remove(B)
	if (islist(B.attached_objs) && B.attached_objs.Find(A))
		B.attached_objs.Remove(A)

// This function counts a passed job.
proc/countJob(rank)
	. = 0
	for(var/mob/H in mobs)
		if(H.mind && H.mind.assigned_role == rank)
			.++
		LAGCHECK(LAG_REALTIME)

/atom/proc/letter_overlay(var/letter as text, var/lcolor, var/dir)
	if (!letter) // you get something random you shithead
		letter = pick("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
	if (!dir)
		dir = NORTHEAST
	if (!lcolor)
		lcolor = rgb(rand(0,255),rand(0,255),rand(0,255))
	var/image/B = image('icons/effects/letter_overlay.dmi', loc = src, icon_state = "[letter]2")
	var/image/L = image('icons/effects/letter_overlay.dmi', loc = src, icon_state = letter)
	B.color = lcolor
	var/px = 0
	var/py = 0

	if (dir & (EAST | WEST))
		px = 11
		if (dir & WEST)
			px *= -1

	if (dir & (NORTH | SOUTH))
		py = 11
		if (dir & SOUTH)
			py *= -1

	B.pixel_x = px
	L.pixel_x = px

	B.pixel_y = py
	L.pixel_y = py

	src.overlays += B
	src.overlays += L
	return

/atom/proc/debug_loverlay()
	var/letter = input(usr, "Please select a letter icon to display.", "Select Letter", "A") as null|anything in list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
	if (!letter)
		return
	var/lcolor = input(usr, "Please enter a color for the icon.", "Input Color", "#FFFFFF") as null|text
	if (!lcolor)
		return
	var/dir = input(usr, "Please select a direction for the icon to display.", "Select Direction", "NORTHEAST") as null|anything in list("NORTH", "SOUTH", "EAST", "WEST", "NORTHEAST", "NORTHWEST", "SOUTHEAST", "SOUTHWEST")
	if (!dir)
		return
	src.letter_overlay(letter, lcolor, text2dir(dir))

/// Returns a list of eligible dead players that COULD choose to respawn or whatever
/proc/eligible_dead_player_list(var/allow_dead_antags = 0, var/require_client = FALSE)
	. = list()
	for (var/datum/mind/M in ticker.minds)
		if (M.current && M.current.client)
			var/client/C = M.current.client
			if (dead_player_list_helper(M.current, allow_dead_antags, require_client) != 1)
				continue
			if (C.holder && !C.holder.ghost_respawns && !C.player_mode || !M.show_respawn_prompts)
				continue
			. += M

/// Returns a list of eligible dead players to be respawned as an antagonist or whatever (Convair880).
/// Text messages: 1: alert | 2: alert (chatbox) | 3: alert acknowledged (chatbox) | 4: no longer eligible (chatbox) | 5: waited too long (chatbox)
/proc/dead_player_list(var/return_minds = 0, var/confirmation_spawn = 0, var/list/text_messages = list(), var/allow_dead_antags = 0,
		var/require_client = FALSE)
	var/list/candidates = list()
	// Confirmation delay specified, so prompt eligible dead mobs and wait for response.
	if (confirmation_spawn > 0)
		var/ghost_timestamp = TIME

		// Preliminary work.
		var/text_alert = "Would you like to be respawned? Your name will be added to the list of eligible candidates and may be selected at random by the game."
		var/text_chat_alert = "You are eligible to be respawned. You have [confirmation_spawn / 10] seconds to respond to the offer."
		var/text_chat_added = "You have been added to the list of eligible candidates. The game will pick a player soon. Good luck!"
		var/text_chat_failed = "You are no longer eligible for the offer."
		var/text_chat_toolate = "You have waited too long to respond to the offer."

		if (text_messages.len)
			if (text_messages.len >= 1) text_alert = text_messages[1]
			if (text_messages.len >= 2) text_chat_alert = text_messages[2]
			if (text_messages.len >= 3) text_chat_added = text_messages[3]
			if (text_messages.len >= 4) text_chat_failed = text_messages[4]
			if (text_messages.len >= 5) text_chat_toolate = text_messages[5]

		text_alert = strip_html(text_alert, MAX_MESSAGE_LEN, 1)
		text_chat_alert = "<span class='notice'><h3>[strip_html(text_chat_alert, MAX_MESSAGE_LEN)]</h3></span>"
		text_chat_added = "<span class='notice'><h3>[strip_html(text_chat_added, MAX_MESSAGE_LEN)]</h3></span>"
		text_chat_failed = "<span class='alert'><b>[strip_html(text_chat_failed, MAX_MESSAGE_LEN)]</b></span>"
		text_chat_toolate = "<span class='alert'><b>[strip_html(text_chat_toolate, MAX_MESSAGE_LEN)]</b></span>"

		// Run prompts. Minds are preferable to mob references because of the confirmation delay.
		for (var/datum/mind/M in ticker.minds)
			if (M.current && M.current.client)
				var/client/C = M.current.client
				if (dead_player_list_helper(M.current, allow_dead_antags, require_client) != 1)
					continue
				if (C.holder && !C.holder.ghost_respawns && !C.player_mode || !M.show_respawn_prompts)
					continue

				SPAWN(0) // Don't lock up the entire proc.
					M.current.playsound_local(M.current, 'sound/misc/lawnotify.ogg', 50, flags=SOUND_IGNORE_SPACE)
					boutput(M.current, text_chat_alert)
					var/list/ghost_button_prompts = list("Yes", "No", "Stop these")
					var/response = tgui_alert(M.current, text_alert, "Respawn", ghost_button_prompts, (ghost_timestamp + confirmation_spawn - TIME), autofocus = FALSE)
					if (response == "Yes")
						if (ghost_timestamp && (TIME > ghost_timestamp + confirmation_spawn))
							if (M.current) boutput(M.current, text_chat_toolate)
							return
						if (dead_player_list_helper(M.current, allow_dead_antags, require_client) != 1)
							if (M.current) boutput(M.current, text_chat_failed)
							return

						if (M.current && !(M in candidates))
							boutput(M.current, text_chat_added)
							candidates.Add(M)
					else if (response == "Stop these")
						M.show_respawn_prompts = FALSE
						return
					else
						return

		while (ghost_timestamp && TIME < ghost_timestamp + confirmation_spawn)
			sleep(30 SECONDS)

		// Filter list again.
		if (candidates.len)
			for (var/datum/mind/M2 in candidates)
				if (!M2.current || !ismob(M2.current) || dead_player_list_helper(M2.current, allow_dead_antags, require_client) != 1)
					candidates.Remove(M2)
					continue

			if (candidates.len)
				if (return_minds == 1)
					return candidates
				else
					var/list/mob/mobs = list()
					for (var/datum/mind/M3 in candidates)
						if (M3.current && ismob(M3.current))
							if (!(M3.current in mobs))
								mobs.Add(M3.current)

					return mobs
			else
				return list()
		else
			return list()

	// Confirmationd delay not specified, return list right away.
	candidates = list()

	for (var/mob/O in mobs)
		if (dead_player_list_helper(O, allow_dead_antags, require_client) != 1)
			continue
		if (!(O in candidates))
			candidates.Add(O)

	if (return_minds == 1)
		var/list/datum/mind/minds = list()
		for (var/mob/M2 in candidates)
			if (M2.mind && !(M2.mind in minds))
				minds.Add(M2.mind)

		return minds

	return candidates

// So there aren't multiple instances of C&P code (Convair880).
/proc/dead_player_list_helper(var/mob/G, var/allow_dead_antags = 0, var/require_client = FALSE)
	if (!G?.mind || G.mind.dnr)
		return 0
	// if (!isobserver(G) && !(isliving(G) && isdead(G))) // if (NOT /mob/dead) AND NOT (/mob/living AND dead)
	// 	return 0
	// If (alive) and (not in the afterlife, or in the afterlife but in hell) and (not a VR ghost)
	// (basically, allow people who are alive in the afterlife or in VR to get respawn popups)
	if (!isdead(G) && !(istype(get_area(G), /area/afterlife) && !istype(get_area(G), /area/afterlife/hell)) && !isVRghost(G))
		return 0
	if (istype(G, /mob/new_player) || G.respawning)
		return 0
	if (jobban_isbanned(G, "Syndicate"))
		return 0
	if (jobban_isbanned(G, "Special Respawn"))
		return 0
	if (require_client && !G.client)
		return 0

	if (isobserver(G))
		var/mob/dead/observer/the_ghost = null

		if (istype(G, /mob/dead/observer))
			the_ghost = G

		if (istype(G, /mob/dead/target_observer))
			var/mob/dead/target_observer/TO = G
			if (TO.ghost && istype(TO.ghost, /mob/dead/observer))
				the_ghost = TO.ghost

		if (!the_ghost || !isobserver(the_ghost) || !isdead(the_ghost) || the_ghost.observe_round)
			return 0

	if (!allow_dead_antags && (!isnull(G.mind.special_role) || length(G.mind.former_antagonist_roles))) // Dead antagonists have had their chance.
		return 0

	return 1

/proc/check_target_immunity(var/atom/target, var/ignore_everything_but_nodamage = 0, var/atom/source = 0)
	var/is_immune = 0

	var/area/a = get_area( target )
	if( a?.sanctuary )
		return 1

	if (isliving(target))
		var/mob/living/L = target

		if (!isdead(L))
			if (ignore_everything_but_nodamage == 1)
				if (L.nodamage)
					is_immune = 1
			else
				if (L.nodamage || L.spellshield)
					is_immune = 1

		if (source && istype(source,/obj/projectile) && ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.stance == "dodge") //matrix dodge flip
				is_immune = 1

	//if (is_immune == 1)
	//	DEBUG_MESSAGE("[L] is immune to damage, aborting.")

	return is_immune

// Their antag status is revoked on death/implant removal/expiration, but we still want them to show up in the game over stats (Convair880).
/proc/remove_mindhack_status(var/mob/M, var/hack_type ="", var/removal_type ="")
	if (!M || !M.mind || !hack_type || !removal_type)
		return

	// Find our master's mob reference (if any).
	var/mob/mymaster = ckey_to_mob(M.mind.master)

	switch (hack_type)
		if ("mindhack")
			switch (removal_type)
				if ("expired")
					logTheThing(LOG_COMBAT, M, "'s mindhack implant (implanted by [mymaster ? "[constructTarget(mymaster,"combat")]" : "*NOKEYFOUND*"]) has worn off.")
				if ("surgery")
					logTheThing(LOG_COMBAT, M, "'s mindhack implant (implanted by [mymaster ? "[constructTarget(mymaster,"combat")]" : "*NOKEYFOUND*"]) was removed surgically.")
				if ("override")
					logTheThing(LOG_COMBAT, M, "'s mindhack implant (implanted by [mymaster ? "[constructTarget(mymaster,"combat")]" : "*NOKEYFOUND*"]) was overridden by a different implant.")
				if ("death")
					logTheThing(LOG_COMBAT, M, "(implanted by [mymaster ? "[constructTarget(mymaster,"combat")]" : "*NOKEYFOUND*"]) has died, removing mindhack status.")
				else
					logTheThing(LOG_COMBAT, M, "'s mindhack implant (implanted by [mymaster ? "[constructTarget(mymaster,"combat")]" : "*NOKEYFOUND*"]) has vanished mysteriously.")

			remove_antag(M, null, 1, 0)
			if (M.mind && ticker.mode && !(M.mind in ticker.mode.former_antagonists))
				if (!(ROLE_MINDHACK in M.mind.former_antagonist_roles))
					M.mind.former_antagonist_roles.Add(ROLE_MINDHACK)
				ticker.mode.former_antagonists += M.mind

		if ("vthrall")
			switch (removal_type)
				if ("death")
					logTheThing(LOG_COMBAT, M, "(enthralled by [mymaster ? "[constructTarget(mymaster,"combat")]" : "*NOKEYFOUND*"]) has died, removing vampire thrall status.")
				else
					logTheThing(LOG_COMBAT, M, "(enthralled by [mymaster ? "[constructTarget(mymaster,"combat")]" : "*NOKEYFOUND*"]) has been freed mysteriously, removing vampire thrall status.")

			remove_antag(M, null, 1, 0)
			if (M.mind && ticker.mode && !(M.mind in ticker.mode.former_antagonists))
				if (!M.mind.former_antagonist_roles.Find(ROLE_VAMPTHRALL))
					M.mind.former_antagonist_roles.Add(ROLE_VAMPTHRALL)
				ticker.mode.former_antagonists += M.mind

		// This is only used for spy minions and mindhacked antagonists at the moment.
		if ("otherhack")
			switch (removal_type)
				if ("expired")
					logTheThing(LOG_COMBAT, M, "'s mindhack implant (implanted by [mymaster ? "[constructTarget(mymaster,"combat")]" : "*NOKEYFOUND*"]) has worn off.")
				if ("surgery")
					logTheThing(LOG_COMBAT, M, "'s mindhack implant (implanted by [mymaster ? "[constructTarget(mymaster,"combat")]" : "*NOKEYFOUND*"]) was removed surgically.")
				if ("override")
					logTheThing(LOG_COMBAT, M, "'s mindhack implant (implanted by [mymaster ? "[constructTarget(mymaster,"combat")]" : "*NOKEYFOUND*"]) was overridden by a different implant.")
				if ("death")
					logTheThing(LOG_COMBAT, M, "(mindhacked by [mymaster ? "[constructTarget(mymaster,"combat")]" : "*NOKEYFOUND*"]) has died, removing mindhack status.")
				else
					logTheThing(LOG_COMBAT, M, "(mindhacked by [mymaster ? "[constructTarget(mymaster,"combat")]" : "*NOKEYFOUND*"]) has been freed mysteriously, removing mindhack status.")

			// Fix for mindhacked traitors etc losing their antagonist status.
			if (M.mind && (M.mind.special_role == "spyminion"))
				remove_antag(M, null, 1, 0)
			else
				M.mind.master = null
			if (M.mind && ticker.mode && !(M.mind in ticker.mode.former_antagonists))
				if (!(ROLE_MINDHACK in M.mind.former_antagonist_roles))
					M.mind.former_antagonist_roles.Add(ROLE_MINDHACK)
				ticker.mode.former_antagonists += M.mind

		else
			logTheThing(LOG_DEBUG, M, "<b>Convair880</b>: [M] isn't mindhacked or vampire thrall, can't remove mindhack status.")
			return

	if (removal_type == "death")
		boutput(M, "<h2><span class='alert'>Since you have died, you are no longer mindhacked! Do not obey your former master's orders even if you've been brought back to life somehow.</span></h2>")
		M.show_antag_popup("mindhackdeath")
	else if (removal_type == "override")
		boutput(M, "<h2><span class='alert'>Your mindhack implant has been overridden by a new one, cancelling out your former allegiances!</span></h2>")
		M.show_antag_popup("mindhackoverride")
	else
		boutput(M, "<h2><span class='alert'>Your mind is your own again! You no longer feel the need to obey your former master's orders.</span></h2>")
		M.show_antag_popup("mindhackexpired")

	return

/**
  * Looks up a player based on a string. Searches a shit load of things ~whoa~. Returns a list of mob refs.
  */
/proc/whois(target, limit = null, admin)
	target = trim(ckey(target))
	if (!target)
		return null
	. = list()
	for (var/mob/M in mobs)
		if (M.ckey && (!limit || length(.) < limit))
			if (findtext(M.real_name, target))
				. += M
			else if (findtext(M.ckey, target))
				. += M
			else if (findtext(M.key, target))
				. += M
			else if (M.mind)
				if (findtext(M.mind.assigned_role, target))
					if (M.mind.assigned_role == "MODE") // We matched on the internal MODE job this doesn't fuckin' count
						continue
					else
						. += M
				else if (findtext(M.mind.special_role, target))
					. += M

	if (!length(.))
		return null

/**
  * A universal ckey -> mob reference lookup proc, adapted from whois() (Convair880).
  */
/proc/ckey_to_mob(target as text, exact=1)
	if(isnull(target))
		return
	target = ckey(target)
	for(var/client/C) // exact match first
		if(C.ckey == target)
			return C.mob
	if(!exact)
		for(var/client/C) // prefix match second
			if(copytext(C.ckey, 1, length(target) + 1) == target)
				return C.mob
		for(var/client/C) // substring match third
			if (findtext(C.ckey, target))
				return C.mob

/**
  * Given a ckey finds a mob with that ckey even if they are not in the game.
  */
/proc/ckey_to_mob_maybe_disconnected(target as text, exact=1)
	if(isnull(target))
		return
	target = ckey(target)
	for(var/mob/M in mobs)
		if(M.ckey == target)
			return M
	if(!exact)
		for(var/mob/M in mobs) // prefix match second
			if(copytext(M.ckey, 1, length(target) + 1) == target)
				return M
		for(var/mob/M in mobs) // substring match third
			if (findtext(M.ckey, target))
				return M

/**
  * Finds whoever's dead.
	*/
/proc/whodead()
	. = list()
	for (var/mob/M in mobs)
		if (M.ckey && isdead(M))
			. += M

/**
  * Returns random hex value of length given
  */
/proc/random_hex(var/digits as num)
	if (!digits)
		digits = 6
	. = ""
	for (var/i in 1 to digits)
		. += pick(hex_chars)

//A global cooldown on this so it doesnt destroy the external server
var/global/nextDectalkDelay = 5 //seconds
var/global/lastDectalkUse = 0
/proc/dectalk(msg)
	if (!msg || !config.spacebee_api_key) return 0
	if (world.timeofday > (lastDectalkUse + (nextDectalkDelay * 10)))
		lastDectalkUse = world.timeofday
		msg = copytext(msg, 1, 2000)

		// Fetch via HTTP from goonhub
		var/datum/http_request/request = new()
		request.prepare(RUSTG_HTTP_METHOD_GET, "[config.spacebee_api_url]/api/tts?dectalk=[url_encode(msg)]&api_key=[config.spacebee_api_key]", "", "")
		request.begin_async()
		UNTIL(request.is_complete())
		var/datum/http_response/response = request.into_response()

		if (response.errored || !response.body)
			logTheThing(LOG_DEBUG, null, "<b>dectalk:</b> Failed to contact goonhub. msg : [msg]")
			return

		return list("audio" = response.body, "message" = msg)
	else
		return list("cooldown" = 1)

proc/copy_datum_vars(var/atom/from, var/atom/target)
	if (!target || !from) return
	for(var/V in from.vars)
		if (!issaved(from.vars[V]))
			continue

		if(V == "type") continue
		if(V == "parent_type") continue
		if(V == "vars") continue
		target.vars[V] = from.vars[V]

/**
  * Given hex color, returns string name of nearest named color
  */
/proc/hex2color_name(var/hex)
	if (!hex)
		return
	var/adj = 0
	if (copytext(hex, 1, 2) == "#")
		adj = 1

	var/hR = hex2num(copytext(hex, 1 + adj, 3 + adj))
	var/hG = hex2num(copytext(hex, 3 + adj, 5 + adj))
	var/hB = hex2num(copytext(hex, 5 + adj, 7 + adj))

	var/datum/color/C = new(hR, hG, hB, 0)
	var/name = get_nearest_color(C)
	if (name)
		return name

var/list/uppercase_letters = list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
var/list/lowercase_letters = list("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z")

var/global/list/allowed_restricted_z_areas

// Helper for blob, wraiths and whoever else might need them (Convair880).
/proc/restricted_z_allowed(var/mob/M, var/T)
	. = FALSE
	if(!allowed_restricted_z_areas)
		allowed_restricted_z_areas = concrete_typesof(/area/shuttle/escape) + concrete_typesof(/area/shuttle_transit_space) + concrete_typesof(/area/football/field)

	if (M && isblob(M))
		var/mob/living/intangible/blob_overmind/B = M
		if (B.tutorial)
			return TRUE

	var/area/A
	if (T && istype(T, /area))
		A = T
	else if (T && isturf(T))
		A = get_area(T)

	if (A && istype(A) && (A.type in allowed_restricted_z_areas))
		return TRUE

/**
  * Given center turf/atom, range, and list of things to smash, will damage said objects within range of center.
  * Used for sonic grenades and similar. Avoiding C&P Code.
  */
/proc/sonic_attack_environmental_effect(var/center, var/range, var/list/smash)
	if (!center || !isnum(range) || range <= 0)
		return 0

	if (!islist(smash) || !length(smash))
		return 0

	var/turf/CT
	if (isturf(center))
		CT = center
	else if (istype(center, /atom))
		CT = get_turf(center)

	if (!(CT && isturf(CT)))
		return 0

	// No visible_messages here because of text spam. The station has a lot of windows and light fixtures.
	// And once again, view() proved quite unreliable.
	for (var/S in smash)
		if (S == "window" || S == "r_window")
			for (var/obj/window/W in view(CT, range))
				if (prob(GET_DIST(W, CT) * 6))
					continue
				//W.health = 0
				//W.smash()
				W.damage_blunt(125,1)

		if (S == "light")
			for (var/obj/machinery/light/L in view(CT, range))
				L.broken()

		if (S == "displaycase")
			for (var/obj/displaycase/D in view(CT, range))
				D.ex_act(1)

		if (S == "glassware")
			for (var/obj/item/reagent_containers/glass/G in view(CT, range))
				if(G.can_recycle)
					G.smash()
			for (var/obj/item/reagent_containers/food/drinks/drinkingglass/G2 in range(CT, range))
				if(G2.can_recycle)
					G2.smash()

	return 1

/**
  * Returns hud style preferences of given client/mob
  */
/proc/get_hud_style(var/someone)
	if (!someone)
		return
	var/client/C = null
	if (isclient(someone))
		C = someone
	else if (ismob(someone))
		var/mob/M = someone
		if (M.client)
			C = M.client
	if (!C || !C.preferences)
		return
	. = C.preferences.hud_style

/**
  * Returns list of all mobs within an atom. Not cheap! (unlike ur mum)
  */
/proc/get_all_mobs_in(atom/found)
	. = list()
	if(ismob(found))
		. += found
	for(var/atom/thing in found)
		var/list/outp = get_all_mobs_in(thing)
		. += outp

/**
  * Given user, will proompt user to select skin color from list (or custom) and returns skin tone after blending
  */
/proc/get_standard_skintone(var/mob/user)
	var/new_tone = tgui_input_list(user, "Please select skin color.", "Character Generation", standard_skintones + "Custom...")
	if (new_tone == "Custom...")
		var/tone = tgui_input_number(user, "Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Skin tone picker", 1, 220, 1)
		if (tone)
			tone = 35 - clamp(round(text2num(tone)), 1, 220) // range is 34 to -194
			//new_tone = rgb(220 + tone, 220 + tone, 220 + tone)
			new_tone = blend_skintone(tone,tone,tone)
		else
			return null
	else if (new_tone)
		new_tone = standard_skintones[new_tone]

	return new_tone

/**
  * Blends given rgb values with old human mob skin color (#ffca95) to return a new rgb value
  */
/proc/blend_skintone(var/r1, var/g1, var/b1)
	//I expect we will only need to darken the already pale white image.
	var/r = min(r1 + 255, 255) //ff min 61 max 255
	var/g = min(g1 + 202, 255) //ca min 8 max 236
	var/b = min(b1 + 149, 255) //95 min 0 max 183
	return rgb(r,g,b)

/**
  * Returns a string based on the current job and antag role of the mob e.g. `"Staff Assistant [Traitor]"`
  */
/proc/getRole(var/mob/M, strip = 0)
	if (!M || !istype(M)) return

	var/role
	if (istype(M, /mob/living/carbon/cube/meat/krampus))
		role += "Krampus"
	if (M.mind)
		if (M.mind.assigned_role == "MODE")
			if (M.job)
				role += M.job
		else
			role += M.mind.assigned_role

		if (M.mind.special_role)
			var/special = uppertext(copytext(M.mind.special_role, 1, 2)) + copytext(M.mind.special_role, 2)
			if (!strip)
				special = "<span class='alert'>[special]</span>"

			role += " \[[special]]"

	else
		role += M.job

	return role

// DM simultaneously makes cursed shit like this work...
// yet won't work with just the unicode raws - infinite pain
var/const/___proper = "\proper"
var/const/___improper = "\improper"
var/static/regex/regexTextMacro = regex("[___proper]|[___improper]", "g")

/**
  * Removes the special data inserted via use of \improper etc in strings
  */
/proc/stripTextMacros(text)
	return replacetext(text, regexTextMacro, "")

/**
  * Returns true if given mob/client/mind is an admin
  */
/proc/isadmin(person)
	if (ismob(person))
		var/mob/M = person
		return !!(M?.client?.holder)

	else if (isclient(person))
		var/client/C = person
		return C.holder ? TRUE : FALSE

	else if (ismind(person))
		var/datum/mind/M = person
		return !!(M?.current?.client?.holder)

	return FALSE

/**
  * Returns span with a color gradient between two given colors of given message
  */
proc/gradientText(var/color1, var/color2, message)
  var/color1hex = hex2num(copytext(color1, 2))
  var/color2hex = hex2num(copytext(color2, 2))
  var/r1 = (color1hex >> 16) & 0xFF
  var/g1 = (color1hex >> 8) & 0xFF
  var/b1 = color1hex & 0xFF
  var/dr = ((color2hex >> 16) & 0xFF)- r1
  var/dg = ((color2hex >> 8) & 0xFF) - g1
  var/db = (color2hex & 0xFF) - b1
  var/list/result = new/list()
  var/n = rand(0,10)/10.0 // what a shitty name for a variable
  var/dir = prob(50) ? -1 : 1
  for(var/i=1, i<=length(message), i += 3)
    n += dir * 0.2
    if(prob(20))
      dir = dir/abs(dir) * -1
    if(n < 0)
      n = 0
      dir = 1
    if(n > 1)
      n = 1
      dir = -1
    var/col = rgb(r1 + dr*n, g1 + dg*n, b1 + db*n)
    var/chars = copytext(message, i, i+3)
    result += "<span style='color:[col]'>[chars]</span>"
  . = result.Join()

/**
  * Returns given text replaced by nonsense chars, excepting HTML tags, on a 40% or given % basis
  */
proc/radioGarbleText(var/message, var/per_letter_corruption_chance=40)
	var/split_html_text = splittext(message,  regex("<\[^>\]*>"), 1, length(message), TRUE) //I'd love to just use include_delimiters=TRUE, but byond
	var/list/corruptedChars = list("@","#","!",",",".","-","=","/","\\","'","\"","`","*","(",")","[","]","_","&")
	. = list()
	for(var/text_bit in split_html_text)
		if(findtext(text_bit, regex("<\[^>\]*>")))
			. += text_bit
			continue
		var/corrupted_bit = ""
		for(var/i=1 to length(text_bit))
			if(prob(per_letter_corruption_chance))
				corrupted_bit += pick(corruptedChars)
			else
				corrupted_bit += copytext(text_bit, i, i+1)
		. += corrupted_bit
	return jointext(.,"")


/**
  * Returns given text replaced entirely by nonsense chars
  */
proc/illiterateGarbleText(var/message)
	. = radioGarbleText(message, 100)

/**
  * Returns the time in seconds since a given timestamp
  */
proc/getTimeInSecondsSinceTime(var/timestamp)
	var/time_of_day = world.timeofday + ((world.timeofday < timestamp) ? 864000 : 0) // Offset the time of day in case of midnight rollover
	var/time_elapsed = (time_of_day - timestamp)/10
	return time_elapsed

/**
  * Handles the two states icon_size can be in: basic number, or string in WxH format
  */
proc/getIconSize()
	if (istext(world.icon_size))
		var/list/iconSizes = splittext(world.icon_size, "x")
		return list("width" = text2num(iconSizes[1]), "height" = text2num(iconSizes[2]))

	return world.icon_size

/**
  * Finds a client by ckey, throws exception if not found
  */
proc/getClientFromCkey(ckey)
	var/datum/player/player = find_player(ckey)
	if(!player?.client)
		throw EXCEPTION("Client not found")
	return player.client

/**
	* Returns true if the given atom is within src's contents (deeply/recursively)
	*/
/atom/proc/contains(var/atom/A)
	. = FALSE
	if(!A)
		return FALSE
	for(var/atom/found = A.loc, found, found = found.loc)
		if(found == src)
			return TRUE

/**
  * Removes non-whitelisted reagents from the reagents of TA
	*
  * * user: the mob that adds a reagent to an atom that has a reagent whitelist
	*
  * * TA: Target Atom. The thing that the user is adding the reagent to
  */
proc/check_whitelist(var/atom/TA, var/list/whitelist, var/mob/user as mob, var/custom_message = "")
	if (!whitelist || (!TA || !TA.reagents) || (islist(whitelist) && !length(whitelist)))
		return
	if (!custom_message)
		custom_message = "<span class='alert'>[TA] identifies and removes a harmful substance.</span>"

	var/found = 0
	for (var/reagent_id in TA.reagents.reagent_list)
		if (!whitelist.Find(reagent_id))
			TA.reagents.del_reagent(reagent_id)
			found = 1
	if (found)
		if(user)
			boutput(user, "[custom_message]")
		else if (ismob(TA.loc))
			var/mob/M = TA.loc
			boutput(M, "[custom_message]")
		else if(ismob(user))
			 // some procs don't know user, for instance because they are in on_reagent_change
			boutput(user, "[custom_message]")
		else
			TA.visible_message("[custom_message]")

/**
	*This proc checks if one atom is in the cone of vision of another one.
	*
	* It uses the following map grid for the check, where each point is an integer coordinate and the seer is at point X:
	*	```
	*					*
	*				* *
	*	POV ->	X * * *
	*				* *
	*					*
	*	```
	*
	* A '*' represents a point that is within X's FOV
	*/
/proc/in_cone_of_vision(var/atom/seer, var/atom/target)
	var/dir = get_dir(seer, target)
	switch(dir)
		if(NORTHEAST, SOUTHWEST)
			var/abs_x = abs(target.x - seer.x)
			var/abs_y = abs(target.y - seer.y)

			if (abs_y > abs_x)
				dir = turn(dir, 45)
			else if (abs_x > abs_y)
				dir = turn(dir, -45)

		if(NORTHWEST, SOUTHEAST)
			var/abs_x = abs(target.x - seer.x)
			var/abs_y = abs(target.y - seer.y)
			if (abs_y > abs_x)
				dir = turn(dir, -45)
			else if (abs_x > abs_y)
				dir = turn(dir, 45)

	return (seer.dir == dir)

/**
	* Returns the passed decisecond-format time in the form of a text string
	*/
proc/time_to_text(var/time)
	. = list()

	var/n_hours = max(0, round(time / (1 HOUR)))
	if(n_hours >= 2)
		. += n_hours
		. += "hours"
	else if(time >= 1 HOUR)
		. += "1 hour"
	time -= n_hours * 1 HOUR

	var/n_minutes = max(0, round(time / (1 MINUTE)))
	if(n_minutes >= 2)
		. += n_minutes
		. += "minutes"
	else if(time >= 1 MINUTE)
		. += "1 minute"
	time -= n_minutes * 1 MINUTE

	if(time == 1 SECOND)
		. += "1 second"
	else if(time || !length(.))
		. += "[round(time / (1 SECOND), 0.1)] seconds"
	. = jointext(., " ")

// this is dumb and bad but it makes the bicon not expand the line vertically and also centers it
// also it assumes 32px height by default
proc/inline_bicon(the_thing, height=32)
	return {"<span style="display:inline-block;vertical-align:middle;height:0px;">
	<div style="position:relative;top:-[height / 2]px">
	[bicon(the_thing)]
	</div>
	</span>"}


proc/total_clients()
	return length(clients)


//total clients used for player cap (which pretends admins don't exist)
proc/total_clients_for_cap()
	.= 0
	for (var/C in clients)
		if (C)
			var/client/CC = C
			if (!CC.holder)
				.++

	for (var/C in player_cap_grace)
		if (player_cap_grace[C] > TIME)
			.++


proc/client_has_cap_grace(var/client/C)
	if (C.ckey in player_cap_grace)
		.= (player_cap_grace[C.ckey] > TIME)


//TODO: refactor the below two into one proc

/// Returns true if not incapicitated and unhandcuffed (by default)
proc/can_act(var/mob/M, var/include_cuffs = 1)
	return !((include_cuffs && M.restrained()) || is_incapacitated(M))

/// Returns true if the given mob is incapacitated
proc/is_incapacitated(mob/M)
	return (M &&(\
		M.hasStatus("stunned") || \
		M.hasStatus("weakened") || \
		M.hasStatus("paralysis") || \
		M.hasStatus("pinned") || \
		M.stat))

/// sets up the list of ringtones players can select through character setup
proc/get_all_character_setup_ringtones()
	if(!length(selectable_ringtones))
		for (var/datum/ringtone/R as anything in filtered_concrete_typesof(/datum/ringtone, /proc/filter_is_character_setup_ringtone))
			var/datum/ringtone/R_prime = new R
			selectable_ringtones[R_prime.name] = R_prime
	return selectable_ringtones

/// converts `get_connected_directions_bitflag()` diagonal bits to byond direction flags
proc/connectdirs_to_byonddirs(var/connectdir_bitflag)
	. = 0
	if (!connectdir_bitflag) return
	if(16 & connectdir_bitflag) .|= NORTHEAST
	if(32 & connectdir_bitflag) .|= SOUTHEAST
	if(64 & connectdir_bitflag) .|= SOUTHWEST
	if(128 & connectdir_bitflag) .|= NORTHWEST

/proc/get_random_station_turf()
	var/list/areas = get_areas(/area/station)
	if (!areas.len)
		return
	var/area/A = pick(areas)
	if (!A)
		return
	var/list/turfs = get_area_turfs(A, 1)
	if (!turfs.len)
		return
	var/turf/T = pick(turfs)
	if (!T)
		return
	return T

/// adjusts a screen_loc to account for non-32px-width sprites, so they get centered in a HUD slot
/proc/do_hud_offset_thing(atom/movable/A, new_screen_loc)
	var/icon/IC = new/icon(A.icon)
	var/width = IC.Width()
	var/regex/locfinder = new(@"^(\w*)([+-]\d)?(:\d+)?(.*)$") //chops up X-axis of a screen_loc
	if(width != 32 && locfinder.Find("[new_screen_loc]")) //if we're 32-width, just use the loc we're given
		var/offset = 0
		if(startswith(locfinder.group[3], ":"))
			offset = text2num(copytext(locfinder.group[3], 2))
		offset -= (width-32)/2 // offsets the screen loc of the item by half the difference of the sprite width and the default sprite width (32), to center the sprite in the box
		return "[locfinder.group[1]][locfinder.group[2]][offset ? ":[offset]":""][locfinder.group[4]]"
	else
		return new_screen_loc //regex failed to match, just use what we got

/// For runtime logs- returns the thing's name, type, and ref as a string
/proc/identify_object(datum/thing)
	if (isnull(thing)) // null
		return "***NULL***"
	if (!istype(thing)) //  probably text or a num or something
		return thing
	return "[thing] \[\ref[thing]\] ([thing.type])" // actual datum
