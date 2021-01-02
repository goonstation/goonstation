/obj/screen/fullautoAimHUD
	name = ""
	desc = ""
	layer = HUD_LAYER - 1
	flags = NOSPLASH
	alpha = 0
	mouse_opacity = 2
	var/xOffset
	var/yOffset

	MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
		SEND_SIGNAL(usr, COMSIG_FULLAUTO_MOUSEDRAG, over_object, over_location, over_control, params)

	MouseDown(location, control, params)
		. = ..()
		SEND_SIGNAL(usr, COMSIG_FULLAUTO_MOUSEDOWN, src, location, control, params)

/datum/component/holdertargeting/fullauto
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	signals = list(COMSIG_FULLAUTO_MOUSEDOWN)
	mobtype = /mob/living
	proctype = .proc/begin_shootloop
	var/turf/target
	var/stopping = 0
	var/shooting
	var/delaystart
	var/delaymin
	var/rampfactor
	var/list/obj/screen/fullautoAimHUD/hudSquares = list()

	Initialize(_delaystart = 4 DECI SECONDS, _delaymin=1 DECI SECOND, _rampfactor=0.9)
		if(..() == COMPONENT_INCOMPATIBLE || !istype(parent, /obj/item/gun))
			return COMPONENT_INCOMPATIBLE
		else
			var/obj/item/gun/G = parent
			src.delaystart = _delaystart
			src.delaymin = _delaymin
			src.rampfactor = _rampfactor
			for(var/x in 1 to WIDE_TILE_WIDTH)
				for(var/y in 1 to 15)
					var/obj/screen/fullautoAimHUD/hudSquare = new /obj/screen/fullautoAimHUD
					hudSquare.screen_loc = "[x],[y]"
					hudSquare.xOffset = x
					hudSquare.yOffset = y
					hudSquares["[x],[y]"] = hudSquare

			if(ismob(G.loc))
				on_pickup(null, G.loc)

	disposing()
		for(var/hudSquare in hudSquares)
			qdel(hudSquare)
		. = ..()

	on_pickup(datum/source, mob/user)
		. = ..()
		for(var/x in 1 to (istext(user.client.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH))
			for(var/y in 1 to 15)
				user.client.screen += hudSquares["[x],[y]"]
		user.targeting_ability = 1
		user.update_cursor()
		stopping = 0

	on_dropped(datum/source, mob/user)
		end_shootloop(user)
		for(var/x in 1 to (istext(user.client.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH))
			for(var/y in 1 to 15)
				user.client.screen -= hudSquares["[x],[y]"]
		user.targeting_ability = 0
		user.update_cursor()
		. = ..()

/datum/component/holdertargeting/fullauto/proc/begin_shootloop(mob/living/user, object, location, control, params)
	if(!stopping)
		var/obj/item/gun/G = parent
		src.retarget(user, object, location, control, params)
		RegisterSignal(user, COMSIG_FULLAUTO_MOUSEDRAG, .proc/retarget)
		RegisterSignal(user, COMSIG_MOUSEUP, .proc/end_shootloop)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/moveRetarget)
		src.shootloop(user)

/datum/component/holdertargeting/fullauto/proc/moveRetarget(mob/M, newLoc, direct)
	if(src.target)
		src.target = get_step(src.target, direct)

/datum/component/holdertargeting/fullauto/proc/retarget(mob/M, object, location, control, params)

	var/turf/T
	var/obj/screen/fullautoAimHUD/F = object
	if(istype(F))
		T = locate(M.x + (F.xOffset + -1 - ((istext(M.client.view) ? WIDE_TILE_WIDTH : SQUARE_TILE_WIDTH) - 1) / 2),\
							M.y + (F.yOffset + -1 - 7),\
							M.z)

		if(T)
			src.target = T

/datum/component/holdertargeting/fullauto/proc/shootloop(mob/living/L)
	set waitfor = 0
	if(shooting)
		return

	var/obj/item/gun/G = parent
	var/delay = delaystart
	shooting = 1

	while(G.canshoot() && !stopping)
		G.shoot(target ? target : get_step(L, NORTH), get_turf(L), L)
		G.suppress_fire_msg = 1
		sleep(max(delay*=rampfactor, delaymin))

	//loop ended - reset values
	G.suppress_fire_msg = initial(G.suppress_fire_msg)
	UnregisterSignal(L, COMSIG_FULLAUTO_MOUSEDRAG)
	UnregisterSignal(L, COMSIG_MOUSEUP)
	UnregisterSignal(L, COMSIG_MOVABLE_MOVED)
	stopping = 0
	shooting = 0

/datum/component/holdertargeting/fullauto/proc/end_shootloop(mob/living/L)
	stopping = 1
